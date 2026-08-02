package mx.scotiabank.nomina.common.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;
import static java.lang.annotation.ElementType.FIELD;
import static java.lang.annotation.ElementType.PARAMETER;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

/**
 * RN-01 · Valida la estructura SAT del RFC (persona fisica 13 · persona moral 12).
 * Patron identico al del OpenAPI: {@code ^[A-ZN&]{3,4}\d{6}[A-Z0-9]{3}$}.
 */
@Documented
@Constraint(validatedBy = RfcValidator.class)
@Target({FIELD, PARAMETER})
@Retention(RUNTIME)
public @interface Rfc {
    String message() default "RFC invalido; no cumple la estructura SAT";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
