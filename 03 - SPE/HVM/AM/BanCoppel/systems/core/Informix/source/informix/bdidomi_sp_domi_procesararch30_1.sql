CREATE PROCEDURE "informix".sp_domi_procesararch30_1(pNom_Arch CHAR(20),pNom_Arch31 CHAR(20),pNom_Arch32 CHAR(20),pUsuario CHAR(8),vRango1 INTEGER,vRango2 INTEGER,pApuntador INTEGER)
	RETURNING CHAR(5);

	--	Definicion de variables.
	DEFINE dFecha_hoy							DATE;
	DEFINE dFechaManana							DATE;
	DEFINE iExiste								INTEGER;
	DEFINE iNumRechazos							INTEGER;
	DEFINE vNumSecuencia						INTEGER;
	DEFINE iSQLerr								INTEGER;
	DEFINE iSecuencia							INTEGER;
	DEFINE iMaximoRechazosPermitidos			INTEGER;
	DEFINE iAplicoCargo							INTEGER;
	DEFINE iContadorRepetidas					INTEGER;
	DEFINE cFisica								CHAR(1);
	DEFINE cEstatus								CHAR(1);
	DEFINE cEstatusCtaCargo						CHAR(1);
	DEFINE cSecuenciaAux						CHAR(7);

	DEFINE cStatusTar							CHAR(1);
	DEFINE cTipo_tarjeta						CHAR(1);
	DEFINE cEstatusAutorizacion					CHAR(2);
	DEFINE cBancoPresentador					CHAR(3);
	DEFINE cBancoReceptor   					CHAR(3);
	DEFINE cClaVeBancaria						CHAR(3);
	DEFINE cSucursalContable					CHAR(4);
	DEFINE cTransaccCargo						CHAR(4);
	DEFINE cTranRet								CHAR(4);
	DEFINE cTransaccAbono						CHAR(4);
	DEFINE cProductoCtaCargo					CHAR(4);
	
	DEFINE cCodRet								CHAR(5);
	DEFINE cCodRetMensaje						CHAR(5);
	DEFINE cSecuencia							CHAR(7);
	DEFINE cFechaTrans							CHAR(8);
	DEFINE cFechaFormat							CHAR(10);
	DEFINE cNum_cte								CHAR(20);
	DEFINE cNumeroFolioCargo					CHAR(16);
	DEFINE cNumeroFolioAbono					CHAR(16);
	DEFINE cNum_Tarjeta							CHAR(16);
	DEFINE cRFCrecibido							CHAR(18);
	DEFINE cRFCOrdenante						CHAR(18);
	DEFINE cCuentaCargo							CHAR(20);
	DEFINE cCuentaAbono							CHAR(20);
	DEFINE cCuentaOrd							CHAR(20);
	DEFINE cCve_proceso							CHAR(20);
	DEFINE cClabeoTarjeta						CHAR(20);
	DEFINE cValTarjeta							CHAR(20);
	DEFINE cValTarjNuevo						CHAR(20);
	DEFINE cReferenciaServicio					CHAR(20);
	DEFINE cNombreTitular						CHAR(40);
	DEFINE cDescripcionProceso					CHAR(50);
	DEFINE cListaProductosPermitidos			CHAR(100);
	DEFINE cMensaje								CHAR(200);
	DEFINE mSaldoAPagar							MONEY(16,2);
	DEFINE mSaldoActual							MONEY(16,2);
	DEFINE mSdoDisp								MONEY(16,2);
	DEFINE mMontoRet							MONEY(16,2);
	DEFINE mImp_maximo							MONEY(16,2);
	DEFINE d_Fech_prox							DATE;
	DEFINE cFecha_trans							CHAR(8);
	DEFINE cFecha_aplica						CHAR(8);
	DEFINE cTpoCuenta_Cargo                     CHAR(2);	
	DEFINE cClabeCancel                         CHAR(20);	
	DEFINE cRefServCancel                       CHAR(40);	
	DEFINE cCuentaCargoCancel                   CHAR(20);	
	DEFINE cTarjetaCargoCancel                  CHAR(20);	
	DEFINE cCuentaRec							CHAR(20);	
	DEFINE cRefServComp                         CHAR(40);	--	Cacha algun posible error no contralado.
	DEFINE vnumcte								CHAR(20);
	DEFINE cursor3                              CHAR(50);
	DEFINE cursor4                              CHAR(50);
	DEFINE vNumSecuencia1                       INTEGER;
	DEFINE vEstatus_cve							CHAR(2);
	DEFINE vtransaccion                         INTEGER;
	DEFINE vsNomProceso 			            CHAR(20);
	DEFINE vsDescripcionProceso 	            CHAR(60);
	DEFINE iExisteProc							INTEGER;	
    DEFINE vCuenta								INTEGER;
	DEFINE vTipo_registro                       CHAR(2);
	DEFINE vCod_divisa                          CHAR(2);
	DEFINE vImporte								CHAR(15);
	DEFINE vUso_futuro_ccen                     CHAR(16);
	DEFINE vTipo_operacion                      CHAR(2);
	DEFINE vFecha_aplica                        CHAR(8);
	DEFINE vTipo_cta_ord                        CHAR(2);
	DEFINE vNum_cta_ord                         CHAR(20);
	DEFINE vNombre_ord							CHAR(40);
	DEFINE vRfc_ord                             CHAR(18);
	DEFINE vTipo_cta_rec                        CHAR(2);
	DEFINE vNum_cta_rec                         CHAR(20);
	DEFINE vNombre_rec                          CHAR(40);
	DEFINE vRfc_rec                             CHAR(18);
	DEFINE vRef_servicio                        CHAR(40);
	DEFINE vNombre_titular_serv                 CHAR(40);
	DEFINE vImporte_iva                         CHAR(15);
	DEFINE vRef_numerica                        CHAR(7);
	DEFINE vRef_leyenda                         CHAR(40);
	DEFINE vClave_rastreo                       CHAR(30);
	DEFINE vFecha_pres_ini                      CHAR(8);
	DEFINE vUso_futuro_banco                    CHAR(12);
	DEFINE vFolio_suc                           CHAR(16);
	DEFINE vUser_insert                         CHAR(8);
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	--RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    DEFINE mSdoActual    money(14,2);
    DEFINE mSdoRetenido  money(14,2);
    DEFINE mSdoCong      money(14,2);
    DEFINE mImpChqSbg    money(14,2);
    DEFINE mSaldoSbc     money(14,2);
	DEFINE iExistePend	 INTEGER;
	DEFINE cCod_err2     CHAR(5);	
    ON EXCEPTION SET iSQLerr
		IF iSQLerr <> 0 THEN
			LET cCodRet = iSQLerr;
			  EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', cCodRet, pUsuario, vsDescripcionProceso, TRIM(pNom_Arch) , 
			  YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
		 RETURN iSQLerr;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535, -255,-243)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
	
	ON EXCEPTION IN (-211, -242, -244, -311)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    

	--	Inicializacion de las variables.
	LET cFecha_trans = "";
	LET cFecha_aplica = "";
	LET cCodRet			  	= "00000";
	LET cCve_proceso		= "RECARCH_30." || SUBSTR(TRIM(pNom_Arch), 15, 2);
	LET cDescripcionProceso = "COBRO POR SERVICIO DE DOMICILIACION";
	
	LET cProductoCtaCargo	= "";
	LET cSucursalContable 	= "";
	LET cMensaje			= "";
	LET cNumeroFolioCargo	= "";
	LET dFecha_hoy			= "";
	LET cEstatus			= "";
	LET cClabeoTarjeta		= "";
	LET cClaVeBancaria		= "";
	LET cCodRetMensaje 		= "";
	LET cCuentaCargo		= "";
	LET cCuentaAbono 		= "";
	LET cTransaccCargo		= "";
	LET cTransaccAbono		= "";
	LET cTranRet			= "";
	
	LET cEstatusCtaCargo	= "";
	LET cFechaTrans			= "";
	LET cBancoPresentador	= "";
	LET cBancoReceptor		= "";
	LET cSecuencia			= "";
	LET cRFCrecibido		= "";
	LET cRFCOrdenante		= "";
	LET cFisica				= "";
	LET cReferenciaServicio = "";
	LET cNombreTitular		= "";
	LET cStatusTar			= "";
	LET cNum_Tarjeta		= "";
	LET cTipo_tarjeta		= "";
	LET cCuentaOrd			= "";
	LET cListaProductosPermitidos = "";
	LET iMaximoRechazosPermitidos = 0;
	LET vNumSecuencia	= pApuntador;
	LET iContadorRepetidas	= 0;
	LET iAplicoCargo		= 0;
	LET iExiste 		  	= 0;
	LET iSecuencia			= 0;
	LET iSQLerr				= 0;
	LET iNumRechazos		= 0;
	LET mSaldoAPagar 		= 0.00;
	LET mSdoDisp			= 0.00;
	LET mMontoRet			= 0.00;
	LET mImp_maximo			= 0.00;
	LET cSecuenciaAux		= "";
	LET cTpoCuenta_Cargo    = "";
	LET cClabeCancel        = "";
	LET cRefServCancel      = "";
	LET cCuentaCargoCancel  = "";
	LET cTarjetaCargoCancel = "";
	LET cCuentaRec          = "";
	LET cRefServComp        = "";
	LET vnumcte             = "";
	LET cursor3             = '';
	LET cursor4             = '';
	LET vNumSecuencia1      = 4000000;
	LET vEstatus_cve        = '';
	LET vtransaccion        = 0;
	LET vsNomProceso        = '';
	LET vsDescripcionProceso = '';
	LET iExisteProc         = 0;						   
    
	LET vTipo_registro       = ''; 
	LET vCod_divisa          = '';
	LET vImporte			 = '';
	LET vUso_futuro_ccen     = '';
	LET vTipo_operacion      = '';
	LET vFecha_aplica        = '';
	LET vTipo_cta_ord        = '';
	LET vNum_cta_ord         = '';
	LET vNombre_ord			 = '';
	LET vRfc_ord             = '';
	LET vTipo_cta_rec        = '';
	LET vNum_cta_rec         = '';
	LET vNombre_rec          = '';
	LET vRfc_rec             = '';
	LET vRef_servicio        = '';
	LET vNombre_titular_serv = '';
	LET vImporte_iva         = '';
	LET vRef_numerica        = '';
	LET vRef_leyenda         = '';
	LET vClave_rastreo       = '';
	LET vFecha_pres_ini      = '';
	LET vUso_futuro_banco    = '';
	LET vFolio_suc           = '';
	LET vUser_insert         = '';
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	--RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    LET mSdoActual    = 0.00;
    LET mSdoRetenido  = 0.00;
    LET mSdoCong      = 0.00;
    LET mImpChqSbg    = 0.00;
    LET mSaldoSbc     = 0.00;							
	LET iExistePend   = 0;
    LET cCod_err2     = '';	
BEGIN
  
	SET ISOLATION DIRTY READ;
    SET LOCK MODE TO wait 3;
 
	--SET DEBUG FILE TO "/RESPALDOSNEW/depuraremesas/sp_domi_procesararch301"|| vRango1 ||".out";
    --TRACE ON;
	
	--	Consulta  fecha del sistema de cheques.
	SELECT FIRST 1 fecha_insert INTO dFecha_hoy FROM bdidomi:dom_cce_control_hilos;
		--      Saca la fecha de presentacion

	LET dFechaManana = dFecha_hoy + 1;
	--NOTA.- Se agrego la validacion de la fecha dado que se puede presentar el caso que la fecha sea habil para la banca e inabil para el banco.
	--Solicitada por jaime gonzales el dia 15/09/2008
	--Realizada por Alejandro Osuna
	
	LET vsNomProceso = 'TRUNCATE_DET_PASO2';
    LET vsDescripcionProceso = 'TRUNCATE TABLE DETALLE_PASO_2';
	SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
	IF iExisteProc = 0 THEN  
		TRUNCATE TABLE bdidomi:dom_cce_detalle_paso_2;
	    EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', '00000', pUsuario, 'sp_domi_procesararch30_1', TRIM(pNom_Arch) , 
		YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet; 
	ELSE
		LET iExisteProc = 0;
	END IF;	
 
	IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

--***********************************************************************************************************************************
--****************************************************INICIO CONSULTA DE PARAMETROS Y VALIDACIONES*************************************

	

	LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');

	CALL bdidomi: "informix".sp_valida_fecha(cFechaFormat) RETURNING cCodRet;

		IF cCodRet <>0 THEN
			EXECUTE FUNCTION bdinteg: "informix".splvalfecha('001', dFechaManana, 0 ) INTO cCodRet,dFechaManana;

			SELECT fecha_prox INTO d_Fech_prox FROM bdinteg: "informix".si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
			IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
				LET dFechaManana = dFechaManana;
			ELSE
				LET dFechaManana = d_Fech_prox;
			END IF;
			LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
			IF cCodRet <>0 THEN
				RETURN cCodRet;
			END IF;
			LET cFecha_trans = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
			--LET cFecha_aplica = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
		END IF;

		SELECT fecha_prox INTO d_Fech_prox FROM bdinteg: "informix".si_feriado_banca WHERE empresa = '001' AND fecha = dFechaManana;
		IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
			LET dFechaManana = dFechaManana;
		ELSE
			LET dFechaManana = d_Fech_prox;

		END IF;
		LET cFechaFormat = YEAR(dFechaManana) || LPAD(MONTH (dFechaManana),2,'0') || LPAD(DAY (dFechaManana),2,'0');
		LET cFecha_trans = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');
		--LET cFecha_aplica = year(dFechaManana) || LPAD(month(dFechaManana),2,'0')|| LPAD(day(dFechaManana),2,'0');

	IF pNom_Arch = "" OR pNom_Arch31 = "" OR pNom_Arch32 = ""  THEN
		LET cCodRet = '00900';
		RETURN cCodRet;
	END IF;

	--	Valida si el usuario contiene un blanco le asigna informix por default.
	IF pUsuario	= ''THEN
		LET pUsuario = 'informix';
	END IF;

	IF LENGTH (pUsuario) < 8 THEN
		LET cCodRet = '00900';
		RETURN cCodRet;
	END IF;

	IF LENGTH (pNom_Arch) < 16 THEN
		LET cCodRet = '00900';
		RETURN cCodRet;
	END IF;

	IF LENGTH (pNom_Arch31) < 17 THEN
		LET cCodRet = '00900';
		RETURN cCodRet;
	END IF;

	IF LENGTH (pNom_Arch32) < 17 THEN
		LET cCodRet = '00900';
		RETURN cCodRet;
	END IF;

	--Obtiene la lista de productos permitidos
	SELECT valor INTO cListaProductosPermitidos FROM bdidomi: "informix".dom_parametros WHERE cod_param = '12';


	--	si existe archivos pendientes por aplicar.
	IF NOT EXISTS (SELECT nombre_arch FROM bdidomi: "informix".dom_cce_encabezado_paso WHERE nombre_arch = pNom_Arch) THEN
		LET cCodRet = '00902';
		RETURN cCodRet;
	END IF;

	--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
	SELECT valor INTO cClaVeBancaria FROM bdidomi: "informix".dom_parametros WHERE cod_param = '05';

		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
			LET cCodRet = '00903';
			RETURN cCodRet;
		END IF;


	--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
	SELECT valor INTO cValTarjeta FROM bdidomi: "informix".dom_parametros WHERE cod_param = '06';
	SELECT valor INTO cValTarjNuevo FROM bdidomi: "informix".dom_parametros WHERE cod_param = '43';

	
		--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
		IF cValTarjeta = '' OR cValTarjeta IS NULL OR cValTarjNuevo = '' OR cValTarjNuevo IS NULL Then
			LET cCodRet = '00904';
			RETURN cCodRet;
		END IF;


	--	se extrae el valor de la sucursal contable.
	SELECT valor INTO cSucursalContable FROM bdidomi: "informix".dom_parametros WHERE cod_param = '07';

	--	validar si existe en el catalogo la sucursal contable.
	SELECT 1 INTO iExiste FROM bdinteg: "informix".si_sucursales WHERE sucursal = cSucursalContable;

		--	Se valida si existe la sucursal contable.
		IF iExiste = 0 Then
			LET cCodRet = '00905';
			RETURN cCodRet;
		ELSE
			LET iExiste = 0;
		END IF;

	--	se extrae el valor de la transaccion de cargo.
	SELECT valor INTO cTransaccCargo FROM bdidomi: "informix".dom_parametros WHERE cod_param = '08';
	SELECT valor INTO cTransaccAbono FROM bdidomi: "informix".dom_parametros WHERE cod_param = '09';

	--	Valida si existe la transaccion de cargo.
	SELECT COUNT(numero) INTO iExiste FROM bdinteg: "informix".si_transacc WHERE numero IN (cTransaccCargo,cTransaccAbono);

		--	Valida si existe las transacciones parametrizadas.
		IF iExiste < 2 Then
			LET cCodRet = '00906';
			RETURN cCodRet;
		ELSE
			LET iExiste = 0;
		END IF;

	SELECT 1,valor INTO iExiste,iMaximoRechazosPermitidos FROM bdidomi: "informix".dom_parametros WHERE cod_param = '11';

		IF iExiste = 0  THEN
			LET cCodRet = '00907';
			RETURN cCodRet;
		ELSE
			LET iExiste = 0;
		END IF;


--*****************************************************FIN CONSULTA DE PARAMETROS Y VALIDACIONES***************************************
--********************************************************************************************************************************************
	LET vRango1 = LPAD (TRIM(TO_CHAR(vRango1)),7,'0');
	LET vRango2 = LPAD (TRIM(TO_CHAR(vRango2)),7,'0');											   
	LET vsNomProceso = 'INSERT_DET_PASO2';
    LET vsDescripcionProceso = 'INSERT TABLE DETALLE_A_PASO_2';
	SELECT count(*) INTO iExisteProc FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = dFecha_hoy AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND estatus = '1';
	
	IF iExisteProc = 0 THEN 
	
		INSERT INTO bdidomi:dom_cce_detalle_paso_2 
		SELECT * FROM bdidomi:dom_cce_detalle_paso Det
		WHERE  Det.nombre_arch =  pNom_Arch
		AND Det.tipo_registro = '02'
		AND Det.num_secuencia >= vRango1
		AND Det.num_secuencia <= vRango2
		AND	Det.cod_operacion = '30'
		AND Det.cve_estatus NOT IN ('02','01');
		UPDATE STATISTICS MEDIUM FOR TABLE bdidomi:dom_cce_detalle_paso_2;
		EXECUTE PROCEDURE bdidomi:sp_domi_bitacora('A', CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, '1', '00000', pUsuario, 'sp_domi_procesararch30_1', TRIM(pNom_Arch) , 
		YEAR(dFecha_hoy) || LPAD(MONTH (dFecha_hoy),2,'0') || LPAD(DAY (dFecha_hoy),2,'0'), '11' ) INTO cCodRet;
	ELSE
		SELECT MAX(num_secuencia) INTO vNumSecuencia FROM bdidomi:dom_cce_detalle_paso_2 WHERE nombre_arch <> pNom_Arch;
		LET vNumSecuencia = vNumSecuencia + 1;
		--LET vNumSecuencia1 = vNumSecuencia1 + 400000;
		--LET iExisteProc = 0;
	END IF;	
  LET vCuenta = 0;	
-- Inicio del ciclo de busqueda por archivo y sus registros.
  FOREACH cursor3 WITH HOLD FOR

	--	Extrae el Monto fijo y cuenta  del archivo.
	SELECT Det.importe /100,Det.num_cta_rec,Det.num_cta_ord,Det.num_secuencia,Det.rfc_rec,Det.rfc_ord,Det.ref_leyenda,Det.fecha_trans,Det.banco_presentador,Det.banco_receptor,Det.ref_servicio,nombre_ord,Det.tipo_cta_rec,Det.num_cta_rec,Det.ref_servicio
	INTO mSaldoAPagar,cClabeoTarjeta,cCuentaOrd,iSecuencia,cRFCrecibido,cRFCOrdenante,cDescripcionProceso,cFechaTrans,cBancoPresentador,cBancoReceptor,cReferenciaServicio,cNombreTitular,cTpoCuenta_Cargo,cCuentaRec,cRefServComp
	FROM bdidomi: "informix".dom_cce_detalle_paso_2 Det
	WHERE  Det.nombre_arch =  pNom_Arch
	AND Det.tipo_registro = '02'
	AND Det.num_secuencia >= vRango1
	AND Det.num_secuencia <= vRango2
	AND	Det.cod_operacion = '30'
	AND Det.cve_estatus NOT IN ('02','01')
	
	LET vsDescripcionProceso = 'sp_domi_procesararch30_1' || ' ' || cClabeoTarjeta;

	--	Valida que la clabe ni el importe se obtengan sin valores.
	 IF mSaldoAPagar IS NULL OR mSaldoAPagar = 0.00 OR  cClabeoTarjeta IS NULL OR cClabeoTarjeta = '' THEN
		CONTINUE FOREACH;
	 END IF;
	 
	 --SET ISOLATION DIRTY READ;
	 --SET LOCK MODE TO wait 4;

	 LET vNumSecuencia = vNumSecuencia +1;

 	 /*SELECT COUNT(num_cta_rec) INTO iContadorRepetidas FROM bdidomi: "informix".dom_cce_detalle_paso_2
	 WHERE  nombre_arch =  pNom_Arch
	 AND num_cta_rec = cClabeoTarjeta
	 AND rfc_ord = cRFCOrdenante
	 AND banco_presentador =  cBancoPresentador
	 AND importe/100 = mSaldoAPagar
	 AND ref_servicio = cReferenciaServicio;

	 IF iContadorRepetidas > 1 THEN
	 
	 	FOREACH cursor4 WITH HOLD FOR
			SELECT num_secuencia
			INTO cSecuenciaAux
			FROM bdidomi: "informix".dom_cce_detalle_paso_2
			WHERE  nombre_arch =  pNom_Arch
			AND num_cta_rec = cClabeoTarjeta
			AND rfc_ord = cRFCOrdenante
			AND banco_presentador =  cBancoPresentador
			AND importe/100 = mSaldoAPagar
			AND ref_servicio = cReferenciaServicio
			AND num_secuencia <> iSecuencia
			
			LET vNumSecuencia1 = vNumSecuencia1 + 1;
			LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia1)),7,'0');

			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
			fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
			nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
			ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert)

			SELECT pNom_Arch31,cFechaFormat,tipo_registro,cSecuencia,'31',cod_divisa,cFecha_trans,
			cBancoReceptor,cBancoPresentador,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,
			num_cta_ord,nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,
			importe_iva,ref_numerica,ref_leyenda,clave_rastreo,'07',fecha_pres_ini,uso_futuro_banco,'02',
			folio_suc,user_insert,CURRENT::DATE
			FROM bdidomi: "informix".dom_cce_detalle_paso_2
			WHERE  nombre_arch =  pNom_Arch
			AND num_cta_rec = cClabeoTarjeta
			AND rfc_ord = cRFCOrdenante
			AND banco_presentador =  cBancoPresentador
			AND importe/100 = mSaldoAPagar
			AND ref_servicio = cReferenciaServicio
			AND num_secuencia = cSecuenciaAux;

			UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02' WHERE CURRENT OF cursor4;
			 
		END FOREACH;
	 END IF;*/

	 SELECT tipo_registro,cod_divisa,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,
		num_cta_ord,nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,
		importe_iva,ref_numerica,ref_leyenda,clave_rastreo,fecha_pres_ini,uso_futuro_banco,folio_suc,user_insert
	  INTO 	vTipo_registro, vCod_divisa, vImporte, vUso_futuro_ccen,vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,
	  vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,vFecha_pres_ini,vUso_futuro_banco,
	  vFolio_suc,vUser_insert
	  FROM bdidomi: "informix".dom_cce_detalle_paso_2 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND num_secuencia = iSecuencia;																																																													 
	--****************************************************INICIO VALIDACIONES A LA CUENTA CARGO*********************************************
	--***********************************************************************************************************************************
	 --	Valida si existe la tarjeta en la sc_tarjeta.
	 SELECT 1 INTO iExiste FROM bdicheq: "informix".sc_tarjeta
	 
	 WHERE empresa = '001' AND num_tarjeta = SUBSTR(cClabeoTarjeta ,5,16);

	 --	Valida si existe la tarjeta y esta en el rango del valor de la tarjeta.
	 IF iExiste = 1 THEN

		--	extrae la cuenta por el # tarjeta.
		SELECT cuenta,status_tar,tipo_tarjeta,num_tarjeta INTO cCuentaCargo,cStatusTar,cTipo_tarjeta,cNum_Tarjeta FROM bdicheq: "informix".sc_tarjeta
		
		WHERE empresa = '001' AND num_tarjeta = SUBSTR(cClabeoTarjeta ,5,16);

		IF cCuentaCargo = '' OR cCuentaCargo IS NULL  THEN
			--	Motivo 06: La cuenta no pertence al banco receptor.

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																						  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'01',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);
	
		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;

			CONTINUE FOREACH;
		END IF;

		IF cTipo_tarjeta <> 'T' THEN
			--	Motivo 06: La cuenta no pertence al banco receptor.

			LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
			 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
			 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
			 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
			 
			 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																			  
			  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
			  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'11',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  
				
			UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
			WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;

			CONTINUE FOREACH;
		END IF;

		IF cStatusTar <> 'A' THEN
			--	Motivo 03: Tarjeta Cancelada
		
		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																					  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'03',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);
	
		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;

			CONTINUE FOREACH;
		END IF;




		IF SUBSTR(cNum_Tarjeta,1,6) <> cValTarjeta AND SUBSTR(cNum_Tarjeta,1,6) <> cValTarjNuevo THEN

			LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
			 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
			 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
			 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
			 
			 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																				  
			  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
			  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'06',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  
			
			UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
			WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;

			CONTINUE FOREACH;
		END IF;

	 --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
	 SELECT 1,cuenta,num_cte,status_cta,producto,sdo_actual,sdo_cong,sdo_retenido,imp_chq_sbg,saldo_sbc
	 INTO iExiste,cCuentaCargo,cNum_cte,cEstatusCtaCargo,cProductoCtaCargo,mSdoActual,mSdoCong,mSdoRetenido,mImpChqSbg,mSaldoSbc
	 FROM bdicheq: "informix".sc_maechq WHERE empresa = '001' AND cuenta = cCuentaCargo;

	 --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
     EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, '', '', 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSaldoActual;


	 ELSE
		 --Comprueba si la clabe nos corresponde.
		 SELECT 1 INTO iExiste FROM bdicheq: "informix".sc_fechas WHERE SUBSTR(cClabeoTarjeta,3,3) <> cClaVeBancaria;
		 IF iExiste = 1 THEN
			--	Motivo 06: La cuenta no pertence al banco receptor.

			LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

			INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
			 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
			 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
			 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
			 
			 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																					  
			  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
			  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'06',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  
			
			UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
			WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			--Hago commit y vuelvo a iniciar
		LET vCuenta = vCuenta + 1;
		IF vCuenta = 1000 THEN
			COMMIT WORK;
			LET vCuenta = 0;
			BEGIN WORK;
		END IF;


			CONTINUE FOREACH;
		 END IF;

		LET iExiste = 0;
		-- si no existe consulta por la cuenta del cliente encontrada en la cuenta_clabe del cliente.
		--RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
		SELECT 1,cuenta,num_cte,status_cta,producto,sdo_actual,sdo_cong,sdo_retenido,imp_chq_sbg,saldo_sbc
		INTO iExiste,cCuentaCargo,cNum_cte,cEstatusCtaCargo,cProductoCtaCargo,mSdoActual,mSdoCong,mSdoRetenido,mImpChqSbg,mSaldoSbc
		FROM bdicheq: "informix".sc_maechq WHERE empresa = '001' AND cuenta = SUBSTR (cClabeoTarjeta,9,11);

		--RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, '', '', 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSaldoActual;
 
	 END IF;

	  IF cCuentaCargo = '' OR cCuentaCargo IS NULL THEN
		--	Motivo 06: La cuenta no pertence al banco receptor.

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');


		INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																					  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'01',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);	  
		
		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
		--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
		--Hago commit y vuelvo a iniciar
		LET vCuenta = vCuenta + 1;
		IF vCuenta = 1000 THEN
			COMMIT WORK;
			LET vCuenta = 0;
			BEGIN WORK;
		END IF;

		CONTINUE FOREACH;
	  END IF;

		/*IF iExiste = 1 THEN
			SELECT FIRST 1 1,cve_estatus,imp_maximo  INTO iExiste,cEstatusAutorizacion,mImp_maximo
			FROM bdidomi: "informix".dom_autorizaciones WHERE cuenta = cCuentaCargo AND  rfc = cRFCOrdenante;

			IF iExiste < 1 OR iExiste IS NULL THEN
				IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cat_servicios WHERE rfc = cRFCOrdenante) THEN
					-- Registra en el catalogo de servicio.
-- Se agregan los codigos de documento ('0000') para digitalizacion. JGP. 06-11-2009
--				INSERT INTO bdidomi:dom_cat_servicios (rfc,razon_social,convenio,cve_canal,presentador,num_cte,nombre_corto,num_reintentos,
--													   comision,comision_dev,cuenta_cargo_comision,layout_especial,user_insert,fecha_insert)
--				VALUES (cRFCOrdenante,cNombreTitular,'N','05','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,pUsuario,CURRENT::DATE);
					INSERT INTO bdidomi: "informix".dom_cat_servicios (rfc,razon_social,convenio,cve_canal,presentador,num_cte,nombre_corto,num_reintentos,
													   comision,comision_dev,cuenta_cargo_comision,layout_especial,user_insert,fecha_insert,
													   cod_grupo_act,cod_grupo_des,cod_grupo_react,cod_grupo_rev)
					VALUES (cRFCOrdenante,cNombreTitular,'N','05','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,pUsuario,CURRENT::DATE,'0000','0000','0000','0000');
				END IF;
				IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante) THEN
					--Inserta el registro de autorizacion domi.
					INSERT INTO bdidomi: "informix".dom_autorizaciones(cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos
					,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert)
					VALUES (cCuentaCargo,cRFCOrdenante,cNum_cte,'05',0.00,0,cSucursalContable,'01',dFecha_hoy,pUsuario,'00',pUsuario,CURRENT::DATE);
				END IF;	
			END IF;
		END IF;*/

	 --	Si la cuenta esta cancelada
	  IF cEstatusCtaCargo = '2' THEN

		--Motivo 01: La cuenta Cancelada.
		
		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																					  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'03',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);		
		
		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
		--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
		--Hago commit y vuelvo a iniciar
		LET vCuenta = vCuenta + 1;
		IF vCuenta = 1000 THEN
			COMMIT WORK;
			LET vCuenta = 0;
			BEGIN WORK;
		END IF;
		CONTINUE FOREACH;

	  END IF;
	  --	Si la cuenta esta bloqueada
	  IF cEstatusCtaCargo = '3' THEN

		--Motivo 02: La cuenta esta bloqueada .
		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																						  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'02',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);	  
		
		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
		--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
		--Hago commit y vuelvo a iniciar
		LET vCuenta = vCuenta + 1;
		IF vCuenta = 1000 THEN
			COMMIT WORK;
			LET vCuenta = 0;
			BEGIN WORK;
		END IF;

		CONTINUE FOREACH;

	  END IF;

	 IF NOT cProductoCtaCargo IS NULL OR NOT cProductoCtaCargo = "" THEN
		SELECT 1 INTO iExiste FROM bdicheq: "informix".sc_producto WHERE producto = cProductoCtaCargo AND divisa = '01';

		IF iExiste <> 1 OR iExiste IS NULL THEN
			--	Motivo 05: La cuenta esta en otra divisa.

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');
		INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'05',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  

		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
		--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
		--Hago commit y vuelvo a iniciar
		LET vCuenta = vCuenta + 1;
		IF vCuenta = 1000 THEN
			COMMIT WORK;
			LET vCuenta = 0;
			BEGIN WORK;
		END IF;
		CONTINUE FOREACH;

		ELSE
			LET iExiste = 0;
		END IF;
  	 END IF;

	 IF NOT( cListaProductosPermitidos LIKE '%'|| cProductoCtaCargo || '%' )   THEN

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																						  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'06',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  
																																					  
		 UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		 WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;
		CONTINUE FOREACH;
	 END IF;
	 
	-------------------------------Comienza validacion para la cancelacion de domicliacion--------------------------
		--Estatus cTipoDomiciliacion se valida por tarjeta o por domiciliacion en el sp_guarda_cancelaciones
		
			-- 1 Cancelacion por TARJETA
			-- 2 Cancelacion por Domiciliacion
			
		--Estatus cancelaciones de la tabla dom_cte_cancelaciones
			
			-- 0 Enviado de aclaraciones
			-- 1 Domiciliacion cancelada aplicada
		
		/*IF cTpoCuenta_Cargo = '40' THEN --Valida si es cuenta clabe
		
			--1 validar por rfc
			--2 validar por numero de cliente
				
			--si yo quiero cancelar sky eso lo vamos hacer por el proceso de recepcion	(es donde nosotros le pagamos a otros bancos)
			SELECT FIRST 1 cuenta_clabe,ref_servicio,cuenta INTO cClabeCancel,cRefServCancel,cCuentaCargoCancel FROM bdidomi:dom_cte_cancelaciones WHERE ref_servicio = TRIM(cRefServComp) AND cuenta_clabe = TRIM(cClabeoTarjeta) AND cuenta = TRIM(cCuentaCargo) AND status_cancelacion = '0';
			
			IF TRIM(cClabeCancel) = TRIM(cClabeoTarjeta) AND TRIM(cRefServCancel) = TRIM(cRefServComp) AND TRIM(cCuentaCargoCancel) = TRIM(cCuentaCargo) THEN
				--	Motivo 10: Por Orden del Cliente: Cancelacion del Servicio.             
				
				LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

				INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
					fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
					nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
					ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert)

				SELECT pNom_Arch31,cFechaFormat,tipo_registro,cSecuencia,'31',cod_divisa,cFecha_trans,
				cBancoReceptor,cBancoPresentador,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,
				num_cta_ord,nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,
				importe_iva,ref_numerica,ref_leyenda,clave_rastreo,'10',fecha_pres_ini,uso_futuro_banco,'02',
				folio_suc,user_insert,CURRENT::DATE
				FROM bdidomi: "informix".dom_cce_detalle_paso_2 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND num_secuencia = iSecuencia;

				UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
				WHERE CURRENT OF cursor3;
				--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
				
				UPDATE bdidomi:dom_cte_cancelaciones SET status_cancelacion = '1' WHERE ref_servicio = TRIM(cRefServComp) AND cuenta_clabe = TRIM(cClabeoTarjeta);
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
				IF vCuenta = 1000 THEN
					COMMIT WORK;
					LET vCuenta = 0;
					BEGIN WORK;
				END IF;
				CONTINUE FOREACH;
			END IF;
		END IF;
		
		IF cTpoCuenta_Cargo = '03' THEN  --Valida si es numero de tarjeta
		
			SELECT FIRST 1 num_tarjeta,ref_servicio,cuenta INTO cTarjetaCargoCancel,cRefServCancel,cCuentaCargoCancel FROM bdidomi:dom_cte_cancelaciones WHERE ref_servicio = TRIM(cRefServComp) AND num_tarjeta = TRIM(cClabeoTarjeta) AND cuenta = TRIM(cCuentaCargo) AND status_cancelacion = '0';

			IF TRIM(cTarjetaCargoCancel) = TRIM(cClabeoTarjeta) AND TRIM(cRefServCancel) = TRIM(cRefServComp) AND TRIM(cCuentaCargoCancel) = TRIM(cCuentaCargo) THEN
				--	Motivo 10: Por Orden del Cliente: Cancelacion del Servicio.             
				
				LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

				INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
					fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
					nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
					ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert)

				SELECT pNom_Arch31,cFechaFormat,tipo_registro,cSecuencia,'31',cod_divisa,cFecha_trans,
				cBancoReceptor,cBancoPresentador,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,
				num_cta_ord,nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,
				importe_iva,ref_numerica,ref_leyenda,clave_rastreo,'10',fecha_pres_ini,uso_futuro_banco,'02',
				folio_suc,user_insert,CURRENT::DATE
				FROM bdidomi: "informix".dom_cce_detalle_paso_2 WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND num_secuencia = iSecuencia;

				UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
				WHERE CURRENT OF cursor3;
				--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
				
				UPDATE bdidomi:dom_cte_cancelaciones SET status_cancelacion = '1' WHERE ref_servicio = TRIM(cRefServComp) AND num_tarjeta = TRIM(cClabeoTarjeta);
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
				IF vCuenta = 1000 THEN
					COMMIT WORK;
					LET vCuenta = 0;
					BEGIN WORK;
				END IF;
				CONTINUE FOREACH;
			END IF;
		END IF;*/
		
		-------------------------------Termina validacion para la cancelacion de domicliacion--------------------------
	
	--****************************************************FIN VALIDACIONES A LA CUENTA CARGO************************************************
	--***********************************************************************************************************************************
	--***********************************************************************************************************************************
	--****************************************************INICIO CONSULTA SI EL CLIENTE ESTA ATORIZADO**************************************
	  --validar que el registro sea para una persona fisica.
	  SELECT num_cte INTO vnumcte FROM bdicheq: "informix".sc_maechq WHERE cuenta = TRIM(cCuentaCargo) AND empresa = '001';
	  SELECT 1 INTO iExiste FROM bdinteg:si_cliente WHERE numcte = TRIM(vnumcte) AND tpo_persona = '01';
	  --Se cambio por el query de arriba para que jale mas rapido el proceso 
	  --SELECT 1 INTO iExiste FROM bdicheq: "informix".sc_maechq mae INNER JOIN bdinteg:si_cliente cte ON mae.num_cte = cte.numcte
	  --WHERE mae.empresa = '001' AND mae.cuenta = cCuentaCargo AND cte.tpo_persona = '01';

	  IF iExiste != 1 THEN

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'11',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);	  

		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
		--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
		--Hago commit y vuelvo a iniciar
		LET vCuenta = vCuenta + 1;
		IF vCuenta = 1000 THEN
			COMMIT WORK;
			LET vCuenta = 0;
			BEGIN WORK;
		END IF;
		CONTINUE FOREACH;
	  ELSE
		LET iExiste = 0;
	  END IF;


	  --consulta si el cliente esta autorizado en el servicio de domi.
	  SELECT FIRST 1 1,cve_estatus,imp_maximo  INTO iExiste,cEstatusAutorizacion,mImp_maximo
	  FROM bdidomi: "informix".dom_autorizaciones WHERE cuenta = cCuentaCargo AND  rfc = cRFCOrdenante;

		IF iExiste < 1 THEN
			IF cEstatusAutorizacion <> '01' THEN

			LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

			 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
			 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
			 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
			 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
			 
			 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																					  
			  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
			  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'11',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  
			
			 UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
			 WHERE CURRENT OF cursor3;
				--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
			  --Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
				IF vCuenta = 1000 THEN
					COMMIT WORK;
					LET vCuenta = 0;
					BEGIN WORK;
				END IF;	
			  CONTINUE FOREACH;

			END IF;
		ELSE
			IF NOT EXISTS (SELECT 1 FROM bdidomi: "informix".dom_cat_servicios WHERE rfc = cRFCOrdenante) THEN
				-- Registra en el catalogo de servicio.
-- Se agregan los codigos de documento ('0000') para digitalizacion. JGP. 06-11-2009
--				INSERT INTO bdidomi: "informix".dom_cat_servicios (rfc,razon_social,convenio,cve_canal,presentador,num_cte,nombre_corto,num_reintentos,
--													   comision,comision_dev,cuenta_cargo_comision,layout_especial,user_insert,fecha_insert)
--				VALUES (cRFCOrdenante,cNombreTitular,'N','05','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,pUsuario,CURRENT::DATE);
				INSERT INTO bdidomi: "informix".dom_cat_servicios (rfc,razon_social,convenio,cve_canal,presentador,num_cte,nombre_corto,num_reintentos,
													   comision,comision_dev,cuenta_cargo_comision,layout_especial,user_insert,fecha_insert,
													   cod_grupo_act,cod_grupo_des,cod_grupo_react,cod_grupo_rev)
				VALUES (cRFCOrdenante,cNombreTitular,'N','05','N',NULL,NULL,NULL,NULL,NULL,NULL,NULL,pUsuario,CURRENT::DATE,'0000','0000','0000','0000');
			END IF;
			IF NOT EXISTS (SELECT 1 FROM bdidomi:"informix".dom_autorizaciones WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante) THEN
				--Inserta el registro de autorizacion domi.
				INSERT INTO bdidomi: "informix".dom_autorizaciones(cuenta,rfc,num_cte,cve_canal,imp_maximo,num_rechazos
				,cve_sucursal,cve_estatus,fecha_estatus,user_estatus,cve_causa,user_insert,fecha_insert)
				VALUES (cCuentaCargo,cRFCOrdenante,cNum_cte,'05',0.00,0,cSucursalContable,'01',dFecha_hoy,pUsuario,'00',pUsuario,CURRENT::DATE);
			END IF;	
		END IF;

		--Valida motivo 04 por orden del cliente:importe mayor del autorizado.
		IF mSaldoAPagar > mImp_maximo AND mImp_maximo > 0.00 THEN

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																						 
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'09',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);			
		
		UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		WHERE CURRENT OF cursor3;
		--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
		--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;
		  CONTINUE FOREACH;
		END IF;
		LET mSaldoActual = mSaldoActual;
		LET mSaldoAPagar = mSaldoAPagar;
		--Valida y compara que el saldo actual de la cuenta alcanze a pagar el monto.
		IF mSaldoAPagar > mSaldoActual THEN

		LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

		 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
		 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
		 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
		 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
		 
		 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,																							  
		  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
		  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'04',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);	
			
		 UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
		 WHERE CURRENT OF cursor3;
			--WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;

			LET iNumRechazos = 0;

			--Consulta si el numero de rechazos parametrizados es menor a los que tiene el cliente.
			SELECT FIRST 1 num_rechazos INTO iNumRechazos FROM bdidomi: "informix".dom_autorizaciones WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante;

			IF iMaximoRechazosPermitidos > iNumRechazos THEN
			  --Se comenta por el error -243 en la implementacion de hilos
			  --UPDATE bdidomi: "informix".dom_autorizaciones SET num_rechazos = num_rechazos + 1
			  --WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante;

			  LET iNumRechazos = iNumRechazos + 1;
			  IF iNumRechazos = iMaximoRechazosPermitidos THEN
				  UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
				  --WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND num_secuencia = iSecuencia;
				  WHERE CURRENT OF cursor3;					
				  --Comentado para no bloquear las domiciliaciones RMQ 06 894 Modificaciones en intentos de cobranza al proceso de DOMI
				  --UPDATE bdidomi: "informix".dom_autorizaciones SET cve_estatus = '02',cve_causa = '01'
				  --WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante;
			  END IF;

			ELSE
			  UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
			  --WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND num_secuencia = iSecuencia;
			  WHERE CURRENT OF cursor3;						
			  --Comentado para no bloquear las domiciliaciones RMQ 06 894 Modificaciones en intentos de cobranza al proceso de DOMI
			  --UPDATE bdidomi: "informix".dom_autorizaciones SET cve_estatus = '02',cve_causa = '01'
			  --Se comenta por el error -243 en la implementacion de hilos
			  --UPDATE bdidomi: "informix".dom_autorizaciones SET num_rechazos = num_rechazos + 1
			  --WHERE cuenta = cCuentaCargo AND rfc = cRFCOrdenante;
			END IF;
			--Hago commit y vuelvo a iniciar
			LET vCuenta = vCuenta + 1;
			IF vCuenta = 1000 THEN
				COMMIT WORK;
				LET vCuenta = 0;
				BEGIN WORK;
			END IF;
		  CONTINUE FOREACH;
		END IF;

	--****************************************************FIN CONSULTA SI EL CLIENTE ESTA ATORIZADO*****************************************
	--***********************************************************************************************************************************
	--***********************************************************************************************************************************
	--****************************************************LLAMADO AL PROCESO DE CARGO Y ABONO**********************************************

	IF cFechaFormat = cFechaTrans THEN
	--	Genera el folio del cargo para el cliente.
		CALL bdicheq: "informix".sp_generafolionomina(SUBSTR(cNum_cte,2,9))RETURNING cCodRet,cNumeroFolioCargo;

	--	se llama la ejecucion del cargo para el cliente.
		--CALL bdicheq: "informix".cargo_ref ("001", cSucursalContable, pUsuario, cTransaccCargo, "0000", cNumeroFolioCargo,cCuentaCargo,0, mSaldoAPagar,"01",TRIM(cCuentaCargo)||" "||TRIM(cDescripcionProceso),'',pUsuario)RETURNING cCodRet,cTranRet,dFecha_hoy,mSdoDisp,mMontoRet;
		CALL bdicheq:"informix".cargon_ref("001",cSucursalContable,pUsuario,cTransaccCargo,"0000",cNumeroFolioCargo,cCuentaCargo,0,mSaldoAPagar,"01",TRIM(cCuentaCargo)||" "||TRIM(cDescripcionProceso),'',pUsuario) RETURNING cCodRet,cTranRet;
		LET cCodRet = LPAD(TRIM(cCodRet),5,"0");

		IF cCodRet <> '00000' THEN
			IF cCodRet > '00000' THEN				

				LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

				 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
				 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
				 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
				 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
				 
				 (pNom_Arch31,cFechaFormat,vTipo_registro,cSecuencia,'31', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,
				  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,
				  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'11',vFecha_pres_ini,vUso_futuro_banco,'02',vFolio_suc,vUser_insert,CURRENT::DATE);  

				 UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET cve_estatus = '02'
				 --WHERE nombre_arch = pNom_Arch AND num_secuencia = iSecuencia;
				 WHERE CURRENT OF cursor3;
					
					--Hago commit y vuelvo a iniciar
					LET vCuenta = vCuenta + 1;
					IF vCuenta = 1000 THEN
						COMMIT WORK;
						LET vCuenta = 0;
						BEGIN WORK;
					END IF;	
					CONTINUE FOREACH;
			ELSE
				EXECUTE PROCEDURE bdicheq:reversion('001', cSucursalContable, pUsuario, cNumeroFolioCargo,'M') INTO cCod_err2;
				CONTINUE FOREACH;
			END IF;	
		ELSE
			LET iAplicoCargo = 1;
			
			LET cSecuencia = LPAD (TRIM(TO_CHAR(vNumSecuencia)),7,'0');

			 INSERT INTO bdidomi: "informix".dom_cce_detalle_paso_2 (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,
			 fecha_trans,banco_presentador,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,
			 nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,
			 ref_leyenda,clave_rastreo,motivo_dev,fecha_pres_ini,uso_futuro_banco,cve_estatus,folio_suc,user_insert,fecha_insert) VALUES
			 
			 (pNom_Arch32,cFechaFormat,vTipo_registro,cSecuencia,'32', vCod_divisa,cFecha_trans,cBancoReceptor,cBancoPresentador,vImporte,vUso_futuro_ccen,
			  vTipo_operacion,vFecha_aplica,vTipo_cta_ord,vNum_cta_ord,vNombre_ord,vRfc_ord,vTipo_cta_rec,vNum_cta_rec,vNombre_rec,vRfc_rec,vRef_servicio,																								  
			  vNombre_titular_serv,vImporte_iva,vRef_numerica,vRef_leyenda,vClave_rastreo,'00',vFecha_pres_ini,vUso_futuro_banco,'01',cNumeroFolioCargo,vUser_insert,CURRENT::DATE);
			
			  UPDATE bdidomi: "informix".dom_cce_detalle_paso_2 SET folio_suc =  cNumeroFolioCargo,cve_estatus = '01' --WHERE CURRENT OF cursor3;
			  --WHERE nombre_arch = pNom_Arch AND cod_operacion = '30' AND num_secuencia = iSecuencia;
			  WHERE CURRENT OF cursor3;
			  --Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
				IF vCuenta = 1000 THEN
					COMMIT WORK;
					LET vCuenta = 0;
					BEGIN WORK;
				END IF;
		END IF;
	ELSE
		CONTINUE FOREACH;
	END IF;
	--************************************************FIN LLAMADO AL PROCESO DE CARGO Y ABONO**********************************************
	--***********************************************************************************************************************************************
  END FOREACH;
  
	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		COMMIT WORK;
	END IF;

	SELECT COUNT(*) INTO iExistePend
	FROM bdidomi: "informix".dom_cce_detalle_paso_2 Det
	WHERE  Det.nombre_arch =  pNom_Arch
	AND Det.tipo_registro = '02'
	AND Det.num_secuencia >= vRango1
	AND Det.num_secuencia <= vRango2
	AND	Det.cod_operacion = '30'
	AND Det.cve_estatus NOT IN ('02','01');
	
	IF iExistePend >= 1 THEN 
		EXECUTE PROCEDURE bdidomi:sp_domi_procesararch30_1(pNom_Arch,pNom_Arch31,pNom_Arch32,pUsuario,vRango1,vRango2,pApuntador) INTO cCodRet;
	ELSE
		LET cCodRet = 0;
	END IF;												 
	IF cCodRet = 0 THEN
		LET cCodRet = LPAD(TRIM(cCodRet),5,'0');
		LET cMensaje = 'PROCESADO EXITOSAMENTE';
	END IF;

	RETURN cCodRet;
 END

END PROCEDURE
DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdidomi',
'VER   : 1.2';