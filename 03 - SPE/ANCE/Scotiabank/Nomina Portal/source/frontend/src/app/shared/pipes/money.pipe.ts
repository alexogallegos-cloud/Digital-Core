import { Pipe, PipeTransform } from '@angular/core';
import { Money } from '../../core/api/models';

/**
 * MoneyPipe — formatea un Money (string decimal) a formato MXN legible SIN
 * convertirlo a number (preserva precision). Solo agrupa miles y antepone el
 * simbolo; el valor subyacente permanece string en todo el flujo de datos.
 */
@Pipe({ name: 'money', standalone: true })
export class MoneyPipe implements PipeTransform {
  transform(value: Money | null | undefined, currency = 'MXN'): string {
    if (value == null || value === '') return '—';
    const [intPart, decPart = '00'] = value.split('.');
    const grouped = intPart.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return `$${grouped}.${decPart} ${currency}`;
  }
}
