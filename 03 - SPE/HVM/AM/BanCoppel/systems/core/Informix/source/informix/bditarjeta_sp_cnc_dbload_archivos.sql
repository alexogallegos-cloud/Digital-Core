CREATE PROCEDURE "informix".sp_cnc_dbload_archivos
(
	psRuta_Repositorio	VARCHAR (90),
	psNomArchivo		VARCHAR (30),
	psArchivoOrigen		VARCHAR(3), 
	piTipoLayOut		INTEGER,
	psSistema			VARCHAR(1)
)

RETURNING VARCHAR (5) AS rCodigoRetorno, VARCHAR(250) AS rMensajeRespuesta;

	DEFINE SQLERR					INTEGER;
	DEFINE ISAM_ERR					INTEGER;
	DEFINE ERROR_INFO				VARCHAR(250);
	DEFINE vCODIGO_RETORNO			VARCHAR(5);
	DEFINE vMENSAJE_RETORNO			VARCHAR(250);
	DEFINE CONTADOR_TRANSACCIONES	SMALLINT;
	DEFINE RUTA_ORIGEN				VARCHAR(100);
	DEFINE vExecuteSQL				LVARCHAR(1000);
	DEFINE vNombreTablaCarga		VARCHAR(90);
	DEFINE vCaracterDelimitador		CHAR(1);
	DEFINE vNomCarga_DBLOAD			VARCHAR(20);
	DEFINE vNomError_DBLOAD			VARCHAR(20);
	DEFINE vNomError_Ejecucion		VARCHAR(16);
	DEFINE vNombreArchivo			VARCHAR(23);
	DEFINE vNombreCompScript		VARCHAR(113);	DEFINE vNombreCompTXT			VARCHAR(113);
	DEFINE vNombreCompLog			VARCHAR(113);
	DEFINE vNombreEjecucionLog		VARCHAR(113);
	DEFINE vNombreArchivoLog		VARCHAR(113);

	LET SQLERR 						= '';
	LET ISAM_ERR 					= '';
	LET ERROR_INFO 					= '';
	LET vCODIGO_RETORNO 			= '';
	LET vMENSAJE_RETORNO 			= '';
	LET CONTADOR_TRANSACCIONES		= 1000;
	LET RUTA_ORIGEN					= '/RESPALDOSNEW/';
	LET vExecuteSQL					= '';
	LET vNombreTablaCarga			= '';
	LET vCaracterDelimitador		= '';
	LET vNomCarga_DBLOAD			= 'dbload_carga_';
	LET vNomError_DBLOAD			= 'dbload_error_';
	LET vNomError_Ejecucion		= 'error_ejecucion_';

	LET vNombreCompScript = TRIM(psRuta_Repositorio)||'/'||vNomCarga_DBLOAD||LOWER(psArchivoOrigen)||'.sql';
	LET vNombreCompTXT = TRIM(psRuta_Repositorio)||'/'||vNomCarga_DBLOAD||LOWER(psArchivoOrigen)||'.txt';
	LET vNombreCompLog = TRIM(psRuta_Repositorio)||'/'||vNomError_DBLOAD||LOWER(psArchivoOrigen)||'.log';
	LET vNombreEjecucionLog = TRIM(psRuta_Repositorio)||'/'||vNomError_Ejecucion||LOWER(psArchivoOrigen)||'.log';
	LET vNombreArchivoLog = vNomError_Ejecucion||LOWER(psArchivoOrigen)||'.log';

	LET vNombreArchivo = psNomArchivo;

	-- SET DEBUG FILE TO "/home/c90265232/prueba/CC_RQI32492/debug_sp_cnc_dbload_archivos.out";
	-- TRACE ON;

	BEGIN

		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

			--SET DEBUG FILE TO RUTA_ORIGEN||"excep_sp_cnc_dbload_archivos.err.out" WITH APPEND;
			--TRACE ON;

			IF ( SQLERR <> 0 ) THEN
				LET vMENSAJE_RETORNO = 'Archivo '||vNombreArchivo||' Proceso '||vCODIGO_RETORNO||' SQL_ERR '||SQLERR||' '||'Leer archivo '||vNombreArchivoLog||' '||current;
				LET vCODIGO_RETORNO = SQLERR;
				RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
			END IF;
			
		END EXCEPTION

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET vCaracterDelimitador = '+';
		LET vNombreTablaCarga = 'td_carga_archivo';
		LET vNomCarga_DBLOAD = 'dbload_carga_';
		LET vNomError_DBLOAD = 'dbload_error_';

		--Se repite el Layout 1 para Mastercard asn que se anade como condicion el archivo origen
		IF ( psArchivoOrigen = 'MCO' AND piTipoLayOut = 1 ) THEN
			LET vNombreTablaCarga = 'td_carga_archivo_mc';
		END IF

		IF ( piTipoLayOut = 6 ) THEN
			LET vCaracterDelimitador = '|';
		END IF

		IF ( piTipoLayOut = 8 ) THEN
		-- Agosto 2024: Se ajusta la validacion de este layout con la finaldiad de que identifique el STA06 PAGOS o DEPOSITADORES
			IF psNomArchivo LIKE "%PAG%" THEN
				LET vNombreTablaCarga = 'td_carga_archivo_atm_stat06_pagos';
			ELIF psNomArchivo LIKE "%DEP%" THEN
				LET vNombreTablaCarga = 'td_carga_archivo_dep_atm';
			END IF
		END IF

		IF ( piTipoLayOut = 9 ) THEN
			LET vNombreTablaCarga = 'td_carga_archivo_colaborapp';
		END IF

		LET vCODIGO_RETORNO = '00001';
		LET vMENSAJE_RETORNO = 'LIMPIAR TABLA DE TRABAJO.';

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo truncate table bditarjeta:' || vNombreTablaCarga || ' drop storage > ' || vNombreCompScript;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 777 ' || vNombreCompScript;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess bditarjeta '||vNombreCompScript;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -f "||vNombreCompScript;
		SYSTEM vExecuteSQL;

		LET vCODIGO_RETORNO = '00002';
		LET vMENSAJE_RETORNO = 'GENERAR COMANDO DE CARGA.';

		-- Octubre 2024: Se agrega la validacion a partir de la linea de comandos con el fin de identificar que no exita algun PIPE | en el archivo a procesar
		-- en caso de encontrar coincidencia se sustituye por un espacio en blanco
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = " tr '|' ' ' < " || TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo) || " > " || TRIM(psRuta_Repositorio) || '/' || "archivotemp.txt && mv " || TRIM(psRuta_Repositorio) || '/' || "archivotemp.txt " || TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo) || " && chmod 777 " || TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo);
		SYSTEM vExecuteSQL; 

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| "' delimiter '"||vCaracterDelimitador||"' "|| '1'||
						"; INSERT INTO "||vNombreTablaCarga|| ";"||'"'||' > '||vNombreCompTXT;
		SYSTEM vExecuteSQL;

		LET vCODIGO_RETORNO = '00003';
		LET vMENSAJE_RETORNO = 'EJECUTAR CARGA DE ARCHIVO.';

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d bditarjeta -c "||vNombreCompTXT||" -l "||vNombreCompLog||" -n "||CONTADOR_TRANSACCIONES||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL;

		LET vCODIGO_RETORNO = '00004';
		LET vMENSAJE_RETORNO = 'BORRAR ARCHIVOS DE DBLOAD CARGA | ERROR CARGA | DE EJECUCION';

		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||vNombreCompTXT ||' '||vNombreCompLog||' '||vNombreEjecucionLog;
		SYSTEM vExecuteSQL;

		LET vCODIGO_RETORNO = '00000';
		LET vMENSAJE_RETORNO = 'CARGA DE ARCHIVO EXITOSA.'||psNomArchivo;

		RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
	
	END

END PROCEDURE
DOCUMENT
'#1',
'Coord. Admon. Tarjetas - Gerencia I',
'Descripcion: Componente considerado para guardar la informacion de cada uno de los archivos de todas las conciliaciones automaticas',
'Usando el comando dbload y ejecutando la instruccion commit por cada 1000 afectaciones.',
'El objetivo de lo anterior es disminuir los bloqueos hacia las tablas productivas',
'Fecha: 05 de agosto del 2021',
'Base de datos: bditarjeta',
'#2',
'Coord. Admon. Tarjetas - Gerencia I',
'Descripcion: Se hacen ajustes con la finalidad de que el proceso pueda ser empleado por el flujo de STAT06 PAGOS y STAT06 DEPOSITADORES',
'con el objetivo de reutilizar codigo',
'Fecha: 27 de agosto de 2024',
'Base de datos: bditarjeta',
'#3',
'Coord. Admon. Tarjetas - Gerencia I',
'Descripcion: Se agrega la validacion en los archivos a procesar para corroborar que no tengan PIPE, en caso de que se encuentre se sustituye',
'por un espacio en blanco ',
'Fecha: 22 de octubre de 2024',
'Base de datos: bditarjeta';

CREATE  PROCEDURE "informix".sp_txns_atms_exitosas()
RETURNING       char (5) AS COD_RET, char(150) AS MENSAJE;

--- Variables de control de errores ---

DEFINE  vContadorDelete	INTEGER;
DEFINE  vContadorInsert	INTEGER;
DEFINE  iSqlErr			INTEGER;
DEFINE  iIsamErr		INTEGER;
DEFINE  vErrorInfo		VARCHAR(80);
DEFINE  CVarDataErr		CHAR(150);
DEFINE  CCodret			CHAR(5);
DEFINE  CMENSAJE		CHAR(150);
DEFINE  vpaso			INTEGER;

--- Variables ---1

DEFINE Vsumamis decimal(19,4);
DEFINE vsumasus decimal(19,4);
DEFINE vsumatotal decimal(19,4);

--- Variables de totales ---

DEFINE vmonto_retiro_bd decimal(19,4);
DEFINE vmonto_retiro_bc decimal(19,4);
DEFINE vmonto_retiro_od decimal(19,4);
DEFINE vmonto_retiro_oc decimal(19,4);
DEFINE vmaest decimal(19,4);

--- Variables de fechas ---

DEFINE vfecharep DATE;
DEFINE vfecha_hoy DATE;
DEFINE vano     varchar (4);
DEFINE vmesdia     varchar (4);
DEFINE vano2 varchar (4);
DEFINE vmes     varchar (2);
DEFINE vdia varchar (2);
DEFINE vdma varchar (8);
DEFINE vdmar varchar (10);
DEFINE vdmar2 varchar (8);
DEFINE vfechadelete DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_inimov DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_finmov DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_inistat        DATETIME YEAR TO FRACTION(5);
DEFINE vfecharep_finstat        DATETIME YEAR TO FRACTION(5);
DEFINE vcontadortxnexi INTEGER;
DEFINE vcontadorstat INTEGER;
DEFINE vcontadortdmovcon INTEGER;
DEFINE vfecharephoy	varchar (10); --> Variable para fecha en formato DD/MM/AAAA
DEFINE vanohoy varchar (4);
DEFINE vmeshoy varchar (2);
DEFINE vdiahoy varchar (2);

--- Variables de archivo ---

DEFINE vsFlagEnTransaccion	CHAR(5);
DEFINE vsecuencia VARCHAR(7);
DEFINE vtarjeta VARCHAR (16);
DEFINE vNombreArchivo	VARCHAR (50);
DEFINE vsql	CHAR (2404);

---Variables Foreach

DEFINE viContadorRegistros  INTEGER;
DEFINE vsFlagEnTransaccionFor  CHAR(1);
DEFINE vconsecutivo INTEGER;
DEFINE vfechaproceso DATETIME YEAR TO FRACTION(5);
DEFINE vfechahoramov DATETIME YEAR TO FRACTION(5);
DEFINE vsecuenciaFor CHAR(7);
DEFINE vnumtarjetamovi CHAR(16);
DEFINE vnumtarjetastat06 CHAR(16);
DEFINE vbin VARCHAR(6);
DEFINE vidterminal VARCHAR(16);
DEFINE vtipotran VARCHAR(2);
DEFINE vcodtran VARCHAR(2);
DEFINE vesnacional VARCHAR(4);
DEFINE vtransaccionorigen VARCHAR(4);
DEFINE vidreceptor VARCHAR(4);
DEFINE vcodreversa VARCHAR(1);
DEFINE vmovconciliado VARCHAR(1);
DEFINE vmovreversado VARCHAR(1);
DEFINE vtrancajeropropio VARCHAR(1);
DEFINE vformato VARCHAR(4);
DEFINE varchivoorigen VARCHAR(3);
DEFINE vcreditodebito VARCHAR(1);
DEFINE vmarca VARCHAR(1);
DEFINE vmonto DECIMAL(19,4);
DEFINE vmontorealrevfzda DECIMAL(19,4);
DEFINE vmontosurcharge DECIMAL(19,4);
DEFINE vmontocomision DECIMAL(19,4);
DEFINE vinternacional char(7);

--Optimiza SFT inicio --v
DEFINE cempresa char(3);
--Optimiza SFT fin    --^

--Y_Sftk inicio--
DEFINE vcontadorcommit INTEGER;  ---Contador para los ciclos commit
DEFINE vautorizacion CHAR(6);
DEFINE vnumtarjetad CHAR(16);
DEFINE vmontocomisionup DECIMAL(19,4);
--Y_Sftk fin---

--SET DEBUG FILE TO "/informix/c94796696/sp_txns_atms_exitosas.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET CCodret = iSqlErr;
			LET CMENSAJE = vErrorInfo;
			insert into bditarjeta:"informix".td_bitacora_procesos (consecutivo,idproceso,fechahora,no_error,descripcion)
			VALUES(0,'01',current,CCodret,vErrorInfo);
		END IF;
	END EXCEPTION;

	--- Inicializando variables ---

	let vfecharep ='';
	let vfecha_hoy = '';

	let vsumamis = 0;
	let vsumasus = 0;
	let vsumatotal = 0;
	let vsFlagEnTransaccion = 'F';
	let vContadorDelete = 0;
	let vContadorInsert = 0;

	let vmonto_retiro_bd = 0;
	let vmonto_retiro_bc = 0;
	let vmonto_retiro_od = 0;
	let vmonto_retiro_oc = 0;
	let vmaest = 0;
	let vcontadortxnexi = 0;
	let vcontadorstat = 0;
	let vcontadortdmovcon = 0;

	LET vsFlagEnTransaccionFor = 'F';
	LET viContadorRegistros = 0;


	/*
	DEFINE vfechaproceso DATETIME YEAR TO FRACTION(5);
	DEFINE vfechahoramov DATETIME YEAR TO FRACTION(5); */
	LET vconsecutivo = 0;
	LET vsecuencia ='';
	LET vnumtarjetamovi='';
	LET vnumtarjetastat06= '';
	LET vbin='';
	LET vidterminal='';
	LET vtipotran='';
	LET vcodtran='';
	LET vesnacional='';
	LET vtransaccionorigen='';
	LET vidreceptor='';
	LET vcodreversa='';
	LET vmovconciliado='';
	LET vmovreversado='';
	LET vtrancajeropropio='';
	LET vformato='';
	LET varchivoorigen='';
	LET vcreditodebito='';
	LET vmarca='';
	LET vmonto=0;
	LET vmontorealrevfzda=0;
	LET vmontosurcharge=0;
	LET vmontocomision=0;
	LET vinternacional='';

	--Optimiza SFT inicio --v
	LET cempresa = '001';
	--Optimiza SFT fin    --^

	--Y_Sftk inicio--
	LET vcontadorcommit = 0;   ---Contador para los ciclos commit
	LET vautorizacion='';
	LET vnumtarjetad='';
	LET vmontocomisionup=0;
	--Y_Sftk fin---


	--- Obtiene la fecha del dia para generar el reporte ---

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;


	--Optimiza sFT inicio --v  --Accede por indice
	--SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:"informix".si_fechas;
	SELECT fecha_hoy 
	INTO vfecha_hoy 
	FROM bdinteg:"informix".si_fechas 
	WHERE empresa=cempresa;
	--Optimiza SFT fin    --^


	--let vfecha_hoy = '12/30/2023';
	let vfecha_hoy = vfecha_hoy-1;
	let vfecharep = vfecha_hoy; -->>Fecha de datos (no de la conciliacion)

	--- Fechas para el campo fechaconciliacion ---

	let vfecharep_inimov = vfecha_hoy-1;
	let vfecharep_inimov= SUBSTRING(vfecharep_inimov FROM  1 FOR 10) || ' 00:00:00';

	let vfecharep_finmov= vfecha_hoy-1;
	let vfecharep_finmov = SUBSTRING(vfecharep_finmov FROM  1 FOR 10) || ' 23:59:59';

	let vfecharep_inistat = vfecha_hoy;
	let vfecharep_inistat= SUBSTRING(vfecharep_inistat FROM  1 FOR 10) || ' 00:00:00';

	---vfecharep_inistat='2016-11-15 00:00:00'

	let vfecharep_finstat = vfecha_hoy;
	let vfecharep_finstat = SUBSTRING(vfecharep_finstat FROM  1 FOR 10) || ' 23:59:59';

	let vano = YEAR(vfecharep);
	let vmes = LPAD(MONTH(vfecharep), 2,"0");
	let vdia = LPAD(DAY (vfecharep),2,"0");
	let vdma = vdia||vmes||vano;
	let vdmar = vdia||'-'||vmes||'-'||vano;
	--let vfecharephoy = vdia||'/'||vmes||'/'||vano;
	let vano='';

	--Optimiza SFT inicio --v  --Accede por indice
	--SELECT to_char(fecha_hoy,"%y") INTO  vano FROM  bdinteg:"informix".si_fechas;
	SELECT TO_CHAR(fecha_hoy,"%y") 
	INTO  vano 
	FROM  bdinteg:"informix".si_fechas 
	WHERE empresa=cempresa;
	--Optimiza SFT fin    --^


	let vdmar2 = vdia||'/'||vmes||'/'||vano;

	let vanohoy = YEAR(vfecha_hoy-1);
	let vmeshoy = LPAD(MONTH(vfecha_hoy-1),2,"0");
	let vdiahoy = LPAD(DAY (vfecha_hoy-1),2,"0");

	let vanohoy = RIGHT(vanohoy,2);
	let vfecharephoy = vdiahoy||'/'||vmeshoy||'/'||vanohoy; --> Fecha en formato DD/MM/AAAA
	let vmesdia = vmeshoy || vdiahoy;

	--- Valida que exista informacion del dia en el STAT06 ---

	--IF (not exists(select fechaconciliacion from intercard:"informix".conciliacion_atm_stat06 where cast(fechaconciliacion as date) = vfecha_hoy)) THEN
	--IF (not exists(select fechaconciliacion from intercard:"informix".conciliacion_atm_stat06 where fecha = vfecharephoy)) THEN

	--Optimiza SFT inicio --v
	--select count(*) INTO vcontadorstat from intercard:"informix".conciliacion_atm_stat06 where fechaconciliacion between vfecharep_inistat and vfecharep_finstat and fecha = vf
	--harephoy and archivoorigen = 'IST';
	select count(*) INTO vcontadorstat 
	from intercard:"informix".conciliacion_atm_stat06
	where fechaconciliacion >= vfecharep_inistat
	and fechaconciliacion <= vfecharep_finstat and fecha = vfecharephoy and archivoorigen = 'IST';
	--Optimiza SFT fin    --^

	--IF (not exists(select count(*) from intercard:"informix".conciliacion_atm_stat06 where fechaconciliacion between vfecharep_inistat and vfecharep_finstat and fecha = vfecharephoy and archivoorigen = 'IST')) THEN
	IF (vcontadorstat = 0) THEN
			
		let cCodret = '00011';
		let CVarDataErr = 'No existe informacion del dia: '||vfecha_hoy-1||' en la tabla de STAT06';
			insert into bditarjeta:"informix".td_bitacora_procesos (consecutivo,idproceso,fechahora,no_error,descripcion)
				VALUES(0,'01',current,CCodret,CVarDataErr);

		RETURN cCodret,CVarDataErr;
	END IF;


	--- Valida que exista informacion del dia en MOVIMIENTOS CONCILIACION ---

	--select count(*) INTO vcontadortdmovcon from bditarjeta:"informix".td_movimientos_conciliacion where fechacarga between vfecharep_inistat and vfecharep_finstat and archivo_origen in ('TMC','TMD');

	--Optimiza SFT inicio --v
	--select count(*) INTO vcontadortdmovcon from bditarjeta:"informix".td_movimientos_conciliacion
	--where fechacarga between vfecharep_inistat and vfecharep_finstat and fechaconcilia between vfecharep_inistat and vfecharep_finstat and archivo_origen in ('TMC','TMD');
	select count(*) INTO vcontadortdmovcon 
	from bditarjeta:"informix".td_movimientos_conciliacion
	where fechacarga >= vfecharep_inistat
	and fechacarga <= vfecharep_finstat	and fechaconcilia >= vfecharep_inistat
	and fechaconcilia <= vfecharep_finstat and archivo_origen in ('TMC','TMD');
	--Optimiza SFT fin    --^

	--IF  (not exists(select fechacarga from bditarjeta:"informix".td_movimientos_conciliacion where cast(fechacarga as date) = vfecha_hoy)) THEN
	--IF  (not exists(select fechacarga from bditarjeta:"informix".td_movimientos_conciliacion where fechatransaccion BETWEEN vfecharep_inimov AND vfecharep_finmov)) THEN

	--IF (vcontadortdmovcon = 0) THEN
	--IF (not exists(select FIRST 10 * from bditarjeta:"informix".td_movimientos_conciliacion where fechacarga between vfecharep_inistat and vfecharep_finstat and fechaconcilia between vfecharep_inistat and vfecharep_finstat and archivo_origen in ('TMC','TMD'))) THEN
	IF (vcontadortdmovcon = 0) THEN
		let cCodret = '00012';
		let CVarDataErr = 'No existe informaciOn del dia: '||vfecha_hoy-1||' en la tabla de MOVS CONCILIACION';
		
		insert into bditarjeta:"informix".td_bitacora_procesos (consecutivo,idproceso,fechahora,no_error,descripcion)
			VALUES(0,'01',current,CCodret,CVarDataErr);
		
		RETURN cCodret,CVarDataErr;
	END IF;

	--- Valida que si existe informacion en la tabla 'td_txns_atms_exitosas' del dia a procesar, borra la informacion ---

	--SELECT COUNT(*) INTO vcontadortxnexi from bditarjeta:"informix".td_txns_atms_exitosas where fechahoramov between vfecharep_inimov and vfecharep_finmov and fechaproceso between vfecharep_inistat and vfecharep_finstat + 1;
	--Optimiza SFT inicio --v
	--SELECT COUNT(*) INTO vcontadortxnexi from bditarjeta:"informix".td_txns_atms_exitosas where fechahoramov between vfecharep_inimov and vfecharep_finmov;
	SELECT COUNT(*) 
	INTO vcontadortxnexi 
	from bditarjeta:"informix".td_txns_atms_exitosas 
	where fechahoramov >= vfecharep_inimov and fechahoramov <= vfecharep_finmov;
	--Optimiza SFT fin    --^

	IF	(vcontadortxnexi > 0) THEN
	--Optimiza SFT inicio --v
	{ 
		FOREACH WITH HOLD

			SELECT FIRST 1 fechahoramov 
			INTO vfechadelete 
			from bditarjeta:"informix".td_txns_atms_exitosas 
			--where fechahoramov between vfecharep_inimov and vfecharep_finmov
			-------Y_Sftk-Se cambia between en el where--->
			where fechahoramov >= vfecharep_inimov and fechahoramov <= vfecharep_finmov
			-------Y_Sftk---<
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccionFor = 'F') THEN
				BEGIN WORK;
				LET vsFlagEnTransaccionFor = 'V';
			END IF;
			-------Y_Sftk-Se cambia between en el where--->
			DELETE bditarjeta:"informix".td_txns_atms_exitosas
			--WHERE fechahoramov between vfecharep_inimov and vfecharep_finmov;
			WHERE fechahoramov >= vfecharep_inimov and fechahoramov <= vfecharep_finmov;
			-------Y_Sftk---<
			LET vContadorDelete = vContadorDelete + 1;

			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vContadorDelete = 500) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccionFor = 'F';
				LET vContadorDelete = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;

		IF ((vContadorDelete > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccionFor = 'F';
		END IF;
	}
		-------Y_Sftk-Se puso directiva pero este delete no esta en el codigo original por lo que se elimina--->
		--DELETE {+AVOID_FULL (bditarjeta:"informix".td_txns_atms_exitosas)} bditarjeta:"informix".td_txns_atms_exitosas
		--WHERE fechahoramov >= vfecharep_inimov AND fechahoramov <= vfecharep_finmov;
		-------Y_Sftk---<
	--Optimiza SFT fin    --^
	END IF;

	--- Valida que no existan las siguientes tablas ---
	--Optimiza SFT inicio --v
	{ 
		IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'movimientoist' AND dbsname= 'intercard') THEN
			DROP TABLE intercard:"informix".movimientoist;
		END IF;

		IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_sus_en_mis_exi' AND dbsname= 'intercard') THEN
			DROP TABLE intercard:"informix".td_sus_en_mis_exi;
		END IF;

		IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_sus_en_mis_exi2' AND dbsname= 'intercard') THEN
			DROP TABLE intercard:"informix".td_sus_en_mis_exi2;
		END IF;

		IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'reversossusenmis' AND dbsname= 'intercard') THEN
			DROP TABLE intercard:"informix".reversossusenmis;
		END IF;
	}
	--Optimiza SFT fin    --^
	/*IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'revpartmo' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".revpartmo;
	END IF;*/

	--Optimiza SFT inicio --v
	/*IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'revparist' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".revparist;
	END IF;*/
	--Optimiza SFT fin    --^

	/*IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'td_txns_atms_exitosas_temp' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".td_txns_atms_exitosas_temp;
	END IF;*/

	/*IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'tmo1' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".tmo1;
	END IF;*/

	/*IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'ist1' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".ist1;
	END IF;*/

	--Optimiza SFT inicio --v
	/*IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'revpar_movimientoist' AND dbsname= 'intercard') THEN
		DROP TABLE intercard:"informix".revpar_movimientoist;
	END IF;*/
	--Optimiza SFT fin    --^

	--- Obtiene las transacciones exitosas del dia, de la tabla 'Movimiento' a la tabla 'movimientoist' ---
	let vpaso= 1;

	SELECT * FROM intercard:movimiento mv
	--Optimiza SFT inicio --v
	--where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
	where mv.fechahorainauth >= vfecharep_inimov AND mv.fechahorainauth <= vfecharep_finmov
	--Optimiza SFT fin    --^
		--mv.fechahorainauth between '2017-11-17 00:00:00' and '2017-11-17 23:59:59'
		and mv.codigoiso = '00'
		and mv.codtran in ('31','01')
		--and mv.fechalocaltransaccion = vmesdia
		--Optimiza SFT inicio --v
		--and mv.horalocaltransaccion BETWEEN '000000' AND '235959'
		and mv.horalocaltransaccion >= '000000' AND mv.horalocaltransaccion <= '235959'
		--Optimiza SFT fin    --^
		and mv.prodind = '01'
		and mv.movreversado = 'F'
		and mv.formato in ('0200')
		and mv.codreversa in ('0')
	INTO temp movimientoist WITH NO LOG;

	CREATE INDEX idxtmp_movimientoist ON movimientoist(fechahorainauth) USING BTREE;
	CREATE INDEX idxtmp_movimientoist_2 ON movimientoist(numtarjeta) USING BTREE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE movimientoist;

	/*SELECT * FROM intercard:movimiento mv
	where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
	--mv.fechahorainauth between '2017-11-17 00:00:00' and '2017-11-17 23:59:59'
	and mv.prodind = '01'
	and mv.codigoiso = '00'
	and mv.codreversa in ('0')
	and mv.formato in ('0200')
	and mv.movreversado = 'F'
	and mv.codtran in ('31','01')
	INTO temp movimientoist WITH NO LOG;
	CREATE INDEX idxtmp_movimientoist ON movimientoist(fechahorainauth) USING BTREE;
	CREATE INDEX idxtmp_movimientoist_2 ON movimientoist(numtarjeta) USING BTREE;
	UPDATE STATISTICS MEDIUM FOR TABLE movimientoist;*/

	--- Obtiene las transacciones exitosas del dia que cuenten con reversos parciales, de la tabla 'Movimiento' a la tabla 'revpar_movimientoist' ---

	let vpaso= 2;


	----cmmancilla

	select * from intercard:movimiento mv
	--Optimiza SFT inicio --v
	--where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
	where mv.fechahorainauth >= vfecharep_inimov AND mv.fechahorainauth <= vfecharep_finmov
	--Optimiza SFT fin    --^
	--mv.fechahorainauth between '2017-11-17 00:00:00' and '2017-11-17 23:59:59'
	and codigoiso = '00'
	and codtran in ('31','01')
	--and mv.fechalocaltransaccion = vmesdia
	--Optimiza SFT inicio --v
	--and mv.horalocaltransaccion BETWEEN '000000' AND '235959'
	and mv.horalocaltransaccion >= '000000' AND mv.horalocaltransaccion <= '235959'
	--Optimiza SFT fin    --^
	and prodind = '01'
	and formato = '0420'
	and codreversa = '2'
	INTO temp revpar_movimientoist WITH NO LOG;

	CREATE INDEX idxtmp_revpar_movimientoist ON revpar_movimientoist(fechahorainauth) USING BTREE;
	CREATE INDEX idxtmp_revpar_movimientoist_2 ON revpar_movimientoist(numtarjeta) USING BTREE;

	UPDATE STATISTICS MEDIUM FOR TABLE revpar_movimientoist;

	--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dia entre las tablas 'movimientoist' y 'conciliacion_atm_stat06' del tipo 'MIS en MIS' Y 'MIS en SUS' ('IST') ---
	----------INSERT 1 a MODIFICAR cmmancilla

	let vpaso= 3;

	FOREACH CURSOR1 WITH HOLD FOR

		select-- count(*)
		0, con.fechaconciliacion as fechaproceso,mv.fechahorainauth as fechahoramov,mv.secuencia,mv.numtarjeta as numtarjetamovi,con.numtarjeta as numtarjetastat06,
		SUBSTR (mv.numtarjeta,0,6) AS BIN,trim(mv.idterminal),
		case
			WHEN transaccionorigen='0010'  THEN "MM"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'V' and esnacional ='V'  THEN "MM"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='V'  THEN "MS"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='F'  THEN "MS"
			ELSE ''
		END AS tipotran,
		mv.codtran,
		mv.esnacional,
		mv.transaccionorigen,
		mv.idreceptor,
		mv.codreversa,
		case
			WHEN movconciliado ='F' THEN "V"
			ELSE "V"
		END AS movconciliado,
		mv.movreversado,
		mv.trancajeropropio,
		mv.formato,
		con.archivoorigen,
		case
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='C') THEN "C"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='D') THEN "D"
			ELSE ''
		END AS creditodebito,
		case
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='MC') THEN "M"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='VS') THEN "V"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='MC') THEN "M"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='VS') THEN "V"
			ELSE ''
		END AS marca,mv.monto,mv.montorealrevfzda,mv.montosurcharge,mv.montocomision,con.red

		INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

		from  intercard:movimientoist mv,intercard:conciliacion_atm_stat06 con
		--where mv.fechahorainauth between '2016-11-15 00:00:00' and '2016-11-15 23:59:59'
		--Optimiza SFT inicio --v
		--where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
		where mv.fechahorainauth >= vfecharep_inimov AND mv.fechahorainauth <= vfecharep_finmov
			--Optimiza SFT fin    --^
			and mv.prodind='01'
			and  mv.numtarjeta =con.numtarjeta
			and SUBSTR (mv.secuencia,2,7)=con.autorizacion
			and mv.idterminal=con.numcajero
			and con.archivoorigen in ('IST')
			and con.fecha = vfecharephoy
			--and con.fechaconciliacion between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
			--and con.fechaconciliacion between vfecharep_inistat and vfecharep_finstat
			and con.indicadordereversa =''
			and mv.codigoiso='00'
			and mv.codreversa ='0'
			and mv.formato='0200'
			and mv.codigoiso='00'
			and mv.transaccionorigen='0010'
		order by mv.numtarjeta

		INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional, transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,
		marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional) 
		VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);

		--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dia entre las tablas 'movimientoist' y 'td_movimientos_conciliacion' del tipo 'MIS en MIS' Y 'MIS en SUS' ('TMC','TMD') ---

		----cmmancilla

		IF (vsFlagEnTransaccionFor = 'F') THEN
			BEGIN WORK;
			LET vsFlagEnTransaccionFor = 'V';
		END IF;

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;

	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccionFor = 'F';
	END IF;

	LET vsFlagEnTransaccionFor = 'F';
	LET viContadorRegistros = 0;
	LET vconsecutivo = 0;
	LET vsecuencia ='';
	LET vnumtarjetamovi='';
	LET vnumtarjetastat06= '';
	LET vbin='';
	LET vidterminal='';
	LET vtipotran='';
	LET vcodtran='';
	LET vesnacional='';
	LET vtransaccionorigen='';
	LET vidreceptor='';
	LET vcodreversa='';
	LET vmovconciliado='';
	LET vmovreversado='';
	LET vtrancajeropropio='';
	LET vformato='';
	LET varchivoorigen='';
	LET vcreditodebito='';
	LET vmarca='';
	LET vmonto=0;
	LET vmontorealrevfzda=0;
	LET vmontosurcharge=0;
	LET vmontocomision=0;
	LET vinternacional='';

	----------INSERT 2 a MODIFICAR cmmancilla

	---RQI 15 060 Modificacion al  calculo de retiros exitosos en cajeros-----

	let vpaso= 4;


	FOREACH CURSOR2 WITH HOLD FOR

		select 0, con.fechacarga as fechaproceso,mv.fechahorainauth as fechahoramov,mv.secuencia,mv.numtarjeta as numtarjetamovi,con.numtarjeta as numtarjetastat06,
		SUBSTR (mv.numtarjeta,0,6) AS BIN,trim(mv.idterminal),
		case
			WHEN transaccionorigen='1234'  and trancajeropropio = 'V' and esnacional ='V'  THEN "MM"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='V'  THEN "MS"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='F'  THEN "MS"
			ELSE ''
		END AS tipotran,
		mv.codtran,
		mv.esnacional,
		mv.transaccionorigen,
		mv.idreceptor,
		mv.codreversa,
		mv.movconciliado,
		mv.movreversado,
		mv.trancajeropropio,
		mv.formato,
		con.archivo_origen,
		case
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='C') THEN "C"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='D') THEN "D"
			ELSE ''
		END AS creditodebito,
		case
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='MC') THEN "M"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='VS') THEN "V"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='MC') THEN "M"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='VS') THEN "V"
			ELSE ''
		END AS marca,mv.monto,mv.montorealrevfzda,mv.montosurcharge,mv.montocomision,'EGLOBAL'

		INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

		from  intercard:movimientoist mv,bditarjeta:td_movimientos_conciliacion con
		--where mv.fechahorainauth between '2016-11-15 00:00:00' and '2016-11-15 23:59:59'
		--Optimiza SFT inicio --v
		--where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
		where mv.fechahorainauth >= vfecharep_inimov AND mv.fechahorainauth <= vfecharep_finmov
		--Optimiza SFT fin    --^
			and mv.prodind='01'
			and  mv.numtarjeta =con.numtarjeta
			and SUBSTR (mv.secuencia,2,7)=con.secuencia325
			and mv.idterminal=con.idterminal
			and con.archivo_origen in ('TMC','TMD')
			and con.fechatransaccion BETWEEN vfecharep_inimov AND vfecharep_finmov
			--and con.fechacarga between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
			--and con.fechacarga between vfecharep_inistat and vfecharep_finstat
			and mv.codigoiso='00'
			and mv.codreversa ='0'
			and mv.formato='0200'
			and mv.codigoiso='00'
			and con.iso323='00'
			and mv.transaccionorigen='1234'
			AND con.movrev325='F'
		order by mv.numtarjeta

		INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional, transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,
		marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional) 
		VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);
		--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dia con reversos parciales entre las tablas 'movimientoist' y 'td_movimientos_conciliacion' del tipo 'MIS en MIS' Y 'MIS en SUS' ('TMC','TMD') ---

		---cmmancilla

		IF (vsFlagEnTransaccionFor = 'F') THEN
			BEGIN WORK;
			LET vsFlagEnTransaccionFor = 'V';
		END IF;

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;
	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccionFor = 'F';
	END IF;

	LET vsFlagEnTransaccionFor = 'F';
	LET viContadorRegistros = 0;
	LET vconsecutivo = 0;
	LET vsecuencia ='';
	LET vnumtarjetamovi='';
	LET vnumtarjetastat06= '';
	LET vbin='';
	LET vidterminal='';
	LET vtipotran='';
	LET vcodtran='';
	LET vesnacional='';
	LET vtransaccionorigen='';
	LET vidreceptor='';
	LET vcodreversa='';
	LET vmovconciliado='';
	LET vmovreversado='';
	LET vtrancajeropropio='';
	LET vformato='';
	LET varchivoorigen='';
	LET vcreditodebito='';
	LET vmarca='';
	LET vmonto=0;
	LET vmontorealrevfzda=0;
	LET vmontosurcharge=0;
	LET vmontocomision=0;
	LET vinternacional='';

	----------FIN INSERT 2 a MODIFICAR cmmancilla

	----------INSERT 3 a MODIFICAR cmmancilla


	let vpaso= 5;

	FOREACH CURSOR3 WITH HOLD FOR

		select 0, con.fechacarga as fechaproceso,mv.fechahorainauth as fechahoramov,mv.secuencia,mv.numtarjeta as numtarjetamovi,con.numtarjeta as numtarjetastat06,
		SUBSTR (mv.numtarjeta,0,6) AS BIN,trim(mv.idterminal),
		case
			WHEN transaccionorigen='1234'  and trancajeropropio = 'V' and esnacional ='V'  THEN "MM"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='V'  THEN "MS"
			WHEN transaccionorigen='1234'  and trancajeropropio = 'F' and esnacional ='F'  THEN "MS"
			ELSE ''
		END AS tipotran,
		mv.codtran,
		mv.esnacional,
		mv.transaccionorigen,
		mv.idreceptor,
		mv.codreversa,
		con.movconciliado,
		mv.movreversado,
		mv.trancajeropropio,
		mv.formato,
		con.archivo_origen,
		case
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='C') THEN "C"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT BIN FROM INTERCARD:BINES WHERE creditodebito ='D') THEN "D"
			ELSE ''
		END AS creditodebito,
		case
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='MC') THEN "M"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='D' and MARCA ='VS') THEN "V"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='MC') THEN "M"
			WHEN SUBSTR (mv.numtarjeta,0,6) IN (SELECT bin FROM INTERCARD:BINES WHERE creditodebito ='C' and MARCA ='VS') THEN "V"
			ELSE ''
		--Optimizacion SFT inicio --v
		--END AS marca,montorealrevfzda as monto,'0' as montorealrevfzda,mv.montosurcharge,mv.montocomision,'EGLOBAL'
		END AS marca,montorealrevfzda as monto,'0' as montorealrevfzda,mv.montosurcharge,
		CASE 
			WHEN montocomision IS NULL THEN 0
			WHEN montocomision ='' THEN 0
		END AS  montocomision,
		'EGLOBAL'
		--Optimizacion SFT fin    --^

		INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

		from  intercard:revpar_movimientoist mv, bditarjeta:td_movimientos_conciliacion con
		--where mv.fechahorainauth between '2016-11-15 00:00:00' and '2016-11-15 23:59:59'
		--Optimizacion SFT inicio --v
		--where mv.fechahorainauth BETWEEN vfecharep_inimov AND vfecharep_finmov
		where mv.fechahorainauth >= vfecharep_inimov AND mv.fechahorainauth <= vfecharep_finmov
		--Optimizacion SFT fin    --^
			and mv.prodind='01'
			and con.fechatransaccion BETWEEN vfecharep_inimov AND vfecharep_finmov
			--and con.fechacarga between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
			--and con.fechacarga between vfecharep_inistat and vfecharep_finstat
			and  mv.numtarjeta =con.numtarjeta
			and SUBSTR (mv.secuenciaorig,2,7)=con.secuencia325--Se modifica para encontrar la operacion original UJAA
			and mv.idterminal=con.idterminal--Se modifica para encontrar la operacion original UJAA
			and desc_conciliacion like 'ATM reversa parcial                                         %'
			and con.archivo_origen in ('TMC','TMD')
			and con.movrev325='P'--Verifica si es un reverso parcial en la tabla bditarjeta:td_movimientos_conciliacion con
			and mv.codigoiso='00'
			and mv.codreversa ='2'
			and mv.formato='0420'
			and mv.codigoiso='00'
			and mv.transaccionorigen='1234'
		order by mv.numtarjeta

		INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional, transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,
		marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional)
		VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);
		--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dia con reversos parciales entre las tablas 'movimientoist' y 'td_movimientos_conciliacion' del tipo 'MIS en MIS' Y 'MIS en SUS' ('TMC','TMD') ---

		----cmmancilla

		IF (vsFlagEnTransaccionFor = 'F') THEN
			BEGIN WORK;
			LET vsFlagEnTransaccionFor = 'V';
		END IF;

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;

	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccionFor = 'F';
	END IF;

	LET vsFlagEnTransaccionFor = 'F';
	LET viContadorRegistros = 0;
	LET vconsecutivo = 0;
	LET vsecuencia ='';
	LET vnumtarjetamovi='';
	LET vnumtarjetastat06= '';
	LET vbin='';
	LET vidterminal='';
	LET vtipotran='';
	LET vcodtran='';
	LET vesnacional='';
	LET vtransaccionorigen='';
	LET vidreceptor='';
	LET vcodreversa='';
	LET vmovconciliado='';
	LET vmovreversado='';
	LET vtrancajeropropio='';
	LET vformato='';
	LET varchivoorigen='';
	LET vcreditodebito='';
	LET vmarca='';
	LET vmonto=0;
	LET vmontorealrevfzda=0;
	LET vmontosurcharge=0;
	LET vmontocomision=0;
	LET vinternacional='';


	--- Obtiene las transacciones exitosas del dia sin reversos, de la tabla 'conciliacion_atm_stat06' a la tabla 'td_sus_en_mis_exi' del tipo 'SUS en MIS' ---
	----------FIN INSERT 3 a MODIFICAR cmmancilla

	let vpaso= 6;

		select * from intercard:conciliacion_atm_stat06 con
		--where  fechaconciliacion between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
		--Optimiza SFT inicio --v
		--where con.fechaconciliacion between vfecharep_inistat and vfecharep_finstat
		where con.fechaconciliacion >= vfecharep_inistat AND con.fechaconciliacion <= vfecharep_finstat
		--Optimiza SFT fin    --^
			and con.fecha = vfecharephoy
			--and compania = 'BNI'
					---RQI 15 060 Modificacion al  calculo de retiros exitosos en cajeros-----
			and compania IN ('BNC','BND')
			--and archivoorigen in ('TMO','IST')
			and archivoorigen in ('IST')
			and codigoiso in ('00','01')
			AND (indicadordereversa <>'REVERSAL'
			AND indicadordereversa <> 'REVERSAL          P')
		INTO temp td_sus_en_mis_exi  WITH NO LOG;

		CREATE INDEX informix.td_sus_en_mis_exi_01 ON informix.td_sus_en_mis_exi(numtarjeta);
		CREATE INDEX informix.td_sus_en_mis_exi_02 ON informix.td_sus_en_mis_exi(numtarjeta, codigoiso, respuesta);
		CREATE INDEX informix.td_sus_en_mis_exi_04 ON informix.td_sus_en_mis_exi(numcuenta);
		CREATE INDEX informix.td_sus_en_mis_exi_03 ON informix.td_sus_en_mis_exi(fechaconciliacion, keyx);
		CREATE INDEX informix.td_sus_en_mis_exi_05 ON informix.td_sus_en_mis_exi(indicadordereversa);
		
		UPDATE STATISTICS MEDIUM FOR TABLE td_sus_en_mis_exi;

	--- Obtiene las transacciones exitosas del dia, de la tabla 'conciliacion_atm_stat06' a la tabla 'td_sus_en_mis_exi2' del tipo 'SUS en MIS' ---

	let vpaso= 7;


	select * from intercard:conciliacion_atm_stat06 con
	--where  fechaconciliacion between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
	--Optimiza SFT inicio --v
	--where con.fechaconciliacion between vfecharep_inistat and vfecharep_finstat
	where con.fechaconciliacion >= vfecharep_inistat AND con.fechaconciliacion <= vfecharep_finstat
	--Optimiza SFT fin    --^
		and con.fecha = vfecharephoy
		--and compania = 'BNI'
				---RQI 15 060 Modificacion al  calculo de retiros exitosos en cajeros-----
		and compania IN ('BNC','BND')
		--and archivoorigen in ('TMO','IST')
		and archivoorigen in ('IST')
		and codigoiso in ('00','01')
	INTO temp td_sus_en_mis_exi2  WITH NO LOG;
	
	CREATE INDEX informix.td_sus_en_mis_exi2_01 ON informix.td_sus_en_mis_exi2(numtarjeta);
	CREATE INDEX informix.td_sus_en_mis_exi2_02	ON informix.td_sus_en_mis_exi2(numtarjeta, codigoiso, respuesta);
	CREATE INDEX informix.td_sus_en_mis_exi2_04	ON informix.td_sus_en_mis_exi2(numcuenta);
	CREATE INDEX informix.td_sus_en_mis_exi2_03	ON informix.td_sus_en_mis_exi2(fechaconciliacion, keyx);
	CREATE INDEX informix.td_sus_en_mis_exi2_05	ON informix.td_sus_en_mis_exi2(indicadordereversa);
	
	UPDATE STATISTICS MEDIUM FOR TABLE td_sus_en_mis_exi2;

	--- Obtiene las transacciones exitosas del dia con reversos parciales y totales, de la tabla 'conciliacion_atm_stat06' a la tabla 'reversossusenmis' del tipo 'SUS en MIS' ---

	let vpaso= 8;


	select *  from intercard:conciliacion_atm_stat06 con
	--where  fechaconciliacion between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
	--Optimiza SFT inicio --v
	--where con.fechaconciliacion between vfecharep_inistat and vfecharep_finstat
	where con.fechaconciliacion >= vfecharep_inistat AND con.fechaconciliacion <= vfecharep_finstat
		--Optimiza SFT fin    --^
		and con.fecha = vfecharephoy
		--and compania = 'BNI'
				---RQI 15 060 Modificacion al  calculo de retiros exitosos en cajeros-----
		and compania IN ('BNC','BND')
		--and archivoorigen in ('TMO','IST')
		and archivoorigen in ('IST')
		AND (trim(indicadordereversa)= 'REVERSAL          P'
		OR trim(indicadordereversa)= 'REVERSAL')
		and codigoiso in ('00','01')
	INTO temp reversossusenmis  WITH NO LOG;
	
	CREATE INDEX informix.reversossusenmis_01 ON informix.reversossusenmis(numtarjeta);
	CREATE INDEX informix.reversossusenmis_02	ON informix.reversossusenmis(numtarjeta, codigoiso, respuesta);
	CREATE INDEX informix.reversossusenmis_04	ON informix.reversossusenmis(numcuenta);
	CREATE INDEX informix.reversossusenmis_03	ON informix.reversossusenmis(fechaconciliacion, keyx);
	CREATE INDEX informix.reversossusenmis_05	ON informix.reversossusenmis(indicadordereversa);
	
	UPDATE STATISTICS MEDIUM FOR TABLE reversossusenmis;


	--- Borra las trancciones con reversos totales de la tabla 'td_sus_en_mis_exi' provenientes del IST ---
	let vpaso= 9;

	--- Y_Sftk - Se agrega commit cada 1000 en delete--->
	LET vcontadorcommit = 0;

	FOREACH WITH HOLD
		SELECT autorizacion, numtarjeta 
		INTO vautorizacion, vnumtarjetad
		FROM intercard:td_sus_en_mis_exi
		WHERE autorizacion IN (
			select a.autorizacion
			from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi b
			where a.autorizacion=b.autorizacion
				and a.numtarjeta = b.numtarjeta
				and a.secuencia=b.secuencia
				and a.fecha=b.fecha
				and a.archivoorigen=b.archivoorigen
				and a.monto=b.monto
				and a.emisor=b.emisor
				and b.archivoorigen='IST'
				and trim(a.indicadordereversa) ='REVERSAL'
			)
		and numtarjeta IN (
			select a.numtarjeta
			from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi b
			where a.autorizacion=b.autorizacion
				and a.numtarjeta = b.numtarjeta
				and a.secuencia=b.secuencia
				and a.fecha=b.fecha
				and a.archivoorigen=b.archivoorigen
				and a.monto=b.monto
				and a.emisor=b.emisor
				and b.archivoorigen='IST'
				and trim(a.indicadordereversa) ='REVERSAL'
			)
		and archivoorigen='IST'

		IF (vcontadorcommit = 0) THEN
			BEGIN WORK;
		END IF;
			
		delete from intercard:td_sus_en_mis_exi
		where autorizacion = vautorizacion
			and numtarjeta = vnumtarjetad
			and archivoorigen='IST';

		LET vcontadorcommit = vcontadorcommit + 1;    
		
		IF (vcontadorcommit >= 1000) THEN
			COMMIT WORK;
			LET vcontadorcommit = 0;
		END IF;
	END FOREACH;

	IF (vcontadorcommit > 0) THEN
		COMMIT WORK;
	END IF;

	LET vcontadorcommit = 0;
	--- Y_Sftk ------<
	
	--- Borra las trancciones con reversos parciales de la tabla 'td_sus_en_mis_exi' provenientes del IST

	let vpaso= 10;

	LET vautorizacion='';
	LET vnumtarjetad='';

	--- Y_Sftk - Se agrega commit cada 1000 en delete--->
	FOREACH WITH HOLD
	SELECT autorizacion, numtarjeta 
		INTO vautorizacion, vnumtarjetad
		FROM intercard:td_sus_en_mis_exi
		WHERE autorizacion IN (
			select a.autorizacion 
			from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi2 b
			where a.autorizacion=b.autorizacion
				and a.numtarjeta = b.numtarjeta
				and a.secuencia=b.secuencia
				and a.fecha=b.fecha
				and a.archivoorigen=b.archivoorigen
				and a.monto=b.monto
				and a.emisor=b.emisor
				and b.archivoorigen='IST'
				and trim(a.indicadordereversa) ='REVERSAL          P'
			)
		and numtarjeta in (
			select a.numtarjeta
			from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi2 b
			where a.autorizacion=b.autorizacion
				and a.numtarjeta = b.numtarjeta
				and a.secuencia=b.secuencia
				and a.fecha=b.fecha
				and a.archivoorigen=b.archivoorigen
				and a.monto=b.monto
				and a.emisor=b.emisor
				and b.archivoorigen='IST'
				and trim(a.indicadordereversa) ='REVERSAL          P'
			)
		and archivoorigen='IST'

		IF (vcontadorcommit = 0) THEN
			BEGIN WORK;
		END IF;

		delete from intercard:td_sus_en_mis_exi
		where autorizacion = vautorizacion
			and numtarjeta = vnumtarjetad
			and archivoorigen='IST';

		LET vcontadorcommit = vcontadorcommit + 1;    
		
		IF (vcontadorcommit >= 1000) THEN
			COMMIT WORK;
			LET vcontadorcommit = 0;
		END IF;
	END FOREACH;

	IF (vcontadorcommit > 0) THEN
		COMMIT WORK;
	END IF;

	LET vcontadorcommit = 0;
	---- Y_Sftk -----<

	--- Borra las trancciones con reversos totales de la tabla 'td_sus_en_mis_exi' provenientes del TMO ---

	let vpaso= 11;

	/*delete from intercard:td_sus_en_mis_exi
	where autorizacion in ((select a.autorizacion from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi b
	where a.autorizacion=b.autorizacion
	and   a.numtarjeta = b.numtarjeta
	and   a.secuencia=b.secuencia
	and   a.fecha=b.fecha
	and  a.archivoorigen=b.archivoorigen
	and a.monto=b.monto
	and a.emisor=b.emisor
	and b.archivoorigen='TMO'
	and trim(a.indicadordereversa) ='REVERSAL'))
	and numtarjeta in ((select a.numtarjeta
	from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi b
	where a.autorizacion=b.autorizacion
	and   a.numtarjeta = b.numtarjeta
	and   a.secuencia=b.secuencia
	and   a.fecha=b.fecha
	and  a.archivoorigen=b.archivoorigen
	and a.monto=b.monto
	and a.emisor=b.emisor
	and b.archivoorigen='TMO'
	and trim(a.indicadordereversa) ='REVERSAL'))
	and archivoorigen='TMO';*/

	--- Borra las trancciones con reversos parciales de la tabla 'td_sus_en_mis_exi' provenientes del TMO ---

	let vpaso= 12;

	/*delete  intercard:td_sus_en_mis_exi
	where autorizacion in ((select a.autorizacion from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi2 b
	where a.autorizacion=b.autorizacion
	and   a.numtarjeta = b.numtarjeta
	and   a.secuencia=b.secuencia
	and   a.fecha=b.fecha
	and  a.archivoorigen=b.archivoorigen
	and a.monto=b.monto
	and a.emisor=b.emisor
	and b.archivoorigen='TMO'
	and trim(a.indicadordereversa) ='REVERSAL          P'))
	and numtarjeta in ((select a.numtarjeta
	from intercard:reversossusenmis a ,intercard:td_sus_en_mis_exi2 b
	where a.autorizacion=b.autorizacion
	and   a.numtarjeta = b.numtarjeta
	and   a.secuencia=b.secuencia
	and   a.fecha=b.fecha
	and  a.archivoorigen=b.archivoorigen
	and a.monto=b.monto
	and a.emisor=b.emisor
	and b.archivoorigen='TMO'
	and trim(a.indicadordereversa) ='REVERSAL          P'))
	and archivoorigen='TMO';*/

	--- Obtiene las trancciones reversos parciales provenientes del IST ---

	let vpaso= 13;



	select
	con2.keyx,con2.fechaconciliacion,con2.archivoorigen,con2.nombrearchivo,con2.emisor,con2.numcajero,con2.numtarjeta,
	con2.numcuenta,con2.indicadordereversa,con2.descripcion,con2.respuesta,con2.codigoiso,con2.secuencia,con2.fecha,con2.hora,con2.orden,con2.red,
	(con1.monto-con2.monto-con1.comisionsurcharge) as monto,con2.dolares,con2.comisionsurcharge,
	con2.donativo,con2.emp,con2.autorizacion,con2.compania,con2.comision_loyaltyfee,con2.comision_usolinea,
	con2.pos_entry_mode,con2.service_code,con2.terminal_capability,con2.arqc,con2.arpc,con2.arqc_verify
	from intercard:td_sus_en_mis_exi2 con1 ,intercard:reversossusenmis con2
	where con1.autorizacion=con2.autorizacion
		and con1.fechaconciliacion=con2.fechaconciliacion
		and con1.archivoorigen in ('IST')
		and con2.archivoorigen in ('IST')
		and con1.codigoiso in ('00','01')
		and con2.codigoiso in ('00','01')
		and trim(con2.indicadordereversa)= 'REVERSAL          P'
	INTO temp revparist  WITH NO LOG;
	
	CREATE INDEX informix.revparist_01 ON informix.revparist(numtarjeta);
	CREATE INDEX informix.revparist_02	ON informix.revparist(numtarjeta, codigoiso, respuesta);
	CREATE INDEX informix.revparist_04	ON informix.revparist(numcuenta);
	CREATE INDEX informix.revparist_03	ON informix.revparist(fechaconciliacion, keyx);
	CREATE INDEX informix.revparist_05	ON informix.revparist(indicadordereversa);
	
	UPDATE STATISTICS MEDIUM FOR TABLE revparist;

	--- Obtiene las trancciones reversos parciales provenientes del TMO ---

	let vpaso= 14;

	/*select
	con1.keyx,con1.fechaconciliacion,con1.archivoorigen,con1.nombrearchivo,con1.emisor,con1.numcajero,con1.numtarjeta,con1.numcuenta,con1.indicadordereversa,con1.descripcion,con1.respuesta,con1.codigoiso,con1.secuencia,con1.fecha,con1.hora,con1.orden,con1.red,
	(con1.monto-con2.monto-con1.comisionsurcharge) as monto,con1.dolares,con1.comisionsurcharge,
	con1.donativo,con1.emp,con1.autorizacion,con1.compania,con1.comision_loyaltyfee,con1.comision_usolinea,con1.pos_entry_mode,con1.service_code,con1.terminal_capability,con1.arqc,con1.arpc,con1.arqc_verify
	from intercard:td_sus_en_mis_exi2 con1,intercard:reversossusenmis con2
	--where  con1.fechaconciliacion between '2016-11-16 00:00:00' and '2016-11-16 23:59:59'
	--where con.fechaconciliacion between vfecharep_inistat and vfecharep_finstat
	Where con1.autorizacion=con2.autorizacion
	and con1.archivoorigen ='TMO'
	and con2.archivoorigen ='TMO'
	and con1.codigoiso in ('00','01')
	and con2.codigoiso in ('00','01')
	and con1.fechaconciliacion=con2.fechaconciliacion
	and con1.numtarjeta = con2.numtarjeta
	and trim(con2.indicadordereversa)= 'REVERSAL          P'
	INTO temp revpartmo  WITH NO LOG;*/

	--- Obtiene e inserta las transacciones exitosas del dia con reversos parciales del IST, de la tabla 'revparist' a la tabla 'td_txns_atms_exitosas' ---

	let vpaso= 15;


	FOREACH CURSOR4 WITH HOLD FOR

		select 0, fechaconciliacion as fechaproceso,substr(to_DATE (fecha ,'%d/%m/%y'),0,11)||hora||'.00000' as fechahoramov,autorizacion as secuencia,'' as numtarjetamovi,numtarjeta as numtarjetastat06,SUBSTR (numtarjeta,0,6) AS BIN,trim(numcajero) as idterminal,'SM' as tipotran,
		case
			WHEN descripcion like 'CONSULTA%' AND monto = '0' THEN "31"
			WHEN descripcion like 'CONSULTA%' AND monto = '8' THEN "02"
			WHEN descripcion like 'CONSULTA%' AND monto = '5' THEN "02"
			ELSE "01"
		END as codtran,
		case
			WHEN emisor in ('VISA','MDS') THEN "F"
			ELSE "V"
		END AS esnacional,
		'0010' as transaccionorigen,'' as idreceptor, '2' as codreversa, 'V' as movconciliado, 'F' as movreversado,'V' as trancajeropropio,'0420' as formato,archivoorigen,
		case
			WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='c') THEN "C"
			WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='d') THEN "D"
				---RQI 15 060 Modificacion al  calculo de retiros exitosos en cajeros-----
			WHEN p.compania ='BND' THEN "D"
			WHEN p.compania ='BNC' THEN "C"
			ELSE ''
		END AS creditodebito,
		case
			WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='4') THEN "V"
			WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='4') THEN "V"
			WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='5') THEN "M"
			WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='5') THEN "M"
			ELSE ''
		END AS marca,monto as monto,'0' as montorealrevfzda,comisionsurcharge as montosurcharge,'0' as montocomision,red

		INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

		from intercard:revparist p

		INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional,
			transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional)
		VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
			vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);

		IF (vsFlagEnTransaccionFor = 'F') THEN
			BEGIN WORK;
			LET vsFlagEnTransaccionFor = 'V';
		END IF;

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;

	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccionFor = 'F';
	END IF;

	LET vsFlagEnTransaccionFor = 'F';
	LET viContadorRegistros = 0;
	LET vconsecutivo = 0;
	LET vsecuencia ='';
	LET vnumtarjetamovi='';
	LET vnumtarjetastat06= '';
	LET vbin='';
	LET vidterminal='';
	LET vtipotran='';
	LET vcodtran='';
	LET vesnacional='';
	LET vtransaccionorigen='';
	LET vidreceptor='';
	LET vcodreversa='';
	LET vmovconciliado='';
	LET vmovreversado='';
	LET vtrancajeropropio='';
	LET vformato='';
	LET varchivoorigen='';
	LET vcreditodebito='';
	LET vmarca='';
	LET vmonto=0;
	LET vmontorealrevfzda=0;
	LET vmontosurcharge=0;
	LET vmontocomision=0;
	LET vinternacional='';



	--where monto>'0';

	--- Obtiene e inserta las transacciones exitosas del dia con reversos parciales del TMO, de la tabla 'revpartmo' a la tabla 'td_txns_atms_exitosas' ---

	let vpaso= 16;

	/*INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional,
	transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,marca,monto,montorealrevfzda,montosurcharge,montocomision)
	select 0, fechaconciliacion as fechaproceso,substr(to_DATE (fecha ,'%d/%m/%y'),0,11)||hora||'.00000' as fechahoramov,autorizacion as secuencia,'' as numtarjetamovi,numtarjeta as numtarjetastat06,SUBSTR (numtarjeta,0,6) AS BIN,trim(numcajero) as idterminal,'SM' as tipotran,--'01' as codtran,
	case
	WHEN  descripcion like 'CONSULTA%' AND monto ='0' THEN "31"
	ELSE "01"
	END as codtran,
	case
		WHEN emisor in ('VISA','MDS') THEN "F"
	ELSE "V"
	END AS esnacional,
	'1234' as transaccionorigen,'' as idreceptor, '2' as codreversa, 'V' as movconciliado, 'F' as movreversado,'V' as trancajeropropio,'0420' as formato,archivoorigen,
	case
		WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='c') THEN "C"
		WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='d') THEN "D"
	ELSE ''
	END AS creditodebito,
	case
		WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='4') THEN "V"
		WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='4') THEN "V"
		WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='5') THEN "M"
		WHEN SUBSTR (p.numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='5') THEN "M"
	ELSE ''
	END AS marca,monto as monto,'0' as montorealrevfzda,comisionsurcharge as montosurcharge,'0' as montocomision
	from intercard:revpartmo p
	where monto>'0';*/

	--- Obtiene e inserta en la tabla 'td_txns_atms_exitosas' las transacciones exitosas del dia, de la tabla 'td_sus_en_mis_exi' del tipo 'SUS en MIS' del IST y TMO ---

	let vpaso= 17;

	FOREACH CURSOR5 WITH HOLD FOR

		select 0, fechaconciliacion as fechaproceso,substr(to_DATE (fecha ,'%d/%m/%y'),0,11)||hora||'.00000' as fechahoramov,autorizacion as secuencia,'' as numtarjetamovi,numtarjeta as numtarjetastat06,SUBSTR (numtarjeta,0,6) AS BIN,trim(numcajero) as idterminal,'SM' as tipotran,--'01' as codtran,
		case
			WHEN descripcion like 'CONSULTA%' AND monto = '0' THEN "31"
			WHEN descripcion like 'CONSULTA%' AND monto = '8' THEN "02"
			WHEN descripcion like 'CONSULTA%' AND monto = '5' THEN "02"
			ELSE "01"
		END as codtran,
		case
			WHEN emisor in ('VISA','MDS') THEN "F"
			ELSE "V"
		END AS esnacional,
		case
			WHEN archivoorigen ='TMO' THEN '1234'
			WHEN archivoorigen ='IST' THEN '0010'
			ELSE ''
		end as transaccionorigen,'' as idreceptor, '0' as codreversa, 'V' as movconciliado, 'F' as movreversado,'V' as trancajeropropio,'0200' as formato,archivoorigen,
		case
			WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='c') THEN "C"
			WHEN SUBSTR (numtarjeta,0,6) IN (SELECT BIN FROM BDICHEQ:SC_BINES WHERE creditodebito ='d') THEN "D"
				---RQI 15 060 Modificacion al  calculo de retiros exitosos en cajeros-----
			WHEN compania ='BND' THEN "D"
			WHEN compania ='BNC' THEN "C"
			ELSE ''
		END AS creditodebito,
		case
			WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='4') THEN "V"
			WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='4') THEN "V"
			WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='d' and SUBSTR (bin,0,1) ='5') THEN "M"
			WHEN SUBSTR (numtarjeta,0,1) IN  (SELECT SUBSTR (bin,0,1) FROM bdicheq:sc_bines WHERE creditodebito ='c' and SUBSTR (bin,0,1) ='5') THEN "M"
			ELSE ''
		END AS marca,monto as monto,'0' as montorealrevfzda,comisionsurcharge as montosurcharge,'0' as montocomision,red

		INTO vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional

		from intercard:td_sus_en_mis_exi

		INSERT INTO bditarjeta:"informix".td_txns_atms_exitosas(consecutivo, fechaproceso, fechahoramov, secuencia, numtarjetamovi, numtarjetastat06, bin,idterminal, tipotran, codtran, esnacional,
		transaccionorigen, idreceptor, codreversa,movconciliado,movreversado,trancajeropropio,formato,archivoorigen,creditodebito,marca,monto,montorealrevfzda,montosurcharge,montocomision,internacional)
		VALUES (vconsecutivo, vfechaproceso, vfechahoramov, vsecuenciaFor, vnumtarjetamovi, vnumtarjetastat06, vbin,vidterminal, vtipotran, vcodtran, vesnacional, vtransaccionorigen, vidreceptor, vcodreversa, vmovconciliado,vmovreversado,vtrancajeropropio,vformato,varchivoorigen,vcreditodebito,
		vmarca,vmonto,vmontorealrevfzda,vmontosurcharge,vmontocomision,vinternacional);

		IF (vsFlagEnTransaccionFor = 'F') THEN
			BEGIN WORK;
			LET vsFlagEnTransaccionFor = 'V';
		END IF;

		LET viContadorRegistros = viContadorRegistros + 1;

		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 500) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccionFor = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;

	END FOREACH;

	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccionFor = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccionFor = 'F';
	END IF;

	LET vsFlagEnTransaccionFor = 'F';
	LET viContadorRegistros = 0;
	LET vconsecutivo = 0;
	LET vsecuencia ='';
	LET vnumtarjetamovi='';
	LET vnumtarjetastat06= '';
	LET vbin='';
	LET vidterminal='';
	LET vtipotran='';
	LET vcodtran='';
	LET vesnacional='';
	LET vtransaccionorigen='';
	LET vidreceptor='';
	LET vcodreversa='';
	LET vmovconciliado='';
	LET vmovreversado='';
	LET vtrancajeropropio='';
	LET vformato='';
	LET varchivoorigen='';
	LET vcreditodebito='';
	LET vmarca='';
	LET vmonto=0;
	LET vmontorealrevfzda=0;
	LET vmontosurcharge=0;
	LET vmontocomision=0;
	LET vinternacional='';

	--- Obtiene e inserta las transacciones exitosas 'SUS en MIS' del TMO en la tabla 'tmo1' ---

	let vpaso= 18;

	/*select * FROM bditarjeta:td_txns_atms_exitosas a
	where a.tipotran='SM'
	and archivoorigen='TMO'
	INTO temp tmo1  WITH NO LOG;*/

	--- Obtiene e inserta las transacciones exitosas 'SUS en MIS' del IST en la tabla 'ist1' ---

	let vpaso= 19;

	/*select * FROM bditarjeta:td_txns_atms_exitosas a
	where a.tipotran='SM'
	and archivoorigen='IST'
	INTO temp ist1  WITH NO LOG;*/

	--- Se unen las tablas 'tmo1' y 'ist1' en la tabla 'td_txns_atms_exitosas_temp' ---

	let vpaso= 20;

	/*select a.secuencia,a.numtarjetastat06, a.archivoorigen
	from tmo1 a
	inner  JOIN ist1 b
	on a.numtarjetastat06=b.numtarjetastat06
	and a.secuencia= b.secuencia
	and a.monto= b.monto
	and a.fechahoramov = b.fechahoramov
	and a.idterminal=b.idterminal
	and a.trancajeropropio=b.trancajeropropio
	and a.tipotran=b.tipotran
	and a.bin=b.bin
	and a.transaccionorigen <>b.transaccionorigen
	and a.archivoorigen <> b.archivoorigen   --6442
	where (a.secuencia is not null  OR  b.secuencia is not  null)
	INTO temp td_txns_atms_exitosas_temp  WITH NO LOG;*/

	--- Se eliminan las transacciones duplicadas provenientes del TMO de la tabla 'td_txns_atms_exitosas' ---

	let vpaso= 21;

	/*begin;
	DELETE from bditarjeta:td_txns_atms_exitosas
	where secuencia in (select secuencia from td_txns_atms_exitosas_temp where archivoorigen='TMO')
	and numtarjetastat06  in (select numtarjetastat06 from td_txns_atms_exitosas_temp where archivoorigen='TMO')
	and archivoorigen in (select archivoorigen from td_txns_atms_exitosas_temp where archivoorigen='TMO');
	commit;*/

	--- Se actualiza el valor de la comision a cero (0)' ---

	let vpaso= 22;

	--BEGIN;
	{

		--- Y_Sftk - Se agrega commit cada 1000 en update--->
		LET vcontadorcommit = 0;
		LET vmontocomisionup=0;
		
		FOREACH WITH HOLD	
			select montocomision
			INTO vmontocomisionup
			from bditarjeta:td_txns_atms_exitosas
			WHERE fechahoramov >= vfecharep_inimov and fechahoramov <= vfecharep_finmov
			and montocomision is null;

			IF (vcontadorcommit = 0) THEN
				BEGIN WORK;
			END IF;
			
			UPDATE bditarjeta:td_txns_atms_exitosas
			SET montocomision = '0'
			WHERE montocomision = vmontocomisionup;
				

			LET vcontadorcommit = vcontadorcommit + 1;    
					
			IF (vcontadorcommit >= 1000) THEN
				COMMIT WORK;
				LET vcontadorcommit = 0;
			END IF;
		END FOREACH;

		IF (vcontadorcommit > 0) THEN
			COMMIT WORK;
		END IF;

		LET vcontadorcommit = 0;
		--- Y_Sftk ------<
			
	}
	--commit;

	--- Se eliminan laa tablas temporales creadas ---

	let vpaso= 23;

	DROP table movimientoist;
	DROP table td_sus_en_mis_exi;
	DROP table td_sus_en_mis_exi2;
	DROP table reversossusenmis;
	--DROP table revpartmo;
	DROP table revparist;
	--DROP table td_txns_atms_exitosas_temp;
	--DROP table tmo1;
	--DROP table ist1;
	DROP table revpar_movimientoist;

	--- Muestra el mensaje final por haber concluido el proceso ---

	let vpaso= 24;

	let cCodret = '00000';
	let CMENSAJE = 'Proceso concluido exitosamente del dia: '||vfecharephoy;

	insert into bditarjeta:"informix".td_bitacora_procesos (consecutivo,idproceso,fechahora,no_error,descripcion)
		VALUES(0,'01',current,CCodret,CMENSAJE);

	RETURN cCodret,CMENSAJE;

	END
END PROCEDURE;