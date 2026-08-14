CREATE PROCEDURE "informix".sp_frecuencia_uso()
RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES TARJETAS PERSONALIZADAS:
--AUTOR : PEREZ LOPEZ YULIETTE
--MODIFICADO POR: KITZIA MIRLETH IRBE CASTAÑEDA
--FECHA : 28/11/2017
--FECHA MODIFICACION: 06/08/2019
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

/*VARIABLES PARA OPERACIÃ?N DE FECHAS*/
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

DEFINE v_clave_sucursal   varchar(5);			
DEFINE v_nombre_sucursal  varchar(50);
DEFINE v_subbin       	char(2);
DEFINE v_descripcion      varchar(28);
DEFINE v_transaccion      varchar(28);
DEFINE v_no_tarjetas      integer;
DEFINE v_no_txns          integer;
DEFINE v_impote_total     decimal(19,4);
DEFINE v_txns_promedio    decimal(19,4);
DEFINE v_importe_promedio	decimal(19,4);

--/*SET DEBUG FILE TO "/resplogifx/sp_frecuencia_uso.out";
--*/TRACE ON;

/*INICIALIZACION VARIABLES*/

LET 	CodRetorno = '00000';
LET 	DescRetorno = 'Ejecucion de proceso exitosa.';
LET     viSqlErr = 0;
LET 	viSamErr = 0;
LET 	vsflagentransaccion = 'F';
LET		vicontadorregistros = 0;
LET     vicontadorregistros2 = 0;	

LET v_clave_sucursal   = '';
LET v_nombre_sucursal  = '';
LET v_subbin       	   = '';
LET v_descripcion      = '';
LET v_transaccion      = '';
LET v_no_tarjetas      = 0;
LET v_no_txns          = 0;
LET v_impote_total     = 0.0;
LET v_txns_promedio    = 0.0;
LET v_importe_promedio = 0.0;	

LET     vPeriodoActual = '';
LET     vPeriodoAnterior = '';
LET     vPeriodoAnteAnterior = '';
LET     v_ultimo_Periodo = '';  

/*OBTENER FECHA ACTUAL*/
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:si_fechas WHERE empresa='001';	
--let vfecha_hoy = "08/01/2018"; -- mes dia año

/*OBTENER EL ULTIMO DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCION*/  
LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCION*/
LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ANTERIOR A LA EJECUCION*/  
LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES ANTERIOR A LA EJECUCION*/
LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ACTUAL*/ 
LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

/*OBTENER EL PRIMER DÃA DEL MES ACTUAL*/ 
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
	

        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'frecuencia_uso' AND dbsname= 'bditarjeta') THEN
            DROP TABLE frecuencia_uso;
        END IF;
		
	CREATE TABLE "informix".frecuencia_uso (
            tt_clave_sucursal   varchar(5),			
           	tt_nombre_sucursal  varchar(50),
		    tt_subbin       	char(2),
			tt_descripcion      varchar(28),
			tt_transaccion      varchar(28),
			tt_no_tarjetas      integer,
            tt_no_txns          integer,
			tt_impote_total     decimal(19,4),
			tt_txns_promedio    decimal(19,4),
            tt_importe_promedio	decimal(19,4)
	        
	)EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;

	select max(periodo)
	into v_ultimo_Periodo
	from rpt_frecuencia_uso_tp;
	
	IF(vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecucion para el periodo
		LET CodRetorno = '00005';
		LET DescRetorno = 'El Proceso ya se ejecuto para el periodo ' || vPeriodoAnterior;
		RETURN CodRetorno, DescRetorno;
	END IF;	
	
	/*Reporte 4 - FRECUENCIA DE USO */ 


--Debe ser la cantidad de transacciones de todas las tarjetas durante el Periodo relacionado a dichas tarjetas indendientemente su fecha de asignacion
--indiferente al estatus
		

FOREACH 
-- METER el campo Transaccion de movimiento

select lte.clave_sucursal, suc.nombre_sucursal, substring(mv.numtarjeta from 7 for 2) as subbin, tpo.descripcion,
                   CASE WHEN (mv.ProdInd = '01' AND mv.codtran = '31') then 'Consulta ATM'
                        WHEN (mv.ProdInd = '01' AND mv.codtran = '01') then 'Retiro ATM'
                        WHEN (mv.ProdInd = '02' AND mv.codtran = '00') then 'Compra POS'
                        ELSE 'No determinada' END as Transaccion,
		   count(distinct(tjt.numtarjeta)) as tarjetas, count(mv.secuencia) as transacciones, sum(mv.monto) as Importe, 		   		   
		   ROUND((count(*) /count(distinct(tjt.numtarjeta))),2) as TxnsPromedio, ROUND((sum(mv.monto) / count(mv.secuencia)),2) as ImpPromedio	
		   
		   into v_clave_sucursal, v_nombre_sucursal, v_subbin, v_descripcion,v_transaccion, v_no_tarjetas, v_no_txns, v_impote_total, v_txns_promedio, v_importe_promedio
		   
	from  intercard:"informix".sucursal suc, intercard:"informix".tarjeta tjt, intercard:"informix".lote lte, 
	      intercard:"informix".tipotarjeta tpo, intercard:"informix".movimiento mv
	where lte.clave_tipotarjeta = tpo.clave_tipotarjeta and
		  lte.clave_sucursal = suc.clave_sucursal and
		  tjt.numerolote = lte.numerolote and      
		  tjt.codstatusasignada = 'SIA' and --No importa el estatus de la tarjeta, solo que haya operado en el mes  
suc.enoperacion_imagen ='V' and
		  tjt.fechaasignacion <= vultimo_dia_mes_anterior_hora and--'2018-09-30 23:59:59.9' and
		  mv.fechahorainauth >=  vprimer_dia_mes_anterior_hora and--'2018-09-01 00:00:00.0' and
		  mv.fechahorainauth <=  vultimo_dia_mes_anterior_hora and--'2018-09-30 23:59:59.9' and
		  tjt.numtarjeta = mv.numtarjeta and
		  tpo.clave_tipotarjeta  in ('5','7','12','14','15','17')and
		  mv.transaccionorigen = '1234' and                  
		  mv.formato = '0200' and 
		  mv.codigoiso = '00' and
         ((mv.prodind = '01' and mv.codtran  = '01') or (mv.prodind = '01' and mv.codtran  = '31') or (mv.prodind = '02' and mv.codtran  = '00')) and
		  mv.codreversa = 0 and
		  mv.movreversado = 'F' and
		  suc.clave_sucursal  in( select distinct(suc.clave_sucursal)
	                   from intercard:"informix".sucursal_tipotarjeta tpo, intercard:"informix".sucursal suc
	                   where tpo.clave_tipotarjeta  in('14','15') and
                                 tpo.clave_sucursal = suc.clave_sucursal and
				(tpo.existencia > 0 ))
	group by 1,2,3,4,5
	order by 1,2,3,4,5
	--transaccion
	INSERT  INTO frecuencia_uso(tt_clave_sucursal, tt_nombre_sucursal, tt_subbin, tt_descripcion, tt_transaccion,tt_no_tarjetas,tt_no_txns, tt_impote_total, tt_txns_promedio, tt_importe_promedio) 
	VALUES (v_clave_sucursal, v_nombre_sucursal, v_subbin, v_descripcion,v_transaccion, v_no_tarjetas, v_no_txns, v_impote_total, v_txns_promedio, v_importe_promedio); 


END FOREACH;


insert into rpt_frecuencia_uso_tp
   (periodo, clave_sucursal, nombre_sucursal, subbin, desc_tipotarjeta,transaccion,	no_tarjetas, no_txns, importe_total, promedio_txns, importe_promediotxns)
    select vPeriodoAnterior, tt_clave_sucursal, tt_nombre_sucursal, tt_subbin, tt_descripcion,tt_transaccion, tt_no_tarjetas,tt_no_txns, tt_impote_total, tt_txns_promedio, tt_importe_promedio
    from frecuencia_uso order by vPeriodoAnterior, tt_clave_sucursal, tt_subbin;

            let vsql = ''; 	  
			let vsql = 'echo "Periodo|Sucursal|Nombre de Sucursal|Subbin|Tipo de Tarjeta|Transaccion|No. de Tarjetas|No. de Txns|Impote Total|Txns Promedio|Importe Promedio">/RESPALDOSNEW/TPfrecuenciauso_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /RESPALDOSNEW/TPfrecuenciauso.unl select * from rpt_frecuencia_uso_tp where periodo = ' 
	  		         || vPeriodoAnterior || ';">/RESPALDOSNEW/tpfrecuenciauso.sql'; 			
			system vsql;
			let vsql ='';
			let vsql= 'chmod 777 /RESPALDOSNEW/tpfrecuenciauso.sql';
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess bditarjeta /RESPALDOSNEW/tpfrecuenciauso.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /RESPALDOSNEW/tpfrecuenciauso.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /RESPALDOSNEW/TPfrecuenciauso.unl >>/RESPALDOSNEW/TPfrecuenciauso_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
			system vsql;
			let vsql ='rm /RESPALDOSNEW/TPfrecuenciauso.unl';
			system vsql;
			
        DROP table frecuencia_uso;
				
		RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE;