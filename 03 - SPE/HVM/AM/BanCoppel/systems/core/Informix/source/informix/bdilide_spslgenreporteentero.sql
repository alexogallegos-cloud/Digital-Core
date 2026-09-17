CREATE PROCEDURE "informix".spslgenreporteentero(p_sempresa CHAR(3), 
                                                 p_dfechareporte DATE, 
                                                 p_susuario CHAR(8))

RETURNING CHAR(3), CHAR(80);

    DEFINE v_scodret    CHAR(3);
    DEFINE v_smensaje   CHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE error_info   CHAR(40);
    DEFINE v_sstatus	CHAR(1);
    DEFINE v_mrecaudado	MONEY(18,2);
    DEFINE v_dfechahoy	DATE;
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET v_scodret = sql_err;
        LET v_smensaje = sql_err||" * "||isam_err|| " * "||error_info;
        RETURN v_scodret, v_smensaje ;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/tmp/spslgenreporteentero.out";  
    -- TRACE ON;                                           
    
    LET v_dfechahoy = CURRENT::DATE;
    LET v_scodret = '003';
    LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO NO TERMINO ADECUADAMENTE. AVISE AL ADMINISTRADOR';
    
    BEGIN
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT status 
      INTO v_sstatus 
      FROM bdilide:sl_procesos 
     WHERE proceso = 'rep_entero' 
       AND fech_proceso = p_dfechareporte;
       
    IF v_sstatus <> 'NULL' THEN
        IF v_sstatus = 0 THEN
            DELETE FROM bdilide:sl_enteros 
             WHERE fech_entero = p_dfechareporte;
             
            SELECT SUM(imp_recaudado) 
              INTO v_mrecaudado 
              FROM bdilide:sl_detlide 
             WHERE num_cte BETWEEN (SELECT MIN(num_cte) FROM bdilide:sl_detlide) AND
                                   (SELECT MAX(num_cte) FROM bdilide:sl_detlide)
               AND fecha_ret = p_dfechareporte 
             GROUP BY fecha_ret;
             
            IF v_mrecaudado IS NULL THEN
                LET v_mrecaudado = 0;
            END IF;
            
            INSERT INTO bdilide:sl_enteros (fech_entero, monto, num_operacion, fech_operacion, user_insert, fecha_insert)
            VALUES (p_dfechareporte, v_mrecaudado, '', '', p_susuario, v_dfechahoy);
            
            UPDATE bdilide:sl_procesos 
               SET status = 1 
             WHERE proceso = 'rep_entero' 
               AND fech_proceso = p_dfechareporte;
               
            LET v_scodret = '000';
            LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO HA FINALIZADO CON EXITO';
        ELIF v_sstatus = 1 THEN
            LET v_scodret = '001';
            LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO YA HA SIDO GENERADO';
        END IF;
    ELSE
        IF EXISTS (SELECT fech_entero 
                     FROM bdilide:sl_enteros 
                    WHERE fech_entero = p_dfechareporte) THEN
            DELETE bdilide:sl_enteros 
             WHERE fech_entero = p_dfechareporte;
        END IF;
        
        SELECT NVL(SUM(imp_recaudado),0) 
          INTO v_mrecaudado 
          FROM bdilide:sl_detlide 
         WHERE num_cte BETWEEN (SELECT MIN(num_cte) FROM bdilide:sl_detlide) AND
                               (SELECT MAX(num_cte) FROM bdilide:sl_detlide)
               AND fecha_ret = p_dfechareporte 
         GROUP BY fecha_ret;
         
        IF v_mrecaudado IS NULL THEN
            LET v_mrecaudado = 0;
        END IF;
        
        INSERT INTO bdilide:sl_enteros (fech_entero, monto, num_operacion, fech_operacion, user_insert, fecha_insert)
        VALUES (p_dfechareporte, v_mrecaudado, '', '', p_susuario, v_dfechahoy);
        
        INSERT INTO bdilide:sl_procesos (proceso, fech_proceso, status, user_insert, fecha_insert)
        VALUES ('rep_entero', p_dfechareporte, '1', p_susuario, v_dfechahoy );
        
        LET v_scodret = '000';
        LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO HA FINALIZADO CON EXITO';
    END IF;
    
    END;
    
    RETURN v_scodret, v_smensaje;
    
END PROCEDURE;