package mx.scotiabank.nomina.common;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Conversion entre el dinero interno ({@link BigDecimal}, DECIMAL(18,2) en SQL
 * Server) y su representacion en la API ("Money" del OpenAPI: string-decimal con
 * exactamente 2 decimales, patron {@code ^\d+\.\d{2}$}).
 *
 * <p>El dinero NUNCA se representa como float/double — en banca es incidente P1.
 */
public final class MoneyMapper {

    private MoneyMapper() {
    }

    /** BigDecimal interno -> string de la API (2 decimales). */
    public static String toApi(BigDecimal value) {
        if (value == null) {
            return null;
        }
        return value.setScale(2, RoundingMode.HALF_EVEN).toPlainString();
    }

    /** string de la API -> BigDecimal interno. Lanza si el formato no cumple el contrato. */
    public static BigDecimal parse(String money) {
        if (money == null || !money.matches("^\\d+\\.\\d{2}$")) {
            throw new IllegalArgumentException("Money invalido; formato esperado ^\\d+\\.\\d{2}$");
        }
        return new BigDecimal(money);
    }
}
