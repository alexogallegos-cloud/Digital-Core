create procedure "informix".cons_chsus(pempresa char(3),
                                       pcuenta char(20),
                                       pnrodoc integer)
   returning char(5),char(1);

   define w_cod_ret   char(5);
   define v_long_cta   char(2);
   define w_estado   char(1);
   define w_cuenta    char(20);
   define w_nrodoc    integer;
   define longitud    smallint;

   let w_cod_ret   = "000";
   let w_estado   = "";


--- Valida que la Cuenta no sea Blanco
   if pcuenta = " " then
      let w_cod_ret = "110";
      return w_cod_ret,w_estado;
   end if


--- Valida que el Numero de Documento no sea Nulo
   if pnrodoc is null then
      let w_cod_ret = "110";
      return w_cod_ret,w_estado;
   end if

--- Valida que el Numero de Documento no sea Ceros
   if pnrodoc = 0 then
      let w_cod_ret = "110";
      return w_cod_ret,w_estado;
   end if

---- Valida que Exista en Control de Cheques
   select cuenta, numero, estado
      into w_cuenta,w_nrodoc,w_estado
      from sc_contch
      where empresa = pempresa and cuenta = pcuenta and numero = pnrodoc;
      if  w_cuenta is null then
         let w_cuenta = "0";
      end if
   if w_cuenta != pcuenta then
      select cuenta,numero,estado
         into w_cuenta,w_nrodoc,w_estado
         from sc_histch
         where empresa = pempresa and cuenta = pcuenta and numero = pnrodoc;
      if w_cuenta is null then
         let w_cuenta = "0";
      end if
      if w_cuenta != pcuenta then
         let w_cod_ret = "500";
         return w_cod_ret,w_estado;
      else
         return w_cod_ret,w_estado;
      end if
   else
      return w_cod_ret,w_estado;
   end if

end procedure;