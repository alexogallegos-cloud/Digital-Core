CREATE PROCEDURE "informix".sp_aplica_genconadmin ( psNumEmpleado CHAR (8), psArchivoOrigen CHAR(3), psNombreArchivo CHAR (23), 
psFlag_AplicarSaldos CHAR(1), pdtFecha_Conciliacion DATETIME YEAR TO FRACTION (5))

--****************************************************************************************************
-- DESCRIPCION:  SP QUE VALIDA LOS PARAMETROS DE ENTRADA PROVENIENTES DEL TRIGER () Y DECIDE EJECUTAR LA CONCILIACION ADMINISTRATIVA (sp_GenConAdMin)
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 09/02/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico  --- ADMINI8STRATIVA
-- MODIFICADO : 23/04/2010 Casanova Edeza Hector Juan --Se agrego la logica para considerar a archivos de corresponsales de pagos(CCP), depositos(CCD) para que se active la conciliacion administratica de corresponsales
-- MODIFICADO : 09/06/2010 Casanova Edeza Hector Juan --Se modificaron los criterios de busqueda de archivos conciliados para que contemplen las tablas de conciliacion automatica y conciliacion manual.
-- MODIFICADO : 26/05/2011 Casanova Edeza Hector Juan --Se agrega la funcionalidad de la conciliacion administrativa para el archivo de TPD.
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsNomArchivoComplemento CHAR(23);
DEFINE vsFechaArchivo CHAR(8);
DEFINE vsArchivoOrigen CHAR(3);
DEFINE vsRuta_Repositorio_WIN CHAR(100);

DEFINE vsNomArchivoCom CHAR(23);
DEFINE vsNomArchivoCred CHAR(23);
DEFINE vsNomArchivoDeb CHAR(23);
DEFINE vsRuta_Repositorio_AIX CHAR(100);

DEFINE vsRespuesta CHAR(5);
DEFINE Total_Registros INTEGER;
DEFINE Mensaje_Respuesta CHAR(1000);

DEFINE vdtFechaArchivo DATE;


DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vsNomArchivoComplemento = '';
LET vsFechaArchivo = '';
LET vsArchivoOrigen = '';
LET vsRuta_Repositorio_WIN = '';

LET vsNomArchivoCom = '';
LET vsNomArchivoCred = '';
LET vsNomArchivoDeb = '';
LET vsRuta_Repositorio_AIX = '';

LET vsRespuesta = '';
LET Total_Registros = 0;
LET Mensaje_Respuesta = '';

LET vdtFechaArchivo = CURRENT::DATE;


LET visqlerr = 0;


--SET DEBUG FILE TO '/home/sysifx/conciliacion/TraceAplica_genconadmin.sql';
--TRACE ON ;

BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
		
	END EXCEPTION;
	
	
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	
	IF ((psArchivoOrigen = 'TCC') OR (psArchivoOrigen = 'TCD')) THEN --INTERREDES
		
		--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
		IF (psArchivoOrigen = 'TCC') THEN
			LET vsNomArchivoComplemento = 'BCPLTCD_' || SUBSTRING (psNombreArchivo FROM 9 FOR 12);
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vsNomArchivoCred = psNombreArchivo;
			LET vsNomArchivoDeb = vsNomArchivoComplemento;
		ELIF (psArchivoOrigen = 'TCD') THEN
			LET vsNomArchivoComplemento = 'BCPLTCC_' || SUBSTRING (psNombreArchivo FROM 9 FOR 12);
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vsNomArchivoCred = vsNomArchivoComplemento;
			LET vsNomArchivoDeb = psNombreArchivo;
		END IF;
		
		IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
			ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V') 
				AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V')) THEN  --VALIDA KE EXISTA EL REGISTRO
			ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V') 
				AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V')) THEN ----VALIDA KE EXISTA EL REGISTRO DEL ARCHIVO COMPLEMENTO EN LA MISMA FECHA
		ELSE -- OK
			--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
			EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 70 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			
			IF (vdtFechaArchivo <> CURRENT::DATE) THEN --ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
				--concitarjMMDDAAAA.txt
				LET vsNomArchivoCom = SUBSTRING (vsNomArchivoCom FROM 1 FOR 9) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
			END IF;
			
			--CORRE LA CONCILIACION ADMINISTRATIVA INTERREDES
			EXECUTE PROCEDURE Intercard:sp_GenConAdMin(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, vdtFechaArchivo) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;			
		END IF;
		
	ELIF ((psArchivoOrigen = 'CCD') OR (psArchivoOrigen = 'CCP')) THEN --CORRESPONSALES 
		--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
		--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt 
		IF (psArchivoOrigen = 'CCP') THEN --CORRESPONSALES CREDITO
			LET vsNomArchivoComplemento = 'BCPLCCD_' || SUBSTRING (psNombreArchivo FROM 9 FOR 15);
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			LET vsNomArchivoCred = psNombreArchivo;
			LET vsNomArchivoDeb = vsNomArchivoComplemento;
		ELIF (psArchivoOrigen = 'CCD') THEN --CORRESPONSALES DEBITO
			LET vsNomArchivoComplemento = 'BCPLCCP_' || SUBSTRING (psNombreArchivo FROM 9 FOR 15);
			--LET vsFechaArchivo = SUBSTRING (pdtFecha_Conciliacion FROM 9 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 6 FOR 2 ) || SUBSTRING (pdtFecha_Conciliacion FROM 1 FOR 4 ) ;
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			LET vsNomArchivoCred = vsNomArchivoComplemento;
			LET vsNomArchivoDeb = psNombreArchivo;
		ELIF (psArchivoOrigen = 'TPD') THEN --TRANSFERENCIA PRESTAMOS COPPEL
			LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
			LET vsNomArchivoCred = 'TPD';
			LET vsNomArchivoDeb = psNombreArchivo;
		END IF;
		
		
		IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
		ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V') 
			AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V')) THEN  --VALIDA KE EXISTA EL REGISTRO
		ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V') 
			AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoCred)) AND Aplicar_Saldos = 'V')) THEN ----VALIDA KE EXISTA EL REGISTRO DEL ARCHIVO COMPLEMENTO EN LA MISMA FECHA
		ELSE -- OK
			--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
			EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 71 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			
			IF (vdtFechaArchivo <> CURRENT::DATE) THEN --ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
				--concicorrMMDDAAAA.txt
				LET vsNomArchivoCom = SUBSTRING (vsNomArchivoCom FROM 1 FOR 9) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
			END IF;
			
			--CORRE LA CONCILIACION ADMINISTRATIVA CORRESPONSALES
			EXECUTE PROCEDURE Intercard:sp_GenConAdMinCorr(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, vdtFechaArchivo) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;
		END IF;
		
	ELIF (psArchivoOrigen = 'TPD') THEN -- TRANSFERENCIA PRESTAMOS COPPEL
		--SE GENERA EL NOMBRE DEL ARCHIVO COMPAÑERO
		--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt 
		
		LET vdtFechaArchivo = SUBSTRING (psNombreArchivo FROM 11 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 9 FOR 2 ) || '/' || SUBSTRING (psNombreArchivo FROM 13 FOR 4 );
		LET vsNomArchivoCred = 'TPD';
		LET vsNomArchivoDeb = psNombreArchivo;		
		
		IF ( psFlag_AplicarSaldos <> 'V' ) THEN -- ARCHIVO EN PROCESO O CON ERROR NO SE TOMA EN CUENTA (NO SE FINALIZO CORRECTAMENTE)
		ELIF (NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionAut WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V') 
			AND NOT EXISTS (SELECT ArchivoOrigen FROM Intercard:Monitor_ConciliacionMan WHERE UPPER(TRIM(Nom_Archivo)) = UPPER(TRIM(vsNomArchivoDeb)) AND Aplicar_Saldos = 'V')) THEN  --VALIDA KE EXISTA EL REGISTRO
		ELSE -- OK
			--OBTIENE EL NOMBRE Y RUTA DEL ARCHIVO DE COMISIONES 
			EXECUTE PROCEDURE Intercard:sp_ObtenerNombreArchivo ( 72 ) INTO vsNomArchivoCom, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN;
			
			IF (vdtFechaArchivo <> CURRENT::DATE) THEN --ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
				--concicorrMMDDAAAA.txt
				LET vsNomArchivoCom = SUBSTRING (vsNomArchivoCom FROM 1 FOR 9) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
			END IF;
			
			--CORRE LA CONCILIACION ADMINISTRATIVA CORRESPONSALES
			EXECUTE PROCEDURE Intercard:sp_GenConAdMinCorr(psNumEmpleado, vsNomArchivoCom, vsNomArchivoCred, vsNomArchivoDeb, vsRuta_Repositorio_AIX, vdtFechaArchivo) INTO vsRespuesta, Total_Registros, Mensaje_Respuesta;
		END IF;
		
	END IF;
	
	
END
END PROCEDURE 
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SP QUE VALIDA LOS PARAMETROS DE ENTRADA PROVENIENTES DEL TRIGER () Y DECIDE EJECUTAR ',
'LA CONCILIACION ADMINISTRATIVA (sp_GenConAdMin).',
'Fecha: 2010/02/09',
'Version: 20100209.1613',
'BD: Intercard',
'',
'Modificado: Javier Chavez BANCOPPEL',
'Proyecto: Conciliacion Automatica',
'Descripcion: Al validar el tipo de archivo se modifico parametro psNombreArchivo por el de ',
'psArchivoOrigen. Cambio de formato de nombre del archivo "BCPL_TCD" y "BCPL_TCC" por "BCPLTCD_" y "BCPLTCC_".',
'Fecha: 02/19/2010',
'Version: 20100219.1646',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1107',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego la logica para considerar a archivos de corresponsales de pagos(CCP),', 
'depositos(CCD) para que se active la conciliacion administratica de corresponsales.',
'Fecha: 2010/04/23',
'Version: 20100423.1858',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modificaron los criterios de busqueda de archivos conciliados para que contemplen ',
'las tablas de conciliacion automatica y conciliacion manual.',
'Fecha: 2010/06/09',
'Version: 20100609.1657',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - TRANSFERENCIA DE PRESTAMOS COPPEL',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega la funcionalidad de la conciliacion administrativa para el archivo de TPD.',
'Fecha: 2011/05/26',
'Version: 20110526.1712',
'BD: Intercard'; */
;

CREATE PROCEDURE "informix".sp_clasifica_devoluciones_pos_pba
(psNomArchivo VARCHAR(30), psArchivoOrigen VARCHAR(3), psNumTarjeta VARCHAR(20), psSecuenciaAutArchivo VARCHAR(6), pmMontoArchivo MONEY, psNomComercio VARCHAR(30), psEncontrado VARCHAR(1), pmMontoIntercard MONEY, piStatusConciliacion INTEGER, psMovConciliado CHAR(1), psFechaHoraInAuth DATETIME YEAR TO FRACTION )

--RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  GUARDA REGISTRO DE LOS TIPOS DE DEVOLUCIONES PROCESADAS EN LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 26/08/2011
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica -- 
-- MODIFICADO : Casanova Edeza Hector Juan 2011/11/28' --SE AGREGA LA VALIDACION DEL CAMPO MOVCONCILIADO PARA VALIDAR LA TRANSACCION ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/01' --SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS CON MONTO MAYOR PARA QUE SE CALSIFIQUEN COMO PENDIENTES CON ERROR.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/07' --SE AJUSTA EL FILTRO PARA OBTENER DE MANERA CERTERA LA REFERENCIA DEL MOVIMIENTO ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/15' --SE MODIFICA LA VALIDACION DEL RETENIDO PARA CREDITO Y DEBITO.
--***************************************************************************************************


/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;
DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE vsEstado VARCHAR(1);
DEFINE vsMotivo VARCHAR(60);
DEFINE vsFolioSucursal VARCHAR(16);
DEFINE vsReferencia23 VARCHAR(40);
DEFINE viKeyx INTEGER;
DEFINE vsAplicado VARCHAR(1);

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET vsEstado = '';
LET vsMotivo = '';
LET vsFolioSucursal = '';
LET vsReferencia23 = '';
LET viKeyx = 0;
LET vsAplicado = '';


BEGIN

ON EXCEPTION SET viSQLerr
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsCodRet = '00100';
	
END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT MAX(KeyX), FolioSucursal, Referencia
	INTO viKeyx, vsFolioSucursal, vsReferencia23
	FROM Intercard:"informix".Central 
	WHERE NombreArchivo = psNomArchivo
	AND NumTarjeta = psNumTarjeta
	AND TipoMov in ('A','D')
	AND Importe = pmMontoArchivo
	GROUP BY keyx, FolioSucursal, Referencia;

		
	IF ((psEncontrado <> 'V') OR (LENGTH(TRIM(psSecuenciaAutArchivo)) < 6 ) OR (TRIM(psSecuenciaAutArchivo) IN ('', '000000', '111111', '222222', '333333', '444444', '555555', '666666', '777777', '888888', '999999'))) THEN 
		--REGISTRO NO ENCONTRADO (NO CONCUERDA NUM TARJETA O SECUENCIA AUTORIZACION).
		--DISCRIMINAR SECUENCIAS CONSECUTIVAS.
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsMotivo = 'El número de autorización no coincide con la compra';
		LET vsEstado = 'P';
		LET vsAplicado = 'F';
	
	ELIF ((psMovConciliado <> 'V') AND (EXISTS (SELECT Fecha_Hoy FROM bdinteg:"informix".Si_Fechas WHERE ((Fecha_Hoy::DATE - (psFechaHoraInAuth::DATE) >8 ))))) THEN 
	
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';	
		
	
	ELIF (psMovConciliado <> 'V') THEN 
		-- VALIDA QUE EL MOVIMIENTO ORIGINAL ESTE CONCILIADO.
		LET vsMotivo = 'La compra original todavía no esta marcada como conciliada';
		--LET vsEstado = 'P';
		--LET vsAplicado = 'F';
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
	/*	
	ELIF ((psArchivoOrigen IN ('VND','VID')) --SOLO DEBITO
	AND (EXISTS (SELECT Cuenta FROM BdiCheq:"informix".Sc_DocRet 
	WHERE Folio_Suc = NVL(vsFolioSucursal, '')
	AND Cancelado = 'L'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO 
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
		
	ELIF ((psArchivoOrigen IN ('VNC', 'VIC')) --SOLO CREDITO
	AND (EXISTS (SELECT Num_Credito FROM BdiCred:"informix".Sd_MaeRetenido 
	WHERE Empresa = '001' AND Num_Credito IS NOT NULL  
	AND Folio_Suc = NVL(vsFolioSucursal, '')
	AND Estatus  = 'S'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO
	*/
	
	
	ELIF (pmMontoArchivo > pmMontoIntercard) THEN
		--MONTO ARCHIVO MAYOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		LET vsMotivo = 'Devolucion con monto mayor a la compra original';
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsEstado = 'P';
		LET vsAplicado = 'E';
		
	ELIF (pmMontoArchivo < pmMontoIntercard) THEN 
		--MONTO MENOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		--APLICACION FORZADA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'F';
		LET vsAplicado = 'F';	
		
	ELSE -- TODO COINCIDE
		--CONCILIADA (OK), SE APLICA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'A';
		LET vsAplicado = 'F';
		
	END IF;

	
	
	--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt
	--REGISTRO DE DETALLE
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	INSERT INTO BdiTarjeta:"informix".Td_DevolucionesPOS 
	(
		NomArchivo, 
		ArchivoOrigen, 
		Fecha, 
		TipoArchivo, 
		NumTarjeta, 
		SecuenciaAutArchivo, 
		MontoArchivo, 
		NomComercio, 
		Referencia, 
		Encontrado, 
		MontoIntercard, 
		Motivo,
		Estado,
		Aplicado
	) 
	VALUES 
	(
		psNomArchivo, 
		psArchivoOrigen, 
		SUBSTR(psNomArchivo,11,2) || '/' || (SUBSTR(psNomArchivo,9,2) || '/' ||  SUBSTR(psNomArchivo,13,4)),  --FECHA
		(CASE WHEN (psArchivoOrigen IN ('VNC', 'VIC')) THEN 'C'	WHEN (psArchivoOrigen IN ('VND', 'VID')) THEN 'D' ELSE 'X' END),  --TIPOARCHIVO
		NVL(psNumTarjeta, ''), 
		NVL(psSecuenciaAutArchivo, ''), 
		NVL(pmMontoArchivo, 0.0), 
		NVL(psNomComercio, ''), 
		NVL(vsReferencia23, ''), 
		NVL(psEncontrado, ''), 
		NVL(pmMontoIntercard, 0.0), 
		NVL(vsMotivo, ''), 
		NVL(vsEstado, ''),
		NVL(vsAplicado, '')
	);
	
	--RETURN vsCodRet, vsMensaje_Respuesta;

END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA REGISTRO DE LOS TIPOS DE DOVOLUCIONES PROCESADAS EN LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.',
'Fecha: 2011/08/25',
'Version: 20110825.0933',
'BD: Intercard', 
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA LA VALIDACION DEL CAMPO MOVCONCILIADO PARA VALIDAR LA TRANSACCION ORIGINAL.',
'Fecha: 2011/11/28',
'Version: 2011128.1910',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS CON MONTO MAYOR PARA QUE SE CALSIFIQUEN COMO PENDIENTES CON ERROR.',
'Fecha: 2011/12/01',
'Version: 20111201.1900',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AJUSTA EL FILTRO PARA OBTENER DE MANERA CERTERA LA REFERENCIA DEL MOVIMIENTO ORIGINAL.',
'Fecha: 2011/12/07',
'Version: 20111207.1648',
'BD: Intercard',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA VALIDACION DEL RETENIDO PARA CREDITO Y DEBITO.',
'Fecha: 2011/12/15',
'Version: 20111215.1025',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_clasifica_devoluciones_pos
(psNomArchivo VARCHAR(30), psArchivoOrigen VARCHAR(3), psNumTarjeta VARCHAR(20), psSecuenciaAutArchivo VARCHAR(6), pmMontoArchivo MONEY, psNomComercio VARCHAR(30), psEncontrado VARCHAR(1), pmMontoIntercard MONEY, piStatusConciliacion INTEGER, psMovConciliado CHAR(1), psFechaHoraInAuth DATETIME YEAR TO FRACTION )

--RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  GUARDA REGISTRO DE LOS TIPOS DE DEVOLUCIONES PROCESADAS EN LA CONCILIACION PARA ADMINISTRAR SU CORRECTA APLICACION.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 26/08/2011
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica -- 
-- MODIFICADO : Casanova Edeza Hector Juan 2011/11/28' --SE AGREGA LA VALIDACION DEL CAMPO MOVCONCILIADO PARA VALIDAR LA TRANSACCION ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/01' --SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS CON MONTO MAYOR PARA QUE SE CALSIFIQUEN COMO PENDIENTES CON ERROR.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/07' --SE AJUSTA EL FILTRO PARA OBTENER DE MANERA CERTERA LA REFERENCIA DEL MOVIMIENTO ORIGINAL.
-- MODIFICADO : Casanova Edeza Hector Juan 2011/12/15' --SE MODIFICA LA VALIDACION DEL RETENIDO PARA CREDITO Y DEBITO.
--***************************************************************************************************


/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;
DEFINE vsCodRet VARCHAR(5);
DEFINE vsMensaje_Respuesta VARCHAR(250);
DEFINE vsEstado VARCHAR(1);
DEFINE vsMotivo VARCHAR(60);
DEFINE vsFolioSucursal VARCHAR(16);
DEFINE vsReferencia23 VARCHAR(40);
DEFINE viKeyx INTEGER;
DEFINE vsAplicado VARCHAR(1);

/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = '';
LET vsEstado = '';
LET vsMotivo = '';
LET vsFolioSucursal = '';
LET vsReferencia23 = '';
LET viKeyx = 0;
LET vsAplicado = '';


BEGIN

ON EXCEPTION SET viSQLerr
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	LET vsCodRet = '00100';
	
END EXCEPTION;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT MAX(KeyX), FolioSucursal, Referencia
	INTO viKeyx, vsFolioSucursal, vsReferencia23
	FROM Intercard:Central 
	WHERE NombreArchivo = psNomArchivo
	AND NumTarjeta = psNumTarjeta
	AND TipoMov in ('A','D')
	AND Importe = pmMontoArchivo
	GROUP BY keyx, FolioSucursal, Referencia;

		
	IF ((psEncontrado <> 'V') OR (LENGTH(TRIM(psSecuenciaAutArchivo)) < 6 ) OR (TRIM(psSecuenciaAutArchivo) IN ('', '000000', '111111', '222222', '333333', '444444', '555555', '666666', '777777', '888888', '999999'))) THEN 
		--REGISTRO NO ENCONTRADO (NO CONCUERDA NUM TARJETA O SECUENCIA AUTORIZACION).
		--DISCRIMINAR SECUENCIAS CONSECUTIVAS.
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsMotivo = 'El número de autorización no coincide con la compra';
		LET vsEstado = 'P';
		LET vsAplicado = 'F';
	
	ELIF ((psMovConciliado <> 'V') AND (EXISTS (SELECT Fecha_Hoy FROM bdinteg:"informix".Si_Fechas WHERE ((Fecha_Hoy::DATE - (psFechaHoraInAuth::DATE) >8 ))))) THEN 
	
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';	
		
	
	ELIF (psMovConciliado <> 'V') THEN 
		-- VALIDA QUE EL MOVIMIENTO ORIGINAL ESTE CONCILIADO.
		LET vsMotivo = 'La compra original todavía no esta marcada como conciliada';
		--LET vsEstado = 'P';
		--LET vsAplicado = 'F';
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
	/*	
	ELIF ((psArchivoOrigen IN ('VND','VID')) --SOLO DEBITO
	AND (EXISTS (SELECT Cuenta FROM BdiCheq:"informix".Sc_DocRet 
	WHERE Folio_Suc = NVL(vsFolioSucursal, '')
	AND Cancelado = 'L'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO 
		
		--RECIBIDO
		--CONCILIADO
		--FALTANTE
		LET vsMotivo = 'Ya se liberó el retenido de la compra original';
		LET vsEstado = 'F';
		LET vsAplicado = 'E';
		
	ELIF ((psArchivoOrigen IN ('VNC', 'VIC')) --SOLO CREDITO
	AND (EXISTS (SELECT Num_Credito FROM BdiCred:"informix".Sd_MaeRetenido 
	WHERE Empresa = '001' AND Num_Credito IS NOT NULL  
	AND Folio_Suc = NVL(vsFolioSucursal, '')
	AND Estatus  = 'S'))) THEN --BUSCA EL RETENIDO DEL MOVIMIENTO COMO LIBERADO
	*/
	
	
	ELIF (pmMontoArchivo > pmMontoIntercard) THEN
		--MONTO ARCHIVO MAYOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		LET vsMotivo = 'Devolucion con monto mayor a la compra original';
		
		--RECIBIDO
		--ERROR
		--FALTANTE
		LET vsEstado = 'P';
		LET vsAplicado = 'E';
		
	ELIF (pmMontoArchivo < pmMontoIntercard) THEN 
		--MONTO MENOR AL REPORTADO EN LA TRANSACCION ORIGINAL.
		--APLICACION FORZADA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'F';
		LET vsAplicado = 'F';	
		
	ELSE -- TODO COINCIDE
		--CONCILIADA (OK), SE APLICA
		
		--RECIBIDO
		--APLICADO
		LET vsMotivo = '';
		LET vsEstado = 'A';
		LET vsAplicado = 'F';
		
	END IF;

	
	
	--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt
	--REGISTRO DE DETALLE
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	INSERT INTO BdiTarjeta:Td_DevolucionesPOS 
	(
		NomArchivo, 
		ArchivoOrigen, 
		Fecha, 
		TipoArchivo, 
		NumTarjeta, 
		SecuenciaAutArchivo, 
		MontoArchivo, 
		NomComercio, 
		Referencia, 
		Encontrado, 
		MontoIntercard, 
		Motivo,
		Estado,
		Aplicado
	) 
	VALUES 
	(
		psNomArchivo, 
		psArchivoOrigen, 
		SUBSTR(psNomArchivo,11,2) || '/' || (SUBSTR(psNomArchivo,9,2) || '/' ||  SUBSTR(psNomArchivo,13,4)),  --FECHA
		(CASE WHEN (psArchivoOrigen IN ('VNC', 'VIC')) THEN 'C'	WHEN (psArchivoOrigen IN ('VND', 'VID')) THEN 'D' ELSE 'X' END),  --TIPOARCHIVO
		NVL(psNumTarjeta, ''), 
		NVL(psSecuenciaAutArchivo, ''), 
		NVL(pmMontoArchivo, 0.0), 
		NVL(psNomComercio, ''), 
		NVL(vsReferencia23, ''), 
		NVL(psEncontrado, ''), 
		NVL(pmMontoIntercard, 0.0), 
		NVL(vsMotivo, ''), 
		NVL(vsEstado, ''),
		NVL(vsAplicado, '')
	);
	
	--RETURN vsCodRet, vsMensaje_Respuesta;

END;
END PROCEDURE;