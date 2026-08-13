CREATE PROCEDURE "informix".sp_reportes_mensuales_tp()
RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES TARJETAS PERSONALIZADAS:
--AUTOR : LUIS ANTONIO GOMEZ SANTIAGO
--MODIFICADO POR: KITZIA MIRLETH IRIBE CASTAÑEDA
--FECHA : 19/06/2018
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
DEFINE v_subbin       	  char(2);
DEFINE v_descripcion      varchar(28);
DEFINE v_no_tarjetas      integer;
DEFINE v_no_txns          integer;
DEFINE v_impote_total     decimal(19,4);
DEFINE v_txns_promedio    decimal(19,4);
DEFINE v_importe_promedio decimal(19,4);

/*
SET DEBUG FILE TO "/resplogifx/sp_reportes_mensuales_tp.out";
TRACE ON;
*/

/*INICIALIZACION VARIABLES*/

LET 	CodRetorno = '00000';
LET 	DescRetorno = 'Ejecucion de proceso exitoso.';
LET     viSqlErr = 0;
LET 	viSamErr = 0;
LET 	vsflagentransaccion = 'F';
LET		vicontadorregistros = 0;
LET     vicontadorregistros2 = 0;	

LET v_clave_sucursal   = '';
LET v_nombre_sucursal  = '';
LET v_subbin       	   = '';
LET v_descripcion      = '';
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

/*OBTENER EL ULTIMO DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃ?N*/  
LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃ?N*/
LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

/*OBTENER EL ULTIMO DÃA DEL MES ANTERIOR A LA EJECUCIÃ?N*/  
LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
	 
/*OBTENER EL PRIMER DÃA DEL MES ANTERIOR A LA EJECUCIÃ?N*/
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

	--Reporte Stock tipo '14'  
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '14';		
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00002';
		LET DescRetorno = 'El Reporte Tarjetas Stock ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_reporte_mensual_stock() INTO CodRetorno, DescRetorno;		
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('02', current, CodRetorno, DescRetorno);
	
	--Reporte Stock tipo '15'  
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_stock_venta_tp
	where clave_tipotarjeta = '15';		
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00003';
		LET DescRetorno = 'El Reporte Tarjetas Personalizadas ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_reporte_mensual_personalizadas() INTO CodRetorno, DescRetorno;	 
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('03', current, CodRetorno, DescRetorno);	
	
	--Reporte PenetraciÃ³n Mercado 
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_penetracion_mercado_tp;
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00004';
		LET DescRetorno = 'El Reporte PenetraciÃ³n Mercado ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_penetracion_mercado() INTO CodRetorno, DescRetorno;	 
	END IF;
	
	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('04', current, CodRetorno, DescRetorno);	
	
	--Reporte Frecuencia de Uso 
	LET v_ultimo_Periodo = '';
	select max(periodo)
	into v_ultimo_Periodo
	from "informix".rpt_frecuencia_uso_tp;
		
	IF (vPeriodoAnterior = v_ultimo_Periodo) THEN -- El proceso ya se ejecutÃ³ para el periodo del mes Anterior
		LET CodRetorno = '00005';
		LET DescRetorno = 'El Reporte Frecuencia de Uso ya se ejecuto para el periodo ' || vPeriodoAnterior;		
    ELSE
        EXECUTE PROCEDURE bditarjeta:"informix".sp_frecuencia_uso() INTO CodRetorno, DescRetorno; 
	END IF;		

	INSERT INTO "informix".td_bitacora_procesos(idproceso, fechahora, no_error, descripcion)
   	VALUES ('05', current, CodRetorno, DescRetorno);		
			
	RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE;