/// <summary>
/// Codeunit auxiliar para operaciones dinámicas con RecordRef y FieldRef.
/// </summary>
codeunit 60112 "MDF Record Helper"
{
    Access = Public;

    /// <summary>
    /// Obtiene el valor del campo "No." utilizando RecordRef.
    /// </summary>
    /// <param name="RecRef">Registro a procesar.</param>
    /// <returns>Valor del campo "No.".</returns>
    procedure GetNoFromRecRef(RecRef: RecordRef): Code[20]
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
    /// Determina si un FieldRef contiene un valor vacío.
    /// </summary>
    /// <param name="FieldRef">Campo a validar.</param>
    /// <returns>Verdadero si el campo está vacío.</returns>
    procedure IsFieldEmpty(FieldRef: FieldRef): Boolean
    var
        IntVal: Integer;
        DecVal: Decimal;
        DateVal: Date;
        BigIntegerVal: BigInteger;
        TxtVal: Text;
    begin
        case FieldRef.Type of
            FieldType::Code,
            FieldType::Text:
                begin
                    TxtVal := Format(FieldRef.Value);
                    exit(TxtVal = '');
                end;

            FieldType::Integer:
                begin
                    IntVal := FieldRef.Value;
                    exit(IntVal = 0);
                end;

            FieldType::BigInteger:
                begin
                    BigIntegerVal := FieldRef.Value;
                    exit(BigIntegerVal = 0);
                end;

            FieldType::Decimal:
                begin
                    DecVal := FieldRef.Value;
                    exit(DecVal = 0);
                end;

            FieldType::Date:
                begin
                    DateVal := FieldRef.Value;
                    exit(DateVal = 0D);
                end;

            FieldType::Boolean:
                exit(false);

            else
                exit(Format(FieldRef.Value) = '');
        end;
    end;
}