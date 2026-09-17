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