# Capacidad: Payments — Cargos y Abonos Core [S500]
> Dominio: 6 · Common Services · Capacidad: 6.1.3
> Cobertura: S500 · Programa principal: P020 (LINCOMS) · Contexto: P142 (Teradata) · P144 (Conciliación B01/B03)

---

## Contexto funcional

El sistema S500 gestiona la captación bancaria de Banamex sobre la plataforma **Unisys ClearPath MCP**. El programa **P020 (LINCOMS)** actúa como **gateway COMS secundario** de procesamiento online de cargos y abonos; su contraparte primaria es P010. P020 opera como servidor COMS multi-copia (5 copias concurrentes), cada una con identidad propia, tabla de failover y tipo de proceso distinto para el libro mayor **S151**.

El flujo central de pagos core cubre:
1. **Recepción** de la transacción del canal (CVETRAN + cuenta + monto) vía COMS.
2. **Clasificación contable** del CVETRAN en rangos CARGO / ABONO / NCO (no-contable).
3. **Validación** contra el catálogo dinámico 174.
4. **Posting** al archivo S02 (ordenado) y asiento en el libro mayor S151 (REGISTRAS500).
5. **Cálculo fiscal** de IVA (16 % / 11 % frontera) e ISR (factor 0.50) sobre comisiones.
6. **TEF** (Transferencias Electrónicas de Fondos): asignación, reasignación y replicación cross-CSI vía I11-REPLICA hacia Monterrey (CSI-F=04) o Valle de México (CSI-L=10).
7. **Controles operativos**: apagado diferenciado por copia, toggle S151 en caliente, cierre de día contable con recarga de librerías.
8. **Eventos especiales**: decomiso EPP (CNBV/PLD) y bloque DIVESTITURE Citi→Banamex.

P142 (batch diario) extrae atributos de contrato hacia Teradata (CREDITOS CAN); P144 (batch diario) concilia el indicador de ordenante entre BD07 ATRIBUCTA y BD01 CAPTACION. Ambos son **contexto downstream** de la capacidad PAY; no ejecutan cargos ni abonos directos pero comparten la topología host cross-CSI y las tasas ISR/IVA hardcodeadas.

**Plataforma:** Unisys ClearPath MCP · COBOL · DMSII · COMS (servidor de mensajes)
**Geografía:** Valle de México (VDM, CSI-L=10) · Monterrey (MTY, CSI-F=04)
**Regulación aplicable:** CNBV (reporting, EPP) · Banxico (SPEI/TEF HA) · SAT (IVA, ISR Art. 93 LISR)

---

## Inventario de Tareas

| ID | Nombre | Tipo | Programa | Reglas vinculadas |
|----|--------|------|----------|-------------------|
| T-PAY-001 | Clasificación de CVETRAN en rangos NCO / CARGO / ABONO | validación | P020 | RN-S500-115 |
| T-PAY-002 | Validación contra catálogo 174 (CVETXN autorizado) | validación | P020 | RN-S500-116 |
| T-PAY-003 | Enrutamiento de copias COMS y asignación de TIPO-PROC S151 | control | P020 | RN-S500-108, RN-S500-109 |
| T-PAY-004 | Ordenamiento y generación del archivo posting S02 | contable | P020 | RN-S500-117 |
| T-PAY-005 | Asiento en libro mayor S151 (REGISTRAS500) | escritura | P020 | RN-S500-108, RN-S500-114 |
| T-PAY-006 | Cálculo de IVA e ISR sobre comisiones y rendimientos | contable | P020 | RN-S500-122 |
| T-PAY-007 | Procesamiento TEF — asignación y reasignación de cuentas | escritura | P020 | RN-S500-110, RN-S500-121 |
| T-PAY-008 | Replicación cross-CSI del estado TEF (I11-REPLICA) | control | P020 | RN-S500-111, RN-S500-112 |
| T-PAY-009 | Control de apagado diferenciado del gateway COMS | control | P020 | RN-S500-113 |
| T-PAY-010 | Toggle en caliente de integración S151 (TASKVALUE=3027) | control | P020 | RN-S500-114 |
| T-PAY-011 | Cierre de día contable — cancelación y recarga de librerías | contable | P020 | RN-S500-119 |
| T-PAY-012 | Decomiso EPP — bloque judicial (TASKVALUE=3019) | escritura | P020 | RN-S500-118 |
| T-PAY-013 | Proceso DIVESTITURE Citi→Banamex (TASKVALUE=3016) | control | P020 | RN-S500-120 |

---

## Casuísticas

### CS-PAY-01 — Cargo exitoso

**Precondiciones:** Canal online envía transacción con CVETRAN en rango 2000-2999, cuenta válida y saldo suficiente.

1. P020 recibe el mensaje vía COMS en una de sus 5 copias.
2. **T-PAY-001**: `WKS-CVETXN-CAR` se activa (CVETRAN 2000 THRU 2999).
3. **T-PAY-002**: P020 busca CVETXN en `WKS-CAT174-CVETXN`; `WKS-CVETXN-174-OK=0` → autorizado.
4. **T-PAY-004**: Registro se escribe en `I08-POSTING-I`; se ordena en `S02-POSTING-T` por clave `CVETXN + SUC + CTO + IMP`.
5. **T-PAY-005**: Si la transacción incluye comisión, se aplica IVA (`WS-IVA-GRAL=16`) e ISR (`WS-ISR-0=0.50`).
6. **T-PAY-005**: Se envía asiento de cargo a `S151REGISTRA` con `WS-S151-TIPO-PROC = 33-37` (según copia activa).

**Resultado:** Cargo debitado, asiento en S151 confirmado, registro en I08-POSTING-I.

---

### CS-PAY-02 — Transacción rechazada (CVETXN no en catálogo 174 o posting fallido)

**Precondiciones:** Canal envía transacción cuyo CVETXN no existe en catálogo 174, o el posting S02 retorna error.

1. **T-PAY-002**: `WKS-CVETXN-174-NF=1` → CVETXN no autorizado.
2. P020 desvía la transacción a `I02-PROBLEMAS` sin generar asiento en S151.
3. Alternativa: Si el posting falla, el registro va a `I10-POSTING-E` con `POSTERR-DET-CVETXN` para identificar el CVETXN fallido.
4. No se produce débito ni crédito contable. El canal recibe respuesta de error por COMS.

**Resultado:** Transacción registrada en PROBLEMAS / POSTING-E; sin movimiento en saldos ni GL.

---

### CS-PAY-03 — Proceso DIVESTITURE (flag activo durante separación Citi→Banamex)

**Precondiciones:** Operador ejecuta TASKVALUE=3016 durante la ventana de separación corporativa.

1. **T-PAY-013**: P020 detecta `TASKVALUE=3016` en su sección DECLARATIVES (interrupt handler).
2. Se ejecuta el procedimiento `0000-HIS-WFL23`, que lanza el job stream `WFL23` en el mainframe.
3. `WFL23` ejecuta la migración de datos de separación Citi→Banamex sin necesidad de reiniciar el servidor COMS.
4. El bloque está delimitado por comentarios `*INI DIVESTITURE / *FIN DIVESTITURE`, permitiendo extraerlo cuando el proceso de separación concluya.

**Resultado:** Job stream de separación lanzado en caliente; transacciones de canal siguen fluyendo normalmente en paralelo.

---

## Diagrama

```mermaid
sequenceDiagram
    participant CLI as Canal / Cliente
    participant COMS as P020 LINCOMS<br/>(copia 1-5)
    participant CAT as Catálogo-174
    participant S080 as S080BD01CON<br/>(tarifas)
    participant S02 as S02-POSTING
    participant S151 as S151REGISTRA<br/>(GL / libro mayor)
    participant I11 as I11-REPLICA<br/>(cross-CSI)

    CLI->>COMS: TX (CVETRAN, CTO, IMP, MON)
    COMS->>COMS: T-PAY-001 — Clasificar CVETRAN<br/>NCO (0-999) · CARGO (2000-2999)<br/>ABONO (1000-1999 / 3000-3999)
    COMS->>CAT: T-PAY-002 — Validar CVETXN en cat-174
    CAT-->>COMS: OK (174-OK=0) / Rechazado (174-NF=1)

    alt CVETRAN = CARGO exitoso
        COMS->>S080: T-PAY-006 — Consultar tarifa IVA/ISR
        S080-->>COMS: IVA=16% · ISR=0.50
        COMS->>S02: T-PAY-004 — Escribir registro en I08-POSTING-I<br/>Sort por CVETXN+SUC+CTO+IMP
        COMS->>S151: T-PAY-005 — Asiento cargo (TIPO-PROC 33-37)
        S151-->>COMS: Confirmación GL
        COMS-->>CLI: Respuesta OK
    else CVETRAN = ABONO exitoso
        COMS->>S02: T-PAY-004 — Escribir en I09-POSTING-O
        COMS->>S151: T-PAY-005 — Asiento abono (TIPO-PROC 33-37)
        S151-->>COMS: Confirmación GL
        COMS-->>CLI: Respuesta OK
    else CVETXN rechazado (cat-174 NF o posting error)
        COMS->>COMS: Redirigir a I02-PROBLEMAS / I10-POSTING-E
        COMS-->>CLI: Respuesta error
    end

    Note over COMS,I11: COPIA-5 en modo LINEA — T-PAY-008
    COMS->>I11: Replicación cross-CSI (WAIT 1200s prod)
    I11-->>COMS: Estado replicado a CSI opuesto (VDM↔MTY)
```

---

## Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-PAY-001 | RN-S500-115 | P020 — WKS-CVETXN-NCO/ABO/CAR | Clasificación CVETRAN en rangos NCO (0-999), ABONO (1000-1999, 3000-3999), CARGO (2000-2999); valores 534=ELIM y 575=ELIM-DEVOL dentro de NCO |
| T-PAY-002 | RN-S500-116 | P020 — WKS-CAT174-CVETXN | Validación de CVETXN en catálogo 174 dinámico; WKS-CVETXN-174-NF=1 indica transacción no autorizada; catálogo recargable en caliente |
| T-PAY-003 | RN-S500-108 | P020 — WS-S151-TIPO-PROC | Asignación de tipo-proceso S151 por copia: copia 1→33, 2→34, 3→35, 4→36, 5→37; permite que S151 diferencie el origen del movimiento |
| T-PAY-003 | RN-S500-109 | P020 — WKS-SIGUIENTE | Tabla fija de failover de copias: 1→03, 2→01, 3→04, 4→02, 5→02; copias 4 y 5 comparten el mismo siguiente (02) |
| T-PAY-004 | RN-S500-117 | P020 — S02-KEY-CVETXN | Clave compuesta de ordenamiento del archivo posting S02: CVETXN(4)+SUC+CTO+IMP+PROD+INST+MON; rechazos van a I10-POSTING-E |
| T-PAY-005 | RN-S500-108 | P020 — REGISTRAS500 | Posting al GL S151 con TIPO-PROC diferenciado por copia; si S151 desactivado, el TIPO-PROC se asigna pero no se usa |
| T-PAY-005 | RN-S500-114 | P020 — WS-UTILIZA-S151-VA | Toggle en caliente de S151 vía TASKVALUE=3027 (solo PBA/LINEA); CANCEL "REGISTRAS500" para desactivar, LIB-S151L002R500 para reactivar |
| T-PAY-006 | RN-S500-122 | P020 — WS-IVA-GRAL, WS-ISR-0 | IVA general 16%, IVA fronterizo 11%, ISR factor 0.50 (2017: 0.58), exención ISR USD 8668; hardcodeado en P020 + P010 + P142 + P144 sin parámetro centralizado |
| T-PAY-007 | RN-S500-110 | P020 — WS-SOLO-VDM | Si hostname MTY: WS-SOLO-VDM=1; procesamiento TEF solo en copias 1/2/3 (VDM); MTY opera en modo consulta-online únicamente |
| T-PAY-007 | RN-S500-121 | P020 — WS-88-ASIGNA-TEF | TEF CVETRANs: 759=RSG-TEF-RDA, 760=ASG-TEF-RDA, 761=ASG-TEF-SUC, 762=RSG-TEF-BCANET; 759-760 masivos, 761-762 simples |
| T-PAY-008 | RN-S500-111 | P020 — WKS-HOST-ORIG/DEST-XFER | 8 pares host cross-CSI hardcodeados para replicación TEF (VDM↔MTY) + 6 pares clonados; topología Banxico SPEI HA |
| T-PAY-008 | RN-S500-112 | P020 — 50201400-I11-REPLICA | Solo COPIA-5 en modo LINEA genera I11-REPLICA; en producción espera 1200 segundos (WAIT 1200) para que P010 complete su ciclo antes de replicar |
| T-PAY-009 | RN-S500-113 | P020 — SMCOMS-DISABLE | TASKVALUE=3004 apaga cualquier copia; TASKVALUE=3104 apaga solo COPIA-1; WS-COMS-RESULT=1 como confirmación |
| T-PAY-010 | RN-S500-114 | P020 — WS-UTILIZA-S151-VA | Ver T-PAY-005; mismo mecanismo toggle |
| T-PAY-011 | RN-S500-119 | P020 — CAMBIA-DIA-CONTABLE | Cancela 7 librerías dinámicas + espera 5s + recarga; COPIA-3 cancela además S500L050DYR; si S151 activo: también cancela REGISTRAS500 al cierre |
| T-PAY-012 | RN-S500-118 | P020 — DECOMISO-S111 | TASKVALUE=3019 → 00000000-3019-DECOMISO-S111; CVETXN=534 (ELIM) y 575 (ELIM-DEVOL) vinculados a reversión; proyecto P0126372 (Automate EPP Control Figures) |
| T-PAY-013 | RN-S500-120 | P020 — WFL23 | TASKVALUE=3016 → 0000-HIS-WFL23; bloque delimitado *INI/*FIN DIVESTITURE en DECLARATIVES; extraíble sin reiniciar servidor |

---

## Hallazgos de migración

| # | Riesgo | Tarea(s) | Severidad | Acción recomendada |
|---|--------|----------|-----------|-------------------|
| H-PAY-01 | **IVA/ISR hardcodeados en 4 programas** (P010, P020, P142, P144) sin parámetro centralizado. Un cambio de SAT requiere coordinar compilación y despliegue simultáneo de todos. Existe evidencia de un ciclo incompleto (valor 0.60 comentado). | T-PAY-006 | 🟠 Alta | Externalizar tasas a tabla de parámetros (cat-S080 o tabla administrada). Crear contrato único SAT-RATE leído en runtime. Eliminar duplicación cross-programa. |
| H-PAY-02 | **Rangos CVETRAN NCO/ABONO/CARGO hardcodeados** (0-999, 1000-1999, 2000-2999, 3000-3999). El rango 3000-3999 como ABONO no aparece en WKS-CVETXN-ABO del posting (excepción sin validar). | T-PAY-001 | 🟠 Alta | Mapear catálogo de CVETRAN a tabla parametrizable. Verificar con SME si 3000-3999 es ABONO en todos los flujos o solo en S151; resolver la excepción antes de transpilación. |
| H-PAY-03 | **Tabla de failover de copias COMS hardcodeada** (WKS-SIGUIENTE: 1→03, 2→01, 3→04, 4/5→02). Copias 4 y 5 convergen al mismo siguiente, lo que concentra el riesgo de failover. | T-PAY-003 | 🟡 Media | Externalizar a fichero de configuración. Evaluar si la arquitectura cloud-target requiere el mismo modelo de multi-copia o si se reemplaza por load balancer. |
| H-PAY-04 | **Pares host cross-CSI duplicados en P020, P142 y P144** sin COPY book compartido. Un cambio de topología de red (nuevo nodo CSI) requiere actualizar 3 programas por separado en ventana coordinada. | T-PAY-008 | 🟠 Alta | Centralizar la tabla de pares en un único COPY book o micro-servicio de configuración de topología. En la arquitectura target, reemplazar con service discovery. |
| H-PAY-05 | **COPIA-5 espera 1200 segundos** (20 min) antes de replicar I11 en producción; en PBA es inmediato. Comportamiento environment-specific sin parámetro configurable. | T-PAY-008 | 🟡 Media | Parametrizar el tiempo de espera (WAIT N) como variable de entorno o registro de control B02. Documentar el fundamento del umbral de 20 minutos con el equipo de operaciones. |
| H-PAY-06 | **Restricción MTY basada en hostname** (WS-DH-HOSTNAME-MTY). La lógica de routing geográfico está atada a los nombres de host de producción Unisys; no aplica en PBA/SIT/UAT, lo que puede generar divergencias de comportamiento entre entornos. | T-PAY-007 | 🟠 Alta | Reemplazar detección de hostname por variable de entorno o configuración explícita CSI. Asegurar paridad comportamental entre entornos en la arquitectura target. |
| H-PAY-07 | **Bloque DIVESTITURE (TASKVALUE=3016)** — código con fecha de vida conocida. Una vez completada la separación Citi→Banamex, el bloque debe extraerse. Los delimitadores `*INI/*FIN DIVESTITURE` facilitan la identificación. | T-PAY-013 | 🟢 Baja | Confirmar estado del proceso de separación con el equipo legal/regulatorio. Si completado: eliminar el bloque y el procedimiento 0000-HIS-WFL23 antes de transpilación para no arrastrar deuda técnica. |
| H-PAY-08 | **Catálogo 174 no recargado por TASKVALUE=3040** (que recarga cat-1789). Cat-174 es componente separado con mecanismo de recarga propio no documentado en las reglas leídas. | T-PAY-002 | 🟡 Media | Identificar el TASKVALUE o procedimiento de recarga de cat-174 en el código fuente completo. Asegurar que el equivalente cloud mantenga el mismo SLA de recarga. |

---

*cap-pay.md · v1.0 · 2026-07-16*
*Capacidad: 6.1.3 Payments · Sistema: S500 · Programas: P020 LINCOMS · P142 · P144*
*Cross-referencia: RN-S500-108..152 · rules-s500-p020-p142-p144.md · capability-map.md*
