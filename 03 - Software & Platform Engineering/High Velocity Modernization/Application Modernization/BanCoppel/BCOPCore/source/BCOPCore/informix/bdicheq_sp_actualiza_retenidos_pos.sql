CREATE PROCEDURE "informix".sp_actualiza_retenidos_pos(pempresa CHAR(3))
RETURNING CHAR(5), INTEGER, INTEGER, INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(80);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(80);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE vcontador4       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vCuenta          CHAR(20);
    DEFINE vSdoRetMaeChq    MONEY(14,2);
    DEFINE vSdoRetDocRet    MONEY(14,2);

    LET vcodret1      = '000';
    LET vcodret2      = '';
    LET vcodret3      = '';
    LET sql_err       = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcontador3    = 0;
    LET vcontador4    = 0;
    LET ven_transacc  = 0;
    LET vCuenta       = '';
    LET vSdoRetMaeChq = 0.00;
    LET vSdoRetDocRet = 0.00;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_retenidos_pos.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcontador1, vcontador2, vcontador3, vcontador4;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_retenidos_pos.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT {+INDEX(sc_depinterpza idx_sc_depinterpza3)}
           cuenta 
      FROM sc_depinterpza 
     WHERE cuenta >= '10000005016'
       AND fecha >= ( SELECT MIN(fecha) FROM sc_depinterpza )
       AND liberado = '0' 
       AND monto_ret > 0.00
    INTO TEMP tmp_ctas_excluidas WITH NO LOG;
    
    INSERT INTO tmp_ctas_excluidas
    SELECT {+INDEX(sc_depositospei idx_depositospei_comp)}
           cuenta 
      FROM sc_depositospei 
     WHERE fecha_hoy >= ( SELECT MIN(fecha_hoy) FROM sc_depositospei )
       AND cuenta >= '10000005016'
       AND monto_ret > 0.00 
       AND liberado = '0';
       
    CREATE INDEX idxtmp_ctas_excluidas ON tmp_ctas_excluidas(cuenta) ONLINE;
    UPDATE STATISTICS HIGH FOR TABLE tmp_ctas_excluidas;    
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               cuenta, sdo_retenido
          INTO vCuenta, vSdoRetMaeChq
          FROM sc_maechq
         WHERE status_cta IN('1','3','4','5')
           AND sdo_retenido <> 0.00
           AND cuenta NOT IN( SELECT cuenta FROM tmp_ctas_excluidas )
           
        LET vcontador1 = vcontador1 + 1;
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        SELECT {+INDEX(sc_docret cuecan)}
               SUM(monto)
          INTO vSdoRetDocRet
          FROM sc_docret
         WHERE cuenta = vCuenta
           AND cancelado = 'P';
           
        IF vSdoRetDocRet > 0.00 THEN
            IF vSdoRetDocRet <> vSdoRetMaeChq THEN
                UPDATE sc_maechq
                   SET sdo_retenido = vSdoRetDocRet
                 WHERE cuenta = vCuenta;  
                 
                LET vcontador2 = vcontador2 + 1;
            END IF;
             
            LET vcontador3 = vcontador3 + 1;
        ELSE
            UPDATE sc_maechq
               SET sdo_retenido = 0.00
             WHERE cuenta = vCuenta;  
            
            LET vcontador4 = vcontador4 + 1;
        END IF;
        
        COMMIT WORK;
        LET ven_transacc = 0;

        LET vCuenta = '';
        LET vSdoRetMaeChq = 0.00;
        LET vSdoRetDocRet = 0.00;
    END FOREACH;
        
    END;
    
    RETURN vcodret1, vcontador1, vcontador2, vcontador3, vcontador4;
    
END PROCEDURE;