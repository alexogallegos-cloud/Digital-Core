package mx.scotiabank.nomina.spei;

import jakarta.validation.Valid;
import mx.scotiabank.nomina.spei.SpeiDtos.PagoRequest;
import mx.scotiabank.nomina.spei.SpeiDtos.SpeiResultado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Contrato REST del SPEI Adapter consumido por nomina-api ({@code SpeiRestClient}).
 * Se invoca una vez por renglon de dispersion (fan-out sobre Virtual Threads).
 */
@RestController
@RequestMapping("/spei")
public class SpeiController {

    private final SpeiStub stub;

    public SpeiController(SpeiStub stub) {
        this.stub = stub;
    }

    @PostMapping("/pagos")
    public SpeiResultado instruirPago(@Valid @RequestBody PagoRequest req) {
        return stub.instruirPago(req.clabeDestino(), req.importe(), req.referencia());
    }
}
