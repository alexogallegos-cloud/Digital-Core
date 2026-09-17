CREATE PROCEDURE "informix".sp_inserta_oper_manco_bei(
    pIdPerfil INTEGER,
    pIdMenuOper INTEGER,
    pNumCta CHAR(16),
    pMontoMin DECIMAL(16,2),
    pMontoMax DECIMAL(16,2),
    pMancomunado CHAR(1),
    id_admin_manco INTEGER
)
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
	LET cod_ret = '000000';

--****************************************************************************************************
-- DESCRIPCION:  Guarda OPERACIONES de Mancomunidad por Cuenta
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

BEGIN


    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
        END IF ;
    END EXCEPTION ;

	IF(NVL(pIdMenuOper,0) <= 0) THEN
        LET cod_ret="00002";
    END IF;

	IF(NVL(pMontoMin,-1) < 0) THEN
        LET cod_ret="00003";
    END IF;

	IF(NVL(pMontoMax,-1) < 0) THEN
        LET cod_ret="00004";
    END IF;

	IF(NVL(id_admin_manco,0) <= 0) THEN
        LET cod_ret="00005";
    END IF;

	IF(LENGTH(TRIM(NVL(pNumCta,''))) = 0) THEN
        LET cod_ret="00006";
    END IF;

	IF(LENGTH(TRIM(NVL(pMancomunado,''))) = 0) THEN
        LET cod_ret="00007";
    END IF;

    IF(cod_ret <> '00000') THEN
        RETURN  cod_ret;
    END IF;


SET LOCK MODE TO WAIT 4;

    INSERT INTO "informix".bei_admin_manco_det_temp(
        id_admin_manco, tipo_oper,
        id_menu_oper, id_perfil,
        num_cta, monto_min,
        monto_max, mancomunado)
	VALUES(
        id_admin_manco,
        2, pIdMenuOper,
        pIdPerfil, pNumCta,
        pMontoMin, pMontoMax,
        pMancomunado);

    RETURN cod_ret;

END
END PROCEDURE;