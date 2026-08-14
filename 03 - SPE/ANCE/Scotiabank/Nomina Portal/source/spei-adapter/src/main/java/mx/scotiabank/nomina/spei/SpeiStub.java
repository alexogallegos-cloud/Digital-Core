package mx.scotiabank.nomina.spei;

import java.util.concurrent.ThreadLocalRandom;
import mx.scotiabank.nomina.spei.SpeiDtos.SpeiResultado;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * STUB determinista de SPEI para el mock.
 *
 * <p>Regla: una CLABE destino que termina en {@code spei.stub.sufijo-rechazo}
 * es rechazada con codigo Banxico simulado — materializa TC-DISP-012 (dispersion
 * rechazada por SPEI). El resto se confirma con una clave de rastreo de 18 digitos.
 *
 * <p>REEMPLAZAR por el gateway SPEI real en produccion (ADR-ANCE-005). El contrato
 * REST expuesto por {@link SpeiController} se mantiene estable en esa migracion.
 */
@Service
public class SpeiStub {

    private final String sufijoRechazo;
    private final String codigoRechazo;

    public SpeiStub(
            @Value("${spei.stub.sufijo-rechazo}") String sufijoRechazo,
            @Value("${spei.stub.codigo-rechazo}") String codigoRechazo) {
        this.sufijoRechazo = sufijoRechazo;
        this.codigoRechazo = codigoRechazo;
    }

    public SpeiResultado instruirPago(String clabeDestino, String importe, String referencia) {
        if (clabeDestino != null && clabeDestino.endsWith(sufijoRechazo)) {
            // TC-DISP-012: rechazo por SPEI. El importe NO se debita en el flujo del portal.
            return new SpeiResultado(false, null, codigoRechazo,
                    "Cuenta destino rechazada por SPEI (codigo " + codigoRechazo + ")");
        }
        String claveRastreo = generarClaveRastreo();
        return new SpeiResultado(true, claveRastreo, null, "Pago confirmado");
    }

    /** Clave de rastreo SPEI de 18 digitos. */
    private static String generarClaveRastreo() {
        StringBuilder sb = new StringBuilder(18);
        for (int i = 0; i < 18; i++) {
            sb.append(ThreadLocalRandom.current().nextInt(10));
        }
        return sb.toString();
    }
}
