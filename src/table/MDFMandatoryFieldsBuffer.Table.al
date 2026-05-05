table 60110 "MDF Mandatory Fields Buffer"
{
    DataClassification = ToBeClassified;
    Caption = 'Mandatory Fields Buffer';

    fields
    {
        field(1; "Field No."; Integer) { }
        field(2; "Field Name"; Text[100]) { }
        field(3; "Is Missing"; Boolean) { }
    }

    keys
    {
        key(PK; "Field No.") { Clustered = true; }
    }
}
