create procedure "informix".trae_sol(pempresa char(3),
 						 psucursal char(4),
			                   pnumreg integer)
returning 	char(5),
		char(20),
                char(20);

define 	cod_ret char(5);

define counter integer;
define v_ciclo integer;
define sql_err integer;
define w_codigo char(20);
define w_numcte char(20);

   begin
      on exception set sql_err
	 if sql_err <> 0 then
	    let w_codigo = sql_err;
   return cod_ret,w_codigo,  w_numcte
          with resume;
         end if
      end exception;


let counter=0;
let v_ciclo=0;
let cod_ret="000";
let w_codigo = " ";
let w_numcte = " ";


foreach alfa_cursor with hold for
   select num_solicitud, numcte
      into w_codigo, w_numcte
      from bdisolic:ss_solicitudes
      order by num_solicitud

        let v_ciclo=v_ciclo+1;
        if v_ciclo<=pnumreg then
	   continue foreach;
        end if
   return cod_ret,w_codigo, w_numcte  with resume;
   let counter=counter+1;
end foreach;
end
end procedure;