create procedure "informix".fechas( pempresa char(3) )
returning char(5);

    define vcodret      char(5);
    define vcodret2     char(5);
    define vcodret3     char(50);
    define vsqlerr      integer;
    define visamerr     integer;
    define vdescerr     char(50);
    
    let vcodret     = '000';
    let vcodret2    = '';
    let vcodret3    = '';
    let vsqlerr     = 0;
    let visamerr    = 0;
    let vdescerr    = '';

    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/tmp/fechas_int.out";
        trace on;
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if;
    end exception;

    --- set debug file to "/resplogifx/conciliachq/fechasinv.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    -- // ACTUALIZA INDICADOR DE CIERRE FINALIZADO
    update si_fechas
       set fecha_insert = current
     where empresa = pempresa;
    
    return vcodret;
    
    end;
    
end procedure;