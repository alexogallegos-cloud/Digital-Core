# Core Banking — Application Modernization Agent
# togaf_type: core
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: core-banking
# bian_domains: ["current-account", "savings-account", "product-management", "customer-management"]
# discovered: 2026-09-17 · fuente: hipótesis técnica (sistema propietario no divulgado)

> Core bancario Santander México · Sistema de Registro principal (SoR)
> Agente especializado del sistema. Para vista federada: `../../santander-brain/CLAUDE.md`

---

## IDENTIDAD DEL SISTEMA

| Campo | Valor |
|-------|-------|
| Nombre real | Por confirmar (sistema propietario Santander) |
| Tipo TOGAF | core — System of Record (SoR) |
| Estado | Baseline (en producción) |
| Tecnología | Por confirmar — investigar en discovery |
| Hosting | Por confirmar (on-premise · colocación · nube) |
| Equivalencia requerida | ≥ 99.99% (SoR crítico) |
| Regulación | CNBV CUB · Banxico · UIF |

---

## DATO-REQUERIDO — DISCOVERY OBLIGATORIO

> `[DATO-REQUERIDO]` El nombre real y stack tecnológico del core banking de Santander México
> es información confidencial no disponible públicamente. Requiere NDA y acceso cliente.
> **Prioridad ALTA** en discovery — es el punto de partida de cualquier evaluación AM.

### Preguntas clave de discovery

1. ¿Cuál es el nombre del sistema core bancario (Temenos, Silverlake, Finacle, propietario)?
2. ¿Qué versión y release está en producción?
3. ¿Es compartido con otras entidades del grupo o instancia dedicada México?
4. ¿Cuál es la antigüedad del sistema? ¿Ha habido migraciones parciales?
5. ¿Qué bases de datos usa (Oracle, DB2, SQL Server, otro)?
6. ¿Qué lenguajes y frameworks (Java, COBOL, propietario)?
7. ¿Cuántos stored procedures o módulos de lógica de negocio existen?
8. ¿Cuál es el MIPS/recursos de cómputo actual?

---

## CAPACIDADES ESPERADAS (HIPÓTESIS)

| Capacidad BIAN | Estado |
|----------------|--------|
| Current Account | PROBABLE |
| Savings Account | PROBABLE |
| Product Management | PROBABLE |
| Customer Management | PROBABLE |
| Transaction Processing | PROBABLE |
| Interest Calculation | PROBABLE |
| Regulatory Reporting | PROBABLE |

---

## DEPENDENCIAS ESPERADAS (SCAFFOLD)

| Sistema | Tipo | Criticidad |
|---------|------|------------|
| Card Platform | writes/reads | CRÍTICA |
| Loans | reads/writes | CRÍTICA |
| Payments Engine | calls | CRÍTICA |
| Finance ERP | feeds | ALTA |
| CNBV Reporting | feeds | ALTA |
| Datawarehouse | feeds | MEDIA |

---

## PRÓXIMOS PASOS

- [ ] `[DATO-REQUERIDO]` Confirmar nombre real del sistema core
- [ ] Solicitar acceso a documentación técnica (NDA firmado)
- [ ] Ejecutar assessment TOGAF: ABB-to-SBB mapping
- [ ] Aplicar Regla B8 — evidencia operativa como fuente inicial
- [ ] Construir `digital-brain/brain.db` mínimo

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — sistema crítico, información confidencial pendiente*
