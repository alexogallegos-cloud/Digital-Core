CREATE PROCEDURE "informix".sp_alertas_codi() 
RETURNING CHAR(5), CHAR(150); 
    
    DEFINE Sql_Err     INTEGER;
    DEFINE Isam_Err    INTEGER;
    DEFINE Desc_Err    CHAR(50);
    DEFINE cCodRet1    CHAR(5);
    DEFINE cCodRet2    CHAR(5);
    DEFINE cCodRet3    CHAR(50);
    DEFINE iContador1  INTEGER;
    DEFINE iContador2  INTEGER;
    DEFINE iContador3  INTEGER;
    DEFINE iComienza   SMALLINT;
    DEFINE cAbierto    CHAR(1);
    DEFINE iOperAbono  INTEGER;
    DEFINE iLimAbonos  INTEGER;
    DEFINE iOperCargo  INTEGER;
    DEFINE iLimCargos  INTEGER;
    DEFINE cMensaje    CHAR(150);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET cCodRet1    = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';  
    LET iContador1  = 0;
    LET iContador2  = 0;
    LET iContador3  = 0;
    LET iComienza   = -1;
    LET cAbierto    = '0';
    LET iOperAbono  = 0;
    LET iLimAbonos  = 115;
    LET iOperCargo  = 0;
    LET iLimCargos  = 450;
    LET cMensaje    = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertas_codi.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET cCodRet1 = Sql_Err;
            LET cCodRet2 = Isam_Err;
            LET cCodRet3 = Desc_Err;
            RETURN cCodRet1, cMensaje;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertas_codi.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA OPERACIONES CODI DE ABONO
    SELECT COUNT(*)
      INTO iOperAbono
      FROM sc_movdia
     WHERE transacc = '0446'
       AND fech_alt = today
       AND cancelad <> 'S';
       
    IF iOperAbono is null THEN
        LET iOperAbono = 0;
    END IF;
    
    -- // VALIDA OPERACIONES CODI DE CARGO
    SELECT COUNT(*)
      INTO iOperCargo
      FROM sc_movdia
     WHERE transacc = '0447'
       AND fech_alt = today
       AND cancelad <> 'S';
       
    IF iOperCargo is null THEN
        LET iOperCargo = 0;
    END IF;
    
    IF iOperAbono <= iLimAbonos AND iOperCargo <= iLimCargos THEN
        LET cCodRet1 = '000';
        LET cMensaje = '';
    ELIF iOperAbono > iLimAbonos AND iOperCargo <= iLimCargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'ABONOS CODI SE HA REBASADO, LIMITE: 115, ABONOS: '||iOperAbono||'.';
    ELIF iOperAbono <= iLimAbonos AND iOperCargo > iLimCargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'CARGOS CODI SE HA REBASADO, LIMITE: 450, CARGOS: '||iOperCargo||'.';
    ELIF iOperAbono > iLimAbonos AND iOperCargo > iLimCargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'ABONOS Y CARGOS CODI SE HA REBASADO, LIMITE ABONOS: 115, LIMITE CARGOS: 450, ABONOS: '||iOperAbono||' CARGOS: '||iOperCargo||'';
    END IF;
    
    END; 
    
    RETURN cCodRet1, cMensaje;
    
END PROCEDURE;