package com.openpay.shared;

/**
 * [PLANTADO · SINK] El "sistema de registro" de escritura.
 *
 * Es el sumidero de escritura del analisis CQRS (ground-truth-access-classification.md):
 * cualquier clase cuyo CIERRE de llamadas alcanza este gateway se clasifica como
 * de ACTUALIZACION (update). Las que solo alcanzan JdbcReadGateway son de CONSULTA
 * (read-only) → wave temprana de bajo riesgo (CQRS read-model, replica, cache).
 *
 * En un sistema real el "writer" no es un solo objeto: hay JdbcTemplate.update(),
 * EntityManager.persist(), mappers MyBatis, puts a colas. El discovery debe rastrear
 * TODOS los sumideros de escritura, no uno (ver [OBSERVACION] del answer key).
 */
public final class JdbcWriteGateway {

    private JdbcWriteGateway() {}

    /** Persiste en el sistema de registro (MySQL Aurora · tablas transaccionales). */
    public static void persist(AuditContext ctx) {
        // INSERT/UPDATE sobre las tablas de negocio (~920 tablas en el monolito real).
        // Punto unico que marca a toda la cadena de llamada como 'update'.
    }
}