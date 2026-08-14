CREATE PROCEDURE "informix".sp_activacuentas( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cDescErr         CHAR(50);
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE cTransacAbierta  CHAR(1);
    DEFINE cSql             CHAR(500);
    DEFINE cStmt            CHAR(250);
    DEFINE dFechaHoy        DATE;
    DEFINE cCuenta          CHAR(20);
    
    LET cCodRet1        = '';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr	        = 0;
    LET iIsamErr        = 0;
    LET cDescErr        = '';
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET cTransacAbierta = '0';
    LET cSql            = '';
    LET cStmt           = '';
    LET dFechaHoy       = '';
    LET cCuenta         = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_activacuentas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF cTransacAbierta = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_activacuentas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxactivar') THEN
        DROP TABLE "informix".ctasxactivar;
    END IF;
    
    CREATE TABLE "informix".ctasxactivar
        ( 
            cuenta CHAR(20) NOT NULL 
        )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxactiv ON "informix".ctasxactivar(cuenta) ONLINE;
      
    LET cSql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxactivar.unl INSERT INTO ctasxactivar" > /resplogifx/conciliachq/ctasxact.sql';
    SYSTEM cSql;
    LET cSql = '';
    
    LET cStmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxact.sql';
    SYSTEM cStmt;
    LET cStmt = '';
    
    UPDATE STATISTICS HIGH FOR TABLE ctasxactivar;
    
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO cCuenta
          FROM ctasxactivar
        
        BEGIN WORK;
        LET cTransacAbierta = '1'; 
        LET iContador1 = iContador1 + 1;
        
        UPDATE sc_maechq
           SET status_cta = '1',
               fecha_proceso = dFechaHoy,
               num_cgos_mes = 0,
               imp_cgos_mes = 0.00,
               num_abonos_mes = 0,
               imp_abonos_mes = 0.00
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
           
        UPDATE sc_maenoc
           SET dia_sdo_pos = 0,
               acum_sdo_pos = 0.00,
               int_acum = 0.00,
               dias_acum_int = 0,
               acum_sdo_int = 0.00
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            COMMIT WORK;
            LET iContador2 = iContador2 + 1;
        ELSE 
            ROLLBACK WORK;
        END IF;
        
        LET cCuenta = '';
        LET cTransacAbierta = '0';
    END FOREACH;
    
    LET cCodRet1 = '000';
    LET cCodRet2 = '000';
    LET cCodRet3 = 'PROCESO FINALIZADO CORRECTAMENTE';
    
    END;

    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;

END PROCEDURE;