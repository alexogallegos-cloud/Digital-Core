create procedure "informix".cons_nomb(pempresa char(3),
                                      pcuenta char(20))
          returning char(5),char(60);
   define w_cod_ret   char(5);
   define w_cuenta    char(20);
   define w_num_cte   char(20);
   define w_razon_soc char(40);
   define w_nombre    char(60);
   define v_long_cta  char(2);
   define longitud    smallint;
   define w_esfisica  char(1);
   define sql_err     integer;

--- Inicializa Variables de Salida
   let w_cod_ret   = "000";
   let w_cuenta    = "";
   let w_razon_soc = "";
   let w_nombre    = "";
   begin
      on exception set sql_err
	 if sql_err <> 0 then
	    let w_cod_ret = sql_err;
	    return w_cod_ret,w_nombre;
	 end if
      end exception;



--- Valida que la Cuenta no sea Blanco
   if pcuenta = " " then
      let w_cod_ret = "110";
      return w_cod_ret,w_nombre;
   end if

---- Valida que Exista la Cuenta de Inversiones
   select cuenta,num_cte into w_cuenta,w_num_cte
      from sv_maeinv
      where empresa = pempresa and cuenta = pcuenta and status_cta <> "4";
   if w_cuenta is null or w_cuenta <> pcuenta then
      let w_cod_ret = "100";
      return w_cod_ret, w_nombre;
   end if

--- Extrae Nombre(s) del Cliente
    select es_fisica,apell_paterno||apell_materno||nombre1||nombre2,razon_social
       into w_esfisica,w_nombre,w_razon_soc
       from bdinteg:si_cliente, bdinteg:si_tipper
       where numcte = w_num_cte and bdinteg:si_cliente.tpo_persona =
	     bdinteg:si_tipper.tpo_persona;
    if w_esfisica is null then
       let w_cod_ret = "104";
       return w_cod_ret,w_nombre;
    else
       if w_esfisica = "N" then
	  let w_nombre = w_razon_soc;
       end if
    end if

  return w_cod_ret,w_nombre;
  end
  end procedure;