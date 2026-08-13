create procedure "informix".valida( pempresa char(3), pcuenta char(20) )
returning char(5), char(4), char(4);

    define vcodret char(5);
    define vstatus char(2);
    define vsucursal, vproducto char(4);
    define vcuenta char(20);
    
    let vcodret = "000";
    
    select cuenta, status_cta, sucursal, producto
      into vcuenta, vstatus, vsucursal, vproducto
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;
       
    if vcuenta is null or vcuenta = "0000000000" or vstatus in("2","6","7","8") or vstatus = "3" then
        let vcodret = "100";
        let vsucursal = " ";
        let vproducto = " ";
    end if;
    
    return vcodret, vsucursal, vproducto;
    
end procedure;