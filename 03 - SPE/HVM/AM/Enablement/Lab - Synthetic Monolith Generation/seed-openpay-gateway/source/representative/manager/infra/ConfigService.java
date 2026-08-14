package com.openpay.manager.infra;

import com.openpay.dto.ResponseEnvelope;
import com.openpay.shared.AuditContext;
import com.openpay.shared.JdbcReadGateway;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * ENABLER in-scope (seam) · component=Manager · domain=infra · access=READ.
 * Blast radius objetivo = 68 (ground-truth-enabler-seams.md) ↔ regression_scope
 * del fanout (config-management-sys, wave 4, seam cdc-read-only).
 *
 * Parametria global del gateway: tasas, limites, feature flags, catalogos. Llamado
 * por ~68 clases de TODOS los dominios → es un SPOF de lectura. Por eso va en wave 4
 * (mayor blast radius) y se extrae con estrategia cdc-read-only: se replica su tabla
 * por CDC y los consumidores leen de la replica, sin cutover de escritura arriesgado.
 *
 * Anti-patrones plantados:
 *  - Cache estatico mutable (ConcurrentHashMap estatico) → estado global escondido.
 *  - Fan-in masivo cross-domain → no hay forma de tocarlo sin un dual-run largo.
 */
@Service
public class ConfigService {

    // [PLANTADO] cache global estatico — estado compartido invisible en el call graph
    private static final Map<String, String> CACHE = new ConcurrentHashMap<>();

    /** Lectura de parametro (read-only: nunca alcanza un writer → access=read). */
    public String get(String key, AuditContext ctx) {
        String v = CACHE.get(key);
        if (v == null) {
            v = JdbcReadGateway.query(ctx);   // [SINK-READ] -> clasifica como 'read'
            CACHE.put(key, v);
        }
        return v;
    }

    public ResponseEnvelope reload(AuditContext ctx) {
        CACHE.clear();
        return ResponseEnvelope.ok("config-cache-cleared");
    }
}