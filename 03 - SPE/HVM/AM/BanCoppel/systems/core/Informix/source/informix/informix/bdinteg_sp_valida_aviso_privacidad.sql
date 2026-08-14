CREATE PROCEDURE "informix".sp_valida_aviso_privacidad(pempresa CHAR(3), pcliente CHAR(20))
   RETURNING CHAR(3);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);

LET iSqlErr = 0;
LET cCodRet = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;

    IF pEmpresa IS NULL OR Trim(pEmpresa) = "" THEN
       LET cCodRet  = "001";
       RETURN cCodRet;
    END IF;

    IF pcliente IS NULL OR Trim(pcliente) = "" THEN
       LET cCodRet  = "001";
       RETURN cCodRet;
    END IF;

    --Validando que no exista en bitacora

IF EXISTS (
		SELECT prosp.numcte from bdisolic:ss_prospecteo_solicitudes prosp, bdinteg:si_cliente clie
		where prosp.numcte = pcliente
		and prosp.numcte = clie.numcte
		and clie.tipo_cliente = '2'
		and prosp.numcte NOT IN (SELECT numcte FROM bdinteg:si_autorizacion_privacidad WHERE empresa = '001' AND numcte = pcliente AND respuesta = '1')) THEN
		LET cNumCte = '1';
	  IF cNumCte = '1'  THEN
           LET cCodRet = '000';
		RETURN cCodRet;   
	  END IF;
ELSE      
        SELECT FIRST 1 numcte
        INTO cNumCte
        FROM bdinteg:si_cliente
        WHERE numcte IN (SELECT num_cte FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = pCliente)
        OR numcte IN    (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = pEmpresa AND num_cte = pCliente)
        OR numcte IN    (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = pEmpresa AND numcte = pCliente)
        OR numcte IN    (SELECT numcte FROM bdisolic:ss_solicitudes WHERE empresa = pEmpresa AND numcte = pCliente)
        OR numcte IN    (SELECT numcte FROM bdinteg:si_autorizacion_privacidad WHERE empresa = pEmpresa AND numcte = pCliente AND respuesta = '1');  

        IF cNumCte = '' OR cNumCte IS NULL THEN
           LET cCodRet = '000';
        ELSE
           LET cCodRet = '001';
		END IF;
RETURN cCodRet;
END IF;
END
END PROCEDURE;