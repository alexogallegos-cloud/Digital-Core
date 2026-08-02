package mx.scotiabank.nomina.dispersion;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * MovimientoDispersion Â· resultado por empleado (spec Â§5). Tabla
 * {@code MovimientoDispersion}. {@code clabeDestino} es PCI.
 */
@Entity
@Table(name = "MovimientoDispersion")
public class MovimientoDispersion {

    @Id
    @Column(name = "idMovimiento", columnDefinition = "uniqueidentifier")
    private UUID idMovimiento;

    @Column(name = "idDispersion", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idDispersion;

    @Column(name = "idEmpleado", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idEmpleado;

    @Column(name = "importe", precision = 18, scale = 2)
    private BigDecimal importe;

    /** PCI. */
    @Column(name = "clabeDestino", length = 18)
    private String clabeDestino;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 12)
    private EstadoMovimiento estado = EstadoMovimiento.ENVIADO;

    /** Clave de rastreo SPEI (18 digitos). */
    @Column(name = "referenciaSPEI", length = 18)
    private String referenciaSPEI;

    @Column(name = "codigoRechazoBanxico")
    private String codigoRechazoBanxico;

    @Column(name = "fechaConfirmacion")
    private LocalDateTime fechaConfirmacion;

    protected MovimientoDispersion() {
    }

    public static MovimientoDispersion enviado(UUID idDispersion, UUID idEmpleado,
                                               BigDecimal importe, String clabeDestino) {
        MovimientoDispersion m = new MovimientoDispersion();
        m.idMovimiento = UUID.randomUUID();
        m.idDispersion = idDispersion;
        m.idEmpleado = idEmpleado;
        m.importe = importe;
        m.clabeDestino = clabeDestino;
        m.estado = EstadoMovimiento.ENVIADO;
        return m;
    }

    public void confirmar(String referenciaSPEI) {
        this.estado = EstadoMovimiento.CONFIRMADO;
        this.referenciaSPEI = referenciaSPEI;
        this.fechaConfirmacion = LocalDateTime.now();
    }

    public void rechazar(String codigoRechazoBanxico) {
        this.estado = EstadoMovimiento.RECHAZADO;
        this.codigoRechazoBanxico = codigoRechazoBanxico;
    }

    public boolean confirmado() {
        return estado == EstadoMovimiento.CONFIRMADO;
    }

    public UUID getIdMovimiento() {
        return idMovimiento;
    }

    public UUID getIdDispersion() {
        return idDispersion;
    }

    public UUID getIdEmpleado() {
        return idEmpleado;
    }

    public BigDecimal getImporte() {
        return importe;
    }

    public String getClabeDestino() {
        return clabeDestino;
    }

    public EstadoMovimiento getEstado() {
        return estado;
    }

    public String getReferenciaSPEI() {
        return referenciaSPEI;
    }

    public String getCodigoRechazoBanxico() {
        return codigoRechazoBanxico;
    }
}

