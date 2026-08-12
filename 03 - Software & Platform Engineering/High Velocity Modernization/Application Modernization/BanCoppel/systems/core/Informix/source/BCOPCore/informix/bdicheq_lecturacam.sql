create procedure "informix".lecturacam(pempresa char(3),
                                       parchivo char(300))
       returning char(5);

define vsqlerr integer;
define vcodret char(5);
define vfecha_hoy date;
define vconreg smallint;
define vsql char(800);
define vsucursal char(4);
define vbanco char(4);
define vremesa char(4);
define vsecuencia integer;
define vcuenta char(20);
define vcheque char(10);
define vimporte money(14,2);
define vtipo_docto char(2);
define vcausa_dev char(3);
define vcodigo_moneda char(2);


begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = "970";
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   select fecha_hoy into vfecha_hoy from sc_fechas where empresa = pempresa;

   select count(*) into vconreg
      from sc_archivos
      where empresa = pempresa and fecha = vfecha_hoy;
   if vconreg = 0 then
        delete from sc_detcam where empresa = pempresa;
   end if

   select count(*) into vconreg from sc_archivos
      where empresa = pempresa and archivo = parchivo and fecha = vfecha_hoy;
   if vconreg > 0 then
      let vcodret = "969";
      return vcodret;
   end if

   delete from sc_camsuc where empresa = pempresa;
   delete from sc_devcam_prev where empresa = pempresa;
   delete from sc_detcam where empresa = pempresa;
   delete from sc_devcam where empresa = pempresa;
   delete from sc_camara where empresa = pempresa;

   let vsql = 'echo "load from ' || trim(parchivo) ||
              ' insert into sc_camsuc "' || ' > query.sql';
   system vsql;
   let vsql = "dbaccess bdicheq query.sql";
   system vsql;

   foreach
      select sucursal,banco,remesa,importe_total
         into vsucursal,vbanco,vremesa,vimporte
         from sc_camsuc
         where empresa = pempresa and tipo_reg = "1"
      insert into sc_camara
         values(pempresa,vsucursal,"CAMARA",vbanco,vremesa,vimporte,
                vimporte,0);
   end foreach

   foreach
      select sucursal,banco,remesa,secuencia,cuenta,cheque,importe,
             tipo_docto,causa_dev,codigo_moneda
         into vsucursal,vbanco,vremesa,vsecuencia,vcuenta,vcheque,vimporte,
             vtipo_docto,vcausa_dev,vcodigo_moneda
         from sc_camsuc
         where empresa = pempresa and tipo_reg = "1"
      insert into sc_detcam
         values(pempresa,vsucursal,"CAMARA",vbanco,vremesa,vsecuencia,vcuenta,
                vcheque,vimporte,vtipo_docto,vcausa_dev,0,1,vcodigo_moneda);
   end foreach

   return vcodret;
end
end procedure;