package mx.scotiabank.nomina.common;

import java.util.UUID;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

/**
 * Acceso tipado al principal autenticado (claims del JWT). Aisla del emisor
 * concreto (mock HS256 u OIDC prod) — los claims {@code sub}, {@code empresaId} y
 * {@code rol} tienen el mismo contrato en ambos.
 *
 * <p>El scoping multi-tenant (toda consulta se acota a {@code empresaId}) parte de
 * aqui: nunca se confia en un {@code empresaId} recibido en el body.
 */
public final class CurrentUser {

    private CurrentUser() {
    }

    private static Jwt jwt() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof Jwt j) {
            return j;
        }
        throw new IllegalStateException("No hay JWT en el contexto de seguridad");
    }

    public static UUID idUsuario() {
        return UUID.fromString(jwt().getSubject());
    }

    /** Empresa del usuario. Null solo para ADMIN_SCO (usuario interno del banco). */
    public static UUID idEmpresa() {
        String v = jwt().getClaimAsString("empresaId");
        return v == null ? null : UUID.fromString(v);
    }

    public static String rol() {
        return jwt().getClaimAsString("rol");
    }
}
