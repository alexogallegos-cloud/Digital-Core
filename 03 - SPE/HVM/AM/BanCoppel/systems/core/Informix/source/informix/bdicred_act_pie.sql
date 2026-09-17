create procedure "informix".act_pie(pempresa char(3))
returning char(5);


define vcodret         char(5);
define vNumCredito     char(20);
define vsqlerr         Integer;
define vMtoMin         money(14,2);
define vMtoFinan       money(14,2);
define vDifFinan       money(14,2);


-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

  --set debug file to "audita.out";
  --trace on;



  let vcodret         = "000";
  let vNumCredito     = '';
  let vMtoMin         = 0;
  let  vDifFinan      = 0;
  let  vMtoFinan      = 0;

--Creditos Transitorios

  FOREACH WITH HOLD
        SELECT num_credito INTO vNumCredito FROM sd_pie_edocta WHERE fecha_emision = '05/20/2008'
        BEGIN WORK;

        UPDATE sd_pie_edocta SET dias_periodo = '30'
        WHERE fecha_emision = '05/20/2008' and num_credito = vNumCredito;
        COMMIT work;
  END FOREACH;

  RETURN vcodret;
END
end procedure
;