create procedure "informix".sp_cargo_val(pcuenta char(20))
returning char(5);
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vfecha_hoy       date;
    define vfecha_ant       date;
    define vfecha_proceso   date;
    define vstatus_cta      char(1);
    define vretiros         money(14,2);
    define vabonos          money(14,2);
    define vsdoactual       money(14,2);
    define vsdoinicial      money(14,2);
    define vsdoretenido     money(14,2);
    define vsdodisp         money(14,2);
    define vsdocalculado    money(14,2);
    define vdiferencia      money(14,2);
    define vreferencia      char(40);
    define vcuantos         smallint;
    define vproducto        char(4);
    define vcodretblq       char(5);
    define vclaveblq        char(5);
    define vstatus          char(1);
    
    let vcodret         = '00000';
    let vcodret2        = '';
    let vcodret3        = '';
    let vsqlerr         = 0;
    let visamerr        = 0;
    let vdescerr        = '';
    let vfecha_hoy      = '';
    let vfecha_ant      = '';
    let vfecha_proceso  = '';
    let vstatus_cta     = '';
    let vretiros 		= 0.00;
    let vabonos         = 0.00;
    let vsdoactual      = 0.00;
    let vsdoinicial     = 0.00;
    let vsdoretenido    = 0.00;
    let vsdodisp        = 0.00;
    let vsdocalculado   = 0.00;
    let vdiferencia     = 0.00;
    let vreferencia     = '';
    let vcuantos        = 0;
    let vproducto       = '';
    let vcodretblq      = '';
    let vclaveblq       = '';
    let vstatus         = '';
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/sp_cargo_val.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/sp_cargo_val.out";
    --- trace on;
    
    --- set isolation to cursor stability;
    set isolation to dirty read;
    set lock mode to wait 3;

    --let vcodret = '00000';
    --return vcodret;	
    
    -- // VALIDA EL PARAMETRO DE ENTRADA
    if pcuenta = '' then
        let vcodret = '110';
        return vcodret;
    end if;
	
    -- // VALIDA CUENTAS EXCLUIDAS
    if pcuenta in('16000000080','16000000322','16000000012','99010000020', '16000000063') or 
       pcuenta in('10014594944','10029763610','10096982955','10101302909','10112587964','10121425535','10152230708','10290633686','10331870680',
                  '10349349235','13005759646','10426086994','10426817026','10430000557','10441560350','10442816048','10449170151','10449445150', '12000000823',
                  '12000002591', '16000000160', '16000000250', '22000002384', '99000000287', '99000000295', '99000000309', '99000000325', '99000000376',
                  '99000000449', '99000000457', '99000000465', '99000000473', '99000000481', '99000000490', '99000000520', '99010000030', '99010000048', 
                  '99010000056', '99010000064', '99010000080', '99010000110', '27000000138', '16000001531', '27000000103', '27000000111', '27000000146',
                  '27000000162', '27000000154', '27000000170','12000000114') then
        let vcodret = '00000';
        return vcodret;
    end if;

    -- // OBTIENE LAS FECHAS DEL SISTEMA
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant
      from sc_fechas
     where empresa = '001';
    
    -- // OBTIENE DATOS DE LA CUENTA
    select sdo_dia_ant, sdo_actual, sdo_retenido, status_cta, fecha_proceso, producto 
      into vsdoinicial, vsdoactual, vsdoretenido, vstatus_cta, vfecha_proceso, vproducto
      from sc_maechq
     where cuenta = pcuenta;
    
    /* ----------------------------
    if vproducto = '2900' then
        let vcodret = '00000';
        return vcodret;
    end if;	
    ---------------------------- */
	
	    -- // VALIDA CUENTAS ESPECIAL	
	if pcuenta = '10057557465' then
		insert into sc_cuentas_retiro 
            ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
            values
            ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
        let vcodret = '00000';
        return vcodret;	
	end if;
    
    -- // VALIDA LOS ESTATUS DE LA CUENTA
    if vstatus_cta IN('2','6') then
        let vcodret = '00000';
        return vcodret;
    end if; 
    
    if vstatus_cta in('1','3','5') then
        if vfecha_proceso is null or vfecha_proceso = "" then
            let vfecha_hoy = vfecha_hoy;
        else
            let vfecha_hoy = vfecha_proceso;
        end if;
    end if;
    
    -- // VALIDA ESTATUS DE LA CUENTA EN TABLA DE CONTROL
    select nvl(estatus,'')
      into vstatus
      from sc_cuentas_retiro
     where cuenta = pcuenta
       and fecha = vfecha_hoy;
       
    if vstatus = 'A' then
        let vcodret = '110';
        return vcodret;
    elif vstatus = 'R' then
        let vcodret = '00000';
        return vcodret;
    end if;
    
    -- // VALIDA QUE LA CUENTA NO ESTE INACTIVA
    select nvl(count(*),0)
      into vcuantos
      from sc_movdia
     where transacc in('0415','0416','3232')
       and cancelad <> 'S'
       and cuenta = pcuenta;
    
    if vcuantos > 0 then
        let vcodret = '00000';
        return vcodret;
    end if;   
    
    -- // OBTIENE EL MONTO DE CARGOS
    select nvl(sum(mov.monto_tot),0) 
      into vretiros
      from sc_movdia mov, 
           bdinteg:si_transacc trx
     where mov.cuenta = pcuenta
       and trx.naturaleza = 'C'
       and trx.se_contabiliza = 'S'
    ---and trx.se_emite_edocta = 'S'
       and mov.transacc = trx.numero
       and trx.sistema = '01'
       and mov.fech_alt = vfecha_hoy
       and mov.cancelad <> 'S'
       and mov.transacc <> '0232';
    
    -- // OBTIENE EL MONTO DE DEPOSITOS
    select nvl(sum(mov.monto_tot),0) 
      into vabonos
      from sc_movdia mov, 
           bdinteg:si_transacc trx
     where mov.cuenta = pcuenta
       and trx.naturaleza = 'A'
       and trx.se_contabiliza = 'S'
    ---and trx.se_emite_edocta = 'S'
       and mov.transacc = trx.numero
       and trx.sistema = '01'
       and mov.fech_alt = vfecha_hoy
       and mov.cancelad <> 'S';   
    
    -- // REALIZA LA CONCILIACION DE SALDOS DE LA CUENTA
    --- let vsdodisp = vsdoactual - vsdoretenido;
    let vsdodisp = vsdoactual;
    let vsdocalculado = vsdoinicial + vabonos - vretiros;
    
    if pcuenta in('22000001574', '99010000030') then
        let vdiferencia = vsdodisp - vsdocalculado;
        
        if vdiferencia < 0.00 then
            let vdiferencia = vdiferencia * -1;
        end if;
        
        if vdiferencia > 100000.00 then
            let vcodret = '110';
            
            insert into sc_cuentas_retiro 
            ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
            values
            ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
            
            execute procedure bloqueo_cta( '001', pcuenta, 0.00, '09', 3, vfecha_hoy, 'informix', '', '09', 'L', '02', 'C' )
            into vcodretblq, vclaveblq;
        else
            let vcodret = '00000';
        end if;
    else
        if vsdocalculado <> vsdodisp then
            let vcodret = '110';
            
            insert into sc_cuentas_retiro 
            ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
            values
            ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
            
            execute procedure bloqueo_cta( '001', pcuenta, 0.00, '09', 3, vfecha_hoy, 'informix', '', '09', 'L', '02', 'C' )
            into vcodretblq, vclaveblq;
        else
            let vcodret = '00000';
        end if;
    end if;
    
    -- // VALIDA DEPOSITOS SPEI
    select nvl(referencia,''), nvl(count(*),0)
      into vreferencia, vcuantos
      from sc_movdia
     where transacc = '0273'
       and cancelad <> 'S'
       and cuenta = pcuenta
     group by 1
    having count(*) > 1;
    
    if vcuantos > 1 then
        let vcodret = '110';
        
        insert into sc_cuentas_retiro 
        ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
        values
        ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
        
        execute procedure bloqueo_cta( '001', pcuenta, 0.00, '09', 3, vfecha_hoy, 'informix', '', '09', 'L', '02', 'C' )
        into vcodretblq, vclaveblq;
    end if;
    
    return vcodret;
    
    end;
    
end procedure;