import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';

/**
 * Functional interceptor — agrega `Authorization: Bearer <jwt>` a cada request
 * saliente cuando hay sesion activa. El token vive SOLO en memoria (AuthService),
 * nunca en storage (PCI-DSS · ADR-ANCE-004).
 *
 * No agrega el header a los endpoints publicos de auth (login / 2fa/verify).
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.accessToken;

  const isPublicAuth = req.url.includes('/auth/login') || req.url.includes('/auth/2fa/verify');

  if (token && !isPublicAuth) {
    const cloned = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
    return next(cloned);
  }
  return next(req);
};
