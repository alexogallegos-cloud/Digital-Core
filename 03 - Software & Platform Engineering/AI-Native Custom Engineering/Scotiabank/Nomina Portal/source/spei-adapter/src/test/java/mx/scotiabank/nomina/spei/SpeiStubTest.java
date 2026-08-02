package mx.scotiabank.nomina.spei;

import static org.assertj.core.api.Assertions.assertThat;

import mx.scotiabank.nomina.spei.SpeiDtos.SpeiResultado;
import org.junit.jupiter.api.Test;

/**
 * Verifica el comportamiento determinista del stub SPEI.
 * Relacionado con TC-DISP-012 (dispersion rechazada por SPEI).
 */
class SpeiStubTest {

    private final SpeiStub stub = new SpeiStub("00", "07");

    @Test
    void rechazaClabeTerminadaEn00() {
        SpeiResultado r = stub.instruirPago("012180000000000000", "1500.00", "REF-1");
        assertThat(r.confirmado()).isFalse();
        assertThat(r.codigoRechazoBanxico()).isEqualTo("07");
        assertThat(r.claveRastreo()).isNull();
    }

    @Test
    void confirmaClabeValidaConClaveRastreo18Digitos() {
        SpeiResultado r = stub.instruirPago("012180000000000123", "1500.00", "REF-2");
        assertThat(r.confirmado()).isTrue();
        assertThat(r.codigoRechazoBanxico()).isNull();
        assertThat(r.claveRastreo()).hasSize(18).containsOnlyDigits();
    }
}
