CREATE PROCEDURE "informix".sp_valida_token_expira_bei(pSucursal CHAR(4), pNumCliente CHAR(9), pIdUsuario INTEGER, pPaginacion INTEGER)

RETURNING CHAR(5), CHAR(10), CHAR(150), CHAR(1), CHAR(1), INTEGER;
-- cod_ret, ns_token, nombre, id_status_solicitud, id_token_vencido, numero_tokens  

--****************************************************************************************************
-- DESCRIPCION: Procedimiento que valida si un cliente o usuario tiene tokens proximos a vencer o vencidos
-- AUTOR : Solser
-- FECHA : 31/07/2018
-- BD: bdibei
--***************************************************************************************************

	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vid_tipo_usuario SMALLINT;
    DEFINE vns_token VARCHAR(10);
    DEFINE vnombre CHAR(150);
    DEFINE vid_status_solicitud CHAR(1);
    DEFINE vid_token_vencido CHAR(1);
    DEFINE vnum_tokens INTEGER;
    DEFINE vnum_reg_xpag INTEGER;
	
	LET cod_ret = '00000';
    LET vid_tipo_usuario = 0;
    LET vns_token = '';
    LET vnombre = '';
    LET vid_status_solicitud = '';
    LET vid_token_vencido = '';
    LET vnum_tokens = 0;
    LET vnum_reg_xpag = 10;
    LET pPaginacion = pPaginacion * vnum_reg_xpag;

	
 --SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_valida_token_expira_bei.out";
  --TRACE ON;
  
  
   SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;

	
BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, vns_token, vnombre, vid_status_solicitud, vid_token_vencido, vnum_tokens;
        END IF;
    END EXCEPTION;

    -- Valida parametros
    IF(NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
         RETURN cod_ret, vns_token, vnombre, vid_status_solicitud, vid_token_vencido, vnum_tokens;
    END IF;

    

    -- Validaciones particulares del SP
    SELECT id_tipo_usuario 
        INTO vid_tipo_usuario
    FROM bei_usuario
        WHERE id_usuario = pIdUsuario;

    IF(vid_tipo_usuario = 1) THEN -- admin
        SELECT NVL(COUNT(ns_token), 0) 
            INTO vnum_tokens
        FROM bdibei:'informix'.bei_tokenexpira    
            WHERE num_cte = pNumCliente
            AND id_token_vencido = 0
            AND id_status_solicitud = 0;

        IF(vnum_tokens > 0) THEN
          FOREACH
            SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                ns_token, nombre, id_status_solicitud, id_token_vencido
              INTO vns_token, vnombre, vid_status_solicitud, vid_token_vencido
            FROM bdibei:'informix'.bei_tokenexpira    
                WHERE num_cte = pNumCliente
                AND id_token_vencido = 0
                AND id_status_solicitud = 0

            RETURN cod_ret, vns_token, vnombre, vid_status_solicitud, vid_token_vencido, vnum_tokens WITH RESUME;
          END FOREACH;  
        ELSE 
            RETURN cod_ret, vns_token, vnombre, vid_status_solicitud, vid_token_vencido, vnum_tokens;
        END IF;

    ELIF (vid_tipo_usuario = 2) THEN -- operador
        SELECT NVL(COUNT(ns_token), 0) 
            INTO vnum_tokens
        FROM bdibei:'informix'.bei_tokenexpira    
            WHERE num_cte = pNumCliente
            AND id_usuario = pIdUsuario;

        IF(vnum_tokens = 1) THEN
            SELECT ns_token, nombre, id_status_solicitud, id_token_vencido  
                INTO vns_token, vnombre, vid_status_solicitud, vid_token_vencido
            FROM bdibei:'informix'.bei_tokenexpira    
                WHERE num_cte = pNumCliente
                AND id_usuario = pIdUsuario;
        END IF;

        RETURN cod_ret, vns_token, vnombre, vid_status_solicitud, vid_token_vencido, vnum_tokens;
    END IF;

END;
END PROCEDURE;