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
    }

    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."No." <> '') and (Rec.SystemCreatedAt <> 0DT) then
            CurrPage.MandatoryFields.Page.LoadData(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        CurrPage.MandatoryFields.Page.LoadData(Rec);
        CurrPage.DimMandatory.Page.LoadData(Rec);
    end;
}
