# Ground Truth — Data Dictionary · SISTEMA-CREDITO-LATAM

> Espeja el "Data Dictionary" (Etapa 2) del Specialist - Reverse Engineering.

| Campo | Origen | PIC / Tipo | Tipo lógico | COMP-3 | Notas |
|-------|--------|-----------|-------------|:------:|-------|
| CRED-NUM | CREDCPY / CREDITOS | 9(10) / DECIMAL(10,0) | ID crédito | — | PK |
| CRED-CLIENTE | CREDCPY / CREDITOS | 9(10) | FK → CLIENTES | — | join |
| CRED-MONTO | CREDCPY / CREDITOS | S9(13)V99 COMP-3 | Monto otorgado | **Sí** | depack requerido |
| CRED-TASA | CREDCPY / CREDITOS | S9(3)V9(6) COMP-3 | Tasa interés | **Sí** | 6 decimales |
| CRED-TIPO | CREDCPY | X(2) + 88-levels | Tipo producto | — | PE/HI/AU |
| CRED-STATUS | CREDCPY | X(2) + 88-levels | Estado crédito | — | AP/RE/PE/CA |
| CRED-FECHA-APR | CREDCPY | 9(8) | Fecha aprobación | — | formato YYYYMMDD |
| CLI-ID | CLICPY / CLIENTES | 9(10) | ID cliente | — | PK |
| CLI-NOMBRE | CLICPY | X(40) | Nombre | — | — |
| CLI-RFC | CLICPY | X(13) | RFC | — | PII |
| CLI-SALDO-PROM | CLICPY / CLIENTES | S9(13)V99 COMP-3 | Saldo promedio 6m | **Sí** | base de RN-002 |
| CLI-CREDITOS-ACT | CLICPY | 9(3) | Créditos activos | — | base de RN-001 |
| CLI-SCORE-BURO | CLICPY | 9(3) | Score buró | — | base de RN-004 |
| LIM-MAXIMO | LIMCPY / LIMITES_CREDITO | S9(13)V99 COMP-3 | Límite máximo | **Sí** | base de RN-005 |
| HIST-ANIO | HISTORIAL_PAGOS | SMALLINT (2 díg.) | Año del pago | — | **fecha 2 dígitos — ventana de siglo** |

## Campos a vigilar en migración de datos
- **COMP-3 (packed decimal):** CRED-MONTO, CRED-TASA, CLI-SALDO-PROM, LIM-MAXIMO → **4 campos** requieren depack exacto.
- **Fecha de 2 dígitos:** HIST-ANIO (`WS-ANIO-CORTE PIC 9(02) VALUE 26` en RPTGEN) → ambigüedad 1926 vs 2026.