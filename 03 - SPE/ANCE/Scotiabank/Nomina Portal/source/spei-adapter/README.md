# SPEI Adapter · SPE-ANCE-006

Anti-Corruption Layer entre el Portal Nómina y SPEI/Banxico.

## Estado

**Stub determinista para el mock.** En producción se reemplaza por el gateway SPEI
real (directo Banxico o intermediario interno Scotiabank · `ADR-ANCE-005`),
preservando el contrato REST que consume `nomina-api`.

## Contrato REST (consumido por nomina-api · `SpeiRestClient`)

| Método | Ruta | Request | Response |
|--------|------|---------|----------|
| POST | `/spei/pagos` | `{clabeDestino, importe, referencia}` | `{confirmado, claveRastreo, codigoRechazoBanxico, mensaje}` |

## Comportamiento del stub

- CLABE destino que termina en `00` → **rechazo** con código Banxico simulado (`07`). Materializa **TC-DISP-012** (dispersión rechazada por SPEI).
- Cualquier otra CLABE → **confirmación** con clave de rastreo de 18 dígitos.

Se invoca una vez por renglón de dispersión; el fan-out corre sobre Virtual Threads.

## Correr en modo mock

```bash
mvn spring-boot:run
```

Levanta en `http://localhost:8082`. `nomina-api` lo consume vía `integration.spei.base-url`.

## Seguridad

Nunca loguea CLABE destino ni importe en claro. Datos del mock sintéticos.
