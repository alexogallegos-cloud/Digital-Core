CREATE PROCEDURE "informix".sp_elimina_referencias_duplicadas(pEmpresa CHAR(3), pNum_solicitud CHAR(20), pNumCte CHAR(20))
RETURNING CHAR(6)  AS cCodRet;
			
--Declaracion de variables-------------------------------------------------------- 
DEFINE iSqlErr				INTEGER;
DEFINE cCodRet 				CHAR(6);
DEFINE iContador			INTEGER;
DEFINE iSecuencia			INTEGER;
DEFINE cNumSolicitud		CHAR(20);
DEFINE cNumCte				CHAR(20);
DEFINE cNombre				CHAR(26);
DEFINE cNomobreDos			CHAR(26);
DEFINE cApellP				CHAR(26);
DEFINE cApellM				CHAR(26);


--Inicializacion de Variables----------------------------------------------------- 
LET iSqlErr					= 0;
LET cCodRet 				= '000001';
LET iContador 				= 0;
LET iSecuencia 				= 0;
LET cNumSolicitud			= '';
LET cNumCte					= '';
LET cNombre					= '';
LET cNomobreDos				= '';
LET cApellP					= '';
LET cApellM					= '';

	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/622/sp_elimina_referencias_duplicadas_pba.out';
	--TRACE ON;

	BEGIN 

		ON EXCEPTION SET iSqlerr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF TRIM(pEmpresa) <> '' AND TRIM(pNum_solicitud) <> '' AND TRIM(pNumCte) <> '' THEN
			FOREACH
				SELECT num_solicitud, numcte, MAX(secuencia), apell_paterno, apell_materno, nombre1, nombre2, COUNT(*)
					INTO cNumSolicitud, cNumCte, iSecuencia, cApellP, cApellM, cNombre, cNomobreDos, iContador
					FROM "informix".si_refclientes
					WHERE empresa = pEmpresa
						AND num_solicitud = pNum_solicitud
						AND numcte = pNumCte
						GROUP BY num_solicitud, numcte, apell_paterno, apell_materno, nombre1, nombre2
					HAVING COUNT(*) > 1
					
				IF iContador > 1 THEN
					DELETE FROM "informix".si_refclientes
						WHERE empresa = pEmpresa
						AND secuencia = iSecuencia
						AND num_solicitud = pNum_solicitud
						AND numcte = pNumCte;
						
						LET cCodRet	= '000000';
				END IF;
				
			END FOREACH
		ELSE
			LET cCodRet	= '000002';
		END IF;
		
		RETURN cCodRet;
	
	END
END PROCEDURE
DOCUMENT
'ModificÃ³: 97879606 - AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'Folio: 622.1',
'Fecha: 21/10/2019',
'ModificaciÃ³n: Se genera Procedimiento Almacenado para eliminar las referencias repetidas generadas en prospecteo',
'Solicita: Rodolfo GÃ³mez', 
'Base de datos: BDINTEG';

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