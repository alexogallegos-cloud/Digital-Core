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
 * Dispersion Â· ejecucion de la nomina (spec Â§5). Tabla {@code Dispersion}.
 * Relacion 1-1 con Nomina.
 */
@Entity
@Table(name = "Dispersion")
public class Dispersion {

    @Id
    @Column(name = "idDispersion", columnDefinition = "uniqueidentifier")
    private UUID idDispersion;

    @Column(name = "idNomina", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID idNomina;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 20)
    private EstadoDispersion estado = EstadoDispersion.PENDIENTE;

    @Column(name = "fechaInstruccion", nullable = false)
    private LocalDateTime fechaInstruccion;

    @Column(name = "usuarioInstruye", columnDefinition = "uniqueidentifier")
    private UUID usuarioInstruye;

    @Column(name = "usuarioAutoriza", columnDefinition = "uniqueidentifier")
    private UUID usuarioAutoriza;

    @Column(name = "referenciaInterna")
    private String referenciaInterna;

    @Column(name = "montoDispersado", precision = 18, scale = 2)
    private BigDecimal montoDispersado = BigDecimal.ZERO;

    protected Dispersion() {
    }

    public static Dispersion instruir(UUID idNomina, UUID usuarioInstruye, BigDecimal monto) {
        Dispersion d = new Dispersion();
        d.idDispersion = UUID.randomUUID();
        d.idNomina = idNomina;
        d.usuarioInstruye = usuarioInstruye;
        d.estado = EstadoDispersion.PROCESANDO;
        d.fechaInstruccion = LocalDateTime.now();
        d.referenciaInterna = "DISP-" + d.idDispersion.toString().substring(0, 8).toUpperCase();
        d.montoDispersado = monto;
        return d;
    }

    public void resolver(boolean todosConfirmados) {
        this.estado = todosConfirmados ? EstadoDispersion.CONFIRMADA : EstadoDispersion.RECHAZADA_PARCIAL;
    }

    public UUID getIdDispersion() {
        return idDispersion;
    }

    public UUID getIdNomina() {
        return idNomina;
    }

    public EstadoDispersion getEstado() {
        return estado;
    }

    public LocalDateTime getFechaInstruccion() {
        return fechaInstruccion;
    }

    public String getReferenciaInterna() {
        return referenciaInterna;
    }

    public BigDecimal getMontoDispersado() {
        return montoDispersado;
    }
}

