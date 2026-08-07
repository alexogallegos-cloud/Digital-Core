# Arquitectura AS-IS — Autorizador de Pagos BanCoppel
> **Fuente**: Diagnóstico de arquitectura producido en enero 2026 tras los incidentes Nov-Dic 2025
> **Alcance**: Capas del sistema de autorización de pagos — eGlobal, Autorizador Java, Informix SPL/OLTP, AIX, infraestructura física
> **Versión**: 1.0.0 · 2026-08-07

---

## Diagrama de capas (descripción textual)

El sistema de autorización de pagos de BanCoppel opera en 7 capas físicas y lógicas. La capa 7 (presentación) recibe la transacción del canal y la capa 1 (infraestructura física) es el disco donde vive Informix.

```
Capa 7 — Canales y Presentación
  ├── E-Global              ← autorizador de pagos (canal principal)
  └── LGEC + Canales c/SPEI ← canales SPEI entrantes

Capa 6 — Integración y Servicios
  ├── InterSec              ← capa de integración (deuda técnica A)
  └── IBM Bus de Integración ← ESB para canales SPEI

Capa 5 — Lógica de Aplicación
  ├── Autorizador (Java)    ← motor de autorización [A B C D]
  │     Sin pool de conexiones a BD — 25 conexiones directas sin self-healing
  │     Capacidad: 3,240 txn/min promedio
  └── Queue Mensajes        ← cola transaccional [bottleneck O]
        Umbral diseñado: 2 paquetes
        Pico en incidentes: 3,285 paquetes
        Tipos: Tx activas <8s · Tx caducan >8s · Reverso realizadas · Reverso no realizadas

Capa 4 — Middleware y Runtime
  ├── Informix SPL          ← stored procedures [A D]
  │     193 buffer waits simultáneos (observado en incidentes)
  └── Latinia               ← servicio de notificaciones (SMS/push)

Capa 3 — Datos y Persistencia
  └── Informix OLTP         ← base de datos transaccional [B C D]
        Bottleneck derivado de la Firma Digital

Capa 2 — Sistema Operativo
  └── AIX OS + Firma Digital ← hasta 100% de saturación en picos
        Firma Digital es el cuello de botella entre OLTP y la infraestructura

Capa 1 — Infraestructura Física
  └── Disco (hdisk3 entre otros)
        Forking de SPEI: hasta 72 procesos vs 1-5 nominal
        hdisk3 saturado 100% I/O wait (observado 15-dic-2025)

Componentes auxiliares (derecha):
  ├── HSM  ← Hardware Security Module (genera/valida firma digital)
  └── CAS  ← Card Authorization System
```

---

## SLA del sistema

| Parámetro | Valor | Consecuencia si se supera |
|-----------|-------|--------------------------|
| Round-trip máximo e-Global | **8 segundos** | e-Global cancela la transacción automáticamente |
| Umbral de cola Queue Mensajes | **2 paquetes** | Sistema entra en degradación — umbral diseñado para carga normal |
| Capacidad Autorizador | **3,240 txn/min** promedio | Cola crece cuando el flujo entrante supera esta capacidad |

---

## Deudas técnicas identificadas (enero 2026)

| Tag | Tipo | Componentes afectados | Descripción |
|-----|------|-----------------------|-------------|
| **A** | Deuda Técnica — Obsolescencia | Autorizador · InterSec · Informix SPL | Componentes sin actualización tecnológica; InterSec y el Autorizador Java heredan patrones de diseño pre-cloud |
| **B** | Alto Acoplamiento entre Capas | Autorizador · Informix OLTP | El Autorizador escribe directamente a Informix OLTP sin capa de abstracción; cambio en schema = cambio en el Autorizador |
| **C** | Encolamiento Transaccional — Falta de Balanceo de Cargas | Autorizador · Informix OLTP | No hay distribución de carga entre instancias; una sola instancia Informix atiende todo el volumen del Autorizador |
| **D** | Subutilización de Infraestructura / Optimización | Autorizador · Informix SPL · Informix OLTP · Infraestructura | Recursos de cómputo disponibles no utilizados; configuración conservadora que no aprovecha la capacidad del servidor POWER-AIX |

---

## Cadena de fallo (mecanismo de los incidentes)

```
1. SPEI pico (quincena / aguinaldo / fin de mes)
       ↓
2. Sistema SPEI forkea hasta 72 procesos (vs 1-5 nominal)
       ↓
3. AIX OS llega al 100% de utilización
       ↓
4. Firma Digital (HSM) se satura — bloquea operaciones criptográficas
       ↓
5. Informix OLTP no puede completar transacciones:
   Load Average sube a 82-127%
   193+ buffer waits simultáneos en SPL
       ↓
6. Autorizador (Java) espera respuesta de Informix:
   25 conexiones directas se agotan (sin pool, sin self-healing)
   Cola de Queue Mensajes sube de 2 → 3,285 paquetes
       ↓
7. e-Global supera el SLA de 8 segundos → cancela transacciones
       ↓
8. Cliente recibe rechazo / timeout
```

---

## Métricas de saturación observadas en incidentes

| Fecha | Load Avg Informix | Cola Autorizador | Duración | Impacto |
|-------|------------------|-----------------|----------|---------|
| 2025-11-29 | N/D | N/D | 4.5 h | 69.71% txn declinadas · $663 MDP |
| 2025-12-15 | **82-92%** + hdisk3 100% I/O wait | Masivo | 7.5 h | Encolamiento masivo |
| 2025-12-17 | **55-63%** | Masivo | 5.7 h | Encolamiento masivo |
| 2025-12-21 | N/D | **3,500 paquetes** | 1.5 h | — |
| 2025-12-23 | **127%** | Masivo | 23 min | eGlobal connection leak identificado |
| 2025-12-31 | **94.55%** | 1,500–3,200 paquetes | 3.9 h | 5 encolamientos separados |
| 2026-01-12 | **50%** | 700 paquetes | 6.58 h | Degradación a carga moderada — leak sistémico |

---

## Hallazgo crítico: 12-ene-2026

El incidente del 12 de enero ocurrió con Load Average de solo 50% — por debajo de la mitad de la saturación del 23-dic. La duración fue 6.58h, la segunda más larga de la serie. Esto indica que para enero el **connection leak de e-Global se había vuelto sistémico**: el Autorizador agota sus 25 conexiones incluso a cargas moderadas porque las conexiones no se liberan correctamente.

El volumen del 12-ene era significativamente menor (Eglobal p15, SPEI p48) — el sistema fallaba por acumulación de deuda técnica, no por volumen.

---

## Implicaciones para la migración

| # | Riesgo | Capa impactada | Severidad |
|---|--------|---------------|-----------|
| 1 | Sin pool de conexiones en el Autorizador — 25 directas sin self-healing → el target debe implementar connection pooling (HikariCP o equivalente) antes de go-live | Capa 5 (Autorizador) | N5 |
| 2 | SPEI forking 72 procesos vs 1-5 nominal → Aurora PostgreSQL + microservicios deben manejar connection spikes sin forking OS | Capa 1 + Capa 3 | N5 |
| 3 | No load balancing en la capa de autorización → target debe tener al menos 2 instancias activas del Autorizador con balanceo | Capa 5 | N4 |
| 4 | Firma Digital como bottleneck síncrono → evaluar firma asíncrona o HSM con mayor throughput | Capa 2 | N4 |
| 5 | SLA e-Global de 8s → el target debe responder en < 4s en P95 para tener margen de 50% | Capa 7 | N4 |
| 6 | Connection leak en e-Global → requiere fix antes de migración; si se replica el leak contra el nuevo backend el comportamiento se repite | Capa 5 / Capa 7 | N4 |

---

*v1.0.0 · 2026-08-07 · Fuente: diagnóstico arquitectónico enero 2026 post-incidentes Nov-Dic 2025 · Complementado con análisis de volumetría Excel (Eglobal + SPEI minxmin)*
