create procedure "informix".genmovinver(pempresa    char(3),
                                        ptipo_mov   char(1),
                                        pcuenta     char(20),
                                        pmonto      money(14,2),
                                        pdivisa     char(2),
                                        ptransacc   char(4),
                                        preferencia char(40),
                                        pfecha_apli date,
                                        psucursal   char(4),
                                        pusuario    char(8))
       returning char(5);

define vsqlerr     integer;
define vcodret     char(5);
define vsucursal   char(4);
define vusuario    char(8);
define vfecha_hoy  date;
define vproducto   char(4);
define vplaza      char(3);
define vdivisa  char(2);
define vnaturaleza char(1);

let vcodret      = "000";


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
	 let vcodret = vsqlerr;
	 return vcodret;
      end if;
   end exception;

   select fecha_hoy into vfecha_hoy
      from sc_fechas where empresa = pempresa;

   if pcuenta     = " " or pcuenta     is null or
      pmonto      = 0   or pmonto      is null or
      pdivisa     = " " or pdivisa     is null or
      pfecha_apli = " " or pfecha_apli is null or
      ptransacc   = " " or ptransacc   is null then
      let vcodret = "110"; -- Datos insuficientes
      return vcodret;
   end if

   select naturaleza into vnaturaleza
      from bdinteg:si_transacc
      where empresa = pempresa and numero = ptransacc;
   if vnaturaleza is null then
      let vcodret = "550";
      return vcodret;
   end if

   if ptipo_mov <> vnaturaleza then
      let vcodret = "560";
      return vcodret;
   end if

   select producto, plaza into vproducto, vplaza
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;
   if vproducto is null then
      let vcodret = "100";
      return vcodret;
   end if

   select divisa into vdivisa
      from sc_producto
      where empresa = pempresa and producto = vproducto;
   if vdivisa != pdivisa then
      let vcodret = "951";
      return vcodret;
   end if

   insert into sc_movinver
      values(pempresa,ptipo_mov,psucursal,pcuenta,pmonto,pdivisa,"N",
             vfecha_hoy,ptransacc,preferencia,pusuario," ",pfecha_apli,"");

   return vcodret;
end
end procedure;