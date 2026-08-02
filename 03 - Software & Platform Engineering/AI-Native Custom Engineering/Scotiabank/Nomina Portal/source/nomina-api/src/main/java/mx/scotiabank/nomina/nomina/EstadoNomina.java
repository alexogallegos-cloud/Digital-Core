package mx.scotiabank.nomina.nomina;

import java.util.Set;

/**
 * Estado de la nomina / dispersion (schema {@code EstadoNomina} del OpenAPI ·
 * maquina de estados spec §6.2).
 *
 * <pre>
 * BORRADOR -> LAYOUT_CARGADO -> VALIDADA -> [EN_AUTORIZACION] -> AUTORIZADA -> DISPERSANDO
 *                  ^   |             |                                             |
 *                  |(errores)   (fondos insuf.)                          CONFIRMADA | RECHAZADA_PARCIAL
 *                  +---+
 * CANCELADA (hasta antes de AUTORIZADA)
 * </pre>
 *
 * La transicion a DISPERSANDO es irreversible (fondos comprometidos).
 */
public enum EstadoNomina {
    BORRADOR,
    LAYOUT_CARGADO,
    VALIDADA,
    EN_AUTORIZACION,
    AUTORIZADA,
    DISPERSANDO,
    CONFIRMADA,
    RECHAZADA_PARCIAL,
    CANCELADA;

    private static final Set<EstadoNomina> DISPERSABLES = Set.of(VALIDADA, AUTORIZADA);

    /** Estados desde los que se puede instruir la dispersion (tras 2FA). */
    public boolean permiteInstruirDispersion() {
        return DISPERSABLES.contains(this);
    }

    /** CANCELADA solo es alcanzable antes de AUTORIZADA. */
    public boolean permiteCancelar() {
        return this == BORRADOR || this == LAYOUT_CARGADO || this == VALIDADA || this == EN_AUTORIZACION;
    }
}
