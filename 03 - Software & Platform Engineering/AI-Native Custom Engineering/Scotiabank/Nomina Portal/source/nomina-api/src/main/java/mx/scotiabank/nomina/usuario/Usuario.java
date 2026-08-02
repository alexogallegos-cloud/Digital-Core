package mx.scotiabank.nomina.usuario;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Usuario Â· operador del portal (spec Â§5). Tabla {@code Usuario}.
 *
 * <p>{@code passwordHash} solo existe en el mock (IAM propio). En prod la
 * identidad es federada (claim {@code subjectIdP}) y este campo queda nulo.
 */
@Entity
@Table(name = "Usuario")
public class Usuario {

    @Id
    @Column(name = "idUsuario", columnDefinition = "uniqueidentifier")
    private UUID idUsuario;

    @Column(name = "idEmpresa", columnDefinition = "uniqueidentifier")
    private UUID idEmpresa;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "nombre")
    private String nombre;

    @Enumerated(EnumType.STRING)
    @Column(name = "rol", nullable = false, length = 32)
    private Rol rol;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false, length = 16)
    private EstadoUsuario estado = EstadoUsuario.ACTIVO;

    /** Solo mock â€” BCrypt. En prod es null (SSO federado). NUNCA se serializa a la API. */
    @Column(name = "passwordHash")
    private String passwordHash;

    /** Solo prod â€” subject del IdP federado. */
    @Column(name = "subjectIdP")
    private String subjectIdP;

    @Column(name = "ultimoAcceso")
    private LocalDateTime ultimoAcceso;

    protected Usuario() {
    }

    public UUID getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(UUID idUsuario) {
        this.idUsuario = idUsuario;
    }

    public UUID getIdEmpresa() {
        return idEmpresa;
    }

    public void setIdEmpresa(UUID idEmpresa) {
        this.idEmpresa = idEmpresa;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol rol) {
        this.rol = rol;
    }

    public EstadoUsuario getEstado() {
        return estado;
    }

    public void setEstado(EstadoUsuario estado) {
        this.estado = estado;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getSubjectIdP() {
        return subjectIdP;
    }

    public void setSubjectIdP(String subjectIdP) {
        this.subjectIdP = subjectIdP;
    }

    public LocalDateTime getUltimoAcceso() {
        return ultimoAcceso;
    }

    public void setUltimoAcceso(LocalDateTime ultimoAcceso) {
        this.ultimoAcceso = ultimoAcceso;
    }
}

