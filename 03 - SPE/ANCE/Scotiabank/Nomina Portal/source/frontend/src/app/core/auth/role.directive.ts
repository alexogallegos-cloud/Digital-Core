import {
  Directive,
  effect,
  inject,
  input,
  TemplateRef,
  ViewContainerRef
} from '@angular/core';
import { Rol } from '../api/models';
import { AuthService } from './auth.service';

/**
 * Directiva estructural `*npHasRole` — muestra el contenido solo si la sesion
 * tiene alguno de los roles indicados. Complementa (no reemplaza) el guard de
 * ruta: el guard controla navegacion, la directiva controla visibilidad de UI
 * (botones/acciones). La autorizacion real la impone el backend (@PreAuthorize).
 *
 * Uso: `<button *npHasRole="['OPERADOR_NOMINA','ADMIN_EMPRESA']">Dispersar</button>`
 */
@Directive({
  selector: '[npHasRole]',
  standalone: true
})
export class RoleDirective {
  private readonly auth = inject(AuthService);
  private readonly tpl = inject(TemplateRef<unknown>);
  private readonly vcr = inject(ViewContainerRef);

  readonly npHasRole = input.required<Rol[]>();

  private rendered = false;

  constructor() {
    // Reacciona a cambios de rol (signal) y del input.
    effect(() => {
      const roles = this.npHasRole();
      const allowed = this.auth.hasRole(...roles);
      if (allowed && !this.rendered) {
        this.vcr.createEmbeddedView(this.tpl);
        this.rendered = true;
      } else if (!allowed && this.rendered) {
        this.vcr.clear();
        this.rendered = false;
      }
    });
  }
}
