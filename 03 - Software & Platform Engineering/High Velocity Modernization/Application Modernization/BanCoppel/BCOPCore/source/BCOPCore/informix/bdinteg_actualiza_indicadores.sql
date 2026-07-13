CREATE PROCEDURE "informix".actualiza_indicadores( pIndCierreChq CHAR(1), 
                                                   pIndDispChq   CHAR(1), 
                                                   pIndCierreCrd CHAR(1), 
                                                   pIndDispCrd   CHAR(1),
                                                   pIndCierreInv CHAR(1), 
                                                   pIndDispInv   CHAR(1),
                                                   pIndCierreSer CHAR(1), 
                                                   pMotivo       CHAR(50),
                                                   pUsuario      CHAR(8) )
RETURNING CHAR(5);  --- CODIGO DE RETORNO
       
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
    
    --- SET DEBUG FILE TO "/tmp/actualiza_indicadores.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/actualiza_indicadores.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pIndCierreChq is null OR pIndCierreChq = '' ) OR 
       ( pIndDispChq is null OR pIndDispChq = '' ) OR
       ( pIndCierreCrd is null OR pIndCierreCrd = '' ) OR
       ( pIndDispCrd is null OR pIndDispCrd = '' ) OR
       ( pIndCierreInv is null OR pIndCierreInv = '' ) OR
       ( pIndDispInv is null OR pIndDispInv = '' ) OR
       ( pIndCierreSer is null OR pIndCierreSer = '' ) OR
       ( pMotivo is null OR pMotivo = '' ) OR
       ( pUsuario is null OR pUsuario = '' ) THEN
        LET vcCodRet = '110';
        RETURN vcCodRet;
    END IF;
    
    -- // OBTIENE LOS INDICADORES
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreCheq, vcDisponCheq
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreCred, vcDisponCred
      FROM bdicred:sd_fechas
     WHERE empresa = '001';
       
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreInv, vcDisponInv
      FROM bdinvers:sv_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0')
      INTO vcCierreServ
      FROM bdisac:sac_fechas
     WHERE empresa = '001';
    
    -- // ACTUALIZA LOS INDICADORES
    UPDATE bdicheq:sc_fechas
       SET ind_cierre = pIndCierreChq,
           ind_disponible = pIndDispChq
     WHERE empresa = '001';
    
    UPDATE bdicred:sd_fechas
       SET ind_cierre = pIndCierreCrd,
           ind_disponible = pIndDispCrd
     WHERE empresa = '001';
     
    UPDATE bdinvers:sv_fechas
       SET ind_cierre = pIndCierreInv,
           ind_disponible = pIndDispInv
     WHERE empresa = '001';
     
    UPDATE bdisac:sac_fechas
       SET ind_cierre = pIndCierreSer
     WHERE empresa = '001';
     
    -- // GUARDA REGISTRO EN LA BITACORA
    INSERT INTO si_bitacora_cierre VALUES
    ( '001', vcCierreCheq, vcDisponCheq, pIndCierreChq, pIndDispChq,
      vcCierreCred, vcDisponCred, pIndCierreCrd, pIndDispCrd,
      vcCierreInv, vcDisponInv, pIndCierreInv, pIndDispInv,
      vcCierreServ, pIndCierreSer, CURRENT, pUsuario, pMotivo );
    
    RETURN vcCodRet;

    END;

END PROCEDURE;