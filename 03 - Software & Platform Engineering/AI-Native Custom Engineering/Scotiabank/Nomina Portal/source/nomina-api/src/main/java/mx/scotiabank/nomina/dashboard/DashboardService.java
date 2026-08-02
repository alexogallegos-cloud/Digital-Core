package mx.scotiabank.nomina.dashboard;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import mx.scotiabank.nomina.centrotrabajo.CentroTrabajoRepository;
import mx.scotiabank.nomina.dashboard.dto.DashboardDtos.CentroResumen;
import mx.scotiabank.nomina.dashboard.dto.DashboardDtos.DashboardResumen;
import mx.scotiabank.nomina.dashboard.dto.DashboardDtos.EstadoConteo;
import mx.scotiabank.nomina.empleado.EmpleadoRepository;
import mx.scotiabank.nomina.empleado.EstadoCuentaEmpleado;
import mx.scotiabank.nomina.nomina.NominaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Resumen del dashboard y reporte CSV (spec §8.1). Agrega en BD el estado de la
 * operación de la empresa. Todas las consultas se acotan a {@code idEmpresa}
 * (multi-tenant). El filtro "Intervalo de tiempo" acota las estadísticas de
 * empleados por fecha de ingreso.
 */
@Service
public class DashboardService {

    private static final EstadoCuentaEmpleado EXCLUIR = EstadoCuentaEmpleado.ELIMINADA;

    private final EmpleadoRepository empleados;
    private final NominaRepository nominas;
    private final CentroTrabajoRepository centros;

    public DashboardService(EmpleadoRepository empleados,
                            NominaRepository nominas,
                            CentroTrabajoRepository centros) {
        this.empleados = empleados;
        this.nominas = nominas;
        this.centros = centros;
    }

    /**
     * @param meses ventana en meses para el filtro de empleados (null = todo el histórico).
     */
    @Transactional(readOnly = true)
    public DashboardResumen resumen(UUID idEmpresa, Integer meses) {
        LocalDate desde = (meses == null) ? null : LocalDate.now().minusMonths(meses);

        List<EstadoConteo> empleadosPorEstado =
                toConteo(empleados.conteoPorEstado(idEmpresa, EXCLUIR, desde));
        long totalEmpleados = empleadosPorEstado.stream().mapToLong(EstadoConteo::total).sum();

        List<EstadoConteo> nominasPorEstado = toConteo(nominas.conteoPorEstado(idEmpresa));
        long totalNominas = nominas.countByIdEmpresa(idEmpresa);

        List<CentroResumen> centrosResumen = centros.findByIdEmpresa(idEmpresa).stream()
                .map(c -> new CentroResumen(
                        c.getIdCentroTrabajo().toString(),
                        c.getNombre(),
                        c.getSucursalAsignada()))
                .toList();

        return new DashboardResumen(
                empleadosPorEstado, totalEmpleados,
                nominasPorEstado, totalNominas,
                centrosResumen, centrosResumen.size());
    }

    /**
     * Genera un reporte CSV real desde la BD. {@code tipo} ∈ RESUMEN | EMPLEADOS | NOMINAS.
     * {@code meses} acota EMPLEADOS por fecha de ingreso.
     */
    @Transactional(readOnly = true)
    public String reporteCsv(UUID idEmpresa, String tipo, Integer meses) {
        String t = (tipo == null) ? "RESUMEN" : tipo.trim().toUpperCase();
        return switch (t) {
            case "EMPLEADOS" -> reporteEmpleados(idEmpresa, meses);
            case "NOMINAS" -> reporteNominas(idEmpresa);
            default -> reporteResumen(idEmpresa, meses);
        };
    }

    private String reporteResumen(UUID idEmpresa, Integer meses) {
        DashboardResumen r = resumen(idEmpresa, meses);
        StringBuilder sb = new StringBuilder();
        sb.append("seccion,clave,valor\n");
        for (EstadoConteo e : r.empleadosPorEstado()) {
            sb.append("empleados,").append(e.estado()).append(',').append(e.total()).append('\n');
        }
        sb.append("empleados,TOTAL,").append(r.totalEmpleados()).append('\n');
        for (EstadoConteo n : r.nominasPorEstado()) {
            sb.append("nominas,").append(n.estado()).append(',').append(n.total()).append('\n');
        }
        sb.append("nominas,TOTAL,").append(r.totalNominas()).append('\n');
        sb.append("centros,TOTAL,").append(r.totalCentros()).append('\n');
        return sb.toString();
    }

    private String reporteEmpleados(UUID idEmpresa, Integer meses) {
        LocalDate desde = (meses == null) ? null : LocalDate.now().minusMonths(meses);
        StringBuilder sb = new StringBuilder();
        sb.append("numeroEmpleado,nombre,estadoCuenta,fechaIngreso\n");
        empleados.findByIdEmpresaAndEstadoCuentaNotOrderByPrimerApellidoAsc(idEmpresa, EXCLUIR).stream()
                .filter(e -> desde == null || !e.getFechaIngreso().isBefore(desde))
                .forEach(e -> sb.append(csv(e.getNumeroEmpleado())).append(',')
                        .append(csv(e.nombreCompleto())).append(',')
                        .append(e.getEstadoCuenta()).append(',')
                        .append(e.getFechaIngreso()).append('\n'));
        return sb.toString();
    }

    private String reporteNominas(UUID idEmpresa) {
        StringBuilder sb = new StringBuilder();
        sb.append("tipo,periodoInicio,periodoFin,estado,montoTotal,totalEmpleados\n");
        nominas.findByIdEmpresaOrderByPeriodoInicioDesc(idEmpresa)
                .forEach(n -> sb.append(n.getTipo()).append(',')
                        .append(n.getPeriodoInicio()).append(',')
                        .append(n.getPeriodoFin()).append(',')
                        .append(n.getEstado()).append(',')
                        .append(n.getMontoTotal()).append(',')
                        .append(n.getTotalEmpleados()).append('\n'));
        return sb.toString();
    }

    /** Mapea filas {@code [enum, count]} de la agregación a {@link EstadoConteo}. */
    private static List<EstadoConteo> toConteo(List<Object[]> rows) {
        return rows.stream()
                .map(r -> new EstadoConteo(((Enum<?>) r[0]).name(), ((Number) r[1]).longValue()))
                .toList();
    }

    /** Escapa un valor para CSV (comillas si contiene coma/comilla/salto). */
    private static String csv(String v) {
        if (v == null) {
            return "";
        }
        if (v.contains(",") || v.contains("\"") || v.contains("\n")) {
            return '"' + v.replace("\"", "\"\"") + '"';
        }
        return v;
    }
}