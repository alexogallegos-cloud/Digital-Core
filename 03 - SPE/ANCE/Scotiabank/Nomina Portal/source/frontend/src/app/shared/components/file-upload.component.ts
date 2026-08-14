import { ChangeDetectionStrategy, Component, output, signal } from '@angular/core';
import { DecimalPipe } from '@angular/common';

/**
 * FileUploadComponent — drag & drop + seleccion de archivo, reutilizable para
 * carga masiva de empleados y carga de layout de nomina. Emite el File; la
 * validacion client-side de contenido la hace el feature que lo consume
 * (feedback inmediato por fila antes de enviar — estandar dt-frontend-engineer).
 */
@Component({
  selector: 'np-file-upload',
  standalone: true,
  imports: [DecimalPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div
      class="dropzone"
      [class.dragging]="dragging()"
      (dragover)="onDragOver($event)"
      (dragleave)="dragging.set(false)"
      (drop)="onDrop($event)"
    >
      <p class="hint">Arrastra el archivo aqui o</p>
      <label class="np-btn np-btn--ghost">
        Seleccionar archivo
        <input type="file" [accept]="accept" (change)="onSelect($event)" hidden />
      </label>
      @if (selected(); as f) {
        <p class="filename">{{ f.name }} ({{ (f.size / 1024) | number: '1.0-0' }} KB)</p>
      }
    </div>
  `,
  styles: [
    `
      .dropzone {
        border: 2px dashed var(--np-color-border);
        border-radius: var(--np-radius);
        padding: 24px;
        text-align: center;
        transition: border-color 0.15s ease, background 0.15s ease;
      }
      .dropzone.dragging { border-color: var(--np-color-primary); background: #eef2f5; }
      .hint { color: var(--np-color-text-muted); margin: 0 0 8px; }
      .filename { margin: 12px 0 0; font-size: 0.85rem; font-weight: 600; }
    `
  ]
})
export class FileUploadComponent {
  /** Extensiones aceptadas (ej. ".xlsx,.txt"). */
  accept = '.xlsx,.xls,.txt,.csv';

  readonly selected = signal<File | null>(null);
  readonly dragging = signal(false);

  /** Emite el archivo seleccionado. */
  readonly fileSelected = output<File>();

  onDragOver(e: DragEvent): void {
    e.preventDefault();
    this.dragging.set(true);
  }

  onDrop(e: DragEvent): void {
    e.preventDefault();
    this.dragging.set(false);
    const file = e.dataTransfer?.files?.[0];
    if (file) this.emit(file);
  }

  onSelect(e: Event): void {
    const file = (e.target as HTMLInputElement).files?.[0];
    if (file) this.emit(file);
  }

  private emit(file: File): void {
    this.selected.set(file);
    this.fileSelected.emit(file);
  }
}
