'use client';

import { useRouter, useSearchParams } from 'next/navigation';

const TABS = ['tv-video', 'pantallas', 'streaming'] as const;
type Tab = (typeof TABS)[number];

export default function SubcategoryTabs({ active }: { active: string }) {
  const router = useRouter();
  const searchParams = useSearchParams();

  function navigate(tab: Tab) {
    const params = new URLSearchParams(searchParams.toString());
    params.set('subcategory', tab);
    router.push(`/?${params.toString()}`);
  }

  return (
    <nav className="flex gap-2 mb-8" aria-label="Subcategorías">
      {TABS.map((tab) => (
        <button
          key={tab}
          onClick={() => navigate(tab)}
          className="rounded-full px-4 py-1.5 text-sm font-medium transition-colors focus:outline-none focus-visible:ring-2"
          style={
            tab === active
              ? { background: '#003087', color: '#FFD600' }
              : { background: '#e5e7eb', color: '#374151' }
          }
        >
          {tab}
        </button>
      ))}
    </nav>
  );
}
