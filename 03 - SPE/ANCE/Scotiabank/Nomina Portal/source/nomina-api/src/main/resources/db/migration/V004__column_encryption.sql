/* =============================================================================
   V004__column_encryption.sql
   Portal Empresas Nómina · Scotiabank México · SPE-ANCE-005
   Estrategia de cifrado de datos PII/PCI (spec §11) — DOCUMENTAL / REFERENCIA.

   *** EN EL MOCK ESTA MIGRACIÓN ES UN NO-OP ***
   La habilitación de Always Encrypted requiere Column Master Key (CMK) en un
   almacén de llaves (Azure Key Vault / Windows Cert Store / HSM) y Column
   Encryption Keys (CEK), infraestructura que NO existe en el entorno mock local.
   Además, habilitar Always Encrypted sobre estas columnas REQUIERE sign-off de
   dt-security-engineer (ver swarm/dt-dba.md · Decision Authority) y coordinación
   con ADR-ANCE-003 (multi-tenant) y el driver del PAC/PCI scope.

   Por eso el DDL real de cifrado queda COMENTADO abajo como plantilla de PROD.
   Este archivo sólo imprime la estrategia para dejar traza versionada en Flyway.

   -------------------------------------------------------------------------------
   CLASIFICACIÓN (spec §11) — columnas a cifrar en PROD:

     PCI (Always Encrypted · determinístico sólo si se necesita búsqueda/join;
          aleatorio en caso contrario — preferente para PAN/tarjeta):
       · dbo.Empresa.clabeOrigen
       · dbo.Empresa.numeroCuenta
       · dbo.Empleado.numeroCuenta
       · dbo.Empleado.clabe
       · dbo.Empleado.numeroTarjeta            (además tokenizada en la app)
       · dbo.DetalleNomina.clabeDestino
       · dbo.MovimientoDispersion.clabeDestino

     PII (Always Encrypted determinístico donde haya búsqueda por igualdad —
          p.ej. rfc/curp — aleatorio en el resto):
       · dbo.Empresa.rfcEmpresa
       · dbo.Empleado.rfc
       · dbo.Empleado.curp
       · dbo.Empleado.nombres / primerApellido / segundoApellido
       · dbo.Empleado.ingresoMensualNeto

   CONTROLES COMPLEMENTARIOS:
     · TDE (Transparent Data Encryption) a nivel de base de datos: cifrado en
       reposo de todo el archivo de datos/log/backup. Independiente de Always
       Encrypted (defense in depth). Se habilita a nivel instancia/DB en PROD.
     · Enmascarado en UI por rol (últimos 4/6) — responsabilidad de la API, no de
       la DB. Opcionalmente Dynamic Data Masking como control adicional.
     · Nunca CLABE/RFC/PAN en claro en logs (anti-patrón dt-dba).
   ============================================================================= */

SET NOCOUNT ON;
GO

PRINT '=============================================================';
PRINT 'V004__column_encryption — NO-OP en mock.';
PRINT 'Cifrado PII/PCI (Always Encrypted + TDE) documentado para PROD.';
PRINT 'Requiere: CMK/CEK en Key Vault + sign-off dt-security-engineer.';
PRINT '=============================================================';
GO

/* =============================================================================
   PLANTILLA DE PROD — NO EJECUTAR EN MOCK (bloque comentado)
   -----------------------------------------------------------------------------

   -- 1) TDE (cifrado en reposo de toda la base de datos) -----------------------
   -- USE master;
   -- CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<strong-secret-from-vault>';
   -- CREATE CERTIFICATE TDECert WITH SUBJECT = 'Nomina Portal TDE Certificate';
   -- USE NominaPortal;
   -- CREATE DATABASE ENCRYPTION KEY
   --   WITH ALGORITHM = AES_256
   --   ENCRYPTION BY SERVER CERTIFICATE TDECert;
   -- ALTER DATABASE NominaPortal SET ENCRYPTION ON;

   -- 2) Always Encrypted — Column Master Key + Column Encryption Key -----------
   --    (normalmente aprovisionadas por el driver de aprovisionamiento con la
   --     CMK residente en Azure Key Vault; aquí sólo referencia de metadata)
   -- CREATE COLUMN MASTER KEY CMK_NominaPortal
   --   WITH ( KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT',
   --          KEY_PATH = 'https://<vault>.vault.azure.net/keys/nomina-cmk/<ver>' );
   -- CREATE COLUMN ENCRYPTION KEY CEK_NominaPortal
   --   WITH VALUES ( COLUMN_MASTER_KEY = CMK_NominaPortal,
   --                 ALGORITHM = 'RSA_OAEP',
   --                 ENCRYPTED_VALUE = 0x<blob> );

   -- 3) Cifrar columnas PCI (ejemplo — clabe del empleado, aleatorio) ----------
   --    ALTER TABLE con ONLINE = ON para no bloquear. Aleatorio = sin búsqueda;
   --    usar DETERMINISTIC sólo en columnas que requieren igualdad (rfc/curp).
   -- ALTER TABLE dbo.Empleado
   --   ALTER COLUMN clabe VARCHAR(18)
   --   ENCRYPTED WITH ( COLUMN_ENCRYPTION_KEY = CEK_NominaPortal,
   --                    ENCRYPTION_TYPE = RANDOMIZED,
   --                    ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256' )
   --   WITH (ONLINE = ON);

   -- ALTER TABLE dbo.Empleado
   --   ALTER COLUMN rfc VARCHAR(13)
   --   ENCRYPTED WITH ( COLUMN_ENCRYPTION_KEY = CEK_NominaPortal,
   --                    ENCRYPTION_TYPE = DETERMINISTIC,
   --                    ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256' )
   --   WITH (ONLINE = ON);

   --    ... repetir para el resto de columnas PCI/PII del inventario de arriba.
   ============================================================================= */
