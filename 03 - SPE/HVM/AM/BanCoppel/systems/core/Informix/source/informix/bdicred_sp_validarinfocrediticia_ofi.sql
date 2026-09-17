CREATE PROCEDURE "informix".sp_validarinfocrediticia_ofi
(
pEmpresa		CHAR(3), 
pNumCte			VARCHAR(20),
pNumTarjeta		VARCHAR(20)
)

RETURNING 
CHAR(6) AS COD_RET,
CHAR(80) AS MENSAJE_RET,
CHAR(60) AS DESC_STATUS;
		  
--DEFINICIÃN DE VARIABLES--		  
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);

DEFINE cDescripcion			CHAR(60);
DEFINE cNumTarjeta			CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE cStatusCred			CHAR(2);
DEFINE cStatusInc			CHAR(2);
DEFINE dtFecha1				DATE;
DEFINE dtFechaHoy			DATE;
DEFINE v_empresa			CHAR(1);
DEFINE v_garantizada		CHAR(1);
DEFINE v_credito			CHAR(1);
DEFINE v_valida				CHAR(1);
DEFINE cMtoVen              DECIMAL(18,2);

--INICIALIZACIÃN DE VARIABLES--
LET iSqlErr               	= 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= 'PROCESO EXITOSO';
LET cCodRet               	= '000000';

LET cDescripcion			= '';
LET cNumTarjeta				= '';
LET cNumCredito				= '';
LET cStatusCred				= '';
LET cStatusInc				= '';
LET dtFecha1				= DATE(1);
LET dtFechaHoy				= DATE(1);
LET v_empresa				= '';
LET v_garantizada			= '';
LET v_credito				= '';
LET v_valida				= '';
LET cMtoVen                = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;
		  
	--SET DEBUG FILE TO '/home/sysifx/has/sp_validarinfocrediticia_ofi.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;

	IF NVL(pEmpresa,'') = '' OR (NVL(pNumCte,'') = '' AND NVL(pNumTarjeta,'') = '') THEN 
		LET cCodRet = '000001';
		LET cErrorInfo = 'FALTA UNO O MAS PARÃMETROS';
		RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
	ELSE
		--IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
		SELECT FIRST 1 '1' INTO v_empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
		
		IF (v_empresa IS NULL) OR (v_empresa = '') THEN
			LET cCodRet = '000002';
			LET cErrorInfo = 'LA EMPRESA NO ES VÃLIDA';
			RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		ELSE
			-- NO VIENE LA TARJETA PERO SI TRAE EL NUMERO DE CLIENTE EN LOS PARAMETROS RECIBIDOS
			IF NVL(pNumTarjeta,'') = '' THEN -- HACER QUE LA CONSULTA REGRESE EL CREDITO QUE ESTA VIGENTE YA QUE EL CLIENTE PUEDE TENER MAS DE 1
				FOREACH WITH HOLD
					SELECT a.num_credito, a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
					INTO cNumCredito, cStatusCred,cMtoVen
					FROM bdicred:"informix".sd_maecred a
					INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
					WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
					ORDER BY a.fecha_apertura DESC
				END FOREACH
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '000003';
					LET cErrorInfo = 'NO SE ENCUENTRA EL CLIENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			
				SELECT num_tarjeta
				INTO cNumTarjeta
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_credito = cNumCredito AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumTarjeta,'') = '' THEN
					LET cCodRet = '000004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON CRÃDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			-- TRAE EL NUMERO DE TARJETA EN LOS PARAMETROS RECIBIDOS
			ELSE
				SELECT num_credito, numcte
				INTO cNumCredito, pNumCte
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_tarjeta = pNumTarjeta AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '000004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON DE CRÃDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
				
				SELECT a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
				INTO cStatusCred, cMtoVen
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
				WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
				AND a.num_credito = cNumCredito ;
				
			END IF
			
			--validaciÃ³n de TDC Garantizada			
			--IF EXISTS (SELECT * FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S") THEN
			
			SELECT FIRST 1 '1' INTO v_garantizada FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S";
			
			IF (v_garantizada = '1') THEN
				-- Cliente con Tarjeta de CrÃ©dito Garantizada.
				LET cCodRet = '000011';
				LET cErrorInfo = 'Cliente con Tarjeta de CrÃ©dito Garantizada.';
				RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
			END IF;					
			
			--Lazalde VALIDAR QUE LA TARJETA DE CREDITO VISA NO ESTE BLOQUEADA				
				--VALIDAR DE QUE EL NUMERO DE CREDITO EXISTA EN EL LISTADO DE TARJETAS BLOQUEADAS
			/*	IF EXISTS(
					SELECT num_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito
					)
						THEN*/
				SELECT FIRST 1 '1' INTO v_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito;
					
				IF (v_credito = '1') THEN
							LET cCodRet = '000012';
							LET cErrorInfo = 'Cliente tiene "Bloqueada" su Tarjeta de CrÃ©dito Visa';
							RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
			
			  IF (cStatusCred NOT IN ('AA','E1') or cMtoVen > 0) THEN   --IFRS MACF
				IF cStatusCred IN ('BT','BA','CV','FC','E1','E2','E3')  THEN  --IFRS MACF
					SELECT descripcion
					INTO cDescripcion
					FROM bdicred:"informix".sd_tipocartera
					WHERE status_cred = cStatusCred;
					LET cCodRet = '000005';
					LET cErrorInfo = 'CLIENTE TIENE ' || trim(cDescripcion) || ' SU TARJETA DE CRÃDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				ELSE
					LET cCodRet = '000006';
					LET cErrorInfo = 'CLIENTE CON CRÃDITO NO VIGENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			ELSE
				-- OBTIENE LA FECHA DOS MESES ANTES
				SELECT monthadd(fecha_hoy, -3), fecha_hoy
				INTO dtFecha1, dtFechaHoy
				FROM bdicred:"informix".sd_fechas
				WHERE empresa = pEmpresa;
			
			/*	IF EXISTS(SELECT empresa FROM bdicred:"informix".sd_bitacora_aumlincred 
						WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY) )  THEN*/
				SELECT FIRST 1 '1' INTO v_valida FROM bdicred:"informix".sd_bitacora_aumlincred 
				WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY);
				
				IF (v_valida = '1') THEN
					-- Solicitud de incremento ya hecha en el mismo dia
					LET cCodRet = '000010';
					LET cErrorInfo = 'CLIENTE YA REALIZÃ LA SOLICITUD DE INCREMENTO ESTE MISMO DÃA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF

				SELECT FIRST 1 NVL(a.status,'')
				INTO cStatusInc
				FROM bdicred:"informix".sd_bitacora_aumlincred a
				WHERE a.numcte = pNumCte           
				AND a.fecha_insert = (SELECT MAX(b.fecha_insert)
									   FROM bdicred:"informix".sd_bitacora_aumlincred b
									  WHERE b.status = b.status
										AND b.numcte = pNumCte
										AND b.empresa = a.empresa
										AND b.fecha_insert BETWEEN dtFecha1 AND dtFechaHoy)
				AND a.empresa = pEmpresa;
				   
				IF cStatusInc IS NULL THEN
					LET cStatusInc = '';
				END IF;
			   
				IF cStatusInc IN ('IN','AT') THEN
				   -- Cliente tiene en tramite un Incremento en la lÃ­nea de CrÃ©dito
					LET cCodRet = '000007';
					LET cErrorInfo = 'CLIENTE TIENE EN TRAMITE UN INCREMENTO EN LA LÃNEA DE CRÃDITO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc = 'RT' THEN
				   -- Cliente con Solicitud de Incremento de LÃ­nea 'Rechazada'
					LET cCodRet = '000008';
					LET cErrorInfo = 'CLIENTE CON SOLICITUD DE INCREMENTO DE LÃNEA RECHAZADA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc IN ('PC','AC','BC','CC','EC') THEN
				   -- Cliente tiene una Solicitud de Incremento de LÃ­nea en Proceso
					LET cCodRet = '000009';
					LET cErrorInfo = 'CLIENTE TIENE UNA SOLICITUD DE INCREMENTO DE LÃNEA EN PROCESO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			END IF
			
		END IF
	END IF

	RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para confirmaciÃ³n de la informaciÃ³n del cliente',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 12/10/2011',
'BD    : BDICRED',
'MODIFICO: Mohamed Carreon',
'DESCRIPCION: Se modifico para cumplir con las reglas de programacion',
'FECHA: 11/NOV/2011',
'MODIFICO: Armando Morales',
'DESCRIPCION: Se modificÃ³ para que consulte el credito mas reciente que tiene el cliente ya que puede tener mas de 1',
'FECHA: 12/06/2012',
'Modificacion: Se corrige para agregar validaciÃ³n de las solicitudes en PC',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 17/Septiembre/2012',
'BD    : bdicred',
'VERSION:20120917.1011',
'FECHA: 12/06/2012',
'Modificacion: Se borra cÃ³digo comentado,se agregan informix y bd a las tablas que no tenÃ­an, Se implementan reglas','de informix',
'AUTOR : JosuÃ© Remberto Zazueta Acosta',
'FECHA : 02/Octubre/2012',
'BD    : bdicred',
'Modificacion: Validar si la tarjeta de crÃ©dito visa esta bloqueada',
'AUTOR : Juan Daniel Lazalde',
'FECHA : 14/Febrero/2014',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_validarinfocrediticia_ofi_web
(
pEmpresa		CHAR(3), 
pNumCte			VARCHAR(20),
pNumTarjeta		VARCHAR(20)
)

RETURNING 
CHAR(5) AS COD_RET,
CHAR(80) AS MENSAJE_RET,
CHAR(60) AS DESC_STATUS;
		  
--DEFINICIÃÂN DE VARIABLES--		  
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(5);

DEFINE cDescripcion			CHAR(60);
DEFINE cNumTarjeta			CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE cStatusCred			CHAR(2);
DEFINE cStatusInc			CHAR(2);
DEFINE dtFecha1				DATE;
DEFINE dtFechaHoy			DATE;
DEFINE v_empresa			CHAR(1);
DEFINE v_garantizada		CHAR(1);
DEFINE v_credito			CHAR(1);
DEFINE v_valida				CHAR(1);
DEFINE cMtoVen              DECIMAL(18,2);

--INICIALIZACIÃÂN DE VARIABLES--
LET iSqlErr               	= 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= 'PROCESO EXITOSO';
LET cCodRet               	= '00000';

LET cDescripcion			= '';
LET cNumTarjeta				= '';
LET cNumCredito				= '';
LET cStatusCred				= '';
LET cStatusInc				= '';
LET dtFecha1				= DATE(1);
LET dtFechaHoy				= DATE(1);
LET v_empresa				= '';
LET v_garantizada			= '';
LET v_credito				= '';
LET v_valida				= '';
LET cMtoVen                = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;
		  
	--SET DEBUG FILE TO '/home/sysifx/has/sp_validarinfocrediticia_ofi.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' OR (NVL(pNumCte,'') = '' AND NVL(pNumTarjeta,'') = '') THEN 
		LET cCodRet = '00001';
		LET cErrorInfo = 'FALTA UNO O MAS PARÃÂMETROS';
		RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
	ELSE
		--IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
		SELECT FIRST 1 '1' INTO v_empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
		
		IF (v_empresa IS NULL) OR (v_empresa = '') THEN
			LET cCodRet = '00002';
			LET cErrorInfo = 'LA EMPRESA NO ES VÃÂLIDA';
			RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		ELSE
			-- NO VIENE LA TARJETA PERO SI TRAE EL NUMERO DE CLIENTE EN LOS PARAMETROS RECIBIDOS
			IF NVL(pNumTarjeta,'') = '' THEN -- HACER QUE LA CONSULTA REGRESE EL CREDITO QUE ESTA VIGENTE YA QUE EL CLIENTE PUEDE TENER MAS DE 1
				FOREACH WITH HOLD
									  
									
					SELECT a.num_credito, a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
					INTO cNumCredito, cStatusCred,cMtoVen
					FROM bdicred:"informix".sd_maecred a
					INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
					WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
					ORDER BY a.fecha_apertura DESC
				END FOREACH
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '00003';
					LET cErrorInfo = 'NO SE ENCUENTRA EL CLIENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			
				SELECT num_tarjeta
				INTO cNumTarjeta
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_credito = cNumCredito AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumTarjeta,'') = '' THEN
					LET cCodRet = '00004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON CRÃÂDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			-- TRAE EL NUMERO DE TARJETA EN LOS PARAMETROS RECIBIDOS
			ELSE
				SELECT num_credito, numcte
				INTO cNumCredito, pNumCte
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_tarjeta = pNumTarjeta AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '00004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON DE CRÃÂDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
				
				SELECT a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
					
									  
												 
									 
	
													
				INTO cStatusCred, cMtoVen
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
				WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
				AND a.num_credito = cNumCredito ;
				
			END IF
			
			--validaciÃÂ³n de TDC Garantizada			
			--IF EXISTS (SELECT * FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S") THEN
			
			SELECT FIRST 1 '1' INTO v_garantizada FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S";
			
			IF (v_garantizada = '1') THEN
				-- Cliente con Tarjeta de CrÃÂ©dito Garantizada.
				LET cCodRet = '00011';
				LET cErrorInfo = 'Cliente con Tarjeta de CrÃÂ©dito Garantizada.';
				RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
			END IF;					
			
			--Lazalde VALIDAR QUE LA TARJETA DE CREDITO VISA NO ESTE BLOQUEADA				
				--VALIDAR DE QUE EL NUMERO DE CREDITO EXISTA EN EL LISTADO DE TARJETAS BLOQUEADAS
			/*	IF EXISTS(
					SELECT num_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito
					)
						THEN*/
				SELECT FIRST 1 '1' INTO v_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito;
					
				IF (v_credito = '1') THEN
							LET cCodRet = '00012';
							LET cErrorInfo = 'Cliente tiene "Bloqueada" su Tarjeta de CrÃÂ©dito Visa';
							RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
			
			  IF (cStatusCred NOT IN ('AA','E1') or cMtoVen > 0) THEN   --IFRS MACF
												   
				IF cStatusCred IN ('BT','BA','CV','FC','E1','E2','E3')  THEN  --IFRS MACF
					SELECT descripcion
					INTO cDescripcion
					FROM bdicred:"informix".sd_tipocartera
					WHERE status_cred = cStatusCred;
					LET cCodRet = '00005';
					LET cErrorInfo = 'CLIENTE TIENE ' || trim(cDescripcion) || ' SU TARJETA DE CREDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				ELSE
					LET cCodRet = '00006';
					LET cErrorInfo = 'CLIENTE CON CREDITO NO VIGENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			ELSE
				-- OBTIENE LA FECHA DOS MESES ANTES
				SELECT monthadd(fecha_hoy, -3), fecha_hoy
				INTO dtFecha1, dtFechaHoy
				FROM bdicred:"informix".sd_fechas
				WHERE empresa = pEmpresa;
			
			/*	IF EXISTS(SELECT empresa FROM bdicred:"informix".sd_bitacora_aumlincred 
						WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY) )  THEN*/
				SELECT FIRST 1 '1' INTO v_valida FROM bdicred:"informix".sd_bitacora_aumlincred 
				WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY);
				
				IF (v_valida = '1') THEN
					-- Solicitud de incremento ya hecha en el mismo dia
					LET cCodRet = '00010';
					LET cErrorInfo = 'CLIENTE YA REALIZÃÂ LA SOLICITUD DE INCREMENTO ESTE MISMO DÃÂA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF

				SELECT FIRST 1 NVL(a.status,'')
				INTO cStatusInc
				FROM bdicred:"informix".sd_bitacora_aumlincred a
				WHERE a.numcte = pNumCte           
				AND a.fecha_insert = (SELECT MAX(b.fecha_insert)
									   FROM bdicred:"informix".sd_bitacora_aumlincred b
									  WHERE b.status = b.status
										AND b.numcte = pNumCte
										AND b.empresa = a.empresa
										AND b.fecha_insert BETWEEN dtFecha1 AND dtFechaHoy)
				AND a.empresa = pEmpresa;
				   
				IF cStatusInc IS NULL THEN
					LET cStatusInc = '';
				END IF;
			   
				IF cStatusInc IN ('IN','AT') THEN
				   -- Cliente tiene en tramite un Incremento en la lÃÂ­nea de CrÃÂ©dito
					LET cCodRet = '00007';
					LET cErrorInfo = 'CLIENTE TIENE EN TRAMITE UN INCREMENTO EN LA LÃÂNEA DE CRÃÂDITO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc = 'RT' THEN
				   -- Cliente con Solicitud de Incremento de LÃÂ­nea 'Rechazada'
					LET cCodRet = '00008';
					LET cErrorInfo = 'CLIENTE CON SOLICITUD DE INCREMENTO DE LÃÂNEA RECHAZADA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc IN ('PC','AC','BC','CC','EC') THEN
				   -- Cliente tiene una Solicitud de Incremento de LÃÂ­nea en Proceso
					LET cCodRet = '00009';
					LET cErrorInfo = 'CLIENTE TIENE UNA SOLICITUD DE INCREMENTO DE LÃÂNEA EN PROCESO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			END IF
			
		END IF
	END IF

	RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para confirmaciÃÂ³n de la informaciÃÂ³n del cliente',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 12/10/2011',
'BD    : BDICRED',
'MODIFICO: Mohamed Carreon',
'DESCRIPCION: Se modifico para cumplir con las reglas de programacion',
'FECHA: 11/NOV/2011',
'MODIFICO: Armando Morales',
'DESCRIPCION: Se modificÃÂ³ para que consulte el credito mas reciente que tiene el cliente ya que puede tener mas de 1',
'FECHA: 12/06/2012',
'Modificacion: Se corrige para agregar validaciÃÂ³n de las solicitudes en PC',
'AUTOR : JesÃÂºs Manuel Aguilar Heredia',
'FECHA : 17/Septiembre/2012',
'BD    : bdicred',
'VERSION:20120917.1011',
'FECHA: 12/06/2012',
'Modificacion: Se borra cÃÂ³digo comentado,se agregan informix y bd a las tablas que no tenÃÂ­an, Se implementan reglas','de informix',
'AUTOR : JosuÃÂ© Remberto Zazueta Acosta',
'FECHA : 02/Octubre/2012',
'BD    : bdicred',
'Modificacion: Validar si la tarjeta de crÃÂ©dito visa esta bloqueada',
'AUTOR : Juan Daniel Lazalde',
'FECHA : 14/Febrero/2014',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_chi_pld_layout_sic(v_id_proceso CHAR(1))
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Creado por: 			Gutberto Gomez Guadarrama
	-- Fecha de creacion: 	25/05/2021
	-- Peticion:			RQM 10-1404 (RQI 28 268)
	-- Modificado por: 		N/A
	-- Fecha modificación:	N/A
	-- Modificación:		N/A
	-- BD: 					bdicred
	-- ID Rational:			50746
	-------------------------------------------------------------------------------------
	-- Peticion:			RQM 10 1404 - Hipotecario Infonavit
	-- Modificado por: 		Miguel Alejandro Sánchez Mojica
	-- Fecha modificación:	16/12/2021
	-- Modificación:		Manejo de errores en sección de exceptions
	-- BD: 					bdicred
	-- ID Rational:			54604
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	error_info              CHAR(40);
    DEFINE     	cod_ret                 CHAR(6);
	DEFINE	   	mensaje_ret				VARCHAR(255);
    DEFINE     	cod_ret_aux             CHAR(6);
	DEFINE	   	mensaje_ret_aux			VARCHAR(255);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE 		v_fechacaptura          DATE;
	DEFINE 		v_fechaintegracion      DATE;
	DEFINE 		v_naturaleza            CHAR(1);
	DEFINE 		v_importe               MONEY(18,2);
	DEFINE 		v_mensaje               CHAR(50);
	DEFINE 		v_status	            CHAR(8);
	DEFINE 		v_integra               INTEGER;
	DEFINE 		v_numtotal              SMALLINT;
	DEFINE	   	vCounter				INTEGER;
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta_in			    CHAR(100);
	DEFINE 		cRuta_out			    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cArchivoLay			    CHAR(100);
	DEFINE 		cArchivoRep			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
	DEFINE 		cNombreArchivo2		    CHAR(100);
	
	DEFINE		v_ap_paterno			VARCHAR(50);
	DEFINE		v_ap_materno			VARCHAR(50);
	DEFINE		v_nombres				VARCHAR(80);
	DEFINE		v_fecha_nac				VARCHAR(10);
	DEFINE		v_rfc					VARCHAR(13);
	DEFINE		v_num_credito			VARCHAR(20);
	DEFINE		v_ind_listas_negras		VARCHAR(1);
	DEFINE		v_count_exist			INTEGER;
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';
    LET 	   	cod_ret_aux 			= '00000'; 
	LET 	   	mensaje_ret_aux 		= '';
	LET			v_count_exist			= 0;
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET			v_fechacaptura			= today;
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta_in	 			= "/resplogifx/hipotecario_infonavit/pld/";
	LET 		cRuta_out	 			= "/RESPALDOSNEW/hipotecario_infonavit/pld/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_temp_chi_pld_layout_sic.sql";
	LET 		cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET 		cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		cArchivoLay				= "chi_pld_layout_sic_";
	LET 		cArchivoRep				= "chi_pld_layout_sic_listas_negras_";
	LET			cNombreArchivo			= "";
	LET			cNombreArchivo2			= "";
	LET			vCounter				= 0;
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A CARGAR, TIPOS DE DATOS Y LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS Y LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/pld/sp_chi_pld_layout_sic'||v_id_proceso||'.out';
		--TRACE ON;                                                   
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

-- ****************************************************************************
-- *                      SE OBTIENE FECHA DE PROCESO                         *
-- ****************************************************************************	
	SELECT LPAD(YEAR(fecha_hoy), 4, '0') INTO cYear FROM bdicred:sd_fechas WHERE empresa = '001';
	SELECT LPAD(MONTH(fecha_hoy), 2, '0') INTO cMes FROM bdicred:sd_fechas WHERE empresa = '001';
	SELECT LPAD(DAY(fecha_hoy), 2, '0') INTO cDia FROM bdicred:sd_fechas WHERE empresa = '001';	

-- ****************************************************************************
-- *                          PASE A HISTORICO                                *
-- ****************************************************************************	
IF v_id_proceso = 0 THEN
			INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_hist 
			SELECT * FROM bdicred:"informix".sd_chi_pld_layout_sic;

-- ****************************************************************************
-- *                     ELIMINAR REGISTROS ACTUALES                          *
-- ****************************************************************************	
			
			DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
		
-- ****************************************************************************
-- *                        ELIMINAR TABLA DE PASO                            *
-- ****************************************************************************	
			
			DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
		
	
-- ****************************************************************************
-- *               IMPORTACIóN DE ARCHIVO A TABLA DE PASO                     *
-- ****************************************************************************	
			
			--- layout de archivo: APELLIDO PATERNO|APELLIDO MATERNO|NOMBRE(S)|FECHA DE NACIMIENTO(DDMMAAAA)|RFC|NUMERO CREDITO
			LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
			LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta_in) || TRIM(cNombreArchivo) || 
				' INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_paso;' || "" || '">'||TRIM(cRuta_in)|| TRIM(cNomSQL);
			SYSTEM TRIM(cSQL);

			LET cSQL='chmod 777 '|| TRIM(cRuta_in)|| TRIM(cNomSQL);
			SYSTEM cSQL;

			LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta_in) || TRIM(cNomSQL);
			SYSTEM cSQL;
			
			LET cSQL = 'rm ' || TRIM(cRuta_in) || TRIM(cNomSQL);
			SYSTEM cSQL;
			

-- ****************************************************************************
-- *                    PASE A TABLA DE PROCESO ACTUAL                        *
-- ****************************************************************************	
				
			FOREACH WITH HOLD
				SELECT  
					hito_num_credito,
					hito_nombres,
					hito_fecha_nacimiento,
					hito_rfc
					--
					INTO 
					v_num_credito,
					v_nombres,
					v_fecha_nac,
					v_rfc
				FROM bdicred:"informix".sd_chi_pld_layout_sic_paso
				
				SELECT COUNT (*) INTO v_count_exist
				FROM bdicred:"informix".sd_chi_pld_layout_sic WHERE hito_num_credito = v_num_credito;
				
				IF v_count_exist = 0 THEN
				
					INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic VALUES
					(
						v_num_credito,
						v_nombres,
						v_fecha_nac,
						v_rfc,
						'',--pld_numcte_bcpl
						'',--pld_uid
						'',--pld_categoria
						'',--pld_sub_categoria
						'',--pld_posicion
						'',--pld_lugar_nacimiento
						'',--pld_ciudadania
						'',--pld_companias
						'',--pld_ind_validado
						'',--pld_ind_listas_negras
						CURRENT::datetime year to second,--fecha_carga
						CURRENT::datetime year to second--fecha_modifica
					);
					ELSE
						INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_err VALUES
						(
							v_num_credito,
							v_nombres,
							v_fecha_nac,
							v_rfc,
							'',--pld_numcte_bcpl
							'',--pld_uid
							'',--pld_categoria
							'',--pld_sub_categoria
							'',--pld_posicion
							'',--pld_lugar_nacimiento
							'',--pld_ciudadania
							'',--pld_companias
							'',--pld_ind_validado
							'',--pld_ind_listas_negras
							CURRENT::datetime year to second,--fecha_carga
							CURRENT::datetime year to second--fecha_modifica
						);
					END IF;
					
			END FOREACH;
			
-- ****************************************************************************
-- *                       GENERACIÓN DE REPORTE                              *
-- ****************************************************************************	
			ELSE

					--- layout de archivo: APELLIDO PATERNO|APELLIDO MATERNO|NOMBRE(S)|FECHA DE NACIMIENTO(DDMMAAAA)|RFC
					LET cNombreArchivo = TRIM(cArchivoRep) || cYear || cMes || cDia || '.unl ';
					let cSQL = '';
					let cSQL=  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' 
					|| TRIM(cRuta_out) || TRIM(cNombreArchivo) || 
					' SELECT TRIM(hito_num_credito), hito_nombres, hito_fecha_nacimiento, hito_rfc, pld_ind_listas_negras FROM bdicred:"informix".sd_chi_pld_layout_sic /*WHERE ind_listas_negras = "0"*/;">'
					||TRIM(cRuta_out)|| TRIM(cNomSQL);
					system cSQL;
							
					let cSQL='chmod 777 '|| TRIM(cRuta_out)|| TRIM(cNomSQL);
					System cSQL;
							
					let cSQL = '';
					let cSQL= '/ifxsif01/bin/dbaccess bdicred ' || TRIM(cRuta_out) || TRIM(cNomSQL);
					system cSQL;					
					
					let cSQL = cSQL;
					let cSQL ='rm ' || TRIM(cRuta_out) || TRIM(cNomSQL);
					
					LET cNombreArchivo2 = TRIM(cArchivoRep) || cYear || cMes || cDia || '.txt ';
					
					system cSQL;
					let cSQL ='';
					let cSQL = "sed 's/|$//g' "|| TRIM(cRuta_out) || TRIM(cNombreArchivo) ||" >> "|| TRIM(cRuta_out) || TRIM(cNombreArchivo2);
					system cSQL;

					let cSQL = cSQL;
					let cSQL ='rm ' || TRIM(cRuta_out) || TRIM(cNombreArchivo);
					system cSQL;
					
					
			
		END IF
		RETURN cod_ret;	
    END	
END PROCEDURE;