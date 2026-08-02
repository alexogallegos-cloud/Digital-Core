package mx.scotiabank.nomina.empleado;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import java.util.UUID;
import mx.scotiabank.nomina.common.CurrentUser;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.BajaRequest;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.CargaMasivaResultado;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoCreate;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoPage;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoResponse;
import mx.scotiabank.nomina.usuario.Rol;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/**
 * Empleados (M4). operationIds del OpenAPI: listEmpleados, createEmpleado,
 * getEmpleado, bajaEmpleado, cargaMasivaEmpleados.
 *
 * <p>Autorizacion por rol via {@code @PreAuthorize} (identica en mock y prod).
 * El AUDITOR es solo lectura; el alta y la baja las hacen ADMIN_EMPRESA y
 * OPERADOR_NOMINA.
 */
@RestController
@RequestMapping("/api/v1/empleados")
public class EmpleadoController {

    private final EmpleadoService service;

    public EmpleadoController(EmpleadoService service) {
        this.service = service;
    }

    /** operationId: listEmpleados. */
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR')")
    public EmpleadoPage listEmpleados(
            @RequestParam(required = false) String cursor,
            @RequestParam(defaultValue = "25") int limit,
            @RequestParam(required = false) EstadoCuentaEmpleado estadoCuenta,
            @RequestParam(required = false) String q) {
        return service.list(CurrentUser.idEmpresa(), estadoCuenta, q, limit, rol());
    }

    /** operationId: createEmpleado. Requiere Idempotency-Key (efecto financiero: apertura de cuenta). */
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public ResponseEntity<EmpleadoResponse> createEmpleado(
            @RequestHeader(name = "Idempotency-Key") UUID idempotencyKey,
            @Valid @RequestBody EmpleadoCreate body) {
        EmpleadoResponse created = service.create(CurrentUser.idEmpresa(), body, rol());
        return ResponseEntity
                .created(URI.create("/api/v1/empleados/" + created.idEmpleado()))
                .body(created);
    }

    /** operationId: getEmpleado. */
    @GetMapping("/{idEmpleado}")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR')")
    public EmpleadoResponse getEmpleado(@PathVariable UUID idEmpleado) {
        return service.get(CurrentUser.idEmpresa(), idEmpleado, rol());
    }

    /** operationId: bajaEmpleado (PATCH · baja logica). */
    @PatchMapping("/{idEmpleado}")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public EmpleadoResponse bajaEmpleado(@PathVariable UUID idEmpleado,
                                         @Valid @RequestBody BajaRequest body) {
        return service.baja(CurrentUser.idEmpresa(), idEmpleado, rol());
    }

    /**
     * operationId: cargaMasivaEmpleados. Recibe archivo (Excel/TXT), procesa el
     * lote de forma asincrona y reporta error por fila sin abortar el lote valido
     * (RN-12). El parser real de archivo lo desarrolla una story dedicada; aqui se
     * expone el contrato 202 + CargaMasivaResultado.
     */
    @PostMapping(path = "/carga-masiva", consumes = "multipart/form-data")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA')")
    public ResponseEntity<CargaMasivaResultado> cargaMasivaEmpleados(
            @RequestHeader(name = "Idempotency-Key") UUID idempotencyKey,
            @RequestParam("archivo") MultipartFile archivo,
            @RequestParam(name = "idCentroTrabajoDefault", required = false) String idCentroTrabajoDefault) {
        var resultado = new CargaMasivaResultado(
                UUID.randomUUID().toString(), "PROCESANDO", 0, 0, 0, List.of());
        return ResponseEntity.accepted().body(resultado);
    }

    private static Rol rol() {
        return Rol.valueOf(CurrentUser.rol());
    }
}
