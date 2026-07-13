create procedure "informix".edo_ctama11(pempresa char(3),
                                        cta char(20),
                                        num_movto smallint)
   returning char(5), date, char(40), integer, money(14,2),
             money(14,2), money(14,2), char(51),
             char(1),char(20),money(14,2),char(20),
             char(35),char(50);
   define v_transacc char(40);
   define x_transacc char(4);
   define v_fecha date;
   define v_docto integer;
   define v_num_cte char(20);
   define v_refer char(40);
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
   define sql_err integer;
   define v_producto char(4);
   define v_divisa char(2);
   define v_prodnom char(45);
   define v_moneda char(30);
   define v_descrip1 char(35);
   define v_descrip2 char(50);


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
   let v_refer= " ";
   let v_producto = "";
   let v_moneda = "";
   let v_prodnom = "";
   let v_divisa = "";
   let v_descrip1 = "";
   let v_descrip2 = "";
   let v_env_dir = "";
   let v_num_cte = "";
   let v_saldo_disp = 0;
   begin
      on exception set sql_err
         if sql_err <> 0 then
            let v_cod_ret = sql_err;
            return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
                   v_saldo, v_sdo_mesant, v_nombre,v_env_dir,
                   v_num_cte,v_saldo_disp,v_refer,v_descrip1,v_descrip2;
         end if
      end exception;

   -- Extrae el nombre del cliente
   select distinct
          sdo_actual, sdo_mes_ant, envio_direcc, numcte, apell_paterno,
          apell_materno, nombre1, nombre2, razon_social,
          (sdo_actual-sdo_retenido-sdo_cong),ma.producto,
          pr.nombre,pr.divisa,di.descripcion
          into v_saldo, v_sdo_mesant,v_env_dir, v_num_cte, v_paterno,
          v_materno, v_nombre1, v_nombre2, v_razon, v_saldo_disp,
          v_producto, v_prodnom,v_divisa, v_moneda
   from sc_maeman ma, bdinteg:si_cliente cl,bdinteg:si_divisas di,
        sc_producto pr
   where ma.empresa = pempresa and ma.cuenta = cta and
         pr.empresa = ma.empresa and pr.producto = ma.producto and
         di.empresa = pr.empresa and di.divisa = pr.divisa and
         ma.num_cte = cl.numcte;

   let v_descrip1 = v_divisa||" "||v_moneda;
   let v_descrip2 = v_producto||" "||v_prodnom;
   if v_saldo is null then
      let v_saldo_disp = 0;
      let v_cod_ret="150";
      return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
             v_saldo, v_sdo_mesant, v_nombre,v_env_dir,
             v_num_cte,v_saldo_disp,v_refer,v_descrip1,v_descrip2;
   else
      if v_razon is null or v_razon=" " then
         if v_nombre2 is null or v_nombre2=" " then
            let v_nombre=trim(v_nombre1) ||v_espacio||trim(v_paterno) ||v_espacio||
                         trim(v_materno);
         else
            if v_nombre1 is null or v_nombre1=" " then
               let v_nombre=trim(v_nombre2) ||v_espacio||trim(v_paterno) ||v_espacio||
                            trim(v_materno);
            else
               let v_nombre=trim(v_nombre1) || v_espacio||trim(v_nombre2 )||v_espacio||trim(v_paterno) ||
                            v_espacio||trim(v_materno);
            end if;
         end if;
      else
         let v_nombre=v_razon;
      end if;
   end if;


   -- Extrae los movimientos mensuales
   foreach
      select fech_alt, num_serial, fech_hor, descripcion, num_cheq, monto_tot,
             naturaleza, transacc, referencia
             into v_fecha, v_serial, v_hora, v_transacc, v_docto, v_monto,
             v_naturaleza, x_transacc, v_refer
      from sc_movman ma, bdinteg:si_transacc tr
      where ma.empresa = pempresa and cuenta = cta and
            cancelad not in("V") and
            tr.empresa = ma.empresa and numero = transacc and
            se_emite_edocta = "S"
      order by fech_alt, num_serial
      if v_refer is null then
         let v_refer = " ";
      end if
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
      return v_cod_ret, v_fecha, v_transacc, v_docto, v_monto,
             v_saldo, v_sdo_mesant, v_nombre,v_env_dir,
             v_num_cte,v_saldo_disp,v_refer,v_descrip1,v_descrip2 with resume;
      let v_conta=v_conta+1;
   end foreach;

end
end procedure;