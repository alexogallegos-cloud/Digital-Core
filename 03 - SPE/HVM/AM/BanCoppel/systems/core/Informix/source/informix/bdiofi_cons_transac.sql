create procedure "informix".cons_transac(w_transaccionid integer,
                                         w_empresaid char(3))
returning char(5), char(60), char(15);

    define w_cod_ret		char(5);
    define w_descripcion	char(60);
    define w_nombreCorto        char(15);
    define sql_err		integer;

--- Inicializa Variables de Salida
    let w_cod_ret	= "000";
    let w_descripcion   = " ";
    let w_nombreCorto   = " ";

begin
   on exception set sql_err
      if sql_err <> 0 then
      let w_cod_ret = sql_err;
         let w_descripcion= " ";
         let w_nombreCorto = " ";
         return w_cod_ret, w_descripcion, w_nombreCorto;
      end if
   end exception;

   --- Validaciones basicas ----
   if w_transaccionid = " " then
      let w_cod_ret= "110";
      let w_descripcion= " ";
      let w_nombreCorto = " ";
      return w_cod_ret, w_descripcion, w_nombreCorto;
   end if

   select descripcion,nombrecorto into w_descripcion,w_nombreCorto from so_transacciones
   where transaccionid=w_transaccionid and  empresaId = w_empresaid;


   if w_descripcion is null then
      let w_cod_ret="000";
      let w_descripcion= " ";
      let w_nombreCorto= " ";
      return w_cod_ret, w_descripcion, w_nombreCorto;
end if

   return w_cod_ret, w_descripcion, w_nombreCorto;
 end
end procedure;