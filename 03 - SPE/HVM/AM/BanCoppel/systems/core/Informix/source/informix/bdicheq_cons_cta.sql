create procedure "informix".cons_cta(pempresa char(3),
                                     pcuenta char(20),
                                     pmoneda char(02))
returning char(5);

    define w_codret    char(5);
    define w_cuenta    char(20);
    define w_statuscta char(1);
    define w_moneda    char(2);
    define sql_err     integer;

    --- Inicializa Variables de Salida
    let w_codret    = "000";
    
    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let w_codret = sql_err;
            return w_codret;
        end if
    end exception;

    --- Valida que la Cuenta o la moneda no sea Blanco
    if pcuenta = " " or pcuenta is null or pmoneda = " " or pmoneda is null then
        let w_codret = "110";
        return w_codret;
    end if

    ---- Valida que Exista la Cuenta de Cheques
    select status_cta,divisa 
      into w_statuscta, w_moneda
      from sc_maechq mc, 
           sc_producto pr
     where mc.empresa = pempresa 
       and cuenta = pcuenta 
       and mc.empresa = pr.empresa 
       and mc.producto = pr.producto;
    
    if w_statuscta is null then
        let w_codret = "100";
        return w_codret;
    end if

    if w_statuscta in("2","6","7") then
        let w_codret = "200";
        return w_codret;
    end if

    if w_statuscta = "3" then
        let w_codret = "300";
        return w_codret;
    end if

    if w_moneda <> pmoneda then
        let w_codret = "905";
        return w_codret;
    end if

    return w_codret;
    
    end
    
end procedure;