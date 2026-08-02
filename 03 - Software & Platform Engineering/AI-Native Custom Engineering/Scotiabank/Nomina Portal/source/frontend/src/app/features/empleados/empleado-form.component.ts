import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { EmpleadoService } from '../../core/api/empleado.service';
import { EmpleadoCreate } from '../../core/api/models';
import {
  curpValidator,
  moneyValidator,
  rfcValidator
} from '../../shared/validators/mexican-validators';

/**
 * EmpleadoFormComponent — M4 (EP-04). Pantallas P-EMP-02/03 (datos personales +
 * laborales). Alta individual con validacion reactiva de RFC (RN-01) y CURP
 * (RN-02) usando los mismos regex del contrato OpenAPI. El ingreso mensual es
 * Money (string, moneyValidator). Materializa TC-EMP-002 (RFC invalido → error).
 */
@Component({
  selector: 'np-empleado-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule],
  template: `
    <h2>Alta de empleado</h2>

    <form class="np-card form" [formGroup]="form" (ngSubmit)="onSubmit()">
      <fieldset>
        <legend>Datos personales</legend>
        <div class="grid">
          <div class="np-field">
            <label for="nombres">Nombre(s)</label>
            <input id="nombres" formControlName="nombres" />
            @if (invalid('nombres')) { <span class="np-error">Requerido.</span> }
          </div>
          <div class="np-field">
            <label for="primerApellido">Primer apellido</label>
            <input id="primerApellido" formControlName="primerApellido" />
            @if (invalid('primerApellido')) { <span class="np-error">Requerido.</span> }
          </div>
          <div class="np-field">
            <label for="segundoApellido">Segundo apellido</label>
            <input id="segundoApellido" formControlName="segundoApellido" />
          </div>
          <div class="np-field">
            <label for="rfc">RFC</label>
            <input
              id="rfc"
              formControlName="rfc"
              maxlength="13"
              [class.np-invalid]="invalid('rfc')"
              (input)="upper('rfc')"
            />
            @if (control('rfc').hasError('required') && control('rfc').touched) {
              <span class="np-error">RFC requerido.</span>
            } @else if (control('rfc').hasError('rfc')) {
              <span class="np-error" data-testid="rfc-error">RFC invalido (estructura SAT).</span>
            }
          </div>
          <div class="np-field">
            <label for="curp">CURP</label>
            <input
              id="curp"
              formControlName="curp"
              maxlength="18"
              [class.np-invalid]="invalid('curp')"
              (input)="upper('curp')"
            />
            @if (control('curp').hasError('required') && control('curp').touched) {
              <span class="np-error">CURP requerida.</span>
            } @else if (control('curp').hasError('curp')) {
              <span class="np-error" data-testid="curp-error">CURP invalida (18 caracteres).</span>
            }
          </div>
          <div class="np-field">
            <label for="genero">Genero</label>
            <select id="genero" formControlName="genero">
              <option value="">—</option>
              <option value="MASCULINO">Masculino</option>
              <option value="FEMENINO">Femenino</option>
            </select>
          </div>
          <div class="np-field">
            <label for="estadoCivil">Estado civil</label>
            <select id="estadoCivil" formControlName="estadoCivil">
              <option value="">—</option>
              <option value="SOLTERO">Soltero</option>
              <option value="CASADO">Casado</option>
              <option value="OTRO">Otro</option>
            </select>
          </div>
          <div class="np-field">
            <label for="nacionalidad">Nacionalidad</label>
            <input id="nacionalidad" formControlName="nacionalidad" />
          </div>
        </div>
      </fieldset>

      <fieldset>
        <legend>Datos laborales</legend>
        <div class="grid">
          <div class="np-field">
            <label for="numeroEmpleado">Numero de empleado</label>
            <input id="numeroEmpleado" formControlName="numeroEmpleado" />
            @if (invalid('numeroEmpleado')) { <span class="np-error">Requerido.</span> }
          </div>
          <div class="np-field">
            <label for="fechaIngreso">Fecha de ingreso</label>
            <input id="fechaIngreso" type="date" formControlName="fechaIngreso" />
            @if (invalid('fechaIngreso')) { <span class="np-error">Requerida.</span> }
          </div>
          <div class="np-field">
            <label for="ingresoMensualNeto">Ingreso mensual neto (MXN)</label>
            <input
              id="ingresoMensualNeto"
              formControlName="ingresoMensualNeto"
              placeholder="18500.00"
              [class.np-invalid]="invalid('ingresoMensualNeto')"
            />
            @if (control('ingresoMensualNeto').hasError('required') && control('ingresoMensualNeto').touched) {
              <span class="np-error">Requerido.</span>
            } @else if (control('ingresoMensualNeto').hasError('money')) {
              <span class="np-error">Formato invalido (ej. 18500.00).</span>
            }
          </div>
          <div class="np-field">
            <label for="idCentroTrabajo">ID centro de trabajo</label>
            <input id="idCentroTrabajo" formControlName="idCentroTrabajo" />
            @if (invalid('idCentroTrabajo')) { <span class="np-error">Requerido.</span> }
          </div>
        </div>
      </fieldset>

      @if (submitError()) {
        <p class="form-error" role="alert">{{ submitError() }}</p>
      }
      @if (submitOk()) {
        <p class="form-ok" role="status">Empleado registrado. Apertura de cuenta en proceso.</p>
      }

      <div class="form-actions">
        <button class="np-btn np-btn--ghost" type="button" (click)="cancel()">Cancelar</button>
        <button class="np-btn" type="submit" [disabled]="saving()">
          {{ saving() ? 'Guardando…' : 'Registrar empleado' }}
        </button>
      </div>
    </form>
  `,
  styles: [
    `
      .form { max-width: 860px; }
      fieldset { border: 1px solid var(--np-color-border); border-radius: var(--np-radius); margin-bottom: 20px; padding: 16px; }
      legend { font-weight: 600; padding: 0 8px; }
      .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px 20px; }
      .form-actions { display: flex; justify-content: flex-end; gap: 12px; }
      .form-error { color: var(--np-color-danger); }
      .form-ok { color: var(--np-color-success); }
    `
  ]
})
export class EmpleadoFormComponent {
  private readonly fb = inject(FormBuilder);
  private readonly empleadoService = inject(EmpleadoService);
  private readonly router = inject(Router);

  readonly saving = signal(false);
  readonly submitError = signal<string | null>(null);
  readonly submitOk = signal(false);

  readonly form = this.fb.nonNullable.group({
    numeroEmpleado: ['', [Validators.required]],
    nombres: ['', [Validators.required]],
    primerApellido: ['', [Validators.required]],
    segundoApellido: [''],
    rfc: ['', [Validators.required, rfcValidator()]],
    curp: ['', [Validators.required, curpValidator()]],
    genero: [''],
    nacionalidad: ['MEXICANA'],
    estadoCivil: [''],
    fechaIngreso: ['', [Validators.required]],
    ingresoMensualNeto: ['', [Validators.required, moneyValidator()]],
    idCentroTrabajo: ['', [Validators.required]]
  });

  control(name: keyof typeof this.form.controls) {
    return this.form.controls[name];
  }

  invalid(name: keyof typeof this.form.controls): boolean {
    const c = this.form.controls[name];
    return c.invalid && c.touched;
  }

  /** Fuerza mayusculas en RFC/CURP (los regex del contrato son en mayusculas). */
  upper(name: 'rfc' | 'curp'): void {
    const c = this.form.controls[name];
    const v = (c.value ?? '').toUpperCase();
    if (v !== c.value) c.setValue(v, { emitEvent: false });
  }

  onSubmit(): void {
    this.form.markAllAsTouched();
    this.submitError.set(null);
    this.submitOk.set(false);
    if (this.form.invalid) return;

    this.saving.set(true);
    const raw = this.form.getRawValue();
    const body: EmpleadoCreate = {
      numeroEmpleado: raw.numeroEmpleado,
      nombres: raw.nombres,
      primerApellido: raw.primerApellido,
      segundoApellido: raw.segundoApellido || undefined,
      rfc: raw.rfc,
      curp: raw.curp,
      genero: raw.genero ? (raw.genero as EmpleadoCreate['genero']) : undefined,
      nacionalidad: raw.nacionalidad || undefined,
      estadoCivil: raw.estadoCivil ? (raw.estadoCivil as EmpleadoCreate['estadoCivil']) : undefined,
      fechaIngreso: raw.fechaIngreso,
      ingresoMensualNeto: raw.ingresoMensualNeto,
      idCentroTrabajo: raw.idCentroTrabajo
    };

    this.empleadoService.createEmpleado(body).subscribe({
      next: () => {
        this.saving.set(false);
        this.submitOk.set(true);
        setTimeout(() => void this.router.navigate(['/empleados']), 800);
      },
      error: (e: { message?: string }) => {
        this.saving.set(false);
        this.submitError.set(e.message ?? 'No se pudo registrar el empleado.');
      }
    });
  }

  cancel(): void {
    void this.router.navigate(['/empleados']);
  }
}
