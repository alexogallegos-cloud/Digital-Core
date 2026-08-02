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
 * RN-03 · Valida CLABE: 18 digitos y digito verificador (modulo 10 con pesos
 * 3-7-1 · Banxico).
 */
@Documented
@Constraint(validatedBy = ClabeValidator.class)
@Target({FIELD, PARAMETER})
@Retention(RUNTIME)
public @interface Clabe {
    String message() default "CLABE invalida (18 digitos + digito verificador)";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
