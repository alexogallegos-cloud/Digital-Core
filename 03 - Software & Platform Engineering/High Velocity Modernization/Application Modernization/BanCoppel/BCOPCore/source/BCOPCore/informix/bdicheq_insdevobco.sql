create procedure "informix".insdevobco(pempresa char(3),
                            pbanco       char(4),
                            pcuenta_obco char(20),
                            pnum_cheq    integer,
                            pmonto_tot   money(14,2),
                            pcausa_dev   char(2),
                            pplaza_inter char(2),
                            pdivisa      char(2),
                            pnumero_dev  smallint,
                            pultima_dev  smallint)
       returning char(5);

define vcodret char(5);
define vtotdev smallint;
define vexiste char(1);
define vsqlerr integer;
define vfechoy date;



let vcodret = "000";

select fecha_hoy into vfechoy
   from sc_fechas where empresa = pempresa;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

   if pbanco is null or pbanco = " " THEN
      let vcodret = "110";
      return vcodret;
   end if

   if pcuenta_obco is null or pcuenta_obco = " " THEN
      let vcodret = "110";
      return vcodret;
   end if

   if pnum_cheq is null or pnum_cheq = 0 THEN
      let vcodret = "110";
      return vcodret;
   end if

   if pmonto_tot is null or pmonto_tot = 0 THEN
      let vcodret = "110";
      return vcodret;
   end if

   if pcausa_dev is null or pcausa_dev = " " THEN
      let vcodret = "110";
      return vcodret;
   end if

   if pplaza_inter is null or pplaza_inter = " " THEN
      let vcodret = "110";
      return vcodret;
   end if

   if pnumero_dev = 1 then
      delete from sc_devotrobcog
         where empresa = pempresa and fecha_alta < vfechoy;
   end if

   select "1" into vexiste
      from sc_devotrobcog
      where empresa = pempresa and numero_dev = pnumero_dev and
            fecha_alta = vfechoy and 
            status_envio = "P";

   if vexiste = "1" then
      delete from sc_devotrobcog
         where empresa = pempresa and numero_dev = pnumero_dev and
               status_envio = "P";
   end if

   insert into sc_devotrobcog
      values(pempresa,pplaza_inter,pcuenta_obco,pmonto_tot,pbanco,pnum_cheq,
             pdivisa,pcausa_dev,vfechoy,pnumero_dev,pultima_dev,"P");

   if pnumero_dev = pultima_dev then
      select count(*) into vtotdev
         from sc_devotrobcog
         where empresa = pempresa and fecha_alta = vfechoy and 
               status_envio = "P";
      if vtotdev = pultima_dev then
         update sc_devotrobcog
            set status_envio = "C"
            where empresa = pempresa and fecha_alta = vfechoy and 
                  status_envio = "P";
         update sc_histcamara
            set motivo_dev = pcausa_dev
            where empresa = pempresa and nro_cuenta = pcuenta_obco  and
                  nro_cheque = pnum_cheq and
                  bco_emisor = pbanco;
      else
         let vcodret = "913";
         return vcodret;
      end if
   end if
   return vcodret;
end
end procedure;