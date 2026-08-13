CREATE PROCEDURE "informix".sp_actualiza_archivo_eval_bei( p_idEvaluacion INTEGER, p_estatus INTEGER, p_cta_origen VARCHAR(20), p_numctasb INTEGER, p_numctaso INTEGER)
RETURNING char(5);

--****************************************************************************************************
-- DESCRIPCION:  Actualiza la informaciÃ³n del archivo que se evalua
-- AUTOR : SOLSER 
-- FECHA : 08/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel - Cordinacion Internet - G3
-- FECHA DE LIBERACIÃ?N: 
--***************************************************************************************************


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER;

 	LET cod_ret="00000";

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
    END EXCEPTION ;
	
	--SET debug FILE TO "/home/informix/BereniceOut/sp_actualiza_archivo_eval_bei.out";
	--Trace ON;

    SET LOCK MODE TO WAIT 4;

    IF(NVL(p_idEvaluacion, -1) <= 0) THEN
        LET cod_ret="00001";
        RETURN cod_ret;
    END IF;

    IF(NVL(p_estatus, -1) <= 0) THEN
        LET cod_ret="00002"; 
        RETURN cod_ret;
    END IF;

    IF(p_estatus == 4 OR p_estatus == 5 OR p_estatus == 6 OR p_estatus ==7 ) THEN
      UPDATE bdibei:"informix".bei_archivos_eval 
         SET id_estatus_eval=p_estatus, fecha_estatus = sysdate
       WHERE id_evaluacion= p_idEvaluacion;
		
    ELSE
       UPDATE bdibei:"informix".bei_archivos_eval 
          SET id_estatus_eval=p_estatus, fecha_estatus = sysdate,cta_origen = p_cta_origen ,numctasb=p_numctasb ,numctaso=p_numctaso
        WHERE id_evaluacion= p_idEvaluacion;
    END IF;

	
    RETURN cod_ret;

END
END PROCEDURE;