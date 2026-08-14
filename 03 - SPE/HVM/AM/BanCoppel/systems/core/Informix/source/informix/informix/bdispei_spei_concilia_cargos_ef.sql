CREATE PROCEDURE "informix".spei_concilia_cargos_ef( pEmpresa CHAR(3) )
RETURNING CHAR(5);

    DEFINE cCodRet1    CHAR(5);
    DEFINE cCodRet2    CHAR(5);
    DEFINE cCodRet3    CHAR(50);
    DEFINE iSqlErr     INTEGER;
    DEFINE iSamErr     INTEGER;
    DEFINE iDesErr     CHAR(50);
    DEFINE iTransacc   SMALLINT;
    DEFINE iExisteTbl  SMALLINT;
    DEFINE cSQL        CHAR(500);
    DEFINE dFechaHoy   DATE;
    DEFINE dFechaAnt   DATE;
    DEFINE cCveRastreo VARCHAR(40);
    DEFINE cCuentaOrd  VARCHAR(20);
    DEFINE dMonto      DECIMAL(19,2);
    DEFINE cCuentaChq  VARCHAR(20);    
    DEFINE iExisteTrx  SMALLINT;
    DEFINE i           INTEGER;
    DEFINE j           INTEGER;
    DEFINE iExisteFer  SMALLINT;
    DEFINE dFechaValor DATE;
    DEFINE dFechaCaptu DATE;
    DEFINE cTrxOpera   CHAR(4);
    
    LET cCodRet1    = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET iDesErr     = 0;
    LET iTransacc   = 0;
    LET iExisteTbl  = 0;
    LET cSQL        = '';
    LET dFechaHoy   = '';
    LET dFechaAnt   = '';
    LET cCveRastreo = '';
    LET cCuentaOrd  = '';
    LET dMonto      = 0.00;
    LET cCuentaChq  = '';
    LET iExisteTrx  = 0;
    LET i           = 0;
    LET j           = 0;
    LET iExisteFer  = 0;
    LET dFechaValor = '';
    LET dFechaCaptu = '';
    LET cTrxOpera   = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_concilia_cargos_ef.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_concilia_cargos_ef.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // CARGA REGISTROS POR VALIDAR
    SELECT COUNT(*) 
      INTO iExisteTbl
      FROM sysmaster:systabnames 
     WHERE partnum > 0 
       AND tabname = 'cargos_spei';
    
    IF iExisteTbl > 0 THEN
        DROP TABLE "informix".cargos_spei;
    END IF;
    
    CREATE TABLE "informix".cargos_spei
      ( 
        clave_rastreo VARCHAR(40)
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cargos_spei ON "informix".cargos_spei(clave_rastreo) ONLINE;
      
    LET cSQL = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_pago_spei.txt INSERT INTO cargos_spei;" > /resplogifx/conciliachq/cargos_spei.sql';
    SYSTEM cSQL;
    
    LET cSQL = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/cargos_spei.sql';
    SYSTEM cSQL;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cargos_spei;
    
    -- // CALCULA FECHAS OPERATIVAS DEL SPEI
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    LET i = 1;
    LET j = 1;
    
    WHILE i <= j
        LET dFechaAnt = dFechaHoy - j;

        IF (WEEKDAY(dFechaAnt) >= 1 AND WEEKDAY(dFechaAnt) <= 5) THEN
            SELECT COUNT(*) 
              INTO iExisteFer
              FROM bdinteg:si_feriado 
             WHERE empresa = pEmpresa 
               AND fecha = dFechaAnt;
               
            IF iExisteFer = 0 THEN
                EXIT WHILE;
            END IF;
        END IF;
        
        LET j = j + 1;
    END WHILE;
    
    -- // PROCESA REGISTROS
    FOREACH WITH HOLD
        SELECT vchrclaverastreo, vchrcuentaord, mnyimporte, dtfechavalor, dtfechacaptura, chrtxop
          INTO cCveRastreo, cCuentaOrd, dMonto, dFechaValor, dFechaCaptu, cTrxOpera
          FROM tblpago
         WHERE chrestatusenvio = 'E'
           AND vchrclaverastreo NOT IN(SELECT clave_rastreo FROM cargos_spei)
        
        BEGIN WORK;
        LET iTransacc = 1;
        
        IF LENGTH(cCuentaOrd) = 10 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_cuenta_telefono
             WHERE telefono = cCuentaOrd;
        ELIF LENGTH(cCuentaOrd) = 11 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_maechq
             WHERE cuenta = cCuentaOrd;
        ELIF LENGTH(cCuentaOrd) = 16 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_tarjeta
             WHERE num_tarjeta = cCuentaOrd;
        ELIF LENGTH(cCuentaOrd) = 18 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_maechq
             WHERE cuenta_clabe = cCuentaOrd;
        END IF;
        
        IF cCuentaChq is null OR cCuentaChq = '' THEN
            ROLLBACK WORK;
            LET iTransacc = 0;
            CONTINUE FOREACH;
        END IF;
        
        SELECT COUNT(*)
          INTO iExisteTrx
          FROM bdicheq:sc_movdia
         WHERE transacc IN('0274','0447')
           AND fech_val = dFechaHoy
           AND cancelad <> 'S'
           AND referencia = cCveRastreo
           AND cuenta = cCuentaChq
           AND monto_tot = dMonto;
           
        IF iExisteTrx = 0 THEN
            SELECT COUNT(*)
              INTO iExisteTrx
              FROM bdicheq:sc_movhis
             WHERE transacc IN('0274','0447')
               AND fech_val >= dFechaAnt
               AND cancelad <> 'S'
               AND referencia = cCveRastreo
               AND cuenta = cCuentaChq
               AND monto_tot = dMonto;
            
            IF iExisteTrx = 0 THEN
                ROLLBACK WORK;
                LET iTransacc = 0;
                CONTINUE FOREACH;
            END IF;
        END IF;
                
        SELECT COUNT(*)
          INTO iExisteTrx
          FROM bdicheq:sc_movdia
         WHERE transacc = '0276'
           AND fech_val = dFechaHoy
           AND cancelad <> 'S'
           AND referencia = cCveRastreo
           AND cuenta = cCuentaChq
           AND monto_tot = dMonto;
           
        IF iExisteTrx = 0 THEN
            SELECT COUNT(*)
              INTO iExisteTrx
              FROM bdicheq:sc_movhis
             WHERE transacc = '0276'
               AND fech_val >= dFechaAnt
               AND cancelad <> 'S'
               AND referencia = cCveRastreo
               AND cuenta = cCuentaChq
               AND monto_tot = dMonto;
            
            IF iExisteTrx = 0 THEN
                UPDATE tblpago
                   SET chrestatusenvio = 'N'
                 WHERE vchrclaverastreo = cCveRastreo;
                   
                IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                    INSERT INTO tblconciliacargos 
                    ( vchrclaverastreo, vchrcuentaord, mnyimporte, dtfechavalor, dtfechacaptura, chrtxop, chrcuentachq, dtfechaopera )
                    VALUES
                    ( cCveRastreo, cCuentaOrd, dMonto, dFechaValor, dFechaCaptu, cTrxOpera, cCuentaChq, current );
                    
                    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                        COMMIT WORK;
                        LET iTransacc = 0;
                    END IF;
                ELSE
                    ROLLBACK WORK;
                    LET iTransacc = 0;
                END IF;
            END IF;
        END IF;
        
        LET cCveRastreo = '';
        LET cCuentaOrd  = '';
        LET dMonto      = 0.00;
        LET cCuentaChq  = '';
        LET iExisteTrx  = 0;
        LET dFechaValor = '';
        LET dFechaCaptu = '';
        LET cTrxOpera   = '';
    END FOREACH;
    
    END;

    RETURN cCodRet1;

END PROCEDURE;