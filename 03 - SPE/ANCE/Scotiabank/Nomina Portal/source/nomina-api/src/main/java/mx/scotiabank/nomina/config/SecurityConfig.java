package mx.scotiabank.nomina.config;

import java.nio.charset.StandardCharsets;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import mx.scotiabank.nomina.auth.JwtProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Configuracion de seguridad del portal · IAM propio del mock (ADR-ANCE-004).
 *
 * <p><b>Estrategia de abstraccion (clave para migrar a prod sin tocar codigo):</b>
 * el portal valida los JWT a traves del contrato {@link JwtDecoder} de Spring
 * Security. En el mock ese bean es un {@link NimbusJwtDecoder} HS256 respaldado
 * por el secreto compartido con {@code JwtIssuer}. En produccion, para migrar a
 * <b>OIDC / SSO federado contra el IdP Scotiabank</b>, se elimina el bean HS256 y
 * se declara por configuracion:
 * <pre>
 *   spring.security.oauth2.resourceserver.jwt.issuer-uri: https://idp.scotiabank.com.mx/...
 * </pre>
 * Spring Boot autoconfigura entonces un {@code JwtDecoder} contra el JWKS del IdP.
 * <b>Ni los controllers ni las reglas {@code @PreAuthorize} cambian</b> — solo el
 * emisor de identidad. El modelo de roles es identico en mock y prod.
 *
 * <p>La autorizacion por rol se aplica con {@code @PreAuthorize} en los
 * controllers ({@link EnableMethodSecurity}). El claim {@code rol} del token se
 * mapea a la authority {@code ROLE_<rol>}.
 */
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    /** Clave de firma HS256 · SOLO mock. En prod la firma la posee el IdP (OIDC). */
    @Bean
    SecretKey jwtSigningKey(JwtProperties props) {
        byte[] secret = props.secret().getBytes(StandardCharsets.UTF_8);
        return new SecretKeySpec(secret, "HmacSHA256");
    }

    /**
     * JwtDecoder del mock (HS256). Punto de intercambio hacia OIDC en produccion.
     */
    @Bean
    JwtDecoder jwtDecoder(SecretKey jwtSigningKey) {
        return NimbusJwtDecoder.withSecretKey(jwtSigningKey).build();
    }

    /** Mapea el claim {@code rol} -> authority {@code ROLE_<rol>}. */
    @Bean
    JwtAuthenticationConverter jwtAuthenticationConverter() {
        JwtGrantedAuthoritiesConverter authorities = new JwtGrantedAuthoritiesConverter();
        authorities.setAuthorityPrefix("ROLE_");
        authorities.setAuthoritiesClaimName("rol");
        JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(authorities);
        return converter;
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http,
                                    JwtAuthenticationConverter jwtAuthConverter) throws Exception {
        http
                // API stateless: sin sesion de servidor, JWT en cada request.
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // CSRF no aplica a una API stateless con Bearer token.
                .csrf(csrf -> csrf.disable())
                .cors(Customizer.withDefaults())
                .authorizeHttpRequests(auth -> auth
                        // Endpoints publicos (auth + doc + health).
                        .requestMatchers(HttpMethod.POST, "/api/v1/auth/login", "/api/v1/auth/2fa/verify").permitAll()
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers("/actuator/health/**", "/actuator/info").permitAll()
                        // Todo lo demas requiere JWT valido; el rol se afina con @PreAuthorize.
                        .anyRequest().authenticated())
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthConverter)))
                // Headers de seguridad (X-Frame-Options relevante por el embebido en el portal).
                .headers(headers -> headers
                        .frameOptions(frame -> frame.sameOrigin())
                        .httpStrictTransportSecurity(hsts -> hsts.includeSubDomains(true)));
        return http.build();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        // En mock permitimos el origen local del frontend Angular. En prod se restringe
        // al dominio del Portal Empresa (config por ambiente · 12-factor).
        var source = new UrlBasedCorsConfigurationSource();
        var config = new org.springframework.web.cors.CorsConfiguration();
        config.setAllowedOrigins(java.util.List.of("http://localhost:4200", "http://localhost:4201"));
        config.setAllowedMethods(java.util.List.of("GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(java.util.List.of("*"));
        config.setAllowCredentials(true);
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
