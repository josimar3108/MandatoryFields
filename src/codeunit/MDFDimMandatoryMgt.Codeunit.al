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
    procedure GetMissingDimensions(var TempBuffer: Record "MDF Dim Mandatory Buffer" temporary; VariantRec: Variant)
    var
        RecRef: RecordRef;
        DefaultDim: Record "Default Dimension";
        Setup: Record "MDF Tables Default Dimension";
        TableID: Integer;
        NoCode: Code[20];
    begin
        TempBuffer.DeleteAll();

        // Convertimos el Variant a RecordRef para obtener metadatos del registro
        RecRef.GetTable(VariantRec);
        TableID := RecRef.Number;
        NoCode := GetNoFromRecRef(RecRef);

        if NoCode = '' then
            exit;

        // Recorremos la configuración de dimensiones obligatorias definidas por el usuario
        if Setup.FindSet() then
            repeat
                // Verificamos si la dimensión actual de la configuración aplica a la tabla del registro
                if IsDimensionMandatoryForTable(Setup, TableID) then begin
                    // Si la dimensión es obligatoria pero no existe en las dimensiones por defecto, se añade al buffer
                    if not DimensionExists(DefaultDim, TableID, NoCode, Setup."Dimension Code") then begin
                        TempBuffer.Init();
                        TempBuffer."Dimension Code" := Setup."Dimension Code";
                        TempBuffer."Is Missing" := true;
                        TempBuffer.Insert();
                    end;
                end;
            until Setup.Next() = 0;
    end;

    /// <summary>
    /// Evalúa según la tabla de configuración si una dimensión debe considerarse obligatoria para una tabla específica.
    /// </summary>
    /// <param name="Setup">Registro de la tabla de configuración "MDF Tables Default Dimension".</param>
    /// <param name="TableID">ID de la tabla que se está validando.</param>
    /// <returns>Verdadero si la configuración marca la dimensión como obligatoria para el tipo de tabla.</returns>
    local procedure IsDimensionMandatoryForTable(Setup: Record "MDF Tables Default Dimension"; TableID: Integer): Boolean
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
    /// Comprueba si existe un registro en la tabla "Default Dimension" con un valor asignado para la combinación de tabla, número y dimensión.
    /// </summary>
    /// <param name="DefaultDim">Referencia al registro "Default Dimension".</param>
    /// <param name="TableID">ID de la tabla (p.ej., 18 para Clientes).</param>
    /// <param name="NoCode">Código del registro (No. del Cliente, Producto, etc.).</param>
    /// <param name="DimCode">Código de la dimensión a validar.</param>
    /// <returns>Boolean indicando si la dimensión existe y tiene un valor no nulo.</returns>
    procedure DimensionExists(var DefaultDim: Record "Default Dimension"; TableID: Integer; NoCode: Code[20]; DimCode: Code[20]): Boolean
    begin
        DefaultDim.Reset();
        DefaultDim.SetRange("Table ID", TableID);
        DefaultDim.SetRange("No.", NoCode);
        DefaultDim.SetRange("Dimension Code", DimCode);
        // Validamos que el código de valor de dimensión no esté vacío
        DefaultDim.SetFilter("Dimension Value Code", '<>%1', '');
        exit(not DefaultDim.IsEmpty());
    end;

    /// <summary>
    /// Extrae de forma dinámica el valor del campo "No." de un registro utilizando RecordRef.
    /// Se asume que el campo "No." es el Field No. 1.
    /// </summary>
    /// <param name="RecRef">RecordRef del registro a procesar.</param>
    /// <returns>El valor del campo "No." como Code[20].</returns>
    local procedure GetNoFromRecRef(RecRef: RecordRef): Code[20]
    var
        FieldRef: FieldRef;
    begin
        if RecRef.FieldExist(1) then begin
            FieldRef := RecRef.Field(1);
            exit(FieldRef.Value);
        end;

        exit('');
    end;

    /// <summary>
    /// Función simplificada para determinar rápidamente si un registro tiene dimensiones obligatorias faltantes.
    /// </summary>
    /// <param name="VariantRec">Registro a validar.</param>
    /// <returns>Verdadero si falta al menos una dimensión obligatoria.</returns>
    procedure HasMissingMandatoryDimensions(var VariantRec: Variant): Boolean
    var
        TempBuffer: Record "MDF Dim Mandatory Buffer" temporary;
    begin
        GetMissingDimensions(TempBuffer, VariantRec);
        exit(not TempBuffer.IsEmpty());
    end;
}