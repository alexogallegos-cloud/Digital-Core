create procedure "informix".fechas( pempresa char(3) )
returning char(5);

    define vcodret      char(5);
    define vcodret2     char(5);
    define vcodret3     char(50);
    define vsqlerr      integer;
    define visamerr     integer;
    define vdescerr     char(50);
    define vfecha_hoy   date;
    define vprox_fecha  date;
    define vcuenta      char(20);
    define vfecha_venc  date;
    define vplazo       smallint;
    
    let vcodret     = '000';
    let vcodret2    = '';
    let vcodret3    = '';
    let vsqlerr     = 0;
    let visamerr    = 0;
    let vdescerr    = '';
    let vfecha_hoy  = '';
    let vprox_fecha = '';
    let vcuenta     = '';
    let vfecha_venc = '';
    let vplazo      = 0;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/fechas_inv.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if;
    end exception;

    --- set debug file to "/resplogifx/conciliachq/fechas_inv.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    -- // OBTIENE FECHAS DEL SISTEMA DE INVERSIONES
    select fecha_hoy, prox_fecha
      into vfecha_hoy, vprox_fecha
      from sv_fechas
     where empresa = pempresa;
     
    -- // ACTUALIZA INDICADOR DE CIERRE FINALIZADO
    update sv_fechas
       set ind_cierre = '1'
     where empresa = pempresa;
    
    foreach
        select cuenta, fecha_venc, plazo
          into vcuenta, vfecha_venc, vplazo
          from sv_cambioplazo
          
        if vfecha_venc = vprox_fecha then
            update sv_maeinv
               set plazo = vplazo
             where empresa = pempresa
               and cuenta = vcuenta
               and status_cta = '1';
               
            update sv_dias
               set pzo_inicial = vplazo
             where cuenta = vcuenta;
        end if;      
        
        let vcuenta = '';
        let vfecha_venc = '';
        let vplazo = 0;
    end foreach;
    
    return vcodret;
    
    end;
    
end procedure;