CREATE PROCEDURE "informix".sp_extraer_cifrastrans_bts(pfechaini date,pfechafin date,ptipo integer,tpo_remesa CHAR(03),pdepcta CHAR(02))
-- ********************************************************************************
-- * VersiÃ?Â?Ã?Â?Ã?Â?Ã?Â³n:              	1.0.0                                                 *
-- * Objetivo:             	Extraccion cifras de Remesas BTS.			  		  *
-- * Creado por:            Christian Jose Angel Castillo Olivas				  *
-- * Fecha de ElaboraciÃ?Â?Ã?Â?Ã?Â?Ã?Â³n: 							  					   		  *
-- * Modificado por: 		Jeaneth Isamar Montoya Romo                   		  *
-- * Ultima Modificacion:      20/06/2013                                 		  *
-- * Modificacion:     	   Se automatizÃ?Â?Ã?Â?Ã?Â?Ã?Â³ el proceso para relizar las extracciones *
-- *			en la tabla "informix".tblpld_bts de la base de datos bdiauditor  *
-- * Modificado por:		Gilberto Lopez Inzunza								  *	
-- * Modificacion:			se adapta a las especificaciones del requermiento     *
-- *					RQI 14 186 denes de Pago para sistema de PLDÃ?*
-- * fecha de modifiacion: 28/04/2015											  *
-- * Modificado por:		Gilberto Lopez Inzunza								  *	
-- * Modificacion:			Se agrega la opcion para la consulta de ordenes 	  *	
-- *						de pago 											  *
-- * fecha de modifiacion: 										                  *
-- * Modificado por:		Gilberto Lopez Inzunza								  *	
-- * Modificacion:			Se agrega parametro que indica si es deposito en  	  *	
-- *						cuenta	 											  *
-- * fecha de modificacion: 														  *
-- ********************************************************************************
 RETURNING
CHAR(5) as cod_ret,
int as transferidas,
int as num_operaciones,
decimal(18,2) as montotot_dolar, 
decimal(18,2) as montotot_pesos,
char(12) as num_confirmacion,
char(50) as nomb_ord,
char(9) as estatus,
date as fechapago,
decimal(18,2) as mont_dolar,
decimal(18,2) as mont_pesos,
char(50) as nomb_ben,
char(8) as fecha_nacimiento,
char (150) as calle,
char (6) as num_ext,
char (6) as num_int,
char (6) as depto,
char (30) as colonia,
char (5) as cp,
char (30) as delg_mun,
char (30) as ciudad,
char (30) as estado,
char (4) as num_sucpag,
char (40) as nomb_sucpag,
char (40) as loc_sucpag;
-- ***************************
-- * DEFINICIÃ?Â?Ã?Â?Ã?Â?Ã?Â?N DE VARIABLES *
-- ***************************
DEFINE iSqlErr           INTEGER;
define vtipo                int;
define vvfechini            date;
define vvfechfin            date;
define d_fechaini           char(8);
define d_fechafin           char(8);
DEFINE cod_ret				CHAR(5);
DEFINE transferidas 		integer;
DEFINE num_operaciones      integer;
DEFINE tot_dolar 			decimal(18,2);
DEFINE tot_pesos 			decimal(18,2);
DEFINE vnum_confirmacion 	char(12);
DEFINE nomb_ord 			char(50);
DEFINE fechapago 			date;
DEFINE mont_dolar			decimal(18,2);
DEFINE mont_pesos			decimal(18,2);
DEFINE nomb_ben				char(50);
DEFINE fecha_nacimiento		char(8);
DEFINE calle 				char (150);
DEFINE num_ext              char (6);                            
DEFINE num_int              char (6); 
DEFINE depto                char (6); 
DEFINE colonia              char (30);
DEFINE cp                   char (5); 
DEFINE delg_mun             char (30);                            
DEFINE ciudad               char (30);
DEFINE estado               char (30);
DEFINE num_sucpag           char (4); 
DEFINE nomb_sucpag          char (40);
DEFINE loc_sucpag	        char (40);
DEFINE vconteo				int;

BEGIN
ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,0,0,0, 0,'','','',null,0,0,'',null,'','','','','','','','','','','','';
			END IF;
END EXCEPTION;

--set debug file to "ordenes_pago.out";
--trace on;

-- *******************************
-- * INICIALIZACIÃ?Â?Ã?Â?Ã?Â?Ã?Â?N DE VARIABLES *
-- *******************************
let vtipo = ptipo;
let vvfechini = pfechaini;
let vvfechfin = pfechafin;
let vconteo = 0;

Set isolation to dirty read;
truncate table bdiauditor:"informix".tbltrans_bts;
truncate table bdiauditor:"informix".tblpld_wu;


		SELECT * FROM bdisac:"informix".sac_pld_ordenes_pago 
				WHERE ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin)) and tipo_orden = tpo_remesa
				AND	estatus ='CANCELADA' OR  estatus ='REVERSADA'   
			INTO temp tablapld with no log;
			
			
			INSERT INTO tablapld 
				SELECT * FROM  bdisac:"informix".sac_pld_ordenes_pago  
				WHERE ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin)) and tipo_orden = tpo_remesa
				AND estatus IN ('PAGADA') AND num_control NOT IN (SELECT num_control FROM tablapld);
		 
		 
			INSERT INTO tablapld 
				SELECT * FROM  bdisac:"informix".sac_pld_ordenes_pago 
				WHERE ((fecha_pago between vvfechini and vvfechfin) or (fecha_envio between vvfechini and vvfechfin)) and tipo_orden = tpo_remesa
				AND estatus IN ('ENVIADA') AND num_control NOT IN (SELECT num_control FROM tablapld);

-- ***************************
-- * Cifras Rango			 *
-- ***************************
if vtipo = 1  THEN 

	IF tpo_remesa = 'OPA' THEN
		
					
		SELECT num_control, 
         case when fecha_pago = '01/01/1900' then (monto_total /  (select precio from tipo_cambio tc where pg.fecha_envio = tc.fecha_tc-1 ) ) 
              else (monto_total /  (select precio from tipo_cambio tc where pg.fecha_pago = tc.fecha_tc-1 ) ) 
        end as monto_dolares,
         monto_total
		FROM tablapld pg
		WHERE  tipo_orden ='OPA' 
        AND ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
		group by 1,2,3
		into temp tx1 with no log;
		
		SELECT count(num_control)as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		FROM tx1
		WHERE monto_dolares between '0.01' and '249.99' ;
		Return '',0,nvl(num_operaciones,0),nvl(tot_dolar,0), nvl(tot_pesos,0),'','','',null,0,0,'','','','','','','','','','','','','','De 0.1 a 249.99' WITH RESUME;
		
		SELECT count(num_control)as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		FROM tx1
		WHERE monto_dolares between '250' and '499.99';
		Return '',0,nvl(num_operaciones,0),nvl(tot_dolar,0), nvl(tot_pesos,0),'','','',null,0,0,'','','','','','','','','','','','','','De 250 a 499.99' WITH RESUME;
		
		SELECT count(num_control)as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		FROM tx1
		WHERE monto_dolares between '500'  and '749.99';
		Return '',0,nvl(num_operaciones,0),nvl(tot_dolar,0), nvl(tot_pesos,0),'','','',null,0,0,'','','','','','','','','','','','','','De 500 a 749.99' WITH RESUME;
		
		SELECT count(num_control)as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		FROM tx1
		WHERE monto_dolares between '750' and '999.99';
		Return '',0,nvl(num_operaciones,0),nvl(tot_dolar,0), nvl(tot_pesos,0),'','','',null,0,0,'','','','','','','','','','','','','','De 750 a 999.99' WITH RESUME;
		
		SELECT count(num_control)as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		FROM tx1
		WHERE monto_dolares >= '1000';
		Return '',0,nvl(num_operaciones,0),nvl(tot_dolar,0), nvl(tot_pesos,0),'','','',null,0,0,'','','','','','','','','','','','','','De 1000 en adelante' WITH RESUME;
		
		SELECT count(num_control)as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		FROM tx1;		
		Return '',0,nvl(num_operaciones,0),nvl(tot_dolar,0), nvl(tot_pesos,0),'','','',null,0,0,'','','','','','','','','','','','','','Totales' WITH RESUME;				
		
		DROP TABLE tx1;
		
		drop table tablapld;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN	
	
		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		and monto_dolares between '0.01' and '249.99' ;
		Return '',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 0.1 a 249.99' WITH RESUME;
		
		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		and monto_dolares between '250' and '499.99';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 250 a 499.99' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		and monto_dolares between '500'  and '749.99';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 500 a 749.99' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		and monto_dolares between '750' and '999.99';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 750 a 999.99' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		and monto_dolares >= '1000';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 1000 en adelante' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta;
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','Totales' WITH RESUME;

	ELSE	
		
		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		and monto_dolares between '0.01' and '249.99' ;
		Return '',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 0.1 a 249.99' WITH RESUME;
		
		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		and monto_dolares between '250' and '499.99';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 250 a 499.99' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		and monto_dolares between '500'  and '749.99';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 500 a 749.99' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		and monto_dolares between '750' and '999.99';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 750 a 999.99' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		and monto_dolares >= '1000';
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','De 1000 en adelante' WITH RESUME;

		select 
		count(beneficiario_direccion) as numero_operaciones, sum(monto_dolares) as tot_dollar, sum(monto_total) as tot_pesos
		INTO num_operaciones,tot_dolar, tot_pesos
		from bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin;
		Return '0',0,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','Totales' WITH RESUME;		
		
	END IF
end if;
-- ***************************
-- * Cifras Ordenantes		 *
-- *************************** 
if vtipo = 2  THEN

	IF tpo_remesa = 'OPA' THEN

		select 
		trim(ordenante_nombre1)|| trim(ordenante_nombre2)|| trim(ordenante_appaterno)||trim(ordenante_apmaterno)
		||trim(ordenante_direccion)|| trim(ordenante_telefono) as id_ord,
		count(num_control) as maxtrans,  round (sum((SELECT  monto_total / precio FROM tipo_cambio tp WHERE  tp.fecha_tc = fecha_pago-1)),2 )as monto_dolar,
		sum(monto_total) as monto_pesos 
		 from tablapld
		WHERE ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin)) and tipo_orden ='OPA' 
		group by 1 order by 2 desc
		into TEMP T1 with no log;
		
			
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
		
		select id_ord ,count(id_ord) as maxtrans,  round (sum(monto_dolares),2 )as monto_dolar,sum(monto_total) as monto_pesos 
		from table (multiset(
		SELECT substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
		monto_dolares, monto_total
		FROM bdisac:sac_pld_remesas WHERE  fecha_remesa between vvfechini and vvfechfin
		and tipo_remesa =tpo_remesa and abono_cuenta = pdepcta
		)) group by 1 order by 2 desc 
		into TEMP T1 with no log;	
	
	ELSE
		select id_ord ,count(id_ord) as maxtrans,  round (sum(monto_dolares),2 )as monto_dolar,sum(monto_total) as monto_pesos 
		from table (multiset(
		SELECT substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
		monto_dolares, monto_total
		FROM bdisac:sac_pld_remesas WHERE  fecha_remesa between vvfechini and vvfechfin
		and tipo_remesa =tpo_remesa
		)) group by 1 order by 2 desc 
		into TEMP T1 with no log;
	
	END IF
	
	select id_ord,maxtrans,monto_dolar,monto_pesos
	from T1
	order by maxtrans desc
	into TEMP T2 with no log;

	SELECT maxtrans,
	count(maxtrans) as Num_ordenantes,round(sum(monto_dolar),2) as Montodolar,sum(monto_pesos) as Monto_pesos
	from T2 
	group by maxtrans
	order by maxtrans desc
	into TEMP T3 with no log;

	FOREACH
		select maxtrans,Num_ordenantes,Montodolar,Monto_pesos
		into transferidas,num_operaciones,tot_dolar,tot_pesos 
		from T3
		Return '',transferidas,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','' WITH RESUME;
	END FOREACH; 

	select sum(maxtrans),sum(Num_ordenantes),sum(Montodolar),sum(Monto_pesos)
	into transferidas,num_operaciones,tot_dolar,tot_pesos 
	from T3;
	Return '100',transferidas,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','' WITH RESUME;
	
drop table T1;
drop table T2;
drop table T3;
--drop table T4;
drop table tablapld;

end if; 
-- ***************************
-- * Cifras Beneficiarios	 *
-- ***************************
 if vtipo = 3  THEN
	
	IF tpo_remesa = 'OPA' THEN
	
		SELECT 
		trim(beneficiario_nombre1)||trim(beneficiario_nombre2)||trim(beneficiario_appaterno)||
		trim(beneficiario_apmaterno)||trim(beneficiario_tpo_identificacion)|| 
		trim(beneficiario_num_identificacion)|| trim(beneficiario_direccion) as id_ben,
		count(num_control) as maxtrans,round (sum((SELECT monto_total / precio FROM tipo_cambio tp WHERE  tp.fecha_tc = fecha_pago-1)),2 )as monto_dolar,
		sum(monto_total) as monto_pesos
		 FROM tablapld 
		WHERE ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin)) and tipo_orden ='OPA' 
		group by 1 ORDER BY 1
		into TEMP T1 with no log;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		select id_ben , count(id_ben) as maxtrans,  round (sum(monto_dolares),2 )as monto_dolar,sum(monto_total) as monto_pesos 
		from table (multiset(
		select 
		substr(nvl(beneficiario_nombre1,''),0,4)|| substr(nvl(beneficiario_appaterno,''),0,4)||
		substr(nvl(beneficiario_apmaterno,''),0,4)|| month(nvl(beneficiario_fecha_nac,'01/01/1900'))||day(nvl(beneficiario_fecha_nac,'01/01/1900'))||year(nvl(beneficiario_fecha_nac,'01/01/1900')) as id_ben ,
		monto_dolares, monto_total
		FROM bdisac:sac_pld_remesas WHERE  fecha_remesa between vvfechini and vvfechfin
			and tipo_remesa =tpo_remesa and abono_cuenta = pdepcta
		)) group by 1	
		into TEMP T1 with no log;
	
	ELSE
	
		select id_ben , count(id_ben) as maxtrans,  round (sum(monto_dolares),2 )as monto_dolar,sum(monto_total) as monto_pesos 
		from table (multiset(
		select 
		substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||
		substr(beneficiario_apmaterno,0,4)|| month(beneficiario_fecha_nac)||day(beneficiario_fecha_nac)||year(beneficiario_fecha_nac) as id_ben ,
		monto_dolares, monto_total
		FROM bdisac:sac_pld_remesas WHERE  fecha_remesa between vvfechini and vvfechfin
			and tipo_remesa =tpo_remesa
		)) group by 1	
		into TEMP T1 with no log;
		
	END IF
	
	select maxtrans ,count(maxtrans) as Num_Ben,round(sum(monto_dolar),2) as Montodolar,sum(monto_pesos) as Monto_peso
	from T1
	group by maxtrans
	order by maxtrans desc
	into TEMP T2  with no log;

	FOREACH
		select maxtrans,Num_Ben,Montodolar,Monto_peso				
		into transferidas,num_operaciones,tot_dolar, tot_pesos
		from T2			
		Return '',transferidas,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','' WITH RESUME;
	END FOREACH; 

	select sum(maxtrans),sum(Num_Ben),sum(Montodolar),sum(Monto_peso)
	into transferidas,num_operaciones,tot_dolar,tot_pesos 
	from T2;
	Return '100',transferidas,num_operaciones,tot_dolar, tot_pesos,'','','',null,0,0,'','','','','','','','','','','','','','' WITH RESUME; 
	
	drop table T1;	
	drop table T2;	
	drop table tablapld;
end if; 
-- ******************************
-- * Total Transferencias BTS	*
-- ****************************** 
if vtipo = 4  THEN  

	IF tpo_remesa = 'OPA' THEN
		
		SELECT num_control AS confirmation_nm , 
		TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
		"P" as txn_status, fecha_pago  AS fech_alt, (SELECT monto_total / precio FROM tipo_cambio tp WHERE  tp.fecha_tc = fecha_pago-1) as total_dollares_xenvio,
		monto_total AS monto_tot,
		TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
		'19000101' as r_fecha_nac, ' ' AS r_nom_calle,
		'0' AS r_num_ext, '0' AS r_num_int,
		' ' AS r_depto, beneficiario_direccion as r_colonia ,' ' AS r_cp,
		' ' AS r_mncpo_deleg, ' ' AS r_ciudad,' ' AS r_estado ,
		sucursal_numero_destino as sucursal,
		(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_nombre ,
		(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_direccion1 

		 FROM tablapld rm
		WHERE  ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin)) 
		    and tipo_orden ='OPA' 
		group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
		into TEMP T1 with no log;
	
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		SELECT
			num_confirmacion AS confirmation_nm ,
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			"A" as txn_status,fecha_remesa AS fech_alt, monto_dolares as total_dollares_xenvio,
			monto_total AS monto_tot,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac,
			beneficiario_calle AS r_nom_calle, beneficiario_num_ext AS r_num_ext, beneficiario_num_int AS r_num_int,
			beneficiario_depto AS r_depto,beneficiario_colonia as r_colonia ,beneficiario_cp AS r_cp,
			beneficiario_mncpo_del AS r_mncpo_deleg, beneficiario_ciudad AS r_ciudad,beneficiario_estado AS r_estado ,
			sucursal,
			(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_nombre ,
			(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion1 
		FROM bdisac:sac_pld_remesas rm where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		into TEMP T1 with no log;
		
	
	ELSE
	
		SELECT
			num_confirmacion AS confirmation_nm ,
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			"A" as txn_status,fecha_remesa AS fech_alt, monto_dolares as total_dollares_xenvio,
			monto_total AS monto_tot,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac,
			beneficiario_calle AS r_nom_calle, beneficiario_num_ext AS r_num_ext, beneficiario_num_int AS r_num_int,
			beneficiario_depto AS r_depto,beneficiario_colonia as r_colonia ,beneficiario_cp AS r_cp,
			beneficiario_mncpo_del AS r_mncpo_deleg, beneficiario_ciudad AS r_ciudad,beneficiario_estado AS r_estado ,
			sucursal,
			(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_nombre ,
			(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion1 
		FROM bdisac:sac_pld_remesas rm where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		into TEMP T1 with no log;
	
	END IF

	IF tpo_remesa in ('BTS','OPA') THEN
			insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,num_confirmacion,nomb_ord, estatus,fechapago, mont_dolar,mont_pesos,
			nomb_ben,fecha_nacimiento,calle,num_ext,num_int,depto,colonia,cp,delg_mun,ciudad,estado,num_sucpag,nomb_sucpag,loc_sucpag)		
			select 	vvfechini,vvfechfin,confirmation_nm,nombre_Ord,txn_status,fech_alt,total_dollares_xenvio,monto_tot,nombre_Ben,r_fecha_nac,r_nom_calle,
			r_num_ext,r_num_int,r_depto,r_colonia,r_cp,r_mncpo_deleg,r_ciudad,r_estado,sucursal,suc_nombre,suc_direccion1  
			from T1;
		ELSE
			insert into bdiauditor:"informix".tblpld_wu(
			vvfechini,vvfechfin,num_confirmacion,nomb_ord, estatus,fechapago,
			 mont_dolar,mont_pesos,
			nomb_ben,fecha_nacimiento,calle,colonia,cp,ciudad,estado,num_sucpag,nomb_sucpag,loc_sucpag,nombre_transacc)	
			select 
				vvfechini,vvfechfin,confirmation_nm,nombre_Ord,txn_status,fech_alt,total_dollares_xenvio,monto_tot,
			nombre_Ben,r_fecha_nac,r_nom_calle,r_colonia,r_cp,r_ciudad,r_estado,
			sucursal,suc_nombre,suc_direccion1 ,  
			case	WHEN tpo_remesa = 'WUN' THEN 'wu'
				WHEN tpo_remesa = 'OVA' THEN 'ov'
				WHEN tpo_remesa = 'VIG'	THEN 'vi' end
			from T1;
	END IF
	
	drop table T1;	
	drop table tablapld;
end if; 
-- **************************
-- * Igual o Mayor a 1000 	*
-- **************************
if vtipo = 5  THEN 

	IF tpo_remesa = 'OPA' THEN	
			SELECT num_control AS confirmation_nm , 
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				"P" as txn_status, fecha_pago  AS fech_alt, (SELECT monto_total / precio FROM tipo_cambio tp WHERE  tp.fecha_tc = fecha_pago-1) as total_dollares_xenvio,
				monto_total AS monto_tot,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				'19000101' as r_fecha_nac, ' ' AS r_nom_calle,
				'0' AS r_num_ext, '0' AS r_num_int,
				' ' AS r_depto, beneficiario_direccion as r_colonia ,' ' AS r_cp,
				' ' AS r_mncpo_deleg, ' ' AS r_ciudad,' ' AS r_estado ,
				sucursal_numero_destino as sucursal,
				(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_nombre ,
				(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_direccion1 

			FROM tablapld rm
			WHERE  ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
					and tipo_orden ='OPA' 
			group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
			into TEMP T1 with no log;
		
		ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
		
		
			SELECT
				num_confirmacion AS confirmation_nm ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				"A" as txn_status,fecha_remesa AS fech_alt, monto_dolares as total_dollares_xenvio,
				monto_total AS monto_tot,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac,
				beneficiario_calle AS r_nom_calle, beneficiario_num_ext AS r_num_ext, beneficiario_num_int AS r_num_int,
				beneficiario_depto AS r_depto,beneficiario_colonia as r_colonia ,beneficiario_cp AS r_cp,
				beneficiario_mncpo_del AS r_mncpo_deleg, beneficiario_ciudad AS r_ciudad,beneficiario_estado AS r_estado ,
				sucursal,
				(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_nombre ,
				(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion1 
			FROM bdisac:sac_pld_remesas rm where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
			into TEMP T1 with no log;		
			
		ELSE
		
			SELECT
				num_confirmacion AS confirmation_nm ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				"A" as txn_status,fecha_remesa AS fech_alt, monto_dolares as total_dollares_xenvio,
				monto_total AS monto_tot,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac,
				beneficiario_calle AS r_nom_calle, beneficiario_num_ext AS r_num_ext, beneficiario_num_int AS r_num_int,
				beneficiario_depto AS r_depto,beneficiario_colonia as r_colonia ,beneficiario_cp AS r_cp,
				beneficiario_mncpo_del AS r_mncpo_deleg, beneficiario_ciudad AS r_ciudad,beneficiario_estado AS r_estado ,
				sucursal,
				(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_nombre ,
				(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion1 
			FROM bdisac:sac_pld_remesas rm where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin
			into TEMP T1 with no log;
			
	END IF
	IF tpo_remesa in ('BTS','OPA') THEN
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,num_confirmacion,nomb_ord, estatus,fechapago, mont_dolar,mont_pesos,
		nomb_ben,fecha_nacimiento,calle,num_ext,num_int,depto,colonia,cp,delg_mun,ciudad,estado,num_sucpag,nomb_sucpag,loc_sucpag)
		select 	vvfechini,vvfechfin,confirmation_nm,nombre_Ord,txn_status,fech_alt,total_dollares_xenvio,monto_tot,nombre_Ben,r_fecha_nac,r_nom_calle,
		r_num_ext,r_num_int,r_depto,r_colonia,r_cp,r_mncpo_deleg,r_ciudad,r_estado,sucursal,suc_nombre,suc_direccion1  
		from T1
		where total_dollares_xenvio >= (select valor FROM bdiauditor:param WHERE llave = 'PARAM_MONTO_TXBTS');
		
	ELSE	
		insert into bdiauditor:"informix".tblpld_wu(
		vvfechini,vvfechfin,num_confirmacion,nomb_ord, estatus,fechapago,
		 mont_dolar,mont_pesos,
		nomb_ben,fecha_nacimiento,calle,colonia,cp,ciudad,estado,num_sucpag,nomb_sucpag,loc_sucpag,nombre_transacc)	
		select 
			vvfechini,vvfechfin,confirmation_nm,nombre_Ord,txn_status,fech_alt,total_dollares_xenvio,monto_tot,
		nombre_Ben,r_fecha_nac,r_nom_calle,r_colonia,r_cp,r_ciudad,r_estado,
		sucursal,suc_nombre,suc_direccion1 ,  
		case	WHEN tpo_remesa = 'WUN' THEN 'wu'
			WHEN tpo_remesa = 'OVA' THEN 'ov'
			WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T1 where total_dollares_xenvio >= (select valor FROM bdiauditor:param WHERE llave = 'PARAM_MONTO_TXBTS');
	END IF
	
	drop table T1;
	drop table tablapld;
	
end if;
-- ********************************************
-- * Transferencias BTS ordenantes por numero *
-- ********************************************
if vtipo = 6  THEN 	
	--procesos beneficiarios

	
	IF tpo_remesa = 'OPA' THEN	
	
		SELECT 
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			count(ordenante_nombre1 ) as maxtrans_benf,
			round (sum(monto_total),2)  as monto_pesos
		FROM tablapld 
		WHERE  ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
			   and tipo_orden ='OPA' 
		group by 1,2,3
		into TEMP T1 with no log;
	
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		SELECT
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				count(ordenante_nombre1 ) as maxtrans_benf,
				round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		group by 1,2,3
		into TEMP T1 with no log;
	
	ELSE
	
		SELECT
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				count(ordenante_nombre1 ) as maxtrans_benf,
				round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		group by 1,2,3
		into TEMP T1 with no log;
		
	END IF
	
	--procesos ordenantes
	select	id_Ord,nombre_Ord,sum(maxtrans_benf) as Num_EnvOrd,round (sum(monto_pesos),2)  as Monto_Totpeso
	from 	T1 			
	group by id_Ord,nombre_Ord
	into temp T2 with no log;
	
	--tabla final 
	select tc.nombre_Ord,tc.Num_EnvOrd,tc.Monto_Totpeso,tf.nombre_Ben,tf.maxtrans_benf,tf.monto_pesos from T1 tf, T2 tc
	where tf.id_Ord = tc.id_Ord
	into TEMP T3 with no log;
	
	IF tpo_remesa in ('BTS','OPA') THEN
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,nomb_ord,num_operaciones,montotot_pesos,nomb_ben,transferidas,mont_pesos)
		select 	vvfechini,vvfechfin,nombre_Ord,Num_EnvOrd,Monto_Totpeso,nombre_Ben,maxtrans_benf,monto_pesos			
		from T3;	
	ELSE	
		insert into bdiauditor:"informix".tblpld_wu (vvfechini,vvfechfin,nomb_ord,num_operaciones,montotot_pesos,
		nomb_ben,transferidas,mont_pesos,nombre_transacc)
		select 	vvfechini,vvfechfin,nombre_Ord,Num_EnvOrd,Monto_Totpeso,nombre_Ben,maxtrans_benf,monto_pesos,
		case	WHEN tpo_remesa = 'WUN' THEN 'wu'
			WHEN tpo_remesa = 'OVA' THEN 'ov'
			WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T3;
	END IF
	
	drop table T1;
	drop table T2;
	drop table T3;
	drop table tablapld;
end if;	
-- *******************************************
-- * Transferencias BTS ordenantes por monto *
-- *******************************************
if vtipo = 7 THEN
	--procesos beneficiarios
	
	IF tpo_remesa = 'OPA' THEN	
	
		SELECT 
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			count(ordenante_nombre1 ) as maxtrans_benf,
			round (sum(monto_total),2)  as monto_pesos
		FROM tablapld 
		WHERE   ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
				and tipo_orden ='OPA' 
		group by 1,2,3
		into TEMP T1 with no log;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		SELECT
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				count(ordenante_nombre1 ) as maxtrans_benf,
				round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		group by 1,2,3
		into TEMP T1 with no log;
	
	
	ELSE
	
		SELECT
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				count(ordenante_nombre1 ) as maxtrans_benf,
				round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		group by 1,2,3
		into TEMP T1 with no log;
		
	END IF
	--procesos ordenantes
	select	id_Ord,nombre_Ord,sum(maxtrans_benf) as Num_EnvOrd,round (sum(monto_pesos),2)  as Monto_Totpeso
	from 	T1 tfinal			
	group by id_Ord,nombre_Ord
	into temp T2 with no log;
	
	--tabla final 
	select tc.nombre_Ord,tc.Num_EnvOrd,tc.Monto_Totpeso,tf.nombre_Ben,tf.maxtrans_benf,tf.monto_pesos from T1 tf, T2 tc
	where tf.id_Ord = tc.id_Ord
	order by Monto_Totpeso desc
	into TEMP T3 with no log;
		
	IF tpo_remesa in ('BTS','OPA') THEN
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,nomb_ord,num_operaciones,montotot_pesos,nomb_ben,transferidas,mont_pesos)
		select 	vvfechini,vvfechfin,nombre_Ord,Num_EnvOrd,Monto_Totpeso,nombre_Ben,maxtrans_benf,monto_pesos			
		from T3;
	ELSE
		insert into bdiauditor:"informix".tblpld_wu (vvfechini,vvfechfin,nomb_ord,num_operaciones,montotot_pesos,
		nomb_ben,transferidas,mont_pesos,nombre_transacc)
		select 	vvfechini,vvfechfin,nombre_Ord,Num_EnvOrd,Monto_Totpeso,nombre_Ben,maxtrans_benf,monto_pesos,
		case	WHEN tpo_remesa = 'WUN' THEN 'wu'
			WHEN tpo_remesa = 'OVA' THEN 'ov'
			WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T3;
	END IF

	drop table T1;
	drop table T2;
	drop table T3;
	drop table tablapld;
end if;	
-- *************************************
-- * Transferencias BTS por domicilio  *
-- *************************************
if vtipo = 8  THEN

	--procesos beneficiarios
	IF tpo_remesa = 'OPA' THEN	
		SELECT ordenante_direccion as s_address,
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
			substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||substr(beneficiario_apmaterno,0,4)||substr(beneficiario_direccion,0,4) as id_ben ,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			COUNT(beneficiario_nombre1) as maxtrans_benf,round (sum(monto_total),2)  as monto_pesos
		FROM tablapld 
		WHERE ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
			  and tipo_orden ='OPA' 
		group by 1,2,3,4,5
		into TEMP T1 with no log;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN

		SELECT
			ordenante_direccion as s_address,
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
			substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||substr(beneficiario_apmaterno,0,4)|| month(beneficiario_fecha_nac)||day(beneficiario_fecha_nac)||year(beneficiario_fecha_nac) as id_ben ,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			COUNT(beneficiario_nombre1) as maxtrans_benf,round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas where tipo_remesa = tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		group by 1,2,3,4,5
		into TEMP T1 with no log;
		
	ELSE
	
		SELECT
			ordenante_direccion as s_address,
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
			substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
			substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||substr(beneficiario_apmaterno,0,4)|| month(beneficiario_fecha_nac)||day(beneficiario_fecha_nac)||year(beneficiario_fecha_nac) as id_ben ,
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
			COUNT(beneficiario_nombre1) as maxtrans_benf,round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		group by 1,2,3,4,5
		into TEMP T1 with no log;
	END IF
	--procesos ordenantes
	select s_address,id_Ord,nombre_Ord,sum(maxtrans_benf) as Num_EnvOrd,round (sum(monto_pesos),2)  as Monto_Totpeso
	from T1 			
	group by s_address,id_Ord,nombre_Ord
	into temp T2 with no log;

	select tf.s_address, count(tf.s_address) as num  from T1 tf, T2 tc
	where tf.s_address = tc.s_address
	group by tf.s_address
	into temp T3 with no log;

	select s_address from T3 where  num >= 2
	into temp T4 with no log;

	select tf.id_Ord, count(tf.id_Ord) as num  from T1 tf, T2 tc
	where tf.id_Ord = tc.id_Ord
	group by tf.id_Ord
	into temp T5 with no log;

	select id_Ord from T5 where  num = 1
	into temp T6 with no log;	
	 
	 --tabla final 
	select tf.s_address,tc.nombre_Ord,tc.Num_EnvOrd,tc.Monto_Totpeso,tf.nombre_Ben,tf.maxtrans_benf,tf.monto_pesos 
	from T1 tf, T2 tc,T4 tdiez,T6 tdoce
	where tdiez.s_address = tc.s_address 
	and tdiez.s_address = tf.s_address
	and tdoce.id_Ord = tc.id_Ord
	and tdoce.id_Ord = tf.id_Ord
	into TEMP T7 with no log;
	 
	IF tpo_remesa in ('BTS','OPA') THEN 
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,nomb_ord,calle,num_operaciones,montotot_pesos,nomb_ben,transferidas,mont_pesos)
		select 	vvfechini,vvfechfin,nombre_Ord,s_address,Num_EnvOrd,Monto_Totpeso,nombre_Ben,maxtrans_benf,monto_pesos 
		from T7;
			
	ELSE
		insert into bdiauditor:"informix".tblpld_wu (vvfechini,vvfechfin,nomb_ord,calle,num_operaciones,montotot_pesos,
		nomb_ben,transferidas,mont_pesos,nombre_transacc)
		select 	vvfechini,vvfechfin,nombre_Ord,s_address,Num_EnvOrd,Monto_Totpeso,nombre_Ben,maxtrans_benf,monto_pesos,
		case	WHEN tpo_remesa = 'WUN' THEN 'wu'
				WHEN tpo_remesa = 'OVA' THEN 'ov'
				WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T7;
	END IF
	
	drop table T1;
	drop table T2;
	drop table T3;
	drop table T4;
	drop table T5; 
	drop table T6;
	drop table T7;
	drop table tablapld;
end if;	 
-- ***********************************************
-- * Transferencias BTS beneficiarios por numero *
-- ***********************************************
if vtipo = 9  THEN

    --procesos ordenantes
	IF tpo_remesa = 'OPA' THEN
		 SELECT 
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)|| substr(beneficiario_apmaterno,0,4)|| substr(beneficiario_direccion,0,4) as id_ben ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				COUNT(ordenante_nombre1) as maxtrans_Ord, round (sum(monto_total),2)  as monto_pesos
		FROM	tablapld
		WHERE	((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
				and tipo_orden ='OPA' 
		group by 1,2,3
		into TEMP T1 with no log;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
		
		
	
		SELECT 
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)|| substr(beneficiario_apmaterno,0,4)|| month(nvl(beneficiario_fecha_nac,'01/01/1900'))||day(nvl(beneficiario_fecha_nac,'01/01/1900'))||year(nvl(beneficiario_fecha_nac,'01/01/1900')) as id_ben ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				COUNT(ordenante_nombre1) as maxtrans_Ord, round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		group by 1,2,3
		into TEMP T1 with no log;
		
	
	ELSE	
		
		SELECT 
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)|| substr(beneficiario_apmaterno,0,4)|| month(beneficiario_fecha_nac)||day(beneficiario_fecha_nac)||year(beneficiario_fecha_nac) as id_ben ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				COUNT(ordenante_nombre1) as maxtrans_Ord, round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa and fecha_remesa between vvfechini and vvfechfin
		group by 1,2,3
		into TEMP T1 with no log;
		
	END IF
	
	--procesos beneficiarios
	select	id_ben,nombre_Ben, count (maxtrans_Ord) as conteo, sum (maxtrans_Ord) as Num_Recibida, round (sum(monto_pesos),2)  as Monto_Totpeso
	from 	T1			
	group by id_ben,nombre_Ben
	into temp T2 with no log;

	--tabla final 
	select tc.nombre_Ben,tc.Num_Recibida,tc.Monto_Totpeso,tf.nombre_Ord,tf.maxtrans_Ord,tf.monto_pesos 
	from T1 tf, T2 tc
	where tc.id_ben = tf.id_ben
	order by Num_Recibida desc
	into TEMP T3 with no log;

		
	
	IF tpo_remesa IN ('BTS','OPA') THEN 
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,nomb_ben,transferidas,montotot_pesos,nomb_ord,num_operaciones,mont_pesos)
		select 	vvfechini,vvfechfin,nombre_Ben,Num_Recibida,Monto_Totpeso,nombre_Ord,maxtrans_Ord,monto_pesos	
		from T3;
	ELSE
		
		insert into bdiauditor:"informix".tblpld_wu (vvfechini,vvfechfin,nomb_ben,transferidas,montotot_pesos,
		nomb_ord,num_operaciones,mont_pesos,nombre_transacc)
		select 	vvfechini,vvfechfin,nombre_Ben,Num_Recibida,Monto_Totpeso,nombre_Ord,maxtrans_Ord,monto_pesos,
		case WHEN tpo_remesa = 'WUN' THEN 'wu'
					WHEN tpo_remesa = 'OVA' THEN 'ov'
					WHEN tpo_remesa = 'VIG'	THEN 'vi' end	
		from T3;
	END IF
	
	drop table T1;
	drop table T2;
	drop table T3;
	drop table tablapld;
end if;	 
-- ***********************************************
-- * Transferencias BTS beneficiarios por  monto *
-- ***********************************************
if vtipo = 10 THEN

	--procesos ordenantes
	
	IF tpo_remesa = 'OPA' THEN
		
		SELECT 
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)|| substr(beneficiario_apmaterno,0,4)|| substr(beneficiario_direccion,0,4) as id_ben ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				COUNT(ordenante_nombre1) as maxtrans_Ord, round (sum(monto_total),2)  as monto_pesos
		FROM	tablapld
		WHERE	((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin)) 
				and tipo_orden ='OPA' 
		group by 1,2,3
		into TEMP T1 with no log;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		SELECT 
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)|| substr(beneficiario_apmaterno,0,4)|| month(nvl(beneficiario_fecha_nac,'01/01/1900'))||day(nvl(beneficiario_fecha_nac,'01/01/1900'))||year(nvl(beneficiario_fecha_nac,'01/01/1900')) as id_ben ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				COUNT(ordenante_nombre1) as maxtrans_Ord, round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas 
		WHERE tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin and abono_cuenta = pdepcta
		group by 1,2,3
		into TEMP T1 with no log;
	
		
	ELSE
	
	
		SELECT 
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
				substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)|| substr(beneficiario_apmaterno,0,4)|| month(beneficiario_fecha_nac)||day(beneficiario_fecha_nac)||year(beneficiario_fecha_nac) as id_ben ,
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
				COUNT(ordenante_nombre1) as maxtrans_Ord, round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas 
		WHERE tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin
		group by 1,2,3
		into TEMP T1 with no log;

	END IF
	
	--procesos beneficiarios
	select	id_ben,nombre_Ben, count (maxtrans_Ord) as conteo, sum (maxtrans_Ord) as Num_Recibida, round (sum(monto_pesos),2)  as Monto_Totpeso
	from 	T1 			
	group by id_ben,nombre_Ben
	into temp T2 with no log;

	--tabla final 
	select tc.nombre_Ben,tc.Num_Recibida,tc.Monto_Totpeso,tf.nombre_Ord,tf.maxtrans_Ord,tf.monto_pesos 
	from T1 tf, T2 tc
	where tc.id_ben = tf.id_ben
	order by Monto_Totpeso desc
	into TEMP T3 with no log;

	IF tpo_remesa in ('BTS','OPA') THEN
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,nomb_ben,transferidas,montotot_pesos,nomb_ord,num_operaciones,mont_pesos)
		select 	vvfechini,vvfechfin,nombre_Ben,Num_Recibida,Monto_Totpeso,nombre_Ord,maxtrans_Ord,monto_pesos	
		from T3;
	ELSE
		insert into bdiauditor:"informix".tblpld_wu (vvfechini,vvfechfin,nomb_ben,transferidas,montotot_pesos,
		nomb_ord,num_operaciones,mont_pesos,nombre_transacc)
		select 	vvfechini,vvfechfin,nombre_Ben,Num_Recibida,Monto_Totpeso,nombre_Ord,maxtrans_Ord,monto_pesos,
		case WHEN tpo_remesa = 'WUN' THEN 'wu'
					WHEN tpo_remesa = 'OVA' THEN 'ov'
					WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T3;
	END IF
	
	drop table T1;
	drop table T2;
	drop table T3;
	drop table tablapld;	
end if;	
-- **************************************************
-- * Transferencias BTS beneficiarios por domicilio.*
-- **************************************************
if vtipo = 11 THEN

	--procesos ordenantes	
	
	IF tpo_remesa = 'OPA' THEN
		SELECT TRIM(substr(beneficiario_direccion,0,7)) as DirBene, beneficiario_direccion as DirBenf,
		TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
		substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
		substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||substr(beneficiario_apmaterno,0,4)|| TRIM(substr(beneficiario_direccion,0,4)) as id_ben ,
		TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
		count(ordenante_nombre1) as maxtrans_benf, round (sum(monto_total),2)  as monto_pesos
		FROM tablapld 
		WHERE  ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
				and tipo_orden ='OPA'
		group by 1,2,3,4,5,6
		into TEMP T1 with no log;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN

		SELECT	
		TRIM(substr(beneficiario_ciudad,0,4)) ||" "|| TRIM(substr(beneficiario_colonia,0,4)) ||' '|| 
		TRIM(substr(beneficiario_calle,0,4)) ||' '|| TRIM(substr(beneficiario_num_ext,0,4)) ||' '|| 
		TRIM(substr(beneficiario_num_int,0,4)) ||' '|| TRIM(substr(beneficiario_depto,0,4)) ||' '||
		TRIM(substr(beneficiario_cp,0,4)) as DirBene,
		TRIM(beneficiario_ciudad) ||' '|| TRIM(beneficiario_colonia) ||' '|| TRIM(beneficiario_calle) ||' '|| 
		TRIM(beneficiario_num_ext) ||' '|| TRIM(beneficiario_num_int) ||' '|| TRIM(beneficiario_depto) ||' '||
		TRIM(beneficiario_cp) as DirBenf, 
		TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
		substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
		substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||substr(beneficiario_apmaterno,0,4)|| month(nvl(beneficiario_fecha_nac,'01/01/1900'))||day(nvl(beneficiario_fecha_nac,'01/01/1900'))||year(nvl(beneficiario_fecha_nac,'01/01/1900')) as id_ben ,
		TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
		count(ordenante_nombre1) as maxtrans_benf, round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas where tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin AND abono_cuenta = pdepcta
		group by 1,2,3,4,5,6
		into TEMP T1 with no log;	
	
	ELSE
	
	
		SELECT	
		TRIM(substr(beneficiario_ciudad,0,4)) ||" "|| TRIM(substr(beneficiario_colonia,0,4)) ||' '|| 
		TRIM(substr(beneficiario_calle,0,4)) ||' '|| TRIM(substr(beneficiario_num_ext,0,4)) ||' '|| 
		TRIM(substr(beneficiario_num_int,0,4)) ||' '|| TRIM(substr(beneficiario_depto,0,4)) ||' '||
		TRIM(substr(beneficiario_cp,0,4)) as DirBene,
		TRIM(beneficiario_ciudad) ||' '|| TRIM(beneficiario_colonia) ||' '|| TRIM(beneficiario_calle) ||' '|| 
		TRIM(beneficiario_num_ext) ||' '|| TRIM(beneficiario_num_int) ||' '|| TRIM(beneficiario_depto) ||' '||
		TRIM(beneficiario_cp) as DirBenf, 
		TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,
		substr(ordenante_nombre1,0,4)||substr(ordenante_appaterno,0,4)||substr(ordenante_apmaterno,0,4)||substr(ordenante_direccion,0,4) as id_ord,
		substr(beneficiario_nombre1,0,4)|| substr(beneficiario_appaterno,0,4)||substr(beneficiario_apmaterno,0,4)|| month(nvl(beneficiario_fecha_nac,'01/01/1900'))||day(nvl(beneficiario_fecha_nac,'01/01/1900'))||year(nvl(beneficiario_fecha_nac,'01/01/1900')) as id_ben ,
		TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben,
		count(ordenante_nombre1) as maxtrans_benf, round (sum(monto_total),2)  as monto_pesos
		FROM bdisac:sac_pld_remesas where tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin
		group by 1,2,3,4,5,6
		into TEMP T1 with no log;
		
	END IF	

	--procesos beneficiarios
	select	DirBene,DirBenf,id_ben,nombre_Ben,sum (maxtrans_benf) as Num_Recibida, round (sum(monto_pesos),2)  as Monto_Totpeso
	from 	T1 			
	group by DirBene,id_ben,DirBenf,nombre_Ben
	into temp T2 with no log;

	select tf.DirBene, count(tf.DirBene) as num  from T1 tf, T2 tc
	where tf.DirBene = tc.DirBene
	group by tf.DirBene
	into temp T3 with no log;

	select DirBene from T3 where  num >= 2
	into temp T4 with no log;

	select tf.id_ben, count(tf.id_ben) as num  from T1 tf, T2 tc
	where tf.id_ben = tc.id_ben
	group by tf.id_ben
	into temp T5 with no log;


	select id_ben from T5 where  num = 1
	into temp T6 with no log;

	--tabla final 
	select tf.DirBene,tf.DirBenf,tc.nombre_Ben,tc.Num_Recibida,tc.Monto_Totpeso,tf.nombre_Ord,tf.maxtrans_benf,tf.monto_pesos 
	from T1 tf, T2 tc,T4 tdiez,T6 tdoce
	where tf.DirBene = tdiez.DirBene
	and tc.DirBene = tdiez.DirBene
	and tf.id_ben = tdoce.id_ben
	and tc.id_ben = tdoce.id_ben
	into TEMP T7 with no log;

	IF tpo_remesa in ('BTS','OPA') THEN
		insert into bdiauditor:"informix".tbltrans_bts (DirBene,vvfechini,vvfechfin,nomb_ben,transferidas,montotot_pesos,nomb_ord,calle,num_operaciones,mont_pesos)
		select 	DirBene,vvfechini,vvfechfin,nombre_Ben,Num_Recibida,Monto_Totpeso,nombre_Ord, DirBenf,maxtrans_benf,monto_pesos
		from T7;
	ELSE
		insert into bdiauditor:"informix".tblpld_wu (DirBene,vvfechini,vvfechfin,nomb_ben,transferidas,
			montotot_pesos,nomb_ord,num_operaciones,mont_pesos,nombre_transacc)
		select 	DirBene,vvfechini,vvfechfin,nombre_Ben,Num_Recibida,Monto_Totpeso,nombre_Ord,maxtrans_benf,monto_pesos,
		case WHEN tpo_remesa = 'WUN' THEN 'wu'
						WHEN tpo_remesa = 'OVA' THEN 'ov'
						WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T7;
	END IF
	
	drop table T1;
	drop table T2;
	drop table T3;
	drop table T4;
	drop table T5; 
	drop table T6;    
	drop table T7;  
	drop table tablapld;	
end if;	
-- *********************************
-- * Reporte Regulatorio  Ver BTS 2*
-- *********************************
 if vtipo = 12  THEN 
 
	IF tpo_remesa = 'OPA' THEN
	
		SELECT 
			beneficiario_nombre1, beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
			(SELECT monto_total / precio FROM tipo_cambio tp WHERE  tp.fecha_tc = fecha_pago-1) as monto_dolares
		FROM tablapld 
		WHERE  ((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
				and tipo_orden ='OPA'
		group by 1,2,3,4,5
		into TEMP Tx with no log;
	
	
		SELECT 
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben ,
			'19000101' as r_fecha_nac
		FROM Tx
		WHERE  monto_dolares >= (select valor FROM bdiauditor:param WHERE llave = 'PARAM_MONTO_RPTREG')
		into TEMP T1 with no log; 
		
		DROP table tx;
		
		drop table tablapld;
		
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		select 
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben ,
			YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac
		from bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin
		and monto_dolares >= (select valor FROM bdiauditor:param WHERE llave = 'PARAM_MONTO_RPTREG') AND abono_cuenta = pdepcta
		into TEMP T1 with no log; 
		
		
	ELSE	
		
		select 
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben ,
			YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac
		from bdisac:sac_pld_remesas
		where tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin
		and monto_dolares >= (select valor FROM bdiauditor:param WHERE llave = 'PARAM_MONTO_RPTREG')
		into TEMP T1 with no log; 

	END IF
	
	IF tpo_remesa in ('BTS','OPA') THEN
		insert into bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,nomb_ben,fecha_nacimiento)						
		select 	vvfechini,vvfechfin,nombre_Ben,r_fecha_nac	
		from T1;
	ELSE
		insert into bdiauditor:"informix".tblpld_wu (vvfechini,vvfechfin,nomb_ben,fecha_nacimiento,nombre_transacc)						
		select 	vvfechini,vvfechfin,nombre_Ben,r_fecha_nac	,
		case WHEN tpo_remesa = 'WUN' THEN 'wu'
						WHEN tpo_remesa = 'OVA' THEN 'ov'
						WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T1;
	END IF
	drop table T1;
end if;
-- **********************************
-- * Reporte General BTS  VER BTS 2 *
-- **********************************
 if vtipo = 13  THEN 	
	
	IF tpo_remesa = 'OPA' THEN
	
		SELECT 
			TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,	
			TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben  , 
			(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_nombre ,
				(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_direccion1 ,
				(SELECT direccion2 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal_numero_destino ) as suc_direccion2 ,
				sucursal_numero_destino as sucursal, num_control as confirmation_nm,"p" as txn_status ,
				' ' as r_nom_calle, ' ' as r_num_ext,' ' as r_num_int ,
				'19000101' as r_fecha_nac,
				' ' as r_depto, beneficiario_direccion as r_colonia ,
				' ' as r_cp,' ' as r_mncpo_deleg,' ' as r_ciudad,
				' ' as r_estado,monto_total as monto_tot,fecha_pago as fech_alt,folio_sucursal as folio_suc,
				usuario_pago as usuario,(SELECT monto_total / precio FROM tipo_cambio tp WHERE  tp.fecha_tc = fecha_pago-1) as total_dollares_xenvio
		FROM	tablapld rm
		WHERE	((fecha_pago between vvfechini and vvfechfin ) or (fecha_envio between vvfechini and vvfechfin))
				and tipo_orden ='OPA'
		group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 		
	    into TEMP T1 with no log;
	
	ELIF tpo_remesa = 'BTS' and (pdepcta ='SI' OR pdepcta ='NO')THEN
	
		select   
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,	
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben  ,
				(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_nombre ,
				(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion1 ,
				(SELECT direccion2 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion2 ,
				sucursal, num_confirmacion as confirmation_nm, "A" as txn_status ,
				beneficiario_calle as r_nom_calle, beneficiario_num_ext as r_num_ext,beneficiario_num_int as r_num_int ,
				 YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac,
				beneficiario_depto as r_depto, beneficiario_colonia as r_colonia ,
				beneficiario_cp as r_cp,beneficiario_mncpo_del as r_mncpo_deleg,beneficiario_ciudad as r_ciudad,
				beneficiario_estado as r_estado,monto_total as monto_tot,fecha_remesa as fech_alt,folio_sucursal as folio_suc,
				usuario,monto_dolares as total_dollares_xenvio			
	   from bdisac:sac_pld_remesas rm
	   WHERE tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin AND abono_cuenta = pdepcta
		into TEMP T1 with no log;
		
	
	ELSE	
				
		select   
				TRIM(ordenante_nombre1) ||" "||	TRIM(ordenante_nombre2) ||" "|| TRIM(ordenante_appaterno) ||" "|| TRIM(ordenante_apmaterno) as nombre_Ord,	
				TRIM(beneficiario_nombre1 ) ||" "||	TRIM(beneficiario_nombre2) ||" "|| TRIM(beneficiario_appaterno) ||" "|| TRIM(beneficiario_apmaterno) as nombre_Ben  ,
				(SELECT nombre FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_nombre ,
				(SELECT direccion1 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion1 ,
				(SELECT direccion2 FROM bdinteg:si_sucursales suc where suc.sucursal = rm.sucursal ) as suc_direccion2 ,
				sucursal, num_confirmacion as confirmation_nm, "A" as txn_status ,
				beneficiario_calle as r_nom_calle, beneficiario_num_ext as r_num_ext,beneficiario_num_int as r_num_int ,
				 YEAR(beneficiario_fecha_nac)|| lpad(MONTH(beneficiario_fecha_nac),2,0)||lpad(day(beneficiario_fecha_nac),2,0) as r_fecha_nac,
				beneficiario_depto as r_depto, beneficiario_colonia as r_colonia ,
				beneficiario_cp as r_cp,beneficiario_mncpo_del as r_mncpo_deleg,beneficiario_ciudad as r_ciudad,
				beneficiario_estado as r_estado,monto_total as monto_tot,fecha_remesa as fech_alt,folio_sucursal as folio_suc,
				usuario,monto_dolares as total_dollares_xenvio			
	   from bdisac:sac_pld_remesas rm
	   WHERE tipo_remesa =tpo_remesa AND fecha_remesa between vvfechini and vvfechfin
		into TEMP T1 with no log;
	
	END IF
	
	IF tpo_remesa in ('BTS','OPA') THEN
		SELECT COUNT(*) into vconteo FROM T1;

		insert into  bdiauditor:"informix".tbltrans_bts (vvfechini,vvfechfin,num_confirmacion,nomb_ord, estatus,fechapago, mont_dolar,mont_pesos,
		nomb_ben,fecha_nacimiento,calle,num_ext,num_int,depto,colonia,cp,delg_mun,ciudad,estado,num_sucpag,nomb_sucpag,loc_sucpag,empleado, dirbene  )
		select 	vvfechini,vvfechfin,confirmation_nm,nombre_Ord,txn_status,fech_alt,total_dollares_xenvio,monto_tot,nombre_Ben,r_fecha_nac,r_nom_calle,
		r_num_ext,r_num_int,r_depto,r_colonia,r_cp,r_mncpo_deleg,r_ciudad,r_estado,sucursal,suc_nombre,suc_direccion1,	usuario, vconteo
		from T1;
	ELSE
		insert into  bdiauditor:"informix".tblpld_wu  (vvfechini,vvfechfin,num_confirmacion,nomb_ord,
		estatus,fechapago, mont_dolar,mont_pesos,
		nomb_ben,fecha_nacimiento,calle,colonia,cp,ciudad,estado,num_sucpag,nomb_sucpag,loc_sucpag,empleado,
		nombre_transacc)
		select 	vvfechini,vvfechfin,confirmation_nm,nombre_Ord,txn_status,fech_alt,total_dollares_xenvio,
		monto_tot,nombre_Ben,r_fecha_nac,r_nom_calle,
		r_colonia,r_cp,r_ciudad,r_estado,sucursal,suc_nombre,
		suc_direccion1,	usuario, 
		case WHEN tpo_remesa = 'WUN' THEN 'wu'
							WHEN tpo_remesa = 'OVA' THEN 'ov'
							WHEN tpo_remesa = 'VIG'	THEN 'vi' end
		from T1;
	END IF

		
	drop table T1;
	drop table tablapld;
end if;

	
end;
end procedure;