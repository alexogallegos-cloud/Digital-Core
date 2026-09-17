CREATE PROCEDURE "informix".sp_reportehoyayer (fechaIni date, fechaFin date)

	RETURNING CHAR(50) AS tipo_evento, INTEGER AS nuevas, INTEGER AS proceso, INTEGER AS resueltas; -- 6 items

    DEFINE res_tipo_evento 	CHAR(50);
    DEFINE res_nuevas 		INTEGER;
    DEFINE res_proceso 		INTEGER;
    DEFINE res_resueltas 	INTEGER;

	SET ISOLATION TO DIRTY READ;
	
    BEGIN
        --Hace el conteo de aclaraciones nuevas por tipo de evento

        --Solo obtiene las aclaraciones nuevas
		SELECT DISTINCT 
        acl_tipo_evento.descripcion,
        count(*) AS nuevas
        FROM acl_aclaracion, acl_estatus_aclaracion, acl_tipo_evento
        WHERE 
        acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
        acl_estatus_aclaracion.nombre <> 'INTENTO'
        AND acl_tipo_evento.pky_tipo_evento = acl_aclaracion.fky_tipo_evento
        AND fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_tipo_evento.descripcion
        INTO temp temp_nuevas
        WITH NO LOG;

        --Hace el conteo de aclaraciones en proceso por tipo de evento
        SELECT DISTINCT acl_tipo_evento.descripcion, count(*) AS proceso
        FROM
        acl_aclaracion, acl_estatus_aclaracion, acl_tipo_evento, acl_estatus_corporativo
        WHERE
        acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
        acl_estatus_aclaracion.nombre = 'ACLARACION_INGRESADA' AND
        acl_aclaracion.fky_estatus_corp_analisis
        in (9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
        AND acl_aclaracion.fky_estatus_corp_general in (2, 3, 5, 7)
        AND acl_tipo_evento.pky_tipo_evento = acl_aclaracion.fky_tipo_evento
        AND fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_tipo_evento.descripcion
        INTO temp temp_proceso
        WITH NO LOG;

        --Hace el conteo de aclaraciones resueltas por tipo de evento
        SELECT DISTINCT 
        acl_tipo_evento.descripcion, count(*) AS resuelta
        FROM
        acl_aclaracion, acl_estatus_aclaracion, acl_tipo_evento
        WHERE
        acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
        acl_estatus_aclaracion.nombre in ('ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO', 'ACLARACION_CON_DICTAMEN_IMPRESO', 'ACLARACION_FINALIZADA')
        AND acl_tipo_evento.pky_tipo_evento = acl_aclaracion.fky_tipo_evento
        AND fechacaptura BETWEEN fechaIni AND fechaFin
        GROUP BY acl_tipo_evento.descripcion
        INTO temp temp_resuelta
        WITH NO LOG;

        
		FOREACH
        SELECT CasE WHEN temp_nuevas.descripcion IS null
                    THEN CasE WHEN temp_proceso.descripcion IS null THEN temp_resuelta.descripcion
                         ELSE temp_proceso.descripcion
                         END
                    ELSE temp_nuevas.descripcion
                    END,
                 nuevas, proceso, resuelta
        INTO res_tipo_evento, res_nuevas, res_proceso, res_resueltas
        FROM (temp_nuevas full join temp_proceso on temp_nuevas.descripcion = temp_proceso.descripcion) 
             full join temp_resuelta on temp_nuevas.descripcion = temp_resuelta.descripcion

        RETURN res_tipo_evento, 
                CasE WHEN res_nuevas IS null THEN 0 ELSE res_nuevas END, 
                CasE WHEN res_proceso IS null THEN 0 ELSE res_proceso END,
                CasE WHEN res_resueltas IS null THEN 0 ELSE res_resueltas END
                WITH resume;
      END FOREACH;
      DROP TABLE temp_nuevas;
      DROP TABLE temp_proceso;
      DROP TABLE temp_resuelta;
  END;

END PROCEDURE

;