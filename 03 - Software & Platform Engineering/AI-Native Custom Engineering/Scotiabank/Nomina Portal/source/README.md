# Source — Portal Empresas Nómina · Scotiabank México
> SPE-ANCE-001 · Código fuente del portal por componente

## Estructura

| Carpeta | Componente | ID | Tecnología |
|---------|-----------|-----|-----------|
| `knowledge-base/` | Documentación base del proyecto | — | Contexto · specs · contratos iniciales · dominio |
| `frontend/` | Portal SPA | SPE-ANCE-001 | Angular 20 · TypeScript |
| `nomina-api/` | Nómina API Backend | SPE-ANCE-002 | Java 21 · Spring Boot 3.3 |
| `core-banking-adapter/` | Core Banking Adapter | SPE-ANCE-003 | Java 21 · Spring Boot 3.3 |
| `spei-adapter/` | SPEI Adapter | SPE-ANCE-006 | Java 21 · Spring Boot 3.3 |
| `database/` | DB Schema + Migrations | SPE-ANCE-005 | MS SQL Server 2022 · Flyway |
| `db-init/` | Init de BD para el mock | — | Crea la BD `nomina` antes de Flyway |

## Correr el mock end-to-end

`docker-compose.yml` orquesta los 5 módulos (7 servicios: SQL Server + 3 Java + frontend + init + flyway). Guía completa en [`README-run.md`](README-run.md):

```bash
cd source && cp .env.example .env && docker compose up --build
```

Frontend en http://localhost:4200 · API en http://localhost:8080 (Swagger en `/swagger-ui.html`).

## Carpeta `knowledge-base/`

Contiene la documentación base que alimenta al swarm de Digital Twins durante DISCOVER y BUILD:
- Contratos OpenAPI iniciales
- Contexto de dominio (reglas de negocio Scotiabank México, capacidades BIAN relevantes)
- Mocks y ejemplos de payloads
- Diagramas de referencia
- Layouts de nómina (CNBV, SUA, IMSS)

> Los DTs leen `knowledge-base/` durante DISCOVER para construir contexto antes de producir código.
