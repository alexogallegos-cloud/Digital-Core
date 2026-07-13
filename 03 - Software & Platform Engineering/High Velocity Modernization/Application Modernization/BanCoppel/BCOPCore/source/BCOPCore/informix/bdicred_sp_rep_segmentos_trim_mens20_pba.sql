CREATE PROCEDURE "informix".sp_rep_segmentos_trim_mens20_pba(pEmpresa CHAR(3))
RETURNING CHAR(6);

--Creado por:Guadalupe Espinoza 08/10/2013
--Proceso para generar Reporte trimestral y mensual de uso de línea 

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE vcCodRet 			CHAR(6);
DEFINE cErrorInfo			CHAR(80);
DEFINE pempresa				CHAR(3);
DEFINE pproceso				CHAR(30);
DEFINE pusuario				CHAR(8);
DEFINE cruta				CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE ntrimestre 			CHAR(30);
DEFINE cnomarchivo			CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte				CHAR(20);
DEFINE cnumcred				CHAR(20);
DEFINE cSQL					CHAR(8204);
DEFINE cSQL1				CHAR(6204);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFechaHoy			DATE;
DEFINE dFecha 				DATE;
DEFINE dFechatrim 			DATE;
DEFINE dFecha2 				DATE;
DEFINE dFecha3 				DATE;
DEFINE dFechaprim 			DATE;
DEFINE dDiaprimero  		DATE;
DEFINE dDiaUltimo   		DATE;
DEFINE canio        		CHAR(4);
DEFINE vsegmentos 			CHAR(12);
DEFINE vtotaltrimestre 		DECIMAL(18,2);
DEFINE totalint 			DECIMAL(18,2);
DEFINE sPaso				SMALLINT;
DEFINE sPaso2				SMALLINT;
DEFINE creotabla			CHAR(1);
DEFINE creotabla2			CHAR(1);

--SET DEBUG FILE TO "sp_rep_segmentos_trim_mens.out";
--TRACE ON;

--Inicialización de variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET vcCodRet 				= "000000";
LET pMensaje				= 'PROCESO EXITOSO';
LET pproceso				= '2111';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFechaHoy				= DATE(1);
LET dFecha 					= DATE(1);
LET dFechatrim 				= DATE(1);
LET dFecha2					= DATE(1);
LET dFecha3 				= DATE(1);
LET dFechaprim 					= DATE(1);
LET dDiaprimero 			= '';
LET dDiaUltimo 				= '';
LET canio   				= '';
LET vsegmentos 				= '';
LET vtotaltrimestre 		= 0;
LET totalint 				= 0;
LET sPaso					=0;
LET sPaso2					=0;
LET creotabla 				= '';
LET creotabla2 				= '';
	
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, trim(pMensaje)||'20', '02')
	Returning cCod_RetIB;
		RETURN pCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
		
	SELECT fecha_hoy,pri_dia_mes, pri_dia_mes - 1 units day, pri_dia_mes - 3 units month  
      into dFechahoy,dFechaprim, dFecha, dFechatrim
	FROM bdicred:sd_fechas;
	
	LET dFecha2 = dFechaprim - 1 units month - 1 units day;	LET dFecha3 = dFechaprim - 2 units month - 1 units day;	
   LET canio = lpad(year(dFechahoy),4,'0');

	let dFecha = mdy(month(dFecha),'20', year(dFecha) );
    let dFecha2 = mdy(month(dFecha2),'20', year(dFecha2) );
    let dFecha3 = mdy(month(dFecha3),'20', year(dFecha3) );

	SELECT TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND grupo_parametro = 'CAT_PROMOS' 
	AND num_parametro = 2;
	--let cruta = '/informix/gpe/'; --pruebas

	
    SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'creditostransaccion';
    IF NVL(sPaso,0) > 0 THEN
        DROP TABLE creditostransaccion;
    END IF;
	
	CREATE TABLE "informix".creditostransaccion(
	fecha DATE,
	num_credito CHAR(12),
	num_trans CHAR(2),
    seg_e_0 DECIMAL(18,2),
	seg_e0 DECIMAL(18,2),
	seg_e25 DECIMAL(18,2),
	seg_e50 DECIMAL(18,2),
	seg_e75 DECIMAL(18,2),
	seg_e100 DECIMAL(18,2),
	seg_e_100 DECIMAL(18,2),
	sdo_intereses DECIMAL(18,2),
	monto_compra DECIMAL(18,2),
	monto_disp DECIMAL(18,2));
	
	create index ixcts1 on creditostransaccion (fecha);
	update statistics medium for table creditostransaccion;

	--Segmentacion por numero de transacciones y porcentajes de línea
	
IF 	MONTH(dFecha) = '03' or MONTH(dFecha) = '06' or MONTH(dFecha) = '09' or MONTH(dFecha) = '12' THEN
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '20-Inicia Consulta Principal-Trim', '02')
    Returning cCod_RetIB;
		
	INSERT INTO bdicred:creditostransaccion
	select  ind.fecha, ind.num_credito,
    case   
     when (sum(sdo.mto_fin_ven_trasp) = 1) then 'X1'
     when (sum(sdo.mto_fin_ven_trasp) = 2) then 'X2'
     when (sum(sdo.mto_fin_ven_trasp) = 3) then 'X3'
     when (sum(sdo.mto_fin_ven_trasp) = 4) then 'X4'
     when (sum(sdo.mto_fin_ven_trasp) = 5) then 'X5'
     when (sum(sdo.mto_fin_ven_trasp) = 6) then 'X6'
	 when (sum(sdo.mto_fin_ven_trasp) > 6) then 'X7'
     when (sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 0) and (sum(sdo.mto_fin_ven_trasp) = 0) then 'D0'
     when sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 1 then 'T1' 
     when sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 2 then 'T2' 
     when sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) >= 3 then 'T3'
	 else 'Y8' end NumTrans,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  <  0 THEN 1 else 0 end) as E_0,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  = 0 THEN 1 else 0 end) as E0,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 0 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <= 25 THEN 1 else 0 end) as E25,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 25 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=50 THEN 1 else 0 end) as E50,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 50 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=75 THEN 1 else 0 end) as E75,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 75 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=100 THEN 1 else 0 end) as E100,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 100 THEN 1 else 0 end) as E_100,
	sum(sdo.sdo_no_exig) sdo_intereses, 
	sum(nvl(monto_pos,0)) monto_compra , sum(nvl(monto_atm,0) + nvl(monto_vtn,0) ) monto_disp 
	from bdicred:sd_indicador_cred_hist ind, bdicred:"informix".sd_maesdoshist  sdo
	where ind.fecha = sdo.fecha
	and ind.empresa = sdo.empresa
	and ind.num_credito = sdo.Num_credito
	and ind.fecha between  dFechatrim and dFecha --mdy('01','01','2013') 
  --and ind.fecha <= mdy('08','31','2013')
	and day(ind.fecha) = 20 
	group by 1,2; --,3,4,5;
	update statistics medium for table creditostransaccion;

    DELETE FROM creditostransaccion WHERE num_credito in (select num_credito from sd_maecred where campo_trab3 = 'BAJA');
	
	----Reporte Trimestral Primer Trimestre
	SELECT COUNT(tabid)INTO sPaso2 FROM systables WHERE tabname= 'segmento_trim';
    IF NVL(sPaso2,0) > 0 THEN
        DROP TABLE segmento_trim;
    END IF;
	
	CREATE TABLE segmento_trim(
	segmento char(12), 
	totaltrimestre integer);
	
	create index ix2 on segmento_trim (segmento);
	update statistics medium for table segmento_trim;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '20-Inserta en segmento trim -Trim', '02')
    Returning cCod_RetIB;
	INSERT INTO segmento_trim
	select --s1.num_credito,
	       case when s3.seg_e_0 =  1  then '-P000-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)
	            when s3.seg_e0 =  1  then 'P000-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)
				when s3.seg_e25 =  1  then 'P025-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)
				when s3.seg_e50 =  1  then 'P050-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)
                when s3.seg_e75 =  1  then 'P075-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)
                when s3.seg_e100 =  1  then 'P100-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)
				when s3.seg_e_100 =  1  then '+P100-'|| trim(s1.num_trans) || trim(s2.num_trans)||trim(s3.num_trans)				
	       end , 
	       count(s1.num_credito)
	  from creditostransaccion s1, creditostransaccion s2, creditostransaccion s3 
	  where s1.num_credito = s2.num_credito
       and s1.num_credito = s3.num_credito
	   and s1.fecha = dFecha3
	   and s2.Fecha = dFecha2
	   and s3.Fecha = dFecha
     group by  1;
	update statistics medium for table segmento_trim;
	/*
	FOREACH 
	select segmento, totaltrimestre into vsegmentos,vtotaltrimestre from segmento_trim
	
		IF 	MONTH(dFecha) = '03' THEN
			INSERT INTO "informix".sd_segmentos_trimestre(empresa,anio,segmento,num_ctas_primer_trim,num_ctas_segundo_trim,num_ctas_tercer_trim,num_ctas_cuarto_trim)
			VALUES ('001',canio,vsegmentos,vtotaltrimestre,'','','');
		
			LET ntrimestre = 'Primer';
		
		ELIF MONTH(dFecha) = '06' THEN
		
			IF NOT EXISTS( select empresa,anio,segmento from bdicred:sd_segmentos_trimestre where anio = canio ) THEN
		
			INSERT INTO "informix".sd_segmentos_trimestre(empresa,anio,segmento,num_ctas_primer_trim,num_ctas_segundo_trim,num_ctas_tercer_trim,num_ctas_cuarto_trim)
			VALUES ('001',canio,vsegmentos,'',vtotaltrimestre,'','');

			ELSE 
			
			UPDATE "informix".sd_segmentos_trimestre set num_ctas_segundo_trim = vtotaltrimestre 
			WHERE empresa = '001' and anio = canio ;
			
			END IF;
		
			LET ntrimestre = 'Segundo';
		
		ELIF MONTH(dFecha) = '09' THEN
		
			IF NOT EXISTS( select empresa,anio,segmento from bdicred:sd_segmentos_trimestre where anio = canio ) THEN
		
			INSERT INTO "informix".sd_segmentos_trimestre(empresa,anio,segmento,num_ctas_primer_trim,num_ctas_segundo_trim,num_ctas_tercer_trim,num_ctas_cuarto_trim)
			VALUES ('001',canio,vsegmentos,'','',vtotaltrimestre,'');

			ELSE 
			
			UPDATE "informix".sd_segmentos_trimestre set num_ctas_tercer_trim = vtotaltrimestre 
			WHERE empresa = '001' and anio = canio ;
			
			END IF;
		
			LET ntrimestre = 'Tercer';
		
		ELIF MONTH(dFecha) = '12' THEN
		
		
			IF NOT EXISTS( select empresa,anio,segmento from bdicred:sd_segmentos_trimestre where anio = canio ) THEN
		
			INSERT INTO "informix".sd_segmentos_trimestre(empresa,anio,segmento,num_ctas_primer_trim,num_ctas_segundo_trim,num_ctas_tercer_trim,num_ctas_cuarto_trim)
			VALUES ('001',canio,vsegmentos,'','','',vtotaltrimestre);

			ELSE 
			
			UPDATE "informix".sd_segmentos_trimestre set num_ctas_cuarto_trim = vtotaltrimestre 
			WHERE empresa = '001' and anio = canio ;
			
			END IF;
		
		LET ntrimestre = 'Cuarto';
		
		END IF;
	END FOREACH;
*/
	--Reporte trimestral (3,6,9,12)
   CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '20-Inicia descarga-Trim', '02')
    Returning cCod_RetIB;

	LET cnomarchivo1 = 'Segmentatrimestre'||'.unl';
	LET cnomarchivo =  'rep_segmentos_trimestral'||to_char( dFechaHoy,'20%m%Y')||'.txt';
	--Encabezado
	let cSql='';
	let csql = 'echo "Segmento|'||TRIM(ntrimestre)||' trimestre'||
			'" >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || '''|'''||'';
	LET cSQL2 = ' select segmento,totaltrimestre from segmento_trim order by segmento,totaltrimestre';
	LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;
	LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
	System cSQL;
	LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
	System cSQL;
	LET cSql = cSql; 
	LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
	SYSTEM cSql;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
	SYSTEM cSQL;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	
	--Reporte Mensual (3,6,9,12)
	select sum(nvl(sdo_intereses,0))		
	into totalint
	from creditostransaccion
	where fecha = dFecha;
		
	
	LET cnomarchivo1 = 'SegmentaMes'||'.unl';
	LET cnomarchivo =  'rep_segmentos_mensual'||to_char( dFechaHoy,'20%m%Y')||'.txt';
	--Encabezado
	let cSql='';
	let csql = 'echo "Mes|Segmento|-0%|0%|25%|50%|75%|100%|+100%|Intereses|Porcentaje|Compras|' ||
			'Disposiciones'||
			'" >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || '''|'''||'';
	LET cSQL2 = ' select fecha, num_trans, sum(seg_e_0), sum(seg_e0), sum(seg_e25) , sum(seg_e50), sum(seg_e75), sum(seg_e100),sum(seg_e_100), sum(sdo_intereses), ' 
				||'round((sum(sdo_intereses)/'|| NVL(totalint,0) ||')*100,0),sum(monto_compra), sum(monto_disp) from creditostransaccion '
				||'where fecha = mdy( ' || (month(dFecha) || ',' || day(dFecha) || ',' || year(dFecha)) || ')' 
				||'group by  1,2 order by fecha,num_trans';
				--||'where fecha = '||(dFecha)||' group by  1,2 order by fecha';
	LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;
	LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
	System cSQL;
	LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
	System cSQL;
	LET cSql = cSql; 
	LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
	SYSTEM cSql;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
	SYSTEM cSQL;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	DROP TABLE creditostransaccion;
	DROP TABLE segmento_trim;
	
	ELSE 
    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '20-Inicia consulta Principal-Mensual', '02')
    Returning cCod_RetIB;
	--Reporte Mensual 
	INSERT INTO bdicred:creditostransaccion
	select  ind.fecha, ind.num_credito,  	
    case   
     when (sum(sdo.mto_fin_ven_trasp) = 1) then 'X1'
     when (sum(sdo.mto_fin_ven_trasp) = 2) then 'X2'
     when (sum(sdo.mto_fin_ven_trasp) = 3) then 'X3'
     when (sum(sdo.mto_fin_ven_trasp) = 4) then 'X4'
     when (sum(sdo.mto_fin_ven_trasp) = 5) then 'X5'
     when (sum(sdo.mto_fin_ven_trasp) = 6) then 'X6'
	 when (sum(sdo.mto_fin_ven_trasp) > 6) then 'X7'
     when (sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 0) and (sum(sdo.mto_fin_ven_trasp) = 0) then 'D0'
     when sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 1 then 'T1' 
     when sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 2 then 'T2' 
     when sum(nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) >= 3 then 'T3'
	 else 'Y8' end NumTrans,  
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  <  0 THEN 1 else 0 end) as E_0,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  = 0 THEN 1 else 0 end) as E0,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 0 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <= 25 THEN 1 else 0 end) as E25,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 25 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=50 THEN 1 else 0 end) as E50,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 50 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=75 THEN 1 else 0 end) as E75,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 75 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=100 THEN 1 else 0 end) as E100,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 100 THEN 1 else 0 end) as E_100,
	sum(sdo.sdo_no_exig) sdo_intereses, 
	sum(nvl(monto_pos,0)) monto_compra , sum(nvl(monto_atm,0) + nvl(monto_vtn,0) ) monto_disp 
	from bdicred:sd_indicador_cred_hist ind, bdicred:"informix".sd_maesdoshist sdo ---sdo
	where ind.fecha = sdo.fecha
	and ind.empresa = sdo.empresa
	and ind.num_credito = sdo.num_credito
	and ind.fecha = dFecha --mdy('02','20','2014') --
	and day(ind.fecha) = 20
	group by 1,2; --,3,4,5;
	update statistics medium for table creditostransaccion;
	
	DELETE FROM creditostransaccion WHERE num_credito in (select num_credito from sd_maecred where campo_trab3 = 'BAJA');
	
	select sum(sdo_intereses)		
	into totalint
	from creditostransaccion
	where fecha = dFecha;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '20-Inicia descarga-Mensual', '02')
    Returning cCod_RetIB;

	LET cnomarchivo1 =  'SegmentaMes'||'.unl';
	LET cnomarchivo =  'rep_segmentos_mensual'||to_char( dFechaHoy,'20%m%Y')||'.txt';
	--Encabezado
	let cSql='';
	let csql = 'echo "Mes|Segmento|-0%|0%|25%|50%|75%|100%|+100%|Intereses|Porcentaje|Compras|' ||
			'Disposiciones'||
			'" >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || '''|'''||'';
	LET cSQL2 = ' select fecha, num_trans,sum(seg_e_0),sum(seg_e0),sum(seg_e25),sum(seg_e50),sum(seg_e75),sum(seg_e100),sum(seg_e_100),sum(sdo_intereses), ' 
				||'round((sum(sdo_intereses)/'|| NVL(totalint,0) ||')*100,2),sum(monto_compra), sum(monto_disp) from creditostransaccion '
				||'group by  1,2 order by fecha,num_trans';
	LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;
	LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
	System cSQL;
	LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
	System cSQL;
	LET cSql = cSql; 
	LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
	SYSTEM cSql;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
	SYSTEM cSQL;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	DROP TABLE creditostransaccion;
END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret;

END
END PROCEDURE;