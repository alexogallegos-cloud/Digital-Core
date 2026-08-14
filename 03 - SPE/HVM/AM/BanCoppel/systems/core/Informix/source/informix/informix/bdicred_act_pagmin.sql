create procedure "informix".act_pagmin()
returning char(5);


define vcodret         char(5);
define vNumCredito     char(20);
define vsqlerr         Integer;
define vMtoMin         money(14,2);
define vMtoFinan       money(14,2);
define vDifFinan       money(14,2);
define vmontopago      money(14,2);
define vmontohis       money(14,2);
define vmontodia       money(14,2);

--set debug file to "audita.out";
--trace on;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;




  let vcodret         = "000";
  let vNumCredito     = '';
  let vMtoMin         = 0;
  let  vDifFinan      = 0;
  let  vMtoFinan      = 0;
  let vmontopago      = 0;
  let vmontohis       = 0;
  let vmontodia       = 0;

--Creditos Transitorios


  FOREACH WITH HOLD

        SELECT num_credito,monto INTO vNumCredito,vMtoMin FROM creditos
        BEGIN WORK;

        let vmontopago      = 0;
        let vmontohis       = 0;
        let vmontodia       = 0;

        select nvl(sum(monto),0)
        into vmontohis
        from bdicred:sd_movhis
        where empresa = '001' 
          and num_credito = vNumCredito
          and codigo_fun in ('033','334') and codigo_ref in (7,8,9,10)
          and reversado = 'N'
          and fecha_mov >= '05-21-2008';

        select nvl(sum(monto),0)
        into vmontodia
        from bdicred:sd_movdia
        where empresa = '001' 
          and num_credito = vNumCredito
          and reversado = 'N'
          and codigo_fun in ('033','334') and codigo_ref in (7,8,9,10)
          and fecha_mov >= '05-21-2008';

        let vmontopago = vmontohis + vmontodia;

        UPDATE sd_maesdos SET monto_financiado = vMtoMin - vmontopago,
                                 sdo_trab4     = vMtoMin
        WHERE  num_credito = vNumCredito and empresa = '001';

      COMMIT work;
  END FOREACH;

  RETURN vcodret;
END
end procedure
;