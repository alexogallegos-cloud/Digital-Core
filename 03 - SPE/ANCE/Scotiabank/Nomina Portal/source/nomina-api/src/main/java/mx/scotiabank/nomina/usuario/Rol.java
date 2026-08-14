package mx.scotiabank.nomina.usuario;

/**
 * Roles del portal (spec §3). El modelo de autorizacion es identico en mock y
 * produccion; solo cambia el emisor de identidad (ADR-ANCE-004).
 */
public enum Rol {
    /** Configura la empresa, gestiona usuarios, define limites. */
    ADMIN_EMPRESA,
    /** Crea nomina, carga layout, instruye dispersion. */
    OPERADOR_NOMINA,
    /** Solo lectura: movimientos, CFDI, historial. */
    AUDITOR,
    /** Back-office Scotiabank: alta/bloqueo de empresas, limites globales, reportes CNBV. */
    ADMIN_SCO
}
