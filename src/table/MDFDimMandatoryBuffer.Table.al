table 60111 "MDF Dim Mandatory Buffer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Dimension Code"; Code[20]) { }
        field(2; "Is Missing"; Boolean) { }
    }

    keys
    {
        key(PK; "Dimension Code") { Clustered = true; }
    }
}
