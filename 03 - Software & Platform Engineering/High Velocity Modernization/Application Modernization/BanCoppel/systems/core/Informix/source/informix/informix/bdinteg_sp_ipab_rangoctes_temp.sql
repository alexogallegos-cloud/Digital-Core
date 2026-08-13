CREATE PROCEDURE "informix".sp_ipab_rangoctes_temp()
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
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ipab_rangoctes_temp.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ipab_rangoctes_temp.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT ROUND(COUNT(*)/20)
      INTO vpromedio
      FROM si_cliente_ipab_temp;
      
    LET vcont = 1;
    
    WHILE vcont <= 21 
        IF vcont = 1 THEN
            SELECT MIN(numcte)
              INTO cNumCte
              FROM si_cliente_ipab_temp;
              
            UPDATE si_param
               SET valor = cNumCte
             WHERE cod_param = 221;
        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
             
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 222;
            END FOREACH;
        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 2;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 223;
            END FOREACH;
        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 3;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 224;
            END FOREACH;
        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 4;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 225;
            END FOREACH;
        ELIF vcont = 6 THEN
            LET vbrinca = vpromedio * 5;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 226;
            END FOREACH;
        ELIF vcont = 7 THEN
            LET vbrinca = vpromedio * 6;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 227;
            END FOREACH;
        ELIF vcont = 8 THEN
            LET vbrinca = vpromedio * 7;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 228;
            END FOREACH;
        ELIF vcont = 9 THEN
            LET vbrinca = vpromedio * 8;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 229;
            END FOREACH;
        ELIF vcont = 10 THEN
            LET vbrinca = vpromedio * 9;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 230;
            END FOREACH;
        ELIF vcont = 11 THEN
            LET vbrinca = vpromedio * 10;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 231;
            END FOREACH;
        ELIF vcont = 12 THEN
            LET vbrinca = vpromedio * 11;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 232;
            END FOREACH;
        ELIF vcont = 13 THEN
            LET vbrinca = vpromedio * 12;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 233;
            END FOREACH;
        ELIF vcont = 14 THEN
            LET vbrinca = vpromedio * 13;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 234;
            END FOREACH;
        ELIF vcont = 15 THEN
            LET vbrinca = vpromedio * 14;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 235;
            END FOREACH;
        ELIF vcont = 16 THEN
            LET vbrinca = vpromedio * 15;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 236;
            END FOREACH;
        ELIF vcont = 17 THEN
            LET vbrinca = vpromedio * 16;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 237;
            END FOREACH;
        ELIF vcont = 18 THEN
            LET vbrinca = vpromedio * 17;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 238;
            END FOREACH;
        ELIF vcont = 19 THEN
            LET vbrinca = vpromedio * 18;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 239;
            END FOREACH;
        ELIF vcont = 20 THEN
            LET vbrinca = vpromedio * 19;
            FOREACH
                SELECT SKIP vbrinca FIRST 1 numcte
                  INTO cNumCte
                  FROM si_cliente_ipab_temp
                 ORDER BY numcte
                 
                UPDATE si_param
                   SET valor = cNumCte
                 WHERE cod_param = 240;
            END FOREACH;
        ELIF vcont = 21 THEN
            SELECT MAX(numcte)
              INTO cNumCte
              FROM si_cliente_ipab_temp;
              
            UPDATE si_param
               SET valor = cNumCte
             WHERE cod_param = 241;
        END IF;
        
        LET vcont = vcont + 1;  
        LET cNumCte = '';
    END WHILE;    

    END;
    
    RETURN cCodRet;

END PROCEDURE;