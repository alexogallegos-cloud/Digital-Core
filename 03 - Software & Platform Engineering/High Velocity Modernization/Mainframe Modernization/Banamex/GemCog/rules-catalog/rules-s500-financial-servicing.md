# Catálogo de Reglas de Negocio — S500 Financial Servicing · Compliance · Reconciliation
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P105 · P015 · P045 · P180 · P120 · P102 · P005 · P046 (Financial Servicing) · P106 (Compliance) · P160 (Financial Reconciliation) · P101 (Scheduling)
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S500-611 a RN-S500-664 (54 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-611 — Aplicación de movimientos a datasets de Cifras e Histórico por clave de movimiento (CVEMOV)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-611 |
| **Nombre** | Aplicación de movimientos a datasets de Cifras e Histórico por clave de movimiento (CVEMOV) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P105 (S500P105 batch) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El batch P105 aplica los movimientos de Ahorros, CtaMae y Cheques tanto al dataset de Cifras como al de Histórico, ramificando la lógica contable según la clave de movimiento (CVEMOV). Cada clave determina un tratamiento contable distinto: entrada/salida de plazo, apertura, bloqueo o cancelación.

**Fórmula/pseudocódigo:**
```
51040000-ACT-CIFRAS:
  SI CVEMOV = 1072 Y BAN-MOV07 = 1  → crear B27, ADD IMPORTE a CIF-6D-ACTUAL
     SI ORIGEN = 1 → ADD a CIF-6D-ENT-L   (entrada local)
     SINO         → ADD a CIF-6D-ENT-FR  (entrada foránea)
  SI CVEMOV = 3036 (salida SBC 6 días)  → ADD a CIF-6D-SAL, SUBTRACT de CIF-6D-ACTUAL
  SI BAN-APE = 1 (apertura)  → ADD 1 a CIF-NUM-APE, ADD IMPORTE a CIF-SDO-APE
  SI CVEMOV = 1009 (SBC tradicional) Y BAN-DIAL = 0 → SBC-B07
```

**Vocabulario en la fórmula:** CVEMOV · CIF-6D-ACTUAL · ORIGEN · BAN-APE · SBC · B27

**Excepciones:**
- El origen 1 se trata como local; cualquier otro valor se trata como foráneo (entrada/salida FR).
- CVEMOV 1009 con BAN-DIAL = 1 (movimiento de diálogo) limpia decenas de campos temporales antes de acumular a CIF-IMP-SDOSBC-FE.

**Estado validación:** Verificado fuente líneas 5348-5427

---

## RN-S500-612 — Clasificación de cancelaciones por producto mediante siete claves de movimiento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-612 |
| **Nombre** | Clasificación de cancelaciones por producto mediante siete claves de movimiento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P105 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P105 reconoce siete claves de movimiento distintas como cancelaciones de contrato, cada una asociada a un producto o canal específico. Al detectar cualquiera de ellas incrementa el contador de cancelaciones del día en el dataset de Cifras, que después alimenta la estadística B09.

**Fórmula/pseudocódigo:**
```
SI CVEMOV = 2014 (CtaMae o Cheques)
   OR 2093 (Ahorros)  OR 2216 (Perfiles)
   OR 2269 (Soriana)  OR 2271 (Soriana-Evolución)
   OR 2365 (Cta Global) OR 2534 (Cta Global x reactivación de origen)
   → ADD 1 TO CIF-NUM-CANCE(INDCIF)
...
ADD CIF-NUM-CANCE(PRD) TO B09-NUM-CANCELAC
```

**Vocabulario en la fórmula:** CVEMOV · Cancelación · CtaMae · Soriana · Cuenta Global · B09-NUM-CANCELAC

**Excepciones:**
- La clave 2534 corresponde a una cancelación de Cuenta Global generada por reactivación de su cuenta global origen, no a una cancelación solicitada por el cliente.
- Las claves 2269/2271 (Soriana / Soriana-Evolución) reflejan el convenio comercial con esa cadena; son hardcode de negocio ligado a un tercero.

**Estado validación:** Verificado fuente líneas 5350-5356, 5394-5396, 9637

---

## RN-S500-613 — Tratamiento diferenciado de SBC a 6 días (entradas y salidas de plazo)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-613 |
| **Nombre** | Tratamiento diferenciado de SBC a 6 días (entradas y salidas de plazo) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P105 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los Saldos Básicos de Captación (SBC) a 6 días tienen contabilidad especializada de plazo. La entrada (CVEMOV 1072) acumula al saldo actual de 6 días y crea el registro en B07; la salida (CVEMOV 3036) resta del saldo actual y acumula a la bolsa de salidas, discriminando siempre entre flujo local y foráneo por el campo ORIGEN.

**Fórmula/pseudocódigo:**
```
SI CVEMOV = 1072 (entrada SBC 6D) Y BAN-SBC6 = 1 → 51042000-SBC-B07
SI CVEMOV = 3036 (salida SBC 6D):
   SI ORIGEN = 1 → ADD IMPORTE a CIF-6D-SAL-L, SUBTRACT de CIF-6D-ACTUAL
   SINO         → ADD IMPORTE a CIF-6D-SAL-FR, SUBTRACT de CIF-6D-ACTUAL
```

**Vocabulario en la fórmula:** SBC · 6 días · B07 · CIF-6D-ACTUAL · ORIGEN

**Excepciones:**
- La creación del registro B07 para la entrada sólo ocurre si simultáneamente BAN-SBC6 = 1; la bandera BAN-MOV07 activa una ruta B27 distinta.

**Estado validación:** Verificado fuente líneas 5370-5387

---

## RN-S500-614 — Generación de archivo de punteo contra el S151 desde el sistema de Tarjetas S054

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-614 |
| **Nombre** | Generación de archivo de punteo contra el S151 desde el sistema de Tarjetas S054 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P105 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P105 genera un archivo de punteo cuyos datos provienen del sistema de Tarjetas S054, para que posteriormente se concilie contra el S151. Es el punto de acoplamiento entre la captación (S500) y la contabilidad de movimientos (S151), materializado como archivo físico con ruta estandarizada.

**Fórmula/pseudocódigo:**
```
OPEN OUTPUT PUNTEO CANCELACIONES MOVIMIENTOS
Nombre del archivo de punteo:
   S500/FILE/S500/PTOS111/{csi}/{aammdd}/{copia}
```

**Vocabulario en la fórmula:** Punteo · S151 · S054 · PTOS111 · CSI · Copia

**Excepciones:**
- La ruta incluye CSI (04 ó 10) y copia, por lo que se genera un archivo por copia de proceso.

**Estado validación:** Verificado fuente líneas 84-88, 2907

---

## RN-S500-615 — Segregación de contratos migrados al S111 en el conteo estadístico

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-615 |
| **Nombre** | Segregación de contratos migrados al S111 en el conteo estadístico |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P105 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los contratos marcados como migrados al S111 (B03-MIGR-S111 = 1) se excluyen de determinadas rutinas de acumulación e histórico, para no duplicar cifras entre S500 y el sistema receptor S111. La marca actúa como interruptor de propiedad del dato.

**Fórmula/pseudocódigo:**
```
SI B03-MIGR-S111 = 1
   NEXT SENTENCE   (no acumula histórico ni opera inversión)
SINO
   PERFORM lectura de histórico / operación de inversión
```

**Vocabulario en la fórmula:** B03-MIGR-S111 · Contrato migrado · S111 · Histórico

**Excepciones:**
- En P160 la misma marca evita generar el registro de motor y la comparación de saldos para contratos ya migrados.

**Estado validación:** Verificado fuente P160 líneas 1372-1374, 1395-1396

---

## RN-S500-616 — Movimientos con origen distinto de local pero que deben generar iniciativa contable

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-616 |
| **Nombre** | Movimientos con origen distinto de local pero que deben generar iniciativa contable |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P105 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Existe una regla de excepción documentada en P105 por la cual ciertos movimientos que traen un origen distinto de 1 (por ejemplo origen 3) deben, pese a ello, generar iniciativa contable. El comportamiento depende de la bandera BAN-ORILOC, que sobrescribe la clasificación por origen.

**Fórmula/pseudocódigo:**
```
SI BAN-ORILOC > 0
   → tratar el movimiento como generador de iniciativa
     aunque ORIGEN <> 1 (típicamente ORIGEN = 3)
```

**Vocabulario en la fórmula:** BAN-ORILOC · ORIGEN · Iniciativa contable

**Excepciones:**
- Es lógica frágil: la relación entre origen 3 e iniciativa está codificada en banderas de working-storage, no parametrizada; candidata a documentación explícita en la modernización.

**Estado validación:** Verificado fuente líneas 5364-5367

---

## RN-S500-617 — Dispersión de movimientos a sistemas externos por archivos ordenados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-617 |
| **Nombre** | Dispersión de movimientos a sistemas externos por archivos ordenados |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P015 (DISPERSADOR) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa DISPERSADOR (P015) toma archivos de movimientos previamente generados y ordenados y los dispersa hacia múltiples sistemas externos: dispersión estándar S087, dispersión S152, conciliación EAS-HUB, movimientos de tarjeta/cajeros (TBINT diario y semanal) y saldos pendientes. Es el nodo de fan-out de la captación hacia el ecosistema.

**Fórmula/pseudocódigo:**
```
SI WKS-HAY-ORDENADO-A-DISPERSAR (valor 1 ó 2)
   PERFORM 50050000-DISPERSA-ORDENADO
      1 = ORDENADO-CM pendiente por dispersar
      2 = ORDENADO-SP (saldo pendiente) por dispersar
Destinos: DISPS087, DISPS152, EAS-HUB, MOVTBINT, MOVTBINTSEM, SALDOSPEN
```

**Vocabulario en la fórmula:** Dispersión · S087 · S152 · EAS-HUB · TBINT · Saldo Pendiente

**Excepciones:**
- Los archivos EAS-HUB corresponden a conciliación (comentarios NOR-INI/NOR-FIN), integración más reciente que el resto.

**Estado validación:** Verificado fuente líneas 33-66, 4759-4766, 1642-1645

---

## RN-S500-618 — Prohibición de dispersión bajo condición de batch y control de reinicio

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-618 |
| **Nombre** | Prohibición de dispersión bajo condición de batch y control de reinicio |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P015 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** DISPERSADOR incorpora candados para no repetir una dispersión ya efectuada ni dispersar en condiciones de batch no permitidas. Ante reinicio, sólo vuelve a dispersar el archivo pendiente, tomando de la base los archivos ya dispersados para no duplicar el envío a sistemas externos.

**Fórmula/pseudocódigo:**
```
SI condición no válida → "ERROR NO SE PERMITE DISPERSAR EN BATCH 0002"
SI ya existe archivo de saldo pendiente → "YA SE TIENE ARCHIVO PARA DISPERSAR..."
En reinicio → tomar archivos ya dispersados de la base de datos,
              redispersar sólo el pendiente
```

**Vocabulario en la fórmula:** Dispersión · Reinicio · Batch 0002 · Idempotencia

**Excepciones:**
- La duplicación de una dispersión implicaría doble aplicación de movimientos en sistemas externos; por eso el candado es crítico aunque silencioso.

**Estado validación:** Verificado fuente líneas 1531, 1610-1621, 4729, 5031-5076

---

## RN-S500-619 — Acceso a archivos externos por llave con organización secuencial y acceso aleatorio

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-619 |
| **Nombre** | Acceso a archivos externos por llave con organización secuencial y acceso aleatorio |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P015 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Todos los archivos de dispersión de P015 se declaran como OPTIONAL, con organización secuencial y modo de acceso RANDOM mediante ACTUAL KEY. Esto permite que la ausencia física del archivo no aborte el paso (OPTIONAL) y que el programa posicione registros por llave para reintentos y conciliación selectiva.

**Fórmula/pseudocódigo:**
```
SELECT OPTIONAL DISPS087 ASSIGN DISK
   ORGANIZATION SEQUENTIAL  ACCESS RANDOM  ACTUAL KEY WS-LLAVE-DISPS087
(idéntico patrón para DISPS152, EAS-HUB, SALDOSPEN, MOVTBINT)
```

**Vocabulario en la fórmula:** OPTIONAL · ACTUAL KEY · ACCESS RANDOM · Llave de dispersión

**Excepciones:**
- El uso de OPTIONAL es deliberado: si el archivo destino aún no existe, el flujo continúa en lugar de truncar el batch diario.

**Estado validación:** Verificado fuente líneas 34-66

---

## RN-S500-620 — Conversión de clave de donativo genérica 1500 según el BIN de la tarjeta

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-620 |
| **Nombre** | Conversión de clave de donativo genérica 1500 según el BIN de la tarjeta |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P045 (Donativos / TELETON) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En los donativos con cargo a tarjeta, la clave genérica de movimiento 1500 se convierte a una clave contable específica en función del BIN de la tarjeta con que se paga. La conversión distingue tarjetas Banamex vs. otros bancos, nacional vs. internacional y American Express, cada una con su propia clave de gasto.

**Fórmula/pseudocódigo:**
```
CLAVE 1500 se convierte según BIN (esquema 2016):
   0793 → Tarjetas Banamex          Nacional        (antes 1503)
   0794 → Tarjetas otros bancos     Nacional        (antes 1502)
   0795 → Tarjetas otros bancos     Internacional   (antes 1504)
   0796 → American Express                          (antes 3505/1502)
```

**Vocabulario en la fórmula:** Donativo · Clave 1500 · BIN · Banamex · American Express · TELETON

**Excepciones:**
- Los códigos entre paréntesis ("ANTERIOR") son claves previas a 2016; conviven en el histórico y deben mapearse en la modernización.

**Estado validación:** Verificado fuente líneas 22-33

---

## RN-S500-621 — Restricción de sucursales autorizadas para donativos con cargo a tarjeta (Q050066)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-621 |
| **Nombre** | Restricción de sucursales autorizadas para donativos con cargo a tarjeta (Q050066) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P045 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El donativo por cargo a tarjeta mediante la pantalla Q050066 sólo puede operarse desde un conjunto cerrado de sucursales de captación de valores. Las eliminaciones de donativo (Q050067) sí operan en todas las sucursales. Además, el llamado a seguridad S041 diferencia montos menores y mayores con claves distintas.

**Fórmula/pseudocódigo:**
```
Q050066 (cargo a tarjeta): SOLO sucursales 0519 OR 4899 OR 1037 OR 1905
Q050067 (elimina donativo): TODAS las sucursales
Seguridad S041:
   Montos Menores → clave "Q050066A"
   Montos Mayores → clave "Q050066B"
```

**Vocabulario en la fórmula:** Q050066 · Sucursal · Donativo · S041 · Monto menor/mayor

**Excepciones:**
- Las sucursales 0519, 1037, 1905 y 4899 corresponden a CtaS de captación de valores; el conjunto es hardcode operativo.

**Estado validación:** Verificado fuente líneas 8-13, 35-39

---

## RN-S500-622 — Máquina de estados del ciclo TELETON en el campo B02-ACT-TELETON

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-622 |
| **Nombre** | Máquina de estados del ciclo TELETON en el campo B02-ACT-TELETON |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P045 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El campo B02-ACT-TELETON gobierna como máquina de estados el ciclo de vida de la campaña TELETON: activar, desactivar, terminar y continuar. Las transiciones se disparan por pantalla Q050070 en P010 y son calificadas por el WFL/Lote diario mediante P100 opción 9. Cada estado detona un conjunto específico de procesos de base y líneas.

**Fórmula/pseudocódigo:**
```
Transiciones válidas de B02-ACT-TELETON (por Q050070 antes de 22:00 hrs):
   0 → 1  ACTIVA    TELETON
   1 → 0  DES-ACTIVA TELETON
   2 → 3  TERMINA   TELETON
   3 → 2  CONTINUA  TELETON
Ejecución WFL/Lote opción TELETON por valor: "0" nada · "1" crea base+líneas
   · "2" respalda y repite "1" · "3" da de baja e inicializa B02-ACT-TELETON=0
```

**Vocabulario en la fórmula:** B02-ACT-TELETON · TELETON · Q050070 · S500BD06TELETON · WFL/Lote

**Excepciones:**
- La modificación por pantalla sólo es válida antes de las 22:00 hrs (ventana operativa de corte).

**Estado validación:** Verificado fuente líneas 55-99

---

## RN-S500-623 — Ventana de corte de 22:00 hrs para modificación del estado TELETON

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-623 |
| **Nombre** | Ventana de corte de 22:00 hrs para modificación del estado TELETON |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P045 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El cambio del valor de B02-ACT-TELETON por pantalla debe realizarse antes de las 22:00 hrs. Después de esa hora el valor queda congelado para que el WFL/Lote diario lo califique de forma consistente, evitando que un cambio tardío altere el proceso batch ya en curso.

**Fórmula/pseudocódigo:**
```
SI hora_modificacion < 22:00
   permitir cambio de B02-ACT-TELETON via Q050070
SINO
   el valor queda para calificación por WFL/Lote (P100 "9")
```

**Vocabulario en la fórmula:** 22:00 hrs · B02-ACT-TELETON · Corte · WFL/Lote

**Excepciones:**
- La hora de corte 22:00 es hardcode operativo ligado al arranque del batch diario; no está parametrizada.

**Estado validación:** Verificado fuente líneas 57-68

---

## RN-S500-624 — Comandos de control operativo del monitor de mensajes y autorizador B24

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-624 |
| **Nombre** | Comandos de control operativo del monitor de mensajes y autorizador B24 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P045 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P045 recibe por parámetro comandos numéricos que gobiernan la operación de la línea: activar o desactivar el monitor de mensajes por cuenta única o todas (9999), habilitar/deshabilitar seguridad y el autorizador B24, y limpiar revocaciones pendientes de L012. Es la consola operativa de la aplicación en línea.

**Fórmula/pseudocódigo:**
```
Parámetro de control de P045:
   02XXXX activa monitor de mensajes (XXXX=cta única, 9999=todas)
   03     desactiva monitor de mensajes
   04     fin de la aplicación (baja de líneas)
   10     deshabilita seguridad     · 11 habilita seguridad
   36     habilita/deshabilita autorizador B24
   4646   elimina de L012 revocaciones pendientes
```

**Vocabulario en la fórmula:** Monitor de mensajes · Autorizador B24 · Seguridad · Revocación · L012

**Excepciones:**
- El valor 9999 como comodín de "todas las cuentas" es una convención de negocio embebida.

**Estado validación:** Verificado fuente líneas 100-109

---

## RN-S500-625 — Donativos por aplicación (TEOS e Internet) siempre con cargo a tarjeta y autorización B24

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-625 |
| **Nombre** | Donativos por aplicación (TEOS e Internet) siempre con cargo a tarjeta y autorización B24 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P045 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los donativos originados por aplicación, tanto desde tercer nivel (TEOS) como desde Internet, operan exclusivamente con cargo a tarjeta bajo la clave 1500, y en ambos canales el S500 solicita autorización al sistema B24 antes de aplicar el cargo. No se admiten donativos por aplicación con cargo a cuenta.

**Fórmula/pseudocódigo:**
```
Donativo por aplicación (canal TEOS 3er nivel  o  Internet):
   clave 1500  CON cargo a tarjeta
   → S500 pide autorización a B24  antes de aplicar
```

**Vocabulario en la fórmula:** Donativo · TEOS · Internet · Clave 1500 · B24 · Cargo a tarjeta

**Excepciones:**
- La clave 1500 se resuelve a la clave contable definitiva según el BIN (ver RN-S500-620) sólo tras la autorización de B24.

**Estado validación:** Verificado fuente líneas 18-24

---

## RN-S500-626 — Reporte de inventario de inversiones de Ahorros a partir del archivo INVE clasificado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-626 |
| **Nombre** | Reporte de inventario de inversiones de Ahorros a partir del archivo INVE clasificado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P180 (REPORTEADOR) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El REPORTEADOR (P180) genera los archivos y listados de inventario de las inversiones de Ahorros tomando como insumo el archivo INVE que el paso previo P181 produce ya clasificado por nodo, sucursal, producto, instrumento, moneda y contrato. P180 lo sortea y arma el inventario impreso por esa jerarquía.

**Fórmula/pseudocódigo:**
```
Insumo: archivo INVE clasificado por (NODO, SUCURSAL, PRD, INS, MON, CTO) — generado en P181
INVE-PTE se sortea → arma REG-INVEN (132 chars)
Etiqueta: S500/FILE/INVEPTE/{csi}/{fecha}/...
```

**Vocabulario en la fórmula:** Inventario · Inversiones · Ahorros · INVE · Nodo · Sucursal · INVEPTE

**Excepciones:**
- La clasificación del INVE es responsabilidad de P181; P180 asume que llega ordenado.

**Estado validación:** Verificado fuente líneas 45-49, 148-338

---

## RN-S500-627 — Migración de la generación de archivos Datateca y Génesis del P180 al P181 (ABR/2019)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-627 |
| **Nombre** | Migración de la generación de archivos Datateca y Génesis del P180 al P181 (ABR/2019) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P180 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En la versión ABR/2019 se eliminó de P180 la generación de los archivos para Datateca y Génesis, trasladándola al nuevo paso P181, que también clasifica el archivo INVE. Esta separación de responsabilidades es un antecedente directo de descomposición modular relevante para la modernización.

**Fórmula/pseudocódigo:**
```
Versión ABR/2019:
   P180 ya NO genera archivos Datateca ni Génesis
   P181 genera el INVE clasificado + archivos Datateca/Génesis
   P180 consume el INVE de P181 para listados
```

**Vocabulario en la fórmula:** Datateca · Génesis · P181 · INVE · Versión ABR/2019

**Excepciones:**
- Cualquier lógica que downstream espere estos archivos desde P180 debe reapuntarse a P181.

**Estado validación:** Verificado fuente líneas 44-50

---

## RN-S500-628 — Catálogo de estatus de devolución de cheques por fondos insuficientes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-628 |
| **Nombre** | Catálogo de estatus de devolución de cheques por fondos insuficientes |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P120 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P120 clasifica cada intento de devolución con un estatus de dos dígitos que documenta el desenlace del cheque devuelto: devolución efectiva, cobro posterior, saldo suficiente al cierre, duplicado evitado, bloqueo, contrato inexistente, producto sin claves de cobro, recuperación total en S408, clave inválida, eliminado o causa distinta a fondos insuficientes. Este catálogo es la fuente de verdad del ciclo de devolución.

**Fórmula/pseudocódigo:**
```
WKS-I00-R01-STATUS-DEV:
  00 = DEVOLUCION            06 = NO COBRA PRODUCTO (falta claves B05/B17)
  01 = FUE COBRADO (post)    07 = RECUPERADO TOTAL en S408
  02 = CTO CON SALDO SUF.    08 = ERR CVE (no es 2001/2002/2113)
  03 = DUPLICADO (no cobrar) 09 = ELIMINADO
  04 = SIN COBRO X BLOQ (bloqueo 66, restricciones 17)
  05 = NO EXISTE CONTRATO    10 = CAUSA DEV no es por fondos insuficientes
```

**Vocabulario en la fórmula:** Devolución · STATUS-DEV · Fondos insuficientes · Bloqueo · Duplicado · B05 · B17

**Excepciones:**
- El estatus 03 (duplicado) es un candado de idempotencia para no cobrar dos veces la misma devolución.
- El estatus 04 depende de bloqueo tipo 66 y restricciones tipo 17 (esquema de bloqueos B05/B17).

**Estado validación:** Verificado fuente líneas 701-712

---

## RN-S500-629 — Devolución sólo procede para claves de movimiento válidas (2001, 2002, 2113)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-629 |
| **Nombre** | Devolución sólo procede para claves de movimiento válidas (2001, 2002, 2113) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P120 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Una devolución únicamente es cobrable si la clave de movimiento asociada pertenece al conjunto autorizado 2001, 2002 ó 2113. Cualquier otra clave se marca con estatus 08 (ERR CVE) y no genera cargo, evitando cobros sobre movimientos que no corresponden al proceso de devolución de cheques.

**Fórmula/pseudocódigo:**
```
SI CVE-MOV NO EN (2001, 2002, 2113)
   MOVE 08 (ERR CVE) TO STATUS-DEV
   → no cobrar la devolución
```

**Vocabulario en la fórmula:** CVE-MOV · Devolución · 2001 · 2002 · 2113 · ERR CVE

**Excepciones:**
- El conjunto de claves válidas es hardcode; en la modernización debe externalizarse a catálogo.

**Estado validación:** Verificado fuente línea 710

---

## RN-S500-630 — Solo se devuelve por fondos insuficientes; otras causas se excluyen del cobro

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-630 |
| **Nombre** | Solo se devuelve por fondos insuficientes; otras causas se excluyen del cobro |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P120 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de cobro de devolución de P120 aplica solamente cuando la causa de devolución corresponde a fondos insuficientes. Si la causa registrada es distinta, el movimiento se marca con estatus 10 (CAUSA DEV) y queda fuera del cobro, preservando la semántica de que la devolución de cheque se cobra por insuficiencia de fondos.

**Fórmula/pseudocódigo:**
```
SI CAUSA-DEV <> fondos insuficientes
   MOVE 10 (CAUSA DEV) TO STATUS-DEV
   → no aplica cobro de devolución
```

**Vocabulario en la fórmula:** Causa de devolución · Fondos insuficientes · STATUS-DEV 10

**Excepciones:**
- La subcausa (WKS-I00-R01-SBCAUSA-DEV) matiza la causa principal pero no altera el candado de cobro.

**Estado validación:** Verificado fuente líneas 698-699, 712

---

## RN-S500-631 — Punteo de devoluciones entre S500 y P102 vía archivos puente

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-631 |
| **Nombre** | Punteo de devoluciones entre S500 y P102 vía archivos puente |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P120 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P120 concilia las devoluciones mediante dos archivos puente de punteo: uno de entrada (PUNTEOIN, generado por P102 en la ruta S500/FILE/P102/PUNTEO) y uno de salida (PUNTEOOUT). El punteo cruza los importes y claves de movimiento para determinar qué devoluciones fueron efectivamente cobradas o recuperadas.

**Fórmula/pseudocódigo:**
```
I03-PUNTEOIN  ← S500/FILE/P102/PUNTEO/...   (produce P102)
I02-PUNTEOOUT → resultado del cruce de punteo
Cruce por: NUM-CONTRATO, CVE-MOV, NUM-CHEQUE, IMP-DEVOL
```

**Vocabulario en la fórmula:** Punteo · PUNTEOIN · PUNTEOOUT · P102 · Devolución

**Excepciones:**
- El acoplamiento P102→P120 es por archivo físico, no por base; una falla de residencia rompe la conciliación.

**Estado validación:** Verificado fuente líneas 71-72, 151-159, 825-837

---

## RN-S500-632 — Ingesta de comisiones previas cobradas desde el sistema S127

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-632 |
| **Nombre** | Ingesta de comisiones previas cobradas desde el sistema S127 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P120 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P120 lee un archivo de comisiones previas (COMIPREV) que proviene del sistema S127, con ruta (S127)S127/FILE/S500/COMIPREV. Estas comisiones previamente cobradas modulan el tratamiento de la devolución, para no duplicar cargos ya aplicados por el sistema de comisiones.

**Fórmula/pseudocódigo:**
```
E03-COMIPREV-ENT ← (S127)S127/FILE/S500/COMIPREV/...
ACCESS RANDOM por ACTUAL KEY W77-REG-PREV
→ ajusta el cobro de devolución con la comisión ya cobrada en S127
```

**Vocabulario en la fórmula:** COMIPREV · Comisión previa · S127 · Devolución

**Excepciones:**
- El origen S127 (no S500) marca una dependencia cross-system de comisiones que debe mapearse en la modernización.

**Estado validación:** Verificado fuente líneas 65-86, 745-747

---

## RN-S500-633 — Ejecución de pagos pendientes a Línea de Crédito S408 gobernada por bandera B02

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-633 |
| **Nombre** | Ejecución de pagos pendientes a Línea de Crédito S408 gobernada por bandera B02 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P102 efectúa los pagos pendientes hacia la Línea de Crédito (S408) sólo cuando la bandera de control B02-PGOPEND-S408 está encendida (= 1). Tras procesarlos actualiza los datasets B09 y B14 con los movimientos generados y, al terminar, reinicializa la bandera a 0 para no reprocesar.

**Fórmula/pseudocódigo:**
```
SI B02-PGOPEND-S408 = 1
   efectuar pagos pendientes a L.C. (S408)
   actualizar B09 y B14 con movimientos generados
   dar fin de día al S408 para inicio de su batch
   MOVE 0 TO B02-PGOPEND-S408   (y B02-HAY-ST2113 = 0)
```

**Vocabulario en la fórmula:** B02-PGOPEND-S408 · Línea de Crédito · S408 · B09 · B14 · Fin de día

**Excepciones:**
- El fin de día a S408 dispara el arranque del batch de ese sistema; hay dependencia de secuencia inter-sistema.

**Estado validación:** Verificado fuente líneas 43-54

---

## RN-S500-634 — Generación de archivo de protección de cobros

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-634 |
| **Nombre** | Generación de archivo de protección de cobros |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P102 genera un archivo de protección de cobros con ruta S500/FILE/INTE/50002E01/XX/AAAAMMDD/PROTCOBR. Este archivo preserva la evidencia de los cobros para que, ante un reinicio o incidente, los cargos ya efectuados no se vuelvan a aplicar, protegiendo al cliente de un doble cobro.

**Fórmula/pseudocódigo:**
```
Al procesar cobros → escribir archivo
   S500/FILE/INTE/50002E01/{CSI}/{AAAAMMDD}/PROTCOBR
Función: protección contra doble cobro en reinicio
```

**Vocabulario en la fórmula:** Protección de cobros · PROTCOBR · Doble cobro · Reinicio

**Excepciones:**
- El sufijo 50002E01 identifica el nodo/entidad de intercambio; forma parte de la convención de nombres de intercambio.

**Estado validación:** Verificado fuente líneas 56-58

---

## RN-S500-635 — Reinicialización de banderas de control al cierre de P102 (B02-PGOPEND-S408 y B02-HAY-ST2113)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-635 |
| **Nombre** | Reinicialización de banderas de control al cierre de P102 (B02-PGOPEND-S408 y B02-HAY-ST2113) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al finalizar, P102 reinicializa a cero las banderas de control B02-PGOPEND-S408 (pagos pendientes a Línea de Crédito) y B02-HAY-ST2113 (existencia de status 2113). Es un cierre silencioso pero crítico: si no se reinicializan, la siguiente corrida reprocesaría pagos ya aplicados o interpretaría un estado transitorio como vigente.

**Fórmula/pseudocódigo:**
```
Al finalizar P102 (inicialización de campos):
   MOVE 0 TO B02-PGOPEND-S408
   MOVE 0 TO B02-HAY-ST2113
```

**Vocabulario en la fórmula:** B02-PGOPEND-S408 · B02-HAY-ST2113 · Reinicialización · Idempotencia

**Excepciones:**
- La omisión de esta reinicialización es un riesgo latente de doble aplicación de pagos; debe conservarse explícito en la modernización.

**Estado validación:** Verificado fuente líneas 52-54

---

## RN-S500-636 — Traspaso a beneficiario e integración con archivo del sistema B22

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-636 |
| **Nombre** | Traspaso a beneficiario e integración con archivo del sistema B22 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P102 procesa traspasos a beneficiario (I03-TRASPBENEF, acceso RANDOM por llave) integrando el archivo de dispersión que produjo P010 (I04-DISP-P010) y el archivo del sistema B22 (I05-ARCHB22), y emite un reporte de traspasos a beneficiario (R02-TRPBENEF). Es el eslabón que aplica los pagos a la cuenta del beneficiario final.

**Fórmula/pseudocódigo:**
```
I03-TRASPBENEF (ACCESS RANDOM, ACTUAL KEY W77-KEY-I03)
I04-DISP-P010  ← dispersión generada por P010 (226 chars)
I05-ARCHB22    ← archivo del sistema B22 (144 chars)
→ aplicar traspaso a beneficiario + reporte R02-TRPBENEF
```

**Vocabulario en la fórmula:** Traspaso a beneficiario · TRASPBENEF · B22 · DISP-P010

**Excepciones:**
- El insumo I04-DISP-P010 acopla P102 al online P010; la longitud fija de 226 caracteres es contrato implícito entre ambos.

**Estado validación:** Verificado fuente líneas 73-104

---

## RN-S500-637 — Fin de día a S408 como precondición de arranque de su batch

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-637 |
| **Nombre** | Fin de día a S408 como precondición de arranque de su batch |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Entre las funciones principales de P102 está dar el fin de día al sistema S408 (Línea de Crédito), lo cual es la señal que habilita el inicio del batch de ese sistema. Establece una dependencia de secuencia estricta: el batch de S408 no debe arrancar hasta que P102 haya emitido este fin de día.

**Fórmula/pseudocódigo:**
```
Al concluir el procesamiento de pagos pendientes:
   emitir FIN DE DIA al S408
   → S408 puede iniciar su batch
```

**Vocabulario en la fórmula:** Fin de día · S408 · Línea de Crédito · Secuencia de batch

**Excepciones:**
- Es un handshake inter-sistema no transaccional; una falla silenciosa aquí desincroniza dos cierres.

**Estado validación:** Verificado fuente líneas 50-51

---

## RN-S500-638 — Orquestación de actividad de batch por TASKVALUE (PREBATCH, PRELINEA, FINBATCH, REST24HRS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-638 |
| **Nombre** | Orquestación de actividad de batch por TASKVALUE (PREBATCH, PRELINEA, FINBATCH, REST24HRS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P005 determina su modo de operación a partir del atributo TASKVALUE con que se invoca, mapeando cada valor a una fase del ciclo de batch y a un número de copia MAPLI. Es el despachador de fases del proceso diario de captación.

**Fórmula/pseudocódigo:**
```
Según ATTRIBUTE TASKVALUE OF MYSELF:
   1 → "PREBATCH"     (copia 1, monitor)
   2 → "PRELINEA"     (copia 2)
   3 → "FINBATCH"     (copia 3)
   5 → "REST24HRS"    (copia 5)
   6 → "CARGACATP020" 7 → "INILINEAP020" 8 → "INIBATCHP020"
```

**Vocabulario en la fórmula:** TASKVALUE · PREBATCH · PRELINEA · FINBATCH · REST24HRS · MAPLI · Copia

**Excepciones:**
- Los valores 6/7/8 (CARGACATP020, INILINEAP020, INIBATCHP020) son adiciones marcadas "INI C DYR / FIN C DYR", posteriores al diseño original.

**Estado validación:** Verificado fuente líneas 571-613

---

## RN-S500-639 — Depuración de registros del dataset B10 por marca de depurable

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-639 |
| **Nombre** | Depuración de registros del dataset B10 por marca de depurable |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P005 (DEPURADOR |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La rutina de depuración de P005 (agregada bajo la marca IBM-CHARITY) recorre el dataset B10 y elimina únicamente los registros marcados como depurables mediante la condición WS88-REG-DEPURABLE (valor 1); los no depurables (valor 0) se conservan. El identificador de depuración por default es 03.

**Fórmula/pseudocódigo:**
```
WS-REG-DEPURABLE:
   88 WS88-REG-NODEPURABLE VALUE 0  → conservar
   88 WS88-REG-DEPURABLE   VALUE 1  → depurar (eliminar de B10)
WS10-IDE-DEPURACION default = 03
```

**Vocabulario en la fórmula:** Depuración · B10PDEPURA · Depurable · IBM-CHARITY

**Excepciones:**
- Si no se encuentra el primer registro para depuración se emite "NO ENCONTRE PRIMER REGISTRO PARA DEPURACION B10".

**Estado validación:** Verificado fuente líneas 325-352, 447-495

---

## RN-S500-640 — Registro de avance en el monitor MAPLI del batch diario

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-640 |
| **Nombre** | Registro de avance en el monitor MAPLI del batch diario |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P005 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando P005 opera con monitor activo (W77-SI-MONITOR = 1), inicializa el programa en el monitor MAPLI del "BATCH DIARIO" con grupo 06 y registra el avance del proceso (número de registros procesados y actividad). Provee la telemetría operativa que permite seguir el batch desde la consola.

**Fórmula/pseudocódigo:**
```
SI W77-SI-MONITOR = 1
   grupo MAPLI = 06, nombre lib = "BATCH DIARIO"
   PERFORM 70000950-INI-PGM-MAPLI
   registrar ACT01, número de registro procesado
```

**Vocabulario en la fórmula:** MAPLI · Monitor · BATCH DIARIO · Grupo 06 · Actividad

**Excepciones:**
- El grupo 06 y el nombre "BATCH DIARIO" son constantes de despliegue del monitor.

**Estado validación:** Verificado fuente líneas 618-627

---

## RN-S500-641 — Envío en línea de cancelaciones/revocaciones vía librería L046-REVOCA con time-out

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-641 |
| **Nombre** | Envío en línea de cancelaciones/revocaciones vía librería L046-REVOCA con time-out |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P046 (ALGOL wrapper) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P046 es un programa driver en ALGOL que habilita el canal online (COMS) e invoca el procedimiento ENVIA_CANCELACIONES de la librería L046/REVOCA para transmitir revocaciones/cancelaciones en línea. Resuelve dinámicamente el título de la librería vía control de versiones (CTLVER/DAME_TIT), con un fallback fijo si la consulta de versión falla.

**Fórmula/pseudocódigo:**
```
SI DAME_TIT("S500L046REVO", EA_TIT) < 0
   TITLE de TIME_OUT := "(S500)S500/OBJECT/L046/REVOCA/25MTP002 ON CAPTACION"
SINO
   TITLE := EA_TIT (título resuelto por CTLVER)
ENABLE(COMSINHDR,"ONLINE")
ENVIA_CANCELACIONES(COMS_IN, COMS_OUT, DCIINPUTEVENT, DCITASKEVENT)
```

**Vocabulario en la fórmula:** Revocación · Cancelación · L046 · REVOCA · COMS · Online · Time-out

**Excepciones:**
- El fallback a la versión 25MTP002 hardcodeada garantiza operación aún si CTLVER no responde; puede quedar desactualizado respecto a la versión vigente.

**Estado validación:** Verificado fuente líneas 20-49

---

## RN-S500-642 — Nombre dinámico del listado de salida por marca de tiempo (P046)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-642 |
| **Nombre** | Nombre dinámico del listado de salida por marca de tiempo (P046) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 6.6.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P046 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P046 construye el nombre del listado de salida (BDNAME del proceso) de forma dinámica incorporando la marca de tiempo del sistema, para garantizar unicidad de cada ejecución online. Además activa opciones MCP de volcado (BDBASE, FAULT, DSED, ARRAYS) para diagnóstico ante fallas.

**Fórmula/pseudocódigo:**
```
E_MSG := "S500/LIST/P046/1000/R000/" , TIME(15).[15:48] , "."
MYSELF.BDNAME := E_MSG
MYSELF.OPTIONS := * & 1[VALUE(BDBASE):1] & 1[VALUE(FAULT):1]
                    & 1[VALUE(DSED):1]   & 1[VALUE(ARRAYS):1]
```

**Vocabulario en la fórmula:** BDNAME · TIME(15) · BDBASE · FAULT · DSED · ARRAYS

**Excepciones:**
- Es lógica específica de MCP/ALGOL (atributos de tarea y volcado); sin equivalente directo en plataformas destino, requiere reimplementación de la observabilidad.

**Estado validación:** Verificado fuente líneas 37-44

---

## RN-S500-643 — Estatus resultado de la cancelación de contrato en el S016 (aviso de cancelación)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-643 |
| **Nombre** | Estatus resultado de la cancelación de contrato en el S016 (aviso de cancelación) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P106 (MOD-ARCH) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La opción 5 de P106 procesa la cancelación de contrato en el S016 y devuelve un estatus normalizado que documenta el desenlace de cada intento. La cancelación exitosa coloca el contrato en estatus 31 en el S016; los demás estatus documentan por qué no se pudo cancelar. Este resultado es la evidencia de trazabilidad de cancelaciones exigible en auditoría.

**Fórmula/pseudocódigo:**
```
Resultado de cancelación en S016 (opción 5):
   00 = CORRECTO   → coloca STATUS 31 en el S016
   10 = NO EXISTE en el S016
   16 = NO SE PUEDE MODIFICAR el status en el S016
   99 = RECHAZADO
```

**Vocabulario en la fórmula:** S016 · Cancelación · Estatus 31 · Contrato · Rechazado

**Excepciones:**
- El estatus 99 (rechazado) alimenta el conteo de rechazos que enciende el incidente (ver RN-S500-651).

**Estado validación:** Verificado fuente líneas 15-24 (comentario cabecera), 1222-1234

---

## RN-S500-644 — Invocación de cancelación al S016 vía librería S016L428 con opción 03 y estatus 31

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-644 |
| **Nombre** | Invocación de cancelación al S016 vía librería S016L428 con opción 03 y estatus 31 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al avisar la cancelación al S016, P106 arma la estructura de entrada con producto, instrumento y contrato del registro cancelado, fija la opción de control 03 y el estatus de cuenta 31 (cancelada), y ejecuta la rutina S016L428 B04CTAB08MDA. Es la materialización técnica del aviso regulatorio de cancelación de la cuenta.

**Fórmula/pseudocódigo:**
```
001-AVISA-CANC-S016:
   WS-S016-0701-CTA-NUMPROD-E  ← WKS-I10-PRODUC-D3
   WS-S016-0701-CTA-CVEINST-E  ← WKS-I10-INSTRU-D3
   WS-S016-0701-CTA-NUM-E      ← WKS-I10-CONTRA-D3
   WS-S016-0701-CTR-OPCION-E   ← 03
   WS-S016-0701-CTA-CVESTATUS-E ← 31  (cancelada)
   PERFORM 20000016-L428-B04CTAB08MDA
```

**Vocabulario en la fórmula:** S016L428 · B04CTAB08MDA · Opción 03 · Estatus 31 · Contrato

**Excepciones:**
- El estatus de moneda (MDA-CVESTATUS-E) se envía en 0; sólo se cancela el estatus de cuenta.

**Estado validación:** Verificado fuente líneas 1222-1234

---

## RN-S500-645 — Recuperación auditable de transacciones desde archivos de Rechazos, Log e Incidentes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-645 |
| **Nombre** | Recuperación auditable de transacciones desde archivos de Rechazos, Log e Incidentes |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P106 recupera y reconstruye transacciones desde los archivos operativos de Rechazos, Log e Incidentes buscando por tarjeta, sucursal/cuenta, autorización o contrato. Es la capacidad de trazabilidad y reconstrucción transaccional que sustenta la respuesta ante requerimientos de auditoría y aclaraciones regulatorias.

**Fórmula/pseudocódigo:**
```
Según WKS-IN-FILE:
   1 → Archivo de RECHAZOS       2 → Archivo LOG
   3 → INCIDENTES secuenciales 1..3   4 → INCIDENTE secuencial 4
   5/6 → procesar archivos CANCELADOS por P130
Búsqueda WKS-IN-OPC:
   1 = por Tarjeta o Sucursal/Cta (16 pos)
   3 = por Autorización (8 pos) o Contrato (12 pos)
```

**Vocabulario en la fórmula:** Rechazos · Log · Incidente · Tarjeta · Autorización · Contrato · OnDemand

**Excepciones:**
- Para búsqueda en incidentes la opción por medio "NO APLICA"; sólo aplican los criterios de rechazos/log.

**Estado validación:** Verificado fuente líneas 26-42, 781-798, 949-966

---

## RN-S500-646 — Validación de integridad del header del archivo de cancelados (fecha y CSI)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-646 |
| **Nombre** | Validación de integridad del header del archivo de cancelados (fecha y CSI) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar los detalles de un archivo de contratos cancelados, P106 valida que el header sea del tipo 1 y que su fecha contable y su CSI coincidan con los parámetros de la corrida. Si no coinciden, aborta el procesamiento del archivo con "ERROR EN HEADER", impidiendo aplicar cancelaciones de una fecha o entidad equivocada.

**Fórmula/pseudocódigo:**
```
SI TPOREG-H = 1 (header):
   SI FECH(header) = WKS-IN-FECH  Y  CSIORI-H = CSI de la corrida
      procesar detalles
   SINO
      "ERROR EN HEADER" → escribir en reporte, MOVE 1 TO W77-EOF (aborta)
```

**Vocabulario en la fórmula:** Header · TPOREG · Fecha contable · CSI · Cancelados

**Excepciones:**
- Es un control silencioso-crítico: sin él, un archivo de fecha errónea cancelaría contratos indebidamente.

**Estado validación:** Verificado fuente líneas 1188-1197

---

## RN-S500-647 — Reinicio idempotente del proceso de cancelaciones desde el último contrato leído

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-647 |
| **Nombre** | Reinicio idempotente del proceso de cancelaciones desde el último contrato leído |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P106 mantiene un archivo de reinicio con el último contrato procesado. Ante una nueva corrida, si existe el archivo de reinicio, avanza en el archivo de cancelados hasta reencontrar ese contrato y continúa desde ahí, evitando reprocesar cancelaciones ya avisadas al S016.

**Fórmula/pseudocódigo:**
```
001-VALIDA-INICIO:
   SI existe I02-REINICIO → leer último registro, tomar SEC y FECHA
SI WKS-SI-HAY-REINICIO = 1:
   SI I02-FD-R00-CTO = WKS-I10-CONTRA-D3 → reanudar desde aquí
   SINO → EXIT PERFORM (seguir saltando registros ya procesados)
```

**Vocabulario en la fórmula:** Reinicio · REINICIO · Último contrato · Idempotencia · Cancelados

**Excepciones:**
- El reinicio se escribe con WITH SAVE tras cada aviso, garantizando persistencia por contrato individual.

**Estado validación:** Verificado fuente líneas 1117-1135, 1178-1185, 1318-1334

---

## RN-S500-648 — Opción 6: generación de reporte con estatus 99 a partir del último registro (contingencia)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-648 |
| **Nombre** | Opción 6: generación de reporte con estatus 99 a partir del último registro (contingencia) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La opción 6 de P106 es una ruta de contingencia: en caso de falla del proceso normal (opción 5), genera el reporte marcando estatus 99 (rechazado) a partir del último registro leído de los archivos de cancelados, sin volver a intentar el aviso al S016. Permite cerrar el proceso con evidencia consistente aun ante falla.

**Fórmula/pseudocódigo:**
```
SI WKS-IN-FILE = 6 y TPOREG-D3 = 3 (detalle):
   MOVE 99 TO WS-S016-0701-RESULT
   PERFORM 002-WRITE-REINICIO   (NO llama a S016)
```

**Vocabulario en la fórmula:** Opción 6 · Estatus 99 · Contingencia · Último registro · Reinicio

**Excepciones:**
- A diferencia de la opción 5, la opción 6 no invoca S016L428; sólo documenta el rechazo.

**Estado validación:** Verificado fuente líneas 22-24, 790-794, 1201-1209

---

## RN-S500-649 — Resolución de CSI e identidad de nodo por hostname (producción vs contingencia)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-649 |
| **Nombre** | Resolución de CSI e identidad de nodo por hostname (producción vs contingencia) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P106 determina el número de CSI (Centro de Servicio Informático) que forma parte de todos los títulos de archivo y encabezados a partir del hostname de la máquina. Los hosts de producción/contingencia definidos se mapean a CSI 10 y el resto a CSI 04, lo que a su vez determina la sucursal y nombre de plaza impresos en el reporte regulatorio.

**Fórmula/pseudocódigo:**
```
SI HOSTNAME ∈ {VDMALFA, ACYPGAMA, ACYPOMEGA, VDMBETA}
   MOVE 10 → CSI de rechazos, reporte, incidente, cancelados
SINO
   MOVE 04 → CSI ...
En reporte: CSI 04 → suc 3667 "CYSAU MTY CTROL PROD"
            CSI 10 → suc 3084 "PYCP JARDINES"
```

**Vocabulario en la fórmula:** Hostname · CSI · Nodo · Sucursal · Contingencia

**Excepciones:**
- La lista de hostnames es hardcode de infraestructura MCP; cambia con la topología del datacenter y no es portable.

**Estado validación:** Verificado fuente líneas 814-824, 1288-1293

---

## RN-S500-650 — Reporte regulatorio de transacciones rechazadas del sistema S500 Captación

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-650 |
| **Nombre** | Reporte regulatorio de transacciones rechazadas del sistema S500 Captación |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P106 produce el "REPORTE DE TRANSACCIONES RECHAZADAS DEL SISTEMA S500 INTEGRAL CAPTACION", que documenta cada transacción recuperada con sus parámetros de entrada (fecha, archivo, criterio de búsqueda) y el total de registros encontrados, así como el reporte de rechazos de avisos de cancelación al S016 con conteos de aceptados, rechazados y total.

**Fórmula/pseudocódigo:**
```
Encabezados: "REPORTE DE TRANSACCIONES RECHAZADAS"
             "DEL SISTEMA S500 INTEGRAL CAPTACION"
Cuerpo: FECHA · ARCHIVO · BUSCAR POR · REGISTROS ENCONTRADOS
Reporte cancelaciones al S016:
   REGISTROS ACEPTADOS · REGISTROS RECHAZADOS · TOTAL CANCELADOS
```

**Vocabulario en la fórmula:** Reporte · Transacciones rechazadas · Aceptados · Rechazados · Total

**Excepciones:**
- Si no hay datos imprime "*** SIN INFORMACION ***" y cierra con "*** FIN DE REPORTE ***".

**Estado validación:** Verificado fuente líneas 336-346, 405-433, 1304-1312

---

## RN-S500-651 — Encendido de incidente cuando existen cancelaciones rechazadas (TASKVALUE = 50)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-651 |
| **Nombre** | Encendido de incidente cuando existen cancelaciones rechazadas (TASKVALUE = 50) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al finalizar el procesamiento de cancelados, si hubo al menos un registro rechazado, P106 enciende la señal de incidente colocando 50 en el TASKVALUE con que responde al WFL/Lote. Esto permite que el flujo batch detecte automáticamente que la cancelación al S016 tuvo rechazos y dispare la ruta de atención correspondiente.

**Fórmula/pseudocódigo:**
```
001-ENCIENDE-INC:
   SI W77-REPCAN-RCHZ > 0
      MOVE 50 TO W77-ENC-INC
...
SI WKS-IN-FILE = 5 OR 6
   SET MYSELF (TASKVALUE) TO W77-ENC-INC
```

**Vocabulario en la fórmula:** Incidente · TASKVALUE 50 · Rechazos · REPCAN-RCHZ · WFL/Lote

**Excepciones:**
- Con cero rechazos el TASKVALUE permanece en 00 (sin incidente); es un semáforo binario hacia el orquestador.

**Estado validación:** Verificado fuente líneas 778, 802-803, 1167-1170

---

## RN-S500-652 — Verificación de residencia de archivos antes de operar y bitácora al operador (LJ)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-652 |
| **Nombre** | Verificación de residencia de archivos antes de operar y bitácora al operador (LJ) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-10 |
| **bian_ref** | 6.5.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P106 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de abrir cualquier archivo (rechazos, log, incidente, cancelados, reinicio), P106 valida su atributo RESIDENT. Si el archivo no está residente, no aborta ciegamente: registra un mensaje explícito con el título del archivo faltante en la bitácora del operador (librería LJ) y marca error, dejando traza auditable de la falta.

**Fórmula/pseudocódigo:**
```
SI ATTRIBUTE RESIDENT OF archivo = TRUE
   OPEN INPUT ... procesar
SINO
   MOVE 1 TO W77-ERROR
   STRING "ARCHIVO NO RESIDENTE: " título INTO TEXTO-LJ
   CALL "LJ IN LIBLJ"
```

**Vocabulario en la fórmula:** RESIDENT · LJ · Bitácora · Archivo no residente · Título

**Excepciones:**
- Con W77-ERROR = 1 el reporte se cierra WITH PURGE (se descarta) en vez de WITH SAVE, para no dejar un reporte incompleto.

**Estado validación:** Verificado fuente líneas 889-899, 1344-1347

---

## RN-S500-653 — Comparación de saldo Inversiones contra saldo calculado del Histórico (conciliación núcleo)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-653 |
| **Nombre** | Comparación de saldo Inversiones contra saldo calculado del Histórico (conciliación núcleo) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P160 (COMPARATIVO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El corazón del reconciliador P160 recalcula el saldo esperado del histórico como el saldo de fin de corte más depósitos menos retiros del periodo, y lo compara contra el saldo actual del dataset de Inversiones (incluyendo pendiente y saldo protegido por orden judicial). Si no coinciden, graba el contrato como diferencia para reporte y sorteo.

**Fórmula/pseudocódigo:**
```
WS-SUM-SDOCAL = B03-SDO-FINCORTE + SUM(DEP) - SUM(RET)
B03-SDO-ACTUAL = B03-SDO-ACTUAL + B03-SDO-PENDIENTE + B03-SDOPROT-BLOQ
SI B03-SDO-ACTUAL = WS-SUM-SDOCAL
   NEXT SENTENCE   (cuadra)
SINO
   PERFORM 50213210-GRABO  (graba diferencia)
```

**Vocabulario en la fórmula:** Saldo Inversiones · Saldo Histórico · Fin de corte · Depósitos · Retiros · Saldo protegido

**Excepciones:**
- El saldo protegido por orden judicial (B03-SDOPROT-BLOQ) se suma al saldo actual antes de comparar, para no reportar como descuadre un bloqueo legal.

**Estado validación:** Verificado fuente líneas 1571-1572, 1631-1656

---

## RN-S500-654 — Inclusión de depósitos y retiros diarios del histórico acotada a 31 días

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-654 |
| **Nombre** | Inclusión de depósitos y retiros diarios del histórico acotada a 31 días |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P160 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para reconstruir el saldo del histórico, P160 acumula los depósitos y retiros día por día desde el arreglo diario del dataset B06, con un tope estricto de 31 días. El límite refleja la estructura de un mes calendario máximo de movimientos por contrato en el arreglo histórico.

**Fórmula/pseudocódigo:**
```
50213110-ACUM-MOV:
   ADD 1 TO WS-DIAC2
   SI WS-DIAC2 > 31 → MOVE 1 TO WS-6VEZ (fin)
   SINO
      ADD B06-DEPS-DIA(WS-DIAC2) TO WS-SUM-SDODEP, WS-TOTALDEP
      ADD B06-RETS-DIA(WS-DIAC2) TO WS-SUM-SDORET, WS-TOTALRET
```

**Vocabulario en la fórmula:** Depósitos día · Retiros día · 31 días · B06 · Acumulación

**Excepciones:**
- El límite 31 es hardcode del tamaño del arreglo diario; contratos con arreglo distinto quedarían mal acumulados.

**Estado validación:** Verificado fuente líneas 1605-1626

---

## RN-S500-655 — Exclusiones de la conciliación por estatus de contrato y calificaciones QPIM

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-655 |
| **Nombre** | Exclusiones de la conciliación por estatus de contrato y calificaciones QPIM |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P160 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P160 excluye del cálculo de motor y conciliación aquellos contratos con estatus 4 (cancelado), sin cliente asignado (número de cliente 0) o con ciertas calificaciones QPIM de producto/instrumento específicas. Estas exclusiones evitan reportar como descuadre situaciones esperadas (cuentas canceladas o productos fuera de alcance).

**Fórmula/pseudocódigo:**
```
SI B03-STATUS = 4  OR  B03-NUM-CLIENTE = 0
   OR QPIM-0066-0090-01 OR QPIM-0066-0011-01
   OR QPIM-0066-0017-01 OR QPIM-0500-0006-01
   → NEXT SENTENCE (no arma motor / no concilia)
SINO
   COMPUTE saldos y PERFORM 50200500-ARMA-MOTOR
```

**Vocabulario en la fórmula:** B03-STATUS 4 · NUM-CLIENTE · QPIM · Producto · Instrumento

**Excepciones:**
- Para el producto QPIM-0500-0006-01 la exclusión se amplía a estatus 2, 3 y 4 (no sólo cancelado).

**Estado validación:** Verificado fuente líneas 1376-1389, 1400-1406

---

## RN-S500-656 — Generación de archivo Motor con fecha de último movimiento por cliente (insumo P189)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-656 |
| **Nombre** | Generación de archivo Motor con fecha de último movimiento por cliente (insumo P189) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P160 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P160 genera el archivo Motor con la fecha de último movimiento por cliente, que consume el paso P189. El registro Motor se escribe sólo cuando se cumple alguna condición de cambio relevante: tipo de archivo 1 con fecha de recálculo distinta a la de último movimiento, movimiento del día, estatus 1, o divergencia entre saldo actual y saldo anterior.

**Fórmula/pseudocódigo:**
```
50200500-ARMA-MOTOR — escribe motor SI:
   (TPOARCH=1 Y FEC-RCTAORI <> FEC-ULTMOV)  OR
   (FEC-ULTMOV = FECHA-PRO Y FEC-RCTAORI <> FEC-ULTMOV) OR
   B03-STATUS = 1  OR
   WKS-MOT-SDOACT <> WKS-MOT-SDOANT
```

**Vocabulario en la fórmula:** Motor · Fecha último movimiento · P189 · Saldo actual/anterior

**Excepciones:**
- Saldo actual y anterior incluyen el saldo bloqueado (SDOPROT-BLOQ / SDOBLO-ANTANT) para detectar cambios en cuentas con bloqueo.

**Estado validación:** Verificado fuente líneas 1385-1389, 1412-1441

---

## RN-S500-657 — Terminación controlada (DMTERMINATE) ante error de base de datos en la conciliación

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-657 |
| **Nombre** | Terminación controlada (DMTERMINATE) ante error de base de datos en la conciliación |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P160 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando P160 encuentra un error de base al recorrer contratos o al buscar en el histórico B06, distingue el "no encontrado" (status 1, tratado como caso de negocio) de un error real de base. Ante error real, registra el mensaje diagnóstico con PIM, contrato y copia, y termina de forma controlada con DMTERMINATE para no continuar sobre datos inconsistentes.

**Fórmula/pseudocódigo:**
```
SI WS-STATUS-BASE > 0
   SI = 1 (no encontrado) → tratar como caso esperado (MOVE 1 a bandera vez)
   SINO
      STRING "ERROR AL HACER FIND A B06 ... PIM ... CTO ... COPIA ..."
      PERFORM 70000050-MENSAJE
      CALL SYSTEM DMTERMINATE
```

**Vocabulario en la fórmula:** WS-STATUS-BASE · DMTERMINATE · FIND · B06 · PIM · Copia

**Excepciones:**
- El "contrato inexistente en B06" (status 1) no aborta: pone saldos anteriores en cero y continúa; sólo el error genuino termina el proceso.

**Estado validación:** Verificado fuente líneas 1355-1369, 1584-1600

---

## RN-S500-658 — Control de ejecución del WFL/Lote por opciones de paso (INICIO, ROLLBACK, FIN, REINICIO)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-658 |
| **Nombre** | Control de ejecución del WFL/Lote por opciones de paso (INICIO, ROLLBACK, FIN, REINICIO) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P101 gobierna la ejecución del WFL/Lote diario mediante un parámetro de opción que marca el momento del ciclo: inicio del WFL, inicio y fin de paso actualizador, validación de reinicio, fin del WFL, trueno por incidente, proceso especial y fin de paso sin rollback. Al inicio de cada paso actualizador guarda la información para rollback y al final la marca como ya no requerida.

**Fórmula/pseudocódigo:**
```
WKS-WFL-P-OPCION:
   1 INICIO WFL        2 INICIO PASO (accesa base, guarda rollback)
   3 FIN PASO + genera arch/ctrl   4 VALIDA REINICIO WFL
   5 FIN WFL           6 TRUENE por incidente de paso
   7 LEE archivo proceso especial  8 FIN PASO sin rollback
```

**Vocabulario en la fórmula:** WFL/Lote · Paso actualizador · Rollback · CTRLWFL · Opción

**Excepciones:**
- La opción 9 (genera archivo de control vacío) figura en la cabecera pero está marcada "SIN USO".

**Estado validación:** Verificado fuente líneas 25-36, 176-196, 467-480

---

## RN-S500-659 — Máquina de estados del control WFL/paso y decisión de reinicio con rollback

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-659 |
| **Nombre** | Máquina de estados del control WFL/paso y decisión de reinicio con rollback |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P101 mantiene en el archivo CTRLWFL el estatus del WFL y de cada paso (0 sin iniciar, 1 en curso, 2 terminado) y su bandera de rollback. Al validar reinicio, si el paso quedó en estatus 1 (interrumpido) responde al WFL con "CON REINICIO" y opción de rollback 2, devolviendo los datos (job, mix, fecha, hora) para deshacer; si terminó, responde "SIN ROLLBACK".

**Fórmula/pseudocódigo:**
```
5005000-VAL-REINICIO:
   SI WFL-STATUS = 1:
      SI PASO-STATUS = 1 → CON-ROLLBACK (OPC-ROLL=2, OPC-REINI=2,
                            devuelve JOB MIX FECINI HORAINI)
      SINO → SIN-ROLLBACK (OPC-ROLL=1, OPC-REINI=2 "CONREINICIO")
   SINO → SIN-REINICIO (OPC-ROLL=1, OPC-REINI=1)
```

**Vocabulario en la fórmula:** WFL-STATUS · PASO-STATUS · Rollback · Reinicio · CTRLWFL

**Excepciones:**
- Un paso en estatus 1 al iniciar otro paso produce "HAYPASOSINFIN" (opción 8): hay un paso previo sin cerrar, condición de bloqueo.

**Estado validación:** Verificado fuente líneas 654-689, 529-555

---

## RN-S500-660 — Transacción de auditoría (rollback point) al iniciar un paso actualizador

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-660 |
| **Nombre** | Transacción de auditoría (rollback point) al iniciar un paso actualizador |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al iniciar un paso actualizador (opción 2), P101 abre la base en modo UPDATE y ejecuta una transacción sobre el dataset de reinicio B91 (BEGIN-TRANSACTION NO-AUDIT / END-TRANSACTION AUDIT SYNC) para establecer un punto de auditoría desde el cual el WFL puede hacer rollback. También ajusta el atributo MAXCARDS de la tarea.

**Fórmula/pseudocódigo:**
```
5003210-ACCESA-BASE:
   OPEN UPDATE S500BD01CAPTACION
   BEGIN-TRANSACTION NO-AUDIT S500B91REINICIO
      ON EXCEPTION MOVE DMSTATUS(DMCATEGORY) TO WS-STATUS-BASE
   END-TRANSACTION AUDIT S500B91REINICIO SYNC
   CHANGE ATTRIBUTE MAXCARDS OF MYSELF TO 9
```

**Vocabulario en la fórmula:** BEGIN-TRANSACTION · AUDIT SYNC · B91REINICIO · Rollback · DMSTATUS · MAXCARDS

**Excepciones:**
- El LOCK/STORE sobre B02CONTROL aparece comentado; el punto de auditoría efectivo se ancla en B91REINICIO, no en B02.

**Estado validación:** Verificado fuente líneas 560-581

---

## RN-S500-661 — Validación estricta del parámetro de 31 posiciones del WFL/Lote

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-661 |
| **Nombre** | Validación estricta del parámetro de 31 posiciones del WFL/Lote |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P101 recibe del WFL/Lote un parámetro de exactamente 31 posiciones (opción, fecha, CSI, job, nombre de paso) y lo valida integralmente antes de operar: opción entre 1 y 8, año 2004-2099, mes 01-12, día 01-31, CSI en {04, 10}, job 00001-99999 y nombre de paso no vacío. Si algo falla, responde error al WFL sin tocar la base.

**Fórmula/pseudocódigo:**
```
SI W88-WFL-P-OPCION-OK Y W88-PARAM-AA-OK Y W88-PARAM-MM-OK
   Y W88-PARAM-DD-OK Y W88-WFL-P-NUMCSI-OK Y W88-WFL-P-NUMJOB-OK
   Y WKS-WFL-P-NUMPASO <> " "
   → continuar
SINO
   MOVE 1 TO W77-ERR-PARAM · "PARAMETRO ERRONEO" → LJ
   responde OPC-REINI=5, OPC-ROLL=5, "ERRPARAM"
```

**Vocabulario en la fórmula:** Parámetro · 31 posiciones · CSI · Job · Nombre de paso · Validación

**Excepciones:**
- El CSI sólo admite 04 ó 10; cualquier otro centro se rechaza como parámetro erróneo.

**Estado validación:** Verificado fuente líneas 176-196, 433-461

---

## RN-S500-662 — Archivo de control por paso para impedir doble ejecución en el mismo día

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-662 |
| **Nombre** | Archivo de control por paso para impedir doble ejecución en el mismo día |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Por cada paso que termina, P101 genera un archivo de control con nombre variable en la ruta S500/FILE/CTRLWFL/XX/AAAAMMDD/. El WFL/Lote valida la residencia de ese archivo antes de correr el paso: si ya existe, el paso no se repite. El registro documenta que "ESTE PASO YA CORRIO HOY" con la fecha y el job.

**Fórmula/pseudocódigo:**
```
5004500-GEN-ARCH-PASO:
   TITLE = S500/FILE/CTRLWFL/{CSI}/{FECJOB}/{NUMPASO}
   WRITE "ESTE PASO YA CORRIO HOY {FECJOB} EN JOB {NUMJOB}"
El WFL valida residencia del archivo para no repetir el paso
```

**Vocabulario en la fórmula:** CTRLPASO · Archivo de control · Idempotencia de paso · CTRLWFL

**Excepciones:**
- El nombre de paso (15 posiciones) es dato variable por proceso; distingue archivos de control entre pasos distintos del mismo día.

**Estado validación:** Verificado fuente líneas 14-17, 630-651

---

## RN-S500-663 — Proceso especial en línea del lote validado por header y detalle (opción 7)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-663 |
| **Nombre** | Proceso especial en línea del lote validado por header y detalle (opción 7) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La opción 7 de P101 lee un archivo de proceso especial (ESPECIALENLOTED) para inyectar dinámicamente un paso adicional al WFL/Lote después de determinado paso. Valida que el header sea tipo 01 para P101 con CSI y fecha correctos, y que el detalle sea tipo 03, del cual extrae paso anterior, paso especial y su value, devueltos al WFL vía TASKSTRING.

**Fórmula/pseudocódigo:**
```
80000200-PROESO-ESPE:
   SI residente ARCHPROC:
      leer header: TPOREG=01, PASO="P101", CSI y FECH coinciden
      leer detalle: TPOREG=03 → PASOANT, NAMEPASO, VALUE
      SET MYSELF(TASKSTRING) TO WKS-PARAM-SAL-ESP
   SINO → W77-ERR-PARAM = 1
```

**Vocabulario en la fórmula:** Proceso especial · ARCHPROC · ESPECIALENLOTED · TASKSTRING · Header/Detalle

**Excepciones:**
- Cualquier discrepancia de header/detalle produce "ERRARCHH"/"ERRARCHD" y anula la inyección del paso especial.

**Estado validación:** Verificado fuente líneas 744-806, 130-158

---

## RN-S500-664 — Catálogo de estatus de base de datos (DMSTATUS) para diagnóstico de fallas de paso

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-664 |
| **Nombre** | Catálogo de estatus de base de datos (DMSTATUS) para diagnóstico de fallas de paso |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P101 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P101 define un catálogo completo de códigos de estatus de base (DMSTATUS categoría), del 00 (sin error) al 21 (parameter error), que traduce las excepciones DMSII a condiciones de negocio nombradas: notfound, duplicates, deadlock, notlocked, abort, integrityerror, etc. Este catálogo es la base de la resiliencia del scheduler frente a fallas de la base de datos.

**Fórmula/pseudocódigo:**
```
WS-STATUS-BASE (niveles 88):
   00 NOTERROR   01 NOTFOUND   02 DUPLICATES  03 DEADLOCK
   05 NOTLOCKED  07 SYSTEMERROR 11 OPENERROR  14 INUSE
   16 ABORT      17 SECURITYERROR 19 FATALERROR 20 INTEGRITYERROR
   21 PARAMETERERROR   (1..99 = ERROR)
```

**Vocabulario en la fórmula:** DMSTATUS · DEADLOCK · ABORT · INTEGRITYERROR · Estatus de base

**Excepciones:**
- El deadlock (03) e in-use (14) son condiciones recuperables típicas de concurrencia batch/online que el WFL puede reintentar; abort (16) y fatalerror (19) no.

**Estado validación:** Verificado fuente líneas 290-313
