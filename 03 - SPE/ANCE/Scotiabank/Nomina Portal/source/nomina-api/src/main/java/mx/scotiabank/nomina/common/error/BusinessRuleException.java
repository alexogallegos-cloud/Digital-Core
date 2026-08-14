package mx.scotiabank.nomina.common.error;

import java.util.List;

/**
 * Violacion de una regla de negocio (RN-01..RN-12 del spec §13). Se mapea a
 * HTTP 422 con {@code application/problem+json} y el campo {@code code = RN-xx}.
 */
public class BusinessRuleException extends RuntimeException {

    /** Codigo de regla de negocio, p.ej. "RN-05". */
    private final String code;
    private final transient List<ApiFieldError> errors;

    public BusinessRuleException(String code, String detail) {
        this(code, detail, List.of());
    }

    public BusinessRuleException(String code, String detail, List<ApiFieldError> errors) {
        super(detail);
        this.code = code;
        this.errors = errors == null ? List.of() : List.copyOf(errors);
    }

    public String getCode() {
        return code;
    }

    public List<ApiFieldError> getErrors() {
        return errors;
    }
}
