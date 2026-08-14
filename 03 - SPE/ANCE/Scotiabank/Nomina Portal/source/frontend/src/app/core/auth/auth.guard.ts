import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Rol } from '../api/models';
import { AuthService } from './auth.service';

/**
 * Functional guard basado en el signal `isAuthenticated` del AuthService.
 * Redirige a /login preservando el returnUrl.
 */
export const authGuard: CanActivateFn = (_route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isAuthenticated()) {
    return true;
  }
  return router.createUrlTree(['/login'], { queryParams: { returnUrl: state.url } });
};

/**
 * Factory de guard por rol (ADMIN_EMPRESA, OPERADOR_NOMINA, AUDITOR, ADMIN_SCO).
 * Uso en rutas: `canActivate: [authGuard, roleGuard('OPERADOR_NOMINA', 'ADMIN_EMPRESA')]`.
 */
export function roleGuard(...roles: Rol[]): CanActivateFn {
  return () => {
    const auth = inject(AuthService);
    const router = inject(Router);

    if (!auth.isAuthenticated()) {
      return router.createUrlTree(['/login']);
    }
    if (auth.hasRole(...roles)) {
      return true;
    }
    // Autenticado pero sin rol suficiente.
    return router.createUrlTree(['/dashboard'], { queryParams: { denied: '1' } });
  };
}
