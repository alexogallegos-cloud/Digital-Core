CREATE PROCEDURE "informix".sp_cierra_sesiones_bm() 
RETURNING CHAR(5) AS vCodRet1;
        
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
        
    DEFINE vnumcel              CHAR(15);
    DEFINE vsecmax              INTEGER;
    DEFINE vid_session          INTEGER;
    DEFINE vnumcte              CHAR(20);
    DEFINE vid_oper             CHAR(4);
            
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = '';
        
    LET vnumcel     = '';
    LET vsecmax     = 0;
    LET vid_session = 0;
    LET vnumcte     = '';
    LET vid_oper    = '';
        
    BEGIN
        
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cierra_sesiones_bm.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cierra_sesiones_bm.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH
        SELECT UNIQUE numcel
          INTO vnumcel
          FROM bdinteg:"informix".si_bm_bitacora
         WHERE DATE(fech_oper) = CURRENT::DATE
         
        SELECT MAX(secuencia)
          INTO vsecmax
          FROM bdinteg:"informix".si_bm_bitacora
         WHERE DATE(fech_oper) = CURRENT::DATE
           AND numcel = vnumcel;
           
        IF vsecmax is null OR vsecmax = 0 THEN
            CONTINUE FOREACH;
        END IF;
         
        FOREACH
            SELECT id_session, numcte, id_oper
              INTO vid_session, vnumcte, vid_oper
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND numcel = vnumcel
               AND secuencia = vsecmax
                    
            IF vid_oper <> '1001' THEN
                IF ( SELECT CURRENT HOUR TO SECOND - EXTEND(fech_oper, HOUR TO SECOND)
                       FROM bdinteg:"informix".si_bm_bitacora
                      WHERE DATE(fech_oper) = CURRENT::DATE
                        AND numcel = vnumcel
                        AND secuencia = vsecmax ) > '00:05:00' THEN
                      
                    LET vsecmax = vsecmax + 1;
                    
                    INSERT INTO bdinteg:"informix".si_bm_bitacora( id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol )
                    VALUES( vid_session, CURRENT, vnumcte, vsecmax, '1001', vnumcel, null, null );
                END IF;
            END IF;
            
            LET vid_session = 0;
            LET vnumcte     = '';
            LET vid_oper    = '';
        END FOREACH;
        
        LET vnumcel     = '';
        LET vsecmax     = 0;
    END FOREACH;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;