package mx.scotiabank.nomina.dispersion.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.util.List;
import mx.scotiabank.nomina.dispersion.EstadoDispersion;
import mx.scotiabank.nomina.dispersion.EstadoMovimiento;

/** DTOs de Dispersion (schemas del OpenAPI). Records inmutables. */
public final class DispersionDtos {

    private DispersionDtos() {
    }

    /** Body de {@code instruirDispersion}: 2FA obligatorio (RN-08) + fecha opcional. */
    public record InstruirDispersionRequest(
            @NotBlank String challengeId,
            @NotBlank String code,
            LocalDateTime fechaProgramada) {
    }

    /** {@code Dispersion} (respuesta). */
    public record DispersionResponse(
            String idDispersion,
            String idNomina,
            EstadoDispersion estado,
            String montoDispersado,
            String referenciaInterna,
            LocalDateTime fechaInstruccion) {
    }

    /** {@code MovimientoDispersion} Â· clabeDestino enmascarada (PCI). */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record MovimientoResponse(
            String idEmpleado,
            String importe,
            String clabeDestino,
            EstadoMovimiento estado,
            String referenciaSPEI,
            String codigoRechazoBanxico) {
    }

    /** {@code DispersionDetalle} = Dispersion + movimientos[]. */
    public record DispersionDetalleResponse(
            String idDispersion,
            String idNomina,
            EstadoDispersion estado,
            String montoDispersado,
            String referenciaInterna,
            LocalDateTime fechaInstruccion,
            List<MovimientoResponse> movimientos) {
    }
}

