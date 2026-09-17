CREATE PROCEDURE "informix".sp_marcafecharetiro( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    
    DEFINE vcomienza        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    
    DEFINE vfechconmovhis           CHAR(10);
    DEFINE vfechconmovhisold        CHAR(10);
    DEFINE vfechconmovhisold2       CHAR(10);
    DEFINE vfechconmovhisold3       CHAR(10);
    DEFINE vctamin                  CHAR(20);
    DEFINE vctamax                  CHAR(20);
    DEFINE vcuenta                  CHAR(20);
    DEFINE vfecha_ultima_transacc   DATE;
    
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    
    LET vfechconmovhis         = '';
    LET vfechconmovhisold      = '';
    LET vfechconmovhisold2     = '';
    LET vfechconmovhisold3     = '';
    LET vctamin                = '';
    LET vctamax                = '';
    LET vcuenta                = '';                    
    LET vfecha_ultima_transacc = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcafecharetiro.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcafecharetiro.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor 
      INTO vfechconmovhisold2
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechaIniMovhisOld2';
       
    SELECT valor 
      INTO vfechconmovhisold3
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechaIniMovhisOld3';
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vctamin, vctamax
      FROM sc_maechq;    
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta BETWEEN vctamin AND vctamax
           AND status_cta <> '2'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET ven_transacc = 1;
        END IF;
        
        SELECT MAX(mov.fech_alt)
          INTO vfecha_ultima_transacc
          FROM sc_movdia mov,
               bdinteg:si_transacc trx
         WHERE mov.empresa = pempresa
           AND mov.cuenta = vcuenta
           AND mov.cancelad <> 'S'
           AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
           AND trx.numero = mov.transacc
           AND trx.naturaleza = 'C';
           
        IF vfecha_ultima_transacc is null THEN
        
            SELECT {+INDEX(sc_movhis idx_movhisnew4)}
                   MAX(mov.fech_alt)
              INTO vfecha_ultima_transacc
              FROM sc_movhis mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pempresa
               AND mov.cuenta = vcuenta
               AND mov.fech_alt >= vfechconmovhis
               AND mov.cancelad <> 'S'
               AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
               AND trx.numero = mov.transacc
               AND trx.naturaleza = 'C';
               
            IF vfecha_ultima_transacc is null THEN
            
                SELECT {+INDEX(sc_movhis_old movhis1)}
                       MAX(mov.fech_alt)
                  INTO vfecha_ultima_transacc
                  FROM sc_movhis_old mov,
                       bdinteg:si_transacc trx
                 WHERE mov.empresa = pempresa
                   AND mov.cuenta = vcuenta
                   AND mov.fech_alt >= vfechconmovhisold
                   AND mov.fech_alt < vfechconmovhis
                   AND mov.cancelad <> 'S'
                   AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                   AND trx.numero = mov.transacc
                   AND trx.naturaleza = 'C';
                   
                IF vfecha_ultima_transacc is null THEN
                
                    SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
                           MAX(mov.fech_alt)
                      INTO vfecha_ultima_transacc
                      FROM sc_movhis_old2 mov,
                           bdinteg:si_transacc trx
                     WHERE mov.empresa = pempresa
                       AND mov.cuenta = vcuenta
                       AND mov.fech_alt >= vfechconmovhisold2
                       AND mov.fech_alt < vfechconmovhisold
                       AND mov.cancelad <> 'S'
                       AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                       AND trx.numero = mov.transacc
                       AND trx.naturaleza = 'C';
                       
                    IF vfecha_ultima_transacc is null THEN
                
                        SELECT {+INDEX(sc_movhis_old3 movhis1_old3)}
                               MAX(mov.fech_alt)
                          INTO vfecha_ultima_transacc
                          FROM sc_movhis_old3 mov,
                               bdinteg:si_transacc trx
                         WHERE mov.empresa = pempresa
                           AND mov.cuenta = vcuenta
                           AND mov.fech_alt >= vfechconmovhisold3
                           AND mov.fech_alt < vfechconmovhisold2
                           AND mov.cancelad <> 'S'
                           AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                           AND trx.numero = mov.transacc
                           AND trx.naturaleza = 'C';
                           
                        IF vfecha_ultima_transacc is null THEN
                            
                            SELECT {+INDEX(sc_movhis_old4 movhis1_old4)}
                                   MAX(mov.fech_alt)
                              INTO vfecha_ultima_transacc
                              FROM sc_movhis_old4 mov,
                                   bdinteg:si_transacc trx
                             WHERE mov.empresa = pempresa
                               AND mov.cuenta = vcuenta
                               AND mov.fech_alt < vfechconmovhisold3
                               AND mov.cancelad <> 'S'
                               AND mov.transacc NOT IN('3381','3382','3276','3277','3353','3354','3280')
                               AND trx.numero = mov.transacc
                               AND trx.naturaleza = 'C';
                            
                        END IF;
             
                    END IF;
                    
                END IF;
                
            END IF;
            
        END IF;
        
        IF vfecha_ultima_transacc is not null OR vfecha_ultima_transacc <> '' THEN
            UPDATE sc_maechq
               SET fecultret = vfecha_ultima_transacc
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;

        IF vcontador2 >= 7500 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta = '';
        LET vfecha_ultima_transacc = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;