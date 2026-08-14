create procedure "informix".sp_actualizadirecciones( pempresa char(3) )
returning char(5), integer, integer;
    
    define vcodret 		char(5);
    define vcodret2     char(5);
    define vcodret3     char(50);
    define vsqlerr 		integer;
    define visamerr		integer;
    define vdescerr	    char(50);
    define vtransacc    smallint;
    define vcontador1   integer;
    define vcontador2   integer;
    define vnumcte      char(20);
    
    let vcodret    = '000';
    let vcodret2   = '';
    let vcodret3   = '';
    let vsqlerr    = 0;
    let visamerr   = 0;
    let vdescerr   = '';
    let vtransacc  = 0;
    let vcontador1 = 0;
    let vcontador2 = 0;
    let vnumcte    = '';
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/sp_actualizadirecciones.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            if vtransacc = 1 then
                rollback work;
            end if;
            return vcodret, vcontador1, vcontador2;
        end if
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/sp_actualizadirecciones.out";
    --- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 5;
    
    select numcte, count(*) cuantos
      from si_direcciones_actual
     where tipo_dir = '1'
     group by 1
    having count(*) > 1
    into temp tmp_ctes with no log;
     
    foreach with hold
        select numcte
          into vnumcte
          from tmp_ctes
          
        begin work;
        let vtransacc = 1;
        let vcontador1 = vcontador1 + 1;
        
        delete from si_direcciones_actual
         where numcte = vnumcte
           and tipo_dir = '1'
           and secuencia = ( select min(secuencia) 
                               from si_direcciones_actual
                              where numcte = vnumcte
                                and tipo_dir = '1' );
                                
        if ( dbinfo('sqlca.sqlerrd2') > 0 ) then
            let vcontador2 = vcontador2 + 1;
        end if;
        
        commit work;
        let vtransacc = 0;
        
        let vnumcte = '';
    end foreach;
    
    return vcodret, vcontador1, vcontador2;
    
    end;
    
end procedure;