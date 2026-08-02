package mx.scotiabank.nomina.integration.spei;

import java.math.BigDecimal;
import java.util.Map;
import mx.scotiabank.nomina.integration.spei.dto.SpeiResultado;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Implementacion REST del puerto hacia el SPEI Adapter (SPE-ANCE-006).
 *
 * <p>Durante una dispersion masiva se invoca una vez por renglon; Virtual Threads
 * permite el fan-out sin agotar hilos de plataforma. NUNCA loguea CLABE destino.
 */
@Component
public class SpeiRestClient implements SpeiGateway {

    private final RestClient rest;

    public SpeiRestClient(RestClient.Builder builder,
                          @Value("${integration.spei.base-url}") String baseUrl) {
        this.rest = builder.baseUrl(baseUrl).build();
    }

    @Override
    public SpeiResultado instruirPago(String clabeDestino, BigDecimal importe, String referencia) {
        return rest.post()
                .uri("/spei/pagos")
                .body(Map.of("clabeDestino", clabeDestino, "importe", importe.toPlainString(),
                        "referencia", referencia))
                .retrieve()
                .body(SpeiResultado.class);
    }
}
