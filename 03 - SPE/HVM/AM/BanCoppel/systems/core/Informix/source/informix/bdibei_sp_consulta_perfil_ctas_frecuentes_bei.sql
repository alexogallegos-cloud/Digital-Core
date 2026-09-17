CREATE PROCEDURE "informix".sp_consulta_perfil_ctas_frecuentes_bei(pNumCliente CHAR(9), pIdPerfil INTEGER, pIdUsuario INTEGER) 
RETURNING CHAR(5), CHAR(1), CHAR(1);
--****************************************************************************************************
-- DESCRIPCION: Consulta si usuario cuenta con permiso para cuentas frecuentes (mancomunidad)
-- AUTOR : Jose Angel Hernandez Gonzalez
-- FECHA : 29/Agosto/2016
-- BD: bdibei
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
    
    IF EXISTS (SELECT manc.autoriza, oper.mancomunado
        FROM bdibei:"informix".bei_mancomunidad AS manc
        INNER JOIN bdibei:"informix".bei_operaciones AS oper
            ON oper.id_perfil = pIdPerfil 
            AND oper.num_cta = vNum_cta 
            AND oper.id_menu_oper = vIdMenuOper
        WHERE manc.num_cta = vNum_cta 
            AND manc.num_cte = pNumCliente
            AND manc.id_usuario = pIdUsuario) THEN
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
        LET cod_ret = '00001';
        RETURN cod_ret, '', '';
    END IF;
END
END PROCEDURE;