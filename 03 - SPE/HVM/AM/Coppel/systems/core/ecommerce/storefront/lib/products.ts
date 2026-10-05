export interface Product {
  id: string;
  brand: string;
  name: string;
  price: number;
  oldPrice: number;
  emoji: string;
  isOffer: boolean;
  isInternational: boolean;
  subgraph: string;
  category: string;
  subcategory: string;
}

export const PRODUCTS: Product[] = [
  // TV y video
  { id: 'p001', brand: 'Roku',    name: 'Roku Express 3930 Streaming HD Purple — S010',           price: 1099,  oldPrice: 1499,  emoji: '📦', isOffer: true,  isInternational: false, subgraph: 'busqueda',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p002', brand: 'Aiwa',    name: 'Barra de Sonido Aiwa AWSBH15 Negra 50/60hz',             price: 690,   oldPrice: 1299,  emoji: '🔊', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p003', brand: 'Roku',    name: 'Reproductor de Streaming Roku Ultra 2024 4K Con Alexa',  price: 2795,  oldPrice: 3249,  emoji: '📦', isOffer: true,  isInternational: true,  subgraph: 'busqueda',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p004', brand: 'JBL',     name: 'Barra de Sonido JBL Bar 5.1 Immersive Surround 550W',   price: 7699,  oldPrice: 9799,  emoji: '🔊', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p005', brand: 'Samsung', name: 'Pantalla Samsung 55" Crystal UHD 4K Smart TV 2024',     price: 8999,  oldPrice: 12999, emoji: '📺', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p006', brand: 'LG',      name: 'Pantalla LG 50" NanoCell 4K Smart TV con ThinQ AI',    price: 6499,  oldPrice: 8999,  emoji: '📺', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p007', brand: 'Google',  name: 'Chromecast con Google TV 4K — Nieve',                   price: 999,   oldPrice: 1299,  emoji: '📦', isOffer: true,  isInternational: false, subgraph: 'busqueda',  category: 'electronica', subcategory: 'tv-video' },
  { id: 'p008', brand: 'Samsung', name: 'Barra de Sonido Samsung HW-B550 2.1 410W Bluetooth',    price: 3499,  oldPrice: 4999,  emoji: '🔊', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'tv-video' },
  // Pantallas
  { id: 'p009', brand: 'Samsung', name: 'Pantalla Samsung 55" QLED 4K Smart TV Q70C 2024',       price: 14999, oldPrice: 19999, emoji: '📺', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'pantallas' },
  { id: 'p010', brand: 'LG',      name: 'Pantalla LG 65" OLED Evo C3 4K Smart TV — Negro',      price: 22999, oldPrice: 29999, emoji: '📺', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'pantallas' },
  { id: 'p011', brand: 'Hisense', name: 'Pantalla Hisense 43" 4K UHD Smart TV VIDAA — Negro',   price: 4999,  oldPrice: 6499,  emoji: '📺', isOffer: true,  isInternational: false, subgraph: 'busqueda',  category: 'electronica', subcategory: 'pantallas' },
  { id: 'p012', brand: 'TCL',     name: 'Pantalla TCL 50" 4K UHD Google TV S5400A — Negro',     price: 5499,  oldPrice: 7499,  emoji: '📺', isOffer: true,  isInternational: false, subgraph: 'catalogo',  category: 'electronica', subcategory: 'pantallas' },
  // Streaming
  { id: 'p013', brand: 'Amazon',  name: 'Fire TV Stick 4K Max (2ª gen) con Alexa',              price: 1499,  oldPrice: 1999,  emoji: '📦', isOffer: true,  isInternational: true,  subgraph: 'busqueda',  category: 'electronica', subcategory: 'streaming' },
];

export function getProductsBySubcategory(subcategory: string): Product[] {
  return PRODUCTS.filter(p => p.subcategory === subcategory);
}

export function searchProducts(query: string): Product[] {
  const q = query.toLowerCase();
  return PRODUCTS.filter(p =>
    p.name.toLowerCase().includes(q) ||
    p.brand.toLowerCase().includes(q) ||
    p.subcategory.toLowerCase().includes(q)
  );
}

export function quincenal(price: number): number {
  return Math.round(price / 24);
}
