CREATE PROCEDURE "informix".sp_reporte_tarjetas_notificadas()
RETURNING VARCHAR(6), VARCHAR(80);

    DEFINE P_COD_RET VARCHAR(6);
    DEFINE P_MENSAJE VARCHAR(80);
    DEFINE vfecha_hoy DATE;
    DEFINE vsql CHAR(1150);
    DEFINE vPrimerDiaMes DATE;
    DEFINE vUltimoDiaMes DATE;

    BEGIN

    --SET DEBUG FILE TO "/informix/argoz/sp_reporte_tarjetas_notificadas.out";
    --TRACE ON;
    
    LET P_COD_RET = '00000';
    LET P_MENSAJE = 'PROCESO EXITOSO';
    
    --ObtenciÃ³n de fechas del mes anterior para su ejecuciÃ³n
    SET ISOLATION TO dirty READ;
    SELECT fecha_hoy, pri_dia_mes - 1 units month , pri_dia_mes - 1 units day 
        INTO vfecha_hoy, vPrimerDiaMes, vUltimoDiaMes
    FROM bdinteg:si_fechas;    
    
    --NOTA: Es importante que las columnas tengan el mismo nombre o crear un alias similar a la tabla temporal
    --Para evitar el error "Virtual column must have explicit name"
    
    --PASO 1. Recepcion en Sucursal
    SET ISOLATION TO dirty READ;
    
    SELECT fecha_insert fecha_mensaje_1, count(tarjeta) conteo_mensaje_1
    FROM bitacoraenvios_tjts b 
        WHERE estatus_envio = "V" 
        AND id_proceso = "REC_SUC" 
        AND tarjeta NOT IN (
                SELECT tarjeta FROM bitacoraenvios_tjts b 
                WHERE estatus_envio = "V"  
                AND id_proceso IN ("MSJ_NOTIF_SIA" , "MSJ_NOTIF_2" , "MSJ_NOTIF_3" , "MSJ_NOTIF_4")
            )
        AND fecha_insert BETWEEN (vPrimerDiaMes) AND (vUltimoDiaMes)
    GROUP BY fecha_mensaje_1
	ORDER BY fecha_mensaje_1 
        INTO TEMP tmp_bitacoras_rec_suc;
    
    
    --PASO 2. Notificacion del 2do aviso.
    SET ISOLATION TO DIRTY READ;
    SELECT date(fecha_insert) fecha_mensaje_2, count(tarjeta) conteo_mensaje_2
    FROM bitacoraenvios_tjts b
        WHERE estatus_envio = "V"
        AND id_proceso = "MSJ_NOTIF_2"
        AND tarjeta NOT IN (	
            SELECT tarjeta
            FROM bitacoraenvios_tjts b
            WHERE estatus_envio = "V" 
            AND id_proceso IN ("MSJ_NOTIF_SIA", "MSJ_NOTIF_3", "MSJ_NOTIF_4")
            )    
        AND fecha_insert BETWEEN (vPrimerDiaMes) AND (vUltimoDiaMes)
    GROUP BY fecha_mensaje_2
	ORDER BY fecha_mensaje_2 
        INTO TEMP tmp_bitacoras_notif_dos;
    
    --PASO 3. Notificacion del 3er aviso.
    SET ISOLATION TO DIRTY READ;
    SELECT fecha_insert fecha_mensaje_3, count(tarjeta) conteo_mensaje_3
    FROM bitacoraenvios_tjts b
    WHERE estatus_envio = 'V'
        AND id_proceso = 'MSJ_NOTIF_3'
        AND tarjeta NOT IN (	
            SELECT tarjeta
            FROM bitacoraenvios_tjts b
            WHERE estatus_envio = 'V' 
            AND id_proceso IN ('MSJ_NOTIF_SIA', 'MSJ_NOTIF_4')
            )    
        AND fecha_insert BETWEEN (vPrimerDiaMes) AND (vUltimoDiaMes)
    GROUP BY fecha_mensaje_3
	ORDER BY fecha_mensaje_3
        INTO TEMP tmp_bitacoras_notif_tres;
    
    --PASO 4. Notificacion del 4to aviso.
    SET ISOLATION TO DIRTY READ;
    SELECT fecha_insert fecha_mensaje_4, count(tarjeta) conteo_mensaje_4
    FROM bitacoraenvios_tjts b
    WHERE estatus_envio = 'V'
        AND id_proceso = 'MSJ_NOTIF_4'
        AND tarjeta NOT IN (	
            SELECT tarjeta
            FROM bitacoraenvios_tjts b
            WHERE estatus_envio = 'V' 
            AND id_proceso = 'MSJ_NOTIF_SIA'
            )    
        AND fecha_insert BETWEEN (vPrimerDiaMes) AND (vUltimoDiaMes)
    GROUP BY fecha_mensaje_4
	ORDER BY fecha_mensaje_4
        INTO TEMP tmp_bitacoras_notif_cuatro;
    
    --PASO 5. Tarjetas Asignadas
    SET ISOLATION TO DIRTY READ;
    SELECT DATE(fecha_insert) fecha_tarjetas_asignadas, count(tarjeta) conteo_tarjetas_asignadas
    FROM bitacoraenvios_tjts b
    WHERE estatus_envio = 'V'
        AND id_proceso = 'MSJ_NOTIF_SIA'    
        AND fecha_insert BETWEEN (vPrimerDiaMes) AND (vUltimoDiaMes)
    GROUP BY fecha_tarjetas_asignadas
	ORDER BY fecha_tarjetas_asignadas
        INTO TEMP tmp_bitacoras_tar_asignadas;    
    
    --PASO 6. Conteo de clientes
    SET ISOLATION TO dirty READ;
    SELECT fecha_insert fecha_registro, count(numcliente) conteo_usuarios
    FROM bitacoraenvios_tjts b, tarjeta t
    WHERE id_proceso = 'REC_SUC' 
        AND fecha_insert BETWEEN (vPrimerDiaMes) AND (vUltimoDiaMes)
        AND b.tarjeta = t.numtarjeta
    GROUP BY fecha_insert
    ORDER BY fecha_insert
        INTO TEMP tmp_usuarios_registrados;
        
    --Validar, crear y eliminar al finalizar el proceso.
    DROP TABLE IF EXISTS "informix".reporte_tarjetas_notificadas;    
    
    CREATE TABLE "informix".reporte_tarjetas_notificadas (        
        secuencial SERIAL NOT NULL,
        fecha_registro DATE,
        conteo_usuarios VARCHAR(5),
        fecha_mensaje_1   DATE,
        conteo_mensaje_1 VARCHAR(5),        
        fecha_mensaje_2  DATE,
        conteo_mensaje_2 VARCHAR(5),	
        fecha_mensaje_3  DATE,
        conteo_mensaje_3 VARCHAR(5),	
        fecha_mensaje_4  DATE,
        conteo_mensaje_4 VARCHAR(5),	
        fecha_tarjetas_asignadas DATE,
        conteo_tarjetas_asignadas VARCHAR(5),
        PRIMARY KEY(secuencial)
    )EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
    
   
    --PASO 1.1. Recepcion en Sucursal
    SET ISOLATION TO DIRTY READ;
    INSERT INTO reporte_tarjetas_notificadas (fecha_mensaje_1, conteo_mensaje_1)
    SELECT * FROM tmp_bitacoras_rec_suc;
   
    --PASO 2.2 Notificacion del 2do aviso.
    SET ISOLATION TO DIRTY READ;
    INSERT INTO reporte_tarjetas_notificadas ( fecha_mensaje_2, conteo_mensaje_2)
    SELECT * FROM tmp_bitacoras_notif_dos;
    
    --PASO 3.3 Notificacion del 3er aviso.
    SET ISOLATION TO DIRTY READ;
    INSERT INTO reporte_tarjetas_notificadas ( fecha_mensaje_3, conteo_mensaje_3)
    SELECT * FROM tmp_bitacoras_notif_tres;
    
    --PASO 4.4 Notificacion del 4to aviso.
    SET ISOLATION TO DIRTY READ;
    INSERT INTO reporte_tarjetas_notificadas ( fecha_mensaje_4, conteo_mensaje_4)
    SELECT * FROM tmp_bitacoras_notif_cuatro;

    --PASO 5.5 Tarjetas asignadas
    SET ISOLATION TO DIRTY READ;
    INSERT INTO reporte_tarjetas_notificadas ( fecha_tarjetas_asignadas, conteo_tarjetas_asignadas)
    SELECT * FROM tmp_bitacoras_tar_asignadas;
    
    --PASO 6.6. Conteo de clientes
    SET ISOLATION TO DIRTY READ;
    INSERT INTO reporte_tarjetas_notificadas (fecha_registro, conteo_usuarios)
    SELECT * FROM tmp_usuarios_registrados;
    
        --- A) Titulos de las columnas | Archivo ReporteNotificaciones_DDMMAAAA.txt';
        LET vsql = '';    
        LET vsql = 'echo "Fecha Registro|Conteo usuarios|Fecha mensaje 1 | Conteo Mensaje 1|Fecha mensaje 2 | Conteo Mensaje 2|Fecha mensaje 3 | Conteo Mensaje 3|Fecha mensaje 4 | Conteo Mensaje 4|Fecha tarjetas asignadas | Conteo Asignadas|" > /resplogifx/ReporteNotificaciones_'|| LPAD (day(vfecha_hoy),2,"0")||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = 'echo " UNLOAD TO /resplogifx/ReporteNotificaciones.unl SELECT NVL(TO_CHAR(fecha_registro, \"%d/%m/%Y\"),\"N/A\"), NVL(conteo_usuarios, \"0\"), NVL(TO_CHAR(fecha_mensaje_1, \"%d/%m/%Y\"),\"N/A\"), NVL(conteo_mensaje_1, \"0\") , NVL(TO_CHAR(fecha_mensaje_2, \"%d/%m/%Y\"),\"N/A\"), NVL(conteo_mensaje_2, \"0\"), NVL(TO_CHAR(fecha_mensaje_3, \"%d/%m/%Y\"),\"N/A\"), NVL(conteo_mensaje_3, \"0\"), NVL(TO_CHAR(fecha_mensaje_4, \"%d/%m/%Y\"),\"N/A\"), NVL(conteo_mensaje_4, \"0\"), NVL(TO_CHAR(fecha_tarjetas_asignadas, \"%d/%m/%Y\"),\"N/A\"), NVL(conteo_tarjetas_asignadas, \"0\") FROM reporte_tarjetas_notificadas;" > /resplogifx/reporte_notificaciones_sc.sql';
        SYSTEM vsql;   

        LET vsql ='';
        LET vsql= 'dbaccess intercard /resplogifx/reporte_notificaciones_sc.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql ='rm /resplogifx/reporte_notificaciones_sc.sql';
        SYSTEM vsql;
        
        LET vsql ='';
        LET vsql = "sed 's/|s//g' /resplogifx/ReporteNotificaciones.unl >> /resplogifx/ReporteNotificaciones_"|| LPAD (day(vfecha_hoy),2,"0")||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".txt";
        SYSTEM vsql;
        
        LET vsql ='rm /resplogifx/ReporteNotificaciones.unl';
        SYSTEM vsql;    

    
    DROP TABLE reporte_tarjetas_notificadas;
    
    RETURN 	P_COD_RET,P_MENSAJE;
       
    END;

END PROCEDURE;