create procedure "informix".ult_tran(pplaza      char(3),
                            psucursal   char(4),
			    pusuario    char(5),
			    pfecha      date,
			    phora       datetime hour to fraction(3),
			    ptransacc   char(4),
			    ptotal      money(14,2),
			    pfirme      money(14,2),
			    psbc        money(14,2),
			    premesa     money(14,2))
   returning char(5);

   define cod_ret char(5);
   define sql_err, isam_err integer; 
   define sucret char(4);

   let sucret= " ";

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret;
         end if;
      end exception;

   select sucursal into sucret
   from sv_ultran
   where plaza = pplaza and
         sucursal = psucursal and
	 usuario  = pusuario;

   if sucret = psucursal then
      update sv_ultran
      set fecha        = pfecha,
          hora         = phora,
          transac      = ptransacc,
          monto_total  = ptotal,
          monto_firme  = pfirme,
          monto_sbc    = psbc,
          monto_remesa = premesa
      where plaza    = pplaza and
            sucursal = psucursal and
	    usuario  = pusuario;
   else
      insert into sv_ultran
      values (pplaza, psucursal, pusuario, ptransacc, pfecha, phora, ptotal,
	      pfirme, psbc, premesa);
   end if;
   end;      -- fin del on exception
return cod_ret;
end procedure;