table 60109 "MDF Mandatory Fields Setup"
{
    Caption = 'MDF Mandatory Fields Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }

        field(2; "Enable Customer Validation"; Boolean)
        {
            Caption = 'Enable Customer Validation';
        }

        field(3; "Enable Vendor Validation"; Boolean)
        {
            Caption = 'Enable Vendor Validation';
        }

        field(4; "Enable Item Validation"; Boolean)
        {
            Caption = 'Enable Item Validation';
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
