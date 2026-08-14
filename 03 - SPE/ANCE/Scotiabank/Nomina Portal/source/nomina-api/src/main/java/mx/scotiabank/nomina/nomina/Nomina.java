package mx.scotiabank.nomina.nomina;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Nomina Â· cabecera de un ciclo de pago (spec Â§5). Tabla {@code Nomina}.
 * Encapsula las transiciones de su maquina de estados (Â§6.2).
 */
@Entity
@Table(name = "Nomina")
public class Nomina {

    @Id
    @Column(name = "idNomina", columnDefinition = "uniqueidentifier")
    private UUID idNomina;

    @Column(name = "idEmpresa", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idEmpresa;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false, length = 16)
    private TipoNomina tipo;

    @Column(name = "periodoInicio", nullable = false)
    private LocalDate periodoInicio;

    @Column(name = "periodoFin", nullable = false)
    private LocalDate periodoFin;

    @Column(name = "descripcion")
    private String descripcion;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoNomina estado = EstadoNomina.BORRADOR;

    @Column(name = "montoTotal", precision = 18, scale = 2)
    private BigDecimal montoTotal = BigDecimal.ZERO;

    @Column(name = "totalEmpleados")
    private int totalEmpleados;

    @Column(name = "fechaProgramada")
    private LocalDateTime fechaProgramada;

    protected Nomina() {
    }

    public static Nomina crear(UUID idEmpresa, TipoNomina tipo, LocalDate inicio,
                               LocalDate fin, String descripcion) {
        Nomina n = new Nomina();
        n.idNomina = UUID.randomUUID();
        n.idEmpresa = idEmpresa;
        n.tipo = tipo;
        n.periodoInicio = inicio;
        n.periodoFin = fin;
        n.descripcion = descripcion;
        n.estado = EstadoNomina.BORRADOR;
        return n;
    }

    /** Transicion tras cargar el layout: -> LAYOUT_CARGADO con totales. */
    public void marcarLayoutCargado(BigDecimal montoTotal, int totalEmpleados) {
        this.montoTotal = montoTotal;
        this.totalEmpleados = totalEmpleados;
        this.estado = EstadoNomina.LAYOUT_CARGADO;
    }

    /** Resultado de validar el layout: -> VALIDADA (sin errores) o se queda en LAYOUT_CARGADO. */
    public void marcarValidada() {
        this.estado = EstadoNomina.VALIDADA;
    }

    public void marcarEnAutorizacion() {
        this.estado = EstadoNomina.EN_AUTORIZACION;
    }

    public void marcarDispersando() {
        this.estado = EstadoNomina.DISPERSANDO;
    }

    public void resolverDispersion(boolean todosConfirmados) {
        this.estado = todosConfirmados ? EstadoNomina.CONFIRMADA : EstadoNomina.RECHAZADA_PARCIAL;
    }

    public UUID getIdNomina() {
        return idNomina;
    }

    public UUID getIdEmpresa() {
        return idEmpresa;
    }

    public TipoNomina getTipo() {
        return tipo;
    }

    public LocalDate getPeriodoInicio() {
        return periodoInicio;
    }

    public LocalDate getPeriodoFin() {
        return periodoFin;
    }

    public EstadoNomina getEstado() {
        return estado;
    }

    public BigDecimal getMontoTotal() {
        return montoTotal;
    }

    public int getTotalEmpleados() {
        return totalEmpleados;
    }

    public void setFechaProgramada(LocalDateTime fechaProgramada) {
        this.fechaProgramada = fechaProgramada;
    }
}

