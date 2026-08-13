CREATE PROCEDURE "informix".tc_sube_concilia 
		(
		pEmpresa CHAR(3), 
		pArchivo CHAR(12) 
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter 
		--	Consecutivo  1 caracter 
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5);

	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------   
	DEFINE vFechaHoy	DATE;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	DEFINE vArchivo  	VARCHAR(3);
	DEFINE vTabla  	 	VARCHAR(30);
	DEFINE vTipo		CHAR(1);
	--------------------------------------------------------
	--	Varibales de Control de Encabezado
	--------------------------------------------------------   
	DEFINE vSucursal 	VARCHAR(3);
	DEFINE vUsuario		VARCHAR(8);
	DEFINE vFecha		DATE;
	DEFINE vTotMovs		CHAR(16);
	DEFINE vTotCgo		CHAR(20);
	DEFINE vTotAbono	VARCHAR(20);
	DEFINE vTotRev		DECIMAL(14,2);
	DEFINE vBandera		CHAR(2);
	--------------------------------------------------------
	--	Variables de Control de Detalles
	--------------------------------------------------------   
	DEFINE vTotMovsDet	INTEGER;
	DEFINE vTotCgoDet	INTEGER;
	DEFINE vTotAbonoDet	INTEGER;
	DEFINE vTotRevDet	INTEGER;
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------   
	LET vFechaHoy	= " ";
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	LET vArchivo  	= "";
	LET vTabla  	= "";
	LET vTipo		= "";
	--------------------------------------------------------
	--	Varibales de Control de Encabezado
	--------------------------------------------------------   
	LET vSucursal 	= "";
	LET vUsuario	= "";
	LET vFecha		= " ";
	LET vTotMovs	= "";
	LET vTotCgo		= "";
	LET vTotAbono	= "";
	LET vTotRev		= 0;
	LET vBandera	= "";
	--------------------------------------------------------
	--	Variables de Control de Detalles
	--------------------------------------------------------   
	LET vTotMovsDet		= 0;
	LET vTotCgoDet		= 0;
	LET vTotAbonoDet	= 0;
	LET vTotRevDet		= 0;

BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;


--SET DEBUG FILE TO '/home/sysifx/conciliacion/TraceSUBECONCILIA.sql';
--TRACE ON ;
 
  SET LOCK MODE TO WAIT 10;
  SET ISOLATION TO DIRTY READ ;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo parametros
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT fecha_hoy::DATE 		INTO vFechaHoy
	FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo tipo de conciliacion
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	LET vArchivo =	SUBSTR(pArchivo,1,3);
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT archivo,tabla,tipo  INTO vArchivo,vTabla,vTipo
	FROM BdiTarjeta:td_archivos 
	WHERE empresa =  pEmpresa
	AND archivo = vArchivo;
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- No se encuentra definicion para el archivo proporcionado
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vTabla IS NULL OR vTabla = "" THEN
 		RETURN '001';
 	END IF
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Validacion de encabezado
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT  tp_movto, 	tran_central, 	tran_sucursal::DATE, 
			folio_mov,  cuenta,	       	tran_secuencia, 
			monto, 		moneda
  	INTO 	vSucursal, 	vUsuario, 		vFecha, 
  			vTotMovs, 	vTotCgo, 		vTotAbono,
       		vTotRev, 	vBandera
  	FROM BdiTarjeta:td_pasoconcilia
 	WHERE filename = pArchivo AND tp_renglon = "E";
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- El Encabezado no Existe o esta corrupto
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vSucursal IS NULL OR vUsuario IS NULL  OR vFecha IS NULL  OR
 	   vTotMovs IS NULL OR vTotCgo IS NULL  OR vTotAbono IS NULL  OR
 	   vTotRev IS NULL OR vBandera IS NULL  OR vUsuario IS NULL  
 	THEN
 		RETURN '002';
 	END IF
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Validacion de Encabezado con detalle
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT COUNT(*),
		   SUM(CASE WHEN tp_movto   = 'C' THEN  1 ELSE 0 END),
		   SUM(CASE WHEN tp_movto   = 'A' THEN  1 ELSE 0 END),
		   SUM(CASE WHEN tp_movto   = 'R' THEN  1 ELSE 0 END)
	INTO   vTotMovsDet,vTotCgoDet,vTotAbonoDet,vTotRevDet
 	FROM BdiTarjeta:td_pasoconcilia
 	WHERE filename = pArchivo AND tp_renglon <> "E";
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- No coincide el encabezado con el detalle
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vTotMovs::INTEGER <> vTotMovsDet OR vTotCgo::INTEGER <> vTotCgoDet OR
 	   vTotAbono::INTEGER <> vTotAbonoDet OR vTotRev::INTEGER <> vTotRevDet THEN
 		RETURN '003';
 	 END IF
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserta Registro de Control de Carga
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	INSERT INTO BdiTarjeta:td_conciliaarchivos
		(
		empresa, 			archivo, 			fecha, 		
		recibidos_total, 	recibidos_cargo,	recibidos_abono, 	
		recibidos_reversa, 	fecha_recepcion,	bandera_procesa,
	  	procesados,			cargo_concilia,		cargo_aplica,
	  	cargo_error,		abono_concilia,		abono_aplica,
	  	abono_error,		reversa_concilia,	reversa_aplica,
	  	reversa_error,		usuario,			sucursal,
	  	tipoarchivo
	  	)
	VALUES
	 	(
	 	pEmpresa, 			pArchivo, 			vFecha, 
	 	vTotMovs, 			vTotCgo, 			vTotAbono,
	  	vTotRev, 			vFechaHoy, 			"0",
	  	"0",				"0",				"0",
	  	"0",				"0",				"0",
	  	"0",				"0",				"0",
	  	"0",				vUsuario,			vSucursal,
	  	vArchivo
	  	);
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserta Movimiento a Conciliar
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--------------------------------------------------------
	--	POS
	--------------------------------------------------------
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	-- PAGOS NACIONALES INTERBANCARIOS
	IF vTabla = "td_conpospnc" THEN
		INSERT INTO BdiTarjeta:td_conpospnc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
		
	-- VENTAS NACIONALES CREDITO
	ELIF  vTabla = "td_conposvnc" THEN
		INSERT INTO BdiTarjeta:td_conposvnc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		--AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
		/*
		---/// MODIFICACION TEMPORAL;
		INSERT INTO BdiTarjeta:td_conposvnc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
			cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
         */
		
	-- VENTAS NACIONALES DEBITO
	ELIF  vTabla = "td_conposvnd" THEN
		INSERT INTO BdiTarjeta:td_conposvnd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		--AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
		/*
		---/// MODIFICACION TEMPORAL;		
		INSERT INTO BdiTarjeta:td_conposvnd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
			cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0
		AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
        */
			

	-- VENTAS INTERNACIONALES CREDITO
	ELIF  vTabla = "td_conposvic" THEN
		INSERT INTO BdiTarjeta:td_conposvic
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		--AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
		
        /* 
		---/// MODIFICACION TEMPORAL;
		INSERT INTO BdiTarjeta:td_conposvic
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
			cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0
		AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
        */
				
	
	-- VENTAS INTERNACIONALES DEBITO
	ELIF  vTabla = "td_conposvid" THEN
        
        --//// SE AJUSTA TEMPORALMENTE PARA EXCUILR TODOS LAS DEVOLUCIONES DEL ARCHIVO VID
		INSERT INTO BdiTarjeta:td_conposvid
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
        --AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;

        /*
		--- /// MODIFICACION TEMPORAL
        INSERT INTO BdiTarjeta:td_conposvid
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
            cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0
        AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
        */
		
	--------------------------------------------------------
	--	ATM
	--------------------------------------------------------
	-- RETIROS CREDITO
	ELIF  vTabla = "td_conatmc" THEN
		INSERT INTO BdiTarjeta:td_conatmc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;

	-- RETIROS DEBITO
	ELIF  vTabla = "td_conatmd" THEN
		INSERT INTO BdiTarjeta:td_conatmd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
 
			
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
		--MOVIMIENTOS CORRESPONSAL BCPLCCP
	ELIF  vTabla = "td_concorrp" THEN
		INSERT INTO BdiTarjeta:td_concorrp
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
 
			
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
		--MOVIMIENTOS CORRESPONSAL BCPLCCD
	ELIF  vTabla = "td_concorrd" THEN
		INSERT INTO BdiTarjeta:td_concorrd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
			
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
	ELIF  vTabla = "td_contpd" THEN
		INSERT INTO BdiTarjeta:td_contpd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
	END IF

	DELETE FROM BdiTarjeta:td_pasoconcilia 
	WHERE filename = pArchivo AND bandera_proceso = 0;


   RETURN cod_ret;

-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;
END PROCEDURE;