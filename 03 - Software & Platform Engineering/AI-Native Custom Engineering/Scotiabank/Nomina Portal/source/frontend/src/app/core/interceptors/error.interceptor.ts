import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { ProblemDetails } from '../api/models';
import { AuthService } from '../auth/auth.service';

/**
 * Interceptor de errores — normaliza los errores RFC 9457 (Problem Details) del
 * contrato y maneja 401 global (sesion expirada → logout + redireccion a login).
 */
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      if (err.status === 401 && !req.url.includes('/auth/')) {
        auth.logout();
        void router.navigate(['/login']);
      }
      const problem = (err.error ?? {}) as ProblemDetails;
      // Re-emite un error enriquecido y tipado para las features.
      return throwError(() => ({
        status: err.status,
        problem,
        message: problem.detail ?? problem.title ?? err.message
      }));
    })
  );
};
