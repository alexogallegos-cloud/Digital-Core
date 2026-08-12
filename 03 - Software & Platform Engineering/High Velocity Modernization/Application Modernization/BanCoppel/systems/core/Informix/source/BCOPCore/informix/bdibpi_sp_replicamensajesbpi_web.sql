CREATE PROCEDURE "informix".sp_replicamensajesbpi_web(iRegistros SMALLINT)
RETURNING CHAR(5) AS Retorno, INTEGER AS CodigoMensaje, CHAR(250) AS Mensaje

DEFINE cCod_Ret         CHAR(5);
DEFINE iCodigoMensaje   INTEGER;
DEFINE cMensaje         CHAR(250);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;
DEFINE vDesErr          CHAR(60);

LET cCod_Ret = '00000';
LET iCodigoMensaje = 0;
LET cMensaje = '';


BEGIN 
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret, 0, '';
    END EXCEPTION;

    FOREACH
        SELECT SKIP iRegistros FIRST 31 codigo, mensaje
        INTO iCodigoMensaje, cMensaje
        FROM bdibpi : bpi_catmensajes

        RETURN cCod_Ret, iCodigoMensaje, cMensaje
        WITH RESUME;
    END FOREACH
END
END PROCEDURE
DOCUMENT
"Obtiene los mensajes que serÃÂ¡n mostrados durante el proceso de preactivaciÃÂ³n de",
"Servicio de Banca Por Internet",
"Autor : RaÃÂºl Ruiz",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_can_tknxpira( pfecha DATE)
RETURNING CHAR(5);
----------------------------------------------------------------------------------------------------------------------------------------
-- Realiza: Rene Aldana 
-- Actividad: Valida los token que se encuentra en la tabla tkn_tokenexpira los cuales ya paso su fecha de caducidad ('31','12','2017') y   -- no fueron renovados.
-- Se requiere cancelarlos para que desde sucursal el cliente pueda solicitar un nuevo dispositivo Token.
-- SolicitÃÂÃÂ³: Alejandro Vazquez
-- Fecha de Solicitud: 02/28/2017
-- Modifica: Rene Aldana 18/01/2018
-- Identifica si algun token del usuario que esta en expirado se debe cancelar para que se pueda solicitar
-- nuevo Token desde el canal sucursal.

----------------------------------------------------------------------------------------------------------------------------------------


--Declaracion de variables
DEFINE vsCodRet CHAR(10);
DEFINE viSqlErr INTEGER;
DEFINE vTransaccion INTEGER;
DEFINE vNum_cliente CHAR(9);
DEFINE vNs_token    CHAR(9);

SET isolation to cursor stability;

  --SET DEBUG FILE TO "/home/informix/raldana/BPI/renotoken/spl/sp_can_tknxpira.out";
  --TRACE ON;

--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vTransaccion = 0;
LET vNum_cliente = '';
LET vNs_token    = '';

--Inicio del procedimiento

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
	
        IF viSqlErr <> 0 THEN
            LET vsCodRet = viSqlErr;
            IF vTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
			
            RETURN vsCodRet;
			
        END IF;
		
    END EXCEPTION;
	
    ON EXCEPTION IN (-535)
        LET vTransaccion = 1;
    END EXCEPTION WITH RESUME;

	SET LOCK MODE TO WAIT 3;
	
    IF vTransaccion = 1 THEN
         COMMIT WORK;
         BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
	
    IF vsCodRet = '00000' THEN
     		
        -- Pasar los token de la campaÃÂÃÂ±a anterior a la tabla historica. 
		-- Cancela los Token que estan dentro de la tabla token expira y los cuales ya fue su fecha de expiracion
			
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;			
		FOREACH 
			SELECT  b.num_cliente,b.ns_token-- 927
            INTO vNum_cliente,vNs_token
			FROM bdibpi:tkn_tokenexpira a 
			INNER JOIN bdinteg:si_bpitoken  b ON a.numcte = b.num_cliente
			INNER JOIN bdibpi:tkn_nseries   c ON a.ns_token =c.ns_token 
			WHERE a.id_status_solicitud = 'f'	
              AND b.id_status_token <> 199
              AND f_caducidad = MDY(month(pfecha),day(pfecha),year(pfecha)) 
			  
            UPDATE bdibpi:bpi_tokensolicitud SET id_status = '199' WHERE numcte = vNum_cliente and ns_token = vNs_token;
            UPDATE bdibpi:tkn_nseries SET id_status = '199' WHERE ns_token = vNs_token;
           
            INSERT INTO bdinteg:si_bpitokenhis 
            SELECT *  FROM bdinteg:si_bpitoken WHERE num_cliente= vNum_cliente ;
            
			UPDATE bdinteg:si_bpitokenhis  SET id_status_token = '199' WHERE num_cliente= vNum_cliente;
            DELETE FROM bdinteg:si_bpitoken WHERE num_cliente= vNum_cliente; 
			DELETE FROM bdibpi:tkn_tokenexpira where numcte = vNum_cliente and id_status_solicitud = 'f';	
		END FOREACH;
	--commit;
	END IF;
	--Inserta los token de la tabla tokenexpira y los pasa a la tabla tkn_tokenexpira_his
	INSERT INTO bdibpi:tkn_tokenexpira_his 
	SELECT *,CURRENT year to second from bdibpi:tkn_tokenexpira; 
			

	-- TRUNCATE TABLE "informix".tkn_tokenexpira;
	Commit;
		
	RETURN vsCodRet;
END
END PROCEDURE;