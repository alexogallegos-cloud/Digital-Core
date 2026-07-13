CREATE PROCEDURE "informix".sp_rep_porc_uso(pEmpresa CHAR(3))

RETURNING CHAR(6);

--Proceso para generar Reporte porcentaje de Uso 
--Creado por:Guadalupe Espinoza 08/10/2013

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE pempresa				CHAR(3);
DEFINE pproceso				CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cnumcred             CHAR(20);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFecha    		DATE;
DEFINE sPaso				smallint;

--SET DEBUG FILE TO "/informix/sp_rep_porc_uso.out";
--TRACE ON;

--Inicializació® ¤e variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET pCod_Ret                = "000000";
LET pMensaje                = 'PROCESO EXITOSO';
LET pproceso				= '2110';
LET pempresa				= '001';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnumcte                 = "";
LET cnumcred                = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cCod_RetIB              = "000000";
LET dFecha           	= DATE(1);
LET sPaso					=0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET pCod_ret = sql_err;
            LET pMensaje = error_info;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
                Returning cCod_RetIB;
        RETURN pCod_ret;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
            Returning cCod_RetIB;

	SELECT pri_dia_mes - 1 into dFecha
	FROM bdicred:sd_fechas;
	--let dFecha =  mdy('05','31','2013');
	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta 
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND num_parametro = 2;
	--let cruta = '/informix/gpe/'; --pruebas
	
	-----TABLA--------------
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'temp_porc_uso';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE temp_porc_uso;
            END IF;
	
	CREATE TABLE temp_porc_uso(
    status_credito char(2),
	por_de_linea CHAR(5),
	cuentas DECIMAL(18,2),
	porcentaje DECIMAL(18,2)
	);
	
	
	SELECT cr.status_cred, count(*) as vtotal,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  <  0 THEN 1 else 0 end) as vpor_linea0,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  = 0 THEN 1 else 0 end) as vpor_linea1,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 0 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <= 25 THEN 1 else 0 end) as vpor_linea2,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 25 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=50 THEN 1 else 0 end) as vpor_linea3,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 50 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=75 THEN 1 else 0 end) as vpor_linea4,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 75 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=100 THEN 1 else 0 end) as vpor_linea5,
	SUM(CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 100 THEN 1 else 0 end) as vpor_linea6
    FROM bdicred:"informix".sd_maesdoscont sdo, bdicred:"informix".sd_maecredcont cr
	WHERE 
	     sdo.fecha = cr.fecha
	    AND sdo.empresa = cr.empresa
		AND sdo.num_credito = cr.num_credito
		AND cr.status_cred in ( 'AA','BA','BT','E1','E2','E3')
		AND cr.campo_trab3 <> 'BAJA'
		AND sdo.fecha = dFecha --mdy('08','31','2013') 
    group by cr.status_cred    
	INTO TEMP uso_linea WITH NO LOG;

	
	SELECT status_cred, '-0' as por_de_linea,vpor_linea0 as cuentas ,round((vpor_linea0 / vtotal ) * 100,0) as porcentaje
	FROM uso_linea
	UNION ALL
	SELECT status_cred,'0' as por_de_linea,vpor_linea1 as cuentas ,round((vpor_linea1 / vtotal ) * 100,0) as porcentaje
	FROM uso_linea
	UNION ALL
	SELECT status_cred,'25' as por_de_linea,vpor_linea2 as cuentas,round((vpor_linea2 / vtotal) * 100,0)as porcentaje
	FROM uso_linea
	UNION ALL
	SELECT status_cred,'50' as por_de_linea,vpor_linea3 as cuentas,round((vpor_linea3 / vtotal) * 100,0) as porcentaje
	FROM uso_linea
	UNION ALL
	SELECT status_cred,'75' as por_de_linea,vpor_linea4 as cuentas,round((vpor_linea4 / vtotal) * 100,0) as porcentaje
	FROM uso_linea
	UNION ALL
	SELECT status_cred,'100' as por_de_linea,vpor_linea5 as cuentas,round((vpor_linea5 / vtotal) * 100,0) as porcentaje
	FROM uso_linea
	UNION ALL
	SELECT status_cred,'+100' as por_de_linea,vpor_linea6 as cuentas,round((vpor_linea6 / vtotal) * 100,0) as porcentaje
	FROM uso_linea
	INTO TEMP uso_linea2 WITH NO LOG;
	
	INSERT INTO temp_porc_uso
	SELECT status_cred,  por_de_linea, cuentas, porcentaje FROM uso_linea2;
	
  
  -----Creació® ¤e archivo------

		--Validar que existe el archivo
    LET cnomarchivo1 =  'rep_porcentaje_uso_'||substr(year(dFecha),3)||to_char(dFecha,'%m%d')||'.txt';
    LET cnomarchivo =  'rep_porcentaje_uso'||substr(year(dFecha),3)||to_char( dFecha,'%m%d')||'.txt';
	--se ejecuta para ponerle el encabezado
	let cSql='';
	let csql = 'echo "Status;% de Ló¹¡;Cuentas;% " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;

	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''';'''||'';
	LET cSQL2 = ' SELECT * FROM temp_porc_uso;';
	LET cSQL3 = '">'||TRIM(cRuta)||'ejec_rep_porcentaje_uso.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'ejec_rep_porcentaje_uso.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'ejec_rep_porcentaje_uso.sql';
    System cSQL;

    LET cSql = cSql; 
    LET cSql = "sed 's/;$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejec_rep_porcentaje_uso.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	DROP TABLE temp_porc_uso;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
        Returning cCod_RetIB;

	RETURN pCod_ret;

END;
END PROCEDURE;