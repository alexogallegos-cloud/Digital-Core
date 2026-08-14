create procedure "informix".aplicacreditos(pempresa char(3))
returning char(5);

DEFINE vcodret       char(5);
DEFINE vNumCredito   char(20);
DEFINE vNumTarjeta   char(20);
DEFINE vFolio        char(20);
DEFINE vTipo         char(1);
DEFINE vReferencia   char(40);
DEFINE vsqlerr       smallint;
DEFINE FechaHoy      date;
DEFINE vMtoPago      decimal(14,2);
DEFINE vMtoIva       decimal(14,2);
DEFINE vRemanente    decimal(14,2);
DEFINE vIntMoraCob   decimal(14,2);
DEFINE vIntVencCob   decimal(14,2);
DEFINE vCapVencCob   decimal(14,2);
DEFINE vIntVigCob    decimal(14,2);
DEFINE vCapVigCob    decimal(14,2);
DEFINE vImpuesto     decimal(14,2);
DEFINE vComision     decimal(14,2);
DEFINE vSeguro       decimal(14,2);
DEFINE i             integer;
DEFINE y             integer;
define vrowid        integer;




-- CONTROL DE ERRORES
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vcodret=vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

--   set debug file to "aplicacredito.out";
--   trace on;

   let vcodret       = "000";
   let vNumCredito   = '';
   let vNumCredito   = '';
   let vFolio        = '';
   let vTipo         = '';
   let vReferencia   = '';
   let vMtoPago      = 0;
   let vMtoIva       = 0;
   let vRemanente    = 0;
   let vIntMoraCob   = 0;
   let vIntVencCob   = 0;
   let vCapVencCob   = 0;
   let vIntVigCob    = 0;
   let vCapVigCob    = 0;
   let vImpuesto     = 0;
   let vComision     = 0;
   let vSeguro       = 0;
   let i             = 1;
   let y             = 0;
   --let vNumCredito = '600000079613';

   SELECT fecha_hoy INTO FechaHoy FROM sd_fechas
   WHERE empresa = pempresa;
--let FechaHoy = FechaHoy + 1 units day;
   SELECT count(*) INTO y FROM creditos;

--   FOR i = 1 to y
   FOREACH with hold
       Select num_tarjeta,a.num_credito,comi,iva, a.rowid  Into vNumTarjeta,vNumCredito,vMtoPago,vMtoIva, vrowid
       From creditos a,
           sd_maecred  b
         where empresa = '001'
         and a.num_credito = b.num_credito
         and status_cred <> 'CV'
         and (b.id_unidad_prod is null or b.id_unidad_prod <> 1)
         and a.status = '0'

       Let vMtoPago = vMtoPago;
       Let vMtoIva  = vMtoIva;
       Let vFolio =  vNumTarjeta;

       begin work;

       CALL principal(pempresa,vNumCredito,1,vMtoPago,'92195491','9250',vFolio,'6814')

        RETURNING vcodret, vRemanente, vIntMoraCob, vIntVencCob,
                  vCapVencCob, vIntVigCob, vCapVigCob, vImpuesto,
                      vComision, vSeguro;
       Let vMtoPago = vMtoPago;
       Let vMtoIva  = vMtoIva;

       IF vcodret not in ('000','008') THEN
          return vcodret;
       END IF;

       IF vcodret = '000' THEN
          update creditos set status = '1' WHERE rowid = vrowid;
       else
          update creditos set status = '2' WHERE rowid = vrowid;
       end if;

       let vcodret = '000';

       commit work;

   END FOREACH;
-- END FOR;
  return vcodret;
END
END PROCEDURE;