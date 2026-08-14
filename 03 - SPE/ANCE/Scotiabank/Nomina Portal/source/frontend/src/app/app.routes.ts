import { Routes } from '@angular/router';
import { authGuard, roleGuard } from './core/auth/auth.guard';

/**
 * Rutas de la aplicacion — features standalone cargadas LAZY por ruta
 * (loadComponent). El shell agrupa las rutas autenticadas y las protege con
 * authGuard; los roles (RN-08, spec §3) se refuerzan con roleGuard por ruta.
 */
export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/login/login.component').then((m) => m.LoginComponent),
    title: 'Ingreso · Portal Empresas Nomina'
  },
  {
    path: '',
    loadComponent: () => import('./layout/shell.component').then((m) => m.ShellComponent),
    canActivate: [authGuard],
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then((m) => m.DashboardComponent),
        title: 'Dashboard'
      },
      {
        path: 'empleados',
        loadComponent: () =>
          import('./features/empleados/empleados-list.component').then(
            (m) => m.EmpleadosListComponent
          ),
        title: 'Empleados'
      },
      {
        path: 'empleados/nuevo',
        loadComponent: () =>
          import('./features/empleados/empleado-form.component').then(
            (m) => m.EmpleadoFormComponent
          ),
        canActivate: [roleGuard('ADMIN_EMPRESA', 'OPERADOR_NOMINA')],
        title: 'Alta de empleado'
      },
      {
        path: 'empleados/carga-masiva',
        loadComponent: () =>
          import('./features/empleados/empleados-carga-masiva.component').then(
            (m) => m.EmpleadosCargaMasivaComponent
          ),
        canActivate: [roleGuard('ADMIN_EMPRESA', 'OPERADOR_NOMINA')],
        title: 'Carga masiva de empleados'
      },
      {
        path: 'nominas',
        loadComponent: () =>
          import('./features/nominas/nominas.component').then((m) => m.NominasComponent),
        canActivate: [roleGuard('ADMIN_EMPRESA', 'OPERADOR_NOMINA')],
        title: 'Nominas'
      },
      {
        path: 'dispersiones',
        loadComponent: () =>
          import('./features/dispersiones/dispersiones.component').then(
            (m) => m.DispersionesComponent
          ),
        canActivate: [roleGuard('ADMIN_EMPRESA', 'OPERADOR_NOMINA')],
        title: 'Dispersiones'
      },
      {
        path: 'cfdi',
        loadComponent: () =>
          import('./features/cfdi/cfdi.component').then((m) => m.CfdiComponent),
        title: 'CFDI de nomina'
      }
    ]
  },
  { path: '**', redirectTo: '' }
];
