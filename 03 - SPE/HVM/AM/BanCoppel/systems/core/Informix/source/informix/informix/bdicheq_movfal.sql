create procedure "informix".movfal(pempresa char(3),
                                   pcuenta  char(20),
                                   prenglon smallint)

       returning char(5),date,char(20),money(14,2),char(80),char(80),
                 char(80),money(14,2),money(14,2),char(40);

   define cod_ret char(5);
   define sql_err integer;
   define v_cuenta char(20);
   define v_fecha      date;
   define v_transacc   char(20);
   define v_monto_tot  money(14,2);
   define v_sdo_cuenta money(14,2);
   define v_sdo_cuenta1 money(14,2);
   define v_completo   char(80);
   define v_nombre,v_nomcotit1,v_nomcotit2 char(80);
   define v_ciclo      smallint;
   define v_numcte,v_cotit char(20);
   define v_numero char(20);
   define v_nombre2,v_nombre1,v_materno,v_paterno char(15);
   define v_razon char(36);
   define vconreg smallint;
   define v_serie integer;
   define v_fisica,v_naturaleza char(1);
   define v_producto char(4);
   define v_impcargo,v_impabono money(14,2);
   define v_destran char(20);
   define v_nomsuc,v_sucursal char(40);
   define v_moneda char(2);
   define v_maneja_libreta char(1);
   define vusuario char(8);

   let cod_ret      = "000";
   let v_cuenta     = " ";
   let v_fecha      = " ";
   let v_transacc   = " ";
   let v_monto_tot  = 0;
   let v_sdo_cuenta = 0;
   let v_sdo_cuenta1 = 0;
   let v_nombre     = " ";
   let v_completo   = " ";
   let v_nomcotit1  = " ";
   let v_nomcotit2  = " ";
   let v_ciclo      = 0;
   let v_impabono   = 0;
   let v_impcargo   = 0;
   let v_destran    = " ";
   let v_sucursal   = " ";
   let v_moneda  = "";
begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret,v_fecha,v_transacc,v_sdo_cuenta,v_completo,
                v_nomcotit1,v_nomcotit2,v_impcargo,v_impabono,v_sucursal;

      end if
   end exception;


   select num_cte,sucursal,producto into v_numcte,v_sucursal,v_producto
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;

   if v_numcte is null then
      let cod_ret = "100";
      return cod_ret,v_fecha,v_transacc,v_sdo_cuenta,v_completo,
             v_nomcotit1,v_nomcotit2,v_impcargo,v_impabono,v_sucursal;
   end if

   select divisa,maneja_libreta into v_moneda,v_maneja_libreta
      from sc_producto
      where empresa = pempresa and producto = v_producto;
   if v_maneja_libreta = "N" or v_maneja_libreta is null then
      let cod_ret = "940";
      return cod_ret,v_fecha,v_transacc,v_sdo_cuenta,v_completo,
             v_nomcotit1,v_nomcotit2,v_impcargo,v_impabono,v_sucursal;
   end if

   select numcte,apell_paterno,apell_materno,nombre1,nombre2,
          razon_social,es_fisica
     into v_numero,v_paterno,v_materno,v_nombre1,v_nombre2,
          v_razon,v_fisica
     from bdinteg:si_cliente,bdinteg:si_tipper
     where numcte=v_numcte and
           bdinteg:si_tipper.tpo_persona = bdinteg:si_cliente.tpo_persona;
   if v_numero is null then
      let cod_ret = "104";
      return cod_ret,v_fecha,v_transacc,v_sdo_cuenta,v_completo,
             v_nomcotit1,v_nomcotit2,v_impcargo,v_impabono,v_sucursal;
   end if
   IF v_paterno IS NULL THEN
      LET v_paterno=" ";
   END IF;
   IF v_materno IS NULL THEN
      LET v_materno =" ";
   END IF;
   IF v_nombre1 IS NULL THEN
      LET v_nombre1 =" ";
   END IF;
   IF v_nombre2 IS NULL THEN
      LET v_nombre2 =" ";
   END IF;
   IF v_razon IS NULL THEN
    LET v_razon =" ";
   END IF;

   if v_fisica = "S" then
      let v_completo = TRIM(v_paterno)||" "||TRIM(v_materno)||" "||
                       TRIM(v_nombre1);
   else
      let v_completo = TRIM(v_razon);
   end if

   let v_moneda = " ";

   --- Extrae cotitulares
   let vconreg = 0;
   let  v_nomcotit1 = " ";
   let  v_nomcotit2 = " ";
   if v_fisica = "S" then
      foreach
         select nombre into v_cotit from sc_cotitular
            where empresa = pempresa and cuenta = pcuenta
         let vconreg = vconreg + 1;
         if v_cotit is null then
            if vconreg = 1 then
               exit foreach;
            else
 	       continue foreach;
            end if
         end if
         select numcte,apell_paterno,apell_materno,nombre1,nombre2,razon_social
            into v_numero,v_paterno,v_materno,v_nombre1,v_nombre2,v_razon
            from bdinteg:si_cliente
            where numcte = v_cotit;
         if v_numero is null then
            continue foreach;
         end if
         IF v_paterno IS NULL THEN
            LET v_paterno =" ";
         END IF;
         IF v_materno IS NULL THEN
            LET v_materno =" ";
         END IF;
         IF v_nombre1 IS NULL THEN
            LET v_nombre1 =" ";
         END IF;
         IF v_nombre2 IS NULL THEN
            LET v_nombre2 =" ";
         END IF;
         IF v_razon IS NULL THEN
            LET v_razon =" ";
         END IF;
         if vconreg = 1 then
            if v_razon is null  or v_razon = " " then
               let v_nomcotit1 = TRIM(v_cotit)||" "||TRIM(v_paterno)||" "||
	           TRIM(v_materno)||" "||TRIM(v_nombre1);
            else
               let v_nomcotit1 = TRIM(v_cotit)||" "||TRIM(v_razon);
            end if
         else
            if v_razon is null  or v_razon = " " then
               let v_nomcotit2 = TRIM(v_cotit)||" "||TRIM(v_paterno)||" "||
	           TRIM(v_materno)||" "||TRIM(v_nombre1);
            else
               let v_nomcotit2 = TRIM(v_cotit)||" "||TRIM(v_razon);
            end if
         end if
     end foreach
  end if

  select nombre into v_nomsuc
     from bdinteg:si_sucursales
     where empresa = pempresa and sucursal = v_sucursal;
  let v_sucursal = trim(v_sucursal)||" "||trim(v_nomsuc);

  foreach
     select mf.rowid,cuenta,fech_alt,numero,monto_tot,sdo_cuenta,
	    naturaleza,abreviatura,folio_suc[6,8]
        into v_serie,v_cuenta,v_fecha,v_transacc,v_monto_tot,
             v_sdo_cuenta1,v_naturaleza,v_destran,vusuario
        from sc_movfal mf,bdinteg:si_transacc tr
        where mf.empresa = pempresa and cuenta = pcuenta and
              nvl(status_imp," ") <> "I" and 
              tr.empresa = mf.empresa and
              numero = transacc and se_emite_edocta ="S"
     union all
     select num_serial,cuenta,fech_alt,numero,monto_tot,
            sdo_cuenta,naturaleza,abreviatura,folio_suc[6,8]
        from sc_movdia md,bdinteg:si_transacc tr
        where md.empresa = pempresa and cuenta = pcuenta and
         edo_cta <> "I" and cancelad <> "V" and
              tr.empresa = md.empresa and numero = transacc and
              se_emite_edocta ="S"
     order by 2,3,1

     if v_monto_tot < 0 then
        let v_destran = "R "||trim(v_destran);
     end if
     if v_naturaleza = "A" then
        let v_impabono = v_monto_tot;
        let v_impcargo = 0;
     end if
     if v_naturaleza = "C" then
        let v_impcargo = v_monto_tot;
        let v_impabono = 0;
     end if

     IF v_sdo_cuenta = 0 THEN
        let v_sdo_cuenta=v_sdo_cuenta1;
     END IF

     if v_naturaleza = "A" then
        let v_sdo_cuenta = v_sdo_cuenta + v_monto_tot;
        let v_impabono = v_monto_tot;
        let v_impcargo = 0;
     end if
     if v_naturaleza = "C" then
        let v_sdo_cuenta = v_sdo_cuenta - v_monto_tot;
        let v_impcargo = v_monto_tot;
        let v_impabono = 0;
     end if
     if v_naturaleza ="R" THEN
        IF v_transacc = "3718" THEN
           let v_impcargo = v_monto_tot;
           let v_impabono = 0;
           let v_sdo_cuenta= v_sdo_cuenta - v_monto_tot;
        ELSE
           let v_impabono = v_monto_tot;
           let v_impcargo = 0;
           let v_sdo_cuenta= v_sdo_cuenta + v_monto_tot;
        END IF
     end if

     let v_ciclo = v_ciclo + 1;
     if v_ciclo <= prenglon then
        continue foreach;
     end if;
     let v_transacc = trim(vusuario)||" "||trim(v_destran);
     return cod_ret,v_fecha,v_transacc,v_sdo_cuenta,v_completo,v_nomcotit1,
            v_nomcotit2,v_impcargo,v_impabono,v_sucursal with resume;
  end foreach
end
end procedure;