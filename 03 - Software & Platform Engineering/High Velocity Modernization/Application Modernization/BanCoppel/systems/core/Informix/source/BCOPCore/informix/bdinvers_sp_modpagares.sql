create procedure "informix".sp_modpagares(pempresa char(3))
returning char(5);

    define vcodret      char(5);
    define vcodret2     char(5);
    define vcodret3     char(50);
    define vsqlerr      integer;
    define visamerr     integer;
    define vdescerr     char(50);
    define vfecha_hoy   date;
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
    let vcuenta     = '';
    let vfecha_venc = '';
    let vplazo      = 0;

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/sp_modpagares.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if;
    end exception;

    --- set debug file to "/resplogifx/conciliachq/sp_modpagares.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy
      into vfecha_hoy
      from sv_fechas
     where empresa = '001';
    
    foreach
        select pla.cuenta
          into vcuenta
          from sv_cambioplazo pla,
               sv_maeinv inv
         where pla.cuenta = inv.cuenta
           and pla.fecha_venc <= '05/23/2013'
           and inv.status_cta = '1'
           
        select fecha_venc
          into vfecha_venc
          from sv_maeinv
         where empresa = '001'
           and cuenta = vcuenta
           and status_cta = '1';
          
        update sv_cambioplazo
           set fecha_venc = vfecha_venc
         where cuenta = vcuenta;
               
        let vcuenta = '';
        let vfecha_venc = '';
    end foreach;
    
    foreach
        select cuenta, plazo
          into vcuenta, vplazo
          from sv_cambioplazo
         where fecha_venc = vfecha_hoy
           
        update sv_dias
           set pzo_inicial = vplazo
         where cuenta = vcuenta;
               
        let vcuenta = '';
        let vplazo = '';
    end foreach;
    
    return vcodret;
    
    end;
    
end procedure;