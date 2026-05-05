page 60113 "MDF Mandatory Fields Setup"
{
    PageType = Card;
    SourceTable = "MDF Mandatory Fields Setup";
    Caption = 'Mandatory Field Setup';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Enable Customer Validation"; Rec."Enable Customer Validation")
                {
                    ApplicationArea = All;
                }

                field("Enable Vendor Validation"; Rec."Enable Vendor Validation")
                {
                    ApplicationArea = All;
                }

                field("Enable Item Validation"; Rec."Enable Item Validation")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(LoadTableFields)
            {
                Caption = 'Load Fields From Table';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Page.Run(Page::"MDF Table Field Loader");
                end;
            }

            group(MandatoryFields)
            {
                Caption = 'Mandatory Fields';

                action(CustomerMandatoryFields)
                {
                    Caption = 'Customer Fields';
                    Image = Customer;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MandatoryFields: Record "MDF Mandatory Fields";
                    begin
                        MandatoryFields.SetRange("Table No.", Database::Customer);
                        Page.Run(Page::"MDF Mandatory Fields List", MandatoryFields);
                    end;
                }

                action(VendorMandatoryFields)
                {
                    Caption = 'Vendor Fields';
                    Image = Vendor;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MandatoryFields: Record "MDF Mandatory Fields";
                    begin
                        MandatoryFields.SetRange("Table No.", Database::Vendor);
                        Page.Run(Page::"MDF Mandatory Fields List", MandatoryFields);
                    end;
                }

                action(ItemMandatoryFields)
                {
                    Caption = 'Item Fields';
                    Image = Item;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        MandatoryFields: Record "MDF Mandatory Fields";
                    begin
                        MandatoryFields.SetRange("Table No.", Database::Item);
                        Page.Run(Page::"MDF Mandatory Fields List", MandatoryFields);
                    end;
                }
            }

        }
    }
}
