CREATE PROCEDURE "informix".sp_ipab_borratablas_temp() 
RETURNING CHAR(5);
    
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE cCodRet  CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET cCodRet  = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_borratablas_temp.out';
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_borratablas_temp.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // TABLA DE CLIENTES IPAB
    IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_clientes_ipab_temp') THEN
        DROP TABLE "informix".si_clientes_ipab_temp;
    END IF;
    
    create table "informix".si_clientes_ipab_temp 
      (
        numcte  char(20) 
      ) 
    fragment by round robin in datos00 , datos01 , datos02 
    extent size 256000 next size 32000 lock mode row;
    
    create index "informix".idxtmp_clientesipabcomp_cte ON "informix".si_clientes_ipab_temp(numcte) IN datos03 ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_clientes_ipab_temp;
    
    -- // TABLA DE CLIENTES IPAB
    IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_cliente_ipab_temp') THEN
        DROP TABLE "informix".si_cliente_ipab_temp;
    END IF;
    
    create table "informix".si_cliente_ipab_temp 
      (
        numcte  char(20) 
      ) 
    fragment by round robin in datos00 , datos01 , datos02 
    extent size 256000 next size 32000 lock mode row;
    
    create index "informix".idxtmp_clienteipabcomp_cte ON "informix".si_cliente_ipab_temp(numcte) IN datos03 ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_cliente_ipab_temp;
        
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;