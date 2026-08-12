CREATE PROCEDURE "informix".sp_modctastraspasadas( pempresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE vcodret1         char(5);
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE ven_transacc     smallint;
    DEFINE vcomienza        smallint;
    
    DEFINE vsql             char(600);
    DEFINE vstmt            char(300);
    DEFINE vfecha_hoy       date;
    DEFINE vfecha_ant       date;
    DEFINE vmes_actual      char(2);
    DEFINE vmes_siguiente   char(2);
    DEFINE vaniomes         char(6);
    DEFINE vaniomes2        char(6);
    DEFINE vanio            char(4);
    DEFINE vdia             char(2);
    DEFINE vdia2            char(2);
    DEFINE vmes             char(2);
    DEFINE vprodcrec        char(4);
    DEFINE vcuenta          char(20);
    DEFINE vsucursal        char(4);
    DEFINE vsdo_dia_ant     decimal(18,2);
    DEFINE vimp_chq_sbg     decimal(18,2);
    DEFINE vint_acum        decimal(18,2);
    DEFINE vacum_sdo_int    decimal(18,2);
    DEFINE vproducto        char(4);
    DEFINE vstatus_cta      char(1);
    DEFINE vfecha_proceso   date;
    DEFINE vfec_ult_mov     date;
    DEFINE vsdo_actual      decimal(18,2);
    DEFINE vnum_cte         char(20);
    DEFINE vejecutivo       char(8);
    
    LET vcodret1       = "000";               
    LET vcodret2       = '000';
    LET vcodret3       = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err        = 0;                   
    LET isam_err       = 0;
    LET desc_err       = '';
    LET vcontador1     = 0;                   
    LET vcontador2     = 0;
    LET ven_transacc   = 0;                   
    LET vcomienza      = -1;  
         
    LET vsql           = '';                  
    LET vstmt          = '';
    LET vfecha_hoy     = '';                  
    LET vfecha_ant     = '';                    
    LET vmes_actual    = 0;                   
    LET vmes_siguiente = 0;                 
    LET vaniomes       = '';   
    LET vaniomes2      = '';    
    LET vdia           = '';     
    LET vdia2          = '';     
    LET vmes           = '';                  
    LET vanio          = '';    
    LET vprodcrec      = '';    
    LET vcuenta        = '';    
    LET vsucursal      = '';    
    LET vsdo_dia_ant   = 0;              
    LET vimp_chq_sbg   = 0;              
    LET vint_acum      = 0;              
    LET vacum_sdo_int  = 0;              
    LET vproducto      = '';    
    LET vstatus_cta    = '';    
    LET vfecha_proceso = '';    
    LET vfec_ult_mov   = '';    
    LET vsdo_actual    = 0;              
    LET vnum_cte       = '';    
    LET vejecutivo     = '';    
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modctastraspasadas.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modctastraspasadas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vmes_actual    = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vmes_siguiente = LPAD(MONTH(vfecha_hoy), 2, '0');
    LET vaniomes       = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant), 2, '0');
    LET vdia           = DAY(vfecha_ant);
    LET vmes           = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vanio          = YEAR(vfecha_ant);
    LET vaniomes2      = YEAR(vfecha_ant - 1 UNITS DAY)||LPAD(MONTH(vfecha_ant - 1 UNITS DAY), 2, '0');
    LET vdia2          = DAY(vfecha_ant - 1 UNITS DAY);
     
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctastraspasadas') THEN
        DROP TABLE "informix".ctastraspasadas;
    END IF;
    
    CREATE RAW TABLE "informix".ctastraspasadas
      ( 
        cuenta char(20) not null 
      ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctatraspasada ON "informix".ctastraspasadas(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_traspasar_28112013.unl INSERT INTO ctastraspasadas" > /resplogifx/conciliachq/ctastrasp.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctastrasp.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctastraspasadas;
    
    SELECT valor
      INTO vprodcrec
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PRODCREC';
    
    FOREACH WITH HOLD
        SELECT cta.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int, chq.producto, 
               chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int, vproducto, 
               vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
          FROM ctastraspasadas cta,
               sc_maechq chq, 
               sc_maenoc noc
         WHERE cta.cuenta = chq.cuenta
           AND chq.producto != vprodcrec 
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta < vfecha_hoy
    
        BEGIN WORK;
        LET ven_transacc = 1;
           
        IF vimp_chq_sbg < 0 THEN
            LET vimp_chq_sbg = vimp_chq_sbg * -1;
        END IF
        
        LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
        
        -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
        CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2) 
        RETURNING vcodret1;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    FOREACH WITH HOLD
        SELECT cta.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
               chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
               vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo
          FROM ctastraspasadas cta,
               sc_maechq chq, 
               sc_maenoc noc
         WHERE cta.cuenta = chq.cuenta
           AND ( ( chq.producto = vprodcrec AND chq.status_cta != '2' AND chq.fecultdep < vfecha_hoy ) OR
                 ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) OR
                 ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso is null AND chq.fec_ult_mov >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) )
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        IF vimp_chq_sbg < 0 THEN
            LET vimp_chq_sbg = vimp_chq_sbg * -1;
        END IF
        
        LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
        
        IF ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso = vfecha_ant ) OR
           ( vproducto = vprodcrec AND vstatus_cta = '2' AND vfecha_proceso is null AND vfec_ult_mov = vfecha_ant ) THEN
            LET vsdo_dia_ant = vsdo_actual;
        END IF;
        
        -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
        CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2) 
        RETURNING vcodret1;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;