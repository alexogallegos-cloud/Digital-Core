CREATE PROCEDURE "informix".sp_reportehoyayerremanente (fechaIni date, fechaFin date)

	RETURNING INTEGER AS remanente; -- 6 items

    DEFINE res_remanente 	INTEGER;
    DEFINE var_nuevas 		INTEGER;
    DEFINE var_anteriores 	INTEGER;

	SET ISOLATION TO DIRTY READ;
    
    BEGIN
        --Hace el conteo de aclaraciones nuevas por tipo de evento

        --Solo obtiene las aclaraciones nuevas
        SELECT count(*) AS nuevas
        INTO var_nuevas
        FROM acl_aclaracion, acl_estatus_aclaracion, acl_tipo_evento
        WHERE 
        acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
        acl_estatus_aclaracion.nombre <> 'INTENTO'
        AND acl_tipo_evento.pky_tipo_evento = acl_aclaracion.fky_tipo_evento
        AND fechacaptura = fechaFin;
        --group by acl_tipo_evento.descripcion;
        

        SELECT count(*) AS proceso
        INTO var_anteriores
        FROM
        acl_aclaracion, acl_estatus_aclaracion, acl_tipo_evento, acl_estatus_corporativo
        WHERE
        acl_estatus_aclaracion.pky_estatus_aclaracion = acl_aclaracion.fky_estatus_aclaracion AND
        acl_estatus_aclaracion.nombre = 'ACLARACION_INGRESADA' AND
        acl_aclaracion.fky_estatus_corp_analisis
        NOT IN (9, 10, 11, 12, 13, 14, 15, 16, 17, 18)
        AND acl_aclaracion.fky_estatus_corp_general NOT IN (2, 3, 5, 7)
        AND acl_tipo_evento.pky_tipo_evento = acl_aclaracion.fky_tipo_evento
        AND fechacaptura = fechaIni;
        --group by acl_tipo_evento.descripcion;
        RETURN var_anteriores + var_nuevas;
  END;

END PROCEDURE
;