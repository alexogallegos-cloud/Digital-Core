package mx.scotiabank.nomina.empleado.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
import java.util.List;
import mx.scotiabank.nomina.common.PageInfo;
import mx.scotiabank.nomina.common.validation.Curp;
import mx.scotiabank.nomina.common.validation.Rfc;
import mx.scotiabank.nomina.empleado.EstadoCuentaEmpleado;

/**
 * DTOs de Empleado (schemas del OpenAPI). Records inmutables. El dinero viaja
 * como string-decimal (Money) — validado con el patron del contrato.
 */
public final class EmpleadoDtos {

    private EmpleadoDtos() {
    }

    /** {@code EmpleadoCreate}. */
    public record EmpleadoCreate(
            @NotBlank String numeroEmpleado,
            @NotBlank String nombres,
            @NotBlank String primerApellido,
            String segundoApellido,
            @NotBlank @Rfc String rfc,
            @NotBlank @Curp String curp,
            String genero,
            String nacionalidad,
            String estadoCivil,
            @NotNull LocalDate fechaIngreso,
            @NotBlank @Pattern(regexp = "^\\d+\\.\\d{2}$",
                    message = "ingresoMensualNeto debe ser Money (^\\d+\\.\\d{2}$)")
            String ingresoMensualNeto,
            @NotBlank String idCentroTrabajo) {
    }

    /** {@code Empleado} (respuesta) · PII/PCI enmascarados segun rol. */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record EmpleadoResponse(
            String idEmpleado,
            String numeroEmpleado,
            String nombreCompleto,
            String rfc,
            String curp,
            String clabe,
            String numeroTarjeta,
            EstadoCuentaEmpleado estadoCuenta,
            String idCentroTrabajo) {
    }

    /** {@code EmpleadoPage}. */
    public record EmpleadoPage(List<EmpleadoResponse> data, PageInfo page) {
    }

    /** Sub-error de fila del schema {@code CargaMasivaResultado}. */
    public record FilaError(int fila, String campo, String mensaje) {
    }

    /** {@code CargaMasivaResultado}. */
    public record CargaMasivaResultado(
            String idCarga,
            String estado,
            int totalRegistros,
            int exitosos,
            int conError,
            List<FilaError> errores) {
    }

    /** Body de la baja logica (PATCH /empleados/{id}). */
    public record BajaRequest(@NotNull LocalDate fechaEfectiva) {
    }
}
