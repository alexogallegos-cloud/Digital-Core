CREATE PROCEDURE "informix".sp_ipab_obtienectes( pFechaIni DATE, pNumCliente CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE cCodRet  CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE cCteMin  CHAR(20);
    DEFINE cCteMax  CHAR(20);
    
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET cCodRet  = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET cCteMin  = '';
    LET cCteMax  = '';
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_obtienectes.out';
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_obtienectes.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF pNumCliente <> '999999999' THEN
    
        INSERT INTO si_clientes_ipab
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE cte.numcte = pNumCliente
           AND mae.num_cte = cte.numcte
           AND noc.cuenta = mae.cuenta
           AND mae.producto NOT IN('1100','9900','9901')
           AND noc.fecha_alta <= pFechaIni
           AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('1','3','4','5','6') OR mae.fec_cancelac > pFechaIni );
         
        INSERT INTO si_clientes_ipab
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae
         WHERE cte.numcte = pNumCliente
           AND mae.num_cte = cte.numcte
           AND mae.producto = '1100'
           AND mae.fecultdep <= pFechaIni
           AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('1','3','4','5','6') OR mae.fec_cancelac > pFechaIni );
           
           
        INSERT INTO si_clientes_ipab
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdinvers:sv_maeinv mae
         WHERE cte.numcte = pNumCliente
           AND mae.num_cte = cte.numcte
           AND mae.fecha_alta <= pFechaIni 
           AND mae.fecha_venc > pFechaIni
           AND ( mae.fec_cancelac > pFechaIni or mae.fec_cancelac is null );
           
        /*
        INSERT INTO si_clientes_ipab
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicred:sd_maecred crd
         WHERE cte.numcte = crd.numcte
           AND crd.status_cred IN('AA','BA','BT')
           AND crd.numcte = pNumCliente;
           
        INSERT INTO si_clientes_ipab
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicred:sd_maecredcrd crd
         WHERE cte.numcte = crd.numcte
           AND crd.status_cred IN('VP','AA','BA','BT')
           AND crd.numcte = pNumCliente;
        */
           
        UPDATE STATISTICS HIGH FOR TABLE si_clientes_ipab;
    
        SELECT MIN(numcte), MAX(numcte)
          INTO cCteMin, cCteMax
          FROM si_clientes_ipab;
        
        INSERT INTO si_cliente_ipab
        SELECT UNIQUE numcte
          FROM si_clientes_ipab
         WHERE numcte >= cCteMin 
           AND numcte <= cCteMax;
        
        UPDATE STATISTICS HIGH FOR TABLE si_cliente_ipab;
        
    ELSE
        
        INSERT INTO si_clientes_ipab_comp
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.num_cte = cte.numcte
           AND noc.cuenta = mae.cuenta
           AND mae.producto NOT IN('1100','9900','9901')
           AND noc.fecha_alta <= pFechaIni
           AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('1','3','4','5','6') OR mae.fec_cancelac > pFechaIni );
         
        INSERT INTO si_clientes_ipab_comp
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae
         WHERE mae.num_cte = cte.numcte
           AND mae.producto = '1100'
           AND mae.fecultdep <= pFechaIni
           AND ( mae.fecha_proceso >= pFechaIni OR mae.fecha_proceso IS NULL OR mae.status_cta IN('1','3','4','5','6') OR mae.fec_cancelac > pFechaIni );
           
        INSERT INTO si_clientes_ipab_comp
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdinvers:sv_maeinv mae
         WHERE mae.num_cte = cte.numcte
           AND mae.fecha_alta <= pFechaIni 
           AND mae.fecha_venc > pFechaIni
           AND ( mae.fec_cancelac > pFechaIni or mae.fec_cancelac is null );
           
        /*
        INSERT INTO si_clientes_ipab_comp
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicred:sd_maecred crd
         WHERE crd.numcte = cte.numcte
           AND crd.status_cred IN('AA','BA','BT');
           
        INSERT INTO si_clientes_ipab_comp
        SELECT cte.numcte
          FROM bdinteg:si_cliente cte,
               bdicred:sd_maecredcrd crd
         WHERE crd.numcte = cte.numcte
           AND crd.status_cred IN('VP','AA','BA','BT');
        */
           
        UPDATE STATISTICS HIGH FOR TABLE si_clientes_ipab_comp;
    
        SELECT MIN(numcte), MAX(numcte)
          INTO cCteMin, cCteMax
          FROM si_clientes_ipab_comp;
        
        INSERT INTO si_cliente_ipab_comp
        SELECT UNIQUE numcte
          FROM si_clientes_ipab_comp
         WHERE numcte >= cCteMin 
           AND numcte <= cCteMax;
        
        UPDATE STATISTICS HIGH FOR TABLE si_cliente_ipab_comp; 
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;