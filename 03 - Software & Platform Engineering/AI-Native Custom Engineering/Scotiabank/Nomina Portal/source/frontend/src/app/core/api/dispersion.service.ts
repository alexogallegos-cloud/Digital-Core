import { HttpClient, HttpHeaders } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API_BASE_URL, newIdempotencyKey } from './api.config';
import { Dispersion, DispersionDetalle, InstruirDispersionRequest } from './models';

/**
 * Cliente tipado del grupo /dispersiones del contrato OpenAPI.
 * operationIds: instruirDispersion, getEstadoDispersion.
 * La instruccion requiere 2FA (challengeId + code) y es IRREVERSIBLE.
 */
@Injectable({ providedIn: 'root' })
export class DispersionService {
  private readonly http = inject(HttpClient);
  private readonly base = inject(API_BASE_URL);

  /** POST /nominas/{idNomina}/dispersar — operationId instruirDispersion */
  instruirDispersion(idNomina: string, body: InstruirDispersionRequest): Observable<Dispersion> {
    const headers = new HttpHeaders({ 'Idempotency-Key': newIdempotencyKey() });
    return this.http.post<Dispersion>(`${this.base}/nominas/${idNomina}/dispersar`, body, {
      headers
    });
  }

  /** GET /dispersiones/{idDispersion}/estado — operationId getEstadoDispersion (polling) */
  getEstado(idDispersion: string): Observable<DispersionDetalle> {
    return this.http.get<DispersionDetalle>(`${this.base}/dispersiones/${idDispersion}/estado`);
  }
}
