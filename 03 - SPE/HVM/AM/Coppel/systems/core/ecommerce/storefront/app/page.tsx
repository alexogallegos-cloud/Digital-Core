'use client';
import { useState } from 'react';
import { PRODUCTS } from '@/lib/products';
import ProductCard from '@/app/components/ProductCard';

const TABS = [
  { key: 'tv-video',   label: 'TV y Video' },
  { key: 'pantallas',  label: 'Pantallas' },
  { key: 'streaming',  label: 'Streaming' },
] as const;

type Tab = (typeof TABS)[number]['key'];

export default function Home() {
  const [tab, setTab] = useState<Tab>('tv-video');
  const products = PRODUCTS.filter(p => p.subcategory === tab);

  return (
    <main className="min-h-screen p-8" style={{ background: '#f8f9fb' }}>
      <header className="mb-8">
        <div className="flex items-center gap-3 mb-1">
          <span
            className="inline-flex items-center justify-center w-9 h-9 rounded-full text-sm font-extrabold shrink-0"
            style={{ background: '#FFD600', color: '#003087' }}
          >
            C
          </span>
          <h1 className="text-2xl font-bold" style={{ color: '#003087' }}>
            Coppel eCommerce — Digital Brain Demo
          </h1>
        </div>
        <p className="ml-12 text-sm text-gray-500">
          Catálogo federado · subgraphs búsqueda + catálogo · DynamoDB coppel-products
        </p>
      </header>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        {TABS.map(t => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className="px-4 py-2 rounded-full text-sm font-semibold transition-all"
            style={{
              background: tab === t.key ? '#003087' : '#e8e8e8',
              color: tab === t.key ? '#fff' : '#374151',
              border: 'none',
              cursor: 'pointer',
            }}
          >
            {t.label}
          </button>
        ))}
      </div>

      {products.length === 0 ? (
        <p className="text-sm text-gray-500">No hay productos en esta subcategoría.</p>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {products.map(p => (
            <ProductCard key={p.id} product={p} />
          ))}
        </div>
      )}
    </main>
  );
}
