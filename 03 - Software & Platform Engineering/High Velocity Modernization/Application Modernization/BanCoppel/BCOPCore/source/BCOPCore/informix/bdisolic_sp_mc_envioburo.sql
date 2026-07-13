CREATE PROCEDURE "informix".sp_mc_envioburo(pEmpresa CHAR(3),pNumCte CHAR(20),pNumSol CHAR(20), pCoppel CHAR(1))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(1) AS banderamotormc
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNumSolSIC		CHAR(20);
DEFINE cConsultaSic		CHAR(2);
DEFINE dtFechaSic		DATE;
DEFINE dtFechaHoy		DATE;
DEFINE iDiasVigencia    INTEGER;
DEFINE cBanderaMotorMC	CHAR(1);
DEFINE cProducto		CHAR(4);
---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizï¿½ la consulta correctamente";
LET cNumSolSIC			= "";
LET cConsultaSic		= "";
LET dtFechaSic			= DATE(1);
LET dtFechaHoy			= DATE(1);
LET iDiasVigencia		= 0;
LET cBanderaMotorMC		='0';
LET cProducto			='';
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet, cBanderaMotorMC; 
END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/LeonardoFigueroa/Motor/Mesacontrol/sp_mc_envioburo.out";
--TRACE ON;

	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumCte,'')= ''  OR NVL(pNumSol,'')= '' THEN
		LET cCodret = '000001';
		LET cMensajeRet = 'PARAMETROS DE ENTRADA INVALIDOS'; 
		RETURN cCodRet, cMensajeRet, cBanderaMotorMC; 
	 END IF;

	 
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

  ------obtencion del parametro de dias de vigencia de consultas SIC --JMAH
	SELECT valor
	INTO iDiasVigencia
	FROM "informix".ss_param
	WHERE empresa = pEmpresa
	AND secuencia = 362;		
	
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;		
	

	IF NVL(iDiasVigencia,0) = 0 THEN
		LET iDiasVigencia = 0; ---para minimo cumplir lo que viene en el RQM
	END IF;
	
	SELECT num_solicitud_sic, fecha_sic, institucion
	INTO cNumSolSIC, dtFechaSic, cConsultaSic
	FROM "informix".ss_solicitudes_sic
	WHERE rowid = (SELECT MAX(rowid)
				   FROM "informix".ss_solicitudes_sic
				   WHERE numcte= pNumCte
				   AND (fecha_sic >= dtFechaHoy - iDiasVigencia or fecha_sic IS NULL));

	IF cNumSolSIC IS NULL THEN
		INSERT INTO "informix".ss_solicitudes_sic
			(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
		VALUES(pEmpresa,pNumCte,pNumSol,pNumSol,'',dtFechaHoy,NULL);

	   EXECUTE PROCEDURE bdiburo:"informix".burocred(pEmpresa, "0000", USER, pNumSol, 0) INTO cCodRet;
	ELSE
		IF dtFechaSic IS NULL THEN
			INSERT INTO "informix".ss_solicitudes_sic
			(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
			VALUES(pEmpresa,pNumCte,pNumSol,cNumSolSIC,'',dtFechaHoy,NULL);
		ELSE
			INSERT INTO "informix".ss_solicitudes_sic
			(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
			VALUES(pEmpresa,pNumCte,pNumSol,cNumSolSIC,cConsultaSic,dtFechaHoy,dtFechaSic);

			IF ( cConsultaSic = 'CC' ) THEN
				EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cConsultaSic, '', 'SOLICITUD ENVIADA A CIRCULO DE CREDITO') INTO cCodRet;

				IF cCodRet <> '000000' THEN
				   LET cCodRet= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
				   RETURN cCodRet, cMensajeRet, cBanderaMotorMC; 
			   END IF;
			END IF;
			--JMAH Se realiza homologacion con ajustes paso 5
			IF pCoppel = "C" THEN-- envio a de consulta a coppel  ---Consulta Coppel
				
				UPDATE "informix".ss_solicitudes
					SET envio_parametrico = "1"
				WHERE num_solicitud = pNumSol
				AND empresa = pEmpresa;			
			ELSE
				SELECT num_producto INTO cProducto FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pNumSol;
				IF EXISTS(SELECT numproducto from bdicred:sd_productos_motor WHERE numproducto=cProducto) THEN
					LET cBanderaMotorMC = '1';
					LET cMensajeRet = 'Solicitud enviada a motor';
					RETURN cCodRet, cMensajeRet, cBanderaMotorMC;
				ELSE
					EXECUTE PROCEDURE "informix".califica_scoring2_cjunk(pEmpresa, pNumSol) INTO cCodRet;
				END IF;
				LET cCodRet = '000';
			END IF;
		END IF;
	END IF;
	RETURN cCodRet, cMensajeRet, cBanderaMotorMC;
END
END PROCEDURE
