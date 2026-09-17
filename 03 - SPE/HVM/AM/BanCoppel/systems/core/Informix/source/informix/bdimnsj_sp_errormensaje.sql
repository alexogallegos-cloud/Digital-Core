CREATE PROCEDURE "informix".sp_errormensaje(Isecuencial INT)

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.

--DEFINIR VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE vsqlerr INTEGER;

--INICIALIZAR VARIABLES
LET cCodRet = '00001';
LET vsqlerr = 0;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
    --*******************************************************************************************************
    -- Realizo   : Ricardo Abel Gomez Velazquez
    -- Proyecto  : Replica Errores Latinia.
    -- Actividad : Se actualiza el estatus de los mensajes que no fueron enviados por la plataforma marcandolo con un estatus 2.
    -- Fecha     : 16/07/2014
    --*******************************************************************************************************
	
	IF (Isecuencial IS NULL OR Isecuencial = 0)
			THEN	   
		   LET cCodRet = '00001'; ----- El parametro que se recibe viene vacio.
		   RETURN cCodRet;
	END IF;

	UPDATE bdimnsj:"informix".mnsjr_trx_online SET estatus = 0 WHERE secuencial = Isecuencial;  

END;
RETURN cCodRet;

END PROCEDURE;