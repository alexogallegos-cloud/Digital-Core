CREATE PROCEDURE "informix".sp_valtraspasoarchivo( pNombreArchivo CHAR(30) )
RETURNING CHAR(5);
    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vRuta        CHAR(50);
    DEFINE cSQL         CHAR(300);
    DEFINE vContador    INTEGER;
    
    LET Sql_Err	  = 0;
    LET Isam_Err  = 0;
    LET Desc_Err  = '';
    LET vCodRet1  = '';
    LET vCodRet2  = '';
    LET vCodRet3  = '';
    LET vRuta     = '';
    LET cSQL      = '';
    LET vContador = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/riesgos/sp_valtraspasoarchivo.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/riesgos/sp_valtraspasoarchivo.trc";
    TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctesxanalizar') THEN
        DROP TABLE "informix".ctesxanalizar;
    END IF;  
    
    CREATE TABLE "informix".ctesxanalizar  
      ( 
        num_cte CHAR(20) NOT NULL
      )
    EXTENT SIZE 10000 NEXT SIZE 1000 LOCK MODE ROW;
    
    SELECT valor
      INTO vRuta
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'rutarchriesgos';
       
    LET cSQL = '';
    LET cSQL = 'echo "LOAD FROM '||TRIM(vRuta)||TRIM(pNombreArchivo)||' delimiter '','' INSERT INTO ctesxanalizar" > '||TRIM(vRuta)||'ctesanacap.sql';
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = '/ifxsif01/bin/dbaccess bdicheq '||TRIM(vRuta)||'ctesanacap.sql';
    SYSTEM cSQL;
    
    CREATE INDEX "informix".idx_ctexana ON "informix".ctesxanalizar(num_cte) USING BTREE; 
    UPDATE STATISTICS HIGH FOR TABLE ctesxanalizar;
    
    SELECT COUNT(*)
      INTO vContador
      FROM ctesxanalizar;
      
    IF vContador > 0 THEN
        LET vCodRet1 = '000';
    ELSE
        LET vCodRet1 = '111';
    END IF;
    
    /* ################################################################
    LET vComando = '';
    LET vComando = 'ls -l '||TRIM(vRuta)||TRIM(pNombreArchivo)||'';
    SYSTEM vComando;
    LET vComando = '';
    ################################################################ */
        
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;