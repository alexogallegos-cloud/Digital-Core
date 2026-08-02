package mx.scotiabank.nomina.spei;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * SPEI Adapter (SPE-ANCE-006) · Anti-Corruption Layer hacia SPEI/Banxico.
 *
 * <p>En el mock expone un stub determinista que confirma o rechaza instrucciones
 * de pago segun reglas fijas. En produccion se reemplaza por el gateway SPEI real
 * (directo Banxico o intermediario interno Scotiabank · ADR-ANCE-005), preservando
 * el contrato REST que consume nomina-api.
 */
@SpringBootApplication
public class SpeiAdapterApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpeiAdapterApplication.class, args);
    }
}
