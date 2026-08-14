package mx.scotiabank.nomina.integration.spei;

import java.math.BigDecimal;
import mx.scotiabank.nomina.integration.spei.dto.SpeiResultado;

/**
 * Puerto (Anti-Corruption Layer) hacia el gateway SPEI · SPE-ANCE-006.
 *
 * <p>En el mock lo implementa {@link SpeiRestClient} apuntando al SPEI Adapter
 * stub. El gateway real (directo Banxico o intermediario interno Scotiabank)
 * queda para ADR-ANCE-005.
 */
public interface SpeiGateway {

    /** Instruye un pago SPEI a una CLABE destino. Devuelve confirmacion o rechazo Banxico. */
    SpeiResultado instruirPago(String clabeDestino, BigDecimal importe, String referencia);
}
