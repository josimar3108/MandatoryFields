/// <summary>
/// Codeunit principal del framework encargada de orquestar todas las validaciones
/// relacionadas con calidad de datos y gobierno de información.
/// </summary>
codeunit 60110 "MDF Validation Mgt"
{
    Access = Public;

    /// <summary>
    /// Ejecuta todas las validaciones configuradas para un registro.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <returns>Verdadero si el registro contiene errores de validación.</returns>
    procedure ValidateRecord(VariantRec: Variant): Boolean
    var
        MissingFields: Text;
        MissingDimensions: Text;
    begin
        exit(GetValidationSummary(
            VariantRec,
            MissingFields,
            MissingDimensions));
    end;

    /// <summary>
    /// Obtiene el resumen completo de validaciones faltantes para un registro.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <param name="MissingFields">Lista de campos obligatorios faltantes.</param>
    /// <param name="MissingDimensions">Lista de dimensiones obligatorias faltantes.</param>
    /// <returns>Verdadero si existen errores de validación.</returns>
    procedure GetValidationSummary(
        VariantRec: Variant;
        var MissingFields: Text;
        var MissingDimensions: Text): Boolean
    var
        MandatoryFieldMgt: Codeunit "MDF Mandatory Field Mgt";
        DimMandatoryMgt: Codeunit "MDF Dim Mandatory Mgt";
        HasIssues: Boolean;
    begin
        Clear(MissingFields);
        Clear(MissingDimensions);

        HasIssues := false;

        if MandatoryFieldMgt.ValidateMandatoryFields(VariantRec, MissingFields) then
            HasIssues := true;

        if DimMandatoryMgt.HasMissingMandatoryDimensions(VariantRec, MissingDimensions) then
            HasIssues := true;

        exit(HasIssues);
    end;

    /// <summary>
    /// Ejecuta validaciones y aplica bloqueo automáticamente dependiendo del resultado.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    procedure ValidateAndApplyBlocking(VariantRec: Variant)
    var
        BlockingMgt: Codeunit "MDF Blocking Mgt";
    begin
        if ValidateRecord(VariantRec) then
            BlockingMgt.BlockRecord(VariantRec)
        else
            BlockingMgt.UnblockRecord(VariantRec);
    end;

    /// <summary>
    /// Muestra un mensaje con el detalle de validaciones faltantes.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    procedure ShowValidationIssues(VariantRec: Variant)
    var
        MissingFields: Text;
        MissingDimensions: Text;
        MessageTxt: Text;
    begin
        if not GetValidationSummary(
            VariantRec,
            MissingFields,
            MissingDimensions)
        then
            exit;

        if MissingFields <> '' then
            MessageTxt +=
                StrSubstNo(
                    'Missing mandatory fields:\%1\',
                    MissingFields);

        if MissingDimensions <> '' then
            MessageTxt +=
                StrSubstNo(
                    'Missing mandatory dimensions:\%1',
                    MissingDimensions);

        Message(MessageTxt);
    end;
}