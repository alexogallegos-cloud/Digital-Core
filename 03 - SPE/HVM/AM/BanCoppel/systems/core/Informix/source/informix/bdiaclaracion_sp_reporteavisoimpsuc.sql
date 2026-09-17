CREATE PROCEDURE "informix".sp_reporteavisoimpsuc(opcion_de_estatus integer, fechaInicial date, fechaFinal date)

    RETURNING  CHAR(25) AS folio_csuac, CHAR(25) AS numero_cuenta, CHAR(25) AS numero_tarjeta, CHAR(25) AS numero_sucursal, 
    CHAR(25) AS primer_nombre, CHAR(25) AS segundo_nombre, CHAR(25) AS apellido_materno, 
    CHAR(25) AS apellido_paterno, CHAR(25) AS numero_cliente, CHAR(50) AS resultado_nombre_promotor, 
    CHAR(25) AS importe_original, date AS fechacaptura, date AS fecha_vencimiento,
    INTEGER as resultado_estatus_inf, CHAR(25) AS estatus
    --,CHAR(25) AS fechahora_transaccion
    
    DEFINE res_estatus                                    CHAR(25);
    DEFINE resultado_folio_csuac                          CHAR(25);   
    DEFINE resultado_numero_cuenta                        CHAR(25);
    DEFINE resultado_numero_tarjeta                       CHAR(25);
    DEFINE resultado_numero_sucursal                      CHAR(25);

    DEFINE resultado_nombre1                              CHAR(25);
    DEFINE resultado_nombre2                              CHAR(25);
    DEFINE resultado_apell_paterno                        CHAR(25);
    DEFINE resultado_apell_materno                        CHAR(25);
    DEFINE resultado_numero_cliente                       CHAR(25);

    DEFINE resultado_numero_promotor                      CHAR(25);
    DEFINE resultado_nombre_promotor                      CHAR(50);
    DEFINE resultado_importe_original                     CHAR(25);  
    --DEFINE resultado_fechahora_transaccion                CHAR(25);  
    DEFINE resultado_camino                               INTEGER; 
    DEFINE resultado_fechacaptura                         DATE;
    DEFINE resultado_fecha_vencimiento                    DATE;
    DEFINE resultado_dias_vencimiento                     INTEGER;
    DEFINE resultado_estatus                              INTEGER;

    DEFINE var_fky_estatus_corp_analisis                     INTEGER;
    DEFINE var_cantidad_dias_desde_captura_hasta_hoy      INTEGER;
    DEFINE var_esta_digitalizado                                INTEGER;
    DEFINE var_respuesta_estimada                               INTEGER;


    LET resultado_estatus = 0;
    LET res_estatus = '';

    BEGIN

    select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';

    -- opcion_de_estatus 1 es ATENDIDAS
    IF opcion_de_estatus == 1 THEN
        FOREACH 
            SELECT DISTINCT acl.num_cliente, acl.folio_csuac, pr.numero_cuenta, pr.numero_tarjeta, acl.num_sucursal,
            cal.numero_emp_promotor, acl.importeoriginal, acl.fechacaptura
            INTO resultado_numero_cliente, resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, 
            resultado_numero_sucursal, resultado_numero_promotor, resultado_importe_original, resultado_fechacaptura
            
            FROM acl_aclaracion acl 
           
            INNER JOIN acl_regla_negocio rn ON acl.fky_regla_negocio = rn.pky_id_regla 
            INNER JOIN acl_rango_importe ri ON ri.fky_id_regla=rn.pky_id_regla
            INNER JOIN acl_producto pr ON acl.fky_producto=pr.pky_producto
            INNER JOIN acl_control_aclaracion_tel cal ON cal.fky_aclaracion=acl.pky_aclaracion
            INNER JOIN acl_control_digitalizacion_doc cdd ON cdd.folio_csuac=acl.folio_csuac
            INNER JOIN acl_movimiento mov on acl.folio_csuac=mov.folio_csuac

            WHERE fky_estatus_corp_analisis = 28
            AND ACL.fechacaptura BETWEEN fechaInicial AND fechaFinal            
            AND fky_tipo_documento = 1
            AND cdd.digitalizado = 1
            AND mov.fky_padre is null
            AND mov.duplicado=0
            AND cal.fky_opcion_cliente = 3
            --AND (today - acl.fechacaptura < ri.resp_estimada)

            -- cuenta la cantidad de registros que hay en la tabla acl_movimiento dado el folio csuac obtenido. Esto se hace porque
            -- si aparece más de un registro dado un folio, se deberá tomar al original si y solo si el fky_padre es nulo.
        
            select nombre1 
            INTO resultado_nombre1
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select nombre2 
            INTO resultado_nombre2
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_materno 
            INTO resultado_apell_materno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_paterno 
            INTO resultado_apell_paterno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            /*select nombre 
            INTO resultado_nombre_promotor
            FROM bdiaclaraciondes:acl_usuario
            WHERE num_empleado = resultado_numero_promotor;*/

            SELECT nombre
            INTO resultado_nombre_promotor
            FROM bdinteg:si_ejecut
            WHERE ejecutivo = resultado_numero_promotor;

            select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';

            LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;

            LET resultado_estatus = opcion_de_estatus;  
            LET res_estatus = 'Atendida'; 

            RETURN resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_numero_sucursal,
                resultado_nombre1, resultado_nombre2, resultado_apell_materno, resultado_apell_paterno,
                resultado_numero_cliente, resultado_nombre_promotor, resultado_importe_original, 
                resultado_fechacaptura, resultado_fecha_vencimiento, resultado_estatus, res_estatus

            WITH resume;
        END FOREACH;
    END IF;

    -- opcion_de_estatus 2 es PENDIENTES
    IF opcion_de_estatus == 2 THEN
        FOREACH 
            SELECT DISTINCT acl.num_cliente, acl.folio_csuac, pr.numero_cuenta, pr.numero_tarjeta, acl.num_sucursal,
            cal.numero_emp_promotor, acl.importeoriginal, acl.fechacaptura
            INTO resultado_numero_cliente, resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, 
            resultado_numero_sucursal, resultado_numero_promotor, resultado_importe_original, resultado_fechacaptura
            
            FROM acl_aclaracion acl 
           
            INNER JOIN acl_regla_negocio rn ON acl.fky_regla_negocio = rn.pky_id_regla 
            INNER JOIN acl_rango_importe ri ON ri.fky_id_regla=rn.pky_id_regla
            INNER JOIN acl_producto pr ON acl.fky_producto=pr.pky_producto
            INNER JOIN acl_control_aclaracion_tel cal ON cal.fky_aclaracion=acl.pky_aclaracion
            INNER JOIN acl_control_digitalizacion_doc cdd ON cdd.folio_csuac=acl.folio_csuac
            INNER JOIN acl_movimiento mov on acl.folio_csuac=mov.folio_csuac

            WHERE fky_estatus_corp_analisis = 28
            AND ACL.fechacaptura BETWEEN fechaInicial AND fechaFinal
            AND (resultado_dias_vencimiento + acl.fechacaptura >= today)
            AND fky_tipo_documento=1            
            AND cdd.digitalizado = 0
            AND mov.fky_padre is null
            AND mov.duplicado=0
            AND cal.fky_opcion_cliente = 3
            --AND (today - acl.fechacaptura < ri.resp_estimada)
        
            select nombre1 
            INTO resultado_nombre1
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select nombre2 
            INTO resultado_nombre2
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_materno 
            INTO resultado_apell_materno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_paterno 
            INTO resultado_apell_paterno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            /* select nombre 
            INTO resultado_nombre_promotor
            FROM bdiaclaraciondes:acl_usuario
            WHERE num_empleado = resultado_numero_promotor; */
            
            SELECT nombre
            INTO resultado_nombre_promotor
            FROM bdinteg:si_ejecut
            WHERE ejecutivo = resultado_numero_promotor;

            select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';


            LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;

            LET resultado_estatus = opcion_de_estatus;

            LET res_estatus = 'Pendiente';

            RETURN resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_numero_sucursal,
                resultado_nombre1, resultado_nombre2, resultado_apell_materno, resultado_apell_paterno,
                resultado_numero_cliente, resultado_nombre_promotor, resultado_importe_original, 
                resultado_fechacaptura, resultado_fecha_vencimiento, resultado_estatus, res_estatus

            WITH resume;
        END FOREACH;
    END IF;

    IF opcion_de_estatus == 3 THEN
        FOREACH 
            -- opcion_de_estatus 3 es VENCIDAS
            SELECT DISTINCT acl.num_cliente, acl.folio_csuac, pr.numero_cuenta, pr.numero_tarjeta, acl.num_sucursal,
            cal.numero_emp_promotor, acl.importeoriginal, acl.fechacaptura
            INTO resultado_numero_cliente, resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, 
            resultado_numero_sucursal, resultado_numero_promotor, resultado_importe_original, resultado_fechacaptura
            
            FROM acl_aclaracion acl 
           
            INNER JOIN acl_regla_negocio rn ON acl.fky_regla_negocio = rn.pky_id_regla 
            INNER JOIN acl_rango_importe ri ON ri.fky_id_regla=rn.pky_id_regla
            INNER JOIN acl_producto pr ON acl.fky_producto=pr.pky_producto
            INNER JOIN acl_control_aclaracion_tel cal ON cal.fky_aclaracion=acl.pky_aclaracion
            INNER JOIN acl_control_digitalizacion_doc cdd ON cdd.folio_csuac=acl.folio_csuac
            INNER JOIN acl_movimiento mov on acl.folio_csuac=mov.folio_csuac

            WHERE fky_estatus_corp_analisis = 28
            AND ACL.fechacaptura BETWEEN fechaInicial AND fechaFinal            
            AND (resultado_dias_vencimiento + acl.fechacaptura < today)
            AND fky_tipo_documento = 1
            AND cdd.digitalizado = 0
            AND mov.fky_padre is null
            AND mov.duplicado=0
            AND cal.fky_opcion_cliente = 3
            --AND (today - acl.fechacaptura > ri.resp_estimada)    
        
            select nombre1 
            INTO resultado_nombre1
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select nombre2 
            INTO resultado_nombre2
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_materno 
            INTO resultado_apell_materno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_paterno 
            INTO resultado_apell_paterno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            /*select nombre 
            INTO resultado_nombre_promotor
            FROM bdiaclaraciondes:acl_usuario
            WHERE num_empleado = resultado_numero_promotor;*/

            SELECT nombre
            INTO resultado_nombre_promotor
            FROM bdinteg:si_ejecut
            WHERE ejecutivo = resultado_numero_promotor;


            select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';


            LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;

            LET resultado_estatus = opcion_de_estatus;

            LET res_estatus = 'Vencida';

            RETURN resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_numero_sucursal,
                resultado_nombre1, resultado_nombre2, resultado_apell_materno, resultado_apell_paterno,
                resultado_numero_cliente, resultado_nombre_promotor, resultado_importe_original, 
                resultado_fechacaptura, resultado_fecha_vencimiento, resultado_estatus, res_estatus

            WITH resume;
        END FOREACH;
    END IF;

    IF opcion_de_estatus == 4 THEN
        FOREACH 
            -- opcion_de_estatus 4 es TODAS
            SELECT DISTINCT acl.num_cliente, acl.folio_csuac, pr.numero_cuenta, pr.numero_tarjeta, acl.num_sucursal,
            cal.numero_emp_promotor, acl.importeoriginal, acl.fechacaptura, fky_estatus_corp_analisis,
            ri.resp_estimada, cdd.digitalizado

            INTO resultado_numero_cliente, resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, 
            resultado_numero_sucursal, resultado_numero_promotor, resultado_importe_original, resultado_fechacaptura,
            var_fky_estatus_corp_analisis, var_respuesta_estimada, var_esta_digitalizado

            FROM acl_aclaracion acl 
           
            INNER JOIN acl_regla_negocio rn ON acl.fky_regla_negocio = rn.pky_id_regla 
            INNER JOIN acl_rango_importe ri ON ri.fky_id_regla=rn.pky_id_regla
            INNER JOIN acl_producto pr ON acl.fky_producto=pr.pky_producto
            INNER JOIN acl_control_aclaracion_tel cal ON cal.fky_aclaracion=acl.pky_aclaracion
            INNER JOIN acl_control_digitalizacion_doc cdd ON cdd.folio_csuac=acl.folio_csuac
            INNER JOIN acl_movimiento mov on acl.folio_csuac=mov.folio_csuac

            WHERE fky_estatus_corp_analisis = 28
            AND fky_tipo_documento=1
            AND mov.fky_padre is null
            AND mov.duplicado=0
            AND cal.fky_opcion_cliente = 3
            AND acl.fechacaptura BETWEEN fechaInicial AND fechaFinal

            select dias_vencimiento
            into resultado_dias_vencimiento
            from acl_cat_tipo_aclaracion 
            WHERE pky_cat_tipo_aclaracion='2';

            LET var_cantidad_dias_desde_captura_hasta_hoy = today - resultado_fechacaptura;
                         
            -- Se usan las cláusulas "where" de cada opcion de estatus (pendiente, atendida y vencida) para así inferir
            -- cuál es el estatus que le corresponde a cada registro listado.
            IF
                var_fky_estatus_corp_analisis == 28 AND
                var_esta_digitalizado == 1 AND
                resultado_fechacaptura >= fechaInicial AND
                resultado_fechacaptura <= fechaFinal             
            THEN
                -- infiere que es un estatus ATENDIDAS
                LET resultado_estatus = 1;
                LET res_estatus = 'Atendida';
            ELIF
                var_fky_estatus_corp_analisis == 28 AND
                resultado_fechacaptura >= fechaInicial AND
                resultado_fechacaptura <= fechaFinal AND                
                var_esta_digitalizado == 0  AND      
                var_cantidad_dias_desde_captura_hasta_hoy <= resultado_dias_vencimiento 
            THEN
                -- infiere que es un estatus PENDIENTES
                LET resultado_estatus = 2;
                LET res_estatus = 'Pendiente';
            ELIF
                var_fky_estatus_corp_analisis == 28 AND
                resultado_fechacaptura >= fechaInicial AND
                resultado_fechacaptura <= fechaFinal AND
                var_esta_digitalizado == 0  AND
                var_cantidad_dias_desde_captura_hasta_hoy > resultado_dias_vencimiento
            THEN
                -- infiere que es un estatus VENCIDAS                
                LET resultado_estatus = 3;
                LET res_estatus = 'Vencida';
            END IF;                                        

            select nombre1 
            INTO resultado_nombre1
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select nombre2 
            INTO resultado_nombre2
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_materno 
            INTO resultado_apell_materno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            select apell_paterno 
            INTO resultado_apell_paterno
            FROM bdinteg:si_cliente
            WHERE numcte = resultado_numero_cliente;

            /*select nombre 
            INTO resultado_nombre_promotor
            FROM bdiaclaraciondes:acl_usuario
            WHERE num_empleado = resultado_numero_promotor;*/

            SELECT nombre
            INTO resultado_nombre_promotor
            FROM bdinteg:si_ejecut
            WHERE ejecutivo = resultado_numero_promotor;

            LET resultado_fecha_vencimiento=resultado_fechacaptura+resultado_dias_vencimiento UNITS DAY;

            RETURN resultado_folio_csuac, resultado_numero_cuenta, resultado_numero_tarjeta, resultado_numero_sucursal,
                resultado_nombre1, resultado_nombre2, resultado_apell_materno, resultado_apell_paterno,
                resultado_numero_cliente, resultado_nombre_promotor, resultado_importe_original, 
                resultado_fechacaptura, resultado_fecha_vencimiento, resultado_estatus, res_estatus

            WITH resume;

        END FOREACH;
    END IF;

    END
END PROCEDURE;