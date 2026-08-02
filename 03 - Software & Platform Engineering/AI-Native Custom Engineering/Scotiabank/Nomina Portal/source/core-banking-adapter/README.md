# Core Banking Adapter · SPE-ANCE-003

Anti-Corruption Layer entre el Portal Nómina y el core bancario de Scotiabank México.

## Estado

**Stub determinista para el mock.** En producción este módulo se reemplaza por la
integración real con el core bancario (`ADR-ANCE-001` · `[DATO-REQUERIDO]`),
preservando el contrato REST que consume `nomina-api`.

## Contrato REST (consumido por nomina-api · `CoreBankingRestClient`)

| Método | Ruta | Request | Response |
|--------|------|---------|----------|
| POST | `/core/cuentas-nomina` | `{idEmpresa, idEmpleado, rfc}` | `{numeroCuenta, clabe}` |
| GET | `/core/cuentas/{clabe}/saldo` | — | `{disponible}` |
| POST | `/core/cargos` | `{clabeOrigen, monto, referencia}` | `{aplicado, referencia}` |

## Comportamiento del stub

- `consultarSaldo`: devuelve un saldo fijo alto (`corebanking.stub.saldo-disponible`) — en el mock nunca faltan fondos, salvo que se reconfigure.
- `abrirCuentaNomina`: genera CLABE sintética de 18 dígitos + número de cuenta ficticio.
- `instruirCargo`: siempre aplicado; devuelve referencia de core sintética.

## Correr en modo mock

```bash
mvn spring-boot:run
```

Levanta en `http://localhost:8081`. `nomina-api` lo consume vía `integration.core-banking.base-url`.

## Seguridad

Nunca loguea CLABE ni montos en claro. Los datos del mock son sintéticos.
