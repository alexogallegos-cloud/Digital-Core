package mx.scotiabank.nomina.corebanking;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Core Banking Adapter (SPE-ANCE-003) · Anti-Corruption Layer hacia el core bancario.
 *
 * <p>En el mock expone un stub determinista de las capacidades del core
 * (apertura de cuenta, consulta de saldo, cargo a cuenta origen). En produccion
 * este modulo se reemplaza por la integracion real con el core bancario de
 * Scotiabank Mexico (ADR-ANCE-001 · DATO-REQUERIDO), preservando el contrato REST
 * que consume nomina-api para no impactar el dominio del portal.
 */
@SpringBootApplication
public class CoreBankingAdapterApplication {

    public static void main(String[] args) {
        SpringApplication.run(CoreBankingAdapterApplication.class, args);
    }
}
