page 60117 "MDF Dim Mandatory FactBox"
{
    PageType = ListPart;
    SourceTable = "MDF Dim Mandatory Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Header)
            {
                field(StatusTxt; StatusTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                }
            }

            repeater(Lines)
            {
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        DimMgt: Codeunit "MDF Dim Mandatory Mgt";
        StatusTxt: Text[100];
        StyleTxt: Text[30];

    procedure LoadData(VariantRec: Variant)
    begin
        DimMgt.GetMissingDimensions(Rec, VariantRec);

        if Rec.Count = 0 then begin
            StatusTxt := '✓ Dimensiones completas';
            StyleTxt := 'Favorable';
        end else begin
            StatusTxt := '⚠ ' + Format(Rec.Count) + ' dimensiones faltantes';
            StyleTxt := 'Attention';
        end;

        CurrPage.Update(false);
    end;
}
