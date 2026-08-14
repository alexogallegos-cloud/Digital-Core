CREATE PROCEDURE "informix".sp_reactivainvscrecs(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(200);
    DEFINE vfecha_hoy       DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2); 
    DEFINE vint_acum        MONEY(14,2); 
    DEFINE vfecha_mod       DATE;
    DEFINE vexiste          SMALLINT;
    DEFINE vfecha_alta      DATE;
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET ven_transacc  = 0;
    LET vsql          = '';
    LET vstmt         = '';
    LET vfecha_hoy    = '';
    LET vcuenta       = '';
    LET vmonto        = 0.00;
    LET vint_acum     = 0.00;
    LET vfecha_mod    = '';
    LET vexiste       = 0;
    LET vfecha_alta   = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_reactivainvscrecs.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_reactivainvscrecs.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'invscrecxactivar') THEN
        DROP TABLE "informix".invscrecxactivar;
    END IF;
    
    CREATE TABLE "informix".invscrecxactivar
      (
        cuenta      char(20)    not null,
        monto       money(18,2) not null,
        int_acum    money(14,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_invcrecxact ON "informix".invscrecxactivar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/invscrecxactivar.unl DELIMITER ''","'' INSERT INTO invscrecxactivar" > /resplogifx/conciliachq/abonos.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/abonos.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS HIGH FOR TABLE invscrecxactivar;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT cuenta, monto, int_acum
          INTO vcuenta, vmonto, vint_acum
          FROM invscrecxactivar
           
        BEGIN WORK;
        LET ven_transacc = 1;
        
        SELECT fecha_mod
          INTO vfecha_mod
          FROM sc_maenoc
         WHERE cuenta = vcuenta;
         
        IF vfecha_mod is null OR vfecha_mod = '' THEN
            UPDATE sc_maechq
               SET status_cta = '1',
                   sdo_actual = vmonto,
                   fecha_proceso = null,
                   fec_cancelac = ''
             WHERE cuenta = vcuenta;
             
            UPDATE sc_maenoc 
               SET fecha_alta = vfecha_hoy
             WHERE cuenta = vcuenta;
        ELSE
            UPDATE sc_maechq
               SET status_cta = '1',
                   sdo_actual = vmonto,
                   fecha_proceso = vfecha_hoy,
                   fec_cancelac = ''
             WHERE cuenta = vcuenta;
             
            UPDATE sc_maenoc 
               SET acum_sdo_int = vint_acum,
                   dia_sdo_pos = 13,
                   acum_sdo_pos = vmonto * 13
             WHERE cuenta = vcuenta;
             
            SELECT COUNT(*)
              INTO vexiste
              FROM sc_tasa_variable
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
               
            IF vexiste = 0 THEN
                SELECT fecha_alta
                  INTO vfecha_alta
                  FROM sc_maenoc
                 WHERE cuenta = vcuenta;
                 
                INSERT INTO sc_tasa_variable 
                SELECT empresa, cuenta, inicio_periodo, fin_periodo, tipo_tasa, valor_tasa, int_acum, isr, tasa_isr
                  FROM sc_tasa_var_hist
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tasa IN('M','P')
                   AND fin_periodo >= vfecha_alta;
                   
                DELETE FROM sc_tasa_var_hist
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND tipo_tasa IN('M','P')
                   AND fin_periodo >= vfecha_alta;
            END IF;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vcuenta = '';
        LET vmonto = 0.00;
        LET vint_acum = 0.00;
        LET vfecha_mod = '';
        LET vexiste = 0;
        LET vfecha_alta = '';
    END FOREACH;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;