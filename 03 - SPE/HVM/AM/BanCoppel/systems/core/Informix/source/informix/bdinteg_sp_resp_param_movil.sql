CREATE PROCEDURE "informix".sp_resp_param_movil(pGrupo char(3), pElemento char(3), pSolicitud char(13))
RETURNING CHAR(5) as codret, CHAR(100) as pregunta, CHAR(100) as respuesta, char(2) as elemento

DEFINE iSqlErr		INTEGER;
DEFINE sPregunta        CHAR(100);
DEFINE sRespuesta       CHAR(100);
DEFINE sElemento        CHAR(2);


LET iSqlErr         =0;
LET sPregunta       ='';
LET sRespuesta      ='';
LET sElemento       ='';

BEGIN
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		RETURN iSqlErr, sPregunta, sRespuesta, sElemento;
	END IF;
END EXCEPTION;


        SELECT c.descripcion, b.descripcion, a.elemento INTO sPregunta, sRespuesta, sElemento
        FROM bdisolic:ss_detalle_scoring a INNER JOIN bdisolic:ss_scoring_element b 
            ON a.grupo=b.grupo AND a.elemento=b.elemento AND a.seccion=b.seccion
         INNER JOIN bdisolic:ss_scoring_grupo c ON b.grupo=c.grupo AND b.seccion=c.seccion 
        WHERE num_solicitud=pSolicitud AND a.grupo=pGrupo;
              

RETURN '00000', sPregunta, sRespuesta, sElemento;

END
END PROCEDURE;