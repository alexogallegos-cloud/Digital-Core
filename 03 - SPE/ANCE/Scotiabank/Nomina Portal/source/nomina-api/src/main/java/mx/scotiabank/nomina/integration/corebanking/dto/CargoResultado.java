package mx.scotiabank.nomina.integration.corebanking.dto;

/** Resultado de instruir el cargo a la cuenta origen para fondear la dispersion. */
public record CargoResultado(boolean aplicado, String referencia) {
}
