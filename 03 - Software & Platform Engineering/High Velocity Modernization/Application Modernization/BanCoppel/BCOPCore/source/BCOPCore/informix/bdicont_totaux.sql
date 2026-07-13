CREATE PROCEDURE "informix".totaux(pempresa char(3))

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
define pccmayor char(4);
define pccsub char(2);
define pccsubsub char(2);
define pccssubsub char(2);
define pccsssubsub char(2); 
define psector char(2);
define pmoneda char(2);
define psucursal char(4);
define pnro_auxiliar char(12);
define pciudad char(3);

SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/contabilidad/totaux.out";
TRACE ON;                                     

-- ****************************************************************************
-- Inicializa variables de trabajo
-- ****************************************************************************
   let vnaturaleza   = " ";
   let vusuario      = " ";
   let vexiste       = 1;
-- ****************************************************************************
-- Verifica los saldos por dia de auxiliares de una cuenta
-- ****************************************************************************

FOREACH
  SELECT ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector
  INTO   pccmayor,pccsub,pccsubsub,pccssubsub,pccsssubsub,psector
  FROM   bdinteg:si_catalog
  WHERE  empresa=pempresa
  AND    tipo_cuenta='D'
  AND    auxiliar='S'
  --AND    ccmayor=pccmayor
  GROUP BY 1,2,3,4,5,6
  ORDER BY 1,2,3,4,5,6

 SELECT  naturaleza_cta, auxiliar
      INTO vnaturaleza,vauxiliar  
      FROM  bdinteg:si_catalog
      WHERE empresa    = pempresa and
            ccmayor    = pccmayor and
            ccsub      = pccsub and  
            ccsubsub   = pccsubsub and 
            ccssubsub  = pccssubsub and
            ccsssubsub = pccsssubsub and
            sector     = psector;

 FOREACH 	
 SELECT nro_auxiliar,moneda,sucursal,ciudad
 INTO   pnro_auxiliar,pmoneda,psucursal,pciudad
         FROM bdicont:co_historico
         WHERE empresa      = pempresa
           AND ccmayor      = pccmayor   
           AND ccsub        = pccsub
           AND ccsubsub     = pccsubsub   
           AND ccssubsub    = pccssubsub    
           AND ccsssubsub   = pccsssubsub   
           AND sector       = psector
 GROUP BY 1,2,3,4
 ORDER BY 1,2,3,4

-- con lo siguiente garantizo que los cargos y abonos por cuenta se hicieron en el dia correcto
 SELECT min(fecha_valida)
    INTO vfecha_inicio
         FROM bdicont:co_historico
         WHERE empresa      = pempresa
           AND ccmayor      = pccmayor   
           AND ccsub        = pccsub
           AND ccsubsub     = pccsubsub   
           AND ccssubsub    = pccssubsub    
           AND ccsssubsub   = pccsssubsub   
           AND sector       = psector
           AND nro_auxiliar = pnro_auxiliar
           AND moneda       = pmoneda
	   AND sucursal     = psucursal
	   AND ciudad       = pciudad;
	   
let vsaldo_inicio_diar=0;
let vsaldo_fin_de_diar=0;
let vsaldo_acumulado_diar=0;
let vsaldo_acumulado=0;
--determino la fecha en conta
select fecha_hoy into vfecha_hoy from bdicont:co_fechas;
let vdias_acum = 0;
while vfecha_inicio < vfecha_hoy
 let vmes_dia = vfecha_inicio;
 let vnro_abonos_dia = 0;
 let vmonto_abonos = 0;
 let vnro_cargos_dia = 0;
 let vmonto_cargos = 0;
if MONTH(vmes_dia) != MONTH(vfecha_hoy) then
 foreach
 SELECT count(*),sum(monto),naturaleza
 INTO vnro_cargos_dia,vmonto,vnaturalezah
         FROM bdicont:co_historico
         WHERE empresa      = pempresa
           AND ccmayor      = pccmayor   
           AND ccsub        = pccsub
           AND ccsubsub     = pccsubsub   
           AND ccssubsub    = pccssubsub    
           AND ccsssubsub   = pccsssubsub   
           AND sector       = psector
           AND nro_auxiliar = pnro_auxiliar
           AND moneda       = pmoneda
	   AND sucursal     = psucursal
	   AND ciudad       = pciudad
	   AND fecha_valida = vmes_dia
    group by 3
    order by 3,2
    
    if vnaturalezah = "C" then
       let vnro_abonos_dia = vnro_cargos_dia;
       let vmonto_abonos = vmonto;
    else
       let vnro_cargos_dia = vnro_cargos_dia;
       let vmonto_cargos = vmonto;
    end if
 end foreach
else
 foreach
 SELECT count(*),sum(monto),naturaleza
 INTO vnro_cargos_dia,vmonto,vnaturalezah
         FROM bdicont:co_mensual
         WHERE empresa      = pempresa
           AND ccmayor      = pccmayor   
           AND ccsub        = pccsub
           AND ccsubsub     = pccsubsub   
           AND ccssubsub    = pccssubsub    
           AND ccsssubsub   = pccsssubsub   
           AND sector       = psector
           AND nro_auxiliar = pnro_auxiliar
           AND moneda       = pmoneda
	   AND sucursal     = psucursal
	   AND ciudad       = pciudad
	   AND fecha_valida = vmes_dia
    group by 3
    order by 3,2
    
    if vnaturalezah = "C" then
       let vnro_abonos_dia = vnro_cargos_dia;
       let vmonto_abonos = vmonto;
    else
       let vnro_cargos_dia = vnro_cargos_dia;
       let vmonto_cargos = vmonto;
    end if
 end foreach
end if
let vfecha_sig = "";
 SELECT min(fecha_valida)
     INTO vfecha_sig
          FROM bdicont:co_historico
          WHERE empresa      = pempresa
            AND ccmayor      = pccmayor   
            AND ccsub        = pccsub
            AND ccsubsub     = pccsubsub   
            AND ccssubsub    = pccssubsub    
            AND ccsssubsub   = pccsssubsub   
            AND sector       = psector
            AND nro_auxiliar = pnro_auxiliar
            AND moneda       = pmoneda
   	    AND sucursal     = psucursal
   	    AND ciudad       = pciudad
   	    AND fecha_valida > vmes_dia;
if vfecha_sig is null then   	    
 SELECT min(fecha_valida)
     INTO vfecha_sig
          FROM bdicont:co_mensual
          WHERE empresa      = pempresa
            AND ccmayor      = pccmayor   
            AND ccsub        = pccsub
            AND ccsubsub     = pccsubsub   
            AND ccssubsub    = pccssubsub    
            AND ccsssubsub   = pccsssubsub   
            AND sector       = psector
            AND nro_auxiliar = pnro_auxiliar
            AND moneda       = pmoneda
   	    AND sucursal     = psucursal
   	    AND ciudad	     = pciudad
   	    AND fecha_valida > vmes_dia;
end if
if vfecha_sig is null then let vfecha_sig = vmes_dia; end if;
let vdias_acum = vfecha_sig - vmes_dia;
{if vnaturaleza = "D" then  
   let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_cargos - vmonto_abonos);
   let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;
else
   let vsaldo_fin_de_diar = vsaldo_inicio_diar + (vmonto_abonos - vmonto_cargos);
   let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;
end if
let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;}
if MONTH(vmes_dia) != MONTH(vfecha_hoy) then
    select nvl(saldo_fin_de_dia,0),nvl(cargos_dia,0),nvl(abonos_dia,0) 
    into vsaldo_inicio,vcar_dia,vabo_dia
    from bdicont:co_histdiasaux
    where empresa 	= pempresa   	and
        ccmayor 	= pccmayor   	and
        ccsub   	= pccsub     	and
        ccsubsub	= pccsubsub  	and
        ccssubsub	= pccssubsub 	and
        ccsssubsub	= pccsssubsub 	and
        sector		= psector	and
	auxiliar        = pnro_auxiliar and        
        moneda		= pmoneda	and
        sucursal	= psucursal     and
        ciudad          = pciudad	and
        mes_dia		= vmes_dia - 1;

	if vsaldo_inicio is null then
		let vsaldo_inicio = 0;
		--let vsaldo_inicio = 5233.10;
	end if;
	if vnaturaleza = "D" then  
	   let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);
	   let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;
	else
	   let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);
	   let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;
	end if
	--let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;

       select count(*)
       into vexiste
       from bdicont:co_histdiasaux
       where empresa 	= pempresa   	and
         ccmayor 	= pccmayor   	and
         ccsub   	= pccsub     	and
         ccsubsub	= pccsubsub  	and
         ccssubsub	= pccssubsub 	and
         ccsssubsub	= pccsssubsub 	and
         sector		= psector	and
 	 auxiliar       = pnro_auxiliar and        
         moneda		= pmoneda	and
         sucursal	= psucursal     and
         ciudad		= pciudad	and
         mes_dia	= vmes_dia;                 

    if vexiste > 0 then
	    update bdicont:co_histdiasaux
			 --set saldo_inicio_dia = vsaldo_inicio_diar,
			 set cargos_dia = vmonto_cargos,
			 abonos_dia = vmonto_abonos,
			 nro_cargos_dia = vnro_cargos_dia,
			 nro_abonos_dia = vnro_abonos_dia,
			 saldo_fin_de_dia = vsaldo_fin_de_diar
	       where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia;                 

	    update bdicont:co_histdiasaux
			 set saldo_inicio_dia = vsaldo_inicio
			 --cargos_dia = vmonto_cargos,
			 --abonos_dia = vmonto_abonos,
			 --nro_cargos_dia = vnro_cargos,
			 --nro_abonos_dia = vnro_abonos,
			 --saldo_acumulado = saldo_acumulado + vsaldo_acumulado,
			 --set saldo_fin_de_dia = vsaldo_fin_de_diar
	       where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia;                 

		if vsaldo_inicio = 0 then
		    update bdicont:co_histdiasaux
				 set saldo_acumulado = saldo_fin_de_dia
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		else
		    select nvl(saldo_acumulado,0)
		    into vsaldo_acumulado_diar
		    from bdicont:co_histdiasaux
		    where empresa 	= pempresa   	and
			ccmayor 	= pccmayor   	and
			ccsub   	= pccsub     	and
			ccsubsub	= pccsubsub  	and
			ccssubsub	= pccssubsub 	and
			ccsssubsub	= pccsssubsub 	and
			sector		= psector	and
			auxiliar        = pnro_auxiliar and        
			moneda		= pmoneda	and
			sucursal	= psucursal     and
			ciudad		= pciudad	and
			mes_dia		= vmes_dia - 1;

			if vsaldo_acumulado_diar is null then
				let vsaldo_acumulado_diar = 0;
			end if;

		    update bdicont:co_histdiasaux
				 set saldo_acumulado = saldo_fin_de_dia + vsaldo_acumulado_diar
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		end if;
    else
    	if trim(pnro_auxiliar) != "" then
            insert
            into co_histdiasaux
            values (pempresa,pccmayor,pccsub,pccsubsub,
                    pccssubsub,pccsssubsub,psector,pciudad,
                    psucursal,pnro_auxiliar,pmoneda,vmes_dia,
                    vmonto_cargos,vmonto_abonos,vnro_cargos_dia,
                    vnro_abonos_dia,0,
                    0,0,
                    vsaldo_inicio,vsaldo_fin_de_diar);

		if vsaldo_inicio = 0 then
		    update bdicont:co_histdiasaux
				 set saldo_acumulado = saldo_fin_de_dia
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		else
		    select nvl(saldo_acumulado,0)
		    into vsaldo_acumulado_diar
		    from bdicont:co_histdiasaux
		    where empresa 	= pempresa   	and
			ccmayor 	= pccmayor   	and
			ccsub   	= pccsub     	and
			ccsubsub	= pccsubsub  	and
			ccssubsub	= pccssubsub 	and
			ccsssubsub	= pccsssubsub 	and
			sector		= psector	and
			auxiliar        = pnro_auxiliar and        
			moneda		= pmoneda	and
			sucursal	= psucursal     and
			ciudad		= pciudad	and
			mes_dia		= vmes_dia - 1;

			if vsaldo_acumulado_diar is null then
				let vsaldo_acumulado_diar = 0;
			end if;

		    update bdicont:co_histdiasaux
				 set saldo_acumulado = saldo_fin_de_dia + vsaldo_acumulado_diar
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		end if;
	end if;
    end if;
else
     let vmes_dia = vmes_dia;
     if day(vmes_dia) = 1 then
	     select nvl(saldo_fin_de_dia,0),nvl(cargos_dia,0),nvl(abonos_dia,0) 
	     into vsaldo_inicio,vcar_dia,vabo_dia
	     from bdicont:co_histdiasaux
	     where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia - 1;
     else
	     select nvl(saldo_fin_de_dia,0),nvl(cargos_dia,0),nvl(abonos_dia,0) 
	     into vsaldo_inicio,vcar_dia,vabo_dia
	     from bdicont:co_diasaux
	     where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia - 1;
     end if;
         
	if vsaldo_inicio is null then
		let vsaldo_inicio = 0;
	end if;
	if vnaturaleza = "D" then  
	   let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_cargos - vmonto_abonos);
	   let vsaldo_acumulado = vmonto_cargos - vmonto_abonos;
	else
	   let vsaldo_fin_de_diar = vsaldo_inicio + (vmonto_abonos - vmonto_cargos);
	   let vsaldo_acumulado = vmonto_abonos - vmonto_cargos;
	end if
	let vsaldo_acumulado = vsaldo_acumulado * vdias_acum;
	
       select count(*)
       into vexiste
       from bdicont:co_diasaux
       where empresa 	= pempresa   	and
         ccmayor 	= pccmayor   	and
         ccsub   	= pccsub     	and
         ccsubsub	= pccsubsub  	and
         ccssubsub	= pccssubsub 	and
         ccsssubsub	= pccsssubsub 	and
         sector		= psector	and
 	 auxiliar       = pnro_auxiliar and        
         moneda		= pmoneda	and
         sucursal	= psucursal     and
         ciudad		= pciudad	and
         mes_dia	= vmes_dia;                 

       let vmes_dia = vmes_dia;
    if vexiste > 0 then
	    update bdicont:co_diasaux
			 --set saldo_inicio_dia = vsaldo_inicio_diar,
			 set cargos_dia = vmonto_cargos,
			 abonos_dia = vmonto_abonos,
			 nro_cargos_dia = vnro_cargos_dia,
			 nro_abonos_dia = vnro_abonos_dia,
			 saldo_fin_de_dia = vsaldo_fin_de_diar
			 --,saldo_acumulado = vsaldo_acumulado
	       where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia;                 

	    update bdicont:co_diasaux
			 set saldo_inicio_dia = vsaldo_inicio
			 --cargos_dia = vmonto_cargos,
			 --abonos_dia = vmonto_abonos,
			 --nro_cargos_dia = vnro_cargos,
			 --nro_abonos_dia = vnro_abonos,
			 --saldo_acumulado = saldo_acumulado + vsaldo_acumulado,
			 --set saldo_fin_de_dia = vsaldo_fin_de_diar
	       where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia;                 

		if vsaldo_inicio = 0 then
		    update bdicont:co_diasaux
				 set saldo_acumulado = saldo_fin_de_dia
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		else
		    select nvl(saldo_acumulado,0)
		    into vsaldo_acumulado_diar
		    from bdicont:co_diasaux
		    where empresa 	= pempresa   	and
			ccmayor 	= pccmayor   	and
			ccsub   	= pccsub     	and
			ccsubsub	= pccsubsub  	and
			ccssubsub	= pccssubsub 	and
			ccsssubsub	= pccsssubsub 	and
			sector		= psector	and
			auxiliar        = pnro_auxiliar and        
			moneda		= pmoneda	and
			sucursal	= psucursal     and
			ciudad		= pciudad	and
			mes_dia		= vmes_dia - 1;

			if vsaldo_acumulado_diar is null then
				let vsaldo_acumulado_diar = 0;
			end if;

		    update bdicont:co_diasaux
				 set saldo_acumulado = saldo_fin_de_dia + vsaldo_acumulado_diar
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		end if;
    else
    	if trim(pnro_auxiliar) != "" then
            insert
            into co_diasaux
            values (pempresa,pccmayor,pccsub,pccsubsub,
                    pccssubsub,pccsssubsub,psector,pciudad,
                    psucursal,pnro_auxiliar,pmoneda,vmes_dia,
                    vmonto_cargos,vmonto_abonos,vnro_cargos_dia,
                    vnro_abonos_dia,0,
                    0,0,
                    vsaldo_inicio,vsaldo_fin_de_diar);

	    update bdicont:co_diasaux
			 --set saldo_inicio_dia = vsaldo_inicio_diar,
			 set cargos_dia = vmonto_cargos,
			 abonos_dia = vmonto_abonos,
			 nro_cargos_dia = vnro_cargos_dia,
			 nro_abonos_dia = vnro_abonos_dia,
			 saldo_fin_de_dia = vsaldo_fin_de_diar
			 --,saldo_acumulado = vsaldo_acumulado
	       where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia;                 

	    update bdicont:co_diasaux
			 set saldo_inicio_dia = vsaldo_inicio
			 --cargos_dia = vmonto_cargos,
			 --abonos_dia = vmonto_abonos,
			 --nro_cargos_dia = vnro_cargos,
			 --nro_abonos_dia = vnro_abonos,
			 --saldo_acumulado = saldo_acumulado + vsaldo_acumulado,
			 --set saldo_fin_de_dia = vsaldo_fin_de_diar
	       where empresa 	= pempresa   	and
		 ccmayor 	= pccmayor   	and
		 ccsub   	= pccsub     	and
		 ccsubsub	= pccsubsub  	and
		 ccssubsub	= pccssubsub 	and
		 ccsssubsub	= pccsssubsub 	and
		 sector		= psector	and
		 auxiliar       = pnro_auxiliar and        
		 moneda		= pmoneda	and
		 sucursal	= psucursal     and
		 ciudad		= pciudad	and
		 mes_dia	= vmes_dia;                 

		if vsaldo_inicio = 0 then
		    update bdicont:co_diasaux
				 set saldo_acumulado = saldo_fin_de_dia
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		else
		    select nvl(saldo_acumulado,0)
		    into vsaldo_acumulado_diar
		    from bdicont:co_diasaux
		    where empresa 	= pempresa   	and
			ccmayor 	= pccmayor   	and
			ccsub   	= pccsub     	and
			ccsubsub	= pccsubsub  	and
			ccssubsub	= pccssubsub 	and
			ccsssubsub	= pccsssubsub 	and
			sector		= psector	and
			auxiliar        = pnro_auxiliar and        
			moneda		= pmoneda	and
			sucursal	= psucursal     and
			ciudad		= pciudad	and
			mes_dia		= vmes_dia - 1;

			if vsaldo_acumulado_diar is null then
				let vsaldo_acumulado_diar = 0;
			end if;

		    update bdicont:co_diasaux
				 set saldo_acumulado = saldo_fin_de_dia + vsaldo_acumulado_diar
		       where empresa 	= pempresa   	and
			 ccmayor 	= pccmayor   	and
			 ccsub   	= pccsub     	and
			 ccsubsub	= pccsubsub  	and
			 ccssubsub	= pccssubsub 	and
			 ccsssubsub	= pccsssubsub 	and
			 sector		= psector	and
			 auxiliar       = pnro_auxiliar and        
			 moneda		= pmoneda	and
			 sucursal	= psucursal     and
			 ciudad		= pciudad	and
			 mes_dia	= vmes_dia;
		end if;
	end if;
    end if;
end if
    let vfecha_inicio = vfecha_inicio + 1 UNITS DAY;
end while;
 END FOREACH;
END FOREACH;
end procedure;