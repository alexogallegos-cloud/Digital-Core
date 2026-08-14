import { HttpClient, HttpHeaders } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API_BASE_URL, newIdempotencyKey } from './api.config';
import { Nomina, NominaCreate, ResumenNomina, ValidacionNomina } from './models';

/**
 * Cliente tipado del grupo /nominas del contrato OpenAPI.
 * operationIds: createNomina, cargarLayoutNomina, validarNomina, getResumenNomina.
 */
@Injectable({ providedIn: 'root' })
export class NominaService {
  private readonly http = inject(HttpClient);
  private readonly base = inject(API_BASE_URL);

  /** POST /nominas — operationId createNomina */
  createNomina(body: NominaCreate): Observable<Nomina> {
    const headers = new HttpHeaders({ 'Idempotency-Key': newIdempotencyKey() });
    return this.http.post<Nomina>(`${this.base}/nominas`, body, { headers });
  }

  /** POST /nominas/{idNomina}/layout — operationId cargarLayoutNomina */
  cargarLayout(idNomina: string, archivo: File): Observable<Nomina> {
    const form = new FormData();
    form.append('archivo', archivo);
    const headers = new HttpHeaders({ 'Idempotency-Key': newIdempotencyKey() });
    return this.http.post<Nomina>(`${this.base}/nominas/${idNomina}/layout`, form, { headers });
  }

  /** POST /nominas/{idNomina}/validar — operationId validarNomina */
  validar(idNomina: string): Observable<ValidacionNomina> {
    return this.http.post<ValidacionNomina>(`${this.base}/nominas/${idNomina}/validar`, {});
  }

  /** GET /nominas/{idNomina}/resumen — operationId getResumenNomina */
  getResumen(idNomina: string): Observable<ResumenNomina> {
    return this.http.get<ResumenNomina>(`${this.base}/nominas/${idNomina}/resumen`);
  }
}
