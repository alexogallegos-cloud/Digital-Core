CREATE PROCEDURE "informix".sp_os_actualizastatusprospectotitular(pEmpresa CHAR(3),pNumSol CHAR(20))
RETURNING 
	CHAR(6) AS CodigoRetorno,
	CHAR(80) AS MensajeRetorno; 

--DECLARACIONES 
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cCodRetAct       	CHAR(6);
DEFINE cMensajeRet     		CHAR(80);	
DEFINE cNumCteBco     		CHAR(20);	
DEFINE cStatusNumctePros   	CHAR(2);	
DEFINE cStatusSolicitud   	CHAR(2);	
DEFINE cNumSolicitud	   	CHAR(20);		
DEFINE cDesc	     		CHAR(40);
DEFINE iSec	        		INTEGER;

--INICIALIZACIONES
LET iSqlErr         	= 0;
LET iIsamErr        	= 0;
LET cErrorInfo      	= "";
LET cCodRet         	= "000000";
LET cCodRetAct         	= "000000";
LET cMensajeRet     	= "";
LET cNumCteBco	     	= "";
LET cStatusNumctePros  	= "";
LET cStatusSolicitud  	= "";
LET cNumSolicitud  		= "";
LET cDesc		  		= "";
LET iSec		       	= 0;


BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet;
       END IF;
    END EXCEPTION;
		
	-- SET DEBUG FILE TO "/respaldosbd/josue/sp_os_actualizastatusprospectotitular.out";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
		-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") =  "" OR NVL(pNumSol,"") = ""  THEN
		LET cCodRet = "000001";
		LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS";
		RETURN cCodRet,cMensajeRet;
	END IF
	
	
	--OBTIENE CLIENTE BANCO.
	SELECT numcte,status_numcte_pros
	INTO cNumCteBco,cStatusNumctePros
	FROM bdiprospectos:"informix".pr_cliente 	
	WHERE numcte_pros = pNumSol;
	
	IF NVL(cNumCteBco,"") = "" THEN 		
		LET cCodRet = "000002";
		LET cMensajeRet = "NO EXISTE EL CLIENTE PROSPECTO COMO TITULAR";
		RETURN cCodRet,cMensajeRet;
	END IF;
		
	IF EXISTS(SELECT numcte	FROM bdisolic: "informix".ss_solicitudes WHERE numcte = cNumCteBco) THEN 
		FOREACH 		
			SELECT num_solicitud,status_solicitud
			INTO cNumSolicitud,cStatusSolicitud
			FROM bdisolic: "informix".ss_solicitudes
			WHERE numcte = cNumCteBco
			
			IF NVL(cNumSolicitud,"") <> "" AND (NVL(cStatusSolicitud,"") = "EE" OR NVL(cStatusSolicitud,"") = "CE") THEN
			
				SELECT TRIM(NVL(descripcion,'')) INTO cDesc FROM bdisolic: "informix".ss_status_sol WHERE status_solicitud = cStatusNumctePros;
				
				EXECUTE PROCEDURE bdisolic: "informix".sp_actualiza_status_sol(pEmpresa, "sistema", cNumSolicitud, cStatusNumctePros, "",cDesc)
				INTO cCodRetAct;

				IF CAST(cCodRetAct AS INTEGER) <> 0 THEN
					LET cCodRet = "000003";
					LET cMensajeRet = "OCURRIO UN ERROR EN LA EJECUCION DEL PROCEDIMIENTO: sp_actualiza_status_sol";
					RETURN cCodRet,cMensajeRet;
				END IF;							
			END IF;

			IF NVL(cNumSolicitud,'') <> '' THEN
				SELECT secuencia INTO iSec FROM bdisolic: "informix".ss_osclientesupervisar WHERE num_solicitud =  pNumSol;
				
				IF NVL(iSec,0) > 0 THEN
					IF (SELECT COUNT(num_solicitud) FROM bdisolic: "informix".ss_solicitud_os WHERE num_solicitud = cNumSolicitud) > 0 THEN
						UPDATE bdisolic: "informix".ss_solicitud_os SET secuenciaos = iSec WHERE num_solicitud =cNumSolicitud;
					END IF;
				END IF;
			END IF;
			
		END FOREACH;
	ELSE 
		LET cCodRet = "000002";
		LET cMensajeRet = "NO EXISTE EL CLIENTE PROSPECTO COMO TITULAR";
		RETURN cCodRet,cMensajeRet;
	END IF;
	
END 
END PROCEDURE
