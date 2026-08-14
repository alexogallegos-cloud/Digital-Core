package mx.scotiabank.nomina.empleado;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Empleado · persona con cuenta nomina (spec §5). Tabla {@code Empleado}.
 *
 * <p>Campos PII: {@code rfc}, {@code curp}, {@code ingresoMensualNeto}.
 * Campos PCI: {@code numeroCuenta}, {@code clabe}, {@code numeroTarjeta}
 * (cifrados en reposo · enmascarados en salida · NUNCA en logs).
 */
@Entity
@Table(name = "Empleado")
public class Empleado {

    @Id
    @Column(name = "idEmpleado", columnDefinition = "uniqueidentifier")
    private UUID idEmpleado;

    @Column(name = "idEmpresa", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idEmpresa;

    @Column(name = "idCentroTrabajo", columnDefinition = "uniqueidentifier")
    private UUID idCentroTrabajo;

    @Column(name = "numeroEmpleado", nullable = false)
    private String numeroEmpleado;

    @Column(name = "nombres", nullable = false)
    private String nombres;

    @Column(name = "primerApellido", nullable = false)
    private String primerApellido;

    @Column(name = "segundoApellido")
    private String segundoApellido;

    /** PII. */
    @Column(name = "rfc", nullable = false, length = 13)
    private String rfc;

    /** PII. */
    @Column(name = "curp", nullable = false, length = 18)
    private String curp;

    @Column(name = "genero", length = 16)
    private String genero;

    @Column(name = "nacionalidad")
    private String nacionalidad;

    @Column(name = "estadoCivil", length = 16)
    private String estadoCivil;

    @Column(name = "fechaIngreso", nullable = false)
    private LocalDate fechaIngreso;

    /** PII. */
    @Column(name = "ingresoMensualNeto", precision = 18, scale = 2)
    private BigDecimal ingresoMensualNeto;

    /** PCI. */
    @Column(name = "numeroCuenta")
    private String numeroCuenta;

    /** PCI. */
    @Column(name = "clabe", length = 18)
    private String clabe;

    /** PCI (tokenizado). */
    @Column(name = "numeroTarjeta")
    private String numeroTarjeta;

    @Enumerated(EnumType.STRING)
    @Column(name = "estadoCuenta", nullable = false, length = 16)
    private EstadoCuentaEmpleado estadoCuenta = EstadoCuentaEmpleado.NO_INICIADA;

    protected Empleado() {
    }

    public static Empleado nuevo(UUID idEmpresa, UUID idCentroTrabajo, String numeroEmpleado,
                                 String nombres, String primerApellido, String segundoApellido,
                                 String rfc, String curp, String genero, String nacionalidad,
                                 String estadoCivil, LocalDate fechaIngreso, BigDecimal ingresoMensualNeto) {
        Empleado e = new Empleado();
        e.idEmpleado = UUID.randomUUID();
        e.idEmpresa = idEmpresa;
        e.idCentroTrabajo = idCentroTrabajo;
        e.numeroEmpleado = numeroEmpleado;
        e.nombres = nombres;
        e.primerApellido = primerApellido;
        e.segundoApellido = segundoApellido;
        e.rfc = rfc;
        e.curp = curp;
        e.genero = genero;
        e.nacionalidad = nacionalidad;
        e.estadoCivil = estadoCivil;
        e.fechaIngreso = fechaIngreso;
        e.ingresoMensualNeto = ingresoMensualNeto;
        // Al dar de alta se solicita apertura de cuenta -> transiciona a EN_PROCESO.
        e.estadoCuenta = EstadoCuentaEmpleado.EN_PROCESO;
        return e;
    }

    public String nombreCompleto() {
        StringBuilder sb = new StringBuilder(nombres).append(' ').append(primerApellido);
        if (segundoApellido != null && !segundoApellido.isBlank()) {
            sb.append(' ').append(segundoApellido);
        }
        return sb.toString();
    }

    public void darDeBaja() {
        this.estadoCuenta = EstadoCuentaEmpleado.ELIMINADA;
    }

    /** Registra la CLABE/cuenta asignadas por el core y vincula la cuenta. */
    public void vincularCuenta(String numeroCuenta, String clabe) {
        this.numeroCuenta = numeroCuenta;
        this.clabe = clabe;
        this.estadoCuenta = EstadoCuentaEmpleado.VINCULADA;
    }

    public UUID getIdEmpleado() {
        return idEmpleado;
    }

    public UUID getIdEmpresa() {
        return idEmpresa;
    }

    public UUID getIdCentroTrabajo() {
        return idCentroTrabajo;
    }

    public String getNumeroEmpleado() {
        return numeroEmpleado;
    }

    public LocalDate getFechaIngreso() {
        return fechaIngreso;
    }

    public String getRfc() {
        return rfc;
    }

    public String getCurp() {
        return curp;
    }

    public String getClabe() {
        return clabe;
    }

    public String getNumeroTarjeta() {
        return numeroTarjeta;
    }

    public BigDecimal getIngresoMensualNeto() {
        return ingresoMensualNeto;
    }

    public EstadoCuentaEmpleado getEstadoCuenta() {
        return estadoCuenta;
    }
}
