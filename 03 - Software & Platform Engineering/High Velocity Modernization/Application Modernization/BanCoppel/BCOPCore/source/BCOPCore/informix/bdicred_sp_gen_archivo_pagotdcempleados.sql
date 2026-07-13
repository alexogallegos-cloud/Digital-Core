CREATE PROCEDURE "informix".sp_gen_archivo_pagotdcempleados(pEmpresa CHAR(3))
	
RETURNING CHAR(6) AS CodigoRetorno,
		CHAR(80) AS Mensaje;

--Elaborado por: Guadalupe Espinoza Valenzuela. 20140113		
--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
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
DEFINE cSucursal			CHAR(4);
DEFINE cSQL					CHAR(8204);
DEFINE cSQL1				CHAR(6204);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFecha				DATE;
DEFINE sPaso				smallint;

--SET DEBUG FILE TO "/informix/gpe/sp_gen_archivo_pagotdcempleados.out";
--TRACE ON;

--Inicializació® ¤e variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET pMensaje				= 'PROCESO EXITOSO';
LET pproceso				= '2120';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSucursal				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFecha					= DATE(1);
LET sPaso					=0;

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
		RETURN pCod_ret,pMensaje;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
		
	SELECT fecha_hoy
	INTO dFecha
	FROM bdicred:sd_fechas;
	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta 
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' AND tipo_campania = 50 
	AND num_parametro = 2;
	--let cruta = '/informix/gpe/'; --pruebas
	
	-----Creació® ¤e archivo------
    LET cnomarchivo1 =  'seguimiento_pagos_tdc'||substr(year(dFecha),3)||to_char(dFecha,'%m%d')||'.txt';
    LET cnomarchivo =  'seguimiento_pagos_tdc_'||substr(year(dFecha),3)||to_char( dFecha,'%m%d')||'.txt';
	--se ejecuta para ponerle el encabezado
	let cSql='';
	let csql = 'echo "NÃºmero de cré¤©to;Estatus del cré¤©to;Monto otorgado;Capital vigente;Capital transitorio;Saldo vencido;Capital vencido no exigible;Meses vencidos;" >' ||TRIM(cruta)|| cnomarchivo;
	system csql;

	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''';'''||'';
	LET cSQL2 = ' select a.num_credito,a.status_cred,b.monto_otorgado,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,'||
				'b.cap_tras_no_venci, '||
				'(select count(*) from bdicred:sd_amortiza_credito where num_credito = a.num_credito and empresa = a.empresa and capital_status in('''||2||''','''||7||''','''||6||''')) '||
				'from bdicred:sd_maecred a '||
				'join bdicred:sd_maesdos b on (b.empresa = a.empresa and b.num_credito = a.num_credito) '||
				'where a.num_credito in(select e.num_credito from bdicred:sd_tdc_empleados e where e.empresa = a.empresa) '||
				'union all '||
				'select c.num_credito,c.status_cred,d.monto_otorgado,d.sdo_capital,d.monto_vencido,d.mto_venc_trasp, '||
				'd.cap_tras_no_venci, '||
				'(select count(*) from bdicred:sd_amortiza_creditocrd where num_credito = c.num_credito and empresa = c.empresa and capital_status in('''||2||''','''||7||''','''||6||''')) '||
				'from bdicred:sd_maecredcrd c '||
				'join bdicred:sd_maesdoscrd d on (d.empresa = c.empresa and d.num_credito = c.num_credito) '||
				'where c.num_credito in(select e.num_credito from bdicred:sd_tdc_empleados e where e.empresa = c.empresa);';

	LET cSQL3 = '">'||TRIM(cRuta)||'ejec_seg_tdc_pagos.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'ejec_seg_tdc_pagos.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'ejec_seg_tdc_pagos.sql';
    System cSQL;

    LET cSql = cSql; 
    LET cSql = "sed 's/;$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejec_seg_tdc_pagos.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END;
END PROCEDURE;