CREATE PROCEDURE "informix".sp_pago_wu_web(pEmpresa			    CHAR(3),
										   pNombre1			    CHAR(40),
										   pNombre2             CHAR(40),
										   pApellidoPaterno     CHAR(40),
										   pApellidoMaterno     CHAR(40),
										   pFechaHoy            CHAR(10),
										   pEstado              CHAR(2),
										   pMontoAPagar         CHAR(20),
										   pSucursal            CHAR(4),
										   pMoneda              CHAR(3),
										   pMontoMoneda         MONEY(16,2),
										   pRefUno              CHAR(11),
										   pRetCode             CHAR(5),
										   pDescError           CHAR(250),
										   pMtcn                CHAR(11),
										   pNewMtcn             CHAR(16),
										   pFolSucEmp           CHAR(16),
										   pEmisorNameType      CHAR(1),
										   pBenefNameType       CHAR(1),
										   pMoneyTransKey       CHAR(10),
										   pNumRefRp            CHAR(16),
										   pFusionStatus        CHAR(4),
										   pEmisorCodMoneda     CHAR(3),
										   pBenefEdo            CHAR(40),
										   pSystemIdRp          CHAR(11),
										   pTelefonoCasa        CHAR(10),
										   pTelefonoCelular     CHAR(10),
										   pCategoria           CHAR(2),
										   pConvenio            CHAR(5),
										   pRefDos              CHAR(20),
										   pFormaPago           CHAR(1),
										   peMontoTotal         DECIMAL(10,2),
										   peImpComConv         DECIMAL(6,2),
										   peIvaComConv         DECIMAL(6,2),
										   peImpComCte          DECIMAL(6,2),
										   peIvaComCte          DECIMAL(6,2),
										   pNumEmp              CHAR(8),
										   pFolsuc              CHAR(16),
										   pTransSuc            CHAR(4),
										   pFechaPag            DATE,
										   pTranEquivCargo      CHAR(4),
										   pTransSucRef         CHAR(4),
										   pCuentaCargo         CHAR(20),
										   pCheque              INTEGER,
										   pMontoTotalRef       MONEY(14,2),
										   pDivisa              CHAR(2),
										   pReferenciaCargo     CHAR(40),
										   pNumTarjeta          CHAR(16),
										   pUsuAutoriza         CHAR(8),
										   pTranEquivAbono      CHAR(4),
										   pCuentaAbono         CHAR(20),
										   pDocto               INTEGER,
										   pMontoFirme          MONEY(14,2),
										   pMtoSBC              MONEY(14,2),
										   pMtoRem              MONEY(14,2),
										   pDiasRet             INTEGER,
										   pReferenciaAbono     CHAR(40),
										   pMtcnConf            CHAR(10),
										   pCiudad              CHAR(24),
										   pEstadoConf          CHAR(40),
										   ptFechaHora          DATETIME YEAR TO SECOND,
										   ptFechaInsert        DATETIME YEAR TO SECOND,
										   pForeignRefNumRq     CHAR(16),
										   pForeingRefNumRp     CHAR(16),
										   pConfPago            CHAR(1),
										   pNumCte			    CHAR(20),
										   pValorCargo		    MONEY(16,2),
										   pValorAbono		    MONEY(16,2),
										   pFechaNacimiento     CHAR(10),
										   pMarca				CHAR(2),
										   pCodigoPostalBenef1	VARCHAR(9),
										   pDirLinea1Benef		VARCHAR(40),
										   pDirLinea2Benef		VARCHAR(40),
										   pTelCasaBenef		VARCHAR(20),
										   pTelCelBenef			VARCHAR(20),
										   pCanalOrigen          CHAR(4),
	                                       pCajaOrigen           CHAR(2),
	                                       pSucursalOrigen       CHAR(4),
	                                       pFolioOrigen          CHAR(16),
	                                       pCampoGenerico1       CHAR(20),
	                                       pCampoGenerico2       CHAR(20),
	                                       pCampoGenerico3       CHAR(20)
										   )

	RETURNING CHAR (5) AS RetCode, CHAR (2) AS IdentificadorProceso, CHAR (5) AS RetCode2, CHAR (4) AS ChannelType, CHAR (4) AS ChannelName, CHAR (4) AS ChannelVersion, CHAR (11) AS FrsIdentifier, CHAR (13) AS FrsCounterId;

	-- Definicion de variables --                                                          			 
	DEFINE cCodErr 				 CHAR (5);                                                 			 
	DEFINE cIdentificadorProceso CHAR (2);                                                 			 
	DEFINE cRetCode2			 CHAR (5);
	DEFINE cRetCode3			 CHAR (5);
	DEFINE iSqlErr				 INTEGER;
	DEFINE vtransaccion			 SMALLINT;
	DEFINE cFlagTelCel			 CHAR (1);
	DEFINE cFlagTelCasa			 CHAR (1);
	DEFINE cFlagTelOficina		 CHAR (1);
	DEFINE mMontoServ            MONEY(16,2);
	DEFINE mMontoCargoServ       MONEY(16,2);	
	DEFINE iMovtoServ            INTEGER;
	DEFINE iMovtoCargoServ       INTEGER;
    DEFINE cDescripcion          CHAR(40); 
    DEFINE cMoneda               CHAR(3);
	DEFINE mPaisImporte			 MONEY;
	DEFINE vfec_nac              CHAR(10);
	DEFINE vcuenta			     INTEGER;	
	DEFINE cTranret			 	 CHAR(4);
	DEFINE dFechahoy			 DATE;
	DEFINE mSdodisp				 MONEY(14,2);
	DEFINE mMontoret			 MONEY(14,2);
	DEFINE cDescripcionRev       CHAR(80);
	
	DEFINE cChannelType			   CHAR(4);
	DEFINE cChannelName			   CHAR(4);
	DEFINE cChannelVersion		   CHAR(4);
	DEFINE cFrsIdentifier		   CHAR(11);
	DEFINE cFrsCounterId		   CHAR(13);
	DEFINE cErrorDesc			   CHAR(30);
	DEFINE cTempleteId			   CHAR(10);
	DEFINE cNoreintentos		   CHAR(1);
	DEFINE cUsuario				   CHAR(8);
	DEFINE fechahorainsertCURRENT  CHAR(22);
	
	DEFINE cSegIdentFlag		   CHAR(1);
	DEFINE cContador			   SMALLINT;
	
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE pMarca1 VARCHAR(3);
	DEFINE cValidaPLDteldom INTEGER;
	DEFINE cCodErrAux			 CHAR(6);
	DEFINE cPaisOrigen			CHAR(3);
	DEFINE iCodPais				CHAR(3);
	DEFINE iValPais				INTEGER;
	DEFINE cDesc_error        	CHAR(150);
	DEFINE cCadena_ent        	CHAR(100);
	DEFINE cHora		      	CHAR(6);
	DEFINE cCod_err2          	CHAR(5);

	DEFINE pHoraOrigen      	CHAR(6);

	DEFINE vCajeroWU			CHAR(8);
	DEFINE vCentroCostosHrem	CHAR(4);
	DEFINE vUsuarioHrem			CHAR(8);
	
	
	-- Inicializacion de variables --
	LET cCodErr 				 = "00000";	
	LET cIdentificadorProceso 	 = "00";
    LET cRetCode2 				 = "00000";
	LET cRetCode3 				 = "00000";
	LET iSqlErr 				 = 0;
	LET vtransaccion			 = 0;
    LET mMontoServ               = 0;
	LET mMontoCargoServ          = 0;
	LET iMovtoServ               = 0;
	LET iMovtoCargoServ          = 0;
	LET cDescripcion             = '';
	LET cMoneda                  = '';
	LET cDescripcionRev          = '';
	
	LET cChannelType			 = '';
	LET cChannelName		     = '';
	LET cChannelVersion	         = '';
	LET cFrsIdentifier			 = '';
	LET cFrsCounterId		     = '';
	LET cErrorDesc				 = '';
	LET cTempleteId			     = '';
	LET cNoreintentos			 = '';
	LET cUsuario				 = '';
	LET fechahorainsertCURRENT	 = '';
	LET cSegIdentFlag 			 = '';
	LET cContador                = 0;
	LET cPaisOrigen				= '';		
	LET iCodPais				= '';	
	LET iValPais				= 0;
	LET cCadena_ent 	  		 = TRIM(NVL(pNumEmp,'NULL'))||"|" 
								||TRIM(NVL(pRefUno,'NULL'))||"|" 
								||TRIM(NVL(pFechaHoy,'NULL'));
	LET cHora		    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cDesc_error 			 = '';
	LET cCod_err2         		 = '00000';
	
	--SET DEBUG FILE TO '/home/c90302774/sp_pago_wu_web.out';
	--TRACE ON;
	
	-- Validar que ningun parametro obligatorio este vacio --
	LET pEmpresa			= NVL(pEmpresa			,"");
	LET pNombre1			= NVL(pNombre1			,"");
	LET pNombre2            = NVL(pNombre2          ,"");
	LET pApellidoPaterno    = NVL(pApellidoPaterno  ,"");
	LET pApellidoMaterno    = NVL(pApellidoMaterno  ,"");
	LET pFechaHoy           = NVL(pFechaHoy         ,"");
	LET pEstado             = NVL(pEstado           ,"");
	LET pMontoAPagar        = NVL(pMontoAPagar      ,"");
	LET pSucursal           = NVL(pSucursal         ,"");
	LET pMoneda             = NVL(pMoneda           ,"");
	LET pMontoMoneda        = NVL(pMontoMoneda      ,0);
	LET pRefUno             = NVL(pRefUno           ,"");
	LET pRetCode            = NVL(pRetCode          ,"");
	LET pDescError          = NVL(pDescError        ,"");
	LET pMtcn               = NVL(pMtcn             ,"");
	LET pNewMtcn            = NVL(pNewMtcn          ,"");
	LET pFolSucEmp          = NVL(pFolSucEmp        ,"");
	LET pEmisorNameType     = NVL(pEmisorNameType   ,"");
	LET pBenefNameType      = NVL(pBenefNameType    ,"");
	LET pMoneyTransKey      = NVL(pMoneyTransKey    ,"");
	LET pNumRefRp           = NVL(pNumRefRp         ,"");
	LET pFusionStatus       = NVL(pFusionStatus     ,"");
	LET pEmisorCodMoneda    = NVL(pEmisorCodMoneda  ,"");
	LET pBenefEdo           = NVL(pBenefEdo         ,"");
	LET pSystemIdRp         = NVL(pSystemIdRp       ,"");
	LET pTelefonoCasa       = NVL(pTelefonoCasa     ,"");
	LET pTelefonoCelular    = NVL(pTelefonoCelular  ,"");
	LET pCategoria          = NVL(pCategoria        ,"");
	LET pConvenio           = NVL(pConvenio         ,"");
	LET pRefDos             = NVL(pRefDos           ,"");
	LET pFormaPago          = NVL(pFormaPago        ,"");
	LET peMontoTotal        = NVL(peMontoTotal      ,0);
	LET peImpComConv        = NVL(peImpComConv      ,0);
	LET peIvaComConv        = NVL(peIvaComConv      ,0);
	LET peImpComCte         = NVL(peImpComCte       ,0);
	LET peIvaComCte         = NVL(peIvaComCte       ,0);
	LET pNumEmp             = NVL(pNumEmp           ,"");
	LET pFolsuc             = NVL(pFolsuc           ,"");
	LET pTransSuc           = NVL(pTransSuc         ,"");
	LET pTranEquivCargo     = NVL(pTranEquivCargo   ,"");
	LET pTransSucRef        = NVL(pTransSucRef      ,"");
	LET pCuentaCargo        = NVL(pCuentaCargo      ,"");
	LET pCheque             = NVL(pCheque           ,"");
	LET pMontoTotalRef      = NVL(pMontoTotalRef    ,0);
	LET pDivisa             = NVL(pDivisa           ,"");
	LET pReferenciaCargo    = NVL(pReferenciaCargo  ,"");
	LET pNumTarjeta         = NVL(pNumTarjeta       ,"");
	LET pUsuAutoriza        = NVL(pUsuAutoriza      ,"");
	LET pTranEquivAbono     = NVL(pTranEquivAbono   ,"");
	LET pCuentaAbono        = NVL(pCuentaAbono      ,"");
	LET pDocto              = NVL(pDocto            ,0);
	LET pMontoFirme         = NVL(pMontoFirme       ,0);
	LET pMtoSBC             = NVL(pMtoSBC           ,0);
	LET pMtoRem             = NVL(pMtoRem           ,0);
	LET pDiasRet            = NVL(pDiasRet          ,0);
	LET pReferenciaAbono    = NVL(pReferenciaAbono  ,"");
	LET pMtcnConf           = NVL(pMtcnConf         ,"");
	LET pCiudad             = NVL(pCiudad           ,"");
	LET pEstadoConf         = NVL(pEstadoConf       ,"");
	LET pForeignRefNumRq    = NVL(pForeignRefNumRq  ,"");
	LET pForeingRefNumRp    = NVL(pForeingRefNumRp  ,"");
	LET pConfPago           = NVL(pConfPago         ,"");
	LET pNumCte			    = NVL(pNumCte			,"");
	LET pMarca			    = NVL(pMarca			,"");
	LET pFechaPag			= NVL(pFechaPag			,"");
	LET vcuenta             = 0;
	LET pCodigoPostalBenef1  = NVL(pCodigoPostalBenef1,"");
	LET pDirLinea1Benef     = NVL(pDirLinea1Benef   ,"");
	LET pDirLinea2Benef     = NVL(pDirLinea2Benef   ,"");
	LET pTelCasaBenef       = NVL(pTelCasaBenef     ,"");
	LET pTelCelBenef        = NVL(pTelCelBenef		,"");
	
	
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET pMarca1 = '';
	LET cValidaPLDteldom = 0;
	LET cCodErrAux = "000000";

	LET pHoraOrigen =(SELECT replace(substr(current,12,8),':','') FROM bdisac:sac_fechas);

	LET vCajeroWU = (SELECT first 1 ejecutivo FROM bdinteg:"informix".si_ejecut WHERE empresa = '001' AND sucursal=pSucursal and password <> 'BAJA' and nombramiento like 'CAJERO%');
	LET vCentroCostosHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87121);
	LET vUsuarioHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87122);

	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	 
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodErr = iSqlErr;
			LET cDesc_error = 'Error no controlado.';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			RETURN NVL(cCodErr,""), NVL(cIdentificadorProceso,""), NVL(cRetCode2,""), NVL(cChannelType,""), NVL(cChannelName,""), NVL(cChannelVersion,""), NVL(cFrsIdentifier,""), NVL(cFrsCounterId,"");
		END IF;
	END EXCEPTION;
	
	--Manejo de transacciones
	ON EXCEPTION IN (-535)
        let vtransaccion = 1;
    END EXCEPTION WITH resume;
	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		BEGIN WORK;
	END IF;
	
	--valpais
	SELECT LIMIT 1 emisor_cod_pais INTO cPaisOrigen FROM sac_wu_search WHERE fecha_insert >= today AND txn_status = 'A' AND emisor_cod_pais <> '' AND retcode = '00000' AND mtcn = pRefUno;
	
	IF cPaisOrigen = '' OR cPaisOrigen IS NULL THEN
		
		LET cCodErr = "00001";
		LET cIdentificadorProceso = "12";
		LET cRetCode2 = "00222";
		LET cDesc_error = 'No cuenta con registros en la sac_wu_search';
		
		INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
		VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
		
		RETURN NVL(cCodErr,""), NVL(cIdentificadorProceso,""), NVL(cRetCode2,""), NVL(cChannelType,""), NVL(cChannelName,""), NVL(cChannelVersion,""), NVL(cFrsIdentifier,""), NVL(cFrsCounterId,"");
	
	END IF;
	
	select pais into iCodPais from sac_paises_permitidos where wun = cPaisOrigen;
	
	select count(*) into iValPais from bdinteg:si_paises_remesadoras where id_remesadora = '3' and id_pais = iCodPais;
	
	if iValPais = 0 THEN
	
				LET cCodErr = "00001";
				LET cIdentificadorProceso = "10";
				LET cRetCode2 = "00222";
				LET cDesc_error = 'Pais restringido';
				
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			
				RETURN NVL(cCodErr,""), NVL(cIdentificadorProceso,""), NVL(cRetCode2,""), NVL(cChannelType,""), NVL(cChannelName,""), NVL(cChannelVersion,""), NVL(cFrsIdentifier,""), NVL(cFrsCounterId,"");
			
	END IF;
	
	--Se obtiene el valor de identificador del pago para saber si es la segunda ejecucion para la SEGUNDA IDENTIFICACION, PAGO o DESPAGO
	LET cSegIdentFlag = SUBSTRING(pRefDos FROM 2 FOR 1);
	LET pRefDos = SUBSTRING(pRefDos FROM 1 FOR 1);
	
	IF cSegIdentFlag = 'D' THEN
		--falta un parametro para poder ejecutar el sp de parametros para el servicio para desbloquear la remesa
		IF pEmpresa = "" OR pNumEmp = "" OR pMarca = "" THEN
			LET cCodErr = "00003";
		ELSE 
			--SP que obtiene los parametros para el servicio de WU/VG/OV
			
			IF pCanalOrigen='CPL' THEN 
				EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, vCajeroWU, pMarca, CURRENT) INTO cRetCode2, cErrorDesc, cChannelType, cChannelName, cChannelVersion, cFrsIdentifier, cFrsCounterId, cTempleteId, cNoreintentos, cUsuario, fechahorainsertCURRENT;
			ELSE
				EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, pNumEmp, pMarca, CURRENT) INTO cRetCode2, cErrorDesc, cChannelType, cChannelName, cChannelVersion, cFrsIdentifier, cFrsCounterId, cTempleteId, cNoreintentos, cUsuario, fechahorainsertCURRENT;
			END IF;
			
		END IF;
	
	--Se valida que ninguna variable de entrada este vacia 
	ELIF pEmpresa = "" OR pNombre1 = "" OR pApellidoPaterno = "" OR pFechaHoy = "" OR pEstado = "" OR pMontoAPagar = "" OR pSucursal = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pRefUno = "" OR pRetCode = "" OR pDescError = "" OR pMtcn = "" OR pNewMtcn = "" OR pFolSucEmp = "" OR pEmisorNameType = "" OR pBenefNameType = "" OR pMoneyTransKey = "" OR pNumRefRp = "" OR pFusionStatus = "" OR pEmisorCodMoneda = "" OR pBenefEdo = "" OR pSystemIdRp = "" OR pTelefonoCasa = "" OR pCategoria = "" OR pConvenio = "" OR pRefDos = "" OR (pFormaPago <> "1" AND pNumTarjeta = "" AND pCuentaAbono = "") OR peMontoTotal = 0 OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR (pTranEquivCargo = "" AND pTranEquivAbono = "") OR (pFormaPago <> "1" AND pTransSucRef = "") OR pCuentaCargo = "" OR pCheque = "" OR pMontoTotalRef = 0 OR pDivisa = "" OR pReferenciaCargo = "" OR (pFormaPago <> "1" AND pTranEquivAbono = "") OR (pFormaPago <> "1" AND pCuentaAbono = "") OR pMontoFirme = "" OR pMtoSBC = "" OR pMtoRem = "" OR pDiasRet = "" OR (pFormaPago <> "1" AND pReferenciaAbono = "") OR pMtcnConf = "" OR pCiudad = "" OR pEstadoConf = "" OR ptFechaHora = "" OR ptFechaInsert = "" OR pForeignRefNumRq = "" OR pForeingRefNumRp = "" OR pConfPago = "" OR pMarca = "" THEN
			LET cCodErr = "00001";	
	ELSE
		
		--Validacion solicitada por PLD para limites de Direcciones y Telefonos ingresados en el cobro de remesas sp_sac_pldlim_teldom
			--cIdentificadorProceso = "12"
			
		LET cDia = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
		LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 7 FOR 2), 2, '0');
		--LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
		LET cAnio = LPAD(SUBSTRING(pFechaHoy FROM 1 FOR 4), 4, '0');	
		
		IF pMarca = 'OV' THEN 
			LET pMarca1 = 'OVA';
		ELIF pMarca = 'VG' THEN
			LET pMarca1 = 'VIG';
		ELSE 
			LET pMarca1 = 'WUN';
		END IF;
		
		IF pCanalOrigen='CPL' THEN 
			EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,vUsuarioHrem,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;
		ELSE
			EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,pNumEmp,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;
		END IF;

		IF cRetCode2 <> '00000' THEN
			--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
			LET cRetCode2 = "01245";
			LET cIdentificadorProceso = "02";
			LET cCodErrAux = '999999';
			LET cDesc_error = 'Error en sp sp_sac_pldlim_teldom';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
		ELSE
			--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom en caso de reversion de la operacion
			LET cValidaPLDteldom = 1;
		
			--SP que obtiene los parametros para el servicio de WU/VG/OV
			IF pCanalOrigen='CPL' THEN 
				EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, vCajeroWU, pMarca, CURRENT) INTO cRetCode2, cErrorDesc, cChannelType, cChannelName, cChannelVersion, cFrsIdentifier, cFrsCounterId, cTempleteId, cNoreintentos, cUsuario, fechahorainsertCURRENT;
			ELSE
				EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, pNumEmp, pMarca, CURRENT) INTO cRetCode2, cErrorDesc, cChannelType, cChannelName, cChannelVersion, cFrsIdentifier, cFrsCounterId, cTempleteId, cNoreintentos, cUsuario, fechahorainsertCURRENT;
			END IF;
		
			IF cRetCode2 <> "00000" THEN
				LET cIdentificadorProceso = "11";
				LET cDesc_error = 'Error en sp sp_wu_obtparamsgenerales';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			ELSE
				--Verificar si existe el registro en la tabla sac_movimientos
				SELECT COUNT(*)
				INTO cContador
				FROM bdisac:"informix".sac_movimientos
				WHERE id_sucursal = pSucursal 
				AND numcategoria = pCategoria 
				AND numconvenio = pConvenio
				AND referencia1 = pRefUno 
				AND referencia2 = pRefDos 
				AND folio_suc = pFolsuc
				AND status_cancelado = 'N';
				
				IF cContador = 0 AND cSegIdentFlag = 'N' THEN
					--Se validan los numeros de telefono
					CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefonoCasa, pTelefonoCelular, "")
					RETURNING cRetCode2, cFlagTelCasa, cFlagTelCel, cFlagTelOficina;
					IF cFlagTelCasa <> "1" AND (cFlagTelCel <> "1" AND pTelefonoCelular <> "") THEN
						LET cRetCode2 = "00003";
						LET cIdentificadorProceso = "08";
						LET cDesc_error = 'Telefonos no validos';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
					ELIF cFlagTelCasa <> "1" THEN
						LET cRetCode2 = "00001";
						LET cIdentificadorProceso = "08";
						LET cDesc_error = 'Telefono de casa no valido';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
					ELIF cFlagTelCel <> "1" AND pTelefonoCelular <> "" THEN
						LET cRetCode2 = "00002";
						LET cIdentificadorProceso = "08";
						LET cDesc_error = 'Telefono movil no valido';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
					ELSE
						--Se validan los montos
						LET pFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 2)||SUBSTRING(pFechaHoy FROM 7 FOR 2)||SUBSTRING(pFechaHoy FROM 1 FOR 4);
						EXECUTE PROCEDURE "informix".sp_validamontoremesawu_web(pEmpresa, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, pFechaNacimiento, pFechaHoy, pEstado, pMontoAPagar, pSucursalOrigen, pMoneda, pMontoMoneda, pRefUno, pRetCode, pDescError, pMtcn, pNewMtcn, pForeignRefNumRq, pEmisorNameType, pBenefNameType, pMoneyTransKey, pForeingRefNumRp, pFusionStatus, pMoneda, pBenefEdo, pSystemIdRp) INTO cRetCode2;
						
						IF cRetCode2 <> "00000" THEN
							LET cIdentificadorProceso = "02";
							LET cDesc_error = 'Error en sp sp_validamontoremesawu_web';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
						ELSE
							--Registrar movimientos
							IF pCanalOrigen='CPL' THEN 
								CALL "informix".sp_grabapagoservicio_hs(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFormaPago, peMontoTotal, peImpComConv, peIvaComConv, peImpComCte, peIvaComCte, pCuentaAbono, vUsuarioHrem, pFolsuc, pTransSuc, pFechaPag, pCanalOrigen, pSucursalOrigen, pCajaOrigen, pTransSuc, pHoraOrigen, pFolioOrigen, pCampoGenerico1, pCampoGenerico2)
								RETURNING cRetCode2;
							ELSE 
								CALL "informix".sp_grabapagoservicio_hs(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFormaPago, peMontoTotal, peImpComConv, peIvaComConv, peImpComCte, peIvaComCte, pCuentaAbono, pNumEmp, pFolsuc, pTransSuc, pFechaPag, pCanalOrigen, pSucursalOrigen, pCajaOrigen, pTransSuc, pHoraOrigen, pFolioOrigen, pCampoGenerico1, pCampoGenerico2)
								RETURNING cRetCode2;
							END IF;
							
							
							IF vtransaccion = 1 THEN
								COMMIT WORK;
								BEGIN WORK;
							ELSE
								BEGIN WORK;
							END IF;
							
							IF cRetCode2 <> "00000" THEN
								LET cIdentificadorProceso = "03";
								LET cDesc_error = 'Error en sp sp_grabapagoservicio_hs';
								INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
								VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
							ELSE
								--Busco datos de query
								EXECUTE PROCEDURE "informix".sp_obtieneremadic(pCategoria, '999', pMtcn)
								INTO cRetCode2, cMoneda, mPaisImporte;
	
								--Actualizo tabla de datos para limites de remesas mensuales
								LET vfec_nac = SUBSTRING(pFechaNacimiento FROM 3 FOR 2) || SUBSTRING(pFechaNacimiento FROM 1 FOR 2) || SUBSTRING(pFechaNacimiento FROM 5 FOR 4);
								EXECUTE PROCEDURE "informix".sp_actualizaremesa(pCategoria, pConvenio, pMtcn, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, vfec_nac, cMoneda, mPaisImporte)
								INTO cRetCode2, vcuenta;
								
								IF cRetCode2 <> "00000" THEN
									LET cIdentificadorProceso = "09";
									LET cDesc_error = 'Error en sp sp_actualizaremesa';
									INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
									VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
								ELSE
									
									IF pFormaPago = "1" THEN
										LET pTransSucRef = pTransSuc;
									END IF;	

									--Llamado a sp para aplicar el cargo
									IF pCanalOrigen='CPL' THEN 
										CALL bdicheq:"informix".cargo_ref(pEmpresa, vCentroCostosHrem, vUsuarioHrem, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)	
										RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;
									ELSE
										CALL bdicheq:"informix".cargo_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)	
										RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;
									END IF;
									
									
									IF cRetCode2 <> "000" THEN
										LET cIdentificadorProceso = "07";
										LET cDesc_error = 'Error en sp cargo_ref';
										INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
										VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
									ELSE
										--Se valida que la forma de pago fue en efectivo para evitar el llamado a el sp abono_ref
										IF pFormaPago <> "1" THEN
											--Llamado a sp para el cargo a la cuenta
											IF pCanalOrigen='CPL' THEN
												CALL bdicheq:"informix".abono_ref(pEmpresa, vCentroCostosHrem, vUsuarioHrem, pTranEquivAbono, pTransSucRef, pFolsuc, pCuentaAbono, pDocto, pMontoTotalRef, pMontoFirme, pMtoSBC, pMtoRem, pDiasRet, pDivisa, pReferenciaAbono, pNumTarjeta, pUsuAutoriza)
												RETURNING cRetCode2;
											ELSE
												CALL bdicheq:"informix".abono_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivAbono, pTransSucRef, pFolsuc, pCuentaAbono, pDocto, pMontoTotalRef, pMontoFirme, pMtoSBC, pMtoRem, pDiasRet, pDivisa, pReferenciaAbono, pNumTarjeta, pUsuAutoriza)
												RETURNING cRetCode2;
											END IF;
											
										END IF;
										IF cRetCode2 <> "000" THEN
											LET cIdentificadorProceso = "05";
											LET cDesc_error = 'Error en sp abono_ref';
											INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
											VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
										ELSE
											-- Llamado al sp para validar los montos
											IF pCanalOrigen='CPL' THEN
												SELECT * INTO cRetCode2,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ 
												FROM TABLE(bdicheq:"informix".sp_mini21(pEmpresa,vUsuarioHrem,vCentroCostosHrem,pFolsuc));
											ELSE
												SELECT * INTO cRetCode2,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ 
												FROM TABLE(bdicheq:"informix".sp_mini21(pEmpresa,pNumEmp,pSucursal,pFolsuc));
											END IF;


											IF cRetCode2 <> "00000" THEN
												LET cIdentificadorProceso = "06";
												LET cDesc_error = 'Error en sp sp_mini21';
												INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
												VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
											ELSE
												--Verificar que no hay descuadre en caja
												IF mMontoCargoServ = pValorCargo AND mMontoServ = pValorAbono THEN
													-- Llamado para confirmar el pago
													IF pCanalOrigen='CPL' THEN
														CALL "informix".sp_confpagoservicio(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
														RETURNING cRetCode2, cDescripcion;
													ELSE
														CALL "informix".sp_confpagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
														RETURNING cRetCode2, cDescripcion;
													END IF;
													
													
													IF cRetCode2 <> "00000" THEN
														LET cIdentificadorProceso = "04";
														LET cDesc_error = 'Error en sp sp_confpagoservicio';
														INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
														VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
													END IF;
												ELSE
													-- Hay descuadre en caja
													LET cCodErr = '00002';
												END IF;
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				ELSE 
					LET cDesc_error = 'Remesa pagada anteriormente';
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				END IF;
			END IF;
		END IF;	
	END IF;
	
	
	IF cIdentificadorProceso != '00' THEN
		IF cCodErrAux != '999999' THEN 
			IF cValidaPLDteldom = 1 THEN
				IF pCanalOrigen='CPL' THEN 
					EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,vUsuarioHrem,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
				ELSE
					EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,pNumEmp,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
				END IF;
			END IF;	
		END IF;
	END IF;
	
	RETURN NVL(cCodErr,""), NVL(cIdentificadorProceso,""), NVL(cRetCode2,""), NVL(cChannelType,""), NVL(cChannelName,""), NVL(cChannelVersion,""), NVL(cFrsIdentifier,""), NVL(cFrsCounterId,"");
END
END PROCEDURE;