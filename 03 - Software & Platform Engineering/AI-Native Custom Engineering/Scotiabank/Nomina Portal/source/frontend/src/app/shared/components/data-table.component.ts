import { ChangeDetectionStrategy, Component, input } from '@angular/core';

export interface ColumnDef<T> {
  key: keyof T & string;
  header: string;
  /** Formateo opcional del valor de la celda. */
  format?: (row: T) => string;
}

/**
 * DataTableComponent — tabla generica reutilizable dirigida por signals.
 * Recibe las columnas y las filas como inputs signal. Para celdas con markup
 * rico (badges, campos enmascarados) las features usan tablas propias; esta
 * cubre listados tabulares simples de solo texto.
 */
@Component({
  selector: 'np-data-table',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <table class="np-table">
      <thead>
        <tr>
          @for (col of columns(); track col.key) {
            <th>{{ col.header }}</th>
          }
        </tr>
      </thead>
      <tbody>
        @for (row of rows(); track $index) {
          <tr>
            @for (col of columns(); track col.key) {
              <td>{{ col.format ? col.format(row) : row[col.key] }}</td>
            }
          </tr>
        } @empty {
          <tr>
            <td [attr.colspan]="columns().length" class="empty">{{ emptyMessage() }}</td>
          </tr>
        }
      </tbody>
    </table>
  `,
  styles: [
    `
      .empty { text-align: center; color: var(--np-color-text-muted); padding: 24px; }
    `
  ]
})
export class DataTableComponent<T> {
  readonly columns = input.required<ColumnDef<T>[]>();
  readonly rows = input.required<T[]>();
  readonly emptyMessage = input('Sin registros.');
}
