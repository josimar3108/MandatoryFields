codeunit 60101 "MDF Subscriber"
{
    /* [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemOnAfterInsert(var Rec: Record Item; RunTrigger: Boolean)
    var
        MDFFeatureManagement: Codeunit "MDF Feature Management";
        MDFValidationMgt: Codeunit "MDF Validation Mgt";
    begin
        if (Rec."No." <> '') and (MDFFeatureManagement.IsBlockManaged(Database::Item)) then begin
            MDFValidationMgt.ValidateAndApplyBlocking(Rec);
        end;
    end; */
}
