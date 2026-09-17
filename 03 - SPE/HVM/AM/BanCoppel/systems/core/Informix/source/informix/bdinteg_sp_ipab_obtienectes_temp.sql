CREATE PROCEDURE "informix".sp_ipab_obtienectes_temp( pFechaIni DATE ) 
RETURNING CHAR(5);
    
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE cCteMin      CHAR(20);
    DEFINE cCteMax      CHAR(20);
    DEFINE cNumCte      CHAR(20);
    DEFINE iComienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador    INTEGER;
    
    LET iSqlErr   = 0;
    LET iSamErr   = 0;
    LET cDesErr   = '';
    LET cCodRet   = '000';
    LET cCodRet2  = '';
    LET cCodRet3  = '';
    LET cCteMin   = '';
    LET cCteMax   = '';
    LET iComienza = 0;
    LET iTransacc = 0;
    LET iContador = 0;
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_obtienectes_temp.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        IF iTransacc = 0 THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodRet;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_obtienectes_temp.out';
    --- TRACE ON;
    
    -- // CLIENTES CON CUENTAS DE CHEQUES
    LET iContador = 0;
    LET iComienza = -1;
    
    FOREACH WITH HOLD
        SELECT cte.numcte
          INTO cNumCte
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.num_cte = cte.numcte
           AND noc.cuenta = mae.cuenta
           AND mae.producto NOT IN('1100','9900','9901')
           AND noc.fecha_alta <= pFechaIni
           AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('1','3','4','5','6') OR mae.fec_cancelac > pFechaIni )
           
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
       
        INSERT INTO si_clientes_ipab_temp VALUES(cNumCte);
       
        LET iContador = iContador + 1;
       
        IF iContador >= 5000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    -- // CLIENTES CON INVERSIONES CRECIENTES
    LET iContador = 0;
    LET iComienza = -1;
    
    FOREACH WITH HOLD
        SELECT cte.numcte
          INTO cNumCte
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae
         WHERE mae.num_cte = cte.numcte
           AND mae.producto = '1100'
           AND mae.fecultdep <= pFechaIni
           AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('1','3','4','5','6') OR mae.fec_cancelac > pFechaIni )
           
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
       
        INSERT INTO si_clientes_ipab_temp VALUES(cNumCte);
       
        LET iContador = iContador + 1;
       
        IF iContador >= 5000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    -- // CLIENTES CON PAGARES
    LET iContador = 0;
    LET iComienza = -1;
    
    FOREACH WITH HOLD
        SELECT cte.numcte
          INTO cNumCte
          FROM bdinteg:si_cliente cte,
               bdinvers:sv_maeinv mae
         WHERE mae.num_cte = cte.numcte
           AND mae.fecha_alta <= pFechaIni 
           AND mae.fecha_venc > pFechaIni
           AND ( mae.fec_cancelac > pFechaIni or mae.fec_cancelac is null )
           
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
       
        INSERT INTO si_clientes_ipab_temp VALUES(cNumCte);
       
        LET iContador = iContador + 1;
       
        IF iContador >= 5000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    -- // CLIENTES DE CREDITOS VENCIDOS
    LET iContador = 0;
    LET iComienza = -1;
    
    FOREACH WITH HOLD
        SELECT cve_unica
          INTO cNumCte
          FROM bdinteg:si_crdasotit_temp
           
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
       
        INSERT INTO si_clientes_ipab_temp VALUES(cNumCte);
       
        LET iContador = iContador + 1;
       
        IF iContador >= 5000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE si_clientes_ipab_temp;
    
    -- // OBTIENE CLIENTES UNICOS
    SELECT MIN(numcte), MAX(numcte)
      INTO cCteMin, cCteMax
      FROM si_clientes_ipab_temp;
      
    LET iContador = 0;
    LET iComienza = -1;
      
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO cNumCte
          FROM si_clientes_ipab_temp
         WHERE numcte >= cCteMin 
           AND numcte <= cCteMax
           
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
       
        INSERT INTO si_cliente_ipab_temp VALUES(cNumCte);
       
        LET iContador = iContador + 1;
       
        IF iContador >= 5000 THEN
            LET iContador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCte = '';
    END FOREACH;
    
    IF iTransacc = 1 THEN
        COMMIT WORK;
        LET iTransacc = 0;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE si_cliente_ipab_temp; 
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;