# D35-bdidigital — Digitalización / Expediente Electrónico
> **Dominio**: Digitalización — Expediente Electrónico del cliente
> **Base de datos Informix**: bdidigital
> **Estado**: [DISCOVER ETAPA 1 — caracterización inicial completa] · 2026-08-12
> **Prioridad**: ALTA — 6 SPs ESB-exposed · KYC / expediente regulatorio CNBV

---

## Descripción de Negocio

Gestiona el expediente electrónico del cliente BanCoppel: captura, almacenamiento y consulta de imágenes de documentos de identificación, fotos de perfil y registros del proceso de apertura. Es el **repositorio de KYC digital** que respalda cumplimiento CNBV (Art. 51 Ley de Instituciones de Crédito — identificación del cliente).

## Estadísticas (brain.db · 2026-08-12)

| Métrica | Valor |
|---------|-------|
| SPs totales | 43 |
| Reglas extraídas | 921 |
| SBVR formal | 0 (Layer C+ pendiente) |
| ESB-exposed | 6 (alta exposición omnicanal) |
| CTM batch | 0 |
| sp_archetype | implementation / leaf |

## SPs ESB-Exposed (Journeys candidatos)

| SP | Descripción funcional | Riesgo |
|----|----------------------|--------|
| `cons_expediente2_expcte_web` | Consulta expediente del cliente para canal web | PII — retorna documentos KYC |
| `cons_imgnula` | Consulta imagen nula / placeholder | — |
| `inserta_img_previo` | Inserta imagen de pre-captura en expediente | PII — escribe PAN/foto |
| `inserta_reg_expediente` | Inserta registro de apertura en expediente | PII — escribe identidad |
| `sp_borrardigi` | Elimina registro del expediente digital | Auditoría — requiere log CNBV |
| `sp_consultarexpediente_cliente` | Consulta expediente completo del cliente | PII — retorna todos los documentos |

## Riesgos de Migración Clave

| Riesgo | Descripción |
|--------|-------------|
| PII — almacenamiento documentos | Imágenes de identificación; en target AWS deben ir a S3 cifrado + KMS; acceso auditado CloudTrail |
| Paths AIX | Rutas `/resplogifx/`, `/tmp/` en SPs de UNLOAD deben migrarse a S3 URI |
| CNBV Art. 51 | Expediente 10 años de retención; plan de retención en Aurora/S3 requerido |
| Volumen | 43 SPs + ~900 reglas; análisis SBVR pendiente para detectar patrones IVA/ROUND |

## Diagnóstico de Dominio

- **Tipo TOGAF**: data (repositorio de documentos regulatorios)
- **Sistema de**: record (expediente KYC es source-of-truth)
- **Dependency**: bdicnweb (D01) llama SPs de este dominio en flujo de apertura de cuenta; bditef (D13) puede consumir para validación
- **ESB role**: proveedor (exposición alta, pocas llamadas hacia fuera)

## Próximos Pasos

1. Ejecutar Layer C+ SBVR sobre 921 reglas (alto volumen — alto impacto)
2. Agregar SPs ESB-exposed a `journeys-data.json` como journeys D35
3. Verificar esquema tabla de imágenes en DBA IBM Informix (volumen/BLOB/BYTE columns)
4. Crear `05-risks.md` con riesgos de equivalencia para validación en parallel-run
5. Registrar en migration-risk-register.md: riesgo PII + retención CNBV

---

*Actualizado 2026-08-12 — DISCOVER Etapa 1 · Brain-First characterization*