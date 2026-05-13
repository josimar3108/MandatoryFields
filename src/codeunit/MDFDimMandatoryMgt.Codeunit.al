codeunit 60115 "MDF Dim Mandatory Mgt"
{
    procedure GetMissingDimensions(var TempBuffer: Record "MDF Dim Mandatory Buffer" temporary; VariantRec: Variant)
    var
        RecRef: RecordRef;
        DefaultDim: Record "Default Dimension";
        Setup: Record "MDF Tables Default Dimension";
        TableID: Integer;
        NoCode: Code[20];
    begin
        TempBuffer.DeleteAll();

        RecRef.GetTable(VariantRec);
        TableID := RecRef.Number;

        NoCode := GetNoFromRecRef(RecRef);

        if NoCode = '' then
            exit;

        if Setup.FindSet() then
            repeat
                if IsDimensionMandatoryForTable(Setup, TableID) then begin
                    if not DimensionExists(DefaultDim, TableID, NoCode, Setup."Dimension Code") then begin
                        TempBuffer.Init();
                        TempBuffer."Dimension Code" := Setup."Dimension Code";
                        TempBuffer."Is Missing" := true;
                        TempBuffer.Insert();
                    end;

                end;
            until Setup.Next() = 0;
    end;

    local procedure IsDimensionMandatoryForTable(Setup: Record "MDF Tables Default Dimension"; TableID: Integer): Boolean
    begin
        case TableID of
            Database::Item:
                exit(Setup."Default Item");

            Database::Customer:
                exit(Setup."Default Customer");

            Database::Vendor:
                exit(Setup."Default Vendor");
        end;

        exit(false);
    end;

    procedure DimensionExists(var DefaultDim: Record "Default Dimension"; TableID: Integer; NoCode: Code[20]; DimCode: Code[20]): Boolean
    begin
        DefaultDim.Reset();
        DefaultDim.SetRange("Table ID", TableID);
        DefaultDim.SetRange("No.", NoCode);
        DefaultDim.SetRange("Dimension Code", DimCode);
        DefaultDim.SetFilter("Dimension Value Code", '<>%1', '');
        exit(DefaultDim.FindFirst());
    end;

    local procedure GetNoFromRecRef(RecRef: RecordRef): Code[20]
    var
        FieldRef: FieldRef;
    begin
        if RecRef.FieldExist(1) then begin
            FieldRef := RecRef.Field(1); // normalmente "No."
            exit(FieldRef.Value);
        end;

        exit('');
    end;

    procedure HasMissingMandatoryDimensions(var VariantRec: Variant): Boolean
    var
        TempBuffer: Record "MDF Dim Mandatory Buffer" temporary;
    begin
        GetMissingDimensions(TempBuffer, VariantRec);

        exit(not TempBuffer.IsEmpty());
    end;
}
