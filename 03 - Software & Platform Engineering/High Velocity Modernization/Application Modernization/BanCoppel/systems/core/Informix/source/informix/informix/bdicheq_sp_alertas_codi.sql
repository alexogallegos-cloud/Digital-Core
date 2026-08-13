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
    DEFINE vintabonos  INTEGER;
    DEFINE iOperCargo  INTEGER;
    DEFINE vintcargos  INTEGER;
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
    LET vintabonos  = 0;
    LET iOperCargo  = 0;
    LET vintcargos  = 0;
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
    
    -- // OBTIENE PARAMETROS DE UMBRALES
    SELECT vchrvalor::INT
      INTO vintabonos
      FROM bdispei:tblparametros
     WHERE vchrcveparametro = 'OPER_ABOSCODI_NUMERO';
     
    SELECT vchrvalor::INT
      INTO vintcargos
      FROM bdispei:tblparametros
     WHERE vchrcveparametro = 'OPER_CGOSCODI_NUMERO';
    
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
    
    IF iOperAbono < vintabonos AND iOperCargo < vintcargos THEN
        LET cCodRet1 = '000';
        LET cMensaje = '';
    ELIF iOperAbono >= vintabonos AND iOperCargo < vintcargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'NO. ABONOS CODI SE HA REBASADO, LIMITE: '||vintabonos||', ABONOS: '||iOperAbono||'.';
    ELIF iOperAbono < vintabonos AND iOperCargo >= vintcargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'NO. CARGOS CODI SE HA REBASADO, LIMITE: '||vintcargos||', CARGOS: '||iOperCargo||'.';
    ELIF iOperAbono >= vintabonos AND iOperCargo >= vintcargos THEN
        LET cCodRet1 = '111';
        LET cMensaje = 'ABONOS Y CARGOS CODI SE HA REBASADO, LIMITE ABONOS: '||vintabonos||', LIMITE CARGOS: '||vintcargos||', ABONOS: '||iOperAbono||' CARGOS: '||iOperCargo||' ';
    END IF;
    
    END; 
    
    RETURN cCodRet1, cMensaje;
    
END PROCEDURE;