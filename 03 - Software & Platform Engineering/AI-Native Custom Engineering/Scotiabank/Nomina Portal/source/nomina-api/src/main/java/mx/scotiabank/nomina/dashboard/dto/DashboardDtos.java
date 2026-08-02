package mx.scotiabank.nomina.dashboard.dto;

import java.util.List;

/**
 * DTOs del dashboard (spec §8). El resumen se calcula con agregaciones en BD
 * (GROUP BY) acotadas a la empresa del solicitante — no se derivan en el cliente.
 */
public final class DashboardDtos {

    private DashboardDtos() {
    }

    /** Conteo de una entidad por valor de estado (empleado o nómina). */
    public record EstadoConteo(String estado, long total) {
    }

    /** Centro de trabajo resumido para el panel lateral. */
    public record CentroResumen(String idCentroTrabajo, String nombre, String sucursal) {
    }

    /** Payload de {@code GET /dashboard}. */
    public record DashboardResumen(
            List<EstadoConteo> empleadosPorEstado,
            long totalEmpleados,
            List<EstadoConteo> nominasPorEstado,
            long totalNominas,
            List<CentroResumen> centros,
            long totalCentros) {
    }
}