create procedure "informix".altatarjeta(pempresa char(3),
                         poperacion     char(1),
                         pcuenta        char(20),
                         pnum_credito   char(20),
                         pprodtarjeta   char(4),
                         pnumcte        char(20),
                         ptarjeta       char(20),
                         pexpiracion    char(4),
                         ptitular       char(1),
                         pnombre        char(60),
                         pno_imss       char(12))
        returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vempresa char(3);
   define vexiste char(1);
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

 
   let vcodret  = "000";

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = user;

   if poperacion = "A" or poperacion = "P" then
      select 1 into vexiste
         from bdinteg:si_cliente
         where numcte = pnumcte;
      if vexiste is null then
         let vcodret = "104";
         return vcodret;
      end if;

      select 1 into vexiste
         from sc_tarjeta
         where empresa = pempresa and tarjeta = ptarjeta;
      if vexiste is not null then
         let vcodret = "405";
         return vcodret;
      end if;

      insert into sc_tarjeta
         values (pempresa,ptarjeta,pnumcte,pprodtarjeta,pcuenta,
                 pnum_credito,pexpiracion,ptitular,pnombre,pno_imss);
   elif poperacion = "M" then
      select 1 into vexiste
         from sc_tarjeta
         where empresa = pempresa and tarjeta = ptarjeta;
      if vexiste is null then
         let vcodret = "100";
         return vcodret;
      end if;
      update sc_tarjeta
         set num_credito = pnum_credito
         where empresa = pempresa and tarjeta = ptarjeta;
   else
      select 1 into vexiste
         from sc_tarjeta
         where empresa = pempresa and tarjeta = ptarjeta;
      if vexiste is null then
         let vcodret = "100";
         return vcodret;
      end if;
      update sc_tarjeta
         set expiracion = pexpiracion
         where empresa = pempresa and tarjeta = ptarjeta;
   end if
   return vcodret;
end
end procedure;