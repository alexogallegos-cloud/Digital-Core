package mx.scotiabank.nomina.common.error;

import jakarta.validation.ConstraintViolationException;
import java.net.URI;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Traduce excepciones a {@code application/problem+json} conforme RFC 9457
 * (Problem Details, supersede RFC 7807). Envelope de error consistente exigido
 * por el estandar de contrato del portal.
 *
 * <p>Convencion de {@code type}: {@code https://api-nomina.scotiabank.com.mx/errors/{slug}}.
 * Las violaciones de regla de negocio incluyen la propiedad {@code code} (RN-xx)
 * y el arreglo {@code errors[]} con {campo, mensaje}.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final String TYPE_BASE = "https://api-nomina.scotiabank.com.mx/errors/";

    // --- 400 · validacion de formato (RFC/CURP/CLABE, campos requeridos) ------
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ProblemDetail> onBeanValidation(MethodArgumentNotValidException ex) {
        List<ApiFieldError> errors = ex.getBindingResult().getFieldErrors().stream()
                .map(GlobalExceptionHandler::toFieldError)
                .toList();
        ProblemDetail pd = base(HttpStatus.BAD_REQUEST, "validation",
                "Error de validacion", "Uno o mas campos no cumplen el contrato");
        pd.setProperty("errors", errors);
        return problem(pd);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ProblemDetail> onConstraintViolation(ConstraintViolationException ex) {
        List<ApiFieldError> errors = ex.getConstraintViolations().stream()
                .map(v -> new ApiFieldError(lastNode(v.getPropertyPath().toString()), v.getMessage()))
                .toList();
        ProblemDetail pd = base(HttpStatus.BAD_REQUEST, "validation",
                "Error de validacion", "Uno o mas parametros no cumplen el contrato");
        pd.setProperty("errors", errors);
        return problem(pd);
    }

    // --- 422 · regla de negocio (RN-xx) ---------------------------------------
    @ExceptionHandler(BusinessRuleException.class)
    public ResponseEntity<ProblemDetail> onBusinessRule(BusinessRuleException ex) {
        ProblemDetail pd = base(HttpStatus.UNPROCESSABLE_ENTITY, "business-rule",
                "Regla de negocio violada", ex.getMessage());
        pd.setProperty("code", ex.getCode());
        if (!ex.getErrors().isEmpty()) {
            pd.setProperty("errors", ex.getErrors());
        }
        return problem(pd);
    }

    // --- 409 · transicion de estado invalida ----------------------------------
    @ExceptionHandler(InvalidStateException.class)
    public ResponseEntity<ProblemDetail> onInvalidState(InvalidStateException ex) {
        ProblemDetail pd = base(HttpStatus.CONFLICT, "state-conflict",
                "Estado no valido para la operacion", ex.getMessage());
        return problem(pd);
    }

    // --- 404 ------------------------------------------------------------------
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ProblemDetail> onNotFound(ResourceNotFoundException ex) {
        ProblemDetail pd = base(HttpStatus.NOT_FOUND, "not-found",
                "Recurso no encontrado", ex.getMessage());
        return problem(pd);
    }

    // --- 403 · autorizacion (@PreAuthorize) -----------------------------------
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ProblemDetail> onAccessDenied(AccessDeniedException ex) {
        ProblemDetail pd = base(HttpStatus.FORBIDDEN, "forbidden",
                "Acceso denegado", "El rol no autoriza esta operacion");
        return problem(pd);
    }

    // --- 401 · credenciales invalidas (login / 2FA de sesion) -----------------
    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ProblemDetail> onAuthentication(AuthenticationException ex) {
        ProblemDetail pd = base(HttpStatus.UNAUTHORIZED, "unauthorized",
                "No autorizado", ex.getMessage());
        return problem(pd);
    }

    // --- 401 · 2FA de operacion invalido (RN-08) ------------------------------
    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<ProblemDetail> onSecurity(SecurityException ex) {
        ProblemDetail pd = base(HttpStatus.UNAUTHORIZED, "unauthorized",
                "Operacion no autorizada", ex.getMessage());
        pd.setProperty("code", "RN-08");
        return problem(pd);
    }

    // --- 400 · argumento ilegal (p.ej. Money mal formado) ---------------------
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ProblemDetail> onIllegalArgument(IllegalArgumentException ex) {
        ProblemDetail pd = base(HttpStatus.BAD_REQUEST, "validation",
                "Solicitud invalida", ex.getMessage());
        return problem(pd);
    }

    private static ApiFieldError toFieldError(FieldError fe) {
        return new ApiFieldError(fe.getField(), fe.getDefaultMessage());
    }

    private static String lastNode(String path) {
        int dot = path.lastIndexOf('.');
        return dot >= 0 ? path.substring(dot + 1) : path;
    }

    private static ProblemDetail base(HttpStatus status, String slug, String title, String detail) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(status, detail);
        pd.setType(URI.create(TYPE_BASE + slug));
        pd.setTitle(title);
        return pd;
    }

    private static ResponseEntity<ProblemDetail> problem(ProblemDetail pd) {
        // ProblemDetail ya se serializa como application/problem+json por Spring 6.
        return ResponseEntity.status(pd.getStatus()).body(pd);
    }
}
