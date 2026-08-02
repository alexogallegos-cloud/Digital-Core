package mx.scotiabank.nomina.nomina;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * DetalleNomina · renglon por empleado en la nomina (spec §5). Tabla
 * {@code DetalleNomina}. {@code clabeDestino} es PCI.
 */
@Entity
@Table(name = "DetalleNomina")
public class DetalleNomina {

    @Id
    @Column(name = "idDetalle", columnDefinition = "uniqueidentifier")
    private UUID idDetalle;

    @Column(name = "idNomina", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idNomina;

    @Column(name = "idEmpleado", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idEmpleado;

    /** PCI. */
    @Column(name = "clabeDestino", length = 18)
    private String clabeDestino;

    @Column(name = "importe", precision = 18, scale = 2)
    private BigDecimal importe;

    @Enumerated(EnumType.STRING)
    @Column(name = "estadoRenglon", nullable = false, length = 8)
    private EstadoRenglon estadoRenglon = EstadoRenglon.VALIDO;

    @Column(name = "mensajeError")
    private String mensajeError;

    protected DetalleNomina() {
    }

    public static DetalleNomina de(UUID idNomina, UUID idEmpleado, String clabeDestino, BigDecimal importe) {
        DetalleNomina d = new DetalleNomina();
        d.idDetalle = UUID.randomUUID();
        d.idNomina = idNomina;
        d.idEmpleado = idEmpleado;
        d.clabeDestino = clabeDestino;
        d.importe = importe;
        d.estadoRenglon = EstadoRenglon.VALIDO;
        return d;
    }

    public void marcarError(String mensaje) {
        this.estadoRenglon = EstadoRenglon.ERROR;
        this.mensajeError = mensaje;
    }

    public boolean esValido() {
        return estadoRenglon == EstadoRenglon.VALIDO;
    }

    public UUID getIdDetalle() {
        return idDetalle;
    }

    public UUID getIdNomina() {
        return idNomina;
    }

    public UUID getIdEmpleado() {
        return idEmpleado;
    }

    public String getClabeDestino() {
        return clabeDestino;
    }

    public BigDecimal getImporte() {
        return importe;
    }

    public EstadoRenglon getEstadoRenglon() {
        return estadoRenglon;
    }

    public String getMensajeError() {
        return mensajeError;
    }
}
