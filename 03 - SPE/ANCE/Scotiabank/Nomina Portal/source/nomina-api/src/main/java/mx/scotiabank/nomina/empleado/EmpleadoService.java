package mx.scotiabank.nomina.empleado;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import mx.scotiabank.nomina.centrotrabajo.CentroTrabajoRepository;
import mx.scotiabank.nomina.common.MoneyMapper;
import mx.scotiabank.nomina.common.PageInfo;
import mx.scotiabank.nomina.common.error.ApiFieldError;
import mx.scotiabank.nomina.common.error.BusinessRuleException;
import mx.scotiabank.nomina.common.error.ResourceNotFoundException;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoCreate;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoPage;
import mx.scotiabank.nomina.empleado.dto.EmpleadoDtos.EmpleadoResponse;
import mx.scotiabank.nomina.integration.corebanking.CoreBankingClient;
import mx.scotiabank.nomina.integration.corebanking.dto.CuentaNomina;
import mx.scotiabank.nomina.usuario.Rol;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Logica de negocio de empleados (M4). Toda operacion se acota a la empresa del
 * solicitante. El alta dispara la apertura de cuenta nomina via el Core Banking
 * Adapter (ACL) — en el mock, un stub determinista.
 */
@Service
public class EmpleadoService {

    private final EmpleadoRepository empleados;
    private final CentroTrabajoRepository centros;
    private final CoreBankingClient coreBanking;

    public EmpleadoService(EmpleadoRepository empleados,
                           CentroTrabajoRepository centros,
                           CoreBankingClient coreBanking) {
        this.empleados = empleados;
        this.centros = centros;
        this.coreBanking = coreBanking;
    }

    @Transactional(readOnly = true)
    public EmpleadoPage list(UUID idEmpresa, EstadoCuentaEmpleado estadoCuenta,
                             String q, int limit, Rol rol) {
        var page = PageRequest.of(0, limit);
        List<EmpleadoResponse> data = empleados
                .search(idEmpresa, estadoCuenta, blankToNull(q), page).stream()
                .map(e -> EmpleadoMapper.toResponse(e, rol))
                .toList();
        long total = data.size();
        // Cursor opaco real lo entrega el modulo de paginacion; en el mock null = ultima pagina.
        return new EmpleadoPage(data, new PageInfo(null, total));
    }

    @Transactional(readOnly = true)
    public EmpleadoResponse get(UUID idEmpresa, UUID idEmpleado, Rol rol) {
        Empleado e = empleados.findByIdEmpleadoAndIdEmpresa(idEmpleado, idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Empleado no encontrado: " + idEmpleado));
        return EmpleadoMapper.toResponse(e, rol);
    }

    @Transactional
    public EmpleadoResponse create(UUID idEmpresa, EmpleadoCreate req, Rol rol) {
        UUID idCentro = UUID.fromString(req.idCentroTrabajo());
        if (!centros.existsByIdCentroTrabajoAndIdEmpresa(idCentro, idEmpresa)) {
            throw new BusinessRuleException("RN-EMP-CT",
                    "El centro de trabajo no pertenece a la empresa",
                    List.of(new ApiFieldError("idCentroTrabajo", "Centro de trabajo inexistente")));
        }
        if (empleados.existsByIdEmpresaAndNumeroEmpleado(idEmpresa, req.numeroEmpleado())) {
            throw new BusinessRuleException("RN-EMP-DUP",
                    "Ya existe un empleado con ese numero",
                    List.of(new ApiFieldError("numeroEmpleado", "Numero de empleado duplicado")));
        }

        BigDecimal ingreso = MoneyMapper.parse(req.ingresoMensualNeto());
        Empleado e = Empleado.nuevo(idEmpresa, idCentro, req.numeroEmpleado(),
                req.nombres(), req.primerApellido(), req.segundoApellido(),
                req.rfc(), req.curp(), req.genero(), req.nacionalidad(),
                req.estadoCivil(), req.fechaIngreso(), ingreso);

        // Solicita apertura de cuenta al core (ACL). El stub devuelve CLABE sintetica.
        CuentaNomina cuenta = coreBanking.abrirCuentaNomina(
                idEmpresa.toString(), e.getIdEmpleado().toString(), e.getRfc());
        e.vincularCuenta(cuenta.numeroCuenta(), cuenta.clabe());

        empleados.save(e);
        return EmpleadoMapper.toResponse(e, rol);
    }

    @Transactional
    public EmpleadoResponse baja(UUID idEmpresa, UUID idEmpleado, Rol rol) {
        Empleado e = empleados.findByIdEmpleadoAndIdEmpresa(idEmpleado, idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Empleado no encontrado: " + idEmpleado));
        // Baja logica: preserva historial de dispersiones (TC-EMP-011).
        e.darDeBaja();
        return EmpleadoMapper.toResponse(e, rol);
    }

    private static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s;
    }
}
