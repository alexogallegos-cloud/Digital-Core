package mx.scotiabank.nomina;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

/**
 * Nomina API · SPE-ANCE-002 · Portal Empresas Nomina Scotiabank Mexico.
 *
 * <p>Microservicio sincrono principal de la ruta critica (auth · empleados ·
 * nominas · dispersion · cfdi). Contract-first sobre
 * {@code api/openapi-nomina-portal.yaml}.
 *
 * <p>Virtual Threads (Project Loom) habilitados via
 * {@code spring.threads.virtual.enabled=true} — cada request corre en un hilo
 * virtual, ideal para el fan-out de I/O hacia el Core Banking Adapter y el SPEI
 * Adapter durante una dispersion masiva.
 */
@SpringBootApplication
@ConfigurationPropertiesScan
public class NominaApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(NominaApiApplication.class, args);
    }
}
