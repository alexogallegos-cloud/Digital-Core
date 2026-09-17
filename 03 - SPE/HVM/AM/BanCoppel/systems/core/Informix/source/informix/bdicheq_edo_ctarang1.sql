create procedure "informix".edo_ctarang1(pempresa char(3),
                                         cta char(20),
                                         num_movto smallint,
                                         fecha1 date,
                                         fecha2 date)
   returning char(5),date,char(40),integer,money(14,2),
             money(14,2),money(14,2),char(51),money(14,2),char(1),
            char(20),char(40),char(35),char(50),char(18);
   define vtransacc char(40);
   define x_transacc char(4);
   define vfecha date;
   define vdocto integer;
   define vnum_cte char(20);
   define vmonto,vsaldo,vsdo_mesant money(14,2);
   define vnum_serial integer;
   define vconta smallint;
   define vnombre char(51);
   define vpaterno,vmaterno,vnombre1,vnombre2 char(12);
   define vnaturaleza char(1);
   define vhora datetime hour to fraction(3);
   define vciclo smallint;
   define vcod_ret char(5);
   define vespacio,venvdir char(1);
   define vrazon char(48);
   define vserial integer;
   define vsaldo_disp money(14,2);
   define vreferencia char(40);
   define sql_err integer;
   define vproducto char(4);
   define vprodnom char(45);
   define vdivisa char(2);
   define vmoneda char(30);
   define vdesdivisa char(35);
   define vdesprod char(50);
   define vctaclabe char(18);

   let vconta=0;
   let vcod_ret="000";
   let vtransacc=" ";
   let vdocto=0;
   let vfecha=" ";
   let vmonto=0;
   let vsaldo=0;
   let vsdo_mesant=0;
   let vespacio=" ";
   let vnombre=" ";
   let vciclo=0;
   let vreferencia = " ";
   let vproducto = "";
   let vprodnom = "";
   let vdivisa = "";
   let vmoneda = "";
   let vdesdivisa = "";
   let vdesprod = "";
   let vsaldo_disp = 0;
   let venvdir = "";
   let vnum_cte = " ";
   let vctaclabe = "";

   begin
      on exception set sql_err
         if sql_err <> 0 then
            let vcod_ret = sql_err;
            return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
                   vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
                   vnum_cte,vreferencia,vdesdivisa,vdesprod,vctaclabe;
         end if
      end exception;

   -- Extrae el nombre del cliente
   select sdo_actual,sdo_mes_ant,envio_direcc,numcte,apell_paterno,
          apell_materno,nombre1,nombre2,razon_social,
          (sdo_actual-sdo_retenido-sdo_cong),mc.producto,
          pr.nombre,pr.divisa,di.descripcion
          into vsaldo,vsdo_mesant,venvdir,vnum_cte,vpaterno,
          vmaterno,vnombre1,vnombre2,vrazon,vsaldo_disp,
          vproducto,vprodnom,vdivisa,vmoneda
   from sc_maechq mc,sc_maenoc mn,outer bdinteg:si_cliente cl,sc_producto pr,
        bdinteg:si_divisas di
   where mc.empresa = pempresa and mc.cuenta = cta and
         mn.empresa = mc.empresa and mn.cuenta = mc.cuenta and
         pr.empresa = mc.empresa and pr.producto = mc.producto and
         di.empresa = pr.empresa and di.divisa = pr.divisa and
         mc.num_cte = cl.numcte;

      let vdesdivisa = vdivisa||" "||vmoneda;
      let vdesprod = vproducto||" "||vprodnom;
   if vsaldo is null then
      let vsaldo_disp = 0;
      let vcod_ret="100";
      return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
             vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
             vnum_cte,vreferencia,vdesdivisa,vdesprod,vctaclabe;
   else
      if vrazon is null or vrazon=" " then
         if vnombre2 is null or vnombre2=" " then
            let vnombre=vnombre1 ||vespacio||vpaterno ||vespacio||
                         vmaterno;
         else
            if vnombre1 is null or vnombre1=" " then
               let vnombre=vnombre2 ||vespacio||vpaterno ||vespacio||
                            vmaterno;
            else
               let vnombre=vnombre1 || vnombre2 ||vespacio||vpaterno ||
                            vespacio||vmaterno;
            end if;
         end if;
      else
         let vnombre=vrazon;
      end if;
   end if;

   foreach
      select sum(monto_tot),naturaleza
             into vmonto,vnaturaleza
      from sc_movmes mm,bdinteg:si_transacc tr
      where mm.empresa = pempresa and cuenta = cta
           and mm.transacc != "3322"
           and mm.transacc != "3313"
           and mm.transacc != "3314"
           and fech_alt < fecha1
           and tr.empresa = mm.empresa and tr.numero = mm.transacc
      group by 2
      if vnaturaleza="C"  then
         let vmonto=(vmonto*(-1));
      end if;
      let vsdo_mesant = vsdo_mesant + vmonto;
   end foreach;
   foreach
      select sum(monto_tot),naturaleza
             into vmonto,vnaturaleza
      from sc_movdia md,bdinteg:si_transacc tr
      where md.empresa = pempresa and cuenta = cta
           and md.cancelad != "V"
           and md.transacc != "3322"    -- Excluye transaccion de
           and md.transacc != "3313"    -- Excluye transaccion contable
           and md.transacc != "3314"    -- Excluye transaccion contable
           and fech_alt < fecha1
           and tr.empresa = md.transacc and tr.numero = md.transacc
      group by 2
      if vnaturaleza="C"  then
         let vmonto=(vmonto*(-1));
      end if;
      let vsdo_mesant = vsdo_mesant + vmonto;
   end foreach;
   let vsaldo = vsdo_mesant;
   foreach
      select sum(monto_tot),naturaleza
             into vmonto,vnaturaleza
      from sc_movmes mm,bdinteg:si_transacc tr
      where mm.empresa = pempresa and cuenta = cta
           and mm.transacc != "3322"
           and mm.transacc != "3313"
           and mm.transacc != "3314"
           and fech_alt between fecha1 and fecha2
           and tr.empresa = mm.empresa and tr.numero = mm.transacc
      group by 2
      if vnaturaleza="C"  then
         let vmonto=(vmonto*(-1));
      end if;
      let vsaldo = vsaldo + vmonto;
   end foreach;
   foreach
      select sum(monto_tot),naturaleza
             into vmonto,vnaturaleza
      from sc_movdia md,bdinteg:si_transacc tr
      where md.empresa = pempresa and cuenta = cta
           and md.cancelad != "V"
           and md.transacc != "3322"    -- Excluye transaccion de
           and md.transacc != "3313"    -- Excluye transaccion contable
           and md.transacc != "3314"    -- Excluye transaccion contable
           and fech_alt between fecha1 and fecha2
           and tr.empresa = md.empresa and tr.numero = md.transacc
      group by 2
      if vnaturaleza="C"  then
         let vmonto=(vmonto*(-1));
      end if;
      let vsaldo = vsaldo + vmonto;
   end foreach;
      let vsaldo_disp = vsaldo;
   -- Extrae los movimientos mensuales
   foreach
      select fech_alt,fech_hor,descripcion,num_cheq,monto_tot,
             naturaleza,transacc,referencia
             into vfecha,vhora ,vtransacc,vdocto,vmonto,
             vnaturaleza,x_transacc,vreferencia
      from sc_movmes mm,bdinteg:si_transacc tr
      where mm.empresa = pempresa and cuenta = cta
           and mm.transacc != "3322"
           and mm.transacc != "3313"
           and mm.transacc != "3314"
           and fech_alt between fecha1 and fecha2
           and tr.empresa = mm.empresa and tr.numero = mm.transacc
      order by fech_alt,fech_hor
      if vmonto < 0 then
         let vtransacc = "REV "||trim(vtransacc);
      end if
      if vnaturaleza="C" or x_transacc = "3320"  then
         let vmonto=(vmonto*(-1));
      end if
      let vciclo=vciclo+1;
      if vciclo<=num_movto then
         continue foreach;
      end if
      if vreferencia is null then
         let vreferencia = " ";
      end if
      return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
             vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
             vnum_cte,vreferencia,vdesdivisa,vdesprod,vctaclabe
             with resume;
      let vconta=vconta+1;
   end foreach;

   -- Extrae los movimientos diarios
   foreach
      select fech_alt,num_serial,fech_hor,descripcion,num_cheq,
             monto_tot,naturaleza,transacc," "
             into vfecha,vserial,vhora,vtransacc,vdocto,
             vmonto,vnaturaleza,x_transacc,vreferencia
      from sc_movdia md,bdinteg:si_transacc tr
      where md.empresa = pempresa and md.cuenta = cta
            and cancelad != "V" and
            md.transacc != "3322"
            and md.transacc != "3313"
            and md.transacc != "3314"
            and fech_alt between fecha1 and fecha2
            and tr.empresa = md.empresa and tr.numero = md.transacc
      order by fech_alt,num_serial
      if vmonto < 0 then
         let vtransacc = "REV "||trim(vtransacc);
      end if
      if vnaturaleza="C" or x_transacc = "3320"  then
         let vmonto=(vmonto*(-1));
      end if
      let vciclo=vciclo+1;
      if vciclo<=num_movto then
         continue foreach;
      end if
      if vreferencia is null then
         let vreferencia = " ";
      end if
      return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
             vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
             vnum_cte,vreferencia,vdesdivisa,vdesprod,vctaclabe
      with resume;
      let vconta=vconta+1;
   end foreach;
end
end procedure;