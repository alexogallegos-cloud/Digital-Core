create procedure "informix".valcteprod( pempresa char(3), pnumcte char(20), pproducto char(4) )
returning char(5);
    
    define vcodret      char(5);
    define vedad_minima smallint;
    define vedad_maxima smallint;
    define vedadcte     decimal(5,2);
    define vfecha_nac   date;
    define vfecha_hoy   date;
    define vexiste      char(1);
    define vtutor       char(60);
    
    let vcodret      = "000";
    let vedad_minima = 0;
    let vedad_maxima = 0;
    let vedadcte     = 0;
    let vfecha_nac   = '';
    let vfecha_hoy   = '';
    let vexiste      = '';
    let vtutor       = '';
    
    set isolation to dirty read;

    select edad_minima, edad_maxima 
      into vedad_minima, vedad_maxima
      from sc_producto
     where empresa = pempresa 
       and producto = pproducto;
    
    select fecha_hoy 
      into vfecha_hoy
      from sc_fechas 
     where empresa = pempresa;
    
    select 1 
      into vexiste
      from bdinteg:si_cliente
     where numcte = pnumcte;
    
    if vexiste is null then
        let vcodret = "104";
        return vcodret;
    end if
    
    select fecha_nac, tutor 
      into vfecha_nac, vtutor
      from bdinteg:si_ctepf
     where numcte = pnumcte;
    
    let vedadcte = (vfecha_hoy - vfecha_nac) / 365.22;

    if vedadcte < vedad_minima or vedadcte > vedad_maxima then
        if vtutor = "" then  
            let vcodret = "126";
        end if
    end if
    
    return vcodret;
    
end procedure;