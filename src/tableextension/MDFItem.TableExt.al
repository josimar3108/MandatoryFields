tableextension 60100 "MDF Item" extends Item
{
    trigger OnAfterInsert()
    var
        MDFUtils: Codeunit "MDF Utils";
    begin
        if (Rec."No." <> '') and (MDFUtils.IsBlockManaged(Database::Item)) then
            MDFUtils.ValidateAndApplyBlocking(Rec);
    end;
}
