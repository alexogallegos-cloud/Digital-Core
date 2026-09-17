CREATE PROCEDURE "informix".sp_guarda_archivonom_batch_bei(
        p_nombreTemporal    CHAR(17),
        p_codEmpresa        CHAR(3),
        p_idUsuario         INTEGER,
        p_fechaApp          CHAR(10),
        p_idEstatus         INTEGER,
        p_concepto          CHAR(10),
        p_importe           MONEY(10,2),
        p_empleados         INTEGER,
        p_motivo			VARCHAR(30)
)
RETURNING char(5), INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Guarda el nombre de los archivos de dispersion en proceso batch
-- AUTOR : SOLSER 
-- FECHA : 08/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel - Cordinacion Internet - G3
-- FECHA DE LIBERACION: 
--***************************************************************************************************

DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
 	DEFINE sIdOper INTEGER;

 	LET sIdOper=0;
 	LET cod_ret="00000";

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,sIdOper;
      END IF ;
    END EXCEPTION ;

    SET LOCK MODE TO WAIT 4;

    IF(LENGTH(TRIM(NVL(p_nombreTemporal,''))) = 0) THEN
        LET cod_ret="00001";
    END IF;

    IF(LENGTH(TRIM(NVL(p_codEmpresa,''))) = 0) THEN
        LET cod_ret="00002"; 
    END IF;

    IF(NVL(p_idUsuario, -1) <= 0) THEN
        LET cod_ret="00003"; 
    END IF;

    IF(LENGTH(TRIM(NVL(p_fechaApp,''))) = 0) THEN
        LET cod_ret="00004";
    END IF;

    IF(NVL(p_idEstatus, -1) <= 0) THEN
        LET cod_ret="00005"; 
    END IF;

    IF(LENGTH(TRIM(NVL(p_concepto,''))) = 0) THEN
        LET cod_ret="00006";
    END IF;

    IF(NVL(p_importe, -1) <= 0) THEN
        LET cod_ret="00007";
    END IF;

    IF(NVL(p_empleados, -1) <= 0) THEN
        LET cod_ret="00008";
    END IF;



       INSERT INTO bdibei:"informix".bei_archivos_eval(
            nom_tem_archivo,
            codigo_empresa,
            id_usuario,
            fecha_alta,
            fecha_aplicacion,
            fecha_estatus,
            id_estatus_eval,
            concepto,
            importe,
            cant_empleados,
            motivo
       )
       VALUES(
            p_nombreTemporal,
            p_codEmpresa,
            p_idUsuario,
            sysdate,
            to_date(p_fechaApp,'%d/%m/%Y'),
            sysdate,
            p_idEstatus,
            p_concepto,
            p_importe,
            p_empleados  ,
            p_motivo     
       );

       LET sIdOper = DBINFO('sqlca.sqlerrd1');
	

    RETURN cod_ret,sIdOper;

END
END PROCEDURE;