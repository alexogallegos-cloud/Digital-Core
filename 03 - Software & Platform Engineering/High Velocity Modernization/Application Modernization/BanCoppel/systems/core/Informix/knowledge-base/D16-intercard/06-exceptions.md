# D16 · Intercard (Tarjetas) — Excepciones y Códigos de Error

> **Componente:** Informix · SPE-AM-001
> **Base de datos:** `intercard`
> **Última actualización:** 2026-08-03

---

## Códigos de retorno identificados (análisis estático brain.db)

| Código | SP | Descripción inferida |
|--------|----|----------------------|
| `00011` | `sp_calcula_caratulaproducto_pba` | Error en cálculo de carátula de producto — paso 1 |
| `00012` | `sp_calcula_caratulaproducto_pba` | Error en cálculo de carátula de producto — paso 2 |
| `00013` | `sp_calcula_caratulaproducto_pba` | Error en cálculo de carátula de producto — paso 3 |
| `0000` | `sp_calcula_tarjetasbanda` | Éxito — cálculo de tarjetas de banda completado |
| — | `sp_cancelacion_tarjeta` | `[SME-PENDING]` — códigos de retorno no documentados en brain.db |
| — | `sp_activatarjeta_iccat` | `[SME-PENDING]` — errores ICCAT/BPI no capturados en análisis estático |
| — | `sp_contacto_vencimiento_credito` | `[SME-PENDING]` — 49 reglas con lógica de error pendiente de mapeo |
| — | `sp_contacto_vencimiento_debito` | `[SME-PENDING]` — 46 reglas con lógica de error pendiente de mapeo |

---

## Riesgo ESB — códigos no documentados

D16 comparte la dependencia del ESB con D08 (SPEI), D13 (TEF) y D14 (BEI). Los 5 códigos de error ESB sin documentar aplican también a integraciones de `intercard` con sistemas de notificación externos:

| Código ESB | Descripción | Frecuencia estimada (cross-domain) |
|------------|-------------|:---------------------------------:|
| `4394` | IBM MQ MbUserException | Alta |
| `3743` | SOAP Timeout | Media |
| `3701` | JNI/Axis2 error | Media |
| `3165` | SSL socket error | Media |
| `6233` | Sin descripción | Baja |

> Ver `knowledge-base/D08-bdispei/06-exceptions.md` para el detalle completo del riesgo P655-R005 sobre estos códigos ESB.

---

## Excepciones ICCAT conocidas

`[SME-PENDING]` El canal ICCAT/BPI tiene su propio protocolo de errores. Los SPs `sp_activatarjeta_iccat`, `sp_consultartarjetas_debcred_can_iccat` y `sp_limpiatarjeta_bloqueada_iccat` interactúan con este canal pero sus códigos de error ICCAT no están documentados en el análisis estático actual.

Pendiente de sesión con el equipo de canales BPI para obtener:
- Catálogo de códigos de error ICCAT
- Timeouts configurados
- Protocolo de reintentos

---

## Manejo de errores en batch

Los SPs de batch (`sp_carga_ctes_enrola`, `sp_contacto_vencimiento_credito`, `sp_contacto_vencimiento_debito`) probablemente implementan el patrón `ON EXCEPTION` de Informix SPL. `[SME-PENDING]` auditar si aplica el mismo anti-patrón CWE-390 identificado en D11 (excepción sin bitácora).

> **Ref:** riesgo P655-R010 (D11 Cobranza CV — `ON EXCEPTION` sin bitácora: CWE-390).

---
*Generado: 2026-08-03 · fuente: brain.db analysis · `[SME-PENDING]` = requiere análisis del código fuente*
