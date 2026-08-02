package mx.scotiabank.nomina.auth;

import io.jsonwebtoken.Jwts;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;
import javax.crypto.SecretKey;
import mx.scotiabank.nomina.usuario.Rol;
import org.springframework.stereotype.Component;

/**
 * Emisor del JWT propio del mock (HS256), firmado con el secreto de
 * {@code auth.jwt.secret}.
 *
 * <p><b>ADR-ANCE-004:</b> este emisor SOLO existe en el mock. En produccion la
 * emision la hace el IdP Scotiabank via OIDC; este componente desaparece y el
 * {@code JwtDecoder} de {@link SecurityConfig} se apunta al issuer-uri. Nada mas
 * cambia — los controllers y el {@code @PreAuthorize} son identicos.
 */
@Component
public class JwtIssuer {

    private final SecretKey key;
    private final String issuer;
    private final long ttlSeconds;

    public JwtIssuer(SecretKey jwtSigningKey, JwtProperties props) {
        this.key = jwtSigningKey;
        this.issuer = props.issuer();
        this.ttlSeconds = props.ttlSeconds();
    }

    /** Token emitido para una sesion. El claim {@code rol} alimenta las authorities. */
    public IssuedToken issue(UUID idUsuario, UUID idEmpresa, String email, Rol rol) {
        Instant now = Instant.now();
        Instant exp = now.plusSeconds(ttlSeconds);
        String jwt = Jwts.builder()
                .issuer(issuer)
                .subject(idUsuario.toString())
                .claim("email", email)
                .claim("empresaId", idEmpresa == null ? null : idEmpresa.toString())
                .claim("rol", rol.name())
                .id(UUID.randomUUID().toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(key, Jwts.SIG.HS256)
                .compact();
        return new IssuedToken(jwt, ttlSeconds, rol);
    }

    /** Resultado de la emision. */
    public record IssuedToken(String accessToken, long expiresIn, Rol rol) {
    }
}
