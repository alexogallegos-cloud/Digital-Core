package mx.scotiabank.nomina.centrotrabajo;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

/**
 * CentroTrabajo (spec §5). Modelado minimo para la referencia FK desde Empleado;
 * el CRUD completo (M5) lo desarrolla otra story del backlog.
 */
@Entity
@Table(name = "CentroTrabajo")
public class CentroTrabajo {

    @Id
    @Column(name = "idCentroTrabajo", columnDefinition = "uniqueidentifier")
    private UUID idCentroTrabajo;

    @Column(name = "idEmpresa", columnDefinition = "uniqueidentifier")
    private UUID idEmpresa;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "sucursalAsignada")
    private String sucursalAsignada;

    protected CentroTrabajo() {
    }

    public UUID getIdCentroTrabajo() {
        return idCentroTrabajo;
    }

    public UUID getIdEmpresa() {
        return idEmpresa;
    }

    public String getNombre() {
        return nombre;
    }

    public String getSucursalAsignada() {
        return sucursalAsignada;
    }
}
