# Nómina DB — Portal Empresas Nómina · Scotiabank México

> Componente `SPE-ANCE-005` · Motor **Microsoft SQL Server 2022** (no negociable) · Migraciones **Flyway**
> Owner: `dt-dba` · Spec de referencia: `../../spec-nomina-portal.md` (§5 modelo de dominio · §6 máquinas de estado · §11 PII/PCI) · Contrato: `../../api/openapi-nomina-portal.yaml`

Esquema del portal de nómina bancaria: empresas, usuarios, empleados, centros de trabajo, nóminas, dispersiones SPEI, movimientos y CFDI. Todo el DDL es T-SQL válido para SQL Server 2022.

---

## Estructura

```
source/database/
├── flyway.conf                                  ← config Flyway CLI (mock local)
├── README.md                                    ← este archivo
└── src/main/resources/db/migration/             ← migraciones versionadas (classpath del backend)
    ├── V001__baseline_schema.sql                ← 11 tablas del spec §5 (tablas + FKs + CHECK enums + PII/PCI)
    ├── V002__indexes.sql                        ← índices (migración separada, no bloqueante · ONLINE=ON)
    ├── V003__seed_mock.sql                      ← datos SINTÉTICOS para el mock (NO cargar en PROD)
    └── V004__column_encryption.sql              ← estrategia Always Encrypted + TDE (documental · no-op en mock)
```

La ruta `src/main/resources/db/migration/` es la ubicación estándar que **Flyway autodescubre desde el classpath de Spring Boot** (`nomina-api`, `SPE-ANCE-002`). El mismo conjunto de migraciones sirve para el arranque embebido del backend y para el Flyway CLI standalone.

---

## Tablas (spec §5)

| # | Tabla (PascalCase) | PK | Relaciones |
|---|--------------------|----|------------|
| 1 | `Empresa` | `idEmpresa` | raíz tenant |
| 2 | `Usuario` | `idUsuario` | Empresa 1─N Usuario |
| 3 | `CentroTrabajo` | `idCentroTrabajo` | Empresa 1─N CentroTrabajo |
| 4 | `Empleado` | `idEmpleado` | Empresa 1─N · CentroTrabajo 1─N |
| 5 | `Nomina` | `idNomina` | Empresa 1─N Nomina |
| 6 | `DetalleNomina` | `idDetalle` | Nomina 1─N · Empleado 1─N |
| 7 | `Dispersion` | `idDispersion` | Nomina 1─1 Dispersion (UNIQUE en idNomina) |
| 8 | `MovimientoDispersion` | `idMovimiento` | Dispersion 1─N |
| 9 | `CFDI` | `idCFDI` | MovimientoDispersion 1─0..1 (UNIQUE en idMovimiento) · Empleado 1─N |
| 10 | `RegistroAuditoria` | `idRegistro` | Empresa 1─N · Usuario 1─N |
| 11 | `CargaMasiva` | `idCarga` | Empresa 1─N |

---

## Convenciones

- **Tablas** en `PascalCase` (mismo nombre que la entidad JPA del spec §5, package `mx.scotiabank.nomina`).
- **Columnas** en `camelCase`, idénticas a los atributos del spec §5 (SQL Server es case-insensitive por defecto; las entidades JPA mapean 1:1 sin naming-strategy adicional).
- **PK** = `UNIQUEIDENTIFIER` con `DEFAULT NEWID()`.
- **Dinero** = `DECIMAL(18,2)` — nunca `float`/`real`/`money`. Coherente con `BigDecimal` (Java) y `Money` string-decimal (OpenAPI).
- **Fechas de calendario** = `DATE` · **marcas de tiempo** = `DATETIME2(3)` en UTC (`SYSUTCDATETIME()`).
- **Estados (enums)** = `VARCHAR` + `CHECK` constraint que enumera exactamente los valores del enum del OpenAPI. Los CHECK están alineados 1:1 con `EstadoCuentaEmpleado`, `EstadoNomina`, `EstadoDispersion`, `EstadoMovimiento`, `estadoTimbrado`, roles, etc.
- **PII/PCI** marcados en línea en el DDL con `-- PII` / `-- PCI` según spec §11.
- **Índices** siempre en migración separada de las tablas (`V002`), con `ONLINE = ON` para no bloquear en despliegues con datos.

### Reglas Flyway (de `swarm/dt-dba.md`)

- Toda columna nueva es nullable o tiene `DEFAULT` (no bloquea deploys).
- Nunca `DROP TABLE` en migración — soft-delete primero (`estado = 'ELIMINADA'/'REVOCADO'`).
- Índices en migraciones separadas con `ONLINE = ON`.
- Migraciones inmutables una vez aplicadas (Flyway valida checksums); un cambio = una nueva `Vxxx`.

---

## Cómo aplicar las migraciones

### Opción A — Integrado en `nomina-api` (Spring Boot Flyway, recomendado)

El backend `SPE-ANCE-002` incluye `org.flywaydb:flyway-sqlserver`. Al arrancar, Flyway aplica automáticamente las migraciones del classpath (`classpath:db/migration`).

```yaml
# application.yml (nomina-api)
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    default-schema: dbo
    baseline-on-migrate: false
  datasource:
    url: jdbc:sqlserver://localhost:1433;databaseName=NominaPortal;encrypt=true;trustServerCertificate=true
    username: sa
    password: ${DB_PASSWORD}
```

> Nota: `V003__seed_mock.sql` es data de mock. En QA/STG/PROD excluir el seed (p.ej. `spring.flyway.locations=classpath:db/migration` sólo en perfil `local`, o mover el seed a un `flyway.locations` de perfil).

### Opción B — Flyway CLI (standalone)

```bash
# 1) Levantar SQL Server 2022 local (Docker)
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Local_Dev_Only_ChangeMe1" \
  -p 1433:1433 --name mssql-nomina -d mcr.microsoft.com/mssql/server:2022-latest

# 2) Crear la base (una vez)
docker exec -i mssql-nomina /opt/mssql-tools18/bin/sqlcmd -C -S localhost \
  -U sa -P 'Local_Dev_Only_ChangeMe1' -Q "CREATE DATABASE NominaPortal;"

# 3) Aplicar migraciones (desde source/database/)
flyway -configFiles=flyway.conf migrate

# Verificar estado
flyway -configFiles=flyway.conf info
```

`flyway.conf` ya apunta a `filesystem:src/main/resources/db/migration` y al schema `dbo`.

---

## Datos semilla (mock)

`V003__seed_mock.sql` carga datos **100% sintéticos** (anti-patrón usar RFC/CURP/CLABE reales en no-PROD):

- **1 empresa demo** (`RFC` persona moral sintético `NOM950101AB2`).
- **3 centros de trabajo** (CDMX, Monterrey, Guadalajara).
- **4 usuarios**, uno por rol (`ADMIN_EMPRESA`, `OPERADOR_NOMINA`, `AUDITOR`, `ADMIN_SCO`). Password demo compartido: **`Demo1234!`** (`passwordHash` = bcrypt cost 10, verificado).
- **10 empleados** cubriendo todos los estados del spec §6.1 (`NO_INICIADA`, `EN_PROCESO`, `DOCUMENTADA`, `FINALIZADA`, `VINCULADA`, `BLOQUEADA`, `ELIMINADA`).
- **1 nómina demo** en `BORRADOR`.

Credenciales de login del mock:

| Rol | email | password |
|-----|-------|----------|
| ADMIN_EMPRESA | `admin@empresa.mx` | `Demo1234!` |
| OPERADOR_NOMINA | `operador@empresa.mx` | `Demo1234!` |
| AUDITOR | `auditor@empresa.mx` | `Demo1234!` |
| ADMIN_SCO | `admin.sco@scotiabank-demo.mx` | `Demo1234!` |

---

## Seguridad de datos (PII/PCI · spec §11)

- **PCI**: `clabe`, `numeroCuenta`, `numeroTarjeta`, `clabeDestino` (Empleado/Empresa/DetalleNomina/MovimientoDispersion).
- **PII**: `rfc`, `curp`, `nombres/apellidos`, `ingresoMensualNeto`, `email`.
- `V004__column_encryption.sql` documenta la estrategia **Always Encrypted (columna) + TDE (base)**. En el mock es **no-op** (requiere CMK/CEK en Key Vault y sign-off de `dt-security-engineer`). El DDL real está comentado como plantilla de PROD.
- Enmascarado por rol (últimos 4/6) y exclusión de PII/PCI de logs se aplican en la capa de API, no en la DB.

---

## Multi-tenant (ADR-ANCE-003 · PENDIENTE)

Estrategia **provisional**: columna discriminadora `idEmpresa` en las tablas tenant-scoped de primer nivel (`Usuario`, `Empleado`, `CentroTrabajo`, `Nomina`, `RegistroAuditoria`, `CargaMasiva`). Las de segundo nivel (`DetalleNomina`, `Dispersion`, `MovimientoDispersion`, `CFDI`) se aíslan por su cadena de FKs hacia `Nomina → Empresa`.

La decisión final **schema-per-tenant vs shared-schema** queda abierta en **ADR-ANCE-003**. Migrar a schema-per-tenant sólo requeriría reubicar las tablas por schema de empresa sin cambiar el modelo relacional. Row-Level Security es una alternativa dentro del modelo shared-schema.

---

*Creado por `dt-dba` · SPE-ANCE-005 · SQL Server 2022 · Flyway · [STATE: BUILD]*
