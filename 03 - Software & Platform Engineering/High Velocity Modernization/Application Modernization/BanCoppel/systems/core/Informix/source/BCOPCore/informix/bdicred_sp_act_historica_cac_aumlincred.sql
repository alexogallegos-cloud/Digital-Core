CREATE PROCEDURE "informix".sp_act_historica_cac_aumlincred ()
	RETURNING 
				CHAR (6) 	AS Codigo_Retorno,
				CHAR (80)	AS Mensaje_Retorno;

	DEFINE cCod_Ret			CHAR (6);
	DEFINE cMensaje			CHAR (80);
	DEFINE iSql_Err			INTEGER;
	DEFINE iContador		INTEGER;
	DEFINE dtFecha_Insert 	DATE;
	DEFINE cNum_Solicitud 	CHAR (20);
	DEFINE dtFecha_Status 	DATE;
	DEFINE iBandera  		INTEGER;
	DEFINE iInfo			INTEGER;

	LET cCod_Ret 		= '000000';
	LET cMensaje		= 'EJECUCION EXITOSA.';
	LET iSql_Err		= 0;
	LET iContador		= 0;
	LET dtFecha_Insert 	= DATE (1);
	LET cNum_Solicitud 	= '';
	LET dtFecha_Status 	= DATE (1);
	LET iBandera 		= 0;
	LET iInfo			= 0;
	BEGIN
		ON EXCEPTION SET iSql_Err
			IF iSql_Err <> 0 THEN
				LET cCod_Ret = iSql_Err;
				LET cMensaje = 'ERROR NO CONTROLADO DE INFORMIX.';
				IF iSql_Err = -535 THEN
					ROLLBACK WORK;
					LET cMensaje = 'SE ENCONTRABA UNA TRANSACCION ABIERTA HA SIDO CERRADA, EJECUTE DE NUEVO.';
				END IF;
				RETURN cCod_Ret, cMensaje;
			END IF
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_act_historica_cac_aumlincred.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH WITH HOLD
			--Se obtienes datos para el filtro de la actualizacion y la fecha_insert con la que se 
			--actualizara en el campo fecha_inser de la tabla sd_historica_cac_aumlincred.
			SELECT num_solicitud, fecha_insert, fecha_status
			INTO cNum_Solicitud,dtFecha_Insert,dtFecha_Status
			FROM "informix".sd_bitacora_aumlincred
			WHERE empresa ='001'
			AND fecha_insert  > mdy(12,1,2012)
			AND origen = 'S'
			ORDER BY num_solicitud
			
			IF iBandera = 0 THEN 
				BEGIN WORK;
				LET iBandera = 1;
			END IF
			-- Actualiza la tabla.
			UPDATE "informix".sd_historica_cac_aumlincred
				SET fecha_insert = dtFecha_Insert
			WHERE solicitud = cNum_Solicitud
			AND fecha_insert BETWEEN dtFecha_Insert AND dtFecha_Status;
			
			LET iInfo = dbinfo("sqlca.sqlerrd2");
			LET iContador = iContador + iInfo;

			IF iContador >= 1500 THEN
				COMMIT WORK;
				LET iBandera = 0;
				LET iContador = 0;
			END IF
		END FOREACH
		IF  iBandera = 1 THEN
			COMMIT WORK;
		END IF;
		RETURN cCod_Ret, cMensaje;
	END;
END PROCEDURE
DOCUMENT
'Autor: Mario Gamaliel Olivo Urias',
'DESCRIPCION: Actualiza la fecha_insert de la tabla sd_historica_cac_aumlincred con status AP y Origen ',
'             Sucursal de la tabla sd_bitacora_aumlincred',
'FECHA: 03/JUNIO/2013',
'BD : BDICRED',
'VERSION: 20130603.1045';

CREATE PROCEDURE "informix".sp_obtenerexcepcionescac(pEmpresa CHAR(3),pNumCredito CHAR(20),pFecha  DATE)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION,
	CHAR(3) AS CVE_EXCEPCION,
	VARCHAR(100) AS DESC_EXCEPCION; 

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		CHAR(80);
	DEFINE cExcepcion		CHAR(3);
	DEFINE cDescExcepcion	VARCHAR(100);
	
	---INICIALIZACIONES
    LET iSqlErr				= 0;
    LET iIsamErr			= 0;
    LET cErrorInfo			= '';
    LET cCodRet				= '000000';
    LET cMensajeRet			= 'Proceso Exitoso';
	LET cExcepcion			= '';
	LET cDescExcepcion		= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet, cExcepcion, cDescExcepcion;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO "/tmp/has/sp_obtenerexcepcionescac.out";
	---TRACE ON;
	
	IF NOT EXISTS (SELECT empresa FROM bdinteg:'informix'.si_empresas WHERE empresa = pEmpresa) OR (NVL(pNumCredito,'') = '') THEN
        LET cCodRet = '000001';
		LET cMensajeRet = 'EMPRESA NO ES VALIDA O EL NUM. DE CREDITO ESTA VACIO';
		RETURN cCodRet, cMensajeRet, cExcepcion, cDescExcepcion;
	ELSE
		-- BARRE LAS EXCEPCIONES QUE TIENE ARRASTRANDO LA SOLICITUD
		FOREACH WITH HOLD
			SELECT DISTINCT se.excepciones, e.descripcion
			INTO cExcepcion, cDescExcepcion
			FROM bdicred:'informix'.sd_sol_excepciones_aumlincred se, bdicred:'informix'.sd_excepciones_aumlincred e
			WHERE se.empresa = pEmpresa
			AND e.empresa = pEmpresa
			AND se.excepciones = e.clave_excepcion
			AND se.num_solicitud = pNumCredito  
			AND se.fecha_insert = pFecha
				
			RETURN cCodRet, cMensajeRet, cExcepcion, cDescExcepcion WITH RESUME;
		END FOREACH
		-- VALIDA SI LA SOLICITUD NO TIENE EXCEPCIONES
	    IF dbinfo('sqlca.sqlerrd2') = 0 THEN
	        LET cCodRet = '000002';
	        LET cMensajeRet = 'NO EXISTEN EXCEPCIONES PARA ESTE CREDITO';
			RETURN cCodRet, cMensajeRet, cExcepcion, cDescExcepcion;
	    END IF    
    END IF
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener la clave y la descripcion de las excepciones que tiene una solicitud de crédito', 
'AUTOR: Mohamed Carreón ',
'FECHA: Noviembre 2011',
'VERSION: 20111104.1245';

CREATE PROCEDURE "informix".sp_registrarrespuestacte
(
pEmpresa char(3),
pNumSolicitud char(20),
pRespCte char(3),
pPregunta char(200),
pSucursal char(4),
pEjecutivo char(8)
)

RETURNING char(5) as cod_ret, char(80) as mensaje;

DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vMen char(80);
DEFINE vCont smallint;
DEFINE vFecha date;
DEFINE cErrorInfo char(80);
DEFINE iIsamErr smallint;
DEFINE cCod_Ret char(6);
DEFINE vMenSP char(80);
DEFINE vFechaFin date;
DEFINE vFechaIni date;
DEFINE vfecha_insert date;
DEFINE vDias smallint;
DEFINE vNombreEjec char(45);
DEFINE cStatus char(02);
DEFINE vLinCred    DECIMAL(18,2);
DEFINE cNumproducto CHAR(04);
DEFINE vIncremento DECIMAL(18,2);
DEFINE cSucursal   CHAR(04);
DEFINE viCteNoEsTitPV SMALLINT;
DEFINE pMedioRes CHAR(1);

LET cod_ret = '00000';
LET sql_err = 0;
LET vMen = 'El proceso se ejecuto correctamente';
LET vCont = 0;
LET vFecha = date(1);
LET cErrorInfo = '';
LET iIsamErr = 0;
LET cCod_Ret = '000000';
LET vMenSP = '';
LET vFechaFin = date(1);
LET vFechaIni = date(1);
LET vfecha_insert = date(1);
LET vDias = 0;
LET vNombreEjec = '';
LET cStatus = '';
LET vLinCred       = 0;
LET cNumproducto   = '';
LET vIncremento    = 0;
LET cSucursal      = '';
LET viCteNoEsTitPV = 0;
LET pMedioRes = 'P';

BEGIN
ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
	IF sql_err != 0 THEN
		LET cod_ret = sql_err;
		LET vMen= cErrorInfo;
		RETURN cod_ret, vMen;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/paulq/sp_registrarRespuestaCte.out";
--TRACE ON ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF (NVL(pRespCte,'') = '' OR NVL(pNumSolicitud,'') = '' OR NVL(pEmpresa, '') = '' OR NVL(pSucursal,'') = '' OR NVL(pEjecutivo, '') = '') THEN
LET cod_ret = '454';
LET vMen = 'Parámetros insuficientes para llevar a cabo la consulta';
RETURN cod_ret, vMen;
END IF;

--SELECT MAX(fecha_insert) INTO vFecha FROM bdicred:sd_prospectos_aumlincred WHERE empresa = pEmpresa and num_solicitud = pNumSolicitud;

SELECT fecha_hoy INTO vFechaFin FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

SELECT TRIM(valor) INTO vDias FROM bdicred:"informix".sd_param WHERE empresa = pEmpresa and cod_param = '011';

LET vFechaIni = vFechaFin - vDias UNITS DAY;

--SELECT nombre INTO vNombreEjec FROM bdinteg:si_ejecut where ejecutivo = pEjecutivo;

SELECT lincred_sugerida, num_producto, lincred_sugerida - lincred_actual,sucursal, status, fecha_insert
INTO vLinCred,cNumproducto,vIncremento,cSucursal, cStatus, vfecha_insert
FROM bdicred:"informix".sd_bitacora_aumlincred
WHERE empresa = pEmpresa
AND num_solicitud = pNumSolicitud
-- AND numcte = numcte
AND status IN ('AT', 'IN')
AND fecha_status BETWEEN vFechaIni AND vFechaFin;

LET vCont = DBINFO("sqlca.sqlerrd2");
IF vCont = 0 THEN
	LET cod_ret = '455';
	LET vMen = 'No se encuentra el Número de Solicitud y/o fuera de vigencia';
--               LET cod_ret = "457"; -- El cliente no a autorizado o esta fuera de la vigencia
--               LET vMen    = "El Cliente no a autorizado y/o fuera de vigencia";
   RETURN cod_ret, vMen;
END IF;

/*
UPDATE bdicred:sd_prospectos_aumlincred SET resp_cte = pRespCte, mensaje = pPregunta, ejecutivo = pEjecutivo, nombre = vNombreEjec, sucursal_at =

pSucursal
WHERE empresa = pEmpresa and num_solicitud = pNumSolicitud and numcte = numcte and status = 'AT'
 and fecha_insert between vFechaIni and vFechaFin;

LET vCont = dbinfo("sqlca.sqlerrd2");

IF vCont = 0 THEN
LET cod_ret = '455';
LET vMen = 'No se encuentra el Número de Solicitud y/o fuera de vigencia';
RETURN cod_ret, vMen;
END IF;
*/

IF pRespCte = 1 THEN
LET cStatus = 'AP';
ELIF pRespCte = 2 THEN
IF cStatus = 'AT' THEN
	LET cStatus = 'IN';
ELSE
	LET cStatus = 'RT';
END IF;
END IF;

IF cStatus <> 'RT' THEN
	IF (pRespCte = '3') THEN
		IF (pMedioRes = 'P')THEN
			SELECT cte_noestit_p INTO viCteNoEsTitPV FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN');
			LET viCteNoEsTitPV = viCteNoEsTitPV + 1;
			UPDATE bdicred:"informix".sd_bitacora_aumlincred SET cte_noestit_p = viCteNoEsTitPV, medio_res = pMedioRes WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN') AND fecha_insert = vfecha_insert;
		ELIF(pMedioRes = 'V')THEN
			SELECT cte_noestit_v INTO viCteNoEsTitPV FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN');
			LET viCteNoEsTitPV = viCteNoEsTitPV + 1;
			UPDATE bdicred:"informix".sd_bitacora_aumlincred SET cte_noestit_v = viCteNoEsTitPV, medio_res = pMedioRes WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN') AND fecha_insert = vfecha_insert;
		END IF;
	END IF;

	UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	SET status = cStatus, resp_cte = pRespCte, mensaje = pPregunta, ejecutivo = pEjecutivo, sucursal_at = pSucursal, fecha_status = today, hora_status = current, medio_res = pMedioRes
	WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN') AND fecha_insert = vfecha_insert;
	--AND fecha_status BETWEEN vFechaIni AND vFechaFin;

	IF pRespCte <> '3' THEN

	INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status, fecha_insert,revision_cac)
	VALUES (pempresa, pNumSolicitud, cStatus, '', pEjecutivo, today, vfecha_insert,0);

	END IF;

ELSE
	IF (pRespCte = '3') THEN
		IF (pMedioRes = 'P')THEN
			SELECT cte_noestit_p INTO viCteNoEsTitPV FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN');
			LET viCteNoEsTitPV = viCteNoEsTitPV + 1;
			UPDATE bdicred:"informix".sd_bitacora_aumlincred SET cte_noestit_p = viCteNoEsTitPV, medio_res = pMedioRes WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN') AND fecha_insert = vfecha_insert;
		ELIF(pMedioRes = 'V')THEN
			SELECT cte_noestit_v INTO viCteNoEsTitPV FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN');
			LET viCteNoEsTitPV = viCteNoEsTitPV + 1;
			UPDATE bdicred:"informix".sd_bitacora_aumlincred SET cte_noestit_v = viCteNoEsTitPV, medio_res = pMedioRes WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN') AND fecha_insert = vfecha_insert;
		END IF;
	END IF;

	UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	SET status = cStatus, resp_cte = pRespCte, mensaje = pPregunta, ejecutivo = pEjecutivo, sucursal_at = pSucursal, causa_status  = 'RPC', fecha_status = today, hora_status = current, medio_res = pMedioRes
	WHERE empresa = pEmpresa AND num_solicitud = pNumSolicitud AND status in ('AT', 'IN') AND fecha_insert = vfecha_insert;
   -- AND fecha_status BETWEEN vFechaIni AND vFechaFin;

	INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
	VALUES (pempresa, pNumSolicitud, cStatus, 'RPC', pEjecutivo, today,vfecha_insert, 0);

END IF;

IF pRespCte = '1' THEN
/*
UPDATE bdicred:sd_maesdos
  SET monto_otorgado = vLinCred,
	  fecha_ult_mov = vFechaFin
WHERE num_credito = pNumSolicitud
  AND empresa = pEmpresa;

LET vCont = DBINFO("sqlca.sqlerrd2");
IF vCont = 0 THEN
	LET cod_ret = "458"; -- No existe el Cliente en la sd_maesdos
	LET vMen    = "No existe el Cliente en la sd_maesdos";
	RETURN cod_ret, vMen;
END IF;

EXECUTE PROCEDURE bdicred:GENMOV( pEmpresa, pNumSolicitud
								 , cNumproducto , 1
								 ,'008' , vFechaFin
								 , vIncremento , 'Act LineaCredito'
								 , cSucursal, '01'
								 , '0000'
								 ) INTO cod_ret, vMen;
*/
EXECUTE PROCEDURE "informix".sp_grabarincrementolincred(pEmpresa, pNumSolicitud) INTO cCod_Ret, vMenSP;

IF  (cCod_Ret <> '00000') THEN
	LET cod_ret = cCod_Ret; --'456';
	LET vMen = vMenSP;
	RETURN cod_ret, vMen;
END IF;
/*
EXECUTE  PROCEDURE "informix".sp_actualizarestatusaumlincred (pEmpresa, pNumSolicitud, USER, 'AP', '', '') INTO cCod_Ret, vMenSP;

IF (cCod_Ret <> '000000') THEN 
	LET cod_ret = cCod_Ret; --'457';
	LET vMEn = vMenSP;
	RETURN cod_ret, vMen;
END IF;
*/
END IF;

RETURN cod_ret, vMen;
END;

END PROCEDURE

DOCUMENT
'Registra la respuesta del cliente y si esta es afirmativa manda a llamar los sps para grabar el incremento de la línea de crédito y actualizar el status',
'AUTOR : Nubia Janeth Montoya Medina ',
'FECHA : 07/JULIO/2010',
'BD    : bdicred',
'Se modifica para actualizar campos agregados a tabla sd_bitacora_aumlincred',
'MODIFICO : Rochin Rocha Edgar Ivan',
'FECHA : 05/JULIO/2011',
'BD    : BDICRED',
'VERSION:20110705.1530';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncentral(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS tiene_causa,
		  CHAR(100) AS descripcion,
		  INTEGER AS totalRegCasosCac,
		  DECIMAL(18,2) AS porcentajeCasosCac,
	      INTEGER AS totCAC,
		  DECIMAL(18,2) AS porCAC,
		  INTEGER AS totalRegCasosAuto,
		  DECIMAL(18,2) AS porcentajeCasosAuto,
		  INTEGER AS totAUTO,
		  DECIMAL(18,2) AS porAUTO;
---DECLARACIONES   
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

DEFINE dPorcCasosCac		DECIMAL(18,2);
DEFINE dPorcCasosAuto		DECIMAL(18,2);
DEFINE dPorcStatus			DECIMAL(18,2);
DEFINE dPorcStatusAcum		DECIMAL(18,2);
DEFINE dPorcStatusAcum2		DECIMAL(18,2);
DEFINE dPorcenStatus		DECIMAL(18,2);
DEFINE cStatus 				CHAR(2);
DEFINE cCausa 				CHAR(3);
DEFINE cDescripcion 		VARCHAR(100);
DEFINE cBandera 			CHAR(1);
DEFINE cOrigen				CHAR(1);
DEFINE iTotalStatus 		INTEGER;
DEFINE iTotal 				INTEGER;
DEFINE iTotalRegistros 		INTEGER;
DEFINE iTotalCasosCac		INTEGER;
DEFINE iTotalCasosAuto		INTEGER;
DEFINE iTieneCausa 			INTEGER;
DEFINE iCont 				INTEGER;
DEFINE iTotalReg 			INTEGER;
DEFINE dtFecha 				DATE;
DEFINE itotalCAC            INTEGER;
DEFINE itotalAUTO           INTEGER;
DEFINE dporCAC              DECIMAL(18,2);
DEFINE dporAUTO             DECIMAL(18,2);

---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcCasosCac			 = 0;
LET dPorcCasosAuto			 = 0;
LET dPorcStatus			     = 0;
LET dPorcStatusAcum		     = 0;
LET dPorcStatusAcum2	     = 100;
LET dPorcenStatus			 = 0;
LET iTotalStatus			 = 0;
LET iTotal			         = 0;
LET iTotalRegistros			 = 0;
LET iTotalCasosCac			 = 0;
LET iTotalCasosAuto			 = 0;
LET iTieneCausa				 = 0;
LET iCont					 = 0;
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cBandera				 = "";
LET cOrigen 				 = "";
LET cStatus 				 = "";
LET cCausa 					 = "";
LET itotalCAC                = 0;
LET itotalAUTO               = 0;
LET dporCAC                  = 0;
LEt dporAUTO                 = 0;  


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
	 IF iSqlErr IN (-1204,-1205,-1206) THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "Parámetro de fecha invalido para realizar  la consulta";
	 END IF;	 
	 IF  cBandera = "S" THEN
		 DROP TABLE tme_consultaincrementos;
	 END IF;
       RETURN cCodRet, cMensajeRet,0,'',0,0,0 ,0,0,0,0,0;
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_revisioncentral.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaIni,"") = ""  OR NVL(pFechaFin,"") = "" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta parámetro de fechas requerido para realizar la consulta";
	RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalCasosCac, 0), NVL(dPorcCasosCac, 0), NVL(itotalCAC, 0),NVL(dporCAC, 0),
				NVL(iTotalCasosAuto, 0),NVL(dPorcCasosAuto, 0), NVL(itotalAUTO, 0), NVL(dporAUTO, 0); 
	
END IF;

-- Crear una tabla temporal para insertar los datos de la consulta	
IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
    DROP TABLE tme_consultaincrementos;
END IF;

-- Se crea la tabla de trabajo
CREATE TEMP TABLE tme_consultaincrementos
    (
		status CHAR(2),
		causa	CHAR(3),
		descripcion  CHAR(100),
		totalRegCac INTEGER,
		porcentajeCac  DECIMAL(18,2),
		totalCAC INTEGER,
		porCAC   DECIMAL(18,2),
		totalRegAuto INTEGER,
		porcentajeAuto DECIMAL(18,2),
		totalAUTO INTEGER,
		porAUTO   DECIMAL(18,2)
    )WITH NO LOG;	
	
	LET cBandera = "S";
	LET cOrigen ="C";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
 
--Se obtienen los datos referentes a las solicitudes que requieren revision CAC (Casos CAC)
----se insertan el total de registros por estatus
	FOREACH WITH HOLD
		SELECT status,TRIM(descripcion)
			INTO cStatus,cDescripcion
		FROM  "informix".sd_status_aumlincred 
			
		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred 
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND revisioncac=1		
	
				INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegCac,porcentajeCac,totalRegAuto,porcentajeAuto)
				VALUES(cStatus,'',cDescripcion,NVL(iTotalStatus,0),0,0,0);	 
	
		END FOREACH;  	
	END FOREACH;
--se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalRegCac),0), COUNT(status)
			INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos 
		WHERE status=status
		AND causa = ""
		AND totalRegCac <>0;
		
		LET iTotalRegistros = iTotal;
			
		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegCac
					INTO cStatus, cDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status=status
				AND causa = ""
				AND totalRegCac <>0	
				
					LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
					IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
						LET iCont= iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus= 100 - dPorcStatusAcum;
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					ELSE
						LET iCont= iCont + 1;
						LET dPorcStatus= 100 - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					END IF;
						
				UPDATE tme_consultaincrementos
					SET porcentajeCac = dPorcStatus
				WHERE status=cStatus
				AND causa="";
			END FOREACH;
		END IF;
---se insertan el total de registros por causas
	FOREACH WITH HOLD
		SELECT status,causa_status,TRIM(descripcion)
		  INTO cStatus,cCausa,cDescripcion
		  FROM "informix".sd_causas_aumlincred 
		 WHERE mostrar_pantalla = "1"
			
		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred 
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND causa_status=cCausa
			AND revisioncac=1
						
						INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegCac,porcentajeCac,totalRegAuto,porcentajeAuto)
						VALUES(cStatus,cCausa,cDescripcion,NVL(iTotalStatus,0),0,0,0);
		 
		END FOREACH;  		
	END FOREACH;	
	--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
	LET dPorcStatusAcum=0;
	LET dPorcStatus=0;
	LET iCont=0;

	FOREACH WITH HOLD
			SELECT status,causa_status
				INTO cStatus,cCausa
			FROM  "informix".sd_causas_aumlincred 	
			WHERE mostrar_pantalla = "1"
			ORDER BY status,causa_status
					
					SELECT NVL(SUM(totalRegCac),0), COUNT(causa)
						INTO iTotal,iTotalReg
					FROM  tme_consultaincrementos 
					WHERE status=cStatus
					AND causa <> ""
					AND totalRegCac <>0;
					
				IF iTotalReg <> 0 THEN			
						SELECT status,causa,descripcion,totalRegCac
							INTO cStatus,cCausa,cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status = cStatus
						AND causa = cCausa
						AND totalRegCac <>0;
						
					   IF NVL(iTotalStatus,0) <> 0 THEN
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);							
						UPDATE tme_consultaincrementos
							SET porcentajeCac = dPorcStatus
						WHERE status=cStatus
						AND causa=cCausa;	
					   END IF;
				END IF;
			
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum=0;
				LET dPorcStatus=0;
				LET iCont=0;
			END IF;		
	END FOREACH;	
--Se obtienen los datos referentes a las solicitudes que no requieren revision Cac (Casos Automaticos)
----se insertan el total de registros por estatus
	FOREACH WITH HOLD
		SELECT status,TRIM(descripcion)
			INTO cStatus,cDescripcion
		FROM  "informix".sd_status_aumlincred 
			
		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred 
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND revisioncac=0
	
				UPDATE tme_consultaincrementos 
				SET totalRegAuto=iTotalStatus 
				WHERE status=cStatus 
				AND descripcion=cDescripcion;				
				
	
		END FOREACH;  	
	END FOREACH;
--se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalRegAuto),0), COUNT(status)
			INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos 
		WHERE status=status
		AND causa = ""
		AND totalRegAuto <>0;
		
		LET iTotalRegistros = iTotal;
			
		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegAuto
					INTO cStatus, cDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status=status
				AND causa = ""
				AND totalRegAuto <>0	
				
					LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
					IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
						LET iCont= iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus= 100 - dPorcStatusAcum;
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					ELSE
						LET iCont= iCont + 1;
						LET dPorcStatus= 100 - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					END IF;
						
				UPDATE tme_consultaincrementos
					SET porcentajeAuto = dPorcStatus
				WHERE status=cStatus
				AND causa="";
			END FOREACH;
		END IF;
---se insertan el total de registros por causas
	FOREACH WITH HOLD
		SELECT status,causa_status,TRIM(descripcion)
			INTO cStatus,cCausa,cDescripcion
		FROM  "informix".sd_causas_aumlincred 
		WHERE mostrar_pantalla = "1"
			
		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred 
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND causa_status = cCausa
			AND RevisionCac=0
	
				UPDATE tme_consultaincrementos 
				SET totalRegAuto=iTotalStatus 
				WHERE status=cStatus 
				AND causa=cCausa
				AND descripcion=cDescripcion;
		 
		END FOREACH;  		
	END FOREACH;	
	--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
	LET dPorcStatusAcum=0;
	LET dPorcStatus=0;
	LET iCont=0;

	FOREACH WITH HOLD
			SELECT status,causa_status
				INTO cStatus,cCausa
			FROM  "informix".sd_causas_aumlincred 
			WHERE mostrar_pantalla = "1"			
			ORDER BY status,causa_status
					
					SELECT NVL(SUM(totalRegAuto),0), COUNT(causa)
						INTO iTotal,iTotalReg
					FROM  tme_consultaincrementos 
					WHERE status=cStatus
					AND causa <> ""
					AND totalRegAuto <>0;
					
				IF iTotalReg <> 0 THEN
					--Se obtiene porcentaje del estatus
					SELECT porcentajeAuto
					INTO dPorcenStatus
					FROM tme_consultaincrementos
					WHERE status = cStatus
					AND causa = ""
					AND porcentajeAuto <>0;
					-- Se obtiene el total de registros de status por su causa
						SELECT status,causa,descripcion,totalRegAuto
							INTO cStatus,cCausa,cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status = cStatus
						AND causa = cCausa
						AND totalRegAuto <>0;
						
					   IF NVL(iTotalStatus,0) <> 0 THEN
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= dPorcenStatus - dPorcStatusAcum;							
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= iTotalStatus - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
							END IF;							
							UPDATE tme_consultaincrementos
								SET porcentajeAuto = dPorcStatus
							WHERE status=cStatus
							AND causa=cCausa;	
					   END IF;
				END IF;
			
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum=0;
				LET dPorcStatus=0;
				LET iCont=0;
			END IF;		
	END FOREACH;	

	--Se obtienen totales de ambos casos y se guardan en la tabla
	FOREACH
		SELECT SUM(totalRegCac),SUM(totalRegAuto), SUM(porcentajeCac), SUM (porcentajeAuto)
			INTO iTotalCasosCac, iTotalCasosAuto, dporCAC, dporAUTO
		FROM  tme_consultaincrementos
		WHERE causa=""

			UPDATE tme_consultaincrementos
			SET totalCAC = iTotalCasosCac,
				porCAC = dporCAC,
				totalAUTO = iTotalCasosAuto,
				porAUTO = dporAUTO;
				
	END FOREACH;
		

	--se obtiene los datos de la tabla
	FOREACH
		SELECT status,causa,descripcion,totalRegCac,porcentajeCac,totalCAC,porCAC, totalRegAuto,porcentajeAuto, totalAUTO, porAUTO
			INTO cStatus,cCausa,cDescripcion,iTotalCasosCac,dPorcCasosCac, itotalCAC, dporCAC, iTotalCasosAuto,dPorcCasosAuto, itotalAUTO, dporAUTO
		FROM  tme_consultaincrementos
		ORDER BY status,causa
		 
		IF NVL(cCausa,"") <> "" THEN
			LET iTieneCausa=1;
			LET  cDescripcion = TRIM (cCausa) || '-' || TRIM (cDescripcion);
		ELSE
			LET iTieneCausa=0;
		END IF;
		 RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalCasosCac, 0), NVL(dPorcCasosCac, 0), NVL(itotalCAC, 0),NVL(dporCAC, 0),
				NVL(iTotalCasosAuto, 0),NVL(dPorcCasosAuto, 0), NVL(itotalAUTO, 0), NVL(dporAUTO, 0) WITH RESUME;
	END FOREACH;


	IF  cBandera = "S" THEN
		DROP TABLE tme_consultaincrementos;
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_rep_gral_status(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS tiene_causa,
			  CHAR(100) 	AS descripcion,
			  INTEGER 		AS total_status,
			  DECIMAL(18,2) AS porcentaje,
			  INTEGER 		AS total_general;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = "";
	LET cCodRet                  = "000000";
	LET cMensajeRet              = "SE REALIZÓ LA CONSULTA CORRECTAMENTE";
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = "";
	LET cBandera				 = "";
	LET cStatus 				 = "";
	LET cCausa 					 = "";
	LET dPorcStatusTotal         = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = "000002";
					LET cMensajeRet = "PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA";
				END IF;	 
				IF  cBandera = "S" THEN
					DROP TABLE tme_consultaincrementos;
				END IF;
				RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,' '), NVL(iTotalStatus, 0), NVL(dPorcStatus, 0), NVL(iTotal, 0);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/jesus/sp_rep_gral_status.out';
		--TRACE ON;

		--se validan los parametros de entrada.
		IF NVL(pFechaIni,"") = ""  OR NVL(pFechaFin,"") = "" THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "FALTA PARÁMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA";
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;

		IF NVL(pOrigen,"") = "" THEN
			LET cCodRet = "000003";
			LET cMensajeRet = "FALTA PARÁMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA";
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;
		-- Crear una tabla temporal para insertar los datos de la consulta	
		IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
			DROP TABLE tme_consultaincrementos;
		END IF;

		-- Se crea la tabla de trabajo
		CREATE TEMP TABLE tme_consultaincrementos
		(
			status CHAR(2),
			causa	CHAR(3),
			descripcion  CHAR(100),
			totalRegistros INTEGER,
			porcentaje   decimal(18,2)		
		)WITH NO LOG;	
			
		LET cBandera = "S";

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		----se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status,TRIM(descripcion)
				INTO cStatus,vcDescripcion
			FROM  "informix".sd_status_aumlincred 
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen = pOrigen
					AND status = cStatus					
					AND causa_status =""
				
				IF iTotalStatus > 0 THEN
					INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegistros,porcentaje)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0);	 
				END IF;
			END FOREACH;  	
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen = pOrigen
					AND status = cStatus					
					AND causa_status IN(SELECT causa_status		  
										 FROM "informix".sd_causas_aumlincred
										 WHERE mostrar_pantalla = "1")
				
				IF iTotalStatus > 0 THEN
					INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegistros,porcentaje)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0);	 
				END IF;
				
			END FOREACH;  	
			
		END FOREACH;
		--se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(status)
		INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos 
		WHERE status = status
			AND causa = ""
			AND totalRegistros <> 0;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegistros
				INTO cStatus, vcDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status = status
					AND causa = ""
					AND totalRegistros <> 0	
				
				LET dPorcStatus = ((iTotalStatus * 100)/iTotalRegistros);
				IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcStatus = 100 - dPorcStatusAcum;
					END IF;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcStatus = 100 - dPorcStatusAcum;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				END IF;
						
				UPDATE tme_consultaincrementos
				SET porcentaje = dPorcStatus
				WHERE status = cStatus;
			END FOREACH;
		END IF;
		---se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status,causa_status,TRIM(descripcion)
			  INTO cStatus,cCausa,vcDescripcion
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = "1"
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin		
					AND origen = pOrigen
					AND status = cStatus
					AND causa_status = cCausa
			
				INSERT INTO tme_consultaincrementos (status,causa,descripcion,totalRegistros,porcentaje)	
				VALUES(cStatus,cCausa,vcDescripcion,NVL(iTotalStatus,0),0);
			 
			END FOREACH;  		
		END FOREACH;	
		--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;

		FOREACH WITH HOLD
			SELECT status,causa_status
			  INTO cStatus,cCausa
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = "1"
			ORDER BY status,causa_status
					
			SELECT NVL(SUM(totalregistros),0), COUNT(causa)
			INTO iTotal,iTotalReg
			FROM  tme_consultaincrementos 
			WHERE status = cStatus
				AND causa <> ""
				AND totalRegistros <> 0;
								
			SELECT porcentaje
			INTO  dPorcStatusTotal
			FROM  tme_consultaincrementos 
			WHERE status = cStatus
				AND causa = ""
				AND totalRegistros <> 0;
					
			IF iTotalReg <> 0 THEN
				SELECT status,causa,descripcion,totalRegistros
				INTO cStatus,cCausa,vcDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status = cStatus
					AND causa = cCausa
					AND totalRegistros <> 0;
					
				IF NVL(iTotalStatus,0) <> 0 THEN
					LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);

					IF (dPorcStatusAcum + dPorcStatus) < dPorcStatusTotal THEN
						LET iCont = iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;							
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
					ELSE
						LET iCont = iCont + 1;
						LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
					END IF;
						
					UPDATE tme_consultaincrementos
						SET porcentaje = dPorcStatus
					WHERE status = cStatus
						AND causa = cCausa;	
				END IF;
			END IF;
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum = 0;
				LET dPorcStatus = 0;
				LET iCont = 0;
			END IF;				
		END FOREACH;
		
		--se obtiene los datos de la tabla
		FOREACH
			SELECT status,causa,descripcion,totalRegistros,porcentaje
			INTO cStatus,cCausa,vcDescripcion,iTotalStatus,dPorcStatus
			FROM  tme_consultaincrementos
			ORDER BY status,causa
			
			IF NVL(cCausa,"") <> "" THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0), NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotalRegistros, 0) WITH RESUME;			 
		END FOREACH;	
		
		IF  cBandera = "S" THEN
			DROP TABLE tme_consultaincrementos;
		END IF;
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_actualizasolicmc_lineas()
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION; 

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		CHAR(80);
    DEFINE cNumSol			CHAR(20);
    DEFINE dMontoSol		DECIMAL(18,2);

	---INICIALIZACIONES
    LET iSqlErr				= 0;
    LET iIsamErr			= 0;
    LET cErrorInfo			= '';
    LET cCodRet				= '000000';
    LET cMensajeRet			= 'Proceso Exitoso';
    LET cNumSol				= '';
    LET dMontoSol			= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO "/informix/jesus/sp_actualizasolicmc_lineas.out";
	---TRACE ON;
	
	FOREACH WITH HOLD
		SELECT  tar.num_credito,monto_solicitado
			INTO cNumSol,dMontoSol
		FROM "informix".sd_tarjeta tar,
		bdisolic:"informix".ss_solicitudes sol
		WHERE tar.empresa = sol.empresa
		AND tar.num_credito = sol.num_solicitud
		AND tar.tipo_tarjeta ='T'
		AND tar.status_tar ='A'		
		AND limite_aut <> monto_solicitado
		AND fecha_insert > mdy(7,25,2013)	
		
		
			UPDATE "informix".sd_tarjeta
			SET limite_aut =dMontoSol
			WHERE empresa ='001' 
			AND num_credito = cNumSol;		

	END FOREACH;


	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para actualizar lineas a creditos  que se actualizaron con lineas mayores',
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 30 agosto 2013',
'VERSION: 20130830.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncac(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS tiene_causa,
		  CHAR(100) AS descripcion,
		  INTEGER AS totalRegCentral,
		  DECIMAL(18,2) AS porcentajeCentral,
		  INTEGER AS totalCentral,
		  DECIMAL(18,2) AS totPorCentral,
		  INTEGER AS totalRegSucursal,
		  DECIMAL(18,2) AS porcentajeSucursal,
		  INTEGER AS totalSucursal,
		  DECIMAL(18,2) AS totPorSucursal;
		  
		
---DECLARACIONES   
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

DEFINE dPorcStatusSuc		DECIMAL(18,2);
DEFINE dPorcStatusCen		DECIMAL(18,2);
DEFINE dPorcStatus			DECIMAL(18,2);
DEFINE dPorcStatusAcum		DECIMAL(18,2);
DEFINE dPorcStatusAcum2		DECIMAL(18,2);
DEFINE cStatus 				CHAR(2);
DEFINE cCausa 				CHAR(3);
DEFINE cDescripcion 		VARCHAR(100);
DEFINE cBandera 			CHAR(1);
DEFINE cOrigen				CHAR(1);
DEFINE iTotalStatus 		INTEGER;
DEFINE iTotal 				INTEGER;
DEFINE iTotalRegistros 		INTEGER;
DEFINE iTotalStatusSuc		INTEGER;
DEFINE iTotalStatusCen		INTEGER;
DEFINE iTieneCausa 			INTEGER;
DEFINE iCont 				INTEGER;
DEFINE dPorSucursal         DECIMAL(18,2);
DEFINE dPorCentral          DECIMAL(18,2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalCentral         DECIMAL(18,2);
DEFINE iTotalSucursal        DECIMAL(18,2);
DEFINE dporCasoSucursal       DECIMAL(18,2);
DEFINE dporCasoCentral       DECIMAL(18,2);

---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "SE REALIZÓ LA CONSULTA CORRECTAMENTE";
LET dPorcStatusSuc			 = 0;
LET dPorcStatusCen			 = 0;
LET dPorcStatus			     = 0;
LET dPorcStatusAcum		     = 0;
LET dPorcStatusAcum2	     = 100;
LET iTotalStatus			 = 0;
LET iTotal			         = 0;
LET iTotalRegistros			 = 0;
LET iTotalStatusCen			 = 0;
LET iTotalStatusSuc			 = 0;
LET iTieneCausa				 = 0;
LET iCont					 = 0;
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cBandera				 = "";
LET cOrigen 				 = "";
LET cStatus 				 = "";
LET cCausa 					 = "";
LET dPorSucursal             = 0;
LET dPorCentral              = 0;
LET iTotalCentral            = 0;
LET iTotalSucursal           = 0;
LET dporCasoSucursal         = 0;
LET dporCasoCentral          = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
	 IF iSqlErr IN (-1204,-1205,-1206) THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA";
	 END IF;	 
	 IF  cBandera = "S" THEN
		 DROP TABLE tme_consultaincrementos;
	 END IF;
       RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
			NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0);
   END IF;
END EXCEPTION;

	--SET debug FILE TO "/informix/jesus/sp_cac_rep_revisioncac.out";
	--trace ON;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "FALTA PARÁMETRO DE FECHA REQUERIDO PARA REALIZAR  LA CONSULTA";
	RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
			NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0);
END IF;
-- Crear una tabla temporal para insertar los datos de la consulta	
IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
    DROP TABLE tme_consultaincrementos;
END IF;

-- Se crea la tabla de trabajo
CREATE TEMP TABLE tme_consultaincrementos
    (
		status CHAR(2),
		causa	CHAR(3),
		descripcion  CHAR(100),
		totalRegCentral INTEGER,
		porcentajeCentral  DECIMAL(18,2),
		totalcentral    INTEGER,
		porCentral		DECIMAL(18,2),
		totalRegSucursal INTEGER,
		porcentajeSucursal DECIMAL(18,2),
		totalSucursal  INTEGER,
		porSucursal	DECIMAL(18,2)
		
    )WITH NO LOG;	
	
	LET cBandera = "S";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
 
 FOREACH WITH HOLD
 
	 SELECT origen 
	 INTO cOrigen
	 FROM "informix".sd_aumlincred_origen
	 ORDER by  origen 
	 
	 IF cOrigen='C' THEN	 
		----se insertan el total de registros por estatus
			FOREACH WITH HOLD
				SELECT status,TRIM(descripcion)
					INTO cStatus,cDescripcion
				FROM  "informix".sd_status_aumlincred 
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
				    INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen = cOrigen
					AND status = cStatus			
			
						INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegCentral,porcentajeCentral,totalRegSucursal,porcentajeSucursal)
						VALUES(cStatus,'',cDescripcion,NVL(iTotalStatus,0),0,0,0);	 
			
				END FOREACH;  	
			END FOREACH;
		--se obtiene el total de los registros para esta consulta	
				SELECT NVL(SUM(totalRegCentral),0), COUNT(status)
					INTO iTotal,iTotalReg
				FROM  tme_consultaincrementos 
				WHERE status=status
				AND causa = ""
				AND totalRegCentral <>0;
				
				LET iTotalRegistros = iTotal;
					
				IF iTotalReg <> 0 THEN
					--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
					FOREACH
						SELECT status,descripcion,totalRegCentral
							INTO cStatus, cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status=status
						AND causa = ""
						AND totalRegCentral <>0	
						
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotal);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= 100 - dPorcStatusAcum;
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= 100 - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							END IF;
								
						UPDATE tme_consultaincrementos
							SET porcentajeCentral = dPorcStatus
						WHERE status=cStatus;
				    END FOREACH;
				END IF;
		---se insertan el total de registros por causas
			FOREACH WITH HOLD
				SELECT status,causa_status,TRIM(descripcion)
				  INTO cStatus,cCausa,cDescripcion
				  FROM  "informix".sd_causas_aumlincred 
                 WHERE mostrar_pantalla = "1"
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
						INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen =cOrigen
					AND status=cStatus
					AND causa_status=cCausa
		
						INSERT INTO tme_consultaincrementos (status,causa,descripcion,totalRegCentral,porcentajeCentral,totalRegSucursal,porcentajeSucursal)	
						VALUES(cStatus,cCausa,cDescripcion,NVL(iTotalStatus,0),0,0,0);	
				 
				END FOREACH;  		
			END FOREACH;	
			--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
			LET dPorcStatusAcum=0;
			LET dPorcStatus=0;
			LET iCont=0;

			FOREACH WITH HOLD
					SELECT status,causa_status
                      INTO cStatus,cCausa
					  FROM  "informix".sd_causas_aumlincred
					 WHERE mostrar_pantalla = "1"					
					ORDER BY status,causa_status
							
							SELECT NVL(SUM(totalRegCentral),0), COUNT(causa)
								INTO iTotal,iTotalReg
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa <> ""
							AND totalRegCentral <>0;
							
							SELECT porcentajeCentral
								INTO dPorCentral
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa = ""
							AND totalRegCentral <>0;
							
						IF iTotalReg <> 0 THEN			
								SELECT status,causa,descripcion,totalRegCentral
									INTO cStatus,cCausa,cDescripcion,iTotalStatus
								FROM  tme_consultaincrementos
								WHERE status = cStatus
								AND causa = cCausa
								AND totalRegCentral <>0;
								
							   IF NVL(iTotalStatus,0) <> 0 THEN
									LET dPorcStatus    = ((iTotalStatus * dPorCentral) / iTotal);
									IF (dPorcStatusAcum + dPorcStatus) < dPorCentral THEN
										LET iCont= iCont + 1;
										IF iTotalReg = iCont THEN
											LET dPorcStatus= dPorCentral - dPorcStatusAcum;							
										END IF;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
									ELSE
										LET iCont= iCont + 1;
										LET dPorcStatus= dPorCentral - dPorcStatusAcum;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
									END IF;
										
								UPDATE tme_consultaincrementos
									SET porcentajeCentral = dPorcStatus
								WHERE status=cStatus
								AND causa=cCausa;	
							   END IF;
						END IF;
					
					IF iTotalReg = iCont THEN
						LET dPorcStatusAcum=0;
						LET dPorcStatus=0;
						LET iCont=0;
					END IF;		
			END FOREACH;
	ELSE 
		LET dPorcStatus= 0;
		IF cOrigen='S' THEN
			FOREACH WITH HOLD
				SELECT status,TRIM(descripcion)
					INTO cStatus,cDescripcion
				FROM  "informix".sd_status_aumlincred 
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
						INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen =cOrigen
					AND status=cStatus			
					
						UPDATE tme_consultaincrementos 
						SET totalRegSucursal=iTotalStatus 
						WHERE status=cStatus 
						AND causa='' 
						AND descripcion=cDescripcion;			
						
				END FOREACH;  	
			END FOREACH;
		--se obtiene el total de los registros para esta consulta	
				SELECT NVL(SUM(totalRegSucursal),0), COUNT(status)
					INTO iTotal,iTotalReg
				FROM  tme_consultaincrementos 
				WHERE status=status
				AND causa = ""
				AND totalRegSucursal <>0;
				
				LET iTotalRegistros = iTotal;
					
				IF iTotalReg <> 0 THEN
					--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
					FOREACH
						SELECT status,descripcion,totalRegSucursal
							INTO cStatus, cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status=status
						AND causa = ""
						AND totalRegSucursal <>0	
						
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotal);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= 100 - dPorcStatusAcum;
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= 100 - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							END IF;
								
						UPDATE tme_consultaincrementos
							SET porcentajeSucursal = dPorcStatus
						WHERE status=cStatus;
				    END FOREACH;
					LET dPorcStatus= 0;
					LET dPorcStatusAcum = 0;
--				ELSE 
--					LET dPorcStatus= 0;
--					LET dPorcStatusAcum = 0;
				END IF;
		---se insertan el total de registros por causas
			FOREACH WITH HOLD
				SELECT status,causa_status,TRIM(descripcion)
				  INTO cStatus,cCausa,cDescripcion
				  FROM "informix".sd_causas_aumlincred
		         WHERE mostrar_pantalla = "1"				
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
						INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen =cOrigen
					AND status=cStatus
					AND causa_status=cCausa
				
						UPDATE tme_consultaincrementos 
						SET causa = cCausa, totalRegSucursal = iTotalStatus, porcentajeSucursal = 0 
						WHERE status=cStatus 
						AND descripcion=cDescripcion;
				 
				END FOREACH;  
				LET dPorcStatus= 0;	
				LET dPorcStatusAcum = 0;				
			END FOREACH;	
			 LET dPorcStatus= 0;
			 LET dPorcStatusAcum = 0;
		--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum=0;
		LET dPorcStatus=0;
		LET iCont=0;
		LET dPorSucursal = 0;
	
		FOREACH WITH HOLD
					SELECT status,causa_status
					  INTO cStatus,cCausa
					  FROM "informix".sd_causas_aumlincred
		             WHERE mostrar_pantalla = "1"					
					ORDER BY status,causa_status
					
							SELECT NVL(SUM(totalRegSucursal),0), COUNT(causa)
								INTO iTotal,iTotalReg
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa <> ""
							AND totalRegSucursal <>0;
							
							SELECT porcentajeSucursal
								INTO dPorSucursal 
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa = ""
							AND totalRegSucursal <>0;
							
						IF iTotalReg <> 0 THEN			
								SELECT status,causa,descripcion,totalRegSucursal
									INTO cStatus,cCausa,cDescripcion,iTotalStatus
								FROM  tme_consultaincrementos
								WHERE status = cStatus
								AND causa = cCausa
								AND totalRegSucursal <>0;
								
							   IF NVL(iTotalStatus,0) <> 0 THEN
									LET dPorcStatus    = ((iTotalStatus * dPorSucursal) / iTotal);
									IF (dPorcStatusAcum + dPorcStatus) < dPorSucursal THEN
										LET iCont= iCont + 1;
										IF iTotalReg = iCont THEN
											LET dPorcStatus= dPorSucursal - dPorcStatusAcum;							
										END IF;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
									ELSE
										LET iCont= iCont + 1;
										LET dPorcStatus= dPorSucursal - dPorcStatusAcum;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
									END IF;
										
								UPDATE tme_consultaincrementos
									SET porcentajeSucursal = dPorcStatus
								WHERE status=cStatus
								AND causa=cCausa;	
							   END IF;

						END IF;			
					
					IF iTotalReg = iCont THEN
						LET dPorcStatusAcum=0;
						LET dPorcStatus=0;
						LET iCont=0;
					END IF;		
			END FOREACH;		
			LET dPorcStatus= 0;
		END IF;
	END IF;
END FOREACH;
--Se obtienen totales de ambos casos y se guardan en la tabla
FOREACH
	SELECT SUM(totalRegCentral),SUM(totalRegSucursal),SUM(porcentajeCentral), SUM(porcentajeSucursal)
		INTO iTotalStatusCen, iTotalStatusSuc, dporCasoCentral, dPorCasoSucursal
	FROM  tme_consultaincrementos
	WHERE causa=""

	UPDATE tme_consultaincrementos
	SET totalCentral = iTotalStatusCen,
		porCentral = dporCasoCentral,
		totalSucursal = iTotalStatusSuc,
		porSucursal = dPorCasoSucursal;	 

END FOREACH;

--se obtiene los datos de la tabla
FOREACH
	SELECT status,causa,descripcion,totalRegCentral,porcentajeCentral,totalCentral,porCentral,totalRegSucursal,porcentajeSucursal, totalSucursal,porSucursal
		INTO cStatus,cCausa,cDescripcion,iTotalStatusCen,dPorcStatusCen,iTotalCentral, dporCasoCentral, iTotalStatusSuc,dPorcStatusSuc, iTotalSucursal, dPorCasoSucursal
	FROM  tme_consultaincrementos
	ORDER BY status,causa

	IF NVL(cCausa,"") <> "" THEN
		LET iTieneCausa=1;
		LET  cDescripcion = TRIM (cCausa) || '-' || TRIM (cDescripcion);
	ELSE
		LET iTieneCausa=0;
	END IF;

	RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
			NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0) WITH RESUME;
END FOREACH;
	
	IF  cBandera = "S" THEN
		DROP TABLE tme_consultaincrementos;
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_segmentacion_lincred(pEmpresa  CHAR(3), 
													   pSolicitud CHAR(20), 
													   vLinCred DECIMAL(18,2))
															
RETURNING CHAR(5) AS CodigoRetorno, 
		  CHAR(80) AS Mensaje;			

DEFINE cod_ret     CHAR(5);
DEFINE vCont       SMALLINT;
DEFINE sql_err     SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE cErrorInfo  CHAR(80);
DEFINE iIsamErr    SMALLINT;
DEFINE cNumProd 	CHAR(3);
DEFINE pproducto 	CHAR(3);
DEFINE pNumTarjeta	CHAR(16);


LET cod_ret        = "00000";
LET vCont          = 0;
LET sql_err        = 0;
LET vMen           = "El proceso se ejecuto correctamente";
LET cErrorInfo     = "";
LET iIsamErr       = 0;
LET pNumTarjeta    = 0;
LET cNumProd 	   = 0;
LET pproducto 	   = 0;

BEGIN
	
	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
			LET cod_ret = sql_err;
			LET vMen= cErrorInfo;
        RETURN cod_ret, vMen;	
		END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/sp_segmentacion_lincred.out';
--TRACE ON ;

IF (NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "") THEN
    LET cod_ret = "00001";
    LET vMen    = "Parametros insuficientes para realizar la consulta";
    RETURN cod_ret, vMen;
END IF;

			SELECT num_tarjeta
			  INTO pNumTarjeta
			  FROM bdicred:"informix".sd_tarjeta 	
			WHERE  empresa = '001'
			AND num_credito = pSolicitud
			AND status_tar = "A"
			AND tipo_tarjeta = "T";			
			
			SELECT	LIMIT 1 TRIM(num_prod)
			INTO	cNumProd
			FROM	"informix".sd_segmentos				
			WHERE	empresa= '001' 
			AND limite_max >= vLinCred 
			AND limite_min <= vLinCred;
		
		IF NVL(cNumProd,'') = '' THEN
			LET cod_ret= "00002";
			LET vMen = "No se encuentra rango establecido";
			RETURN cod_ret, vMen;
			
		ELSE	
		
			SELECT codproductotarjeta INTO pproducto FROM intercard:"informix".tarjeta 
			WHERE numtarjeta = pNumTarjeta;
			
			IF pproducto != cNumProd THEN
			
				UPDATE intercard:"informix".tarjeta
				SET	codproductotarjeta = cNumProd
				WHERE	numtarjeta = TRIM(pNumTarjeta);
			
			END IF;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cod_ret= "00003";
				LET vMen = "No se pudo actualizar codigo de producto";
				RETURN cod_ret, vMen;
			END IF				
		END IF
			
			
		RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para actualizar segmento Oro,Clasica,Infinite segun la línea de crédito',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 01/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_second_multi_ocurrence()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(2);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE vnumcuentaq                  CHAR(20);
define vcuenta 						integer;
define vfecha						char(6);

    --SET DEBUG FILE TO "/informix/Janeth_Peinado/Pruebas_shell/sp_depura_second.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET vnumcuentaq      = '';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';

	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
            
FOREACH WITH HOLD
	select DISTINCT(numcuentaq) 
	into vnumcuentaq
	from sd_progesive_01
		
	let vcuenta = 1;	
	
	FOREACH WITH HOLD
	select fecha
	into vfecha
	from sd_progesive_01 
	where numcuentaq = vnumcuentaq
	order by fecha desc
		
		if vcuenta <= 9 then
			let cMensaje = "0" || vcuenta;
		else
			let cMensaje = vcuenta;
		end if
		
		update sd_progesive_01 set progresive_counter_quitar=cMensaje,progresive_counter=cMensaje
		where numcuentaq = vnumcuentaq and
		fecha = vfecha;
	   
	   let vcuenta = vcuenta + 1;
	   
	 END FOREACH; 
	 
END FOREACH; 

     RETURN cCod_ret;
	END;
	
END PROCEDURE;