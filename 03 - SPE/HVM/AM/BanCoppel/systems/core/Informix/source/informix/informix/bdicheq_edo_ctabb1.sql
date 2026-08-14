create procedure "informix".edo_ctabb1(pempresa char(3),
                                       pcuenta char(20),
                                       paniomes char(6),
                                       pultmovto smallint)
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
   define venvdir char(1);
   define vrazon char(48);
   define vserial integer;
   define vsaldo_disp money(14,2);
   define vreferencia char(40);
   define sql_err integer;
   define vdescripmo char(35);
   define vdescripro char(50);
   define vproducto char(4);
   define vnomprod  char(45);
   define vdivisa char(2);
   define vdescmon  char(30);
   define vfolio char(16);
   define vpcuentaclabe char(18);
   define vanio, vmes smallint;
   define vexiste char(1);


   let vconta=0;
   let vcod_ret="000";
   let vtransacc=" ";
   let vdocto=0;
   let vfecha=" ";
   let vmonto=0;
   let vsaldo=0;
   let vsdo_mesant=0;
   let vnombre=" ";
   let vciclo=0;
   let vreferencia = " ";
   let vdescripmo = "";
   let vdescripro  = "";
   let vpcuentaclabe  = "";
   let vproducto = "";
   let vnomprod = "";
   let vdivisa = "";
   let vdescmon = "";
   let vnum_cte = "";
   let venvdir = "";
   let vsaldo_disp = 0;
   let vanio = paniomes[1,4];
   let vmes = paniomes[5,6];
   begin
      on exception set sql_err
         if sql_err <> 0 then
            let vcod_ret = sql_err;
            return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
                   vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
                   vnum_cte,vreferencia,vdescripmo,vdescripro,vpcuentaclabe;
         end if
      end exception;

   select 1 into vexiste
      from sc_maehis
      where empresa = pempresa and cuenta = pcuenta and
            aniomes = paniomes;

   if vexiste = 1 then
      select sdo_actual,sdo_mes_ant,envio_direcc,num_cte,apell_paterno,
             apell_materno,nombre1,nombre2,razon_social,
             (sdo_actual-sdo_retenido-sdo_cong),mc.producto,
             pr.nombre,pr.divisa,di.descripcion,cuenta_clabe
         into vsaldo,vsdo_mesant,venvdir,vnum_cte,vpaterno,
             vmaterno,vnombre1,vnombre2,vrazon,vsaldo_disp,
             vproducto,vnomprod,vdivisa,vdescmon,vpcuentaclabe
         from sc_maehis mc,outer bdinteg:si_cliente cl,
              sc_producto pr,bdinteg:si_divisas di
         where mc.empresa = pempresa and mc.cuenta=pcuenta and
               aniomes = paniomes
               and pr.empresa = mc.empresa and pr.producto=mc.producto
               and di.empresa = mc.empresa and di.divisa=pr.divisa
               and mc.num_cte=cl.numcte;
   else
      select sdo_actual,sdo_mes_ant,envio_direcc,numcte,apell_paterno,
             apell_materno,nombre1,nombre2,razon_social,
             (sdo_actual-sdo_retenido-sdo_cong),mc.producto,
             pr.nombre,pr.divisa,di.descripcion,cuenta_clabe
         into vsaldo,vsdo_mesant,venvdir,vnum_cte,vpaterno,
              vmaterno,vnombre1,vnombre2,vrazon,vsaldo_disp,
              vproducto,vnomprod,vdivisa,vdescmon,vpcuentaclabe
         from sc_maechq mc,sc_maenoc mn,outer bdinteg:si_cliente cl,
              sc_producto pr,bdinteg:si_divisas di
         where mc.empresa = pempresa and mc.cuenta=pcuenta
               and pr.empresa = mc.empresa and pr.producto=mc.producto
               and di.empresa = mc.empresa and di.divisa=pr.divisa
               and mn.empresa = mc.empresa and mn.cuenta=mc.cuenta
               and mc.num_cte=cl.numcte;
   end if
   let vdescripro = vproducto||" "||vnomprod;
   let vdescripmo = vdivisa||" "||vdescmon;
   if vsaldo is null then
      let vsaldo_disp = 0;
      let vcod_ret="100";
      return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
             vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
                vnum_cte,vreferencia,vdescripmo,vdescripro,vpcuentaclabe;
   else
      if vrazon is null or vrazon=" " then
         let vnombre = trim(vnombre1)||" "||trim(vnombre2)||" "||
                       trim(vpaterno)||" "||trim(vmaterno);
      else
         let vnombre=vrazon;
      end if;
      let vnombre = trim(vnombre);
   end if;

   -- Extrae los movimientos mensuales
   foreach
      select fech_alt,num_serial,fech_hor,descripcion,num_cheq,monto_tot,
             naturaleza,transacc,referencia,folio_suc
             into vfecha,vserial,vhora,vtransacc,vdocto,vmonto,
             vnaturaleza,x_transacc,vreferencia,vfolio
      from sc_movhis mm,bdinteg:si_transacc tr
      where mm.empresa = pempresa and cuenta = pcuenta  and
            aniomes = paniomes and cancelad not in ("V","S") and
            tr.empresa = mm.empresa and numero = mm.transacc and
            se_emite_edocta = "S"
      order by fech_alt,num_serial
      if vmonto < 0 then
         let vtransacc = "REV "||trim(vtransacc);
      end if
      if vnaturaleza="C" or x_transacc = "3320"  then
         let vmonto=(vmonto*(-1));
      end if
      let vciclo = vciclo+1;
      if vciclo <= pultmovto then
         continue foreach;
      end if
      if vreferencia is null or vreferencia = " " then
         let vreferencia = vfolio;
      end if
      return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
             vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
                vnum_cte,vreferencia,vdescripmo,vdescripro,vpcuentaclabe
             with resume;
      let vconta=vconta+1;
   end foreach;

   -- Extrae los movimientos diarios
   foreach
      select fech_alt,num_serial,fech_hor,descripcion,num_cheq,
             monto_tot,naturaleza,transacc,referencia,folio_suc
         into vfecha,vserial,vhora,vtransacc,vdocto,
             vmonto,vnaturaleza,x_transacc,vreferencia,vfolio
         from sc_movdia md,bdinteg:si_transacc tr
         where md.empresa = pempresa and md.cuenta = pcuenta and
               year(fech_alt) = vanio and month(fech_alt) = vmes and
               tr.empresa = md.empresa and numero=md.transacc and
               cancelad not in("V","S") and se_emite_edocta = "S"
         order by fech_alt,num_serial
      if vmonto < 0 then
         let vtransacc = "REV "||trim(vtransacc);
      end if
      if vnaturaleza = "C" or x_transacc = "3320"  then
         let vmonto = (vmonto*(-1));
      end if
      let vciclo = vciclo+1;
      if vciclo <= pultmovto then
         continue foreach;
      end if
      if vreferencia is null or vreferencia = " " then
         let vreferencia = vfolio;
      end if
      return vcod_ret,vfecha,vtransacc,vdocto,vmonto,
             vsaldo,vsdo_mesant,vnombre,vsaldo_disp,venvdir,
             vnum_cte,vreferencia,vdescripmo,vdescripro,vpcuentaclabe
      with resume;
      let vconta = vconta+1;
   end foreach;
end
end procedure;