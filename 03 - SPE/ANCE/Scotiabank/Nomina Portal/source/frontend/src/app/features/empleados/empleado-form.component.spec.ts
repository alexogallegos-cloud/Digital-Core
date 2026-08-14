import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { provideRouter } from '@angular/router';
import { fireEvent, render, screen } from '@testing-library/angular';
import { EmpleadoFormComponent } from './empleado-form.component';

/**
 * TC-EMP-002 — Validacion de RFC invalido muestra error en el formulario de alta.
 * Materializa el caso de prueba derivado del criterio de aceptacion de EP-04 y
 * la regla RN-01 (RFC estructura SAT). QE shift-left: el caso existe desde el
 * refinamiento de la story, no hasta la fase TEST.
 */
describe('EmpleadoFormComponent · TC-EMP-002 (RFC invalido)', () => {
  async function setup() {
    return render(EmpleadoFormComponent, {
      providers: [provideRouter([]), provideHttpClient(), provideHttpClientTesting()]
    });
  }

  it('muestra error cuando el RFC no cumple la estructura SAT', async () => {
    await setup();
    const rfcInput = screen.getByLabelText('RFC') as HTMLInputElement;

    // RFC con estructura invalida (no cumple ^[A-ZN&]{3,4}\\d{6}[A-Z0-9]{3}$).
    fireEvent.input(rfcInput, { target: { value: 'INVALIDO123' } });
    fireEvent.blur(rfcInput);

    const error = await screen.findByTestId('rfc-error');
    expect(error).toBeInTheDocument();
    expect(error.textContent).toContain('RFC invalido');
  });

  it('no muestra error cuando el RFC es valido', async () => {
    await setup();
    const rfcInput = screen.getByLabelText('RFC') as HTMLInputElement;

    // RFC de persona fisica valido (13 caracteres, estructura SAT).
    fireEvent.input(rfcInput, { target: { value: 'LOGM900101ABC' } });
    fireEvent.blur(rfcInput);

    expect(screen.queryByTestId('rfc-error')).toBeNull();
  });
});
