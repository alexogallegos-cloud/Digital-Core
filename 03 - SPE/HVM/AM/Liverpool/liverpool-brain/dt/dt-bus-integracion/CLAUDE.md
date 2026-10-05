# Digital Twin — Bus de Integración (IBM IIB)
> `liverpool-brain/dt/dt-bus-integracion/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-02

## Propósito

Gemelo digital del bus corporativo de integración de Liverpool: IBM Integration Bus 10 como columna vertebral que conecta 15+ sistemas, más Tumbleweed (MFT) para intercambios de archivos y Apigee como API Gateway parcialmente desplegado.

Este DT es el **mapa de riesgo** del programa: toda migración de cualquier sistema tiene blast radius que pasa por IIB. Sin entender este bus, las estimaciones de esfuerzo y riesgo de cada 7R son incompletas. Es también el DT que revela las dependencias ocultas entre sistemas.

## Dominio Principal
R10 — Infraestructura y Plataforma

## Sistemas Involucrados

| Sistema | togaf_type | Rol |
|---------|-----------|-----|
| IBM IIB (Integration Bus 10) | integration | Bus corporativo central — orquestación síncrona y asíncrona |
| Tumbleweed (Broadcom MFT) | integration | Managed File Transfer — bancos, SAT, carriers, proveedores |
| Apigee (Google) | integration | API Gateway — deployment parcial (no todos los sistemas) |
| Control-D (BMC) | integration | Scheduler mainframe + output management (batch) |
| IBM IIB → todos los demás | — | IIB conecta: SAP ↔ OMS ↔ Mainframe ↔ ATG ↔ Siebel ↔ FICO ↔ CDP ↔ ... |

## Flujos Clave a Modelar

1. **SAP ↔ OMS**: sincronización de inventario, órdenes de entrega SAP EWM → Sterling OMS
2. **SAP ↔ Mainframe**: integración financiera ECC ↔ VPL Vision Plus / contabilidad LiverpoolCard
3. **ATG ↔ SAP**: precios, catálogo, stock disponible para venta en web
4. **Siebel CRM ↔ SAP**: datos de cliente, historial de compras
5. **FICO TRIAD ↔ Mainframe**: originación de crédito → apertura de cuenta VPL
6. **Tumbleweed ↔ Bancos/SAT**: domiciliaciones, SPEI, facturación electrónica
7. **IIB ↔ CDP-GCP**: eventos de cliente hacia Customer 360

## Señales Activas

- IIB conecta **15+ sistemas** — el bus más crítico del landscape sin excepción
- Apigee está **parcialmente desplegado** — no todos los sistemas están detrás de Apigee; hay endpoints directos
- Tumbleweed maneja integraciones regulatorias (SAT, bancos) — alta criticidad, baja tolerancia a fallas
- Control-D orquesta el batch del Mainframe — scheduler de VPL, SOMS, cierres nocturnos

## Preguntas Estratégicas que Responde

1. ¿Cuál es el blast radius real de migrar cada sistema dado su acoplamiento con IIB?
2. ¿Qué integraciones críticas no están detrás de Apigee y representan riesgo de modernización?
3. ¿Qué flows de IIB son candidatos a migrar a Apigee (estrategia API-first)?
4. ¿Qué intercambios de Tumbleweed tienen dependencia regulatoria (SAT, Banxico) que bloquea cambios?
5. ¿Cuál es la secuencia correcta de migraciones para no romper el bus?

## Estado

`[STATE: SCAFFOLD]` — estructura creada 2026-09-02.
Este DT es el **primer candidato a poblar** junto con `dt-liverpoolcard`: sin el mapa de IIB, el resto de los DTs no puede estimar blast radius.

## Fuentes de Datos Necesarias para Activar

- [ ] Inventario de flows IBM IIB (export del Integration Node — XML/BAR files)
- [ ] Configuración Tumbleweed — routes, partners, scheduling
- [ ] Mapeo Apigee: qué APIs están expuestas vs qué sigue en IIB directo
- [ ] Control-D job list (si disponible — complementa al Mainframe scheduler)
- [ ] Diagrama de interfaces actualizado del cliente (INTEG_HUBS del dashboard es el punto de partida)

## Dependencias Cross-DT

- `dt-liverpoolcard` → IIB conecta FICO TRIAD + Cyberfinancial + VPL con el resto; blast radius financiero pasa por aquí
- `dt-pedido-omnicanal` → IIB es el bus OMS ↔ EWM ↔ canales; deuda de OMS se amplifica si IIB está acoplado
- `dt-ecommerce-transicion` → la migración ATG → commercetools requiere reimaginar los flows IIB que alimentan el canal digital
- `dt-catalogo-producto` → sincronizaciones PIM → SAP → ATG pasan por IIB
- `dt-sap-doble-landscape` → los dos landscapes SAP (ECC LIV / S/4 SBB) tienen flows IIB distintos