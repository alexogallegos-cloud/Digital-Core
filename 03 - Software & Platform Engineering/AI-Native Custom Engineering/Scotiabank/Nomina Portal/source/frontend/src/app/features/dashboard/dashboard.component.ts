import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DashboardService, TipoReporte } from '../../core/api/dashboard.service';
import { EmpleadoService } from '../../core/api/empleado.service';
import { DashboardResumen, Empleado } from '../../core/api/models';
import { EmptyStateComponent } from '../../shared/components/empty-state.component';
import { EstadoBadgeComponent } from '../../shared/components/estado-badge.component';

interface Barra {
  estado: string;
  label: string;
  total: number;
  color: string;
  pct: number;
}
interface Segmento {
  estado: string;
  label: string;
  total: number;
  color: string;
  dash: number;
  gap: number;
  offset: number;
}

/**
 * DashboardComponent — M2 (EP-02). Pantalla de referencia P-INI-01.
 *
 * Los indicadores NO se derivan en el cliente: provienen del endpoint de
 * agregación GET /dashboard (spec §8), calculado con GROUP BY en BD y acotado a
 * la empresa del usuario. El listado de empleados recientes usa /empleados.
 * Gráficas en SVG inline (sin dependencia externa) · Signals-first.
 */
@Component({
  selector: 'np-dashboard',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterLink, EstadoBadgeComponent, EmptyStateComponent],
  template: `
    <h2 class="page-title">Dashboard</h2>

    @if (loading()) {
      <p class="muted">Cargando indicadores…</p>
    } @else if (error()) {
      <p class="error">{{ error() }}</p>
    } @else {

      <!-- Acciones rápidas -->
      <h3 class="section-title">Acciones rápidas</h3>
      <section class="acciones">
        <a class="accion-card" routerLink="/empleados/nuevo">
          <span class="accion-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
              <circle cx="9" cy="7" r="4"/>
              <line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/>
            </svg>
          </span>
          <span class="accion-lbl">Alta de empleado</span>
        </a>
        <a class="accion-card" routerLink="/empleados/carga-masiva">
          <span class="accion-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
              <polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>
            </svg>
          </span>
          <span class="accion-lbl">Carga masiva</span>
        </a>
        <a class="accion-card" routerLink="/nominas">
          <span class="accion-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>
            </svg>
          </span>
          <span class="accion-lbl">Crear nómina</span>
        </a>
        <a class="accion-card" routerLink="/dispersiones">
          <span class="accion-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="17 1 21 5 17 9"/>
              <path d="M3 11V9a4 4 0 0 1 4-4h14"/>
              <polyline points="7 23 3 19 7 15"/>
              <path d="M21 13v2a4 4 0 0 1-4 4H3"/>
            </svg>
          </span>
          <span class="accion-lbl">Dispersiones</span>
        </a>
      </section>

      <!-- Estadísticas generales -->
      <div class="stats-head">
        <h3 class="section-title">Estadísticas generales</h3>
        <div class="stats-controls">
          <label class="ctrl">
            <span class="ctrl-lbl">Intervalo de tiempo</span>
            <select (change)="onIntervalo($event)">
              <option value="">Todo el histórico</option>
              <option value="3">Últimos 3 meses</option>
              <option value="6">Últimos 6 meses</option>
              <option value="12">Últimos 12 meses</option>
            </select>
          </label>
          <label class="ctrl">
            <span class="ctrl-lbl">Tipo de reporte</span>
            <select (change)="onTipo($event)">
              <option value="RESUMEN">Resumen</option>
              <option value="EMPLEADOS">Empleados</option>
              <option value="NOMINAS">Nóminas</option>
            </select>
          </label>
          <button class="report-btn" (click)="descargarReporte()" [disabled]="descargando()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
              <polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            {{ descargando() ? 'Generando…' : 'Reporte general' }}
          </button>
        </div>
      </div>

      <div class="grid">

        <!-- Columna principal -->
        <div class="col-main">

          <!-- Carga de empleados (barras) -->
          <section class="np-card chart-card">
            <h3>Carga de empleados</h3>
            <div class="bars">
              @for (b of barras(); track b.estado) {
                <div class="bar-row">
                  <span class="bar-cnt" [style.background]="b.color">{{ b.total }}</span>
                  <span class="bar-lbl">{{ b.label }}</span>
                  <div class="bar-track">
                    <div class="bar-fill" [style.width.%]="b.pct" [style.background]="b.color"></div>
                  </div>
                </div>
              }
            </div>
          </section>

          <!-- Cuentas de empleados (donut) -->
          <section class="np-card chart-card">
            <h3>Cuentas de empleados</h3>
            @if (donut().total === 0) {
              <np-empty-state mensaje="Aún no hay cuentas registradas." />
            } @else {
              <div class="donut-wrap">
                <svg viewBox="0 0 140 140" class="donut" role="img" aria-label="Distribución de cuentas">
                  <g transform="rotate(-90 70 70)">
                    @for (s of donut().segs; track s.estado) {
                      <circle
                        cx="70" cy="70" r="54" fill="none"
                        [attr.stroke]="s.color" stroke-width="18"
                        [attr.stroke-dasharray]="s.dash + ' ' + s.gap"
                        [attr.stroke-dashoffset]="s.offset" />
                    }
                  </g>
                  <text x="70" y="66" text-anchor="middle" class="donut-num">{{ donut().total }}</text>
                  <text x="70" y="84" text-anchor="middle" class="donut-lbl">empleados</text>
                </svg>
                <ul class="legend">
                  @for (s of donut().segs; track s.estado) {
                    <li>
                      <span class="dot" [style.background]="s.color"></span>
                      <span class="legend-lbl">{{ s.label }}</span>
                      <span class="legend-val">{{ s.total }}</span>
                    </li>
                  }
                </ul>
              </div>
            }
          </section>

          <!-- Empleados recientes -->
          <section class="np-card">
            <h3>Empleados recientes</h3>
            @if (empleadosRecientes().length === 0) {
              <np-empty-state mensaje="Aún no hay empleados cargados." />
            } @else {
              <table class="np-table">
                <thead>
                  <tr><th>No. empleado</th><th>Nombre</th><th>Estado de cuenta</th></tr>
                </thead>
                <tbody>
                  @for (e of empleadosRecientes(); track e.idEmpleado) {
                    <tr>
                      <td>{{ e.numeroEmpleado }}</td>
                      <td>{{ e.nombreCompleto }}</td>
                      <td><np-estado-badge [estado]="e.estadoCuenta" /></td>
                    </tr>
                  }
                </tbody>
              </table>
            }
          </section>
        </div>

        <!-- Columna lateral -->
        <aside class="col-side">

          <!-- Nóminas -->
          <section class="np-card">
            <h3>Nóminas <span class="count-pill">{{ resumen()?.totalNominas ?? 0 }}</span></h3>
            @if (nominas().length === 0) {
              <p class="muted small">Sin nóminas en curso.</p>
            } @else {
              <ul class="stat-list">
                @for (n of nominas(); track n.estado) {
                  <li>
                    <np-estado-badge [estado]="n.estado" />
                    <span class="stat-val">{{ n.total }}</span>
                  </li>
                }
              </ul>
            }
          </section>

          <!-- Centros de trabajo -->
          <section class="np-card">
            <h3>Centros de trabajo <span class="count-pill">{{ resumen()?.totalCentros ?? 0 }}</span></h3>
            @if ((resumen()?.centros ?? []).length === 0) {
              <p class="muted small">Sin centros registrados.</p>
            } @else {
              <ul class="centro-list">
                @for (c of resumen()?.centros ?? []; track c.idCentroTrabajo) {
                  <li>
                    <span class="centro-icon" aria-hidden="true">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                           stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="4" y="2" width="16" height="20" rx="2"/>
                        <line x1="9" y1="7" x2="9" y2="7"/><line x1="15" y1="7" x2="15" y2="7"/>
                        <line x1="9" y1="12" x2="9" y2="12"/><line x1="15" y1="12" x2="15" y2="12"/>
                      </svg>
                    </span>
                    <div class="centro-info">
                      <span class="centro-nombre">{{ c.nombre }}</span>
                      @if (c.sucursal) { <span class="centro-suc">{{ c.sucursal }}</span> }
                    </div>
                  </li>
                }
              </ul>
            }
          </section>
        </aside>
      </div>
    }
  `,
  styles: [`
    .page-title { font-size: 1.6rem; margin-bottom: 20px; }
    .muted { color: var(--np-color-text-muted); }
    .muted.small { font-size: 0.85rem; margin: 4px 0 0; }
    .error { color: var(--np-color-danger); }
    a.np-btn { text-decoration: none; }

    .section-title { font-size: 1.05rem; margin: 0 0 12px; }
    .acciones {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
      gap: 16px;
      margin-bottom: 28px;
    }
    .accion-card {
      display: flex;
      flex-direction: column;
      gap: 12px;
      padding: 18px;
      background: var(--np-color-surface);
      border: 1px solid var(--np-color-border);
      border-radius: var(--np-radius);
      box-shadow: var(--np-shadow);
      text-decoration: none;
      color: var(--np-color-text);
      transition: border-color 0.12s, box-shadow 0.12s, transform 0.12s;
    }
    .accion-card:hover {
      border-color: var(--np-color-primary);
      box-shadow: 0 2px 8px rgba(31, 41, 51, 0.14);
      transform: translateY(-1px);
    }
    .accion-icon { color: var(--np-color-primary); }
    .accion-lbl { font-size: 0.88rem; font-weight: 600; }

    /* ── Estadísticas generales (toolbar) ── */
    .stats-head { margin-bottom: 16px; }
    .stats-controls { display: flex; flex-wrap: wrap; align-items: flex-end; gap: 16px; }
    .ctrl { display: flex; flex-direction: column; gap: 4px; }
    .ctrl-lbl { font-size: 0.75rem; color: var(--np-color-text-muted); }
    .ctrl select {
      padding: 8px 12px;
      border: 1px solid var(--np-color-border);
      border-radius: var(--np-radius-sm);
      font-size: 0.88rem;
      font-family: inherit;
      background: var(--np-color-surface);
      min-width: 170px;
      cursor: pointer;
    }
    .report-btn {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: none;
      border: none;
      color: var(--np-color-primary);
      font-weight: 600;
      font-size: 0.88rem;
      font-family: inherit;
      cursor: pointer;
      padding: 8px 4px;
    }
    .report-btn:hover:not(:disabled) { text-decoration: underline; }
    .report-btn:disabled { opacity: 0.6; cursor: default; }

    .grid { display: grid; grid-template-columns: minmax(0, 2fr) minmax(240px, 1fr); gap: 20px; align-items: start; }
    @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } }
    .col-main, .col-side { display: flex; flex-direction: column; gap: 20px; min-width: 0; }

    section h3 {
      font-size: 1rem;
      margin: 0 0 16px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .count-pill {
      background: #f1f2f4;
      color: var(--np-color-text-muted);
      font-size: 0.72rem;
      font-weight: 700;
      padding: 2px 9px;
      border-radius: 10px;
    }

    /* ── Bar chart ── */
    .bars { display: flex; flex-direction: column; gap: 12px; }
    .bar-row { display: grid; grid-template-columns: 34px 130px 1fr; align-items: center; gap: 10px; }
    .bar-cnt {
      color: #fff; font-weight: 700; font-size: 0.78rem;
      text-align: center; border-radius: 6px; padding: 3px 0;
    }
    .bar-lbl { font-size: 0.82rem; color: var(--np-color-text); text-transform: capitalize; }
    .bar-track { background: #eef0f3; border-radius: 6px; height: 14px; overflow: hidden; }
    .bar-fill { height: 100%; border-radius: 6px; transition: width 0.4s ease; min-width: 2px; }

    /* ── Donut ── */
    .donut-wrap { display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
    .donut { width: 150px; height: 150px; flex-shrink: 0; }
    .donut-num { font-size: 1.5rem; font-weight: 800; fill: var(--np-color-text); }
    .donut-lbl { font-size: 0.62rem; fill: var(--np-color-text-muted); text-transform: uppercase; letter-spacing: 0.05em; }
    .legend { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 8px; }
    .legend li { display: flex; align-items: center; gap: 8px; font-size: 0.82rem; }
    .legend-lbl { text-transform: capitalize; color: var(--np-color-text); min-width: 120px; }
    .legend-val { font-weight: 700; }
    .dot { width: 11px; height: 11px; border-radius: 3px; flex-shrink: 0; }

    /* ── Stat list (nóminas) ── */
    .stat-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
    .stat-list li { display: flex; align-items: center; justify-content: space-between; }
    .stat-val { font-weight: 800; font-size: 1rem; }

    /* ── Centros ── */
    .centro-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
    .centro-list li { display: flex; align-items: center; gap: 10px; }
    .centro-icon {
      width: 34px; height: 34px; flex-shrink: 0;
      display: grid; place-items: center;
      background: #f4f5f7; color: var(--np-color-primary);
      border-radius: 8px;
    }
    .centro-info { display: flex; flex-direction: column; min-width: 0; }
    .centro-nombre { font-size: 0.86rem; font-weight: 600; }
    .centro-suc { font-size: 0.74rem; color: var(--np-color-text-muted); }
  `]
})
export class DashboardComponent {
  private readonly dashboardService = inject(DashboardService);
  private readonly empleadoService = inject(EmpleadoService);

  readonly resumen = signal<DashboardResumen | null>(null);
  readonly empleadosRecientes = signal<Empleado[]>([]);
  readonly loading = signal(true);
  readonly error = signal<string | null>(null);

  /** Filtro "Intervalo de tiempo" (meses; null = todo el histórico). */
  readonly intervalo = signal<number | null>(null);
  /** Tipo de reporte a descargar. */
  readonly tipoReporte = signal<TipoReporte>('RESUMEN');
  readonly descargando = signal(false);

  private readonly ordenEmpleado = [
    'NO_INICIADA', 'EN_PROCESO', 'DOCUMENTADA', 'FINALIZADA', 'VINCULADA', 'BLOQUEADA'
  ];
  // Paleta apagada alineada al original Santander (categórica, baja saturación).
  private readonly colorEmpleado: Record<string, string> = {
    NO_INICIADA: '#E0B04A',
    EN_PROCESO: '#6E9BC5',
    DOCUMENTADA: '#5FA6A0',
    FINALIZADA: '#7CB185',
    VINCULADA: '#9985BE',
    BLOQUEADA: '#CC7A7A'
  };

  private mapaEmpleados(): Map<string, number> {
    const r = this.resumen();
    return new Map((r?.empleadosPorEstado ?? []).map((x) => [x.estado, x.total]));
  }

  readonly barras = computed<Barra[]>(() => {
    if (!this.resumen()) return [];
    const map = this.mapaEmpleados();
    const rows = this.ordenEmpleado.map((e) => ({
      estado: e,
      label: e.replace(/_/g, ' ').toLowerCase(),
      total: map.get(e) ?? 0,
      color: this.colorEmpleado[e]
    }));
    const max = Math.max(1, ...rows.map((x) => x.total));
    return rows.map((x) => ({ ...x, pct: Math.round((x.total / max) * 100) }));
  });

  readonly donut = computed<{ segs: Segmento[]; total: number }>(() => {
    if (!this.resumen()) return { segs: [], total: 0 };
    const C = 2 * Math.PI * 54;
    const map = this.mapaEmpleados();
    const rows = this.ordenEmpleado
      .map((e) => ({
        estado: e,
        label: e.replace(/_/g, ' ').toLowerCase(),
        total: map.get(e) ?? 0,
        color: this.colorEmpleado[e]
      }))
      .filter((x) => x.total > 0);
    const sum = rows.reduce((a, b) => a + b.total, 0);
    let acc = 0;
    const segs: Segmento[] = rows.map((x) => {
      const dash = sum > 0 ? (x.total / sum) * C : 0;
      const seg: Segmento = { ...x, dash, gap: C - dash, offset: -acc };
      acc += dash;
      return seg;
    });
    return { segs, total: sum };
  });

  readonly nominas = computed(() => {
    const r = this.resumen();
    return (r?.nominasPorEstado ?? []).map((x) => ({ ...x, label: x.estado.replace(/_/g, ' ') }));
  });

  constructor() {
    this.cargarResumen();
    this.empleadoService.listEmpleados({ limit: 8 }).subscribe({
      next: (page) => this.empleadosRecientes.set(page.data)
    });
  }

  /** Recarga el resumen aplicando el filtro de intervalo actual. */
  private cargarResumen(): void {
    this.loading.set(true);
    this.dashboardService.getResumen(this.intervalo()).subscribe({
      next: (r) => {
        this.resumen.set(r);
        this.loading.set(false);
      },
      error: (e: { message?: string }) => {
        this.error.set(e.message ?? 'No se pudieron cargar los indicadores.');
        this.loading.set(false);
      }
    });
  }

  onIntervalo(e: Event): void {
    const v = (e.target as HTMLSelectElement).value;
    this.intervalo.set(v === '' ? null : Number(v));
    this.cargarResumen();
  }

  onTipo(e: Event): void {
    this.tipoReporte.set((e.target as HTMLSelectElement).value as TipoReporte);
  }

  /** Descarga el CSV generado por el backend (blob → anchor). */
  descargarReporte(): void {
    const tipo = this.tipoReporte();
    this.descargando.set(true);
    this.dashboardService.descargarReporte(tipo, this.intervalo()).subscribe({
      next: (blob) => {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `reporte-${tipo.toLowerCase()}.csv`;
        a.click();
        URL.revokeObjectURL(url);
        this.descargando.set(false);
      },
      error: () => this.descargando.set(false)
    });
  }
}