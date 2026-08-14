package mx.scotiabank.nomina.spei;

import jakarta.validation.constraints.NotBlank;

/**
 * DTOs del contrato REST del SPEI Adapter.
 *
 * <p>{@link SpeiResultado} coincide 1:1 con el record que nomina-api deserializa
 * ({@code mx.scotiabank.nomina.integration.spei.dto.SpeiResultado}).
 */
public final class SpeiDtos {

    private SpeiDtos() {
    }

    /** Instruccion de pago SPEI para un renglon de dispersion. */
    public record PagoRequest(
            @NotBlank String clabeDestino,
            @NotBlank String importe,
            @NotBlank String referencia) {
    }

    /**
     * Resultado de instruir un pago SPEI.
     *
     * @param confirmado           true si SPEI acepto la instruccion
     * @param claveRastreo         clave de rastreo de 18 digitos (si confirmado)
     * @param codigoRechazoBanxico codigo de rechazo Banxico (si NO confirmado)
     * @param mensaje              detalle legible del resultado
     */
    public record SpeiResultado(
            boolean confirmado,
            String claveRastreo,
            String codigoRechazoBanxico,
            String mensaje) {
    }
}
