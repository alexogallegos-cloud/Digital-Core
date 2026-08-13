CREATE PROCEDURE "informix".sp_valida_opermanco_desbloqueousr(
    pIdOperacion CHAR(4),
    pSubtipoOperacion CHAR(2),
    pIdMancomunidad CHAR(10),
    pIdOperacionManco CHAR(4) 
   )
  
    RETURNING CHAR(5);
  
-- ****************************************************************************************************
-- DESCRIPCION: Valida si existe un registro en la bitacora admin para la operacion: Operacion Mancomunada
-- subtipo: Solicitud para: Desbloqueo de Usuario
-- AUTOR : Solser
-- FECHA : 12/07/2018
-- BD: bdibei
-- FECHA DE LIBERACIÓN: 2018-Agosto
-- ****************************************************************************************************

    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);	
    DEFINE vtotal_registros INTEGER;

    LET cod_ret = '00000'; -- Consulta exitosa
    LET vtotal_registros = 0;

BEGIN

     ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        LET cod_ret = sql_err;
        RETURN cod_ret;
      END IF;
    END EXCEPTION;


-- Validacion de parametros
    IF (pIdOperacion IS NULL OR pSubtipoOperacion IS NULL OR pIdMancomunidad IS NULL OR pIdOperacionManco IS NULL) THEN
		LET cod_ret = '00100'; -- Parametros incorrectos
		 RETURN cod_ret;
    END IF;

    SET ISOLATION TO DIRTY READ;
  	SET LOCK MODE TO WAIT 3;

        SELECT
            COUNT(id_bitacora_admin)
        INTO
            vtotal_registros
        FROM bdibei:"informix".bei_bitacora_admin
            WHERE id_operacion = pIdOperacion -- es operacion mancomunada
            AND cgenerico3 = pSubtipoOperacion -- es solicitud
            AND cgenerico4 = TRIM(pIdMancomunidad)
            AND cgenerico5 = pIdOperacionManco;
            
        IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN cod_ret;
        END IF;

        RETURN cod_ret;

END	
END PROCEDURE;