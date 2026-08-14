create procedure "informix".cierreinv_28102009(pempresa char(3))

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

define vsqlerr                              integer;
define vcodret                              char(5);
define vcap_int,vexiste,vexiste2,
       vper_acred_int,vprovision_int,
       vstatus_cta,vcobraisr,vaplicado      char(1);

define vsecnva,vtotsuc,vcontproc,
       vcontador,vsecuencia                 smallint;

define vdias,vdiasmact,vdiasmsig,
       vnum_dias_int,vplazo,vplazo_nva      smallint;

define vcuenta,vnum_cte,vcta_cheques,
       vctacap,vctaint,vctanva,vnro_cuenta,
       vctaaboint,vctaabocap                char(20);

define vsucursal                            char(4);
define vplaza                               char(3);
define vprovdia                             decimal(14,6);
define vcapital,vprovision,vinteres,
       vintereses,vimporte,vmtovalint,visr,
       vsdo_prom_mesant,vtotal,vtotal_int,
       vintnvo,vimptot,vimpisr,vintnet_nva,
       visr_nvo,vprovmes,vsdo_cong          money(14,2);

define vcod_instrum                         char(4);
define vtasa,vsobretasa,vtasa_nva,
       vtasaisr_nva,vtasaneta_nva           decimal(9,6);

define vtransacc,vtrans_cap,vtrans_int,
       vtrans_isr,vtrans_vtopas1,
       vtrans_vtopas2,vtrans_prov,
       vtrans_proval,vtrans_intval,
       vtrans_isrval,vtrans_reinv,vtran_ret char(4);

define vfechapli,vfecha_nva,
       vfecha_alta,vfecha_venc              date;

define vmoneda,vinst_vento,vsistema,
       vinstcap,vinstint,vsistcap,
       vsistint,vnvainst,vsistnvo,
       vultdig,vsistemai,vsistemac          char(2);

define vfoliosuc                            char(16);
define vsolbcos                             integer;
define vmensaje                             char(80);
define vhorax                               char(16);
define vdirecc_envio                        smallint;
define vpromotor                            char(8);
define vdia,vmes                            char(2);
define vano                                 char(4);
define vfecaboint                           date;
define vtasa_isr                            decimal(9,6);
define vgenera_producto                     char(1);
define vproductochq                         char(4);
define vinteresneto                         money(14,2);
DEFINE vinstruccion                         CHAR(2);
DEFINE vpaso                                CHAR(10);
DEFINE visrreinv                            DECIMAL(14,2);
DEFINE vtotalreinv                          DECIMAL(14,2);
DEFINE vanio                                integer;
DEFINE vresiduo                             integer;
DEFINE vaniobase                            integer;
define vhora                                datetime hour to fraction(3);
DEFINE vfolio_suc                           CHAR(16);
DEFINE vexistee                             smallint;
DEFINE vmontoprov                           MONEY(14,2);

begin

on exception set vsqlerr
    if vsqlerr <> 0 then
        let vcodret = vsqlerr;
        UPDATE bdinteg:sx_contproc
           SET status_proc = 'C',
               hora_fin    = CURRENT,
               codret      = vcodret
         WHERE empresa = pEmpresa
           AND proceso  = 'CierreInv'
           AND fecha    = vgfecha_hoy;
        return vcodret;
    end if;
end exception;

--set debug file to "cierreinv.out";
--trace on;

let vgusuario = USER;
let vcodret = "000";
let vaniobase = 365;

LET vgfecha_hoy   = "10282009";
LET vgprox_fecha  = "10292009";
LET vgpri_dia_mes = "10012009";
LET vgpri_hab_mes = "10012009";
LET vgult_dia_mes = "10312009";
LET vgult_hab_mes = "10312009";

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
                     and tasa = "I.S.R.");

if vgfecha_hoy = vgult_hab_mes then
    let vdiasmact = vgult_dia_mes - vgfecha_hoy + 1;
    let vdiasmsig = vgprox_fecha - vgult_dia_mes - 1;
else
    let vdiasmact = vgprox_fecha - vgfecha_hoy;
    let vdiasmsig = 0;
end if

let vdias = vdiasmact + vdiasmsig;

-- // TRUNCA TABLA DE CODIGOS DE RETORNOS DEL CIERRE
TRUNCATE TABLE "informix".sv_valcierre;

-- // CANCELA INVERSIONES PROCESADAS UN DIA ANTERIOR (DEP A CHEQUES)
foreach
    select {+INDEX(sv_maeinstrucc ix442_1)}
           mv.cuenta, mv.secuencia, inst_vento
      into vcuenta,vsecuencia, vinstruccion
      from sv_maeinv mv,sv_maeinstrucc mi
     where mv.status_cta = "1"
       and mi.cuenta = mv.cuenta
       and mi.empresa = mv.empresa
       and mi.cap_int = "C"
       and mi.importe = 0

    IF vinstruccion = "01" THEN -- Reinversion
        ------- 
    ELIF vinstruccion = "02" THEN -- Deposito a Cta.
        select count(*) into vcontador
          from sv_maeinstrucc
         where empresa = pempresa
           and cuenta = vcuenta
           and importe <> 0;

        if vcontador is null or vcontador = 0 then
            update sv_maeinv
               set (status_cta,fec_ult_mov,fec_cancelac) =
                   ("2",vgfecha_hoy,vgfecha_hoy)
             where empresa = pempresa
               and cuenta = vcuenta
               and secuencia = vsecuencia;
        end if
    END IF
end foreach

-- // ELIMINA INVERSIONES APERTURADAS HOY SIN DEPOSITO INICIAL
foreach
    select cuenta into vcuenta
      from sv_maeinv
     where empresa = pempresa
       and fecha_alta = vgfecha_hoy
       and secuencia = 1
       and status_cta = "0"

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
    SELECT {+INDEX(sv_movdia ix161_17)}
           cuenta, folio_suc
      INTO vcuenta, vfolio_suc
      FROM sv_movdia
     WHERE cancelad <> "S"
       AND transacc = "0500"

    SELECT {+INDEX(sv_maeinv mai5)}
           cta_cheques
      INTO vcta_cheques
      FROM sv_maeinv
     WHERE status_cta <> "2"
       AND cuenta = vcuenta;

    SELECT count(*)
      INTO vexistee
      FROM bdicheq:sc_movdia
     WHERE cancelad = "S"
       AND transacc = "0235"
       AND cuenta = vcta_cheques
       AND folio_suc = vfolio_suc;

    IF vexistee > 0 THEN
        UPDATE sv_maeinv
           SET status_cta = "2",
               fec_cancelac = vgfecha_hoy
         WHERE fecha_alta = vgfecha_hoy
           AND cuenta = vcuenta;

        UPDATE sv_movdia
           SET cancelad = "S"
         WHERE fech_alt = vgfecha_hoy
           AND transacc  = "0500"
           AND folio_suc = vfolio_suc
           AND cuenta = vcuenta;

        UPDATE sv_movdia
           SET cancelad = "S"
         WHERE fech_alt = vgfecha_hoy
           AND transacc  = "0514"
           AND folio_suc = vfolio_suc
           AND cuenta = vcuenta;
    END IF
END FOREACH

-- // CALCULA PROVISION E INTERES DIARIO
foreach
    select {+INDEX(sv_instrum idx_instrum)}
            cuenta,secuencia,sucursal,mv.plaza,capital,sdo_ult_corte,
            mv.cod_instrum,tasa + sobretasa,trans_prov,
            num_dias_int,mv.per_acred_int,provision_int
      into vcuenta,vsecuencia,vsucursal,vplaza,vcapital,vprovmes,
           vcod_instrum,vtasa,vtrans_prov,vnum_dias_int,vper_acred_int,
           vprovision_int
      from sv_maeinv mv,sv_instrum pr
     where mv.status_cta in ("1","3")
       and mv.empresa = pempresa
       and mv.fecha_venc > vgfecha_hoy
	   and mv.fecha_alta <> "10292009"
       and mv.empresa = pr.empresa
       and pr.cod_instrum = mv.cod_instrum
       --- and mv.cuenta in('30000085193')
     order by mv.cuenta

    if vnum_dias_int > 0 then
        let vprovdia = vcapital * vtasa / 100 / vnum_dias_int;
    else
        let vprovdia = 0;
    end if

    let vhora = current hour to fraction(3);
    let vhorax = vhora;
    let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||
                    vhorax[7,8]||vhorax[10,11];

    -- // CALCULA PROVISION MES ACTUAL
    let vprovision = vprovdia * vdiasmact;
    let vhora = current hour to fraction(3);

    if vprovision > 0 then
        if vprovision_int = "D" then
            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vgfecha_hoy,vhora,vtrans_prov,vsucursal,vcuenta,
                    vsecuencia,vcod_instrum,vdiasmact,vprovision,
                    vprovision,0,0,"",vcapital,"0000");
            let vprovmes = 0;
        else
            let vprovmes = vprovmes + vprovision;
            if vgfecha_hoy = vgult_hab_mes then
                insert into sv_movdia
                values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                        vgfecha_hoy,vhora,vtrans_prov,vsucursal,vcuenta,
                        vsecuencia,vcod_instrum,vdiasmact,vprovmes,vprovmes,
                0,0,"",vcapital,"0000");
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
                insert into sv_movdia
                values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                        vgfecha_hoy,vhora,vtrans_prov,vsucursal,vcuenta,
                        vsecuencia,vcod_instrum,vdiasmsig,vprovision,
                        vprovision,0,0,"",vcapital,"0000");
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
end foreach

-- // CIERRE MENSUAL
if vgfecha_hoy = vgult_hab_mes then
    foreach
        select {+INDEX(sv_instrum idx_instrum)}
               cuenta,capital,mv.sucursal,mv.cod_instrum,
               intereses,tasa,sobretasa,trans_cap,trans_int,trans_isr,
               trans_vtopas1,trans_vtopas2,trans_prov,trans_proval,
               trans_intval,trans_isrval,trans_reinv,mv.per_acred_int,
               mv.fecha_alta,fecha_venc,plazo,moneda,cobraisr,
               cta_cheques,mv.plaza,sdo_prom_mesant,num_cte,mv.secuencia,
               num_dias_int
          into vcuenta,vcapital,vsucursal,vcod_instrum,
               vintereses,vtasa,vsobretasa,vtrans_cap,vtrans_int,vtrans_isr,
               vtrans_vtopas1,vtrans_vtopas2,vtrans_prov,vtrans_proval,
               vtrans_intval,vtrans_isrval,vtrans_reinv,vper_acred_int,
               vfecha_alta,vfecha_venc,vplazo,vmoneda,vcobraisr,
               vcta_cheques,vplaza,vmtovalint,vnum_cte,vsecuencia,
               vnum_dias_int
          from sv_maeinv mv,sv_instrum pr
         where status_cta in("1","3")
           and mv.empresa = pempresa
           and mv.fecha_alta <= vgfecha_hoy
           and mv.fecha_venc != vgfecha_hoy
           and mv.per_acred_int <> "V"
           and pr.cod_instrum = mv.cod_instrum
           and pr.gpo_instrum = "CD"
           --- and mv.cuenta in('30000085193')
         order by mv.cuenta

        let vhora = current hour to fraction(3);
        let vhorax = vhora;
        let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||
                        vhorax[7,8]||vhorax[10,11];

        if vper_acred_int = "M" or
            (vper_acred_int = "T" and month(vgfecha_hoy) in(3,6,9,12)) or
            (vper_acred_int = "S" and month(vgfecha_hoy) in(6,12)) or
            (vper_acred_int = "A" and month(vgfecha_hoy) = 12) then

            select {+INDEX(sv_instrucc ix137_1)}
                   sistema,cta_cheques,trans_int,importe,
                   producto,genera_producto
              into vsistema,vnro_cuenta,vtran_ret,vprovision,
                   vproductochq,vgenera_producto
              from sv_maeinstrucc mi,sv_instrucc ci
             where mi.empresa = pempresa
               and mi.cuenta = vcuenta
               and mi.cap_int = "I"
               and mi.aplicado <> "S"
               and mi.sistema <> "03"
               and ci.codigo = mi.inst_vento;

            if vcobraisr = "S" then
                let vimpisr = vcapital * vtasa_isr/100/vaniobase*vplazo;
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
                    insert into sv_movdia
                    values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                            vgusuario,vgprox_fecha,vhora,vtrans_int,
                            vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                            vprovision,vprovision,0,0,"",vcapital,"0000");
                end if

                -- // REGISTRA MOVIMIENTO DE I.S.R.
                if vimpisr > 0 then
                    let vhora = current hour to fraction(3);
                    insert into sv_movdia
                    values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                            vgusuario,vgprox_fecha,vhora,vtrans_isr,
                            vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                            vimpisr,vimpisr,0,0,"",vcapital,"0000");
                end if

                -- // REGISTRA MANTENIMIENTO A VALOR
                if vmtovalint > 0 then
                    let vhora = current hour to fraction(3);
                    insert into sv_movdia
                    values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                            vgusuario,vgprox_fecha,vhora,"5002",
                            vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                            vmtovalint,vmtovalint,0,0,"",vcapital,"0000");
                end if

                if vinteresneto > 0 then
                    if vsistema <> "00" then
                        if vgenera_producto = "S" then
                            select 1 into vexiste
                              from bdicheq:sc_maechq
                             where num_cte = vnum_cte
                               and producto = vproductochq;

                            if vexiste is null then
                                call bdicheq:cuenta1(pempresa,vgusuario,vsucursal,
                                                    vproductochq,vnum_cte,0,"1","1","001",
                                                    vgusuario,0,"","1","","","","","","",0,"N")
                                returning vcodret,vnro_cuenta;
                            end if
                        end if

                        -- // PROCESA TRASPASO A CHEQUES
                        insert into bdicheq:sc_movinver
                        values(pempresa,"A",vsucursal,vnro_cuenta,
                                vinteresneto,vmoneda,"N",vgfecha_hoy,"0207",
                                vcuenta,vgusuario,"000",vgprox_fecha,"");
                    else
                        call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,
                                        vgusuario, vinteresneto,vcuenta)
                        returning vcodret,vmensaje,vsolbcos;
                    end if

                    update sv_maeinstrucc
                       set importe = 0
                     where empresa = pempresa
                       and cuenta = vcuenta
                       and cap_int = "I";

                    let vhora = current hour to fraction(3);

                    insert into sv_movdia
                    values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                            vgusuario,vgprox_fecha,vhora,vtran_ret,
                            vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                            vinteresneto,vinteresneto,0,0,"",vcapital,"0000");

                    update sv_maeinv
                       set fec_ult_mov=vgfecha_hoy,
                           sdo_prom_mesant = 0
                     where empresa = pempresa
                       and cuenta = vcuenta
                       and secuencia = vsecuencia;
                end if
            end if
        end if
    end foreach
end if

-- // PAGA INTERES ANIVERSARIO
foreach
    select {+INDEX(sv_instrum idx_instrum)}
           cuenta,capital,mv.sucursal,mv.cod_instrum,
           intereses,tasa,sobretasa,trans_cap,trans_int,trans_isr,
           trans_vtopas1,trans_vtopas2,trans_prov,trans_proval,
           trans_intval,trans_isrval,trans_reinv,mv.per_acred_int,
           mv.fecha_alta,fecha_venc,plazo,moneda,cobraisr,
           cta_cheques,mv.plaza,sdo_prom_mesant,num_cte,mv.secuencia,
           promotor,num_dias_int
      into vcuenta,vcapital,vsucursal,vcod_instrum,vintereses,
           vtasa,vsobretasa,vtrans_cap,vtrans_int,vtrans_isr,
           vtrans_vtopas1,vtrans_vtopas2,vtrans_prov,vtrans_proval,
           vtrans_intval,vtrans_isrval,vtrans_reinv,vper_acred_int,
           vfecha_alta,vfecha_venc,vplazo,vmoneda,vcobraisr,
           vcta_cheques,vplaza,vmtovalint,vnum_cte,vsecuencia,
           vpromotor,vnum_dias_int
      from sv_maeinv mv,sv_instrum pr
     where status_cta in("1","3")
       and mv.empresa = pempresa
       and mv.fecha_alta <= vgfecha_hoy
       and mv.fecha_venc != vgfecha_hoy
       and mv.per_acred_int = "N"
       and pr.cod_instrum = mv.cod_instrum
       and pr.gpo_instrum = "CD"
       --- and mv.cuenta in('30000085193')
     order by cuenta

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

    let vfecaboint = lpad(trim(vmes),2,"0")||"/"||
    lpad(trim(vdia),2,"0")||"/"||vano;

    if vfecaboint > vgfecha_hoy and vfecaboint <= vgprox_fecha then
        select {+INDEX(sv_instrucc ix137_1)}
               sistema,cta_cheques,trans_int,importe
          into vsistema,vnro_cuenta,vtran_ret,vprovision
          from sv_maeinstrucc mi,sv_instrucc ci
         where mi.empresa = pempresa
           and mi.cuenta = vcuenta
           and mi.cap_int = "I"
           and mi.aplicado <> "S"
           and mi.sistema != "03"
           and ci.codigo = mi.inst_vento;

        if vcobraisr = "S" then
            let vimpisr = vcapital * vtasa_isr/100/vaniobase*vplazo;
        else
            let vimpisr = 0;
        end if

        if vsistema <> "03" then
            let vhora = current hour to fraction(3);
            let vhorax = vhora;
            let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||
                            vhorax[7,8]||vhorax[10,11];
            let vinteresneto = vprovision - vimpisr + vmtovalint;

            if vinteresneto is null then
                let vinteresneto = 0;
            end if

            let vhora = current hour to fraction(3);

            -- // REGISTRA MOVIMIENTO DE CAPITALIZACION
            if vprovision > 0 then
                insert into sv_movdia
                values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                        vgusuario,vgprox_fecha,vhora,vtrans_int,
                        vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                        vprovision,vprovision,0,0,"",vcapital,"0000");
            end if

            -- // REGISTRA MOVIMIENTO DE I.S.R.
            if vimpisr > 0 then
                let vhora = current hour to fraction(3);
                insert into sv_movdia
                values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                        vgusuario,vgprox_fecha,vhora,vtrans_isr,
                        vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                        vimpisr,vimpisr,0,0,"",vcapital,"0000");
            end if

            -- // REGISTRA MANTENIMIENTO A VALOR
            if vmtovalint > 0 then
                let vhora = current hour to fraction(3);
                insert into sv_movdia
                values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                        vgusuario,vgprox_fecha,vhora,"5002",
                        vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                        vmtovalint,vmtovalint,0,0,"",vcapital,"0000");
            end if

            if vinteresneto > 0 then
                if vsistema <> "00" then
                    -- // PROCESA TRASPASO A CHEQUES
                    insert into bdicheq:sc_movinver
                    values(pempresa,"A",vsucursal,vnro_cuenta,vinteresneto,
                            vmoneda,"N",vgfecha_hoy,"0207",vcuenta,
                            vgusuario,"000",vgprox_fecha,"");
                else
                    call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vgusuario,
                    vinteresneto,vcuenta) returning vcodret,vmensaje,vsolbcos;
                end if

                update sv_maeinstrucc
                   set importe = 0
                 where empresa = pempresa
                   and cuenta = vcuenta
                   and cap_int = "I";

                let vhora = current hour to fraction(3);

                insert into sv_movdia
                values (pempresa,0,vfoliosuc,vplaza,vsucursal,
                        vgusuario,vgprox_fecha,vhora,vtran_ret,
                        vsucursal,vcuenta,vsecuencia,vcod_instrum,0,
                        vinteresneto,vinteresneto,0,0,"",vcapital,"0000");

                update sv_maeinv
                   set fec_ult_mov=vgprox_fecha,
                       sdo_prom_mesant = 0
                 where empresa = pempresa
                   and cuenta = vcuenta
                   and secuencia = vsecuencia;
            end if
        end if
    end if
end foreach

-- // PROCESA VENCIMIENTOS
foreach with hold
    select {+INDEX(sv_instrum idx_instrum)}
           cuenta,capital,mv.sucursal,mv.cod_instrum,
           intereses,tasa,sobretasa,trans_cap,trans_int,
           trans_isr,trans_vtopas1,trans_vtopas2,trans_prov,
           trans_proval,trans_intval,trans_isrval,trans_reinv,
           mv.per_acred_int,fec_reinversion,fecha_venc,plazo,moneda,
           cta_cheques,mv.plaza,sdo_prom_mesant,num_cte,mv.promotor,
           mv.direcc_envio,mv.cobraisr,mv.secuencia,status_cta,mv.sdo_cong,
           num_dias_int, isr, sdo_ult_corte, provision_int
      into vcuenta,vcapital,vsucursal,vcod_instrum,vintereses,
           vtasa,vsobretasa,vtrans_cap,vtrans_int,vtrans_isr,
           vtrans_vtopas1,vtrans_vtopas2,vtrans_prov,vtrans_proval,
           vtrans_intval,vtrans_isrval,vtrans_reinv,vper_acred_int,
           vfecha_alta,vfecha_venc,vplazo,vmoneda,
           vcta_cheques,vplaza,vmtovalint,vnum_cte,vpromotor,
           vdirecc_envio,vcobraisr,vsecuencia,vstatus_cta,vsdo_cong,
           vnum_dias_int, visrreinv, vprovmes, vprovision_int
      from sv_maeinv mv,sv_instrum pr
     where mv.status_cta in("1","3")
       and mv.empresa = pempresa
       and mv.fecha_venc <= vgprox_fecha
       and pr.cod_instrum = mv.cod_instrum
       and pr.gpo_instrum = "CD"
       --- and mv.cuenta in('30000085193')
     order by mv.cuenta

    let vtotal = 0;
    let vtotal_int = 0;
    let vhora = current hour to fraction(3);
    let vhorax = vhora;
    let vfoliosuc = vgusuario||vhorax[1,2]||vhorax[4,5]||
                    vhorax[7,8]||vhorax[10,11];
    LET vtotalreinv = 0;

    foreach
        select {+INDEX(sv_instrucc ix137_1)}
               cap_int,inst_vento,importe,sistema,
               cta_cheques,aplicado
          into vcap_int,vinst_vento,vimporte,vsistema,
               vnro_cuenta,vaplicado
          from sv_maeinstrucc mi,sv_instrucc ci
         where mi.empresa = pempresa
           and mi.cuenta = vcuenta
           and ci.codigo = mi.inst_vento
           and ci.empresa = mi.empresa

        if vaplicado = 'N' then
            if vcap_int = 'I' then
                if vimporte < vintereses then
                    let vmontoprov = vintereses - vimporte;
                    { ******************************************************
                    insert into sv_movdia
                    values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                            vgfecha_hoy,vhora,vtrans_prov,vsucursal,vcuenta,
                            vsecuencia,vcod_instrum,0,vmontoprov,vmontoprov,
                            0,0," ",vcapital,"0000");
                    ******************************************************* }
                    let vtotal_int = vmontoprov;
                end if
            end if
        end if

        if vaplicado = "S" then
            if vcap_int = "I" then
                let vinstint = vinst_vento;
                let vctaaboint = vnro_cuenta;
                let vsistemai = vsistema;
                let vctaabocap = vnro_cuenta;
                IF vinst_vento = "01" THEN
                    LET vtotalreinv= vtotalreinv + (vintereses - visrreinv);
                END IF
            else
                IF vinst_vento = "01" THEN
                    let vinstcap = vinst_vento;
                    let vsistemac = vsistema;
                    LET vtotalreinv = vtotalreinv + vcapital;
                    let vctaaboint = vnro_cuenta;
                    let vsistemai = vsistema;
                    let vctaabocap = vnro_cuenta;
                END IF
            end if
        else
            if vcap_int = "C" then
                let vtotal = vtotal + vimporte;
                let vinstcap = vinst_vento;
                let vctaabocap = vnro_cuenta;
                let vsistemac = vsistema;
            else
                let vtotal_int = vtotal_int + vimporte;
                let vinstint = vinst_vento;
                let vctaaboint = vnro_cuenta;
                let vsistemai = vsistema;
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
        let vimptot  = vtotal_int + vmtovalint;

        if vcobraisr = "S" then
            let vimpisr = vtotal * vtasa_isr/100/vaniobase * vplazo;
        else
            let vimpisr = 0;
        end if

        if vinstint <> "00" then
            if vimptot > 0 then
                let vinteresneto = vimptot - vimpisr;
                -- if vsistemai = "01" then

                -- // PROCESA TRASPASO A CHEQUES
                insert into bdicheq:sc_movinver
                values(pempresa, "A", vsucursal, vctaaboint, vimptot,
                        vmoneda, "N", vgfecha_hoy, "0207", vcuenta,
                        vgusuario, "000", vgprox_fecha, "");

                { **********************************************************
                else
                call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vgusuario,
                vinteresneto,vcuenta)
                returning vcodret,vmensaje,vsolbcos;
                end if
                *********************************************************** }
            end if
        end if

        if vinstint = "01" then
            if vfecha_venc > vgfecha_hoy then
                let vinteres = vtotal_int;
                -- let vimpisr = 0;
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
            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vfechapli,vhora,vtrans_int,vsucursal,vcuenta,
                    vsecuencia,vcod_instrum,0,vinteres,vinteres,
                    0,0," ",vcapital,"0000");
        end if

        -- // REGISTRA MOVIMIENTO DE ISR
        if vimpisr > 0 then
            let vhora = current hour to fraction(3);
            insert into bdicheq:sc_movinver
            values(pempresa,"C",vsucursal,vctaaboint,vimpisr,
                    vmoneda, "N",vgfecha_hoy,"3278",vcuenta,
                    vgusuario,"000",vgprox_fecha,"");

            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vfechapli,vhora,vtrans_isr,vsucursal,vcuenta,
                    vsecuencia,vcod_instrum,0,vimpisr,vimpisr,
                    0,0," ",vcapital,"0000");

            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vfechapli,vhora,"0523",vsucursal,vcuenta,
                    vsecuencia,vcod_instrum,0,vimpisr,vimpisr,
                    0,0," ",vcapital,"0000");
        end if

        -- // REGISTRA MANTENIMIENTO VALOR DE INTERESES
        if vmtovalint > 0 then
            let vhora = current hour to fraction(3);
            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vfechapli,vhora,"5002",vsucursal,vcuenta,
                    vsecuencia,vcod_instrum,0,vmtovalint,vmtovalint,
                    0,0," ",vcapital,"0000");
        end if

        -- // REGISTRA MOVIMIENTO DE RETIRO DE INTERES
        let vinteres = vinteres + vmtovalint;
        -- let vinteresneto = vinteres - vimpisr;

        if vinteresneto > 0 then
            let vhora = current hour to fraction(3);
            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vfechapli,vhora,vtran_ret,vsucursal,vcuenta,
                    vsecuencia,vcod_instrum,0,vinteresneto,vinteresneto,
                    0,0," ",vcapital,"0000");

            -- ***************************************************************
            -- * GENERA MOVTO DE PROVISION POR VENCIMIENTO SI ES MENSUAL AXL *
            -- ***************************************************************
            IF vprovision_int = "M" THEN
                SELECT vinteres - importe 
                  INTO vinteresneto
                  FROM sv_maeinstrucc
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta
                   AND cap_int = "I";

                IF vinteresneto > 0 THEN
                    LET vprovmes = vprovmes + vinteresneto;
                ELSE
                    LET vprovmes = vprovmes - vinteresneto;
                END IF
                
                IF vprovmes > 0 THEN
                    INSERT INTO sv_movdia
                    VALUES (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                            vgfecha_hoy,vhora,vtrans_prov,vsucursal,vcuenta,
                            vsecuencia, vcod_instrum,vdiasmact,vprovmes,
                            vprovmes,0,0, "",vcapital,"0000");
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
            ----------
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

        { *********************************
        if vinstcap = "01" then
            let vfechapli = vgfecha_hoy;
        else
            let vfechapli = vgprox_fecha;
        end if
        ********************************** }

        select {+INDEX(sv_instrucc ix137_1)} trans_cap
          into vtran_ret
          from sv_instrucc
         where codigo = vinstcap;

        -- // REGISTRA MOVIMIENTO DE CANCELACION DE PASIVO
        let vhora = current hour to fraction(3);

        if vtrans_vtopas2 <> "" and vtrans_vtopas2 is not null then
            insert into sv_movdia
            values(pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vfechapli,vhora,vtrans_vtopas2,vsucursal,
                    vcuenta,vsecuencia,vcod_instrum,0,vtotal,vtotal,
                    0,0," ",vtotal,"0000");
        end if

        -- // REGISTRA MOVIMIENTO DEL RETIRO POR CANCELACION
        let vhora = current hour to fraction(3);

        insert into sv_movdia
        values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                vfechapli,vhora,vtran_ret,vsucursal,
                vcuenta,vsecuencia,vcod_instrum,0,vtotal,vtotal,0,
                0," ",vcapital,"0000");

        -- // INICIALIZA IMPORTE POR PAGAR
        update sv_maeinstrucc
           set importe = 0,
               aplicado = "S"
         where empresa = pempresa
           and cuenta = vcuenta
           and cap_int = "C";

        if vinstcap <> "00" then
            -- if vsistemac = "01" then

            -- // PROCESA TRASPASO A CHEQUES
            insert into bdicheq:sc_movinver
            values(pempresa,"A",vsucursal,vctaabocap,vtotal,
                    vmoneda, "N",vgfecha_hoy,"0206",vcuenta,
                    vgusuario,"000",vgprox_fecha,"");

            { **************************************************************
            else
            call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vgusuario,
            vtotal,vcuenta) returning vcodret,vmensaje,vsolbcos;
            end if
            ************************************************************** }
        END IF
    END IF

    -- *************************************
    -- * GENERA REINVERSION AUTOMATICA AXL *
    -- *************************************
    IF vaplicado ="S" AND vfecha_venc = vgfecha_hoy AND (vinstcap ="01" OR vinstint ="01") THEN
        let vtotal = vtotalreinv;

        CALL bdicheq:cargo_ref(pempresa, vsucursal, vpromotor, "0235",
                                "0000", vfoliosuc, vctaabocap, 0,
                                vtotal, "01", "", "", "")
        RETURNING vcodret, vpaso, vpaso, vpaso, vpaso;

        IF vcodret <> "000" THEN
            -- IF vcodret = "400" THEN
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

            -- LET vcodret = "000";
            -- CONTINUE FOREACH;
            -- END IF
            -- IF vcodret <> "400" THEN

            INSERT INTO sv_valcierre VALUES(pempresa, vcuenta, 1, vcodret);

            LET vcodret = "000";

            CONTINUE FOREACH;

            -- END IF
        END IF

        select pzo_inicial into vplazo_nva
          from sv_dias
         where empresa = pempresa
           and cuenta = vcuenta;

        if vplazo_nva is null or vplazo_nva = 0 then
            let vplazo_nva = vplazo;
        end if

        let vfecha_nva = vgfecha_hoy + vplazo_nva;
        let vctanva = vcuenta;
        let vsecnva = vsecuencia + 1;

        -- // SE CAMBIA POR UPDATE LALO 05MZO09
        { *********************************************
        delete from sv_maeinstrucc
        where empresa = pempresa and cuenta = vcuenta;
        ********************************************** }

        -- // REAPERTURA LA CUENTA
        call apertura(pempresa,vnum_cte,vsecnva,vcod_instrum,vpromotor,"001",
                        vsucursal,vplaza,"1","0"," ","N"," ",vplazo_nva,
                        vfecha_nva,vtotal,vper_acred_int," ",vgusuario,"1",
                        vcta_cheques,vctanva,0,vdirecc_envio,vcobraisr)

        returning vcodret,vctanva,vplazo_nva,vfecha_nva,visr_nvo,
                    vintnet_nva,vtasa_nva,vtasaisr_nva,vtasaneta_nva;

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
        insert into sv_movdia
        values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                vgfecha_hoy,vhora,vtrans_reinv,vsucursal,
                vctanva,vsecnva,vcod_instrum,0,vtotal,vtotal,0,
                0," ",vtotal,"0000");

        -- // REGISTRA ENTRADA DEL PASIVO
        let vhora = current hour to fraction(3);
        if vtrans_vtopas1 <> "" and vtrans_vtopas1 is not null then
            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vgfecha_hoy,vhora,vtrans_vtopas1,vsucursal,
                    vctanva,vsecnva,vcod_instrum,0,vtotal,vtotal,
                    0,0," ",vtotal,"0000");
        end if

        -- // RECALCULA MONTOS EN INSTRUCCIONES AL VENCIMIENTO

        -- // SE CAMBIA POR UPDATE LALO 05MZO09

        { ************************************************************
        insert into sv_maeinstrucc
        values(pempresa,vctanva,"C",1,vinstcap,vtotal,vsistemac,
        vctaabocap, "N",vfecha_nva,1);
        ************************************************************* }

        update sv_maeinstrucc
           set (importe,aplicado,fecha_venc) = (vtotal,"N",vfecha_nva)
         where empresa  = pempresa
           and cuenta   = vctanva
           and cap_int  = "C";

        { ************************************************************
        insert into sv_maeinstrucc
        values(pempresa,vctanva,"I",1,vinstint,0,vsistemai,
        vctaaboint,"N",vfecha_nva,1);
        ************************************************************* }

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
        let vhora = current hour to fraction(3);

        if vprovision > 0 then
            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vgfecha_hoy,vhora,vtrans_prov,vsucursal,
                    vctanva,vsecnva,vcod_instrum,vdiasmact,vprovision,
                    vprovision,0,0," ",vtotal,"0000");
        end if

        update sv_maeinv
           set sdo_ult_corte = vprovision
         where empresa = pempresa
           and cuenta = vctanva
           and secuencia = vsecnva;

        -- // REGISTRA PROVISION DEL MES SIGUIENTE
        let vprovision = 0;

        if vdiasmsig > 0 then
            let vprovision = vprovdia * vdiasmsig;
            let vhora = current hour to fraction;

            insert into sv_movdia
            values (pempresa,0,vfoliosuc,vplaza,vsucursal,vgusuario,
                    vgprox_fecha,vhora,vtrans_prov,vsucursal,
                    vctanva,vsecnva,vcod_instrum,vdiasmsig,vprovision,
                    vprovision,0,0," ",vtotal,"0000");
        end if

        update sv_maeinv
           set sdo_ult_corte = sdo_ult_corte + vprovision
         where empresa = pempresa
           and cuenta = vctanva
           and secuencia = vsecnva;

        -- // ACTUALIZA ACUMULADO DE INTERESES
        let vinteres = vprovdia * (vdiasmact + vdiasmsig);

        update sv_maeinstrucc
           set importe = importe + vinteres
         where empresa = pempresa
           and cuenta  = vctanva
           and cap_int = "I"
           and aplicado <> "S";
        -- end if AXL
    end if
end foreach

if vcodret = "00000" then
    let vcodret = "000";
end if

if vcodret = "000" then
    -- // LLAMADO AL SPL QUE LLENA LAS TABLAS SV_PROVDIA Y SV_PROVMES
    CALL prov_diames(pempresa) RETURNING vcodret;

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

    update {+INDEX(sv_contproc idx_contproc)} sv_contproc
       set fecha = vgfecha_hoy
     where proceso = "cierreinv";

    UPDATE bdinteg:sx_contproc
       SET status_proc = 'F',
           hora_fin    = CURRENT,
           codret      = vcodret
     WHERE empresa = pEmpresa
       AND proceso  = 'CierreInv'
       AND fecha    = vgfecha_hoy;
end if

return vcodret;

end

end procedure;