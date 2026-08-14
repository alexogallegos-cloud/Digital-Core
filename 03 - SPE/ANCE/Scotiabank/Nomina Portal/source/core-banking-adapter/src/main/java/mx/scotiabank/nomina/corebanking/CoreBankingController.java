package mx.scotiabank.nomina.corebanking;

import jakarta.validation.Valid;
import java.math.BigDecimal;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.AbrirCuentaRequest;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.CargoRequest;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.CargoResultado;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.CuentaNomina;
import mx.scotiabank.nomina.corebanking.CoreBankingDtos.Saldo;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Contrato REST del Core Banking Adapter consumido por nomina-api
 * ({@code CoreBankingRestClient}). Rutas y shapes estables entre mock y prod.
 */
@RestController
@RequestMapping("/core")
public class CoreBankingController {

    private final CoreBankingStub stub;

    public CoreBankingController(CoreBankingStub stub) {
        this.stub = stub;
    }

    @PostMapping("/cuentas-nomina")
    public CuentaNomina abrirCuentaNomina(@Valid @RequestBody AbrirCuentaRequest req) {
        return stub.abrirCuentaNomina(req.idEmpresa(), req.idEmpleado(), req.rfc());
    }

    @GetMapping("/cuentas/{clabe}/saldo")
    public Saldo consultarSaldo(@PathVariable String clabe) {
        return stub.consultarSaldo(clabe);
    }

    @PostMapping("/cargos")
    public CargoResultado instruirCargo(@Valid @RequestBody CargoRequest req) {
        return stub.instruirCargo(req.clabeOrigen(), new BigDecimal(req.monto()), req.referencia());
    }
}
