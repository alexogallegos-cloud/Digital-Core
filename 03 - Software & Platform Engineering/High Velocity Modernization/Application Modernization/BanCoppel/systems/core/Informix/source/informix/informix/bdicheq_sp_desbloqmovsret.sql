CREATE PROCEDURE "informix".sp_desbloqmovsret( pempresa CHAR(3), pfechaini DATE, pfechafin DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER, INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE nComit           SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE vsql             CHAR(300);
    DEFINE vstmt            CHAR(100);    
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(16,2);
    DEFINE vfolio           CHAR(20);
    DEFINE vsdo_retenido    MONEY(16,2);
    
    LET vcodret1      = "000";
    LET vcodret2      = "000";
    LET vcodret3      = "PROCESO CONCLUIDO";
    LET sql_err       = 0;
    LET isam_err      = 0;
    LET desc_err      = 0;
    LET nComit        = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcontador3    = 0;
    LET vsql          = '';
    LET vstmt         = '';
    LET vcuenta       = ''; 
    LET vmonto        = 0.00;
    LET vfolio        = '';
    LET vsdo_retenido = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloqmovsret.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloqmovsret.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movsxdesbloq') THEN
        DROP TABLE "informix".movsxdesbloq;
    END IF;
    
    CREATE RAW TABLE "informix".movsxdesbloq
      (
        cuenta char(20)    not null,
        monto  money(16,2) not null,
        folio  char(16)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_movxdesb ON "informix".movsxdesbloq(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/movs_desb_27012013.unl DELIMITER ''","'' INSERT INTO movsxdesbloq" > /resplogifx/conciliachq/movsxdesb.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movsxdesb.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE movsxdesbloq;
    
    FOREACH WITH HOLD
        SELECT cuenta, monto, folio
          INTO vcuenta, vmonto, vfolio
          FROM movsxdesbloq
                  
        BEGIN WORK;
        LET nComit = 1;
        
        SELECT sdo_retenido
          INTO vsdo_retenido
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        IF vmonto <= vsdo_retenido THEN
            UPDATE sc_maechq
               SET sdo_retenido = sdo_retenido - vmonto
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                LET vcontador1 = vcontador1 + 1;
            END IF;
        END IF;
        
        UPDATE sc_docret
           SET cancelado = 'S',
               monto = 0.00
         WHERE fecha_alta BETWEEN pfechaini AND pfechafin
           AND cuenta = vcuenta
           AND monto_ori = vmonto
           AND folio_suc = vfolio;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
           
        UPDATE sc_movhis
           SET cancelad = 'S'
         WHERE fech_alt BETWEEN pfechaini AND pfechafin
           AND cuenta = vcuenta
           AND monto_tot = vmonto
           AND folio_suc = vfolio;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador3 = vcontador3 + 1;
        END IF;
        
        COMMIT WORK;
        LET nComit = 0;
        
        LET vcuenta       = ''; 
        LET vmonto        = 0.00;
        LET vfolio        = '';
        LET vsdo_retenido = 0.00;
    END FOREACH
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3;
    
END PROCEDURE;