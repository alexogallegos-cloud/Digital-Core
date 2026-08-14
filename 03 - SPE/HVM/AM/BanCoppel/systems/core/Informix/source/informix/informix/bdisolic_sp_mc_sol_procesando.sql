CREATE PROCEDURE "informix".sp_mc_sol_procesando( pNumcte CHAR(20),pEjecutivo CHAR(10),pTipoMovto SMALLINT)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION; 

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		CHAR(80);

	---INICIALIZACIONES
    LET iSqlErr				= 0;
    LET iIsamErr			= 0;
    LET cErrorInfo			= '';
    LET cCodRet				= '000000';
    LET cMensajeRet			= 'Proceso Exitoso';

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
    
	---SET DEBUG FILE TO "/respaldosbd/Malena/sp_mc_sol_procesando.out";
	---TRACE ON;
	--SI EL ESTADO DEVUELTO FUE ESTADO CORRECTO SE GRABA LA INFORMACION RECIBIDA POR EL SERVICIO EN LA TABLA QUE GRABA LA RESPUESTA.
	IF 	NVL(pNumcte,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pTipoMovto,0) NOT IN (1,2) THEN
		LET cCodRet				= '000001';
		LET cMensajeRet			= 'PARAMETROS DE ENTRADA INVALIDOS';
	ELSE
		IF pTipoMovto = 1 THEN	
			INSERT INTO "informix".ss_cte_procesando(numcte, usuario, fecha_insercion, hora_insercion)
			VALUES(pNumcte, pEjecutivo, CURRENT, CURRENT HOUR TO SECOND);
		ELSE
			DELETE FROM "informix".ss_cte_procesando WHERE numcte = pNumcte;
		END IF;
    END IF;


	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
