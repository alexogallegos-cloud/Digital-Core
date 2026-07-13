create procedure "informix".condevobco(pempresa char(3),
                                  pplaza_inter  char(3),
                                  pdivisa       char(2),
                                  psecuencia    smallint)
   returning char(5),char(4), char(20),char(10),money(14,2),char(2);

-- ****************************** Definicion de Variables *********************
   define vcodret          char(5);
   define vsecuencia       smallint;
   define vbanco           char(4);
   define vcuenta_obco     char(20);
   define vnum_cheq        char(10);
   define vmonto_tot       money(14,2);
   define vcausa_dev       char(2);
   define vsqlerr          integer;


begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vbanco,vcuenta_obco,vnum_cheq,vmonto_tot,vcausa_dev;
      end if;
   end exception;

   let vcodret = "000";
   let vsecuencia = 0;
   let vbanco = " ";
   let vcuenta_obco = " ";
   let vnum_cheq = " ";
   let vmonto_tot = 0;
   let vcausa_dev = " ";

   foreach
      select banco,cuenta_obco,num_cheq,monto_tot,causa_dev
         into vbanco,vcuenta_obco,vnum_cheq,vmonto_tot,vcausa_dev
         from sc_devotrobcog
         where empresa = pempresa and plaza_inter = pplaza_inter and
               divisa = pdivisa and status_envio = "C"
         order by banco
      let vsecuencia = vsecuencia + 1;
      if vsecuencia <= psecuencia then
         continue foreach;
      end if
      return vcodret,vbanco,vcuenta_obco,vnum_cheq,
             vmonto_tot,vcausa_dev with resume;
   end foreach
end
end procedure;