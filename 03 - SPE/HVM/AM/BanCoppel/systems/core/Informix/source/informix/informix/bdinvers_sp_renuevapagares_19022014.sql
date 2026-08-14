create procedure "informix".sp_renuevapagares_19022014(pempresa char(3))
returning char(5);

    define global vgusuario     char(8) default " ";
    define global vgprox_fecha  date    default " ";
    define global vgfecha_hoy   date    default " ";
    define global vgpri_hab_mes date    default " ";
    define global vgpri_dia_mes date    default " ";
    define global vgult_hab_mes date    default " ";
    define global vgult_dia_mes date    default " ";
    
    define vsqlerr              integer;
    define vcodret              char(5);
    define vcap_int             char(1);
    define vexiste              char(1);
    define vexiste2             char(1);
    define vper_acred_int       char(1);
    define vprovision_int       char(1);
    define vstatus_cta          char(1);
    define vcobraisr            char(1);
    define vaplicado            char(1);
    define vsecnva              smallint;
    define vtotsuc              smallint;
    define vcontproc            smallint;
    define vcontador            smallint;
    define vsecuencia           smallint;
    define vdias                smallint;
    define vdiasmact            smallint;
    define vdiasmsig            smallint;
    define vnum_dias_int        smallint;
    define vplazo               smallint;
    define vplazo_nva           smallint;
    define vcuenta              char(20);
    define vnum_cte             char(20);
    define vcta_cheques         char(20);
    define vctacap              char(20);
    define vctaint              char(20);
    define vctanva              char(20);
    define vnro_cuenta          char(20);
    define vctaaboint           char(20);
    define vctaabocap           char(20);
    define vsucursal            char(4);
    define vplaza               char(3);
    define vprovdia             decimal(14,6);
    define vcapital             money(14,2);
    define vprovision           money(14,2);
    define vinteres             money(14,2);
    define vintereses           money(14,2);
    define vimporte             money(14,2);
    define vmtovalint           money(14,2);
    define visr                 money(14,2);
    define vsdo_prom_mesant     money(14,2);
    define vtotal               money(14,2);
    define vtotal_int           money(14,2);
    define vintnvo              money(14,2);
    define vimptot              money(14,2);
    define vimpisr              money(14,2);
    define vintnet_nva          money(14,2);
    define visr_nvo             money(14,2);
    define vprovmes             money(14,2);
    define vsdo_cong            money(14,2);
    define vcod_instrum         char(4);
    define vtasa                decimal(9,6);
    define vsobretasa           decimal(9,6);
    define vtasa_nva            decimal(9,6);
    define vtasaisr_nva         decimal(9,6);
    define vtasaneta_nva        decimal(9,6);
    define vtransacc            char(4);
    define vtrans_cap           char(4);
    define vtrans_int           char(4);
    define vtrans_isr           char(4);
    define vtrans_vtopas1       char(4);
    define vtrans_vtopas2       char(4);
    define vtrans_prov          char(4);
    define vtrans_proval        char(4);
    define vtrans_intval        char(4);
    define vtrans_isrval        char(4);
    define vtrans_reinv         char(4);
    define vtran_ret            char(4);
    define vfechapli            date;
    define vfecha_nva           date;
    define vfecha_alta          date;
    define vfecha_venc          date;
    define vmoneda              char(2);
    define vinst_vento          char(2);
    define vsistema             char(2);
    define vinstcap             char(2);
    define vinstint             char(2);
    define vsistcap             char(2);
    define vsistint             char(2);
    define vnvainst             char(2);
    define vsistnvo             char(2);
    define vultdig              char(2);
    define vsistemai            char(2);
    define vsistemac            char(2);
    define vfoliosuc            char(16);
    define vsolbcos             integer;
    define vmensaje             char(80);
    define vhorax               char(16);
    define vdirecc_envio        smallint;
    define vpromotor            char(8);
    define vdia,vmes            char(2);
    define vano                 char(4);
    define vfecaboint           date;
    define vtasa_isr            decimal(9,6);
    define vgenera_producto     char(1);
    define vproductochq         char(4);
    define vinteresneto         money(14,2);
    DEFINE vinstruccion         CHAR(2);
    DEFINE vpaso                CHAR(10);
    DEFINE visrreinv            DECIMAL(14,2);
    DEFINE vtotalreinv          DECIMAL(14,2);
    DEFINE vanio                integer;
    DEFINE vresiduo             integer;
    DEFINE vaniobase            integer;
    define vhora                datetime hour to fraction(3);
    DEFINE vfolio_suc           CHAR(16);
    DEFINE vexistee             smallint;
    DEFINE vmonto_prov          MONEY(14,2);
    DEFINE vmonto_provisionado  MONEY(14,2);
    DEFINE vmonto_desprov       MONEY(14,2);
    DEFINE vtrans_desprov       char(4);
    DEFINE vmonto_provision_his MONEY(14,2);
    DEFINE vmonto_provision_hoy MONEY(14,2);
    DEFINE vdFechaAlta          DATE;
    DEFINE viDiasInact          INTEGER;
    DEFINE vmonto_desprovision_his  MONEY(14,2);
    DEFINE vmonto_desprovision_hoy  MONEY(14,2);
    DEFINE vmonto_desprovisionado   MONEY(14,2);
    DEFINE vprovision_total         MONEY(14,2);
    
    begin 
    
    on exception set vsqlerr
        set debug file to "/resplogifx/conciliachq/sp_renuevapagares_19022014.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if;
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/sp_renuevapagares_19022014.out";
    --- trace on;
    
    let vgusuario = USER;
    let vcodret = "000";
    let vaniobase = 365;
    let vinstcap = '';
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select {+INDEX(sv_fechas idx_fechas)}
           fecha_hoy, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes
      into vgfecha_hoy, vgprox_fecha, vgpri_dia_mes, vgpri_hab_mes, vgult_dia_mes, vgult_hab_mes
      from sv_fechas
     where empresa = pempresa;
     
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
    
    TRUNCATE TABLE "informix".sv_valcierre;
    
    foreach with hold
        select {+INDEX(sv_instrum idx_instrum)}
               cuenta, capital, mv.sucursal, mv.cod_instrum, intereses, tasa, sobretasa, trans_cap, trans_int, trans_isr, trans_vtopas1, trans_vtopas2, 
               trans_prov, trans_proval, trans_intval, trans_isrval, trans_reinv, mv.per_acred_int, fec_reinversion, fecha_venc, plazo, moneda, cta_cheques, mv.plaza, 
               sdo_prom_mesant, num_cte, mv.promotor, mv.direcc_envio, mv.cobraisr, mv.secuencia, status_cta, mv.sdo_cong, num_dias_int, isr, sdo_ult_corte, provision_int
          into vcuenta, vcapital, vsucursal, vcod_instrum, vintereses, vtasa, vsobretasa, vtrans_cap, vtrans_int, vtrans_isr, vtrans_vtopas1, vtrans_vtopas2,
               vtrans_prov, vtrans_proval, vtrans_intval, vtrans_isrval, vtrans_reinv, vper_acred_int, vfecha_alta, vfecha_venc, vplazo, vmoneda, vcta_cheques, vplaza,
               vmtovalint, vnum_cte, vpromotor, vdirecc_envio, vcobraisr, vsecuencia, vstatus_cta, vsdo_cong, vnum_dias_int, visrreinv, vprovmes, vprovision_int
          from sv_maeinv mv,
               sv_instrum pr
         where mv.status_cta in("1","3")
           and mv.empresa = pempresa
           and mv.fecha_venc = vgfecha_hoy
           and pr.cod_instrum = mv.cod_instrum
           and pr.gpo_instrum = "CD"
         order by mv.cuenta
         
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
            select {+INDEX(sv_instrucc ix137_1)}
                   cap_int, inst_vento, importe, sistema, cta_cheques, aplicado
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
                        LET vtotalreinv = vtotalreinv + vcapital;
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
                        LET vtotalreinv = vtotalreinv + (vintereses - visrreinv);
                    end if
                end if
            end if
        end foreach

        IF vinstcap IS NULL OR vinstint IS NULL THEN
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
                continue foreach;
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
        IF vaplicado = "S" AND vfecha_venc = vgfecha_hoy AND (vinstcap = "01" OR vinstint = "01") THEN
            let vtotal = vtotalreinv;

            CALL bdicheq:cargo_ref(pempresa, vsucursal, vpromotor, "0235", "0000", vfoliosuc, vctaabocap, 0, vtotal, "01", "", "", "")
            RETURNING vcodret, vpaso, vpaso, vpaso, vpaso;

            IF vcodret <> "000" THEN
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
                return vcodret;
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
        end if
    end foreach
    
    end;
    
    return vcodret;
    
end procedure;