import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../core/auth/auth.service';

@Component({
  selector: 'np-shell',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <div class="shell">

      <!-- ═══════════ SIDEBAR ═══════════ -->
      <aside class="sidebar">

        <div class="sidebar-brand">
          <img src="/scotiabank-logo.png" alt="Scotiabank" class="sidebar-logo" />
        </div>

        <!-- Empresa context (mock hardcoded — en prod viene de /empresas/me) -->
        <div class="empresa-ctx">
          <div class="empresa-ctx__icon">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2"
                 stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="7" width="20" height="14" rx="2"/>
              <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
            </svg>
          </div>
          <div class="empresa-ctx__info">
            <p class="empresa-name">EMPRESA DEMO S.A. DE C.V.</p>
            <div class="empresa-meta">
              <span>Contrato</span><span>Modelo</span>
              <span class="empresa-meta__val">80037393522</span>
              <span class="empresa-meta__val">Autogestión</span>
            </div>
          </div>
        </div>

        <!-- Nav -->
        <nav class="sidebar-nav">
          <a routerLink="/dashboard" routerLinkActive="active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
              <polyline points="9 22 9 12 15 12 15 22"/>
            </svg>
            Inicio
          </a>
          <a routerLink="/empleados" routerLinkActive="active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
              <circle cx="9" cy="7" r="4"/>
              <path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
            Empleados
          </a>
          <a routerLink="/nominas" routerLinkActive="active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
            </svg>
            Nóminas
          </a>
          <a routerLink="/dispersiones" routerLinkActive="active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="17 1 21 5 17 9"/>
              <path d="M3 11V9a4 4 0 0 1 4-4h14"/>
              <polyline points="7 23 3 19 7 15"/>
              <path d="M21 13v2a4 4 0 0 1-4 4H3"/>
            </svg>
            Dispersiones
          </a>
          <a routerLink="/cfdi" routerLinkActive="active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 11 12 14 22 4"/>
              <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
            </svg>
            CFDI
          </a>
        </nav>

        <!-- Bottom -->
        <div class="sidebar-bottom">
          <span class="sidebar-bottom-link">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"/>
              <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
              <line x1="12" y1="17" x2="12.01" y2="17"/>
            </svg>
            Ayuda
            <svg class="chev" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </span>
          <button class="sidebar-bottom-link" (click)="logout()">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
              <polyline points="16 17 21 12 16 7"/>
              <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
            Cerrar sesión
          </button>
        </div>
      </aside>

      <!-- ═══════════ MAIN ═══════════ -->
      <div class="main-area">
        <header class="topbar">
          <span class="topbar__title">Portal Empresas Nómina</span>
          <div class="topbar__user">
            @if (auth.email(); as email) {
              <span class="user-email">{{ email }}</span>
            }
            @if (auth.rol(); as rol) {
              <span class="user-rol">{{ rol }}</span>
            }
          </div>
        </header>
        <main class="content">
          <router-outlet />
        </main>
      </div>

    </div>
  `,
  styles: [`
    .shell { display: flex; min-height: 100vh; }

    /* ── SIDEBAR (blanco, rojo como acento) ── */
    .sidebar {
      width: 240px;
      background: var(--np-color-surface);
      border-right: 1px solid var(--np-color-border);
      color: var(--np-color-text);
      display: flex;
      flex-direction: column;
      flex-shrink: 0;
    }
    .sidebar-brand {
      padding: 18px 20px 16px;
    }
    .sidebar-logo { height: 30px; width: auto; }

    .empresa-ctx {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 12px 16px;
      margin: 0 12px 8px;
      background: var(--np-color-bg);
      border-radius: 8px;
    }
    .empresa-ctx__icon { margin-top: 2px; flex-shrink: 0; color: var(--np-color-primary); }
    .empresa-name { margin: 0 0 5px; font-size: 0.74rem; font-weight: 700; line-height: 1.3; }
    .empresa-meta {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 0 6px;
      font-size: 0.67rem;
      color: var(--np-color-text-muted);
    }
    .empresa-meta__val { color: var(--np-color-text); font-weight: 600; }

    .sidebar-nav {
      display: flex;
      flex-direction: column;
      padding: 8px;
      gap: 2px;
      flex: 1;
    }
    .sidebar-nav a {
      display: flex;
      align-items: center;
      gap: 12px;
      color: var(--np-color-text);
      text-decoration: none;
      padding: 11px 12px;
      border-radius: 6px;
      font-size: 0.9rem;
      border-left: 3px solid transparent;
      transition: background 0.12s;
    }
    .sidebar-nav a svg { color: var(--np-color-primary); flex-shrink: 0; }
    .sidebar-nav a:hover  { background: var(--np-color-bg); }
    .sidebar-nav a.active {
      background: #fdeceb;
      color: var(--np-color-primary);
      font-weight: 600;
      border-left-color: var(--np-color-primary);
    }

    .sidebar-bottom {
      padding: 12px 8px 16px;
      border-top: 1px solid var(--np-color-border);
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .sidebar-bottom-link {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      width: 100%;
      color: var(--np-color-text-muted);
      text-decoration: none;
      padding: 9px 12px;
      border-radius: 6px;
      font-size: 0.9rem;
      background: none;
      border: none;
      cursor: pointer;
      font-family: inherit;
      transition: background 0.12s, color 0.12s;
    }
    .sidebar-bottom-link svg { flex-shrink: 0; }
    .sidebar-bottom-link .chev { color: var(--np-color-text-muted); }
    .sidebar-bottom-link:hover { background: var(--np-color-bg); color: var(--np-color-text); }

    /* ── MAIN ── */
    .main-area { flex: 1; display: flex; flex-direction: column; min-width: 0; }
    .topbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 24px;
      height: 52px;
      background: var(--np-color-surface);
      border-bottom: 1px solid var(--np-color-border);
      flex-shrink: 0;
    }
    .topbar__title { font-weight: 600; font-size: 0.9rem; }
    .topbar__user  { display: flex; align-items: center; gap: 12px; font-size: 0.83rem; }
    .user-email    { color: var(--np-color-text-muted); }
    .user-rol {
      background: #f1f2f4;
      color: var(--np-color-text-muted);
      padding: 3px 10px;
      border-radius: 12px;
      font-size: 0.7rem;
      font-weight: 700;
      letter-spacing: 0.03em;
    }
    .content { padding: 24px; flex: 1; overflow: auto; }
  `]
})
export class ShellComponent {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  logout(): void {
    this.auth.logout();
    void this.router.navigate(['/login']);
  }
}