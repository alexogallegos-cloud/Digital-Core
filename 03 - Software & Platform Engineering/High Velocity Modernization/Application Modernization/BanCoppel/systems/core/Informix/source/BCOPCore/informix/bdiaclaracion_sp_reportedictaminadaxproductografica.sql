CREATE PROCEDURE "informix".sp_reportedictaminadaxproductografica (procedente INTEGER, fechaIni DATE, fechaFin DATE,ids_productos lvarchar, ids_tipos_evento lvarchar)

	RETURNING lvarchar AS producto, INTEGER AS encontrados

    DEFINE res_areas 			lvarchar;
    DEFINE res_encontrados 		INTEGER;
    DEFINE productos 			LIST(INTEGER NOT NULL);
    DEFINE tipos_evento 		LIST(INTEGER NOT NULL);

    LET productos = 'LIST{' || ids_productos || '}';
    LET tipos_evento = 'LIST{' || ids_tipos_evento || '}';

	SET ISOLATION TO DIRTY READ;
	
    BEGIN

            IF ids_productos <> '-1' AND ids_tipos_evento <> '-1'
            --Cuando no hay ids_productos y no hay ids_tipos_evento
            THEN
                FOREACH
                    SELECT 
                    prod.descripcion AS producto, count(*) AS encontrados
                    INTO
                    res_areas, res_encontrados
                    FROM 
                    acl_aclaracion AS acla, acl_movimiento AS mov, 
                    acl_producto AS prod, acl_tipo_evento AS tipo_e,
                    acl_origen_evento AS origen, acl_entrada_bitacora AS bitacora, 
                    acl_estatus_aclaracion AS estatus
                    WHERE 
                    acla.procede = procedente AND
                    prod.pky_producto IN  productos AND
                    prod.pky_producto = acla.fky_producto AND
                    mov.fky_aclaracion = acla.pky_aclaracion AND
                    tipo_e.pky_tipo_evento IN  tipos_evento AND
                    tipo_e.pky_tipo_evento = acla.fky_tipo_evento AND
                    origen.pky_origen_evento = tipo_e.fky_origen_evento AND
                    bitacora.fky_aclaracion = acla.pky_aclaracion AND
                    bitacora.fechahora BETWEEN fechaIni AND fechaFin AND
                    estatus.pky_estatus_aclaracion = bitacora.fky_estatus_aclaracion AND
                    estatus.nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO'
                    GROUP BY 
                    prod.descripcion

                    RETURN 
                        res_areas, res_encontrados
                    WITH resume;

               END FOREACH;
           END IF;
           --Termina IF -> Cuando no hay ids_productos y no hay ids_tipos_evento

            IF ids_productos <> '-1' AND ids_tipos_evento = '-1'
            --Cuando si hay ids_productos y no hay ids_tipos_evento
            THEN
                FOREACH
                    SELECT 
                    prod.descripcion AS producto, count(*) AS encontrados
                    INTO
                    res_areas, res_encontrados
                    FROM 
                    acl_aclaracion AS acla, acl_movimiento AS mov, 
                    acl_producto AS prod, acl_tipo_evento AS tipo_e,
                    acl_origen_evento AS origen, acl_entrada_bitacora AS bitacora, 
                    acl_estatus_aclaracion AS estatus
                    WHERE 
                    acla.procede = procedente AND
                    prod.pky_producto IN  productos AND
                    prod.pky_producto = acla.fky_producto AND
                    mov.fky_aclaracion = acla.pky_aclaracion AND
                    tipo_e.pky_tipo_evento = acla.fky_tipo_evento AND
                    origen.pky_origen_evento = tipo_e.fky_origen_evento AND
                    bitacora.fky_aclaracion = acla.pky_aclaracion AND
                    bitacora.fechahora BETWEEN fechaIni AND fechaFin AND
                    estatus.pky_estatus_aclaracion = bitacora.fky_estatus_aclaracion AND
                    estatus.nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO'
                    GROUP BY 
                    prod.descripcion

                    RETURN 
                        res_areas, res_encontrados
                    WITH resume;

               END FOREACH;
           END IF;
           --Termina If -> Cuando si hay ids_productos y no hay ids_tipos_evento

            IF ids_productos = '-1' AND ids_tipos_evento <> '-1'
            --Cuando no hay ids_productos y si hay ids_tipos_evento
            THEN
                FOREACH
                    SELECT 
                    prod.descripcion AS producto, count(*) AS encontrados
                    INTO
                    res_areas, res_encontrados
                    FROM 
                    acl_aclaracion AS acla, acl_movimiento AS mov, 
                    acl_producto AS prod, acl_tipo_evento AS tipo_e,
                    acl_origen_evento AS origen, acl_entrada_bitacora AS bitacora, 
                    acl_estatus_aclaracion AS estatus
                    WHERE 
                    acla.procede = procedente AND
                    prod.pky_producto = acla.fky_producto AND
                    tipo_e.pky_tipo_evento IN  tipos_evento AND
                    mov.fky_aclaracion = acla.pky_aclaracion AND
                    tipo_e.pky_tipo_evento = acla.fky_tipo_evento AND
                    origen.pky_origen_evento = tipo_e.fky_origen_evento AND
                    bitacora.fky_aclaracion = acla.pky_aclaracion AND
                    bitacora.fechahora BETWEEN fechaIni AND fechaFin AND
                    estatus.pky_estatus_aclaracion = bitacora.fky_estatus_aclaracion AND
                    estatus.nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO'
                    GROUP BY 
                    prod.descripcion

                    RETURN 
                        res_areas, res_encontrados
                    WITH resume;

               END FOREACH;
           END IF;
           --Termina IF -> Cuando no hay ids_productos y si hay ids_tipos_evento

            IF ids_productos = '-1' AND ids_tipos_evento = '-1'
            --Cuando no hay ids_productos y no hay ids_tipos_evento
            THEN
                FOREACH
                    SELECT 
                    prod.descripcion AS producto, count(*) AS encontrados
                    INTO
                    res_areas, res_encontrados
                    FROM 
                    acl_aclaracion AS acla, acl_movimiento AS mov, 
                    acl_producto AS prod, acl_tipo_evento AS tipo_e,
                    acl_origen_evento AS origen, acl_entrada_bitacora AS bitacora, 
                    acl_estatus_aclaracion AS estatus
                    WHERE 
                    acla.procede = procedente AND
                    prod.pky_producto = acla.fky_producto AND
                    mov.fky_aclaracion = acla.pky_aclaracion AND
                    tipo_e.pky_tipo_evento = acla.fky_tipo_evento AND
                    origen.pky_origen_evento = tipo_e.fky_origen_evento AND
                    bitacora.fky_aclaracion = acla.pky_aclaracion AND
                    bitacora.fechahora BETWEEN fechaIni AND fechaFin AND
                    estatus.pky_estatus_aclaracion = bitacora.fky_estatus_aclaracion AND
                    estatus.nombre = 'ACLARACION_CON_DICTAMEN_NO_DIGITALIZADO'
                    GROUP BY 
                    prod.descripcion

                    RETURN 
                        res_areas, res_encontrados
                    WITH resume;

               END FOREACH;
           END IF;

           
   END;
END PROCEDURE

;