/// <summary>
/// Codeunit diseñada para gestionar y validar la obligatoriedad de dimensiones en entidades maestras 
/// (Productos, Clientes y Proveedores) basándose en una configuración personalizada.
/// </summary>
codeunit 60115 "MDF Dim Mandatory Mgt"
{
    Access = Public;

    /// <summary>
    /// Identifica qué dimensiones obligatorias faltan para un registro específico y las inserta en un buffer temporal.
    /// </summary>
    /// <param name="TempBuffer">Registro temporal de tipo "MDF Dim Mandatory Buffer" que se poblará con las dimensiones faltantes.</param>
    /// <param name="VariantRec">El registro a evaluar (p.ej., Record Item, Customer o Vendor).</param>
    procedure GetMissingDimensions(
        var TempBuffer: Record "MDF Dim Mandatory Buffer" temporary;
        VariantRec: Variant)
    var
        RecRef: RecordRef;
        DefaultDim: Record "Default Dimension";
        Setup: Record "MDF Tables Default Dimension";
        RecordHelper: Codeunit "MDF Record Helper";
        TableID: Integer;
        NoCode: Code[20];
    begin
        TempBuffer.DeleteAll();

        RecRef.GetTable(VariantRec);

        TableID := RecRef.Number;
        NoCode := RecordHelper.GetNoFromRecRef(RecRef);

        if NoCode = '' then
            exit;

        if Setup.FindSet() then
            repeat
                if IsDimensionMandatoryForTable(Setup, TableID) then begin

                    if not DimensionExists(
                        DefaultDim,
                        TableID,
                        NoCode,
                        Setup."Dimension Code")
                    then begin

                        TempBuffer.Init();
                        TempBuffer."Dimension Code" := Setup."Dimension Code";
                        TempBuffer."Is Missing" := true;
                        TempBuffer.Insert();
                    end;
                end;
            until Setup.Next() = 0;
    end;

    /// <summary>
    /// Determina si una dimensión aplica para una tabla específica.
    /// </summary>
    /// <param name="Setup">Configuración de dimensión.</param>
    /// <param name="TableID">ID de la tabla.</param>
    /// <returns>Verdadero si la dimensión es obligatoria.</returns>
    local procedure IsDimensionMandatoryForTable(
        Setup: Record "MDF Tables Default Dimension";
        TableID: Integer): Boolean
    begin
        case TableID of
            Database::Item:
                exit(Setup."Default Item");

            Database::Customer:
                exit(Setup."Default Customer");

            Database::Vendor:
                exit(Setup."Default Vendor");
        end;

        exit(false);
    end;

    /// <summary>
    /// Determina si una dimensión existe y contiene un valor asignado.
    /// </summary>
    /// <param name="DefaultDim">Registro de dimensiones.</param>
    /// <param name="TableID">ID de tabla.</param>
    /// <param name="NoCode">Código del registro.</param>
    /// <param name="DimCode">Código de dimensión.</param>
    /// <returns>Verdadero si la dimensión existe.</returns>
    local procedure DimensionExists(
        var DefaultDim: Record "Default Dimension";
        TableID: Integer;
        NoCode: Code[20];
        DimCode: Code[20]): Boolean
    begin
        DefaultDim.Reset();
        DefaultDim.SetRange("Table ID", TableID);
        DefaultDim.SetRange("No.", NoCode);
        DefaultDim.SetRange("Dimension Code", DimCode);
        DefaultDim.SetFilter("Dimension Value Code", '<>%1', '');

        exit(not DefaultDim.IsEmpty());
    end;

    /// <summary>
    /// Determina si existen dimensiones obligatorias faltantes.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <returns>Verdadero si existen dimensiones faltantes.</returns>
    procedure HasMissingMandatoryDimensions(var VariantRec: Variant): Boolean
    var
        MissingDimensions: Text;
    begin
        exit(HasMissingMandatoryDimensions(VariantRec, MissingDimensions));
    end;

    /// <summary>
    /// Obtiene el listado de dimensiones obligatorias faltantes.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <param name="MissingDimensions">Listado de dimensiones faltantes.</param>
    /// <returns>Verdadero si existen dimensiones faltantes.</returns>
    procedure HasMissingMandatoryDimensions(
        var VariantRec: Variant;
        var MissingDimensions: Text): Boolean
    var
        TempBuffer: Record "MDF Dim Mandatory Buffer" temporary;
    begin
        Clear(MissingDimensions);

        GetMissingDimensions(TempBuffer, VariantRec);

        if TempBuffer.IsEmpty() then
            exit(false);

        TempBuffer.Reset();

        if TempBuffer.FindSet() then
            repeat
                if MissingDimensions <> '' then
                    MissingDimensions += ', ';

                MissingDimensions += TempBuffer."Dimension Code";
            until TempBuffer.Next() = 0;

        exit(true);
    end;
}