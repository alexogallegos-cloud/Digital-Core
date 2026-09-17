CREATE PROCEDURE "informix".sp_obtieneinfide( pempresa char(3), pfechaini DATE, pfechafin DATE )
RETURNING CHAR(5), CHAR(5), CHAR(40);

    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(40);
    DEFINE vsqlerr              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(40);
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    DEFINE vaniomes             CHAR(6);
    DEFINE vfecha_movhis        CHAR(10);
    DEFINE vfecha_movhisold     CHAR(10);
    DEFINE vfecha_movhisold2    CHAR(10);
    
    DEFINE vnum_serial          INTEGER;
    DEFINE vnum_cta             CHAR(20);
    DEFINE vfecha_mov           DATE;
    DEFINE vimp_tot_dep         DECIMAL(18,2);
    DEFINE vtransacc            CHAR(4);
    DEFINE vtransacc_corresp    INTEGER;
    DEFINE vmonto_corresp       DECIMAL(18,2);
    DEFINE vtransacc_suc        INTEGER;
    DEFINE vmonto_suc           DECIMAL(18,2);
    
    DEFINE vnum_cte             CHAR(20);
    DEFINE vno_regs             INTEGER;
    DEFINE vmonto_dep           DECIMAL(18,2);
    DEFINE vmonto_excedente     DECIMAL(18,2);
    DEFINE vmonto_ide           DECIMAL(18,2);
    DEFINE vno_transacc         INTEGER;
    DEFINE vmonto_transacc      DECIMAL(18,2);
    DEFINE vmonto_acum_ide      DECIMAL(18,2);
    
    DEFINE vregs_suc_15         INTEGER;
    DEFINE vregs_suc_15a20      INTEGER;
    DEFINE vregs_suc_20a25      INTEGER;
    DEFINE vregs_suc_25a30      INTEGER;
    DEFINE vregs_suc_30         INTEGER;
    
    DEFINE vregs_corresp_15     INTEGER;
    DEFINE vregs_corresp_15a20  INTEGER;
    DEFINE vregs_corresp_20a25  INTEGER;
    DEFINE vregs_corresp_25a30  INTEGER;
    DEFINE vregs_corresp_30     INTEGER;
    
    DEFINE vmincte              CHAR(20);
    DEFINE vmaxcte              CHAR(20);
    
    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET vsqlerr      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
    LET vaniomes     = '';
    LET vfecha_movhis     = '';
    LET vfecha_movhisold  = '';
    LET vfecha_movhisold2 = '';
    
    LET vnum_serial = 0;
    LET vnum_cta = '';
    LET vfecha_mov = '';
    LET vimp_tot_dep = 0.00;
    LET vtransacc = '';
    LET vtransacc_corresp = 0;
    LET vmonto_corresp = 0.00;
    LET vtransacc_suc = 0;
    LET vmonto_suc = 0.00;
    
    LET vnum_cte = '';
    LET vno_regs = 0;
    LET vmonto_dep = 0.00;
    LET vmonto_excedente = 0.00;
    LET vmonto_ide = 0.00;
    LET vno_transacc = 0;
    LET vmonto_transacc = 0.00;
    LET vmonto_acum_ide = 0.00;
    
    LET vregs_suc_15    = 0;
    LET vregs_suc_15a20 = 0;
    LET vregs_suc_20a25 = 0;
    LET vregs_suc_25a30 = 0;
    LET vregs_suc_30    = 0;
    
    LET vregs_corresp_15    = 0;
    LET vregs_corresp_15a20 = 0;
    LET vregs_corresp_20a25 = 0;
    LET vregs_corresp_25a30 = 0;
    LET vregs_corresp_30    = 0;
    
    LET vmincte = '';
    LET vmaxcte = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtieneinfide.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtieneinfide.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vaniomes = TO_CHAR(pfechafin, '%Y%m');
    
    SELECT valor
      INTO vfecha_movhis
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfecha_movhisold
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor
      INTO vfecha_movhisold2
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechaIniMovhisOld2';
    
    -- // TABLA PARA MOVS DE VENTANILLA
    --- IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'depositos_ventanilla') THEN
    ---     DROP TABLE depositos_ventanilla;        
    --- END IF;
    
    CREATE TEMP TABLE depositos_ventanilla
        (
            no_movimientos      integer,
            monto_movimientos   money(18,2)
        ) WITH NO LOG 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_depvent ON depositos_ventanilla(no_movimientos) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_ventanilla;
    
    -- // TABLA PARA MOVS DE CORRESPONSALES
    --- IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'depositos_corresponsal') THEN
    ---     DROP TABLE depositos_corresponsal;        
    --- END IF;
        
    CREATE TEMP TABLE depositos_corresponsal
        (
            no_movimientos      integer,
            monto_movimientos   money(18,2)
        ) WITH NO LOG 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_depcorr ON depositos_corresponsal(no_movimientos) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_corresponsal;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sl_movefec i_101)}
               num_serial, num_cta, fecha_mov, imp_tot_dep
          INTO vnum_serial, vnum_cta, vfecha_mov, vimp_tot_dep
          FROM sl_movefec
         WHERE tipo_cta = 'D'
           AND fecha_mov BETWEEN pfechaini AND pfechafin
           AND aniomes = vaniomes
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        IF vfecha_mov < vfecha_movhisold2 THEN
            SELECT {+INDEX(bdicheq:sc_movhis_old3 movhis1_old3)}
                   transacc
              INTO vtransacc
              FROM bdicheq:sc_movhis_old3
             WHERE empresa = pempresa
               AND cuenta = vnum_cta
               AND fech_alt = vfecha_mov
               AND cancelad <> 'S'
               AND transacc <> '0000'
               AND monto_tot = vimp_tot_dep
               AND num_serial = vnum_serial;
        ELIF vfecha_mov >= vfecha_movhisold2 AND vfecha_mov < vfecha_movhisold THEN
            SELECT {+INDEX(bdicheq:sc_movhis_old2 movhis1_old2)}
                   transacc
              INTO vtransacc
              FROM bdicheq:sc_movhis_old2
             WHERE empresa = pempresa
               AND cuenta = vnum_cta
               AND fech_alt = vfecha_mov
               AND cancelad <> 'S'
               AND transacc <> '0000'
               AND monto_tot = vimp_tot_dep
               AND num_serial = vnum_serial;
        ELIF vfecha_mov >= vfecha_movhisold AND vfecha_mov < vfecha_movhis THEN
            SELECT {+INDEX(bdicheq:sc_movhis_old movhis1)}
                   transacc
              INTO vtransacc
              FROM bdicheq:sc_movhis_old
             WHERE empresa = pempresa
               AND cuenta = vnum_cta
               AND fech_alt = vfecha_mov
               AND cancelad <> 'S'
               AND transacc <> '0000'
               AND monto_tot = vimp_tot_dep
               AND num_serial = vnum_serial;
        ELIF vfecha_mov >= vfecha_movhis THEN
            SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                   transacc
              INTO vtransacc
              FROM bdicheq:sc_movhis
             WHERE empresa = pempresa
               AND cuenta = vnum_cta
               AND fech_alt = vfecha_mov
               AND cancelad <> 'S'
               AND transacc <> '0000'
               AND monto_tot = vimp_tot_dep
               AND num_serial = vnum_serial;
        END IF;
           
        IF vtransacc = '0282' THEN
            LET vtransacc_corresp = vtransacc_corresp + 1;
            LET vmonto_corresp = vmonto_corresp + vimp_tot_dep;
        ELSE
            LET vtransacc_suc = vtransacc_suc + 1;
            LET vmonto_suc = vmonto_suc + vimp_tot_dep;
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vnum_serial = 0;
        LET vnum_cta = '';
        LET vfecha_mov = '';
        LET vimp_tot_dep = 0.00;
        LET vtransacc = '';
    END FOREACH;
    
    INSERT INTO depositos_ventanilla(no_movimientos, monto_movimientos)
    VALUES(vtransacc_suc, vmonto_suc);
    
    INSERT INTO depositos_corresponsal(no_movimientos, monto_movimientos)
    VALUES(vtransacc_corresp, vmonto_corresp);
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    -- // TABLA PARA MOVIMIENTOS CON IDE
    --- IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'depositos_ide') THEN
    ---     DROP TABLE depositos_ide;        
    --- END IF;
    
    CREATE TEMP TABLE depositos_ide
        (
            no_movimientos      integer,
            monto_movimientos   money(18,2),
            monto_ide           money(18,2)
        ) WITH NO LOG 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_depide ON depositos_ide(no_movimientos) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_ide;
    
    LET vcomienza = -1;
    LET ven_transacc = 0;
    
    SELECT MIN(num_cte), MAX(num_cte)
      INTO vmincte, vmaxcte
      FROM sl_retlide;
    
    FOREACH WITH HOLD
        SELECT num_cte
          INTO vnum_cte
          FROM sl_retlide
         WHERE aniomes = vaniomes
           AND num_cte BETWEEN vmincte AND vmaxcte
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
         
        SELECT {+INDEX(sl_movefec i_101)}
               COUNT(*), SUM(imp_tot_dep)
          INTO vno_regs, vmonto_dep
          FROM sl_movefec
         WHERE tipo_cta = 'D'
           AND fecha_mov BETWEEN pfechaini AND pfechafin
           AND aniomes = vaniomes
           AND num_cte = vnum_cte;
           
        LET vmonto_excedente = vmonto_dep - 15000;
        
        IF vmonto_excedente > 0.00 THEN
            LET vmonto_ide = vmonto_excedente * 0.03;
            
            LET vno_transacc = vno_transacc + vno_regs;
            LET vmonto_transacc = vmonto_transacc + vmonto_dep;
            LET vmonto_acum_ide = vmonto_acum_ide + vmonto_ide;
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vnum_cte = '';
        LET vno_regs = 0;
        LET vmonto_dep = 0.00;
        LET vmonto_excedente = 0.00;
        LET vmonto_ide = 0.00;
    END FOREACH;
    
    INSERT INTO depositos_ide(no_movimientos, monto_movimientos, monto_ide)
    VALUES(vno_transacc, vmonto_transacc, vmonto_acum_ide);
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    -- // MOVIMIENTOS DE VENTANILLA CON IDE
    --- IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'depositos_ide_sucursal') THEN
    ---     DROP TABLE depositos_ide_sucursal;        
    --- END IF;
    
    CREATE TEMP TABLE depositos_ide_sucursal
        (
            menores15           integer,
            mayores15_menores20 integer,
            mayores20_menores25 integer,
            mayores25_menores30 integer,
            mayores30           integer
        ) WITH NO LOG 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_depidesuc ON depositos_ide_sucursal(menores15) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_ide_sucursal;
        
    -- // MOVIMIENTOS DE CORRESPONSAL CON IDE
    --- IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tmp_depositos_ide_corresponsal') THEN
    ---     DROP TABLE tmp_depositos_ide_corresponsal;        
    --- END IF;
    
    CREATE TEMP TABLE tmp_depositos_ide_corresponsal
        (
            menores15           integer,
            mayores15_menores20 integer,
            mayores20_menores25 integer,
            mayores25_menores30 integer,
            mayores30           integer
        ) WITH NO LOG 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_depidecorr ON tmp_depositos_ide_corresponsal(menores15) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_depositos_ide_corresponsal;
    
    LET vcomienza = -1;
    LET ven_transacc = 0;
    
    FOREACH WITH HOLD
        SELECT num_cte
          INTO vnum_cte
          FROM sl_retlide
         WHERE aniomes = vaniomes
           AND num_cte BETWEEN vmincte AND vmaxcte
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
         
        FOREACH
            SELECT {+INDEX(sl_movefec i_101)}
                   num_serial, num_cta, fecha_mov, imp_tot_dep
              INTO vnum_serial, vnum_cta, vfecha_mov, vimp_tot_dep
              FROM sl_movefec
             WHERE tipo_cta = 'D'
               AND fecha_mov BETWEEN pfechaini AND pfechafin
               AND aniomes = vaniomes
               AND num_cte = vnum_cte
               
            IF vfecha_mov < vfecha_movhisold2 THEN
                SELECT {+INDEX(bdicheq:sc_movhis_old3 movhis1_old3)}
                       transacc
                  INTO vtransacc
                  FROM bdicheq:sc_movhis_old3
                 WHERE empresa = pempresa
                   AND cuenta = vnum_cta
                   AND fech_alt = vfecha_mov
                   AND cancelad <> 'S'
                   AND transacc <> '0000'
                   AND monto_tot = vimp_tot_dep
                   AND num_serial = vnum_serial;
            ELIF vfecha_mov >= vfecha_movhisold2 AND vfecha_mov < vfecha_movhisold THEN
                SELECT {+INDEX(bdicheq:sc_movhis_old2 movhis1_old2)}
                       transacc
                  INTO vtransacc
                  FROM bdicheq:sc_movhis_old2
                 WHERE empresa = pempresa
                   AND cuenta = vnum_cta
                   AND fech_alt = vfecha_mov
                   AND cancelad <> 'S'
                   AND transacc <> '0000'
                   AND monto_tot = vimp_tot_dep
                   AND num_serial = vnum_serial;
            ELIF vfecha_mov >= vfecha_movhisold AND vfecha_mov < vfecha_movhis THEN
                SELECT {+INDEX(bdicheq:sc_movhis_old movhis1)}
                       transacc
                  INTO vtransacc
                  FROM bdicheq:sc_movhis_old
                 WHERE empresa = pempresa
                   AND cuenta = vnum_cta
                   AND fech_alt = vfecha_mov
                   AND cancelad <> 'S'
                   AND transacc <> '0000'
                   AND monto_tot = vimp_tot_dep
                   AND num_serial = vnum_serial;
            ELIF vfecha_mov >= vfecha_movhis THEN
                SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                       transacc
                  INTO vtransacc
                  FROM bdicheq:sc_movhis
                 WHERE empresa = pempresa
                   AND cuenta = vnum_cta
                   AND fech_alt = vfecha_mov
                   AND cancelad <> 'S'
                   AND transacc <> '0000'
                   AND monto_tot = vimp_tot_dep
                   AND num_serial = vnum_serial;
            END IF;
               
            IF vtransacc <> '0282' THEN
                IF vimp_tot_dep < 15000.00 THEN
                    LET vregs_suc_15 = vregs_suc_15 + 1;
                ELIF vimp_tot_dep >= 15000 AND vimp_tot_dep < 20000 THEN
                    LET vregs_suc_15a20 = vregs_suc_15a20 + 1;
                ELIF vimp_tot_dep >= 20000 AND vimp_tot_dep < 25000 THEN
                    LET vregs_suc_20a25 = vregs_suc_20a25 + 1;
                ELIF vimp_tot_dep >= 25000 AND vimp_tot_dep < 30000 THEN
                    LET vregs_suc_25a30 = vregs_suc_25a30 + 1;
                ELIF vimp_tot_dep >= 30000 THEN
                    LET vregs_suc_30 = vregs_suc_30 + 1;
                END IF;
            ELSE
                IF vimp_tot_dep < 15000.00 THEN
                    LET vregs_corresp_15 = vregs_corresp_15 + 1;
                ELIF vimp_tot_dep >= 15000 AND vimp_tot_dep < 20000 THEN
                    LET vregs_corresp_15a20 = vregs_corresp_15a20 + 1;
                ELIF vimp_tot_dep >= 20000 AND vimp_tot_dep < 25000 THEN
                    LET vregs_corresp_20a25 = vregs_corresp_20a25 + 1;
                ELIF vimp_tot_dep >= 25000 AND vimp_tot_dep < 30000 THEN
                    LET vregs_corresp_25a30 = vregs_corresp_25a30 + 1;
                ELIF vimp_tot_dep >= 30000 THEN
                    LET vregs_corresp_30 = vregs_corresp_30 + 1;
                END IF;
            END IF;
            
            LET vnum_serial = 0;
            LET vnum_cta = '';
            LET vfecha_mov = '';
            LET vimp_tot_dep = 0.00;
            LET vtransacc = '';
        END FOREACH;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vnum_cte = '';
    END FOREACH;
    
    INSERT INTO depositos_ide_sucursal(menores15, mayores15_menores20, mayores20_menores25, mayores25_menores30, mayores30)
    VALUES(vregs_suc_15, vregs_suc_15a20, vregs_suc_20a25, vregs_suc_25a30, vregs_suc_30);
    
    INSERT INTO tmp_depositos_ide_corresponsal(menores15, mayores15_menores20, mayores20_menores25, mayores25_menores30, mayores30)
    VALUES(vregs_corresp_15, vregs_corresp_15a20, vregs_corresp_20a25, vregs_corresp_25a30, vregs_corresp_30);
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_ventanilla;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_corresponsal;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_ide;
    UPDATE STATISTICS MEDIUM FOR TABLE depositos_ide_sucursal;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_depositos_ide_corresponsal;
    
    LET vcodret3 = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;