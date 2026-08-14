package mx.scotiabank.nomina.empleado;

import mx.scotiabank.nomina.common.MaskingUtil;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoResponse;
import mx.scotiabank.nomina.usuario.Rol;

/**
 * Mapea la entidad Empleado a su representacion de API, aplicando el enmascarado
 * PCI/PII segun el rol del solicitante (TC-EMP-010).
 */
public final class EmpleadoMapper {

    private EmpleadoMapper() {
    }

    public static EmpleadoResponse toResponse(Empleado e, Rol rol) {
        boolean privilegiado = rol == Rol.ADMIN_EMPRESA || rol == Rol.ADMIN_SCO;
        return new EmpleadoResponse(
                e.getIdEmpleado().toString(),
                e.getNumeroEmpleado(),
                e.nombreCompleto(),
                // PII/PCI: los roles no privilegiados siempre ven el valor enmascarado.
                privilegiado ? e.getRfc() : MaskingUtil.maskRfc(e.getRfc()),
                privilegiado ? e.getCurp() : MaskingUtil.maskCurp(e.getCurp()),
                MaskingUtil.maskClabe(e.getClabe()),
                MaskingUtil.maskTarjeta(e.getNumeroTarjeta()),
                e.getEstadoCuenta(),
                e.getIdCentroTrabajo() == null ? null : e.getIdCentroTrabajo().toString());
    }
}
