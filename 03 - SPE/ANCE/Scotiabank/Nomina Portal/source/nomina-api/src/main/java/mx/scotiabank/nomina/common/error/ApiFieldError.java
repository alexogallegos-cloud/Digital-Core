package mx.scotiabank.nomina.common.error;

/**
 * Error a nivel de campo dentro del arreglo {@code errors[]} de un ProblemDetails
 * (RFC 9457). Coincide con el schema del OpenAPI: {@code {campo, mensaje}}.
 */
public record ApiFieldError(String campo, String mensaje) {
}
