# INC-20260424-008 — ACEPTPORTA: Falla de Autenticación SFTP · Portabilidad Nómina

**ID:** INC-20260424-008  
**Fecha captura:** 2026-04-24  
**Portal:** [inc-008-d02-aceptporta.html](../../portal/incidents/inc-008-d02-aceptporta.html)  
**Hora de actividad:** 06:00–13:00 CST (ventana completa de operación del batch)  
**Sistemas afectados:** ACEPTPORTA → ESB → `bdinteg` (sp_inserta_reg_expediente_dig_img, sp_consulta_reg_contr_evid_notif_porta_x_estatus)  
**Severidad:** N2 — servicio de portabilidad de nómina prácticamente detenido  
**Fuentes analizadas:** `errores_bus_20260424_*.txt` (24 archivos, 06:00–13:00 CST) · risk register P655-R007  
**Estado:** DEFECTO ACTIVO EN PRODUCCIÓN — credenciales SFTP inválidas o expiradas  
**Runbook origen:** INC-D02-05 en `knowledge-base/D02-bdinteg/21-observability-runbook.md`

---

## 1. Síntesis del incidente

El 24 de abril de 2026, el sistema `ACEPTPORTA` falló **3,244 veces** al intentar autenticarse contra el servidor SFTP `sysportabnominaapp` (IP: 10.28.217.45), durante toda la ventana de operación de 06:00 a 13:00 CST. El código de error ESB `3381` (`password authentication credentials invalid`) fue el único tipo de falla — 100% de los errores del sistema tienen este código.

El servicio afectado es `PrestamoNominaExpedienteDigital`, que orquesta la carga de imágenes de expedientes digitales en el proceso de portabilidad de nómina CNBV. Al fallar el SFTP, el SP `sp_inserta_reg_expediente_dig_img` nunca se invoca: **3,073 expedientes digitales de portabilidad quedan sin imagen por día**. El flujo de notificación posterior (`sp_consulta_reg_contr_evid_notif_porta_x_estatus`) recibe 1 llamada/día — prácticamente muerto.

No hay mecanismo de reintento ni alerta configurada sobre este error.

---

## 2. Evidencia cuantitativa de los logs 2026-04-24

### 2.1 errores_bus — distribución horaria

| Hora CST | Errores ACEPTPORTA (código 3381) |
|----------|----------------------------------|
| 06:00 | 1 |
| 07:00 | 508 |
| 08:00 | 532 |
| 09:00 | 467 |
| 10:00 | 623 |
| 11:00 | 284 |
| 12:00 | 535 |
| 13:00 | 294 |
| **Total** | **3,244** |

El pico de las 10:00 CST (623 errores) y las 08:00 (532) coincide con el volumen de portabilidades que se procesan en la mañana bancaria. La actividad se detiene completamente después de las 13:00 — señal de que el batch concluye su ventana operativa.

### 2.2 Firma del error en log

```xml
<sistemaOrigen>ACEPTPORTA</sistemaOrigen>
<referencia>postActualizaImagen_20260424_100001</referencia>
<servicio>PrestamoNominaExpedienteDigital</servicio>
<trama>postActualizaImagen (Implementation).lectura_Imagen_Portabilidad ||
  gen.imagenes_expediente_digital_portabilidad_nomina_api ||
  10.28.217.45 || sysportabnominaapp ||
  password authentication credentials invalid || SFTP</trama>
<estatus>error</estatus>
<codigo>3381</codigo>
```

La descripción es idéntica en los 3,244 registros — no hay variación en mensaje de error. Confirma causa única: credenciales del keystore ESB inválidas para el host `10.28.217.45`.

### 2.3 SPs impactados (desde runbook y brain.db)

| SP | Llamadas/día esperadas | Estado en 2026-04-24 |
|----|------------------------|----------------------|
| `sp_inserta_reg_expediente_dig_img` | ~3,073 | 0 invocaciones (SFTP falla antes) |
| `sp_consulta_reg_contr_evid_notif_porta_x_estatus` | ~3,073 | 1 invocación (flujo muerto) |

---

## 3. Causa raíz confirmada

Las credenciales del usuario `sysportabnominaapp` en el keystore del ESB están inválidas o expiradas. El error 3381 es inequívoco: `password authentication credentials invalid`. No hay evidencia de degradación del servidor SFTP (el servidor responde pero rechaza las credenciales), ni de problema de red (el error es autenticación, no conectividad).

**Cadena causal:**
```
1. Batch ACEPTPORTA inicia a las 06:00 CST
2. Para cada expediente: ESB intenta autenticación SFTP contra 10.28.217.45
3. Keystore ESB tiene credencial inválida/expirada para sysportabnominaapp
4. Autenticación rechazada → error 3381 en cada intento
5. sp_inserta_reg_expediente_dig_img no se invoca → expediente sin imagen
6. Flujo de notificación de portabilidad no completa → CNBV incompleto
7. Sin alerta configurada → el incidente pasa desapercibido hasta análisis de logs
```

---

## 4. Defectos identificados

| ID | Componente | Descripción |
|----|-----------|-------------|
| P655-R007-D1 | ESB keystore | Credenciales `sysportabnominaapp` inválidas/expiradas — raíz directa |
| P655-R007-D2 | ACEPTPORTA | Sin mecanismo de reintento ni circuit breaker para fallas SFTP |
| P655-R007-D3 | Monitoreo | Sin alerta configurada sobre código 3381 — incidente pasa invisible |
| P655-R007-D4 | Arquitectura | Gestión de credenciales SFTP en keystore estático del ESB — no rotable sin redeploy |

---

## 5. Impacto regulatorio

El proceso de portabilidad de nómina está regulado por CNBV. Con 3,073 expedientes sin imagen de portabilidad por día durante el período de captura, existe riesgo de incumplimiento del proceso de portabilidad establecido por CNBV. El flujo de notificación al cliente tampoco completa.

---

## 6. Patrones de riesgo para la migración

### Patrón 1 — Credenciales en keystore estático ESB
En el target (MSK/Lambda), la autenticación SFTP debe usar AWS Secrets Manager con rotación automática. El patrón de keystore estático que requiere redeploy para cambiar credenciales no puede replicarse en el target cloud.

### Patrón 2 — Batch sin observabilidad de resultado
El batch ACEPTPORTA opera a ciegas: no hay alarma sobre el volumen de expedientes procesados vs. esperados. En el target, implementar métrica `portabilidad.expedientes.procesados.ratio` con alarma si baja de 95%.

### Patrón 3 — Flujo CNBV sin validación de integridad
El proceso de portabilidad de nómina no tiene una validación al final del día de cuántos expedientes completaron el ciclo completo. En el target, implementar un job de reconciliación diario.

---

## 7. Acciones correctivas

**Inmediato (producción actual Informix/ESB):**
1. Rotar credenciales de `sysportabnominaapp` y actualizar el keystore del ESB.
2. Verificar cuántos días lleva activo el defecto — contar retrospectivamente los registros perdidos.
3. Configurar alerta sobre error 3381 en `errores_bus_*.txt` → threshold: > 10 eventos en 5 min.

**Pre-cutover (target Aurora PostgreSQL + MSK/Lambda):**
1. Migrar gestión de credenciales SFTP a AWS Secrets Manager con rotación automática.
2. Implementar reintento con backoff (máx. 3 intentos) en el Lambda que reemplaza el batch ACEPTPORTA.
3. Agregar métricas de volumen procesado y alarma de reconciliación diaria.
4. Documentar código 3381 en `knowledge-base/D02-bdinteg/06-exceptions.md`.

---

*Fuentes: `source/logs/2026-04-24/errores_bus_*.txt` (24 archivos) · risk register `migration-risk-register.md` P655-R007 · runbook INC-D02-05.*  
*Creado: 2026-08-06 | Informix Gemelo Cognitivo — DISCOVER Etapa 1*
