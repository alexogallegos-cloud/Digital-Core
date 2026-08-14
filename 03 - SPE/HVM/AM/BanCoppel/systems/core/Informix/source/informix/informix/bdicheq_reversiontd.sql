create procedure "informix".reversiontd( pempresa     char(3),
                                         psucursal    char(4),
                                         pusuario     char(8),
                                         pfolsucori   char(16),
                                         ptiporev     char(1),
                                         pcuenta      char(20),
                                         ptransaccrev char(4) )
returning char(5);
    
    define vsqlerr,isam_err int;
    define vcodret char(5)  ;
    define vtipo_tran char(2);
    define vmontolib money(14,2);

    set isolation to dirty read;
    set lock mode to wait 3;

    begin

    on exception set vsqlerr
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            return vcodret;
        end if;
    end exception;

    let vcodret = "000";

    select tipo_tran 
      into vtipo_tran
      from bdinteg:si_transacc
     where empresa = pempresa 
       and numero = ptransaccrev;
       
    if vtipo_tran >= "20" and vtipo_tran <= "29" then
        select sum(monto_tot) 
          into vmontolib
          from sc_movdia
         where empresa = pempresa
           and cuenta = pcuenta 
           and folio_suc = pfolsucori 
           and cancelad <> "S";
           
        if vmontolib is null then
            let vmontolib = 0;
        end if;
        
        if vmontolib > 0 then
            update sc_movdia 
               set cancelad = "S"
             where empresa = pempresa
               and cuenta = pcuenta 
               and folio_suc = pfolsucori
               and cancelad <> "S";
               
            -- // Marca documento retenido
            update sc_docret 
               set cancelado = "S"
             where empresa = pempresa
               and cuenta = pcuenta 
               and folio_suc = pfolsucori 
               and cancelado = "P";
               
            if ( dbinfo('sqlca.sqlerrd2') > 0 ) then
                -- // Actualizacion del Maestro
                update sc_maechq 
                   set (sdo_retenido) = (sdo_retenido - vmontolib)
                 where cuenta = pcuenta;
            end if;
        end if;
    else
        call reversion_td(pempresa,psucursal,pusuario,pfolsucori,ptiporev)
        returning vcodret;
    end if;
    
    return vcodret;
    
    end;
    
end procedure;