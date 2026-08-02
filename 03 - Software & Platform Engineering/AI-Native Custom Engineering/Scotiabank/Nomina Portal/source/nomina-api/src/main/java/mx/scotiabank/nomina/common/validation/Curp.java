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
 * RN-02 · Valida la estructura del CURP (18 caracteres).
 * Patron identico al del OpenAPI: {@code ^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]{2}$}.
 */
@Documented
@Constraint(validatedBy = CurpValidator.class)
@Target({FIELD, PARAMETER})
@Retention(RUNTIME)
public @interface Curp {
    String message() default "CURP invalido; no cumple la estructura";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
