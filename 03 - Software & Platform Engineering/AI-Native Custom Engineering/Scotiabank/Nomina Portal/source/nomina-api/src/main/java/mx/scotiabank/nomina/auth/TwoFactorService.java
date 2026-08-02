package mx.scotiabank.nomina.auth;

import org.springframework.stereotype.Service;

/**
 * Verificacion de segundo factor para operaciones de escritura critica (RN-08:
 * alta de empleado, configuracion de limites, instruccion de dispersion).
 *
 * <p>En el mock el codigo aceptado es fijo ({@link AuthService#MOCK_2FA_CODE}). La
 * interfaz queda declarada para conectar el mecanismo real de 2FA en produccion
 * (DATO-REQUERIDO · dt-security-engineer).
 */
@Service
public class TwoFactorService {

    /**
     * Valida el 2FA de una operacion. Lanza {@link SecurityException} si el
     * challenge/codigo no son validos — que el llamador traduce a rechazo de la
     * operacion (RN-08).
     */
    public void requireValid(String challengeId, String code) {
        boolean ok = challengeId != null && !challengeId.isBlank()
                && AuthService.MOCK_2FA_CODE.equals(code);
        if (!ok) {
            throw new SecurityException("2FA invalido para la operacion (RN-08)");
        }
    }
}
