import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/* =============================================================================
   Validadores reactivos MX — RFC · CURP · CLABE.
   Los regex de RFC y CURP son EXACTAMENTE los del contrato OpenAPI
   (api/openapi-nomina-portal.yaml → EmpleadoCreate) y las reglas RN-01/02/03
   del spec (§13). CLABE incluye validacion de digito verificador (RN-03).
   ============================================================================= */

/** RFC — persona fisica (13) o moral (12). Contrato: ^[A-ZN&]{3,4}\d{6}[A-Z0-9]{3}$ */
export const RFC_REGEX = /^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$/;

/** CURP — 18 chars. Contrato: ^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]{2}$ */
export const CURP_REGEX = /^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]{2}$/;

/** CLABE — 18 digitos (RN-03). */
export const CLABE_REGEX = /^\d{18}$/;

/** Money — decimal string con 2 decimales (contrato: ^\d+\.\d{2}$). */
export const MONEY_REGEX = /^\d+\.\d{2}$/;

export function rfcValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = (control.value ?? '').toString().toUpperCase().trim();
    if (!value) return null; // 'required' lo maneja otro validador
    return RFC_REGEX.test(value) ? null : { rfc: true };
  };
}

export function curpValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = (control.value ?? '').toString().toUpperCase().trim();
    if (!value) return null;
    return CURP_REGEX.test(value) ? null : { curp: true };
  };
}

/**
 * CLABE — 18 digitos + digito verificador (algoritmo Banxico: pesos 3,7,1
 * ciclicos sobre los primeros 17 digitos, modulo 10).
 */
export function clabeValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = (control.value ?? '').toString().trim();
    if (!value) return null;
    if (!CLABE_REGEX.test(value)) return { clabe: true };
    return isValidClabeCheckDigit(value) ? null : { clabeDigitoVerificador: true };
  };
}

/** Valida el digito verificador de una CLABE de 18 digitos (algoritmo Banxico). */
export function isValidClabeCheckDigit(clabe: string): boolean {
  if (!CLABE_REGEX.test(clabe)) return false;
  const weights = [3, 7, 1];
  let sum = 0;
  for (let i = 0; i < 17; i++) {
    const digit = Number(clabe.charAt(i));
    const weighted = (digit * weights[i % 3]) % 10;
    sum += weighted;
  }
  const control = (10 - (sum % 10)) % 10;
  return control === Number(clabe.charAt(17));
}

export function moneyValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = (control.value ?? '').toString().trim();
    if (!value) return null;
    return MONEY_REGEX.test(value) ? null : { money: true };
  };
}
