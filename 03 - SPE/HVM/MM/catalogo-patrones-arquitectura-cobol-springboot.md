Con el contexto completo de ambos CLAUDE.md cargado, produzco ahora el catálogo exhaustivo.

---

# Catálogo de Patrones de Arquitectura — Proyecto Gamma
## Migración IBM z/OS (COBOL/JCL/VSAM/CICS) → Java Spring Boot en x86/Cloud
### Banco Tier-1 México · 136M LOC · 150 sistemas · 3 capas funcionales

**Versión:** 1.0 · 2026-07-08  
**Preparado por:** SME Mainframe Migration & Modernization · Specialist Architecture Patterns  
**Contexto crítico:** La falla anterior fue traducción literal COBOL→Java sin adaptación de patrones de acceso a datos (N+1 masivo, batch chatty, SORT en software). Este catálogo existe precisamente para que eso no se repita.

---

## ÍNDICE

1. [Estrategias de Migración — Las 7R](#1)
2. [Patrones de Transición — La Capa de Intercepción](#2)
3. [Patrones de Descomposición de Dominio — DDD desde COBOL](#3)
4. [Patrones por Capa Funcional](#4)
   - 4A. Capa Online (CICS → REST/Spring Boot)
   - 4B. Capa Conversacional (3270 → API + Frontend)
   - 4C. Capa Batch (COBOL Batch → Spring Batch)
5. [Patrones de Datos](#5)
6. [Patrones de Orquestación (JCL → Cloud)](#6)
7. [Patrones de Resiliencia y API Cloud-Native](#7)
8. [Patrones de Coexistencia y Parallel-Run](#8)
9. [Anti-patrones Críticos — Lo que destruyó el intento anterior](#9)
10. [Matriz de Decisión Rápida](#10)

---

## 1. ESTRATEGIAS DE MIGRACIÓN — LAS 7R {#1}

### 1.1 Framework de Decisión por Sistema

```
                          VALOR DIFERENCIADOR PARA EL NEGOCIO
                    Bajo ◄────────────────────────────────► Alto
                         │                                   │
           Alto  ─────────────────────────────────────────────
                 │ RETAIN          │ REFACTOR    │ REARCHITECT│
  COMPLEJIDAD   │ (dejar como     │ (limpiar    │ (microserv.│
  DEL CÓDIGO    │  está, exponer  │  código,    │ + cloud    │
                │  vía ACL)       │  IaC-ize)   │  native)   │
           Med  ─────────────────────────────────────────────
                │ RETIRE          │ REPLATFORM  │ REARCHITECT│
                │ (eliminar si    │ (lift+      │ o REPLACE  │
                │  sin usuarios)  │  reshape)   │            │
           Bajo ─────────────────────────────────────────────
                │ RETIRE          │ REHOST      │ REFACTOR   │
                │                 │ (lift&shift │            │
                │                 │  con emul.) │            │
                ─────────────────────────────────────────────
```

### 1.2 Las 7R — Definición Operacional para Proyecto Gamma

| Estrategia | Descripción para z/OS→Java | Tiempo al Valor | Riesgo Técnico | Costo Relativo |
|---|---|---|---|---|
| **Rehost** | Ejecutar binarios COBOL en emulación (LzLabs SDM) en x86/cloud sin recompilación | 3–6 meses | Bajo | $ |
| **Replatform** | Recompilar COBOL para Linux on IBM Z o AWS Graviton — COBOL runtime permanece | 6–12 meses | Bajo-Medio | $$ |
| **Refactor** | Restructurar programas COBOL sin cambiar funcionalidad — eliminar dead code, extraer subroutines, separar UI de lógica | 6–18 meses | Medio | $$ |
| **Rearchitect** | Rediseño como microservicios Spring Boot con DB propia, API REST, event-driven | 18–48 meses | Alto | $$$$ |
| **Replace** | Sistema paquetizado nuevo (Temenos, Mambu, Vault, Oracle FLEXCUBE) reemplaza el sistema COBOL | 24–60 meses | Muy Alto | $$$$$ |
| **Retain** | Sistema permanece en z/OS; se expone vía API/ACL para integración con nuevos servicios | Sin fin | Nulo | $ (MIPS continuos) |
| **Retire** | Sistema se elimina — sin reemplazo, sin usuarios activos confirmados por análisis estático | 1–3 meses | Bajo | $0 |

### 1.3 Árbol de Decisión por Sistema Individual

```
ENTRADA: Sistema a clasificar
         │
         ▼
┌─ ¿Tiene usuarios activos en los últimos 12 meses? ─────────────────────────┐
│   Validar con análisis de logs CICS/batch scheduler TWS/CA7                │
│                                                                             │
│   NO ────────────────────────────────────────────────────────► RETIRE      │
│   SÍ → continúa                                                            │
└────────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─ ¿El sistema contiene lógica de negocio propietaria y diferenciadora? ─────┐
│   (reglas de crédito, pricing, scoring, flujos regulatorios únicos)        │
│                                                                             │
│   NO → ¿Existe un producto comercial equivalente con >80% fit?             │
│        SÍ ─────────────────────────────────────────────────────► REPLACE   │
│        NO ─────────────────────────────────────────────────────► REHOST    │
│   SÍ → continúa                                                            │
└────────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─ ¿El sistema cambia con frecuencia? ────────────────────────────────────────┐
│   (> 1 release/trimestre en los últimos 2 años)                            │
│                                                                             │
│   NO + Alta complejidad → ¿Regulatorio crítico? ────────────────► RETAIN   │
│   NO + Baja complejidad ───────────────────────────────────────► REHOST    │
│   SÍ → continúa                                                            │
└────────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─ ¿El equipo entiende profundamente la lógica de negocio? ──────────────────┐
│   (existen SMEs que pueden explicar los EVALUATE anidados)                 │
│                                                                             │
│   NO → REFACTOR primero (documentar y limpiar), luego re-evaluar          │
│   SÍ → continúa                                                            │
└────────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─ ¿El sistema tiene dependencias cruzadas con >10 sistemas? ────────────────┐
│                                                                             │
│   SÍ + Acoplamiento alto ──────────────────────────────────────► REFACTOR  │
│        (primero romper el acoplamiento, luego escalar a REARCH)            │
│   NO o acoplamiento bajo ──────────────────────────────────────► REARCHITECT│
└────────────────────────────────────────────────────────────────────────────┘
```

### 1.4 Aplicación Práctica a las 3 Capas de Gamma

| Capa | Sistemas Típicos | Estrategia Recomendada | Justificación |
|---|---|---|---|
| **Online (CICS)** | Consultas de saldo, validaciones, transacciones simples | Rearchitect por bounded context | Alta volatilidad, diferenciación competitiva, candidatos naturales a microservicios |
| **Conversacional (3270)** | Pantallas operativas teller, backoffice | Rearchitect (API) + Replace (frontend) | El frontend 3270 no tiene valor intrínseco; la lógica de negocio detrás sí |
| **Batch masivo** | Cierres EOD, conciliaciones, generación de estados de cuenta | Replatform → Rearchitect gradual | El batch bien escrito en COBOL es difícil de superar en throughput inicial; migrar por olas |

`[CRÍTICO]` Para Proyecto Gamma con 150 sistemas, la estrategia NO es uniforme. El error más costoso en programas de esta escala es aplicar una sola estrategia a todos los sistemas. La clasificación por sistema (con las 5 dimensiones de la sección 2.3 del SME) es obligatoria antes de comenzar cualquier sprint de migración.

---

## 2. PATRONES DE TRANSICIÓN — LA CAPA DE INTERCEPCIÓN {#2}

### 2.1 Strangler Fig — El Patrón Rector del Programa

El Strangler Fig es el patrón maestro. **Todo lo demás es táctico dentro de este patrón.**

```
ESTADO INICIAL (Día 0)
═══════════════════════════════════════════════════════════════════
                                                                   
  Clientes              API Gateway              z/OS Mainframe    
  (mobile/web/          (NUEVO — instalado       (todo el         
   teller/ATM)    ───►  en Fase 1, antes         tráfico actual)  
                         de migrar cualquier                       
                         sistema)                                  

ESTADO INTERMEDIO (Wave 2-N)
═══════════════════════════════════════════════════════════════════

  Clientes              API Gateway              Destino           
                              │                                    
                              ├─► /creditos/* ──► Spring Boot     
                              │                   (migrado)        
                              │                                    
                              ├─► /cuentas/* ───► Spring Boot     
                              │                   (migrado)        
                              │                                    
                              └─► /batch-status► z/OS Mainframe   
                                                  (pendiente)      

ESTADO FINAL (Post-programa)
═══════════════════════════════════════════════════════════════════

  Clientes              API Gateway              Cloud             
                              │                                    
                              └─► (todo) ───────► Spring Boot     
                                                  Microservicios   
                                                  (z/OS retirado)  
```

**Fases obligatorias del Strangler Fig para Gamma:**

| Fase | Nombre | Duración Estimada | Actividad Clave |
|---|---|---|---|
| **Fase 0** | Reverse Engineering + Clasificación | 12–16 semanas | Inventario completo, call graph, clasificación 7R por sistema |
| **Fase 1** | Intercept | 8–12 semanas | Instalar API Gateway, crear proxy pass-through al mainframe, CERO cambios funcionales |
| **Fase 2–N** | Strangle | 6–10 semanas por bounded context | Migrar un BC por wave, redirigir ruta en API Gateway |
| **Fase Final** | Retire | 4–8 semanas por sistema | Shadow period completo, cutover, descomisión |

`[CRÍTICO]` **Nunca saltear la Fase 1.** Instalar el API Gateway antes de migrar el primer sistema es el movimiento más importante del programa. Sin interceptor, cada migración parcial requiere cambios coordinados en todos los consumidores del mainframe. Con el interceptor, el routing se cambia en un solo punto sin tocar a los clientes.

### 2.2 Branch by Abstraction

Para sistemas donde el código COBOL y el nuevo código Java deben coexistir dentro de la misma capa lógica durante la transición (e.g., un servicio de scoring que se reescribe gradualmente por módulo):

```
ANTES:
  ServiceA → CobolScoringService (todo COBOL vía transacción CICS)

DURANTE (Branch by Abstraction):
  ServiceA → IScoringService (interfaz abstracta)
                │
                ├─[feature flag COBOL_SCORING=true]──► CobolScoringAdapter
                │                                       (llama al mainframe vía ACL)
                └─[feature flag COBOL_SCORING=false]──► JavaScoringService
                                                         (nueva implementación Spring Boot)

DESPUÉS:
  ServiceA → JavaScoringService (COBOL_SCORING flag eliminado)
```

**Implementación en Spring Boot:**

```java
// Interfaz de abstracción
public interface ScoringService {
    ScoringResult evaluate(ScoringRequest request);
}

// Adaptador al mainframe (coexistencia)
@Service
@ConditionalOnProperty(name = "features.scoring.engine", havingValue = "cobol")
public class CobolScoringAdapter implements ScoringService {
    
    private final MainframeGateway mainframeGateway; // ACL
    
    @Override
    public ScoringResult evaluate(ScoringRequest request) {
        // Traduce request moderno → COMMAREA COBOL
        CobolCommarea commarea = CommareaMapper.toCommarea(request);
        CobolResponse response = mainframeGateway.executeTransaction("SCR1", commarea);
        // Traduce respuesta COBOL → modelo moderno
        return CommareaMapper.toScoringResult(response);
    }
}

// Implementación nueva (destino)
@Service
@ConditionalOnProperty(name = "features.scoring.engine", havingValue = "java", 
                       matchIfMissing = true)
public class JavaScoringService implements ScoringService {
    @Override
    public ScoringResult evaluate(ScoringRequest request) {
        // Lógica nueva en Java
    }
}
```

**Cuándo usar Branch by Abstraction vs. Strangler Fig:**

| Criterio | Strangler Fig | Branch by Abstraction |
|---|---|---|
| Separación por API pública | Sí | No — es interna al servicio |
| Requiere cambios en el monolito | No (API Gateway intercepta) | Sí (agregar la interfaz) |
| Rollback | En el API Gateway (routing) | En el feature flag |
| Granularidad | Bounded Context completo | Módulo / clase individual |
| Para Gamma: mejor cuando... | Migrar un sistema completo | Migrar un programa COBOL específico dentro de un sistema ya parcialmente migrado |

### 2.3 Anti-Corruption Layer (ACL) — Patrón Obligatorio en Todo Punto de Integración

La ACL es el traductor de idiomas entre el mundo COBOL y el mundo Java. **Cada punto donde el nuevo código Java necesite hablar con el mainframe existente DEBE tener una ACL.**

```
MUNDO JAVA (modelo limpio)              ACL                    MUNDO COBOL (modelo legacy)
═══════════════════════════    ═══════════════════════    ══════════════════════════════
                                                           
CuentaDto {                 ←─ toDto()                ←─ CUENTA-RECORD {
  id: String                   fromCommarea()            CUEN-NUM     PIC 9(10)
  saldo: BigDecimal            ─────────────             CUEN-SALDO   PIC 9(13)V99 COMP-3
  titular: String              unpackComp3()             CUEN-TITULAR PIC X(40)
  estado: EstadoCuenta         ebcdicToUtf8()            CUEN-STATUS  PIC X(2)
}                              mapStatus()             }
                                                           
PagoCommand {               ──► toCommarea()          ──► COMMAREA-PAGO {
  origen: String               packComp3()                PAGO-ORIGEN  PIC 9(10)
  destino: String              utf8ToEbcdic()             PAGO-DEST    PIC 9(10)
  monto: BigDecimal                                       PAGO-MONTO   PIC 9(11)V99 COMP-3
  concepto: String                                        PAGO-CONCEPTO PIC X(30)
}                                                      }
```

**Responsabilidades de la ACL en Gamma:**

```
ACL Mainframe Gateway
├── Protocolo: TCP/IP → CICS Web Services / MQ / CTG
├── Serialización: JSON → COMMAREA binaria (COMP-3, EBCDIC)
├── Timeout y retry: con exponential backoff
├── Circuit breaker: ante indisponibilidad del mainframe
├── Logging: correlación de request_id entre mundos
└── Métricas: latencia, error rate, throughput hacia mainframe
```

**Implementación Spring Boot:**

```java
@Component
public class MainframeCuentaAcl {

    private static final String TX_CONSULTA_CUENTA = "CCT1";
    private final CtgGateway ctgGateway;
    private final CommareaSerializer serializer;

    public CuentaDto consultarCuenta(String numeroCuenta) {
        // 1. Construir commarea en formato COBOL
        byte[] requestCommarea = serializer.buildConsultaCuenta(numeroCuenta);
        
        // 2. Invocar transacción CICS vía CTG (CICS Transaction Gateway)
        byte[] responseCommarea = ctgGateway.execute(TX_CONSULTA_CUENTA, requestCommarea);
        
        // 3. Desempaquetar respuesta COBOL
        CobolCuentaRecord record = serializer.parseConsultaCuenta(responseCommarea);
        
        // 4. Traducir al modelo limpio Java
        return CuentaMapper.toDto(record);
    }
}

// El serializer maneja COMP-3, EBCDIC, fechas con ventana de siglo, etc.
@Component
public class CommareaSerializer {
    
    public CuentaDto unpackCuentaRecord(byte[] raw) {
        // CRÍTICO: desempaquetar COMP-3 correctamente
        BigDecimal saldo = Comp3Utils.unpack(
            Arrays.copyOfRange(raw, 10, 17),  // offset del campo CUEN-SALDO
            2                                  // 2 decimales (V99)
        );
        String titular = new String(
            Arrays.copyOfRange(raw, 17, 57), 
            Charset.forName("IBM1047")         // EBCDIC code page
        ).trim();
        // ...
    }
}
```

### 2.4 Parallel Run (Shadow Mode) — Patrón de Validación

Para cada sistema migrado, antes del cutover definitivo, ejecutar ambos sistemas en paralelo y comparar outputs:

```
REQUEST ENTRANTE
       │
       ├──(1)──► API Gateway ──► Mainframe COBOL ──► Respuesta Producción (al cliente)
       │                                                        │
       └──(2)──► Duplicador ──► Spring Boot (nuevo) ──► Respuesta Sombra
                                                                │
                                                       Comparador Asíncrono
                                                                │
                                                       ┌────────▼────────┐
                                                       │ ¿Respuestas      │
                                                       │ equivalentes?    │
                                                       │                  │
                                                       │ SÍ → log OK     │
                                                       │ NO → alert +    │
                                                       │      detalle    │
                                                       └─────────────────┘
```

**Implementación Spring Boot del duplicador:**

```java
@Component
public class ShadowModeFilter implements Filter {
    
    @Value("${shadow.enabled:false}")
    private boolean shadowEnabled;
    
    private final ShadowRequestDispatcher shadowDispatcher;
    private final ResponseComparator comparator;
    
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) 
            throws IOException, ServletException {
        
        // Capturar request para duplicar
        CachedBodyRequest cachedReq = new CachedBodyRequest((HttpServletRequest) req);
        CachedBodyResponse cachedRes = new CachedBodyResponse((HttpServletResponse) res);
        
        // Ejecutar en mainframe (producción)
        chain.doFilter(cachedReq, cachedRes);
        String mainframeResponse = cachedRes.getBody();
        
        if (shadowEnabled) {
            // Disparar al nuevo servicio en background (async, no bloquea al cliente)
            CompletableFuture.runAsync(() -> {
                try {
                    String shadowResponse = shadowDispatcher.dispatch(cachedReq);
                    comparator.compare(mainframeResponse, shadowResponse, 
                                       cachedReq.getRequestURI());
                } catch (Exception e) {
                    shadowMetrics.recordShadowError(e);
                }
            }, shadowExecutor);
        }
        
        // El cliente recibe siempre la respuesta del mainframe (hasta cutover)
        copyResponse(cachedRes, (HttpServletResponse) res);
    }
}
```

---

## 3. PATRONES DE DESCOMPOSICIÓN DE DOMINIO — DDD DESDE COBOL {#3}

### 3.1 Extracción de Bounded Contexts desde el Inventario COBOL

El código COBOL no fue diseñado con DDD, pero sus patrones de dependencia revelan los dominios implícitos.

**Metodología de extracción para Gamma:**

```
PASO 1: ANÁLISIS DE COPYBOOKS COMPARTIDOS
─────────────────────────────────────────
Los copybooks que se comparten entre múltiples programas definen
los contratos de datos implícitos — y por tanto, los límites de dominio.

Ejemplo:
  CREDITO.CPY   ← compartido por CRDVAL01, CRDSCO01, CRDLMT01, CRDAUT01
  CLIENTE.CPY   ← compartido por CRDVAL01, CNTCON01, ALTCLI01, BUSCLI01
  CUENTA.CPY    ← compartido por CNTSAL01, CNTMOV01, CNTBLO01

  → CREDITO.CPY define el agregado "Crédito" → BC: Originación de Crédito
  → CLIENTE.CPY define el agregado "Cliente" → BC: Gestión de Clientes (CRM)
  → CUENTA.CPY define el agregado "Cuenta" → BC: Core de Cuentas

PASO 2: ANÁLISIS DE CALL GRAPH
────────────────────────────────
Los programas que se llaman entre sí sin pasar por tabla de datos
tienden a pertenecer al mismo bounded context.

  CRDVAL01 ─CALL─► CRDSCO01 ─CALL─► RISKEVAL  → BC: Credit Risk
  CRDVAL01 ─CALL─► LIMITCHK               → BC: Credit Limits (sub-BC)

PASO 3: ANÁLISIS DE TRANSACCIONES CICS
────────────────────────────────────────
Cada TRANSID de CICS es un flujo de usuario — agrupa por función de negocio.

  CCT1, CCT2, CCT3  → Consultas de cuenta → BC: Account Inquiry
  TRF1, TRF2, TRF3  → Transferencias → BC: Payments
  CRD1, CRD2        → Crédito → BC: Credit Origination

PASO 4: ANÁLISIS DE TABLAS DB2 / VSAM CLUSTERS
────────────────────────────────────────────────
Las tablas/clusters que se acceden siempre juntas pertenecen al mismo BC.

  CREDITOS + LIMITES_CREDITO + HISTORIAL_PAGOS → BC: Credit
  CUENTAS + MOVIMIENTOS + SALDOS → BC: Core Accounts
  CLIENTES + DATOS_KYC + REFERENCIAS → BC: Customer
```

### 3.2 Bounded Contexts Canónicos para un Core Bancario z/OS

Basado en patrones observados en bancos LATAM. Para Gamma, este es el punto de partida a validar con ingeniería inversa real:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    MAPA DE BOUNDED CONTEXTS — PROYECTO GAMMA            │
│                    (tentativo, a validar con call graph real)           │
└─────────────────────────────────────────────────────────────────────────┘

BC-01: Customer Identity                    BC-02: Core Accounts
  Aggregates: Customer, KYC, Address          Aggregates: Account, Balance, Movement
  Legacy: CLIENTES, DATOS_KYC               Legacy: CUENTAS, MOVIMIENTOS, SALDOS
  Key CICS TXs: ALC*, MOD*, CON*            Key CICS TXs: CCT*, SAL*, MOV*
  Bounded por: Regulación CNBV/PLD          Bounded por: Contabilidad, GL

BC-03: Credit Origination                  BC-04: Credit Management
  Aggregates: Application, Scoring           Aggregates: Credit, Installment, Payment
  Legacy: SOLICITUDES, SCORING               Legacy: CREDITOS, CUOTAS, PAGOS
  Key CICS TXs: CRD*, SOL*                  Key CICS TXs: PAG*, CUO*, VEN*
  
BC-05: Payments (Domestic)                 BC-06: Interbank Payments (SPEI)
  Aggregates: Transfer, Order                Aggregates: SpeiOrder, CLABE, Return
  Legacy: TRANSFERENCIAS, ORDENES            Legacy: SPEI_*, ORDENES_IB
  Key CICS TXs: TRF*, ORD*                  Key CICS TXs: SPI*, CEP*
  Regulatorio: BANXICO SPEI rules            Regulatorio: Banxico CEFER

BC-07: General Ledger                      BC-08: Batch Operations
  Aggregates: GLEntry, Period                Aggregates: BatchJob, EODResult
  Legacy: CONTABILIDAD, ASIENTOS             Legacy: CONTROL_BATCH, ESTADISTICAS
  Key JCL Jobs: EOD*, CIER*, CONCIL*        Key JCL Jobs: (todos los batch)

BC-09: Notifications & Comms              BC-10: Product Catalog
  Aggregates: Notification, Channel          Aggregates: Product, Rate, Fee
  Legacy: MENSAJES, ALERTAS                  Legacy: PRODUCTOS, TASAS, CARGOS
  → Candidato a Retire/Replace (SaaS)       → Alta volatilidad, candidato prioritario
```

### 3.3 Context Map — Relaciones entre Bounded Contexts

```
                    ┌──────────────┐
                    │  BC-01       │
                    │  Customer    │
                    │  Identity    │
                    └──────┬───────┘
                           │ Customer/Supplier
                           │ (BC-01 provee cliente a todos)
           ┌───────────────┼───────────────────┐
           ▼               ▼                   ▼
    ┌──────────┐   ┌──────────────┐   ┌──────────────┐
    │ BC-02    │   │ BC-03        │   │ BC-05        │
    │ Core     │◄──│ Credit       │   │ Payments     │
    │ Accounts │   │ Origination  │   │ (Domestic)   │
    └────┬─────┘   └──────────────┘   └──────┬───────┘
         │ Customer/Supplier                  │ Open Host Service
         │ (BC-02 provee cuenta)              │ (ISO 20022 / SPEI protocol)
         ▼                                    ▼
    ┌──────────┐                      ┌──────────────┐
    │ BC-07    │                      │ BC-06        │
    │ General  │                      │ Interbank    │
    │ Ledger   │                      │ Payments     │
    └──────────┘                      │ (SPEI)       │
         ▲                            └──────────────┘
         │ Published Language
         │ (GL entries vía eventos)
    ┌──────────┐
    │ BC-04    │
    │ Credit   │
    │ Mgmt     │
    └──────────┘

PATRONES DE CONTEXT MAP APLICADOS:
  Customer/Supplier: BC-01 → BC-02, BC-03, BC-05 (BC-01 es upstream)
  Anti-Corruption Layer: Todo BC nuevo que consume mainframe legacy
  Open Host Service: BC-06 expone API SPEI según protocolo Banxico
  Published Language: BC-07 recibe eventos en formato ISO 20022 / libro contable estándar
  Conformist: BC-09 (notificaciones) consume BC-01 sin transformar (acepta modelo del upstream)
```

### 3.4 Event Storming Adaptado para Código COBOL Existente

Cuando no hay acceso a stakeholders de negocio (sistema sin documentación), derivar el Event Storming del código:

```
FUENTE COBOL/JCL          →  CONCEPTO DDD
──────────────────────────   ────────────────────────────────────────────
PROCEDURE DIVISION USING  →  Command (el programa recibe un comando)
EXEC CICS SEND            →  Read Model (resultado que ve el usuario)
EXEC CICS RETURN          →  Command Handler completo
WRITE / REWRITE (VSAM)    →  Domain Event (estado cambió)
EXEC SQL UPDATE           →  Domain Event (estado persistido)
CALL 'NOTIF01'            →  Policy (evento dispara notificación)
EVALUATE WS-STATUS        →  Business Rule / Policy
PERFORM VALIDATE-INPUT    →  Domain Service (validación)
MOVE 'ERR' TO WS-STATUS   →  Domain Event (ValidationFailed)
```

---

## 4. PATRONES POR CAPA FUNCIONAL {#4}

### 4A. CAPA ONLINE — CICS → REST / Spring Boot

#### 4A.1 Mapeo Canónico CICS → Spring Boot

```
CICS WORLD                          SPRING BOOT WORLD
══════════════════════════════      ══════════════════════════════════════════

TRANSID (identificador único)   →  @RequestMapping("/api/v1/{recurso}")
COMMAREA (estructura binaria)   →  DTO (Record / POJO + Jackson)
EXEC CICS RECEIVE               →  @RequestBody / @RequestParam
EXEC CICS SEND                  →  ResponseEntity<ResponseDTO>
EXEC CICS RETURN                →  return statement del @RestController
EXEC CICS ABEND ABCODE(...)     →  throw new DomainException(...)  
EXEC CICS LINK PROGRAM(...)     →  service.method() [mismo JVM]
EXEC CICS START TRANSID(...)    →  @Async + MessageBroker.publish()
EIBRESP / EIBRESP2              →  Exception hierarchy + @ExceptionHandler
Syncpoint (EXEC CICS SYNCPOINT) →  @Transactional
Backout (EXEC CICS SYNCPOINT    →  @Transactional (rollback)
         ROLLBACK)              
EXEC CICS READQ/WRITEQ TS      →  Redis Cache / Kafka Topic
EXEC CICS ENQ / DEQ            →  @Lock (DB-level) / Redis distributed lock
```

#### 4A.2 Estructura del Microservicio REST destino

```java
// Estructura de paquetes por bounded context
com.bbva.gamma.credit.origination/
  ├── api/
  │   ├── CreditApplicationController.java     // @RestController
  │   └── dto/
  │       ├── CreditApplicationRequest.java    // ← COMMAREA input
  │       └── CreditApplicationResponse.java   // ← COMMAREA output
  ├── domain/
  │   ├── model/
  │   │   ├── CreditApplication.java           // Aggregate Root
  │   │   └── ScoringResult.java               // Value Object
  │   ├── service/
  │   │   └── CreditApplicationService.java    // Lógica de negocio
  │   ├── repository/
  │   │   └── CreditApplicationRepository.java // Port (interfaz)
  │   └── event/
  │       └── CreditApplicationSubmittedEvent.java
  ├── infrastructure/
  │   ├── persistence/
  │   │   └── JpaCreditApplicationRepository.java // Adapter
  │   ├── messaging/
  │   │   └── KafkaCreditEventPublisher.java
  │   └── legacy/
  │       └── CobolScoringAcl.java              // ACL al mainframe
  └── config/
      └── CreditOriginationConfig.java
```

#### 4A.3 Patrón de Transacción CICS → @Transactional

```
COBOL/CICS (ACID en una sola transacción):
  EXEC CICS RECEIVE (entrada)
  EXEC SQL SELECT (leer cuenta)
  EXEC SQL UPDATE (actualizar saldo)
  VSAM REWRITE (actualizar índice)
  EXEC CICS SYNCPOINT (commit explícito)
  EXEC CICS SEND (respuesta)
  EXEC CICS RETURN

Java Spring Boot (equivalente):
```

```java
@RestController
@RequestMapping("/api/v1/accounts")
public class AccountController {
    
    private final AccountService accountService;
    
    @PostMapping("/{accountId}/debit")
    public ResponseEntity<DebitResponse> debit(
            @PathVariable String accountId,
            @RequestBody DebitRequest request,
            @RequestHeader("X-Idempotency-Key") String idempotencyKey) {
        
        // [CRÍTICO] Idempotency key — equivalente a la atomicidad CICS
        // Si el cliente reintenta, no debitar dos veces
        DebitResponse response = accountService.debit(accountId, request, idempotencyKey);
        return ResponseEntity.ok(response);
    }
}

@Service
@Transactional  // Equivalente a EXEC CICS SYNCPOINT
public class AccountService {
    
    private final AccountRepository accountRepo;
    private final IdempotencyRepository idempotencyRepo;
    private final ApplicationEventPublisher eventPublisher;
    
    public DebitResponse debit(String accountId, DebitRequest request, String idempotencyKey) {
        
        // Idempotency check (equivale a evitar re-procesamiento de transacción CICS)
        if (idempotencyRepo.existsByKey(idempotencyKey)) {
            return idempotencyRepo.getResponse(idempotencyKey);
        }
        
        Account account = accountRepo.findByIdWithLock(accountId)  // SELECT FOR UPDATE
            .orElseThrow(() -> new AccountNotFoundException(accountId));
        
        account.debit(request.amount());  // Lógica de dominio
        accountRepo.save(account);
        
        // Publicar evento (equivalente a EXEC CICS START TRANSID del COBOL notificador)
        eventPublisher.publishEvent(new AccountDebitedEvent(accountId, request.amount()));
        
        DebitResponse response = DebitResponse.from(account);
        idempotencyRepo.save(idempotencyKey, response);
        
        return response;  // @Transactional hace commit aquí (EXEC CICS SYNCPOINT)
    }
}
```

#### 4A.4 Árbol de Decisión — Sincrónico vs. Asíncrono para Transacciones Online

```
¿La operación CICS modificaba datos y requería respuesta inmediata del resultado?
  SÍ → REST sincrónico (@PostMapping + @Transactional)
  NO → evaluar:
    ¿El COBOL hacía EXEC CICS START (lanzar otra transacción en background)?
      SÍ → Spring @Async + Kafka publish
    ¿El COBOL hacía WRITEQ TD (escribía en cola transitoria)?  
      SÍ → Kafka produce (fire and forget)
    ¿El COBOL era read-only (EXEC CICS READ + SEND)?
      SÍ → REST GET con caché (Redis) si el dato no cambia frecuentemente
```

### 4B. CAPA CONVERSACIONAL — 3270/CICS → API + Frontend

#### 4B.1 Anatomía de una Pantalla 3270 → Microservicio API

```
PANTALLA 3270 (BMS Map)                API REST EQUIVALENTE
════════════════════════════════════   ══════════════════════════════════════
                                       
+-CONSULTA DE CUENTA-----------+       POST /api/v1/accounts/inquiry
|                               |       {
| Número:  [__________]         |         "accountNumber": "1234567890"
| Tipo:    [__]                 |       }
|                               |       Response:
| Saldo:   $12,345.67           |       {
| Disponible: $10,000.00        |         "balance": 12345.67,
| Nombre: JUAN PÉREZ GARCÍA     |         "available": 10000.00,
|                               |         "holderName": "JUAN PÉREZ GARCÍA",
| PF1=Movimientos PF3=Salir     |         "_links": {
| PF5=Transferir                |           "movements": "/api/v1/accounts/1234/movements",
|                               |           "transfer": "/api/v1/transfers"
+-------------------------------+         }
                                       }

Teclas PF (Program Function) → HATEOAS _links o frontend navigation
DFHMDF ATTR (atributos de campo) → Validación en API (required, format, etc.)
DFHMDF POS (posición de pantalla) → Irrelevante para la API (UI concern)
```

#### 4B.2 Patrón BFF (Backend for Frontend) para Canales Múltiples

```
                            ┌──────────────────────────────────┐
                            │   Microservicios de Dominio      │
                            │  (Credit, Account, Payments...)  │
                            └───────────────┬──────────────────┘
                                            │ (APIs internas gRPC/REST)
              ┌─────────────────────────────┼────────────────────────────┐
              │                             │                            │
              ▼                             ▼                            ▼
    ┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
    │   Mobile BFF     │        │    Web BFF        │        │   Teller BFF     │
    │  (iOS/Android)   │        │  (Web app)        │        │  (Sucursal)      │
    │                  │        │                   │        │                  │
    │ · Payload mínimo │        │ · Payload rico    │        │ · Pantallas       │
    │ · Batch requests │        │ · SSR friendly    │        │   operativas     │
    │ · Push notif.   │        │ · Auth flows      │        │ · Flujos compl.  │
    │ · Offline-first  │        │                   │        │ · Auditoría      │
    └──────────────────┘        └──────────────────┘        └──────────────────┘
              │                             │                            │
              ▼                             ▼                            ▼
        iOS / Android                  Navegador                   Terminal teller
        (React Native)                 (React/Angular)              (Electron/Web)
```

#### 4B.3 Conversión de Mapas BMS a OpenAPI

```
MAPA BMS COBOL:
  DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
  DFHMDF POS=(1,1),LENGTH=20,ATTRB=(ASKIP,NORM),INITIAL='CONSULTA DE CUENTA'
  DFHMDF POS=(3,1),LENGTH=8,ATTRB=(ASKIP,NORM),INITIAL='Número: '
  DFHMDF POS=(3,10),LENGTH=10,ATTRB=(UNPROT,NUM),NAME=NUMCTA
  DFHMDF POS=(5,1),LENGTH=8,ATTRB=(ASKIP,NORM),INITIAL='Saldo:  '
  DFHMDF POS=(5,10),LENGTH=15,ATTRB=(ASKIP,NORM),NAME=SALDOUT

OPENAPI 3.0 EQUIVALENTE:
  paths:
    /accounts/inquiry:
      post:
        requestBody:
          required: true
          content:
            application/json:
              schema:
                type: object
                required: [accountNumber]
                properties:
                  accountNumber:
                    type: string
                    minLength: 10
                    maxLength: 10
                    pattern: '^[0-9]{10}$'   # ATTRB=NUM
        responses:
          '200':
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    balance:
                      type: number
                      format: decimal
```

### 4C. CAPA BATCH — COBOL BATCH → SPRING BATCH

#### 4C.1 La Crisis del Proyecto Gamma — El N+1 y el Batch Chatty

`[CRÍTICO]` Esta sección documenta los patrones que causaron la falla anterior. El equipo que hizo la traducción literal cometió tres errores estructurales:

**Error 1: N+1 a escala (el más grave)**

```cobol
* COBOL original — eficiente en z/OS porque DB2 está en memoria compartida
* y el I/O es local (canal, no red):
PERFORM UNTIL WS-EOF = 'Y'
    READ INPUT-FILE INTO WS-CUENTA-RECORD
        AT END MOVE 'Y' TO WS-EOF
    END-READ
    
    EXEC SQL
        SELECT SALDO INTO :WS-SALDO
        FROM CUENTAS
        WHERE CUENTA_NUM = :WS-CUENTA-NUM  ← Una query por registro
    END-EXEC
    
    PERFORM CALCULAR-INTERES
    
    EXEC SQL
        UPDATE CUENTAS SET SALDO = :WS-NUEVO-SALDO
        WHERE CUENTA_NUM = :WS-CUENTA-NUM  ← Un update por registro
    END-EXEC
    
END-PERFORM.
* 10 millones de registros = 20 millones de round-trips a DB2
* En z/OS: DB2 local, bus de alta velocidad → tolerable
* En Java→PostgreSQL en red: CATÁSTROFE de latencia
```

```java
// TRADUCCIÓN LITERAL (LA QUE FALLÓ) — NUNCA HACER ESTO
@Component
public class InterestCalculationTasklet implements Tasklet {
    
    @Autowired
    private AccountRepository accountRepo;  // JPA con N+1
    
    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext context) {
        List<String> accountNumbers = getAccountNumbers(); // 10M cuentas
        
        for (String accountNumber : accountNumbers) {        // 10M iteraciones
            Account account = accountRepo.findById(accountNumber).orElseThrow();  // SELECT (N)
            BigDecimal interest = calculateInterest(account);
            account.setBalance(account.getBalance().add(interest));
            accountRepo.save(account);  // UPDATE (N)
        }                               // Total: 20M round-trips
        return RepeatStatus.FINISHED;
    }
}
```

```java
// SOLUCIÓN CORRECTA — Spring Batch con Chunk Processing + Bulk
@Configuration
public class InterestCalculationJobConfig {
    
    @Bean
    public Step interestCalculationStep(
            ItemReader<Account> reader,
            ItemProcessor<Account, Account> processor,
            ItemWriter<Account> writer) {
        
        return stepBuilderFactory.get("interestCalculationStep")
            .<Account, Account>chunk(1000)  // Procesar 1000 registros por chunk
            .reader(reader)                  // Lee en batch de DB
            .processor(processor)            // Lógica de negocio
            .writer(writer)                  // Escribe con INSERT/UPDATE batch
            .faultTolerant()
            .retryLimit(3)
            .retry(DeadlockLoserDataAccessException.class)
            .build();
    }
    
    // Reader eficiente: lee 1000 en una sola query con paginación por clave
    @Bean
    @StepScope
    public JdbcPagingItemReader<Account> accountReader(DataSource dataSource) {
        return new JdbcPagingItemReaderBuilder<Account>()
            .name("accountReader")
            .dataSource(dataSource)
            .selectClause("SELECT account_id, balance, product_type, rate")
            .fromClause("FROM accounts")
            .whereClause("WHERE status = 'ACTIVE'")
            .sortKeys(Map.of("account_id", Order.ASCENDING))
            .pageSize(1000)  // Una query trae 1000 registros
            .rowMapper(new AccountRowMapper())
            .build();
    }
    
    // Writer eficiente: JDBC batch update (un round-trip por 1000 registros)
    @Bean
    public JdbcBatchItemWriter<Account> accountWriter(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<Account>()
            .dataSource(dataSource)
            .sql("UPDATE accounts SET balance = :balance, " +
                 "last_interest_date = :lastInterestDate " +
                 "WHERE account_id = :accountId")
            .beanMapped()
            .build();
    }
}
```

**Error 2: SORT en software (el que agota la memoria)**

```cobol
* COBOL original — SORT usa hardware z/OS (DFSORT/SYNCSORT)
* y consume canales físicos, no RAM:
SORT INPUT-FILE
  ON ASCENDING KEY WS-CUENTA-NUM
  USING INPUT-VSAM
  GIVING SORTED-OUTPUT
  OUTREC FIELDS=(1,10,11,15,26,8)
```

```java
// ERROR: Cargar todo en memoria para ordenar
List<Account> allAccounts = accountRepo.findAll(); // OOM con 10M registros
allAccounts.sort(Comparator.comparing(Account::getAccountId)); // HeapError
// SOLUCIÓN: el SORT debe ocurrir en la base de datos o en el reader paginado

// CORRECTO: ORDER BY en la query de paginación (delegado al motor de DB)
// Ver la cláusula sortKeys en el JdbcPagingItemReader de arriba
// → El ORDER BY lo ejecuta PostgreSQL/Aurora con índice → sin carga de RAM

// Para SORT con transformación de campos (OUTREC): usar ItemProcessor
// Para SORT masivo de archivos planos: Apache Spark / AWS Glue (no en JVM)
```

**Error 3: Batch chatty (múltiples llamadas donde COBOL hacía una sola operación de archivo)**

```cobol
* COBOL original — una sola operación de archivo plano (canal físico)
WRITE OUTPUT-RECORD FROM WS-REPORT-LINE.
* 500,000 records = 500,000 writes directas a DASD, eficiente en z/OS
```

```java
// ERROR: 500,000 inserts a PostgreSQL uno por uno
for (ReportLine line : reportLines) {
    jdbcTemplate.update("INSERT INTO report_lines ...", line);  // N inserts
}

// CORRECTO: Batch JDBC / COPY para carga masiva
@Bean
public JdbcBatchItemWriter<ReportLine> reportWriter(DataSource dataSource) {
    return new JdbcBatchItemWriterBuilder<ReportLine>()
        .dataSource(dataSource)
        .sql("INSERT INTO report_lines (account_id, amount, date) " +
             "VALUES (:accountId, :amount, :date)")
        .beanMapped()
        .build();
    // Con chunk(1000): 500 inserts → 500x más rápido
}

// Para carga masiva inicial (millones de registros): 
// PostgreSQL COPY protocol via pgCopy — 10-100x más rápido que INSERT batch
@Component
public class BulkLoader {
    public void bulkLoad(DataSource ds, List<ReportLine> lines) throws SQLException {
        try (Connection conn = ds.getConnection()) {
            CopyManager cm = conn.unwrap(PGConnection.class).getCopyAPI();
            cm.copyIn(
                "COPY report_lines (account_id, amount, date) FROM STDIN WITH CSV",
                buildCsvStream(lines)
            );
        }
    }
}
```

#### 4C.2 Arquitectura Completa de Spring Batch para Batch Masivo Bancario

```
JOB: InterestCalculationJob (equivalente al JCL STEP*)
═══════════════════════════════════════════════════════════════════

              JobRepository (DB)
                    │ (rastrea estado, permite restart)
                    ▼
         ┌─────────────────────┐
         │  Job Launcher       │
         │  (orquestador       │
         │   externo: Airflow  │
         │   → Spring Batch    │
         │   REST API)         │
         └──────────┬──────────┘
                    │
         ┌──────────▼──────────┐
         │  STEP 1             │     Equivalente a JCL STEP010
         │  Validate Accounts  │     EXEC PGM=VALCUEN01
         │                     │
         │  Reader: JDBC Page  │     DD CUENTFILE DISP=SHR
         │  Processor: Validate│
         │  Writer: JDBC Batch │     DD ERRFILE DISP=(NEW,CATLG)
         │  Chunk size: 1,000  │
         └──────────┬──────────┘
                    │ (si RC=0 → continúa, si RC>0 → skipear STEP 2)
                    │ Equivalente a COND=(0,NE,STEP010)
         ┌──────────▼──────────┐
         │  STEP 2             │     Equivalente a JCL STEP020
         │  Calculate Interest │     EXEC PGM=CALINT01,COND=(0,NE,STEP010)
         │                     │
         │  Reader: JDBC Page  │     Particionado en 8 threads paralelos
         │  Processor: Calc    │     (equivalente a múltiples LPAR/subtask en z/OS)
         │  Writer: JDBC Batch │
         │  Chunk size: 1,000  │
         │  Partitions: 8      │
         └──────────┬──────────┘
                    │
         ┌──────────▼──────────┐
         │  STEP 3             │
         │  Generate Report    │     Equivalente a JCL STEP030 + SORT
         │                     │
         │  Reader: JDBC Query │     ORDER BY en query (no SORT en JVM)
         │  Processor: Format  │
         │  Writer: File/S3    │     Equivalente a SYSOUT o archivo en DASD
         │  Chunk size: 5,000  │
         └─────────────────────┘

PARALELISMO INTRA-JOB (equivalente a múltiples STEPs en paralelo con TWS):
  Spring Batch Parallel Steps:
    Flow 1 → STEP A → STEP B
    Flow 2 → STEP C         → JOIN → STEP D (depende de A+B+C)
```

#### 4C.3 Particionamiento para Batch Masivo (Equivalente a MPP en z/OS)

```java
@Configuration
public class PartitionedInterestJobConfig {
    
    // Partitioner: divide 10M cuentas en 8 rangos
    @Bean
    public Partitioner accountPartitioner(DataSource dataSource) {
        ColumnRangePartitioner partitioner = new ColumnRangePartitioner();
        partitioner.setColumn("account_id");
        partitioner.setTable("accounts");
        partitioner.setDataSource(dataSource);
        return partitioner;
    }
    
    // Master Step: coordina las particiones
    @Bean
    public Step masterInterestStep(Step workerInterestStep, Partitioner partitioner) {
        return stepBuilderFactory.get("masterInterestStep")
            .partitioner("workerInterestStep", partitioner)
            .step(workerInterestStep)
            .gridSize(8)             // 8 particiones paralelas
            .taskExecutor(taskExecutor())
            .build();
    }
    
    // Worker Step: procesa un rango de accountIds
    @Bean
    public Step workerInterestStep(
            @StepScope JdbcPagingItemReader<Account> partitionedReader,
            ItemProcessor<Account, Account> interestProcessor,
            JdbcBatchItemWriter<Account> accountWriter) {
        
        return stepBuilderFactory.get("workerInterestStep")
            .<Account, Account>chunk(1000)
            .reader(partitionedReader)
            .processor(interestProcessor)
            .writer(accountWriter)
            .build();
    }
    
    // Reader con rango de la partición inyectado por Spring
    @Bean
    @StepScope
    public JdbcPagingItemReader<Account> partitionedReader(
            DataSource dataSource,
            @Value("#{stepExecutionContext['minValue']}") Long minValue,
            @Value("#{stepExecutionContext['maxValue']}") Long maxValue) {
        
        return new JdbcPagingItemReaderBuilder<Account>()
            .name("partitionedReader")
            .dataSource(dataSource)
            .selectClause("SELECT *")
            .fromClause("FROM accounts")
            .whereClause("WHERE account_id >= " + minValue + 
                        " AND account_id < " + maxValue)
            .sortKeys(Map.of("account_id", Order.ASCENDING))
            .pageSize(1000)
            .rowMapper(new AccountRowMapper())
            .build();
    }
}
```

#### 4C.4 Estrategia de Migración por Tipo de Batch

| Tipo de Batch COBOL | Patrón Destino | Tecnología | Consideración Crítica |
|---|---|---|---|
| **Batch de actualización masiva** (N updates) | Spring Batch con Chunk + JDBC Batch | Spring Batch + PostgreSQL | Chunk size 500–2000; nunca uno por uno |
| **Batch de cierre/EOD** | Spring Batch con Partitioning | Spring Batch + N workers en Kubernetes | Diseñar para restart (idempotencia por chunk) |
| **Batch con SORT masivo** | SQL ORDER BY + índice | PostgreSQL / Aurora | Nunca SORT en JVM; delegar al motor de DB |
| **Batch con JOINs múltiples de archivos** | SQL JOIN o Kafka Streams | PostgreSQL / Spark | Los COBOL hacían MATCH MERGE manualmente; SQL lo hace mejor |
| **Generación de reportes/estados** | Spring Batch + S3/GCS | Spring Batch + cloud storage | Chunk size grande (5000+); considerar Parquet para big data |
| **Batch de conciliación** | Spring Batch + CQRS read model | Spring Batch + Redis/PostgreSQL | Proyección optimizada para conciliación; no usar tablas transaccionales |
| **Batch de carga inicial (migration)** | PostgreSQL COPY / Spark | pgCopy / AWS Glue | Para millones de registros: COPY es 50–100x más rápido que INSERT |
| **Batch con múltiples pasos dependientes** | Spring Batch Job con Flow | Spring Batch | Equivalente exacto al JCL COND logic |

---

## 5. PATRONES DE DATOS {#5}

### 5.1 Mapeo de Tecnologías de Datos Mainframe → Cloud

| Tecnología Mainframe | Uso Típico | Tecnología Destino | Patrón de Migración |
|---|---|---|---|
| **VSAM KSDS** (Key Sequence) | Archivos maestros (cuentas, clientes) | PostgreSQL / MySQL | Schema-on-write + clave primaria natural |
| **VSAM ESDS** (Entry Sequence) | Logs, trazas, diarios de transacciones | PostgreSQL + particionamiento / S3 + Parquet | Append-only → Event Log o tabla particionada por fecha |
| **VSAM RRDS** (Relative Record) | Tablas de lookup fijas por posición | Redis Hash / PostgreSQL array | Acceso por índice relativo → hash map |
| **VSAM AIX** (Alternate Index) | Búsqueda por campo alternativo | Índice de BD relacional / Elasticsearch | Índice secundario en PostgreSQL |
| **DB2 z/OS** | Datos transaccionales relacionales | PostgreSQL / Aurora PostgreSQL | Schema migration + data migration con CDC |
| **IMS DB (DL/I)** | Datos jerárquicos legacy | PostgreSQL JSONB / MongoDB | Flatten hierarchy + documentar jerarquía implícita |
| **Flat files secuenciales** | Intercambio entre jobs, reportes | S3 / Azure Blob + formato moderno | Parquet/Avro para batch; CSV para intercambio simple |
| **GDGs (Generation Data Groups)** | Versiones históricas de datasets | S3 versioning / PostgreSQL + effective_date | Versionado temporal de datos |
| **MQ Series (MQ)** | Mensajería entre sistemas | Apache Kafka / AWS SQS | Topic Kafka por dominio; dead letter queue |
| **IMS TM** | Transacciones online (como CICS) | Spring Boot + REST | Igual que la sección CICS |

### 5.2 Pipeline de Migración de Datos — El Camino Correcto

```
MAINFRAME (origen)
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│  FASE 1: EXTRACCIÓN (sin parar el mainframe)                    │
│                                                                  │
│  VSAM/DB2 → UNLOAD JCL → Flat file en DASD                    │
│  Flat file → FTP/SFTP → S3 / Azure Blob / GCS                 │
│                                                                  │
│  [CRÍTICO] El unload debe:                                      │
│    · Convertir EBCDIC → UTF-8                                   │
│    · Desempaquetar COMP-3 → decimal textual                    │
│    · Normalizar fechas (YY → YYYY con ventana de siglo)        │
│    · Documentar los codebooks (PIC clauses) antes de migrar    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  FASE 2: TRANSFORMACIÓN (ETL)                                   │
│                                                                  │
│  S3 → AWS Glue / Apache Spark / dbt                            │
│  Transformaciones:                                              │
│    · Normalización de esquema (VSAM flat → relacional 3NF)     │
│    · Limpieza de datos (nulos implícitos en COBOL = espacios)  │
│    · Generación de surrogate keys (si el natural es problemático│
│    · Validación de integridad referencial (FK implícitas COBOL)│
│    · Reconciliación de totales de control                       │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  FASE 3: CARGA INICIAL (bulk load)                             │
│                                                                  │
│  PostgreSQL COPY → bulk load millones de registros              │
│  Aurora → S3 Import con snapshot                                │
│  Validación post-carga:                                         │
│    · COUNT(*) match mainframe vs. destino                       │
│    · Suma de totales financieros (SUM de saldos, monto total)  │
│    · Sample comparison (1000 registros aleatorios, campo a campo│
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│  FASE 4: CDC — Change Data Capture (sincronización delta)      │
│                                                                  │
│  DB2 z/OS → Debezium (via IBM DB2 CDC) → Kafka → Consumer     │
│  PostgreSQL → aplica cambios incrementales                      │
│                                                                  │
│  Mantenimiento de paridad hasta el cutover:                     │
│    · Lag del CDC < 30 segundos en operación normal             │
│    · Alerta si lag > 5 minutos                                  │
│    · Stop-the-world cutover cuando lag = 0                     │
└─────────────────────────────────────────────────────────────────┘
```

### 5.3 Patrón Dual-Write — Coexistencia Durante la Migración

```java
// Cuando el nuevo microservicio escribe y el mainframe debe mantenerse sincronizado
// durante el período de coexistencia

@Service
@Transactional
public class AccountServiceDualWrite {
    
    private final AccountJpaRepository postgresRepo;
    private final MainframeCuentaAcl mainframeAcl;
    private final DualWriteConfig config;
    private final MeterRegistry metrics;
    
    public Account updateBalance(String accountId, BigDecimal amount) {
        
        // Write 1: PostgreSQL (nuevo sistema de record)
        Account account = postgresRepo.findByIdWithLock(accountId).orElseThrow();
        account.updateBalance(amount);
        Account saved = postgresRepo.save(account);
        
        // Write 2: Mainframe (solo durante coexistencia; se elimina post-cutover)
        if (config.isMainframeSyncEnabled()) {
            try {
                mainframeAcl.syncBalance(accountId, saved.getBalance());
                metrics.counter("dual.write.mainframe.success").increment();
            } catch (MainframeException e) {
                // [RIESGO] Decisión de diseño: ¿falla completa o solo alerta?
                // Para datos financieros: alerta + compensación asíncrona,
                // NO rollback del write en PostgreSQL (mainframe es follower aquí)
                metrics.counter("dual.write.mainframe.failure").increment();
                compensationQueue.publish(new MainframeSyncFailedEvent(accountId, saved));
                log.error("Mainframe sync failed for account {}: {}", accountId, e.getMessage());
            }
        }
        
        return saved;
    }
}
```

**Árbol de decisión: ¿Dual-Write o CDC?**

```
¿El microservicio puede invocar directamente al mainframe (latencia aceptable < 500ms)?
  SÍ → ¿El equipo de mainframe puede modificar el COBOL para recibir updates externos?
        SÍ → Dual-Write (más simple, menos infraestructura)
        NO → CDC unidireccional (mainframe → nuevo sistema)
  NO → CDC unidireccional es la única opción viable

¿El dato en el mainframe cambia sin pasar por el nuevo microservicio (otros sistemas)?
  SÍ → CDC es obligatorio (captura cambios de cualquier origen)
  NO → Dual-Write es suficiente
```

### 5.4 Manejo de Tipos de Datos Críticos COBOL en Java

```java
/**
 * Utilitarios para conversión de tipos COBOL → Java.
 * [CRÍTICO] Esta clase debe tener cobertura de test al 100%.
 * Un error aquí implica corrupción de datos financieros.
 */
public final class CobolTypeConverter {

    // COMP-3 (Packed Decimal) → BigDecimal
    public static BigDecimal unpackComp3(byte[] packed, int decimalPlaces) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < packed.length - 1; i++) {
            sb.append((packed[i] >> 4) & 0x0F);
            sb.append(packed[i] & 0x0F);
        }
        // Último byte: high nibble = último dígito, low nibble = signo
        byte lastByte = packed[packed.length - 1];
        sb.append((lastByte >> 4) & 0x0F);
        char sign = ((lastByte & 0x0F) == 0x0D) ? '-' : '+';
        
        BigDecimal value = new BigDecimal(sb.toString())
            .movePointLeft(decimalPlaces);
        return sign == '-' ? value.negate() : value;
    }
    
    // COMP-3 tiene escala implícita según el PIC clause
    // PIC S9(13)V99 COMP-3 → 15 dígitos total, 2 decimales → byte array de 8 bytes
    
    // Fecha COBOL (YYYYMMDD en PIC 9(8)) → LocalDate
    public static LocalDate parseCobolDate(int yyyymmdd) {
        if (yyyymmdd == 0 || yyyymmdd == 99991231) return null; // Convenciones COBOL para null
        int year  = yyyymmdd / 10000;
        int month = (yyyymmdd % 10000) / 100;
        int day   = yyyymmdd % 100;
        return LocalDate.of(year, month, day);
    }
    
    // Fecha COBOL (YYMMDD en PIC 9(6)) → LocalDate con ventana de siglo
    // [CRÍTICO] La ventana de siglo es específica del negocio y del sistema
    public static LocalDate parseCobolDateYY(int yymmdd, int pivotYear) {
        int yy    = yymmdd / 10000;
        int month = (yymmdd % 10000) / 100;
        int day   = yymmdd % 100;
        // pivotYear = 50 significa: yy >= 50 → 1900+yy, yy < 50 → 2000+yy
        int year  = yy >= pivotYear ? 1900 + yy : 2000 + yy;
        return LocalDate.of(year, month, day);
    }
    
    // EBCDIC String → Java String
    public static String ebcdicToString(byte[] ebcdic, String cobolCodePage) {
        return new String(ebcdic, Charset.forName(cobolCodePage))
            .stripTrailing();  // COBOL rellena con espacios, Java no
    }
    
    // Indicador COBOL 'Y'/'N' / ' ' → Boolean
    public static Boolean cobolFlagToBoolean(char flag) {
        return switch (flag) {
            case 'Y', '1' -> Boolean.TRUE;
            case 'N', '0' -> Boolean.FALSE;
            case ' '      -> null;  // Valor nulo implícito en COBOL
            default -> throw new CobolConversionException("Unknown flag: " + flag);
        };
    }
}
```

---

## 6. PATRONES DE ORQUESTACIÓN — JCL → CLOUD {#6}

### 6.1 Mapeo Conceptual JCL → Orquestadores Modernos

```
JCL / TWS (CA7) CONCEPT          AIRFLOW CONCEPT          STEP FUNCTIONS CONCEPT
════════════════════════════      ══════════════════        ═══════════════════════
JOB                          →   DAG                   →   State Machine
STEP                         →   Task                  →   State (Task/Choice)
JCL PROC                     →   SubDAG / TaskGroup    →   Nested State Machine
COND=(RC,OP,STEP)            →   depends_on + trigger  →   Choice State
TWS/CA7 Schedule             →   schedule_interval     →   EventBridge Schedule
SYSOUT                       →   Task log in CloudWatch→   CloudWatch Logs
DD (Dataset Definition)      →   XCom / S3 Paths       →   S3 Path in Input
RESTART from STEP            →   Task retry + start_date→   AWS Failure handling
Job dependencies (network)   →   External Sensors      →   EventBridge + Step Fn
Hold/Release (TWS)           →   Pause/Unpause DAG     →   Manual Approval State
```

### 6.2 Traducción de JCL Ejemplo → Airflow DAG

```jcl
// JCL ORIGINAL:
//INTCALC  JOB  (FINOP),'CALCULO INTERESES',CLASS=A
//*
//STEP010  EXEC PGM=VALCUEN01,COND=(4,LT)
//STEPLIB  DD   DSN=PROD.LOADLIB,DISP=SHR
//CUENTAS  DD   DSN=PROD.CUENTAS.MASTER,DISP=SHR
//ERRFILE  DD   DSN=PROD.CUENTAS.ERRORES,DISP=(NEW,CATLG)
//*
//STEP020  EXEC PGM=CALINT01,COND=(0,NE,STEP010)
//CUENTAS  DD   DSN=PROD.CUENTAS.MASTER,DISP=SHR
//INTTAB   DD   DSN=PROD.TASAS.VIGENTES,DISP=SHR
//OUTPUT   DD   DSN=PROD.INTERESES.HOY,DISP=(NEW,CATLG)
//*
//STEP030  EXEC PGM=RPTGEN01,COND=((0,NE,STEP010),(0,NE,STEP020))
//INFILE   DD   DSN=PROD.INTERESES.HOY,DISP=SHR
//RPTOUT   DD   SYSOUT=*
```

```python
# EQUIVALENTE AIRFLOW DAG:
from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.operators.python import BranchPythonOperator
from datetime import datetime, timedelta

with DAG(
    dag_id='interest_calculation',             # Equivalente a JOB INTCALC
    schedule_interval='0 22 * * *',           # EOD: 22:00 diario (TWS schedule)
    start_date=datetime(2026, 1, 1),
    catchup=False,
    default_args={
        'retries': 2,
        'retry_delay': timedelta(minutes=5),
        'email_on_failure': True,
        'email': ['ops-batch@bbva.com']
    }
) as dag:

    # STEP010: Validación de cuentas
    validate_accounts = KubernetesPodOperator(      # Equivalente: EXEC PGM=VALCUEN01
        task_id='validate_accounts',
        image='gamma/batch-validate-accounts:latest',
        env_vars={
            'INPUT_SOURCE': 's3://gamma-prod/accounts/master/',   # DD CUENTAS
            'ERROR_TARGET': 's3://gamma-prod/accounts/errors/',   # DD ERRFILE
        },
        do_xcom_push=True,  # Publica el return code
        is_delete_operator_pod=True,
        namespace='batch',
    )

    # Lógica COND: STEP020 solo si STEP010 RC=0 (equivale a COND=(0,NE,STEP010))
    def check_validation_rc(**context):
        rc = context['ti'].xcom_pull(task_ids='validate_accounts', key='return_code')
        return 'calculate_interest' if rc == 0 else 'skip_calculation'

    branch = BranchPythonOperator(
        task_id='check_validation_result',
        python_callable=check_validation_rc,
    )

    # STEP020: Cálculo de intereses
    calculate_interest = KubernetesPodOperator(     # Equivalente: EXEC PGM=CALINT01
        task_id='calculate_interest',
        image='gamma/batch-interest-calc:latest',
        env_vars={
            'ACCOUNTS_SOURCE': 's3://gamma-prod/accounts/master/',  # DD CUENTAS
            'RATES_SOURCE':    's3://gamma-prod/rates/current/',     # DD INTTAB
            'OUTPUT_TARGET':   's3://gamma-prod/interest/today/',    # DD OUTPUT
        },
        is_delete_operator_pod=True,
        namespace='batch',
    )

    skip_calculation = DummyOperator(task_id='skip_calculation')

    # STEP030: Generación de reporte (solo si STEP010 y STEP020 OK)
    generate_report = KubernetesPodOperator(        # Equivalente: EXEC PGM=RPTGEN01
        task_id='generate_report',
        image='gamma/batch-report-gen:latest',
        env_vars={
            'INPUT_SOURCE': 's3://gamma-prod/interest/today/',
            'REPORT_TARGET': 's3://gamma-prod/reports/interest/{{ ds }}/',
        },
        is_delete_operator_pod=True,
        namespace='batch',
    )

    # Definir dependencias (equivalente a la red de JCL COND)
    validate_accounts >> branch
    branch >> [calculate_interest, skip_calculation]
    calculate_interest >> generate_report
```

### 6.3 Árbol de Decisión — Qué Orquestador Usar

```
¿El banco ya tiene inversión y expertise en algún orquestador?
  SÍ → Usar ese (no cambiar la plataforma de orquestación durante la migración de apps)
  NO → continuar árbol

¿La regulación exige que el scheduler sea on-premise o en nube privada?
  SÍ → Control-M (IBM) o Autosys (BMC) — madurez enterprise + soporte regulatorio
  NO → continuar árbol

¿Los workflows batch son principalmente data pipelines (ETL/ELT)?
  SÍ → Apache Airflow (en cloud managed: MWAA, Cloud Composer, Astronomer)
  NO → continuar árbol

¿Los workflows son microservicio-driven con APIs/eventos más que archivos?
  SÍ → AWS Step Functions / Azure Durable Functions / Google Workflows
  NO → continuar árbol

¿El equipo es Kubernetes-native y quiere infrastructure-as-code?
  SÍ → Argo Workflows (en Kubernetes, GitOps-friendly)
  NO → Apache Airflow (más accesible, amplia comunidad)
```

---

## 7. PATRONES DE RESILIENCIA Y API CLOUD-NATIVE {#7}

### 7.1 Catálogo Completo de Patrones de Resiliencia

| Patrón | Problema que Resuelve | Implementación Spring Boot | Riesgo si No se Aplica |
|---|---|---|---|
| **Circuit Breaker** | Cascading failures: si el mainframe (ACL) falla, no tumbar todo el microservicio | Resilience4j `@CircuitBreaker` | Un mainframe lento tumba todos los servicios que lo consumen |
| **Retry + Exponential Backoff** | Fallos transitorios de red (cortos) | Resilience4j `@Retry` con `waitDuration` exponencial | Fallo transitorio de 100ms causa error de negocio; reintentos inmediatos generan thundering herd |
| **Bulkhead** | Un servicio lento no bloquea threads de otro | Resilience4j `@Bulkhead` (thread pool isolation) | Pool de threads exhausto por 1 dependencia lenta → toda la app cuelga |
| **Timeout** | Servicios que nunca responden bloquean recursos | `@TimeLimiter` + `RestTemplate.setConnectTimeout` | Sin timeout → hilo bloqueado indefinidamente → OOM |
| **Idempotency** | Duplicados en pagos por retry del cliente | UUID + tabla de deduplicación en DB | Cliente reintenta → doble débito, doble transferencia → fraude/error regulatorio |
| **Graceful Degradation** | Respuesta parcial cuando hay falla de dependencia | Feature flags + cache como fallback | Indisponibilidad de 1 servicio tumba la experiencia completa del cliente |
| **Rate Limiting** | Proteger servicios de sobrecarga | Bucket4j + Redis distribuido | Un canal mal comportado agota recursos, afecta a todos |
| **Health Checks** | Kubernetes necesita saber si el pod está listo | Actuator `/health/liveness` + `/health/readiness` diferenciados | K8s mata pods en buen estado o deja pods rotos recibiendo tráfico |
| **Dead Letter Queue** | Mensajes que no se pueden procesar no se pierden | Kafka DLQ + monitoring + alerting | Mensajes fallidos desaparecen silenciosamente → pérdida de datos de negocio |

### 7.2 Implementación Resilience4j para el ACL al Mainframe

```java
@Component
public class ResilientMainframeGateway {
    
    private final CircuitBreakerRegistry cbRegistry;
    private final RetryRegistry retryRegistry;
    private final MainframeGatewayConfig config;
    private final CtgClient ctgClient;

    // Configuración: Circuit Breaker + Retry + Timeout compuestos
    public MainframeResponse executeWithResilience(String transactionId, byte[] commarea) {
        
        CircuitBreaker cb = cbRegistry.circuitBreaker("mainframe-gateway",
            CircuitBreakerConfig.custom()
                .failureRateThreshold(50)          // Abre si >50% fallan
                .waitDurationInOpenState(Duration.ofSeconds(30))
                .slidingWindowSize(10)             // Ventana de 10 llamadas
                .permittedNumberOfCallsInHalfOpenState(3)
                .build());

        Retry retry = retryRegistry.retry("mainframe-gateway",
            RetryConfig.custom()
                .maxAttempts(3)
                .waitDuration(Duration.ofMillis(200))
                .intervalFunction(IntervalFunction.ofExponentialBackoff(200, 2)) // 200ms, 400ms, 800ms
                .retryExceptions(MainframeTimeoutException.class, 
                                 MainframeConnectionException.class)
                .ignoreExceptions(MainframeBusinessException.class)  // No reintentar errores de negocio
                .build());
        
        TimeLimiter timeLimiter = TimeLimiter.of(
            TimeLimiterConfig.custom()
                .timeoutDuration(Duration.ofSeconds(5))  // SLA mainframe: 5 segundos
                .build());

        // Componer: Retry → Circuit Breaker → Time Limiter → llamada real
        Callable<MainframeResponse> decorated = TimeLimiter.decorateFutureSupplier(
            timeLimiter,
            CircuitBreaker.decorateSupplier(cb,
                Retry.decorateSupplier(retry,
                    () -> ctgClient.execute(transactionId, commarea)
                )
            )
        );

        return Try.of(decorated::call)
            .recover(CallNotPermittedException.class, e -> {
                // Circuit Breaker abierto → fallback
                metrics.counter("mainframe.circuit_breaker.open").increment();
                return MainframeResponse.degraded("SYSTEM_TEMPORARILY_UNAVAILABLE");
            })
            .recover(TimeoutException.class, e -> {
                metrics.counter("mainframe.timeout").increment();
                throw new ServiceUnavailableException("Mainframe timeout after 5s");
            })
            .get();
    }
}
```

### 7.3 Idempotency Pattern para Operaciones Financieras

```java
// [CRÍTICO] Para pagos y transferencias: nunca procesar dos veces el mismo request
@Entity
@Table(name = "idempotency_records", 
       indexes = @Index(columnList = "idempotency_key", unique = true))
public class IdempotencyRecord {
    @Id @GeneratedValue
    private Long id;
    
    @Column(nullable = false, unique = true, length = 36)
    private String idempotencyKey;    // UUID del cliente
    
    @Column(nullable = false)
    private String requestHash;       // SHA-256 del request body (detectar cambios)
    
    @Column(columnDefinition = "TEXT")
    private String responseBody;      // Respuesta almacenada para replay
    
    @Column(nullable = false)
    private String status;            // PROCESSING | COMPLETED | FAILED
    
    @Column(nullable = false)
    private Instant createdAt;
    
    @Column(nullable = false)
    private Instant expiresAt;        // TTL: 24 horas (configurable por tipo de operación)
}

@Service
public class IdempotencyService {
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public <T> T executeIdempotent(String idempotencyKey, String requestHash, 
                                    Supplier<T> operation, Class<T> responseType) {
        
        Optional<IdempotencyRecord> existing = 
            idempotencyRepo.findByIdempotencyKey(idempotencyKey);
        
        if (existing.isPresent()) {
            IdempotencyRecord record = existing.get();
            
            if (!record.getRequestHash().equals(requestHash)) {
                throw new ConflictException(
                    "Idempotency key reused with different request body");
            }
            
            return switch (record.getStatus()) {
                case "COMPLETED" -> deserialize(record.getResponseBody(), responseType);
                case "PROCESSING" -> throw new ConflictException("Request still processing");
                case "FAILED" -> throw new PreviousRequestFailedException(idempotencyKey);
                default -> throw new IllegalStateException("Unknown status: " + record.getStatus());
            };
        }
        
        // Primer intento: crear registro en estado PROCESSING (lock optimista)
        IdempotencyRecord record = idempotencyRepo.save(
            new IdempotencyRecord(idempotencyKey, requestHash, "PROCESSING"));
        
        try {
            T result = operation.get();
            record.setStatus("COMPLETED");
            record.setResponseBody(serialize(result));
            idempotencyRepo.save(record);
            return result;
        } catch (Exception e) {
            record.setStatus("FAILED");
            idempotencyRepo.save(record);
            throw e;
        }
    }
}
```

### 7.4 Patrón Saga — Transacciones Distribuidas Bancarias

```
SAGA ORQUESTADA — Transferencia SPEI (ejemplo)
════════════════════════════════════════════════

SpeiTransferOrchestrator (Spring State Machine / Temporal.io / AWS Step Functions)

HAPPY PATH:
  1. ValidateTransfer ──────────────────► AccountService.reserveFunds()
                                                 │ Success
  2. NotifyBanxico ──────────────────────► SpeiGateway.sendOrder()
                                                 │ Accepted
  3. DebitAccount ───────────────────────► AccountService.debit()
                                                 │ Success
  4. CreditConfirmation ─────────────────► NotificationService.notify()
                                                 │
  5. Complete ──────────────────────────► DONE

COMPENSATION PATH (si falla en paso N):
  Si falla paso 3 (DebitAccount):
    3a. CancelBanxico ─────────────────► SpeiGateway.cancelOrder()
    3b. ReleaseFunds ──────────────────► AccountService.releaseFunds()
    3c. NotifyFailure ─────────────────► NotificationService.notifyError()

  Si falla paso 2 (Banxico rechaza):
    2a. ReleaseFunds ──────────────────► AccountService.releaseFunds()
    2b. NotifyRejection ───────────────► NotificationService.notifyRejection()
```

```java
// Implementación con Temporal.io (recomendado sobre Step Functions para lógica compleja)
@WorkflowInterface
public interface SpeiTransferWorkflow {
    @WorkflowMethod
    TransferResult execute(SpeiTransferCommand command);
}

@ActivityInterface
public interface SpeiTransferActivities {
    @ActivityMethod FundReservation reserveFunds(String accountId, BigDecimal amount);
    @ActivityMethod SpeiOrderResult sendToBanxico(SpeiOrder order);
    @ActivityMethod void debitAccount(String accountId, BigDecimal amount, String orderId);
    @ActivityMethod void releaseFunds(String reservationId);
    @ActivityMethod void cancelBanxicoOrder(String orderId);
    @ActivityMethod void notifyResult(String accountId, TransferResult result);
}

@WorkflowImpl
public class SpeiTransferWorkflowImpl implements SpeiTransferWorkflow {
    
    private final SpeiTransferActivities activities = 
        Workflow.newActivityStub(SpeiTransferActivities.class, 
            ActivityOptions.newBuilder()
                .setStartToCloseTimeout(Duration.ofSeconds(30))
                .setRetryOptions(RetryOptions.newBuilder()
                    .setMaximumAttempts(3)
                    .build())
                .build());
    
    @Override
    public TransferResult execute(SpeiTransferCommand command) {
        FundReservation reservation = null;
        SpeiOrderResult speiResult = null;
        
        try {
            // Paso 1: Reservar fondos
            reservation = activities.reserveFunds(command.sourceAccount(), command.amount());
            
            // Paso 2: Enviar a Banxico
            speiResult = activities.sendToBanxico(buildSpeiOrder(command, reservation));
            if (speiResult.isRejected()) {
                activities.releaseFunds(reservation.reservationId());
                activities.notifyResult(command.sourceAccount(), 
                    TransferResult.rejected(speiResult.rejectionCode()));
                return TransferResult.rejected(speiResult.rejectionCode());
            }
            
            // Paso 3: Débito definitivo
            activities.debitAccount(command.sourceAccount(), command.amount(), 
                                     speiResult.orderId());
            
            activities.notifyResult(command.sourceAccount(), TransferResult.success());
            return TransferResult.success(speiResult.orderId());
            
        } catch (Exception e) {
            // Compensación automática
            if (speiResult != null && speiResult.isAccepted()) {
                activities.cancelBanxicoOrder(speiResult.orderId());
            }
            if (reservation != null) {
                activities.releaseFunds(reservation.reservationId());
            }
            activities.notifyResult(command.sourceAccount(), TransferResult.error(e.getMessage()));
            throw e;
        }
    }
}
```

---

## 8. PATRONES DE COEXISTENCIA Y PARALLEL-RUN {#8}

### 8.1 Modelo de Coexistencia para Proyecto Gamma

```
TIMELINE DE COEXISTENCIA (por wave de migración)

  Semana  0:  API Gateway instalado. Mainframe = 100% del tráfico.
              Sin cambios funcionales. Solo observabilidad en el gateway.
              
  Semana  4:  Wave 1 desplegada (BC-09 Notificaciones — bajo riesgo).
              Shadow mode activado: mainframe responde, Java sombrea.
              Comparador asíncrono acumula divergencias.
              
  Semana  8:  Validación shadow: divergencia < 0.01% → cutover BC-09.
              API Gateway redirige /notifications/* → Spring Boot.
              Mainframe se retira de notificaciones (RETAIN para otros).
              
  Semana 12:  Wave 2 (BC-05 Domestic Payments).
              Shadow mode: ambos sistemas procesan, mainframe lidera.
              ...
              
  Mes  18-24: BC-02 Core Accounts (el más crítico).
              Shadow period mínimo: 1 ciclo mensual completo.
              Parallel run con reconciliación diaria de saldos.
              Cutover en fin de semana post-validación.
              
  Mes 36-48:  BC-07 General Ledger (último — regulatorio).
              Shadow period: 1 ciclo de cierre anual completo (13 meses).
              Doble bookkeeping durante el período (costoso pero no negociable).
```

### 8.2 Parallel-Run con Reconciliación Automática

```java
@Scheduled(cron = "0 30 22 * * *")  // EOD: 22:30 diariamente
public void reconcileParallelSystems() {
    
    ReconciliationReport report = new ReconciliationReport(LocalDate.now());
    
    // 1. Comparar totales de control (suma de saldos)
    BigDecimal mainframeTotal = mainframeAcl.getAccountBalanceTotal();
    BigDecimal postgresTotal  = accountRepo.sumAllBalances();
    
    BigDecimal totalDiff = mainframeTotal.subtract(postgresTotal).abs();
    if (totalDiff.compareTo(BigDecimal.ZERO) != 0) {
        report.addDivergence("TOTAL_BALANCE", mainframeTotal, postgresTotal, totalDiff);
        alertService.critical("Balance totals diverge: " + totalDiff);
    }
    
    // 2. Comparar cuenta por cuenta (muestra de 1000 aleatorias)
    List<String> sampleAccounts = accountRepo.findRandomSample(1000);
    for (String accountId : sampleAccounts) {
        BigDecimal mfBalance = mainframeAcl.getBalance(accountId);
        BigDecimal pgBalance = accountRepo.findById(accountId)
            .map(Account::getBalance).orElse(null);
        
        if (pgBalance == null) {
            report.addMissing(accountId, mfBalance);
        } else if (mfBalance.compareTo(pgBalance) != 0) {
            report.addDivergence(accountId, mfBalance, pgBalance);
        }
    }
    
    // 3. Publicar reporte y determinar go/no-go para cutover
    reconciliationRepo.save(report);
    
    if (report.getDivergenceRate() > 0.0001) {  // > 0.01% divergencia → bloquear cutover
        cutoverGate.block("RECONCILIATION_DIVERGENCE > 0.01%");
        alertService.urgent("Parallel run divergence too high: " + 
                           report.getDivergenceRate() * 100 + "%");
    }
}
```

### 8.3 Estrategia de Cutover — El Momento Crítico

```
CUTOVER PLAN (por BC migrado)

  T-7 días:  Feature freeze en mainframe para el BC a migrar.
             No más cambios COBOL en esos programas.
             El nuevo código Java es el líder de cambios.

  T-2 días:  Dry-run de cutover en staging (réplica de producción).
             Medir tiempo de maintenance window necesario.

  T-1 día:   Go/No-Go meeting:
             ✓ Divergencia en parallel-run < 0.01%
             ✓ Performance tests Java: P95 < SLA del mainframe
             ✓ Rollback plan aprobado y ensayado
             ✓ CNBV notificado (si aplica por regulación)

  T-0 (cutover):
    22:00  → Notificar a canales (mantenimiento programado)
    22:30  → Stop writes en el sistema (maintenance window)
    22:35  → Última sincronización CDC: esperar lag = 0
    22:40  → Verificar paridad final (totales de control)
    22:45  → Cambiar routing en API Gateway: BC → Spring Boot
    22:50  → Smoke tests automáticos (suite de 50 transacciones críticas)
    23:00  → Si smoke tests OK: abrir tráfico real
             Si smoke tests FAIL: rollback (cambiar routing de vuelta en < 2 min)
    
  T+1 hora:  Monitoring intensivo:
             · Error rate vs. baseline mainframe
             · P95 latency vs. SLA
             · CPU/Memory del nuevo servicio
             · Logs de errores de negocio
             
  T+24 horas: Decisión: mantener Spring Boot como sistema de record
              o rollback a mainframe.

ROLLBACK PLAN:
  En el API Gateway: 1 cambio de configuración → routing de vuelta al mainframe
  Tiempo de rollback: < 2 minutos (sin deployment, solo config)
  Datos: CDC inverso (Spring Boot → mainframe) si hubo writes en el período
```

---

## 9. ANTI-PATRONES CRÍTICOS {#9}

### 9.1 Los Anti-patrones que Destruyeron el Intento Anterior de Gamma

`[CRÍTICO]` La falla de performance en la primera migración de Gamma fue predecible y evitable. Documentamos los anti-patrones exactos para que no se repitan.

---

#### ANTIPATRÓN #1: Traducción Literal COBOL → Java (El Anti-patrón Madre)

**Manifestación:**
> "Tomamos el COBOL, lo entendimos, y lo reescribimos línea a línea en Java. Es el mismo algoritmo."

**Por qué falla:**
El COBOL en z/OS fue optimizado para un entorno específico:
- DB2 en memoria compartida (sin latencia de red)
- I/O a DASD por canal físico de alta velocidad
- Buffer pools del sistema operativo (SMF records)
- SORT con hardware dedicado (DFSORT) fuera del address space del programa

Cuando se traduce literalmente a Java:
- Cada `EXEC SQL SELECT` se convierte en un round-trip de red a PostgreSQL (1–5ms cada uno)
- 10M registros × 1 query cada uno = 10M × 3ms promedio = 8.3 horas solo en I/O de DB
- El SORT en JVM carga todo en heap → OOM o GC storms
- Los `CALL` síncronos que en z/OS eran subroutines en memoria se convierten en llamadas HTTP

**La regla:**
```
Al migrar de COBOL a Java, NO migrar el algoritmo.
Migrar la INTENCIÓN DE NEGOCIO (qué hace) 
y reimplementarla con los patrones correctos del entorno destino.
```

---

#### ANTIPATRÓN #2: N+1 Query Problem a Escala de Core Bancario

**Manifestación:** Loop COBOL con SELECT por iteración → traducido a `repository.findById()` en loop.

**Detección:**
```sql
-- En production query logs, ver queries del tipo:
SELECT * FROM accounts WHERE account_id = ?  -- aparece 10,000,000 veces en 1 hora
SELECT * FROM accounts WHERE account_id = ?  -- con EXACTAMENTE los mismos planes
SELECT * FROM accounts WHERE account_id = ?  -- en batch jobs de EOD
```

**Solución:**
```java
// EN LUGAR DE:
for (String id : millionIds) {
    Account acc = repo.findById(id).orElseThrow(); // SELECT × N
    process(acc);
}

// USAR:
// Opción A: JPA findAllById (para conjuntos pequeños < 1000)
List<Account> accounts = repo.findAllById(batchOfIds); // 1 SELECT con IN (...)
accounts.forEach(this::process);

// Opción B: JdbcPagingItemReader con chunk (para millones de registros)
// Ver sección 4C.2

// Opción C: JOIN en la query (cuando necesitas datos de múltiples tablas)
@Query("SELECT a FROM Account a JOIN FETCH a.product p WHERE a.status = 'ACTIVE'")
List<Account> findActiveWithProduct(); // 1 query con JOIN, no N+1
```

---

#### ANTIPATRÓN #3: SORT en JVM para Datasets de Millones de Registros

**Manifestación:**
```java
// ANTI-PATRÓN:
List<Transaction> all = txRepo.findAll(); // Carga 50M registros en heap
all.sort(Comparator.comparing(Transaction::getDate)); // GC storm, OOM
```

**Regla absoluta:** El SORT de datasets grandes NUNCA ocurre en la JVM. Delegarlo siempre a:
1. `ORDER BY` en SQL (el motor tiene índices y algoritmos optimizados)
2. Apache Spark para datasets que no caben en una sola BD
3. AWS Glue / dbt para pipelines de datos

---

#### ANTIPATRÓN #4: Big Bang Rewrite

**Manifestación:**
> "Vamos a reescribir todo en paralelo y hacer un cutover único en 18 meses."

**Por qué falla en sistemas de 136M LOC con 150 sistemas:**
- El equipo subestima sistemáticamente el conocimiento tácito del negocio embebido en COBOL
- La paridad funcional es imposible de verificar sin haber ejecutado ambos sistemas en paralelo
- Un cutover único elimina la posibilidad de rollback
- Cualquier error post-cutover afecta a TODOS los sistemas simultáneamente

**Señales de alerta en el discurso del cliente:**
- "El mainframe tiene todo mal diseñado, mejor empezamos de cero"
- "Ya tenemos los requerimientos funcionales documentados" (para un sistema de 40 años)
- "El cutover va a ser un fin de semana largo"

---

#### ANTIPATRÓN #5: ACL como Simple Proxy (Sin Traducción de Modelo)

**Manifestación:**
```java
// ANTI-PATRÓN: La ACL devuelve el modelo COBOL sin traducir
public CobolCuentaRecord getAccount(String id) {  // ← devuelve el tipo COBOL
    return mainframeGateway.executeTransaction("CCT1", buildCommarea(id));
}
// El microservicio ahora trabaja con PIC X(2) y COMP-3 en Java → el mainframe
// "infecta" al nuevo sistema
```

**Correcto:** La ACL devuelve SIEMPRE el modelo limpio del bounded context destino. El modelo COBOL nunca cruza la frontera de la ACL.

---

#### ANTIPATRÓN #6: Transacciones Distribuidas con 2PC

**Manifestación:**
> "Necesitamos que el débito en cuentas y el registro contable sean atómicos → usamos XA transactions."

**Por qué falla en microservicios:**
- XA/2PC bloquea recursos en todos los nodos participantes durante la coordinación
- Si el coordinator falla, los recursos quedan bloqueados indefinidamente
- La latencia se multiplica por el número de participantes
- Incompatible con la mayoría de brokers Kafka y servicios cloud managed

**Alternativa correcta:** Saga Pattern (ver sección 7.4) + eventual consistency con compensación.

---

#### ANTIPATRÓN #7: Copiar la Estructura del JCL como Estructura de Microservicios

**Manifestación:**
```
JCL original:        Nueva arquitectura:
  STEP010 VALCUEN  →   ValidateAccountsService
  STEP020 CALINT   →   CalculateInterestService
  STEP030 RPTGEN   →   GenerateReportService
```

**El problema:** Los STEPs de JCL son unidades de **orquestación de proceso**, no de dominio de negocio. Crear un microservicio por STEP produce microservicios sin dominio propio, altamente acoplados por secuencia, que en realidad son un monolito distribuido.

**Correcto:** Los microservicios se definen por Bounded Context de dominio, no por paso del JCL. Los STEPs del JCL se mapean a **tareas dentro de un Spring Batch Job**, no a servicios independientes.

---

#### ANTIPATRÓN #8: Omitir el Shadow Period / Parallel Run

**Manifestación:**
> "Ya probamos en QA con datos de prueba. El cutover es directo."

**Por qué es catastrófico en banca:**
- Los datos de producción tienen casos edge que ningún QA anticipa en un sistema de 40 años
- La lógica de negocio undocumentada solo se descubre cuando el sistema nuevo la procesa de forma diferente al COBOL
- En sistemas financieros, los errores de equivalencia generan diferencias contables que tardan semanas en detectarse

**Regla:** Parallel run mínimo de 1 ciclo de negocio completo. Para cierre mensual: 1 mes. Para cierre anual: 1 año.

---

#### ANTIPATRÓN #9: Migrar Sin API Gateway (Strangler Fig Incompleto)

**Manifestación:**
> "No necesitamos el API Gateway ahora. Cuando migremos el primer servicio, conectamos los clientes directamente al nuevo microservicio."

**Por qué falla:** Cada cliente (mobile, web, ATM, teller, sistemas B2B) necesita ser modificado para apuntar al nuevo servicio. Con el API Gateway, CERO modificaciones en los clientes durante la migración — el routing cambia en un solo punto.

---

#### ANTIPATRÓN #10: Ignorar el COMP-3 en la Migración de Datos

**Manifestación:**
> "El extract del VSAM los limpió bien, ya están en formato legible."

**Por qué ocurre:** El UNLOAD de VSAM puede hacer una conversión parcial, dejando campos COMP-3 sin desempaquetar o con la escala incorrecta.

**Consecuencia:** Saldos financieros incorrectos silenciosos. Un campo `PIC S9(11)V99 COMP-3` mal convertido da un valor numérico diferente al real — pero numéricamente coherente, sin errores explícitos.

**Control obligatorio:** Después de cualquier migración de datos, comparar SUM de todos los campos monetarios entre mainframe y destino. Si difieren en cualquier centavo: investigar antes de continuar.

---

## 10. MATRIZ DE DECISIÓN RÁPIDA {#10}

### 10.1 Selección de Patrón por Problema

| Situación | Patrón Principal | Patrón de Soporte |
|---|---|---|
| Migrar sistema completo sin afectar clientes | Strangler Fig | API Gateway como interceptor |
| Migrar un módulo COBOL dentro de un sistema parcialmente migrado | Branch by Abstraction | Feature Flags |
| Integrar nuevo microservicio con mainframe legacy durante coexistencia | Anti-Corruption Layer | Circuit Breaker + Retry |
| Migrar VSAM/DB2 sin downtime | CDC (Debezium) | Dual-Write temporal |
| Procesar 10M+ registros en batch | Spring Batch + Chunk + JDBC Batch | Particionamiento paralelo |
| SORT de datos masivos | ORDER BY en SQL / Apache Spark | Nunca en JVM |
| Transacción que toca 3+ microservicios | Saga Orquestada (Temporal.io) | Compensating Transactions |
| Evitar doble débito en pagos | Idempotency Key + tabla dedup | Circuit Breaker en retry |
| Separar lógica de lectura y escritura (alta escala en queries) | CQRS | Event Sourcing (si auditoría completa) |
| Auditoría completa de cambios (regulatorio CNBV) | Event Sourcing | CQRS + Proyecciones |
| Migrar pantallas 3270 a web/móvil | API REST + BFF | OpenAPI first |
| Migrar JCL jobs a cloud | Apache Airflow / Argo Workflows | Kubernetes Jobs |
| Validar paridad funcional mainframe vs. Java | Parallel Run + Reconciliación | Shadow Mode |
| Múltiples canales con contratos API diferentes | Backend for Frontend (BFF) | API Gateway |

### 10.2 Árbol de Decisión — Sincrónico vs. Asíncrono

```
¿La operación requiere respuesta inmediata para el usuario?
  SÍ → ¿Es una mutación (escribe datos)?
        SÍ → REST POST/PUT + @Transactional + Idempotency Key
        NO → REST GET + Redis Cache si es costosa
        
  NO → ¿Puede haber múltiples consumidores del resultado?
        SÍ → Kafka Event (Publish/Subscribe)
        NO → ¿El receptor es otro microservicio interno?
              SÍ → @Async + CompletableFuture (mismo sistema)
              NO → Kafka o AWS SQS (entre sistemas)
```

### 10.3 Árbol de Decisión — Qué Base de Datos Usar

```
¿El dato es transaccional y requiere ACID fuerte?
  SÍ → PostgreSQL / Aurora PostgreSQL
       (reemplaza DB2 z/OS y VSAM KSDS transaccional)
  NO → ¿Es un dato de alta lectura / baja escritura (catálogos, tasas)?
        SÍ → Redis (caché) + PostgreSQL (source of truth)
        NO → ¿Es un log inmutable / event stream?
              SÍ → Kafka (events) + PostgreSQL/S3 (proyecciones)
              NO → ¿Es un dato de alta cardinalidad con acceso por clave?
                    SÍ → DynamoDB / Redis (reemplaza VSAM KSDS de solo lectura)
                    NO → PostgreSQL por defecto
```

---

## APÉNDICE — Señales de Riesgo por Fase

### Fase 0 — Discovery
- `[CRÍTICO]` Si el análisis de dependencias revela que >30% de los programas se llaman mutuamente sin jerarquía clara → el sistema tiene acoplamiento circular severo; duplicar el esfuerzo de REFACTOR antes de migrar.
- `[RIESGO]` Si hay programas sin CALL entrante (dead code candidates) pero están en el scheduler TWS → verificar que no sean jobs programados directamente sin dependencia de CALL.
- `[CRÍTICO]` Si los copybooks tienen >50 años de modificaciones y no hay copybook de "versión actual" documentada → hacer arqueología de versiones antes de definir el modelo de datos destino.

### Fase 1 — Foundation
- `[CRÍTICO]` Si el API Gateway no está instalado antes de migrar el primer sistema → el Strangler Fig es incompleto; cada migración requerirá cambios en los clientes.
- `[RIESGO]` Si el environment de staging no es réplica fiel de producción (datos, volúmenes, configuración de red) → los performance tests no son válidos.

### Fase 2–N — Migration Waves
- `[CRÍTICO]` Si la divergencia en el parallel run es > 0.01% → no hacer cutover hasta investigar y corregir la causa raíz.
- `[RIESGO]` Si el equipo saltea el shadow mode por "falta de tiempo" → el riesgo de corrupción de datos post-cutover es inaceptable para un banco Tier-1.
- `[ANTIPATRÓN]` Si en cualquier sprint se habla de "ajustar los números" en la reconciliación → señal de que la lógica de negocio en Java es incorrecta; detener el wave hasta corregir.

### Fase Final — Decommission
- `[REGULATORIO]` Antes de descomisionar cualquier sistema de registro bancario, verificar con Compliance que los logs y datos históricos se archivan correctamente por el período requerido por CNBV (mínimo 5 años para registros transaccionales, 10 años para algunos tipos).
- `[CRÍTICO]` No liberar las licencias mainframe hasta haber completado al menos 1 ciclo de cierre anual completo en el sistema nuevo. Los errores contables de cierre de año son los más caros de corregir.

---

*Documento de referencia técnica — Proyecto Gamma · v1.0 · 2026-07-08*  
*SME Mainframe Migration & Modernization + Specialist Architecture Patterns — Accenture México*  
*Clasificación: Uso interno — Accenture + Cliente BBVA (Proyecto Gamma)*