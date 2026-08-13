CREATE PROCEDURE "informix".sp_co_obtiene_movcont(pempresa char(3),pfecha_hoy date,pusuario char(10))
returning char(3);

define vnaturaleza,vnaturalezah,
       vtipo_mov         char(1);
define vciudad           char(3);
define w_empresa         char(3);
define vusuario char(8);
define vpoliza_usuario   char(8);
define vdescripcion      char(50);
define vmonto            money(14,2);
define vvalor_cambio,
       vvalor_div_cambio money(12,7);
define vfecha_captura,
       vfecha_valida     date;
define vsecuencia,vcontrol_poliza   integer;
define v_rowid           integer;
define pfecha_hoy1       date;
define vexiste           integer;
define vccosto_orig      char(4);
define vcargos_dia	 money(18,2);
define vabonos_dia 	 money(18,2);
define vnro_cargos_dia   integer;
define vnro_abonos_dia 	 integer;
define vdias_proyectado  integer;
define vdias_acumulados  integer;
define vsaldo_acumulado  money(18,2);
define vsaldo_inicio_dia money(18,2);
define vsaldo_fin_de_dia money(18,2);
define vsuma_carabo	 money(18,2);
define vmes_dia          date;
define vfecha_sig        date;
define vsaldo_inicio     money(18,2);
define vcar_dia	 	 money(18,2);
define vabo_dia 	 money(18,2);
define pccmayor char(4);
define pccsub char(2);
define pccsubsub char(2);
define pccssubsub char(2);
define pccsssubsub char(2);
define psector char(2);
define pmoneda char(2);
define psucursal char(4);
define vsuc      char(4);
define psistema  char(3);
define pproducto char(4);
define vnro_auxiliar char(12);
define vauxiliar char(1);
define vfecha_hoy        date;
define vfecha_inicio     date;
define vsaldo_acumulador  money(18,2);
define vsaldo_inicio_diar money(18,2);
define vsaldo_fin_de_diar money(18,2);
define vsaldo_acumulado_diar money(18,2);
--define vsaldo_acumulado  money(18,2);
define vdias_acum smallint;
define vmonto_abonos money(18,2);
define vmonto_cargos money(18,2);
define vcont         int;
define vcod_ret      char(3);


--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/contabilidad/08oct2008/obtiene_movcontables.out";
--TRACE ON;

-- ****************************************************************************
-- Inicializa variables de trabajo
-- ****************************************************************************
   let vnaturaleza   = " ";
   let vusuario      = " ";
   let vexiste       = 1;
   let vcont         = 0;
   let vcod_ret      = "000";
-- ****************************************************************************
-- Verifica los saldos por dia de auxiliares de una cuenta
-- ****************************************************************************

  {SELECT  naturaleza_cta, auxiliar
      INTO vnaturaleza,vauxiliar
      FROM  bdinteg:si_catalog
      WHERE empresa    = pempresa and
            ccmayor    = pccmayor and
            ccsub      = pccsub and
            ccsubsub   = pccsubsub and
            ccssubsub  = pccssubsub and
            ccsssubsub = pccsssubsub and
            sector     = psector and
            empresa    = pempresa;}

delete from co_conciliamovs
where sistema='07'
and empresa=pempresa
and fecha=pfecha_hoy
and usuario_alta=pusuario;

select fecha_hoy into vfecha_hoy from bdicont:co_fechas;

let vsaldo_inicio_diar=0;
let vsaldo_fin_de_diar=0;
let vsaldo_acumulado_diar=0;
--determino la fecha en conta
let vdias_acum = 0;
--let vfecha_hoy = '12/31/2007';
 let vmes_dia = pfecha_hoy;
 let vnro_abonos_dia = 0;
 let vmonto_abonos = 0;
 let vnro_cargos_dia = 0;
 let vmonto_cargos = 0;

foreach
	 SELECT empresa,sistema,producto,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,moneda
	 INTO   pempresa,psistema,pproducto,pccmayor,pccsub,pccsubsub,pccssubsub,pccsssubsub,psector,pmoneda
	 FROM   bdicont:co_catctaconcil
     WHERE  sistema = '01' -- Cometado para Generar Solo Cheques
	 GROUP BY empresa,sistema,producto,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,moneda
	 ORDER BY empresa,sistema,producto,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,moneda

	if YEAR(pfecha_hoy)  = YEAR(vfecha_hoy)  AND
	   MONTH(pfecha_hoy) = MONTH(vfecha_hoy) then
	   foreach
		 SELECT sucursal,naturaleza
		 INTO psucursal,vnaturalezah
		 FROM bdicont:co_mensual
		 WHERE empresa      = pempresa
		   AND ccmayor      = pccmayor
		   AND ccsub        = pccsub
		   AND ccsubsub     = pccsubsub
		   AND ccssubsub    = pccssubsub
		   AND ccsssubsub   = pccsssubsub
		   AND sector       = psector           
		   AND fecha_valida = pfecha_hoy
           AND moneda       = pmoneda
		   group by 1,2

                 let psucursal=psucursal;
                 let vnaturalezah=vnaturalezah;

                 SELECT sum(monto)
                 INTO   vmonto
			 FROM bdicont:co_mensual
			 WHERE empresa      = pempresa
			   AND ccmayor      = pccmayor
			   AND ccsub        = pccsub
			   AND ccsubsub     = pccsubsub
			   AND ccssubsub    = pccssubsub
			   AND ccsssubsub   = pccsssubsub
			   AND sector       = psector
               AND sucursal     = psucursal
               AND naturaleza   = vnaturalezah
               AND fecha_valida = pfecha_hoy
               AND moneda       = pmoneda;
			   

		INSERT INTO co_conciliamovs(empresa,sistema,fecha,transac,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
		sucursal,moneda,naturaleza,producto,monto,usuario_alta,fecha_alta)
		VALUES(pempresa,'07',pfecha_hoy,'0000',pccmayor,pccsub,pccsubsub,pccssubsub,pccsssubsub,psector,psucursal,
		pmoneda,vnaturalezah,pproducto,vmonto,pusuario,current);
	   end foreach;
	else
	   foreach
		 SELECT sucursal,naturaleza
		 INTO psucursal,vnaturalezah
		 FROM bdicont:co_historico
		 WHERE empresa      = pempresa
		   AND ccmayor      = pccmayor
		   AND ccsub        = pccsub
		   AND ccsubsub     = pccsubsub
		   AND ccssubsub    = pccssubsub
		   AND ccsssubsub   = pccsssubsub
		   AND sector       = psector	   
		   AND fecha_valida = pfecha_hoy
           AND moneda       = pmoneda
		   group by 1,2

                 let psucursal=psucursal;
                 let vnaturalezah=vnaturalezah;

		 SELECT sum(monto)
		 INTO   vmonto
		 FROM bdicont:co_historico
		 WHERE empresa      = pempresa
		   AND ccmayor      = pccmayor
		   AND ccsub        = pccsub
		   AND ccsubsub     = pccsubsub
		   AND ccssubsub    = pccssubsub
		   AND ccsssubsub   = pccsssubsub
		   AND sector       = psector
           AND ciudad  IS NOT NULL
		   AND sucursal     = psucursal
           AND nro_auxiliar IS NOT NULL
		   AND fecha_valida = pfecha_hoy
           AND moneda       = pmoneda
           AND naturaleza   = vnaturalezah;

		INSERT INTO co_conciliamovs(empresa,sistema,fecha,transac,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
		sucursal,moneda,naturaleza,producto,monto,usuario_alta,fecha_alta)
		VALUES(pempresa,'07',pfecha_hoy,'0000',pccmayor,pccsub,pccsubsub,pccssubsub,pccsssubsub,psector,psucursal,
		pmoneda,vnaturalezah,pproducto,vmonto,pusuario,current);
	   end foreach;
	end if;
end foreach;

return vcod_ret;

end procedure;