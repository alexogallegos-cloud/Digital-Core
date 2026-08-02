package mx.scotiabank.nomina.dispersion;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import mx.scotiabank.nomina.auth.TwoFactorService;
import mx.scotiabank.nomina.common.error.BusinessRuleException;
import mx.scotiabank.nomina.dispersion.dto.DispersionDtos.InstruirDispersionRequest;
import mx.scotiabank.nomina.empleado.Empleado;
import mx.scotiabank.nomina.empleado.EmpleadoRepository;
import mx.scotiabank.nomina.empleado.EstadoCuentaEmpleado;
import mx.scotiabank.nomina.empresa.Empresa;
import mx.scotiabank.nomina.empresa.EmpresaRepository;
import mx.scotiabank.nomina.integration.corebanking.CoreBankingClient;
import mx.scotiabank.nomina.integration.spei.SpeiGateway;
import mx.scotiabank.nomina.nomina.DetalleNomina;
import mx.scotiabank.nomina.nomina.DetalleNominaRepository;
import mx.scotiabank.nomina.nomina.EstadoNomina;
import mx.scotiabank.nomina.nomina.Nomina;
import mx.scotiabank.nomina.nomina.NominaRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * TC-DISP-005 · El monto total de la nomina excede el limite de dispersion de la
 * empresa (RN-05). Se espera una {@link BusinessRuleException} con {@code code =
 * RN-05}, que {@code GlobalExceptionHandler} traduce a HTTP 422.
 *
 * <p>Verifica ademas que NO se llega a consultar el core ni a instruir SPEI cuando
 * el limite ya fue superado (la regla corta antes de comprometer fondos).
 */
@ExtendWith(MockitoExtension.class)
class DispersionLimiteTest {

    @Mock NominaRepository nominas;
    @Mock DetalleNominaRepository detalles;
    @Mock EmpleadoRepository empleados;
    @Mock EmpresaRepository empresas;
    @Mock DispersionRepository dispersiones;
    @Mock MovimientoDispersionRepository movimientos;
    @Mock CoreBankingClient coreBanking;
    @Mock SpeiGateway spei;

    @Mock Nomina nomina;
    @Mock Empresa empresa;
    @Mock DetalleNomina detalle;
    @Mock Empleado empleado;

    @Test
    @DisplayName("TC-DISP-005 · monto total > limite de nomina lanza RN-05 (-> 422)")
    void montoExcedeLimiteNomina() {
        var twoFactor = new TwoFactorService(); // instancia real: valida el 2FA del mock
        var service = new DispersionService(nominas, detalles, empleados, empresas,
                dispersiones, movimientos, coreBanking, spei, twoFactor);

        UUID idEmpresa = UUID.randomUUID();
        UUID idNomina = UUID.randomUUID();
        UUID idEmpleado = UUID.randomUUID();

        when(nominas.findByIdNominaAndIdEmpresa(idNomina, idEmpresa)).thenReturn(Optional.of(nomina));
        when(nomina.getEstado()).thenReturn(EstadoNomina.VALIDADA);
        when(empresas.findById(idEmpresa)).thenReturn(Optional.of(empresa));
        when(empresa.puedeDispersar()).thenReturn(true);
        // Limite de nomina 1,000.00 · sin limite por empleado.
        when(empresa.getLimiteDispersionNomina()).thenReturn(new BigDecimal("1000.00"));
        lenient().when(empresa.getLimiteDispersionEmpleado()).thenReturn(null);

        // Un renglon valido de 5,000.00 para un empleado VINCULADA (dispersable · RN-07).
        when(detalles.findByIdNomina(idNomina)).thenReturn(List.of(detalle));
        when(detalle.esValido()).thenReturn(true);
        when(detalle.getIdEmpleado()).thenReturn(idEmpleado);
        when(detalle.getImporte()).thenReturn(new BigDecimal("5000.00"));
        when(empleados.findByIdEmpleadoAndIdEmpresa(idEmpleado, idEmpresa)).thenReturn(Optional.of(empleado));
        when(empleado.getEstadoCuenta()).thenReturn(EstadoCuentaEmpleado.VINCULADA);

        // Codigo 2FA aceptado por el mock (AuthService.MOCK_2FA_CODE).
        var req = new InstruirDispersionRequest("chg_test", "483920", null);

        assertThatThrownBy(() -> service.instruir(idEmpresa, idNomina, req, UUID.randomUUID()))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getCode()).isEqualTo("RN-05"));

        // La regla corta antes de tocar el core o SPEI (no se comprometen fondos).
        org.mockito.Mockito.verifyNoInteractions(coreBanking, spei, dispersiones, movimientos);
    }
}
