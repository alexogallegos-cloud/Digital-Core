create procedure "informix".concamara(pempresa char(3),
                                 pbco_emisor char(3),
                                 pnro_cuenta char(20),
                                 pnro_cheque char(10),
                                 pultreg     smallint)
   returning char(5),char(3),char(3),date,money(16,2),char(3),integer,
             integer,integer,char(2),integer,char(1),char(8);

   define vcodret char(5);
   define vbco_emisor char(3);
   define vbco_receptor char(3);
   define vfecha_trans date;
   define vimporte money(16,2);
   define vplaza_comp char(3);
   define vdig_inter integer;
   define vdig_premar integer;
   define vcod_segur integer;
   define vmotivo_dev char(2);
   define vplaza_inter integer;
   define vtruncado char(1);
   define vubica_docto char(8);
   define vsqlerr integer;
   define vciclo smallint;


   let vcodret="000";
   let vbco_emisor = " ";
   let vbco_receptor = " ";
   let vfecha_trans = " ";
   let vimporte = 0;
   let vplaza_comp = " ";
   let vdig_inter = 0;
   let vdig_premar = 0;
   let vcod_segur = 0;
   let vmotivo_dev = " ";
   let vplaza_inter = 0;
   let vtruncado = " ";
   let vubica_docto = " ";
   let vciclo = 0;
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret,vbco_emisor,vbco_receptor,vfecha_trans,vimporte,
                vplaza_comp,vdig_inter,vdig_premar,vcod_segur,vmotivo_dev,
                vplaza_inter,vtruncado,vubica_docto;
      end if
   end exception;

   -- Extrae los movimientos
   foreach
      select bco_emisor,bco_receptor,fecha_trans,importe,
             plaza_comp,dig_inter,dig_premar,cod_segur,motivo_dev,
             plaza_inter,truncado,ubica_docto
         into vbco_emisor,vbco_receptor,vfecha_trans,vimporte,
             vplaza_comp,vdig_inter,vdig_premar,vcod_segur,vmotivo_dev,
             vplaza_inter,vtruncado,vubica_docto
         from sc_histcamara
         where empresa = pempresa and nro_cuenta = pnro_cuenta and 
               nro_cheque = pnro_cheque and bco_emisor = pbco_emisor
         order by 3,1
      let vciclo = vciclo+1;
      if vciclo <= pultreg then
         continue foreach;
      end if
      return vcodret,vbco_emisor,vbco_receptor,vfecha_trans,vimporte,
             vplaza_comp,vdig_inter,vdig_premar,vcod_segur,vmotivo_dev,
             vplaza_inter,vtruncado,vubica_docto with resume;
   end foreach;
end
end procedure;