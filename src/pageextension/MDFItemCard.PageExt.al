pageextension 60146 "MDF Item Card" extends "Item Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(MandatoryFields; "MDF Mandatory FactBox")
            {
                ApplicationArea = All;
            }
            part(DimMandatory; "MDF Dim Mandatory FactBox")
            {
                ApplicationArea = All;
            }
        }

        modify(Blocked)
        {
            Editable = CanEditBlockedField;
        }
    }


    actions
    {
        addlast(Processing)
        {
            action(MDFUnlockItem)
            {
                ApplicationArea = All;
                Caption = 'Unlock by Data Quality';
                Image = Lock;
                Promoted = true;
                PromotedCategory = Process;

                Visible = IsBlockManaged;
                Enabled = Rec.Blocked;

                trigger OnAction()
                var
                    MDFUtils: Codeunit "MDF Utils";
                begin
                    if MDFUtils.IsBlockManaged(Database::Item) then
                        MDFUtils.ValidateAndApplyBlocking(Rec);

                    CurrPage.Update(false);
                end;
            }
        }
    }
    var
        IsBlockManaged: Boolean;
        CanEditBlockedField: Boolean;

    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."No." <> '') and (Rec.SystemCreatedAt <> 0DT) then
            CurrPage.MandatoryFields.Page.LoadData(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        MDFUtils: Codeunit "MDF Utils";
    begin
        IsBlockManaged := MDFUtils.IsBlockManaged(Database::Item);
        CanEditBlockedField := not IsBlockManaged;

        CurrPage.MandatoryFields.Page.LoadData(Rec);
        CurrPage.DimMandatory.Page.LoadData(Rec);
    end;
}
