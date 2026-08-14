package mx.scotiabank.nomina.common;

/**
 * Enmascarado de datos PCI/PII para respuestas y logs.
 *
 * <p><b>REGLA DE ORO (dt-security-engineer · PCI-DSS · LFPDPPP):</b> CLABE, RFC,
 * CURP y numero de tarjeta NUNCA se escriben completos en logs. Toda traza que
 * necesite referir a estos campos usa exclusivamente estos helpers. El valor
 * completo solo viaja en la capa de persistencia cifrada y en la respuesta al
 * rol autorizado.
 */
public final class MaskingUtil {

    private MaskingUtil() {
    }

    /** CLABE (18) -> enmascara todo menos los ultimos 6 (PCI · UI + logs). */
    public static String maskClabe(String clabe) {
        return maskKeepingLast(clabe, 6);
    }

    /** Numero de tarjeta -> enmascara todo menos los ultimos 4 (PCI). */
    public static String maskTarjeta(String tarjeta) {
        return maskKeepingLast(tarjeta, 4);
    }

    /** RFC -> enmascara el bloque central (PII). Ej: LOGM****ABC. */
    public static String maskRfc(String rfc) {
        if (rfc == null || rfc.length() < 7) {
            return "****";
        }
        int keepEnd = 3;
        int keepStart = 4;
        return rfc.substring(0, keepStart)
                + "*".repeat(rfc.length() - keepStart - keepEnd)
                + rfc.substring(rfc.length() - keepEnd);
    }

    /** CURP -> enmascara el bloque central (PII). */
    public static String maskCurp(String curp) {
        return maskKeepingLast(curp, 4);
    }

    private static String maskKeepingLast(String value, int visible) {
        if (value == null) {
            return null;
        }
        if (value.length() <= visible) {
            return "*".repeat(value.length());
        }
        return "*".repeat(value.length() - visible) + value.substring(value.length() - visible);
    }
}
