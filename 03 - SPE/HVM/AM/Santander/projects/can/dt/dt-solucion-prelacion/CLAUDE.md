# DT — Solución Motor de Prelación CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Fase:** DESIGN / BUILD
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Diseña el motor de prelación de cargos CAN requerido por OBL-016 y el mecanismo
de timing para OBL-023 (transferencia de prestaciones laborales). Esta es la obligación
operativa más crítica del proyecto: un error en la prelación implica incumplimiento
regulatorio Banxico con sanción directa.

> **Criticidad:** OBL-016 y OBL-023 son las obligaciones con mayor impacto operativo diario.
> Afectan cada ciclo de nómina de todos los clientes con Cuenta Ordenante y CANs designados.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Core Banking Transformation | Diseño del motor · integración con procesamiento de cuentas |
| Software Engineering | Implementación del algoritmo de prelación |
| IT Operating Model | Batch scheduling · SLA operativo DHB · monitoreo |
| Industry Payments → SPEI | Timing SPEI de nómina · hora de corte 17:00 DHB |

---

## Regla de Prelación — OBL-016

### Orden de Cargos (obligatorio por normativa)

```
CUENTA ORDENANTE — ORDEN DE CARGOS EN CICLO DE NÓMINA

NIVEL 1: Créditos NO-CAN de la misma institución depositaria
         contratados ANTES de cualquier CAN designado
         → Cargo por saldo insoluto según contrato original

NIVEL 2: CANs — en orden cronológico de designación (fecha y hora)
         → Primero el CAN más antiguo
         → Si fondos insuficientes: cargar lo disponible + completar
           con siguientes abonos de nómina

NIVEL 3: Domiciliaciones de bienes/servicios y otros créditos NO-CAN
         → Solo si quedan fondos después de NIVEL 1 y NIVEL 2
```

### Caso especial — Fondos insuficientes para un CAN

```
Saldo disponible = $2,000
CAN importe periódico = $3,500

→ Cargo parcial: $2,000 (lo disponible)
→ Pendiente: $1,500 → marca como CARGO_PARCIAL_PENDIENTE
→ En siguiente abono de nómina: cobrar $1,500 antes de cualquier otro cargo
```

---

## Algoritmo del Motor de Prelación

### Pseudocódigo

```python
def ejecutar_prelacion_cuenta(cuenta_clabe: str, abono_nomina: Decimal) -> ResultadoPrelacion:
    """
    Ejecuta el algoritmo de prelación para una Cuenta Ordenante.
    Se invoca al recibir cada abono de prestaciones laborales.
    """
    saldo_disponible = abono_nomina + recuperar_saldo_cuenta(cuenta_clabe)
    cargos_ejecutados = []
    cargos_pendientes = []

    # NIVEL 1: Créditos no-CAN previos (misma institución, anteriores a CANs)
    creditos_no_can = obtener_creditos_no_can_previos(cuenta_clabe)
    for credito in creditos_no_can:
        if saldo_disponible >= credito.importe_cuota:
            ejecutar_cargo(cuenta_clabe, credito, credito.importe_cuota)
            saldo_disponible -= credito.importe_cuota
            cargos_ejecutados.append(credito)
        else:
            # Cargo parcial o skip — per términos del crédito original
            cargos_pendientes.append(credito)

    # NIVEL 2: CANs en orden cronológico de designación (OBL-016)
    cans_activos = obtener_cans_por_prelacion(cuenta_clabe)  # ORDER BY fecha_hora_designacion ASC
    for can in cans_activos:
        importe_pendiente = can.importe_pendiente or can.importe_periodico
        if saldo_disponible >= importe_pendiente:
            ejecutar_cargo(cuenta_clabe, can, importe_pendiente)
            saldo_disponible -= importe_pendiente
            limpiar_cargo_parcial_pendiente(can)
            cargos_ejecutados.append(can)
        elif saldo_disponible > 0:
            # Cargo parcial — el resto se cobra en el siguiente abono
            ejecutar_cargo(cuenta_clabe, can, saldo_disponible)
            registrar_cargo_parcial_pendiente(can, importe_pendiente - saldo_disponible)
            saldo_disponible = 0
            break
        else:
            # Sin fondos — este CAN y los siguientes quedan pendientes
            cargos_pendientes.append(can)

    # NIVEL 3: Domiciliaciones y otros créditos no-CAN
    if saldo_disponible > 0:
        domiciliaciones = obtener_domiciliaciones(cuenta_clabe)
        for domiciliacion in domiciliaciones:
            if saldo_disponible >= domiciliacion.importe:
                ejecutar_cargo(cuenta_clabe, domiciliacion, domiciliacion.importe)
                saldo_disponible -= domiciliacion.importe
                cargos_ejecutados.append(domiciliacion)
            else:
                cargos_pendientes.append(domiciliacion)

    log_prelacion(cuenta_clabe, cargos_ejecutados, cargos_pendientes)
    return ResultadoPrelacion(ejecutados=cargos_ejecutados, pendientes=cargos_pendientes)
```

---

## Motor de Timing — OBL-023

### Regla de Timing (obligación crítica)

```
Si el abono de prestaciones laborales llega ANTES de las 17:00:00 DHB:
    → Ejecutar prelación y transferir remanente el MISMO DHB

Si el abono llega DESPUÉS de las 17:00:00 DHB:
    → Ejecutar prelación y transferir remanente el DHB SIGUIENTE

Excepción CAN (Art. 75 in fine):
    → Si hay cargos CAN pendientes, aplicarlos ANTES de transferir el remanente
    → El timing del remanente puede extenderse hasta que se complete la prelación
```

### Implementación Scheduler

```
ARQUITECTURA DE SCHEDULER (hipótesis — confirmar con IT Operating Model Santander)

Opción A: Batch controlado por evento
  · Al recibir abono SPEI de nómina → trigger inmediato del motor de prelación
  · Sin espera por hora de corte — procesa en cuanto llega el abono
  · Ventaja: tiempo real · Desventaja: carga variable durante el día

Opción B: Batch por hora de corte
  · Acumula abonos de nómina recibidos antes de las 16:45
  · Ejecuta prelación en lote a las 16:45 para cumplir SLA 17:00
  · Abonos después de 16:45 → batch DHB siguiente a las 09:00
  · Ventaja: carga predecible · Desventaja: latencia en procesamiento

Opción C: Híbrido (recomendado)
  · Trigger inmediato para prelación CAN
  · Transferencia del remanente: misma lógica de corte 17:00
```

### Monitor SLA 17:00 (OBL-023)

```
· Alerta a las 16:30 si hay cuentas con prelación CAN sin ejecutar
· Alerta CRÍTICA a las 16:55 si no se completó la prelación para alguna cuenta
· Dashboard operativo: cuentas procesadas vs pendientes por ventana DHB
· Escalación automática a equipo de operaciones si no se cumple el SLA
```

---

## Casos de Prueba Clave (para dt-solucion-testing)

| ID | Escenario | Resultado esperado |
|----|-----------|-------------------|
| PREL-001 | Abono suficiente para todos los niveles | Todos los cargos ejecutados · remanente disponible |
| PREL-002 | Abono insuficiente para CAN nivel 2 | Cargo parcial registrado · pendiente en siguiente abono |
| PREL-003 | Dos CANs — fondos para el primero pero no el segundo | CAN-1 completo · CAN-2 parcial o pendiente |
| PREL-004 | Abono llega a las 14:00 DHB | Prelación + transferencia remanente el mismo DHB |
| PREL-005 | Abono llega a las 17:30 DHB | Prelación + transferencia remanente el DHB siguiente |
| PREL-006 | Cliente cancela CAN durante ciclo en curso | Prelación ignora CAN cancelado · SLA OBL-020 alertado |
| PREL-007 | CAN de otra institución (Santander como Depositaria) | Santander cobra en prelación y remite a institución acreedora |
| PREL-008 | CAN nuevo con fecha de designación posterior | Queda en NIVEL 2 pero con prioridad menor que CANs más antiguos |

---

## Observabilidad

| Métrica | Descripción | Threshold alerta |
|---------|-------------|-----------------|
| `can.prelacion.cuentas_procesadas_dia` | Cuentas procesadas en el ciclo DHB | < 95% del total → WARNING |
| `can.prelacion.cargos_parciales_activos` | CANs con cargo parcial pendiente | > 1,000 → WARNING |
| `can.prelacion.latencia_p99` | Tiempo de ejecución del motor de prelación | > 5 seg → WARNING |
| `can.sla023.incumplimientos` | Cuentas que no procesaron a tiempo | > 0 → CRITICAL |
| `can.prelacion.errores_db` | Errores al escribir en tabla can_prelacion | > 0 → CRITICAL |

---

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Especificación algoritmo de prelación (detallado) | `knowledge-base/rules/spec-motor-prelacion.md` |
| Diseño de scheduler / batch OBL-023 | `knowledge-base/rules/spec-scheduler-obl023.md` |
| Casos de prueba PREL-001 a PREL-008 | → `dt-solucion-testing` |
| Dashboard de observabilidad (métricas) | → `systems/compliance/azure-backbone/` |

## Dependencias

- `[DEPENDS-ON: dt-solucion-datos]` — tabla `can_prelacion` y campos en cuentas
- `[DEPENDS-ON: dt-solucion-arquitectura]` — dónde vive el motor (loans vs core-banking vs can-engine)
- `[DATO-REQUERIDO]` — Cómo procesa HOY Santander los cargos de nómina (batch? evento SPEI?)
- `[DATO-REQUERIDO]` — Scheduler existente (ControlM? Azure Logic Apps? quartz?)
- `[DATO-REQUERIDO]` — Ventanas operativas de nómina de los patrones de Santander

*v0.1.0 · 2026-09-17 · fase DESIGN · CRITICIDAD ALTA*
