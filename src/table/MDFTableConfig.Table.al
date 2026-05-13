table 60105 "MDF Table Config"
{
    Caption = 'Mandatory Fields Table Config';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID"
                WHERE("Object Type" = CONST(Table));
        }

        field(2; "Table Name"; Text[100])
        {
            Caption = 'Table Name';
            Editable = false;
        }

        field(3; "Enable Mandatory Fields"; Boolean)
        {
            Caption = 'Enable Mandatory Fields';
        }

        field(4; "Enable FactBox"; Boolean)
        {
            Caption = 'Enable FactBox';
        }

        field(5; "Block On Validation"; Boolean)
        {
            Caption = 'Block On Validation';
        }

        field(6; "Enable Dimensions"; Boolean)
        {
            Caption = 'Enable Dimensions';
        }
    }

    keys
    {
        key(PK; "Table No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        MandatorySetup: Record "MDF Mandatory Fields";
    begin

        MandatorySetup.SetRange("Table No.", Rec."Table No.");
        MandatorySetup.DeleteAll();
    end;
}
