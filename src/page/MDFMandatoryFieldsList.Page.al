page 60108 "MDF Mandatory Fields List"
{
    ApplicationArea = All;
    Caption = 'Mandatory Fields List';
    PageType = List;
    SourceTable = "MDF Mandatory Fields";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the value of the Table No. field.', Comment = '%';
                    Editable = False;
                }
                field("Field No."; Rec."Field No.")
                {
                    ToolTip = 'Specifies the value of the Field No. field.', Comment = '%';
                    Editable = False;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ToolTip = 'Specifies the value of the Field Name field.', Comment = '%';
                    Editable = False;
                }
                field(Mandatory; Rec.Mandatory)
                {
                    ToolTip = 'Specifies the value of the Mandatory field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(LoadCustomerFields)
            {
                Caption = 'Load Customer Fields';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MDFUtils: Codeunit "MDF Utils";
                    RecVariant: Variant;
                begin
                    MDFUtils.InitializeCustomerFields();
                    Message('Customer fields have been loaded successfully.');
                    CurrPage.Update();
                    RecVariant := Rec;
                    MDFUtils.ValidateMandatoryFields(RecVariant);
                end;
            }
        }
    }
}
