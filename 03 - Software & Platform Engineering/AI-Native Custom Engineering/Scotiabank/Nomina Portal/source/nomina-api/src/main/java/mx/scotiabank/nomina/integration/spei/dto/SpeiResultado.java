package mx.scotiabank.nomina.integration.spei.dto;

/**
 * Resultado de instruir un pago SPEI para un renglon de dispersion.
 *
 * @param confirmado          true si SPEI acepto la instruccion
 * @param claveRastreo        clave de rastreo de 18 digitos (si confirmado)
 * @param codigoRechazoBanxico codigo de rechazo Banxico (si NO confirmado)
 * @param mensaje             detalle legible del resultado
 */
public record SpeiResultado(
        boolean confirmado,
        String claveRastreo,
        String codigoRechazoBanxico,
        String mensaje) {
}
