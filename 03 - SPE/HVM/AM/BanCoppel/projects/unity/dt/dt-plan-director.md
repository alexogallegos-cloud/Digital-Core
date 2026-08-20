# DT Plan Director — Unity R4 · Producto TDC P4900
> Digital Twin de gobierno del programa. Gestión transversal por producto, no por proveedor.
> Versión: 1.0.0 · Fuentes: brain.db v1.0.0 · brain.db (plan_progress, milestones, risks, track_rag) · 2026-08-11

---

## 1. Contexto — El dolor del cliente

El estado actual del programa Unity R4 opera en **silos por proveedor y por plataforma**: cada equipo (BPC/SmartVista, Appware/Apolo, AppWhere/APP, CAT, SIWEB) gestiona su propio avance, sus propias fechas, y sus propios riesgos de forma independiente. Los KPIs se reportan por track tecnológico, no por capacidad de negocio entregada.

El objetivo del Plan Director es reemplazar ese modelo por **gestión transversal por producto**: el producto es **TDC P4900 (Tarjeta de Crédito)** y la unidad de medición es su disponibilidad completa para el go-live de enero 2027. Un solo plan, un set de KPIs, una cadencia de reporte integrada.

**Implicación práctica**: el semáforo del programa no es el promedio de los semáforos de cada proveedor. Es la respuesta a una sola pregunta: *¿Está TDC P4900 en condiciones de llegar a producción en enero 2027 con la funcionalidad must comprometida?*

---

## 2. Modelo de gestión por producto

### Jerarquía de medición

```
Producto: TDC P4900 (Tarjeta de Crédito)
├── Capacidades must: 43 User Stories must (SmartVista=11 · APP=15 · CAT=9 · SIWEB=0 · Apolo=11 · sin track=0+)
├── Integraciones: 18 cross-track (API + Batch + Evento)
├── Entornos: DEV · QA · UAT · SIT
└── Componentes técnicos por track (son el cómo, no el qué):
    ├── SmartVista (BPC) — procesador de tarjeta
    ├── Apolo (Appware) — canal digital core
    ├── APP (AppWhere) — aplicación móvil
    ├── CAT — canales adicionales transaccionales
    └── SIWEB — banca por internet
```

### Semáforo de TDC P4900

El semáforo del producto es el **peor RAG entre todos los tracks** que tienen User Stories must, más los 3 factores transversales:

| Factor | Criterio VERDE | Criterio AMARILLO | Criterio ROJO |
|--------|---------------|-------------------|---------------|
| Avance global | Dentro de ±5pp del esperado | Rezago 5–15pp | Rezago >15pp |
| Tracks must sin proveedor | 0 | — | ≥ 1 |
| Bloqueadores críticos abiertos | 0 | 1–2 | ≥ 3 |
| Entornos SIT listos | 100% | 70–99% | < 70% |

**RAG actual del producto TDC P4900**: 🔴 ROJO

- Rezago global: -13.34pp (límite: ±5pp)
- 2 tracks con User Stories must en RED (APP y CAT)
- CAT sin proveedor contratado
- 3 bloqueadores críticos abiertos (DTMs, SVFM-QA, TRNTs Pagos)

---

## 3. Estado actual (corte 2026-08-11)

### 3.1 Avance global del programa

| Indicador | Valor actual |
|-----------|-------------|
| Avance real | **20.66 %** |
| Avance esperado | 34.0 % |
| Desviación | **-13.34 pp** (retrasado) |
| Responsable de control | María Fernanda Barbosa |

### 3.2 Estado por track (producto TDC P4900)

| Track | RAG | User Stories total | User Stories must | Integraciones | Bloqueador principal |
|-------|-----|-----------|----------|---------------|----------------------|
| SmartVista | 🟡 | 22 | 11 | 7 | Maquila y Homologación Comisiones omnicanal no cierran antes del 15-Oct |
| APP | 🔴 | 18 | 15 | 4 | 6 User Stories must cierran implementación 6-20 Nov — riesgo directo sobre SIT y go-live enero |
| CAT | 🔴 | 12 | 9 | 7 | Doble bloqueo: proveedor sin contratar + DTMs sin responsable confirmado |
| SIWEB | 🟡 | 5 | 0 | — | 10 semanas de construcción desde 18-Ago llegan al 29-Oct (2 sem. después del cierre) |
| Apolo | 🟡 | 22 | 11 | — | Track en roadmap, detalle por User Story en inventario |

### 3.3 Actividades críticas retrasadas

| ID | Desviación | Descripción | Responsable |
|----|-----------|-------------|-------------|
| PP-TRNT-PAGOS | **-100 pp** | TRNTs Pagos: 0% vs 100% esperado. Bloquea contabilidad de pagos | BPC |
| PP-SVFM-QA | **-90 pp** | SVFM no instalado en QA. Bloquea pruebas de fraude del autorizador | BPC |
| PP-DTM-APPWHERE | **-57.7 pp** | DTMs Appwhere: 0% vs 57.7%. Documentación técnica mandatoria pre-desarrollo | AppWhere |
| PP-PGP-THALES | **-50 pp** | Llaves PGP DEV sin completar. Bloquea certificación layout Thales | Armando García Ortiz |
| PP-SV-1-2 | **-19.1 pp** | SV Bloque 2: Aprobación CR y Maquila bloqueadas | BPC / Armando García Ortiz |
| PP-SV-1-5 | **-17.7 pp** | SV Apificación: Mesa de Trabajo y Documento Descripciones sin iniciar | Armando Riveros |

### 3.4 Hitos del programa

| Hito | Fecha objetivo | Estado |
|------|---------------|--------|
| Cierre análisis y diseño (último track) | 2026-10-16 | 🟡 Pendiente |
| Cierre de desarrollo + Unit Testing (todos) | 2026-10-15 | 🟡 Pendiente |
| Inicio SIT — System Integration Testing | 2026-10-15 | 🔴 En riesgo |
| Pentest Cobranza (conflicto con SIT) | 2026-11-15 | 🔴 En riesgo |
| Fin SIT / Code Freeze definitivo | 2026-12-15 | 🟡 Pendiente |
| **Go-Live TDC P4900** | **2027-01-15** | 🟡 Pendiente |

---

## 4. Marco de KPIs del Plan Director

El Plan Director mide el producto, no el track. Los KPIs se reportan en la vista de TDC P4900:

### KPI 1 — Avance por capacidad de producto

| Métrica | Fórmula | Frecuencia | Owner |
|---------|---------|-----------|-------|
| % avance real vs esperado | `pct_real / pct_expected × 100` | Semanal | Líder de control |
| Desviación acumulada | `pct_real - pct_expected` (en pp) | Semanal | Líder de control |
| % User Stories must completadas por track | `must_done / must_total × 100` por track | Semanal | PM por track |

### KPI 2 — Preparación del producto para go-live

| Métrica | Umbral aceptable | Estado actual |
|---------|-----------------|---------------|
| User Stories must certificadas en SIT | = 100 % antes de 2026-12-15 | Sin iniciar |
| Integraciones validadas cross-track | = 18/18 antes de SIT | Sin iniciar |
| Entornos DEV/QA/SIT estables | = 100% de tracks | 🔴 SmartVista SVFM-QA bloqueado, CAT sin activar |

### KPI 3 — Riesgos críticos abiertos

| Métrica | Umbral VERDE | Umbral ROJO |
|---------|-------------|------------|
| Riesgos P=HIGH, I=HIGH abiertos | 0 | ≥ 1 |
| Bloqueadores críticos plan_progress | 0 | ≥ 1 |
| Tracks sin proveedor contratado | 0 | ≥ 1 |

**Estado actual**: 6 riesgos P=HIGH + I=HIGH abiertos, 4 bloqueadores críticos, 1 track sin proveedor (CAT).

### KPI 4 — Calendario integrado (anti-silos)

| Métrica | Descripción | Frecuencia |
|---------|-------------|-----------|
| Conflictos de calendario cross-track | # de fechas que se solapan entre tracks sin coordinación | Semanal |
| Dependencias cross-track sin dueño | # de integraciones sin responsable validado en ambos extremos | Semanal |
| Despliegues en Q4 coordinados | % de los 4 despliegues de Q4 con capacidad confirmada | Mensual |

---

## 5. Acciones críticas abiertas

Las siguientes 8 acciones son bloqueadoras del go-live de enero 2027. Todas son cross-track — no pueden resolverse dentro de un solo proveedor.

| # | Acción | Track afectado | Tipo | Owner sugerido | Fecha límite |
|---|--------|---------------|------|----------------|-------------|
| A1 | Contratar proveedor CAT y asignar DTMs con responsable | CAT | Gestión | BanCoppel PMO | Inmediata |
| A2 | Instalar SVFM en ambiente QA — desbloqueador de 88 reglas del autorizador | SmartVista | Infraestructura | BPC | 2026-08-31 |
| A3 | Completar TRNTs Pagos (TRNTs = Tipos de Transacción) — base de contabilidad | SmartVista | Diseño técnico | BPC | 2026-08-31 |
| A4 | Entregar llaves PGP para ambiente DEV — desbloqueador de Thales | Cross (SV) | Seguridad | Armando García Ortiz | 2026-08-31 |
| A5 | Publicar DTMs de Appwhere — documentación técnica pre-desarrollo mandatoria | APP / CAT / SIWEB | Diseño técnico | AppWhere | 2026-09-15 |
| A6 | Habilitar ambiente de prueba CAT — desbloquear infraestructura rechazada | CAT | Infraestructura | Arquitectura BanCoppel | 2026-09-01 |
| A7 | Definir calendario QA integrado SV+CAT+SIWEB — convergencia sep-nov 26 sin plan | Cross | Planeación | PMO + Líderes de QA | 2026-09-01 |
| A8 | Resolver fragmentación de capa API — latencia >10 seg en App activa en producción | APP / Apolo | Arquitectura | Apificación (Armando Riveros) | 2026-09-15 |

---

## 6. Riesgos de mayor exposición (P=HIGH · I=HIGH)

| ID | Descripción | Track | Categoría |
|----|-------------|-------|-----------|
| R01 | DTMs Appware bloquean construcción en SV, SIWEB y CAT — 54% User Stories sin delta técnico | SmartVista | Capacidad |
| R04 | Fragmentación API — latencia ya encima de 10 seg en App | Apificación | Arquitectura |
| R05 | Latencia Apolo persiste en producción — mejoras no confirmadas | Apolo | Performance |
| R10 | 4 despliegues Q4 con capacidad limitada y pruebas paralelas | Cross | Despliegue |
| R15 | Ambientes DEV/TEST SmartVista sin infraestructura SVFM — 88 reglas sin probar | SmartVista | Entornos |
| R18 | Ambiente prueba CAT bloqueado por arquitectura — múltiples áreas con SLAs independientes | CAT | Entornos |

---

## 7. Candidatos a simplificación R4.1

9 User Stories identificadas como candidatas a diferir o simplificar en una release R4.1 posterior al go-live, para proteger el calendario del producto:

- **Apolo**: 5 User Stories (alto impacto en calendario — revisar priorización con negocio)
- **SmartVista**: 4 User Stories (funcionalidad complementaria no bloqueante para TDC)

**Decisión requerida**: Business Owner de TDC P4900 debe validar y firmar la lista de diferimiento antes del 2026-09-15. Sin esta decisión, el scope sigue siendo 76 User Stories y el riesgo de calendario permanece.

---

## 8. Modelo de reporte del Plan Director

### Cadencia

| Frecuencia | Audiencia | Contenido |
|-----------|-----------|-----------|
| **Semanal** (viernes) | PMO + Líderes de track | Actualización plan_progress, RAG por track, bloqueadores nuevos, acciones críticas |
| **Quincenal** | Dirección BanCoppel + Proveedores | Dashboard cross-track, KPIs del producto, decisiones pendientes |
| **Mensual** | Comité de dirección | RAG del producto TDC P4900, forecast go-live, riesgos escal ados, hitos próximos 30 días |

### Fuente única de verdad

- **brain.db** es el repositorio central de plan, progreso, hitos, riesgos y RAG por track.
- Todo proveedor reporta contra el schema de `plan_progress` — no contra su propia hoja de control.
- El dashboard `portal/plan-director.html` es la vista oficial del Plan Director.

### Proceso anti-silos

1. Cada proveedor actualiza su columna en `plan_progress` antes del viernes a las 12:00.
2. El líder de control (María Fernanda Barbosa) valida y consolida.
3. El Plan Director publica el RAG del producto (no el de cada track) antes del viernes a las 17:00.
4. Las dependencias cross-track (`r4_integrations`) tienen responsable en ambos extremos — nunca solo en el emisor.

---

## 9. Relaciones con otros DTs del programa

| DT | Dependencia |
|----|-------------|
| [dt-cronograma.md](dt-cronograma.md) | Fechas y hitos son la fuente de este DT; Plan Director agrega la vista de producto |
| [dt-riesgos.md](dt-riesgos.md) | Riesgos individuales; Plan Director los agrega en KPI 3 |
| [dt-gobierno.md](dt-gobierno.md) | Estructura de gobernanza del programa; Plan Director define el modelo de reporte |
| [dt-vendors.md](dt-vendors.md) | Responsabilidades por proveedor; Plan Director las integra en la vista de producto |
| [dt-smartvista.md](dt-smartvista.md) | Estado técnico SV; Plan Director consume su RAG |
| [dt-apolo.md](dt-apolo.md) | Estado técnico Apolo; Plan Director consume su RAG |
| [dt-sit-uat.md](dt-sit-uat.md) | Estado de pruebas integradas; es el gate de salida del Plan Director |

---

## Metadatos

| Campo | Valor |
|-------|-------|
| ID | DT-PLAN-DIRECTOR |
| Versión | 1.0.0 |
| Fuentes | brain.db v1.0.0 (plan_progress + milestones + risks + track_rag + user_stories_inventory) |
| Corte de datos | 2026-08-11 |
| Creado | 2026-08-17 |
| Owner analítico | Alejandro Gallegos (Accenture) |
| Owner BanCoppel | María Fernanda Barbosa (Líder de Control) |
| Portal | portal/plan-director.html |