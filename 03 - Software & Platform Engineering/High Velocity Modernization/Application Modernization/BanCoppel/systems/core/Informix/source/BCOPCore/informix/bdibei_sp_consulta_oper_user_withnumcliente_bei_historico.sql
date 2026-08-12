CREATE PROCEDURE "informix".sp_consulta_oper_user_withnumcliente_bei_historico(pNumCliente CHAR(9), pIdPerfil INTEGER, pNoReg INTEGER, pRegIni INTEGER, pIdBitacoraAdmin INTEGER)
    RETURNING CHAR(5), INTEGER, INTEGER, INTEGER, CHAR(50), DECIMAL(16,2), DECIMAL(16,2), CHAR(5);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;
    DEFINE iTotalReg INTEGER;
    DEFINE iExistePerfilXCliente INTEGER;
    DEFINE sIdOper INTEGER;
    DEFINE sIdMenuOper INTEGER;
    DEFINE sNumCta CHAR(20);
    DEFINE sMontoMin DECIMAL(16,2);
    DEFINE sMontoMax DECIMAL(16,2);
    DEFINE sMancomunado BOOLEAN;
	DEFINE cMancomunado CHAR(5);

    LET sIdOper = 0;
    LET sIdMenuOper = 0;
    LET sNumCta = "";
    LET sMontoMin = 0.0;
    LET sMontoMax = 0.0;
    LET sMancomunado = "f";
	LET cMancomunado = "f";
    LET iTotalReg = 0;
    LET iExistePerfilXCliente = 0;
    LET cod_ret = "000";

	--****************************************************************************************************
	-- DESCRIPCION:  Consulta Operaciones de usuario para modificacion de usuario filtrado por número de cliente
	-- AUTOR : Gerardo García Ortiz - SOLSER
	-- FECHA : 07/10/2014
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	-- NOTA: Se clona el sp sp_consulta_oper_user_withnumcliente_bei para la consulta del detalle
	-- de la operacion perfilar operador del requerimiento Bitacora Administradores (11/Junio/2018)
	--***************************************************************************************************
	--****************************************************************************************************
    -- NOTA: Clonado para el requerimiento de bitacora de administradores
    -- AUTOR: Solser
    -- FECHA: 11/Junio/2018
	-- FECHA LIBERACIÓN PRODUCCIÓN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


BEGIN

    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        LET cod_ret = sql_err;
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret, iTotalReg, sIdOper, sIdMenuOper, sNumCta, sMontoMin, sMontoMax, cMancomunado;
      END IF;
    END EXCEPTION;

--**************************************************************************************************************

    IF NVL(pIdPerfil,-1) == -1 THEN
        LET cod_ret = '00001';
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado;
    END IF;

    IF NVL(pNoReg,-1) == -1 THEN
        LET cod_ret = '00002';
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado;
    END IF;

    IF NVL(pRegIni,-1) == -1 THEN
        LET cod_ret = '00003';
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado;
    END IF;

    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0) THEN
        LET cod_ret="00005";
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado;
    END IF;

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
--**************************************************************************************************************

    SELECT COUNT(*)
        INTO iExistePerfilXCliente
    FROM bdibei:"informix".bei_usuario_perfil_historico bup INNER JOIN bdibei:"informix".bei_usuario_historico bus
       ON (bup.id_bitacora_admin = bus.id_bitacora_admin)
        WHERE bup.id_perfil = pIdPerfil AND bus.num_cliente = pNumCliente AND bus.id_tipo_usuario <> 1 AND bus.id_bitacora_admin = pIdBitacoraAdmin;

      IF iExistePerfilXCliente == 0 THEN
        LET cod_ret = '00006';
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado;
      END IF;

      SELECT COUNT(*)
        INTO iTotalReg
      FROM bdibei:"informix".bei_operaciones_historico oper
        WHERE oper.id_perfil = pIdPerfil
        AND oper.id_bitacora_admin = pIdBitacoraAdmin;

      IF iTotalReg == 0 THEN
        LET cod_ret = '00004';
        LET cMancomunado = 'f';
        IF (sMancomunado) THEN
            LET cMancomunado = 't';
        END IF;
        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado;
      END IF;

--**************************************************************************************************************

      FOREACH
        SELECT SKIP pRegIni FIRST pNoReg id_oper,id_menu_oper,num_cta,monto_min,monto_max,mancomunado
          INTO sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,sMancomunado
        FROM bdibei:"informix".bei_operaciones_historico oper
            WHERE oper.id_perfil = pIdPerfil
            AND oper.id_bitacora_admin = pIdBitacoraAdmin

			LET cMancomunado = 'f';
            IF (sMancomunado) THEN
                LET cMancomunado = 't';
			END IF;

        RETURN cod_ret,iTotalReg,sIdOper,sIdMenuOper,sNumCta,sMontoMin,sMontoMax,cMancomunado WITH RESUME;
      END FOREACH;

END;
END PROCEDURE;