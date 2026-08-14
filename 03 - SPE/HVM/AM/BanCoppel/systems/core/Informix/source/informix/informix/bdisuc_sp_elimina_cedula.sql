CREATE PROCEDURE "informix".sp_elimina_cedula()
	RETURNING CHAR(6) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
--DEFINE cDato CHAR(2);

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '000000';
--LET cDato = '';

--SET DEBUG FILE TO '/tmp/sp_Pruebas.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	
	TRUNCATE TABLE bdisuc:'informix'.ss_arqueo_panamericano;

	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Borra el contenido de la tabla ss_arqueo_panamericano',
'AUTOR : Dulce Ramirez',
'FECHA : 15/Jul/2013',
'VERSION: 1.0',
'BD: BDISUC';

create procedure "informix".sp_grabacedulacontable(d_fecha date, parametro INTEGER,caja CHAR(4),pSobrante MONEY(16,2),pFaltante MONEY(16,2),pComen CHAR(300))

-- ************************************************************************
-- * Versión:              1.0.0                                          *
-- * Objetivo:             Genera el reporte de Cédula Contable Caja Gral.*
-- * Creado por:           Jeaneth Isamar Montoya Romo                    *
-- * Fecha de Elaboración: 17 de Mayo del 2013				  *
-- * Modificado por:                              			  *
-- * Ultima Modificacion:                                                 *
-- ************************************************************************
RETURNING char(5), char(30);	

-- ***************************
-- * DEFINICIÓN DE VARIABLES *
-- ***************************
define vcaja char(4);
define vpSobrante money (16,2);
define vpFaltante money (16,2);
define vpComen char(300);
define vplaza char(30);
define vcst_costo char(4);
define d1 CHAR(18);
define d2 CHAR(18);
define d3 CHAR(18);
define d4 CHAR(18);
define d5 CHAR(18);
define d6 CHAR(18);
define c1d FLOAT;
define c2d FLOAT;
define c3d FLOAT;
define c4d FLOAT;
define c5d FLOAT;
define c6d FLOAT;
define codi char(4);
define vsuc char(10);
define vsaldot money(18,2);
define vsld_asignado money (18,2);
define vsld_disponible money(18,2);
define vbill_det money(18,2);
define vmont_dotatm money(18,2);
define vmont_dotsuc money(18,2);
define vcon_atm money;
define vcon_suc money;
define vfecha date;	
define vfecha2 date;
define vsaldo money(18,2);
define vmonto_teso money;
define vsaldo_ante money(18,2);
define vfecha3 date;
define vcorreccionsob money(18,2);
define vcorreccionfalt money(18,2);
define vtotalentradas money(18,2);
define vtotalsalidas money(18,2);
define vdeposito_teso money (18,2);
define vdife_entra money(18,2);
define vsaldo_final money (18,2);
define vsaldoayer_hoy money (18,2);
define vsobrante money (18,2);
define vdot money (18,2);
define vremanent_atm money (18,2);
define vcompra money (18,2);
define vventa money (18,2);
define vdif_etv money(18,2);
define vdif_dia_ant money(18,2);
define vdif_dia_hoy money(18,2);
define vdif_ayer_hoy money(18,2);
define vsaldofin money(18,2);
define vmensaje char(40);
DEFINE vcodret CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
define vparametro INTEGER;
DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
define vfecha_ultima date;

--SET debug file  to "reportecedula_isa.out";
--trace on;

-- ***************************
-- * CONTROL DE ERRORES		 *
-- ***************************
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET vmensaje  = ERROR_INFO;
      RETURN vcodret, vmensaje;
   END EXCEPTION;
 
-- *******************************
-- * INICIALIZACIÓN DE VARIABLES *
-- *******************************
let vcaja=caja;
let vpSobrante=pSobrante;
let vpFaltante=pFaltante;
let vpComen=pComen; 
let vplaza='';
let vcst_costo='';
let vfecha = d_fecha;
let d1 = '';
let d2 = '';
let d3 = '';
let d4 = '';
let d5 = '';
let d6 = '';
let c1d = 0;
let c2d = 0;
let c3d = 0;
let c4d = 0;
let c5d = 0;
let c6d = 0;
let codi = '';
let vsaldot = 0;
let vsld_asignado = 0;
let vsld_disponible =0;
let vbill_det = 0;
let vmont_dotatm =0;
let vmont_dotsuc=0;
let vcon_atm =0; 
let vcon_suc =0;
let vfecha2=vfecha-1;
let vsaldo = 0;
let vmonto_teso = 0;
let vfecha3 = 0;
let vsaldo_ante=0;
let vcorreccionsob=0;
let vcorreccionfalt=0;
let vtotalentradas =0;
let vtotalsalidas=0;
let vdeposito_teso=0;
let vdife_entra=0;
let vsaldo_final =0;
let vsaldoayer_hoy = 0;
let vsobrante = 0;
let vdot = 0;
let vremanent_atm = 0;
let vcompra= 0;
let vventa = 0;
let vdif_etv=0;
let vdif_dia_ant=0;
let vdif_dia_hoy=0;
let vdif_ayer_hoy =0;
let vsaldofin =0;
let vmensaje ='';
LET vcodret = "000";
let vparametro = parametro;
let vfecha_ultima ='01/01/1900';


if vparametro = 2 then

        select min(fecha_diant) into vfecha_ultima 
		from table  (multiset(
		SELECT first 2 distinct(fecha) as fecha_diant 
		FROM bdisuc:ss_reportecedula order by fecha desc));                                                                                                                                                                                   


	if vcaja = 'Todo' then	
		delete {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
		from bdisuc:"informix".ss_reportecedula where fecha = vfecha;
			
		insert into bdisuc:"informix".ss_reportecedula (plaza,saldo_anterior,concentraciones,sobrante,faltante,dotacion_devuelta,arq_dot_suc,
		compra,ventas,remanent_atm,arq_dot_atm,fecha,correccion_falt,correccion_sob,comentarios)
		select * from ss_arqueo_panamericano;
	else
		
		update bdisuc:"informix".ss_reportecedula 
		set correccion_falt = vpFaltante ,correccion_sob = vpSobrante ,comentarios = vpComen
		where fecha = vfecha and centro_costo = vcaja;
			
	end if;
else
	
	SELECT max(fecha)
	into vfecha_ultima
	FROM bdisuc:"informix".ss_reportecedula;
	
	insert into bdisuc:"informix".ss_reportecedula (plaza,saldo_anterior,concentraciones,sobrante,faltante,dotacion_devuelta,arq_dot_suc,
	compra,ventas,remanent_atm,arq_dot_atm,fecha,correccion_falt,correccion_sob,comentarios)
	select * from ss_arqueo_panamericano;
	
end if;
	
	set isolation to dirty read;
-- *******************************
-- * Columna 3: Centro de Costo  *
-- *******************************	
foreach				
		select {+INDEX(bdisuc:"informix".ss_proveedores_etv idx_descripcion)}
		a.plaza, b.cod_proveedor
		into vplaza, vcst_costo
		from bdisuc:"informix".ss_reportecedula a, bdisuc:"informix".ss_proveedores_etv b
		where b.descripcion = a.plaza
		
		update "informix".ss_reportecedula
		set  centro_costo = vcst_costo
		where plaza = vplaza and fecha = vfecha;
		
end foreach; 
-- **************************************
-- * Columna 4: Saldo anterior contable *
-- **************************************			
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	fecha, centro_costo,saldo_final_conta
	into vfecha3,  codi, vsaldo_ante
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha_ultima

	update bdisuc:"informix".ss_reportecedula	
	set saldo_cont_ante = vsaldo_ante
	where fecha = vfecha and centro_costo = codi; 
end foreach;
-- **************************************
-- * Columna 5: Saldos Anterior SIF 	*
-- **************************************			
FOREACH 
select  cod_proveedor, saldo_total, denominacion_1, denominacion_2, denominacion_3, denominacion_4, denominacion_5, denominacion_6,  
cantidad_1d, cantidad_2d, cantidad_3d, cantidad_4d, cantidad_5d, cantidad_6d,saldo_asignado , vfecha as vfecha3
into   codi, vsaldot,d1,d2,d3,d4,d5,d6,c1d,c2d,c3d,c4d,c5d,c6d,vsld_asignado, vfecha3
from bdisuc:ss_cajageneral 

		let vbill_det = ((d1*c1d)+(d2*c2d)+(d3*c3d)+(d4*c4d)+(d5*c5d)+(d6*c6d));

		let vsaldot =vsaldot + vsld_asignado;
		let vsld_asignado = vsld_asignado - vbill_det;
		let vsld_disponible = vsaldot - (vsld_asignado + vbill_det);

update bdisuc:"informix".ss_reportecedula	
set saldo_ante_sif = vsld_disponible
where codi = centro_costo and fecha = vfecha3; 
end  FOREACH;	

-- **************************************
-- * Columna 6: Concentracion ATM		*
-- **************************************	
---NO SE PUEDE LAS DIFERENCIAS
FOREACH
	 SELECT {+INDEX(bdisuc:"informix".ss_operaciones idx03_operaciones)}
	 sum(b.monto), b.cod_proveedor, vfecha as fecha3
	 INTO vcon_atm, codi, vfecha3
	FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores_etv d
	WHERE a.cod_trans in ('0002','0041' )
	AND a.fecha_operacion = vfecha2
	AND a.sucursal IN (SELECT {+INDEX(bdinteg:"informix".si_sucursales  idx_sucursal2)}
					sucursal
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal != '0'
					AND empresa = '001'
					AND tpo_sucursal = 'C' )
	AND a.reversado IN ('0','1') AND a.folio_oper = b.folio_oper
	and b.cod_proveedor = d.cod_proveedor 
	group by b.cod_proveedor

	update bdisuc:"informix".ss_reportecedula	
	set concent_atm = vcon_atm
	where codi = centro_costo and fecha = vfecha3; 
end foreach;   	
-- **************************************
-- * Columna 7: Concentracion Sucursal	*
-- **************************************				
--- QUITANDOLE EL TIPO DE SUCURSAL DAN LAS CUENTAS
foreach
	 SELECT {+INDEX(bdisuc:"informix".ss_operaciones idx03_operaciones)}
	sum(b.monto), b.cod_proveedor, a.fecha_operacion
	INTO vmont_dotatm, codi,vfecha3
	FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores_etv d
	WHERE a.cod_trans ='0002' AND a.fecha_operacion = vfecha2
	AND a.folio_oper = b.folio_oper
	AND a.reversado IN ('0')              
	--AND  b.status ='07'   
	and b.cod_proveedor = d.cod_proveedor
	group by b.cod_proveedor,a.fecha_operacion			

	update "informix".ss_reportecedula
	set concent_suc = vcon_suc
	where codi = centro_costo and fecha = vfecha3; 
end foreach;  
-- **************************************
-- * Columna 9: Compra Tesoreria		*
-- **************************************	pendiente	
 foreach				
			select {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
			compra, centro_costo, fecha
			into vsaldo, codi,vfecha3
			from bdisuc:ss_reportecedula where fecha=vfecha
			
			update "informix".ss_reportecedula
			set compra_tesoreria = vsaldo
			where codi = centro_costo and fecha = vfecha3; 
			
end foreach; 
-- **************************************
-- * Columna 10: Total Entradas			*
-- ************************************** 
foreach
	SELECT  {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo, concent_atm, concent_suc,correccion_sob, compra_tesoreria 
	into  codi, vcon_atm,vcon_suc,vcorreccionsob, vmonto_teso
	FROM bdisuc:"informix".ss_reportecedula  WHERE fecha =vfecha
	
	 let vtotalentradas = vcon_atm + vcon_suc + vcorreccionsob + vmonto_teso;
	 
	update bdisuc:"informix".ss_reportecedula	
	set total_entradas = vtotalentradas
	where fecha = vfecha and centro_costo = codi; 		 		
end foreach;  
-- **************************************
-- * Columna 11: Dotación Cajero		*
-- ************************************** 		 
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_operaciones idx03_operaciones)}
	sum(b.monto), b.cod_proveedor, a.fecha_operacion
	INTO vmont_dotatm, codi,vfecha3
	FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores_etv d
	WHERE a.cod_trans ='0036' AND a.fecha_operacion = vfecha
	AND a.sucursal IN (SELECT {+INDEX( bdinteg:"informix".si_sucursales idx_sucursal2)}
			sucursal 
			FROM bdinteg:"informix".si_sucursales  
			WHERE sucursal != '0' 
			AND empresa = '001'
			AND tpo_sucursal = 'C')
	AND a.folio_oper = b.folio_oper
	AND a.reversado IN ('0')              
	AND  b.status ='11'   
	and b.cod_proveedor = d.cod_proveedor
	group by b.cod_proveedor,a.fecha_operacion

	update bdisuc:"informix".ss_reportecedula
	set dot_atm = vmont_dotatm
	where codi = centro_costo and fecha = vfecha3; 
end foreach; 					
-- **************************************
-- * Columna 12: Dotación Sucursal		*
-- ************************************** 							
foreach
	SELECT  {+INDEX(bdisuc:"informix".ss_operaciones idx03_operaciones)}
	sum(b.monto), b.cod_proveedor, a.fecha_operacion
	INTO vmont_dotsuc, codi,vfecha3
	FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b , bdisuc:"informix".ss_proveedores_etv d
	WHERE a.cod_trans = '0001' AND a.fecha_operacion = vfecha
	AND a.sucursal IN (SELECT {+INDEX( bdinteg:"informix".si_sucursales idx_sucursal2)}
			sucursal 
			FROM bdinteg:"informix".si_sucursales  
			WHERE sucursal != '0' 
			AND empresa = '001'
			AND tpo_sucursal = 'S')
	AND a.folio_oper = b.folio_oper  
	AND a.reversado IN ('0')               
	AND b.status = '11' 
	and b.cod_proveedor = d.cod_proveedor
	group by b.cod_proveedor,a.fecha_operacion 
						
	update bdisuc:"informix".ss_reportecedula	
	set dot_suc = vmont_dotsuc
	where codi = centro_costo and fecha = vfecha3; 
end foreach; 
-- **************************************
-- * Columna 14: Deposito Tesoreria		*
-- **************************************
foreach				
		select {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
		ventas, centro_costo, fecha
		into vventa, codi, vfecha3
		from bdisuc:ss_reportecedula  WHERE fecha =vfecha
		
		update "informix".ss_reportecedula
		set deposito_tesoreria = vventa
		where codi = centro_costo and fecha =vfecha; 
end foreach;  				
-- **************************************
-- * Columna 15: Total Salidas			*
-- ************************************** 
foreach				
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo,dot_atm,dot_suc, correccion_falt,deposito_tesoreria
	into codi, vmont_dotatm, vmont_dotsuc, vcorreccionfalt, vdeposito_teso 
	FROM bdisuc:"informix".ss_reportecedula where fecha=vfecha
			
					let vtotalsalidas = vmont_dotatm+ vmont_dotsuc + vcorreccionfalt + vdeposito_teso;
					
	update bdisuc:"informix".ss_reportecedula	
	set  total_salidas  = vtotalsalidas
	where fecha = vfecha and centro_costo = codi;						
end foreach;	
-- **************************************
-- * Columna 16: Diferencia Entra/Sale	*
-- ************************************** 	
foreach
	SELECT  {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo,total_entradas,total_salidas 
	into  codi, vtotalentradas, vtotalsalidas
	FROM bdisuc:"informix".ss_reportecedula where fecha=vfecha
			
					let vdife_entra = vtotalentradas - vtotalsalidas;
					
	update bdisuc:"informix".ss_reportecedula	
	set dif_entra_sale = vdife_entra
	where fecha = vfecha and centro_costo = codi;			
end foreach;
-- **************************************
-- * Columna 17:  Saldo Final Control	*
-- **************************************	
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo,saldo_ante_sif, total_entradas,total_salidas
	into  codi, vsaldo, vtotalentradas, vtotalsalidas
	FROM bdisuc:"informix".ss_reportecedula where fecha=vfecha
		
					let vsaldo_final = vsaldo +  vtotalentradas - vtotalsalidas ;
					
	update bdisuc:"informix".ss_reportecedula	
	set saldo_final_control = vsaldo_final
	where fecha = vfecha and centro_costo = codi;	
end foreach;
-- *******************************************
-- * Columna 18:  Saldo Ayer Movimientos Hoy *
-- *******************************************	
foreach	
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo,saldo_cont_ante, total_entradas,total_salidas
	into  codi, vsaldo, vtotalentradas, vtotalsalidas
	FROM bdisuc:"informix".ss_reportecedula  where fecha=vfecha
		
					let vsaldoayer_hoy = vsaldo +  vtotalentradas - vtotalsalidas ;
					
	update bdisuc:"informix".ss_reportecedula	
	set  saldo_ayer_movhoy = vsaldoayer_hoy
	where fecha = vfecha and centro_costo = codi;
end foreach;
-- *************************************
-- * Columna 19:  Saldo Final Contable *
-- *************************************				
foreach
		SELECT u.sucursal,nvl(SUM(saldo_fin_de_dia),0) AS saldo
		into codi, vsaldot
		FROM bdicont:co_sdodias s, bdinteg:si_sucursales u
		WHERE s.empresa='001'
		AND s.mes_dia = vfecha
		AND s.ccmayor    = '1101'
		AND s.ccsub      = '01'
		AND s.ccsubsub   = '00'
		AND s.ccssubsub  = '00'
		AND s.ccsssubsub = '00'
		AND s.sector     = '00' 
		AND s.sucursal = u.sucursal 
		and u.sucursal >= '8000'
		GROUP BY u.sucursal
		order by u.sucursal

		update bdisuc:"informix".ss_reportecedula	
		set saldo_final_conta = vsaldot
		where centro_costo = codi and fecha= vfecha;
end foreach;  
-- ************************************
-- * Columna 20:  Diferencia Ayer Hoy *
-- ************************************		
foreach		
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo,  saldo_cont_ante,saldo_final_conta
	into  codi, vsaldo, vsaldofin
	FROM bdisuc:"informix".ss_reportecedula  where fecha=vfecha
		
					let vdif_ayer_hoy = vsaldo - vsaldofin;
					
	update bdisuc:"informix".ss_reportecedula	
	set  dif_ayer_hoy =  vdif_ayer_hoy
	where fecha = vfecha and centro_costo = codi;
end foreach; 
-- *******************************************************
-- * Columna 27: Total Entradas Archivo de Pan Americano *
-- *******************************************************	
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo, concentraciones, sobrante, dotacion_devuelta, remanent_atm, compra 
	into  codi, vsaldo, vsobrante, vdot, vremanent_atm, vcompra
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
	
			let vtotalentradas =  vsaldo + vsobrante + vdot + vremanent_atm + vcompra;
				
	update bdisuc:"informix".ss_reportecedula	
	set arq_total_entra = vtotalentradas
	where fecha = vfecha and centro_costo = codi;				
end foreach;
-- *******************************************************
-- * Columna 32: Total  Salidas Archivo de Pan Americano *
-- *******************************************************	
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)} 
	centro_costo, faltante, arq_dot_suc, arq_dot_atm, ventas
	into  codi, vsaldo, vmont_dotsuc, vmont_dotatm, vventa
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
	
			let vtotalsalidas =   vsaldo + vmont_dotsuc + vmont_dotatm + vventa;
				
	update bdisuc:"informix".ss_reportecedula	
	set arq_total_salida= vtotalsalidas
	where fecha = vfecha and centro_costo = codi;
					
end foreach;		
-- **************************************
-- * Columna 33: Total  Saldo Final ETV *
-- **************************************														
foreach
	SELECT  {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo, saldo_anterior, arq_total_entra,arq_total_salida 
	into  codi, vsaldo,  vtotalentradas, vtotalsalidas
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
	
			let vsaldo_final = vsaldo + vtotalentradas - vtotalsalidas ;
				
	update bdisuc:"informix".ss_reportecedula	
	set saldo_final_etv = vsaldo_final
	where fecha = vfecha and centro_costo = codi;			
end foreach;
-- *******************************
-- * Columna 34: Diferencia ETV  *
-- *******************************	
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo, saldo_final_conta,saldo_final_etv 
	into  codi, vsaldo, vsaldo_final
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
	
			let vsaldot = vsaldo - vsaldo_final ;
				
	update bdisuc:"informix".ss_reportecedula	
	set dif_etv =  vsaldot
	where fecha = vfecha and centro_costo = codi;	
end foreach;
-- ****************************************
-- * Columna 35: Diferencia Día Anterior  *
-- ****************************************	
--(al iniciar el sistema se debe introducir directamente)
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	fecha, centro_costo,dif_etv 
	into vfecha3,  codi, vdif_dia_hoy
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha_ultima

	update bdisuc:"informix".ss_reportecedula	
	set dif_dia_ant = vdif_dia_hoy
	where fecha = vfecha and centro_costo = codi;	
end foreach;
-- ****************************************
-- * Columna 36: Diferencia Día de Hoy    *
-- ****************************************
foreach
	SELECT {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo,dif_etv,dif_dia_ant
	into  codi, vdif_etv, vdif_dia_ant
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
		
	let vdif_dia_hoy =vdif_etv-vdif_dia_ant;
	
	update bdisuc:"informix".ss_reportecedula	
	set dif_dia_hoy =  vdif_dia_hoy
	where fecha = vfecha and centro_costo = codi;			
end foreach;  
-- ****************************************
-- * Columna 37: Fecha de Modificación	  *
-- **************************************** 
 foreach
	SELECT  {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo
	into  codi
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
	
	update bdisuc:"informix".ss_reportecedula	
	set vfecha_modificacion = current
	where fecha = vfecha and centro_costo = codi;	
end foreach; 
-- ****************************************
-- * Columna 38: Fecha del Archivo	      *
-- **************************************** 
foreach
	SELECT  {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
	centro_costo
	into  codi
	FROM bdisuc:"informix".ss_reportecedula  where fecha = vfecha
	
	update bdisuc:"informix".ss_reportecedula	
	set vfecha_archivo =  vfecha
	where fecha = vfecha and centro_costo = codi;	
end foreach;
	  	
let vmensaje='Proceso Exitoso';
	
truncate table bdisuc:"informix".ss_arqueo_panamericano; 
 
RETURN vcodret, vmensaje;
end;
end procedure;