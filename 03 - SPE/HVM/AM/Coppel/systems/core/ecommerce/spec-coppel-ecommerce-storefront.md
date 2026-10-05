# spec-coppel-ecommerce-storefront

**Componente**: Coppel eCommerce Storefront — Category Listing Page (CLP)  
**Metodología**: Spec Driven Development (SDD)  
**Versión**: 0.2.0-DRAFT  
**Fecha**: 2026-09-16  
**Autor**: alejandro.gallegos@accenture.com  
**Revisores pendientes**: Arquitecto Composable (Coppel), Tech Lead N3 (Accenture)  
**Estado**: DRAFT — pendiente validación DR-008 a DR-013  

---

## Tabla de Contenidos

1. [Propósito y Alcance](#1-propósito-y-alcance)
2. [Contexto de Negocio](#2-contexto-de-negocio)
3. [Arquitectura del Componente](#3-arquitectura-del-componente)
4. [User Stories](#4-user-stories)
5. [Contratos de API — GraphQL](#5-contratos-de-api--graphql)
6. [Modelo de Datos](#6-modelo-de-datos)
7. [Especificaciones de Comportamiento (BDD)](#7-especificaciones-de-comportamiento-bdd)
8. [Especificaciones de UI](#8-especificaciones-de-ui)
9. [Estados y Máquinas de Estado](#9-estados-y-máquinas-de-estado)
10. [Estrategia de Caché](#10-estrategia-de-caché)
11. [SEO y Metadata](#11-seo-y-metadata)
12. [Analítica y Eventos](#12-analítica-y-eventos)
13. [Accesibilidad](#13-accesibilidad)
14. [Requisitos No Funcionales](#14-requisitos-no-funcionales)
15. [Estrategia de Testing](#15-estrategia-de-testing)
16. [Manejo de Errores](#16-manejo-de-errores)
17. [Responsividad y Breakpoints](#17-responsividad-y-breakpoints)
18. [Criterios de Salida (DoD)](#18-criterios-de-salida-dod)
19. [Datos Requeridos Pendientes](#19-datos-requeridos-pendientes)
20. [Dependencias y Equipo](#20-dependencias-y-equipo)
21. [Referencia al Demo](#21-referencia-al-demo)

---

## 1. Propósito y Alcance

### 1.1 Definición

La **Category Listing Page (CLP)** es la página que muestra el catálogo de productos de una categoría o subcategoría específica en Coppel.com. Es accesible en rutas como:

```
/electronica/tv-y-video
/electronica/pantallas
/electronica/streaming
/hogar-y-muebles/sofas
/moda/zapatos-de-mujer
```

Es la página con **mayor volumen de tráfico** después del Home. En Hot Sale / Buen Fin, concentra el 60–70% de las sesiones de compra activa.

### 1.2 Alcance de este spec

**Incluido**:
- Layout completo de la CLP desktop y mobile
- Header (logo, search, utilidades, carrito)
- Barra de navegación principal y mega menú
- Hero banner de categoría
- Sidebar de filtros y categorías
- Grid de productos y Product Card
- Comportamiento del carrito (optimistic UI)
- Filtros (precio, marca, oferta, internacional)
- Ordenamiento de resultados
- Paginación e infinite scroll
- Estados de carga (skeleton UI)
- Estados de error (zero results, server error)
- Lista de deseos
- DevStack Inspector (solo en ambientes no-producción)

**Excluido** (tienen su propio spec):
- Página de detalle de producto (PDP)
- Checkout y proceso de pago
- Búsqueda con texto libre (`/buscar?q=samsung`)
- Cuenta de usuario y perfil
- BOPIS (Buy Online, Pick-up In Store) — flujo completo
- Loyalty y Crédito Coppel

### 1.3 Prioridad de desarrollo

```
MUST HAVE (MVP)       → US-001, US-002, US-003, US-004, US-006
SHOULD HAVE           → US-005, US-007, US-009, US-010
COULD HAVE            → US-008, US-011, US-012
WON'T HAVE (v1)      → US-013 (BOPIS avanzado), US-014 (comparador)
```

---

## 2. Contexto de Negocio

### 2.1 Drivers del componente

| Driver | Descripción | Urgencia |
|--------|-------------|----------|
| **Proyecto Desacople** | Reemplazar la CLP de HCL Commerce (Java/monolito) por la versión Composable (Next.js). El equipo de Coppel tiene OKR de migrar el 100% del tráfico de CLP a Composable en Q1 2027. | ALTA |
| **MTTR P1 = 20 días** | El proveedor actual (Publicis Sapient) tiene MTTR real de 20 días vs. SLA contractual de 5 días. La CLP es el componente con mayor frecuencia de tickets P1 (disponibilidad, precios incorrectos). | ALTA |
| **KPI ATC** | Add-to-Cart Rate actual en CLP es sub-óptimo. El nuevo diseño de card (precio quincenal visible, botón siempre visible, delivery info) apunta a incrementar ATC en +15%. | ALTA |
| **KPI Conversión** | 35% de usuarios que añaden al carrito no completan la compra. Filtros mejorados y la visualización de quincenal reducen la indecisión. | MEDIA |
| **Hot Sale / Buen Fin** | La CLP actual en HCL no escala horizontalmente: un pico de 5x tráfico requiere escalar el monolito completo. En Composable, solo escalan los subgraphs de catálogo y búsqueda. | ALTA |
| **$180K MXN/min de impacto** | Cada minuto de downtime de Coppel.com cuesta $180K MXN en ventas perdidas. La CLP es la puerta de entrada: su caída implica caída total del embudo. | CRÍTICA |

### 2.2 KPIs que este componente impacta directamente

| KPI | Definición | Cómo impacta la CLP | Target |
|-----|------------|---------------------|--------|
| **ATC Rate** | % de sesiones con al menos un Add-to-Cart | El botón visible en card sin hover + precio quincenal reduce la fricción de decisión | +15% vs. baseline HCL |
| **Bounce Rate CLP** | % de usuarios que llegan a CLP y salen sin interacción | Tiempo de carga (LCP ≤ 2.5s), imágenes de calidad, relevancia de productos | -10% vs. baseline |
| **Conversion Rate** | % sesiones con orden completada / sesiones totales | Mejora en el flujo CLP → PDP → Cart es la primera etapa | +8% en embudo |
| **Revenue por sesión** | Ingreso promedio por sesión activa | Upsell vía "productos relacionados" en card footer (v2) | N/D en v1 |
| **MTTR P1 CLP** | Tiempo medio de resolución de incidentes P1 en CLP | Stack Composable es más observable (Datadog APM por subgraph) | ≤ 5 días hábiles |
| **LCP** | Largest Contentful Paint (Core Web Vitals) | Afecta ranking en Google Search (SEO orgánico de categorías) | ≤ 2.5s |

### 2.3 Volumen estimado

| Métrica | Normal | Hot Sale |
|---------|--------|----------|
| Sesiones/día en CLP | ~800K | ~4M |
| Req/s en Apollo Federation (solo CLP) | ~150 | ~800 |
| Imágenes servidas/hora (Akamai) | ~12M | ~60M |
| Add-to-cart events/hora | ~45K | ~250K |

---

## 3. Arquitectura del Componente

### 3.1 Flujo completo de request

```
Usuario (Chrome, Safari, App WebView)
      │
      │ GET /electronica/tv-y-video
      ▼
┌─────────────────────────────────┐
│         Akamai CDN (Edge)        │
│  MX-GDL, MX-MEX, MX-MTY        │
│                                 │
│  Cache hit? ──YES──► serve HTML │
│       │NO                       │
└───────┼─────────────────────────┘
        │ (cache miss: forward a origen)
        ▼
┌─────────────────────────────────┐
│   Next.js SSR                   │
│   GKE: cpl-ec-dcplig-prod       │
│   Pod: composable-web-*         │
│                                 │
│   getServerSideProps()          │
│   ├── parseParams(slug)         │
│   ├── buildApolloQuery(params)  │
│   └── apolloClient.query(...)   │
└───────┬─────────────────────────┘
        │ GraphQL query
        ▼
┌─────────────────────────────────┐
│   Apollo Federation Router      │
│   /api/graphql                  │
│                                 │
│   Query planning:               │
│   ├── field: category.title     │──► subgraph: catálogo
│   ├── field: products.name      │──► subgraph: catálogo
│   ├── field: products.images    │──► subgraph: catálogo
│   ├── field: products.pricing   │──► subgraph: precios
│   ├── field: products.inventory │──► subgraph: inventario
│   └── field: products.scores    │──► subgraph: búsqueda
└─┬──────────┬────────────┬───────┘
  │          │            │
  ▼          ▼            ▼
LucidWorks  SFCC Pricing  SFCC Inventory
(catálogo   API           API
+ búsqueda)
  │          │            │
  └──────────┴────────────┘
              │ responses
              ▼
       Apollo Federation
       (query stitching)
              │ merged JSON
              ▼
       Next.js SSR
       (renderToString)
              │ HTML + __NEXT_DATA__
              ▼
       Akamai (cache + serve)
              │
              ▼
       Usuario (HTML renderizado)
              │
              │ (browser hydration)
              ▼
       React Client (interactividad)
```

### 3.2 Árbol de componentes React

```
<CategoryListingPage>
  ├── <PromoBar />
  ├── <Header>
  │     ├── <Logo />
  │     ├── <SearchBar />
  │     └── <HeaderUtils>
  │           ├── <PhoneUtil />
  │           ├── <LocationUtil />
  │           ├── <AccountUtil />
  │           └── <CartWidget count={cartCount} />
  ├── <MainNav>
  │     ├── <NavButton label="Departamentos" onClick={toggleMega} />
  │     ├── <NavButton label="Ofertas" variant="highlight" />
  │     ├── <NavButton label="Servicios" />
  │     ├── <NavButton label="Crédito Coppel" />
  │     └── <MegaMenu open={megaOpen}>
  │           ├── <MegaCol1 departments={DEPARTMENTS} />
  │           ├── <MegaCol2 subcategories={activeSubcategories} />
  │           └── <MegaCol3 items={activeItems} />
  ├── <InfoBanner location="Iztapalapa, Ciudad De Mexico" />
  ├── <HeroBanner category={category} />
  ├── <Breadcrumb items={breadcrumb} />
  └── <PageLayout>
        ├── <Sidebar>
        │     ├── <CategoryNav subcategories={subcategories} />
        │     └── <FilterPanel>
        │           ├── <PriceFilter min={priceMin} max={priceMax} />
        │           ├── <ToggleFilter label="Oferta" />
        │           ├── <ToggleFilter label="Color" />
        │           └── <ToggleFilter label="Marca" />
        └── <MainContent>
              ├── <ResultsHeader title={category.title} count={count} />
              ├── <SortBar sortBy={sortBy} view={view} />
              └── <ProductsGrid>
                    └── <ProductCard product={p} /> × N
```

### 3.3 Responsabilidades por subgraph

| Subgraph | Campo GraphQL | Servicio upstream | TTL cache |
|----------|---------------|------------------|-----------|
| `catalogo` | `product.id`, `name`, `brand`, `slug`, `images`, `categorySlug` | LucidWorks PIM | 5 min |
| `busqueda` | `product.relevanceScore`, `category.totalCount`, `category.facets` | LucidWorks Search | 60s |
| `precios` | `product.pricing.*` | SFCC Pricing API | 30s |
| `inventario` | `product.inventory.*` | SFCC Inventory API | 15s |
| `carrito` | `cart.*` (mutation) | SFCC Basket API | Sin caché |

---

## 4. User Stories

### US-001 — Navegar categoría (MUST HAVE)

**Como** comprador en Coppel.com  
**Quiero** ver los productos de una categoría específica  
**Para** descubrir qué opciones existen antes de decidir qué comprar  

**Criterios de aceptación detallados**:

```
AC-001-01: La URL /electronica/tv-y-video retorna HTTP 200
AC-001-02: La página muestra el título "TV y video" en un <h1>
AC-001-03: El conteo de resultados es visible (ej. "9,213 resultados") bajo el h1
AC-001-04: Se renderizan mínimo 8 product cards en la primera vista (pageSize default = 20)
AC-001-05: Las imágenes de producto se cargan con loading="lazy" excepto las primeras 4 (above-the-fold)
AC-001-06: El LCP es ≤ 2.5s medido en 4G throttled (Lighthouse)
AC-001-07: El breadcrumb muestra: Inicio › Electrónica › TV y video
AC-001-08: Si slug no existe, retorna HTTP 404 con página amigable (no 500)
AC-001-09: En SSR, los datos vienen en <script id="__NEXT_DATA__"> para hydration
AC-001-10: El meta title es "TV y video — Electrónica | coppel.com"
```

---

### US-002 — Ver precio y quincena (MUST HAVE)

**Como** comprador con crédito Coppel  
**Quiero** ver el precio de contado Y el precio quincenal sin hacer cálculos  
**Para** saber si el producto cabe en mi quincena de inmediato  

**Criterios de aceptación detallados**:

```
AC-002-01: Cada card muestra "Precio de contado" como label antes del precio
AC-002-02: El precio de contado se muestra en formato $X,XXX (separador de miles, sin decimales para MXN enteros)
AC-002-03: Si isOffer=true, el precio original se muestra tachado en color gris junto al precio actual
AC-002-04: La quincena se muestra como "Desde $XXX quincenal"
AC-002-05: Fórmula quincenal: Math.ceil(precioContado / 24) — nunca Math.round ni Math.floor
AC-002-06: Ejemplo de validación: precio=$1,099 → quincenal=Math.ceil(1099/24)=$46 (no $45.79)
AC-002-07: Si precioOriginal === precioContado (no hay oferta), NO se muestra el tachado
AC-002-08: Los precios vienen del subgraph "precios" (SFCC Pricing API), no del subgraph catálogo
AC-002-09: Si SFCC Pricing API falla para un producto, se muestra "Precio no disponible" y NO se bloquea la carga del resto de la página
AC-002-10: La fuente del precio es visible y es la misma para todos los contextos (sin diferencias de precio por sesión en el listado, personalización es en PDP)
```

---

### US-003 — Identificar productos internacionales (MUST HAVE)

**Como** comprador  
**Quiero** saber si un producto viene de fuera de México antes de hacer clic  
**Para** tomar una decisión informada sobre tiempos de entrega y costos adicionales  

**Criterios de aceptación detallados**:

```
AC-003-01: Si product.isInternational=true, se muestra el badge "Internacional" en el card
AC-003-02: El badge "Internacional" es de color azul claro (#EEF4FF, texto #1565C0) — diferente al badge "Oferta" (rojo)
AC-003-03: Los badges "Oferta" e "Internacional" pueden coexistir en el mismo card
AC-003-04: El campo isInternational viene del subgraph catálogo (LucidWorks PIM)
AC-003-05: En la sidebar existe un filtro "Internacional" (∨ colapsado por default) que permite filtrar por este atributo
AC-003-06: El tooltip del badge "Internacional" (hover en desktop) muestra "Producto importado — puede tener costos adicionales de importación"
AC-003-07: En mobile, el tooltip se omite (no hay hover) — la información está en PDP
```

---

### US-004 — Agregar al carrito desde el listado (MUST HAVE)

**Como** comprador que ya decidió qué quiere  
**Quiero** agregar un producto al carrito directamente desde la lista  
**Para** no perder tiempo entrando al detalle del producto  

**Criterios de aceptación detallados**:

```
AC-004-01: El botón "Agregar al carrito" está visible en TODOS los cards sin necesidad de hover
AC-004-02: El botón es full-width dentro del card, con estilo pill (border-radius: 28px)
AC-004-03: Al hacer clic, el botón cambia inmediatamente a estado "Agregando..." (disabled, spinner)
AC-004-04: El contador del carrito en el header se incrementa en +1 en ≤ 100ms (optimistic update)
AC-004-05: El toast "✅ Producto agregado al carrito" aparece en ≤ 400ms y desaparece en 2.4s
AC-004-06: La mutation AddToCart se ejecuta en background (no bloquea la UI)
AC-004-07: Si AddToCart resuelve con success=true, el botón regresa a estado normal
AC-004-08: Si AddToCart resuelve con success=false o hay timeout (>5s), se hace rollback: contador -1, toast de error "Error al agregar. Intenta de nuevo."
AC-004-09: Si el producto no tiene stock (inventory.available=false), el botón se muestra como "Sin stock" (disabled, gris)
AC-004-10: Si el usuario no tiene sesión, hacer clic en "Agregar al carrito" abre un modal de login/registro y después del login regresa al carrito con el producto
AC-004-11: El carrito persiste en Firestore para usuarios autenticados (sincronizado entre web y app móvil)
AC-004-12: Para usuarios no autenticados, el carrito se almacena en localStorage con TTL=24h
AC-004-13: Un mismo producto puede agregarse múltiples veces — cada clic incrementa quantity en 1, no duplica el item en el carrito
```

---

### US-005 — Filtrar por precio (SHOULD HAVE)

**Como** comprador con presupuesto definido  
**Quiero** filtrar los productos por rango de precio  
**Para** ver solo lo que puedo pagar  

**Criterios de aceptación detallados**:

```
AC-005-01: La sidebar muestra campos "$ Mínimo" y "$ Máximo" bajo la sección "Filtrar por > Precio"
AC-005-02: Los campos solo aceptan números enteros positivos (validación client-side)
AC-005-03: Si priceMin > priceMax, se muestra error inline "El precio mínimo no puede ser mayor al máximo" y el filtro NO se aplica
AC-005-04: Al hacer clic en "Aplicar" (o presionar Enter), se ejecuta nueva query con priceMin y priceMax
AC-005-05: La URL se actualiza con parámetros: /electronica/tv-y-video?precioMin=5000&precioMax=20000
AC-005-06: El botón "back" del navegador regresa al estado sin filtros (URL sin params)
AC-005-07: Los parámetros de URL son persistentes: al compartir el link, el receptor ve los mismos filtros aplicados
AC-005-08: Con filtros activos, Akamai NO cachea el response (Cache-Control: no-store para requests con query params de filtro)
AC-005-09: El conteo de resultados se actualiza para reflejar el total post-filtro
AC-005-10: Si el rango de precio no tiene resultados, se muestra "Sin productos en este rango de precio" con sugerencia de ampliar el rango
AC-005-11: Hay un botón "Limpiar filtros" que resetea todos los filtros activos
AC-005-12: El filtro de precio también afecta el facet de marcas — si se filtra por $5k-$20k, la lista de marcas disponibles en sidebar se actualiza para mostrar solo marcas con productos en ese rango
```

---

### US-006 — Navegar subcategorías (MUST HAVE)

**Como** comprador que quiere afinar su búsqueda  
**Quiero** navegar a subcategorías sin volver al menú principal  
**Para** ir directo a la sección que me interesa  

**Criterios de aceptación detallados**:

```
AC-006-01: La sidebar muestra las subcategorías de la categoría actual con su conteo
AC-006-02: Ejemplo: en "TV y video" → Accesorios (6804), Películas/Blu-ray (1258), Pantallas (586), Barras de sonido (415), Streaming (150)
AC-006-03: Al hacer clic en una subcategoría, la URL cambia a /electronica/{slug-subcategoria}
AC-006-04: La transición es via Next.js router.push() — NO hay reload completo de página
AC-006-05: Durante la transición, se muestra el skeleton de la grid (no spinner de página completa)
AC-006-06: El breadcrumb se actualiza para reflejar la subcategoría activa
AC-006-07: La subcategoría activa en el sidebar se muestra con font-weight: 700 y color var(--blue)
AC-006-08: Los conteos de subcategorías se actualizan si hay filtros activos (precio, marca, etc.)
AC-006-09: La navegación entre subcategorías es registrada como evento analítico (ver Sección 12)
```

---

### US-007 — Mega menú de departamentos (SHOULD HAVE)

**Como** comprador nuevo o que quiere explorar  
**Quiero** ver todos los departamentos y categorías de Coppel  
**Para** descubrir qué más vende la tienda y navegar libremente  

**Criterios de aceptación detallados**:

```
AC-007-01: El botón "⊞ Departamentos" abre el mega menú (toggle)
AC-007-02: El mega menú se cierra al hacer clic en el overlay oscuro que cubre el resto de la página
AC-007-03: El mega menú se cierra al presionar Escape
AC-007-04: El mega menú tiene 3 columnas: Departamentos (col 1), Subcategorías (col 2), Sub-subcategorías (col 3)
AC-007-05: Col 1 tiene grupos: Hogar, Tecnología, Ropa y zapatos, Accesorios, Salud
AC-007-06: Al hacer clic en un departamento de col 1, col 2 y col 3 se actualizan con las subcategorías correspondientes sin delay
AC-007-07: La subcategoría activa (la que el usuario está viendo) aparece resaltada en el mega menú
AC-007-08: Col 2 tiene un link "Ver ofertas" en la parte superior que lleva a la sección de Ofertas del departamento
AC-007-09: Col 3 tiene links a subcategorías específicas que al ser clicados cierran el mega menú y navegan a la CLP correspondiente
AC-007-10: En mobile, el mega menú es un drawer lateral que aparece desde la izquierda (no el menú de 3 columnas)
AC-007-11: El mega menú tiene max-height con scroll interno en cada columna (no agranda la viewport)
```

---

### US-008 — Lista de deseos (COULD HAVE)

**Como** comprador que no quiere comprar aún  
**Quiero** guardar productos en mi lista de deseos  
**Para** revisarlos cuando esté listo para comprar  

**Criterios de aceptación detallados**:

```
AC-008-01: Cada card tiene un botón de corazón (🤍) en la esquina superior derecha, sobre la imagen
AC-008-02: Al hacer clic en el corazón, si el usuario NO está autenticado → modal de login (mismo que AC-004-10)
AC-008-03: Al hacer clic en el corazón, si el usuario SÍ está autenticado → corazón se llena (❤️) con animación de escala 1.2 → 1.0 en 200ms
AC-008-04: El estado del corazón se persiste en Firestore bajo el documento del usuario
AC-008-05: Si el producto ya está en la lista de deseos (viene del SSR pre-cargando wishlist del usuario), el corazón aparece lleno desde el inicio
AC-008-06: El conteo de productos en la lista de deseos es visible en el icono de cuenta del header (badge pequeño)
AC-008-07: Al volver a hacer clic en un corazón lleno, el producto se ELIMINA de la lista de deseos (toggle)
AC-008-08: La operación de wishlist NO afecta el carrito ni el precio
AC-008-09: En mobile, el botón de corazón es touch target de mínimo 44x44px
```

---

### US-009 — Ordenar resultados (SHOULD HAVE)

**Como** comprador con criterio definido  
**Quiero** ordenar los productos por relevancia, precio o descuento  
**Para** ver primero los que más me interesan  

**Criterios de aceptación detallados**:

```
AC-009-01: El selector de ordenamiento muestra las opciones: Relevancia (default), Precio: menor a mayor, Precio: mayor a menor, Mejor calificados, Mayor descuento
AC-009-02: Al cambiar la opción, se ejecuta nueva query con el sort field correspondiente
AC-009-03: La URL se actualiza con el parámetro: ?ordenar=precio-asc
AC-009-04: El sort se combina con filtros: priceMin + priceMax + sortBy son todos params independientes
AC-009-05: "Relevancia" usa el scoring de LucidWorks (combinación de clicks, conversiones, ATC rate por producto y tiempo de permanencia en PDP)
AC-009-06: El ordenamiento activo se muestra en el selector con el texto correspondiente (no siempre "Relevancia")
```

---

### US-010 — Paginación / Infinite Scroll (SHOULD HAVE)

**Como** comprador que quiere ver más productos  
**Quiero** cargar más resultados sin recargar la página  
**Para** continuar explorando el catálogo sin interrupciones  

**Criterios de aceptación detallados**:

```
AC-010-01: La primera página carga pageSize=20 productos
AC-010-02: Cuando el usuario scrollea hasta 200px del final del grid, se ejecuta automáticamente la query para page=2
AC-010-03: Los nuevos productos se APPEND al grid existente (no reemplaza)
AC-010-04: Durante la carga de la siguiente página, se muestran 4 skeleton cards al final del grid
AC-010-05: Si no hay más productos (page*pageSize >= totalCount), se muestra "Has llegado al final del catálogo" y NO hay más fetching
AC-010-06: El infinite scroll está implementado con IntersectionObserver (no scroll event listener)
AC-010-07: La URL NO cambia con el infinite scroll (la paginación es transparente para el usuario)
AC-010-08: Si el usuario recarga la página, regresa a la primera página (no persiste la posición)
AC-010-09: Para categorías con < 20 productos, no hay infinite scroll — se muestran todos de una vez
```

---

### US-011 — Skeleton UI y Loading States (SHOULD HAVE)

**Como** comprador en conexión lenta  
**Quiero** ver inmediatamente que la página está cargando algo  
**Para** no pensar que el sitio está roto  

**Criterios de aceptación detallados**:

```
AC-011-01: En SSR, el HTML tiene la estructura completa de la página pero con datos reales (no skeleton)
AC-011-02: Al navegar entre subcategorías (client-side), se muestra un skeleton grid de 8 cards con animación pulse
AC-011-03: El skeleton de cada card mantiene las mismas dimensiones que el card real (no hay layout shift — CLS=0)
AC-011-04: El sidebar NO muestra skeleton — mantiene la última categoría mientras cargan los nuevos resultados
AC-011-05: El header, nav y hero NO muestran skeleton — son estáticos durante la transición
AC-011-06: Si la query tarda más de 3s, se muestra un mensaje "Cargando productos..." encima del skeleton
AC-011-07: Si la query tarda más de 10s, se muestra el estado de error (ver US-012)
```

---

### US-012 — Estado de error (MUST HAVE)

**Como** comprador  
**Quiero** ver un mensaje claro cuando algo sale mal  
**Para** saber qué pasó y qué puedo hacer  

**Criterios de aceptación detallados**:

```
AC-012-01: Si Apollo Federation retorna error, se muestra la sección "No pudimos cargar los productos" con botón "Intentar de nuevo"
AC-012-02: El estado de error NO oculta el header, nav, sidebar ni footer — solo el grid
AC-012-03: El botón "Intentar de nuevo" re-ejecuta la query exactamente igual sin recargar la página
AC-012-04: Si hay error parcial (ej. precios fallaron pero catálogo OK), se muestran los productos sin precio con el texto "Precio no disponible"
AC-012-05: Los errores de red se logean como eventos en Datadog RUM (ver Sección 12)
AC-012-06: En producción, el mensaje de error NO expone detalles técnicos (stack trace, URLs de API)
AC-012-07: En staging (devstack activo), el toast de error sí muestra el detalle técnico del error de Apollo
```

---

## 5. Contratos de API — GraphQL

### 5.1 Schema de tipos

```graphql
# ─── PRODUCT TYPES ───────────────────────────────────────────

type Product {
  id: ID!                          # SKU Coppel (ej. "CPL-1234567")
  brand: String!                   # Marca (ej. "Roku")
  name: String!                    # Nombre completo
  slug: String!                    # URL-friendly (ej. "roku-express-3930")
  categorySlug: String!            # Categoría raíz
  subcategorySlug: String          # Subcategoría (nullable)
  isOffer: Boolean!                # Tiene descuento activo
  isInternational: Boolean!        # Importación
  subgraphOrigin: SubgraphOrigin!  # Origen del dato
  images: [ProductImage!]!         # Mínimo 1, máximo 10
  pricing: ProductPricing!
  inventory: ProductInventory!
  relevanceScore: Float            # 0-1, de LucidWorks (solo en contexto de búsqueda)
  rating: ProductRating
}

enum SubgraphOrigin {
  BUSQUEDA   # vino de LucidWorks search subgraph
  CATALOGO   # vino de LucidWorks catalog subgraph
}

type ProductImage {
  url: String!       # URL absoluta (CDN Akamai, https://cdn.coppel.com/...)
  alt: String!       # Texto alternativo para accesibilidad
  width: Int!
  height: Int!
  isPrimary: Boolean!
  format: ImageFormat!
}

enum ImageFormat {
  AVIF
  WEBP
  JPG
  PNG
}

type ProductPricing {
  currentPrice: Float!    # Precio de contado (MXN)
  originalPrice: Float!   # Precio antes del descuento
  currency: String!       # "MXN"
  quincenal: Int!         # ceil(currentPrice / 24)
  discountPercent: Int    # % de descuento (nullable si no hay oferta)
  validUntil: String      # ISO 8601 — cuándo expira la oferta
}

type ProductInventory {
  available: Boolean!
  quantityOnHand: Int            # nullable — no siempre visible al usuario
  deliveryDays: Int!             # días hábiles para entrega a domicilio
  storePickupAvailable: Boolean! # BOPIS disponible
  nearestStore: String           # nombre de tienda más cercana con stock
}

type ProductRating {
  average: Float!   # 0.0 - 5.0
  count: Int!       # número de reseñas
}

# ─── CATEGORY TYPES ──────────────────────────────────────────

type Category {
  id: ID!
  slug: String!
  title: String!
  totalCount: Int!
  subcategories: [Subcategory!]!
  breadcrumb: [BreadcrumbItem!]!
  heroBanner: HeroBanner
  facets: [Facet!]!              # filtros disponibles (precio range, marcas, etc.)
  products(
    page: Int = 1
    pageSize: Int = 20
    filters: ProductFilters
    sort: ProductSort
  ): ProductConnection!
}

type Subcategory {
  slug: String!
  label: String!
  count: Int!
  iconUrl: String
}

type BreadcrumbItem {
  label: String!
  href: String!
}

type HeroBanner {
  imageUrl: String!         # URL de imagen hero (Akamai)
  imageAlt: String!
  headline: String!
  subheadline: String
  ctaLabel: String!
  ctaHref: String!
  backgroundColor: String   # hex — fallback si imagen no carga
}

type Facet {
  key: String!              # ej. "precio", "marca", "color"
  label: String!            # ej. "Precio", "Marca", "Color"
  type: FacetType!
  options: [FacetOption!]!
}

enum FacetType {
  RANGE     # precio (min/max)
  CHECKBOX  # marca, color, oferta
  BOOLEAN   # internacional
}

type FacetOption {
  value: String!
  label: String!
  count: Int!
  selected: Boolean!
}

type ProductConnection {
  edges: [ProductEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type ProductEdge {
  node: Product!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# ─── FILTER AND SORT TYPES ───────────────────────────────────

input ProductFilters {
  priceMin: Float
  priceMax: Float
  isOffer: Boolean
  isInternational: Boolean
  brands: [String!]
  colors: [String!]
  inStock: Boolean
}

input ProductSort {
  field: SortField!
  order: SortOrder!
}

enum SortField {
  RELEVANCE
  PRICE
  RATING
  DISCOUNT_PERCENT
  NEWEST
}

enum SortOrder {
  ASC
  DESC
}

# ─── CART TYPES ───────────────────────────────────────────────

type Cart {
  id: ID!
  sessionId: String!
  itemCount: Int!
  items: [CartItem!]!
  subtotal: Money!
  userId: ID          # null si no autenticado
}

type CartItem {
  productId: ID!
  productName: String!
  quantity: Int!
  unitPrice: Float!
  totalPrice: Float!
  imageUrl: String!
}

type Money {
  amount: Float!
  currency: String!  # "MXN"
}

type CartMutationResult {
  success: Boolean!
  cart: Cart
  error: CartError
}

type CartError {
  code: CartErrorCode!
  message: String!
  productId: ID
}

enum CartErrorCode {
  OUT_OF_STOCK
  MAX_QUANTITY_EXCEEDED
  SESSION_EXPIRED
  SFCC_UNAVAILABLE
  UNKNOWN
}

# ─── WISHLIST TYPES ───────────────────────────────────────────

type WishlistMutationResult {
  success: Boolean!
  inWishlist: Boolean!
  wishlistCount: Int!
  error: String
}
```

### 5.2 Query — Listado de categoría (operación principal)

```graphql
query GetCategoryListing(
  $categorySlug: String!
  $page: Int = 1
  $pageSize: Int = 20
  $filters: ProductFilters
  $sort: ProductSort = { field: RELEVANCE, order: DESC }
) {
  category(slug: $categorySlug) {
    id
    slug
    title
    totalCount
    heroBanner {
      imageUrl
      imageAlt
      headline
      subheadline
      ctaLabel
      ctaHref
    }
    breadcrumb {
      label
      href
    }
    subcategories {
      slug
      label
      count
    }
    facets {
      key
      label
      type
      options {
        value
        label
        count
        selected
      }
    }
    products(page: $page, pageSize: $pageSize, filters: $filters, sort: $sort) {
      totalCount
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          id
          brand
          name
          slug
          isOffer
          isInternational
          subgraphOrigin
          images {
            url
            alt
            width
            height
            isPrimary
            format
          }
          pricing {
            currentPrice
            originalPrice
            currency
            quincenal
            discountPercent
          }
          inventory {
            available
            deliveryDays
            storePickupAvailable
          }
          rating {
            average
            count
          }
        }
      }
    }
  }
}
```

**Variables de ejemplo**:
```json
{
  "categorySlug": "tv-video",
  "page": 1,
  "pageSize": 20,
  "filters": {
    "priceMin": 500,
    "priceMax": 10000,
    "isOffer": true
  },
  "sort": {
    "field": "PRICE",
    "order": "ASC"
  }
}
```

**Response esperado (estructura)**:
```json
{
  "data": {
    "category": {
      "id": "cat-tv-video",
      "slug": "tv-video",
      "title": "TV y video",
      "totalCount": 9213,
      "heroBanner": {
        "imageUrl": "https://cdn.coppel.com/banners/tv-video-hero.webp",
        "imageAlt": "Tu pantallota te espera en Coppel",
        "headline": "¡Tu pantallota te espera en Coppel!",
        "subheadline": "Formatos enormes de 85\" a 110\"",
        "ctaLabel": "Descúbrelas aquí",
        "ctaHref": "/electronica/pantallas"
      },
      "products": {
        "totalCount": 9213,
        "pageInfo": { "hasNextPage": true, "endCursor": "cursor_20" },
        "edges": [
          {
            "node": {
              "id": "CPL-1001234",
              "brand": "Roku",
              "name": "Roku Express 3930 Streaming HD Purple — S010",
              "slug": "roku-express-3930-streaming-hd-purple-s010",
              "isOffer": true,
              "isInternational": false,
              "subgraphOrigin": "BUSQUEDA",
              "images": [
                {
                  "url": "https://cdn.coppel.com/products/roku-express-3930.avif",
                  "alt": "Roku Express 3930 Streaming HD Purple",
                  "width": 400,
                  "height": 400,
                  "isPrimary": true,
                  "format": "AVIF"
                }
              ],
              "pricing": {
                "currentPrice": 1099,
                "originalPrice": 1499,
                "currency": "MXN",
                "quincenal": 46,
                "discountPercent": 27
              },
              "inventory": {
                "available": true,
                "deliveryDays": 3,
                "storePickupAvailable": true
              },
              "rating": { "average": 4.3, "count": 1247 }
            }
          }
        ]
      }
    }
  }
}
```

### 5.3 Mutation — Agregar al carrito

```graphql
mutation AddToCart($productId: ID!, $quantity: Int = 1, $sessionId: String!) {
  addToCart(input: {
    productId: $productId
    quantity: $quantity
    sessionId: $sessionId
  }) {
    success
    cart {
      id
      itemCount
      subtotal {
        amount
        currency
      }
    }
    error {
      code
      message
      productId
    }
  }
}
```

### 5.4 Mutation — Toggle lista de deseos

```graphql
mutation ToggleWishlist($productId: ID!, $userId: ID!) {
  toggleWishlist(input: { productId: $productId, userId: $userId }) {
    success
    inWishlist
    wishlistCount
    error
  }
}
```

### 5.5 Query — Página siguiente (infinite scroll)

```graphql
query GetMoreProducts(
  $categorySlug: String!
  $after: String!           # cursor de la última página cargada
  $pageSize: Int = 20
  $filters: ProductFilters
  $sort: ProductSort
) {
  category(slug: $categorySlug) {
    products(after: $after, pageSize: $pageSize, filters: $filters, sort: $sort) {
      totalCount
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          # mismos campos que GetCategoryListing
          id brand name slug isOffer isInternational subgraphOrigin
          images { url alt width height isPrimary format }
          pricing { currentPrice originalPrice currency quincenal discountPercent }
          inventory { available deliveryDays storePickupAvailable }
          rating { average count }
        }
      }
    }
  }
}
```

---

## 6. Modelo de Datos

### 6.1 Product (TypeScript — frontend)

```typescript
// Tipos del frontend — mapean el response de GraphQL a la UI

export interface Product {
  id: string;
  brand: string;
  name: string;
  slug: string;
  categorySlug: string;
  isOffer: boolean;
  isInternational: boolean;
  subgraphOrigin: 'BUSQUEDA' | 'CATALOGO';
  images: ProductImage[];
  pricing: ProductPricing;
  inventory: ProductInventory;
  rating?: ProductRating;
}

export interface ProductImage {
  url: string;
  alt: string;
  width: number;
  height: number;
  isPrimary: boolean;
  format: 'AVIF' | 'WEBP' | 'JPG' | 'PNG';
}

export interface ProductPricing {
  currentPrice: number;
  originalPrice: number;
  currency: 'MXN';
  quincenal: number;          // SIEMPRE Math.ceil(currentPrice / 24)
  discountPercent?: number;   // undefined si no hay oferta
}

export interface ProductInventory {
  available: boolean;
  deliveryDays: number;
  storePickupAvailable: boolean;
}

export interface ProductRating {
  average: number;  // 0.0 - 5.0
  count: number;
}

// Helpers

export function formatMXN(amount: number): string {
  return amount.toLocaleString('es-MX', {
    style: 'currency',
    currency: 'MXN',
    maximumFractionDigits: 0,
  });
}

export function calcQuincenal(price: number): number {
  return Math.ceil(price / 24);
}
```

### 6.2 Category State (React Context / Zustand)

```typescript
export interface CategoryPageState {
  // data
  category: Category | null;
  products: Product[];
  totalCount: number;
  
  // pagination
  currentPage: number;
  pageSize: number;
  hasNextPage: boolean;
  endCursor: string | null;
  
  // filters
  filters: ProductFilters;
  activeFacets: FacetOption[];
  
  // sort
  sortBy: SortField;
  sortOrder: SortOrder;
  
  // loading states
  isLoadingInitial: boolean;   // primera carga SSR
  isLoadingMore: boolean;      // infinite scroll
  isLoadingFiltered: boolean;  // cambio de filtros
  
  // errors
  error: CategoryError | null;
  
  // cart (global)
  cartCount: number;
  cartId: string | null;
  
  // wishlist (global, requiere autenticación)
  wishlistIds: Set<string>;
}

export interface CategoryError {
  type: 'NETWORK' | 'APOLLO' | 'NOT_FOUND' | 'PARTIAL';
  message: string;
  retryable: boolean;
  affectedFields?: string[];  // para error parcial: qué campos fallaron
}
```

### 6.3 LucidWorks Product Schema (AS-IS — DR-008 pendiente)

> **DATO-REQUERIDO DR-008**: El schema real de LucidWorks para el catálogo Coppel no ha sido confirmado. Los campos a continuación son estimados a partir de la documentación pública de LucidWorks y el contexto del Q&A N3.

```json
{
  "id": "CPL-1001234",
  "sku": "1001234",
  "name": "Roku Express 3930 Streaming HD Purple — S010",
  "brand": "Roku",
  "category_path": "Electrónica/TV y video/Streaming",
  "category_slug": "tv-video",
  "subcategory_slug": "streaming",
  "is_offer": true,
  "is_international": false,
  "status": "active",
  "images": [
    {
      "url": "https://cdn.coppel.com/products/1001234-primary.avif",
      "type": "primary",
      "width": 400,
      "height": 400
    }
  ],
  "attributes": {
    "color": "Morado",
    "connectivity": "Wi-Fi",
    "resolution": "HD"
  },
  "_score": 0.92,
  "created_at": "2024-11-15T00:00:00Z",
  "updated_at": "2026-09-10T12:34:56Z"
}
```

### 6.4 SFCC Pricing API Response (AS-IS)

```json
{
  "productId": "CPL-1001234",
  "prices": [
    {
      "type": "list",
      "value": 1499.00,
      "currency": "MXN"
    },
    {
      "type": "sale",
      "value": 1099.00,
      "currency": "MXN",
      "validFrom": "2026-09-01T00:00:00Z",
      "validTo": "2026-09-30T23:59:59Z"
    }
  ]
}
```

**Mapeo al modelo frontend**:
- `currentPrice` = price donde `type="sale"` (si existe y está en validez) o `type="list"`
- `originalPrice` = price donde `type="list"`
- `isOffer` = existe un price `type="sale"` activo
- `quincenal` = Math.ceil(currentPrice / 24) — **calculado en frontend**, no viene de SFCC

> **DATO-REQUERIDO DR-009**: Confirmar si el cálculo de quincenal es `price/24` o tiene lógica financiera de BanCoppel (tasa de interés, comisiones).

---

## 7. Especificaciones de Comportamiento (BDD)

### Escenario 0: Ocurre Incidente — Add-to-Cart API error en producción

> Este escenario modela el ciclo de vida de un **incidente P1 real**: desde el primer síntoma hasta la observabilidad en Datadog. Es el punto de partida del runbook operacional (ver `runbook-coppel-ecommerce-storefront.md`).

```gherkin
Feature: Manejo de incidente en producción — Add-to-Cart API

  Background:
    Given el ambiente es PRODUCCIÓN (https://www.coppel.com)
    And hay ~150 req/s llegando a la CLP (tráfico normal de tarde-noche)
    And el subgraph "carrito" está desplegado y saludable (uptime 100% últimas 6h)

  Scenario: SFCC Basket API empieza a retornar 503 — incidente P1

    # ─────────────────────────────────────────────────────────────
    # FASE 0: TRIGGER DEL INCIDENTE
    # ─────────────────────────────────────────────────────────────

    When SFCC Basket API (endpoint POST /baskets/{basketId}/items) empieza
         a retornar HTTP 503 con el body:
         """
         {
           "fault": {
             "type": "ServiceUnavailableException",
             "message": "BASKET_SERVICE_OVERLOADED: upstream connection pool exhausted",
             "detail": {
               "code": "BASKET_POOL_EXHAUSTED",
               "retryAfter": 30,
               "affectedRegion": "us-central1",
               "requestId": "sfcc-req-20260916-183422-a9f3c"
             }
           }
         }
         """
    And el error comenzó a las 18:34:22 UTC (13:34:22 hora México)

    # ─────────────────────────────────────────────────────────────
    # FASE 1: LO QUE VE EL USUARIO (impacto inmediato)
    # ─────────────────────────────────────────────────────────────

    Then el usuario que hace clic en "Agregar al carrito" ve:
      | t=0ms    | botón cambia a "Agregando..." + spinner (optimistic) |
      | t=0ms    | contador del carrito incrementa en +1 (optimistic)   |
      | t=5100ms | timeout alcanzado (5s sin respuesta de SFCC)          |
      | t=5100ms | ROLLBACK: contador regresa a valor original            |
      | t=5100ms | botón regresa a "Agregar al carrito"                  |
      | t=5200ms | toast rojo aparece: "❌ Error al agregar. Intenta de nuevo." |
      | t=7600ms | toast desaparece automáticamente                       |

    And el usuario NO ve ningún stack trace ni detalle técnico del error
    And el usuario NO pierde los productos que ya tenía en el carrito

    # ─────────────────────────────────────────────────────────────
    # FASE 2: LO QUE VE EL SISTEMA (observabilidad)
    # ─────────────────────────────────────────────────────────────

    And el subgraph "carrito" loguea en Datadog APM:
         """
         [ERROR] AddToCart mutation failed
         correlationId: txn-cpl-20260916-183427-b2e1a
         productId: "CPL-1001234"
         sessionId: "sess_xyz789"
         upstream: SFCC Basket API
         upstreamStatus: 503
         upstreamBody.fault.detail.code: "BASKET_POOL_EXHAUSTED"
         latencyMs: 5003
         retryAttempts: 0
         userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4)"
         """

    And Datadog RUM recibe el evento desde el browser del usuario:
         """
         {
           "action": "add_to_cart_error",
           "product_id": "CPL-1001234",
           "error_code": "SFCC_UNAVAILABLE",
           "latency_ms": 5003,
           "rollback_applied": true
         }
         """

    # ─────────────────────────────────────────────────────────────
    # FASE 3: DETECCIÓN AUTOMÁTICA (alerting)
    # ─────────────────────────────────────────────────────────────

    And a los 2 minutos del inicio del incidente (18:36 UTC):
      | Métrica                         | Valor normal | Valor en incidente |
      | add_to_cart_error_rate          | < 0.5%       | 98.4%              |
      | add_to_cart_latency_p95_ms      | 350ms        | 5,003ms            |
      | sfcc_basket_upstream_error_rate | < 1%         | 100%               |

    And Datadog dispara la alerta "[P1] Coppel CLP — Add-to-Cart error rate > 50%"
    And la alerta llega al canal #coppel-composable-alerts en Slack con:
         """
         🔴 P1 ALERT — AddToCart failure rate: 98.4%
         Subgraph: carrito
         Upstream: SFCC Basket API
         Error: BASKET_POOL_EXHAUSTED (HTTP 503)
         First seen: 2026-09-16T18:34:22Z
         Dashboard: https://app.datadoghq.com/apm/traces?service=subgraph-carrito
         Runbook: /runbook-coppel-ecommerce-storefront.md#incidente-basket-api
         """

    # ─────────────────────────────────────────────────────────────
    # FASE 4: IMPACTO EN NEGOCIO
    # ─────────────────────────────────────────────────────────────

    And mientras el incidente persiste:
      | KPI              | Impacto                                             |
      | ATC Rate         | cae de ~2.1% a ~0.03% (solo clicks antes del error) |
      | Revenue perdido  | ~$180,000 MXN / minuto (estimado — ver Sección 2.1)  |
      | add_to_cart_count| cae de ~45K/hr a ~0 eventos exitosos                |
      | Bounce Rate CLP  | +34% vs. baseline (usuarios abandonan al ver error)  |

    # ─────────────────────────────────────────────────────────────
    # FASE 5: RESOLUCIÓN ESPERADA
    # ─────────────────────────────────────────────────────────────

    When el equipo de SFCC restaura el connection pool a las 18:41 UTC (7 min de incidente)
    Then SFCC Basket API empieza a retornar HTTP 201 normalmente
    And el próximo click en "Agregar al carrito" (t+1s) resuelve exitosamente
    And la tasa de error en Datadog regresa a < 1% en ≤ 60s
    And Datadog dispara la alerta de resolución: "[RESOLVED] Coppel CLP — Add-to-Cart recovered"
    And el MTTR del incidente queda registrado como 7 minutos
    And el equipo registra el incidente en incident-log-coppel-ecommerce-storefront.md:
         """
         INC-2026-09-16-001
         Tipo: P1 — Degradación de servicio (Add-to-Cart no disponible)
         Duración: 7 minutos (18:34 – 18:41 UTC)
         Causa raíz: SFCC Basket API connection pool exhausted (BASKET_POOL_EXHAUSTED)
         Impacto: ~$1.26M MXN en revenue perdido (7 min × $180K MXN/min)
         Acción correctiva: Aumentar pool size en SFCC de 200 a 500 conexiones (DR-015)
         """
```

---

### Escenario 1: Carga inicial SSR — happy path

```gherkin
Feature: Carga de Category Listing Page

  Background:
    Given el usuario está en un browser con conexión 4G
    And el usuario navega a /electronica/tv-y-video

  Scenario: Primera carga sin filtros
    When Next.js recibe la request GET /electronica/tv-y-video
    Then Next.js ejecuta getServerSideProps()
    And Apollo Federation ejecuta GetCategoryListing con:
      | categorySlug | "tv-video" |
      | page         | 1          |
      | pageSize     | 20         |
      | filters      | null       |
      | sort         | RELEVANCE DESC |
    And el subgraph "catalogo" llama a LucidWorks con query categorySlug=tv-video
    And el subgraph "busqueda" llama a LucidWorks search API para scoring
    And el subgraph "precios" llama a SFCC Pricing API con los 20 product IDs
    And el subgraph "inventario" llama a SFCC Inventory API con los 20 product IDs
    And Apollo Federation hace query stitching de los 4 responses
    And Next.js renderiza el HTML con los datos
    And el HTML resultante incluye <script id="__NEXT_DATA__"> con los datos
    And Next.js retorna HTTP 200 con el HTML
    And Akamai cachea el response con header Cache-Control: public, max-age=60
    And el browser muestra la página con LCP ≤ 2.5s

  Scenario: Carga con filtros activos (URL con params)
    Given el usuario navega a /electronica/tv-y-video?precioMin=1000&precioMax=5000
    When Next.js ejecuta getServerSideProps()
    Then Apollo ejecuta GetCategoryListing con filters: { priceMin: 1000, priceMax: 5000 }
    And el response tiene Cache-Control: no-store (filtros activos no se cachean)
    And el conteo de resultados refleja solo productos en ese rango
```

### Escenario 2: Add-to-cart — flujo completo

```gherkin
Feature: Agregar producto al carrito

  Scenario: Add-to-cart exitoso — usuario autenticado
    Given el usuario está autenticado (sessionId en cookie)
    And el usuario ve la CLP con productos cargados
    And el producto "CPL-1001234" tiene inventory.available=true
    When el usuario hace clic en "Agregar al carrito" del producto "CPL-1001234"
    Then el botón cambia a "Agregando..." con spinner en ≤ 50ms
    And el contador del carrito en el header incrementa de N a N+1 en ≤ 100ms
    And en background se ejecuta mutation AddToCart con { productId: "CPL-1001234", quantity: 1, sessionId: "sess_abc" }
    And Apollo Federation enruta la mutation al subgraph "carrito"
    And el subgraph "carrito" hace POST /baskets/{basketId}/items a SFCC Basket API
    And SFCC responde HTTP 201 con el basket actualizado
    And el subgraph retorna success=true, cart.itemCount=N+1
    And el botón regresa a "Agregar al carrito" en ≤ 100ms
    And el toast "✅ Producto agregado al carrito" aparece en ≤ 400ms del clic
    And el toast desaparece automáticamente en 2.4s
    And el evento "add_to_cart" es enviado a Datadog RUM (ver Sección 12)

  Scenario: Add-to-cart con falla de SFCC
    Given el usuario está en la CLP
    When el usuario hace clic en "Agregar al carrito"
    And la mutation AddToCart falla (SFCC retorna HTTP 503 después de 5s)
    Then el contador del carrito hace rollback de N+1 a N
    And el botón regresa a "Agregar al carrito"
    And el toast muestra "❌ Error al agregar. Intenta de nuevo." en rojo
    And el evento "add_to_cart_error" es enviado a Datadog RUM con error.code=SFCC_UNAVAILABLE
    And el error es logueado en Datadog APM con correlationId

  Scenario: Add-to-cart sin stock
    Given el producto "CPL-9999" tiene inventory.available=false
    When el card se renderiza
    Then el botón muestra "Sin stock" en color gris (#9E9E9E)
    And el botón tiene disabled=true (no responde a clics)
    And NO hay badge de carrito al hacer clic
```

### Escenario 3: Filtro de precio

```gherkin
Feature: Filtro de precio

  Scenario: Aplicar filtro de precio válido
    Given el usuario está en /electronica/tv-y-video con 9,213 resultados
    When el usuario ingresa priceMin=5000 y priceMax=20000
    And el usuario hace clic en "Aplicar"
    Then Next.js navega a /electronica/tv-y-video?precioMin=5000&precioMax=20000
    And se muestra el skeleton de 8 cards durante la carga
    And Apollo ejecuta GetCategoryListing con filters: { priceMin: 5000, priceMax: 20000 }
    And el conteo de resultados se actualiza (ej. "243 resultados")
    And todos los productos mostrados tienen pricing.currentPrice entre 5000 y 20000
    And el botón "Limpiar filtros" aparece en la sidebar
    And el evento "filter_applied" es enviado a Datadog RUM con { filter: "precio", min: 5000, max: 20000 }

  Scenario: Filtro de precio inválido (min > max)
    When el usuario ingresa priceMin=20000 y priceMax=5000
    And el usuario hace clic en "Aplicar"
    Then NO se ejecuta ninguna query
    And se muestra el mensaje de error inline "El precio mínimo no puede ser mayor al máximo"
    And el mensaje de error es color #D32F2F con ícono de advertencia

  Scenario: Filtro sin resultados
    When el usuario aplica un rango de precio que no tiene productos (ej. priceMin=1 y priceMax=50)
    Then el grid muestra el estado vacío:
      "Sin productos en este rango de precio"
      "Prueba ampliar el rango o explorar otras categorías"
      [Botón: "Limpiar filtros"]
```

### Escenario 4: Navegación entre subcategorías

```gherkin
Feature: Navegación de subcategorías en sidebar

  Scenario: Navegar a subcategoría con datos
    Given el usuario está en /electronica/tv-y-video
    When el usuario hace clic en "Pantallas (586)" en la sidebar
    Then Next.js ejecuta router.push('/electronica/pantallas')
    And el skeleton de 8 cards aparece durante la transición
    And Apollo ejecuta GetCategoryListing con categorySlug="pantallas"
    And el H1 cambia de "TV y video" a "Pantallas"
    And el breadcrumb cambia a: Inicio › Electrónica › Pantallas
    And la subcategoría "Pantallas" se activa en la sidebar (font-weight: 700)
    And el evento "subcategory_navigate" es enviado a Datadog RUM

  Scenario: URL compartida con subcategoría activa
    Given el usuario abre directamente la URL /electronica/pantallas
    When Next.js ejecuta getServerSideProps()
    Then el categorySlug parseado es "pantallas"
    And la CLP muestra los productos de Pantallas desde SSR (no hay skeleton visible)
```

### Escenario 5: Mega menú

```gherkin
Feature: Mega menú de departamentos

  Scenario: Abrir y cerrar mega menú
    Given el usuario está en cualquier CLP
    When el usuario hace clic en "⊞ Departamentos"
    Then el mega menú aparece con 3 columnas
    And el overlay oscuro cubre el resto de la página
    And el botón "⊞ Departamentos" muestra un chevron "▲" (en lugar de "▾")

    When el usuario hace clic en el overlay
    Then el mega menú se cierra
    And el overlay desaparece
    And el foco del teclado regresa al botón "⊞ Departamentos"

    When el mega menú está abierto y el usuario presiona Escape
    Then el mega menú se cierra

  Scenario: Navegar por departamentos en el mega menú
    Given el mega menú está abierto
    And la columna 2 muestra subcategorías de "Electrónica" (departamento activo)
    When el usuario hace clic en "🛋️ Hogar y Muebles" en la columna 1
    Then la columna 2 se actualiza con subcategorías de "Hogar y Muebles"
    And la columna 3 se actualiza con sub-subcategorías correspondientes
    And el cambio ocurre sin delay visible (datos predefinidos, no fetch)
```

---

## 8. Especificaciones de UI

### 8.1 Layout general (desktop ≥ 1024px)

```
┌──────────────────────────────────────────────────────────────────┐
│  PROMO BAR · yellow #FFD600 · height: 38px                       │
│  ¡Anímate a consentirte con las increíbles ofertas! [Descúbrelas]│
├──────────────────────────────────────────────────────────────────┤
│  HEADER · blue #003087 · height: 62px · sticky (top: 0)          │
│  [●●● Coppel] [  Search Bar (max 680px)  🔍] [📞][📍][👤][🛒 N]│
├──────────────────────────────────────────────────────────────────┤
│  NAV · blue-nav #002070 · height: 43px · sticky (top: 62px)      │
│  [⊞Dept▾][🏷Ofertas][Servicios][💳Crédito]  ←left  right→     │
│            [🏪Tiendas][📦Pedidos][❓FAQ][Vende en Coppel]       │
├──────────────────────────────────────────────────────────────────┤
│  INFO BANNER · blue light · height: 42px (dismissable)           │
│  ℹ️ Estás viendo para Iztapalapa, Ciudad De Mexico          [✕] │
├──────────────────────────────────────────────────────────────────┤
│  HERO BANNER · max-width: 1280px · border-radius: 10px          │
│  height: 160px (fallback) o 240px (imagen completa)              │
├──────────────────────────────────────────────────────────────────┤
│  BREADCRUMB · height: 32px · font-size: 13px                     │
│  Inicio › Electrónica › TV y video                              │
├───────────────────────┬──────────────────────────────────────────┤
│  SIDEBAR · 285px      │  MAIN CONTENT · flex: 1                  │
│  white · rounded-8px  │                                          │
│  border #E0E0E0       │  H1 "TV y video"  9,213 resultados      │
│                       │  [Ordenar: Relevancia ▾] [⊞] [≡]        │
│  Categoría            │  ─────────────────────────────────────── │
│  · Accesorios (6804)  │  PRODUCTS GRID                          │
│  · Películas (1258)   │  grid-cols: auto-fill, minmax(195px,1fr) │
│  · Pantallas (586)    │  gap: 14px                               │
│  · Barras (415)       │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │
│  · Streaming (150)    │  │ Card │ │ Card │ │ Card │ │ Card │  │
│                       │  └──────┘ └──────┘ └──────┘ └──────┘  │
│  Filtrar por          │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │
│  Precio ∧             │  │ Card │ │ Card │ │ Card │ │ Card │  │
│  [Min] [Max] [Aplicar]│  └──────┘ └──────┘ └──────┘ └──────┘  │
│  Oferta ∨             │                                          │
│  Color  ∨             │  [⊙ Cargando más...] ← visible cuando   │
│  Marca  ∨             │  IntersectionObserver activa scroll     │
│  Internacional ∨      │                                          │
└───────────────────────┴──────────────────────────────────────────┤
│  FOOTER · dark #0D1117 · 4 columnas                              │
└──────────────────────────────────────────────────────────────────┘
```

### 8.2 Anatomía del Product Card — detalle completo

```
┌───────────────────────────────┐  ← border: 1px solid #E0E0E0
│                         [🤍] │  ← wishlist btn: absolute, top:8, right:8
│                               │     size: 30x30px, border-radius: 50%
│                               │     bg: rgba(255,255,255,.9)
│      [imagen producto]        │  ← height: 175px, bg: #FAFAFA
│    (object-fit: contain)      │     padding: 14px
│                               │     lazy loading excepto primeras 4
│                               │
├───────────────────────────────┤
│  Oferta  Internacional        │  ← badges, gap: 8px
│  (rojo)  (azul claro)         │     badge Oferta: color #E53935, font-weight:700
│                               │     badge Internacional: bg #EEF4FF, text #1565C0
│  Nombre completo del          │  ← font-size: 13px, line-height: 1.4
│  producto en hasta 2 líneas   │     overflow: hidden, -webkit-line-clamp: 2
│                               │     color: #222
│  Precio de contado            │  ← label: font-size: 11px, color: #666
│  $1,099        $1,499         │  ← precio actual: font-size: 22px, font-weight:700
│  (precio)    (tachado)        │     color offer: #E53935 | color normal: #222
│                               │     precio viejo: font-size: 12px, color: #666
│  Desde $46 quincenal          │  ← font-size: 12px, color: #666
│                               │
│  🚚  🏪                       │  ← íconos delivery, font-size: 18px, color: #003087
│                               │     tooltip: "Envío a domicilio" / "Retira en tienda"
│  [ Agregar al carrito ]       │  ← btn: full-width, bg: #001A5B, color: #fff
│                               │     border-radius: 28px, padding: 11px
│                               │     font-size: 13px, font-weight: 700
│  ☐ Comparar                   │  ← checkbox + label: font-size: 12px, color: #003087
│                               │     accent-color: #003087
└───────────────────────────────┘

Hover state del card:
  box-shadow: 0 6px 24px rgba(0,0,0,.12)
  transform: translateY(-3px)
  transition: all 150ms ease

Estado "Sin stock":
  .btn-cart → background: #9E9E9E, cursor: not-allowed
  texto: "Sin stock"

Estado "Agregando...":
  .btn-cart → background: #001A5B, opacity: 0.7
  texto: "Agregando..."
  spinner: 16px, border-color: rgba(255,255,255,.3), border-top-color: #fff
```

### 8.3 Skeleton UI — Product Card

```
┌───────────────────────────────┐
│                               │
│  ████████████████████████     │  ← skeleton img: height 175px
│  ████████████████████████     │     background: linear-gradient(
│  ████████████████████████     │       90deg, #F0F0F0 0%, #E0E0E0 50%, #F0F0F0 100%)
│                               │     animation: pulse 1.5s ease-in-out infinite
├───────────────────────────────┤
│  ██████  ████████████         │  ← badge skeletons: height 18px
│                               │
│  ██████████████████           │  ← name line 1: height 13px
│  ████████████████             │  ← name line 2: height 13px
│                               │
│  ██████                       │  ← label precio
│  ████████████  ██████         │  ← precio + tachado
│  ████████████████             │  ← quincenal
│                               │
│  ██████████████████████████   │  ← botón skeleton: height 40px, border-radius 28px
└───────────────────────────────┘
```

### 8.4 Tokens de diseño

| Token CSS | Valor | Usos |
|-----------|-------|------|
| `--blue` | `#003087` | Links, íconos, accents |
| `--blue-dk` | `#001A5B` | Botón "Agregar al carrito" |
| `--blue-lt` | `#1A4BA8` | Hover del botón carrito |
| `--blue-nav` | `#002070` | Barra de navegación |
| `--yellow` | `#FFD600` | Promo bar, search button, logo (acento 1) |
| `--yellow-dk` | `#E6C000` | Hover del search button |
| `--offer` | `#E53935` | Badge Oferta, precio actual con descuento |
| `--green` | `#1A8A2E` | Toast de éxito |
| `--grey-bg` | `#F5F5F5` | Fondo de página |
| `--grey-brd` | `#E0E0E0` | Bordes de cards, sidebar, separadores |
| `--text` | `#222222` | Texto principal |
| `--muted` | `#666666` | Texto secundario (label precio, quincenal) |
| `--info-bg` | `#EEF4FF` | Fondo del info banner, badge Internacional |
| `--info-brd` | `#4285F4` | Borde izquierdo del info banner |

### 8.5 Tipografía

| Rol | Font | Size | Weight | Color |
|-----|------|------|--------|-------|
| Page H1 | System (-apple-system, Segoe UI, Roboto) | 26px | 700 | #222 |
| Card name | System | 13px | 400 | #222 |
| Price current | System | 22px | 700 | #E53935 (oferta) / #222 |
| Price original | System | 12px | 400 | #666, line-through |
| Quincenal | System | 12px | 400 | #666 |
| Badge Oferta | System | 12px | 700 | #E53935 |
| Nav buttons | System | 13px | 500 | rgba(255,255,255,.9) |
| Sidebar links | System | 13px | 400 | #003087 |
| Breadcrumb | System | 13px | 400 | #003087 (links) / #333 (actual) |

---

## 9. Estados y Máquinas de Estado

### 9.1 Estado del botón "Agregar al carrito"

```
                ┌─────────────────────────────────────────────┐
                │                                             │
   inventory    │  IDLE                                       │
   available    │  "Agregar al carrito"                       │
   = false      │  bg: #001A5B                                │
      │         │                                             │
      ▼         │           onClick()                         │
  DISABLED      │              │                              │
  "Sin stock"   │              ▼                              │
  bg: #9E9E9E   │         OPTIMISTIC                          │
  cursor:       │         "Agregando..."                      │
  not-allowed   │         bg: #001A5B, opacity:.7             │
                │         spinner visible                     │
                │         carrito counter +1                  │
                │                                             │
                │    ┌────────────┴────────────┐             │
                │    │ ≤5s                     │ >5s timeout │
                │    ▼                         ▼             │
                │  SUCCESS                  TIMEOUT_ERROR    │
                │  cart.success=true        cart.error       │
                │                           code=SFCC_UNA    │
                │  → IDLE                   → ROLLBACK       │
                │                           counter -1       │
                │                           → IDLE           │
                │                                             │
                │    si cart.success=false                    │
                │    code=OUT_OF_STOCK → DISABLED             │
                │    code=MAX_QUANTITY → toast "Máximo X uds"│
                └─────────────────────────────────────────────┘
```

### 9.2 Estado del filtro de precio

```
    IDLE                           ACTIVE
    filtros vacíos                 filtros aplicados
    URL: /electronica/tv-video     URL: /...?precioMin=X&precioMax=Y
    count: 9,213                   count: N (post-filtro)
         │                              │
         │  usuario ingresa valores     │
         │  y hace clic "Aplicar"       │
         │         │                    │
         │         ▼                    │
         │    VALIDATING                │
         │    min > max? → error inline │
         │    min OK → LOADING          │
         │         │                    │
         │         ▼                    │
         │    LOADING                   │
         │    skeleton 8 cards          │
         │    query en flight           │
         │         │                    │
         │    ┌────┴────┐              │
         │    ▼         ▼              │
         │  ERROR    RESULTS           │
         │  retryable  count updated   │
         │             ← ────────────┘ │
         │                             │
         └──── "Limpiar filtros" ──────┘
```

### 9.3 Estado de la CLP completa (top-level)

```
LOADING_INITIAL
(SSR en progress,
solo skeleton
en client nav)
      │
      │ data OK
      ▼
READY
(productos visibles,
filtros activos/inactivos,
interacción disponible)
      │
      ├──► LOADING_MORE (infinite scroll trigger)
      │         │ data appended
      │         └──► READY
      │
      ├──► LOADING_FILTERED (nuevo filtro/sort)
      │         │ data replaced
      │         └──► READY
      │
      └──► ERROR (red failure / Apollo error)
                │ [Intentar de nuevo]
                └──► LOADING_INITIAL → READY
```

---

## 10. Estrategia de Caché

### 10.1 Capas de caché

| Capa | Sistema | TTL | Invalidación |
|------|---------|-----|--------------|
| **CDN Edge** | Akamai | 60s (CLP sin filtros) | Purge manual via Akamai API cuando Coppel actualiza precios batch |
| **CDN Edge** | Akamai | no-store (CLP con filtros) | N/A — siempre a origen |
| **Apollo Server** | In-memory (GKE pod) | 30s para catálogo | Restart del pod |
| **Subgraph precios** | Redis (GKE) | 30s | Invalidación por evento de SFCC (webhook) |
| **Subgraph inventario** | Redis (GKE) | 15s | Invalidación por evento de SFCC |
| **Subgraph catálogo** | Redis (GKE) | 5 min | Invalidación cuando LucidWorks reindexea |
| **Browser** | Next.js cache | session | N/A — no persiste entre recargas |

### 10.2 Reglas de caché por tipo de request

```
# CLP sin parámetros de filtro
GET /electronica/tv-y-video
→ Cache-Control: public, s-maxage=60, stale-while-revalidate=30
→ Akamai cachea (cache HIT después del primer request)

# CLP con filtros activos
GET /electronica/tv-y-video?precioMin=1000&precioMax=5000
→ Cache-Control: private, no-store
→ Akamai NO cachea (forward directo a GKE)

# Imágenes de producto (CDN Akamai)
GET https://cdn.coppel.com/products/*.avif
→ Cache-Control: public, max-age=86400 (24h)
→ Vary: Accept (para AVIF vs. WEBP según browser support)

# Apollo Federation queries (desde Next.js SSR)
POST /api/graphql
→ No hay HTTP cache — Apollo usa Redis internamente por tipo de subgraph
```

### 10.3 Estrategia de purge en eventos críticos

| Evento | Acción de purge |
|--------|----------------|
| Coppel actualiza precios de productos batch (diario) | Akamai API: `purge_tag: category-clp` en todas las CLP |
| LucidWorks reindexea un producto | Akamai API: `purge_url: /electronica/{categorySlug}` |
| Flash sale o campaña de Hot Sale (cambio inmediato) | Akamai API: purge de toda la cache `/*` — crítico, bajo supervisión |
| Problema detectado en precio (incidente P1) | Purge inmediato + activar `no-store` temporal en Akamai |

---

## 11. SEO y Metadata

### 11.1 Metadata por página

```typescript
// next/head content por CLP

export function generateCLPMetadata(category: Category): Metadata {
  return {
    // <title>
    title: `${category.title} — ${category.parentTitle} | coppel.com`,
    // ejemplo: "TV y video — Electrónica | coppel.com"

    // <meta name="description">
    description: `Encuentra ${category.totalCount.toLocaleString()} productos de ${category.title} en Coppel.com. `
               + `Envío a domicilio, crédito Coppel y retiro en tienda.`,

    // Open Graph
    openGraph: {
      title: `${category.title} | Coppel`,
      description: `${category.totalCount.toLocaleString()} productos disponibles`,
      image: category.heroBanner?.imageUrl,
      url: `https://www.coppel.com/electronica/${category.slug}`,
      type: 'website',
    },

    // Canonical (evitar duplicados por filtros en URL)
    alternates: {
      canonical: `https://www.coppel.com/electronica/${category.slug}`,
      // NO incluir filtros en canonical → evita index de páginas filtradas
    },

    // Robots
    robots: {
      index: true,
      follow: true,
      // páginas filtradas: index: false, follow: true
    },
  };
}
```

### 11.2 Structured Data (Schema.org)

```json
// JSON-LD inyectado en <head> de cada CLP

{
  "@context": "https://schema.org",
  "@type": "ItemList",
  "name": "TV y video",
  "description": "9213 productos en TV y video — Electrónica | Coppel",
  "url": "https://www.coppel.com/electronica/tv-y-video",
  "numberOfItems": 9213,
  "itemListElement": [
    // Primeros 10 productos (Google recomienda ≤ 10 en ItemList)
    {
      "@type": "ListItem",
      "position": 1,
      "url": "https://www.coppel.com/electronica/tv-y-video/roku-express-3930",
      "name": "Roku Express 3930 Streaming HD Purple — S010",
      "image": "https://cdn.coppel.com/products/roku-express-3930.avif",
      "offers": {
        "@type": "Offer",
        "price": "1099",
        "priceCurrency": "MXN",
        "availability": "https://schema.org/InStock"
      }
    }
    // ...9 más
  ]
}
```

### 11.3 Breadcrumb (Schema.org)

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Inicio", "item": "https://www.coppel.com" },
    { "@type": "ListItem", "position": 2, "name": "Electrónica", "item": "https://www.coppel.com/electronica" },
    { "@type": "ListItem", "position": 3, "name": "TV y video" }
  ]
}
```

---

## 12. Analítica y Eventos

Todos los eventos se envían a **Datadog RUM** (Real User Monitoring). El equipo N3 tiene acceso read-only (nivel 4) al dashboard de Datadog.

### 12.1 Catálogo de eventos

| Evento | Trigger | Propiedades |
|--------|---------|-------------|
| `page_view` | Carga de CLP | `category_slug`, `total_count`, `page_source` (SSR/CSR) |
| `product_impression` | Card visible en viewport | `product_id`, `brand`, `position`, `category_slug` |
| `add_to_cart` | Click en botón carrito (exitoso) | `product_id`, `brand`, `price`, `category_slug`, `position_in_grid` |
| `add_to_cart_error` | Fallo en mutation AddToCart | `product_id`, `error_code`, `latency_ms` |
| `add_to_wishlist` | Toggle wishlist a true | `product_id`, `brand`, `category_slug` |
| `remove_from_wishlist` | Toggle wishlist a false | `product_id` |
| `filter_applied` | Aplicar filtro de precio/marca/etc | `filter_type`, `filter_value`, `result_count` |
| `filter_cleared` | Limpiar todos los filtros | `previous_result_count` |
| `sort_changed` | Cambiar ordenamiento | `sort_by`, `sort_order` |
| `subcategory_navigate` | Click en subcategoría sidebar | `from_slug`, `to_slug` |
| `infinite_scroll_trigger` | IntersectionObserver activa | `page_loaded`, `products_count` |
| `mega_menu_open` | Click en "Departamentos" | N/A |
| `mega_menu_navigate` | Click en link del mega menú | `department`, `subcategory`, `destination_slug` |
| `search_bar_focus` | Click en barra de búsqueda | `source_category` |
| `clp_error` | Error de Apollo o network | `error_type`, `category_slug`, `retry_count` |
| `cart_view` | Click en ícono del carrito | `cart_item_count` |

### 12.2 Implementación de eventos (TypeScript)

```typescript
// lib/analytics.ts

export const analytics = {
  trackAddToCart(product: Product, position: number) {
    if (typeof window !== 'undefined' && window.DD_RUM) {
      window.DD_RUM.addAction('add_to_cart', {
        product_id: product.id,
        brand: product.brand,
        price: product.pricing.currentPrice,
        category_slug: product.categorySlug,
        position_in_grid: position,
        is_offer: product.isOffer,
        is_international: product.isInternational,
      });
    }
  },

  trackAddToCartError(productId: string, errorCode: string, latencyMs: number) {
    if (typeof window !== 'undefined' && window.DD_RUM) {
      window.DD_RUM.addError(new Error(`add_to_cart_error: ${errorCode}`), {
        product_id: productId,
        error_code: errorCode,
        latency_ms: latencyMs,
      });
    }
  },

  trackProductImpression(product: Product, position: number) {
    // Usar IntersectionObserver para disparar solo cuando el card es visible
    if (typeof window !== 'undefined' && window.DD_RUM) {
      window.DD_RUM.addAction('product_impression', {
        product_id: product.id,
        brand: product.brand,
        position,
        category_slug: product.categorySlug,
      });
    }
  },
};
```

---

## 13. Accesibilidad

### 13.1 Requisito base

**WCAG 2.1 AA** en todos los componentes. Las páginas de eCommerce tienen exposición legal en México si no cumplen WCAG 2.1 AA (Ley Federal de Telecomunicaciones y Radiodifusión, art. 189).

### 13.2 Especificaciones por componente

**Header / Search**:
- `<input>` de búsqueda tiene `aria-label="Buscar productos"`
- Botón de búsqueda tiene `aria-label="Buscar"`
- Carrito tiene `aria-label="Carrito, {N} artículos"` (actualiza dinámicamente)

**Mega menú**:
- Botón "Departamentos" tiene `aria-haspopup="true"` y `aria-expanded={megaOpen}`
- Cuando está abierto, el foco se mueve al primer ítem del menú
- Navegación completa por teclado: Tab entre columnas, Enter para activar, Escape para cerrar
- El overlay tiene `aria-hidden="true"` (no es interactivo para AT)

**Product Card**:
- `<article>` como elemento raíz del card
- Imagen con `alt` descriptivo (ej. "Roku Express 3930 Streaming HD Purple")
- Si no hay imagen: `alt=""` (decorativo) + texto visible del producto
- Precio: `<span aria-label="Precio de contado $1,099, antes $1,499">` para screen readers
- Quincenal: `<span aria-label="Desde $46 por quincena">`
- Botón carrito: `aria-label="Agregar Roku Express 3930 al carrito"` (incluye nombre del producto)
- Botón wishlist: `aria-label="Agregar a lista de deseos" aria-pressed={inWishlist}`
- Estado sin stock: botón con `aria-disabled="true"` (no `disabled` — para que AT lo lea)

**Filtros**:
- `<fieldset>` y `<legend>` para cada grupo de filtros
- Inputs de precio con `aria-label="Precio mínimo"` y `aria-label="Precio máximo"`
- Error de validación: `aria-live="polite"` para anunciar errores de filtro

**Toast**:
- `role="status" aria-live="polite"` para que screen readers lo anuncien sin interrumpir

**Skeleton**:
- Skeleton cards tienen `aria-hidden="true"` y `aria-busy="true"` en el grid container

### 13.3 Contraste de colores

| Elemento | Fondo | Texto | Ratio | ¿Pasa AA? |
|----------|-------|-------|-------|-----------|
| Card name | #FFFFFF | #222222 | 16.1:1 | ✅ |
| Price current (oferta) | #FFFFFF | #E53935 | 4.6:1 | ✅ (mínimo 4.5:1) |
| Badge Oferta | #FFFFFF | #E53935 | 4.6:1 | ✅ |
| Badge Internacional | #EEF4FF | #1565C0 | 5.9:1 | ✅ |
| Quincenal / muted | #FFFFFF | #666666 | 5.7:1 | ✅ |
| Botón carrito | #001A5B | #FFFFFF | 17.4:1 | ✅ |
| Nav text | #002070 | rgba(255,255,255,.9) | 14.1:1 | ✅ |
| Price old (tachado) | #FFFFFF | #666666 | 5.7:1 | ✅ |

---

## 14. Requisitos No Funcionales

### 14.1 Performance — Core Web Vitals

| Métrica | Target | Medición | Bloqueo CI |
|---------|--------|----------|------------|
| **LCP** | ≤ 2.5s | Lighthouse, 4G throttled, mobile | LCP > 3.0s |
| **CLS** | ≤ 0.1 | Lighthouse | CLS > 0.25 |
| **INP** | ≤ 200ms | Chrome CrUX | INP > 500ms |
| **FCP** | ≤ 1.8s | Lighthouse | FCP > 2.5s |
| **TTFB** | ≤ 600ms | Lighthouse | TTFB > 1.0s |
| **TBT** | ≤ 200ms | Lighthouse | TBT > 400ms |

### 14.2 Performance — Backend

| Métrica | Target | Medición |
|---------|--------|----------|
| Latencia Apollo Federation p50 | ≤ 120ms | Datadog APM |
| Latencia Apollo Federation p95 | ≤ 300ms | Datadog APM |
| Latencia LucidWorks p95 | ≤ 80ms | Datadog APM |
| Latencia SFCC Pricing p95 | ≤ 150ms | Datadog APM |
| Latencia SFCC Inventory p95 | ≤ 100ms | Datadog APM |
| Throughput CLP (normal) | 150 req/s | GKE metrics |
| Throughput CLP (Hot Sale peak) | 800 req/s | GKE HPA |
| Cache hit rate Akamai (CLP sin filtros) | ≥ 85% | Akamai Dashboard |

### 14.3 Disponibilidad y SLOs

| Ambiente | SLO | SLA | Error budget/mes |
|----------|-----|-----|-----------------|
| Producción | 99.9% | 99.5% | 43.8 min/mes |
| Staging | 99.0% | — | 7.2h/mes |

**Impacto financiero de downtime**:
- $180,000 MXN por minuto de caída de Coppel.com
- CLP representa ~40% del tráfico → ~$72,000 MXN/min de impacto directo

### 14.4 Escalabilidad

| Evento | Tráfico esperado | Estrategia |
|--------|-----------------|------------|
| Normal | 800K sesiones/día | 3 pods GKE, Akamai cache |
| Campaña (Día de Reyes, etc.) | 2.5M sesiones/día | 8 pods GKE, HPA activado |
| Hot Sale / Buen Fin | 4M+ sesiones/día | 15+ pods GKE, Redis cluster, Akamai shield, pre-cache manual |

**GKE HPA Configuration**:
```yaml
# estimado — confirmar con equipo infra Coppel
spec:
  scaleTargetRef:
    name: composable-web
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: 65
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: 70
```

### 14.5 Seguridad

| Requisito | Implementación |
|-----------|----------------|
| HTTPS obligatorio | Akamai fuerza HTTPS, HSTS max-age=31536000 |
| Headers de seguridad | CSP, X-Frame-Options: DENY, X-Content-Type-Options: nosniff |
| Rate limiting | Akamai: 100 req/s por IP → desafío JavaScript; 200 req/s → bloqueo temporal |
| No datos PCI en scope | La CLP no procesa pagos; checkout está en dominio separado con PCI scope |
| mTLS interno | Apollo Federation ↔ subgraphs vía mTLS en GKE service mesh |
| Sin secretos en cliente | Las API keys de LucidWorks y SFCC son server-side only (env vars en GKE) |
| Sanitización de params | categorySlug y filtros de URL son parseados y validados server-side antes de query |
| Protección XSS | Next.js escapa todo output por default; `dangerouslySetInnerHTML` está PROHIBIDO |
| Dependencias | npm audit en cada PR; 0 vulnerabilidades críticas (CVSS ≥ 7.0) para merge |

---

## 15. Estrategia de Testing

### 15.1 Pirámide de testing

```
                    ┌───────────────────┐
                    │    E2E Tests      │  Playwright · 15 escenarios
                    │   (15 escenarios) │  Tiempo: ~8min en CI
                    ├───────────────────┤
                  ┌─┤  Integration Tests├─┐  Apollo mock · 30 casos
                  │ │   (30 casos)      │ │  Tiempo: ~3min en CI
                ┌─┤─┤─── Unit Tests ───┤─┤─┐  Jest+RTL · 80+ casos
                │ │ │   (80+ casos)    │ │ │  Tiempo: ~2min en CI
                └─┴─┴───────────────────┴─┴─┘
```

### 15.2 Unit Tests (Jest + React Testing Library)

```typescript
// Casos obligatorios por componente:

// ProductCard.test.tsx
describe('ProductCard', () => {
  test('renders product name, brand, and prices', () => { ... });
  test('shows "Oferta" badge when isOffer=true', () => { ... });
  test('hides "Oferta" badge when isOffer=false', () => { ... });
  test('shows "Internacional" badge when isInternational=true', () => { ... });
  test('calculates quincenal as Math.ceil(price/24)', () => { ... });
  test('formats price as MXN with thousands separator', () => { ... });
  test('shows crossed-out original price when isOffer=true', () => { ... });
  test('does NOT show crossed-out price when isOffer=false', () => { ... });
  test('shows "Sin stock" button when inventory.available=false', () => { ... });
  test('disables button when inventory.available=false', () => { ... });
  test('fires onAddToCart with correct productId on button click', () => { ... });
  test('shows loading state on button while adding', () => { ... });
});

// CartButton.test.tsx
describe('CartButton optimistic update', () => {
  test('increments counter immediately on click', () => { ... });
  test('shows success toast within 400ms', () => { ... });
  test('rolls back counter on mutation error', () => { ... });
  test('shows error toast on mutation failure', () => { ... });
  test('toast disappears after 2400ms', () => { ... });
});

// PriceDisplay.test.tsx
describe('PriceDisplay', () => {
  test.each([
    [1099, 46],    // ceil(1099/24) = ceil(45.79) = 46
    [690, 29],     // ceil(690/24)  = ceil(28.75) = 29
    [7699, 321],   // ceil(7699/24) = ceil(320.79) = 321
    [999, 42],     // ceil(999/24)  = ceil(41.625) = 42
    [24, 1],       // ceil(24/24)   = 1 (precio mínimo)
  ])('calculates quincenal($price) = $expected', (price, expected) => {
    expect(calcQuincenal(price)).toBe(expected);
  });
});

// PriceFilter.test.tsx
describe('PriceFilter', () => {
  test('shows error when min > max', () => { ... });
  test('does not submit when validation fails', () => { ... });
  test('clears error when values are corrected', () => { ... });
  test('updates URL params on valid submit', () => { ... });
});
```

### 15.3 Integration Tests (Apollo MockProvider)

```typescript
// Casos con GraphQL mocked:

describe('CategoryListingPage integration', () => {
  test('renders products from GetCategoryListing response', async () => {
    // mock: devuelve 8 productos de "tv-video"
    // assert: 8 cards visibles, título "TV y video", count correcto
  });

  test('shows skeleton during loading', async () => {
    // mock: delayed response de 500ms
    // assert: skeleton visible durante el delay, datos después
  });

  test('shows error state when Apollo returns error', async () => {
    // mock: Apollo error (network error)
    // assert: "No pudimos cargar los productos" visible
    // assert: botón "Intentar de nuevo" visible
  });

  test('retries query on "Intentar de nuevo" click', async () => {
    // mock: first call fails, second call succeeds
    // assert: después del retry, productos visibles
  });

  test('shows "Sin stock" on card when inventory.available=false', async () => {
    // mock: product con available=false
    // assert: botón "Sin stock" con disabled=true
  });

  test('infinite scroll triggers next page query', async () => {
    // mock: page 1 con hasNextPage=true
    // trigger: simular IntersectionObserver
    // assert: GetMoreProducts ejecutado con after=cursor_20
    // assert: nuevos productos appended al grid (no replace)
  });
});
```

### 15.4 E2E Tests (Playwright)

```typescript
// playwright/tests/clp.spec.ts

test.describe('Category Listing Page', () => {

  test('full page load — TV y video', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    await expect(page.locator('h1')).toContainText('TV y video');
    await expect(page.locator('.products-grid .card')).toHaveCount(20);
    await expect(page.locator('.page-count')).toContainText('resultados');
  });

  test('LCP under 2.5s', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    const metrics = await page.evaluate(() => {
      return new Promise(resolve => {
        new PerformanceObserver(list => {
          const entries = list.getEntries();
          resolve(entries[entries.length - 1].startTime);
        }).observe({ type: 'largest-contentful-paint', buffered: true });
      });
    });
    expect(metrics).toBeLessThan(2500);
  });

  test('add to cart — success flow', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    const firstCard = page.locator('.card').first();
    const cartCount = page.locator('#cart-count');
    const initialCount = parseInt(await cartCount.textContent() || '0');
    await firstCard.locator('.btn-cart').click();
    await expect(cartCount).toContainText(String(initialCount + 1));
    await expect(page.locator('.toast')).toBeVisible();
    await expect(page.locator('.toast')).toContainText('Producto agregado');
  });

  test('price filter — valid range', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    await page.fill('#price-min', '5000');
    await page.fill('#price-max', '20000');
    await page.click('button:has-text("Aplicar")');
    await expect(page).toHaveURL(/precioMin=5000/);
    await expect(page).toHaveURL(/precioMax=20000/);
    await page.waitForSelector('.products-grid .card');
    // todos los precios en rango
    const prices = await page.locator('.price-now').allTextContents();
    for (const p of prices) {
      const num = parseInt(p.replace(/[^0-9]/g, ''));
      expect(num).toBeGreaterThanOrEqual(5000);
      expect(num).toBeLessThanOrEqual(20000);
    }
  });

  test('price filter — min > max shows error', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    await page.fill('#price-min', '20000');
    await page.fill('#price-max', '5000');
    await page.click('button:has-text("Aplicar")');
    await expect(page.locator('.filter-error')).toBeVisible();
    await expect(page).toHaveURL('/electronica/tv-y-video'); // URL no cambia
  });

  test('subcategory navigation', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    await page.click('a:has-text("Pantallas")');
    await expect(page).toHaveURL('/electronica/pantallas');
    await expect(page.locator('h1')).toContainText('Pantallas');
    await expect(page.locator('.breadcrumb')).toContainText('Pantallas');
  });

  test('mega menu open/close with keyboard', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    await page.click('#dept-btn');
    await expect(page.locator('#mega-menu')).toBeVisible();
    await page.keyboard.press('Escape');
    await expect(page.locator('#mega-menu')).not.toBeVisible();
  });

  test('404 for unknown category slug', async ({ page }) => {
    const response = await page.goto('/electronica/categoria-que-no-existe');
    expect(response?.status()).toBe(404);
  });

  test('accessibility — no critical violations', async ({ page }) => {
    await page.goto('/electronica/tv-y-video');
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();
    expect(accessibilityScanResults.violations.filter(v => v.impact === 'critical')).toHaveLength(0);
  });
});
```

### 15.5 Contract Tests (Apollo GraphQL Inspector)

```yaml
# .graphql-inspector.yml
schema:
  ref: main
  path: 'schema.graphql'

check:
  # Bloquear PRs que introduzcan:
  - type: BREAKING_CHANGE  # cualquier breaking change en el schema
  - type: DANGEROUS_CHANGE # cambios que pueden romper clientes

notifications:
  slack: '#coppel-composable-alerts'
```

### 15.6 Performance Tests (Lighthouse CI)

```yaml
# lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3000/electronica/tv-y-video'],
      numberOfRuns: 3,
      settings: {
        throttling: { rttMs: 150, throughputKbps: 1638.4, cpuSlowdownMultiplier: 4 },  # 4G mobile
      },
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.75 }],
        'first-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 3000 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.25 }],
        'total-blocking-time': ['error', { maxNumericValue: 400 }],
      },
    },
  },
};
```

---

## 16. Manejo de Errores

### 16.1 Matriz de errores y respuestas

| Error | Origen | Código | Mensaje usuario | Acción sistema |
|-------|--------|--------|-----------------|----------------|
| LucidWorks no disponible | Subgraph catálogo | `CATALOG_UNAVAILABLE` | "No pudimos cargar los productos. [Intentar de nuevo]" | Log Datadog, retry automático 1x |
| SFCC Pricing timeout | Subgraph precios | `PRICING_UNAVAILABLE` | Card muestra "Precio no disponible" | Productos visibles sin precio; log Datadog |
| SFCC Inventory timeout | Subgraph inventario | `INVENTORY_UNAVAILABLE` | Íconos 🚚🏪 ocultos | Productos visibles sin entrega info; log Datadog |
| Producto sin stock al agregar | SFCC Basket API | `OUT_OF_STOCK` | "Este producto se agotó" | Rollback optimistic, cambiar botón a "Sin stock" |
| Sesión expirada al agregar | SFCC Basket API | `SESSION_EXPIRED` | "Tu sesión expiró. [Renovar sesión]" | Redirigir a login, conservar intent |
| Categoría no existe | Next.js params | `NOT_FOUND` | Página 404 Coppel estilo | HTTP 404, NO 500 |
| Filtros de precio inválidos | Validación client | N/A | "El precio mínimo no puede ser mayor al máximo" | No ejecutar query |
| Network error genérico | Browser/Akamai | `NETWORK_ERROR` | "Comprueba tu conexión y [vuelve a intentarlo]" | Retry manual via botón |
| Timeout Apollo > 10s | Apollo Federation | `TIMEOUT` | "No pudimos cargar los productos. [Intentar de nuevo]" | Log Datadog priority=HIGH |

### 16.2 Comportamiento de error parcial (partial data)

Apollo Federation soporta `@inaccessible` y campos nullables. Si un subgraph falla:

```typescript
// Política de error parcial
// Si falla precios → mostrar card sin precio, NOT block toda la página
// Si falla inventario → mostrar card sin info de entrega
// Si falla catálogo → mostrar estado de error de toda la grid (sin catálogo no hay nada)
// Si falla búsqueda → mostrar catálogo sin scoring (orden default de LucidWorks)

const ErrorBoundary: React.FC = ({ children, fallback }) => {
  // Envuelve el grid y el sidebar individualmente
  // El header, nav, footer NUNCA entran en error state
};
```

### 16.3 Retry policy

| Operación | Max retries | Backoff | Timeout total |
|-----------|-------------|---------|---------------|
| GetCategoryListing (SSR) | 2 | 200ms, 500ms | 3s |
| GetCategoryListing (CSR) | 1 | 300ms | 5s |
| GetMoreProducts (scroll) | 1 | 200ms | 3s |
| AddToCart | 0 | N/A | 5s (luego rollback) |
| ToggleWishlist | 1 | 500ms | 3s |

---

## 17. Responsividad y Breakpoints

### 17.1 Breakpoints

| Breakpoint | px | Layout |
|------------|-----|--------|
| `xs` | < 480 | 1 columna, sin sidebar |
| `sm` | 480 – 767 | 2 columnas, sin sidebar |
| `md` | 768 – 1023 | 3 columnas, sidebar colapsada (off-canvas) |
| `lg` | 1024 – 1279 | 4 columnas, sidebar visible |
| `xl` | ≥ 1280 | 4–5 columnas, sidebar visible, max-width: 1280px |

### 17.2 Cambios específicos por breakpoint

**xs (mobile < 480px)**:
- Header: logo + búsqueda full-width en 2 filas; utilidades colapsadas en ícono "⋮"
- Nav: hidden (reemplazada por hamburger → drawer)
- Hero: imagen en 9:16 (portrait) o 16:9 dependiendo del asset de Akamai
- Grid: 1 columna, cards en layout horizontal (imagen izquierda, info derecha)
- Sidebar: off-canvas, activada por botón "Filtrar" fijo en bottom de pantalla
- Botón carrito: full-width sticky en bottom del card (no dentro del card)

**sm (480–767px)**:
- Grid: 2 columnas
- Header: en 1 fila con búsqueda compacta
- Sidebar: off-canvas

**md (768–1023px)**:
- Grid: 3 columnas
- Sidebar: visible colapsada (solo títulos de sección, expandir con clic)
- Mega menú: drawer desde la izquierda (no 3 columnas)

**lg/xl (≥ 1024px)**:
- Grid: 4 columnas (auto-fill, minmax(195px, 1fr))
- Sidebar: siempre visible (285px fixed width)
- Mega menú: 3 columnas horizontales

### 17.3 Imágenes responsive

```html
<!-- Product card image — adaptive formats via Akamai Image Manager -->
<picture>
  <source 
    srcset="https://cdn.coppel.com/products/{id}.avif?w=195 195w, 
            https://cdn.coppel.com/products/{id}.avif?w=390 390w"
    type="image/avif" 
    sizes="(max-width: 480px) 100vw, (max-width: 768px) 50vw, 195px"
  >
  <source 
    srcset="https://cdn.coppel.com/products/{id}.webp?w=195 195w,
            https://cdn.coppel.com/products/{id}.webp?w=390 390w"
    type="image/webp"
    sizes="(max-width: 480px) 100vw, (max-width: 768px) 50vw, 195px"
  >
  <img 
    src="https://cdn.coppel.com/products/{id}.jpg?w=195"
    alt="{product.name}"
    width="195" height="175"
    loading="lazy"  <!-- excepto primeras 4 cards: loading="eager" -->
    decoding="async"
  >
</picture>
```

---

## 18. Criterios de Salida (DoD)

### 18.1 Para considerar el componente "Done" (v1 MVP)

**Funcional**:
- [ ] US-001 a US-006 verificados con casos Playwright (E2E) en todos los escenarios Happy Path y Error Path
- [ ] US-007, US-009, US-010, US-011, US-012 verificados con casos Playwright
- [ ] Todos los unit tests pasan (cobertura ≥ 80% en componentes nuevos)
- [ ] Contract tests verdes en CI (sin breaking changes en schema)

**Performance**:
- [ ] Lighthouse CI en CI pipeline: LCP ≤ 3.0s, CLS ≤ 0.25, TBT ≤ 400ms
- [ ] Cache hit rate en staging Akamai ≥ 80%
- [ ] Latencia Apollo p95 ≤ 400ms en staging bajo carga de 50 req/s

**Accesibilidad**:
- [ ] axe-core en Playwright: 0 violations críticas (impact="critical")
- [ ] Navegación completa por teclado verificada manualmente
- [ ] Contraste de colores validado (todos los textos ≥ 4.5:1)

**Seguridad**:
- [ ] Headers de seguridad configurados y verificados con securityheaders.com (score A+)
- [ ] npm audit: 0 vulnerabilidades de severity HIGH o CRITICAL

**Documentación**:
- [ ] Este spec actualizado a versión final (sin DRAFT)
- [ ] ADR creado para cada decisión de arquitectura no trivial tomada durante implementación
- [ ] Demo `portal/coppel-demo.html` actualizado si hubo cambios de diseño
- [ ] Runbook de incidentes P1 para la CLP creado en `runbook-coppel-ecommerce-storefront.md`

**Datos Requeridos**:
- [ ] DR-008 a DR-013 resueltos (o documentados como deuda técnica aceptada)

---

## 19. Datos Requeridos Pendientes

Estos puntos son **bloqueantes para implementación productiva**. El demo (`coppel-demo.html`) usa datos simulados que los cubren temporalmente.

| ID | Pregunta | Impacto | Responsable |
|----|----------|---------|-------------|
| **DR-008** | ¿Cuál es el schema exacto de LucidWorks para el catálogo Coppel? Campos disponibles, tipos de datos, nombres exactos de atributos (ej. ¿es `is_international` o `isInternational`?) | Define el modelo de datos real del Producto; impacta el schema GraphQL del subgraph catálogo | Arquitecto Composable — Coppel |
| **DR-009** | ¿El precio quincenal es `Math.ceil(precio/24)` o hay lógica financiera de BanCoppel (tasa de interés, comisiones, CAT)? | Impacta `ProductPricing.quincenal` y US-002. Si hay CAT, el cálculo viene de SFCC y no se calcula en frontend | Equipo de Producto / BanCoppel |
| **DR-010** | ¿Qué campos del Producto son obligatorios vs. opcionales en LucidWorks? ¿Puede `images` estar vacío? | Define nullable fields en el schema GraphQL y el comportamiento de fallback en el card | Arquitecto Composable — Coppel |
| **DR-011** | ¿Cuál es el schema exacto de error de SFCC Basket API? ¿Qué códigos de error existen (OUT_OF_STOCK, MAX_QUANTITY, etc.)? | Impacta US-004 y la Matriz de Errores de la Sección 16 | SFCC team — Coppel |
| **DR-012** | ¿El 6º subgraph de Apollo (Cuenta/Loyalty) afecta el listado? ¿Hay personalización de precios o relevancia por segmento de cliente? | Puede agregar campo `personalizedPrice` al tipo Product y cambiar el query SSR | Arquitecto Composable — Coppel |
| **DR-013** | ¿Los filtros de precio, marca y color vienen de LucidWorks facets (dinámico) o son hardcoded en el frontend? | Determina si el Sidebar es dinámico (fetch de facets por categoría) o estático | Arquitecto Composable — Coppel |
| **DR-014** | ¿Cuál es el TTL real de los precios en SFCC? ¿Cada cuánto cambian los precios de contado en producción? | Determina el TTL del subgraph precios en Redis y la estrategia de purge en Akamai | SFCC team / Equipo de Pricing — Coppel |
| **DR-015** | ¿Cómo funciona la sesión del carrito para usuarios no autenticados? ¿Hay un basketId anónimo de SFCC o es solo localStorage? | Impacta US-004 y la implementación del CartContext en Next.js | SFCC team — Coppel |

---

## 20. Dependencias y Equipo

### 20.1 Dependencias técnicas

| Dependencia | Sistema | Disponibilidad actual | Contacto |
|-------------|---------|----------------------|----------|
| Apollo Federation Router | `/api/graphql` (GKE cpl-ec-dcplig-prod) | Staging disponible | Arq. Composable — Coppel |
| Subgraph Catálogo | LucidWorks PIM | DR-008 pendiente | Equipo LucidWorks — Coppel |
| Subgraph Búsqueda | LucidWorks Search | Staging con datos de prueba | Equipo LucidWorks — Coppel |
| Subgraph Precios | SFCC Pricing API | Sandbox disponible | SFCC Team — Coppel |
| Subgraph Inventario | SFCC Inventory API | Sandbox disponible | SFCC Team — Coppel |
| Subgraph Carrito | SFCC Basket API | Sandbox disponible | SFCC Team — Coppel |
| Akamai CDN | Config por Coppel Infra | Sin acceso directo N3 | Infra — Coppel |
| Datadog | APM + RUM | Acceso read-only (nivel 4) | Observabilidad — Coppel |
| Firestore | Lista de deseos | Sandbox disponible | App Backend — Coppel |
| GKE (staging) | Ambientes provistos por Coppel | Coppel provee todos los ambientes | Infra — Coppel |

### 20.2 Equipo de implementación (Accenture)

| Rol | Responsabilidad principal |
|-----|--------------------------|
| Tech Lead | Arquitectura del componente, decisiones de schema GraphQL, revisión de PRs |
| Frontend Senior (x2) | Implementación Next.js, ProductCard, filtros, infinite scroll |
| QA Engineer | E2E Playwright, Lighthouse CI, contract tests |
| DevOps / SRE | Pipeline CI/CD, Lighthouse CI gate, docker build |
| UX Designer | Validación del diseño contra el spec, actualizaciones de UI |

---

## 21. Referencia al Demo

El prototipo funcional de este componente está disponible en dos formatos:

**Local (sin servidor)**:
```
portal/coppel-demo.html
```
Abrir directamente en browser. Incluye productos reales con imágenes locales (avif/webp), DevStack Inspector, mega menú completo y todas las interacciones del carrito simuladas.

**Producción (AWS Amplify)**:
```
https://main.d2uabuyr2jhfly.amplifyapp.com
```
Deploy job #11. Includes las imágenes de producto reales desde el mismo directorio.

**Cobertura del demo por User Story**:

| US | Historia | Estado en demo |
|----|----------|---------------|
| US-001 | Navegar categoría | ✅ TV y video, Pantallas, Streaming, Barras |
| US-002 | Ver precio y quincena | ✅ Precio de contado + quincenal visible en todos los cards |
| US-003 | Identificar internacionales | ✅ Badge "Internacional" en Roku Ultra y Fire TV |
| US-004 | Agregar al carrito | ✅ Optimistic counter, toast 2.4s, simulado (no SFCC real) |
| US-005 | Filtrar por precio | ✅ Sidebar con Min/Max (solo visual en demo, no filtra resultados) |
| US-006 | Navegar subcategorías | ✅ Sidebar links cambian la grid |
| US-007 | Mega menú | ✅ 3 columnas, navegación entre departamentos |
| US-008 | Lista de deseos | ⚠️ Corazón visual solo, sin persistencia |
| US-009 | Ordenar resultados | ⚠️ Selector visible, sort no implementado en demo |
| US-010 | Infinite scroll | ⬜ No implementado (datos limitados) |
| US-011 | Skeleton UI | ⬜ No implementado en demo |
| US-012 | Estado de error | ⬜ No implementado en demo |

El **DevStack Inspector** (botón ⚡ en esquina inferior derecha) simula:
- Subgraph activo (catálogo / búsqueda / carrito alternando según interacción)
- Cache Akamai (MISS en primer load, HIT en subcategoría cacheada)
- Timeline de request (Akamai → Apollo → LucidWorks → SFCC → Total)
- GKE Pod ID (rota entre 3 pods simulando balanceo de carga)
- Trace ID de Datadog (para correlación con APM)

---

*Este spec es un documento vivo. Las versiones se gestionan en git junto al código del componente.*  
*Última actualización: 2026-09-16 · v0.2.0-DRAFT*  
*Próxima revisión: Al resolver DR-008 a DR-013 con el equipo de Coppel*  
*Referencia: DT-PLAT-001, DT-TRANS-001, ADR-COPPEL-001..004*
