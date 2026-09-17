CREATE PROCEDURE "informix".sp_actmsje_edocta_cfd( pFechaIni DATE, pFechaFin DATE )
RETURNING CHAR(5), INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER;
      
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vComienza            INTEGER;
    DEFINE vEnTransacc          SMALLINT;
    DEFINE vContComit           INTEGER;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vContador3           INTEGER;
    DEFINE vContador4           INTEGER;
    DEFINE vContador5           INTEGER;
    DEFINE vContador6           INTEGER;
    DEFINE vContador7           INTEGER;
    DEFINE vContador8           INTEGER;
    DEFINE vContador9           INTEGER;
    DEFINE vMsjCteEfec          CHAR(255);
    DEFINE vMsjInvCrec          CHAR(255);
    DEFINE vMsjNominaGC         CHAR(255);
    DEFINE vMsjBasicoGral       CHAR(255);
    DEFINE vMsjCteEfecNin       CHAR(255);
    DEFINE vMsjNomina           CHAR(255);
    DEFINE vMsjCteEfecPlus      CHAR(255);
    DEFINE vMsjCteEfecChq       CHAR(255);
    DEFINE vMsjCteEfecJov       CHAR(255);
    DEFINE vIdReg               INTEGER;
    DEFINE vCuenta              CHAR(20);
    DEFINE vFecha               DATE;
    DEFINE vTpoCta              CHAR(2);
    
    LET Sql_Err	        = 0;
    LET Isam_Err        = 0;
    LET Desc_Err        = '';
    LET vCodRet1        = '000';
    LET vCodRet2        = '';
    LET vCodRet3        = '';
    LET vComienza       = -1;
    LET vEnTransacc     = 0;
    LET vContComit      = 0;
    LET vContador1      = 0;
    LET vContador2      = 0;
    LET vContador3      = 0;
    LET vContador4      = 0;
    LET vContador5      = 0;
    LET vContador6      = 0;
    LET vContador7      = 0;
    LET vContador8      = 0;
    LET vContador9      = 0;
    LET vMsjCteEfec     = '';
    LET vMsjInvCrec     = '';
    LET vMsjNominaGC    = '';
    LET vMsjBasicoGral  = '';
    LET vMsjCteEfecNin  = '';
    LET vMsjNomina      = '';
    LET vMsjCteEfecPlus = '';
    LET vMsjCteEfecChq  = '';
    LET vMsjCteEfecJov  = '';
    LET vIdReg          = 0;
    LET vCuenta         = '';
    LET vFecha          = '';
    LET vTpoCta         = '';
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actmsje_edocta_cfd.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vContador1, vContador2, vContador3, vContador4, vContador5, vContador6, vContador7, vContador8, vContador9;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actmsje_edocta_cfd.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT mensaje
      INTO vMsjCteEfec
      FROM sc_mensajes_producto
     WHERE producto = '2000';
     
    SELECT mensaje
      INTO vMsjInvCrec
      FROM sc_mensajes_producto
     WHERE producto = '1100';
     
    SELECT mensaje
      INTO vMsjNominaGC
      FROM sc_mensajes_producto
     WHERE producto = '1300';
     
    SELECT mensaje
      INTO vMsjBasicoGral
      FROM sc_mensajes_producto
     WHERE producto = '1400';
     
    SELECT mensaje
      INTO vMsjCteEfecNin
      FROM sc_mensajes_producto
     WHERE producto = '1500';
     
    SELECT mensaje
      INTO vMsjNomina
      FROM sc_mensajes_producto
     WHERE producto = '1700';
     
    SELECT mensaje
      INTO vMsjCteEfecPlus
      FROM sc_mensajes_producto
     WHERE producto = '1800';
     
    SELECT mensaje
      INTO vMsjCteEfecChq
      FROM sc_mensajes_producto
     WHERE producto = '1900';
     
    SELECT mensaje
      INTO vMsjCteEfecJov
      FROM sc_mensajes_producto
     WHERE producto = '2500';
      
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe)}
               idreg, num_cuenta, fecha_emision
          INTO vIdReg, vCuenta, vFecha
          FROM sc_piepagina_edocta_factelect
         WHERE fecha_emision BETWEEN pFechaIni AND pFechaFin
           AND mensaje LIKE '%Ã%'
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vEnTransacc = 1;
        END IF;
        
        LET vTpoCta = SUBSTR(vCuenta, 1, 2);
        
        IF vTpoCta = '10' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjCteEfec
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador1 = vContador1 + 1;
               
        ELIF vTpoCta = '11' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjInvCrec
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador2 = vContador2 + 1;
               
        ELIF vTpoCta = '13' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjNominaGC
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador3 = vContador3 + 1;
               
        ELIF vTpoCta = '14' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjBasicoGral
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador4 = vContador4 + 1;
               
        ELIF vTpoCta = '15' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjCteEfecNin
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador5 = vContador5 + 1;
               
        ELIF vTpoCta = '17' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjNomina
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador6 = vContador6 + 1;
               
        ELIF vTpoCta = '18' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjCteEfecPlus
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador7 = vContador7 + 1;
               
        ELIF vTpoCta = '19' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjCteEfecChq
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador8 = vContador8 + 1;
               
        ELIF vTpoCta = '25' THEN
        
            UPDATE {+INDEX(sc_piepagina_edocta_factelect idx_piepagina_fe2)}
                   sc_piepagina_edocta_factelect
               SET mensaje = vMsjCteEfecJov
             WHERE fecha_emision = vFecha
               AND idreg = vIdReg;
               
            LET vContador9 = vContador9 + 1;
               
        END IF;
        
        LET vContComit = vContComit + 1;
        
        IF vContComit >= 7500 THEN
            LET vContComit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vIdReg  = 0;
        LET vCuenta = '';
        LET vFecha  = '';
        LET vTpoCta = '';
    END FOREACH;
    
    IF vEnTransacc = 1 THEN
        COMMIT WORK;
        LET vEnTransacc = 0;
    END IF;
    
    END;
    
    RETURN vCodRet1, vContador1, vContador2, vContador3, vContador4, vContador5, vContador6, vContador7, vContador8, vContador9;
    
END PROCEDURE;