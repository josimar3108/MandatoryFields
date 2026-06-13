tableextension 60102 "MDF Vendor" extends Vendor
{
    trigger OnAfterInsert()
    var
        MDFFeatureManagement: Codeunit "MDF Feature Management";
        MDFValidationMgt: Codeunit "MDF Validation Mgt";
    begin
        if (Rec."No." <> '') and (MDFFeatureManagement.IsBlockManaged(Database::Vendor)) then
            MDFValidationMgt.ValidateAndApplyBlocking(Rec);
    end;
}
