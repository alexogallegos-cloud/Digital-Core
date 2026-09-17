CREATE procedure "informix".sp_reportesingredicta(fechaIni DATE, fechaFin DATE)

	RETURNING CHAR(50) AS titulo, INTEGER AS total, FLOAT AS monto;

    DEFINE res_titulo 	CHAR(50);
    DEFINE res_total 	INTEGER;
    DEFINE res_monto 	FLOAT;

	SET ISOLATION TO DIRTY READ;
	
    BEGIN
        SELECT 
            CasE WHEN mov.procede = 0 
                THEN 'Procede' 
                ELSE 'No procede' 
                END AS titulo
        , COUNT(*) AS total, SUM(monto) AS monto
        FROM acl_movimiento AS mov, acl_aclaracion AS acla
        WHERE 
        acla.fechacaptura BETWEEN fechaIni AND fechaFin
        AND acla.pky_aclaracion = mov.fky_aclaracion
        AND mov.procede IS NOT null
        GROUP BY mov.procede
        INTO temp temp_proc
        WITH NO LOG;
        
        SELECT 'Ingreso' AS titulo, COUNT(*) AS total, SUM(monto) AS monto
        FROM acl_aclaracion AS aclara, acl_estatus_aclaracion AS est, acl_movimiento AS mov
        WHERE fechacaptura BETWEEN fechaIni AND fechaFin
        AND est.pky_estatus_aclaracion = aclara.fky_estatus_aclaracion
        AND est.nombre <> 'INTENTO'
        AND aclara.pky_aclaracion = mov.fky_aclaracion
        INTO temp temp_ingr
        WITH NO LOG;

        SELECT *
        FROM temp_ingr
        UNION
        SELECT * FROM 
        temp_proc
        INTO temp temp_UNION
        WITH NO LOG;

        FOREACH
            SELECT titulo, total, monto
            INTO res_titulo, res_total, res_monto
            FROM temp_UNION
            RETURN res_titulo, res_total, res_monto
            WITH resume;
        END FOREACH;
		
        DROP TABLE temp_ingr;
        DROP TABLE temp_proc;
        DROP TABLE temp_UNION;

    END;
END PROCEDURE
;