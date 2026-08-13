CREATE PROCEDURE "informix".actualiza_ctasnoproc_comp( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), INTEGER;
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE vcTrxAbierta SMALLINT;
    DEFINE viContador   INTEGER;
    
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
    DEFINE vfecha_alta      date;
    DEFINE vfecha_nueva     date;
    DEFINE vcodretsdo       char(5);
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = '';
    LET vcTrxAbierta = 0;
    LET viContador   = 0;
    
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
    LET vfecha_alta    = '';
    LET vfecha_nueva   = '';
    LET vcodretsdo     = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/actualiza_ctasnoproc_comp.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/actualiza_ctasnoproc_comp.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF vcTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet, vcCodRet2, viContador;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    LET vmes_actual    = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vmes_siguiente = LPAD(MONTH(vfecha_hoy), 2, '0');
    LET vaniomes       = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant), 2, '0');
    LET vdia           = DAY(vfecha_ant);
    LET vmes           = LPAD(MONTH(vfecha_ant), 2, '0');
    LET vanio          = YEAR(vfecha_ant);
    LET vaniomes2      = YEAR(vfecha_ant - 1 UNITS DAY)||LPAD(MONTH(vfecha_ant - 1 UNITS DAY), 2, '0');
    LET vdia2          = DAY(vfecha_ant - 1 UNITS DAY);
    
    SELECT valor
      INTO vprodcrec
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'PRODCREC';
    
    -- // CUENTAS DE CHEQUES
    FOREACH WITH HOLD
        SELECT cta.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int, chq.producto, 
               chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo, noc.fecha_alta
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int, vproducto, 
               vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo, vfecha_alta
          FROM sc_valcierre cta,
               sc_maechq chq, 
               sc_maenoc noc
         WHERE cta.empresa = chq.empresa
           AND cta.cuenta = chq.cuenta
           AND chq.producto != vprodcrec 
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
           AND noc.fecha_alta < vfecha_hoy
           
        BEGIN WORK;
        LET vcTrxAbierta = 1;
        
        IF LPAD(MONTH(vfecha_alta),2,'0') = '02' THEN
            LET vfecha_nueva = vfecha_alta + 1 UNITS DAY;
        ELSE
            LET vfecha_nueva = LPAD(MONTH(vfecha_alta),2,'0') || '30' || YEAR(vfecha_alta);
        END IF;
           
        UPDATE sc_maenoc
           SET fecha_alta = vfecha_nueva
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta;
           
        IF vimp_chq_sbg < 0 THEN
            LET vimp_chq_sbg = vimp_chq_sbg * -1;
        END IF
        
        LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
        
        -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..        
        CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia, vaniomes2, vdia2) 
        RETURNING vcodretsdo;
           
        LET viContador = viContador + 1;
        
        COMMIT WORK;
        LET vcTrxAbierta = 0;
    END FOREACH;
    
    -- // INVERSIONES CRECIENTES
    FOREACH WITH HOLD
        SELECT cta.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.acum_sdo_int,
               chq.producto, chq.status_cta, chq.fecha_proceso, chq.fec_ult_mov, chq.sdo_actual, chq.num_cte, noc.ejecutivo, noc.fecha_alta
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vacum_sdo_int,
               vproducto, vstatus_cta, vfecha_proceso, vfec_ult_mov, vsdo_actual, vnum_cte, vejecutivo, vfecha_alta
          FROM sc_valcierre cta,
               sc_maechq chq, 
               sc_maenoc noc
         WHERE cta.cuenta = chq.cuenta
           AND ( ( chq.producto = vprodcrec AND chq.status_cta != '2' AND chq.fecultdep < vfecha_hoy ) OR
                 ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) OR
                 ( chq.producto = vprodcrec AND chq.status_cta  = '2' AND chq.fecha_proceso is null AND chq.fec_ult_mov >= vfecha_ant AND chq.fecultdep < vfecha_hoy ) )
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
        
        BEGIN WORK;
        LET vcTrxAbierta = 1;
        
        IF LPAD(MONTH(vfecha_alta),2,'0') = '02' THEN
            LET vfecha_nueva = vfecha_alta + 1 UNITS DAY;
        ELSE
            LET vfecha_nueva = LPAD(MONTH(vfecha_alta),2,'0') || '30' || YEAR(vfecha_alta);
        END IF;
           
        UPDATE sc_maenoc
           SET fecha_alta = vfecha_nueva
         WHERE empresa = pEmpresa
           AND cuenta = vcuenta;
        
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
        RETURNING vcodretsdo;
        
        LET viContador = viContador + 1;
        
        COMMIT WORK;
        LET vcTrxAbierta = 0;
    END FOREACH;
    
    RETURN vcCodRet, vcCodRet2, viContador;
    
    END;
    
END PROCEDURE;