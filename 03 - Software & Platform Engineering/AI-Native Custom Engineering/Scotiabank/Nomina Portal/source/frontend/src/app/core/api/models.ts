/* =============================================================================
   Modelos TypeScript — espejo del contrato OpenAPI 3.1
   (api/openapi-nomina-portal.yaml). Los nombres y enums coinciden 1:1 con los
   schemas del contrato. NO editar sin actualizar el contrato (dt-solution-architect).

   REGLA CRITICA: los montos monetarios (Money) SIEMPRE son `string`
   (decimal codificado, patron ^\d+\.\d{2}$). NUNCA `number` — la precision de
   punto flotante en banca es incidente P1.
   ============================================================================= */

/** Monto monetario como decimal en string. Patron: ^\d+\.\d{2}$ (ej. "18500.00"). */
export type Money = string;

// ---- Error RFC 9457 (Problem Details) ----
export interface ProblemDetailError {
  campo?: string;
  mensaje?: string;
}
export interface ProblemDetails {
  type?: string;
  title?: string;
  status?: number;
  detail?: string;
  instance?: string;
  /** Codigo de regla de negocio (RN-xx). */
  code?: string;
  errors?: ProblemDetailError[];
  [key: string]: unknown;
}

// ---- Paginacion cursor ----
export interface PageInfo {
  nextCursor?: string | null;
  total?: number;
}

// ---- Auth ----
export type Rol = 'ADMIN_EMPRESA' | 'OPERADOR_NOMINA' | 'AUDITOR' | 'ADMIN_SCO';

export interface LoginRequest {
  email: string;
  password: string;
}
export type LoginStatus = 'AUTHENTICATED' | 'PENDING_2FA';
export interface LoginResponse {
  status: LoginStatus;
  challengeId?: string | null;
  accessToken?: string | null;
}
export interface TwoFactorRequest {
  challengeId: string;
  code: string;
}
export interface SessionToken {
  accessToken: string;
  refreshToken: string;
  /** Segundos (<= 3600). */
  expiresIn: number;
  rol: Rol;
}

// ---- Enums de dominio ----
export type EstadoCuentaEmpleado =
  | 'NO_INICIADA'
  | 'EN_PROCESO'
  | 'DOCUMENTADA'
  | 'FINALIZADA'
  | 'VINCULADA'
  | 'BLOQUEADA'
  | 'ELIMINADA';

export type EstadoNomina =
  | 'BORRADOR'
  | 'LAYOUT_CARGADO'
  | 'VALIDADA'
  | 'EN_AUTORIZACION'
  | 'AUTORIZADA'
  | 'DISPERSANDO'
  | 'CONFIRMADA'
  | 'RECHAZADA_PARCIAL'
  | 'CANCELADA';

export type EstadoDispersion =
  | 'PENDIENTE'
  | 'PROCESANDO'
  | 'CONFIRMADA'
  | 'RECHAZADA_PARCIAL';

export type EstadoMovimiento = 'ENVIADO' | 'CONFIRMADO' | 'RECHAZADO';

export type Genero = 'MASCULINO' | 'FEMENINO';
export type EstadoCivil = 'SOLTERO' | 'CASADO' | 'OTRO';
export type TipoNomina = 'SEMANAL' | 'QUINCENAL' | 'MENSUAL' | 'EXTRAORDINARIA';

// ---- Empleado ----
export interface EmpleadoCreate {
  numeroEmpleado: string;
  nombres: string;
  primerApellido: string;
  segundoApellido?: string;
  /** Patron: ^[A-ZN&]{3,4}\d{6}[A-Z0-9]{3}$ */
  rfc: string;
  /** Patron: ^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]{2}$ */
  curp: string;
  genero?: Genero;
  nacionalidad?: string;
  estadoCivil?: EstadoCivil;
  fechaIngreso: string; // date
  ingresoMensualNeto: Money;
  idCentroTrabajo: string;
}
export interface Empleado {
  idEmpleado: string; // uuid
  numeroEmpleado: string;
  nombreCompleto: string;
  /** Enmascarado segun rol. */
  rfc?: string;
  /** Enmascarado segun rol. */
  curp?: string;
  /** PCI — enmascarado (ultimos 6). */
  clabe?: string;
  /** PCI — enmascarado (ultimos 4). */
  numeroTarjeta?: string;
  estadoCuenta: EstadoCuentaEmpleado;
  idCentroTrabajo?: string;
}
export interface EmpleadoPage {
  data: Empleado[];
  page: PageInfo;
}

export interface CargaMasivaErrorFila {
  fila?: number;
  campo?: string;
  mensaje?: string;
}
export interface CargaMasivaResultado {
  idCarga: string;
  estado: 'PROCESANDO' | 'COMPLETADO';
  totalRegistros: number;
  exitosos: number;
  conError: number;
  errores?: CargaMasivaErrorFila[];
}

// ---- Nomina ----
export interface NominaCreate {
  tipo: TipoNomina;
  periodoInicio: string; // date
  periodoFin: string; // date
  descripcion?: string;
}
export interface Nomina {
  idNomina: string;
  tipo: TipoNomina;
  periodoInicio: string;
  periodoFin: string;
  estado: EstadoNomina;
  montoTotal?: Money;
  totalEmpleados?: number;
}
export interface ValidacionErrorFila {
  fila?: number;
  campo?: string;
  mensaje?: string;
}
export interface ValidacionNomina {
  estado: EstadoNomina;
  totalRenglones: number;
  validos: number;
  errores?: ValidacionErrorFila[];
}
export interface ResumenNomina {
  idNomina: string;
  totalEmpleados: number;
  montoTotal: Money;
  saldoDisponibleOrigen: Money;
  fondosSuficientes: boolean;
}

// ---- Dispersion ----
export interface InstruirDispersionRequest {
  challengeId: string;
  code: string;
  /** Opcional; si se omite, dispersion inmediata. */
  fechaProgramada?: string; // date-time
}
export interface Dispersion {
  idDispersion: string;
  idNomina: string;
  estado: EstadoDispersion;
  montoDispersado?: Money;
  referenciaInterna?: string;
  fechaInstruccion?: string; // date-time
}
export interface MovimientoDispersion {
  idEmpleado: string;
  importe: Money;
  /** PCI — enmascarado. */
  clabeDestino?: string;
  estado: EstadoMovimiento;
  /** Clave de rastreo 18 digitos. */
  referenciaSPEI?: string;
  codigoRechazoBanxico?: string | null;
}
export interface DispersionDetalle extends Dispersion {
  movimientos?: MovimientoDispersion[];
}

// ---- CFDI ----
export type EstadoTimbrado = 'PENDIENTE' | 'TIMBRADO' | 'ERROR';
export interface Cfdi {
  idCfdi: string;
  idEmpleado: string;
  uuidSAT?: string;
  estadoTimbrado: EstadoTimbrado;
  codigoErrorSAT?: string | null;
  fechaTimbrado?: string | null; // date-time
}
export interface CfdiPage {
  data: Cfdi[];
  page: PageInfo;
}

// ---- Dashboard (§8) — agregaciones calculadas en BD ----
export interface DashboardEstadoConteo {
  estado: string;
  total: number;
}
export interface DashboardCentroResumen {
  idCentroTrabajo: string;
  nombre: string;
  sucursal?: string | null;
}
export interface DashboardResumen {
  empleadosPorEstado: DashboardEstadoConteo[];
  totalEmpleados: number;
  nominasPorEstado: DashboardEstadoConteo[];
  totalNominas: number;
  centros: DashboardCentroResumen[];
  totalCentros: number;
}

// ---- Query params comunes ----
export interface ListEmpleadosParams {
  cursor?: string;
  limit?: number;
  estadoCuenta?: EstadoCuentaEmpleado;
  q?: string;
}
export interface ListCfdiParams {
  idEmpleado?: string;
  periodo?: string;
  cursor?: string;
  limit?: number;
}
