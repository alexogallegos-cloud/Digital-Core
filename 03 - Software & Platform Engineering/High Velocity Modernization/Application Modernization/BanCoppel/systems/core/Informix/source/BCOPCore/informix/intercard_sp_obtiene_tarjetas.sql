CREATE PROCEDURE "informix".sp_obtiene_tarjetas(pEmpresa CHAR(3))
RETURNING CHAR(5)  AS vCodRet1,
          CHAR(5)  AS vCodRet2,
          CHAR(50) AS vCodRet3,
          INTEGER  AS vContador,
          INTEGER  AS vContador2;
          
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vSqlErr      INTEGER;
    DEFINE vIsamErr     INTEGER;
    DEFINE vDescErr     CHAR(50);
    DEFINE vComienza    SMALLINT;
    DEFINE vCuantos     SMALLINT;
    DEFINE vContador    INTEGER;
    DEFINE vContador2   INTEGER;
    DEFINE vsql         CHAR(300);
    DEFINE vstmt        CHAR(200);
    
    DEFINE vTarjetaOrig      CHAR(16);
    DEFINE vStatusTarjeta    CHAR(3);
    DEFINE vProducto         CHAR(3);
    DEFINE vTarjetaSust      CHAR(16);
    DEFINE vTarjetaSustFinal CHAR(16);
    DEFINE vtarjxact         CHAR(16);
    
    LET vCodRet1   = '000';
    LET vCodRet2   = '000';
    LET vCodRet3   = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET vSqlErr    = 0;
    LET vIsamErr   = 0;
    LET vDescErr   = '';
    LET vComienza  = -1;
    LET vCuantos   = 0;
    LET vContador  = 0;
    LET vContador2 = 0;
    LET vsql       = '';
    LET vstmt      = '';
    
    LET vTarjetaOrig      = '';
    LET vStatusTarjeta    = '';
    LET vProducto         = '';
    LET vTarjetaSust      = '';
    LET vTarjetaSustFinal = '';
    LET vtarjxact         = '';
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_obtiene_tarjetas.err';
        TRACE ON;
        LET vTarjetaOrig = vTarjetaOrig;
        LET vTarjetaSust = vTarjetaSust;
        IF vSqlErr <> 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            LET vCodRet3 = vDescErr;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_obtiene_tarjetas.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tarjxact') THEN
        DROP TABLE "informix".tarjxact;
    END IF;
    
    CREATE RAW TABLE "informix".tarjxact
      (
        no_tarjeta char(16) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_tarjxact ON "informix".tarjxact(no_tarjeta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/tarjetas.unl DELIMITER ''","'' INSERT INTO tarjxact" > /resplogifx/conciliachq/tarj.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess intercard /resplogifx/conciliachq/tarj.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE tarjxact;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'rep_tarjetas') THEN
        DROP TABLE "informix".rep_tarjetas;
    END IF;
    
    CREATE RAW TABLE "informix".rep_tarjetas
      (
        tarjeta    char(16) not null,
        tarjsust   char(16),
        status     char(3)  not null,
        producto   char(3)  not null,
        notarjsust smallint not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_reptarj1 ON "informix".rep_tarjetas(tarjeta) USING BTREE;
    CREATE INDEX "informix".idx_reptarj2 ON "informix".rep_tarjetas(status) USING BTREE;
    
    FOREACH
        SELECT no_tarjeta
          INTO vTarjetaOrig
          FROM tarjxact
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;
        
        SELECT codstatustarjeta, codproductotarjeta, numtarjetasustituta
          INTO vStatusTarjeta, vProducto, vTarjetaSust
          FROM intercard:"informix".tarjeta
         WHERE numtarjeta = vTarjetaOrig;
         
        LET vCuantos = 0;
        LET vTarjetaSustFinal = vTarjetaOrig;
        
        WHILE (vStatusTarjeta <> 'ACT' AND (vTarjetaSust is not null OR vTarjetaSust <> ''))
            LET vTarjetaSustFinal = vTarjetaSust;
        
            SELECT codstatustarjeta, codproductotarjeta, numtarjetasustituta
              INTO vStatusTarjeta, vProducto, vTarjetaSust
              FROM intercard:"informix".tarjeta
             WHERE numtarjeta = vTarjetaSust;
             
            LET vCuantos = vCuantos + 1;
        END WHILE;
        
        INSERT INTO rep_tarjetas VALUES(vTarjetaOrig, vTarjetaSustFinal, vStatusTarjeta, vProducto, vCuantos);
         
        LET vContador = vContador + 1;
        
        LET vTarjetaOrig      = '';
        LET vStatusTarjeta    = '';
        LET vProducto         = '';
        LET vTarjetaSust      = '';
        LET vTarjetaSustFinal = '';
    END FOREACH;
    
    -- // GENERA REPORTE DE TARJETAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/reptarjetas_antes.txt '||
               'SELECT * FROM rep_tarjetas" > /resplogifx/conciliachq/reptarj.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess intercard /resplogifx/conciliachq/reptarj.sql"; 
    SYSTEM vstmt;
    
    LET vComienza = -1;
    
    FOREACH
        SELECT tarjsust
          INTO vtarjxact
          FROM rep_tarjetas
         WHERE status IN('ACT','BLT')
         
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;
        
        UPDATE intercard:"informix".tarjeta
           SET codproductotarjeta = '506'
         WHERE numtarjeta = vtarjxact;
         
        LET vContador2 = vContador2 + 1;
        
        LET vtarjxact = '';
    END FOREACH;
    
    -- // GENERA REPORTE DE TARJETAS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/reptarjetas_despues.txt '||
               'SELECT numtarjeta, codstatustarjeta, codproductotarjeta FROM tarjeta WHERE numtarjeta IN(SELECT tarjsust FROM rep_tarjetas)" > /resplogifx/conciliachq/reptarj.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess intercard /resplogifx/conciliachq/reptarj.sql"; 
    SYSTEM vstmt;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador, vContador2;
    
END PROCEDURE;