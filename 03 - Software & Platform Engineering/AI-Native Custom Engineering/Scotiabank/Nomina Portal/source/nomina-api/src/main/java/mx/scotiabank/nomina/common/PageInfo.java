package mx.scotiabank.nomina.common;

/**
 * Metadata de paginacion cursor (schema {@code PageInfo} del OpenAPI).
 *
 * @param nextCursor cursor opaco para la siguiente pagina; null si es la ultima
 * @param total      total de elementos que satisfacen el filtro
 */
public record PageInfo(String nextCursor, long total) {
}
