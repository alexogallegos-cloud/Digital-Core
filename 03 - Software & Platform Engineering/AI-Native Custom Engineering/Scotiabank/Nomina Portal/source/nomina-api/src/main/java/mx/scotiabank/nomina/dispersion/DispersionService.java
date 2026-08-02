package mx.scotiabank.nomina.dispersion;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import mx.scotiabank.nomina.auth.TwoFactorService;
import mx.scotiabank.nomina.common.error.BusinessRuleException;
import mx.scotiabank.nomina.common.error.InvalidStateException;
import mx.scotiabank.nomina.common.error.ResourceNotFoundException;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.DispersionDetalleResponse;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.DispersionResponse;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.InstruirDispersionRequest;
import mx.scotiabank.nomina.empleado.Empleado;
import mx.scotiabank.nomina.empleado.EmpleadoRepository;
import mx.scotiabank.nomina.empresa.Empresa;
import mx.scotiabank.nomina.empresa.EmpresaRepository;
import mx.scotiabank.nomina.integration.corebanking.CoreBankingClient;
import mx.scotiabank.nomina.integration.corebanking.dto.CargoResultado;
import mx.scotiabank.nomina.integration.spei.SpeiGateway;
import mx.scotiabank.nomina.integration.spei.dto.SpeiResultado;
import mx.scotiabank.nomina.nomina.DetalleNomina;
import mx.scotiabank.nomina.nomina.DetalleNominaRepository;
import mx.scotiabank.nomina.nomina.Nomina;
import mx.scotiabank.nomina.nomina.NominaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Motor de dispersion (M6) — corazon regulatorio del portal. Orquesta la maquina
 * de estados de la nomina/dispersion (spec §6.2) y aplica las reglas RN-04..RN-09.
 *
 * <p>Reglas aplicadas al instruir:
 * <ul>
 *   <li>RN-08 · 2FA obligatorio antes de instruir.</li>
 *   <li>Estado dispersable (VALIDADA/AUTORIZADA) — si no, 409 (irreversibilidad §6.2).</li>
 *   <li>RN-09 · empresa BLOQUEADA/SUSPENDIDA_PLDFT no puede dispersar.</li>
 *   <li>RN-07 · solo empleados FINALIZADA/VINCULADA reciben dispersion.</li>
 *   <li>RN-04 · importe por empleado &gt; 0 y &le; limite por empleado.</li>
 *   <li>RN-05 · monto total &le; limite de nomina y &le; saldo cuenta origen.</li>
 *   <li>RN-06 · monto &ge; umbral con doble autorizacion -&gt; EN_AUTORIZACION.</li>
 * </ul>
 *
 * <p><b>PCI:</b> ningun metodo loguea CLABE ni importe en claro.
 */
@Service
public class DispersionService {

    private static final Logger log = LoggerFactory.getLogger(DispersionService.class);

    private final NominaRepository nominas;
    private final DetalleNominaRepository detalles;
    private final EmpleadoRepository empleados;
    private final EmpresaRepository empresas;
    private final DispersionRepository dispersiones;
    private final MovimientoDispersionRepository movimientos;
    private final CoreBankingClient coreBanking;
    private final SpeiGateway spei;
    private final TwoFactorService twoFactor;

    public DispersionService(NominaRepository nominas, DetalleNominaRepository detalles,
                             EmpleadoRepository empleados, EmpresaRepository empresas,
                             DispersionRepository dispersiones,
                             MovimientoDispersionRepository movimientos,
                             CoreBankingClient coreBanking, SpeiGateway spei,
                             TwoFactorService twoFactor) {
        this.nominas = nominas;
        this.detalles = detalles;
        this.empleados = empleados;
        this.empresas = empresas;
        this.dispersiones = dispersiones;
        this.movimientos = movimientos;
        this.coreBanking = coreBanking;
        this.spei = spei;
        this.twoFactor = twoFactor;
    }

    @Transactional
    public DispersionResponse instruir(UUID idEmpresa, UUID idNomina, InstruirDispersionRequest req,
                                       UUID idUsuario) {
        // RN-08 · 2FA obligatorio.
        twoFactor.requireValid(req.challengeId(), req.code());

        Nomina nomina = nominas.findByIdNominaAndIdEmpresa(idNomina, idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Nomina no encontrada: " + idNomina));

        // Estado dispersable (§6.2). Si ya esta DISPERSANDO/CONFIRMADA, es irreversible -> 409.
        if (!nomina.getEstado().permiteInstruirDispersion()) {
            throw new InvalidStateException(
                    "La nomina no esta en estado dispersable (actual: " + nomina.getEstado() + ")");
        }

        Empresa empresa = empresas.findById(idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Empresa no encontrada"));

        // RN-09 · empresa bloqueada/suspendida no puede dispersar.
        if (!empresa.puedeDispersar()) {
            throw new BusinessRuleException("RN-09",
                    "La empresa esta bloqueada o suspendida y no puede instruir dispersiones");
        }

        // Renglones dispersables: validos (RN-03/RN-04 ya aplicados en validar) y empleado elegible (RN-07).
        List<DetalleNomina> elegibles = new ArrayList<>();
        BigDecimal montoTotal = BigDecimal.ZERO;
        for (DetalleNomina d : detalles.findByIdNomina(idNomina)) {
            if (!d.esValido()) {
                continue;
            }
            Empleado emp = empleados.findByIdEmpleadoAndIdEmpresa(d.getIdEmpleado(), idEmpresa)
                    .orElse(null);
            // RN-07 · solo FINALIZADA/VINCULADA.
            if (emp == null || !emp.getEstadoCuenta().esDispersable()) {
                continue;
            }
            // RN-04 (defensivo) · importe > 0 y <= limite por empleado.
            if (empresa.getLimiteDispersionEmpleado() != null
                    && d.getImporte().compareTo(empresa.getLimiteDispersionEmpleado()) > 0) {
                throw new BusinessRuleException("RN-04",
                        "Un importe por empleado excede el limite de la empresa");
            }
            elegibles.add(d);
            montoTotal = montoTotal.add(d.getImporte());
        }

        // RN-05 · monto total <= limite de nomina.
        if (empresa.getLimiteDispersionNomina() != null
                && montoTotal.compareTo(empresa.getLimiteDispersionNomina()) > 0) {
            throw new BusinessRuleException("RN-05",
                    "El monto total excede el limite de dispersion de la empresa");
        }

        // RN-05 · saldo suficiente en cuenta origen (consulta al core · ACL).
        BigDecimal saldo = coreBanking.consultarSaldo(empresa.getClabeOrigen()).disponible();
        if (saldo.compareTo(montoTotal) < 0) {
            throw new BusinessRuleException("RN-05",
                    "Saldo insuficiente en la cuenta origen para dispersar la nomina");
        }

        // RN-06 · doble autorizacion si el monto alcanza el umbral -> EN_AUTORIZACION (segunda firma).
        if (empresa.requiereDobleAutorizacion(montoTotal)) {
            nomina.marcarEnAutorizacion();
            Dispersion pendiente = Dispersion.instruir(idNomina, idUsuario, montoTotal);
            // Aun no procesa: queda pendiente de la segunda firma.
            dispersiones.save(pendiente);
            log.info("Dispersion {} requiere doble autorizacion (RN-06); nomina {} en EN_AUTORIZACION",
                    pendiente.getReferenciaInterna(), idNomina);
            return DispersionMapper.toResponse(pendiente);
        }

        // --- Ejecucion (irreversible): fondea la cuenta origen y dispersa por SPEI ---
        String refInterna = "DISP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        CargoResultado cargo = coreBanking.instruirCargo(empresa.getClabeOrigen(), montoTotal, refInterna);
        if (!cargo.aplicado()) {
            throw new BusinessRuleException("RN-05",
                    "No se pudo comprometer los fondos en la cuenta origen");
        }

        nomina.marcarDispersando();
        Dispersion dispersion = Dispersion.instruir(idNomina, idUsuario, montoTotal);
        dispersiones.save(dispersion);

        boolean todosConfirmados = true;
        for (DetalleNomina d : elegibles) {
            MovimientoDispersion mov = MovimientoDispersion.enviado(
                    dispersion.getIdDispersion(), d.getIdEmpleado(), d.getImporte(), d.getClabeDestino());
            // Instruye el pago SPEI por renglon (fan-out sobre Virtual Threads en el adapter).
            SpeiResultado res = spei.instruirPago(
                    d.getClabeDestino(), d.getImporte(), dispersion.getReferenciaInterna());
            if (res.confirmado()) {
                mov.confirmar(res.claveRastreo());
            } else {
                mov.rechazar(res.codigoRechazoBanxico());
                todosConfirmados = false;
            }
            movimientos.save(mov);
        }

        // Resuelve el estado agregado (§6.2): CONFIRMADA o RECHAZADA_PARCIAL.
        dispersion.resolver(todosConfirmados);
        nomina.resolverDispersion(todosConfirmados);
        log.info("Dispersion {} resuelta: {} ({} renglones)",
                dispersion.getReferenciaInterna(), dispersion.getEstado(), elegibles.size());
        return DispersionMapper.toResponse(dispersion);
    }

    @Transactional(readOnly = true)
    public DispersionDetalleResponse estado(UUID idDispersion) {
        Dispersion d = dispersiones.findById(idDispersion)
                .orElseThrow(() -> new ResourceNotFoundException("Dispersion no encontrada: " + idDispersion));
        return DispersionMapper.toDetalle(d, movimientos.findByIdDispersion(idDispersion));
    }
}
