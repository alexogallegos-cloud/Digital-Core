create procedure "informix".envio_corres(pempresa char(3),
                                         i_cuenta  char(20),
                                         i_cliente char(20),
                                         cual smallint)
returning char(5);

    define v_long_cta            smallint;
    define w_cod_ret             char(5);
    define w_cuenta              char(20);
    define w_edo_cta             char(1);
    define existe                smallint;

    --     SET DEBUG FILE TO "/tmp/envio_corres.out";
    --     TRACE ON;


    --- Inicializa Variables de Salida
    let w_cod_ret   = "000";
    let existe = 0;
    let w_cuenta    = "";
    let w_edo_cta   = "";

    --- Valida que la Cuenta no sea Blanco
    if i_cuenta = " " then
    let w_cod_ret = "110";
    return w_cod_ret;
    end if

    --- Valida que Exista la Cuenta de Cheques y Extrae los Siguientes Campos
    select num_cte,  status_cta
      into w_cuenta, w_edo_cta
      from sc_maechq
     where empresa = pempresa 
       and cuenta = i_cuenta;
       
    if w_cuenta is null then
        let w_cod_ret = "100";
        return w_cod_ret;
    end if
    
    if w_edo_cta in("2","6","7","8") then
        let w_cod_ret = "200";
        return w_cod_ret;
    end if;
    
    if w_cuenta != i_cliente then
        let w_cod_ret = "122";
        return w_cod_ret;
    end if;
    
    if cual > 0 then
        select secuencia 
          into existe
          from bdinteg:si_direcciones
         where numcte = i_cliente
           and secuencia = cual;
        
        if existe is null or existe = 0 then
            let w_cod_ret = "130";
            return w_cod_ret;
        end if;
        
        update sc_maechq
           set direcc_envio = cual
         where empresa = pempresa 
           and cuenta = i_cuenta;
    end if;
    
    return w_cod_ret;
    
end procedure;