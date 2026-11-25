# Script para Copilot — Lámina 8, Gantt de aprovisionamiento

> Datos: `plan-staffing-oct-nov.md`. Copilot arma mal los Gantt como gráfica; este script pide un Gantt de tabla.
> Si lo deforma, son once filas por siete columnas y se arma a mano.

---

```
CAMBIO, agrega una lámina nueva al final, como lámina 8
Título: Gantt de aprovisionamiento, octubre y noviembre
Línea introductoria: Los tres frentes abren en la semana del 21 de octubre. Las
once posiciones se cubren dentro de la ventana por redespliegue interno y
centros nearshore.

Construye una tabla de Gantt, no una gráfica. Siete columnas con estos
encabezados exactos:
  Rol y nivel
  21-25 oct
  26-30 oct
  2-6 nov
  9-13 nov
  16-20 nov
  23-30 nov

Convención de llenado: morado Ancla significa recurso activo, gris Plano
significa semana de incorporación, celda vacía significa sin asignar. No
escribas texto dentro de las celdas de la línea de tiempo.

Filas agrupadas por frente, con una fila de encabezado de bloque en gris Plano
y texto en negritas antes de cada grupo.

BLOQUE BANAMEX
  Solution Architect del laboratorio, L7, Anexo B
    gris en 21-25 oct, morado de 26-30 oct hasta 23-30 nov
  SDLC y DevSecOps Architect, L8, Anexo B
    gris en 21-25 oct, morado de 26-30 oct hasta 23-30 nov
  API y Developer Platform Architect, L7
    gris en 26-30 oct, morado de 2-6 nov hasta 23-30 nov
  Lead Architect de Modernización con Brain, L6
    gris en 2-6 nov, morado de 9-13 nov hasta 23-30 nov

BLOQUE BANCOPPEL
  Enterprise Architect, L5
    gris en 21-25 oct, morado de 26-30 oct hasta 23-30 nov
  Service Architect AMS con Brain Engineer, L6
    gris en 26-30 oct, morado de 2-6 nov hasta 23-30 nov
  Integration and Platform Architect, L6
    gris en 2-6 nov, morado de 9-13 nov hasta 23-30 nov

BLOQUE TODO LO DEMÁS
  Cloud and Infrastructure Migration Architect, L6
    gris en 21-25 oct, morado de 26-30 oct hasta 23-30 nov
  Reinvention Managed Services Architect, L6
    gris en 26-30 oct, morado de 2-6 nov hasta 23-30 nov
  Lead Architect de Modernización con Brain y QE, L6
    gris en 2-6 nov, morado de 9-13 nov hasta 23-30 nov
  Solution Architect de Producto, Integración y Data & AI, L6
    gris en 9-13 nov, morado de 16-20 nov hasta 23-30 nov

BLOQUE FUERA DEL ALCANCE DE ARQUITECTURA
  Equipo de ingeniería del laboratorio, 4.30 FTE
    morado desde 21-25 oct hasta 23-30 nov, sin celdas grises

Agrega una banda de hitos alineada a las mismas columnas:
  En 21-25 oct: Apertura de los tres frentes y cierre de Habilitación inicial,
  23 de octubre
  En 2-6 nov: Sesión de acreditación, 6 de noviembre
  En 9-13 nov: Entregables 1 y 2 y cuota de arranque, 11 de noviembre
  En 16-20 nov: Equipo completo, once arquitectos activos
  En 23-30 nov: MVP de Backstage, 27 de noviembre

Agrega una fila final llamada Arquitectos activos, con estos valores por
columna: 0, 4, 7, 10, 11, 11.

Agrega al pie, en texto pequeño: Las celdas grises son la semana de
incorporación y las moradas, recurso productivo. Las once posiciones se cubren
por banca de recursos, rotación de engagements y centros nearshore de
Accenture. El Anexo B prohíbe la subcontratación, y nearshore propio no lo es.

Mensaje de cierre en recuadro gris: Los tres frentes abren en la misma semana
con cuatro incorporaciones, y el equipo queda completo el 16 de noviembre. La
decisión que se pide no es presupuesto sino autorización para mover gente de
otros frentes esta semana. Las requisiciones externas se abren en noviembre
para cubrir los huecos que deja ese movimiento.
```

---

**Pendiente de reconciliar:** este Gantt lista once posiciones, pero la sesión del 21 de octubre aprobó cuatro aperturas. Ver `plan-staffing-oct-nov.md`, sección 5.
