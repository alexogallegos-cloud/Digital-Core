# Digital Brain de SDLC Reinvent

Motor de razonamiento sobre el ciclo de entrega de software del banco. No es un archivo de
documentos ni una memoria del proyecto: es la capa que contesta, en segundos, si una palanca de
eficiencia se puede accionar hoy, qué la detiene y qué evidencia haría falta para acreditarla.

La pregunta que lo justifica es incómoda y conviene tenerla a la vista: hoy nadie en el banco
puede decir cuánto tarda un cambio en llegar a producción. Mientras eso siga así, cualquier
promesa de eficiencia es una opinión.

## Cómo se usa

```bash
cd digital-brain/
PYTHONUTF8=1 python build-brain.py   # reconstruye sdlc-brain.db desde cero
PYTHONUTF8=1 python brain.py         # tablero del estado actual
```

```python
from brain import SdlcBrain

with SdlcBrain() as b:
    b.linea_base()                    # cuánto del ciclo está medido, hoy cero
    b.listo_para_comprometer()        # ¿se puede prometer un porcentaje al cliente?
    b.ruta_critica()                  # la fecha dura más próxima y lo que cuelga de ella
    b.cuellos_de_botella()            # fricción por etapa, lo observado antes que lo supuesto
    b.contradicciones()               # dónde dos fuentes del expediente se contradicen
    b.preparacion_componente("C-01")  # ¿puede arrancar este componente y qué lo frena?
    b.que_mueve("M-DORA-01")          # qué palancas y componentes mueven una métrica
    b.recomendar_escenario()          # qué adopción corresponde al estado real
    b.datos_requeridos()              # qué hay que pedirle al banco
    b.core_candidatos_contrato()      # contratos de interfaz derivables del legado
```

## Las cinco funciones que importan

`linea_base()` devuelve la cobertura de medición del ciclo. Hoy son cero de once métricas
medibles. Ese número es el estado real del programa y conviene no maquillarlo.

`listo_para_comprometer()` es el guardrail GR-01 convertido en función. Mientras falte línea
base, haya contradicciones de toolchain de impacto alto o brechas abiertas del banco, responde
que no, enumera las razones y propone la alternativa defendible: comprometer el método y la
cadencia de medición, nunca el porcentaje.

`ruta_critica()` ordena las fechas duras. La más próxima no es del programa sino del Anexo B del
Laboratorio de Aceleración, y la siguiente es el MVP del portal de desarrollador.

`contradicciones()` es la parte menos obvia y la de mayor valor inmediato. Dos propuestas vivas
del mismo banco asumen repositorios y motores de integración distintos, y las dos marcan su
supuesto como dato de cliente. Alguien está equivocado y hay plantillas que dependen de saber
quién.

`core_candidatos_contrato()` cruza con el brain del core. El Anexo B pide construir el core
emulado a partir de contratos de interfaz que el banco debe proporcionar, y esos contratos no
existen. El brain del core ya tiene las reglas extraídas del código, así que se pueden proponer
contratos derivados del propio legado para que el banco los apruebe, en lugar de esperar a que
los redacte.

## Fuentes

| Capa | Fuente | Regla |
|---|---|---|
| Programa | deal-states de los cuatro componentes vivos | Estado y economía se leen de ahí, no se reestiman |
| Toolchain | Supuestos técnicos de esos mismos deal-states | Se conserva la etiqueta original: confirmado, pendiente, en disputa |
| Pipeline | `Portfolio FY27/data/pipeline-fy27.json` | Línea base congelada el 21 de octubre de 2026 |
| Ciclo de referencia | `lab-brain.db`, INI-04 y compuertas G0 a G4 | Federado por referencia, nunca copiado |
| Legado | `systems/core/unisys/digital-brain/brain.db` | Federado por referencia y solo en agregado |
| Guardrails | `Digital Core/03 - SPE/Frictionless SDLC/CLAUDE.md` | Principio rector y antipatrones del sub-offering |

## Federación

Los dos brains vecinos se abren en solo lectura cuando hacen falta y su corpus no se duplica
aquí. Del brain del core solo se leen agregados: la cadencia histórica se devuelve por año y
nunca con nombres de personas, aunque la tabla de origen los tenga.

La cadencia histórica del core merece una advertencia. Sale de marcas fechadas en comentarios
del código, así que cuenta los cambios que alguien se molestó en fechar, no todos los cambios.
Es un piso, no una medición, y sirve únicamente mientras no exista telemetría real del pipeline.

## Esquema

Cinco capas, dieciséis tablas.

**El ciclo:** `etapas`, `friccion`, `metricas`.

**Toolchain:** `herramientas`, `contradicciones`.

**El programa:** `componentes`, `dependencias`, `hitos`.

**Razonamiento:** `palancas`, `guardrails`, `escenarios`.

**Gobierno y federación:** `brechas`, `decisiones_abiertas`, `fuentes`, `brains_federados`,
`stats`.

## Convenciones

- `sdlc-brain.db` es generado y no va a git. Se reconstruye con `build-brain.py`.
- La fricción se marca como observada solo cuando una fuente del expediente la respalda. Lo que
  viene de patrón sectorial se marca como hipótesis y se queda ahí hasta que alguien la valide
  contra el banco.
- Ninguna métrica lleva meta mientras no tenga línea base. Fijar la meta antes de medir es la
  forma más rápida de perder la discusión después.
- No se guardan nombres ni cargos de personas del cliente. Los interlocutores entran como rol.
- Si un dato no está en una fuente, se modela como brecha o como decisión abierta. No se
  inventa, no se estima y no se rellena con un promedio de industria.
