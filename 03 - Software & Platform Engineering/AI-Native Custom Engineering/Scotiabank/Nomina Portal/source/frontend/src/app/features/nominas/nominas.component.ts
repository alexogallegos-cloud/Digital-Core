import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { NominaService } from '../../core/api/nomina.service';
import {
  Nomina,
  NominaCreate,
  ResumenNomina,
  ValidacionNomina
} from '../../core/api/models';
import { EstadoBadgeComponent } from '../../shared/components/estado-badge.component';
import { FileUploadComponent } from '../../shared/components/file-upload.component';
import { MoneyPipe } from '../../shared/pipes/money.pipe';

/**
 * NominasComponent — M6 (EP-06). Flujo: crear nomina → cargar layout → validar
 * (errores por fila) → resumen previo a dispersar. Estado en signals; el paso
 * activo se deriva del estado de la nomina (maquina de estados spec §6.2).
 * La instruccion de dispersion vive en el modulo Dispersiones (requiere 2FA).
 */
@Component({
  selector: 'np-nominas',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, EstadoBadgeComponent, FileUploadComponent, MoneyPipe],
  template: `
    <h2>Nominas</h2>

    <!-- Paso 1: crear cabecera -->
    <div class="np-card step">
      <h3>1. Crear nomina</h3>
      <form [formGroup]="form" (ngSubmit)="crear()">
        <div class="grid">
          <div class="np-field">
            <label for="tipo">Tipo</label>
            <select id="tipo" formControlName="tipo">
              <option value="SEMANAL">Semanal</option>
              <option value="QUINCENAL">Quincenal</option>
              <option value="MENSUAL">Mensual</option>
              <option value="EXTRAORDINARIA">Extraordinaria</option>
            </select>
          </div>
          <div class="np-field">
            <label for="ini">Periodo inicio</label>
            <input id="ini" type="date" formControlName="periodoInicio" />
          </div>
          <div class="np-field">
            <label for="fin">Periodo fin</label>
            <input id="fin" type="date" formControlName="periodoFin" />
          </div>
          <div class="np-field">
            <label for="desc">Descripcion</label>
            <input id="desc" formControlName="descripcion" />
          </div>
        </div>
        <button class="np-btn" type="submit" [disabled]="form.invalid || busy()">Crear nomina</button>
      </form>
    </div>

    @if (nomina(); as n) {
      <div class="np-card step">
        <div class="step-head">
          <h3>Nomina {{ n.tipo }} · {{ n.periodoInicio }} → {{ n.periodoFin }}</h3>
          <np-estado-badge [estado]="n.estado" />
        </div>

        <!-- Paso 2: cargar layout -->
        <section>
          <h4>2. Cargar layout de importes</h4>
          <np-file-upload (fileSelected)="cargarLayout($event)" />
        </section>

        <!-- Paso 3: validar -->
        <section>
          <h4>3. Validar layout</h4>
          <button
            class="np-btn np-btn--ghost"
            type="button"
            [disabled]="busy() || !puedeValidar()"
            (click)="validar()"
          >
            Validar
          </button>
          @if (validacion(); as v) {
            <p class="val-summary">
              {{ v.validos }} / {{ v.totalRenglones }} renglones validos.
            </p>
            @if (v.errores && v.errores.length > 0) {
              <table class="np-table">
                <thead><tr><th>Fila</th><th>Campo</th><th>Mensaje</th></tr></thead>
                <tbody>
                  @for (e of v.errores; track $index) {
                    <tr><td>{{ e.fila }}</td><td>{{ e.campo }}</td><td>{{ e.mensaje }}</td></tr>
                  }
                </tbody>
              </table>
            }
          }
        </section>

        <!-- Paso 4: resumen previo -->
        <section>
          <h4>4. Resumen previo a dispersar</h4>
          <button class="np-btn np-btn--ghost" type="button" [disabled]="busy()" (click)="cargarResumen()">
            Ver resumen
          </button>
          @if (resumen(); as r) {
            <ul class="resumen">
              <li>Empleados: <strong>{{ r.totalEmpleados }}</strong></li>
              <li>Monto total: <strong>{{ r.montoTotal | money }}</strong></li>
              <li>Saldo cuenta origen: <strong>{{ r.saldoDisponibleOrigen | money }}</strong></li>
              <li [class.err]="!r.fondosSuficientes" [class.ok]="r.fondosSuficientes">
                Fondos suficientes: <strong>{{ r.fondosSuficientes ? 'Si' : 'No' }}</strong>
              </li>
            </ul>
            @if (r.fondosSuficientes) {
              <p class="hint">La instruccion de dispersion (con 2FA) se realiza en el modulo Dispersiones.</p>
            } @else {
              <p class="err">Fondos insuficientes — no es posible dispersar (RN-05).</p>
            }
          }
        </section>
      </div>
    }

    @if (error()) { <p class="form-error" role="alert">{{ error() }}</p> }
  `,
  styles: [
    `
      .step { margin-bottom: 20px; }
      .step-head { display: flex; align-items: center; justify-content: space-between; }
      .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px 18px; }
      section { border-top: 1px solid var(--np-color-border); margin-top: 16px; padding-top: 12px; }
      .resumen { list-style: none; padding: 0; display: grid; gap: 6px; max-width: 360px; }
      .resumen .ok strong { color: var(--np-color-success); }
      .resumen .err strong { color: var(--np-color-danger); }
      .val-summary { font-weight: 600; }
      .hint { color: var(--np-color-text-muted); font-size: 0.85rem; }
      .err { color: var(--np-color-danger); }
      .form-error { color: var(--np-color-danger); }
    `
  ]
})
export class NominasComponent {
  private readonly fb = inject(FormBuilder);
  private readonly nominaService = inject(NominaService);

  readonly nomina = signal<Nomina | null>(null);
  readonly validacion = signal<ValidacionNomina | null>(null);
  readonly resumen = signal<ResumenNomina | null>(null);
  readonly busy = signal(false);
  readonly error = signal<string | null>(null);

  readonly puedeValidar = computed(() => {
    const estado = this.nomina()?.estado;
    return estado === 'LAYOUT_CARGADO' || estado === 'VALIDADA';
  });

  readonly form = this.fb.nonNullable.group({
    tipo: ['QUINCENAL', [Validators.required]],
    periodoInicio: ['', [Validators.required]],
    periodoFin: ['', [Validators.required]],
    descripcion: ['']
  });

  crear(): void {
    if (this.form.invalid) return;
    this.busy.set(true);
    this.error.set(null);
    const raw = this.form.getRawValue();
    const body: NominaCreate = {
      tipo: raw.tipo as NominaCreate['tipo'],
      periodoInicio: raw.periodoInicio,
      periodoFin: raw.periodoFin,
      descripcion: raw.descripcion || undefined
    };
    this.nominaService.createNomina(body).subscribe({
      next: (n) => {
        this.nomina.set(n);
        this.validacion.set(null);
        this.resumen.set(null);
        this.busy.set(false);
      },
      error: (e: { message?: string }) => this.fail(e)
    });
  }

  cargarLayout(file: File): void {
    const n = this.nomina();
    if (!n) return;
    this.busy.set(true);
    this.nominaService.cargarLayout(n.idNomina, file).subscribe({
      next: (updated) => {
        this.nomina.set(updated);
        this.busy.set(false);
      },
      error: (e: { message?: string }) => this.fail(e)
    });
  }

  validar(): void {
    const n = this.nomina();
    if (!n) return;
    this.busy.set(true);
    this.nominaService.validar(n.idNomina).subscribe({
      next: (v) => {
        this.validacion.set(v);
        this.nomina.update((prev) => (prev ? { ...prev, estado: v.estado } : prev));
        this.busy.set(false);
      },
      error: (e: { message?: string }) => this.fail(e)
    });
  }

  cargarResumen(): void {
    const n = this.nomina();
    if (!n) return;
    this.busy.set(true);
    this.nominaService.getResumen(n.idNomina).subscribe({
      next: (r) => {
        this.resumen.set(r);
        this.busy.set(false);
      },
      error: (e: { message?: string }) => this.fail(e)
    });
  }

  private fail(e: { message?: string }): void {
    this.error.set(e.message ?? 'Ocurrio un error en el flujo de nomina.');
    this.busy.set(false);
  }
}
