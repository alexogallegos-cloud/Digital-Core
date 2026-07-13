CREATE PROCEDURE "informix".actualiza_intereses( pEmpresa CHAR(3), pFecha DATE )
RETURNING CHAR(5), INTEGER;
    
    
    DEFINE vcodret1         char(5); 
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE vsqlerr          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcomienza        smallint;
    DEFINE ven_transacc     smallint;
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE vtranprovint     char(4);
    DEFINE vtrandesprovint  char(4);
    DEFINE vtranpagoint     char(4);
    DEFINE vdia             char(2);
    DEFINE vaniomes         char(6);
    DEFINE vcuenta          char(20);
    DEFINE vprovint         decimal(18,2);
    DEFINE vdesprov         decimal(18,2);
    DEFINE vpagoint         decimal(18,2);
    DEFINE vcodret4         char(5); 
    DEFINE vcap_ant         decimal(18,2);
    DEFINE vint_acum        decimal(18,2);
    DEFINE vfecha_con       date;
    
    LET vcodret1       = '000';               
    LET vcodret2       = '';
    LET vcodret3       = ''; 
    LET vsqlerr        = 0;                   
    LET isam_err       = 0;
    LET desc_err       = '';  
    LET vcomienza      = -1;                  
    LET ven_transacc   = 0; 
    LET vcontador1     = 0;                   
    LET vcontador2     = 0;
    LET vtranprovint   = '';
    LET vtrandesprovint = '';
    LET vtranpagoint   = '';
    LET vdia           = ''; 
    LET vaniomes       = '';
    LET vcuenta        = ''; 
    LET vprovint       = 0.00;
    LET vdesprov       = 0.00;              
    LET vpagoint       = 0.00;
    LET vcodret4       = '';
    LET vcap_ant       = 0.00; 
    LET vint_acum      = 0.00;   
    LET vfecha_con     = '';     
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/actualiza_intereses.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/actualiza_intereses.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vfecha_con = pFecha - 1 UNITS DAY;
    
    CALL sp_valfechabil(vfecha_con, '-')
    RETURNING vcodret1, vfecha_con;
    
    SELECT valor
      INTO vtranprovint
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'tranprov';
       
    SELECT valor
      INTO vtrandesprovint
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'tranrevprov';
       
    SELECT valor
      INTO vtranpagoint
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'tranpagint';
    
    LET vdia = DAY(pFecha);
    LET vaniomes = YEAR(pFecha)||LPAD(MONTH(pFecha), 2, '0');
    
    SELECT cuenta, fech_alt, transacc, monto_tot
      FROM sc_movhis
     WHERE fech_alt = pFecha
       AND cancelad <> 'S'
       AND transacc IN(vtranprovint, vtrandesprovint, vtranpagoint) 
    INTO TEMP tmp_movs_ints WITH NO LOG;
    CREATE INDEX idx_movs_ints ON tmp_movs_ints(cuenta, transacc) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs_ints;
    
    SELECT UNIQUE cuenta
      FROM tmp_movs_ints
    INTO TEMP tmp_ctas_movs_ints WITH NO LOG;
    CREATE INDEX idx_ctas_movs_ints ON tmp_ctas_movs_ints(cuenta) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_movs_ints;
    
    FOREACH WITH HOLD
        SELECT sdo.cuenta
          INTO vcuenta
          FROM sc_sdodiarioc sdo,
               tmp_ctas_movs_ints mov
         WHERE sdo.cuenta = mov.cuenta
           AND sdo.aniomes = vaniomes
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        CALL sp_capintafecha(vcuenta, vfecha_con)
        RETURNING vcodret4, vcap_ant, vint_acum;
        
        -- // PROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vprovint 
          FROM tmp_movs_ints
         WHERE cuenta = vcuenta
           AND transacc = vtranprovint;
         
        -- // DESPROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vdesprov
          FROM tmp_movs_ints
         WHERE cuenta = vcuenta
           AND transacc = vtrandesprovint;
         
        -- // PAGO DE INTERESES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vpagoint
          FROM tmp_movs_ints
         WHERE cuenta = vcuenta
           AND transacc = vtranpagoint;
           
        LET vprovint = vprovint - vdesprov;
        LET vint_acum = ((vint_acum + vprovint) - vpagoint);
        
        UPDATE sc_sdodiarioc 
           SET intprovnp1  =  DECODE(vdia,1,vint_acum,intprovnp1),
               intprovnp2  =  DECODE(vdia,2,vint_acum,intprovnp2),
               intprovnp3  =  DECODE(vdia,3,vint_acum,intprovnp3),
               intprovnp4  =  DECODE(vdia,4,vint_acum,intprovnp4),
               intprovnp5  =  DECODE(vdia,5,vint_acum,intprovnp5),
               intprovnp6  =  DECODE(vdia,6,vint_acum,intprovnp6),
               intprovnp7  =  DECODE(vdia,7,vint_acum,intprovnp7),
               intprovnp8  =  DECODE(vdia,8,vint_acum,intprovnp8),
               intprovnp9  =  DECODE(vdia,9,vint_acum,intprovnp9),
               intprovnp10 =  DECODE(vdia,10,vint_acum,intprovnp10),
               intprovnp11 =  DECODE(vdia,11,vint_acum,intprovnp11),
               intprovnp12 =  DECODE(vdia,12,vint_acum,intprovnp12),
               intprovnp13 =  DECODE(vdia,13,vint_acum,intprovnp13),
               intprovnp14 =  DECODE(vdia,14,vint_acum,intprovnp14),
               intprovnp15 =  DECODE(vdia,15,vint_acum,intprovnp15),
               intprovnp16 =  DECODE(vdia,16,vint_acum,intprovnp16),
               intprovnp17 =  DECODE(vdia,17,vint_acum,intprovnp17),
               intprovnp18 =  DECODE(vdia,18,vint_acum,intprovnp18),
               intprovnp19 =  DECODE(vdia,19,vint_acum,intprovnp19),
               intprovnp20 =  DECODE(vdia,20,vint_acum,intprovnp20),
               intprovnp21 =  DECODE(vdia,21,vint_acum,intprovnp21),
               intprovnp22 =  DECODE(vdia,22,vint_acum,intprovnp22),
               intprovnp23 =  DECODE(vdia,23,vint_acum,intprovnp23),
               intprovnp24 =  DECODE(vdia,24,vint_acum,intprovnp24),
               intprovnp25 =  DECODE(vdia,25,vint_acum,intprovnp25),
               intprovnp26 =  DECODE(vdia,26,vint_acum,intprovnp26),
               intprovnp27 =  DECODE(vdia,27,vint_acum,intprovnp27),
               intprovnp28 =  DECODE(vdia,28,vint_acum,intprovnp28),
               intprovnp29 =  DECODE(vdia,29,vint_acum,intprovnp29),
               intprovnp30 =  DECODE(vdia,30,vint_acum,intprovnp30),
               intprovnp31 =  DECODE(vdia,31,vint_acum,intprovnp31)
         WHERE cuenta = vcuenta
           AND aniomes = vaniomes;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;

        IF (vcontador2 >= 1000) THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta   = '';
        LET vcodret4  = '';
        LET vcap_ant  = 0.00;
        LET vint_acum = 0.00;
        LET vprovint  = 0.00;
        LET vdesprov  = 0.00;
        LET vpagoint  = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcontador1;

END PROCEDURE;