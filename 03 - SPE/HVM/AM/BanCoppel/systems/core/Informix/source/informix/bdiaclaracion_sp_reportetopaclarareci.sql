CREATE PROCEDURE "informix".sp_reportetopaclarareci (fechaIni DATE, fechaFin DATE)

	RETURNING CHAR(50) AS fecha, INTEGER AS total, FLOAT AS promedio;
    
    DEFINE res_fecha 		CHAR(50);
    DEFINE res_total 		INTEGER;
    DEFINE res_promedio 	FLOAT;
    
	SET ISOLATION TO DIRTY READ;
	
    BEGIN
        SELECT (YEAR(acl_aclaracion.fechacaptura) || '-' || MONTH(acl_aclaracion.fechacaptura)) AS fecha
        ,YEAR(acl_aclaracion.fechacaptura) AS anio, MONTH(acl_aclaracion.fechacaptura) AS mes
        FROM acl_aclaracion, acl_estatus_aclaracion
        WHERE
        acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion
        AND acl_estatus_aclaracion.nombre != 'INTENTO'
        AND acl_aclaracion.fechacaptura BETWEEN fechaIni AND fechaFin
        ORDER BY anio, mes
        INTO temp temp_borrame
        WITH NO LOG;

        SELECT fecha, count(*) AS total, count(*)/2 AS promedio, mes, anio
        FROM temp_borrame
        GROUP BY fecha, mes, anio ORDER BY mes, anio
        INTO temp temp_sin_orden
        WITH no log;

        FOREACH
            SELECT fecha, total, promedio
            INTO res_fecha, res_total, res_promedio
            FROM temp_sin_orden
            RETURN res_fecha, res_total, res_promedio
            WITH resume;
        END FOREACH;
        
        DROP TABLE temp_borrame;
        DROP TABLE temp_sin_orden;
    END;
END PROCEDURE
;