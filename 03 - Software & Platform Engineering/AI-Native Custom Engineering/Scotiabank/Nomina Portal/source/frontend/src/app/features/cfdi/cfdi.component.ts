import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { CfdiService } from '../../core/api/cfdi.service';
import { Cfdi } from '../../core/api/models';
import { EmptyStateComponent } from '../../shared/components/empty-state.component';
import { EstadoBadgeComponent } from '../../shared/components/estado-badge.component';

/**
 * CfdiComponent — M7 (EP-07). Shell de consulta/descarga de CFDI de nomina.
 * Filtro por empleado y periodo; descarga del XML (operationId downloadCfdiXml).
 * Timbrado y reintento se amplian en iteraciones posteriores.
 */
@Component({
  selector: 'np-cfdi',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, EstadoBadgeComponent, EmptyStateComponent],
  template: `
    <h2>CFDI de nomina</h2>

    <form class="filtros np-card" [formGroup]="filtros" (ngSubmit)="buscar()">
      <div class="np-field">
        <label for="idEmpleado">ID empleado (opcional)</label>
        <input id="idEmpleado" formControlName="idEmpleado" placeholder="UUID" />
      </div>
      <div class="np-field">
        <label for="periodo">Periodo</label>
        <input id="periodo" formControlName="periodo" placeholder="2026-07" />
      </div>
      <button class="np-btn" type="submit" [disabled]="loading()">Buscar</button>
    </form>

    @if (loading()) {
      <p class="muted">Cargando…</p>
    } @else if (error()) {
      <p class="error">{{ error() }}</p>
    } @else if (cfdis().length === 0) {
      <np-empty-state mensaje="Sin CFDI para los filtros seleccionados." />
    } @else {
      <table class="np-table">
        <thead>
          <tr>
            <th>Folio fiscal (UUID SAT)</th>
            <th>Empleado</th>
            <th>Estado timbrado</th>
            <th>Fecha timbrado</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          @for (c of cfdis(); track c.idCfdi) {
            <tr>
              <td>{{ c.uuidSAT ?? '—' }}</td>
              <td>{{ c.idEmpleado }}</td>
              <td><np-estado-badge [estado]="c.estadoTimbrado" /></td>
              <td>{{ c.fechaTimbrado ?? '—' }}</td>
              <td>
                @if (c.estadoTimbrado === 'TIMBRADO') {
                  <button class="np-btn np-btn--ghost" type="button" (click)="descargar(c)">
                    Descargar XML
                  </button>
                }
              </td>
            </tr>
          }
        </tbody>
      </table>
    }
  `,
  styles: [
    `
      .filtros { display: flex; gap: 16px; align-items: flex-end; margin-bottom: 16px; flex-wrap: wrap; }
      .filtros .np-field { margin-bottom: 0; }
      .muted { color: var(--np-color-text-muted); }
      .error { color: var(--np-color-danger); }
    `
  ]
})
export class CfdiComponent {
  private readonly fb = inject(FormBuilder);
  private readonly cfdiService = inject(CfdiService);

  readonly cfdis = signal<Cfdi[]>([]);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);

  readonly filtros = this.fb.nonNullable.group({
    idEmpleado: [''],
    periodo: ['']
  });

  buscar(): void {
    this.loading.set(true);
    this.error.set(null);
    const raw = this.filtros.getRawValue();
    this.cfdiService
      .listCfdi({
        idEmpleado: raw.idEmpleado || undefined,
        periodo: raw.periodo || undefined,
        limit: 25
      })
      .subscribe({
        next: (page) => {
          this.cfdis.set(page.data);
          this.loading.set(false);
        },
        error: (e: { message?: string }) => {
          this.error.set(e.message ?? 'No se pudo consultar el CFDI.');
          this.loading.set(false);
        }
      });
  }

  descargar(c: Cfdi): void {
    this.cfdiService.downloadXml(c.idCfdi).subscribe({
      next: (xml) => {
        const blob = new Blob([xml], { type: 'application/xml' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `cfdi-${c.uuidSAT ?? c.idCfdi}.xml`;
        a.click();
        URL.revokeObjectURL(url);
      },
      error: (e: { message?: string }) => this.error.set(e.message ?? 'No se pudo descargar el XML.')
    });
  }
}
