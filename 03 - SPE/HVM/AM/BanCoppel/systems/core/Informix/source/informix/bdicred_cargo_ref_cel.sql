create procedure "informix".cargo_ref_cel(pnum_tarjeta  char(16),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmtocompra   money(14,2),
                                       pmontoefe    money(14,2),
                                       ptransefe    char(4),
                                       pfolioefe    char(16),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       psucursalcom char(4),
                                       pusuariocom  char(8),
                                       ptrancencom  char(4),
                                       ptransuccom  char(4),
                                       pfolsuccom   char(16),
                                       pcuentacom   char(20),
                                       pchequecom   integer,
                                       pmontocom    money(14,2),
                                       pdivisacom   char(2),
                                       prefercom    char(40),
                                       pbanderacom  char(1),
                                       ptrancomefe  char(4),
                                       ptrascomefe  char(4),
                                       pfolcomefe   char(16),
                                       pchequeefe   integer,
                                       pmtocomefe   money(14,2),
                                       pdivcomefe   char(2),
                                       prefcomefe   char(40))

       returning char(5),char(4),date,money(14,2),money(14,2),
                 char(5),char(4),date,money(14,2),money(14,2);

define vsqlerr int;
define vcodret,vcodret1,vcodretcom char(5);
define vtranret1,vtranret,vtransacc char(4);
define vtiporef char(1);
define vfechoy date;
define vsdodisp money(14,2);
define vcompend money(14,2);
define vmontoret,vtotcom money(14,2);
define vempresa char(3);
define vejecargo char(1);
define vconreg smallint;
define vcuenta char(20);
define vtotiva money(14,2);
define vtasaiva decimal(9,3);
define vivacom money(14,2);
define vtotret money(14,2);
define vsuccta char(4);
define vtraniva char(4);
define vfecapli date;

define vmtoapli money(14,2);


-- set debug file to "/tmp/cargo_ref_cel.out";
-- trace on;

set lock mode to wait 2;
begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
          ROLLBACK WORK; 
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if;
   end exception;

   --set isolation to cursor stability;

   BEGIN WORK;

   let vcodret = "000";
   let vtranret = " ";
   let vsdodisp = 0;
   let vmontoret = 0;
   let vcodretcom = "000";
   let vtotcom = 0;
   let psucursal = "9"||trim(psucursal);
   let psucursalcom = "9"||trim(psucursalcom);

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;

   select fecha_hoy into vfechoy
      from sc_fechas
      where empresa = vempresa;

   let vmontoret = pmtocompra+pmontoefe;
   let vtotcom = pmontocom + pmtocomefe;
   let vfecapli = vfechoy;
   select cuenta into vcuenta
      from sc_tarjeta
      where empresa = vempresa and
            num_tarjeta = pnum_tarjeta;
   if vcuenta is null then
      let vcodret = "100";
      ROLLBACK WORK; 
      return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
             vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
   end if
   select sucursal,sdo_actual-sdo_retenido-sdo_cong
      into vsuccta, vsdodisp
      from sc_maechq
      where empresa = vempresa and cuenta = vcuenta;
   select iva into vtasaiva
      from bdinteg:si_sucursales
      where empresa = vempresa and sucursal = vsuccta;
   if vtasaiva is null then
      let vtasaiva = 0;
   end if
   let vtotiva = vtotcom * vtasaiva;
   let vtotret = pmtocompra + pmontoefe + vtotcom + vtotiva;
   if vsdodisp < vtotret then
      let vcodret = "400";
      ROLLBACK WORK; 
      return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
             vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
   end if

   if pmtocompra > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptransacc,ptransuc,
                   pfolsuc,vcuenta,pcheque,pmtocompra,pdivisa,preferencia,
                   pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
   {      call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if
   end if

   if pmontoefe > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptransefe,ptransuc,
                      pfolioefe,vcuenta,pcheque,pmontoefe,pdivisa,preferencia,
                      pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                          vcuenta,ptransefe)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if
   end if
   if pmontocom > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptrancencom,ptransuccom,
                      pfolsuccom,vcuenta,pchequecom,pmontocom,pdivisacom,
                      prefercom,pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                        vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                        vcuenta,ptransefe)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                        vcuenta,ptrancencom)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      else
         select tran_relac into vtraniva
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptrancencom;
         let vivacom = pmontocom * vtasaiva;
         if vivacom > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,"0000",
                     pfolsuccom,vcuenta,pchequecom,vivacom,pdivisacom,
                     prefercom,pnum_tarjeta,"")
                 returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            if vcodret <> "000" then
               ROLLBACK WORK; 
               {
               call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                                vcuenta,ptransacc)
                    returning vcodret1;
               
               call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                                vcuenta,ptransefe)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                                vcuenta,ptrancencom)
                    returning vcodret1;}
               return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                      vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
            end if
         end if
      end if
   end if
   if pmtocomefe > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptrancomefe,
                      ptrancomefe,pfolcomefe,vcuenta,pchequeefe,
                      pmtocomefe,pdivcomefe,prefcomefe,pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                          vcuenta,ptransefe)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                          vcuenta,ptrancencom)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolcomefe,"A",
                          vcuenta,ptrancomefe)
              returning vcodret1;}
      else
         select tran_relac into vtraniva
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptrancencom;
         let vivacom = pmtocomefe * vtasaiva;
         if vivacom > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,
                      "0000",pfolcomefe,vcuenta,pchequeefe,
                      vivacom,pdivcomefe,prefcomefe,pnum_tarjeta,"")
                 returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            if vcodret <> "000" then
               ROLLBACK WORK; 
              { 
               call reversiontd(vempresa,psucursal,pusuario,pfolcomefe,"A",
                                vcuenta,ptransacc)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                                vcuenta,ptransefe)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                                vcuenta,ptrancencom)
                    returning vcodret1;}
               return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                      vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
            end if
         end if
      end if
   end if
   let vfechoy = vfecapli;
   select sdo_actual-sdo_retenido-sdo_cong into vsdodisp
      from sc_maechq
      where empresa = vempresa and cuenta = vcuenta;
   COMMIT WORK;
   return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
          vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
end
end procedure;