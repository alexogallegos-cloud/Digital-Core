package mx.scotiabank.nomina.integration.corebanking.dto;

import java.math.BigDecimal;

/** Saldo disponible de la cuenta origen (RN-05 · validacion de fondos). */
public record Saldo(BigDecimal disponible) {
}
