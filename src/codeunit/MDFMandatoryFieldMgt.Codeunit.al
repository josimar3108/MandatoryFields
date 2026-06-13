/// <summary>
/// Codeunit encargada de gestionar las validaciones dinámicas
/// de campos obligatorios.
/// </summary>
codeunit 60111 "MDF Mandatory Field Mgt"
{
    Access = Public;

    /// <summary>
    /// Inicializa automáticamente los campos configurables de una tabla.
    /// </summary>
    /// <param name="TableNo">ID de la tabla.</param>
    procedure InitializeTableFields(TableNo: Integer)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MandatorySetup: Record "MDF Mandatory Fields";
        i: Integer;
    begin
        RecRef.Open(TableNo);

        for i := 1 to RecRef.FieldCount do begin
            FieldRef := RecRef.FieldIndex(i);

            if FieldRef.Class = FieldClass::FlowField then
                continue;

            if not MandatorySetup.Get(TableNo, FieldRef.Number) then begin
                MandatorySetup.Init();
                MandatorySetup."Table No." := TableNo;
                MandatorySetup."Field No." := FieldRef.Number;
                MandatorySetup."Field Name" := FieldRef.Name;
                MandatorySetup.Mandatory := false;
                MandatorySetup.Insert();
            end;
        end;

        RecRef.Close();
    end;

    /// <summary>
    /// Determina si existen campos obligatorios faltantes.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <returns>Verdadero si existen campos faltantes.</returns>
    procedure ValidateMandatoryFields(var VariantRec: Variant): Boolean
    var
        MissingFields: Text;
    begin
        exit(ValidateMandatoryFields(VariantRec, MissingFields));
    end;

    /// <summary>
    /// Obtiene el listado de campos obligatorios faltantes.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <param name="MissingFields">Listado de campos faltantes.</param>
    /// <returns>Verdadero si existen campos faltantes.</returns>
    procedure ValidateMandatoryFields(var VariantRec: Variant; var MissingFields: Text): Boolean
    var
        MandatorySetup: Record "MDF Mandatory Fields";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RecordHelper: Codeunit "MDF Record Helper";
    begin
        Clear(MissingFields);

        RecRef.GetTable(VariantRec);

        MandatorySetup.SetRange("Table No.", RecRef.Number);
        MandatorySetup.SetRange(Mandatory, true);

        if MandatorySetup.FindSet() then
            repeat
                if RecRef.FieldExist(MandatorySetup."Field No.") then begin

                    FieldRef := RecRef.Field(MandatorySetup."Field No.");

                    if RecordHelper.IsFieldEmpty(FieldRef) then begin
                        if MissingFields <> '' then
                            MissingFields += ', ';

                        MissingFields += MandatorySetup."Field Name";
                    end;
                end;
            until MandatorySetup.Next() = 0;

        exit(MissingFields <> '');
    end;

    /// <summary>
    /// Obtiene los campos obligatorios faltantes y los inserta en un buffer temporal.
    /// </summary>
    /// <param name="TempBuffer">Buffer temporal de campos faltantes.</param>
    /// <param name="VariantRec">Registro a validar.</param>
    procedure GetMissingFields(
        var TempBuffer: Record "MDF Mandatory Fields Buffer" temporary;
        VariantRec: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MDFSetup: Record "MDF Mandatory Fields";
        RecordHelper: Codeunit "MDF Record Helper";
    begin
        TempBuffer.DeleteAll();

        RecRef.GetTable(VariantRec);

        MDFSetup.SetRange("Table No.", RecRef.Number);
        MDFSetup.SetRange(Mandatory, true);

        if MDFSetup.FindSet() then
            repeat
                if RecRef.FieldExist(MDFSetup."Field No.") then begin

                    FieldRef := RecRef.Field(MDFSetup."Field No.");

                    if RecordHelper.IsFieldEmpty(FieldRef) then begin
                        TempBuffer.Init();
                        TempBuffer."Field No." := MDFSetup."Field No.";
                        TempBuffer."Field Name" := FieldRef.Caption;
                        TempBuffer."Is Missing" := true;
                        TempBuffer.Insert();
                    end;
                end;
            until MDFSetup.Next() = 0;
    end;
}