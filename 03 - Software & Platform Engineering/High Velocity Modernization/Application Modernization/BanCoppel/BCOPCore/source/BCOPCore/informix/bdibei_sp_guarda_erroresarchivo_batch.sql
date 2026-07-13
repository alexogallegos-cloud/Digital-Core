CREATE PROCEDURE "informix".sp_guarda_erroresarchivo_batch(
        p_idEvaluacion      INTEGER,
        p_nombreTemporal    CHAR(17),
        p_renglon           INTEGER,
        p_idCatError        INTEGER
)
RETURNING char(5);

--****************************************************************************************************
-- DESCRIPCION:  Se registran los errores que se encuentran en los archivos de dispersión en proceso batch
-- AUTOR : SOLSER 
-- FECHA : 08/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel - Cordinacion Internet - G3
-- FECHA DE LIBERACIÓN: 
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

    SET LOCK MODE TO WAIT 4;

    IF(LENGTH(TRIM(NVL(p_idEvaluacion,''))) = 0) THEN
        LET cod_ret="00001";
    END IF;

    IF(LENGTH(TRIM(NVL(p_nombreTemporal,''))) = 0) THEN
        LET cod_ret="00002"; 
    END IF;

    IF(NVL(p_renglon, -1) <= 0) THEN
        LET cod_ret="00003"; 
    END IF;

    IF(NVL(p_idCatError, -1) <= 0) THEN
        LET cod_ret="00004";
    END IF;

       INSERT INTO bdibei:"informix".bei_errores_archivo(
            id_evaluacion,
            nom_tem_archivo,
            renglon_error,
            id_desc_error
       )
       VALUES(
            p_idEvaluacion,
            p_nombreTemporal,
            p_renglon,
            p_idCatError
       );
	

    RETURN cod_ret;

END
END PROCEDURE;