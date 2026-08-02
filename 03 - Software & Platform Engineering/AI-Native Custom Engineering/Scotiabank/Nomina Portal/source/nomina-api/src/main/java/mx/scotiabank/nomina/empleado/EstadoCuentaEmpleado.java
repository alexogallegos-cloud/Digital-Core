package mx.scotiabank.nomina.empleado;

/**
 * Estado de la cuenta del empleado (schema {@code EstadoCuentaEmpleado} del
 * OpenAPI · maquina de estados spec §6.1).
 *
 * <pre>
 * NO_INICIADA -> EN_PROCESO -> DOCUMENTADA -> FINALIZADA -> VINCULADA
 *                    |              |
 *                    +--------------+--> BLOQUEADA
 *                                        ELIMINADA (baja logica)
 * </pre>
 *
 * Solo FINALIZADA y VINCULADA son dispersables (RN-07).
 */
public enum EstadoCuentaEmpleado {
    NO_INICIADA,
    EN_PROCESO,
    DOCUMENTADA,
    FINALIZADA,
    VINCULADA,
    BLOQUEADA,
    ELIMINADA;

    /** RN-07 · elegibilidad para recibir dispersion. */
    public boolean esDispersable() {
        return this == FINALIZADA || this == VINCULADA;
    }
}
