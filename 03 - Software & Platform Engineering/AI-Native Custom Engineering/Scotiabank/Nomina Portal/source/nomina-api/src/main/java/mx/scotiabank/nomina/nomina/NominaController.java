package mx.scotiabank.nomina.nomina;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.UUID;
import mx.scotiabank.nomina.common.CurrentUser;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.NominaCreate;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.NominaResponse;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.ResumenNomina;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.ValidacionNomina;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/**
 * Nominas (M6). operationIds del OpenAPI: createNomina, cargarLayoutNomina,
 * validarNomina, getResumenNomina.
 *
 * <p>La creacion, carga y validacion las hacen ADMIN_EMPRESA y OPERADOR_NOMINA;
 * el resumen lo puede leer tambien el AUDITOR.
 */
@RestController
@RequestMapping("/api/v1/nominas")
public class NominaController {

    private final NominaService service;
    private final LayoutParser layoutParser;

    public NominaController(NominaService service, LayoutParser layoutParser) {
        this.service = service;
        this.layoutParser = layoutParser;
    }

    /** operationId: createNomina. Requiere Idempotency-Key. */
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public ResponseEntity<NominaResponse> createNomina(
            @RequestHeader(name = "Idempotency-Key") UUID idempotencyKey,
            @Valid @RequestBody NominaCreate body) {
        NominaResponse created = service.create(CurrentUser.idEmpresa(), body);
        return ResponseEntity
                .created(URI.create("/api/v1/nominas/" + created.idNomina()))
                .body(created);
    }

    /** operationId: cargarLayoutNomina (multipart). */
    @PostMapping(path = "/{idNomina}/layout", consumes = "multipart/form-data")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public NominaResponse cargarLayoutNomina(
            @PathVariable UUID idNomina,
            @RequestHeader(name = "Idempotency-Key") UUID idempotencyKey,
            @RequestParam("archivo") MultipartFile archivo) {
        var renglones = layoutParser.parse(idNomina, archivo);
        return service.cargarLayout(CurrentUser.idEmpresa(), idNomina, renglones);
    }

    /** operationId: validarNomina. */
    @PostMapping("/{idNomina}/validar")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public ValidacionNomina validarNomina(@PathVariable UUID idNomina) {
        return service.validar(CurrentUser.idEmpresa(), idNomina);
    }

    /** operationId: getResumenNomina. */
    @GetMapping("/{idNomina}/resumen")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR')")
    public ResumenNomina getResumenNomina(@PathVariable UUID idNomina) {
        return service.resumen(CurrentUser.idEmpresa(), idNomina);
    }
}
