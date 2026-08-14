package mx.scotiabank.nomina.corebanking;

import java.math.BigDecimal;
import java.util.concurrent.ThreadLocalRandom;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.CargoResultado;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.CuentaNomina;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.Saldo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * STUB determinista de las capacidades del core bancario para el mock.
 *
 * <p>REEMPLAZAR por la integracion real con el core bancario Scotiabank Mexico
 * en produccion (ADR-ANCE-001 · DATO-REQUERIDO). El contrato REST expuesto por
 * {@link CoreBankingController} se mantiene estable en esa migracion.
 */
@Service
public class CoreBankingStub {

    private final BigDecimal saldoDisponible;
    private final String clabePrefijo;

    public CoreBankingStub(
            @Value("${corebanking.stub.saldo-disponible}") BigDecimal saldoDisponible,
            @Value("${corebanking.stub.clabe-prefijo}") String clabePrefijo) {
        this.saldoDisponible = saldoDisponible;
        this.clabePrefijo = clabePrefijo;
    }

    /** Genera una CLABE sintetica de 18 digitos y un numero de cuenta ficticio. */
    public CuentaNomina abrirCuentaNomina(String idEmpresa, String idEmpleado, String rfc) {
        long secuencia = Math.abs((long) (idEmpleado + rfc).hashCode()) % 100_000_000L;
        String cuenta = String.format("%011d", secuencia);
        String base = (clabePrefijo + cuenta);
        String clabe = ajustarLongitud(base, 18);
        return new CuentaNomina(cuenta, clabe);
    }

    /** Saldo fijo alto: en el mock nunca faltan fondos salvo que se configure lo contrario. */
    public Saldo consultarSaldo(String clabeOrigen) {
        return new Saldo(saldoDisponible);
    }

    /** Cargo siempre aplicado en el mock; referencia de core sintetica. */
    public CargoResultado instruirCargo(String clabeOrigen, BigDecimal monto, String referencia) {
        String refCore = "CB" + ThreadLocalRandom.current().nextLong(1_000_000_000L, 9_999_999_999L);
        return new CargoResultado(true, refCore);
    }

    private static String ajustarLongitud(String valor, int longitud) {
        if (valor.length() >= longitud) {
            return valor.substring(0, longitud);
        }
        return valor + "0".repeat(longitud - valor.length());
    }
}
