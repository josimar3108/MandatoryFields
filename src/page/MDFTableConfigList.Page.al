page 60101 "MDF Table Config List"
{
    PageType = List;
    SourceTable = "MDF Table Config";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No."; Rec."Table No.") { Editable = false; }
                field("Table Name"; Rec."Table Name") { Editable = false; }
                field("Block On Validation"; Rec."Block On Validation") { }
                /* field("Enable Mandatory Fields"; Rec."Enable Mandatory Fields") { }
                field("Enable FactBox"; Rec."Enable FactBox") { }
                field("Block On Validation"; Rec."Block On Validation") { }
                field("Enable Dimensions"; Rec."Enable Dimensions") { } */
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SeeMandatoryFields)
            {
                Caption = 'Mandatory Fields';
                Image = ShowList;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = false;
                trigger OnAction()
                var
                    MandatoryFields: Record "MDF Mandatory Fields";
                begin
                    MandatoryFields.SetRange("Table No.", Rec."Table No.");
                    Page.Run(Page::"MDF Mandatory Fields List", MandatoryFields);
                end;
            }
            action(LoadTableFields)
            {
                Caption = 'Load Fields From Table';
                Image = Import;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = false;
                trigger OnAction()
                begin
                    Page.Run(Page::"MDF Table Field Loader");
                end;
            }
            action(ResetAndLoadFields)
            {
                Caption = 'Reset & Reload Fields';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = false;
                trigger OnAction()
                var
                    MandatorySetup: Record "MDF Mandatory Fields";
                    MDFMandatoryFieldMgt: Codeunit "MDF Mandatory Field Mgt";
                begin
                    if not Confirm('Esto eliminará la configuración existente. ¿Continuar?', false) then
                        exit;

                    MandatorySetup.SetRange("Table No.", Rec."Table No.");
                    MandatorySetup.DeleteAll();

                    MDFMandatoryFieldMgt.InitializeTableFields(Rec."Table No.");

                    Message('Campos reiniciados.');
                end;
            }
        }
    }
}
