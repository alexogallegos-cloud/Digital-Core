CREATE PROCEDURE "informix".sp_pr_rpt_comportamiento()
returning 
		CHAR(6) as resultado,
		CHAR(100) as mensaje;

	DEFINE cMensajeRet		CHAR(100);
	DEFINE iCodRet			INTEGER;
	DEFINE SCodRet			CHAR(6);
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAnt		DATE;
	DEFINE dtFechaRep		CHAR(8);
	DEFINE cRuta			CHAR(100);
	DEFINE cNomArchRep		CHAR(50);
	DEFINE cSQL				CHAR(4000);
	DEFINE cSQLEnc			CHAR(300);
	DEFINE cSQLEncFinal		CHAR(300);

	--SET DEBUG FILE TO "/informix/marcov/sp_pr_rpt_comportamiento.out";
	--TRACE ON; 

--Inicialización de variables
	LET cMensajeRet = 'El Reporte de comportamiento de creditos de clientes prospecto se realizó correctamente';
	LET iCodRet		= 0;
	LET SCodRet		='000000';
	LET dtFechaHoy	= DATE(1);
	LET dtFechaAnt	= DATE(1);
	LET dtFechaRep	= '';
	LET cRuta		= '';
	LET cNomArchRep = '';
	LET cSQL		= '';
	LET cSQLEnc		= '';
	LET cSQLEncFinal = '';

	--BEGIN
	BEGIN
	ON EXCEPTION SET iCodRet
	IF iCodRet != 0 THEN
		LET SCodRet = iCodRet;
		LET cMensajeRet = 'Error en la ejecución del Reporte de comportamiento de creditos de clientes prospecto';
	END IF;
	RETURN SCodRet,cMensajeRet;
	END EXCEPTION;

	--Seleccionamos la ruta de donde se tomará el archivo asi como donde se guardará el reporte una vez generado  /resplogifx/archivoscartera/
	SELECT TRIM(valor_alfabetico) INTO cRuta 
	FROM bdicobranza:"informix".cb_param_campania WHERE empresa = '001' and tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS'
	and num_parametro = 2;

	--let cRuta = '/informix/marcov/';----PRUEBA

	--Seleccionamos Fecha de hoy
	SELECT NVL(fecha_hoy ,today) 
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';

	--Seleccionamos Fecha del cierre mes anterior
	LET dtFechaAnt = mdy(month(dtFechaHoy),1,year(dtFechaHoy)) - 1 units day;

	--Obtenemos Fecha para nombre de archivos
	LET dtFechaRep = lpad(day(dtFechaAnt),2,0) || lpad(month(dtFechaAnt),2,0) || year(dtFechaAnt);

	--Armar el nombre del archivo que contiene reporte Final
	LET cNomArchRep = 'cartera_activaAC_'||dtFechaRep ||'.txt';

	---Para Armar encabezado que consta de 3 partes 
	LET cSQLEnc='';
	LET cSQLEnc = 'echo "Numero_Credito'||'|'||'Producto'||'|'||'Estatus_Credito'||'|'||'Linea_Otorgada'||'|'||'Monto_Compras'||'|'||'Monto_Pagos'||'|'||'Tipo_Alta'||'|'||'" >'||TRIM(cRuta)||'queryencab1.txt';
	SYSTEM cSQLEnc; 

	/*LET cSQLEncFinal='';
	LET cSQLEncFinal= "sed 's/|$//g' " ||TRIM(cRuta)||"queryencab1.txt "||" >> "||TRIM(cRuta)||"queryencab2.txt;"
	||" sed 's/|$//g' "||TRIM(cRuta)||"queryencab2.txt"||" >> "||TRIM(cRuta)||"queryencab1.txt";
	SYSTEM cSQLEncFinal;*/

	--Obtener y guardar los creditos de cliente - prospectos
	Let  cSQL = 'echo "set isolation to dirty read;'
		||' select b.num_credito,b.num_producto,b.status_cred,nvl(c.monto_otorgado,0) monto_otorgado,'
		||' nvl(d.monto_pos,0) monto_pos,nvl(d.monto_pagos,0) monto_pagos, a.tipo_alta'
		||' from bdiprospectos:pr_cliente a, bdicred:sd_maecred b, bdicred:sd_maesdos c, bdicred:sd_indicador_cred_hist d'
		||' where a.numcte = b.numcte and b.num_credito = c.num_credito and b.num_credito = d.num_credito'
		||' and d.fecha = '||'''"'''||dtFechaAnt||'''"'''
		||' union all'
		||' select b.num_credito,b.num_producto,b.status_cred,nvl(c.monto_otorgado,0) monto_otorgado,'
		||' 0 monto_pos,sum(nvl(d.monto,0)) monto_pagos, a.tipo_alta'
		||' from bdiprospectos:pr_cliente a, bdicred:sd_maecredcrd b, bdicred:sd_maesdoscrd c, bdicred:sd_movhiscrd d'
		||' where a.numcte = b.numcte and b.num_credito = c.num_credito and b.num_credito = d.num_credito'
		||' and b.num_producto = d.num_producto and d.codigo_ref = 1'
		||' and d.codigo_fun in (''020'',''021'',''022'',''023'',''024'',''025'',''027'',''028'')'
		||' and d.fecha_mov >= mdy(month('||'''"'''|| dtFechaAnt ||'''"'''||'),1,year('||'''"'''|| dtFechaAnt ||'''"'''||')) and d.fecha_mov <='||'''"'''||dtFechaAnt||'''"'''
		||' group by b.num_credito,b.num_producto,b.status_cred,c.monto_otorgado,a.tipo_alta'
		||' into temp infoprosp with no log;'

		--Generando Reporte Comportamiento
		||' unload to ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'queryinformacion.txt' || ' DELIMITER ' || '''|'''
		||' select num_credito, num_producto, status_cred, nvl(monto_otorgado,0), nvl(monto_pos,0), nvl(monto_pagos,0),'
		||' (case when tipo_alta = 1 then ''Sucursal'' when tipo_alta = 2 then ''Calle'' end) Tipo_Alta'
		||' from infoprosp'
		||' order by num_credito;'
		||'" > '||TRIM(cRuta) ||'query.sql';

	System cSQL;
	LET cSQL = "dbaccess bdicred "||TRIM(cRuta) ||"query.sql";
	System cSQL;

	--Se une el ancabezado con la información para conformar el reporte
	let cSQL = '';
	LET cSQL= "sed 's/|$//g' " ||TRIM(cRuta)||"queryinformacion.txt"||" >> "||TRIM(cRuta)||"queryencab1.txt;"
	||" sed 's/|$//g' "||TRIM(cRuta)||"queryencab1.txt"||" >> "||TRIM(cRuta)||SUBSTR(cNomArchRep,1,LENGTH(cNomArchRep));
	SYSTEM cSQL;

	--borrar archivo .sql y .txt que ya no se utilizarán
	let cSQL = '';
	let cSQL = "rm " || SUBSTR(cRuta,1,LENGTH(cRuta)) || "query.sql "|| SUBSTR(cRuta,1,LENGTH(cRuta)) || "queryencab1.txt " 
					 || SUBSTR(cRuta,1,LENGTH(cRuta)) ||"queryinformacion.txt";
	System cSQL;
	
	 RETURN SCodRet,cMensajeRet;
	 END;

END PROCEDURE 
