CREATE PROCEDURE "informix".sp_pasamovsret( pempresa CHAR(3) )
RETURNING CHAR(5);
    
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
	DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vabierto     CHAR(1);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcuenta      CHAR(20); 
    DEFINE vfolio_suc   CHAR(16); 
    DEFINE vfecha_alta  DATE;
    DEFINE vtransacc    CHAR(4);
    DEFINE vmonto_ori   MONEY(14,2);
    DEFINE vmincta      CHAR(20);
    DEFINE vmaxcta      CHAR(20);
    
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
	LET vcodret1    = '';
    LET vcodret2    = '';
    LET vcodret3    = '';
    LET vabierto    = '0';
    LET vcomienza   = -1;
    LET vcuenta     = '';
    LET vfolio_suc  = '';
    LET vfecha_alta = '';
    LET vtransacc   = '';
    LET vmonto_ori  = 0;
    LET vmincta     = '';
    LET vmaxcta     = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_pasamovsret.err";
        TRACE ON;
        IF sql_err <> 0 THEN
			LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_pasamovsret.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_docret;
    
    -- // DEPURA REGISTROS DE LA sc_docret
    FOREACH cursor_depura WITH HOLD FOR      
        SELECT cuenta, folio_suc, fecha_alta, transacc, monto_ori
          INTO vcuenta, vfolio_suc, vfecha_alta, vtransacc, vmonto_ori
          FROM sc_docret    
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND siglas IN('SC','SD')
           AND cancelado IN('S','L')
           
        BEGIN WORK;
        LET vabierto = '1'; 
        
        -- // TRASPASA REGISTRO A sc_docret_pos
        INSERT INTO sc_docret_pos
        SELECT *
          FROM sc_docret
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND folio_suc = vfolio_suc
           AND fecha_alta = vfecha_alta
           AND transacc = vtransacc
           AND monto_ori = vmonto_ori;
         
        -- // SI EL REGISTRO SE RESPALDO, ELIMINA EL REGISTRO DE sc_docret
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            DELETE FROM sc_docret
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND folio_suc = vfolio_suc
               AND fecha_alta = vfecha_alta
               AND transacc = vtransacc
               AND monto_ori = vmonto_ori;
        ELSE
            ROLLBACK WORK;
            LET vabierto = '0';
            CONTINUE FOREACH;
        END IF;
             
        COMMIT WORK;
        LET vabierto = '0';
        
        LET vcuenta     = '';
        LET vfolio_suc  = '';
        LET vfecha_alta = '';
        LET vtransacc   = '';
        LET vmonto_ori  = 0;
    END FOREACH;
    
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;