CREATE PROCEDURE "informix".reptarjetacredpago(psucursal char(4),
                                               pfecini char(10),
                                               pfecfin char(10))
RETURNING CHAR(5),char(20), char(20), char(20), money, char(4), date, char(30), char(40);

DEFINE vsqlerr        int;
DEFINE vcodret        CHAR(5);
DEFINE vnum_tarjeta   CHAR(20);
DEFINE vnumcte        CHAR(20);
DEFINE vstatus        CHAR(1);
DEFINE vdescripcion   CHAR(20);
DEFINE vsucursal      CHAR(4);
DEFINE vmonto         MONEY;
DEFINE vfecha         date;
DEFINE vnomempresa    CHAR(30);
DEFINE vnomsuc        CHAR(40);


begin
   --SET DEBUG FILE TO "/tmp/reptarjetacredpago.out";
   --TRACE ON;

   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
        RETURN vcodret,'', '', '', 0, '',null,'','';
      end if;
   end exception;

-- Inicializa variables
   LET vcodret        = "000";
   LET vnum_tarjeta   = "";
   LET vnumcte        = "";
   LET vstatus        = "";
   LET vmonto         = 0;
   LET vsucursal      = '0000';
   LET vdescripcion   = '';
   LET vfecha         = current;

       FOREACH 
          SELECT tar.num_tarjeta, 
                 tar.numcte,
                 doc.cancelado,
                 doc.monto,
                 doc.sucursal,
                 doc.fecha_alta,
                 emp.razon_social,
                 suc.nombre
            INTO vnum_tarjeta,
                 vnumcte ,
                 vstatus ,
                 vmonto ,
                 vsucursal,
                 vfecha ,
                 vnomempresa,
                 vnomsuc
            FROM sc_docret doc, bdicred:sd_tarjeta tar, bdinteg:si_empresas emp,
                 bdinteg:si_sucursales suc
           WHERE doc.siglas = 'SD'
             AND doc.empresa = tar.empresa
             AND doc.cuenta = tar.num_tarjeta
             AND doc.sucursal = DECODE(length(psucursal),4,psucursal,doc.sucursal) 
             AND fecha_alta >= pfecini
             AND fecha_alta <= pfecfin
             AND doc.empresa = emp.empresa
             AND doc.sucursal = suc.sucursal
			UNION
          SELECT tar.num_tarjeta, 
                 tar.numcte,
                 doc.cancelado,
                 doc.monto,
                 doc.sucursal,
                 doc.fecha_alta,
                 emp.razon_social,
                 suc.nombre
            FROM sc_docret_sbc doc, bdicred:sd_tarjeta tar, bdinteg:si_empresas emp,
                 bdinteg:si_sucursales suc
           WHERE doc.siglas = 'SD'
             AND doc.empresa = tar.empresa
             AND doc.cuenta = tar.num_tarjeta
             AND doc.sucursal = DECODE(length(psucursal),4,psucursal,doc.sucursal) 
             AND fecha_alta >= pfecini
             AND fecha_alta <= pfecfin
             AND doc.empresa = emp.empresa
             AND doc.sucursal = suc.sucursal
			 UNION
          SELECT tar.num_tarjeta, 
                 tar.numcte,
                 doc.cancelado,
                 doc.monto,
                 doc.sucursal,
                 doc.fecha_alta,
                 emp.razon_social,
                 suc.nombre
            FROM sc_docret_pos doc, bdicred:sd_tarjeta tar, bdinteg:si_empresas emp,
                 bdinteg:si_sucursales suc
           WHERE doc.siglas = 'SD'
             AND doc.empresa = tar.empresa
             AND doc.cuenta = tar.num_tarjeta
             AND doc.sucursal = DECODE(length(psucursal),4,psucursal,doc.sucursal) 
             AND fecha_alta >= pfecini
             AND fecha_alta <= pfecfin
             AND doc.empresa = emp.empresa
             AND doc.sucursal = suc.sucursal
			 

           IF vstatus = 'S' THEN
              LET vdescripcion = 'CANCELADO'; 
           ELIF vstatus = 'D' THEN
              LET vdescripcion = 'DEVUELTO'; 
           ELIF vstatus = 'T' THEN
              LET vdescripcion = 'TRANSITO'; 
           ELIF vstatus = 'L' THEN
              LET vdescripcion = 'LIBERADO'; 
           ELSE
              LET vdescripcion = 'OTRO'; 
           END IF;
            
           RETURN vcodret,vnum_tarjeta, vnumcte, vdescripcion, vmonto, vsucursal, vfecha, vnomempresa, vnomsuc WITH RESUME;
       END FOREACH;

END
END procedure;