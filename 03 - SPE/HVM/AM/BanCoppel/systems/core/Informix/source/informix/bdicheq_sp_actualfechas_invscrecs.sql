CREATE PROCEDURE "informix".sp_actualfechas_invscrecs( pempresa CHAR(3) )
RETURNING CHAR(5), INTEGER;

    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iContador1   INTEGER;
    DEFINE iEnTransacc  SMALLINT;
    DEFINE cProdInvCrec CHAR(4);
    DEFINE cCuenta      CHAR(20);
    DEFINE dFecha_alta  DATE;
    DEFINE dFechaVenc   DATE;
    DEFINE cDia         CHAR(2);
    DEFINE cTipoTasa    CHAR(1);
    DEFINE dFechaIni    DATE;
    DEFINE dFechaFin    DATE;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iContador1   = 0;
    LET iEnTransacc  = 0;
    LET cProdInvCrec = '';
    LET cCuenta      = '';
    LET dFecha_alta  = '';
    LET dFechaVenc   = '';
    LET cDia         = '';
    LET cTipoTasa    = '';
    LET dFechaIni    = '';
    LET dFechaFin    = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualfechas_invscrecs.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualfechas_invscrecs.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO cProdInvCrec
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'PRODCREC';
    
    SELECT noc.cuenta
      FROM sc_maenoc noc, 
           sc_maechq mae
     WHERE noc.cuenta = mae.cuenta
       AND noc.cuenta IN( SELECT cuenta FROM sc_valcierre_his WHERE fecha IN('12/07/2016','12/08/2016') )
       AND mae.status_cta = '1'
       AND mae.producto = cProdInvCrec
       AND LPAD(DAY(noc.fecha_alta),2,'0') <> LPAD(DAY(noc.fecha_mod),2,'0')
    INTO TEMP tmp_invs_incidencia WITH NO LOG;
    CREATE INDEX idxtmp_invsinc_cta ON tmp_invs_incidencia(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_invs_incidencia;
    
    FOREACH WITH HOLD
        SELECT tmp.cuenta, noc.fecha_alta, noc.fecha_mod
          INTO cCuenta, dFecha_alta, dFechaVenc
          FROM tmp_invs_incidencia tmp,
               sc_maenoc noc
         WHERE tmp.cuenta = noc.cuenta
           
        BEGIN WORK;
        LET iEnTransacc = 1;
         
        LET cDia = LPAD(DAY(dFecha_alta),2,'0');
         
        UPDATE sc_maenoc
           SET fecha_mod = LPAD(MONTH(dFechaVenc),2,'0')||'/'||cDia||'/'||YEAR(dFechaVenc)
         WHERE cuenta = cCuenta;
         
        FOREACH
            SELECT tipo_tasa, inicio_periodo, fin_periodo
              INTO cTipoTasa, dFechaIni, dFechaFin
              FROM sc_tasa_variable
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               
            UPDATE sc_tasa_variable
               SET inicio_periodo = LPAD(MONTH(dFechaIni),2,'0')||'/'||cDia||'/'||YEAR(dFechaIni),
                   fin_periodo = LPAD(MONTH(dFechaFin),2,'0')||'/'||cDia||'/'||YEAR(dFechaFin)
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND inicio_periodo = dFechaIni
               AND tipo_tasa = cTipoTasa;
               
            LET cTipoTasa = '';
            LET dFechaIni = '';
            LET dFechaFin = '';
        END FOREACH;
        
        LET iContador1 = iContador1 + 1;
        
        COMMIT WORK;
        LET iEnTransacc = 0;
        
        LET cCuenta     = '';
        LET dFecha_alta = '';
        LET dFechaVenc  = '';
        LET cDia        = '';
        LET cTipoTasa   = '';
        LET dFechaIni   = '';
        LET dFechaFin   = '';
    END FOREACH;
    
    END;

    RETURN cCodRet1, iContador1;

END PROCEDURE;