CREATE PROCEDURE "informix".sp_gteactsolrtoscalle (pEmpresa CHAR(3),pSucursal CHAR(4),pNumSol CHAR(20), pNumCte CHAR(20),pNomCte CHAR(107),pEjecutivo CHAR(10),pMotivo CHAR(50),pCausaSol CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cMen_ret CHAR(80);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cMen_ret     = "Proceso Exitoso";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_gteactsolrtoscalle.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  OR NVL(pCausaSol,'') = ''  OR NVL(pNumCte,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNumSol,'') = '' OR NVL(pNomCte,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pMotivo,'') = '' THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
		--SE ACTUALIZA LA SOLICITUD
		EXECUTE PROCEDURE sp_actualiza_status_sol
		(pEmpresa, pEjecutivo, pNumSol, 'AT', pCausaSol,pMotivo)
		INTO cCodRet;
		
		INSERT INTO "informix".ss_solautorizadasgte 
		(empresa,sucursal,num_credito,numcte,nombre_cte,fecha_aut ,empleado_aut,motivo,user_insert,fecha_insert )
		VALUES(pEmpresa,pSucursal,pNumSol,pNumCte,pNomCte,TODAY,pEjecutivo,pMotivo,USER,TODAY);
	
		
	END IF;		
	RETURN cCodRet,cMen_ret ;
END
END PROCEDURE
