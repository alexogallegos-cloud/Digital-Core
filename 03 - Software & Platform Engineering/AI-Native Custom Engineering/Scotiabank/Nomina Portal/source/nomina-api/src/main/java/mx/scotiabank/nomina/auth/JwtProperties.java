package mx.scotiabank.nomina.auth;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Propiedades del IAM propio del mock (prefijo {@code auth.jwt}).
 *
 * @param secret     secreto HS256 (>= 32 bytes). Solo mock — en prod NO existe (OIDC).
 * @param issuer     claim {@code iss} del token.
 * @param ttlSeconds expiracion en segundos. Requisito de seguridad: <= 3600 (1h).
 */
@ConfigurationProperties(prefix = "auth.jwt")
public record JwtProperties(String secret, String issuer, long ttlSeconds) {

    public JwtProperties {
        if (ttlSeconds <= 0 || ttlSeconds > 3600) {
            // JWT bancario: expiracion <= 1h (dt-security-engineer · anti-patron explicito).
            throw new IllegalArgumentException("auth.jwt.ttl-seconds debe estar en (0, 3600]");
        }
    }
}
