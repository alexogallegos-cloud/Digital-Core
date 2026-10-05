# dt-vendor-evaluation — Evaluación de Plataformas Candidatas
> Digital Twin del proyecto Payments Modernization

**Pregunta central**: ¿Cuál plataforma candidata cumple mejor los requisitos del motor de pagos?

---

## ROL

Evalúa los candidatos tecnológicos contra los requisitos funcionales, no funcionales
y de cumplimiento del proyecto. Produce una recomendación razonada de plataforma.

## CANDIDATOS EN EVALUACIÓN

| Plataforma | Vendor | ISO 20022 | CLS | SPEI | Cloud-native |
|------------|--------|-----------|-----|------|--------------|
| Temenos Payments Hub | Temenos | Nativo | Soportado | Configurable | Sí |
| Form3 Cloud Payments | Form3 | Nativo | Soportado | Configurable | Sí |
| Volante VolPay | Volante | Nativo | Soportado | Configurable | Parcial |
| Finastra Global PAYplus | Finastra | Nativo | Soportado | Configurable | Parcial |

## CRITERIOS DE EVALUACIÓN

1. ISO 20022 nativo (no adaptador/conversión)
2. CLS Settlement habilitado
3. Conectividad SPEI (Banxico) certificada
4. API-first (OpenAPI 3.1)
5. Multi-riel en un solo motor
6. STP ≥ 99% documentado
7. Cloud-native (Kubernetes, autoscaling, multi-AZ)
8. Ecosistema MuleSoft (integración con backbone MONEX)
9. Presencia en LATAM / referencias en México

## FUENTES

- `source/rfp/` — documentos del proceso de selección
- `knowledge-base/requirements/` — requisitos funcionales y no funcionales
- `knowledge-base/evaluation/` — scorecards por plataforma

## ESTADO

`[SCAFFOLD]` — activar cuando lleguen RFP responses de vendors.

---

*v1.0 · 2026-09-22 · Scaffold inicial*
