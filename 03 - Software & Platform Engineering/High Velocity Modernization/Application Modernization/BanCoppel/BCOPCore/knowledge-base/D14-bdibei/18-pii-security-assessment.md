# D14 · Banca Electrónica Institucional (BEI) — Evaluación PII y Seguridad

> **Componente:** BCOPCore · SPE-AM-001 · Todas las fases
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Cybersecurity (`Delivery - SME/Cybersecurity/`) ← OWNER de este documento
- Industry Banking (clasificación de datos según regulación CNBV)
- DBA — IBM Informix IDS (campos PII en schema real — Etapa 2)
- Data Architect (encriptación en reposo y en tránsito)
- Core Banking Transformation (IAM y controles de acceso en target)

> **Advertencia regulatoria:** el dominio `bdibei` maneja datos de empleados (CURP, nombre, CLABE bancaria), datos de empresas clientes (RFC, razón social), y montos de nómina. La LFPDPPP, la CNBV, y el PCI-DSS aplican directamente.
---

## Clasificación de datos por sensibilidad

| Campo | Tabla | Clasificación LFPDPPP | Regulación adicional | Manejo requerido |
|-------|-------|-----------------------|---------------------|-----------------|
| `curp` | `bei_beneficiarios` | DATO PERSONAL SENSIBLE (art. 3 LFPDPPP) | IMSS / SHCP | Encriptación AES-256 en reposo · TLS 1.3 en tránsito · No en logs |
| `nombre` | `bei_beneficiarios` | DATO PERSONAL | LFPDPPP | Encriptación · Acceso restringido |
| `num_cuenta_destino` | `bei_beneficiarios` | DATO FINANCIERO SENSIBLE | PCI-DSS · CNBV | Tokenización o encriptación · nunca en logs |
| `rfc_empresa` | `bei_empresa` · `bei_convenios` | DATO FISCAL | SAT CFF | Acceso solo a roles autorizados |
| `razon_social` | `bei_empresa` | DATO COMERCIAL | LFPDPPP (datos corporativos) | Acceso restringido |
| `monto_dispersion` | `bei_beneficiarios` · `bei_dispersiones_det` | DATO FINANCIERO | CNBV CUB | No en logs externos; solo en audit trail CNBV |
| `ip_origen` | `bei_bitacora` | DATO PERSONAL (identificador de red) | LFPDPPP | Anonimizar en logs de acceso público; preservar en audit trail |
| `cod_token` | `bei_tokens_empresa` | CREDENCIAL | PCI-DSS 8.3 | Nunca persistir en claro; solo hash bcrypt |

---

## Hallazgo crítico de seguridad — OTP con LCG (BR-BEI-001 a 004)

> **Referencia:** `04-business-rules.md §BR-BEI-001` · `sp-specs-bdibei.md (getrandomcode)`

| Atributo | Valor |
|----------|-------|
| SP afectado | `getrandomcode` |
| Tipo de vulnerabilidad | Generador de números pseudoaleatorios no criptográfico (LCG) |
| CVE equivalente | CWE-338 (Use of Cryptographically Weak PRNG) |
| Estándar violado | PCI-DSS v4.0 Req. 8.3.6 (autenticación multifactor) · CNBV CUB Sec-III |
| Severidad | ALTA |
| Explotabilidad | Media — requiere conocer los parámetros del LCG (están en el código fuente, accesible si hay fuga) |

**Descripción técnica:**

El LCG en `getrandomcode` implementa `x = (a * x + c) % m` donde `a`, `c`, `m`, `k` son constantes. El estado inicial se deriva de `DBINFO('sessionid')` y el conteo de filas en `systables`. Con ambos valores conocidos, un atacante puede predecir todos los códigos OTP siguientes.

**En banca electrónica institucional, el impacto es alto:** el código OTP autentica a la empresa para autorizar dispersiones de nómina. Un atacante que prediga el OTP puede autorizar dispersiones fraudulentas.

**Remediación en target:**

```java
// AuthEmpresaService.java — reemplaza getrandomcode()
@Service
public class OTPService {
    private static final SecureRandom CSPRNG = new SecureRandom();
    private static final String ALPHABET = 
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    public String generarOTP() {
        StringBuilder otp = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            otp.append(ALPHABET.charAt(CSPRNG.nextInt(ALPHABET.length())));
        }
        return otp.toString();
    }
    
    public String hashOTP(String otp) {
        // Nunca almacenar el OTP en claro — solo el hash BCrypt
        return BCrypt.hashpw(otp, BCrypt.gensalt(12));
    }
    
    public boolean validarOTP(String otp, String hashAlmacenado) {
        return BCrypt.checkpw(otp, hashAlmacenado);
    }
}
```

---

## Controles de acceso requeridos en el target

### IAM — Principio de mínimo privilegio

| Rol | Acceso a datos BEI | Tablas permitidas |
|-----|-------------------|------------------|
| `bei-operador-empresa` | Solo su empresa | `bei_convenios` (R), `bei_dispersiones` (R/W), `bei_beneficiarios` (R) |
| `bei-admin-interno` | Todas las empresas | Todas las tablas BEI (R/W) |
| `bei-auditoria` | Solo lectura | `bei_bitacora`, `bei_dispersiones`, `bei_comisiones` |
| `bei-batch-service` | Cuenta de servicio | `bei_dispersiones` (R/W), `bei_dispersiones_det` (R/W), `bei_beneficiarios` (R) |
| `bei-reporte-cnbv` | Solo lectura reporting | `bei_dispersiones`, `bei_comisiones` (R) |

### Autenticación empresa (portal BEI)

| Mecanismo | Estándar | Target |
|-----------|---------|--------|
| Sesión empresa | OAuth 2.0 + PKCE | Amazon Cognito |
| OTP adicional | TOTP OATH RFC 6238 o SMS | Reemplaza `getrandomcode` LCG |
| API B2B empresa | mTLS (certificado cliente) | AWS ACM + API Gateway mTLS |
| Token de acceso | JWT RS256 · expira 1h | Cognito Identity Pools |

---

## Encriptación

### En reposo (at rest)

| Almacenamiento | Encriptación | Clave | Notas |
|---------------|-------------|-------|-------|
| Aurora PostgreSQL | AES-256 (AWS KMS) | CMK dedicado para BEI | KMS key rotation anual |
| S3 (archivos nómina) | SSE-KMS | Mismo CMK BEI | Archivos nómina son PII — restricción de acceso |
| Logs CloudWatch | AES-256 | KMS | Datos de auditoría |

### En tránsito

| Canal | Protocolo | Versión mínima | Notas |
|-------|-----------|---------------|-------|
| Cliente empresa → API Gateway | HTTPS | TLS 1.3 | Certificate pinning recomendado |
| Microservicio → Aurora | TLS | TLS 1.2+ | SSL mode require en Aurora |
| Microservicio → MSK | TLS | TLS 1.2+ | MSK in-transit encryption habilitado |
| API BEI → SPEIService (D08) | HTTPS + mTLS interno | TLS 1.3 | Certificados internos ACM |
| Archivos nómina en S3 | HTTPS | TLS 1.3 | S3 Endpoint VPC |

---

## Datos prohibidos en logs

```yaml
# Configuración de log sanitization — OBLIGATORIO en todos los servicios BEI
campos_prohibidos_en_logs:
  - curp
  - nombre_beneficiario
  - num_cuenta_destino  # CLABE
  - rfc_empresa
  - monto_dispersion    # Montos individuales — solo totales de lote
  - cod_token
  - otp_codigo
  - password

# Campos permitidos en logs (identificadores anonimizados):
campos_permitidos:
  - num_convenio
  - folio_dispersion
  - tipo_dispersion
  - cod_estatus
  - cod_error
  - traceId
  - timestamp
```

---

## Audit trail regulatorio CNBV

El dominio BEI debe mantener un audit trail completo de todas las operaciones para cumplir con CNBV CUB:

| Evento | Campos requeridos | Retención |
|--------|------------------|-----------|
| Alta de convenio empresa | timestamp · usuario · empresa · resultado | 5 años |
| Dispersión iniciada | timestamp · folio · num_convenio · total_registros · total_importe | 5 años |
| Dispersión completada/fallida | timestamp · folio · cod_estatus · registros_ok · registros_fallidos | 5 años |
| Login empresa | timestamp · empresa · IP anonimizada · resultado | 2 años |
| Cambio de beneficiario | timestamp · usuario · convenio · beneficiario_id | 5 años |
| Reverso de dispersión | timestamp · folio_original · motivo · usuario | 5 años |

El audit trail se almacena en `bei_bitacora` (Aurora) y se replica a S3 Glacier para retención de largo plazo.

---

## Aviso de Privacidad — LFPDPPP

BanCoppel debe tener Aviso de Privacidad que cubra el tratamiento de datos de empleados beneficiarios de nómina (CURP, nombre, CLABE). Este tratamiento ocurre en:
- Alta de beneficiarios en `bei_beneficiarios`
- Procesamiento del batch de nómina
- Reportes BEI

`[SME-PENDING]` Cybersecurity — verificar que el Aviso de Privacidad de BanCoppel cubre explícitamente el tratamiento BEI de datos de empleados de empresas clientes.

---

## Checklist de seguridad antes de cutover

- [ ] `getrandomcode` LCG reemplazado por `SecureRandom` — verificado en código target.
- [ ] Datos PII en `bei_beneficiarios` encriptados en Aurora (AES-256 KMS).
- [ ] CLABE en `num_cuenta_destino` tokenizada o encriptada.
- [ ] IAM configurado con principio de mínimo privilegio — revisado por Cybersecurity.
- [ ] TLS 1.2+ forzado en todos los canales — verificado por penetration test.
- [ ] Audit trail CNBV funcionando en pre-prod (bei_bitacora activo).
- [ ] Ningún campo PII en logs de CloudWatch — verificado con gitleaks + revisión manual.
- [ ] Autenticación empresa usa OTP criptográfico (TOTP o equivalente).
- [ ] Aviso de Privacidad BanCoppel cubre tratamiento de datos BEI.
- [ ] PCI-DSS compliance verificado para procesamiento de CLABE.

---
*Generado por: Cybersecurity SME + Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: sp-specs-bdibei.md (hallazgo LCG) + modelo de datos BEI inferido + regulación LFPDPPP + PCI-DSS + CNBV*
