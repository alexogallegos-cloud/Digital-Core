package mx.scotiabank.nomina.corebanking;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

/**
 * DTOs del contrato REST del Core Banking Adapter.
 *
 * <p>Las respuestas coinciden 1:1 con los records que nomina-api deserializa
 * ({@code CuentaNomina}, {@code Saldo}, {@code CargoResultado}) para garantizar
 * coherencia del contrato entre modulos.
 */
public final class CoreBankingDtos {

    private CoreBankingDtos() {
    }

    // --- Requests -----------------------------------------------------------

    /** Solicitud de apertura de cuenta nomina para un empleado. */
    public record AbrirCuentaRequest(
            @NotBlank String idEmpresa,
            @NotBlank String idEmpleado,
            @NotBlank String rfc) {
    }

    /** Instruccion de cargo a la cuenta origen para fondear una dispersion. */
    public record CargoRequest(
            @NotBlank String clabeOrigen,
            @NotBlank String monto,
            @NotBlank String referencia) {
    }

    // --- Responses (espejo de los records de nomina-api) --------------------

    /** Resultado de abrir cuenta. numeroCuenta/clabe son PCI. */
    public record CuentaNomina(String numeroCuenta, String clabe) {
    }

    /** Saldo disponible de la cuenta origen (RN-05). */
    public record Saldo(BigDecimal disponible) {
    }

    /** Resultado del cargo a la cuenta origen. */
    public record CargoResultado(boolean aplicado, String referencia) {
    }
}
