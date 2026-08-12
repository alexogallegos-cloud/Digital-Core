CREATE PROCEDURE "informix".sp_consulta_fecha()
RETURNING DATE;      --- FECHA
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    

    DEFINE vdFechaHoy   DATE;
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '';
    LET vcCodRet3    = '';
    
    LET vdFechaHoy   = '';
    
    --- SET DEBUG FILE TO "/tmp/sp_consulta_fecha.out";
    --- TRACE ON;
    
    BEGIN
	 ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vdFechaHoy;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
         
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM si_fechas
     WHERE empresa = '001';
    
    RETURN vdFechaHoy;

    END;

END PROCEDURE
;