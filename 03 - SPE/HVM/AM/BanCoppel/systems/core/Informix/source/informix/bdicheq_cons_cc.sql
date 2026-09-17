create procedure "informix".cons_cc(pempresa char(3), pcuenta char(20))
returning char(5),date,datetime hour to fraction(3),char(20),char(2),
          char(40),char(2),char(3),char(2),char(1),char(10),date,date,
          money(14,2),money(14,2),smallint,money(14,2),
          smallint,money(14,2),money(14,2),money(14,2),
          money(14,2),money(14,2),money(14,2),money(14,2),char(1),
          money(14,2),money(14,2),date,
          money(14,2),money(14,2),date,
          money(14,2),money(14,2),date;

    define cod_ret char(5);
    define vfecha_hoy date;
    define vhora datetime hour to fraction(3);
    define vcuenta,tcuenta,var_cta char(20);
    define vsistema char(2);
    define vnombre char(40);
    define vpersonalidad char(2);
    define vaplicacion char(3);
    define vmoneda char(2);
    define v_long_cta char(2);
    define ves_fisica,venvio char(1);
    define vstatus_cta char(10);
    define vfecha_apert,vfecha_ultmov date;
    define vint_pend,vcom_pend money(14,2);
    define vchq_dev1,vchq_dev2,longitud smallint;
    define vmto_dev1,vmto_dev2 money(14,2);
    define vsdo_prom1,vsdo_prom2,vsdo_prom3,vsdo_prom4,vsdo_prom5,
    vsdo_prom6 money(14,2);
    define vlinea_ccc_imp,vlinea_rem_imp,vlinea_sbc_imp money(14,2);
    define vlinea_ccc_monto,vlinea_rem_monto,vlinea_sbc_monto money(14,2);
    define vlinea_ccc_disp, vlinea_rem_disp, vlinea_sbc_disp  money(14,2);
    define vlinea_ccc_vig,  vlinea_rem_vig,  vlinea_sbc_vig date;
    define tstatus_cta,vtipo_linea char(1);
    define tnum_cte char(20);
    define tnombre1,tnombre2,tapell_paterno,tapell_materno char(15);
    define trazon_soc char(30);
    define tplaza char(3);
    define tsucursal char(4);
    define v_cal_int_chq char(1);
    define timp_int_ccc money(14,2);
    define timp_sbg_ccc,timp_chq_rem,timp_chq_sbc money(14,2);
    define timpor_dev,tacum_pos money(14,2);
    define tnum_dev,i,tdias_pos smallint;
    define tfecha,tfechar,var_fec datetime year to month;
    define sql_err integer;

    -- ****************************************************************************
    -- Inicializa variables
    -- ****************************************************************************
    let cod_ret          = "000";
    let vfecha_hoy       = "";
    let vhora            = "";
    let vcuenta          = "";
    let vsistema         = "00";
    let vnombre          = "";
    let vpersonalidad    = "";
    let vaplicacion      = "";
    let vmoneda          = "";
    let venvio           = "";
    let vstatus_cta      = "";
    let vfecha_apert     = "";
    let vfecha_ultmov    = "";
    let vint_pend        = 0;
    let vcom_pend        = 0;
    let vchq_dev1        = 0;
    let vmto_dev1        = 0;
    let vchq_dev2        = 0;
    let vmto_dev2        = 0;
    let vsdo_prom1       = 0;
    let vsdo_prom2       = 0;
    let vsdo_prom3       = 0;
    let vsdo_prom4       = 0;
    let vsdo_prom5       = 0;
    let vsdo_prom6       = 0;
    let vlinea_ccc_monto = 0;
    let vlinea_rem_monto = 0;
    let vlinea_sbc_monto = 0;
    let vlinea_ccc_disp  = 0;
    let vlinea_rem_disp  = 0;
    let vlinea_sbc_disp  = 0;
    let vlinea_ccc_vig   = "";
    let vlinea_rem_vig   = "";
    let vlinea_sbc_vig   = "";
    let vlinea_ccc_imp   = 0;
    let vlinea_rem_imp   = 0;
    let vlinea_sbc_imp   = 0;
    let var_cta          = "";
    let var_fec          = "";
    let vtipo_linea      = " ";

    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,vfecha_hoy,vhora,vcuenta,vsistema,vnombre,vpersonalidad,
            vaplicacion,vmoneda,venvio,vstatus_cta,vfecha_apert,
            vfecha_ultmov,vint_pend,vcom_pend,vchq_dev1,vmto_dev1,vchq_dev2,
            vmto_dev2,vsdo_prom1,vsdo_prom2,vsdo_prom3,vsdo_prom4,
            vsdo_prom5,vsdo_prom6,vtipo_linea,vlinea_ccc_monto,
            vlinea_ccc_disp,vlinea_ccc_vig,vlinea_rem_monto,vlinea_rem_disp,
            vlinea_rem_vig,vlinea_sbc_monto,vlinea_sbc_disp,vlinea_sbc_vig;
        end if;
    end exception;

    select sistema 
      into vsistema 
      from bdinteg:si_sistema
     where siglas = "SC";

    -- ****************************************************************************
    -- Valida exista la Cuenta de Cheques y extrae informacion necesaria
    -- ****************************************************************************
    select mc.cuenta,mc.sucursal,mc.plaza,num_cte,producto,envio_direcc,
           status_cta,fecha_alta,imp_int_ccc + imp_int_sbg,com_pendiente,
           lim_sbg_ccc,imp_sbg_ccc + imp_chq_sbg,fech_venc_ccc,
           lim_chq_rem,imp_chq_rem,fech_venc_rem,
           lim_chq_sbc,imp_chq_sbc,fech_venc_sbc,fec_ult_mov,
           tipo_linea
      into vcuenta,tsucursal,tplaza,tnum_cte,vaplicacion,venvio,tstatus_cta,
           vfecha_apert,timp_int_ccc,vcom_pend,vlinea_ccc_monto,
           vlinea_ccc_imp,vlinea_ccc_vig,vlinea_rem_monto,vlinea_rem_imp,
           vlinea_rem_vig,vlinea_sbc_monto,vlinea_sbc_imp,vlinea_sbc_vig,
           vfecha_ultmov,vtipo_linea
      from sc_maechq mc,
           sc_maenoc mn
     where mc.empresa = pempresa 
       and mc.cuenta = pcuenta
       and mc.empresa = mn.empresa 
       and mn.cuenta = mc.cuenta;

    if vcuenta is null then
        let cod_ret = "100";
        return cod_ret,vfecha_hoy,vhora,vcuenta,vsistema,vnombre,vpersonalidad,
        vaplicacion,vmoneda,venvio,vstatus_cta,vfecha_apert,
        vfecha_ultmov,vint_pend,vcom_pend,vchq_dev1,vmto_dev1,vchq_dev2,
        vmto_dev2,vsdo_prom1,vsdo_prom2,vsdo_prom3,vsdo_prom4,
        vsdo_prom5,vsdo_prom6,vtipo_linea,vlinea_ccc_monto,
        vlinea_ccc_disp,vlinea_ccc_vig,vlinea_rem_monto,vlinea_rem_disp,
        vlinea_rem_vig,vlinea_sbc_monto,vlinea_sbc_disp,vlinea_sbc_vig;
    end if

    Select fecha_hoy 
      into vfecha_hoy 
      from sc_fechas 
     where empresa = pempresa;

    let vhora = current hour to fraction(3);

    -- ****************************************************************************
    -- Extrae el nombre del Cliente
    -- ****************************************************************************
    Select es_fisica,nombre1,nombre2,apell_paterno,apell_materno,razon_social
      into ves_fisica,tnombre1,tnombre2,tapell_paterno,tapell_materno,trazon_soc
      from bdinteg:si_cliente,
           bdinteg:si_tipper
     where bdinteg:si_cliente.numcte = tnum_cte 
       and bdinteg:si_cliente.tpo_persona = bdinteg:si_tipper.tpo_persona;
       
    if ves_fisica = "S" then
        let vnombre = trim(tapell_paterno)||" "||trim(tapell_materno)||" "||trim(tnombre1)||" "||trim(tnombre2);
    else
        let vnombre = trim(trazon_soc);
    end if

    -- ****************************************************************************
    -- Extrae el tipo de moneda y sistema de la aplicacion de la cuenta
    -- ****************************************************************************
    select divisa 
      into vmoneda
      from sc_producto
     where empresa = pempresa 
       and producto = vaplicacion;

    -- ****************************************************************************
    -- Define el status de la Cuenta
    -- ****************************************************************************
    if tstatus_cta = "1" then
        let vstatus_cta = "Activa";
    elif tstatus_cta = "2" then
        let vstatus_cta = "Cancelada";
    elif tstatus_cta = "3" then
        let vstatus_cta = "Bloqueada";
    elif tstatus_cta = "4" then
        let vstatus_cta = "Inactiva";
    elif tstatus_cta = "5" then
        let vstatus_cta = "Informada";
    elif tstatus_cta = "6" then
        let vstatus_cta = "Concentrada";
    elif tstatus_cta = "7" then
        let vstatus_cta = "Traspasada";
    elif tstatus_cta = "8" then
        let vstatus_cta = "DesConcentrada";
    end if

    -- ****************************************************************************
    -- Extrae los intereses pendientes
    -- ****************************************************************************
    let vint_pend = timp_int_ccc;

    -- ****************************************************************************
    -- Extrae los cheques devueltos y el saldo promedio
    -- ****************************************************************************
    let tfecha = vfecha_hoy;
    let i = 1;
    
    while i < 7
        let tfecha = tfecha - 1 units month;
        
        begin
        
        let tcuenta,tfechar,tacum_pos,tdias_pos,tnum_dev,timpor_dev = (select cuenta,fecha,acum_pos,dias_pos,num_dev,impor_dev
                                                                         from sc_salpro
                                                                        where empresa = pempresa 
                                                                          and cuenta = pcuenta 
                                                                          and fecha = tfecha);
                                                                          
        end
        
        if pcuenta = var_cta and tfechar = var_fec then
            let tnum_dev   = 0;
            let timpor_dev = 0;
            let tacum_pos  = 0;
        end if
        
        if i = 1 then
            let vchq_dev1  = tnum_dev;
            let vmto_dev1  = timpor_dev;
            
            if tacum_pos > 0 then
                let vsdo_prom1 = tacum_pos/tdias_pos;
            else
                let vsdo_prom1 = 0;
            end if
        elif i = 2 then
            let vchq_dev2  = tnum_dev;
            let vmto_dev2  = timpor_dev;
            
            if tacum_pos > 0 then
                let vsdo_prom2 = tacum_pos/tdias_pos;
            else
                let vsdo_prom2 = 0;
            end if
        elif i = 3 then
            if tacum_pos > 0 then
                let vsdo_prom3 = tacum_pos/tdias_pos;
            else
                let vsdo_prom3 = 0;
            end if
        elif i = 4 then
            if tacum_pos > 0 then
                let vsdo_prom4 = tacum_pos/tdias_pos;
            else
                let vsdo_prom4 = 0;
            end if
        elif i = 5 then
            if tacum_pos > 0 then
                let vsdo_prom5 = tacum_pos/tdias_pos;
            else
                let vsdo_prom5 = 0;
            end if
        elif i = 6 then
            if tacum_pos > 0 then
                let vsdo_prom6 = tacum_pos/tdias_pos;
            else
                let vsdo_prom6 = 0;
            end if
        end if
        
        let i = i + 1;
        let var_cta = tcuenta;
        let var_fec = tfechar;
    end while

    -- ****************************************************************************
    -- Extrae monto disponible de la linea 1305 / 1505
    -- ****************************************************************************
    let vlinea_ccc_disp = vlinea_ccc_monto - vlinea_ccc_imp;
    
    if vlinea_ccc_disp < 0 then
        let vlinea_ccc_monto = vlinea_ccc_imp;
        let vlinea_ccc_disp = 0;
    end if

    -- ****************************************************************************
    -- Extrae monto disponible de la linea de remesas
    -- ****************************************************************************
    let vlinea_rem_disp = vlinea_rem_monto - vlinea_rem_imp;
    
    if vlinea_rem_disp < 0 then
        let vlinea_rem_disp = 0;
    end if

    -- ****************************************************************************
    -- Extrae monto disponible de la linea de sbc
    -- ****************************************************************************
    let vlinea_sbc_disp = vlinea_sbc_monto - vlinea_sbc_imp;

    -- ****************************************************************************
    -- Verifica no enviar nulos como respuesta
    -- ****************************************************************************
    if vchq_dev1 is null then
        let vchq_dev1 = 0;
    end if
    
    if vmto_dev1 is null then
        let vmto_dev1 = 0;
    end if
    
    if vchq_dev2 is null then
        let vchq_dev2 = 0;
    end if
    
    if vmto_dev2 is null then
        let vmto_dev2 = 0;
    end if
    
    if vsdo_prom1 is null then
        let vsdo_prom1 = 0;
    end if
    
    if vsdo_prom2 is null then
        let vsdo_prom2 = 0;
    end if
    
    if vsdo_prom3 is null then
        let vsdo_prom3 = 0;
    end if
    
    if vsdo_prom4 is null then
        let vsdo_prom4 = 0;
    end if
    
    if vsdo_prom5 is null then
        let vsdo_prom5 = 0;
    end if
    
    if vsdo_prom6 is null then
        let vsdo_prom6 = 0;
    end if

    return cod_ret,vfecha_hoy,vhora,vcuenta,vsistema,vnombre,vpersonalidad,
           vaplicacion,vmoneda,venvio,vstatus_cta,vfecha_apert,
           vfecha_ultmov,vint_pend,vcom_pend,vchq_dev1,vmto_dev1,vchq_dev2,
           vmto_dev2,vsdo_prom1,vsdo_prom2,vsdo_prom3,vsdo_prom4,
           vsdo_prom5,vsdo_prom6,vtipo_linea,vlinea_ccc_monto,
           vlinea_ccc_disp,vlinea_ccc_vig,vlinea_rem_monto,vlinea_rem_disp,
           vlinea_rem_vig,vlinea_sbc_monto,vlinea_sbc_disp,vlinea_sbc_vig;

    end

end procedure;