create procedure "informix".cierreinv(pempresa char(3))
returning char(5);
    
    -- *********************************************************************
    -- *   V 1.1   SE MODIFICO EL BORRADO DEL SV_MAEINSTRUCC,              *
    -- *           SE CAMBIO POR UPDATE, EN LA PARTE DE LA REINVERSION.    *
    -- *   V 1     VERSION INICIAL.                                        *
    -- *********************************************************************

    define global vgusuario         char(8)     default " ";
    define global vgprox_fecha      date        default " ";
    define global vgfecha_hoy       date        default " ";
    define global vgpri_hab_mes     date        default " ";
    define global vgpri_dia_mes     date        default " ";
    define global vgult_hab_mes     date        default " ";
    define global vgult_dia_mes     date        default " ";
    define global vgfecha_ant       date        default " ";
    
    define vcap_int                 char(1);
    define vexiste                  char(1);
    define vexiste2                 char(1);
    define vper_acred_int           char(1);
    define vprovision_int           char(1);
    define vstatus_cta              char(1);
    define vcobraisr                char(1);
    define vaplicado                char(1);
    define vgenera_producto         char(1);
    define vmoneda                  char(2);
    define vinst_vento              char(2);
    define vsistema                 char(2);
    define vinstcap                 char(2);
    define vinstint                 char(2);
    define vsistcap                 char(2);
    define vsistint                 char(2);
    define vnvainst                 char(2);
    define vsistnvo                 char(2);
    define vultdig                  char(2);
    define vsistemai                char(2);
    define vsistemac                char(2);
    define vdia                     char(2);
    define vmes                     char(2);
    define vinstruccion             char(2);
    define vplaza                   char(3);
    define vsucursal                char(4);
    define vtransacc                char(4);
    define vtrans_cap               char(4);
    define vtrans_int               char(4);
    define vtrans_isr               char(4);
    define vtrans_vtopas1           char(4);
    define vtrans_vtopas2           char(4);
    define vtrans_prov              char(4);
    define vtrans_proval            char(4);
    define vtrans_intval            char(4);
    define vtrans_isrval            char(4);
    define vtrans_reinv             char(4);
    define vtran_ret                char(4);
    define vcod_instrum             char(4);
    define vproductochq             char(4);
    define vano                     char(4);
    define vtrans_desprov           char(4);
    define vcodret                  char(5);
    define vcodret2                 char(5);
    define vpromotor                char(8);
    define vpaso                    CHAR(10);
    define vfoliosuc                char(16);
    define vhorax                   char(16);
    define vfolio_suc               char(16);
    define vcuenta                  char(20);
    define vnum_cte                 char(20);
    define vcta_cheques             char(20);
    define vctacap                  char(20);
    define vctaint                  char(20);
    define vctanva                  char(20);
    define vnro_cuenta              char(20);
    define vctaaboint               char(20);
    define vctaabocap               char(20);
    define vdescerr                 char(50);
    define vcodret3                 char(50);
    define vmensaje                 char(80);
    define vsecnva                  smallint;
    define vtotsuc                  smallint;
    define vcontproc                smallint;
    define vcontador                smallint;
    define vsecuencia               smallint;
    define vdias                    smallint;
    define vdiasmact                smallint;
    define vdiasmsig                smallint;
    define vnum_dias_int            smallint;
    define vplazo                   smallint;
    define vplazo_nva               smallint;
    define vdirecc_envio            smallint;
    define vexistee                 smallint;
    define vcomienza                smallint;
    define ven_transacc             smallint;
    define vsqlerr                  integer;
    define visamerr                 integer;
    define vsolbcos                 integer;
    define vanio                    integer;
    define vresiduo                 integer;
    define vaniobase                integer;
    define viDiasInact              integer;
    define vcapital                 money(14,2);
    define vprovision               money(14,2);
    define vinteres                 money(14,2);
    define vintereses               money(14,2);
    define vimporte                 money(14,2);
    define vmtovalint               money(14,2);
    define visr                     money(14,2);
    define vsdo_prom_mesant         money(14,2);
    define vtotal                   money(14,2);
    define vtotal_int               money(14,2);
    define vintnvo                  money(14,2);
    define vimptot                  money(14,2);
    define vimpisr                  money(14,2);
    define vintnet_nva              money(14,2);
    define visr_nvo                 money(14,2);
    define vprovmes                 money(14,2);
    define vsdo_cong                money(14,2);
    define vinteresneto             money(14,2);
    define vmonto_prov              money(14,2);
    define vmonto_provisionado      money(14,2);
    define vmonto_desprov           money(14,2);
    define vmonto_provision_his     money(14,2);
    define vmonto_provision_hoy     money(14,2);
    define vmonto_desprovision_his  money(14,2);
    define vmonto_desprovision_hoy  money(14,2);
    define vmonto_desprovisionado   money(14,2);
    define vprovision_total         money(14,2);
    define vtasa                    decimal(9,6);
    define vsobretasa               decimal(9,6);
    define vtasa_nva                decimal(9,6);
    define vtasaisr_nva             decimal(9,6);
    define vtasaneta_nva            decimal(9,6);
    define vtasa_isr                decimal(9,6);
    define visrreinv                decimal(14,2);
    define vtotalreinv              decimal(14,2);
    define vprovdia                 decimal(14,6);
    define vfechapli                date;
    define vfecha_nva               date;
    define vfecha_alta              date;
    define vfecha_venc              date;
    define vfecaboint               date;
    define vdFechaAlta              date;
    define vhora                    datetime hour to fraction(3);
    
    let vcap_int                 = '';
    let vexiste                  = '';
    let vexiste2                 = '';
    let vper_acred_int           = '';
    let vprovision_int           = '';
    let vstatus_cta              = '';
    let vcobraisr                = '';
    let vaplicado                = '';
    let vgenera_producto         = '';
    let vmoneda                  = '';
    let vinst_vento              = '';
    let vsistema                 = '';
    let vinstcap                 = '';
    let vinstint                 = '';
    let vsistcap                 = '';
    let vsistint                 = '';
    let vnvainst                 = '';
    let vsistnvo                 = '';
    let vultdig                  = '';
    let vsistemai                = '';
    let vsistemac                = '';
    let vdia                     = '';
    let vmes                     = '';
    let vinstruccion             = '';
    let vplaza                   = '';
    let vsucursal                = '';
    let vtransacc                = '';
    let vtrans_cap               = '';
    let vtrans_int               = '';
    let vtrans_isr               = '';
    let vtrans_vtopas1           = '';
    let vtrans_vtopas2           = '';
    let vtrans_prov              = '';
    let vtrans_proval            = '';
    let vtrans_intval            = '';
    let vtrans_isrval            = '';
    let vtrans_reinv             = '';
    let vtran_ret                = '';
    let vcod_instrum             = '';
    let vproductochq             = '';
    let vano                     = '';
    let vtrans_desprov           = '';
    let vcodret                  = '';
    let vcodret2                 = '';
    let vpromotor                = '';
    let vpaso                    = '';
    let vfoliosuc                = '';
    let vhorax                   = '';
    let vfolio_suc               = '';
    let vcuenta                  = '';
    let vnum_cte                 = '';
    let vcta_cheques             = '';
    let vctacap                  = '';
    let vctaint                  = '';
    let vctanva                  = '';
    let vnro_cuenta              = '';
    let vctaaboint               = '';
    let vctaabocap               = '';
    let vdescerr                 = '';
    let vcodret3                 = '';
    let vmensaje                 = '';
    let vsecnva                  = 0;
    let vtotsuc                  = 0;
    let vcontproc                = 0;
    let vcontador                = 0;
    let vsecuencia               = 0;
    let vdias                    = 0;
    let vdiasmact                = 0;
    let vdiasmsig                = 0;
    let vnum_dias_int            = 0;
    let vplazo                   = 0;
    let vplazo_nva               = 0;
    let vdirecc_envio            = 0;
    let vexistee                 = 0;
    let vcomienza                = 0;
    let ven_transacc             = 0;
    let vsqlerr                  = 0;
    let visamerr                 = 0;
    let vsolbcos                 = 0;
    let vanio                    = 0;
    let vresiduo                 = 0;
    let vaniobase                = 0;
    let viDiasInact              = 0;
    let vcapital                 = 0;
    let vprovision               = 0;
    let vinteres                 = 0;
    let vintereses               = 0;
    let vimporte                 = 0;
    let vmtovalint               = 0;
    let visr                     = 0;
    let vsdo_prom_mesant         = 0;
    let vtotal                   = 0;
    let vtotal_int               = 0;
    let vintnvo                  = 0;
    let vimptot                  = 0;
    let vimpisr                  = 0;
    let vintnet_nva              = 0;
    let visr_nvo                 = 0;
    let vprovmes                 = 0;
    let vsdo_cong                = 0;
    let vinteresneto             = 0;
    let vmonto_prov              = 0;
    let vmonto_provisionado      = 0;
    let vmonto_desprov           = 0;
    let vmonto_provision_his     = 0;
    let vmonto_provision_hoy     = 0;
    let vmonto_desprovision_his  = 0;
    let vmonto_desprovision_hoy  = 0;
    let vmonto_desprovisionado   = 0;
    let vprovision_total         = 0;
    let vtasa                    = 0;
    let vsobretasa               = 0;
    let vtasa_nva                = 0;
    let vtasaisr_nva             = 0;
    let vtasaneta_nva            = 0;
    let vtasa_isr                = 0;
    let visrreinv                = 0;
    let vtotalreinv              = 0;
    let vprovdia                 = 0;
    let vfechapli                = '';
    let vfecha_nva               = '';
    let vfecha_alta              = '';
    let vfecha_venc              = '';
    let vfecaboint               = '';
    let vdFechaAlta              = '';
    let vhora                    = '';
    
    begin 
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/cierreinv.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = vcodret
             WHERE empresa  = pEmpresa
               AND proceso  = 'CierreInv'
               AND fecha    = vgfecha_hoy;
            if ven_transacc = 1 then
                ROLLBACK WORK;
            end if;
            return vcodret;
        end if;
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/cierreinv.out";
    --- trace on;
    
    let vgusuario    = USER;
    let vcodret      = '000';
    let vaniobase    = 365;
    let vinstcap     = '';
    let vcomienza    = -1;
    let ven_transacc = 0;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes, fecha_ant
      into vgfecha_hoy, vgprox_fecha, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes, vgfecha_ant
      from sv_fechas
     where empresa = pempresa;
     
    UPDATE sv_fechas
       SET ind_cierre = '0'
     WHERE empresa = pempresa;
     
    -- // VALIDA SE HALLA EFECTUADO RESPALDO DE DATOS
    select vexiste
      into vexiste
      from sv_contproc
     where empresa = pempresa
       and proceso = "respacie"
       and fecha = vgfecha_hoy;
    
    if vexiste is null then
        let vcodret = "965";
        return vcodret;
    end if
    
    -- // VALIDA NO SE HALLA EFECTUADO EL CIERRE
    select 1
      into vexiste
      from sv_contproc
     where empresa = pempresa
       and proceso = "cierreinv"
       and fecha = vgfecha_hoy;
    
    IF vexiste = "1" THEN
        LET vcodret = "966";
        return vcodret;
    END IF
    
    select count(*) 
      into vexiste2
      from bdinteg:sx_contproc
     where empresa = pempresa
       and proceso = "CierreInv"
       and fecha = vgfecha_hoy;
    
    IF vexiste2 = 0 THEN
        INSERT INTO bdinteg:sx_contproc
        ( empresa, proceso, fecha, sistema, status_proc, ejecutivo, hora_ini, hora_fin, codret )
        VALUES
        ( pEmpresa, 'CierreInv', vgfecha_hoy, '03', 'I', USER, CURRENT, NULL, '000' );
    ELSE
        update bdinteg:sx_contproc 
           set status_proc = "I"
         where proceso = "CierreInv"
           and fecha = vgfecha_hoy
           and sistema = "03";
    END IF
    
    -- // CALCULA ISR
    let vanio = year(vgfecha_hoy);
    let vresiduo = mod(vanio, 4);
    
    if vresiduo = 0 then
        let vaniobase = 366;
    end if
    
    select valor
      into vtasa_isr
      from bdinteg:si_fechavalor
     where empresa = pempresa
       and tasa = "I.S.R."
       and fecha in ( select max(fecha)
                        from bdinteg:si_fechavalor
                       where empresa = pempresa
                         and tasa = "I.S.R." );
                         
    select valor
      into vtrans_desprov
      from bdinvers:sv_param
     where empresa = pempresa
       and codparam = 'tranrevprov';
    
    if vgfecha_hoy = vgult_hab_mes then
        let vdiasmact = vgult_dia_mes - vgfecha_hoy + 1;
        let vdiasmsig = vgprox_fecha - vgult_dia_mes - 1;
    else
        let vdiasmact = vgprox_fecha - vgfecha_hoy;
        let vdiasmsig = 0;
    end if
    
    let vdias = vdiasmact + vdiasmsig;
    
    -- // TRUNCA TABLA DE CODIGOS DE RETORNOS DEL CIERRE
    INSERT INTO sv_valcierre_his 
    SELECT vgfecha_ant, *
      FROM sv_valcierre;
      
    TRUNCATE TABLE sv_valcierre;
    
    -- // CANCELA INVERSIONES PROCESADAS UN DIA ANTERIOR (DEP A CHEQUES)
    foreach
        select mv.cuenta, mv.secuencia, inst_vento
          into vcuenta,vsecuencia, vinstruccion
          from sv_maeinv mv,
               sv_maeinstrucc mi
         where mv.status_cta = "1"
           and mi.cuenta = mv.cuenta
           and mi.empresa = mv.empresa
           and mi.cap_int = "C"
           and mi.importe = 0
           
        IF vinstruccion = "01" THEN -- Reinversion
            ------------------
        ELIF vinstruccion = "02" THEN -- Deposito a Cta.
            select count(*) 
              into vcontador
              from sv_maeinstrucc
             where empresa = pempresa
               and cuenta = vcuenta
               and importe <> 0;
            
            if vcontador is null or vcontador = 0 then
                update sv_maeinv 
                   set status_cta = '2',
                       fec_ult_mov = vgfecha_hoy,
                       fec_cancelac = vgfecha_hoy
                 where empresa = pempresa
                   and cuenta = vcuenta
                   and secuencia = vsecuencia;
            end if
        END IF
    end foreach
    
    -- // ELIMINA INVERSIONES APERTURADAS HOY SIN DEPOSITO INICIAL
    foreach
        select cuenta 
          into vcuenta
          from sv_maeinv
         where empresa = pempresa
           and fecha_alta = vgfecha_hoy
           and secuencia = 1
           and status_cta = '0'
           
        delete from sv_maeinv
         where empresa = pempresa
           and cuenta = vcuenta;
        
        delete from sv_maeinstrucc
         where empresa = pempresa
           and cuenta = vcuenta;
        
        delete from sv_benefic
         where parentesco <> '00'
           and cuenta = vcuenta;
        
        delete from sv_cotitular
         where cuenta = vcuenta;
    end foreach
    
    -- // CANCELA INVERSIONES SIN DEPOSITO A CHEQUES
    FOREACH
        SELECT cuenta, folio_suc
          INTO vcuenta, vfolio_suc
          FROM sv_movdia
         WHERE cancelad <> 'S'
           AND transacc = '0500'
           
        SELECT cta_cheques
          INTO vcta_cheques
          FROM sv_maeinv
         WHERE status_cta <> '2'
           AND cuenta = vcuenta;
        
        SELECT count(*)
          INTO vexistee
          FROM bdicheq:sc_movdia
         WHERE cancelad = 'S'
           AND transacc = '0235'
           AND cuenta = vcta_cheques
           AND folio_suc = vfolio_suc;
        
        IF vexistee > 0 THEN
            UPDATE sv_maeinv
               SET status_cta = '2',
                   fec_cancelac = vgfecha_hoy
             WHERE fecha_alta = vgfecha_hoy
               AND cuenta = vcuenta;

            UPDATE sv_movdia
               SET cancelad = 'S'
             WHERE fech_alt = vgfecha_hoy
               AND transacc  = '0500'
               AND folio_suc = vfolio_suc
               AND cuenta = vcuenta;

            UPDATE sv_movdia
               SET cancelad = 'S'
             WHERE fech_alt = vgfecha_hoy
               AND transacc  = '0514'
               AND folio_suc = vfolio_suc
               AND cuenta = vcuenta;
        END IF
    END FOREACH
    
    -- // FOREACH PRINCIPAL DEL CIERRE DE PAGARE
    FOREACH principal WITH HOLD FOR
        select mv.cuenta, mv.secuencia, mv.sucursal, mv.plaza, mv.capital, mv.sdo_ult_corte, mv.cod_instrum, mv.tasa, mv.sobretasa, mv.per_acred_int, mv.intereses, mv.isr,
               mv.fecha_alta, mv.fecha_venc, mv.plazo, mv.cobraisr, mv.cta_cheques, mv.sdo_prom_mesant, mv.num_cte, mv.promotor, mv.direcc_envio, mv.status_cta, mv.sdo_cong, 
               pr.trans_prov, pr.num_dias_int,  pr.provision_int, pr.trans_cap, pr.trans_int, pr.trans_isr, pr.moneda, 
               pr.trans_vtopas1, pr.trans_vtopas2, pr.trans_proval, pr.trans_intval, pr.trans_isrval, pr.trans_reinv  
          into vcuenta, vsecuencia, vsucursal, vplaza, vcapital, vprovmes, vcod_instrum, vtasa, vsobretasa, vper_acred_int, vintereses, visrreinv,
               vfecha_alta, vfecha_venc, vplazo, vcobraisr, vcta_cheques, vmtovalint, vnum_cte, vpromotor, vdirecc_envio, vstatus_cta, vsdo_cong, 
               vtrans_prov, vnum_dias_int, vprovision_int, vtrans_cap, vtrans_int, vtrans_isr, vmoneda, 
               vtrans_vtopas1, vtrans_vtopas2, vtrans_proval, vtrans_intval, vtrans_isrval, vtrans_reinv 
          from sv_maeinv mv,
               sv_instrum pr
         where mv.empresa = pr.empresa 
           and mv.status_cta in('1','3')
           and pr.cod_instrum = mv.cod_instrum
           and pr.gpo_instrum = 'CD'
           and ( mv.fecha_val is null OR mv.fecha_val = '' OR mv.fecha_val = ' ' OR mv.fecha_val = vgfecha_hoy )
         order by mv.cuenta
                
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF;
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        -- // CALCULA PROVISION E INTERES DIARIO
        if ( vfecha_venc > vgfecha_hoy ) then
            if vnum_dias_int > 0 then
                let vprovdia = vcapital * vtasa / 100 / vnum_dias_int;
            else
                let vprovdia = 0;
            end if
            
            let vhora = current hour to fraction(3);
            let vhorax = vhora;
            let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||vhorax[7,8]||vhorax[10,11];
            
            -- // CALCULA PROVISION MES ACTUAL
            let vprovision = vprovdia * vdiasmact;
            let vhora = current hour to fraction(3);
            
            if vprovision > 0 then
                if vprovision_int = "D" then
                    insert into sv_movdia values
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_prov, vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, vdiasmact, vprovision, vprovision, 0, 0, "", vcapital, "0000" );
                    
                    let vprovmes = 0;
                else
                    let vprovmes = vprovmes + vprovision;
                    
                    if vgfecha_hoy = vgult_hab_mes then
                        insert into sv_movdia values
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_prov, vsucursal,
                          vcuenta, vsecuencia, vcod_instrum, vdiasmact, vprovmes, vprovmes, 0, 0, "", vcapital, "0000" );
                        
                        let vprovmes = 0;
                    end if
                end if
            end if
            
            let vinteres = vprovision;
            
            -- // CALCULA PROVISION MES SIGUIENTE
            if vdiasmsig > 0 then
                let vprovision = vprovdia * vdiasmsig;
                let vhora = current hour to fraction(3);
                
                if vprovision > 0 then
                    if vprovision_int = "D" then
                        insert into sv_movdia values
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_prov, vsucursal,
                          vcuenta, vsecuencia, vcod_instrum, vdiasmsig, vprovision, vprovision, 0, 0, "", vcapital, "0000" );
                        let vprovmes = 0;
                    else
                        let vprovmes = vprovmes + vprovision;
                    end if
                end if
                
                let vinteres = vinteres + vprovision;
            end if
            
            -- // ACUMULA INTERESES
            update sv_maeinstrucc
               set importe  = importe + vinteres
             where empresa = pempresa
               and cuenta = vcuenta
               and cap_int = "I"
               and aplicado <> "S";
            
            update sv_maeinv
               set sdo_ult_corte = vprovmes,
                   sdo_mes_ant = sdo_mes_ant + vinteres
             where empresa = pempresa
               and cuenta = vcuenta
               and secuencia = vsecuencia;
        end if;
            
        -- // CIERRE MENSUAL
        if vgfecha_hoy = vgult_hab_mes then
            if ( vfecha_alta <= vgfecha_hoy and vfecha_venc != vgfecha_hoy and vper_acred_int <> "V" ) then
                let vhora = current hour to fraction(3);
                let vhorax = vhora;
                let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||vhorax[7,8]||vhorax[10,11];
                
                if ( vper_acred_int = "M" ) or
                   ( vper_acred_int = "A" and month(vgfecha_hoy) = 12 ) or
                   ( vper_acred_int = "S" and month(vgfecha_hoy) in(6,12) ) or
                   ( vper_acred_int = "T" and month(vgfecha_hoy) in(3,6,9,12) ) then
                    
                    select sistema, cta_cheques, trans_int, importe, producto, genera_producto
                      into vsistema, vnro_cuenta, vtran_ret, vprovision, vproductochq, vgenera_producto
                      from sv_maeinstrucc mi,
                           sv_instrucc ci
                     where mi.empresa = pempresa
                       and mi.cuenta = vcuenta
                       and mi.cap_int = "I"
                       and mi.aplicado <> "S"
                       and mi.sistema <> "03"
                       and ci.codigo = mi.inst_vento;
                    
                    if vcobraisr = "S" then
                        let vimpisr = vcapital * vtasa_isr / 100 / vaniobase * vplazo;
                    else
                        let vimpisr = 0;
                    end if
                    
                    if vsistema <> "03" then
                        let vinteresneto = vprovision + vmtovalint - vimpisr;
                        
                        if vinteresneto is null then
                            let vinteresneto = 0;
                        end if
                        
                        let vhora = current hour to fraction(3);
                        
                        -- // REGISTRA MOVIMIENTO DE CAPITALIZACION
                        if vprovision > 0 then
                            insert into sv_movdia values
                            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtrans_int, vsucursal,
                              vcuenta, vsecuencia, vcod_instrum, 0, vprovision, vprovision, 0, 0, "", vcapital, "0000" );
                        end if
                        
                        -- // REGISTRA MOVIMIENTO DE I.S.R.
                        if vimpisr > 0 then
                            let vhora = current hour to fraction(3);
                            
                            insert into sv_movdia values
                            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtrans_isr, vsucursal,
                              vcuenta, vsecuencia, vcod_instrum, 0, vimpisr, vimpisr, 0, 0, "", vcapital, "0000" );
                        end if
                        
                        -- // REGISTRA MANTENIMIENTO A VALOR
                        if vmtovalint > 0 then
                            let vhora = current hour to fraction(3);
                            
                            insert into sv_movdia values
                            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, "5002", vsucursal,
                              vcuenta, vsecuencia, vcod_instrum, 0, vmtovalint, vmtovalint, 0, 0, "", vcapital, "0000" );
                        end if
                        
                        if vinteresneto > 0 then
                            if vsistema <> "00" then
                                if vgenera_producto = "S" then
                                    select 1 
                                      into vexiste
                                      from bdicheq:sc_maechq
                                     where num_cte = vnum_cte
                                       and producto = vproductochq;
                                    
                                    if vexiste is null then
                                        call bdicheq:cuenta1(pempresa, vgusuario, vsucursal, vproductochq, vnum_cte, 0, "1", "1", "001", vgusuario, 0, "", "1", "", "", "", "", "", "", 0, "N")
                                        returning vcodret, vnro_cuenta;
                                    end if
                                end if
                                
                                -- // PROCESA TRASPASO A CHEQUES
                                insert into bdicheq:sc_movinver values
                                ( pempresa, "A", vsucursal, vnro_cuenta, vinteresneto, vmoneda, "N", vgfecha_hoy, "0207", vcuenta, vgusuario, "000", vgprox_fecha, "" );
                            else
                                call bdibanco:sbsp_graba_solchq(pempresa, vnum_cte, vgusuario, vinteresneto, vcuenta)
                                returning vcodret, vmensaje, vsolbcos;
                            end if
                                
                            update sv_maeinstrucc
                               set importe = 0
                             where empresa = pempresa
                               and cuenta = vcuenta
                               and cap_int = "I";
                                
                            let vhora = current hour to fraction(3);
                            
                            insert into sv_movdia values 
                            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtran_ret, vsucursal,
                              vcuenta, vsecuencia, vcod_instrum, 0, vinteresneto, vinteresneto, 0, 0, "", vcapital, "0000" );
                            
                            update sv_maeinv
                               set fec_ult_mov = vgfecha_hoy,
                                   sdo_prom_mesant = 0
                             where empresa = pempresa
                               and cuenta = vcuenta
                               and secuencia = vsecuencia;
                        end if
                    end if
                end if
            end if
        end if
        
        -- // PAGA INTERES ANIVERSARIO
        if ( vfecha_alta <= vgfecha_hoy and vfecha_venc != vgfecha_hoy and vper_acred_int = "N" ) then
            let vmes = month(vgprox_fecha);
            
            if vpromotor = "01999999" then
                let vdia = 15;
            else
                let vdia = day(vfecha_alta);
            end if
            
            let vano = year(vgprox_fecha);
            
            if vdia > day(vgult_dia_mes) then
                let vdia = "01";
                let vmes = vmes + 1;
            end if
            
            let vfecaboint = lpad(trim(vmes),2,"0")||"/"||lpad(trim(vdia),2,"0")||"/"||vano;
            
            if vfecaboint > vgfecha_hoy and vfecaboint <= vgprox_fecha then
                select sistema, cta_cheques, trans_int, importe
                  into vsistema, vnro_cuenta, vtran_ret, vprovision
                  from sv_maeinstrucc mi,
                       sv_instrucc ci
                 where mi.empresa = pempresa
                   and mi.cuenta = vcuenta
                   and mi.cap_int = "I"
                   and mi.aplicado <> "S"
                   and mi.sistema != "03"
                   and ci.codigo = mi.inst_vento;
                
                if vcobraisr = "S" then
                    let vimpisr = vcapital * vtasa_isr / 100 / vaniobase * vplazo;
                else
                    let vimpisr = 0;
                end if
                
                if vsistema <> "03" then
                    let vhora = current hour to fraction(3);
                    let vhorax = vhora;
                    let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||vhorax[7,8]||vhorax[10,11];
                    let vinteresneto = vprovision - vimpisr + vmtovalint;
                    
                    if vinteresneto is null then
                        let vinteresneto = 0;
                    end if
                    
                    let vhora = current hour to fraction(3);
                    
                    -- // REGISTRA MOVIMIENTO DE CAPITALIZACION
                    if vprovision > 0 then
                        insert into sv_movdia values 
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtrans_int, vsucursal,
                          vcuenta, vsecuencia, vcod_instrum, 0, vprovision, vprovision, 0, 0, "", vcapital, "0000" );
                    end if
                    
                    -- // REGISTRA MOVIMIENTO DE I.S.R.
                    if vimpisr > 0 then
                        let vhora = current hour to fraction(3);
                        
                        insert into sv_movdia values 
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtrans_isr, vsucursal,
                          vcuenta, vsecuencia, vcod_instrum, 0, vimpisr, vimpisr, 0, 0, "", vcapital, "0000");
                    end if
                    
                    -- // REGISTRA MANTENIMIENTO A VALOR
                    if vmtovalint > 0 then
                        let vhora = current hour to fraction(3);
                        
                        insert into sv_movdia values 
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, "5002", vsucursal,
                          vcuenta, vsecuencia, vcod_instrum, 0, vmtovalint, vmtovalint, 0, 0, "", vcapital, "0000" );
                    end if
                    
                    if vinteresneto > 0 then
                        if vsistema <> "00" then
                            -- // PROCESA TRASPASO A CHEQUES
                            insert into bdicheq:sc_movinver values
                            ( pempresa, "A", vsucursal, vnro_cuenta, vinteresneto, vmoneda, "N", vgfecha_hoy, "0207", vcuenta, vgusuario, "000", vgprox_fecha, "" );
                        else
                            call bdibanco:sbsp_graba_solchq(pempresa, vnum_cte, vgusuario, vinteresneto, vcuenta) 
                            returning vcodret, vmensaje, vsolbcos;
                        end if
                        
                        update sv_maeinstrucc
                           set importe = 0
                         where empresa = pempresa
                           and cuenta = vcuenta
                           and cap_int = "I";
                        
                        let vhora = current hour to fraction(3);
                        
                        insert into sv_movdia values 
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtran_ret, vsucursal,
                          vcuenta, vsecuencia, vcod_instrum, 0, vinteresneto, vinteresneto, 0, 0, "", vcapital, "0000" );
                        
                        update sv_maeinv
                           set fec_ult_mov = vgprox_fecha,
                               sdo_prom_mesant = 0
                         where empresa = pempresa
                           and cuenta = vcuenta
                           and secuencia = vsecuencia;
                    end if
                end if
            end if
        end if
        
        -- // PROCESA VENCIMIENTOS
        if ( vfecha_venc <= vgprox_fecha ) then
            -- // VERIFICA SI LA INVERSION TIENE MAS DE 3 AÑOS PARA CANCELARLA
            let vdFechaAlta = '';
            let viDiasInact = 0;
            
            select fecha_alta
              into vdFechaAlta
              from sv_maeinv
             where empresa = pempresa
               and cuenta = vcuenta
               and secuencia = 1;
               
            let viDiasInact = vfecha_venc - vdFechaAlta;
            
            if viDiasInact >= 1080 then
                update sv_maeinstrucc
                   set inst_vento = '02'
                 where empresa = pempresa
                   and cuenta = vcuenta
                   and cap_int in('C','I');
            end if
             
            let vtotal = 0;
            let vtotal_int = 0;
            let vhora = current hour to fraction(3);
            let vhorax = vhora;
            let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||vhorax[7,8]||vhorax[10,11];
            let vtotalreinv = 0;
            let vmonto_prov = 0;
            let vmonto_provisionado = 0;
            let vmonto_desprov = 0;
            let vmonto_provision_his = 0;
            let vmonto_provision_hoy = 0;
            let vmonto_desprovision_his = 0;
            let vmonto_desprovision_hoy = 0;
            let vmonto_desprovisionado = 0;
            let vprovision_total = 0;
            
            foreach
                select cap_int, inst_vento, importe, sistema, cta_cheques, aplicado
                  into vcap_int, vinst_vento, vimporte, vsistema, vnro_cuenta, vaplicado
                  from sv_maeinstrucc mi,
                       sv_instrucc ci
                 where mi.empresa = pempresa
                   and mi.cuenta = vcuenta
                   and ci.codigo = mi.inst_vento
                   and ci.empresa = mi.empresa
                
                if vaplicado = "N" then
                    if vcap_int = "C" then
                        let vtotal     = vtotal + vimporte;
                        let vinstcap   = vinst_vento;
                        let vctaabocap = vnro_cuenta;
                        let vsistemac  = vsistema;
                    else
                        if vimporte < vintereses then
                            let vtotal_int = (vintereses - vimporte) + vimporte;
                        else
                            let vtotal_int = vintereses;
                        end if
                        
                        let vinstint   = vinst_vento;
                        let vctaaboint = vnro_cuenta;
                        let vsistemai  = vsistema;
                    end if
                else
                    if vcap_int = "C" then
                        if vinst_vento = "01" then
                            let vinstcap    = vinst_vento;
                            let vsistemac   = vsistema;
                            let vtotalreinv = vtotalreinv + vcapital;
                            let vctaaboint  = vnro_cuenta;
                            let vsistemai   = vsistema;
                            let vctaabocap  = vnro_cuenta;
                        else
                            let vinstcap    = vinst_vento;
                            let vsistemac   = vsistema;
                            let vtotalreinv = 0.00;
                            let vctaaboint  = vnro_cuenta;
                            let vsistemai   = vsistema;
                            let vctaabocap  = vnro_cuenta;
                        end if
                    else
                        let vinstint   = vinst_vento;
                        let vctaaboint = vnro_cuenta;
                        let vsistemai  = vsistema;
                        let vctaabocap = vnro_cuenta;
                        
                        if vinst_vento = "01" then
                            let vtotalreinv = vtotalreinv + (vintereses - visrreinv);
                        else
                            let vtotalreinv = 0.00;
                        end if
                    end if
                end if
            end foreach
            
            IF vinstcap IS NULL OR vinstint IS NULL THEN
                ROLLBACK WORK;
                LET ven_transacc = 0;
                
                INSERT INTO sv_valcierre VALUES
                ( pempresa, vcuenta, 1, '151' );
                
                CONTINUE FOREACH;
            END IF
            
            -- // CAPITALIZA INTERESES
            let vinteres = 0;
            
            if vtotal_int > 0 then
                if vinstint = "01" then
                    let vfechapli = vgfecha_hoy;
                else
                    let vfechapli = vgprox_fecha;
                end if
                
                let vfechapli = vfecha_venc;
                let vimptot   = vtotal_int + vmtovalint;
                
                if vcobraisr = "S" then
                    let vimpisr = vtotal * vtasa_isr / 100 / vaniobase * vplazo;
                else
                    let vimpisr = 0;
                end if
                
                if vinstint <> "00" then
                    if vimptot > 0 then
                        let vinteresneto = vimptot - vimpisr;
                        
                        -- // PROCESA TRASPASO A CHEQUES
                        insert into bdicheq:sc_movinver values
                        ( pempresa, "A", vsucursal, vctaaboint, vimptot, vmoneda, "N", vgfecha_hoy, "0207", vcuenta, vgusuario, "000", vgprox_fecha, "" );
                    end if
                end if
                
                if vinstint = "01" then
                    if vfecha_venc > vgfecha_hoy then
                        let vinteres = vtotal_int;
                    end if
                else
                    let vinteres = vtotal_int;
                end if
                
                select {+INDEX(sv_instrucc ix137_1)} trans_int
                  into vtran_ret
                  from sv_instrucc
                 where codigo = vinstint;
                
                let vhora = current hour to fraction(3);
                
                -- // REGISTRA MOVIMIENTO DE CAPITALIZACION
                if vinteres > 0 then
                    let vhora = current hour to fraction(3);
                        
                    insert into sv_movdia values 
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, vtrans_int, vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, 0, vinteres, vinteres, 0, 0, " ", vcapital, "0000");
                end if
                
                -- // REGISTRA MOVIMIENTO DE ISR
                if vimpisr > 0 then
                    let vhora = current hour to fraction(3);
                    
                    insert into bdicheq:sc_movinver values
                    ( pempresa, "C", vsucursal, vctaaboint, vimpisr, vmoneda, "N", vgfecha_hoy, "3278", vcuenta, vgusuario, "000", vgprox_fecha, "" );
                    
                    insert into sv_movdia values 
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, vtrans_isr, vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, 0, vimpisr, vimpisr, 0, 0, " ", vcapital, "0000" );
                    
                    insert into sv_movdia values 
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, "0523", vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, 0, vimpisr, vimpisr, 0, 0, " ", vcapital, "0000" );
                        
                    update sv_maeinv
                       set isr = vimpisr
                     where empresa = pempresa
                       and cuenta = vcuenta
                       and secuencia = vsecuencia;
                end if
                
                -- // REGISTRA MANTENIMIENTO VALOR DE INTERESES
                if vmtovalint > 0 then
                    let vhora = current hour to fraction(3);
                    
                    insert into sv_movdia values 
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, "5002", vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, 0, vmtovalint, vmtovalint, 0, 0, " ", vcapital, "0000" );
                end if
                
                -- // REGISTRA MOVIMIENTO DE RETIRO DE INTERES
                let vinteres = vinteres + vmtovalint;
                
                if vinteresneto > 0 then
                    let vhora = current hour to fraction(3);
                    
                    insert into sv_movdia values 
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, vtran_ret, vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, 0, vinteresneto, vinteresneto, 0, 0, " ", vcapital, "0000" );
                    
                    -- // GENERA MOVIMIENTO DE PROVISION POR VENCIMIENTO SI ES MENSUAL AXL 
                    IF vprovision_int = "M" THEN
                        SELECT SUM(monto_tot)
                          INTO vmonto_provision_his
                          FROM sv_movhis
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND secuencia = vsecuencia
                           AND transacc = vtrans_prov
                           AND cancelad <> 'S';
                           
                        IF vmonto_provision_his is null THEN
                            LET vmonto_provision_his = 0.00;
                        END IF;
                        
                        SELECT SUM(monto_tot)
                          INTO vmonto_provision_hoy
                          FROM sv_movdia
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND secuencia = vsecuencia
                           AND transacc = vtrans_prov
                           AND cancelad <> 'S';
                        
                        IF vmonto_provision_hoy is null THEN
                            LET vmonto_provision_hoy = 0.00;
                        END IF;
                        
                        LET vmonto_provisionado = vmonto_provision_his + vmonto_provision_hoy;
                        
                        SELECT SUM(monto_tot)
                          INTO vmonto_desprovision_his
                          FROM sv_movhis
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND secuencia = vsecuencia
                           AND transacc = vtrans_desprov
                           AND cancelad <> 'S';
                           
                        IF vmonto_desprovision_his is null THEN
                            LET vmonto_desprovision_his = 0.00;
                        END IF;
                        
                        SELECT SUM(monto_tot)
                          INTO vmonto_desprovision_hoy
                          FROM sv_movdia
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND secuencia = vsecuencia
                           AND transacc = vtrans_desprov
                           AND cancelad <> 'S';
                        
                        IF vmonto_desprovision_hoy is null THEN
                            LET vmonto_desprovision_hoy = 0.00;
                        END IF;
                        
                        LET vmonto_desprovisionado = vmonto_desprovision_his + vmonto_desprovision_hoy;
                        
                        LET vprovision_total = vmonto_provisionado - vmonto_desprovisionado;
                           
                        IF vprovision_total > vtotal_int THEN
                            LET vmonto_desprov = vprovision_total - vtotal_int;
                            
                            INSERT INTO sv_movdia VALUES 
                            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_desprov, vsucursal,
                              vcuenta, vsecuencia, vcod_instrum, vdiasmact, vmonto_desprov, vmonto_desprov, 0, 0, "", vcapital, "0000" );
                        ELSE
                            LET vmonto_prov = vtotal_int - vprovision_total;
                            
                            IF vmonto_prov > 0.00 THEN
                                INSERT INTO sv_movdia VALUES 
                                ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_prov, vsucursal,
                                  vcuenta, vsecuencia, vcod_instrum, vdiasmact, vmonto_prov, vmonto_prov, 0, 0, "", vcapital, "0000" );
                            END IF;
                        END IF;
                        
                        UPDATE sv_maeinv
                           SET sdo_ult_corte = 0
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND status_cta in("1","3");
                    END IF
                    
                    -- // INICIALIZA IMPORTE POR PAGAR
                    update sv_maeinstrucc
                       set importe = 0,
                           aplicado = "S"
                     where empresa = pempresa
                       and cuenta = vcuenta
                       and cap_int = "I";
                end if
                
                if vinstint = "01" and vfecha_venc = vgprox_fecha then
                    ---------------------------------------------
                else
                    -- // ACTUALIZA FECHA DE ULTIMO MOVIMIENTO Y MANTO VALOR
                    update sv_maeinv
                       set fec_ult_mov = vfechapli,
                           sdo_prom_mesant = 0
                     where empresa = pempresa
                       and cuenta = vcuenta
                       and secuencia = vsecuencia;
                end if
            end if
            
            if vtotal > 0  then
                if vinstcap = "00" and vfecha_venc > vgfecha_hoy then
                    ROLLBACK WORK;
                    LET ven_transacc = 0;
                    
                    INSERT INTO sv_valcierre VALUES
                    ( pempresa, vcuenta, 1, '151' );
                    
                    CONTINUE FOREACH;
                end if
                
                select {+INDEX(sv_instrucc ix137_1)} trans_cap
                  into vtran_ret
                  from sv_instrucc
                 where codigo = vinstcap;
                
                -- // REGISTRA MOVIMIENTO DE CANCELACION DE PASIVO
                let vhora = current hour to fraction(3);
                
                if vtrans_vtopas2 <> "" and vtrans_vtopas2 is not null then
                    insert into sv_movdia values
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, vtrans_vtopas2, vsucursal,
                      vcuenta, vsecuencia, vcod_instrum, 0, vtotal,vtotal, 0, 0, " ", vtotal, "0000" );
                end if
                
                -- // REGISTRA MOVIMIENTO DEL RETIRO POR CANCELACION
                let vhora = current hour to fraction(3);
                
                insert into sv_movdia values 
                ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vfechapli, vhora, vtran_ret, vsucursal,
                  vcuenta, vsecuencia, vcod_instrum, 0, vtotal, vtotal, 0, 0, " ", vcapital, "0000" );
                
                -- // INICIALIZA IMPORTE POR PAGAR
                update sv_maeinstrucc
                   set importe = 0,
                       aplicado = "S"
                 where empresa = pempresa
                   and cuenta = vcuenta
                   and cap_int = "C";
                
                if vinstcap <> "00" then
                    -- // PROCESA TRASPASO A CHEQUES
                    insert into bdicheq:sc_movinver values
                    ( pempresa, "A", vsucursal, vctaabocap, vtotal, vmoneda, "N", vgfecha_hoy, "0206", vcuenta, vgusuario, "000", vgprox_fecha, "" );
                END IF
            END IF
            
            -- // * GENERA REINVERSION AUTOMATICA AXL *
            --- IF ( vaplicado = "S" AND vfecha_venc = vgfecha_hoy AND ( vinstcap = "01" OR vinstint = "01" ) ) THEN
            IF ( vaplicado = "S" AND vfecha_venc = vgfecha_hoy ) THEN
            
                IF ( vinstcap = "01" OR vinstint = "01" ) THEN
                    
                    LET vtotal = vtotalreinv;
                    
                    CALL bdicheq:cargo_ref(pempresa, vsucursal, vpromotor, "0235", "0000", vfoliosuc, vctaabocap, 0, vtotal, "01", "", "", "")
                    RETURNING vcodret, vpaso, vpaso, vpaso, vpaso;
                    
                    IF vcodret <> "000" THEN
                        ROLLBACK WORK;
                        LET ven_transacc = 0;
                        
                        SELECT MAX(secuencia)
                          INTO vdirecc_envio
                          FROM sv_maeinv
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND status_cta IN ("1","4");
                        
                        UPDATE sv_maeinv
                           SET status_cta = "2",
                               fec_cancelac = vgfecha_hoy
                         WHERE empresa = pempresa
                           AND cuenta = vcuenta
                           AND secuencia = vdirecc_envio;
                        
                        INSERT INTO sv_valcierre VALUES
                        ( pempresa, vcuenta, 1, vcodret );
                        
                        LET vcodret = "000";
                        
                        CONTINUE FOREACH;
                    END IF
                        
                    select pzo_inicial 
                      into vplazo_nva
                      from sv_dias
                     where empresa = pempresa
                       and cuenta = vcuenta;
                        
                    if vplazo_nva is null or vplazo_nva = 0 then
                        let vplazo_nva = vplazo;
                    end if
                        
                    let vfecha_nva = vgfecha_hoy + vplazo_nva;
                    let vctanva = vcuenta;
                    let vsecnva = vsecuencia + 1;
                    
                    -- // REAPERTURA LA CUENTA
                    call apertura( pempresa, vnum_cte, vsecnva, vcod_instrum, vpromotor, "001", vsucursal, vplaza, "1", "0", " ", "N", " ", 
                                   vplazo_nva, vfecha_nva, vtotal, vper_acred_int, " ", vgusuario, "1", vcta_cheques, vctanva, 0, vdirecc_envio, vcobraisr )
                    returning vcodret, vctanva, vplazo_nva, vfecha_nva, visr_nvo, vintnet_nva, vtasa_nva, vtasaisr_nva, vtasaneta_nva;

                    if vcodret <> "000" then
                        ROLLBACK WORK;
                        LET ven_transacc = 0;
                        
                        INSERT INTO sv_valcierre VALUES
                        ( pempresa, vcuenta, 1, '365' );
                        
                        CONTINUE FOREACH;
                    else
                        update sv_maeinv
                           set status_cta = vstatus_cta,
                               sdo_cong = vsdo_cong
                         where empresa = pempresa
                           and cuenta = vctanva
                           and secuencia = vsecnva;
                    end if

                    if vplazo_nva > 0 then
                        let vprovdia = (vintnet_nva + visr_nvo) / vplazo_nva;
                    else
                        let vprovdia = 0;
                    end if

                    -- // REGISTRA DEPOSITO INICIAL NUEVO DOCUMENTO
                    let vhora = current hour to fraction(3);
                    
                    insert into sv_movdia values 
                    ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_reinv, vsucursal,
                      vctanva, vsecnva, vcod_instrum, 0, vtotal, vtotal, 0, 0, " ", vtotal, "0000" );

                    -- // REGISTRA ENTRADA DEL PASIVO
                    let vhora = current hour to fraction(3);
                    
                    if vtrans_vtopas1 <> "" and vtrans_vtopas1 is not null then
                        insert into sv_movdia values 
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_vtopas1, vsucursal,
                          vctanva, vsecnva, vcod_instrum, 0, vtotal, vtotal, 0, 0, " ", vtotal, "0000" );
                    end if

                    -- // RECALCULA MONTOS EN INSTRUCCIONES AL VENCIMIENTO  * SE CAMBIA POR UPDATE LALO 05MZO09 *
                    update sv_maeinstrucc
                       set (importe,aplicado,fecha_venc) = (vtotal,"N",vfecha_nva)
                     where empresa  = pempresa
                       and cuenta   = vctanva
                       and cap_int  = "C";
                    
                    update sv_maeinstrucc
                       set (importe,aplicado,fecha_venc) = (0,"N",vfecha_nva)
                     where empresa  = pempresa
                       and cuenta   = vctanva
                       and cap_int  = "I";

                    let vinteres = vprovdia * vdiasmact;

                    update sv_maeinv
                       set fec_ult_mov = vgfecha_hoy,
                           modificado  = vgusuario,
                           fecha_mod   = vgfecha_hoy,
                           status_cta  = "4"
                     where empresa = pempresa
                       and cuenta = vcuenta
                       and secuencia = vsecuencia;
                    
                    -- // REGISTRA PROVISION DEL MES ACTUAL
                    let vprovision = vprovdia * vdiasmact;
                    
                    --- // INICIALIZO VARIABLE PARA QUE NO PROVISIONE EL DIA DE LA REINVERSION DEL PAGARE //
                    let vprovision = 0; 

                    if vprovision > 0 then
                        let vhora = current hour to fraction(3);
                        
                        insert into sv_movdia values 
                        ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgfecha_hoy, vhora, vtrans_prov, vsucursal,
                          vctanva, vsecnva, vcod_instrum, vdiasmact, vprovision, vprovision, 0, 0, " ", vtotal, "0000");
                          
                        update sv_maeinv
                           set sdo_ult_corte = vprovision
                         where empresa = pempresa
                           and cuenta = vctanva
                           and secuencia = vsecnva;
                    end if

                    -- // REGISTRA PROVISION DEL MES SIGUIENTE
                    let vprovision = 0;

                    if vdiasmsig > 0 then
                        let vprovision = vprovdia * vdiasmsig;
                        let vhora = current hour to fraction;
                        
                        --- // INICIALIZO VARIABLE PARA QUE NO PROVISIONE EL DIA DE LA REINVERSION DEL PAGARE //
                        let vprovision = 0; 
                        
                        if vprovision > 0 then
                            insert into sv_movdia values 
                            ( pempresa, 0, vfoliosuc, vplaza, vsucursal, vgusuario, vgprox_fecha, vhora, vtrans_prov, vsucursal,
                              vctanva, vsecnva, vcod_instrum, vdiasmsig, vprovision, vprovision, 0, 0, " ", vtotal, "0000" );
                              
                            update sv_maeinv
                               set sdo_ult_corte = sdo_ult_corte + vprovision
                             where empresa = pempresa
                               and cuenta = vctanva
                               and secuencia = vsecnva;
                        end if 
                    end if

                    -- // ACTUALIZA ACUMULADO DE INTERESES
                    let vinteres = vprovdia * (vdiasmact + vdiasmsig);
                    
                    if vinteres > 0 then
                        update sv_maeinstrucc
                           set importe = importe + vinteres
                         where empresa = pempresa
                           and cuenta  = vctanva
                           and cap_int = "I"
                           and aplicado <> "S";
                           
                        update sv_maeinv
                           set sdo_ult_corte = vinteres
                         where empresa = pempresa
                           and cuenta = vctanva
                           and secuencia = vsecnva;
                    end if 
                ELIF ( vinstcap = "02" OR vinstint = "02" ) THEN
                    SELECT MAX(secuencia)
                      INTO vdirecc_envio
                      FROM sv_maeinv
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta
                       AND status_cta IN ("1","4");
                    
                    UPDATE sv_maeinv
                       SET status_cta = "2",
                           fec_cancelac = vgfecha_hoy
                     WHERE empresa = pempresa
                       AND cuenta = vcuenta
                       AND secuencia = vdirecc_envio;
                    
                    LET vcodret = "000";
                    
                    COMMIT WORK;
                    LET ven_transacc = 0;
                    
                    CONTINUE FOREACH;
                END IF;
            END IF;
        end if;
        
        update sv_maeinv
           set fecha_val = vgprox_fecha
         where cuenta = vcuenta
           and secuencia = vsecuencia;

        COMMIT WORK;
        LET ven_transacc = 0;
    END FOREACH;

    if vcodret = "00000" then
        let vcodret = "000";
    end if

    if vcodret = "000" then
        insert into sv_movmes
        select *
          from sv_movdia
         where empresa = pempresa
           and fech_alt <= vgfecha_hoy;

        insert into sv_movhis
        select *
          from sv_movdia
         where empresa = pempresa
           and fech_alt <= vgfecha_hoy;
        
        DELETE FROM sv_movdia
         WHERE empresa = pempresa
           and fech_alt <= vgfecha_hoy;
           
        -- // LLAMADO AL SPL QUE LLENA LAS TABLAS SV_PROVDIA Y SV_PROVMES
        CALL prov_diames(pempresa) 
        RETURNING vcodret;
            
        update {+INDEX(sv_contproc idx_contproc)} sv_contproc
           set fecha = vgfecha_hoy
         where proceso = "cierreinv";
    
        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin    = CURRENT,
               codret      = vcodret
         WHERE empresa = pEmpresa
           AND proceso = 'CierreInv'
           AND fecha   = vgfecha_hoy;
    end if
    
    return vcodret;
    
    end;
    
end procedure;