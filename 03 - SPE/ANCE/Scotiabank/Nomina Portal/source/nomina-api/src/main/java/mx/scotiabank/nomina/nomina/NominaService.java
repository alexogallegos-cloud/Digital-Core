package mx.scotiabank.nomina.nomina;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import mx.scotiabank.nomina.common.MoneyMapper;
import mx.scotiabank.nomina.common.error.BusinessRuleException;
import mx.scotiabank.nomina.common.error.ResourceNotFoundException;
import mx.scotiabank.nomina.common.validation.ClabeValidator;
import mx.scotiabank.nomina.empresa.Empresa;
import mx.scotiabank.nomina.empresa.EmpresaRepository;
import mx.scotiabank.nomina.integration.corebanking.CoreBankingClient;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.FilaError;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.NominaCreate;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.NominaResponse;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.ResumenNomina;
import mx.scotiabank.nomina.nomina.dto.NominaDtos.ValidacionNomina;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Logica de negocio de nomina (M6): creacion de cabecera, carga y validacion de
 * layout, y resumen previo a dispersar. Aplica las reglas RN-03, RN-04 y RN-05
 * durante la validacion del layout.
 */
@Service
public class NominaService {

    private final NominaRepository nominas;
    private final DetalleNominaRepository detalles;
    private final EmpresaRepository empresas;
    private final CoreBankingClient coreBanking;

    public NominaService(NominaRepository nominas, DetalleNominaRepository detalles,
                         EmpresaRepository empresas, CoreBankingClient coreBanking) {
        this.nominas = nominas;
        this.detalles = detalles;
        this.empresas = empresas;
        this.coreBanking = coreBanking;
    }

    @Transactional
    public NominaResponse create(UUID idEmpresa, NominaCreate req) {
        if (req.periodoFin().isBefore(req.periodoInicio())) {
            throw new BusinessRuleException("RN-NOM-PERIODO",
                    "periodoFin no puede ser anterior a periodoInicio");
        }
        Nomina n = Nomina.crear(idEmpresa, req.tipo(), req.periodoInicio(),
                req.periodoFin(), req.descripcion());
        nominas.save(n);
        return toResponse(n);
    }

    /**
     * Carga el layout con los importes por empleado. En el mock, el parser real
     * del archivo lo cubre una story dedicada; aqui se persisten los renglones ya
     * parseados y se totaliza. Transiciona la nomina a LAYOUT_CARGADO.
     */
    @Transactional
    public NominaResponse cargarLayout(UUID idEmpresa, UUID idNomina, List<DetalleNomina> renglones) {
        Nomina n = find(idEmpresa, idNomina);
        detalles.deleteByIdNomina(idNomina);
        BigDecimal total = BigDecimal.ZERO;
        for (DetalleNomina d : renglones) {
            detalles.save(d);
            total = total.add(d.getImporte());
        }
        n.marcarLayoutCargado(total, renglones.size());
        return toResponse(n);
    }

    /**
     * Valida el layout (RN-03 CLABE · RN-04 limite por empleado) y devuelve el
     * detalle de errores por fila. Solo si no hay errores la nomina pasa a VALIDADA.
     */
    @Transactional
    public ValidacionNomina validar(UUID idEmpresa, UUID idNomina) {
        Nomina n = find(idEmpresa, idNomina);
        Empresa empresa = empresas.findById(idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Empresa no encontrada"));
        BigDecimal limiteEmpleado = empresa.getLimiteDispersionEmpleado();

        List<DetalleNomina> renglones = detalles.findByIdNomina(idNomina);
        List<FilaError> errores = new ArrayList<>();
        int fila = 0;
        int validos = 0;
        for (DetalleNomina d : renglones) {
            fila++;
            // RN-03 · CLABE con digito verificador valido.
            if (!ClabeValidator.isValidClabe(d.getClabeDestino())) {
                d.marcarError("CLABE invalida (digito verificador)");
                errores.add(new FilaError(fila, "clabeDestino", "CLABE invalida (digito verificador)"));
                continue;
            }
            // RN-04 · importe > 0 y <= limite por empleado.
            if (d.getImporte() == null || d.getImporte().signum() <= 0) {
                d.marcarError("Importe debe ser mayor a cero");
                errores.add(new FilaError(fila, "importe", "Importe debe ser mayor a cero"));
                continue;
            }
            if (limiteEmpleado != null && d.getImporte().compareTo(limiteEmpleado) > 0) {
                d.marcarError("Importe excede limite por empleado");
                errores.add(new FilaError(fila, "importe", "Importe excede limite por empleado"));
                continue;
            }
            validos++;
        }

        if (errores.isEmpty()) {
            n.marcarValidada();
        }
        return new ValidacionNomina(n.getEstado(), renglones.size(), validos, errores);
    }

    /**
     * Resumen previo a dispersar: total, empleados, saldo disponible en la cuenta
     * origen y si los fondos son suficientes (insumo de RN-05).
     */
    @Transactional(readOnly = true)
    public ResumenNomina resumen(UUID idEmpresa, UUID idNomina) {
        Nomina n = find(idEmpresa, idNomina);
        Empresa empresa = empresas.findById(idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Empresa no encontrada"));
        BigDecimal saldo = coreBanking.consultarSaldo(empresa.getClabeOrigen()).disponible();
        boolean suficientes = saldo.compareTo(n.getMontoTotal()) >= 0;
        return new ResumenNomina(
                n.getIdNomina().toString(),
                n.getTotalEmpleados(),
                MoneyMapper.toApi(n.getMontoTotal()),
                MoneyMapper.toApi(saldo),
                suficientes);
    }

    Nomina find(UUID idEmpresa, UUID idNomina) {
        return nominas.findByIdNominaAndIdEmpresa(idNomina, idEmpresa)
                .orElseThrow(() -> new ResourceNotFoundException("Nomina no encontrada: " + idNomina));
    }

    static NominaResponse toResponse(Nomina n) {
        return new NominaResponse(
                n.getIdNomina().toString(),
                n.getTipo(),
                n.getPeriodoInicio(),
                n.getPeriodoFin(),
                n.getEstado(),
                MoneyMapper.toApi(n.getMontoTotal()),
                n.getTotalEmpleados());
    }
}
