# Informix - Scope del Vocabulario (10 tipos)

> **Corpus:** 0 SPs analizados  
> **Identificadores:** AIN=0  AOUT=0  BDR=0  BDW=0  LOC=0  LC=0  CUR=0  EXC=0

## Distribucion por tipo de scope

| Tipo | N | Descripcion |
|------|--:|-------------|
| — (sin senal) | 690 | No aparece en ningun SP del corpus |

---

## Uso en la arquitectura target

| Scope | Implicacion en el microservicio target |
|-------|----------------------------------------|
| PERSISTE-BD    | El bounded context que escribe este dato es el OWNER. Va en el esquema del microservicio. |
| LECTURA-BD     | El microservicio lee datos de otro BC. Candidato a query via API del BC owner, no schema propio. |
| INTERFAZ-IN    | Entra en el request DTO. Debe tener un nombre canonico en el target (target_term). |
| INTERFAZ-OUT   | Sale en el response DTO. Idem — nombre canonico requerido. |
| BATCH          | Proceso offline — candidato a job separado (Lambda / Cloud Run Job) con su propio schema. |
| CURSOR         | Implementacion — no necesita superficie en el API contract. |
| EFIMERA-CALCULO| Regla de negocio interna. Preservar la formula (golden master). No en el contrato. |
| EFIMERA        | Detalle de implementacion — puede reescribirse libremente en el target. |
| EXCEPCION      | Error model del microservicio. Debe mapearse a HTTP status + ProblemDetail RFC 9457. |
| MIXTO          | Analizar por contexto de SP. Posible necesidad de desambiguacion en el modelo de dominio. |

*Generado por extract-dataflow.py v2 - 10 tipos de scope*