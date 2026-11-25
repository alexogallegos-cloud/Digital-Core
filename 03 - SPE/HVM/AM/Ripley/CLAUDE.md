# Banco Ripley — Application Modernization Project Agent

> Hereda `CLAUDE.md` de `03 - SPE/HVM/AM/` y, por referencia, las reglas universales de Digital Core.
> Asset que gobierna el conocimiento: `00 - Enterprise Brain/`. Canon aplicable: `canon/brain-rules.md`, 45 reglas.

```
# project_type: enterprise-situation-analysis
# project_state: active
# platform: [DATO-REQUERIDO] core bancario y procesador de tarjetas por confirmar
# horizon_present: [DATO-REQUERIDO] landscape sin evidencia cargada
# horizon_future: [DATO-REQUERIDO]
# replaces_or_complements: —
```

---

## Qué es esta carpeta

El proyecto de conocimiento de **Banco Ripley Chile**. Hoy tiene un solo alcance activo: construir el modelo ontológico del banco y, con él, el análisis de la situación. No hay todavía un programa de modernización contratado ni sistemas con código fuente cargado.

La inteligencia vive en `bank-brain/`, que es el brain de nivel cliente, de tipo `enterprise`, y federa los brains de sistema y de proyecto cuando existan. Las carpetas `systems/` y `projects/` están creadas y vacías a propósito: se pueblan cuando la evidencia demuestre la existencia de cada sistema (Regla B8) y no antes.

---

## Identidad del cliente

| Campo | Valor | Nivel |
|-------|-------|-------|
| Entidad | Banco Ripley, Chile | gold |
| Grupo | Ripley Corp, sociedad anónima abierta listada en la Bolsa de Santiago | gold |
| Industria primaria | Banca, modelo Digital Bank 4.0 | gold |
| Industria secundaria | Retail, como canal de originación y no como lifecycle propio | silver |
| Regulador principal | Comisión para el Mercado Financiero, CMF | gold |
| Regulador monetario | Banco Central de Chile | gold |
| Protección al consumidor | SERNAC | gold |
| Modelo de negocio | Banco de consumo ligado a una red de retail, con la tarjeta de crédito como activo principal | silver, por confirmar con el Industry SME |
| Geografía del brain | Chile. La operación de Perú queda fuera de alcance por decisión del 2026-10-27 | gold |

El nivel de cada afirmación es el de la Regla B37 y se registra en `knowledge_lineage` cuando el brain se construya. Lo marcado gold aquí viene de registros públicos; nada de lo gold describe la tecnología del banco.

---

## Frontera con México

Este es el primer cliente del estate fuera de México y la diferencia no es cosmética. El Industry Banking SME tiene su capa local resuelta para México, con la extensión de 89 productos de banca múltiple y el mapa de CNBV, Banxico y CONDUSEF. Para Chile no existe equivalente. Esa ausencia es la brecha bloqueante de la primera ronda del análisis y está declarada como tal en la metodología.

Reusar la capa mexicana sería el peor error disponible: cambia el regulador, cambia la unidad indexada, cambia el tope de tasa, cambia el costo informado al cliente y cambia el ecosistema de pagos. El detalle está en `bank-brain/knowledge-base/methodology/metodologia-analisis-situacion.md`, sección "Lo que cambia respecto de México".

---

## Estado

| Fase del Brain Lifecycle | Estado | Fecha |
|--------------------------|--------|-------|
| DISCOVER, Brain Bootstrap | En curso | 2026-10-27 |
| DESIGN, Knowledge Architecture | No iniciada | — |
| BUILD, Brain Population | No iniciada | — |

Corpus fuente disponible al 2026-10-27: solo información pública. Ningún documento del cliente, ninguna entrevista, ningún código.

---

*Creado 2026-10-27. Instanciado desde la semilla del asset Enterprise Brain.*
