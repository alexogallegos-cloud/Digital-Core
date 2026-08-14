CREATE PROCEDURE "informix".sp_reporteaclarareciensucursal (fechaIni DATE, fechaFin DATE)

    RETURNING CHAR(8) AS fecha, INTEGER AS ingresadas, 
              INTEGER AS en_proceso, INTEGER AS dictaminadas,
              INTEGER AS con_dictamen_impreso, INTEGER AS finalizadas 

    DEFINE res_fecha 			CHAR(8);
    DEFINE res_ingresadas 		INTEGER;
    DEFINE res_en_proceso 		INTEGER;
    DEFINE res_dictaminadas 		INTEGER;
    DEFINE res_con_dictamen_impreso 	INTEGER;
    DEFINE res_finalizadas 		INTEGER;

	SET ISOLATION TO DIRTY READ;
	
    BEGIN
        --Cuenta las ingresadas
        SELECT (MONTH(fechacaptura) || '-' || YEAR(fechacaptura)) AS fecha, count(*) AS ingresadas
        FROM acl_aclaracion, acl_estatus_aclaracion
        WHERE acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
              acl_estatus_aclaracion.nombre = 'ACLARACION_INGRESADA' AND
              acl_aclaracion.fky_estatus_corp_analisis is null
              AND acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_aclaracion.fechacaptura
        INTO temp temp_ingresadas
        WITH NO LOG;

        SELECT fecha, sum(ingresadas) AS ingresadas
        FROM temp_ingresadas
        GROUP BY fecha
        INTO temp temp_ingresadas_fecha
        WITH NO LOG;

        --Cuenta las aclaraciones en proceso
        SELECT (MONTH(fechacaptura) || '-' || YEAR(fechacaptura)) AS fecha, count(*) AS en_proceso
        FROM acl_aclaracion, acl_estatus_aclaracion
        WHERE acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
              acl_estatus_aclaracion.nombre = 'ACLARACION_INGRESADA' AND
              acl_aclaracion.fky_estatus_corp_analisis IS NOT null
              AND acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_aclaracion.fechacaptura
        INTO temp temp_en_proceso
        WITH NO LOG;

        SELECT fecha, sum(en_proceso) AS en_proceso
        FROM temp_en_proceso
        GROUP BY fecha
        INTO temp temp_en_proceso_fecha
        WITH NO LOG;

        --Cuenta las aclaraciones dictaminadas
        SELECT (MONTH(fechacaptura) || '-' || YEAR(fechacaptura)) AS fecha, count(*) AS dictaminadas
        FROM acl_aclaracion, acl_estatus_aclaracion
        WHERE acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
              acl_estatus_aclaracion.nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO' 
              AND acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_aclaracion.fechacaptura
        INTO temp temp_dictaminadas
        WITH NO LOG;

        SELECT fecha, sum(dictaminadas) AS dictaminadas
        FROM temp_dictaminadas
        GROUP BY fecha
        INTO temp temp_dictaminadas_fecha
        WITH NO LOG;

        --Cuenta las aclaraciones con dictamen impreso
        SELECT (MONTH(fechacaptura) || '-' || YEAR(fechacaptura)) AS fecha, count(*) AS dictamen_impreso
        FROM acl_aclaracion, acl_estatus_aclaracion
        WHERE acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
              acl_estatus_aclaracion.nombre = 'ACLARACION_CON_DICTAMEN_IMPRESO' 
              AND acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_aclaracion.fechacaptura
        INTO temp temp_dictamen_impreso
        WITH NO LOG;

        SELECT fecha, sum(dictamen_impreso) AS dictamen_impreso
        FROM temp_dictamen_impreso
        GROUP BY fecha
        INTO temp temp_dictamen_impreso_fecha
        WITH NO LOG;

        --Cuenta las aclaraciones finalizadas
        SELECT (MONTH(fechacaptura) || '-' || YEAR(fechacaptura)) AS fecha, count(*) AS finalizadas
        FROM acl_aclaracion, acl_estatus_aclaracion
        WHERE acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
              acl_estatus_aclaracion.nombre = 'ACLARACION_FINALIZADA' 
              AND acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_aclaracion.fechacaptura
        INTO temp temp_finalizadas
        WITH NO LOG;

        SELECT fecha, sum(finalizadas) AS finalizadas
        FROM temp_finalizadas
        GROUP BY fecha
        INTO temp temp_finalizadas_fecha
        WITH NO LOG;

        FOREACH
            SELECT (CasE WHEN temp_ingresadas_fecha.fecha IS NOT null
                        THEN temp_ingresadas_fecha.fecha
                        ELSE CasE WHEN temp_en_proceso_fecha.fecha IS NOT null 
                             THEN temp_en_proceso_fecha.fecha
                             ELSE CasE WHEN temp_dictaminadas_fecha.fecha IS NOT null 
                                  THEN temp_dictaminadas_fecha.fecha
                                  ELSE CasE WHEN temp_dictamen_impreso_fecha.fecha IS NOT null 
                                       THEN temp_dictamen_impreso_fecha.fecha
                                       ELSE temp_finalizadas_fecha.fecha
                                       END
                                  END
                             END
                        END) AS fechas, ingresadas, en_proceso, dictaminadas, dictamen_impreso, finalizadas
            INTO res_fecha, res_ingresadas, res_en_proceso, res_dictaminadas, res_con_dictamen_impreso, res_finalizadas
            FROM (temp_ingresadas_fecha FULL JOIN temp_en_proceso_fecha 
                 ON temp_en_proceso_fecha.fecha = temp_ingresadas_fecha.fecha) 
                 FULL JOIN temp_dictaminadas_fecha ON temp_ingresadas_fecha.fecha = temp_dictaminadas_fecha.fecha
                 FULL JOIN temp_dictamen_impreso_fecha ON temp_dictamen_impreso_fecha.fecha = temp_dictaminadas_fecha.fecha
                 FULL JOIN temp_finalizadas_fecha ON temp_dictamen_impreso_fecha.fecha = temp_finalizadas_fecha.fecha
            ORDER BY fechas

           -- INTO temp temp
            --WITH NO LOG;

            RETURN res_fecha, 
            CasE WHEN res_ingresadas is null THEN 0 ELSE res_ingresadas END, 
            CasE WHEN res_en_proceso is null THEN 0 ELSE res_en_proceso END, 
            CasE WHEN res_dictaminadas is null THEN 0 ELSE res_dictaminadas END, 
            CasE WHEN res_con_dictamen_impreso is null THEN 0 ELSE res_con_dictamen_impreso END, 
            CasE WHEN res_finalizadas is null THEN 0 ELSE res_finalizadas END
            WITH resume;
        END FOREACH;

        --DROP TABLE temp;
        DROP TABLE temp_ingresadas;
        DROP TABLE temp_ingresadas_fecha;
        DROP TABLE temp_en_proceso;
        DROP TABLE temp_en_proceso_fecha;
        DROP TABLE temp_dictaminadas;
        DROP TABLE temp_dictaminadas_fecha;
        DROP TABLE temp_dictamen_impreso;
        DROP TABLE temp_dictamen_impreso_fecha;
        DROP TABLE temp_finalizadas;
        DROP TABLE temp_finalizadas_fecha;
    END;

END PROCEDURE
;