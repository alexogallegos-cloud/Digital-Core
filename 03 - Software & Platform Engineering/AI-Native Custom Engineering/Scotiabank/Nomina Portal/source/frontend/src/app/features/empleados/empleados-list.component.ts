import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { debounceTime, distinctUntilChanged } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { EmpleadoService } from '../../core/api/empleado.service';
import { Empleado, PageInfo } from '../../core/api/models';
import { EmptyStateComponent } from '../../shared/components/empty-state.component';
import { EstadoBadgeComponent } from '../../shared/components/estado-badge.component';
import { MaskedFieldComponent } from '../../shared/components/masked-field.component';

/**
 * EmpleadosListComponent — M4 (EP-04). Pantalla P-EMP-01.
 * Listado con busqueda (nombre/RFC/numero) y paginacion cursor. Estado en
 * signals (empleados, pageInfo, loading). El campo CLABE se muestra enmascarado
 * (PCI, RN via np-masked-field).
 */
@Component({
  selector: 'np-empleados-list',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ReactiveFormsModule,
    RouterLink,
    EstadoBadgeComponent,
    MaskedFieldComponent,
    EmptyStateComponent
  ],
  template: `
    <div class="header">
      <h2>Empleados</h2>
      <div class="actions">
        <a class="np-btn np-btn--ghost" routerLink="/empleados/carga-masiva">Carga masiva</a>
        <a class="np-btn" routerLink="/empleados/nuevo">Alta individual</a>
      </div>
    </div>

    <div class="np-field search">
      <input
        type="search"
        [formControl]="search"
        placeholder="Buscar por nombre, RFC o numero de empleado"
        aria-label="Buscar empleados"
      />
    </div>

    @if (loading()) {
      <p class="muted">Cargando…</p>
    } @else if (error()) {
      <p class="error">{{ error() }}</p>
    } @else if (empleados().length === 0) {
      <np-empty-state mensaje="No se encontraron empleados." />
    } @else {
      <table class="np-table">
        <thead>
          <tr>
            <th>No. empleado</th>
            <th>Nombre completo</th>
            <th>RFC</th>
            <th>CLABE</th>
            <th>Estado de cuenta</th>
          </tr>
        </thead>
        <tbody>
          @for (e of empleados(); track e.idEmpleado) {
            <tr>
              <td>{{ e.numeroEmpleado }}</td>
              <td>{{ e.nombreCompleto }}</td>
              <td>{{ e.rfc ?? '—' }}</td>
              <td><np-masked-field [value]="e.clabe" [visibleTail]="6" /></td>
              <td><np-estado-badge [estado]="e.estadoCuenta" /></td>
            </tr>
          }
        </tbody>
      </table>

      <div class="pager">
        <span class="muted">Total: {{ pageInfo()?.total ?? empleados().length }}</span>
        @if (pageInfo()?.nextCursor) {
          <button class="np-btn np-btn--ghost" type="button" (click)="loadMore()">
            Cargar mas
          </button>
        }
      </div>
    }
  `,
  styles: [
    `
      .header { display: flex; align-items: center; justify-content: space-between; }
      .actions { display: flex; gap: 10px; }
      .actions a { text-decoration: none; }
      .search { max-width: 420px; margin: 12px 0 16px; }
      .pager { display: flex; align-items: center; justify-content: space-between; margin-top: 16px; }
      .muted { color: var(--np-color-text-muted); }
      .error { color: var(--np-color-danger); }
    `
  ]
})
export class EmpleadosListComponent {
  private readonly empleadoService = inject(EmpleadoService);

  readonly search = new FormControl('', { nonNullable: true });
  readonly empleados = signal<Empleado[]>([]);
  readonly pageInfo = signal<PageInfo | null>(null);
  readonly loading = signal(true);
  readonly error = signal<string | null>(null);

  constructor() {
    this.fetch();
    this.search.valueChanges
      .pipe(debounceTime(300), distinctUntilChanged(), takeUntilDestroyed())
      .subscribe(() => this.fetch());
  }

  private fetch(): void {
    this.loading.set(true);
    this.error.set(null);
    const q = this.search.value.trim();
    this.empleadoService.listEmpleados({ q: q || undefined, limit: 25 }).subscribe({
      next: (page) => {
        this.empleados.set(page.data);
        this.pageInfo.set(page.page);
        this.loading.set(false);
      },
      error: (e: { message?: string }) => {
        this.error.set(e.message ?? 'No se pudo cargar el listado.');
        this.loading.set(false);
      }
    });
  }

  loadMore(): void {
    const cursor = this.pageInfo()?.nextCursor;
    if (!cursor) return;
    const q = this.search.value.trim();
    this.empleadoService.listEmpleados({ q: q || undefined, cursor, limit: 25 }).subscribe({
      next: (page) => {
        this.empleados.update((prev) => [...prev, ...page.data]);
        this.pageInfo.set(page.page);
      },
      error: (e: { message?: string }) => this.error.set(e.message ?? 'Error al paginar.')
    });
  }
}
