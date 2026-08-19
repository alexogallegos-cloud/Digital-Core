# DT: Coexistencia Informix ↔ Unity — Unity R4
> **Digital Twin** · Fuente: brain.db Informix · brain.db Unity · ADR-UNITY-002 · ADR-UNITY-003 · SME Core Banking Transformation
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: Reglas de convivencia entre el core bancario Informix/PISA y Unity (Temenos Transact + SmartVista) por canal y producto, estrategia de routing y criterios de decommission

---

## Principio de Coexistencia

BanCoppel opera **dos cores bancarios simultáneamente**. El estado actual es Transitional (TOGAF): Informix es el Baseline, Unity es el Target, pero el Target no está completo — solo algunos productos han migrado. El go-live de R4 (Producto 4900 / TDC Digital) no apaga Informix; Informix sigue siendo el core de todos los demás productos.

> **Regla de oro**: Ningún canal ni producto puede enrutar a ambos cores simultáneamente sin una regla de routing explícita, documentada y en producción.

---

## Mapa de Productos por Core (Estado a enero 2027)

| Producto | ID | Core activo | Informa a Informix? | Status coexistencia |
|---------|-----|------------|---------------------|---------------------|
| Cuenta Efectiva N2 | UNITY-R1-P-CE-N2 | Temenos Transact | DATO-REQUERIDO | En producción |
| Cuenta Efectiva Digital N4 | UNITY-R2-P-CED-N4 | Temenos Transact | DATO-REQUERIDO | En producción |
| Nómina N4 | UNITY-R3-P-NOM-N4 | Temenos Transact | DATO-REQUERIDO | En producción |
| Préstamo Simple | UNITY-RX-P-PS | Temenos Transact | DATO-REQUERIDO | En producción |
| **TDC Clásica Digital (4900)** | UNITY-R4-P4900 | **SmartVista** | DATO-REQUERIDO | **Building — go-live ene 2027** |
| Crédito Coppel (legacy) | DATO-REQUERIDO | **Informix/PISA** | Sí — native | En producción |
| Nómina (legacy) | DATO-REQUERIDO | **Informix/PISA** | Sí — native | En producción |
| Todos los demás productos | DATO-REQUERIDO | **Informix/PISA** | Sí — native | En producción |

> **Nota crítica**: los R1-R3+Rx están en Transact pero no está claro si también replican a Informix para reportería o coexistencia. Este dato es fundamental para el decommission futuro. **DATO-REQUERIDO**.

---

## Sistemas Reemplazados por SmartVista R4

El Producto 4900 reemplaza a tres sistemas legacy de gestión de tarjetas:

| Sistema legacy | Función | Estado post-R4 |
|---------------|---------|----------------|
| CMS (Card Management System) | Gestión de ciclo de vida de tarjetas | `[STATE: DEPRECATED]` en go-live R4 |
| Intercard | Procesamiento de transacciones con tarjeta | `[STATE: DEPRECATED]` en go-live R4 |
| Macweb | DATO-REQUERIDO | DATO-REQUERIDO |

> Fecha de `[STATE: SUNSET]` para CMS/Intercard/Macweb: **DATO-REQUERIDO** — debe estar en el ADR-UNITY-002.

---

## Reglas de Routing por Canal

### Canal AppMovil (App)

| Operación | Ruta actual (pre-R4) | Ruta post-go-live R4 | Regla de switch |
|-----------|---------------------|---------------------|-----------------|
| Consulta saldo TDC Digital | DATO-REQUERIDO | SmartVista via SVIP | Feature flag por tipo de producto |
| Pago TDC Digital | DATO-REQUERIDO | SmartVista via SVIP | Feature flag por tipo de producto |
| Consulta saldo Crédito Coppel | Informix | Informix | Sin cambio |
| Compra diferida TDC | N/A | SmartVista (DPP — pendiente contratar) | Bloqueada |

### Canal SIWEB (Sucursales)

| Operación | Ruta post-go-live R4 | Regla de switch |
|-----------|---------------------|-----------------|
| Alta / modificación TDC Digital | SmartVista | Por tipo de producto |
| Consulta movimientos TDC Digital | SmartVista | Por tipo de producto |
| Todas las operaciones de otros productos | Informix | Sin cambio |

### Canal CAT (Contact Center)

| Operación | Ruta post-go-live R4 | Regla de switch |
|-----------|---------------------|-----------------|
| Consulta saldo TDC Digital | SmartVista via SVIP + IVR CAT | Por tipo de producto (CAT sin contratar 🔴) |
| Reporte robo/extravío TDC | SmartVista | Por tipo de producto |
| Cobranza TDC Digital | Cobranza Direccionada + SmartVista | Por tipo de producto |

### Canal Cobranza Direccionada

| Operación | Ruta post-go-live R4 | Depende de |
|-----------|---------------------|-----------|
| Gestión de mora TDC Digital | SmartVista (aging periods E1/E2/E3) | Integración Informix↔SmartVista para datos compartidos |

---

## Antipatrones de Coexistencia — Reglas de Oro

| Antipatrón | Riesgo | Regla correcta |
|-----------|--------|---------------|
| Enrutar el mismo cliente a ambos cores sin sesión atómica | Inconsistencia de saldo — fraude o pérdida | Un cliente-producto = un core por operación |
| Escribir en ambos cores simultáneamente sin CDC | Datos duplicados o divergentes | Escritura en core owner; lectura puede ser dual con reconciliación |
| Usar tipos MONEY de Informix directamente en Java/Transact | Errores de redondeo (0.01 centavos acumulados) | Usar `BigDecimal` con `HALF_EVEN` en todo el código Java del middleware |
| Asumir que los IDs de cliente son iguales en ambos sistemas | Clientes sin match en reconciliación | Confirmar el ID de cliente canónico y mapearlo explícitamente |
| Decommission de Informix antes de que todos sus SPs tengan migration_fate ≠ unknown | Funcionalidad sin cobertura en producción | Verificar `bank-brain.capability_gap() = 0` antes de cualquier decommission |

---

## Tipos MONEY — Equivalencia Financiera

Informix usa el tipo `MONEY` (decimal de precisión fija) con semántica de banco. En la migración a Java:

| Regla | Detalle |
|-------|---------|
| Tipo Java para cantidades monetarias | `BigDecimal` — nunca `double` ni `float` |
| Modo de redondeo | `HALF_EVEN` (redondeo bancario / banker's rounding) |
| Precisión mínima | 2 decimales para MXN; 8 para tipos internos de SmartVista |
| Comparación de equivalencia | diff absoluta ≤ $0.01 MXN en cualquier resultado de prueba |

Esta regla aplica al middleware de Apificación y a cualquier integración que pase cantidades entre Informix y SmartVista/Transact.

---

## Migration Fate de Informix — Resumen

El brain.db de Informix tiene registrada la `migration_fate` de los SPs. El estado actual:

| Fate | % (según brain.db Informix) | Significado |
|------|-----------------------------|-------------|
| `absorbed` | 59% | SmartVista/Transact lo hace nativamente |
| `replicate` | 24% | Se construye en el nuevo sistema |
| `complement` | 17% | Informix y Unity colaboran |
| `unknown` | 0% objetivo | Sin decision = bloquea decommission |

El 24% `replicate` son los SPs cuya lógica debe existir en SmartVista o Apificación. El 17% `complement` define la zona de coexistencia permanente: Informix y Unity interactúan en esos dominios indefinidamente hasta nueva decisión.

> **Acción**: verificar que todos los SPs con `replicate` tienen un equivalente confirmado en SmartVista antes del go-live.

---

## Parallel Run — Protocolo

Para el go-live de R4, el parallel run aplica únicamente al Producto 4900 (TDC Digital). El resto de productos no entra en parallel run porque no migran.

| Parámetro | Valor |
|-----------|-------|
| Duración mínima del parallel run | DATO-REQUERIDO (recomendación SRE: ≥ 2 semanas) |
| Transacciones cubiertas | Solo Producto 4900 — no otros productos |
| Comparación | SmartVista vs. CMS/Intercard (legacy) |
| Tolerancia de divergencia | ≤ 0.05% de operaciones con diferencia |
| Reconciliación | Diaria — dashboard activo durante parallel run |
| Owner del comparator | DATO-REQUERIDO |

---

## ACL — Anti-Corruption Layer Informix ↔ SmartVista

Donde la lógica de negocio de Informix necesita comunicarse con SmartVista, el middleware de Apificación actúa como ACL:

```
Informix SP ──→ [API Apificación ACN] ──→ SVIP ──→ SmartVista
                      │
                      ├── Traduce tipos MONEY → BigDecimal
                      ├── Mapea IDs de cliente
                      ├── Maneja errores SQLSTATE → códigos de error Unity
                      └── Registra en el RAID de coexistencia
```

> Los contratos de API del ACL deben estar en OpenAPI 3.1 y versionados antes de SIT.

---

## ADRs de Coexistencia (pendientes)

| ADR | Decisión | Status |
|-----|----------|--------|
| ADR-UNITY-002 | Estrategia de coexistencia con Informix — ¿temporal o permanente para algunos dominios? | Propuesta — **pendiente de firmar** |
| ADR-UNITY-003 | Routing de canales por producto — ¿feature flag? ¿API gateway? ¿configuración en Apificación? | Propuesta — **pendiente de firmar** |

---

## DATO-REQUERIDO — Información crítica faltante

1. ¿Los productos R1-R3+Rx replican datos a Informix? ¿En tiempo real o batch?
2. ID de cliente canónico para el mapeo entre sistemas (¿mismo en Informix y Transact/SmartVista?)
3. Función exacta de Macweb y su fecha de decommission
4. Duración del parallel run del Producto 4900 (mínimo recomendado)
5. Owner del comparator de parallel run
6. Inventario de SPs Informix con `migration_fate = replicate` — ¿todos tienen equivalente confirmado en SmartVista?
7. Reglas de routing explícitas para el canal de Cobranza Direccionada
8. Protocolo de reconciliación entre Informix y SmartVista para datos compartidos durante coexistencia

---

*Creado: 2026-08-16 — Digital Twin Coexistencia Informix↔Unity v1.0.0*
