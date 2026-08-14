create procedure "informix".inthist(pempresa char(3),
                                    i_cuenta char(20),
                                    monto_tot money(14,2))
 returning char(5);


define w_int_acum,w_monto_tot money(14,2);
define x_cuenta,v_cuenta char(20);
define x_codret char(5);
define w_fecha_sbg date;
define w_rowid integer;



   let x_codret = "000";


--- Elimina Interes que fueron cobrados con el abono
   let w_monto_tot = monto_tot;
   foreach
      select rowid,cuenta,fecha_sbg,int_acum
         into w_rowid,x_cuenta,w_fecha_sbg,w_int_acum
         from sc_histsbg
         where empresa = pempresa and cuenta = i_cuenta 
         order by fecha_sbg
      if w_monto_tot >= w_int_acum then
         let w_monto_tot = w_monto_tot - w_int_acum;
         update sc_histsbg
            set (int_acum) = (0)
            where rowid = w_rowid;
      else
         update sc_histsbg
            set (int_acum) = (int_acum - w_monto_tot)
            where rowid = w_rowid;
         let w_monto_tot = 0;
         exit foreach;
      end if
   end foreach
   return x_codret;
 end procedure;