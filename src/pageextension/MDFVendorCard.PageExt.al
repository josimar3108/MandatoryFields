pageextension 60148 "MDF Vendor Card" extends "Vendor Card"
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
            action(MDFBlockVendor)
            {
                ApplicationArea = All;
                Caption = 'Block by Data Quality';
                Image = Lock;
                Promoted = true;
                PromotedCategory = Process;

                Visible = IsBlockManaged;
                Enabled = Rec.Blocked = Rec.Blocked::" ";

                trigger OnAction()
                var
                    MDFFeatureManagement: Codeunit "MDF Feature Management";
                begin
                    if MDFFeatureManagement.IsBlockManaged(Database::Vendor) then begin
                        Rec.Blocked := Rec.Blocked::All;
                        Rec.Modify();
                    end;

                    CurrPage.Update(false);
                end;
            }

            action(MDFUnlockVendor)
            {
                ApplicationArea = All;
                Caption = 'Unlock by Data Quality';
                Image = Lock;
                Promoted = true;
                PromotedCategory = Process;

                Visible = IsBlockManaged;
                Enabled = Rec.Blocked <> Rec.Blocked::" ";

                trigger OnAction()
                var
                    MDFFeatureManagement: Codeunit "MDF Feature Management";
                    MDFValidationMgt: Codeunit "MDF Validation Mgt";
                begin
                    if not MDFFeatureManagement.IsBlockManaged(Database::Vendor) then
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

    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."No." <> '') and (Rec.SystemCreatedAt <> 0DT) then
            CurrPage.MandatoryFields.Page.LoadData(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        MDFFeatureManagement: Codeunit "MDF Feature Management";
    begin
        IsBlockManaged := MDFFeatureManagement.IsBlockManaged(Database::Vendor);
        CanEditBlockedField := not IsBlockManaged;

        CurrPage.MandatoryFields.Page.LoadData(Rec);
        CurrPage.DimMandatory.Page.LoadData(Rec);
    end;
}
