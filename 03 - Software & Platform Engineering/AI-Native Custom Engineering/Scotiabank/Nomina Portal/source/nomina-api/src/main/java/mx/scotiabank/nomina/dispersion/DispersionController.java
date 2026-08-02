package mx.scotiabank.nomina.dispersion;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.UUID;
import mx.scotiabank.nomina.common.CurrentUser;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.DispersionDetalleResponse;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.DispersionResponse;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.InstruirDispersionRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

/**
 * Dispersiones (M6). operationIds del OpenAPI: instruirDispersion (bajo
 * {@code /nominas/{idNomina}/dispersar}) y getEstadoDispersion.
 *
 * <p>La instruccion la hacen ADMIN_EMPRESA y OPERADOR_NOMINA (con 2FA · RN-08);
 * el AUDITOR puede consultar el estado (solo lectura).
 */
@RestController
public class DispersionController {

    private final DispersionService service;

    public DispersionController(DispersionService service) {
        this.service = service;
    }

    /** operationId: instruirDispersion · 202 + Location (irreversible tras autorizar). */
    @PostMapping("/api/v1/nominas/{idNomina}/dispersar")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public ResponseEntity<DispersionResponse> instruirDispersion(
            @PathVariable UUID idNomina,
            @RequestHeader(name = "Idempotency-Key") UUID idempotencyKey,
            @Valid @RequestBody InstruirDispersionRequest body) {
        DispersionResponse d = service.instruir(
                CurrentUser.idEmpresa(), idNomina, body, CurrentUser.idUsuario());
        return ResponseEntity
                .accepted()
                .location(URI.create("/api/v1/dispersiones/" + d.idDispersion() + "/estado"))
                .body(d);
    }

    /** operationId: getEstadoDispersion (polling · estado por empleado). */
    @GetMapping("/api/v1/dispersiones/{idDispersion}/estado")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR')")
    public DispersionDetalleResponse getEstadoDispersion(@PathVariable UUID idDispersion) {
        return service.estado(idDispersion);
    }
}
