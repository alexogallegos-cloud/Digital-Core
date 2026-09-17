CREATE PROCEDURE "informix".sp_resp_param_prospecteo(pGrupo char(3), pElemento char(3), pSolicitud char(13))
RETURNING CHAR(5) as codret, 
		  CHAR(100) as pregunta,
		  CHAR(100) as respuesta,
		  char(2) as elemento;

DEFINE iSqlErr			INTEGER;
DEFINE sPregunta        CHAR(100);
DEFINE sRespuesta       CHAR(100);
DEFINE sElemento        CHAR(2);


LET iSqlErr         = 0;
LET sPregunta       = '';
LET sRespuesta      = '';
LET sElemento       = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			RETURN iSqlErr, sPregunta, sRespuesta, sElemento;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/JoseLuis/529/sp_obtiene_productos_prospecteo.out";
	--TRACE ON;

    SELECT c.descripcion, b.descripcion, a.elemento INTO sPregunta, sRespuesta, sElemento
    FROM bdisolic:"informix".ss_detalle_scoring a INNER JOIN bdisolic:"informix".ss_scoring_element b
        ON a.grupo=b.grupo AND a.elemento=b.elemento
     INNER JOIN bdisolic:"informix".ss_scoring_grupo c ON b.grupo=c.grupo AND b.seccion=c.seccion
    WHERE num_solicitud=pSolicitud AND a.grupo=pGrupo;
              
	RETURN '00000', NVL(sPregunta,0), NVL(sRespuesta,0), NVL(sElemento,0);

END;
END PROCEDURE
