CREATE PROCEDURE "informix".sp_consulta_ctas_mod_perfilar_oper_historico(pIdBitacoraAdmin INTEGER)

RETURNING CHAR(5), INTEGER, CHAR(20);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE vid_historico INTEGER;
    DEFINE vnum_cta CHAR(20);

    LET cod_ret = '00000';
    LET vid_historico = 0;
    LET vnum_cta = '';


	-- *****************************************************************************************************************
	-- DESCRIPCION:  Se consultan las cuentas modificadas durante el alta o modificacion de un operador
	-- AUTOR: Solser
	-- FECHA: 17/07/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


BEGIN

    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        LET cod_ret = sql_err;
        RETURN cod_ret, NVL(vid_historico, 0), NVL(vnum_cta, '');
      END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
-- ***************************************************************************************************************

    IF (NVL(pIdBitacoraAdmin, -1) == -1) THEN
        LET cod_ret = '00001'; -- El parametro requerido es nulo
        RETURN cod_ret, NVL(vid_historico, 0), NVL(vnum_cta, '');
    END IF;

    FOREACH
		SELECT id_historico, num_cta
		  INTO
            vid_historico,
            vnum_cta
		FROM bdibei:"informix".bei_perfil_oper_ctas_mod_historico 
		WHERE id_bitacora_admin = pIdBitacoraAdmin
		ORDER BY id_historico ASC

		RETURN   
		    cod_ret,
		    NVL(vid_historico, 0),
		    NVL(vnum_cta, '')
		    WITH RESUME;
	END FOREACH;   

END
END PROCEDURE;