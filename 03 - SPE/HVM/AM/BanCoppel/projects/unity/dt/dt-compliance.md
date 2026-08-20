# DT: Compliance y Regulación — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · SME Core Banking Transformation · SME Cybersecurity · SME Industry Banking
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: Obligaciones regulatorias del go-live de TDC Digital — CNBV, PCI-DSS, CONDUSEF — con fechas de cumplimiento y responsables

---

## Resumen Ejecutivo de Obligaciones

El go-live del Producto 4900 (Tarjeta de Crédito) en enero 2027 activa obligaciones regulatorias múltiples. El incumplimiento de cualquiera de ellas puede resultar en:
- Suspensión del producto por la CNBV
- Multas administrativas (CNBV, CONDUSEF)
- Invalidación de la certificación PCI-DSS (suspensión de operación con tarjetas)
- Responsabilidad penal para los directivos firmantes

| Regulación | Obligación principal | Fecha límite | Responsable | Status |
|-----------|---------------------|-------------|------------|--------|
| CNBV Art. 76 LIC | Notificación de cambio de sistema core | Antes del go-live | Director Regulatorio BanCoppel | DATO-REQUERIDO |
| PCI-DSS v4.0 | Certificación del entorno SmartVista | Antes del go-live | CISO + Auditor externo QSA | DATO-REQUERIDO |
| CONDUSEF | Actualización de productos / contratos TDC | Antes o al go-live | Área Legal BanCoppel | DATO-REQUERIDO |
| Banxico — SPEI | Sin cambio crítico si la integración SPEI no cambia | Verificar | DATO-REQUERIDO | DATO-REQUERIDO |
| CNBV — Reportería | Reportes regulatorios desde SmartVista en formato CNBV | Desde primer mes en producción | TI + Regulatorio | DATO-REQUERIDO |

---

## CNBV — Artículo 76 LIC (Notificación de cambio de sistema)

### Marco regulatorio

El **Artículo 76 de la Ley de Instituciones de Crédito** obliga a las instituciones bancarias a **notificar a la CNBV** cuando implementen cambios significativos en sus sistemas de procesamiento de operaciones. El cambio de sistema de gestión de tarjetas (CMS/Intercard → SmartVista) es un cambio significativo.

### Obligaciones concretas

| Obligación | Contenido requerido | Plazo |
|-----------|---------------------|-------|
| Notificación previa | Descripción del cambio, sistemas afectados, fecha prevista, plan de contingencia | DATO-REQUERIDO días antes del go-live |
| Evidencia de pruebas | Plan SIT/UAT ejecutado y aprobado | Al momento del go-live |
| DRP documentado | Plan de recuperación ante desastres para el nuevo sistema | Al momento del go-live |
| Autorización CNBV | Si la CNBV lo requiere para este tipo de cambio | DATO-REQUERIDO |

> **DATO-REQUERIDO crítico**: ¿Requiere autorización previa de la CNBV o solo notificación? La diferencia puede ser semanas de proceso adicional. El Director Regulatorio de BanCoppel debe responder esto.

### Capas de notificación sugeridas

```
Notificación Art. 76 LIC
  ├── Descripción técnica del cambio (SmartVista como nuevo sistema de tarjetas)
  ├── Mapeo de capabilities: qué hace SmartVista que antes hacía CMS/Intercard
  ├── Plan de pruebas SIT/UAT (ver dt-sit-uat)
  ├── Plan de coexistencia CMS/Intercard durante parallel run (ver dt-coexistencia)
  ├── DRP documentado (ver dt-ops-readiness)
  └── RTO/RPO formales del nuevo sistema
```

---

## PCI-DSS v4.0 — Scope SmartVista + Tarjetas

### Qué entra en scope PCI-DSS

El go-live de TDC Digital activa obligaciones PCI-DSS porque BanCoppel **almacena, procesa y transmite datos de tarjetas de pago**:

| Sistema | PCI-DSS scope | Datos en scope |
|---------|--------------|----------------|
| SmartVista (SVBO/SVFE/SVIP) | **Sí — componente central** | PANs, CVVs, datos de portador |
| APOLO (originación) | Sí | Datos de solicitud de crédito |
| App (canal digital) | Sí | Transmisión de datos de tarjeta |
| Maquiladores (GID/Forza/TGS) | Sí | Datos de embosado + PGP keys |
| Apificación (middleware) | Sí | Transmisión de datos entre componentes |
| CAT (IVR) | Sí (si captura datos de tarjeta) | PAN, datos de autenticación |

### Controles PCI-DSS críticos por confirmar

| Control | Descripción | Status en SmartVista |
|---------|-------------|---------------------|
| 3.2-3.5 | Protección de datos almacenados (no almacenar CVV/CVC2 post-autorización) | DATO-REQUERIDO |
| 4.1 | Cifrado en tránsito (TLS 1.2+ en todas las interfaces SVIP) | DATO-REQUERIDO |
| 6.4 | Manejo de vulnerabilidades — patch management de SmartVista | DATO-REQUERIDO |
| 7.1 | Restricción de acceso a datos de tarjeta por necesidad de negocio | DATO-REQUERIDO |
| 8.6 | Autenticación multifactor para acceso admin a SmartVista | DATO-REQUERIDO |
| 10.2 | Logs de auditoría de acceso a datos de tarjeta | DATO-REQUERIDO |
| 11.3 | Pentest anual en el entorno PCI | Pentest Cobranza nov — ¿cubre todo el scope? |
| 12.3 | DRP documentado y probado | Ver dt-ops-readiness |

### QSA (Qualified Security Assessor)

BanCoppel debe contratar un **QSA externo** para la certificación PCI-DSS v4.0 de SmartVista. El QSA no puede ser el mismo proveedor que implementó el sistema.

| Campo | Valor |
|-------|-------|
| QSA seleccionado | DATO-REQUERIDO |
| Fecha de assessment QSA | DATO-REQUERIDO (debe ser antes del go-live) |
| Report on Compliance (RoC) | Requerido para go-live |
| Attestation of Compliance (AoC) | DATO-REQUERIDO |

### HSM (Hardware Security Module)

El sistema de maquila usa HSM para el cifrado de claves por tarjeta. Los controles del HSM son PCI-DSS mandatorios:

| Control HSM | Responsable | Status |
|------------|------------|--------|
| Vigencia de llaves HSM validada antes de cada lote | Maquiladores (GID/Forza/TGS) | DATO-REQUERIDO |
| Dual control para gestión de llaves | BanCoppel + Maquilador | DATO-REQUERIDO |
| Destrucción de llaves expiradas | DATO-REQUERIDO | DATO-REQUERIDO |

---

## CONDUSEF — Tarjeta de Crédito Digital

### Obligaciones

| Obligación | Descripción | Fecha límite |
|-----------|-------------|-------------|
| Registro del producto TDC Digital | Registrar el Producto 4900 en el sistema de CONDUSEF | Antes o al go-live |
| Contrato de adhesión actualizado | Contrato que el cliente firma al solicitar la TDC | Antes de emitir primeras tarjetas |
| Estado de cuenta en formato CONDUSEF | El estado de cuenta mensual cumple el formato regulatorio | Desde primera fecha de corte |
| Tabla comparativa de productos | Publicación en sitio web de BanCoppel | Al go-live |
| RECA (Registro de Contratos de Adhesión) | Registro del contrato en CONDUSEF antes de usarlo | DATO-REQUERIDO |

### Campos mínimos del contrato TDC (CONDUSEF)

Verificar que el contrato de la TDC Digital incluye:
- Tasa de interés (CAT y tasa mensual)
- Comisiones aplicables (anualidad, reposición, mora)
- Límite de crédito inicial y condiciones de modificación
- Mecanismos de pago
- Proceso de aclaración y PROFECO
- Datos de contacto para quejas

---

## Timeline de Cumplimiento Regulatorio

```
Hoy (ago 2026)
    │
    ├── Sep 2026: 
    │   ├── Confirmar si CNBV requiere autorización previa (no solo notificación)
    │   ├── Seleccionar QSA para certificación PCI-DSS
    │   └── Definir scope PCI-DSS formal con BPC
    │
    ├── Oct 2026 (inicio SIT):
    │   ├── Pentest de seguridad en scope PCI — resolver conflicto con pentest Cobranza
    │   └── Pre-assessment PCI-DSS en ambiente SIT
    │
    ├── Nov-Dic 2026 (SIT + UAT):
    │   ├── Assessment QSA en ambiente pre-prod
    │   ├── Preparar documentación CNBV Art. 76 LIC
    │   └── Validar contrato de adhesión CONDUSEF
    │
    ├── Dic 2026 (pre-go-live):
    │   ├── Notificación formal CNBV Art. 76 LIC
    │   ├── Report on Compliance (RoC) del QSA firmado
    │   └── Registro RECA en CONDUSEF
    │
    └── Ene 2027 (go-live):
        ├── Sistema en producción dentro de scope PCI-DSS certificado
        └── Primera reportería regulatoria al mes siguiente
```

---

## BIN 4268 0711 — Consideraciones

El BIN (Bank Identification Number) del Producto 4900 es **4268 0711** (prefijo Visa). Las consideraciones regulatorias y operativas:

| Aspecto | Detalle |
|---------|---------|
| Emisor certificado Visa | BanCoppel debe mantener certificación de emisor Visa activa |
| Reglas de autorización Visa | SmartVista debe cumplir reglas Visa para autorizaciones (MDES/VTS) |
| Reportería a Visa | Reportes mensuales de operación al esquema Visa |
| Fraude y chargebacks | Procesos de disputa deben estar configurados en SmartVista |

---

## DATO-REQUERIDO — Información crítica faltante

1. ¿El cambio CMS → SmartVista requiere autorización previa de CNBV o solo notificación?
2. Nombre del QSA seleccionado para la certificación PCI-DSS v4.0
3. Fecha del assessment QSA (debe ser antes del go-live)
4. Status de los controles PCI-DSS 3.2-3.5 (almacenamiento CVV) en SmartVista
5. Implementación de MFA para acceso admin a SmartVista (control 8.6)
6. Fecha de registro del RECA (contrato de adhesión TDC en CONDUSEF)
7. Quién firma la notificación CNBV Art. 76 LIC en BanCoppel
8. Si el pentest de noviembre cubre el scope PCI-DSS completo o solo Cobranza

---

*Creado: 2026-08-16 — Digital Twin Compliance y Regulación Unity R4 v1.0.0*
