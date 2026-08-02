import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { routes } from './app.routes';
import { authInterceptor } from './core/auth/auth.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

/**
 * Configuracion de la aplicacion standalone (sin NgModules).
 * Providers: HttpClient con interceptors funcionales (auth Bearer + errores
 * RFC 9457) y el router con binding de inputs desde parametros de ruta.
 */
export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(
      // El orden importa: auth agrega el token; error normaliza la respuesta.
      withInterceptors([authInterceptor, errorInterceptor])
    )
  ]
};
