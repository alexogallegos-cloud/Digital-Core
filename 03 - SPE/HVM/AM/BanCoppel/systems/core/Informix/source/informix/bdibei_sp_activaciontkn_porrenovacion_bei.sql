CREATE PROCEDURE "informix".sp_activaciontkn_porrenovacion_bei(pNumCliente CHAR(9), pIdUsuario INTEGER, pNsToken CHAR(10), pSucursal CHAR(4))

RETURNING CHAR(5);
-- cod_ret

--****************************************************************************************************
-- DESCRIPCION: Procedimiento que activacion de tokens por renovacion
-- AUTOR : Solser
-- FECHA : 30/08/2018
-- BD: bdibei
--***************************************************************************************************

	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vExisteTkn INTEGER;
    DEFINE vStatusTknAnt INTEGER;
    DEFINE vStatus_manco SMALLINT;
    DEFINE vid_tipo_usuario SMALLINT;
	DEFINE cCodRet_Token	  CHAR(5);
	DEFINE pns_token    CHAR(9);
	DEFINE psolicitud   CHAR(10);

	LET cod_ret = '00000';
    LET vExisteTkn = 0;
    LET vStatusTknAnt = 0;
    LET vStatus_manco = -1;
    LET vid_tipo_usuario = 0;
	LET cCodRet_Token='00000';
	LET pns_token='';
	LET psolicitud='';
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_activaciontkn_porrenovacion_bei.out";
	--TRACE ON;
	
	

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF;
    END EXCEPTION;

    -- Valida parametros
    IF(NVL(pNumCliente, '') == '' OR NVL(pIdUsuario, -1) == -1 OR NVL(pNsToken, '') == '' OR NVL(pSucursal, '') == '') THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


	
	
    SELECT NVL(COUNT(ns_token), 0)
        INTO vExisteTkn
    FROM bdibei:"informix".bei_token
        WHERE id_usuario = pIdUsuario
        AND ns_token = pNsToken;

    IF(vExisteTkn > 0) THEN
        -- Se guarda en una variable el estatus actual del token
        SELECT NVL(id_status_token, -1)
        INTO vStatusTknAnt
        FROM bdibei:"informix".bei_token
        WHERE id_usuario = pIdUsuario
        AND ns_token = pNsToken;

        -- Actualizar el registro de la tabla bdibei:bei_token, donde corresponda al id_Operador y token anterior, 
        -- el estatus del token para a 220 y el campo fecha_status igual a current
        UPDATE bdibei:"informix".bei_token
        SET id_status_token = 220, f_status = CURRENT
        WHERE id_usuario = pIdUsuario
        AND ns_token = pNsToken;
		
		
        -- Insertar el del cambio de estatus del token anterior, registro en la tabla: bdibei:bei_tokenhis 
        -- con estatus con el estatus actual del token y el nuevo estatus 220
        INSERT INTO informix.bei_tokenhis(id_usuario, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro) 
        VALUES(pIdUsuario, pNumCliente, pNsToken, pSucursal, '', vStatusTknAnt, CURRENT YEAR TO SECOND, CURRENT);

      -- Execute Procedure  bdibpi:"informix".sp_set_statustoken_admtoken(pNsToken, pNsToken, '220', 'informix','15');
	  EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(pNSToken,vStatusTknAnt, '220','transBEI','03') INTO cCodRet_Token;
			IF(cCodRet_Token <> '000') THEN
					LET cod_ret='00003';
					RETURN cod_ret;
				END IF;
				
				
	    select tkn.ns_token , sol.solicitud into pns_token, psolicitud
		from bdibei:bei_token as tkn inner join bdibei:bei_tokensolicitud as sol 
		on tkn.ns_token=sol.ns_token and  tkn.id_usuario = pIdUsuario and tkn.num_cliente=sol.numcte;
		
		Update bdibei:"informix".bei_solicitudtoken set id_status='220' where solicitud=psolicitud;
		update bdibei:"informix".bei_tokensolicitud set id_status='220' where ns_token = pNsToken and solicitud=psolicitud;

	  
        -- Si el usuario es admin y mancomunado se actualiza el estatus de mancomunidad, 
        -- en la tabla bdibei:bei_servicio se cambiara el campo status_manco=2
        SELECT id_tipo_usuario 
            INTO vid_tipo_usuario
        FROM bdibei:bei_tokenexpira
            WHERE id_usuario = pIdUsuario;

        IF(vid_tipo_usuario = 1) THEN -- Si el usuario es admin
            SELECT NVL(status_manco, -1) 
                INTO vStatus_manco
            FROM bdibei:"informix".bei_servicio 
                WHERE id_usuario = pIdUsuario;

					IF(vStatus_manco == 1) THEN -- y mancomunado
						UPDATE bdibei:"informix".bei_servicio 
						SET status_manco = 2, f_mod_manco = TODAY
						WHERE num_cliente = pNumCliente AND id_usuario = pIdUsuario; 
					ELSE
						LET vStatus_manco = -1;
					END IF;
		--END IF;
		ELSE
		 
			--IF(vid_tipo_usuario = 2) THEN 
						--proceso de renovaciÃ³n		
					DELETE "informix".bei_token WHERE  id_usuario = pIdUsuario AND ns_token = pNsToken;
							--UPDATE "informix".bei_servicio SET ns_token=null WHERE ns_token = pNsToken AND num_cliente=pNumCliente;
					UPDATE "informix".bei_tokenexpira set id_status_solicitud='4' where id_usuario = pIdUsuario AND num_cte=pNumCliente;  --concluye el flujo de renovaciÃ³n
			--END IF;
        END IF;

        RETURN cod_ret;
    ELSE 
        LET cod_ret = '00002'; -- No se encontro registro en la tabla
        RETURN cod_ret;
    END IF;

END
END PROCEDURE;