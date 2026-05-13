table 60104 "MDF Setup"
{
    Caption = 'Mandatory Fields Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }

        field(2; "Enable Mandatory Fields"; Boolean)
        {
            Caption = 'Enable Mandatory Fields';
        }

        field(3; "Enable FactBoxes"; Boolean)
        {
            Caption = 'Enable FactBoxes';
        }

        field(4; "Block On Validation"; Boolean)
        {
            Caption = 'Block On Validation';
        }

        field(5; "Enable Dimensions Control"; Boolean)
        {
            Caption = 'Enable Dimensions Control';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
