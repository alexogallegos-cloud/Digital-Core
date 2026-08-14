create function "informix".get_lasttransaccion(w_EmpresaID char(3))
       returning       integer;

--- Inicializa las variables de Salida
	define w_cod_ret	char(5);
	define w_TransaccionID	integer;
        define sql_err          integer;

	let w_cod_ret="000";
	let w_TransaccionID=0;
    BEGIN
      on exception set sql_err
         if sql_err <> 0 then
	   let w_cod_ret = sql_err;
	   let w_TransaccionID=-1;
         end if
      end exception;

         SELECT max (transaccionid) + 1 into w_TransaccionID FROM so_Transacciones
         WHERE EmpresaID = w_EmpresaID;

         return w_TransaccionID;
     END
end function;