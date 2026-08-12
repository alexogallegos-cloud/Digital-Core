create procedure "informix".cons_cuentas(pempresa char(3), pnum_cte char(20))
returning char(5),char(11),char(4),char(4),char(18);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_numcte char(9);
    define v_cuenta char(11);
    define v_producto char(4);
    define v_sucursal char(4);
    define v_cuenta_clabe char(18);

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret       = "000";
    let v_cuenta      = "";
    let v_numcte      = "";
    let v_cuenta      = "";
    let v_producto    = "";
    let v_sucursal    ="";
    let v_cuenta_clabe ="";

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
    
    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe;
        end if
    end exception;

    select numcte 
      into v_numcte 
      from bdinteg:si_cliente
     where numcte = pnum_cte;
     
    if v_numcte is null then
        let cod_ret = "104";
        return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe;
    end if

    foreach
        select cuenta, producto, sucursal, cuenta_clabe
          into v_cuenta, v_producto, v_sucursal, v_cuenta_clabe
          from sc_maechq
         where empresa = pempresa 
           and num_cte = pnum_cte 
           and status_cta not in('2','6','7')
        order by cuenta

        return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe WITH RESUME;
    end foreach
    
    end
    
end procedure;