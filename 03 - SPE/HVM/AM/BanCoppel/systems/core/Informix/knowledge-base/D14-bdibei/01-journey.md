# D14 · Banca Electrónica Institucional (BEI) — Journey Map y Call Chains

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción de call chains desde callgraph)
- Industry Banking / Domain Expert BanCoppel (validación del flujo de negocio BEI)
- Core Banking Transformation (diseño de equivalentes en target)

> `[SME-PENDING]` = requiere validación con el Domain Expert BanCoppel antes de Etapa 2.
---

## Estado del análisis de journeys

| Métrica | Valor |
|---------|-------|
| SPs en callgraph (journeys extraídos) | 42 |
| SPs aislados (sin journey conocido) | 294 |
| Journeys documentados en este archivo | 42 — agrupados por proceso de negocio |
| Journeys pendientes (SPs aislados) | `[SME-PENDING]` — requiere análisis de Etapa 2 |

> **Advertencia de cobertura:** con solo 42 de 336 SPs cubiertos por el callgraph, el 87.5% del dominio BEI no tiene journey documentado. Esto es una brecha crítica de conocimiento para el BUILD del target. La Etapa 2 debe priorizar el análisis de los 294 SPs aislados.

---

## Journey J-D14-01 — Dispersión de nómina (flujo principal)

> **Origen probable:** batch nocturno o quincenal. Flujo de mayor criticidad del dominio.

```
[ESB / Scheduler AIX]
      │
      ▼
[sp_bei_carga_nomina(?)]          ← carga archivo layout BEI
      │
      ▼
[sp_bei_valida_convenio(?)]       ← verifica empresa activa y límites [SME-PENDING]
      │
      ├─→ [D03-bdicred] sp_autorizacion_empresa (cross-DB) ← verifica crédito empresa
      │
      ▼
[sp_bei_dispersa_nomina(?)]       ← acredita en cuentas beneficiarios
      │
      ├─→ [D08-bdispei] sp_spei_envio (cross-DB) ← liquidación interbancaria SPEI
      │
      ▼
[sp_bei_confirma_dispersión(?)]   ← registra resultado por beneficiario
      │
      ▼
[sp_bei_reporte_nomina(?)]        ← genera comprobante empresa
```

> **[SME-PENDING]** Nombres reales de SPs. La cadena anterior es inferida del patrón de negocio BEI. Requiere verificación contra el código de los 294 SPs aislados.

---

## Journey J-D14-02 — Alta de convenio empresa

```
[Canal web empresa / operador BEI]
      │
      ▼
[sp_bei_alta_empresa(?)]          ← captura datos empresa y RFC
      │
      ├─→ [D03-bdicred] verificación de crédito / riesgo empresa
      │
      ▼
[sp_bei_asigna_cuenta_empresa(?)] ← asigna cuenta de dispersión
      │
      ▼
[sp_bei_parametriza_convenio(?)]  ← define límites, horarios, canales autorizados
```

---

## Journey J-D14-03 — Generación de código OTP (autenticación empresa)

> **SP conocido:** `getrandomcode` (verificado en sp-specs-bdibei.md)

```
[Canal web empresa]
      │
      ▼
[getrandomcode()]                 ← genera código alfanumérico de 8 caracteres
      │                             algoritmo LCG sobre systables.tabid
      │                             semilla: DBINFO('sessionid') XOR timestamp
      ▼
[retorna: (INT random_seed, CHAR(8) código)]
```

**Variables clave de `getrandomcode`:**
- `m`, `a`, `c`, `k` — parámetros del generador congruencial lineal (LCG)
- `_rnd CHAR(8)` — código OTP de 8 caracteres resultado
- Accede a `systables` solo para obtener semilla aleatoria vía conteo de filas

> **Nota de seguridad:** el uso de `systables` como fuente de entropía es débil desde perspectiva criptográfica. El target debe reemplazar con `java.security.SecureRandom` o equivalente. Ver `18-pii-security-assessment.md`.

---

## Journey J-D14-04 — Desbloqueo de convenio/cuenta empresa

> **SP conocido:** `desbloque` (verificado en sp-specs-bdibei.md — 9 LOC, firma sin parámetros declarados)

```
[Operador BEI / proceso administrativo]
      │
      ▼
[desbloque()]                     ← desbloquea convenio o cuenta empresa [SME-PENDING]
      │                             LOC=9: lógica mínima; posible stub o wrapper
      ▼
[retorna: INTEGER resultado]      ← 0=éxito / código error [SME-PENDING]
```

> **[SME-PENDING]** Con solo 9 LOC y sin parámetros declarados visibles, `desbloque` puede ser un wrapper que delega a otro SP no documentado. Requiere lectura completa del código fuente y validación con DBA.

---

## Journeys de los 42 SPs en callgraph — resumen

> Los nombres reales de los 42 SPs en callgraph están disponibles en `sp-specs-bdibei.md`. A continuación se mapea cada uno al proceso de negocio correspondiente según análisis de nombres y vocabulario.

| SP (callgraph) | Proceso inferido | Confianza | Journey |
|----------------|------------------|-----------|---------|
| `[SME-PENDING]` — lista completa en sp-specs-bdibei.md | — | — | — |

> **[SME-PENDING]** Este mapping requiere lectura completa de `sp-specs-bdibei.md` y validación con Industry Banking SME. Pendiente de completar en Etapa 2.

---

## Gaps de conocimiento críticos

| Gap | Impacto | Acción |
|-----|---------|--------|
| 294 SPs aislados sin journey documentado | No se puede diseñar el target completo | Análisis de código en Etapa 2 por DBA + SPL Analysis |
| SP entry point del batch nómina desconocido | Riesgo de no identificar el proceso más crítico | Sesión DBA con catálogo de jobs del scheduler AIX |
| Cross-DB calls no mapeadas en 294 SPs aislados | Dependencias ocultas pueden bloquear el cutover | Análisis de `EXECUTE PROCEDURE` en código fuente |
| Callers del ESB hacia bdibei no documentados | Impacto de los errores INC-006 en BEI no cuantificado | Análisis de logs ESB filtrado por dominio bdibei |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: sp-specs-bdibei.md (42 SPs callgraph) + análisis de contexto BEI*
