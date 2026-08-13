CREATE PROCEDURE "informix".sp_ctanvl2_genotp(pNumCte CHAR(20),pNumCel CHAR(13))
	RETURNING CHAR(5) AS codret,
		CHAR(6) AS codigo_OTP;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalReg INTEGER; 
	DEFINE iExisteCte INTEGER;
	DEFINE cExisteOTP CHAR(6);
	DEFINE cCodigoOTP CHAR(6);
	DEFINE cUno CHAR(1);
	DEFINE cDos CHAR(1);
	DEFINE cTre CHAR(1);
	DEFINE cInit CHAR(10);
	DEFINE cResp CHAR(10);
	DEFINE dHora DATETIME HOUR TO SECOND;
	DEFINE GLOBAL seed DEC(10) DEFAULT 1;
    DEFINE d DEC(20,0);
    --DEFINE cOTP CHAR(6);
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaInsert DATE;
	DEFINE cExiste CHAR(1);
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotalReg = 0;
	LET iExisteCte = 0;
	LET cExisteOTP = '';
	LET cCodigoOTP = '';
	LET cUno = '';
    LET cDos = '';
    LET cTre = '';
    LET cInit = '';
    LET cResp = '';
    LET dHora = '';
    LET seed = 1;
    LET d = 0;
    --LET cOTP = '';
	LET cEmpresa = '001';
	LET dFechaInsert = '';
	LET cExiste = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN 
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCodigoOTP;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctanvl2_genotp.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDACION DE CAMPOS REQUERIDOS
		IF pNumCte IS NULL OR pNumCte = '' OR pNumCel IS NULL OR pNumCel = '' THEN
			LET cCodRet = '110'; 
			RETURN cCodRet, cCodigoOTP;
		END IF;
		
		IF LENGTH(pNumCel) <> 10 THEN
			LET cCodRet = '395'; 
			RETURN cCodRet, cCodigoOTP;
		END IF;
		
		--SE OBTIENE LA FECHA DEL SISTEMA
		SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} 
		fecha_hoy INTO dFechaInsert
		FROM bdinteg:"informix".si_fechas WHERE empresa = cEmpresa;
		
		--VALIDACION SI EXISTE CLIENTE
		SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente5)} 
		1 INTO cExiste
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = cEmpresa AND numcte = pNumCte;
		
		IF cExiste IS NULL THEN
			LET cCodRet = '384';
			RETURN cCodRet, cCodigoOTP;
		END IF;
		
		--GENERACION DE CODIGO OTP
		LET dHora = CURRENT HOUR TO fraction;
		LET d = SUBSTR(dHora, 7,1);	
		LET cUno = SUBSTR(pNumCel, d,1);
		LET d = SUBSTR(dHora, 4,1);	
		LET cDos = SUBSTR(pNumCel, d,1);
		LET d = SUBSTR(dHora, 2,1);	
		LET cTre = SUBSTR(pNumCel, d,1);
		LET cInit = SUBSTR(dHora, 7,2)||SUBSTR(dHora, 4,2)||cUno||cDos||cTre; 
		LET d = cInit::INT;
		LET d = seed * 1103515245 + d;
		LET seed = d - 4294967296 * TRUNC( d / 4294967296 );	
		LET cResp = MOD( TRUNC( seed / 65536 ), 32768 );
		
		LET cCodigoOTP = TRIM(cResp)||TRIM(cInit);
		
		IF LEN(cCodigoOTP) < 6 THEN
			LET cCodigoOTP = TRIM(RIGHT(pNumCel,2))||TRIM(cCodigoOTP)||TRIM(cResp)||TRIM(LEFT(pNumCel,2));
		END IF;
		
		SELECT cve_otp_gen
		INTO cExisteOTP
		FROM bdinteg:"informix".si_ctanvl2_genotp 
		WHERE numcte = pNumCte;
		
		IF NVL(cExisteOTP,'') = '' THEN
			INSERT INTO bdinteg:"informix".si_ctanvl2_genotp(numcte,tel_movil,cve_otp_gen,no_intentos,fecha_insert)
			VALUES(pNumCte,pNumCel,cCodigoOTP,0,dFechaInsert);
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '379';
				RETURN cCodRet,cCodigoOTP;
			END IF;
		ELSE 
			IF cExisteOTP <> cCodigoOTP THEN
				UPDATE bdinteg:"informix".si_ctanvl2_genotp	SET cve_otp_gen = cCodigoOTP, fecha_insert = dFechaInsert WHERE numcte = pNumCte;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '222';
					RETURN cCodRet, cCodigoOTP;
				END IF;
			END IF;
		END IF;
		
		RETURN cCodRet, cCodigoOTP;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica SÃ¡nchez Tlacomulco',
'FECHA: 23/06/2020',
'DESCRIPCION: SPL encargado de generar el codigo OTP del cliente',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_gensms(pTipoMsj CHAR(1),pIdMsj CHAR(10),pIdPlantilla CHAR(12),pNumCte CHAR(20),
pNumCta CHAR(20),pNumTarjeta CHAR(16),pTipoProc CHAR(1),pStr1 CHAR(30),pStr2 CHAR(30),pStr3 CHAR(30),pStr4 CHAR(30),pStr5 CHAR(150),
pStr6 CHAR(100),pStr7 CHAR(60),pStr8 CHAR(60),pStr9 CHAR(15),pStr10 CHAR(100),pCorreoAlterno CHAR(100),pCelularAlterno CHAR(10),
pImporte1 MONEY(16,2),pImporte2 MONEY(16,2),pImporte3 MONEY(16,2),pImporte4 MONEY(16,2),pImporte5 MONEY(16,2),
pFecha1 DATETIME YEAR TO FRACTION(3),pFecha2 DATETIME YEAR TO FRACTION(3))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cBandera VARCHAR(100);
	DEFINE cDia CHAR(2);
	DEFINE cMes CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cMes1 CHAR(10);
	DEFINE cExiste CHAR(1);
	DEFINE cNumCte CHAR(20);
	DEFINE cTtransactionId CHAR(12);
	DEFINE cTablaNotif CHAR(50);
	DEFINE cPermiteInsertar CHAR(1);
	DEFINE cCodAlerta CHAR(3);
	DEFINE iActInac INTEGER;
	DEFINE cExisteCte CHAR(20);
	DEFINE cFecha1Aux VARCHAR(100);
	DEFINE cFecha2Aux VARCHAR(100);
	DEFINE cNumCtaAux CHAR(22);
	DEFINE cNumTarjetaAux CHAR(18);
	DEFINE cInsStmt LVARCHAR(2000);
	
	LET cCodRet = '000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cBandera = '';
	LET cDia = '';
	LET cMes = '';
	LET cAnio = '';
	LET cMes1 = '';
	LET cExiste = '';
	LET cNumCte = '';
	LET cTtransactionId = '';
	LET cTablaNotif = '';
	LET cPermiteInsertar = '';
	LET cCodAlerta = '';
	LET iActInac = 0;
	LET cExisteCte = '';
	LET cFecha1Aux = '';
	LET cFecha2Aux = '';
	LET cNumCtaAux = '';
	LET cNumTarjetaAux = '';
	LET cInsStmt = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlerr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctanvl2_gensms.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDA CAMPOS REQUERIDOS
		IF pTipoMsj IS NULL OR pTipoMsj = '' OR pIdMsj IS NULL OR pIdMsj = '' OR 
		pIdPlantilla IS NULL OR pIdPlantilla = '' OR pNumCte IS NULL OR pNumCte = '' OR 
		pNumCta IS NULL OR pNumCta = '' OR pTipoProc  IS NULL OR pTipoProc  = '' OR 
		pStr1 IS NULL OR pStr1 = '' OR pFecha1 IS NULL OR pFecha1 = '' OR 
		pFecha2 IS NULL OR pFecha2 = '' THEN
			LET cCodRet = '110';
			RETURN cCodRet;
		END IF;
		
		--
		SELECT {+INDEX (bdimnsj:"informix".mnsj_param idxmnsj_par)} valor INTO cBandera 
		FROM bdimnsj:"informix".mnsj_param WHERE cod_param = '5';
		
		IF TRIM(cBandera) = '0' THEN
			RETURN cCodRet;
		END IF;
		
		--VERIFICA SI SE TRATA DE UN PROCESO VALIDO
		IF pTipoProc > '2' OR pTipoProc = '0'THEN
		   LET cCodRet = '392';
		   RETURN cCodRet;
		END IF;
		
		--VERIFICA QUE SEA UN TIPO DE MENSAJE VALIDO
		IF pTipoMsj > '3' OR pTipoMsj = '0' THEN
			LET cCodRet = '393';
			RETURN cCodRet;
		END IF;
		
		--VALIDACION DE FECHA FORMATO DE MES NOMBRE COMPLETO    
		IF pIdMsj IN ('POS_CREDE','ATM_CREDE') THEN
			
			SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)}
			DAY(fecha_hoy),MONTH(fecha_hoy),YEAR(fecha_hoy) 
			INTO cDia,cMes,cAnio
			FROM bdinteg:"informix".si_fechas WHERE empresa = cEmpresa;
			
			IF (cMes = '1') THEN 
				LET cMes1 = 'ENERO';  
			ELIF (cMes = '2') THEN 
				LET cMes1 = 'FEBRERO';
			ELIF (cMes = '3') THEN 
				LET cMes1 = 'MARZO';
			ELIF (cMes = '4') THEN 
				LET cMes1 = 'ABRIL';
			ELIF (cMes = '5') THEN 
				LET cMes1 = 'MAYO';
			ELIF (cMes = '6') THEN 
				LET cMes1 = 'JUNIO';
			ELIF (cMes = '7') THEN 
				LET cMes1 = 'JULIO';
			ELIF (cMes = '8') THEN 
				LET cMes1 = 'AGOSTO';
			ELIF (cMes = '9') THEN 
				LET cMes1 = 'SEPTIEMBRE';
			ELIF (cMes = '10') THEN 
				LET cMes1 = 'OCTUBRE';
			ELIF (cMes = '11') THEN 
				LET cMes1 = 'NOVIEMBRE';
			ELIF (cMes = '12') THEN 
				LET cMes1 = 'DICIEMBRE';
			END IF;
			
			LET pStr5 = TRIM(cDia)||'-'||TRIM(cMes1)||'-'||TRIM(cAnio);
		
		ELIF pIdMsj IN ('SPEI_SMREC','SPEI_TRREC') THEN
			LET pTipoProc = '1';
		END IF;	
		
		--VALIDA EL NUMERO DE CLIENTE
		IF SUBSTR(pIdMsj,1,3)<>"WEB" THEN
			IF (TRIM(pNumCte) <> '000000000') THEN
				
				SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente5)} 
				1 INTO cExiste
				FROM bdinteg:"informix".si_cliente
				WHERE empresa = cEmpresa AND numcte = pNumCte;
				
				IF cExiste IS NULL THEN
					LET cCodRet = '384';
					RETURN cCodRet;
				END IF;
				
			END IF;
		END IF;
		
		LET cNumCte = pNumCte;
		LET cTtransactionId = 'NULL';
		
		--SYNDEIN
        SELECT {+AVOID_FULL(bdimnsj:"informix".notif_cfg)} 
		nombre_tabla
		INTO cTablaNotif
		FROM bdimnsj:"informix".notif_cfg
		WHERE id_mensaje = pIdMsj
		AND tipo_mensaje = pTipoMsj
		AND tipo_proceso = pTipoProc;
		
        IF (cTablaNotif IS NULL OR cTablaNotif = '') THEN
			SELECT {+AVOID_FULL(bdimnsj:"informix".notif_cfg)}
			nombre_tabla
			INTO cTablaNotif
			FROM bdimnsj:"informix".notif_cfg
			WHERE id_mensaje = 'DEFAULT'
			AND tipo_mensaje = pTipoMsj
			AND tipo_proceso = pTipoProc;
        END IF;
		
		SELECT {+AVOID_FULL(bdimnsj:"informix".notif_cfg)}
		FIRST 1 permite_insertar
		INTO cPermiteInsertar
		FROM bdimnsj:"informix".notif_cfg
		WHERE nombre_tabla = cTablaNotif;
		
		IF cPermiteInsertar = 'F' THEN
			LET cCodRet = '394';
			RETURN cCodRet;
		END IF;
		
		IF pIdMsj IN ('CUB_EMAIL','CUB_SMS') AND cNumCte NOT IN ('','000000000') THEN
			SELECT {+AVOID_FULL(bdimnsj:"informix".mnsjr_cat_suscripcion)}
			FIRST 1 codigo INTO cCodAlerta 
			FROM bdimnsj:"informix".mnsjr_cat_suscripcion 
			WHERE id_mensaje = pIdMsj AND id_plantilla = pIdPlantilla;
			
			IF NVL(cCodAlerta,'') <> '' THEN
				SELECT {+INDEX (bdimnsj:"informix".mnsjr_suscripcion_ctes idx01_suscripcion_ctes)}
				COUNT(*) INTO iActInac 
				FROM bdimnsj:"informix".mnsjr_suscripcion_ctes 
				WHERE numcte = cNumCte AND codigo = cCodAlerta;
				
				IF NVL(iActInac,0) > 0 THEN
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
		
		IF pTipoProc = '1' AND pIdMsj = 'OFI_AVSMS' AND pIdPlantilla <> 'OFI_CNCEL3' THEN
			
			SELECT {+AVOID_FULL(bdimnsj:"informix".mnsjr_trx_online)} cliente INTO cExisteCte 
		    FROM bdimnsj:"informix".mnsjr_trx_online 
		    WHERE cliente = cNumCte AND id_mensaje = pIdMsj AND id_plantilla <> 'OFI_CNCEL3' 
		    AND celular_alterno = pCelularAlterno AND fecha_hora_registro >= today;
			
			IF cExisteCte IS NOT NULL THEN
				RETURN cCodRet;
			END IF;
		END IF;
		
		IF (pImporte1 IS NULL OR pImporte1 = '') THEN
            LET pImporte1 = 0.00;
        END IF;
		IF (pImporte2 IS NULL OR pImporte2 = '') THEN
			LET pImporte2 = 0.00;
        END IF;
		IF (pImporte3 IS NULL OR pImporte3 = '') THEN
			LET pImporte3 = 0.00;
        END IF;
		IF (pImporte4 IS NULL OR pImporte4 = '') THEN
			LET pImporte4 = 0.00;
        END IF;
		IF (pImporte5 IS NULL OR pImporte5 = '') THEN
			LET pImporte5 = 0.00;
        END IF;
		
		LET cFecha1Aux = "'"||pFecha1||"'::DATETIME YEAR TO FRACTION(3)";
        LET cFecha2Aux = "'"||pFecha2||"'::DATETIME YEAR TO FRACTION(3)";
        LET cNumCtaAux = "'"||TRIM(pNumCta)||"'";
        
		IF (pStr1 IS NULL) THEN
			LET pStr1 = '';
        END IF;
		IF (pStr2 IS NULL) THEN
			LET pStr2 = '';
        END IF;
		IF (pStr3 IS NULL) THEN
			LET pStr3 = '';
        END IF;
		IF (pStr4 IS NULL) THEN
			LET pStr4 = '';
        END IF;
		IF (pStr5 IS NULL) THEN
			LET pStr5 = '';
        END IF;
		IF (pStr6 IS NULL) THEN
			LET pStr6 = '';
        END IF;
		IF (pStr7 IS NULL) THEN
			LET pStr7 = '';
        END IF;
		IF (pStr8 IS NULL) THEN
			LET pStr8 = '';
        END IF;
		IF (pStr9 IS NULL) THEN
			LET pStr9 = '';
        END IF;
		IF (pStr10 IS NULL) THEN
			LET pStr10 = '';
        END IF;
		
		IF (pCorreoAlterno IS NULL) THEN
			LET pCorreoAlterno = '';
        END IF;
		IF (pCelularAlterno IS NULL) THEN
			LET pCelularAlterno = '';
        END IF;
		IF (cNumCte IS NULL) THEN
			LET cNumCte = '';
        END IF;
		IF (pNumTarjeta IS NULL) THEN
			LET cNumTarjetaAux = 'NULL';
        ELSE
			LET cNumTarjetaAux =  "'"||TRIM(pNumTarjeta)||"'";
        END IF;
		
		LET cInsStmt = "INSERT INTO "||cTablaNotif||"(tipo_mensaje,id_mensaje,id_plantilla,cliente,cuenta,tarjeta,transaction_id,estatus,fecha_hora_registro,fecha_hora_recuperado,"||
		"string1,string2,string3,string4,string5,string6,string7,string8,string9,string10,correo_alterno,celular_alterno,importe1,importe2,importe3,importe4,importe5,fecha1,fecha2)"||
		" VALUES('"||pTipoMsj||"','"||pIdMsj||"','"||pIdPlantilla||"','"||cNumCte||"',"||cNumCtaAux||","||cNumTarjetaAux||","||cTtransactionId||",null,CURRENT,'','"||
		pStr1||"','"||pStr2||"','"||pStr3||"','"||pStr4||"','"||pStr5||"','"||pStr6||"','"||pStr7||"','"||pStr8||"','"||pStr9||"','"||pStr10||"','"||
		pCorreoAlterno||"','"||pCelularAlterno||"','"||pImporte1||"','"||pImporte2||"','"||pImporte3||"','"||pImporte4||"','"||pImporte5||"',"||cFecha1Aux||","||cFecha2Aux||")";
		EXECUTE IMMEDIATE cInsStmt;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 25/06/2020',
'DESCRIPCION: SPL encargado de realizar la insercion de datos a la tabla sobre la cual posteriormente se consultara',
'la informacion necesaria para el envio de un MSN confirmando el alta del cliente.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_valdatos(pNombre1 CHAR(26),pNombre2 CHAR(26),pApellPaterno CHAR(26),pApellMaterno CHAR(26),
pFechaNac DATE,pGenero CHAR(1),pNacionalidad CHAR(3),pTpoPersona CHAR(2))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cExiste CHAR(1);
	DEFINE cEsFisica CHAR(1);
	
	LET cCodRet = '000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cMes = '';
	LET cDia = '';
	LET cAnio = '';
	LET cExiste = '';
	LET cEsFisica = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlerr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctanvl2_valdatos.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDA CAMPOS REQUERIDOS
		IF pNombre1 IS NULL OR pNombre1 = '' OR pApellPaterno IS NULL OR pApellPaterno = '' OR 
		pFechaNac IS NULL OR pFechaNac = '' OR pGenero IS NULL OR pGenero = '' OR 
		pNacionalidad IS NULL OR pNacionalidad = '' OR pTpoPersona IS NULL OR pTpoPersona = '' THEN
			LET cCodRet = '110';
			RETURN cCodRet;
		ELSE
			--ASIGNACION DE VALORES
			LET cMes = SUBSTR(pFechaNac,1,2);
			LET cDia = SUBSTR(pFechaNac,4,2);
			LET cAnio = SUBSTR(pFechaNac,7,4);
		END IF;
		
		--VALIDA FORMATO DE FECHA
		IF (cMes <> MONTH(pFechaNac)) OR (cDia <> DAY(pFechaNac)) OR (cAnio <> YEAR(pFechaNac)) THEN
			LET cCodRet = '195';
			RETURN cCodRet;
		ELSE
			IF (cMes::INTEGER > 12) THEN
				LET cCodRet = '184';
				RETURN cCodRet;
			END IF;
			IF (cDia::INTEGER > 31) THEN
				LET cCodRet = '185';
				RETURN cCodRet;
			END IF;
		END IF;
		
		--VALIDA QUE EL GENERO SEA MASCULINO = 'M' O FEMENINO = 'F'  
		IF pGenero NOT IN ('M','F') THEN
			LET cCodRet = '377';
			RETURN cCodRet;
		END IF;
		
		--VALIDA NACIONALIDAD
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_nacion
		WHERE nacion = pNacionalidad;
		
		IF cExiste IS NULL THEN
			LET cCodRet = '124';
			RETURN cCodRet;
		END IF;
		
		--VALIDA SI TIPO DE PERSONA SEA FISICA = '01' O FISICA EMPRESARIAL = '03'
		SELECT {+INDEX (bdinteg:"informix".si_tipper ix193_1)} 
		UPPER(es_fisica) INTO cEsFisica
		FROM bdinteg:"informix".si_tipper
		WHERE tpo_persona = pTpoPersona;
		
		IF cEsfisica <> 'S' THEN
			LET cCodRet = '120';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 17/06/2020',
'DESCRIPCION: SPL encargado de realizar la validacion de los datos del cliente.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_valotp(pNumCte CHAR(20),pNumCel CHAR(13),pOtp CHAR(6))
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER; 
	DEFINE iExisteCte INTEGER;
	DEFINE sIntenPerm SMALLINT;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaInsert DATE;
	DEFINE cCodigoOtp CHAR(6);
	DEFINE sNoIntentos SMALLINT;
	DEFINE cExiste CHAR(1);
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExisteCte = 0;
	LET sIntenPerm = 0;
	LET cEmpresa = '001';
	LET dFechaInsert = '';
	LET cCodigoOtp = '';
	LET sNoIntentos = 0;
	LET cExiste = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN 
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctanvl2_valotp.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDACION DE CAMPOS REQUERIDOS
		IF pNumCte IS NULL OR pNumCte = '' OR pNumCel IS NULL OR pNumCel = '' OR pOtp IS NULL OR pOtp = '' THEN
			LET cCodRet = '110';
			RETURN cCodRet;
		END IF;
		
		IF LENGTH(pNumCel) <> 10 OR LENGTH(pOtp) <> 6 THEN
			LET cCodRet = '395'; 
			RETURN cCodRet;
		END IF;
		
		--SE OBTIENE LA FECHA DEL SISTEMA
		SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} 
		fecha_hoy INTO dFechaInsert
		FROM bdinteg:"informix".si_fechas WHERE empresa = cEmpresa;
		
		--VALIDACION SI EXISTE CLIENTE
		SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente5)} 
		1 INTO cExiste
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = cEmpresa AND numcte = pNumCte;
		
		IF cExiste IS NULL THEN
			LET cCodRet = '384';
			RETURN cCodRet;
		END IF;
		
		--SE OBTIENE NUMERO DE INTENTOS PERMITIDOS
		SELECT {+INDEX (bdinteg:"informix".si_param ix_si_param)} 
		valor INTO sIntenPerm
		FROM bdinteg:"informix".si_param WHERE cod_param = 485;
	   
		SELECT cve_otp_gen, no_intentos
		INTO cCodigoOtp, sNoIntentos
		FROM bdinteg:"informix".si_ctanvl2_genotp
		WHERE numcte = pNumCte;
		
		IF cCodigoOtp IS NULL OR cCodigoOtp = '' THEN 
			LET cCodRet = '372'; 
		ELSE
			IF sNoIntentos >= sIntenPerm THEN
				LET cCodRet = '370';
			ELSE
				IF cCodigoOtp = pOtp THEN
					UPDATE bdinteg:"informix".si_ctanvl2_genotp
					SET cve_otp_rec = pOtp, no_intentos = sNoIntentos + 1
					WHERE numcte = pNumCte;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '222';
						RETURN cCodRet;
					END IF;
				ELSE
					UPDATE bdinteg:"informix".si_ctanvl2_genotp
					SET no_intentos = sNoIntentos + 1
					WHERE numcte = pNumCte;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '222';
						RETURN cCodRet;
					END IF;
					
					LET cCodRet = '371'; 
				END IF;	
			END IF;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica SÃ¡nchez Tlacomulco',
'FECHA: 23/06/2020',
'DESCRIPCION: SPL encargado de validar el cÃ³digo OTP del cliente',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_eliminapdf()
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cExiste CHAR(1);
	DEFINE cEsFisica CHAR(1);
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cReporteHist CHAR(100);
	DEFINE dFechaHoy DATE;
	DEFINE cSQL CHAR(500);
	DEFINE cEjecuta CHAR(1);
	
	LET cCodRet = '000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cMes = '';
	LET cDia = '';
	LET cAnio = '';
	LET cExiste = '';
	LET cEsFisica = '';
	LET cRutaArchivo = '';
	LET cReporteHist = '';
	LET dFechaHoy = '';
	LET cSQL = '';
	LET cEjecuta = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlerr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_ctanvl2_eliminapdf.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} 
		fecha_hoy INTO dFechaHoy
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = cEmpresa;
		
		SELECT ejecuta 
          INTO cEjecuta 
          FROM bdinteg:"informix".si_ctanvl2_ctrlelimina 
         WHERE fecha_ej = dFechaHoy;
		
		IF NVL(cEjecuta,'') <> 't' THEN
			
			INSERT INTO bdinteg:"informix".si_ctanvl2_ctrlelimina(ejecuta,fecha_ej) VALUES('t',dFechaHoy);
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '379';
				--RETURN cCodRet;
			END IF;
			
			SELECT {+INDEX (bdinteg:"informix".si_param ix_si_param)} 
			valor INTO cRutaArchivo
			FROM bdinteg:"informix".si_param WHERE cod_param = 490;
			
			FOREACH
			
				SELECT nom_reporte
				INTO cReporteHist
				FROM bdinteg:"informix".si_ctanvl2_ctrlrep 
				WHERE TO_DATE(fecha_gen, '%d/%m/%Y') < dFechaHoy
				
				LET cSQL = '';
				LET cSQL = '/usr/bin/rm -rf '||TRIM(cRutaArchivo)||'caratulasPDF/'||TRIM(cReporteHist);
				SYSTEM cSQL;
				
				DELETE FROM bdinteg:"informix".si_ctanvl2_ctrlrep WHERE nom_reporte = TRIM(cReporteHist);
				
			END FOREACH;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/07/2020',
'DESCRIPCION: SPL encargado de realizar la eliminacion de todos los archivos PDF generados anteriores a la fecha hoy (T-1).',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_ctanvl2_gencaratula(pNumCte CHAR(20),pNumCta CHAR(20))
	RETURNING CHAR(5) AS codret,
		CHAR(40) AS producto;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cExiste CHAR(1);
	DEFINE cProducto CHAR(40);
	
	LET cCodRet = '000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cExiste = '';
	LET cProducto = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlerr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cProducto;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctanvl2_gencaratula.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDA CAMPOS REQUERIDOS
		IF pNumCte IS NULL OR pNumCte = '' OR pNumCta IS NULL OR pNumCta = '' THEN
			LET cCodRet = '110';
			RETURN cCodRet,cProducto;
		END IF;
		
		SELECT {+INDEX (bdinteg:"informix".sc_maechq idx_sc_maechq)} {+INDEX (bdinteg:"informix".sc_producto idxscproductopba)} 
		pro.nombre INTO cProducto
		FROM bdicheq:"informix".sc_maechq AS mae, bdicheq:"informix".sc_producto AS pro
		WHERE mae.cuenta = pNumCta AND mae.producto = pro.producto;
		
		RETURN cCodRet,cProducto;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 15/07/2020',
'DESCRIPCION: SPL encargado de consultar el detalle de la informacion que sera implementada para la generacion de la caratula.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_rpt_cte_biometria()
returning char(5) as CodRet;

DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err     INT;
DEFINE sFecha       CHAR(10);
DEFINE sfechaInicial CHAR(10);
DEFINE sfechaFinal   CHAR(10);
DEFINE sFechaArch   CHAR(10);
DEFINE cCmd1        CHAR(10000);
DEFINE cCmd2        CHAR(10000);
DEFINE cCmd3        CHAR(10000);
DEFINE cCmd4        CHAR(10000);
DEFINE cCmd5        CHAR(10000);
DEFINE cCmd6        CHAR(10000);
DEFINE cCmd7        CHAR(10000);
DEFINE cCmd8        CHAR(10000);
DEFINE cCmd9        CHAR(10000);
DEFINE cCmd11        CHAR(10000);
DEFINE cCmd12       CHAR(10000);
DEFINE cQuery        CHAR(10000);
DEFINE cQueryD        CHAR(10000);
DEFINE cQueryM        CHAR(10000);
DEFINE cQueryMB        CHAR(10000);
DEFINE cQueryMD        CHAR(10000);
DEFINE cQueryMBD        CHAR(10000);
DEFINE pArchDescarga CHAR(100);
DEFINE pArchDescargaG CHAR(100);
DEFINE pArchDescargaM CHAR(100);
DEFINE pArchDescargaMG CHAR(100);
DEFINE pArchDescargaMB CHAR(100);
DEFINE sDia          CHAR(2);
DEFINE sMes          CHAR(2);
DEFINE sYear         CHAR(4);
DEFINE dFbio         INT;

LET cCodRet 		='00000';
LET iSql_err        =0;
LET sFecha          ='';
LET sfechaInicial   ='';
LET sfechaFinal     ='';
LET cCmd1           ='';
LET cCmd2           ='';
LET cCmd3           ='';
LET cCmd4           ='';
LET cCmd5           ='';
LET cCmd6           ='';
LET cCmd7           ='';
LET cCmd8           ='';
LET cCmd9           ='';
LET cCmd11           ='';
LET cCmd12          ='';
LET pArchDescarga   ='';
LET pArchDescargaG   ='';
LET pArchDescargaM  ='';
LET pArchDescargaMG  ='';
LET pArchDescargaMB  ='';
LET sFechaArch      ='';
LET sDia            ='';
LET sMes            ='';
LET sYear           ='';
LET cQuery			='';
LET cQueryD			='';
LET cQueryM			='';
LET cQueryMB	    ='';
LET cQueryMD	    ='';
LET cQueryMBD	    ='';
LET dFbio           =0;

BEGIN

    ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
    
    ---SET DEBUG FILE TO '/RESPALDOSNEW/sp_rpt_cte_biometria.out';
    ---TRACE ON;
	
	
    LET sfecha = (select fecha_hoy from si_fechas WHERE empresa = "001");
    --LET sFechaArch=(select REPLACE(fecha_hoy,'/','') from si_fechas);

    LET sDia=(select day(fecha_hoy) from si_fechas);
    LET sMes=(select month(fecha_hoy) from si_fechas);
    LET sYear=(select year(fecha_hoy) from si_fechas);

    LET sfechaInicial = (SELECT TO_CHAR(fecha_hoy - 1 units month, '%m/%d/%Y') FROM bdinteg:si_fechas WHERE empresa = "001");
	LET sfechaFinal = (SELECT TO_CHAR(fecha_ant, '%m/%d/%Y') FROM bdinteg:si_fechas WHERE empresa = "001");
    IF LENGTH(sDia)<2 THEN
         LET sDia="0"||sDia;
    END IF;

    IF LENGTH(sMes)<2 THEN
         LET sMes="0"||sMes;
    END IF;

    LET sFechaArch=sDia||sMes||sYear;

    LET pArchDescarga='"/RESPALDOSNEW/reporte_clientes_biometria_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaG='"/RESPALDOSNEW/reporte_clientes_biometria_gral_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaM='"/RESPALDOSNEW/reporte_clientes_biometria_mes_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaMG='"/RESPALDOSNEW/reporte_clientes_biometria_mes_gral_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
	LET pArchDescargaMB='"/RESPALDOSNEW/reporte_clientes_biometria_mes_dfb_'||TRIM(sFechaArch)||'.txt" delimiter "|" ';
		

                ---Se consulta la tabla principal y se crea la tabla temporal con los indices.
        ---LET cCmd1 ='select numcte,tipo_cliente,tpo_persona,tpo_biometria,fecha_insert FROM bdinteg:si_cliente WHERE tipo_cliente="1" and tpo_persona="01" and fecha_insert<today INTO TEMP si_cliente_bio with no log; CREATE INDEX si_cliente_temp_idx on si_cliente_bio (numcte,tipo_cliente,tpo_persona,tpo_biometria,fecha_insert);';
			
		 		---De la tabla pricipal se obtiene el total de clientes titulares, total de clientes titulares con biometria.
		LET cCmd2 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and tpo_biometria="1" and fecha_insert< "'||sFecha||'"';
		LET cCmd3 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and fecha_insert< "'||sFecha||'"';
	
			    ---De la tabla pricipal se obtiene el total de clientes titulares y total de clientes titulares con biometria del mes.
     	
		LET cCmd4 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and tpo_biometria="1" and fecha_insert between "'||sfechaInicial||'" and "'||sfechaFinal||'"';	
       	LET cCmd5 = 'select count(*) from bdinteg:si_cliente where tipo_cliente="1" and tpo_persona="01" and tpo_biometria="0" and fecha_insert between "'||sfechaInicial||'" and "'||sfechaFinal||'"';
		
		
		---Se obtiene el total de cliente con fecha alta diferente a la fecha registro de biometria.
		LET cCmd6 = 'select count(cte.numcte) from bdinteg:si_cliente cte inner join bdirostros@coppelimg_tcp:si_cte_rostro bio on cte.numcte=bio.numcte and cte.fecha_insert<>bio.fecha_alta and cte.fecha_insert between "'||sfechaInicial||'" and "'||sfechaFinal||'" where cte.tipo_cliente= "1" and cte.tpo_biometria= "1"';
	
	
	 ---Se realiza la union de las dos consultas generales
	    ---LET cCmd7 = TRIM(cCmd2)||" UNION "||TRIM(cCmd3);
		LET cCmd7 = TRIM(cCmd2);
		LET cCmd11 = TRIM(cCmd3);
		LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd7)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
		LET cQueryD = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaG)||"  "||TRIM(cCmd11)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
		---LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd2)||" UNION "||TRIM(cCmd3)|| " " || " UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd7)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	    ---LET cQuery = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd1)||" " || " UNLOAD TO "||TRIM(pArchDescarga)||"  "||TRIM(cCmd7)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	  
	 ---Se realiza la union de las consultas por mes
	    LET cCmd8 = TRIM(cCmd4);
		LET cCmd12 = TRIM(cCmd5);
		LET cQueryM = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaM)||"  "||TRIM(cCmd8)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 "; 	  	 	 
		LET cQueryMD = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaMG)||"  "||TRIM(cCmd12)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 "; 	  	 	 
	    ----LET cQueryM = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd1)||" " || " UNLOAD TO "||TRIM(pArchDescargaM)||"  "||TRIM(cCmd8)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";

	---Se descarga el resultado de la consulta entre la bdinteg:si_cliente y la bdidigital@coppelimg_tcp:si_cte_rostro.
	    LET cCmd9 = TRIM(cCmd6);
		LET cQueryMB = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO "||TRIM(pArchDescargaMB)||"  "||TRIM(cCmd9)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1";
		---LET cQueryMB = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd6)||" " || " UNLOAD TO "||TRIM(pArchDescargaMB)||"  "||TRIM(cCmd9)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	    ---LET cQueryMB = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; " || TRIM(cCmd1)||" " || " UNLOAD TO "||TRIM(pArchDescargaMB)||"  "||TRIM(cCmd9)||"' | /ifxsif01/bin/dbaccess bdinteg > /dev/null 2>&1 ";
	 
	    SYSTEM TRIM(cQuery);
	    SYSTEM TRIM(cQueryD);
        SYSTEM TRIM(cQueryM);
		SYSTEM TRIM(cQueryMD);
	    SYSTEM TRIM(cQueryMB);
		

	

RETURN cCodRet;
END;
END PROCEDURE;