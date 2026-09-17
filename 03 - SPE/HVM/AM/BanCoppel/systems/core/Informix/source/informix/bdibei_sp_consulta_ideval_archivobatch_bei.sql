CREATE PROCEDURE "informix".sp_consulta_ideval_archivobatch_bei(p_idOperacionManco INTEGER)
RETURNING CHAR(5), CHAR(11);

--****************************************************************************************************
-- DESCRIPCION:  Se consulta el id_evaluacion del archivo para dispersion en batch
-- AUTOR : SOLSER
-- FECHA : 27/DIC/2017
-- FECHA ACTUALIZACION : 11/04/2017
-- BD: bdibei
-- SOLICITO : BanCoppel - Coordinacion Internet - G3
-- FECHA DE LIBERACION:
--***************************************************************************************************

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE iTotalReg INTEGER;
    DEFINE vIdEvaluacion CHAR(11);

    LET cod_ret = '00000';
    LET iTotalReg = 0;
    LET vIdEvaluacion = "";

 BEGIN
 
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, NVL(vIdEvaluacion, "");
        END IF;
    END EXCEPTION;
   
   -- SET DEBUG FILE TO "/home/informix/BereniceOut/sp_consulta_ideval_archivobatch_bei.out";
    --TRACE ON;

    IF NVL(p_idOperacionManco, -1) == -1 THEN
        LET cod_ret = '00001'; -- Parametro incorrecto
        RETURN cod_ret, NVL(vIdEvaluacion, "");
    END IF;

    SET LOCK MODE TO WAIT 4;

    SELECT {+INDEX("informix".bei_archivos_eval archivo)} COUNT(*)
        INTO iTotalReg
        FROM bdibei:"informix".bei_archivos_eval bae
        WHERE bae.id_operacion_manco = p_idOperacionManco;

    IF iTotalReg == 0 THEN
        LET cod_ret = '00002'; -- No se encontraron registros coincidentes
        RETURN cod_ret, NVL(vIdEvaluacion, "");
    END IF ;

    SELECT {+INDEX("informix".bei_archivos_eval archivo)} id_evaluacion
        INTO vIdEvaluacion
        FROM bdibei:"informix".bei_archivos_eval as bae
        WHERE bae.id_operacion_manco = p_idOperacionManco;

    RETURN cod_ret, NVL(vIdEvaluacion, "") WITH RESUME;

END
END PROCEDURE;