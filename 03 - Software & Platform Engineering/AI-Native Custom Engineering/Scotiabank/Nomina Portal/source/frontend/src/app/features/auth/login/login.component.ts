import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../core/auth/auth.service';

/**
 * LoginComponent — M1 (EP-01). Pantalla de login + verificacion 2FA.
 * El flujo lo maneja AuthService con signals: `pending2fa()` alterna la vista
 * de credenciales por la de codigo. Marca neutra (placeholder, sin cliente).
 */
@Component({
  selector: 'np-login',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule],
  template: `
    <div class="login-wrap">
      <div class="login-card np-card">
        <div class="brand">
          <img src="/scotiabank-logo.png" alt="Scotiabank" class="brand__logo" />
          <h1>Portal Empresas Nómina</h1>
          <p class="subtitle">Acceso para empresas</p>
        </div>

        @if (!auth.pending2fa()) {
          <!-- Paso 1: credenciales -->
          <form [formGroup]="loginForm" (ngSubmit)="onLogin()">
            <div class="np-field">
              <label for="email">Correo electronico</label>
              <input id="email" type="email" formControlName="email" autocomplete="username" />
              @if (invalid('email')) {
                <span class="np-error">Correo requerido y valido.</span>
              }
            </div>
            <div class="np-field">
              <label for="password">Contrasena</label>
              <input
                id="password"
                type="password"
                formControlName="password"
                autocomplete="current-password"
              />
              @if (invalid('password')) {
                <span class="np-error">Contrasena requerida.</span>
              }
            </div>
            <button class="np-btn full" type="submit" [disabled]="auth.loading() || loginForm.invalid">
              {{ auth.loading() ? 'Ingresando…' : 'Ingresar' }}
            </button>
          </form>
        } @else {
          <!-- Paso 2: 2FA (RN-08) -->
          <form [formGroup]="twoFaForm" (ngSubmit)="onVerify()">
            <p class="twofa-hint">Ingresa el codigo de verificacion (NIP dinamico de token).</p>
            <div class="np-field">
              <label for="code">Codigo 2FA</label>
              <input
                id="code"
                type="text"
                inputmode="numeric"
                maxlength="8"
                formControlName="code"
                autocomplete="one-time-code"
              />
              @if (invalid2fa()) {
                <span class="np-error">Codigo requerido.</span>
              }
            </div>
            <button class="np-btn full" type="submit" [disabled]="auth.loading() || twoFaForm.invalid">
              {{ auth.loading() ? 'Verificando…' : 'Verificar' }}
            </button>
          </form>
        }

        @if (auth.error(); as err) {
          <p class="form-error" role="alert">{{ err }}</p>
        }
      </div>

      <p class="disclaimer">
        Ambiente mock — IAM propio (ADR-ANCE-004). En produccion: SSO federado del portal.
      </p>
    </div>
  `,
  styles: [
    `
      .login-wrap {
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 16px;
        background: var(--np-color-bg);
      }
      .login-card { width: 360px; max-width: 90vw; }
      .brand { text-align: center; margin-bottom: 20px; }
      .brand__logo { height: 40px; width: auto; display: block; margin: 0 auto; }
      .brand h1 { font-size: 1.15rem; margin: 12px 0 2px; }
      .subtitle { color: var(--np-color-text-muted); font-size: 0.85rem; margin: 0; }
      .full { width: 100%; justify-content: center; }
      .twofa-hint { font-size: 0.85rem; color: var(--np-color-text-muted); }
      .form-error { color: var(--np-color-danger); font-size: 0.85rem; margin-top: 12px; text-align: center; }
      .disclaimer { font-size: 0.75rem; color: var(--np-color-text-muted); max-width: 360px; text-align: center; }
    `
  ]
})
export class LoginComponent {
  readonly auth = inject(AuthService);
  private readonly fb = inject(FormBuilder);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);

  private readonly submitted = signal(false);

  readonly loginForm = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]]
  });

  readonly twoFaForm = this.fb.nonNullable.group({
    code: ['', [Validators.required, Validators.minLength(6)]]
  });

  invalid(field: 'email' | 'password'): boolean {
    const c = this.loginForm.controls[field];
    return c.invalid && (c.touched || this.submitted());
  }

  invalid2fa(): boolean {
    const c = this.twoFaForm.controls.code;
    return c.invalid && (c.touched || this.submitted());
  }

  async onLogin(): Promise<void> {
    this.submitted.set(true);
    if (this.loginForm.invalid) return;
    try {
      const res = await this.auth.login(this.loginForm.getRawValue());
      this.submitted.set(false);
      if (res.status === 'AUTHENTICATED') {
        this.redirect();
      }
      // Si es PENDING_2FA, el template cambia solo (auth.pending2fa()).
    } catch {
      /* auth.error() ya refleja el mensaje */
    }
  }

  async onVerify(): Promise<void> {
    this.submitted.set(true);
    if (this.twoFaForm.invalid) return;
    try {
      await this.auth.verify2fa(this.twoFaForm.getRawValue().code);
      this.redirect();
    } catch {
      /* auth.error() ya refleja el mensaje */
    }
  }

  private redirect(): void {
    const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') ?? '/dashboard';
    void this.router.navigateByUrl(returnUrl);
  }
}
