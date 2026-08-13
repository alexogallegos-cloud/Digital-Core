CREATE PROCEDURE "informix".actualizarregistroburo( pInstitucion char(2),pnum_solicitud char(20), pStatus char(1), pComentario char(80))

RETURNING char(6);


DEFINE cCodRet     CHAR(6);
DEFINE iSqlErr int;

LET iSqlErr = 0;
LET cCodRet = "000000";

SET ISOLATION TO dirty read;
SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET iSqlErr
       if iSqlErr <> 0 then
         LET cCodRet = iSqlErr;
          RETURN cCodRet;
       end if
    END EXCEPTION;
    
    UPDATE bdiburo:br_traslado SET status = pStatus, fecha_insert=today WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
    DELETE bdiburo:sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
--IPCB Mayo2016 Reingenieria de Demonios.
    DELETE FROM bdiburo:br_respuesta WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
    DELETE FROM bdiburo:br_respuesta_aprocesar WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;   
    DELETE FROM bdiburo:br_respuesta_aprocesar_aux WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud; 	
--IPCB Mayo2016 Reingenieria de Demonios.
    UPDATE bdiburo:br_auditor SET comentario = pComentario   WHERE institucion = pInstitucion AND solicitud = pnum_solicitud;

    RETURN cCodRet;

END

END PROCEDURE;