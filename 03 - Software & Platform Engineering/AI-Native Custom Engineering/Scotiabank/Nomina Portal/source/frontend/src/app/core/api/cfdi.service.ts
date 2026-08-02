import { HttpClient, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API_BASE_URL } from './api.config';
import { CfdiPage, ListCfdiParams } from './models';

/**
 * Cliente tipado del grupo /cfdi del contrato OpenAPI.
 * operationIds: listCfdi, downloadCfdiXml.
 */
@Injectable({ providedIn: 'root' })
export class CfdiService {
  private readonly http = inject(HttpClient);
  private readonly base = inject(API_BASE_URL);

  /** GET /cfdi — operationId listCfdi */
  listCfdi(params: ListCfdiParams = {}): Observable<CfdiPage> {
    let httpParams = new HttpParams();
    if (params.idEmpleado) httpParams = httpParams.set('idEmpleado', params.idEmpleado);
    if (params.periodo) httpParams = httpParams.set('periodo', params.periodo);
    if (params.cursor) httpParams = httpParams.set('cursor', params.cursor);
    if (params.limit != null) httpParams = httpParams.set('limit', params.limit);
    return this.http.get<CfdiPage>(`${this.base}/cfdi`, { params: httpParams });
  }

  /** GET /cfdi/{idCfdi}/xml — operationId downloadCfdiXml (descarga texto XML) */
  downloadXml(idCfdi: string): Observable<string> {
    return this.http.get(`${this.base}/cfdi/${idCfdi}/xml`, { responseType: 'text' });
  }
}
