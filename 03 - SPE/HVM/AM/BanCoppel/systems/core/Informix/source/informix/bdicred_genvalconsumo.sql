create procedure "informix".genvalconsumo()
   RETURNING CHAR(5),CHAR(3),CHAR(20),
             MONEY(14,2),MONEY(14,2),MONEY(14,2),
             MONEY(14,2),CHAR(1),INTEGER,CHAR(1);

   define vcodret        char(5);
   define vfecha_hoy     date;
   define vmoneda        char(2);
   define vmonto         decimal(18);
   define vlinea_prod    decimal(18,2);
   define vheader        char(150);
   define vheader1       char(70);
   define vsegmento_pn   char(375);
   define vsegmento1_pn  char(375);
   define vsegmento_pa	 char(326);
   define vsegmento2_pa	 char(326);
   define vsegmento_tl	 char(436);
   define vsegmento3_tl	 char(436);
   define vsegmento4	 char(436);
   define vsegmento5	 char(253);
   define vlongitud	 integer;
   define vapell_paterno char(26);
   define vapell_materno char(26);
   define vnombre1	 char(26);
   define vnombre2	 char(26);
   define vfecha_nac	 date;
   define vano		 char(4);
   define vmes		 char(2);
   define vdia		 char(2);
   define vrfc		 char(13);
   define vfecha_alta	 date;
   define vnacionalidad	 char(3);
   define vresidencia	 char(1);
   define vestado_civil	 char(1);
   define vsexo		 char(1);
   define vcalle	 char(40);
   define vcolonia	 char(40);
   define vdelegacion	 char(40);
   define vestado	 char(2);
   define vcod_postal	 char(10);
   define vnum_credito	 char(25);
   define vtp_linea	 char(1);
   define vdivisa	 char(2);
   define vnum_pagos	 char(5);
   define vfrecuencia	 char(1);
   define vfecha_apertura date;
   define vfecha_pago	 date;
   define vnumcte	 char(20);
   define vencabezado1	 char(4);
   define vversion	 char(2);
   define vclave_usu 	 char(10);
   define vnombre_usu	 char(16);
   define vciclo	 char(2);
   define vfecha_reporte char(8);
   define vuso_futuro	 char(10);
   define vinf_adicional char(98);
   define vsql		 char(200);
   define varchivo	 char(60);
   define i              smallint;
   define vfecha_ini     date;
   define vstatus_cred   char(2);
   define vpago_cap, vpago_int date;
   define vsiglas_edo    char(4);
   define vsigla_div     char(2);
   define vfrecpago      char(1);
   define vmin_cuota,vcuota_cap,vcuota_int smallint;
   define vcuotas_vencap,vcuotas_venint,vcuotas_ven smallint;
   define vmonto_otorgado, vsaldo_vig, vsaldo_venc,
          vsaldo_actual,vmonto_pago decimal(18,2);
   define vfecha_cap, vfecha_int, vfecha_venc, vfecha_pricuo date;
   define vdiasvenc smallint;
   define vmop char(2);
   define vnumreg integer;
   define vempresa char(3);
   define vcapital_vig,vcapital_ven,vinteres_vig,vinteres_ven decimal(18,2);
   define vnum_producto  char(4);
   define vperiodo_plazo char(1);
	 define vnum_periodos  integer;
   define vcalificacion  char(1);



   let vcodret = "000";
   let vempresa = "";
   let vnum_credito = "";
   let vcapital_vig = 0;
   let vcapital_ven = 0;
   let vinteres_vig = 0;
   let vinteres_ven = 0;
   let vnum_producto = "";
   let vperiodo_plazo = "";
	 let vnum_periodos = 0;
   let vcalificacion = "A1";

   let vinf_adicional = "&";

   delete from sd_valconsumo;

   select fecha_hoy into vfecha_hoy
      from bdicred:sd_fechas;

   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));

   let vano = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

   --- Genera registro encabezado
   let vlongitud = 0;
   let vnumreg = 0;
   --insert into sd_valconsumo
   --   values(vnumreg,vheader);

   foreach
     select a.empresa,a.num_credito,a.num_producto,(sdo_no_exig + sdo_capital),sdo_exig_int,
            (monto_vencido + mto_venc_trasp),(sdo_moratorio + mto_venc_tra_int + mto_venc_int)
     into vempresa,vnum_credito,vnum_producto,vcapital_vig,vinteres_vig,vcapital_ven,vinteres_ven
     from sd_maecred a,sd_maesdos b,sd_definicion c
     where a.empresa = b.empresa      and
     a.num_credito   = b.num_credito  and
     a.empresa       = c.empresa      and
     a.num_producto  = c.num_producto and
     c.cod_tipcred   = '02'
     order by a.num_credito
           
		 select periodo_plazo into vperiodo_plazo
		 from sd_definicion
		 where empresa = a.empresa and
		 num_producto  = vnum_producto;
		 
     select max(fecha_pago) into vpago_cap
        from sd_pagocapit
        where num_credito = vnum_credito;
     if vstatus_cred = "FF" then
        if vpago_cap < vfecha_ini then
           continue foreach;
        end if
     end if
     let vsegmento_pn = trim(vempresa)||trim(vnum_credito)||trim(vnum_producto)||trim(vcapital_vig);
     let vsegmento_pn = trim(vsegmento_pn)||trim(vinteres_vig)||trim(vcapital_ven)||trim(vinteres_ven);
     let vsegmento_pn = trim(vsegmento_pn)||trim(vperiodo_plazo);
     let vnumreg = vnumreg + 1;
     insert into sd_valconsumo
        values(vnumreg,vsegmento_pn);

     {select min(num_cuota) into vmin_cuota
        from sd_pagocapit
	where num_credito = vnum_credito and status_cuota = 1 and
              fecha_cuota < vfecha_ini + 2 units month;
     if vmin_cuota is null then
        let vcuota_cap = 0;
     else
        select monto_cuota - monto_real_pag into vcuota_cap
           from sd_pagocapit
           where num_credito = vnum_credito and
    	         num_cuota = vmin_cuota;
     end if
     select min(num_cuota) into vmin_cuota
        from sd_paginter
	where num_credito = vnum_credito and status_cuota = 1 and
              fecha_cuota < vfecha_ini + 2 units month;
     if vmin_cuota is not null then
        let vcuota_int = 0;
     else
        select monto_cuota - monto_real_pag into vcuota_int
           from sd_paginter
           where num_credito = vnum_credito and
    	         num_cuota = vmin_cuota;
     end if
     let vmonto = round(vcuota_cap+vcuota_int,0);
     select max(fecha_pago) into vpago_cap
        from sd_pagocapit
        where num_credito = vnum_credito;
     select max(fecha_pag) into vpago_int
	from sd_paginter
	where num_credito = vnum_credito;
     if vpago_cap > vpago_int then
        let vfecha_pago = vpago_cap;
     else
        let vfecha_pago = vpago_int;
     end if
     let vano = year(vfecha_pago);
     let vmes = lpad(month(vfecha_pago),2,"0");
     let vdia = lpad(day(vfecha_pago),2,"0");
     select monto_otorgado,sdo_no_exig + sdo_capital, -- saldo vig
            sdo_moratorio+mto_venc_tra_int+mto_venc_int+ --interes venc
            mto_venc_trasp + monto_vencido -- capital venc
        into vmonto_otorgado, vsaldo_vig, vsaldo_venc
        from sd_maesdos
        where num_credito = vnum_credito;
     let vsaldo_actual = vsaldo_vig + vsaldo_venc;
     select count(*) into vcuotas_vencap
        from sd_pagocapit
        where num_credito = vnum_credito and status_cuota in(2,7);
     select count(*) into vcuotas_venint
        from sd_paginter
        where num_credito = vnum_credito and status_cuota in(2,7);
     if vcuotas_vencap > vcuotas_venint then
        let vcuotas_ven = vcuotas_vencap;
     else
        let vcuotas_ven = vcuotas_venint;
     end if
     select min(fecha_cuota) into vfecha_cap
        from sd_pagocapit
        where num_credito = vnum_credito and status_cuota in(2,7);
     select min(fecha_cuota) into vfecha_int
        from sd_paginter
        where num_credito = vnum_credito and status_cuota in(2,7);
     if vfecha_cap < vfecha_int then
        let vfecha_venc = vfecha_cap;
     else
        let vfecha_venc = vfecha_int;
     end if
     if vfecha_venc is null then
        let vdiasvenc = 0;
     else
        let vdiasvenc = vfecha_hoy - vfecha_venc + 1;
     end if
     select nvl(sum(a.monto_real_pag + b.monto_real_pag),0)
        into vmonto_pago
        from sd_pagocapit a, sd_paginter b
        where a.num_credito = vnum_credito and
              a.num_credito = b.num_credito;
     select min(fecha_cuota) into vfecha_cap
        from sd_pagocapit
        where num_credito = vnum_credito;
     select min(fecha_cuota) into vfecha_int
        from sd_paginter
        where num_credito = vnum_credito;
     if vfecha_cap < vfecha_int then
        let vfecha_pricuo = vfecha_cap;
     else
        let vfecha_pricuo = vfecha_int;
     end if
     let vnumreg = vnumreg + 1;
     insert into sd_valconsumo
        values(vnumreg,vsegmento3_tl);}
  end foreach

{ let varchivo = "genvalconsumo.sql";

  let vsql = 'echo " unload to xvalconsumo.unl'||" delimiter '|' "||
             '" > '||trim(varchivo);
  system vsql;

  let vsql = 'echo "'||
             "select * from sd_valconsumo order by numreg "||
             '" >> '||trim(varchivo);
  system vsql;

  let vsql = "dbaccess bdicred "||trim(varchivo);
  system vsql;

  let vsql = "sed 's/&/ /g' xvalconsumo.unl > xvalconsumo1.unl ";
  system vsql;

  let vsql = "sed 's/[0-9]*|//g' xvalconsumo1.unl > xvalconsumo2.unl ";
  system vsql;

  let vsql = "sed 's/|//g' xvalconsumo2.unl > xvalconsumo3.unl ";
  system vsql;

  let vsql = "cat xvalconsumo3.unl| tr -d '\n' > valconsumo.txt ";
  system vsql;}
{
  let vsql = "rm xvalconsumo*";
  system vsql;
}
  return vcodret,vempresa,vnum_credito,vcapital_vig,vinteres_vig,vcapital_ven,vinteres_ven,
         vperiodo_plazo,vnum_periodos,vcalificacion;
end procedure;