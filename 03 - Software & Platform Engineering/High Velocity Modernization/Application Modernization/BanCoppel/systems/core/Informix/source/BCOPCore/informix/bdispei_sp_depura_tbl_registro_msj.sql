CREATE PROCEDURE "informix".sp_depura_tbl_registro_msj(pempresa CHAR(3))
RETURNING CHAR(5), INTEGER;

    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(80);
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE iComienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    
    DEFINE cNumCte      CHAR(20);
    DEFINE cTipoMsj     CHAR(1);
    DEFINE cStr1        CHAR(30);
    DEFINE cStr2        CHAR(30);
    DEFINE cStr3        CHAR(30);
    DEFINE cStr4        CHAR(30);
    DEFINE cStr5        CHAR(150);
    DEFINE dFecha1      DATETIME YEAR TO FRACTION(3);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET iContador1 = 0;
    LET iContador2 = 0;
    LET iComienza  = -1;
    LET iTransacc  = 0;
    
    LET cNumCte  = '';
    LET cTipoMsj = '';
    LET cStr1    = '';
    LET cStr2    = '';
    LET cStr3    = '';
    LET cStr4    = '';
    LET cStr5    = '';
    LET dFecha1  = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depura_tbl_registro_msj.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET cCodRet1 = sql_err;
            LET cCodRet2 = isam_err;
            LET cCodRet3 = desc_err;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depura_tbl_registro_msj.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(tbl_registro_msj idxtbl_registro_msj)}
               pnumclt, ptipomsj, pstr1, pstr2, pstr3, pstr4, pstr5, pfecha1
          INTO cNumCte, cTipoMsj, cStr1, cStr2, cStr3, cStr4, cStr5, dFecha1
          FROM tbl_registro_msj
         WHERE pnumclt >= '000001002'
           AND ptipomsj IN('1','2')
           AND pfecha1 = pfecha1
           AND pstatus = 'E'
           
        IF iComienza = -1 THEN
            LET iComienza =  0;
            BEGIN WORK;
            LET iTransacc = 1;
        END IF;
         
        INSERT INTO tbl_registro_msj_hist
        SELECT *
          FROM tbl_registro_msj
         WHERE pnumclt = cNumCte
           AND ptipomsj = cTipoMsj
           AND pfecha1 = dFecha1
           AND pstatus = 'E'
           AND pstr1 = cStr1
           AND pstr2 = cStr2
           AND pstr3 = cStr3
           AND pstr4 = cStr4
           AND pstr5 = cStr5;
           
        DELETE {+INDEX(tbl_registro_msj idxtbl_registro_msj)}
          FROM tbl_registro_msj
         WHERE pnumclt = cNumCte
           AND ptipomsj = cTipoMsj
           AND pfecha1 = dFecha1
           AND pstatus = 'E'
           AND pstr1 = cStr1
           AND pstr2 = cStr2
           AND pstr3 = cStr3
           AND pstr4 = cStr4
           AND pstr5 = cStr5;
        
        LET iContador1 = iContador1 + 1;
        LET iContador2 = iContador2 + 1;
        
        IF iContador2 >= 1000 THEN
            LET iContador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;            
        
        LET cNumCte  = '';
        LET cTipoMsj = '';
        LET cStr1    = '';
        LET cStr2    = '';
        LET cStr3    = '';
        LET cStr4    = '';
        LET cStr5    = '';
        LET dFecha1  = '';
    END FOREACH;
     
    IF iTransacc = 1 THEN
        LET iTransacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN cCodRet1, iContador1;
    
END PROCEDURE;