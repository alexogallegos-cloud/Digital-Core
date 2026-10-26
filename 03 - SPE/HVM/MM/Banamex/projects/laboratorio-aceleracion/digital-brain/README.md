# Digital Brain del Laboratorio de Aceleración

Capa SQLite consultable del proyecto. Existe para que las cuatro iniciativas estratégicas
arranquen sin un descubrimiento de meses, y para que el equipo pueda responder en segundos qué
está contratado, qué falta y de quién depende.

## Cómo se usa

```bash
cd digital-brain/
PYTHONUTF8=1 python build-brain.py   # reconstruye lab-brain.db desde cero
PYTHONUTF8=1 python brain.py         # resumen del estado
```

```python
from brain import LabBrain

with LabBrain() as b:
    b.ruta_critica()                 # cadena hacia la sesión que libera la cuota de arranque
    b.sin_dependencias()             # qué puede arrancar hoy
    b.datos_requeridos()             # qué le falta pedir al banco
    b.talla_por_consumo(35000)       # la talla no se contrata, se lee del consumo
    b.candidatos_contrato()          # capacidades del core con más reglas, para derivar contratos
    b.preparacion_iniciativa("INI-01")
```

## Fuentes

| Capa | Fuente | Regla |
|---|---|---|
| Contrato | `source/sow/`, Anexo B firmado | Fuente de verdad contractual. Nada se infiere |
| Laboratorio | `source/docs/`, diseño de solución v8 | Propuesta aceptada, no compromiso contractual |
| Setup | `plan-setup.md` | El plan es la fuente; el brain lo vuelve consultable |
| Iniciativas | Contexto del proyecto más brechas detectadas | Las brechas marcadas DATO-REQUERIDO son del banco |
| Core | `systems/core/unisys/digital-brain/brain.db` | **Federado por referencia, nunca copiado** |

## Federación con el brain del core

El brain del core (S500 y S151) se abre en solo lectura cuando hace falta. Su corpus no se
duplica: `core_snapshot` guarda solo contadores, y los métodos `core_*` consultan en vivo.

Lo que aporta hoy: 1,583 reglas de negocio extraídas del código, 26 capacidades, 181 riesgos de
migración, 5 decisiones de disposición 7R, 218 piezas de inventario y 152 programas.

El puente de mayor valor es `candidatos_contrato()`. El Anexo B pide que el core emulado se
construya a partir de contratos de interfaz, esquemas de mensajes y reglas de negocio
proporcionados por el cliente. El brain del core ya tiene esas reglas extraídas del código, así
que en lugar de esperar a que el banco las redacte, se le pueden proponer contratos derivados
de su propio legado para que los apruebe.

## Esquema

Cinco capas, veinte tablas.

**Contrato:** `contrato`, `entregables_contractuales`, `compromisos_servicio`, `tallas`,
`penas`, `criterios_arranque`.

**Laboratorio:** `arquetipos`, `capas_lab`, `compuertas`, `stack`, `rutas_codigo`.

**Setup:** `fases`, `actividades` con búsqueda de texto completo, `entregables_setup`.

**Iniciativas:** `iniciativas`, `habilitadores`, `brechas`.

**Federación y gobierno:** `brains_federados`, `core_snapshot`, `decisiones_abiertas`, `stats`.

## Convenciones

- `lab-brain.db` es generado y no va a git. Se reconstruye con `build-brain.py`.
- No se guardan nombres de personas del cliente. Los contactos de escalamiento viven en el
  Anexo B como rol, y el brain solo registra el rol.
- Si un dato no está en el Anexo ni en el diseño, se modela como brecha o decisión abierta, no
  se inventa.
