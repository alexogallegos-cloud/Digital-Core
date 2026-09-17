CREATE PROCEDURE "informix".verifica_sistemas()
RETURNING CHAR(5),  --- CODIGO DE RETORNO
          CHAR(1),  --- INDICADOR CIERRE CREDITO
          CHAR(1),  --- INDICADOR DISPONIBILIDAD CREDITO
          CHAR(1),  --- INDICADOR CIERRE CHEQUES
          CHAR(1),  --- INDICADOR DISPONIBILIDAD CHEQUES
          CHAR(1),  --- INDICADOR CIERRE INVERSIONES
          CHAR(1),  --- INDICADOR DISPONIBILIDAD INVERSIONES
          CHAR(1);  --- INDICADOR CIERRE SERVICIOS
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    
    DEFINE vcCierreCred CHAR(1);
    DEFINE vcDisponCred CHAR(1);
    DEFINE vcCierreCheq CHAR(1);
    DEFINE vcDisponCheq CHAR(1);
    DEFINE vcCierreInv  CHAR(1);
    DEFINE vcDisponInv  CHAR(1);
    DEFINE vcCierreServ CHAR(1);
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '';
    LET vcCodRet3    = '';
    
    LET vcCierreCred = '';
    LET vcDisponCred = '';
    LET vcCierreCheq = '';
    LET vcDisponCheq = '';
    LET vcCierreInv  = '';
    LET vcDisponInv  = '';
    LET vcCierreServ = '';
    
    --- SET DEBUG FILE TO "/tmp/verifica_sistemas.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/verifica_sistemas.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet, vcCierreCred, vcDisponCred, vcCierreCheq, vcDisponCheq, vcCierreInv, vcDisponInv, vcCierreServ;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreCred, vcDisponCred
      FROM bdicred:sd_fechas
     WHERE empresa = '001';
       
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreCheq, vcDisponCheq
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreInv, vcDisponInv
      FROM bdinvers:sv_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0')
      INTO vcCierreServ
      FROM bdisac:sac_fechas
     WHERE empresa = '001';
    
    RETURN vcCodRet, vcCierreCred, vcDisponCred, vcCierreCheq, vcDisponCheq, vcCierreInv, vcDisponInv, vcCierreServ;

    END;

END PROCEDURE;