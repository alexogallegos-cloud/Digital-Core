CREATE PROCEDURE "informix".sp_ipab_rangoctes()
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE iDesErr      CHAR(50);
    DEFINE vpromedio    INTEGER;
    DEFINE vcont        SMALLINT;
    DEFINE vbrinca      INTEGER;
    DEFINE cNumCte      CHAR(20);
    
    LET cCodRet    = "000";
    LET cCodRet2   = "";
    LET cCodRet3   = "";
    LET iSqlErr    = 0;
    LET iSamErr    = 0;
    LET iDesErr    = '';  
    LET vpromedio  = 0;
    LET vcont      = 0;
    LET vbrinca    = 0;
    LET cNumCte    = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ipab_rangoctes.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ipab_rangoctes.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT ROUND(COUNT(*)/20)
      INTO vpromedio
      FROM si_cliente_ipab_comp;
      
    LET vcont = 1;
    
    WHILE vcont <= 21     
    
        IF vcont = 1 THEN
            SELECT MIN(numcte)
              INTO cNumCte
              FROM si_cliente_ipab_comp;
              
            UPDATE si_param
               SET valor = cNumCte
             WHERE cod_param = 200;
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
             
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 201;
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 202;
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 203;
            END FOREACH;
        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 204;
            END FOREACH;
        ELIF vcont = 6 THEN
            LET vbrinca = vpromedio * 5;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 205;
            END FOREACH;
        ELIF vcont = 7 THEN
            LET vbrinca = vpromedio * 6;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 206;
            END FOREACH;
        ELIF vcont = 8 THEN
            LET vbrinca = vpromedio * 7;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 207;
            END FOREACH;
        ELIF vcont = 9 THEN
            LET vbrinca = vpromedio * 8;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 208;
            END FOREACH;
        ELIF vcont = 10 THEN
            LET vbrinca = vpromedio * 9;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 209;
            END FOREACH;
        ELIF vcont = 11 THEN
            LET vbrinca = vpromedio * 10;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 210;
            END FOREACH;
        ELIF vcont = 12 THEN
            LET vbrinca = vpromedio * 11;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 211;
            END FOREACH;
        ELIF vcont = 13 THEN
            LET vbrinca = vpromedio * 12;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 212;
            END FOREACH;
        ELIF vcont = 14 THEN
            LET vbrinca = vpromedio * 13;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 213;
            END FOREACH;
        ELIF vcont = 15 THEN
            LET vbrinca = vpromedio * 14;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 214;
            END FOREACH;
        ELIF vcont = 16 THEN
            LET vbrinca = vpromedio * 15;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 215;
            END FOREACH;
        ELIF vcont = 17 THEN
            LET vbrinca = vpromedio * 16;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 216;
            END FOREACH;
        ELIF vcont = 18 THEN
            LET vbrinca = vpromedio * 17;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 217;
            END FOREACH;
        ELIF vcont = 19 THEN
            LET vbrinca = vpromedio * 18;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 218;
            END FOREACH;
        ELIF vcont = 20 THEN
            LET vbrinca = vpromedio * 19;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_comp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 219;
            END FOREACH;
        ELIF vcont = 21 THEN
            SELECT MAX(numcte)
              INTO cNumCte
              FROM si_cliente_ipab_comp;
              
            UPDATE si_param
               SET valor = cNumCte
             WHERE cod_param = 220;
        END IF;
        
        LET vcont = vcont + 1;  
        LET cNumCte = '';
    END WHILE;    

    END;
    
    RETURN cCodRet;

END PROCEDURE;