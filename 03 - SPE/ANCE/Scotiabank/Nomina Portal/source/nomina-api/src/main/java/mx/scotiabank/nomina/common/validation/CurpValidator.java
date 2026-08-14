package mx.scotiabank.nomina.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.regex.Pattern;

/** RN-02 · Validador de estructura CURP. Regex canonico del contrato OpenAPI. */
public class CurpValidator implements ConstraintValidator<Curp, String> {

    private static final Pattern CURP_PATTERN =
            Pattern.compile("^[A-Z]{4}\\d{6}[HM][A-Z]{5}[A-Z0-9]{2}$");

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.isBlank()) {
            return false;
        }
        return CURP_PATTERN.matcher(value).matches();
    }
}
