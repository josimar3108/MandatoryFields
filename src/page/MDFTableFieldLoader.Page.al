page 60112 "MDF Table Field Loader"
{
    PageType = List;
    SourceTable = AllObjWithCaption;
    Caption = 'Select Table';
    ApplicationArea = All;
    SourceTableView = where("Object Type" = const(Table));

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                }

                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadFields)
            {
                Caption = 'Create Fields';
                Image = Import;

                trigger OnAction()
                var
                    MandatoryFieldMgt: Codeunit "MDF Utils";
                begin
                    MandatoryFieldMgt.InitializeTableFields(Rec."Object ID");
                    Message('Fields created for table %1', Rec."Object Caption");
                end;
            }
        }
    }
}
