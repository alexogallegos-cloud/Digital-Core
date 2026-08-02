package mx.scotiabank.nomina.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.servers.Server;
import org.springframework.context.annotation.Configuration;

/**
 * Metadata OpenAPI del runtime (springdoc). El contrato fuente de verdad es
 * {@code api/openapi-nomina-portal.yaml} (contract-first); esta anotacion solo
 * asegura que Swagger UI del servicio expone el esquema Bearer coherente.
 */
@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "Portal Empresas Nomina API",
                version = "1.0.0",
                description = "API B2B de nomina bancaria · Scotiabank Mexico · SPE-ANCE-002",
                contact = @Contact(name = "Swarm SPE-ANCE-001 · dt-backend-engineer"),
                license = @License(name = "Internal — Accenture MX / Scotiabank Mexico")),
        servers = @Server(url = "/api/v1", description = "Base path (URI versioning)"))
@SecurityScheme(
        name = "BearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT")
public class OpenApiConfig {
}
