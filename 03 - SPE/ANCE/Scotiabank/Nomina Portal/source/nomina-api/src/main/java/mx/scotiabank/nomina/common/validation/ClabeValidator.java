package mx.scotiabank.nomina.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

/**
 * RN-03 · Validador de CLABE (Clave Bancaria Estandarizada, 18 digitos).
 *
 * <p>Algoritmo Banxico: se ponderan los primeros 17 digitos con los pesos
 * 3, 7, 1 (ciclicos), a cada producto se le toma el modulo 10, se suman, y el
 * digito verificador esperado es {@code (10 - (sum % 10)) % 10}.
 */
public class ClabeValidator implements ConstraintValidator<Clabe, String> {

    private static final int[] PESOS = {3, 7, 1};

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        return isValidClabe(value);
    }

    /** Reutilizable desde la validacion de layout de nomina (fila por fila). */
    public static boolean isValidClabe(String clabe) {
        if (clabe == null || !clabe.matches("^\\d{18}$")) {
            return false;
        }
        int suma = 0;
        for (int i = 0; i < 17; i++) {
            int digito = clabe.charAt(i) - '0';
            suma += (digito * PESOS[i % 3]) % 10;
        }
        int verificadorEsperado = (10 - (suma % 10)) % 10;
        int verificadorReal = clabe.charAt(17) - '0';
        return verificadorEsperado == verificadorReal;
    }
}
