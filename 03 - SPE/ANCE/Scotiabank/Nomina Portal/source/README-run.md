# Cómo correr el mock end-to-end

Orquestación del Portal Empresas Nómina (Scotiabank México) con Docker Compose:
SQL Server 2022 + 3 servicios Java 21 + frontend Angular 20. Todo mock.

## Requisitos

- Docker Desktop (o Docker Engine + Compose v2)
- ~6 GB de RAM libres (SQL Server pide memoria)
- Puertos libres: 1433, 4200, 8080, 8081, 8082

No necesitas JDK, Maven ni Node instalados en el host: los builds ocurren dentro de las imágenes.

## Arranque

```bash
cd source
cp .env.example .env          # ajusta MSSQL_SA_PASSWORD y AUTH_JWT_SECRET si quieres
docker compose up --build
```

Orden de arranque (gestionado por `depends_on` + healthchecks):

```
sqlserver (healthy)
  └─ db-init            → crea la BD 'nomina'
       └─ flyway        → V001 schema · V002 índices · V003 seed mock · V004 cifrado (doc)
            └─ nomina-api (espera flyway completo + adapters arriba)
core-banking-adapter ─┐
spei-adapter ─────────┴─ arriba antes de nomina-api
frontend               → Nginx sirve la SPA y proxya /api → nomina-api
```

## URLs

| Servicio | URL |
|----------|-----|
| Frontend (portal) | http://localhost:4200 |
| Nómina API | http://localhost:8080 |
| Swagger UI (contrato ejecutable) | http://localhost:8080/swagger-ui.html |
| Core Banking Adapter | http://localhost:8081/actuator/health |
| SPEI Adapter | http://localhost:8082/actuator/health |
| SQL Server | localhost:1433 (`sa` / `MSSQL_SA_PASSWORD`) |

## Usuarios de prueba (seed V003)

Los 4 roles, password `Demo1234!`, código 2FA mock `483920`:

| Rol | Email (ver seed V003) |
|-----|-----------------------|
| ADMIN_EMPRESA | administrador de la empresa demo |
| OPERADOR_NOMINA | operador de nómina |
| AUDITOR | auditor (solo lectura) |
| ADMIN_SCO | back-office Scotiabank |

> Consulta los emails exactos en `database/src/main/resources/db/migration/V003__seed_mock.sql`.

## Probar la ruta crítica

1. Login en el frontend con OPERADOR_NOMINA → 2FA `483920`.
2. Alta de empleado (valida RFC/CURP en vivo).
3. Crear nómina → cargar layout → validar → dispersar (2FA).
4. **Caso de rechazo SPEI (TC-DISP-012)**: una CLABE destino terminada en `00` es rechazada por el SPEI Adapter con código Banxico `07`; el resto se confirma con clave de rastreo de 18 dígitos.

## Comandos útiles

```bash
docker compose logs -f nomina-api        # logs de la API
docker compose down                      # detener
docker compose down -v                   # detener + borrar datos SQL (reinicia el seed)
docker compose up --build nomina-api     # rebuild de un solo servicio
```

## Notas de mock (no producción)

- `nomina-api` conecta a SQL Server como `sa` — **solo mock**; en prod usa un usuario de app con permisos mínimos.
- Flyway lo corre un servicio dedicado; `nomina-api` arranca con `SPRING_FLYWAY_ENABLED=false` y solo valida el schema (JPA `validate`).
- El seed `V003` (datos ficticios) se aplica en este entorno; en QA/STG/PROD debe excluirse (ver `database/README.md`).
- Auth es IAM propio (`ADR-ANCE-004`); en prod migra a SSO/OIDC del portal existente (`ADR-ANCE-007`).
- Los adaptadores Core Banking y SPEI son stubs deterministas (`ADR-ANCE-001` / `ADR-ANCE-005`).
