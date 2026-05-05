pageextension 60147 "MDF Customer Card" extends "Customer Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(MandatoryFields; "MDF Mandatory FactBox")
            {
                ApplicationArea = All;
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."No." <> '') and (Rec.SystemCreatedAt <> 0DT) then
            CurrPage.MandatoryFields.Page.LoadData(Rec);
    end;

    /* trigger OnAfterGetCurrRecord()
    begin
        CurrPage.MandatoryFields.Page.LoadData(Rec);
    end; */

    trigger OnAfterGetRecord()
    begin
        CurrPage.MandatoryFields.Page.LoadData(Rec);
    end;
}
