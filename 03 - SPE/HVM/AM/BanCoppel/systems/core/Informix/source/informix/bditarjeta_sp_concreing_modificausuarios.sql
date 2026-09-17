CREATE PROCEDURE "informix".sp_concreing_modificausuarios 
				(pClave CHAR(10), 
				 pNombre CHAR(30), 
				 pOperacion CHAR(1), 
				 pMonitoreo CHAR(1), 
				 pAdmon CHAR(1), 
				 pFecha DATE, 
				 psUsuario CHAR(10),
				 pActivo char(1)) -- Para Reactivacion del Usuario
RETURNING CHAR(5);

--*************************************************************************************************
-- Creado por Adilene Lara Armenta.
--24/ 11/2011
-- Procedimiento almacenado que modifica los datos del usuario y sus perfiles
----------------------------------------------------------------------------------------------------------------------------

--Definición de Variables
	DEFINE cod_ret              CHAR(5);
	DEFINE sql_err               SMALLINT;
	
	DEFINE vsCodRet2 CHAR(5);
	DEFINE viElemento INTEGER;
	DEFINE vsMensaje_Respuesta VARCHAR (250);
		
--Inicializacion de Variables

	LET cod_ret          = "000";
	LET sql_err           = "";
	
	LET vsCodRet2 = '';
	LET viElemento = 43;
	LET vsMensaje_Respuesta = '';
        
BEGIN

--Control de Errores 

	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;
	  
		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || sql_err || ') MODIFICAR DE USUARIO [' || pClave || ']. ';
		EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;
	  
		RETURN 	cod_ret;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/modificausuarios.sql';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;

	UPDATE bditarjeta:"informix".td_usuarios_conciliacion
	SET nombre = pNombre,
		operacion = pOperacion,
		monitoreo = pMonitoreo,
		administracion = pAdmon,
		fecha_modificacion = pFecha,
		activo = pActivo
	WHERE cve_usuario = pClave;

	--GUARDA REGISTRO EN BITACORA
	LET vsMensaje_Respuesta = 'SE REGISTRA LA MODIFICACION DEL USUARIO [' || pClave || '].';
	EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_GuardaBitacora (viElemento, vsMensaje_Respuesta, psUsuario) INTO vsCodRet2;

	RETURN 	cod_ret;

	
END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA EL REGISTRO DE LA OPERACION EN BITACORA.',
'Fecha: 2012/08/03',
'Version: 20120803.1205',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega la campo para actualizar el estatus del usuario.',
'Fecha: 2015/09/29',
'Version: 20150929.1240',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_maparopecr
(
psFlag CHAR(1),   					--  Tipo de operacion
psComDebito CHAR(4), 				-- Comision de Interredes Debito
psComCredito CHAR(4), 				-- Comision de Interredes Crédito
psComPago CHAR(4),    				-- Comision de Deposito a Cta Efectiva
psComDeposito CHAR(4),				-- Comisión de Pago a TCD Bancoppel
psConcEjec CHAR(1),  				-- Bandera de Ejecucion
psComSaldoDebito Char(4),			-- Comision por consulta de Saldo de Débito 
psComSaldoCredito char(4),			-- Comision por consulta de Saldo de Crédito 
psComDisposicionDebito char(4),		-- Comision por disposición de Débito
psComDisposicionCredito char(4), 	-- Comision por disposición de Crédito
psComTranferenciaEfectiva char(4),	-- Comisión Transferencia entre Ctas Efectivas
psComPagTDCBCPLCargEfectiva char(4),-- Comisión Pago de TDC BCPL cargo a cta Efectiva
psComPagTDCOtroCargEfectiva char(4),-- Comisión Pago de TDC Otro cargo a cta Efectiva
psComPagTDCOtroEfectivo	char(4),	-- Comisión Pago de TDC Otro pago efectivo
psComTransferencia char(4),			-- Comisión por transferencia 
psUsuario CHAR(8)					-- Usuario que opera sistema  
)

RETURNING 
			CHAR(5) AS CodRet,
			CHAR(4) AS ComDebito,
			CHAR(4) AS ComCredito,
			CHAR(4) AS ComPago,
			CHAR(4) AS ComDeposito, 
			CHAR(1) AS ConcEjec,
			char(4) AS ComSaldoDebito,				-- Comision por consulta de Saldo de Débito 
			char(4) AS ComSaldoCredito,				-- Comision por consulta de Saldo de Crédito 
			char(4) AS ComDisposicionDebito,		-- Comision por disposición de Débito
			char(4) AS ComDisposicionCredito, 		-- Comision por disposición de Crédito
			char(4) AS ComTranferenciaEfectiva,		-- Comisión Transferencia entre Ctas Efectivas
			char(4) AS ComPagTDCBCPLCargEfectiva,	-- Comisión Pago de TDC BCPL cargo a cta Efectiva
			char(4) AS ComPagTDCOtroCargEfectiva, 	-- Comisión Pago de TDC Otro cargo a cta Efectiva
			char(4) AS ComPagTDCOtroEfectivo,		-- Comisión Pago de TDC Otro pago efectivo
			char(4) AS ComTransferencia; 			-- Comisión por transferencia 

--***********************************************************************************************************
-- DESCRIPCION: Realiza cambios en parametros de conciliacion reingenieria hechos por usuario.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/11/12
-- BD: bditarjeta
-- SISTEMA : Conciliacion Reingenieria
--***********************************************************************************************************

DEFINE vsComDebito				CHAR(4);
DEFINE vsComCredito				CHAR(4);
DEFINE vsComPago				CHAR(4);
DEFINE vsComDeposito			CHAR(4);
DEFINE vsConcEjec				CHAR(1);

DEFINE vsComSaldoDebito			char(4);				-- Comision por consulta de Saldo de Débito 
DEFINE vsComSaldoCredito		char(4);				-- Comision por consulta de Saldo de Crédito 
DEFINE vsComDisposicionDebito 	char(4);				-- Comision por disposición de Débito
DEFINE vsComDisposicionCredito  char(4);		 		-- Comision por disposición de Crédito
DEFINE vsComTranferenciaEfectiva char(4);				-- Comisión Transferencia entre Ctas Efectivas
DEFINE vsComPagTDCBCPLCargEfectiva char(4);				-- Comisión Pago de TDC BCPL cargo a cta Efectiva
DEFINE vsComPagTDCOtroCargEfectiva char(4);			 	-- Comisión Pago de TDC Otro cargo a cta Efectiva
DEFINE vsComPagTDCOtroEfectivo	char(4);				-- Comisión Pago de TDC Otro pago efectivo
DEFINE vsComTransferencia 		char(4); 				-- Comisión por transferencia 

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET vsComDebito = "";
LET vsComCredito = "";
LET vsComPago = "";
LET vsComDeposito = "";
LET vsConcEjec = "";

LET vsComSaldoDebito = '';	
LET vsComSaldoCredito = '';
LET vsComDisposicionDebito = '';
LET vsComDisposicionCredito = '';
LET vsComTranferenciaEfectiva = '';
LET vsComPagTDCBCPLCargEfectiva  = '';
LET vsComPagTDCOtroCargEfectiva  = ''; 
LET vsComPagTDCOtroEfectivo	= '';
LET vsComTransferencia 	= '';

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_concreing_maparopecr.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
			RETURN 	
			vsCodRet,
			NVL(vsComDebito,''),
			NVL(vsComCredito,''),
			NVL(vsComPago,''), 
			NVL(vsComDeposito,''),
			NVL(vsConcEjec,''),
			NVL(vsComSaldoDebito,''),	
			NVL(vsComSaldoCredito,''),
			NVL(vsComDisposicionDebito,''),
			NVL(vsComDisposicionCredito,''),
			NVL(vsComTranferenciaEfectiva,''), 
			NVL(vsComPagTDCBCPLCargEfectiva,''),
			NVL(vsComPagTDCOtroCargEfectiva,''),
			NVL(vsComPagTDCOtroEfectivo,''),
			NVL(vsComTransferencia,'');
	END IF;
END EXCEPTION;

--Consulta valores de parametros operativos.
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComCredito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '301';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComDebito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '302';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComPago FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '303';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComDeposito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '304';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsConcEjec FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '001';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComSaldoDebito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '311';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComSaldoCredito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '312';

	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComDisposicionDebito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '313';	
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComDisposicionCredito FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '314';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComTranferenciaEfectiva FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '315';

	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComPagTDCBCPLCargEfectiva FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '316';

	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComPagTDCOtroCargEfectiva FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '317';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComPagTDCOtroEfectivo FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '318';
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor INTO vsComTransferencia FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '305';
	
	
	
	
IF(psFlag = "1")THEN  -- Se manda con este valor para solo recuperar parametros 
	
	RETURN 	
			vsCodRet,
			NVL(vsComDebito,''),
			NVL(vsComCredito,''),
			NVL(vsComPago,''), 
			NVL(vsComDeposito,''),
			NVL(vsConcEjec,''),
			NVL(vsComSaldoDebito,''),	
			NVL(vsComSaldoCredito,''),
			NVL(vsComDisposicionDebito,''),
			NVL(vsComDisposicionCredito,''),
			NVL(vsComTranferenciaEfectiva,''), 
			NVL(vsComPagTDCBCPLCargEfectiva,''),
			NVL(vsComPagTDCOtroCargEfectiva,''),
			NVL(vsComPagTDCOtroEfectivo,''),
			NVL(vsComTransferencia,'');
			
--Actualiza valores de parametros operativos.
elif (psFlag = "2")THEN -- Se manda con este valor cuando hay que actualizar datos y hacer registro en la Botacora de la actualizacion realizada 
	
	IF (psComCredito != vsComCredito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComCredito WHERE codigo = '301';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION CREDITO INTERREDES (ACI-C):'||TRIM(vsComCredito)||' A '||TRIM(psComCredito), psUsuario) INTO vsCodRet;
	END IF;
	IF (psComDebito != vsComDebito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComDebito WHERE codigo = '302';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION DEBITO INTERREDES (ACI-D):'||TRIM(vsComDebito)||' A '||TRIM(psComDebito), psUsuario) INTO vsCodRet;
	END IF;
	IF (psComPago != vsComPago) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComPago WHERE codigo = '303';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION PAGO CORRESPONSAL (ACC-C):'||TRIM(vsComPago)||' A '||TRIM(psComPago), psUsuario) INTO vsCodRet;
	END IF;
	IF (psComDeposito != vsComDeposito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComDeposito WHERE codigo = '304';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION DEP. CORRESPONSAL (ACC-D):'||TRIM(vsComDeposito)||' A '||TRIM(psComDeposito), psUsuario) INTO vsCodRet;
	END IF;
	IF (psConcEjec != vsConcEjec) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psConcEjec WHERE codigo = '001';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO CONCILIACION EN EJECUCION DE: '||TRIM(vsConcEjec)||' -> '||TRIM(psConcEjec), psUsuario) INTO vsCodRet;
	END IF;
	
	IF (psComSaldoDebito != vsComSaldoDebito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComSaldoDebito WHERE codigo = '311';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION CONSULTA SALDO DEBITO: '||TRIM(vsComSaldoDebito)||' -> '||TRIM(psComSaldoDebito), psUsuario) INTO vsCodRet;		
	END IF;

	IF (psComSaldoCredito != vsComSaldoCredito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComSaldoCredito WHERE codigo = '312';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION CONSULTA SALDO CREDITO: '||TRIM(vsComSaldoCredito)||' -> '||TRIM(psComSaldoCredito), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComDisposicionDebito != vsComDisposicionDebito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComDisposicionDebito WHERE codigo = '313';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION DISPOSICION DE EFECTIVA: '||TRIM(vsComDisposicionDebito)||' -> '||TRIM(psComDisposicionDebito), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComDisposicionCredito != vsComDisposicionCredito) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComDisposicionCredito WHERE codigo = '314';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION DISPOCION DE TDC BCPL VISA: '||TRIM(vsComDisposicionCredito)||' -> '||TRIM(psComDisposicionCredito), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComTranferenciaEfectiva != vsComTranferenciaEfectiva) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComTranferenciaEfectiva WHERE codigo = '315';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION TRANSFERENCIA EN CTAS EFECTIVAS: '||TRIM(vsComTranferenciaEfectiva)||' -> '||TRIM(psComTranferenciaEfectiva), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComPagTDCBCPLCargEfectiva != vsComPagTDCBCPLCargEfectiva) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComPagTDCBCPLCargEfectiva WHERE codigo = '316';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION PAGO DE TDC BCPL CARGO EFECTIVA:  '||TRIM(vsComPagTDCBCPLCargEfectiva)||' -> '||TRIM(psComPagTDCBCPLCargEfectiva), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComPagTDCOtroCargEfectiva != vsComPagTDCOtroCargEfectiva) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComPagTDCOtroCargEfectiva WHERE codigo = '317';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION PAGO DE TDC OTRO CARGO EFECTIVA: '||TRIM(vsComPagTDCOtroCargEfectiva)||' -> '||TRIM(psComPagTDCOtroCargEfectiva), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComPagTDCOtroEfectivo != vsComPagTDCOtroEfectivo) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComPagTDCOtroEfectivo WHERE codigo = '318';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION PAGO DE TDC OTRO EFECTIVO: '||TRIM(vsComPagTDCOtroEfectivo)||' -> '||TRIM(psComPagTDCOtroEfectivo), psUsuario) INTO vsCodRet;	
	END IF;

	IF (psComTransferencia != vsComTransferencia) THEN 
		UPDATE bditarjeta:"informix".td_param_conciliacion_concreing SET valor = psComTransferencia WHERE codigo = '305';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora (41, 'MODIFICO COMISION CONSULTA SALDO CREDITO: '||TRIM(psComTransferencia)||' -> '||TRIM(psComSaldoCredito), psUsuario) INTO vsCodRet;	
	END IF;
	
	let vsComDebito = psComDebito;
	let vsComCredito = psComCredito;
	let vsComPago = psComPago;
	let vsComDeposito = psComDeposito;
	let vsConcEjec = psConcEjec;
	let vsComSaldoDebito = psComSaldoDebito;
	let vsComSaldoCredito = psComSaldoCredito;
	let vsComDisposicionDebito = psComDisposicionDebito;
	let vsComDisposicionCredito = psComDisposicionCredito;
	let vsComTranferenciaEfectiva = psComTranferenciaEfectiva;
	let vsComPagTDCBCPLCargEfectiva = psComPagTDCBCPLCargEfectiva;
	let vsComPagTDCOtroCargEfectiva = psComPagTDCOtroCargEfectiva;
	let vsComPagTDCOtroEfectivo = psComPagTDCOtroEfectivo;
	let vsComTransferencia = psComTransferencia;
	
	RETURN 	
			vsCodRet,
			NVL(vsComDebito,''),
			NVL(vsComCredito,''),
			NVL(vsComPago,''), 
			NVL(vsComDeposito,''),
			NVL(vsConcEjec,''),
			NVL(vsComSaldoDebito,''),	
			NVL(vsComSaldoCredito,''),
			NVL(vsComDisposicionDebito,''),
			NVL(vsComDisposicionCredito,''),
			NVL(vsComTranferenciaEfectiva,''), 
			NVL(vsComPagTDCBCPLCargEfectiva,''),
			NVL(vsComPagTDCOtroCargEfectiva,''),
			NVL(vsComPagTDCOtroEfectivo,''),
			NVL(vsComTransferencia,'');
END IF;
	

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'Descripcion: Realiza cambios en parametros de conciliacion reingenieria hechos por usuario.',
'Fecha: 2011/11/12',
'Version: 20111112.1800',
'BD: bditarjeta',
'',
'AUTOR: JUAN FCO. PONCE DAMIAN',
'Proyecto: Conciliacion Reingenieria',
'Solicito: Luis Gomez',
'MODIFICACION: Se agregaron validaciones para que solo guarde los parametros que se modificaron.',
'Fecha: 2012/08/02',
'Version: 20120802.1700',
'BD: bditarjeta',
'',
'MODIFICO: L.I.A Ricardo Resendiz Martinez',
'Proyecto: Conciliacion Nuevas transacciones Corresponsales',
'Solicito: Jose Luis Puebla',
'MODIFICACION: Se agrega nuevas comisiones a contempla asi como ciclo de validacion .',
'Fecha: 2015/09/02',
'Version: 20150902.2000',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_concreing_consultamovpendientes ( psCve_usuario CHAR(10), psFecha DATE )
	RETURNING CHAR (5) AS Retorno, 
	INTEGER AS Consecutivo,
	CHAR(23) AS NombreArchivo,
	CHAR(3) AS ArchivoOrigen,
	CHAR(1) AS Integridad,
	CHAR(20) AS IntegridadError,
	CHAR(16) AS NumTarjeta,
	CHAR(6) AS Secuencia,
	CHAR(9) AS IdComercio325,
	CHAR(30) AS NomComercio325,
	CHAR(23) AS Referencia23_325,
	CHAR(13) AS Monto ,
	CHAR(15) as Rfc325,
	CHAR(3) AS Divisa325,
	CHAR(13) AS MontoCashBack ,
	CHAR(1) AS Conciliacion ,
	INTEGER AS TipoConciliacion,
	CHAR(15) AS SecuenciaExtendida,
	MONEY(16,2) AS MontoIntercard,
	CHAR(1) AS MovConciliado ,
	CHAR(1) AS MovReversado ,
	CHAR(1) AS Aplicacion ,
	CHAR(16) AS FolioAplica ,
	CHAR(5) AS CodigoRetorno,
	CHAR(15) AS TipoTransaccion325,
	CHAR(13) AS Monto325,
	CHAR(1) AS BanderaProceso;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  CONSULTA DE MOVIMIENTOS PENDIENTES  ------------------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/10/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	*****************************************************************************************************
	-- Modificado: Juan Fco. Ponce Damian 
	-- fecha : 06/09/2013
	-- Descripción: Se modificaron todos las consultas para retornar el Monto de Cash Back.
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsErrorIntegridad CHAR(20);
	DEFINE vsErrorActividad	CHAR(250);
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	DEFINE viErrores INTEGER;
	
	DEFINE viConsecutivo INTEGER;
	DEFINE vsNombreArchivo CHAR(23);
	DEFINE vsArchivoOrigen CHAR(3);
	DEFINE vsIntegridad CHAR(1);
	DEFINE vsIntegridadError CHAR(20);
	DEFINE vsNumTarjeta CHAR(16);
	DEFINE vsSecuencia CHAR(6);
	DEFINE vsIdComercio325 CHAR(9);
	DEFINE vsNomComercio325 CHAR(30);
	DEFINE vsReferencia23_325 CHAR(23);
	DEFINE vsMonto CHAR(13);
	DEFINE vsRfc325 CHAR(15);
	DEFINE vsDivisa325 CHAR(3);
	DEFINE vmMontoCashBack CHAR(13);
	DEFINE vsConciliacion CHAR(1);
	DEFINE viTipoConciliacion INTEGER;
	DEFINE vsSecuenciaExtendida CHAR(15);
	DEFINE vmMontoIntercard MONEY(16,2);
	DEFINE vsMovConciliado CHAR(1);
	DEFINE vsMovReversado CHAR(1);
	DEFINE vsAplicacion CHAR(1);
	DEFINE vsFolioAplica CHAR(16);
	DEFINE vsCodigoRetorno CHAR(5);
	
	DEFINE vsTipotransaccion325 CHAR(15);
	DEFINE vsMonto325 CHAR(13);
	DEFINE vsBanderaProceso CHAR(1);
	/* INICIALIZACION DE VARIABLES */

	LET vsIntegridad = '';
	LET vsErrorIntegridad = '';
	LET vsErrorActividad = '';
	
	LET  vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 40;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	LET viErrores = 0;
	
	LET viConsecutivo = 0;
	LET vsNombreArchivo ='';
	LET vsArchivoOrigen ='';
	LET vsIntegridad ='';
	LET vsIntegridadError ='';
	LET vsNumTarjeta ='';
	LET vsSecuencia ='';
	LET vsIdComercio325 = "";
	LET vsNomComercio325 = "";
	LET vsReferencia23_325 = "";
	LET vsMonto ='';
	LET vsRfc325 ='';
	LET vsDivisa325 ='';
	LET vmMontoCashBack ='';
	LET vsConciliacion ='';
	LET viTipoConciliacion =0;
	LET vsSecuenciaExtendida ='';
	LET vmMontoIntercard =0.0;
	LET vsMovConciliado ='';
	LET vsMovReversado ='';
	LET vsAplicacion ='';
	LET vsFolioAplica ='';
	LET vsCodigoRetorno = '';
	LET vsBanderaProceso = '';
	
	LET vsTipotransaccion325 = '';
	LET vsMonto325 = '';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || NVL(vssqlerr,'') ||' ISAM '|| NVL(isam_err,0) ||' INFORMIX '||TRIM(NVL(error_info,'')) || ' EN sp_concreing_consultamovpendientes';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
			

		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,''),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'');

	END EXCEPTION;

--SET DEBUG FILE TO '/informix/HomeInformix/rrm/movpen.txt';
--TRACE ON;

	--REINGENIERIA-CONCILIACION-AUTOMATICA---------
	--2011/10/24-ING-ALFONSO-CRUZ------------------

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		--CONSULTA QUE SE TRAE LOS REGISTROS PENDIENTES
		
	IF psCve_usuario NOT IN (SELECT cve_usuario 
	                         FROM   bditarjeta:"informix".td_usuarios_conciliacion
                             WHERE  activo = 'V' AND operacion = 'V' AND monitoreo = 'V' )  THEN -- Usuarios con capacidad de modificar registros a su criterio
	
		-- Se mantienen registros de todos los archivos 
		FOREACH 
			SELECT consecutivo, nombrearchivo, archivo_origen, 
				integridad, 
				integridad_error, numtarjeta, secuencia325, idcomercio325, 
				REPLACE (REPLACE (nomcomercio325,"'", " "),'"' , ' '), 
				referencia23_325,
				monto325, rfc325, divisa325, montocashback325, 
				/*replace(conciliacion, 'P', 'F')*/conciliacion, tipo_conciliacion,
				secuencia_extendida, montointercard, movconciliado, movreversado, aplicacion/*replace(aplicacion,'P','F')*/, folio_mov,
				cod_retorno, tipotransaccion325, monto325, bandera_proceso 
				INTO viConsecutivo, 
				 vsNombreArchivo, vsArchivoOrigen, vsIntegridad, vsIntegridadError, vsNumTarjeta, vsSecuencia,
				 vsIdComercio325, vsNomComercio325, 
				 vsReferencia23_325, vsMonto, vsRfc325, vsDivisa325, vmMontoCashBack,
				 vsConciliacion, viTipoConciliacion, vsSecuenciaExtendida, vmMontoIntercard, vsMovConciliado, vsMovReversado,
				 vsAplicacion, vsFolioAplica, vsCodigoRetorno, vsTipotransaccion325, vsMonto325, vsBanderaProceso
				FROM bditarjeta:td_movimientos_conciliacion	
				WHERE (integridad='F' OR conciliacion = 'F'	OR aplicacion =  'F') 
					   and nombrearchivo in (SELECT nombrearchivo 
											 FROM bditarjeta:td_archivos_conciliacion  
											 WHERE fecha_archivo = psFecha)
			
			IF ((vsSecuencia IS NULL)OR(TRIM(vsSecuencia) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,''),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'')
			WITH RESUME;
			
		END FOREACH;
	ELSE
		FOREACH 
			SELECT consecutivo, nombrearchivo, archivo_origen, 
				--REPLACE (REPLACE (integridad,'P', 'F'),'V', 'F'), -- Cambia para poder reprocesar los registros con aplicacion en P
				integridad, -- Cambia para poder reprocesar los registros con aplicacion en P
				integridad_error, numtarjeta, secuencia325, idcomercio325, 
				REPLACE (REPLACE (nomcomercio325,"'", " "),'"' , ' '), 
				referencia23_325,
				monto325, rfc325, divisa325, montocashback325, 
				conciliacion/*replace(conciliacion, 'P', 'F')*/, tipo_conciliacion,
				secuencia_extendida, montointercard, movconciliado, movreversado, aplicacion/*replace(aplicacion,'P','F')*/, folio_mov,
				cod_retorno, tipotransaccion325, monto325, bandera_proceso 
				INTO viConsecutivo, 
				 vsNombreArchivo, vsArchivoOrigen, vsIntegridad, vsIntegridadError, vsNumTarjeta, vsSecuencia,
				 vsIdComercio325, vsNomComercio325, 
				 vsReferencia23_325, vsMonto, vsRfc325, vsDivisa325, vmMontoCashBack,
				 vsConciliacion, viTipoConciliacion, vsSecuenciaExtendida, vmMontoIntercard, vsMovConciliado, vsMovReversado,
				 vsAplicacion, vsFolioAplica, vsCodigoRetorno, vsTipotransaccion325, vsMonto325, vsBanderaProceso
				FROM bditarjeta:td_movimientos_conciliacion	
				WHERE (integridad='F' OR conciliacion = 'F'	OR aplicacion <> 'V') -- Se mostrar los registros hasta que estos sean reprocesados por el cron 3
					   and nombrearchivo in (SELECT nombrearchivo 
											 FROM bditarjeta:td_archivos_conciliacion  
											 WHERE fecha_archivo = psFecha)
					   and archivo_origen in ('VNC', 'VND', 'VID', 'VIC','MCC', 'MCD')
			
			IF ((vsSecuencia IS NULL)OR(TRIM(vsSecuencia) ='' ) ) THEN
				LET viErrores = viErrores + 1;
			END IF;
				
		RETURN NVL(vssqlerr,''), 
			NVL(viConsecutivo,0),
			NVL(vsNombreArchivo,''),
			NVL(vsArchivoOrigen,''),
			NVL(vsIntegridad,''),
			NVL(vsIntegridadError,''),
			NVL(vsNumTarjeta,''),
			NVL(vsSecuencia,''),
			NVL(vsIdComercio325,''),
			NVL(vsNomComercio325,''),
			NVL(vsReferencia23_325,''),
			NVL(vsMonto,''),
			nvl(vsRfc325,''),
			nvl(vsDivisa325,''),
			NVL(vmMontoCashBack,''),
			NVL(vsConciliacion,''),
			NVL(viTipoConciliacion,0),
			NVL(vsSecuenciaExtendida,''),
			NVL(vmMontoIntercard,''),
			NVL(vsMovConciliado,''),
			NVL(vsMovReversado,''),
			NVL(vsAplicacion,''),
			NVL(vsFolioAplica,''),
			NVL(vsCodigoRetorno,''),
			NVL(vsTipotransaccion325,''),
			NVL(vsMonto325,''),
			NVL(vsBanderaProceso,'')
			WITH RESUME;
			
		END FOREACH;
	END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: CONSULTA MOVIMIENTOS PENDIENTES.',
'Fecha: 2011/10/24',
'Version: 20111024.1712',
'BD: bditarjeta',
'',
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGA CAMPO BANDERA PROCESO.',
'Fecha: 2011/11/24',
'Version: 20111124.1712',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 40.',
'Fecha: 2012/08/03',
'Version: 20120803.1555',
'BD: BdiTarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA EXTRACCION DE DATOS PARA OMITIR CARACTERES ESPECIALES EN EL NOMRE DEL COMERCIO.',
'Fecha: 2012/10/23',
'Version: 20121023.1036',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez ',
'Descripcion: Se agrega IF para tener consulta de usuario especial y resto de los usuarios de sistema.',
'Fecha: 2012/11/08',
'Version: 20121108',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martinez',
'Proyecto: Perfiles para modificacion de devoluciones no aplicadas',
'Solicito: Evelio Chaparro Garcia ',
'Descripcion: Se agregaron usuarios especificos para que pueda modificar devoluciones no aplicadas por regla de negocio ',
'Fecha: 2013/02/20',
'Version: 20130220.2030',
'BD: BdiTarjeta',
'',
'MODIFICACION: Juan Francisco Ponce ',
'Proyecto: Se integra recuperación de monto cashback325 ',
'Solicito: Luis Antonio Gomez Santiago ',
'Descripcion: Se modifica seleccion para poder recuperar datos MontoCashBack325 en lugar de montosurcharge325',
'Fecha: 2013/09/06',
'Version: 20130906.1445',
'BD: BdiTarjeta',
'',
'MODIFICACION: Ricardo Reséndiz Martínez',
'Proyecto: Proyecto Master Card Integración ',
'Solicito: Luis Antonio Gomez Santiago ',
'Descripcion: Se integran archivos MCD y MCC para el proceso de revalidacion por integridad',
'Fecha: 2014/03/10',
'Version: 20140310.1400',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Reséndiz Martínez',
'Proyecto: Proyecto de Migracion de SIF a SOC  ',
'Solicito: Jose Luis Puebla  ',
'Descripcion: Se modifica para que muestre registros conforme a nuevo esquemas de trabajo en SOC ',
'Fecha: 2015/10/10',
'Version: 20151010.1400',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_actualizarepositoriosparam ( 
psCve_usuario CHAR(10) ,
psArchivoOrigen CHAR(3),
psRep_Win VARCHAR(50),
psRep_Aix VARCHAR(50),
psHistorico VARCHAR(90),
psDiasBitacora VARCHAR(90),
psDiasMovimientos VARCHAR(90),
psDiasArchivosAIX VARCHAR(90),
piFicha INTEGER
)
	RETURNING CHAR (5) AS Retorno;
	
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  ACTUALIZA REPOSITORIOS Y DIAS DE DEPURACION  ---------------------------------------
	-- AUTOR : Ing. Alfonso Cruz  -----------------------------------------------------------------------
	-- FECHA : 24/11/2011  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Reingenieria de la conciliacion automatica  --------------------------------------------
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/

	/*VARIABLES DE ERRORES*/
	DEFINE vsRetBitacora CHAR(5);
	
	DEFINE vsActividad VARCHAR(150);
	DEFINE viElemento INTEGER;

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE isam_err INT ;
	DEFINE error_info CHAR(70) ;
	
	DEFINE vsCodigoRetorno CHAR(5);

	/* INICIALIZACION DE VARIABLES */

	LET vsRetBitacora = '';
	
	LET vsActividad = '';
	LET viElemento = 45;
	
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET isam_err = 0 ;
	LET error_info = '' ;
	
	LET vsCodigoRetorno = '00000';
	
	BEGIN

	ON EXCEPTION SET viCodigo,isam_err,error_info   --cacha el error en caso de que exista y regresa un valor predeterminado
		LET vssqlerr = viCodigo;
		LET vsActividad = 'ERROR ' || vssqlerr ||' ISAM '|| isam_err ||' INFORMIX '||error_info || ' EN sp_concreing_ActualizaRepositoriosParam';
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN 	NVL(vssqlerr,'');

	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/soporte/concreing/TraceActualizaRepositoriosParam.sql';
	--SET DEBUG FILE TO '/tmp/conciliacion/TraceCONSULTAREPOSITORIOS.txt';
	--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		
		IF (piFicha == 1) THEN 
			UPDATE bditarjeta:"informix".td_archivo_origenTMP
			SET     rep_aix = TRIM(psRep_Aix), 
                    rep_win = TRIM(psRep_Win)
			WHERE archivo_origen = psArchivoOrigen;

            UPDATE bditarjeta:"informix".td_archivo_origen
			SET     rep_aix = TRIM(psRep_Aix), 
                    rep_win = TRIM(psRep_Win)
			WHERE archivo_origen = psArchivoOrigen;

			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = TRIM(psHistorico)
			WHERE codigo = '401';
			
			LET vsActividad = 'SE ACTUALIZAN LAS RUTAS DE LOS REPOSITORIOS PARA EL ARCHIVO [' || psArchivoOrigen || ']';
			
		ELIF (piFicha == 2) THEN 
		
			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = psDiasBitacora
			WHERE codigo = '402';
			
			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = psDiasMovimientos
			WHERE codigo = '403';
			
			UPDATE bditarjeta:"informix".td_param_conciliacion_concreing
			SET valor = psDiasArchivosAIX
			WHERE codigo = '404';
			
			LET vsActividad = 'SE ACTUALIZAN LOS DÍAS DE DEPURACIÓN DE LAS TABLAS DEL PROCESO DE CONCILIACIÓN';
			
		END IF;
		
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora(viElemento,vsActividad,psCve_usuario) INTO vsRetBitacora;
		
		RETURN vsCodigoRetorno;
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ing. Alfonso Cruz',
'Proyecto: Reingenieria de la Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: ACTUALIZA REPOSITORIOS Y DIAS DE DEPURACION.',
'Fecha: 2011/11/24',
'Version: 20111124.1102',
'BD: bditarjeta',
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIA EL ELEMENTO DE IDENTIFICACION DEL SISTEMA DE 8 A 45.',
'Fecha: 2012/08/06',
'Version: 20120806.1435',
'BD: BdiTarjeta',
'',
'MODIFICACION: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Migracion de SIF a SOC ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrega opcion de actualizar tambien la tabla de Catalogo principal ademas de la temporal',
'Fecha: 2012/08/06',
'Version: 20120806.1435',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_conarchivodetalle_con(
														cTipo char(1),
														cTipoCon varchar(3),
														cNombreArchivo varchar(23),
														cNumEmpl varchar(9)
													)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
    char(23) as nombrearchivo,
    char(3) as archivo_origen,       
    datetime year to fraction(3) as  fechacarga,
    char(1) as integridad,
    char(16) as numtarjeta,    
    char(6) as secuencia325,     
    char(13) as monto325,     
    char(13) as montocashback325,
    char(20) as numcuenta,     
    char(9) as idcomercio325,     
    char(30) as nomcomercio325,     
    char(15) as tipotransaccion325 


	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	
	
	DEFINE vNombrearchivo char(23);
    DEFINE vArchivo_origen char(3);    
    DEFINE vFechacarga datetime year to fraction(3);    
    DEFINE vIntegridad char(1);
    DEFINE vNumtarjeta char(16);    
    DEFINE vSecuencia325 char(6);    
    DEFINE vMonto325 char(13);    
    DEFINE vmontocashback325 char(13);    
    DEFINE vNumcuenta char(20);    
    DEFINE vIdcomercio325 char(9);    
    DEFINE vNomcomercio325 char(30);    
    DEFINE vTipotransaccion325 char(15);
	
	
	LET vNombrearchivo = '';
    LET vArchivo_origen = '';
    LET vFechacarga  = '1900-01-01 00:00:00';    
    LET vIntegridad = '';
    LET vNumtarjeta = '';
    LET vSecuencia325 = '';
    LET vMonto325 = '';
    LET vmontocashback325 = '';
    LET vNumcuenta = '';
    LET vIdcomercio325 = '';
    LET vNomcomercio325 = '';
    LET vTipotransaccion325 = '';
		

	
	--SET DEBUG FILE TO "/tmp/manuel/ejemplo_consarc";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('9','Error en sp_conarchivodetalle_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;

     RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Consulta de Detalle de Archivos de Conciliación
--************************************************************
-- Modificado: Juan Fco. Ponce Damian 
-- fecha : 06/09/2013
-- Descripción: Se modificaron todos las consultas para retornar el Monto de Cash Back.
--************************************************************
-- Modificado: L.I.A. Ricardo Resendiz Martinez
-- fecha : 18/09/2015
-- Descripción: Se modifica consulta para que busque por la clave del tipo de conciliación. Se redujeron de 60 a 3 el cTipoCon
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
   IF (cTipo == 'A') THEN --Todos los Registros
		FOREACH			
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion 	
			WHERE nombrearchivo = trim(cNombreArchivo)
														
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;
	ELIF (cTipo == 'B') THEN --Error de Integridad
		FOREACH		
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion 	
			WHERE nombrearchivo = trim(cNombreArchivo) AND integridad = 'F'
														
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;		
	ELIF (cTipo == 'C') THEN --Error de Integridad
		FOREACH		
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE nombrearchivo = trim(cNombreArchivo) AND 
				  --tipo_conciliacion = (select tipo_conciliacion from bditarjeta:td_tipo_conciliacion  where desc_conciliacion =trim (cTipoCon))			
				  tipo_conciliacion = cTipoCon
				  
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;
	ELIF (cTipo == 'D') THEN --Error de Integridad
		FOREACH		
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'F' AND integridad = 'V' AND conciliacion = 'V'
								
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;		
	ELIF (cTipo == 'E') THEN --Error de Integridad
		FOREACH		
			SELECT nombrearchivo,archivo_origen,fechacarga,integridad,numtarjeta,secuencia325,
				   monto325,montocashback325,numcuenta,idcomercio325,nomcomercio325,tipotransaccion325
			INTO   vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE nombrearchivo = trim(cNombreArchivo) AND aplicacion = 'V' 
								
			RETURN P_COD_RET,P_MENSAJE, vNombrearchivo,vArchivo_origen,vFechacarga,vIntegridad,vNumtarjeta,vSecuencia325,vMonto325,
				   vmontocashback325,vNumcuenta,vIdcomercio325,vNomcomercio325,vTipotransaccion325	with resume;	
								
		END FOREACH;			
	END IF;

      
END;
END PROCEDURE;