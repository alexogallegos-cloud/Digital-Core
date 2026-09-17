create procedure "informix".sp_cargo_val_pba(pcuenta    char(20))
    returning char(5);

    define vcodret 		char(5);
    define vsqlerr 		integer;
    define vfecha_hoy    date;
    define vfecha_ant    date;
    define vfecha_proceso date;
    define vstatus_cta   char(1);
    define vretiros 		money(14,2);
    define vabonos		money(14,2);
    define vsdoactual	money(14,2);
    define vsdoinicial   money(14,2);
    define vsdoretenido  money(14,2);
    define vsdodisp      money(14,2);
    define vsdocalculado money(14,2);
    define vdiferencia   money(14,2);
    define vreferencia 	char(40);
    define vcuantos      smallint;
    define vproducto		char(4);

    set isolation to cursor stability;
    set lock mode to wait 10;

    let vcodret = "000";
    let vabonos = 0;
    let vretiros = 0;
    let vdiferencia = 0;

    begin

    on exception set vsqlerr
        set debug file to "/tmp/sp_cargo_val_pba.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if
    end exception;

    SET DEBUG FILE TO "/tmp/sp_cargo_val_pba.out";
    TRACE ON;

    -- // Valida la informacion de entrada
    if pcuenta = '' then
        let vcodret = 110;
        return vcodret;
    end if;

    set isolation to dirty read;

    if pcuenta in('16000000080','16000000322','16000000012') or 
       pcuenta in('10014594944','10029763610','10096982955','10101302909','10112587964','10121425535','10152230708','10290633686','10331870680',
                  '10349349235','13005759646','10426086994','10426817026','10430000557','10441560350','10442816048','10449170151','10449445150') then
        let vcodret = '00000';
        return vcodret;
    end if;
    
    -- // OBTIENE LAS FECHAS DEL SISTEMA
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant
      from sc_fechas;

    select sdo_dia_ant, sdo_actual, sdo_retenido, status_cta, fecha_proceso, producto 
      into vsdoinicial, vsdoactual, vsdoretenido, vstatus_cta, vfecha_proceso, vproducto
      from sc_maechq
     where cuenta = pcuenta;

    /* ############################
    if vproducto = '2900' then
        let vcodret = '00000';
        return vcodret;
    end if;	
    ############################ */

    if vstatus_cta IN('2', '6') then
        let vcodret = '00000';
        return vcodret;
    end if; 

    if vstatus_cta in('1', '3', '5') then
        if vfecha_proceso is null or vfecha_proceso = "" then
            let vfecha_hoy = vfecha_hoy;
        else
            let vfecha_hoy = vfecha_proceso;
        end if;
    end if;

    select nvl(count(*), 0)
      into vcuantos
      from sc_movdia
     where transacc in('0415', '0416', '3232')
       and cancelad <> 'S'
       and cuenta = pcuenta;

    if vcuantos > 0 then
        let vcodret = '00000';
        return vcodret;
    end if;   

    select nvl(sum(monto_tot), 0) into vretiros
      from sc_movdia, bdinteg:si_transacc
     where cuenta = pcuenta
       and naturaleza = 'C'
       and se_contabiliza = 'S'
    -- and se_emite_edocta = 'S'
       and transacc = numero
       and sistema = '01'
       and fech_alt = vfecha_hoy
       and cancelad <> 'S'
       and transacc <> '0232';

    select nvl(sum(monto_tot), 0) into vabonos
      from sc_movdia, bdinteg:si_transacc
     where cuenta = pcuenta
       and naturaleza = 'A'
       and se_contabiliza = 'S'
    -- and se_emite_edocta = 'S'
       and transacc = numero
       and sistema = '01'
       and fech_alt = vfecha_hoy
       and cancelad <> 'S';   

    -- let vsdodisp = vsdoactual - vsdoretenido;
    let vsdodisp = vsdoactual;
    let vsdocalculado = vsdoinicial + vabonos - vretiros;

    if pcuenta in('22000001574', '99010000030') then
        let vdiferencia = vsdodisp - vsdocalculado;
        
        if vdiferencia < 0.00 then
            let vdiferencia = vdiferencia * -1;
        end if;
        
        if vdiferencia > 100000.00 then
            let vcodret = 110;
            insert into sc_cuentas_retiro values(pcuenta, vfecha_hoy, vsdocalculado, vsdodisp);
        else
            let vcodret = '00000';
        end if;
    else
        if vsdocalculado <> vsdodisp then
            let vcodret = 110;
            insert into sc_cuentas_retiro values(pcuenta, vfecha_hoy, vsdocalculado, vsdodisp);
        else
            let vcodret = '00000';
        end if;
    end if;

    select nvl(referencia, ''), nvl(count(*), 0)
      into vreferencia, vcuantos
      from sc_movdia
     where transacc = '0273'
       and cancelad <> 'S'
       and cuenta = pcuenta
     group by 1
    having count(*) > 1;

    if vcuantos > 1 then
        let vcodret = 110;
        insert into sc_cuentas_retiro values(pcuenta, vfecha_hoy, vsdocalculado, vsdodisp);
    end if;

    return vcodret;

    end;

end procedure;