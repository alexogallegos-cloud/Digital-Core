import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { EmpleadoService } from '../../core/api/empleado.service';
import { CargaMasivaResultado } from '../../core/api/models';
import { FileUploadComponent } from '../../shared/components/file-upload.component';

/**
 * EmpleadosCargaMasivaComponent — M4 (EP-04). Pantallas P-EMP-08/09/12.
 * Carga masiva de empleados desde archivo (Excel/TXT). Muestra el resultado
 * asincrono con errores por fila (RN-12: reporta error por fila sin abortar el
 * lote valido).
 */
@Component({
  selector: 'np-empleados-carga-masiva',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [FileUploadComponent],
  template: `
    <h2>Carga masiva de empleados</h2>
    <p class="muted">Formatos: Excel (.xlsx/.xls) o texto (.txt). Descarga la plantilla del portal.</p>

    <div class="np-card">
      <div class="np-field">
        <label for="ct">ID centro de trabajo por defecto (opcional)</label>
        <input id="ct" [value]="idCentroTrabajoDefault()" (input)="onCt($event)" />
      </div>

      <np-file-upload (fileSelected)="onFile($event)" />

      <div class="actions">
        <button class="np-btn" type="button" [disabled]="!archivo() || uploading()" (click)="upload()">
          {{ uploading() ? 'Procesando…' : 'Cargar archivo' }}
        </button>
      </div>
    </div>

    @if (error()) {
      <p class="form-error" role="alert">{{ error() }}</p>
    }

    @if (resultado(); as r) {
      <div class="np-card resultado">
        <h3>Resultado de la carga</h3>
        <ul class="stats">
          <li>Total: <strong>{{ r.totalRegistros }}</strong></li>
          <li class="ok">Exitosos: <strong>{{ r.exitosos }}</strong></li>
          <li class="err">Con error: <strong>{{ r.conError }}</strong></li>
          <li>Estado: <strong>{{ r.estado }}</strong></li>
        </ul>

        @if (r.errores && r.errores.length > 0) {
          <table class="np-table">
            <thead>
              <tr><th>Fila</th><th>Campo</th><th>Mensaje</th></tr>
            </thead>
            <tbody>
              @for (e of r.errores; track $index) {
                <tr>
                  <td>{{ e.fila }}</td>
                  <td>{{ e.campo }}</td>
                  <td>{{ e.mensaje }}</td>
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
      .muted { color: var(--np-color-text-muted); }
      .actions { margin-top: 16px; }
      .resultado { margin-top: 20px; }
      .stats { list-style: none; padding: 0; display: flex; gap: 24px; flex-wrap: wrap; }
      .stats .ok strong { color: var(--np-color-success); }
      .stats .err strong { color: var(--np-color-danger); }
      .form-error { color: var(--np-color-danger); }
    `
  ]
})
export class EmpleadosCargaMasivaComponent {
  private readonly empleadoService = inject(EmpleadoService);

  readonly archivo = signal<File | null>(null);
  readonly idCentroTrabajoDefault = signal('');
  readonly uploading = signal(false);
  readonly resultado = signal<CargaMasivaResultado | null>(null);
  readonly error = signal<string | null>(null);

  onFile(file: File): void {
    this.archivo.set(file);
    this.resultado.set(null);
    this.error.set(null);
  }

  onCt(e: Event): void {
    this.idCentroTrabajoDefault.set((e.target as HTMLInputElement).value);
  }

  upload(): void {
    const file = this.archivo();
    if (!file) return;
    this.uploading.set(true);
    this.error.set(null);
    this.empleadoService
      .cargaMasivaEmpleados(file, this.idCentroTrabajoDefault() || undefined)
      .subscribe({
        next: (r) => {
          this.resultado.set(r);
          this.uploading.set(false);
        },
        error: (err: { message?: string }) => {
          this.error.set(err.message ?? 'No se pudo procesar el archivo.');
          this.uploading.set(false);
        }
      });
  }
}
