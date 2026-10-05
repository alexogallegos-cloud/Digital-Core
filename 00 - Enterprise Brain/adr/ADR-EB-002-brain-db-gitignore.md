# ADR-EB-002 — brain.db en .gitignore — pipeline como fuente de verdad

**Estado**: APROBADO
**Fecha**: 2026-09-29
**Autores**: alejandro.gallegos@accenture.com
**Contexto**: Gestión del brain.db en el repositorio git del proyecto

---

## Contexto

El archivo `brain.db` crece entre 50 MB y 500 MB según el tamaño del sistema analizado. Almacena el resultado de procesar cientos de miles de líneas de código fuente del cliente — datos que se derivan completamente del contenido de `source/`.

La pregunta es: ¿se commitea `brain.db` al repositorio o se reconstruye desde el pipeline?

---

## Decisión

**brain.db nunca se commitea al repositorio git**. Se agrega a `.gitignore` desde el primer día del proyecto.

La fuente de verdad es siempre el código fuente en `source/` y los scripts de build en `generators/`. El brain.db es un artefacto derivado — reconstruible desde el pipeline en cualquier momento.

---

## Razones

1. **Tamaño**: un brain.db de sistema mediano pesa 150-400 MB. Git no está diseñado para archivos binarios de este tamaño — ralentiza `git status`, `git pull` y `git clone` para todo el equipo.
2. **Binario no diffable**: git no puede mostrar qué cambió entre dos versiones de un brain.db. Los commits de "update brain.db" son cajas negras.
3. **Reproducibilidad como propiedad de diseño**: si el brain no se puede reconstruir desde el pipeline, hay un problema en el pipeline — no en la decisión de gitignore. Cualquier estado del brain es reproducible con `python generators/build-brain.py`.
4. **Sin secretos del cliente en git**: el brain.db puede contener fragmentos de código fuente propietario del cliente. No commitear elimina el riesgo de filtración en repositorios corporativos.
5. **Consistencia**: la regla es simple y sin excepciones — elimina debates sobre "¿este brain sí o no?".

---

## Consecuencias

- Cada developer necesita reconstruir el brain localmente después de un `git clone` o `git pull`.
- El pipeline de CI/CD no tiene brain.db — si un workflow necesita el brain, debe buildear primero.
- El tiempo de build (extracción + enrichment + build-brain.py) debe documentarse en el README del sistema como expectativa del desarrollador.
- Para compartir el brain entre miembros del equipo sin rebuild, se puede usar una ruta de red compartida — documentada en el CLAUDE.md del sistema, no en git.

---

## Alternativas rechazadas

| Alternativa | Por qué se rechazó |
|-------------|-------------------|
| Git LFS | Resuelve el problema de tamaño pero no el de binario no diffable ni el de secretos del cliente. Agrega complejidad operativa. |
| Commitear con .gitattributes binary | No diffable, poluciona el historial, riesgo de datos del cliente en git. |
| Commitear solo el brain "inicial" | Crea inconsistencias — ¿cuál es el brain canónico? El del repositorio o el construido localmente. |

---

*ADR-EB-002 · Enterprise Brain · Digital Core · Accenture México · 2026-09-29*
