CREATE PROCEDURE "informix".sp_guardar_monto_solicitado ( pNumSolicitud CHAR (20), sMontoSolicitado CHAR (20), sAceptoPopupOfertaPMB CHAR(1))
RETURNING
	CHAR(6) AS cCodRet;

    --DEFINICION DE VARIABLES DE ERROR
    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cCodRet         CHAR(6);

    --DECLARACION DE VARIABLES DE ERROR
    LET iSqlErr  = 0;
    LET iIsamErr = 0;
    LET cCodRet  ="000000";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet;
       END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --SET debug file to '/home/sysifx/OscarOjeda/sp_guardar_monto_solicitado.out';
    --TRACE ON; 

    IF NVL(pNumSolicitud,"") = "" OR NVL(sMontoSolicitado,"") = "" OR NVL(sAceptoPopupOfertaPMB,"") = "" THEN

		  LET cCodRet = "000001"; -- Parametros de entrada insuficiontes

    ELSE
	
		UPDATE ss_resum_scor_fin 
		SET monto_solicitado = sMontoSolicitado,
		acepto_popup_oferta_pmb = sAceptoPopupOfertaPMB 
		WHERE num_solicitud = pNumSolicitud;

    END IF;	

	RETURN cCodRet; 
END
END PROCEDURE
