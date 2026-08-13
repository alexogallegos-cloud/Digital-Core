CREATE PROCEDURE "informix".corrige_saldos(pempresa char(3),pccmayor char(4), 
pccsub char(2), pccsubsub char(2), pccssubsub char(2), pccsssubsub char(2), 
psector char(2),pmoneda char(2),pfecha1 date,pfecha2 date)

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
define vccmayor char(4); 
define vccsub char(2); 
define vccsubsub char(2);
define vccssubsub char(2);
define vccsssubsub char(2);
define vsector char(2);
define vmoneda char(2);
define vsucursal char(4);
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
define pciudad       char(3);
define psucursal     char(4);

--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/contabilidad/corrige_saldos.out";
--TRACE ON;                                     

-- ****************************************************************************
-- Inicializa variables de trabajo
-- ****************************************************************************
   let vnaturaleza   = " ";
   let vusuario      = " ";
   let vexiste       = 1;
   let vcont         = 0;   
-- ****************************************************************************
-- Verifica los saldos por dia de auxiliares de una cuenta
-- ****************************************************************************
foreach
 SELECT  naturaleza_cta, auxiliar,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector
      INTO vnaturaleza,vauxiliar,pccsub,pccsubsub,pccssubsub,pccsssubsub,psector  
      FROM  bdinteg:si_catalog
      WHERE empresa    = pempresa and
            ccmayor    = pccmayor and
            --ccsub      = pccsub and  
            --ccsubsub   = pccsubsub and 
            --ccssubsub  = pccssubsub and
            --ccsssubsub = pccsssubsub and
            --sector     = psector and
            tipo_cuenta='D'
      ORDER BY ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector
            
 foreach
 SELECT mes_dia,ciudad,sucursal
    INTO vfecha_inicio,pciudad,psucursal
         FROM bdicont:co_histsdodias
         WHERE empresa      = pempresa
           AND ccmayor      = pccmayor   
           AND ccsub        = pccsub
           AND ccsubsub     = pccsubsub   
           AND ccssubsub    = pccssubsub    
           AND ccsssubsub   = pccsssubsub   
           AND sector       = psector
           AND moneda       = pmoneda
	   AND mes_dia between pfecha1 and
                               pfecha2
           GROUP BY mes_dia,ciudad,sucursal
           ORDER BY mes_dia,ciudad,sucursal
	   
let vsaldo_inicio_diar=0;
let vsaldo_fin_de_diar=0;
let vsaldo_acumulado_diar=0;
--determino la fecha en conta
select fecha_hoy into vfecha_hoy from bdicont:co_fechas;
let vdias_acum = 0;
--let vfecha_hoy = '12/31/2007';
while month(vfecha_inicio) <> month(vfecha_hoy)
 let vmes_dia = vfecha_inicio;
 let vnro_abonos_dia = 0;
 let vmonto_abonos = 0;
 let vnro_cargos_dia = 0;
 let vmonto_cargos = 0;
 let vfecha_sig = "";
if MONTH(vmes_dia) != MONTH(vfecha_hoy) then
    select nvl(saldo_fin_de_dia,0),nvl(cargos_dia,0),nvl(abonos_dia,0),nvl(saldo_inicio_dia,0),nvl(saldo_acumulado,0)
    into vsaldo_fin_de_diar,vcar_dia,vabo_dia,vsaldo_inicio,vsaldo_acumulado
    from bdicont:co_histsdodias
    where empresa 	= pempresa   	and
        ccmayor 	= pccmayor   	and
        ccsub   	= pccsub     	and
        ccsubsub	= pccsubsub  	and
        ccssubsub	= pccssubsub 	and
        ccsssubsub	= pccsssubsub 	and
        sector		= psector	and
        moneda		= pmoneda	and
        sucursal	= psucursal     and
	ciudad          = pciudad	and
        mes_dia		= vmes_dia - 1;

    if vsaldo_fin_de_diar <> 0 then
	if vnaturaleza = "D" then  
	   let vsaldo_fin_de_diar = vsaldo_inicio + (vcar_dia - vabo_dia);
	else
	   let vsaldo_fin_de_diar = vsaldo_inicio + (vabo_dia - vcar_dia);
	end if
	    {let vsaldo_fin_de_diar=vsaldo_fin_de_diar;
	    let vcar_dia=vcar_dia;
	    let vabo_dia=vabo_dia;
	    let vsaldo_inicio=vsaldo_inicio;
	    let vsaldo_acumulado=vsaldo_acumulado + vsaldo_fin_de_diar;}

	    select count(*)
	    into vcont
	    from bdicont:co_histsdodias
	    where empresa 	= pempresa   	and
		ccmayor 	= pccmayor   	and
		ccsub   	= pccsub     	and
		ccsubsub	= pccsubsub  	and
		ccssubsub	= pccssubsub 	and
		ccsssubsub	= pccsssubsub 	and
		sector		= psector	and
		moneda		= pmoneda	and
		sucursal	= psucursal     and
		ciudad          = pciudad	and
		mes_dia		= vmes_dia;

	    if vcont = 0 then
		insert into co_histsdodias(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,               
		ciudad,sucursal,moneda,mes_dia,cargos_dia,abonos_dia,nro_cargos_dia,nro_abonos_dia,       
		dias_proyectado,dias_acumulado,saldo_acumulado,saldo_inicio_dia,saldo_fin_de_dia)
		values(pempresa,pccmayor,pccsub,pccsubsub,pccssubsub,pccsssubsub,psector,
		pciudad,psucursal,pmoneda,vmes_dia,0,0,0,0,
		0,day(vmes_dia),vsaldo_acumulado+vsaldo_fin_de_diar,vsaldo_fin_de_diar,vsaldo_fin_de_diar);
	    else
		    update bdicont:co_histsdodias
				 set saldo_inicio_dia = vsaldo_fin_de_diar
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad         = pciudad       and
			 mes_dia	= vmes_dia;

		if vnaturaleza = "D" then  
		    update bdicont:co_histsdodias
				     set saldo_fin_de_dia = saldo_inicio_dia + cargos_dia - abonos_dia
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad         = pciudad       and
			 mes_dia	= vmes_dia;

		update bdicont:co_histsdodias
				     set saldo_acumulado = saldo_fin_de_dia + vsaldo_acumulado
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad         = pciudad       and
			 mes_dia	= vmes_dia;
		end if;

		if vnaturaleza = "C" then  
		    update bdicont:co_histsdodias
				 set saldo_acumulado  = vsaldo_acumulado,
				     saldo_fin_de_dia = saldo_inicio_dia - cargos_dia + abonos_dia
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad         = pciudad       and
			 mes_dia	= vmes_dia;

		update bdicont:co_histsdodias
				     set saldo_acumulado = saldo_fin_de_dia + vsaldo_acumulado
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad         = pciudad       and
			 mes_dia	= vmes_dia;
		end if;
	    end if;
	end if;	    
 end if
    let vfecha_inicio = vfecha_inicio + 1 UNITS DAY;
end while;
end foreach;
end foreach;

end procedure;