create procedure "informix".compensa_pos()
returning char(5);

define vsqlerr         Integer;
define vBegin          char(01);
define vempresa        CHAR(03);
define vcodret         char(10);
define vnumcredito     CHAR(20);
define vmonto          DECIMAL(18,2);
define vfolio_suc      CHAR(16) ;
define vfechamov       DATE;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF;
      RETURN vcodret;
   END IF;
END EXCEPTION;

--  set debug file to "compensa_pos.out";
--  trace on;

let vsqlerr = 0;
let vBegin = '';
let vcodret = '000';
let vnumcredito = '';
let vmonto = 0;
let vfolio_suc = '';
let vfechamov = date(0);
let vempresa = null;


--Creditos Vigentes

FOREACH WITH HOLD

  select num_credito, monto, folio_suc, fecha_mov
  into vnumcredito, vmonto, vfolio_suc, vfechamov
  from  sd_aplicaposrev 
  where aplicado = ''
  
  let vempresa = null;

  if vfechamov = mdy('10','05','2008') then
    select empresa into vempresa from bdicred:sd_movhis 
     where empresa = '001' 
       and num_credito = vnumcredito
       and monto = vmonto
       and fecha_mov = vfechamov
       and folio_suc = vfolio_suc;
  else
    select empresa into vempresa from bdicred:sd_movdia
     where empresa = '001' 
       and num_credito = vnumcredito
       and monto = vmonto
       and fecha_mov = vfechamov
       and folio_suc = vfolio_suc;
  end if;
  
  if (vempresa = '001') then
       begin work;
       LET vBegin ="S";

-- Actualiza saldos
       UPDATE bdicred:sd_maesdos 
         SET sdo_capital = sdo_capital - vmonto,
	   	     sdo_cap_insoluto = sdo_cap_insoluto - vmonto,
		     mto_ministra_cap = mto_ministra_cap - vmonto,
             cargos_mes_cap   = cargos_mes_cap - vmonto WHERE empresa = '001' AND num_credito = vnumcredito;

-- Actualiza movimiento
      if vfechamov = mdy('10','05','2008') then
        update bdicred:sd_movhis set reversado = 'S'
         where empresa = '001' 
           and num_credito = vnumcredito
           and monto = vmonto
           and fecha_mov = vfechamov
           and folio_suc = vfolio_suc;
      else
        update bdicred:sd_movdia set reversado = 'S'
         where empresa = '001' 
           and num_credito = vnumcredito
           and monto = vmonto
           and fecha_mov = vfechamov
           and folio_suc = vfolio_suc;
      end if;

-- Actualiza aplicados

        update bdicred:sd_aplicaposrev set aplicado = '1'
         where num_credito = vnumcredito
           and monto = vmonto
           and fecha_mov = vfechamov
           and folio_suc = vfolio_suc;

      COMMIT WORK;
      LET vBegin ="N";

  end if;
   
end foreach

return vcodret;
end
end procedure
;