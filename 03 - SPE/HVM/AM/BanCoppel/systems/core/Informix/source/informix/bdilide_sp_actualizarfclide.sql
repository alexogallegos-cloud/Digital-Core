CREATE PROCEDURE "informix".sp_actualizarfclide( cNumCte CHAR(20), 
                                                 cRfcAnt CHAR(13),
                                                 cRfcActual CHAR(13), 
                                                 cAnioMes1 CHAR(6), 
                                                 cAnioMes2 CHAR(6) )
RETURNING CHAR(5) -- DATOS A REGRESAR --

    -- // DEFINICION DE VARIABLES --
    DEFINE iSql_Err INTEGER;
    DEFINE cCodRet CHAR(5);
    DEFINE cAnioConsat CHAR(4);
    DEFINE vexiste1 INTEGER;
    DEFINE vexiste2 INTEGER;
    DEFINE vexiste3 INTEGER;
    DEFINE vexiste4 INTEGER;
    DEFINE vexiste5 INTEGER;
    DEFINE vexiste6 INTEGER;
    DEFINE vexiste7 INTEGER;

    -- // INICIALIZACION DE VARIABLES--
    LET iSql_Err = 0;
    LET cCodRet = '000';
    LET cAnioConsat = '';
    LET vexiste1 = 0;
    LET vexiste2 = 0;
    LET vexiste3 = 0;
    LET vexiste4 = 0;
    LET vexiste5 = 0;
    LET vexiste6 = 0;
    LET vexiste7 = 0;

    BEGIN

    ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet;
        END IF;
    END  EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_actualizarfclide.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*)
      INTO vexiste1
      FROM bdilide:sl_movefec 
     WHERE num_cte = cNumCte 
       AND rfc = cRfcAnt 
       AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
       
    IF vexiste1 > 0 THEN
        UPDATE bdilide:sl_movefec
           SET rfc = cRfcActual
         WHERE num_cte = cNumCte
           AND rfc = cRfcAnt
           AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
    END IF;
    

    SELECT COUNT(*)
      INTO vexiste3
      FROM bdilide:sl_retlide 
     WHERE num_cte = cNumCte 
       AND rfc = cRfcAnt 
       AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
      
    IF vexiste3 > 0 THEN
        UPDATE bdilide:sl_retlide
           SET rfc = cRfcActual
         WHERE num_cte = cNumCte
           AND rfc = cRfcAnt
           AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
    END IF;

    SELECT COUNT(*)
      INTO vexiste4
      FROM bdilide:sl_detlide 
     WHERE num_cte = cNumCte 
       AND rfc = cRfcAnt 
       AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
       
    IF vexiste4 > 0 THEN
        UPDATE bdilide:sl_detlide
           SET rfc = cRfcActual
         WHERE num_cte = cNumCte
           AND rfc = cRfcAnt
           AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
    END IF;

    SELECT COUNT(*)
      INTO vexiste5
      FROM bdilide:sl_constancias 
     WHERE num_cte = cNumCte 
       AND rfc = cRfcAnt 
       AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
       
    IF vexiste5 > 0 THEN
        UPDATE bdilide:sl_constancias
           SET rfc = cRfcActual
         WHERE num_cte = cNumCte
           AND rfc = cRfcAnt
           AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;
    END IF;

    LET cAnioConsat = SUBSTR(cAnioMes1, 1, 4);

    SELECT COUNT(*)
      INTO vexiste6
      FROM bdilide:sl_consat 
     WHERE rfc = cRfcAnt 
       AND YEAR(fecha_sol) = cAnioConsat;
       
    IF vexiste6 > 0 THEN
        UPDATE bdilide:sl_consat
           SET rfc = cRfcActual
         WHERE rfc = cRfcAnt
           AND YEAR(fecha_sol) = cAnioConsat;
    END IF;

    SELECT COUNT(*)
      INTO vexiste7
      FROM bdilide:sl_exentos 
     WHERE num_cte = cNumCte 
       AND rfc = cRfcAnt;
       
    IF vexiste7 > 0 THEN
        UPDATE bdilide:sl_exentos
           SET rfc = cRfcActual
         WHERE num_cte = cNumCte
           AND rfc = cRfcAnt;
    END IF;

    RETURN cCodRet;

    END;
    
END PROCEDURE

