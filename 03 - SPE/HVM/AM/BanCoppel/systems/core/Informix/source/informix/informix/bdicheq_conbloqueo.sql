create procedure "informix".conbloqueo(pempresa char(3),
                                       pcuenta  char(20),
                                       pultreg  smallint)
returning char(5),char(2),money(14,2),char(8),date,char(5);

    define vcodret       char(5);
    define vsqlerr       integer;
    define vconreg       smallint;
    define vcodbloq      char(2);
    define vimporte      money(14,2);
    define vusuario      char(8);
    define vfechbloq     date;
    define vclave        char(5);
    define vstatus_cta   char(1);
    
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vcodbloq,vimporte,vusuario,vfechbloq,vclave;
        end if;
    end exception;

    let vcodret = "000";
    let vconreg = 0;
    let vcodbloq = " ";
    let vimporte = 0;
    let vusuario = " ";
    let vfechbloq = "";
    let vclave = " ";

    select status_cta 
      into vstatus_cta
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;
       
    if vstatus_cta is null then
        let vcodret = "100";
        return vcodret,vcodbloq,vimporte,vusuario,vfechbloq,vclave;
    end if;

    if vstatus_cta in('2','6','7') then
        let vcodret = "200";
        return vcodret,vcodbloq,vimporte,vusuario,vfechbloq,vclave;
    end if;

    foreach
        select motivo,importe,usuario,fecha,clave
          into vcodbloq,vimporte,vusuario,vfechbloq,vclave
          from sc_histbloq
         where empresa = pempresa 
           and cuenta = pcuenta 
           and tipo_mov = "B" and status_blo = "B"
        order by fecha
        
        let vconreg = vconreg + 1;
        
        if vconreg <= pultreg then
            continue foreach;
        end if
        
        return vcodret,vcodbloq,vimporte,vusuario,vfechbloq,vclave with resume;
    end foreach
    end
end procedure;