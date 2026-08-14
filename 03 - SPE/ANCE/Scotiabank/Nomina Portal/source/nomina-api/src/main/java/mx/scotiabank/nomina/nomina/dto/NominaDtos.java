package mx.scotiabank.nomina.nomina.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.List;
import mx.scotiabank.nomina.nomina.EstadoNomina;
import mx.scotiabank.nomina.nomina.TipoNomina;

/** DTOs de Nomina (schemas del OpenAPI). Records inmutables · Money como string. */
public final class NominaDtos {

    private NominaDtos() {
    }

    /** {@code NominaCreate}. */
    public record NominaCreate(
            @NotNull TipoNomina tipo,
            @NotNull LocalDate periodoInicio,
            @NotNull LocalDate periodoFin,
            String descripcion) {
    }

    /** {@code Nomina} (respuesta). */
    public record NominaResponse(
            String idNomina,
            TipoNomina tipo,
            LocalDate periodoInicio,
            LocalDate periodoFin,
            EstadoNomina estado,
            String montoTotal,
            int totalEmpleados) {
    }

    /** Sub-error de fila del schema {@code ValidacionNomina}. */
    public record FilaError(int fila, String campo, String mensaje) {
    }

    /** {@code ValidacionNomina}. */
    public record ValidacionNomina(
            EstadoNomina estado,
            int totalRenglones,
            int validos,
            List<FilaError> errores) {
    }

    /** {@code ResumenNomina}. */
    public record ResumenNomina(
            String idNomina,
            int totalEmpleados,
            String montoTotal,
            String saldoDisponibleOrigen,
            boolean fondosSuficientes) {
    }
}
