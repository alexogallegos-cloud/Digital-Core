CREATE PROCEDURE "informix".sp_validatknadmin_renovaciontkn(pNumCliente CHAR(9), pIdUsuario INTEGER)

RETURNING CHAR(5), CHAR(10);
-- cod_ret, vSolicitud

--****************************************************************************************************
-- DESCRIPCION: Se valida si el administrador debe renovar su token
-- AUTOR : Solser
-- FECHA : 31/08/2018
-- BD: bdibei
--***************************************************************************************************

	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vExisteTkn INTEGER;
    DEFINE vSolicitud CHAR(10);

	LET cod_ret = '00000';
    LET vExisteTkn = 0;
    LET vSolicitud = '';

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_validatknadmin_renovaciontkn.out";
  --TRACE ON;
  
  
   SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;

	
BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vSolicitud;
        END IF;
    END EXCEPTION;

    -- Valida parametros
    IF(NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret, vSolicitud;
    END IF;

 

    SELECT NVL(COUNT(ns_token), 0)
        INTO vExisteTkn
    FROM bdibei:'informix'.bei_tokenexpira    
        WHERE num_cte = pNumCliente
        AND id_usuario = pIdUsuario
        AND id_status_solicitud = 1;

    IF(vExisteTkn > 0) THEN
        SELECT NVL(solicitud, '')
            INTO vSolicitud
        FROM bdibei:'informix'.bei_tokenexpira    
            WHERE num_cte = pNumCliente
            AND id_usuario = pIdUsuario
            AND id_status_solicitud = 1;
			
		delete "informix".bei_token WHERE  id_usuario = pIdUsuario AND  num_cliente = pNumCliente;	
		update bdibei:'informix'.bei_tokenexpira   set id_status_solicitud='4' WHERE num_cte = pNumCliente   AND id_usuario = pIdUsuario;

        RETURN cod_ret, vSolicitud;
    ELSE 
        LET cod_ret = '00002'; -- No se encontro registro en la tabla
        RETURN cod_ret, vSolicitud;
    END IF;

END
END PROCEDURE;