create procedure "informix".reversion_web(pempresa char(3),
                           psucursal  char(3),
			   pusuario   char(8),
                           pfolio     char(16),
                           ptiporev   char(1))
returning char(5),char(20);

   define tran,vcod_instrum char(4);
   define mon_tot,fir,sbc money(14,2);
   define cta char(20);
   define nat char(1);
   define v_trans_recap,v_trans_int char(4);
   define n_s int;
   define cod_ret char(5);
   define sql_err,isam_err integer;
   define vsecuencia,contador smallint;
   define v_fechoy date;
   let cod_ret="00000";
   let contador=0;
   let cta = "0";



   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,cta;
         end if;
      end exception;

   select count(*) into contador
      from sv_movdia
      where empresa = pempresa and folio_suc=pfolio and cancelad!="S";
   if contador = 0 then
      ---* No existen movimientos en el diario o ya estan reversados *
     -- let cod_ret = "00001";
      return cod_ret,cta;
   end if;

   select fecha_hoy into v_fechoy from sv_fechas where empresa = pempresa;

   foreach
      select num_serial,transacc,cuenta,monto_tot,firme,en_sbc,cod_instrum
	 into n_s,tran,cta,mon_tot,fir,sbc,vcod_instrum
	 from sv_movdia
	 where empresa = pempresa and folio_suc = pfolio and cancelad <> "S"
       	 order by num_serial desc
      select trans_recap,trans_int into v_trans_recap,v_trans_int
         from sv_instrum
   	 where empresa = pempresa and cod_instrum = vcod_instrum;
      if tran = v_trans_recap then
         select max(secuencia) into vsecuencia
            from sv_maeinv
            where empresa = pempresa and cuenta = cta;
         update sv_maeinv
            set status_cta = "1"
            where empresa = pempresa and cuenta = cta and
                  secuencia = vsecuencia;
         update sv_maeinstrucc
	    set aplicado = "N"
            where empresa = pempresa and cuenta = cta and cap_int = "C";
      end if;
      if tran = v_trans_int then
         update sv_maeinstrucc
	    set aplicado = "N"
            where empresa = pempresa and cuenta = cta and cap_int = "I";
      end if;
      if ptiporev = "A" then
         delete from sv_movdia
            where num_serial = n_s;
      else
         update sv_movdia
	    set cancelad = "S" where num_serial = n_s;
      end if
      delete from sv_auxcont
	 where empresa = pempresa and cuenta = cta;
   end foreach;

 return cod_ret,cta;
end;   --fin del on exception
return cod_ret,cta;
end procedure;