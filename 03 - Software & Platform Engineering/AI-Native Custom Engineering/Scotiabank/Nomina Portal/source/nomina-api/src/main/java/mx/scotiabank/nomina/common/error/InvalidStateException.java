package mx.scotiabank.nomina.common.error;

/**
 * Transicion no permitida por la maquina de estados (spec §6). Se mapea a
 * HTTP 409 Conflict — p.ej. instruir dispersion de una nomina que no esta en
 * estado VALIDADA/AUTORIZADA.
 */
public class InvalidStateException extends RuntimeException {
    public InvalidStateException(String detail) {
        super(detail);
    }
}
