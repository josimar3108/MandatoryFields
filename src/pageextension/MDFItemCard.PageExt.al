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
            action(MDFBlockItem)
            {
                ApplicationArea = All;
                Caption = 'Block by Data Quality';
                Image = Lock;
                Promoted = true;
                PromotedCategory = Process;

                Visible = IsBlockManaged;
                Enabled = not Rec.Blocked;

                trigger OnAction()
                var
                    MDFFeatureManagement: Codeunit "MDF Feature Management";
                begin
                    if MDFFeatureManagement.IsBlockManaged(Database::Item) then begin
                        Rec.Blocked := true;
                        Rec.Modify();
                    end;

                    CurrPage.Update(false);
                end;
            }
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
                    MDFFeatureManagement: Codeunit "MDF Feature Management";
                    MDFValidationMgt: Codeunit "MDF Validation Mgt";
                begin
                    if not MDFFeatureManagement.IsBlockManaged(Database::Item) then
                        exit;

                    if MDFValidationMgt.ValidateRecord(Rec) then begin
                        MDFValidationMgt.ShowValidationIssues(Rec);
                        exit;
                    end;

                    MDFValidationMgt.ValidateAndApplyBlocking(Rec);

                    CurrPage.Update(false);
                end;
            }
        }
    }
    var
        IsBlockManaged: Boolean;
        CanEditBlockedField: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        MDFFeatureManagement: Codeunit "MDF Feature Management";
        MDFValidationMgt: Codeunit "MDF Validation Mgt";
    begin
        if (Rec."No." <> '') and (MDFFeatureManagement.IsBlockManaged(Database::Item)) then begin
            MDFValidationMgt.ValidateAndApplyBlocking(Rec);
            Commit();
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."No." <> '') and (Rec.SystemCreatedAt <> 0DT) then
            CurrPage.MandatoryFields.Page.LoadData(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        MDFFeatureManagement: Codeunit "MDF Feature Management";
    begin
        IsBlockManaged := MDFFeatureManagement.IsBlockManaged(Database::Item);
        CanEditBlockedField := not IsBlockManaged;

        CurrPage.MandatoryFields.Page.LoadData(Rec);
        CurrPage.DimMandatory.Page.LoadData(Rec);
    end;
}
