# Plan de aprovisionamiento de arquitectos — octubre y noviembre 2026

> Base: `data/pipeline-fy27.json` (53 oportunidades, 16 cuentas, congelada 2026-10-21).
> Ventana: 21-oct-2026 a 30-nov-2026.

---

## 1. Lo que manda la ventana

No es la demanda del portafolio, son cuatro fechas contractuales.

| Fecha | Hito | Origen |
|---|---|---|
| 23-oct-2026 | Cierre de Habilitación inicial | Anexo B Banamex, Cláusula Cuarta (i) |
| 6-nov-2026 | Sesión de acreditación de los cuatro criterios | Anexo B, Cláusula Sexta |
| 11-nov-2026 | Entregables 1 y 2, y exigibilidad de la cuota de arranque de 30,000 USD | Anexo B, fase de on-boarding |
| 27-nov-2026 | MVP de Backstage IDP | `deal-state-banamex-backstage.md` |

Los cuatro criterios se acreditan **en sesión en vivo, no con documentos**: usuarios con acceso, que ingresan por sí mismos, que ven los entornos, y que ejecutan un pipeline de punta a punta.

## 2. Premisa de aprovisionamiento

Ningún proceso de contratación externa cierra dentro de la ventana. Las posiciones se cubren por **banca de recursos, rotación de engagements que cierran y centros nearshore de Accenture**. El Anexo B prohíbe la subcontratación; nearshore propio no lo es.

Consecuencia que hay que nombrar: mover gente de adentro abre huecos en otro lado. **Las requisiciones externas se abren en noviembre para cubrir esos huecos**, no para este plan, y aterrizan en diciembre y enero.

## 3. Olas, con los tres frentes abriendo en la semana 1

| Frente | Rol y nivel | Semana de incorporación | Activo desde |
|---|---|---|---|
| Banamex | Solution Architect del laboratorio, L7 (Anexo B) | 21-25 oct | 26 oct |
| Banamex | SDLC y DevSecOps Architect, L8 (Anexo B) | 21-25 oct | 26 oct |
| BanCoppel | Enterprise Architect, L5 | 21-25 oct | 26 oct |
| Todo lo demás | Cloud and Infrastructure Migration Architect, L6 | 21-25 oct | 26 oct |
| Banamex | API y Developer Platform Architect, L7 | 26-30 oct | 2 nov |
| BanCoppel | Service Architect AMS con Brain Engineer, L6 | 26-30 oct | 2 nov |
| Todo lo demás | Reinvention Managed Services Architect, L6 | 26-30 oct | 2 nov |
| Banamex | Lead Architect de Modernización con Brain, L6 | 2-6 nov | 9 nov |
| BanCoppel | Integration and Platform Architect, L6 | 2-6 nov | 9 nov |
| Todo lo demás | Lead Architect de Modernización con Brain y QE, L6 | 2-6 nov | 9 nov |
| Todo lo demás | Solution Architect de Producto, Integración y Data & AI, L6 | 9-13 nov | 16 nov |

**Rampa de arquitectos activos por semana:** 0, 4, 7, 10, 11, 11.

Siete activos antes de la sesión de acreditación del 6 de noviembre. Equipo completo el 16 de noviembre.

**Riesgo del ordenamiento:** el Enterprise Architect L5 de BanCoppel es la posición más senior y la más difícil de sacar de banca. Alternativa preparada: el frente abre con el Service Architect L6 y el L5 entra en la ola 2.

## 4. Fuera del alcance de arquitectura, pero condiciona la compuerta

El Anexo B exige **8.30 FTE en setup, que bajan a 6.60 con la palanca de IA**. De esos, solo 1.75 son de nivel arquitecto. Hay **4.30 FTE de ingeniería** (Cloud Engineer Senior, Platform Engineer IaC, Harness, Synthetic Data, IAM, SecOps, FinOps) que este plan no contempla y sin los cuales la sesión de acreditación del 6 de noviembre no es demostrable. Detalle de roles en el `lab-brain.db` del Laboratorio de Aceleración.

## 5. Lo que decidió la sesión del 21 de octubre

La sesión SP&E / Arquitectos aterrizó en **cuatro perfiles abiertos, no once**:

- **Banamex**, un arquitecto senior de modernización de aplicaciones y mainframe, APIs, microservicios y transformación bancaria.
- **BanCoppel**, uno. Cabello ya asignado; falta el reemplazo que abre la salida de Servín.
- **AXA**, dos: uno de enterprise y transformación, otro de modernización técnica. AXA se elevó a prioridad propia.

**La restricción dominante es la contratación monetizada en México**: no se pueden traer perfiles senior sin chargeability de corto plazo. Eso explica el salto de once a cuatro y lleva a una conclusión dura: las 17 oportunidades prospectivas del portafolio no se cubren contratando.

**Personas:** Cabello asignado a BanCoppel; Servín en transición de salida; Santeliz candidato a Banamex, dejando hueco en Gentera y Mifel (bajo riesgo: Gentera está caducada y Mifel sin expediente); Pichardo en el pool; José Luis Navas como puente de contratación global.

**Canales:** Argentina, Brasil, Monterrey, pools regionales y globales. Dos candidatos externos identificados. Terceros: Shaker y Sideral.

## 6. Brecha abierta que hay que escalar

Ninguno de los cuatro perfiles prioritarios cubre las dos únicas posiciones con fecha contractual: los dos roles del Anexo B con entregables al 11 de noviembre, y el perfil de Backstage con MVP al 27 de noviembre. Si se cubren con el equipo actual, conviene dejarlo por escrito, porque hoy el `lab-brain` los tiene sin asignar.
