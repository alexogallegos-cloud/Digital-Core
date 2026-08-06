# D14 · Banca Electrónica Institucional (BEI) — Contrato de API

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Core Banking Transformation (diseño del contrato API, ACL con sistemas legados)
- Software Engineering SME (implementación OpenAPI 3.1)
- Industry Banking (validación de endpoints contra modelo BIAN)
- Cybersecurity (autenticación mTLS empresa, JWT, PII en tránsito)

> **Principio Contract-First:** el contrato OpenAPI 3.1 debe escribirse ANTES del primer endpoint productivo. Este documento es el borrador de contrato — el contrato definitivo vive en el repositorio Git del `BEIService`.
---

## Info general del API

```yaml
openapi: "3.1.0"
info:
  title: BEI Service API — Banca Electrónica Institucional
  description: |
    API de Banca Electrónica Institucional (BEI) para dispersiones masivas,
    nóminas empresariales y gestión de convenios. Versión 1.0.0 corresponde
    a la equivalencia funcional con el dominio bdibei de IBM Informix.
  version: "1.0.0"
  contact:
    name: BCOPCore Team — SPE-AM-001
servers:
  - url: https://api-internal.bancoppel.com/bei/v1
    description: Producción
  - url: https://api-stg.bancoppel.com/bei/v1
    description: Staging
security:
  - BearerAuth: []
  - mTLSEmpresa: []
```

---

## Endpoints principales

### Módulo de Convenios Empresa

```yaml
paths:
  /convenios:
    post:
      operationId: crearConvenio
      summary: Alta de convenio empresa BEI
      tags: [Convenios]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ConvenioRequest'
      responses:
        '201':
          description: Convenio creado exitosamente
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ConvenioResponse'
        '400':
          description: RFC inválido o datos de empresa incorrectos
        '409':
          description: Convenio ya existe para esta empresa
        '422':
          description: Límite de crédito de empresa no suficiente

  /convenios/{numConvenio}:
    get:
      operationId: consultarConvenio
      summary: Consulta estado y parámetros del convenio empresa
      parameters:
        - name: numConvenio
          in: path
          required: true
          schema:
            type: string
            maxLength: 10
      responses:
        '200':
          description: Datos del convenio
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ConvenioDetalle'
        '404':
          description: Convenio no encontrado

  /convenios/{numConvenio}/bloquear:
    put:
      operationId: bloquearConvenio
      summary: Bloquear o desbloquear convenio empresa
      tags: [Convenios]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                accion:
                  type: string
                  enum: [BLOQUEAR, DESBLOQUEAR]
                motivo:
                  type: string
```

### Módulo de Dispersiones

```yaml
  /dispersiones:
    post:
      operationId: crearDispersion
      summary: Crear solicitud de dispersión masiva de pagos
      tags: [Dispersiones]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/DispersionRequest'
      responses:
        '202':
          description: Dispersión aceptada y en procesamiento
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/DispersionAceptada'
        '400':
          description: Formato de solicitud inválido (CLABE, RFC, montos)
        '403':
          description: Convenio inactivo o bloqueado
        '422':
          description: Monto excede límite del convenio
        '429':
          description: Fuera de horario de dispersión del convenio

  /dispersiones/{folio}:
    get:
      operationId: consultarDispersion
      summary: Consultar estado de una dispersión
      parameters:
        - name: folio
          in: path
          required: true
          schema:
            type: integer
            format: int64
      responses:
        '200':
          description: Estado de la dispersión
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/DispersionEstado'
        '404':
          description: Dispersión no encontrada

  /dispersiones/{folio}/reverso:
    post:
      operationId: reversarDispersion
      summary: Reverso de dispersión (solo mismo día hábil)
      responses:
        '200':
          description: Reverso exitoso
        '422':
          description: Dispersión no reversable (fecha distinta o ya procesada)
```

### Módulo de Nómina (Batch)

```yaml
  /nomina/cargar:
    post:
      operationId: cargarArchivonomina
      summary: Cargar archivo de nómina para procesamiento batch
      tags: [Nomina]
      requestBody:
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                numConvenio:
                  type: string
                archivo:
                  type: string
                  format: binary
                fechaDispersion:
                  type: string
                  format: date
      responses:
        '202':
          description: Archivo aceptado — se procesará en el batch programado
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/NominaAceptada'
        '409':
          description: Archivo duplicado — folio ya procesado para este convenio y fecha

  /nomina/{idNomina}/estado:
    get:
      operationId: consultarEstadoNomina
      summary: Estado de procesamiento de nómina batch
      responses:
        '200':
          description: Estado de procesamiento con detalle por beneficiario
```

### Módulo de Beneficiarios

```yaml
  /convenios/{numConvenio}/beneficiarios:
    post:
      operationId: altaBeneficiario
      summary: Alta de beneficiario en nómina
      tags: [Beneficiarios]
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/BeneficiarioRequest'
      responses:
        '201':
          description: Beneficiario dado de alta
        '400':
          description: CLABE inválida o datos incorrectos
    
    get:
      operationId: listarBeneficiarios
      summary: Listar beneficiarios del convenio (paginado)
      parameters:
        - name: page
          in: query
          schema:
            type: integer
        - name: size
          in: query
          schema:
            type: integer
            maximum: 100
```

### Módulo de Autenticación OTP Empresa

```yaml
  /auth/otp/generar:
    post:
      operationId: generarOTP
      summary: Generar código OTP para autenticación de empresa (reemplaza getrandomcode)
      tags: [Autenticacion]
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                cveEmpresa:
                  type: string
      responses:
        '200':
          description: OTP generado (válido 5 minutos)
          content:
            application/json:
              schema:
                type: object
                properties:
                  otpHash:
                    type: string
                    description: Hash del OTP (nunca el OTP en claro por API)
                  expiraEn:
                    type: integer
                    description: Segundos hasta expiración
```

---

## Schemas principales

```yaml
components:
  schemas:
    ConvenioRequest:
      type: object
      required: [cveEmpresa, rfcEmpresa, razonSocial, montoMaxDispersion, cuentaCargo]
      properties:
        cveEmpresa:
          type: string
          maxLength: 12
        rfcEmpresa:
          type: string
          pattern: '^[A-Z]{3,4}[0-9]{6}[A-Z0-9]{3}$'
          description: RFC persona moral — 12 caracteres
        razonSocial:
          type: string
          maxLength: 200
        montoMaxDispersion:
          type: number
          format: decimal
          description: Límite por dispersión individual (NUMERIC 18,2)
        montoMaxMensual:
          type: number
          format: decimal
        cuentaCargo:
          type: string
          pattern: '^[0-9]{18}$'
          description: CLABE 18 dígitos de la cuenta origen
        horarioMaxDispersion:
          type: string
          format: time
          description: Hora límite para dispersiones (HH:MM)

    BeneficiarioRequest:
      type: object
      required: [nombre, numCuentaDestino, bancoDest, montoDispersion]
      properties:
        curp:
          type: string
          pattern: '^[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[0-9A-Z][0-9]$'
          description: CURP del empleado — dato PII sensible
        nombre:
          type: string
          maxLength: 120
          description: Nombre completo — dato PII
        numCuentaDestino:
          type: string
          pattern: '^[0-9]{18}$'
          description: CLABE 18 dígitos — validar dígito verificador
        bancoDestino:
          type: string
          maxLength: 3
          description: Clave banco receptor del catálogo SPEI
        montoDispersion:
          type: number
          format: decimal
          multipleOf: 0.01
          description: Monto a dispersar — NUMERIC(18,2)

    DispersionRequest:
      type: object
      required: [numConvenio, tipoDispersion, beneficiarios]
      properties:
        numConvenio:
          type: string
        tipoDispersion:
          type: string
          enum: [NM, PR, SV]
          description: NM=Nómina · PR=Proveedor · SV=Servicio
        beneficiarios:
          type: array
          items:
            $ref: '#/components/schemas/BeneficiarioDispersion'
          maxItems: 10000

  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    mTLSEmpresa:
      type: mutualTLS
      description: Certificado cliente de la empresa para autenticación mTLS
```

---

## Contratos con dominios dependientes (Consumer-Driven)

BEI actúa como **consumer** de los siguientes servicios. Los contratos se gestionan con Pact:

| Servicio provider | Operación que BEI consume | Pact consumer test |
|------------------|--------------------------|-------------------|
| `SPEIService` (D08) | `POST /spei/transferencias` — envío instrucción SPEI | `BEIDispersionService-SPEIService.pact.json` |
| `CreditoEmpresaService` (D03) | `GET /credito/empresas/{cve}/limite` — verificar límite | `BEIConvenioService-CreditoService.pact.json` |
| `CuentasService` (D05) | `POST /cuentas/{cuenta}/cargos` — debitar cuenta origen | `BEIDispersionService-CuentasService.pact.json` |
| `ContabilidadService` (D12) | `POST /contabilidad/asientos` — registro contable | `BEIDispersionService-ContabilidadService.pact.json` |

---
*Generado por: Core Banking Transformation + Software Engineering SME · 2026-08-03 · Borrador de contrato — requiere revisión y aprobación antes de BUILD*
