table 60108 "MDF Mandatory Fields"
{
    Caption = 'Mandatory Fields';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }

        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
        }

        field(3; "Field Name"; Text[100])
        {
            Caption = 'Field Name';
        }

        field(4; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }
}
