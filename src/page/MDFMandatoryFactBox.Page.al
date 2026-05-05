page 60116 "MDF Mandatory FactBox"
{
    PageType = ListPart;
    SourceTable = "MDF Mandatory Fields Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Header)
            {
                field(MissingCountTxt; MissingCountTxt)
                {
                    Caption = 'Campos restantes';
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                }
            }

            repeater(Fields)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        MDFMgt: Codeunit "MDF Utils";
        MissingCountTxt: Text[100];
        StyleTxt: Text[30];

    procedure LoadData(VariantRec: Variant)
    begin
        MDFMgt.GetMissingFields(Rec, VariantRec);

        if Rec.Count = 0 then begin
            MissingCountTxt := '✓ Completo';
            StyleTxt := 'Favorable'; // Verde
        end else begin
            MissingCountTxt := '⚠ ' + Format(Rec.Count) + ' campo(s) faltante(s)';
            StyleTxt := 'Attention';
        end;

        CurrPage.Update(false);
    end;

}
