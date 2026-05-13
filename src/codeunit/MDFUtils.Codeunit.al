codeunit 60112 "MDF Utils"
{

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

            if FieldRef.Class = FieldClass::FlowField then
                continue;

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
                exit(false);

            else
                exit(Format(FieldRef.Value) = '');
        end;
    end;

    local procedure IsFeatureEnabled(TableID: Integer): Boolean
    var
        Setup: Record "MDF Setup";
        TableCfg: Record "MDF Table Config";
    begin
        if not Setup.Get('SETUP') then
            exit(false);

        if not Setup."Enable Mandatory Fields" then
            exit(false);

        if not TableCfg.Get(TableID) then
            exit(false);

        exit(TableCfg."Enable Mandatory Fields");
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

    procedure IsBlockManaged(TableID: Integer): Boolean
    var
        MDFTableConfig: Record "MDF Table Config";
    begin
        if not MDFTableConfig.Get(TableID) then
            exit(false);

        exit(MDFTableConfig."Block On Validation");
    end;

    #region Item - Customer - Vendor Validations

    procedure ValidateAndApplyBlocking(VariantRec: Variant)
    var
        MDFDimMandatoryMgt: Codeunit "MDF Dim Mandatory Mgt";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(VariantRec);

        if ValidateMandatoryFields(VariantRec)
        or MDFDimMandatoryMgt.HasMissingMandatoryDimensions(VariantRec)
        then
            ApplyBlockedState(RecRef, true)
        else
            ApplyBlockedState(RecRef, false);
    end;

    local procedure ApplyBlockedState(var RecRef: RecordRef; IsBlocked: Boolean)
    var
        Item: Record Item;
        Customer: Record Customer;
        Vendor: Record Vendor;
        IsHandled: Boolean;
    begin
        IsHandled := false;

        OnBeforeApplyBlockedState(RecRef, IsBlocked, IsHandled);

        if IsHandled then
            exit;

        case RecRef.Number of
            Database::Item:
                begin
                    RecRef.SetTable(Item);

                    Item.Blocked := IsBlocked;
                    Item."Sales Blocked" := IsBlocked;
                    Item."Purchasing Blocked" := IsBlocked;

                    Item.Modify();
                end;

            Database::Customer:
                begin
                    RecRef.SetTable(Customer);

                    if IsBlocked then
                        Customer.Blocked := Customer.Blocked::All
                    else
                        Customer.Blocked := Customer.Blocked::" ";

                    Customer.Modify();
                end;

            Database::Vendor:
                begin
                    RecRef.SetTable(Vendor);

                    if IsBlocked then
                        Vendor.Blocked := Vendor.Blocked::All
                    else
                        Vendor.Blocked := Vendor.Blocked::" ";

                    Vendor.Modify();
                end;
        end;

        OnAfterApplyBlockedState(RecRef, IsBlocked)
    end;

    #endregion Item - Customer - Vendor Validations

    #region IntegrationEvents

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyBlockedState(var RecRef: RecordRef; IsBlocked: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyBlockedState(var RecRef: RecordRef; IsBlocked: Boolean)
    begin
    end;

    #endregion IntegrationEvents
}
