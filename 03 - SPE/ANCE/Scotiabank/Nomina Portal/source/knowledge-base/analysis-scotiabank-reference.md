# Análisis de Referencia — Alcance Objetivo del Portal Empresa Scotiabank
> dt-product-owner · SPE-ANCE-001 · 2026-07-24
> Fuente: ND-Portal empresa.pdf + PortalEmpresa_Scotiabank_10072026_V6.pptx (documentos de referencia Scotiabank que definen el alcance objetivo)

---

## Resumen Ejecutivo

Los documentos de referencia de Scotiabank México definen un sistema B2B para que empresas gestionen la **apertura de cuentas bancarias de nómina para sus empleados** y el seguimiento de ese proceso: alta, validación, vinculación de tarjeta y estado del ciclo de vida de la cuenta.

**Contexto AS-IS**: hoy Scotiabank México ejecuta este proceso de forma **mayoritariamente manual**. El portal a construir es **funcionalidad nueva (greenfield)** que digitaliza ese proceso end-to-end. Estos documentos son el **alcance objetivo de referencia**, no un portal existente a reemplazar.

**Alcance ampliado en la nueva versión**: además del modelo de gestión de cuentas de empleados que definen los documentos, el portal integra la **dispersión real vía SPEI/CoDi** y el **CFDI de nómina** en un portal unificado.

---

## Módulos Identificados (alcance objetivo de referencia)

| # | Módulo | Sub-secciones | Descripción |
|---|--------|--------------|-------------|
| 1 | **Inicio** (Dashboard) | — | Estadísticas generales + acciones rápidas + gráfica reporte |
| 2 | **Empleados** | Carga individual · Carga masiva | Alta de empleados para apertura de cuenta nómina |
| 3 | **Centros de trabajo** | Directorio · Carga individual · Carga masiva · Recepción de tarjetas | Gestión de sucursales/puntos de entrega de tarjetas |
| 4 | **Estadísticas** | Bloqueadas · Finalizadas · En proceso · Documentadas · No iniciadas · Vinculadas | Seguimiento del estado de cuentas de empleados |
| 5 | **Registros** | Exitosos · Pendientes · Por corregir · Validar en sucursal · Eliminados · No iniciadas · Vinculadas | Historial de cargas de empleados por archivo |
| 6 | **Ayuda** | — | Soporte |

---

## Estados del Ciclo de Vida de Cuenta de Empleado

```
CARGA → No iniciada
          ↓
        En proceso
          ├── Documentación
          └── En Análisis
          ↓
        Documentada
          ├── Formato físico pendiente
          ├── Formato físico no recibido
          └── Bloqueada (en documentadas)
          ↓
        Finalizada  →  Vinculada (cuenta + tarjeta asignada)
          
        Bloqueada (estado final)
        Eliminada
```

---

## Campos del Formulario de Empleado (Carga Individual)

### Datos personales
| Campo | Tipo | Obligatorio |
|-------|------|-------------|
| Nombre(s) | Texto | Sí |
| Primer apellido | Texto | Sí |
| Segundo apellido | Texto | Sí |
| Género | Catálogo (MASCULINO/FEMENINO) | Sí |
| Nacionalidad | Catálogo | Sí |
| Estado civil | Catálogo | Sí |
| RFC | Alfanumérico 13 chars | Sí |
| CURP | Alfanumérico 18 chars | Sí |

### Datos laborales
| Campo | Tipo | Obligatorio |
|-------|------|-------------|
| Número de empleado | Alfanumérico | Sí |
| Fecha de ingreso | Fecha | Sí |
| Ingreso mensual neto | Monto | Sí |
| Número de sucursal | Numérico | Sí |
| ID Centro de trabajo | Numérico | Sí (si múltiples CTs) |

---

## Datos del Registro de Empleado (vistas de lista)

| Campo visible en listas | Notas |
|------------------------|-------|
| No. de solicitud | Generado por el banco |
| Nombre completo | |
| RFC | |
| No. de empleado | |
| Fecha de carga / bloqueo / vinculación | |
| No. de cuenta | Asignado tras apertura |
| Cuenta CLABE | 18 dígitos |
| No. de tarjeta | Últimos 4 dígitos (masked) |
| Centro de trabajo | |
| Estado de cuenta para depósito | DESBLOQUEADA / BLOQUEADA |
| Estado de cuenta para cargo | DESBLOQUEADA / BLOQUEADA |

---

## Dashboard — Métricas Mostradas

| Métrica | Descripción |
|---------|-------------|
| Por corregir | Cargas con errores de formato |
| Validar en sucursal | Empleados que requieren validación presencial |
| Exitosas | Cuentas abiertas exitosamente |
| Pendientes | En proceso |
| En proceso (cuentas) | Número de cuentas en flujo activo |
| Finalizadas (cuentas) | Cuentas completamente activas |
| Bloqueadas (cuentas) | Cuentas con bloqueo operativo |
| Gráfica de cargas recientes | Timeline de archivos cargados |

---

## Centros de Trabajo — Campos

### Formulario de alta
| Campo | Obligatorio |
|-------|-------------|
| Nombre del centro | Sí |
| Total de empleados | Sí |
| Sucursal banco asignada | Sí |
| Tarjetas asignadas al CT | Sí |
| Calle | Sí |
| Colonia | Sí |
| Código postal | Sí |
| No. Exterior | Sí |
| No. Interior | No |
| Delegación/Municipio | Sí |
| Estado | Sí |
| Instrucciones de entrega | No |
| Contacto 1 (nombre, email, lada, teléfono, área) | Sí |
| Contacto 2 | Sí |
| Contacto 3 | No |

### Recepción de tarjetas (remesas)
- Validar código de remesa (tipo "PAMPA")
- Ver últimas remesas: fecha entrega, categoría (ej. "3 - 100 Tarjetas"), estado
- Confirmar recepción con NIP dinámico de token

---

## Flujos de Autenticación Sensibles

Toda operación de escritura (carga de empleados, carga de centros, recepción de remesas) requiere:
- **NIP dinámico de token** (8 dígitos) — equivalente a OTP/TOTP

---

## Carga Masiva de Empleados

| Aspecto | Detalle |
|---------|---------|
| Formatos soportados | Excel (.xls) con MACROS o SIN MACROS · .txt |
| Plantillas | Descargables desde el portal |
| Opciones de asignación | Un solo centro de trabajo · Múltiples centros (ID CT obligatorio en layout) |
| Límite carga individual | 10 empleados por carga |
| Confirmación | Notificación cuando las cuentas sean validadas |

---

## Diferencias Clave a Considerar para la Nueva Versión

| Aspecto | Definido en documentos de referencia | A confirmar/definir para la construcción |
|---------|----------------------|----------------------|
| Foco principal | Apertura de cuentas nómina para empleados | Apertura de cuentas + **dispersión directa de nómina** |
| Tipo de producto | N4 Cuenta Digital Nómina · N2 Cuenta Smart | Producto Scotiabank México equivalente `[DATO-REQUERIDO]` |
| Distribución de tarjetas | Flujo físico de remesas a centros de trabajo | `[DATO-REQUERIDO: ¿Scotiabank México mantiene tarjetas físicas o migra a CLABE digital?]` |
| Autenticación | NIP dinámico de token hardware | `[DATO-REQUERIDO: ¿token hardware, OTP app, o factor propio Scotiabank México?]` |
| Formato de layout | Excel propio | `[DATO-REQUERIDO: layout — ¿SAT nómina v1.2, SUA, formato propio?]` |
| Validación en sucursal | Requiere presencia física en algunos casos | `[DATO-REQUERIDO: ¿flujo 100% digital o requiere sucursal?]` |
| Integración SPEI | No contemplada (sistema separado) | **Integrada en el portal** — BIAN 2.2.6 + 2.2.7 |
| CFDI de nómina | No contemplado | **En scope** — complemento nómina v1.2 SAT 4.0 |

---

## Pantallas Identificadas (Inventario Preliminar)

| ID Pantalla | Nombre | Sección |
|-------------|--------|---------|
| P-INI-01 | Dashboard principal | Inicio |
| P-EMP-01 | Listado de empleados cargados | Empleados |
| P-EMP-02 | Formulario carga individual — datos personales | Empleados |
| P-EMP-03 | Formulario carga individual — datos laborales | Empleados |
| P-EMP-04 | Tabla de empleados pendientes de cargar | Empleados |
| P-EMP-05 | Modal: NIP dinámico token | Empleados |
| P-EMP-06 | Modal: selección de centro de trabajo | Empleados |
| P-EMP-07 | Modal: alta en múltiples centros de trabajo | Empleados |
| P-EMP-08 | Carga masiva — paso 1 (selección tipo) | Empleados |
| P-EMP-09 | Carga masiva — paso 2 (upload archivo) | Empleados |
| P-EMP-10 | Carga masiva — modal múltiples CTs | Empleados |
| P-EMP-11 | Carga masiva — NIP token | Empleados |
| P-EMP-12 | Carga masiva — confirmación éxito | Empleados |
| P-CT-01 | Directorio de centros de trabajo | Centros de trabajo |
| P-CT-02 | Carga individual CT — formulario | Centros de trabajo |
| P-CT-03 | Carga masiva CT | Centros de trabajo |
| P-CT-04 | Recepción de tarjetas — validar remesa | Centros de trabajo |
| P-CT-05 | Recepción de tarjetas — detalle remesa | Centros de trabajo |
| P-CT-06 | Recepción de tarjetas — confirmación CT único | Centros de trabajo |
| P-EST-01 | Estadísticas — dashboard general | Estadísticas |
| P-EST-02 | Estadísticas — Bloqueadas (columnas básicas) | Estadísticas |
| P-EST-03 | Estadísticas — Bloqueadas (columnas extendidas) | Estadísticas |
| P-EST-04 | Estadísticas — Finalizadas (básico) | Estadísticas |
| P-EST-05 | Estadísticas — Finalizadas (extendido) | Estadísticas |
| P-EST-06 | Estadísticas — En proceso (básico) | Estadísticas |
| P-EST-07 | Estadísticas — En proceso (extendido) | Estadísticas |
| P-EST-08 | Estadísticas — Documentadas (resumen) | Estadísticas |
| P-EST-09 | Estadísticas — Documentadas (detalle) | Estadísticas |
| P-EST-10 | Estadísticas — No iniciadas | Estadísticas |
| P-EST-11 | Estadísticas — Vinculadas | Estadísticas |
| P-REG-01 | Registros — Exitosos | Registros |
| P-REG-02 | Registros — Pendientes | Registros |
| P-REG-03 | Registros — Validar en sucursal | Registros |
| P-REG-04 | Registros — Por corregir | Registros |
| P-REG-05 | Registros — Eliminados | Registros |
| P-REG-06 | Registros — No iniciadas | Registros |
| P-REG-07 | Registros — Vinculadas | Registros |

**Total pantallas Scotiabank identificadas: 37**

---

## Preguntas Abiertas para Scotiabank México (dt-product-owner → Scotiabank México)

1. ¿La nueva versión también maneja la distribución física de tarjetas a centros de trabajo, o migra a CLABE digital?
2. ¿Qué productos de cuenta nómina tiene Scotiabank México que sustituirán a N4/N2 del portal actual?
3. ¿El segundo factor de autenticación es token hardware, app móvil Scotiabank México, o SMS OTP?
4. ¿El layout de carga masiva de empleados sigue el formato del portal actual o es compatible con el estándar SAT?
5. ¿Se requiere validación en sucursal (presencial) en algún paso del flujo de la nueva versión, o es 100% digital?
6. ¿Scotiabank México requiere el módulo de CFDI de nómina dentro del portal, o es un sistema externo?
7. ¿El portal maneja múltiples contratos de empresa (grupo empresarial) o es uno por empresa?

---

*Análisis generado por dt-product-owner · 2026-07-24 · v0.1*
