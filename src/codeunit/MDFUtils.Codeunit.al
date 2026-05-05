codeunit 60112 "MDF Utils"
{
    procedure InitializeCustomerFields()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CustomerFieldSetup: Record "MDF Mandatory Fields";
        i: Integer;
    begin
        RecRef.Open(Database::Customer);

        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);

            if not CustomerFieldSetup.Get(Database::Customer, FieldRef.Number) then begin
                CustomerFieldSetup.Init();
                CustomerFieldSetup."Table No." := Database::Customer;
                CustomerFieldSetup."Field No." := FieldRef.Number;
                CustomerFieldSetup."Field Name" := FieldRef.Name;
                CustomerFieldSetup.Mandatory := false;
                CustomerFieldSetup.Insert();
            end;
        end;

        RecRef.Close();
    end;

    procedure InitializeTableFields(TableNo: Integer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MandatorySetup: Record "MDF Mandatory Fields";
        i: Integer;
    begin
        RecRef.Open(TableNo);

        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);

            if not MandatorySetup.Get(TableNo, FieldRef.Number) then begin
                MandatorySetup.Init();
                MandatorySetup."Table No." := TableNo;
                MandatorySetup."Field No." := FieldRef.Number;
                MandatorySetup."Field Name" := FieldRef.Name;
                MandatorySetup.Mandatory := false;
                MandatorySetup.Insert();
            end;
        end;

        RecRef.Close();
    end;

    procedure ValidateMandatoryFields(var AnyRec: Variant): Boolean
    var
        MandatorySetup: Record "MDF Mandatory Fields";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MissingFields: Text;
        IsValid: Boolean;
    begin
        RecRef.GetTable(AnyRec);
        IsValid := true;

        MandatorySetup.SetRange("Table No.", RecRef.Number);
        MandatorySetup.SetRange(Mandatory, true);

        if MandatorySetup.FindSet() then
            repeat
                FieldRef := RecRef.Field(MandatorySetup."Field No.");

                if IsFieldEmpty(FieldRef) then begin
                    IsValid := false;
                    MissingFields += StrSubstNo('\%1', MandatorySetup."Field Name");
                end;

            until MandatorySetup.Next() = 0;

        if not IsValid then begin
            Message(
                'The following fields are mandatory for %1%2',
                RecRef.RecordId,
                MissingFields);
            exit(true);
        end;


        exit(false);
    end;

    local procedure IsFieldEmpty(FieldRef: FieldRef): Boolean
    var
        tempDate: Date;
        tempInt: Integer;
    begin
        case FieldRef.Type of
            FieldType::Code,
            FieldType::Text:
                exit(Format(FieldRef.Value) = '');

            FieldType::Date:
                begin
                    tempDate := FieldRef.Value;
                    exit(tempDate = 0D);
                end;


            FieldType::Decimal,
            FieldType::Integer,
            FieldType::BigInteger:
                begin
                    tempInt := FieldRef.Value;
                    exit(tempInt = 0);
                end;


            FieldType::Boolean:
                exit(false); // normalmente no se valida boolean

            else
                exit(Format(FieldRef.Value) = '');
        end;
    end;

    procedure ValidateMandatoryCustomerFields(Customer: Record Customer)
    var
        CustomerFieldSetup: Record "MDF Mandatory Fields";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(Customer);

        CustomerFieldSetup.SetRange("Table No.", Database::Customer);
        CustomerFieldSetup.SetRange(Mandatory, true);

        if CustomerFieldSetup.FindSet() then
            repeat
                FieldRef := RecRef.Field(CustomerFieldSetup."Field No.");

                if Format(FieldRef.Value) = '' then
                    Message(
                        'The field %1 is mandatory before the customer can be unblocked.',
                        CustomerFieldSetup."Field Name");
            until CustomerFieldSetup.Next() = 0;
    end;

    procedure GetMissingFields(var TempBuffer: Record "MDF Mandatory Fields Buffer" temporary; VariantRec: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MDFSetup: Record "MDF Mandatory Fields";
    begin
        TempBuffer.DeleteAll();

        RecRef.GetTable(VariantRec);

        MDFSetup.SetRange("Table No.", RecRef.Number);
        MDFSetup.SetRange(Mandatory, true);

        if MDFSetup.FindSet() then
            repeat
                if RecRef.FieldExist(MDFSetup."Field No.") then begin

                    FieldRef := RecRef.Field(MDFSetup."Field No.");

                    if IsEmpty(FieldRef) then begin
                        TempBuffer.Init();
                        TempBuffer."Field No." := MDFSetup."Field No.";
                        TempBuffer."Field Name" := FieldRef.Caption;
                        TempBuffer."Is Missing" := true;
                        TempBuffer.Insert();
                    end;
                end;

            until MDFSetup.Next() = 0;
    end;

    local procedure IsEmpty(FieldRef: FieldRef): Boolean
    var
        IntVal: Integer;
        DecVal: Decimal;
        DateVal: Date;
        BoolVal: Boolean;
        TxtVal: Text;
    begin
        case FieldRef.Type of
            FieldType::Code,
            FieldType::Text:
                begin
                    TxtVal := Format(FieldRef.Value);
                    exit(TxtVal = '');
                end;

            FieldType::Integer:
                begin
                    IntVal := FieldRef.Value;
                    exit(IntVal = 0);
                end;

            FieldType::Decimal:
                begin
                    DecVal := FieldRef.Value;
                    exit(DecVal = 0);
                end;

            FieldType::Date:
                begin
                    DateVal := FieldRef.Value;
                    exit(DateVal = 0D);
                end;

            FieldType::Boolean:
                begin
                    BoolVal := FieldRef.Value;
                    exit(BoolVal = false);
                end;

            FieldType::Option:
                begin
                    TxtVal := Format(FieldRef.Value);
                    exit(TxtVal = '');
                end;

            else
                exit(false);
        end;
    end;
}
