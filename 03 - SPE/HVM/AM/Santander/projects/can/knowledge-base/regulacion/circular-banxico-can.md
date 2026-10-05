# Circular 3/2012 Banxico — Resumen Ejecutivo CAN
> **Instrumento:** Disposiciones de carácter general aplicables a las Instituciones de Crédito
> **Versión compilada:** Hasta Circular 6/2025 (publicada ~mayo 2025)
> **Documento fuente:** `source/docs/regulacion/Circular 3-2012 CAN Compilado 6-2025.pdf` (303 págs.)
> **Versión de este resumen:** 1.0.0 · 2026-09-16 · dt-normativa-can

---

## Alcance CAN dentro de la Circular

La Circular 3/2012 es el marco regulatorio principal de Banxico para cuentas de depósito, operaciones activas (créditos) y servicios de transferencia. Los artículos CAN se concentran en dos capítulos:

| Capítulo | Sección CAN | Páginas |
|----------|-------------|---------|
| Capítulo I — Operaciones Pasivas | Art. 22 Bis (Identificación Cuentas Ordenantes) + Art. 22 Bis 1 (Características) | 60-65 |
| Capítulo II — Operaciones Activas | Art. 63 Bis (Características del CAN) + Art. 63 Bis 1 (Gestión) + Art. 63 Bis 2 (Derogado) + Art. 63 Bis 3 (Mecanismos) | 100-104 |
| Capítulo III — Servicios | Art. 64 (Domiciliación), Art. 65 (Cancelación), Art. 68 (Objeción), Art. 75 (Transferencia nómina) | 104-110 |
| Capítulo IV — Servicios de Nómina | Art. 81 Bis 1 (Nómina Interbancaria) + Art. 81 Bis 2 (Lineamientos) | 111+ |

---

## Historia Regulatoria CAN

| Circular | Año | Cambio principal |
|----------|-----|-----------------|
| Circular 3/2012 | 2012 | Marco base de operaciones de depósito y crédito |
| Circular 15/2018 | 2018 | **Crea el esquema CAN** — añade Arts. 22 Bis, 22 Bis 1, 63 Bis, 63 Bis 1, 63 Bis 2, 63 Bis 3, 81 Bis 1 |
| Circular 7/2019 | 2019 | Modifica CAN — ajustes en Domiciliación y gestión interbancaria; añade Art. 81 Bis 2 |
| Circular 6/2025 | 2025 | Modificación mayor — deroga Art. 63 Bis 2; ajusta Art. 22 Bis (fracción III para cuentas designadas por cliente) y toda la normativa CAN |

---

## Conceptos Estructurales del Esquema CAN

### El Triángulo CAN

```
    ACREDITADO / CUENTAHABIENTE
    (titular de Cuenta Ordenante)
           |           |
    otorga mandato   designa CAN
           |           |
    INSTITUCIÓN       INSTITUCIÓN / SOFOM
    DEPOSITARIA  ←→  ACREEDORA CAN
    (Cuenta Ordenante)  (Art. 63 Bis 3)
           |
    ejecuta cargos en prelación
    (OBL-016)
```

### Flujo de Apertura de un CAN

1. **Acreedora oferta crédito** con intención CAN
2. **Acreedora solicita info** de Cuenta Ordenante via Art. 63 Bis 3 (OBL-001)
3. **Depositaria responde** en 1 DHB: confirmación, saldos, abonos 6 meses (OBL-015)
4. **Acreedora evalúa** capacidad de pago vs. límite Comité de Riesgos (OBL-002)
5. **Cliente firma mandato** (OBL-005) y recibe comparativo CAN vs. no-CAN (OBL-007)
6. **Acreedora celebra CAN** y asigna Clave Básica Estandarizada (OBL-009)
7. **Acreedora gestiona Domiciliación** ante depositaria via Art. 64 (OBL-010)
8. **Acreedora notifica** a Banxico el límite de su Comité de Riesgos (OBL-003)
9. **Depositaria ejecuta cargos** en prelación en cada ciclo de nómina (OBL-016)

### Prelación de Cargos (OBL-016 — crítico operativo)

```
Cargo 1: Créditos no-CAN con la misma institución depositaria (anteriores al CAN)
Cargo 2: CANs — en orden cronológico de designación (fecha y hora)
Cargo 3: Domiciliaciones de bienes/servicios y otros créditos no-CAN
```

Si no hay fondos suficientes para un CAN → cargar lo disponible y completar con siguientes abonos.

---

## Obligaciones por Actor — Vista Rápida

### Santander como Institución Depositaria (lleva Cuenta Ordenante)
- Identificar Cuentas Ordenantes (OBL-013)
- Ofrecer derecho a designar CANs en contrato (OBL-014)
- Obtener mandato del cliente (OBL-018)
- Responder en 1 DHB con info de la Cuenta (OBL-015)
- Ejecutar cargos en prelación (OBL-016)
- Notificar CANs previos al abrir nueva Cuenta Ordenante (OBL-017)
- Comunicar datos de nueva Cuenta a instituciones con CANs previos (OBL-019)
- Notificar cancelación de Domiciliación CAN (OBL-020)
- Resolver objeción CAN en 5 DHB (OBL-021)
- Remitir objeción a institución acreedora en 2 DHB (OBL-022)
- Transferir Prestaciones Laborales mismo DHB o siguiente (OBL-023)

### Santander como Institución Acreedora (otorga el CAN)
- Solicitar info antes de ofrecer CAN en cuenta de otra institución (OBL-001)
- Respetar límite de amortizaciones del Comité de Riesgos (OBL-002)
- Notificar límite a Banxico en 10 DHB (OBL-003)
- Verificar identidad antes de solicitar info (OBL-004)
- Obtener mandato del acreditado (OBL-005)
- Liquidar créditos anteriores via SPEI si es refinanciamiento (OBL-006)
- Presentar comparativo CAN vs. no-CAN (OBL-007)
- Reportar a buró el carácter CAN (OBL-008)
- Asignar Clave Básica Estandarizada (OBL-009)
- Gestionar Domiciliación ante institución depositaria (OBL-010)
- Ajustar pagos por prepago (OBL-011)

### Ambos roles
- Usar mecanismo comunicación transparente y notificar a Banxico (OBL-012)

---

## Plazos Críticos

| Obligación | Plazo | Consecuencia del incumplimiento |
|-----------|-------|--------------------------------|
| Responder info Cuenta Ordenante (OBL-015) | 1 DHB | Bloquea apertura del CAN |
| Notificar cancelación Domiciliación CAN (OBL-020) | 1 DHB | Cargo indebido post-cancelación |
| Remitir objeción a acreedora (OBL-022) | 2 DHB | Incumplimiento Art. 68 |
| Notificar límite a Banxico (OBL-003) | 10 DHB desde aprobación | Multa Banxico |
| Resolver objeción CAN (OBL-021) | 5 DHB | Incumplimiento Art. 68 |
| Notificar mecanismo comunicación a Banxico (OBL-012) | Previo a implementación | Mecanismo sin validez regulatoria |
| Transferir Prestaciones Laborales (OBL-023) | Mismo DHB (antes 17:00) o siguiente | Incumplimiento Art. 75 |

---

## Sistemas Santander Impactados (hipótesis inicial)

| Sistema | Tipo de impacto | Obligaciones relacionadas |
|---------|-----------------|--------------------------|
| core bancario Santander (core-banking / loans) | Core — motor de nómina y cargos | OBL-013, OBL-014, OBL-015, OBL-016, OBL-017, OBL-018, OBL-019 |
| `banxico-spei` (Santander) | Liquidaciones SPEI para refinanciamientos CAN | OBL-006, OBL-009 |
| Canales digitales (App Móvil, Banca Internet) | Interfaz mandato + comparativo CAN | OBL-005, OBL-007, OBL-018 |
| ControlM | Scheduling de cargos periódicos CAN | OBL-016, OBL-023 |
| Reporting/CNBV | Reporte buró, comunicaciones Banxico | OBL-003, OBL-008 |
| Mecanismo Art. 63 Bis 3 | Hub de comunicación interbancaria CAN | OBL-012, OBL-015, OBL-019, OBL-020 |

---

## Artículos Derogados

| Artículo | Contenido original | Derogado por |
|----------|-------------------|-------------|
| Art. 63 Bis 2 | Supuestos adicionales para vencimiento y modificación del CAN | Circular 6/2025 |
| Art. 22 Bis 1 I(c) | Inciso c del Art. 22 Bis 1 | Circular 6/2025 |
| Art. 22 Bis 1 I(d) | Inciso d del Art. 22 Bis 1 | Circular 6/2025 |
| Art. 22 Bis 1 I(g) | Inciso g del Art. 22 Bis 1 | Circular 6/2025 |

---

## Próximos Pasos del DT

1. **Extraer Art. 81 Bis 1 y 81 Bis 2** — Servicio de Nómina Interbancaria (páginas 111+ de la circular)
2. **Leer DE CAN v4.2** — especificaciones técnicas del mecanismo de comunicación Art. 63 Bis 3
3. **Activar dt-impacto-sistemas** — cruzar obligaciones contra el core Santander en santander-brain
4. **Poblar CANBrain** — cargar OBL-001 a OBL-023 en `regulatory_obligations`

---

*v1.0.0 · 2026-09-16 · 23 obligaciones identificadas · dt-normativa-can*
