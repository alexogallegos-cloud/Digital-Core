CREATE PROCEDURE "informix".sp_consultatkns_activtknadmin(pNumCliente CHAR(9), pSolicitud CHAR(10), pPaginacion INTEGER)

RETURNING CHAR(5), CHAR(10), INTEGER;
-- cod_ret, sns_token, vnum_tokens

--****************************************************************************************************
-- DESCRIPCION: Procedimiento que consulta los tokens para la activacion del token del adminitrador 
-- desde Renovacion de Token
-- AUTOR : Solser
-- FECHA : 31/08/2018
-- BD: bdibei
--***************************************************************************************************

	DEFINE sql_err INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE vnum_reg_xpag INTEGER;
    DEFINE sns_token CHAR(10);
    DEFINE vnum_tokens INTEGER;

	
	LET cod_ret = '00000';
    LET vnum_reg_xpag = 10;
    LET pPaginacion = pPaginacion * vnum_reg_xpag;
    LET sns_token = '';
    LET vnum_tokens = 0;

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consultatkns_activtknadmin.out";
--  TRACE ON;
	
	
BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, sns_token, vnum_tokens;
        END IF;
    END EXCEPTION;

    -- Valida parametros
    IF(NVL(pNumCliente, '') == '' OR NVL(pSolicitud, '') == '' OR NVL(pPaginacion, -1) == -1) THEN
        LET cod_ret = '00001'; -- Algun parametro requerido es nulo
        RETURN cod_ret, sns_token, vnum_tokens;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    SELECT NVL(COUNT(ns_token), 0) 
        INTO vnum_tokens
    FROM bdibei:"informix".bei_tokensolicitud
        WHERE numcte = pNumCliente
        AND solicitud = pSolicitud
        AND id_status = 130;

    IF(vnum_tokens > 0) THEN
        FOREACH
            SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                ns_token
                INTO sns_token
            FROM bdibei:"informix".bei_tokensolicitud
                WHERE numcte = pNumCliente
                AND solicitud = pSolicitud
				and ns_token not in (SELECT ns_token from "informix".bei_token WHERE num_cliente  = pNumCliente)
                AND id_status = 130

            RETURN cod_ret, sns_token, vnum_tokens WITH RESUME;
        END FOREACH;  
    ELSE
        LET cod_ret = '00002'; -- No se encontraron registros con los criterios requeridos
        RETURN cod_ret, sns_token, vnum_tokens;
    END IF;
       
END
END PROCEDURE;