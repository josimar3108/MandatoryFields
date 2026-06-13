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
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = false;
                trigger OnAction()
                var
                    MDFMandatoryFieldMgt: Codeunit "MDF Mandatory Field Mgt";
                begin
                    EnsureTableConfig(Rec."Object ID");
                    MDFMandatoryFieldMgt.InitializeTableFields(Rec."Object ID");
                    Message('Fields created for table %1', Rec."Object Caption");
                end;
            }
        }
    }

    local procedure EnsureTableConfig(TableNo: Integer)
    var
        TableCfg: Record "MDF Table Config";
        AllObj: Record AllObjWithCaption;
    begin
        if not TableCfg.Get(TableNo) then begin
            TableCfg.Init();
            TableCfg."Table No." := TableNo;

            if AllObj.Get(AllObj."Object Type"::Table, TableNo) then
                TableCfg."Table Name" := AllObj."Object Caption";

            TableCfg.Insert();
        end;
    end;
}
