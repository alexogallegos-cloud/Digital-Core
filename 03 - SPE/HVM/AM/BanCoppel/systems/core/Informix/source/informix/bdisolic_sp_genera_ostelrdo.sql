CREATE PROCEDURE "informix".sp_genera_ostelrdo()
RETURNING CHAR(5);
---Declaracion de variables
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cRuta VARCHAR(100);
DEFINE cNomArchivo VARCHAR(50);
DEFINE sCadSql LVARCHAR(500);
DEFINE cSQL                 CHAR(2204);
DEFINE cMensaje				  CHAR(80);
DEFINE vproceso				  CHAR (4);
define vfecha_hoy	date;
---Inicializacion de variables
LET cCodRet = '00001';
LET iSqlErr = 0;
LET cRuta = '';
LET cNomArchivo = '';
LET sCadSql = '';
LET cMensaje    = 'PROCESO EXITOSO';
LET vproceso	='2068';
let vfecha_hoy = date(1);
let cSQL = '';

BEGIN

	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02');
		RETURN cCodRet;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/sp_genera_ostelrdo.out";
	--TRACE ON;
	--Se obtiene la ruta y el nombre del archivo
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01');
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_hoy INTO vfecha_hoy FROM bdicred:sd_fechas WHERE empresa= '001';
	SELECT trim(valor) INTO cRuta FROM bdisolic:"informix".ss_param WHERE secuencia = 22;
	SELECT trim(valor) into cNomArchivo  FROM bdisolic:"informix".ss_param WHERE secuencia = 23;
	LET cNomArchivo  = cNomArchivo|| LPAD(TRIM(DAY(vfecha_hoy)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(vfecha_hoy)::CHAR(2)),2,'0') || YEAR(vfecha_hoy)||'.txt' ;
--let cRuta ='/informix/Elizabeth/';--pruebas
	--Se valida los datos obtenidos
	IF NVL(cRuta,'') <> '' AND  NVL(cNomArchivo,'') <> '' THEN
	--Se elimina tabla temporal
		IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tme_ss_ostel_resultado') THEN 
			DROP TABLE tme_ss_ostel_resultado; 
		END IF;
		--Se crea tabla temporal
		CREATE TABLE tme_ss_ostel_resultado 
		(
			secuencia INTEGER NOT NULL,
			tipociudad INTEGER,
			tiporeferenciasolicitante INTEGER,
			resultadotelefonocasa CHAR(2),
			causatelefonocasa CHAR(1),
			resultadotelefonoref CHAR(2),
			causatelefonoref CHAR(1),
			resultadotelefonotrab CHAR(2),
			causatelefonotrab CHAR(1),
			resultadotelefonocelular CHAR(2),
			causatelefonocelular CHAR(1),
			resultadoprc_1 CHAR(2),
			resultadoprct_2 CHAR(2),
			resultadoprrt_3 CHAR(2),
			deccoppel CHAR(2),
			decbancoppelctenuevo CHAR(2),
			estado SMALLINT,
			fechahorainicio DATETIME YEAR TO SECOND,
			fechahorafin DATETIME YEAR TO SECOND,
			ejecutivo CHAR(8)
		);
		--Guarda el query de load en archivo *.SQL
		LET sCadSql = 'echo "LOAD FROM ''' || TRIM(cRuta) || TRIM(cNomArchivo) || ''' DELIMITER ' || '''|''' || ' INSERT INTO tme_ss_ostel_resultado" > '|| TRIM(cRuta) || 'EjecutaScripts_sp_genera_ostelrdo.sql';
		SYSTEM sCadSql;
		--Ejecuta el archivo *.SQL
		LET sCadSql = 'dbaccess bdisolic ' || TRIM(cRuta) || 'EjecutaScripts_sp_genera_ostelrdo.sql';
		SYSTEM sCadSql;
		--Se obtiene la informacion del archivo
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		INSERT INTO bdisolic:"informix".ss_ostel_resultado(secuencia,tipociudad,tiporeferenciasolicitante,resultadotelefonocasa,
		causatelefonocasa,resultadotelefonoref,causatelefonoref,resultadotelefonotrab,causatelefonotrab,resultadotelefonocelular,
		causatelefonocelular,resultadoprc_1,resultadoprct_2,resultadoprrt_3,deccoppel,decbancoppelctenuevo,estado,fechahorainicio,
		fechahorafin,atendido_15min,ejecutivo)
		SELECT secuencia,tipociudad,tiporeferenciasolicitante,resultadotelefonocasa,causatelefonocasa,resultadotelefonoref,
		causatelefonoref,resultadotelefonotrab,causatelefonotrab,resultadotelefonocelular,causatelefonocelular,resultadoprc_1,
		resultadoprct_2,resultadoprrt_3,deccoppel,decbancoppelctenuevo,estado,fechahorainicio,fechahorafin,
		CASE WHEN (fechahorafin - fechahorainicio) < '0 00:15:00' THEN 'S' 
		WHEN (fechahorafin - fechahorainicio) >= '0 00:15:00' THEN 'N' END,ejecutivo FROM tme_ss_ostel_resultado;
		--Se elimina tabla temporal
		DROP TABLE tme_ss_ostel_resultado;
		LET cCodRet = '00000';
	END IF;
	
	let cSql = '';
         LET cSql = "rm /home/syscobra/cat/EjecutaScripts_sp_genera_ostelrdo.sql";
	   --LET cSql = "rm /informix/Elizabeth/EjecutaScripts_sp_genera_ostelrdo.sql";--pruebas
        SYSTEM cSql;
	
	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
	RETURN cCodRet;
END;
END PROCEDURE
