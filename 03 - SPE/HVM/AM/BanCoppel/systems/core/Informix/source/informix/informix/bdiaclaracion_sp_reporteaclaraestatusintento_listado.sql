CREATE PROCEDURE "informix".sp_reporteaclaraestatusintento_listado(fechaIni DATE, fechaFin DATE)

	RETURNING  CHAR(20) AS estatus_aclaracion, DATETIME YEAR to FRACTION(5) AS fecha_intento,CHAR (10) AS num_sucursal,CHAR (50) AS motivo_intento, CHAR (8) AS usuario,INTEGER AS usuario_cancela,INTEGER AS error_sistema,INTEGER AS resp_incorrecta_prefiltro,INTEGER AS error_conexion_interact,INTEGER AS error_conexion_hibernate,INTEGER AS error_causas_no_identificadas;
    
    DEFINE intento 	INTEGER;
    DEFINE v_estatus_aclaracion CHAR (20);
    DEFINE v_fecha_intento DATETIME YEAR to FRACTION(5);
    DEFINE v_num_sucursal CHAR (10);
    DEFINE v_motivo_intento CHAR (50) ;
    DEFINE v_usuario CHAR (8);
    
    DEFINE v_usuario_cancela INTEGER;
    DEFINE v_error_sistema INTEGER;
    DEFINE v_resp_incorrecta INTEGER;
    DEFINE v_con_interact INTEGER;
    DEFINE v_con_hibernate INTEGER;
    DEFINE v_error_NoRegistrado INTEGER;


	SET ISOLATION TO DIRTY READ;
	
    BEGIN
        LET intento =1;
        
        LET v_usuario_cancela = (SELECT COUNT(*) AS usuario_cancela 
            FROM bdiaclaracion:acl_aclaracion 
            WHERE acl_aclaracion.fechacaptura 
            BETWEEN fechaIni AND fechaFin 
            and  fky_estatus_aclaracion=intento
            AND fky_tipo_error_ingreso_acl=1);

        LET v_error_sistema = (SELECT COUNT(*) AS error_sistema 
            FROM bdiaclaracion:acl_aclaracion 
            WHERE acl_aclaracion.fechacaptura 
            BETWEEN fechaIni AND fechaFin 
            and  fky_estatus_aclaracion=intento
            AND fky_tipo_error_ingreso_acl=2);

         LET v_resp_incorrecta= (SELECT COUNT(*) AS resp_incorrecta 
            FROM acl_aclaracion 
            WHERE acl_aclaracion.fechacaptura 
            BETWEEN fechaIni AND fechaFin 
            and  fky_estatus_aclaracion=intento 
            AND fky_tipo_error_ingreso_acl=3);

          LET v_con_interact = ( SELECT COUNT(*) AS con_interact 
            FROM bdiaclaracion:acl_aclaracion 
            WHERE acl_aclaracion.fechacaptura 
            BETWEEN fechaIni AND fechaFin 
            and  fky_estatus_aclaracion=intento 
            AND fky_tipo_error_ingreso_acl=4);

           LET v_con_hibernate = ( SELECT COUNT(*) AS con_hibernate 
            FROM bdiaclaracion:acl_aclaracion 
            WHERE acl_aclaracion.fechacaptura 
            BETWEEN fechaIni AND fechaFin 
            and  fky_estatus_aclaracion=intento 
            AND fky_tipo_error_ingreso_acl=5);  

            LET v_error_NoRegistrado = ( SELECT COUNT(*) AS no_registrado 
            FROM bdiaclaracion:acl_aclaracion 
            WHERE acl_aclaracion.fechacaptura 
            BETWEEN fechaIni AND fechaFin 
            and  fky_estatus_aclaracion=intento 
            AND fky_tipo_error_ingreso_acl IS NULL);    
  
            FOREACH
               SELECT 
                    E_ACLARACION.nombre AS estatus_aclaracion,
                    ACLARACION.fechainicio AS fecha_intento,
                    ACLARACION.num_sucursal,
                    TIPO_ERROR_ACLARACION.tipo_error_ingreso_acl AS motivo_intento,
                    ACLARACION.num_empleado AS usuario 
                INTO  v_estatus_aclaracion,v_fecha_intento, v_num_sucursal, v_motivo_intento, v_usuario 
                FROM bdiaclaracion:acl_aclaracion  ACLARACION 
                RIGHT JOIN acl_estatus_aclaracion E_ACLARACION ON ACLARACION.fky_estatus_aclaracion = E_ACLARACION.pky_estatus_aclaracion 
                RIGHT JOIN acl_tipo_error_ingreso_acl TIPO_ERROR_ACLARACION ON ACLARACION.fky_tipo_error_ingreso_acl = TIPO_ERROR_ACLARACION.pky_tipo_error_ingreso_acl
                WHERE ACLARACION.fky_estatus_aclaracion = intento 
                AND ACLARACION.fechacaptura BETWEEN fechaIni  AND fechaFin
                --ORDER BY ACLARACION.fechainicio ASC
                UNION ALL
                
                SELECT 
                    E_ACLARACION.nombre AS estatus_aclaracion,
                    ACLARACION.fechainicio AS fecha_intento,
                    ACLARACION.num_sucursal,
                    'ERROR CAUSA NO IDENTIFICADA' AS motivo_intento,
                  --  TIPO_ERROR_ACLARACION.tipo_error_ingreso_acl AS motivo_intento,
                    ACLARACION.num_empleado AS usuario 
               -- INTO  v_estatus_aclaracion,v_fecha_intento, v_num_sucursal, v_motivo_intento, v_usuario 
                FROM bdiaclaracion:acl_aclaracion  ACLARACION 
                RIGHT JOIN acl_estatus_aclaracion E_ACLARACION ON ACLARACION.fky_estatus_aclaracion = E_ACLARACION.pky_estatus_aclaracion 
                --RIGHT JOIN acl_tipo_error_ingreso_acl TIPO_ERROR_ACLARACION ON ACLARACION.fky_tipo_error_ingreso_acl = TIPO_ERROR_ACLARACION.pky_tipo_error_ingreso_acl
                WHERE ACLARACION.fky_estatus_aclaracion = intento
                AND ACLARACION.fky_tipo_error_ingreso_acl IS NULL
                AND ACLARACION.fechacaptura BETWEEN fechaIni  AND fechaFin
                ORDER BY ACLARACION.fechainicio ASC 
                RETURN v_estatus_aclaracion,v_fecha_intento, v_num_sucursal, v_motivo_intento, v_usuario,v_usuario_cancela,v_error_sistema,v_resp_incorrecta,v_con_interact,v_con_hibernate,v_error_NoRegistrado
                WITH resume;
         END FOREACH; 
                 
    END;
END PROCEDURE;