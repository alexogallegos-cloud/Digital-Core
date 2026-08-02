import { HttpClient } from '@angular/common/http';
import { computed, inject, Injectable, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { API_BASE_URL } from '../api/api.config';
import { LoginRequest, LoginResponse, Rol, SessionToken } from '../api/models';

/**
 * AuthService — estado de sesion con Signals (NO BehaviorSubject · estandar
 * dt-frontend-engineer / Angular 20).
 *
 * SEGURIDAD / PCI (ADR-ANCE-004, decision-authority del rol):
 *   - El JWT de sesion se mantiene SOLO EN MEMORIA (signal privada).
 *   - NUNCA se persiste en localStorage/sessionStorage: PCI-DSS prohibe datos
 *     de sesion/pago persistidos en cliente y evita robo por XSS/persistencia.
 *   - Consecuencia deliberada: un refresh de pagina pierde la sesion y obliga a
 *     re-login. En produccion (ADR-ANCE-007) el token lo provee el portal padre
 *     via SSO federado y se recibe por postMessage / silent refresh OIDC.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly base = inject(API_BASE_URL);

  // ---- Estado privado (signals writables) ----
  private readonly _accessToken = signal<string | null>(null);
  private readonly _rol = signal<Rol | null>(null);
  private readonly _email = signal<string | null>(null);
  private readonly _challengeId = signal<string | null>(null);
  private readonly _loading = signal(false);
  private readonly _error = signal<string | null>(null);

  // ---- Estado publico (solo lectura + computed) ----
  readonly rol = this._rol.asReadonly();
  readonly email = this._email.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();
  readonly pending2fa = computed(() => this._challengeId() !== null && !this._accessToken());
  readonly isAuthenticated = computed(() => this._accessToken() !== null);

  /** Token en memoria — lo consume el interceptor. NO exponer setter publico. */
  get accessToken(): string | null {
    return this._accessToken();
  }

  /** True si la sesion tiene alguno de los roles indicados. */
  hasRole(...roles: Rol[]): boolean {
    const current = this._rol();
    return current !== null && roles.includes(current);
  }

  /** POST /auth/login — operationId login. Puede devolver PENDING_2FA. */
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    this._loading.set(true);
    this._error.set(null);
    try {
      const res = await firstValueFrom(
        this.http.post<LoginResponse>(`${this.base}/auth/login`, credentials)
      );
      this._email.set(credentials.email);
      if (res.status === 'PENDING_2FA') {
        this._challengeId.set(res.challengeId ?? null);
      } else if (res.accessToken) {
        // Login directo sin 2FA (mock puede permitirlo).
        this._accessToken.set(res.accessToken);
      }
      return res;
    } catch (e) {
      this._error.set(this.toMessage(e));
      throw e;
    } finally {
      this._loading.set(false);
    }
  }

  /** POST /auth/2fa/verify — operationId verify2fa. Emite el JWT de sesion. */
  async verify2fa(code: string): Promise<SessionToken> {
    const challengeId = this._challengeId();
    if (!challengeId) {
      throw new Error('No hay un challenge 2FA activo.');
    }
    this._loading.set(true);
    this._error.set(null);
    try {
      const session = await firstValueFrom(
        this.http.post<SessionToken>(`${this.base}/auth/2fa/verify`, { challengeId, code })
      );
      this._accessToken.set(session.accessToken);
      this._rol.set(session.rol);
      this._challengeId.set(null);
      return session;
    } catch (e) {
      this._error.set(this.toMessage(e));
      throw e;
    } finally {
      this._loading.set(false);
    }
  }

  /**
   * Devuelve el challengeId activo para operaciones que requieren 2FA
   * (ej. instruir dispersion). En un mock reutilizamos el challenge de sesion;
   * en prod se pediria un challenge fresco por operacion critica.
   */
  currentChallengeId(): string | null {
    return this._challengeId();
  }

  /** Limpia toda la sesion en memoria. */
  logout(): void {
    this._accessToken.set(null);
    this._rol.set(null);
    this._email.set(null);
    this._challengeId.set(null);
    this._error.set(null);
  }

  private toMessage(e: unknown): string {
    if (typeof e === 'object' && e !== null && 'error' in e) {
      const err = (e as { error?: { detail?: string; title?: string } }).error;
      if (err?.detail) return err.detail;
      if (err?.title) return err.title;
    }
    return 'No se pudo completar la autenticacion.';
  }
}
