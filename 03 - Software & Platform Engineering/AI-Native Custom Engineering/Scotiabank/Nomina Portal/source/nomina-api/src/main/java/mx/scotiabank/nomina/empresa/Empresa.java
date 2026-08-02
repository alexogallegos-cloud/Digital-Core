package mx.scotiabank.nomina.empresa;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Empresa · cliente de nomina (spec §5). Tabla {@code Empresa}. Portadora de los
 * limites de dispersion y del umbral de doble autorizacion que alimentan las
 * reglas RN-04, RN-05, RN-06 y RN-09.
 *
 * <p>{@code clabeOrigen}/{@code numeroCuenta} son PCI — cifrados en reposo y
 * nunca en logs.
 */
@Entity
@Table(name = "Empresa")
public class Empresa {

    @Id
    @Column(name = "idEmpresa", columnDefinition = "uniqueidentifier")
    private UUID idEmpresa;

    @Column(name = "numeroContrato")
    private String numeroContrato;

    @Column(name = "rfcEmpresa", length = 13)
    private String rfcEmpresa;

    @Column(name = "razonSocial")
    private String razonSocial;

    @Column(name = "claveGiro")
    private String claveGiro;

    /** PCI. */
    @Column(name = "clabeOrigen", length = 18)
    private String clabeOrigen;

    /** PCI. */
    @Column(name = "numeroCuenta")
    private String numeroCuenta;

    @Column(name = "limiteDispersionNomina", precision = 18, scale = 2)
    private BigDecimal limiteDispersionNomina;

    @Column(name = "limiteDispersionEmpleado", precision = 18, scale = 2)
    private BigDecimal limiteDispersionEmpleado;

    @Column(name = "limiteDispersionDiario", precision = 18, scale = 2)
    private BigDecimal limiteDispersionDiario;

    @Column(name = "requiereDobleAutorizacion")
    private boolean requiereDobleAutorizacion;

    @Column(name = "montoUmbralAutorizacion", precision = 18, scale = 2)
    private BigDecimal montoUmbralAutorizacion;

    @Enumerated(EnumType.STRING)
    @Column(name = "estadoEmpresa", nullable = false, length = 24)
    private EstadoEmpresa estadoEmpresa = EstadoEmpresa.ACTIVA;

    /** Referencia al cliente en el core bancario (DATO-REQUERIDO en prod). */
    @Column(name = "idClienteCore")
    private String idClienteCore;

    protected Empresa() {
    }

    /** RN-09 · una empresa BLOQUEADA o SUSPENDIDA_PLDFT no puede instruir dispersiones. */
    public boolean puedeDispersar() {
        return estadoEmpresa == EstadoEmpresa.ACTIVA;
    }

    /** RN-06 · la dispersion requiere doble autorizacion si el monto alcanza el umbral. */
    public boolean requiereDobleAutorizacion(BigDecimal montoTotal) {
        return requiereDobleAutorizacion
                && montoUmbralAutorizacion != null
                && montoTotal.compareTo(montoUmbralAutorizacion) >= 0;
    }

    public UUID getIdEmpresa() {
        return idEmpresa;
    }

    public void setIdEmpresa(UUID idEmpresa) {
        this.idEmpresa = idEmpresa;
    }

    public String getRfcEmpresa() {
        return rfcEmpresa;
    }

    public String getRazonSocial() {
        return razonSocial;
    }

    public String getClabeOrigen() {
        return clabeOrigen;
    }

    public String getNumeroCuenta() {
        return numeroCuenta;
    }

    public BigDecimal getLimiteDispersionNomina() {
        return limiteDispersionNomina;
    }

    public BigDecimal getLimiteDispersionEmpleado() {
        return limiteDispersionEmpleado;
    }

    public BigDecimal getLimiteDispersionDiario() {
        return limiteDispersionDiario;
    }

    public BigDecimal getMontoUmbralAutorizacion() {
        return montoUmbralAutorizacion;
    }

    public EstadoEmpresa getEstadoEmpresa() {
        return estadoEmpresa;
    }

    public void setEstadoEmpresa(EstadoEmpresa estadoEmpresa) {
        this.estadoEmpresa = estadoEmpresa;
    }

    public String getIdClienteCore() {
        return idClienteCore;
    }
}
