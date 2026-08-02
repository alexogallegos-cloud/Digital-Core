package mx.scotiabank.nomina.dashboard;

import java.nio.charset.StandardCharsets;
import mx.scotiabank.nomina.common.CurrentUser;
import mx.scotiabank.nomina.dashboard.dto.DashboardDtos.DashboardResumen;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Dashboard (M2). operationIds: getDashboardResumen, descargarReporte. Solo
 * lectura; disponible para los tres roles de empresa (el AUDITOR también).
 */
@RestController
@RequestMapping("/api/v1/dashboard")
public class DashboardController {

    private final DashboardService service;

    public DashboardController(DashboardService service) {
        this.service = service;
    }

    /** operationId: getDashboardResumen. {@code meses} = filtro "Intervalo de tiempo" (opcional). */
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR')")
    public DashboardResumen resumen(@RequestParam(required = false) Integer meses) {
        return service.resumen(CurrentUser.idEmpresa(), meses);
    }

    /** operationId: descargarReporte. Genera CSV real (RESUMEN | EMPLEADOS | NOMINAS). */
    @GetMapping("/reporte")
    @PreAuthorize("hasAnyRole('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR')")
    public ResponseEntity<byte[]> reporte(
            @RequestParam(defaultValue = "RESUMEN") String tipo,
            @RequestParam(required = false) Integer meses) {
        String csv = service.reporteCsv(CurrentUser.idEmpresa(), tipo, meses);
        byte[] body = csv.getBytes(StandardCharsets.UTF_8);
        String filename = "reporte-" + tipo.toLowerCase() + ".csv";
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .body(body);
    }
}