import { FormControl } from '@angular/forms';
import {
  clabeValidator,
  curpValidator,
  isValidClabeCheckDigit,
  moneyValidator,
  rfcValidator
} from './mexican-validators';

describe('Validadores MX (RN-01/02/03)', () => {
  describe('rfcValidator', () => {
    const v = rfcValidator();
    it('acepta RFC de persona fisica valido', () => {
      expect(v(new FormControl('LOGM900101ABC'))).toBeNull();
    });
    it('acepta RFC de persona moral valido (12)', () => {
      expect(v(new FormControl('ABC900101XYZ'))).toBeNull();
    });
    it('rechaza RFC con estructura invalida', () => {
      expect(v(new FormControl('INVALIDO123'))).toEqual({ rfc: true });
    });
    it('no valida cuando esta vacio (delega en required)', () => {
      expect(v(new FormControl(''))).toBeNull();
    });
  });

  describe('curpValidator', () => {
    const v = curpValidator();
    it('acepta CURP valida', () => {
      expect(v(new FormControl('LOGM900101MDFPRR03'))).toBeNull();
    });
    it('rechaza CURP invalida', () => {
      expect(v(new FormControl('XX00'))).toEqual({ curp: true });
    });
  });

  describe('clabeValidator', () => {
    const v = clabeValidator();
    it('rechaza CLABE que no tiene 18 digitos', () => {
      expect(v(new FormControl('123'))).toEqual({ clabe: true });
    });
    it('rechaza CLABE con digito verificador invalido', () => {
      // 18 digitos pero DV incorrecto.
      expect(v(new FormControl('012345678901234567'))).toEqual({ clabeDigitoVerificador: true });
    });
  });

  describe('isValidClabeCheckDigit', () => {
    it('valida el algoritmo Banxico (pesos 3,7,1)', () => {
      // CLABE construida con DV correcto segun el algoritmo.
      const base17 = '01418000000000000';
      const dv = computeDv(base17);
      expect(isValidClabeCheckDigit(base17 + dv)).toBe(true);
    });
  });

  describe('moneyValidator', () => {
    const v = moneyValidator();
    it('acepta decimal con 2 posiciones', () => {
      expect(v(new FormControl('18500.00'))).toBeNull();
    });
    it('rechaza formato sin decimales o con separador de miles', () => {
      expect(v(new FormControl('18500'))).toEqual({ money: true });
      expect(v(new FormControl('18,500.00'))).toEqual({ money: true });
    });
  });
});

/** Helper local: calcula el DV Banxico de los primeros 17 digitos. */
function computeDv(base17: string): string {
  const weights = [3, 7, 1];
  let sum = 0;
  for (let i = 0; i < 17; i++) {
    sum += (Number(base17.charAt(i)) * weights[i % 3]) % 10;
  }
  return String((10 - (sum % 10)) % 10);
}
