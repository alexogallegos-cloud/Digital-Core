CREATE PROCEDURE "informix".sp_validasolper(pNumCte varchar(13), pNumCuenta varchar(13))
   RETURNING CHAR(5), CHAR(50), CHAR(6), CHAR(1);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   
   DEFINE cDescripcion 	  CHAR(50);
   DEFINE cIdSolicitud 	  CHAR(6);
   DEFINE cEstatusProceso CHAR(1);
   DEFINE cNumTarj        CHAR(16);     
   DEFINE cNumCte        CHAR(16);    
   
   LET cCodRet 		      = '00000';   
   LET cDescripcion	      = '';
   LET cIdSolicitud	      = '';
   LET cEstatusProceso    = '';
   LET cNumTarj           = '';
   LET cNumCte           = '';      
      
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/combinacion/SP_VALIDASOLPER.out";
	--TRACE ON;	
	
	FOREACH
		SELECT idsolicitud, estatusproceso INTO cIdSolicitud, cEstatusProceso 
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta
		
		IF cNumTarj <> "" OR cNumTarj is not null THEN
			SELECT numcliente INTO cNumCte FROM intercard: tarjeta WHERE numcliente = pNumCte AND codstatustarjeta = 'NOA';
		END IF;
		
		IF cEstatusProceso = "V" AND cNumCte <> '' AND cNumCte is not null THEN
			
			SELECT num_tarjeta INTO cNumTarj FROM bdicheq: sc_tarjeta WHERE numcte = pNumCte AND cuenta = pNumCuenta AND status_tar = 'A';
			IF cNumTarj = "" OR cNumTarj is null THEN
				SELECT num_tarjeta INTO cNumTarj FROM bdicred: sd_tarjeta WHERE numcte = pNumCte AND num_credito = pNumCuenta AND status_tar = 'A';
			END IF;
			
			IF cNumTarj = "" OR cNumTarj is null THEN
				LET cCodRet = "00000";
				LET cDescripcion = "Solicitud Procesada";					
			ELSE
				LET cCodRet = "00001";
				LET cDescripcion = "Solicitud (Reposición)";
			END IF;
		ELIF cEstatusProceso = "F" AND cNumCte = '' AND cNumCte is null THEN
			LET cCodRet = "00000";
			LET cDescripcion = "Solicitud en Proceso";
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
		END IF;	
	END FOREACH;
	
	IF cIdSolicitud = "" OR cEstatusProceso = "" OR cIdSolicitud is null OR cEstatusProceso is null THEN
		LET cCodRet = "00001";
		LET cDescripcion = 'Solicitud';		
	END IF;
	
	RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Elmer López Valenzuela',
'FECHA: 03/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar exista una solicitud que no ha sido procesada para el cliente';

CREATE PROCEDURE "informix".sp_ws_appriza_login(pTokenId CHAR(80))

RETURNING CHAR(5), CHAR(100);

--Definicion de Variables
DEFINE iSqlErr 	   INTEGER;
DEFINE iIsamError  INTEGER;
DEFINE cCodRet    CHAR(5);
DEFINE cDescipcion CHAR(100);
DEFINE cIdOper	   INTEGER;


--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '00000';
LET cDescipcion = 'Consulta Exitosa.';
LET cIdOper = 0;



BEGIN
	ON EXCEPTION SET iSqlErr
		--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_cctes.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescipcion = '';
			
		END IF;
		
		RETURN cCodRet,cDescipcion;
		
	END EXCEPTION;

	--log
	--SET DEBUG FILE TO '/tmp/cristo/sp_ws_afore_ctes.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 10;

	--Se valida que alguno de los parametros de entrada no venga nulo

	IF NVL(pTokenId, '') = '' THEN
		LET cCodRet = '00001';
		LET cDescipcion = 'Error. Parametros de entrada vacios.';

	ELSE
	
		UPDATE "informix".mc_parametros SET valordefault=pTokenId 
		WHERE etiqueta='TokenId' AND tipo='E'
		AND id_oper IN (SELECT id_oper FROM "informix".mc_operaciones WHERE id_ws='5');
		
	END IF;
	
	RETURN cCodRet,cDescipcion;
	
END;
END PROCEDURE;