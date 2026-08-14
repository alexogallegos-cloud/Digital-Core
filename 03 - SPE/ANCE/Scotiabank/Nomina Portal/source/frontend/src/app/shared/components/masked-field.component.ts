import { ChangeDetectionStrategy, Component, computed, input, signal } from '@angular/core';

/**
 * MaskedFieldComponent — muestra datos sensibles PCI/PII (CLABE, tarjeta, RFC,
 * CURP) enmascarados, revelando solo los ultimos N caracteres. Boton opcional
 * para revelar temporalmente (auditado en backend en prod).
 *
 * El valor que llega del backend YA viene enmascarado segun rol (contrato);
 * este componente refuerza el enmascarado en cliente y estandariza la UI.
 */
@Component({
  selector: 'np-masked-field',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <span class="masked">
      <span class="value">{{ display() }}</span>
      @if (revealable()) {
        <button type="button" class="toggle" (click)="toggle()">
          {{ revealed() ? 'Ocultar' : 'Ver' }}
        </button>
      }
    </span>
  `,
  styles: [
    `
      .masked { display: inline-flex; align-items: center; gap: 6px; font-variant-numeric: tabular-nums; }
      .toggle { border: none; background: none; color: var(--np-color-info); font-size: 0.75rem; cursor: pointer; padding: 0; }
    `
  ]
})
export class MaskedFieldComponent {
  /** Valor a mostrar (puede venir ya enmascarado del backend). */
  readonly value = input<string | null | undefined>('');
  /** Cuantos caracteres finales dejar visibles. */
  readonly visibleTail = input(4);
  /** Si permite revelar el valor completo (solo si el backend lo envio completo). */
  readonly revealable = input(false);

  readonly revealed = signal(false);

  readonly display = computed(() => {
    const v = (this.value() ?? '').toString();
    if (!v) return '—';
    if (this.revealed()) return v;
    if (v.includes('*') || v.includes('•')) return v; // ya enmascarado
    const tail = this.visibleTail();
    if (v.length <= tail) return v;
    return '•'.repeat(v.length - tail) + v.slice(-tail);
  });

  toggle(): void {
    this.revealed.update((r) => !r);
  }
}
