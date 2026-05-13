page 60113 "MDF Setup"
{
    PageType = Card;
    SourceTable = "MDF Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Mandatory Fields"; Rec."Enable Mandatory Fields") { }
                field("Enable FactBoxes"; Rec."Enable FactBoxes") { }
                field("Block On Validation"; Rec."Block On Validation") { }
                field("Enable Dimensions Control"; Rec."Enable Dimensions Control") { }
            }
        }
    }


    trigger OnOpenPage()
    begin
        if not Rec.Get('SETUP') then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec.Insert();
        end;
    end;
}
