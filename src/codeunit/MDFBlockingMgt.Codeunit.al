/// <summary>
/// Codeunit encargada de administrar el bloqueo automático
/// de entidades maestras.
/// </summary>
codeunit 60113 "MDF Blocking Mgt"
{
    Access = Public;

    /// <summary>
    /// Aplica bloqueo al registro especificado.
    /// </summary>
    /// <param name="VariantRec">Registro a bloquear.</param>
    procedure BlockRecord(VariantRec: Variant)
    begin
        ApplyBlockedState(VariantRec, true);
    end;

    /// <summary>
    /// Remueve el bloqueo del registro especificado.
    /// </summary>
    /// <param name="VariantRec">Registro a desbloquear.</param>
    procedure UnblockRecord(VariantRec: Variant)
    begin
        ApplyBlockedState(VariantRec, false);
    end;

    /// <summary>
    /// Aplica el estado de bloqueo correspondiente al registro.
    /// </summary>
    /// <param name="VariantRec">Registro a procesar.</param>
    /// <param name="IsBlocked">Indica si debe bloquearse.</param>
    local procedure ApplyBlockedState(
        VariantRec: Variant;
        IsBlocked: Boolean)
    var
        RecRef: RecordRef;
        Item: Record Item;
        Customer: Record Customer;
        Vendor: Record Vendor;
        IsHandled: Boolean;
    begin
        RecRef.GetTable(VariantRec);

        IsHandled := false;

        OnBeforeApplyBlockedState(RecRef, IsBlocked, IsHandled);

        if IsHandled then
            exit;

        case RecRef.Number of
            Database::Item:
                begin
                    RecRef.SetTable(Item);

                    Item.Blocked := IsBlocked;
                    Item."Sales Blocked" := IsBlocked;
                    Item."Purchasing Blocked" := IsBlocked;

                    Item.Modify();
                end;

            Database::Customer:
                begin
                    RecRef.SetTable(Customer);

                    if IsBlocked then
                        Customer.Blocked := Customer.Blocked::All
                    else
                        Customer.Blocked := Customer.Blocked::" ";

                    Customer.Modify();
                end;

            Database::Vendor:
                begin
                    RecRef.SetTable(Vendor);

                    if IsBlocked then
                        Vendor.Blocked := Vendor.Blocked::All
                    else
                        Vendor.Blocked := Vendor.Blocked::" ";

                    Vendor.Modify();
                end;
        end;

        OnAfterApplyBlockedState(RecRef, IsBlocked);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyBlockedState(
        var RecRef: RecordRef;
        IsBlocked: Boolean;
        var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyBlockedState(
        var RecRef: RecordRef;
        IsBlocked: Boolean)
    begin
    end;
}