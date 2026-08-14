CREATE PROCEDURE "informix".sp_valida_token_activacion_bei(pSucursal CHAR(4), pNumCliente CHAR(9), pIdUsuario INTEGER, pPaginacion INTEGER)

RETURNING CHAR(5), CHAR(9), INTEGER, CHAR(10), CHAR(150), INTEGER, CHAR(1), INTEGER;
-- cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros

--****************************************************************************************************
-- DESCRIPCION: Procedimiento que valida si un cliente tiene tokens para activacion desde renovacion de tokens
-- AUTOR : Solser
-- FECHA : 29/08/2018
-- BD: bdibei
--***************************************************************************************************

	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vid_tipo_usuario SMALLINT;
    DEFINE vnum_reg_xpag INTEGER;

    DEFINE snum_cte CHAR(9);
    DEFINE sid_usuario INTEGER;
    DEFINE sns_token CHAR(10);
    DEFINE snombre CHAR(150);
    DEFINE sid_status_token INTEGER;
    DEFINE sid_token_vencido CHAR(1);
    DEFINE stotal_registros INTEGER;

    DEFINE vnum_tokens INTEGER;
    DEFINE vnum_solicitud CHAR(10);
    DEFINE vtkns_preact INTEGER;
	DEFINE sid_tipo_usuario INTEGER;
	
	LET cod_ret = '00000';
    LET vid_tipo_usuario = 0;
    LET vnum_reg_xpag = 10;
    LET pPaginacion = pPaginacion * vnum_reg_xpag;

    LET snum_cte = '';
    LET sid_usuario = 0;
    LET sns_token = '';
    LET snombre = '';
    LET sid_status_token = 0;
    LET sid_token_vencido = '';
    LET stotal_registros = 0;

    LET vnum_tokens = 0;
    LET vnum_solicitud = '';
    LET vtkns_preact = 0;
	LET sid_tipo_usuario=0;

	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/2_sp_valida_token_activacion_bei.out";
  --TRACE ON;
  
  
  
   SET LOCK MODE TO WAIT 3;
	 SET ISOLATION TO DIRTY READ;

	
BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros;
        END IF;
    END EXCEPTION;

    -- Valida parametros
    IF(NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1 OR NVL(pPaginacion, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros;
    END IF;

   

    -- Validaciones particulares del SP
    SELECT id_tipo_usuario  INTO vid_tipo_usuario
    FROM bei_usuario  WHERE id_usuario = pIdUsuario;

    IF(vid_tipo_usuario = 1) THEN -- admin
        SELECT NVL(COUNT(ns_token), 0)   INTO vnum_tokens
        FROM bdibei:'informix'.bei_tokenexpira   WHERE num_cte = pNumCliente AND id_status_solicitud = 1;

        IF(vnum_tokens > 0) THEN
            SELECT FIRST 1 solicitud   INTO vnum_solicitud
            FROM bdibei:'informix'.bei_tokenexpira WHERE num_cte = pNumCliente AND id_status_solicitud = 1;

            SELECT NVL(COUNT(solicitud), 0)  INTO vtkns_preact
            FROM bdibei:"informix".bei_solicitudtoken WHERE numcte = pNumCliente  AND id_status = 130  AND solicitud = vnum_solicitud;

            IF(vtkns_preact > 0) THEN--{
			
				SELECT NVL(COUNT(ns_token), 0)   INTO stotal_registros
                FROM bdibei:'informix'.bei_tokenexpira WHERE num_cte = pNumCliente AND id_status_solicitud = 1;
				
				FOREACH
								SELECT SKIP pPaginacion FIRST vnum_reg_xpag
									num_cte, id_usuario,id_tipo_usuario, ns_token, nombre, id_status_token, id_token_vencido
									INTO snum_cte, sid_usuario, sid_tipo_usuario, sns_token, snombre, sid_status_token, sid_token_vencido
								FROM bdibei:'informix'.bei_tokenexpira WHERE num_cte = pNumCliente AND id_status_solicitud = 1
								
								IF (sid_tipo_usuario=1 AND sid_usuario==pIdUsuario)  OR (sid_tipo_usuario=2) THEN		
									RETURN cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros WITH RESUME;
								end if;
                END FOREACH;  
            ELSE
                LET cod_ret = '00002'; -- La solicitud de renovacion aun no tiene los tokens preactivos
                RETURN cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros;
            END IF;
        ELSE 
            LET cod_ret = '00003'; -- No existen tokens con solicitud de renovacion
            RETURN cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros;
        END IF;
    ELSE
        LET cod_ret = '00004'; -- No es administrador
        RETURN cod_ret, snum_cte, sid_usuario, sns_token, snombre, sid_status_token, sid_token_vencido, stotal_registros;
    END IF;

END;
END PROCEDURE;