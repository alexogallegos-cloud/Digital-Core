import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

type Tono = 'ok' | 'pendiente' | 'error' | 'neutro';

/**
 * Badge de estado reutilizable para enums de dominio (EstadoCuentaEmpleado,
 * EstadoNomina, EstadoDispersion, EstadoMovimiento, EstadoTimbrado).
 * Mapea el valor a un tono semantico (color).
 */
@Component({
  selector: 'np-estado-badge',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `<span class="badge" [class]="'badge--' + tono()">{{ label() }}</span>`,
  styles: [
    `
      .badge {
        display: inline-block;
        padding: 2px 10px;
        border-radius: 12px;
        font-size: 0.72rem;
        font-weight: 700;
        letter-spacing: 0.02em;
        color: #fff;
        white-space: nowrap;
      }
      .badge--ok { background: var(--np-estado-ok); }
      .badge--pendiente { background: var(--np-estado-pendiente); }
      .badge--error { background: var(--np-estado-error); }
      .badge--neutro { background: var(--np-estado-neutro); }
    `
  ]
})
export class EstadoBadgeComponent {
  readonly estado = input.required<string>();

  readonly label = computed(() => this.estado().replace(/_/g, ' '));

  readonly tono = computed<Tono>(() => {
    const e = this.estado();
    if (OK.has(e)) return 'ok';
    if (ERROR.has(e)) return 'error';
    if (PENDIENTE.has(e)) return 'pendiente';
    return 'neutro';
  });
}

const OK = new Set([
  'FINALIZADA',
  'VINCULADA',
  'VALIDADA',
  'AUTORIZADA',
  'CONFIRMADA',
  'CONFIRMADO',
  'TIMBRADO',
  'DOCUMENTADA'
]);
const ERROR = new Set([
  'BLOQUEADA',
  'ELIMINADA',
  'CANCELADA',
  'RECHAZADA_PARCIAL',
  'RECHAZADO',
  'ERROR'
]);
const PENDIENTE = new Set([
  'NO_INICIADA',
  'EN_PROCESO',
  'BORRADOR',
  'LAYOUT_CARGADO',
  'EN_AUTORIZACION',
  'DISPERSANDO',
  'PENDIENTE',
  'PROCESANDO',
  'ENVIADO'
]);
