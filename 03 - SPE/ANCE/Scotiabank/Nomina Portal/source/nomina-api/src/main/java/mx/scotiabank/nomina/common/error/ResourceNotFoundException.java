package mx.scotiabank.nomina.common.error;

/** Recurso no encontrado -> HTTP 404 (application/problem+json). */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String detail) {
        super(detail);
    }
}
