package mx.scotiabank.nomina.integration.corebanking.dto;

/** Resultado de abrir una cuenta nomina en el core. CLABE/cuenta son PCI. */
public record CuentaNomina(String numeroCuenta, String clabe) {
}
