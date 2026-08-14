package mx.scotiabank.nomina.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.util.regex.Pattern;

/**
 * RN-01 · Validador de estructura RFC (SAT). Regex canonico del contrato OpenAPI.
 *
 * <p>Nota: la validacion de homoclave (digito verificador del RFC) es un algoritmo
 * adicional que se puede incorporar aqui (TC-EMP-004) sin cambiar la firma del
 * validador; el mock valida estructura, suficiente para TC-EMP-002/003.
 */
public class RfcValidator implements ConstraintValidator<Rfc, String> {

    /** ^[A-ZN&]{3,4}\d{6}[A-Z0-9]{3}$ — incluye la N con virgulilla del contrato. */
    private static final Pattern RFC_PATTERN =
            Pattern.compile("^[A-ZÑ&]{3,4}\\d{6}[A-Z0-9]{3}$");

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null || value.isBlank()) {
            return false;
        }
        return RFC_PATTERN.matcher(value).matches();
    }
}
