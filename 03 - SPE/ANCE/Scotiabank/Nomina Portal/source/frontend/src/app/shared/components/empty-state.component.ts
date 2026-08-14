import { ChangeDetectionStrategy, Component, input } from '@angular/core';

/** Estado vacio reutilizable para listados sin datos. */
@Component({
  selector: 'np-empty-state',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="empty">
      <p class="mensaje">{{ mensaje() }}</p>
      <ng-content />
    </div>
  `,
  styles: [
    `
      .empty { text-align: center; padding: 40px 16px; color: var(--np-color-text-muted); }
      .mensaje { font-size: 0.95rem; margin: 0 0 12px; }
    `
  ]
})
export class EmptyStateComponent {
  readonly mensaje = input('No hay datos para mostrar.');
}
