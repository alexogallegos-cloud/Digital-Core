CREATE PROCEDURE "informix".sp_consulta_perfil_ctas_frecuentes_bei2 (pNumCliente CHAR(9), pIdPerfil INTEGER, pIdUsuario INTEGER, pIdMancomunidad INTEGER) 
RETURNING CHAR(5), CHAR(1), CHAR(1);
--****************************************************************************************************
-- DESCRIPCION: Consulta si usuario cuenta con permiso para cuentas frecuentes (mancomunidad)
-- AUTOR : Jose Angel Hernandez Gonzalez
-- FECHA : 29/Agosto/2016
-- BD: bdibei
--****************************************************************************************************

--****************************************************************************************************
-- DESCRIPCION: Consulta si usuario cuenta con permiso para cuentas frecuentes (mancomunidad)
-- AUTOR : GUSTAVO BUJANO GUZMÁN
-- FECHA : 18/04/2017
-- BD: bdibei
--MODIFICACION: Se adecua la excepción para cuando son alta de usuarios
--****************************************************************************************************

-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
-- Variables
    DEFINE vNum_cta CHAR(8);
    DEFINE vIdMenuOper INTEGER;
    DEFINE vMancomunidad CHAR(1);
    DEFINE vAutoriza CHAR(1);
    LET cod_ret  = '00000';
    LET vNum_cta = '00000000';
    LET vIdMenuOper = 63;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN '', '', cod_ret;
      END IF;
    END EXCEPTION;
	
    IF NVL(pIdMancomunidad,'')='' OR NVL(pIdMancomunidad,'')='null'  THEN
		LET pIdMancomunidad=0;
	END IF;
	
    IF EXISTS (SELECT manc.autoriza, oper.mancomunado
        FROM bdibei:"informix".bei_mancomunidad AS manc
        INNER JOIN bdibei:"informix".bei_operaciones AS oper
            ON oper.id_perfil = pIdPerfil 
            AND oper.num_cta = vNum_cta 
            AND oper.id_menu_oper = vIdMenuOper
        WHERE manc.num_cta = vNum_cta 
            AND manc.num_cte = pNumCliente
            AND manc.id_usuario = pIdUsuario) and pIdMancomunidad = 0 THEN
                SELECT CASE WHEN manc.autoriza = 't' THEN 't' WHEN manc.autoriza = 'f' THEN 'f' ELSE '' END AS autoriza,
        CASE WHEN oper.mancomunado = 't' THEN 'M' WHEN oper.mancomunado = 'f' THEN 'I' ELSE '' END AS mancomunidad 
        INTO vAutoriza, vMancomunidad
        FROM bdibei:"informix".bei_mancomunidad AS manc
        INNER JOIN bdibei:"informix".bei_operaciones AS oper
            ON oper.id_perfil = pIdPerfil 
            AND oper.num_cta = vNum_cta 
            AND oper.id_menu_oper = vIdMenuOper
        WHERE manc.num_cta = vNum_cta 
            AND manc.num_cte = pNumCliente
            AND manc.id_usuario = pIdUsuario;
                RETURN cod_ret, vAutoriza, vMancomunidad;
    ELSE
        IF pIdMancomunidad <> 0  THEN
            IF EXISTS (select autoriza, mancomunado from bdibei:"informix".bei_admin_manco_det_temp where tipo_oper = 1  and num_cte = pNumCliente  and num_cta = vNum_cta and id_admin_manco =pIdMancomunidad) THEN
                            SELECT CASE WHEN autoriza = 't' THEN 't' WHEN autoriza = 'f' THEN 'f' ELSE '' END AS autoriza,
                            CASE WHEN mancomunado = 't' THEN 'M' WHEN mancomunado = 'f' THEN 'I' ELSE '' END AS mancomunidad 
                            INTO vAutoriza, vMancomunidad
                        from bdibei:"informix".bei_admin_manco_det_temp where tipo_oper = 1  and num_cte = pNumCliente and num_cta = vNum_cta and id_admin_manco =pIdMancomunidad;
                            RETURN cod_ret, vAutoriza, vMancomunidad;
            ELSE
                LET cod_ret = '00001';
                RETURN cod_ret, '', '';
            END IF
        ELSE 
                LET cod_ret = '00001';
                RETURN cod_ret, '', '';
        END IF;
   END IF
END
END PROCEDURE;