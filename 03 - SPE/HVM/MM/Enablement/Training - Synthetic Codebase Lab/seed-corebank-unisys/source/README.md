# Source representativo · SISTEMA-CORE-UNISYS

A escala de core banking real (~830 programas) **no se emite cada fuente a mano** —
no aportaría y sería irreal de mantener. La estrategia es **grafo-como-dato**:

- **El sistema completo vive en `../graph/`** — `dependency-graph.json` (830 nodos,
  3,607 aristas) y `copybook-usage.json` (capa de acoplamiento por copybook). Esa es
  la verdad del sistema y lo que se entrega a una herramienta/RE para el benchmark.
- **`source/` contiene source Unisys real y legible** sólo para:
  1. los **hubs** (utilerías de fan-in alto: `UDMSIIWR`, `UDATECONV`), y
  2. el **bounded context `deposits` completo** como muestra de un dominio.

Así se puede inspeccionar código ClearPath auténtico (COBOL85 + DMSII verbs, WFL,
ALGOL, DASDL) sin pretender que 830 archivos escritos a mano son "realistas".

| Carpeta | Contenido |
|---------|-----------|
| `dasdl/` | Schema DMSII del core (DASDL) |
| `copybooks/` | Copybooks compartidos (los que crean el acoplamiento oculto) |
| `wfl/` | Work Flow Language — job nocturno de deposits |
| `cobol/` | Programas COBOL: deposits BL + hub UDMSIIWR |
| `algol/` | Utilería de sistema en ALGOL (hub UDATECONV) |

> Para regenerar el grafo: `python ../generator/generate.py` (determinista, seed 2200).