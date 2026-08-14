package mx.scotiabank.nomina.empleado;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.time.LocalDate;
import java.util.Set;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoCreate;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * TC-EMP-002 · Alta de empleado con RFC de estructura invalida (NP-020 · RN-01).
 * La violacion de Bean Validation la traduce {@code GlobalExceptionHandler} a
 * HTTP 400 con {@code errors[].campo = rfc}. Aqui se verifica a nivel de
 * validador (nivel Unit del test-strategy).
 *
 * <p>Incluye tambien TC-EMP-004 (RFC estructuralmente valido pasa la validacion).
 */
class EmpleadoRfcValidationTest {

    private static ValidatorFactory factory;
    private static Validator validator;

    @BeforeAll
    static void setUp() {
        factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @AfterAll
    static void tearDown() {
        factory.close();
    }

    private EmpleadoCreate withRfc(String rfc) {
        return new EmpleadoCreate(
                "E-00123", "Maria", "Lopez", "Garcia",
                rfc, "LOGM900101MDFPRR03", "FEMENINO", "MEXICANA", "SOLTERO",
                LocalDate.of(2026, 1, 15), "18500.00", "5f1c-ct-01");
    }

    @Test
    @DisplayName("TC-EMP-002 · RFC con estructura invalida produce violacion en campo 'rfc' (-> 400)")
    void rfcInvalido() {
        // RFC demasiado corto / mal formado.
        Set<ConstraintViolation<EmpleadoCreate>> violations = validator.validate(withRfc("XXX"));
        assertThat(violations)
                .anyMatch(v -> v.getPropertyPath().toString().equals("rfc"));
    }

    @Test
    @DisplayName("TC-EMP-004 · RFC con estructura valida no produce violacion en 'rfc'")
    void rfcValido() {
        Set<ConstraintViolation<EmpleadoCreate>> violations = validator.validate(withRfc("LOGM900101ABC"));
        assertThat(violations)
                .noneMatch(v -> v.getPropertyPath().toString().equals("rfc"));
    }
}
