CREATE PROCEDURE "informix".sp_consulta_archivobatch_bei(pIdEvaluacion INTEGER)
RETURNING CHAR(5);

--****************************************************************************************************
-- DESCRIPCION:  Se valida que el archivo a dispersar se encuentra en estatus 6
-- AUTOR : SOLSER
-- FECHA : 08/MARZO/2016
-- FECHA ACTUALIZACION : 12/MARZO/2018
-- BD: bdibei
-- SOLICITO : BanCoppel - Coordinacion Internet - G3
-- FECHA DE LIBERACION:
--***************************************************************************************************


    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE dFechaActual DATE;
    DEFINE iTotalReg INTEGER;

    LET cod_ret = '00000';
    LET iTotalReg = 0;
    LET dFechaActual = '';

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
        END IF;
    END EXCEPTION;
   
     
    --SET DEBUG FILE TO "/home/informix/BereniceOut/sp_consulta_archivobatch_bei.out";
    --TRACE ON;

	IF NVL(pIdEvaluacion, 0) == 0 THEN
	 	  LET cod_ret = '00001';
            RETURN cod_ret;
	END IF;

    SET LOCK MODE TO WAIT 4;
	
    SELECT {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)} fecha_hoy
        INTO dFechaActual
        FROM bdicheq:sc_fechas
        WHERE empresa = "001";

    SELECT COUNT(*)
        INTO iTotalReg
        FROM bdibei:"informix".bei_archivos_eval
        WHERE id_evaluacion = pIdEvaluacion
        AND id_estatus_eval = 6;
       -- AND bae.fecha_estatus <= (EXTEND(CURRENT YEAR TO MINUTE) - INTERVAL(5) MINUTE TO MINUTE);

    IF iTotalReg == 0 THEN
        LET cod_ret = '00002';
    END IF;

    RETURN cod_ret;

END
END PROCEDURE;