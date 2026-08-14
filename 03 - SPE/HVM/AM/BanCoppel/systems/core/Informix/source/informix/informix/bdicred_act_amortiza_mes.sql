create procedure "informix".act_amortiza_mes()
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

  FOREACH WITH HOLD

        SELECT num_credito 
          INTO vNumCredito
          from bdicred:sd_amortiza_credito 
         where empresa = '001' 
           and fecha_cuota = '01/20/2009' 
           and capital_status = '5' 
           and capital_debe > 0

        BEGIN WORK;

        UPDATE bdicred:sd_amortiza_credito SET capital_status = '1'
        WHERE  num_credito = vNumCredito and empresa = '001' and fecha_cuota = '01/20/2009';

      COMMIT work;
  END FOREACH;

  RETURN vcodret;
END
end procedure;