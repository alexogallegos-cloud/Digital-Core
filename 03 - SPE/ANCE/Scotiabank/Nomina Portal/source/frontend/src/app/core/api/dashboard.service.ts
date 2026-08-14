import { HttpClient, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API_BASE_URL } from './api.config';
import { DashboardResumen } from './models';

/** Tipo de reporte descargable (§8.1). */
export type TipoReporte = 'RESUMEN' | 'EMPLEADOS' | 'NOMINAS';

/**
 * Cliente tipado de /dashboard (operationIds getDashboardResumen, descargarReporte).
 * El resumen lo calcula el backend con agregaciones en BD (spec §8.1).
 */
@Injectable({ providedIn: 'root' })
export class DashboardService {
  private readonly http = inject(HttpClient);
  private readonly base = inject(API_BASE_URL);

  /**
   * GET /dashboard — resumen agregado de la empresa.
   * @param meses filtro "Intervalo de tiempo" (null = todo el histórico).
   */
  getResumen(meses?: number | null): Observable<DashboardResumen> {
    let params = new HttpParams();
    if (meses != null) params = params.set('meses', meses);
    return this.http.get<DashboardResumen>(`${this.base}/dashboard`, { params });
  }

  /** GET /dashboard/reporte — CSV real generado en el backend. */
  descargarReporte(tipo: TipoReporte, meses?: number | null): Observable<Blob> {
    let params = new HttpParams().set('tipo', tipo);
    if (meses != null) params = params.set('meses', meses);
    return this.http.get(`${this.base}/dashboard/reporte`, { params, responseType: 'blob' });
  }
}
