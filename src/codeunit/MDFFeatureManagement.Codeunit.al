/// <summary>
/// Codeunit encargada de centralizar la administración
/// de configuraciones y features del framework.
/// </summary>
codeunit 60114 "MDF Feature Management"
{
    Access = Public;

    /// <summary>
    /// Determina si las validaciones de campos obligatorios
    /// están habilitadas para una tabla.
    /// </summary>
    /// <param name="TableID">ID de la tabla.</param>
    /// <returns>Verdadero si la funcionalidad está habilitada.</returns>
    procedure IsMandatoryFieldValidationEnabled(TableID: Integer): Boolean
    var
        Setup: Record "MDF Setup";
        TableCfg: Record "MDF Table Config";
    begin
        if not Setup.Get('SETUP') then
            exit(false);

        if not Setup."Enable Mandatory Fields" then
            exit(false);

        if not TableCfg.Get(TableID) then
            exit(false);

        exit(TableCfg."Enable Mandatory Fields");
    end;

    /// <summary>
    /// Determina si el bloqueo automático está habilitado para una tabla.
    /// </summary>
    /// <param name="TableID">ID de la tabla.</param>
    /// <returns>Verdadero si el bloqueo está habilitado.</returns>
    procedure IsBlockManaged(TableID: Integer): Boolean
    var
        MDFTableConfig: Record "MDF Table Config";
    begin
        if not MDFTableConfig.Get(TableID) then
            exit(false);

        exit(MDFTableConfig."Block On Validation");
    end;
}