CREATE PROCEDURE "informix".sp_rep_uso_linea(pEmpresa CHAR(3))

RETURNING CHAR(6);

--Proceso para generar Reporte Uso de línea del portafolio(Total)
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
DEFINE dFecha     		DATE;
DEFINE sPaso				smallint;

--SET DEBUG FILE TO "/informix/sp_rep_uso_linea.out";
--TRACE ON;

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET pCod_Ret                = "000000";
LET pMensaje                = 'PROCESO EXITOSO';
LET pproceso				= '2100';
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
LET dFecha           = DATE(1);
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

	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta 
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND num_parametro = 2;
	--let cruta = '/informix/gpe/'; --pruebas
	
	-----TABLA--------------
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'temp_linea';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE temp_linea;
            END IF;
	
	CREATE TABLE temp_linea(
    status_cred char(2),
	concepto CHAR(20),
	monto_total DECIMAL(18,2),
	porcentaje DECIMAL(18,2)
	);
	
	
	SELECT cr1.status_cred,  'Linea Total' as linea_total, 
      sum(sdo1.monto_otorgado) / 1000000 as monto_total,
	  (sum(sdo1.monto_otorgado) / sum(sdo1.monto_otorgado)) * 100 as porcentaje
	FROM bdicred:"informix".sd_maesdoscont sdo1, bdicred:"informix".sd_maecredcont cr1
	WHERE sdo1.fecha = cr1.fecha
	    AND sdo1.empresa = cr1.empresa
		AND sdo1.num_credito = cr1.num_credito
		AND sdo1.fecha = dFecha--mdy('08','31','2013') 
		AND cr1.status_cred in ( 'AA','BA','BT','E1','E1','E3')
		AND cr1.campo_trab3 <> 'BAJA'
		GROUP BY cr1.status_cred
	UNION ALL
	SELECT cr2.status_cred, 'Linea Disponible' as linea_disponible,
     (sum(sdo2.monto_otorgado) - sum(sdo2.sdo_cap_insoluto)) / 1000000 as monto_total,
	round((sum(sdo2.monto_otorgado) - sum(sdo2.sdo_cap_insoluto))/ sum(sdo2.monto_otorgado) * 100) as porcentaje
	FROM bdicred:"informix".sd_maesdoscont sdo2, bdicred:"informix".sd_maecredcont cr2
	WHERE sdo2.fecha = cr2.fecha
	    and sdo2.empresa = cr2.empresa
		AND sdo2.num_credito = cr2.num_credito
		AND sdo2.fecha = dFecha--mdy('08','31','2013') 
		AND cr2.status_cred in ( 'AA','BA','BT','E1','E2','E3')
		AND cr2.campo_trab3 <> 'BAJA'
		GROUP BY cr2.status_cred
	UNION ALL
	SELECT cr3.status_cred, 'Linea Revolvente' as linea_revolvente,       
      sum(sdo3.sdo_cap_insoluto)/ 1000000 as monto_total,
	round( sum(sdo3.sdo_cap_insoluto) / sum(sdo3.monto_otorgado) * 100)as porcentaje
	FROM bdicred:"informix".sd_maesdoscont sdo3, bdicred:"informix".sd_maecredcont cr3
	WHERE sdo3.fecha = cr3.fecha
	    and sdo3.empresa = cr3.empresa
		AND sdo3.num_credito = cr3.num_credito
		AND sdo3.fecha = dFecha--mdy('08','31','2013') 
		AND cr3.status_cred in ( 'AA','BA','BT','E1','E2','E3')
		AND cr3.campo_trab3 <> 'BAJA'
		GROUP BY cr3.status_cred
		INTO TEMP tabla_linea with no log;
	
	INSERT INTO temp_linea
	SELECT * FROM tabla_linea;

  -----Creación de archivo------
    LET cnomarchivo1 =  'rep_uso_linea_'||substr(year(dFecha),3)||to_char(dFecha,'%m%d')||'.txt';
    LET cnomarchivo =  'rep_uso_linea'||substr(year(dFecha),3)||to_char( dFecha,'%m%d')||'.txt';
	--Encabezado
	let cSql='';
	let csql = 'echo "Status;Concepto;Monto Total;Porcentaje " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''';'''||'';
	LET cSQL2 = ' SELECT * FROM temp_linea';
	LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_rep_uso_linea.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;
	LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_rep_uso_linea.sql';
    System cSQL;
	LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_rep_uso_linea.sql';
    System cSQL;
	LET cSql = cSql; 
    LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_rep_uso_linea.sql';
	SYSTEM cSQL;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	DROP TABLE temp_linea;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
        Returning cCod_RetIB;

	RETURN pCod_ret;

END;
END PROCEDURE;