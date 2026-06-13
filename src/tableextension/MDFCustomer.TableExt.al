tableextension 60101 "MDF Customer" extends Customer
{
    trigger OnAfterInsert()
    var
        MDFFeatureManagement: Codeunit "MDF Feature Management";
        MDFValidationMgt: Codeunit "MDF Validation Mgt";
    begin
        if (Rec."No." <> '') and (MDFFeatureManagement.IsBlockManaged(Database::Customer)) then
            MDFValidationMgt.ValidateAndApplyBlocking(Rec);
    end;
}
