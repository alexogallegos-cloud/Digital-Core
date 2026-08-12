CREATE PROCEDURE "informix".sp_penetracion_mercado()
RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES TARJETAS PERSONALIZADAS: PENETRACION MERCADO
--AUTOR : PEREZ LOPEZ YULIETTE
--MODIFICADO POR: KITZIA MIRLETH IRIBE CARTAÑEDA
--FECHA : 28/11/2017
--FECHA MODIFICACION: 21/11/2019
--BD: BDITARJETA
--****************************************************************************************************

/*VARIABLES PARA RETORNO*/
DEFINE CodRetorno               	 VARCHAR(5);
DEFINE DescRetorno              	 VARCHAR(60);

/*VARIABLES PARA CONTROL DE ERRORES*/
DEFINE viSqlErr                 	 INTEGER;
DEFINE viSamErr                      INTEGER;

/*VARIABLES PARA EL CONTROL DE CONTADORES*/
DEFINE  vsflagentransaccion     	 CHAR(1);
DEFINE 	vicontadorregistros 		 INTEGER;
DEFINE  vicontadorregistros2 		 INTEGER;

/*VARIABLES PARA OPERACIÓN DE FECHAS*/
DEFINE vfecha_hoy               	 DATE;
DEFINE vultimo_dia_mes_ante_anterior DATE;
DEFINE vprimer_dia_mes_ante_anterior DATE; 
DEFINE vultimo_dia_mes_anterior      DATE;
DEFINE vprimer_dia_mes_anterior      DATE;
DEFINE vultimo_dia_mes_actual 		 DATE;
DEFINE vprimer_dia_mes_actual	     DATE;

DEFINE vultimo_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
DEFINE vprimer_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
DEFINE vultimo_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
DEFINE vprimer_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
DEFINE vultimo_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
DEFINE vprimer_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
DEFINE vPeriodoActual 			          VARCHAR(6);
DEFINE vPeriodoAnterior			          VARCHAR(6);
DEFINE vPeriodoAnteAnterior		          VARCHAR(6);
DEFINE v_ultimo_Periodo			          VARCHAR(6);
DEFINE vsql                               char(1150);

/*VARIABLES VARIABLES SCRIPT*/
DEFINE v_sucursal           varchar(5);			
DEFINE v_nombre_sucursal    varchar(50);
DEFINE v_producto       	char(2);
DEFINE v_nombre_producto    varchar(28);
DEFINE v_clave_tipotarjeta   integer;
DEFINE v_no_cuentas         integer;
DEFINE v_no_tarjetas        integer;

--tabla2
DEFINE vv_sucursal           varchar(5);			
DEFINE vv_nombre_sucursal    varchar(50);
DEFINE vv_producto       	char(2);
DEFINE vv_nombre_producto    varchar(28);
DEFINE vv_TP                 integer;
DEFINE vv_TS                 integer;
DEFINE vv_TD                 integer;
DEFINE vv_nocuentas          integer;
DEFINE vv_notarjetas         integer;
DEFINE vv_porcentajepen      decimal (2);
DEFINE vv_porcentajeselectar decimal (2);	

/*
SET DEBUG FILE TO "/resplogifx/sp_penetracion_mercado.out";
TRACE ON;
*/

/*INICIALIZACION VARIABLES*/
LET 	CodRetorno = '00000';
LET 	DescRetorno = 'Ejecución de proceso exitosa.';
LET     viSqlErr = 0;
LET 	viSamErr = 0;
LET 	vsflagentransaccion = 'F';
LET		vicontadorregistros = 0;
LET     vicontadorregistros2 = 0;	

/*VARIABLES VARIABLES SCRIPT*/
LET v_sucursal           = '';
LET v_nombre_sucursal    = '';
LET v_producto           = '';
LET v_nombre_producto    = '';
LET v_clave_tipotarjeta  = 0;
LET v_no_cuentas         = 0;
LET v_no_tarjetas        = 0;
		  
--tabla2		   
LET vv_sucursal         = '';		
LET vv_nombre_sucursal  = '';
LET vv_producto       	= '';
LET vv_nombre_producto  = '';
LET vv_TP               = '';
LET vv_TS               = '';
LET vv_TD               = '';
LET vv_nocuentas        = '';
LET vv_notarjetas       = '';
LET vv_porcentajepen      =0;
LET vv_porcentajeselectar =0;
		    
LET     vPeriodoActual = '';
LET     vPeriodoAnterior = '';
LET     vPeriodoAnteAnterior = '';
LET     v_ultimo_Periodo = '';  

/*OBTENER FECHA ACTUAL*/
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas WHERE empresa='001';	


/*OBTENER EL ULTIMO DÍA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÓN*/  
LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÍA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÓN*/
LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÍA DEL MES ANTERIOR A LA EJECUCIÓN*/  
LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÍA DEL MES ANTERIOR A LA EJECUCIÓN*/
LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÍA DEL MES ACTUAL*/ 
LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

/*OBTENER EL PRIMER DÍA DEL MES ACTUAL*/ 
LET vprimer_dia_mes_actual = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY; 
LET vprimer_dia_mes_hora_actual= extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
LET vprimer_dia_mes_hora_actual = SUBSTRING(vprimer_dia_mes_hora_actual FROM  1 FOR 10) || ' 00:00:00'; 

--Periodo a ejecutar debe ser el periodo del mes anterior al mes actual
LET vPeriodoActual       =  YEAR(vfecha_hoy)|| LPAD(MONTH(vfecha_hoy),2,0);
LET vPeriodoAnterior     =  YEAR(vprimer_dia_mes_anterior)|| LPAD(MONTH(vprimer_dia_mes_anterior),2,0);
LET vPeriodoAnteAnterior =  YEAR(vprimer_dia_mes_ante_anterior)|| LPAD(MONTH(vprimer_dia_mes_ante_anterior),2,0);

BEGIN

	ON EXCEPTION
		SET viSqlErr, viSamErr
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;
	
	BEGIN;
	   TRUNCATE TABLE "informix".producto_tarjeta1; 
	COMMIT;

	BEGIN;
	   TRUNCATE TABLE "informix".producto_tarjeta2;
	COMMIT;

	select max(periodo)
	into v_ultimo_Periodo
	from rpt_penetracion_mercado_tp;
	
	IF(vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutó para el periodo
		LET CodRetorno = '00004';
		LET DescRetorno = 'El Proceso ya se ejecutó para el periodo ' || vPeriodoAnterior;
		RETURN CodRetorno, DescRetorno;
	END IF;	
		
-- Tabla 1		
	/*Reporte 3 - PENETRACIONMERCADO */  
		SELECT  DISTINCT SUBSTR(suc.clave_sucursal,2,4) AS clave_sucursal
        FROM    intercard:"informix".sucursal_tipotarjeta tpo, intercard:"informix".sucursal suc
	    WHERE tpo.clave_tipotarjeta  IN('14','15') AND
                           tpo.clave_sucursal = suc.clave_sucursal AND
						   (tpo.existencia > 0 OR tpo.solicitadas > 0) 
                           INTO TEMP temp_suc WITH NO LOG;

FOREACH
       select vPeriodoAnterior, chq.sucursal, suc.nombre as nombre_sucursal, chq.producto, pro.nombre as nombre_producto, lte.clave_tipotarjeta, 
                count(distinct(cta.numcuenta)) as no_cuentas, count(distinct(tjt.numtarjeta)) as no_tarjetas
	   into vPeriodoAnterior, v_sucursal, v_nombre_sucursal, v_producto, v_nombre_producto, v_clave_tipotarjeta, v_no_cuentas, v_no_tarjetas
       from bdicheq:"informix".sc_maechq chq, bdicheq:"informix".sc_maenoc noc, bdinteg:"informix".si_sucursales suc, bdicheq:"informix".sc_producto pro,
  	   intercard:"informix".tarjetacuenta cta, intercard:"informix".tarjeta tjt, intercard:"informix".lote lte
where chq.cuenta = noc.cuenta and
      chq.producto in('2000','1300','1400','1500','1700','1900','2500') and
      noc.fecha_alta <= vultimo_dia_mes_anterior and 
      chq.status_cta = '1' and
      chq.sucursal = suc.sucursal and
      chq.producto = pro.producto and
      chq.cuenta = cta.numcuenta and
      tjt.numerolote = lte.numerolote and
      cta.numtarjeta = tjt.numtarjeta and
      tjt.codstatustarjeta in('INA','ACT','BLO','BLT')  and
      tjt.codstatusasignada = 'SIA' and
      chq.status_cta = '1' and noc.fecha_alta <= vultimo_dia_mes_anterior and
      tjt.fechaasignacion <= vultimo_dia_mes_anterior_hora and
	  tjt.fechaasignacion >= vprimer_dia_mes_anterior_hora and
      suc.sucursal in  (SELECT clave_sucursal FROM temp_suc )
      group by 1,2,3,4,5,6
      order by 1,2,3,4,5,6


	INSERT  INTO producto_tarjeta1(empresa,tt_sucursal, tt_nombre_sucursal, tt_producto, tt_nombre_producto, tt_clave_tipotarjeta,tt_no_cuentas, tt_no_tarjetas) 
	VALUES 						  ('001'  ,v_sucursal , v_nombre_sucursal , v_producto , v_nombre_producto , v_clave_tipotarjeta , v_no_cuentas, v_no_tarjetas); 

END FOREACH;


FOREACH

    select a.tt_sucursal, a.tt_nombre_sucursal, a.tt_producto, a.tt_nombre_producto, 
		   (select sum(b.tt_no_tarjetas) from producto_tarjeta1 b
				  where b.tt_producto = a.tt_producto and b.tt_clave_tipotarjeta = '15') as tp,
		   (select sum(c.tt_no_tarjetas) from producto_tarjeta1 c
				  where c.tt_producto = a.tt_producto and c.tt_clave_tipotarjeta = '14') as ts,
		   (select sum(d.tt_no_tarjetas) from producto_tarjeta1 d
				  where d.tt_producto = a.tt_producto and d.tt_clave_tipotarjeta not in('14','15')) as td,
		   sum(a.tt_no_cuentas) as cuentas, sum(a.tt_no_tarjetas) as tarjetas      
	
into vv_sucursal, vv_nombre_sucursal, vv_producto, vv_nombre_producto, vv_TP,vv_TS,vv_TD,vv_nocuentas,vv_notarjetas
	   
from producto_tarjeta1 a
where a.empresa='001'
group by a.tt_sucursal,a.tt_nombre_sucursal,a.tt_producto,a.tt_nombre_producto,tp,ts,td   
			
	INSERT  INTO producto_tarjeta2(empresa, tt2_sucursal, tt2_nombre_sucursal, tt2_producto, tt2_nombre_producto, tt2_TP, tt2_TS, tt2_TD,tt2_nocuentas,tt2_notarjetas) 
	VALUES 						  ('001'  , vv_sucursal , vv_nombre_sucursal , vv_producto , vv_nombre_producto , vv_TP , vv_TS , vv_TD ,vv_nocuentas ,vv_notarjetas); 
	
END FOREACH;


FOREACH
select c.tt2_sucursal, c.tt2_producto, sum(((c.tt2_TP +  c.tt2_TS) / c.tt2_nocuentas)),  sum(((c.tt2_TP +  c.tt2_TS) / c.tt2_notarjetas))	   	  
    into vv_sucursal, vv_producto, vv_porcentajepen, vv_porcentajeselectar	   
from producto_tarjeta2 c
where c.empresa='001'
group by 1,2

    UPDATE producto_tarjeta2 d
	SET d.tt2_porcentajepen       =  vv_porcentajepen,
		d.tt2_porcentajeselectar  =  vv_porcentajeselectar	
	where d.tt2_sucursal = vv_sucursal and
	      d.tt2_producto = vv_producto;
END FOREACH;
		
        insert into rpt_penetracion_mercado_tp
        (periodo, clave_sucursal, nombre_sucursal, producto,descripcion_producto, tp,	ts, td,	no_cuentas, no_tarjetas, penetracion, seleccion_tarjeta)
    select vPeriodoAnterior, tt2_sucursal, tt2_nombre_sucursal, tt2_producto,	tt2_nombre_producto, tt2_TP, tt2_TS, tt2_TD, tt2_nocuentas, tt2_notarjetas,
		 tt2_porcentajepen,	tt2_porcentajeselectar
    from producto_tarjeta2 where empresa='001' 
	order by vPeriodoAnterior, tt2_sucursal, tt2_producto;

            let vsql = ''; 	   
			let vsql = 'echo "Sucursal|Clave Sucursal|Nombre de Sucursal|Producto|Nombre Producto|No. cuentas|No. de Tarjetas|TP|TS|TD|%penetracion|%seleccion tarjeta">/RESPALDOSNEW/TPpenetracionmercado_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
		    let vsql=  'echo "UNLOAD TO /RESPALDOSNEW/TPpenetracionmercado.unl select * from rpt_penetracion_mercado_tp where periodo = ' 
	  		         || vPeriodoAnterior || ';">/RESPALDOSNEW/tppenetracionmercado.sql'; 	
			system vsql;
			let vsql ='';
			let vsql= 'chmod 777 /RESPALDOSNEW/tppenetracionmercado.sql';
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess bditarjeta /RESPALDOSNEW/tppenetracionmercado.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /RESPALDOSNEW/tppenetracionmercado.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /RESPALDOSNEW/TPpenetracionmercado.unl >>/RESPALDOSNEW/TPpenetracionmercado_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
			system vsql;
			let vsql ='rm /RESPALDOSNEW/TPpenetracionmercado.unl';
			system vsql;
						
		TRUNCATE TABLE "informix".producto_tarjeta1 DROP STORAGE;
		TRUNCATE TABLE "informix".producto_tarjeta2 DROP STORAGE;
		
		RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE;