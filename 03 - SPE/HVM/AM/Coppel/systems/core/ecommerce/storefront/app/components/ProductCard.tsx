'use client';

import { Product, quincenal } from '@/lib/products';

interface Props {
  product: Product;
}

function fmt(n: number) {
  return n.toLocaleString('es-MX', { style: 'currency', currency: 'MXN', maximumFractionDigits: 0 });
}

export default function ProductCard({ product }: Props) {
  const { brand, name, price, oldPrice, isOffer, isInternational, subgraph } = product;

  return (
    <div className="flex flex-col gap-3 rounded-xl bg-white p-4 shadow-sm hover:shadow-md transition-shadow" style={{ border: '1px solid #e5e7eb', borderTop: '3px solid #003087' }}>
      <div className="flex flex-wrap gap-1.5">
        {isOffer && (
          <span
            className="rounded px-2 py-0.5 text-xs font-bold"
            style={{ background: '#FFD600', color: '#003087' }}
          >
            OFERTA
          </span>
        )}
        {isInternational && (
          <span className="rounded bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800">
            Internacional
          </span>
        )}
        <span
          className="rounded px-2 py-0.5 text-xs font-medium"
          style={{ background: '#003087', color: '#fff' }}
        >
          {subgraph === 'busqueda' ? 'búsqueda' : 'catálogo'}
        </span>
      </div>

      <div>
        <p className="text-xs font-semibold uppercase tracking-wide text-gray-500">{brand}</p>
        <p className="mt-0.5 text-sm font-medium leading-snug text-gray-900">{name}</p>
      </div>

      <div className="mt-auto flex flex-col gap-0.5">
        <p className="text-xl font-bold" style={{ color: '#003087' }}>
          {fmt(price)}
        </p>
        <p className="text-xs text-gray-400 line-through">{fmt(oldPrice)}</p>
        <p className="text-xs font-semibold" style={{ color: '#003087' }}>
          {fmt(quincenal(price))}/qna
        </p>
      </div>
    </div>
  );
}
