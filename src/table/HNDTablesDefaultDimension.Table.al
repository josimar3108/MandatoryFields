table 60100 "MDF Tables Default Dimension"
{
    Caption = 'MDF Tables Default Dimension';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension;
        }
        field(2; "Default Item"; Boolean)
        {
            Caption = 'Item';
        }
        field(3; "Default Customer"; Boolean)
        {
            Caption = 'Customer';
        }
        field(4; "Default Vendor"; Boolean)
        {
            Caption = 'Vendor';
        }
    }
    keys
    {
        key(PK; "Dimension Code")
        {
            Clustered = true;
        }
    }
}
