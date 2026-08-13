create procedure "informix".edo_ctaran1(pempresa char(3),
                                        cta char(20), 
                                        num_movto smallint,
                                        fecha1 date,
                                        fecha2 date)
   returning char(5), date, char(40), integer, money(14,2),
             money(14,2), money(14,2), char(51),money(14,2), char(1),
             char(40);
   define v_transacc char(40);
   define x_transacc char(4);
   define v_fecha date;
   define v_docto integer;
   define v_num_cte char(20);
   define v_monto, v_saldo, v_sdo_mesant money(14,2);
   define v_num_serial integer;
   define v_conta smallint;
   define v_nombre char(51);
   define v_paterno, v_materno, v_nombre1, v_nombre2 char(12);
   define v_naturaleza char(1);
   define v_hora datetime hour to fraction(3);
   define v_ciclo smallint;
   define v_cod_ret char(5);
   define v_espacio,v_env_dir char(1);
   define v_razon char(48);
   define v_serial integer;
   define v_saldo_disp money(14,2);
   define v_referencia char(40);
   define sql_err integer;
   let v_conta=0;
   let v_cod_ret="000";
   let v_transacc=" ";
   let v_docto=0;
   let v_fecha=" ";
   let v_monto=0;
   let v_saldo=0;
   let v_sdo_mesant=0;
   let v_espacio=" ";
   let v_nombre=" ";
   let v_ciclo=0;
   let v_referencia = " ";
   begin
      on exception set sql_err
         if sql_err <> 0 then
            let v_cod_ret = sql_err;
            return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
                   v_saldo, v_sdo_mesant, v_nombre,v_saldo_disp,v_env_dir,
                   v_referencia;
         end if
      end exception;

   -- Extrae el nombre del cliente
   select sdo_actual, sdo_mes_ant, envio_direcc, numcte, apell_paterno,
          apell_materno, nombre1, nombre2, razon_social,
          (sdo_actual-sdo_retenido-sdo_cong)
          into v_saldo, v_sdo_mesant,v_env_dir, v_num_cte, v_paterno,
          v_materno, v_nombre1, v_nombre2, v_razon, v_saldo_disp
   from sc_maechq mc, sc_maenoc mn, bdinteg:si_cliente cl
   where mc.empresa = pempresa and mc.cuenta = cta and
         mn.empresa = mc.empresa and mn.cuenta = mc.cuenta and
         mc.num_cte = cl.numcte;
   if v_saldo is null then
      let v_saldo_disp = 0;
      let v_cod_ret="100";
      return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
             v_saldo, v_sdo_mesant, v_nombre,v_saldo_disp,v_env_dir,
             v_referencia;
   else
      if v_razon is null or v_razon=" " then
         if v_nombre2 is null or v_nombre2=" " then
            let v_nombre=v_nombre1 ||v_espacio||v_paterno ||v_espacio||
                         v_materno;
         else
            if v_nombre1 is null or v_nombre1=" " then
               let v_nombre=v_nombre2 ||v_espacio||v_paterno ||v_espacio||
                            v_materno;
            else
               let v_nombre=v_nombre1 || v_nombre2 ||v_espacio||v_paterno ||
                            v_espacio||v_materno;
            end if;
         end if;
      else
         let v_nombre=v_razon;
      end if;
   end if;


   -- Extrae los movimientos mensuales
   foreach
      select fech_alt, fech_hor, descripcion, num_cheq, monto_tot,
             naturaleza, transacc, referencia
             into v_fecha, v_hora, v_transacc, v_docto, v_monto,
             v_naturaleza, x_transacc, v_referencia
      from sc_movmes mm, bdinteg:si_transacc tr
      where mm.empresa = pempresa and cuenta = cta and 
            tr.empresa = mm.empresa and tr.numero = mm.transacc and
            se_emite_edocta = "S" and fech_alt between fecha1 and fecha2
      order by fech_alt, fech_hor
      if v_monto < 0 then
         let v_transacc = "REV "||trim(v_transacc);
      end if
      if v_naturaleza="C" then
         let v_monto=(v_monto*(-1));
      end if
      let v_ciclo=v_ciclo+1;
      if v_ciclo<=num_movto then
         continue foreach;
      end if
      if v_referencia is null then
         let v_referencia = " ";
      end if
      return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
             v_saldo, v_sdo_mesant, v_nombre,v_saldo_disp,v_env_dir,
             v_referencia
             with resume;
      let v_conta=v_conta+1;
   end foreach;

   -- Extrae los movimientos diarios
   foreach
      select fech_alt, num_serial,fech_hor, descripcion, num_cheq,
             monto_tot, naturaleza, transacc, referencia
             into v_fecha,v_serial, v_hora, v_transacc, v_docto,
             v_monto, v_naturaleza, x_transacc, v_referencia
      from sc_movdia md, bdinteg:si_transacc tr
      where md.empresa = pempresa and md.cuenta = cta and 
            tr.empresa = md.empresa and tr.numero = md.transacc and
            cancelad!="V" and fech_alt between fecha1 and fecha2 and
            se_emite_edocta = "S"
      order by fech_alt, num_serial
      if v_monto < 0 then
         let v_transacc = "REV "||trim(v_transacc);
      end if
      if v_naturaleza="C" or x_transacc = "3320"  then
         let v_monto=(v_monto*(-1));
      end if
      let v_ciclo=v_ciclo+1;
      if v_ciclo<=num_movto then
         continue foreach;
      end if
      if v_referencia is null then
         let v_referencia = " ";
      end if
      return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
             v_saldo, v_sdo_mesant, v_nombre,v_saldo_disp,v_env_dir,
             v_referencia
      with resume;
      let v_conta=v_conta+1;
   end foreach;
end
end procedure;