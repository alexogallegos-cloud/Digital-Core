CREATE PROCEDURE "informix".pro_genera_reportes_pl()
returning CHAR(5); --Codigo Retorno
    
DEFINE cCodret                    CHAR(5);             
DEFINE iSqlerr                    INTEGER;
DEFINE iExiste                    INTEGER;

DEFINE cCadena         			  CHAR(5500);
DEFINE vNomarch 				  CHAR(255); --cadena con nombre del archivo
DEFINE vPath 					  CHAR(255); --cadena con la ruta del archivo
DEFINE vseparador 				  CHAR(1);
DEFINE dateNow 					  CHAR(15);
DEFINE dateAft					  CHAR(15);
DEFINE nameReportCons			  CHAR(15);
DEFINE constPuntosPolizasHistorico CHAR(15);
DEFINE extension				  CHAR(4);

DEFINE rFechaInicio				datetime year to second;
DEFINE rFechaFin				datetime year to second;

DEFINE aProducto 				char(40);
DEFINE aNumCte 					char(20);
DEFINE aNumCredito 				char(20);
DEFINE bMontoAcumulado			decimal(16,2);
DEFINE rAmount 					decimal(16,2);
DEFINE rPercentagePoints 		char(40);
DEFINE eSaldoTotal 				decimal(16,2);
DEFINE rAccumulatedMonetary 	decimal(16,2);
DEFINE fPeriodo 				char(40);
DEFINE rExpiration              char(40);
DEFINE aOrigen	                char(40);
DEFINE cPorcentajeEsp			char(40);
DEFINE cPorcentajeBen			char(40);
DEFINE cMontoMinimo				decimal(16,2);
DEFINE aReferencia23			CHAR(40);
DEFINE aFechaMov				DATE;
DEFINE dFechaNac				DATE;
DEFINE eFechaActualizacion		DATE;
DEFINE aDiaUltimo				SMALLINT;
DEFINE aFechaFinMes				DATE;


---------------------------------------
LET cCodret                = "00000";
LET iSqlerr                = 0;
LET iExiste                = 0;
LET cCadena 			   = "";
LET vPath 				   = "";
LET vSeparador             = '|';
LET dateNow			       = "";
LET dateAft			       = "";
LET nameReportCons		   = "";
LET constPuntosPolizasHistorico  = "";
LET	extension 			   = '.txt';

LET aProducto 				= "";
LET aNumCte 				= "";
LET aNumCredito 			= "";
LET bMontoAcumulado			= "";
LET rAmount					= "";
LET rPercentagePoints 		= "";
LET eSaldoTotal 			= 0;
LET rAccumulatedMonetary 	= "";
LET fPeriodo 				= "";
LET rExpiration 			= "";
LET aOrigen		 			= "";
LET cPorcentajeEsp			= "";
LET cPorcentajeBen			= "";
LET cMontoMinimo			= "";
LET aReferencia23			= "";
LET aFechaMov				= "";
LET dFechaNac				= "";
LET eFechaActualizacion		= "";
LET aDiaUltimo				= 0;
LET aFechaFinMes			= "";

---------------------------------------
    
BEGIN
    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret;
        END IF;
    END EXCEPTION;
    --Activacion/Desactivacion del Trace del SP
    --SET DEBUG FILE TO "/resplogifx/archivoscredito//pro_genera_reportes_pl.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--Inicializamos las fechas para la generacion de los archivos txt
   SELECT TO_CHAR( fecha_hoy-1  , '%d_%m_%Y') as reportConst,
        TO_CHAR( fecha_hoy-1 , '%d%m%Y') as reportConstPuntosPolizasHistorico,
		TO_CHAR( fecha_hoy-1  , '%Y-%m-%d') as dabdicredart, 
		TO_CHAR( fecha_hoy-2  , '%Y-%m-%d')   AS dateEnd,
		ult_dia_mes
		INTO nameReportCons,constPuntosPolizasHistorico, dateNow, dateAft,aFechaFinMes
		FROM bdicred:sd_fechas
		WHERE empresa = '001';
	  
	  --Variables para la generacion del reporte de  puntos 
	  LET rFechaInicio = trim(dateNow) || " 00:00:00";	  LET rFechaFin = trim(dateNow) ||" 23:59:59";	--##########################################################
	--#####Variables para la generacion de reportes Manual######
	--##########################################################
	--LET dateAft = '2023-08-14'; --Antier
    --LET dateNow = '2023-08-15'; --Ayer
	--LET rFechaInicio = "2023-08-14 00:00:00";--Ayer
	--LET rFechaFin = "2023-08-15 23:59:59";--Ayer
	----###################################################
	
 	LET cCodret='00000';
	LET cCadena = '';
	LET vPath = '/resplogifx/archivoscredito/';
	--LET vPath = '/informix/roman/reportes/';
	--#############################################
	--#####GENERACION DE REPORTE CONCILIACION######
	--#############################################
	
	
    --Asignamos el nombre del archivo de acuerdo a la fecha del dia   
 	LET vNomarch = 'consul_conciliarecompensa_diaant_vs_' || trim(nameReportCons) || trim(extension);
	
 	--Generamos el archivo sql con para despues agregar la sentencia a ejecutar para la descargar del archivo
	LET cCadena = 'echo " unload to ' || "'"|| trim(vPath) || trim(vNomarch) || "' delimiter '|' " || '" >' || trim(vPath) || 'concilia_pl.sql';
    SYSTEM TRIM(cCadena);
           
   	--Generamos la sentencia sql para ejecutar y la guardamos
	LET cCadena = 'echo "'|| 'select A.num_producto as product,A.numcte as client,A.num_credito as bill,A.fecha_apertura as openingDate,A.status_cred as stageStatus, (NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0) as sdoPointsStart, case when B.origen = ''Plan_Lealtad'' then (((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0)) * .5)  when B.origen = ''Reworth'' then  ((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  end as sdoMonetaryStart, NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0) as sdoPointsMov, case when B.origen = ''Plan_Lealtad'' then ((NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0))  * .5) when B.origen = ''Reworth'' then  (NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0))  end  as sdoMonetaryMov, ((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  +(NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0)) as sdoPointsCalculated, case when B.origen = ''Plan_Lealtad'' then ((((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  +(NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0)))  * .5)  when B.origen = ''Reworth'' then  ((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  +(NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0)) end  as sdoMonetaryCalculated, NVL(C.saldo_total,0) as sdoPointsSis, case when B.origen = ''Plan_Lealtad'' then (NVL(C.saldo_total,0)  * .5) when B.origen = ''Reworth'' then  NVL(C.saldo_total,0)  end as sdoMonetarySis,NVL(C.saldo_total,0) - (((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  +(NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0))) as sdoPointsDif, case when B.origen = ''Plan_Lealtad'' then (NVL(C.saldo_total,0)  * .5) when B.origen = ''Reworth'' then  NVL(C.saldo_total,0)  end - case when B.origen = ''Plan_Lealtad'' then ((((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  +(NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0))) * .5)  when B.origen = ''Reworth'' then  ((((NVL(C.saldo_total,0)+NVL(EE.TotalCargosCashHoy,0)+NVL(UU.TotalCargosCashHoyT,0))-NVL(DD.TotalAbonosAyer,0))  +(NVL(DD.TotalAbonosAyer,0)- NVL(UU.TotalCargosCashHoyT,0)))) end as sdoMonetaryDif, TO_CHAR( MIN(V.fecha_insert) , ''%d-%m-%Y'') as DATE_INSERT_OLD, TO_CHAR( MAX(V.fecha_insert), ''%d-%m-%Y'') as DATE_INSERT_NOW, B.origen as origin from informix.sd_maecred as A left join informix.sd_movs_monedero_plan_lealtad as B on A.numcte = B.numcte and A.num_credito = B.num_credito left join informix.sd_monedero_plan_lealtad as C on C.numcte = B.numcte and B.origen=C.origen left join informix.sd_vigencia_monedero_plan_lealtad as V on C.numcte = V.numcte LEFT join (select NVL(sum(D.beneficio_calculado),0) as TotalAbonosAyer, D.num_credito,D.origen from informix.sd_movs_monedero_plan_lealtad as D where D.tipo_mov = ''ABONO_PUNTOS''  and fecha_mov between '''|| trim(dateNow) ||' 00:00:00'' and '''|| trim(dateNow) ||' 23:59:59'' group by D.num_credito,D.origen  ) as DD on DD.num_credito = A.num_credito and B.origen=DD.origen LEFT join (select NVL(sum(E.beneficio_calculado),0) as TotalCargosCashHoy, E.num_credito,E.origen from informix.sd_movs_monedero_plan_lealtad as E where E.tipo_mov = ''CARGO_PUNTOS'' and fecha_mov between '''|| trim(dateAft) ||' 00:00:00'' and '''|| trim(dateAft) ||' 23:59:59'' group by E.num_credito,E.origen  ) as EE on EE.num_credito = A.num_credito and B.origen=EE.origen LEFT join (select NVL(sum(U.beneficio_calculado),0) as TotalCargosCashHoyT, U.num_credito,U.origen from informix.sd_movs_monedero_plan_lealtad as U where U.tipo_mov = ''CARGO_PUNTOS'' and U.fecha_mov between '''|| trim(dateNow) ||' 00:00:00'' and '''|| trim(dateNow) ||' 23:59:59'' group by U.num_credito,U.origen  ) as UU on UU.num_credito = A.num_credito and B.origen=UU.origen  group by A.num_producto, A.numcte, A.num_credito, A.fecha_apertura, A.status_cred, sdoPointsStart,sdoMonetaryStart, sdoPointsMov, sdoMonetaryMov, sdoPointsCalculated, sdoMonetaryCalculated, sdoPointsSis, sdoMonetarySis,sdoPointsDif, sdoMonetaryDif, B.origen">>' || trim(vPath) || 'concilia_pl.sql';
    SYSTEM TRIM(cCadena);
    
	LET cCadena = '';
    --Ejecutamos archivo sql para generar archivo de concilia
    LET cCadena = 'dbaccess bdicred ' || trim(vPath) || 'concilia_pl.sql';
    SYSTEM TRIM(cCadena);
	   
	LET cCadena = '';
    --Eliminamos archivo sql que genera archivo de concilia
	LET cCadena = 'rm ' || trim(vPath) || 'concilia_pl.sql';
    SYSTEM TRIM(cCadena);
   
   --#########################################
   --######GENERACION DE REPORTE POLIZAS######
   --#########################################
   
   
    --Inicializamos las fechas y las variables necesarias para el reporte de polizas
   	LET vNomarch = '';
    LET cCadena = '';
	
	
    --Asignamos el nombre del archivo de acuerdo a la fecha del dia   
 	LET vNomarch = 'reporte_Polizas_' || trim(constPuntosPolizasHistorico) || trim(extension);

 	--Generamos el archivo sql con para despues agregar la sentencia a ejecutar para la descargar del archivo
	LET cCadena = 'echo " unload to ' || "'"|| trim(vPath) || trim(vNomarch) || "' delimiter '|' " || '" >' || trim(vPath) || 'reportes_polizas_pl.sql';
    SYSTEM TRIM(cCadena);
   
    --Guardamos archivo sql desde el sistema para despues generar el archivo de reportes de polizas
 	LET cCadena = 'echo "'|| 'SELECT ''001'' AS Business, '' '' AS CcSource, '' '' AS User, a.fecha_mov AS CaptureDate, a.num_credito AS Bill, '' '' AS Sub, '' '' AS ss, '' '' AS sss, '' '' AS ssss, '' '' AS Sector, ''mex'' AS Region, '' '' AS CcDestinity, '' '' AS assistant, current AS ValueDate, a.moneda AS currency, case when a.tipo_mov = ''ABONO_PUNTOS'' then cast (floor(a.beneficio_calculado) as char(40)) when a.tipo_mov = ''ABONO_CASHBACK'' then cast (a.monto as char(40)) end as Amount, case when a.tipo_mov = ''ABONO_PUNTOS'' then ''ABONO'' when a.tipo_mov = ''ABONO_CASHBACK'' then ''ABONO'' end as nature, a.tipo_mov AS description, a.origen AS origin FROM informix.sd_movs_monedero_plan_lealtad a inner join informix.sd_maecred as B on B.numcte = a.numcte and a.num_credito = B.num_credito where a.tipo_mov in (''ABONO_PUNTOS'',''ABONO_CASHBACK'') and a.fecha_mov BETWEEN '''|| trim(dateNow) ||' 00:00:00'' AND '''|| trim(dateNow) ||' 23:59:59'' " >>' || trim(vPath) ||'reportes_polizas_pl.sql'; 
	SYSTEM TRIM(cCadena);
	LET cCadena = '';

	--Ejecutamos archivo sql para generar archivo de reporte de polizas
	LET cCadena = 'dbaccess bdicred ' || trim(vPath) || 'reportes_polizas_pl.sql';
	SYSTEM TRIM(cCadena);
   
	LET cCadena = '';
	--Eliminamos archivo sql que genera archivo de reportes de polizas
	LET cCadena = 'rm ' || trim(vPath) || 'reportes_polizas_pl.sql';
	SYSTEM TRIM(cCadena);
	
	--#########################################
	--#####GENERACION DE REPORTE HITORICO######
	--#########################################
   	LET vNomarch = '';
    LET cCadena = '';

		
	LET vNomarch = 'his_credito_recompensa_'|| trim(constPuntosPolizasHistorico) || trim(extension);

	--Generamos el archivo sql con para despues agregar la sentencia a ejecutar para la descargar del archivo
	LET cCadena = 'echo " unload to ' || "'"|| trim(vPath) || trim(vNomarch) || "' delimiter '|' " || '" >' || trim(vPath) || 'reportes_historico_pl.sql';
    SYSTEM TRIM(cCadena);
   
	--Generamos el archivo sql con la sentencia a ejecutar para la descargar del archivo
  	LET cCadena = 'echo "'|| ' select A.tipo_producto as PRODUCT, A.num_credito as BILL, A.numcte as CLIENT,C.sucursal as Cc,A.folio as Invoice,B.nro_tarjeta as Card,sum(A.beneficio_calculado) as PointsBalance,A.monto as MoneyBalance,A.tipo_mov as Descp,case when A.origen = ''Plan_Lealtad'' then ''9823'' when A.origen = ''Reworth'' then ''9830'' end as Transacc, ''S'' as Contabil,''N/A'' as Sec, case when A.origen = ''Plan_Lealtad'' then case when A.tipo_producto = ''6001'' then  ''14020108010000'' when A.tipo_producto = ''8100'' then ''14020108020000'' end when A.origen = ''Reworth'' then case when A.tipo_producto = ''6001'' then  ''88840101000000'' when A.tipo_producto = ''8100'' then ''88840102000000'' end end  as charge, case when A.origen = ''Plan_Lealtad'' then case when A.tipo_producto = ''6001'' then  ''24020702010132'' when A.tipo_producto = ''8100'' then ''24020702010232'' end when A.origen = ''Reworth'' then case when A.tipo_producto = ''6001'' then  ''78840101000000'' when A.tipo_producto = ''8100'' then ''78840102000000'' end end as payment, TO_CHAR( CAST(A.fecha_mov AS DATE) , ''%d-%m-%Y'') as DateMov, A.origen origin from informix.sd_movs_monedero_plan_lealtad A, informix.sd_compras_plan_lealtad B, informix.sd_Maecred C where A.numcte = B.numcte and A.monto = B.monto_diario and A.referencia23 = B.referencia23 and A.num_credito = C.num_credito and A.fecha_mov between '''|| trim(dateNow) ||' 00:00:00'' AND '''|| trim(dateNow) ||' 23:59:59'' group by A.tipo_producto, A.num_credito, A.numcte, C.sucursal, A.folio,  B.nro_tarjeta, A.monto,A.tipo_mov,A.origen,A.fecha_mov  " >>' || trim(vPath) ||'reportes_historico_pl.sql'; 
	SYSTEM TRIM(cCadena);
	
	LET cCadena = '';
	--Ejecutamos archivo sql para generar archivo de reporte historico
    LET cCadena = 'dbaccess bdicred ' || trim(vPath) || 'reportes_historico_pl.sql';
    SYSTEM TRIM(cCadena);
	LET cCadena = '';

	--Eliminamos archivo sql que genera archivo de reportes de puntos
    LET cCadena = 'rm ' || trim(vPath) || 'reportes_historico_pl.sql';
    SYSTEM TRIM(cCadena);


	--#######################################
	--#####GENERACION DE REPORTE PUNTOS######
	--#######################################
	TRUNCATE TABLE bdicred:informix.sd_reporte_puntos_acumulados_pl;

	
	FOREACH
		SELECT a.numcte, a.num_credito, a.tipo_producto, a.origen
		 INTO aNumCte, aNumCredito, aProducto, aOrigen
		 FROM "informix".sd_movs_monedero_plan_lealtad a 
		 where a.fecha_mov BETWEEN rFechaInicio AND rFechaFin
		 AND a.tipo_producto IN ('6001', '8100') AND tipo_mov =  'ABONO_PUNTOS' 
		 group by numcte,num_credito,tipo_producto,origen
		 
		 LET aFechaMov = rFechaInicio;
		
		--Ultimo dia del mes
		 LET aDiaUltimo = DAY(aFechaFinMes);
		
		 LET fPeriodo = TO_CHAR(date(aFechaMov), "%m-%Y");
		
		 SELECT NVL(b.monto_acumulado,0)
		 INTO bMontoAcumulado
		 FROM bdicred:"informix".sd_compra_acumulada_plan_lealtad b
		 WHERE b.num_credito = aNumCredito
		 AND b.numcte = aNumCte
		 AND b.producto = aProducto
		 AND b.origen = aOrigen;
		
		 SELECT c.porcentaje_especial, c.porcentaje_beneficio, c.monto_minimo
		 INTO cPorcentajeEsp, cPorcentajeBen, cMontoMinimo
		 FROM bdicred:"informix".sd_productos_permitidos_plan_lealtad c
		 WHERE c.num_producto = aProducto;
		 
		 SELECT d.fecha_nac
		 INTO dFechaNac
		 FROM bdinteg:"informix".si_ctepf d
		 WHERE d.numcte = aNumCte;
		
		 SELECT e.saldo_total
		 INTO eSaldoTotal
		 FROM bdicred:"informix".sd_monedero_plan_lealtad e
		 WHERE e.numcte = aNumCte
		 AND e.origen = aOrigen;
		
	
		select d.fecha_insert 
		INTO eFechaActualizacion
		from (
		select first 1 fecha_insert
		FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
		WHERE numcte = aNumCte
		and estatus = "f"
		ORDER BY fecha_insert asc) as d;
		 
		 LET rAmount = CASE 
						 WHEN aProducto = '6001' THEN cMontoMinimo 
						 WHEN aProducto = '8100' THEN cMontoMinimo 
					   END;
					   
		LET rPercentagePoints = CASE WHEN MONTH(dFechaNac) = MONTH(aFechaMov) THEN
								 CASE WHEN aProducto = '6001' THEN cPorcentajeEsp 
									  WHEN aProducto = '8100' THEN cPorcentajeEsp 
								 END 
								 ELSE  
								 CASE WHEN aProducto = '6001' THEN cPorcentajeBen
									  WHEN aProducto = '8100' THEN cPorcentajeBen  
								 END 
							   END;
		 
		 LET rAccumulatedMonetary = CASE 
										WHEN aOrigen= 'Reworth' THEN   eSaldoTotal  
										WHEN aOrigen= 'Plan_Lealtad' THEN   eSaldoTotal * 0.5
									END;
		
		 IF aOrigen = 'Reworth' then
			 
		 	 SELECT sum(monto)
			 INTO bMontoAcumulado
			 FROM "informix".sd_movs_monedero_plan_lealtad a 
			 where a.fecha_mov BETWEEN MDY(MONTH(aFechaMov), 1, YEAR(aFechaMov)) AND MDY(MONTH(aFechaMov), aDiaUltimo, YEAR(aFechaMov))
			 and a.tipo_producto IN ('6001', '8100') AND a.tipo_mov =  'ABONO_PUNTOS'
			 and a.origen = 'Reworth';
			 
		 	LET rAmount = 0;
		 END IF;
		
		 LET rExpiration = mdy(month(eFechaActualizacion),day(eFechaActualizacion),year(eFechaActualizacion)) + 1 units year;
		 
		 IF eSaldoTotal IS NOT NULL AND eFechaActualizacion IS NOT NULL THEN
			 INSERT INTO bdicred:informix.sd_reporte_puntos_acumulados_pl (Product,Client,Bill,AccomulatedPurchases,Amount,PercentagePoints,PercentageAccumulated,AccumulatedMonetary,CumulativePeriod,Expiration,origen) 
			 VALUES (aProducto,aNumCte,aNumCredito,bMontoAcumulado,rAmount,rPercentagePoints,eSaldoTotal,rAccumulatedMonetary,fPeriodo,rExpiration,aOrigen);
		 END IF;
	END FOREACH;
	
	LET vNomarch = '';
    LET cCadena = '';

	
	LET vNomarch = 'CoppelMaxx_'|| trim(constPuntosPolizasHistorico) || trim(extension);
	
	--Generamos el archivo sql con para despues agregar la sentencia a ejecutar para la descargar del archivo
	LET cCadena = 'echo " unload to ' || "'"|| trim(vPath) || trim(vNomarch) || "' delimiter '|' " || '" >' || trim(vPath) || 'reportes_puntos_pl.sql';
    SYSTEM TRIM(cCadena);
   
	--Generamos el archivo sql con la sentencia a ejecutar para la descargar del archivo
	--Guardamos archivo sql desde el sistema para despues generar el archivo de reportes de puntos
	LET cCadena = 'echo "'|| 'SELECT NVL(product,'' '') as Product,NVL(client,'' '') as Client, NVL(bill,'' '') as Bill, NVL(accomulatedpurchases,'' '') as AccumulatedPurchases, NVL(amount,'' '') as Amout, NVL(percentagepoints,'' '') as PercentagePoints, NVL(percentageaccumulated,'' '') as PercentageAccumulated, NVL(accumulatedmonetary,'' '') as AccumulatedMonetary, NVL(cumulativeperiod,'' '') as CumulativePeriod, NVL(expiration,'' '') as Expiration, NVL(origen,'' '') as Origin FROM informix.sd_reporte_puntos_acumulados_pl  " >>' || trim(vPath) ||'reportes_puntos_pl.sql'; 
	SYSTEM TRIM(cCadena);
	LET cCadena = '';

	--Ejecutamos archivo sql para generar archivo de reporte de puntos
	LET cCadena = 'dbaccess bdicred ' || trim(vPath) || 'reportes_puntos_pl.sql';
	SYSTEM TRIM(cCadena);
   
	LET cCadena = '';
	--Eliminamos archivo sql que genera archivo de reportes de puntos
	LET cCadena = 'rm ' || trim(vPath) || 'reportes_puntos_pl.sql';
	SYSTEM TRIM(cCadena);
	
RETURN  cCodret;
END
END procedure;