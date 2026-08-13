CREATE PROCEDURE "informix".asigcobauto()
       RETURNING CHAR(5);       -- Codigo Retorno

DEFINE vcodret           CHAR(5);
DEFINE vsqlerr           INTEGER;
define vcuotasven        smallint;
define vnum_credito      char(20);
define vfecha_hoy        date;
define vmontoven         money(14,2);
define vcapven           money(14,2);
define vintven           money(14,2);
define vsdo_moratorio    money(14,2);
define vproxcuota        date;
define vsucursal         char(4);
define vexiste           char(1);



LET vsqlerr = 0;
LET vcodret = "000";
BEGIN
   ON EXCEPTION
      SET vsqlerr
      LET vcodret = vsqlerr;
      RETURN vcodret;
   END EXCEPTION;

   select fecha_hoy into vfecha_hoy
      from bdicred:sd_fechas;

   foreach
      select  a.num_credito,sucursal,sdo_moratorio
        into  vnum_credito,vsucursal,vsdo_moratorio
        from  bdicred:sd_maecred a, bdicred:sd_maesdos b
       where  status_cred not in("DD","FF") and
              a.num_credito = b.num_credito
      select 1 into vexiste
         from  cb_cobranza
         where num_credito = vnum_credito and
               status_cob in("P","A");
      if vexiste = 1 then
         continue foreach;
      end if
      select min(fecha_cuota) into vproxcuota
         from bdicred:sd_pagocapit
         where num_credito = vnum_credito and
               fecha_cuota > vfecha_hoy and status_cuota <> "5";
      select nvl(sum(monto_cuota - monto_real_pag),0),count(*)
         into vcapven,vcuotasven
         from bdicred:sd_pagocapit
         where num_credito = vnum_credito and
               fecha_cuota = vproxcuota and 
               status_cuota in("2","7");
      if vcuotasven > 0 then
         select nvl(sum(monto_cuota - monto_real_pag),0)
            into vintven
            from bdicred:sd_paginter
            where num_credito = vnum_credito and
                  status_cuota in("2","7");
         let vmontoven = vcapven + vintven + vsdo_moratorio;
      else
         select (a.monto_cuota - a.monto_real_pag) +
                (b.monto_cuota - b.monto_real_pag)
            into vmontoven
            from bdicred:sd_pagocapit a, bdicred:sd_paginter b
            where a.num_credito = vnum_credito and
                  a.fecha_cuota = vproxcuota and
               a.num_credito = b.num_credito;
         let vcuotasven = 0;
          select count(*)
             into vcuotasven
             from bdicred:sd_paginter
             where num_credito = vnum_credito and
               status_cuota in("2","7");
      end if
      if vcuotasven > 0 then
         insert into cb_cobranza
            values(vnum_credito,"","","",
                  vfecha_hoy,"",vcuotasven,vmontoven,0,0,"P");
      end if
   end foreach
   RETURN vcodret;
END
END PROCEDURE;