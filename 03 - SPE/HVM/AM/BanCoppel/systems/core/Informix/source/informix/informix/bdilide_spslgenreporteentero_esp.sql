CREATE PROCEDURE "informix".spslgenreporteentero_esp( p_dfechareporte DATE )
RETURNING CHAR(3), CHAR(80);
    
    DEFINE v_scodret    CHAR(5);
    DEFINE v_scodret2   CHAR(5);
    DEFINE v_scodret3   CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE error_info   CHAR(50);
    DEFINE v_smensaje   CHAR(80);
    DEFINE v_mrecaudado	MONEY(18,2);
    DEFINE v_dfechahoy	DATE;
    DEFINE vExiste      INTEGER;
    DEFINE vctemin      CHAR(20);
    DEFINE vctemax      CHAR(20);
    
    LET v_scodret = '';
    LET v_scodret2 = '';
    LET v_scodret3 = '';
    LET sql_err = 0;
    LET isam_err = 0;
    LET error_info = '';
    LET v_smensaje = '';
    LET v_mrecaudado = 0;
    LET v_dfechahoy = CURRENT::DATE;
    LET vExiste = 0;
    LET vctemin = '';
    LET vctemax = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET v_scodret = sql_err;
        LET v_scodret2 = isam_err;
        LET v_scodret3 = error_info;
        LET v_smensaje = sql_err||" * "||isam_err|| " * "||error_info;
        RETURN v_scodret, v_smensaje ;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/tmp/spslgenreporteentero_esp.out";  
    -- TRACE ON;                                           
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*)
      INTO vExiste
      FROM bdilide:sl_enteros 
     WHERE fech_entero = p_dfechareporte;
     
    IF vExiste > 0 THEN
        DELETE FROM bdilide:sl_enteros 
         WHERE fech_entero = p_dfechareporte;
    END IF;
    
    SELECT MIN(num_cte), MAX(num_cte)
      INTO vctemin, vctemax
      FROM bdilide:sl_detlide; 
     
    SELECT SUM(imp_recaudado) 
      INTO v_mrecaudado 
      FROM bdilide:sl_detlide 
     WHERE num_cte BETWEEN vctemin AND vctemax
       AND fecha_ret = p_dfechareporte 
     GROUP BY fecha_ret;
     
    IF v_mrecaudado IS NULL THEN
        LET v_mrecaudado = 0;
    END IF;
    
    INSERT INTO bdilide:sl_enteros (fech_entero, monto, num_operacion, fech_operacion, user_insert, fecha_insert)
    VALUES (p_dfechareporte, v_mrecaudado, '', '', 'informix', v_dfechahoy);
     
    LET v_scodret = '000';
    LET v_smensaje = 'EL PROCESO DE REPORTE ENTERO HA FINALIZADO CON EXITO';
     
    END;
    
    RETURN v_scodret, v_smensaje;
    
END PROCEDURE;