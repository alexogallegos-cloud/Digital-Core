import { ChangeDetectionStrategy, Component, DestroyRef, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { interval, switchMap } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { DispersionService } from '../../core/api/dispersion.service';
import { DispersionDetalle, InstruirDispersionRequest } from '../../core/api/models';
import { AuthService } from '../../core/auth/auth.service';
import { EstadoBadgeComponent } from '../../shared/components/estado-badge.component';
import { MaskedFieldComponent } from '../../shared/components/masked-field.component';
import { MoneyPipe } from '../../shared/pipes/money.pipe';

/**
 * DispersionesComponent — M6 (EP-06). Instruir dispersion (2FA · RN-08),
 * seguimiento de estado por polling (signals) y feedback de rechazo SPEI
 * (codigoRechazoBanxico por movimiento). La instruccion es IRREVERSIBLE (spec
 * §6.2). Feedback visual explicito de operacion asincrona (anti-patron: sin
 * feedback en operacion async).
 */
@Component({
  selector: 'np-dispersiones',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, EstadoBadgeComponent, MaskedFieldComponent, MoneyPipe],
  template: `
    <h2>Dispersiones</h2>

    <div class="np-card">
      <h3>Instruir dispersion</h3>
      <p class="warn">Operacion irreversible. Requiere segundo factor (2FA).</p>
      <form [formGroup]="form" (ngSubmit)="instruir()">
        <div class="grid">
          <div class="np-field">
            <label for="idNomina">ID de nomina validada</label>
            <input id="idNomina" formControlName="idNomina" placeholder="UUID de la nomina" />
            @if (invalid('idNomina')) { <span class="np-error">Requerido.</span> }
          </div>
          <div class="np-field">
            <label for="code">Codigo 2FA</label>
            <input id="code" inputmode="numeric" maxlength="8" formControlName="code" />
            @if (invalid('code')) { <span class="np-error">Codigo requerido.</span> }
          </div>
        </div>
        <button class="np-btn np-btn--danger" type="submit" [disabled]="instruyendo() || form.invalid">
          {{ instruyendo() ? 'Instruyendo…' : 'Instruir dispersion' }}
        </button>
      </form>
      @if (error()) { <p class="form-error" role="alert">{{ error() }}</p> }
    </div>

    @if (detalle(); as d) {
      <div class="np-card seguimiento">
        <div class="head">
          <h3>Seguimiento</h3>
          <np-estado-badge [estado]="d.estado" />
          @if (polling()) { <span class="polling">Actualizando…</span> }
        </div>
        <ul class="meta">
          <li>Referencia: <strong>{{ d.referenciaInterna ?? '—' }}</strong></li>
          <li>Monto dispersado: <strong>{{ d.montoDispersado | money }}</strong></li>
        </ul>

        @if (d.movimientos && d.movimientos.length > 0) {
          <table class="np-table">
            <thead>
              <tr>
                <th>Empleado</th>
                <th>Importe</th>
                <th>CLABE destino</th>
                <th>Estado</th>
                <th>Clave rastreo SPEI</th>
                <th>Rechazo Banxico</th>
              </tr>
            </thead>
            <tbody>
              @for (m of d.movimientos; track m.idEmpleado) {
                <tr [class.rechazado]="m.estado === 'RECHAZADO'">
                  <td>{{ m.idEmpleado }}</td>
                  <td>{{ m.importe | money }}</td>
                  <td><np-masked-field [value]="m.clabeDestino" [visibleTail]="6" /></td>
                  <td><np-estado-badge [estado]="m.estado" /></td>
                  <td>{{ m.referenciaSPEI ?? '—' }}</td>
                  <td class="rechazo">
                    @if (m.codigoRechazoBanxico) {
                      <span title="Codigo de rechazo Banxico">{{ m.codigoRechazoBanxico }}</span>
                    } @else { — }
                  </td>
                </tr>
              }
            </tbody>
          </table>
        }
      </div>
    }
  `,
  styles: [
    `
      .warn { color: var(--np-color-warning); font-size: 0.85rem; }
      .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px 18px; }
      .seguimiento { margin-top: 20px; }
      .head { display: flex; align-items: center; gap: 12px; }
      .polling { font-size: 0.78rem; color: var(--np-color-info); }
      .meta { list-style: none; padding: 0; display: flex; gap: 24px; }
      tr.rechazado { background: #fdecec; }
      .rechazo span { color: var(--np-color-danger); font-weight: 700; }
      .form-error { color: var(--np-color-danger); }
    `
  ]
})
export class DispersionesComponent {
  private readonly fb = inject(FormBuilder);
  private readonly dispersionService = inject(DispersionService);
  private readonly auth = inject(AuthService);
  private readonly destroyRef = inject(DestroyRef);

  readonly detalle = signal<DispersionDetalle | null>(null);
  readonly instruyendo = signal(false);
  readonly polling = signal(false);
  readonly error = signal<string | null>(null);

  readonly form = this.fb.nonNullable.group({
    idNomina: ['', [Validators.required]],
    code: ['', [Validators.required, Validators.minLength(6)]]
  });

  invalid(name: 'idNomina' | 'code'): boolean {
    const c = this.form.controls[name];
    return c.invalid && c.touched;
  }

  instruir(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.instruyendo.set(true);
    this.error.set(null);

    const raw = this.form.getRawValue();
    const body: InstruirDispersionRequest = {
      // El challengeId proviene de la sesion 2FA (mock); en prod se solicita un
      // challenge fresco por operacion critica.
      challengeId: this.auth.currentChallengeId() ?? 'chg_session',
      code: raw.code
    };

    this.dispersionService.instruirDispersion(raw.idNomina, body).subscribe({
      next: (disp) => {
        this.instruyendo.set(false);
        this.detalle.set({ ...disp });
        this.startPolling(disp.idDispersion);
      },
      error: (e: { message?: string; status?: number }) => {
        this.instruyendo.set(false);
        this.error.set(
          e.status === 409
            ? 'La nomina no esta en un estado dispersable (spec §6.2).'
            : e.message ?? 'No se pudo instruir la dispersion.'
        );
      }
    });
  }

  /** Polling del estado hasta que la dispersion sea terminal (spec §6.2). */
  private startPolling(idDispersion: string): void {
    this.polling.set(true);
    interval(3000)
      .pipe(
        switchMap(() => this.dispersionService.getEstado(idDispersion)),
        takeUntilDestroyed(this.destroyRef)
      )
      .subscribe({
        next: (d) => {
          this.detalle.set(d);
          if (d.estado === 'CONFIRMADA' || d.estado === 'RECHAZADA_PARCIAL') {
            this.polling.set(false);
          }
        },
        error: (e: { message?: string }) => {
          this.polling.set(false);
          this.error.set(e.message ?? 'Error al consultar el estado de la dispersion.');
        }
      });
  }
}
