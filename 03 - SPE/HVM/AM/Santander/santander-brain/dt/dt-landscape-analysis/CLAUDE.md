# dt-landscape-analysis — Análisis de Landscape Tecnológico
> Digital Twin federado · Santander México
> Pregunta rectora: ¿Cuál es el mapa tecnológico AS-IS completo de Santander México?

---

## PROPÓSITO

Construir y mantener el mapa completo del landscape tecnológico AS-IS de Santander México:
sistemas existentes, clasificación TOGAF, estado de modernización, dependencias cross-sistema,
y distancia hacia el estado target (TO-BE).

---

## CONTENIDO A POBLAR

- [ ] `landscape-as-is.md` — Inventario completo de sistemas con clasificación TOGAF (core · processors · channels · data · integration · compliance)
- [ ] `landscape-to-be.md` — Estado target y roadmap por tipo de sistema
- [ ] `togaf-mapping.md` — Mapeo formal TOGAF: ABBs → SBBs del cliente
- [ ] `system-inventory.md` — Tabla maestra: slug · nombre real · vendor · versión · hosting · SLA · criticidad
- [ ] `dependency-map.md` — Dependencias cross-sistema documentadas con evidencia

---

## FUENTES DE INFORMACIÓN REQUERIDAS

Para poblar este DT se necesita acceso a:
- Inventario de aplicaciones del área de TI
- Diagrama de arquitectura enterprise (TOGAF o equivalente)
- Catálogo de servicios ITSM (ServiceNow probable)
- Inventario de contratos de licenciamiento
- CMDB / topología de red

---

## CLASIFICACIÓN TOGAF INICIAL (SCAFFOLD)

Ver `../../CLAUDE.md` sección "Landscape de Sistemas" para el estado actual del landscape.

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — pendiente discovery real*
