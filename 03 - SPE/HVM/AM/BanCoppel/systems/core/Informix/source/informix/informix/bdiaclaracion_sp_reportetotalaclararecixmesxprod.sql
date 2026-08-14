CREATE PROCEDURE "informix".sp_reportetotalaclararecixmesxprod(fechaini DATE, fechaFIN DATE, ids_productos lVARCHAR)

	RETURNING VARCHAR(100) AS producto, CHAR(300) AS evento, INTEGER AS total;

    DEFINE res_producto 		CHAR(100);
    DEFINE res_evento 			CHAR(300);
    DEFINE res_total 			INTEGER;
    DEFINE productos 			LIST(INTEGER NOT NULL);

    LET productos = 'LIST{' || ids_productos || '}';

	SET ISOLATION TO DIRTY READ;
	
    BEGIN

        IF ids_productos = -1 THEN
            SELECT prod.descripcion AS producto, evento.descripcion AS evento, folio_csuac
            FROM acl_aclaracion AS aclara, acl_producto AS prod, acl_tipo_evento AS evento, acl_estatus_aclaracion
            WHERE aclara.fky_producto = prod.pky_producto AND
            aclara.fky_tipo_evento = evento.pky_tipo_evento AND
            aclara.fechacaptura BETWEEN fechaINi AND fechaFIN AND
            acl_estatus_aclaracion.pky_estatus_aclaracion = aclara.fky_estatus_aclaracion AND
            acl_estatus_aclaracion.nombre <> 'INTENTO'
            GROUP BY prod.descripcion, evento.descripcion, folio_csuac
            ORDER BY producto
            INTO temp temp_aclaras
            WITH NO LOG;
        END IF;

        IF ids_productos <> -1 THEN
            SELECT prod.descripcion AS producto, evento.descripcion AS evento, folio_csuac
            FROM acl_aclaracion AS aclara, acl_producto AS prod, acl_tipo_evento AS evento, acl_estatus_aclaracion
            WHERE aclara.fky_producto = prod.pky_producto AND
            aclara.fky_tipo_evento = evento.pky_tipo_evento AND
            aclara.fechacaptura BETWEEN fechaINi AND fechaFIN AND
            --prod.pky_producto in productos AND
            prod.fky_tipo_producto in productos AND
            acl_estatus_aclaracion.pky_estatus_aclaracion = aclara.fky_estatus_aclaracion AND
            acl_estatus_aclaracion.nombre <> 'INTENTO'
            GROUP BY prod.descripcion, evento.descripcion, folio_csuac
            ORDER BY producto
            INTO temp temp_aclaras
            WITH NO LOG;
        END IF;
        

        FOREACH
            SELECT DISTINCT producto, evento, count(*) AS total
            INTO res_producto, res_evento, res_total
            FROM temp_aclaras
            GROUP BY producto, evento
            
            RETURN res_producto, res_evento, res_total
            WITH resume;
        END FOREACH;

        DROP TABLE temp_aclaras;

    END;

END PROCEDURE
;