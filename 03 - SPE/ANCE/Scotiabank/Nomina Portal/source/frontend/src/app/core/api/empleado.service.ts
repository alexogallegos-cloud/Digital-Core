import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API_BASE_URL, newIdempotencyKey } from './api.config';
import {
  CargaMasivaResultado,
  Empleado,
  EmpleadoCreate,
  EmpleadoPage,
  ListEmpleadosParams
} from './models';

/**
 * Cliente tipado del grupo /empleados del contrato OpenAPI.
 * operationIds: listEmpleados, createEmpleado, getEmpleado, bajaEmpleado,
 * cargaMasivaEmpleados.
 */
@Injectable({ providedIn: 'root' })
export class EmpleadoService {
  private readonly http = inject(HttpClient);
  private readonly base = inject(API_BASE_URL);

  /** GET /empleados — operationId listEmpleados */
  listEmpleados(params: ListEmpleadosParams = {}): Observable<EmpleadoPage> {
    let httpParams = new HttpParams();
    if (params.cursor) httpParams = httpParams.set('cursor', params.cursor);
    if (params.limit != null) httpParams = httpParams.set('limit', params.limit);
    if (params.estadoCuenta) httpParams = httpParams.set('estadoCuenta', params.estadoCuenta);
    if (params.q) httpParams = httpParams.set('q', params.q);
    return this.http.get<EmpleadoPage>(`${this.base}/empleados`, { params: httpParams });
  }

  /** POST /empleados — operationId createEmpleado (requiere Idempotency-Key) */
  createEmpleado(body: EmpleadoCreate): Observable<Empleado> {
    const headers = new HttpHeaders({ 'Idempotency-Key': newIdempotencyKey() });
    return this.http.post<Empleado>(`${this.base}/empleados`, body, { headers });
  }

  /** GET /empleados/{idEmpleado} — operationId getEmpleado */
  getEmpleado(idEmpleado: string): Observable<Empleado> {
    return this.http.get<Empleado>(`${this.base}/empleados/${idEmpleado}`);
  }

  /** PATCH /empleados/{idEmpleado} — operationId bajaEmpleado (baja logica) */
  bajaEmpleado(idEmpleado: string, fechaEfectiva: string): Observable<Empleado> {
    return this.http.patch<Empleado>(`${this.base}/empleados/${idEmpleado}`, { fechaEfectiva });
  }

  /** POST /empleados/carga-masiva — operationId cargaMasivaEmpleados */
  cargaMasivaEmpleados(
    archivo: File,
    idCentroTrabajoDefault?: string
  ): Observable<CargaMasivaResultado> {
    const form = new FormData();
    form.append('archivo', archivo);
    if (idCentroTrabajoDefault) form.append('idCentroTrabajoDefault', idCentroTrabajoDefault);
    const headers = new HttpHeaders({ 'Idempotency-Key': newIdempotencyKey() });
    return this.http.post<CargaMasivaResultado>(`${this.base}/empleados/carga-masiva`, form, {
      headers
    });
  }
}
