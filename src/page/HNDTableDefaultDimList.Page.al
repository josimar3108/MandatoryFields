page 60110 "MDF Table Default Dim. List"
{
    ApplicationArea = All;
    Caption = 'Mandatory Dimensiones';
    PageType = List;
    SourceTable = "MDF Tables Default Dimension";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ToolTip = 'Specifies the value of the Dimension Code field.', Comment = '%';
                }
                field("Default Customer"; Rec."Default Customer")
                {
                    ToolTip = 'Specifies the value of the Customer field.', Comment = '%';
                }
                field("Default Item"; Rec."Default Item")
                {
                    ToolTip = 'Specifies the value of the Item field.', Comment = '%';
                }
                field("Default Vendor"; Rec."Default Vendor")
                {
                    ToolTip = 'Specifies the value of the Vendor field.', Comment = '%';
                }
            }
        }
    }
}
