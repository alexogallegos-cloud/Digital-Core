package mx.scotiabank.nomina.integration.corebanking;

import java.math.BigDecimal;
import java.util.Map;
import mx.scotiabank.nomina.integration.corebanking.dto.CargoResultado;
import mx.scotiabank.nomina.integration.corebanking.dto.CuentaNomina;
import mx.scotiabank.nomina.integration.corebanking.dto.Saldo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Implementacion REST del puerto hacia el Core Banking Adapter (SPE-ANCE-003).
 *
 * <p>Corre sobre Virtual Threads: las llamadas HTTP bloqueantes no consumen
 * hilos de plataforma. NUNCA loguea CLABE ni montos en claro.
 */
@Component
public class CoreBankingRestClient implements CoreBankingClient {

    private final RestClient rest;

    public CoreBankingRestClient(RestClient.Builder builder,
                                 @Value("${integration.core-banking.base-url}") String baseUrl) {
        this.rest = builder.baseUrl(baseUrl).build();
    }

    @Override
    public CuentaNomina abrirCuentaNomina(String idEmpresa, String idEmpleado, String rfc) {
        return rest.post()
                .uri("/core/cuentas-nomina")
                .body(Map.of("idEmpresa", idEmpresa, "idEmpleado", idEmpleado, "rfc", rfc))
                .retrieve()
                .body(CuentaNomina.class);
    }

    @Override
    public Saldo consultarSaldo(String clabeOrigen) {
        return rest.get()
                .uri("/core/cuentas/{clabe}/saldo", clabeOrigen)
                .retrieve()
                .body(Saldo.class);
    }

    @Override
    public CargoResultado instruirCargo(String clabeOrigen, BigDecimal monto, String referencia) {
        return rest.post()
                .uri("/core/cargos")
                .body(Map.of("clabeOrigen", clabeOrigen, "monto", monto.toPlainString(),
                        "referencia", referencia))
                .retrieve()
                .body(CargoResultado.class);
    }
}
