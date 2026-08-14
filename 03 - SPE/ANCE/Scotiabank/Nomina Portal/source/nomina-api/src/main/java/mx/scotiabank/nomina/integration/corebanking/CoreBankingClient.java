package mx.scotiabank.nomina.integration.corebanking;

import java.math.BigDecimal;
import mx.scotiabank.nomina.integration.corebanking.dto.CargoResultado;
import mx.scotiabank.nomina.integration.corebanking.dto.CuentaNomina;
import mx.scotiabank.nomina.integration.corebanking.dto.Saldo;

/**
 * Puerto (Anti-Corruption Layer) hacia el core bancario · SPE-ANCE-003.
 *
 * <p>Aisla el dominio del portal del modelo del core. En el mock lo implementa
 * {@link CoreBankingRestClient} apuntando al Core Banking Adapter stub. El
 * protocolo real (REST/MQ/adapter directo) queda para ADR-ANCE-001.
 */
public interface CoreBankingClient {

    /** Solicita apertura de cuenta nomina; devuelve CLABE/cuenta asignadas. */
    CuentaNomina abrirCuentaNomina(String idEmpresa, String idEmpleado, String rfc);

    /** RN-05 · valida fondos antes de dispersar. */
    Saldo consultarSaldo(String clabeOrigen);

    /** Debita la cuenta origen para fondear la dispersion (idempotente por referencia). */
    CargoResultado instruirCargo(String clabeOrigen, BigDecimal monto, String referencia);
}
