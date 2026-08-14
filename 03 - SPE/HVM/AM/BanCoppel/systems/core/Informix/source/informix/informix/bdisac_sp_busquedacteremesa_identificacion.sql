CREATE PROCEDURE "informix".sp_busquedacteremesa_identificacion(pNumIdentificacion CHAR(30))
RETURNING
CHAR(5)  AS  cCodRet,
CHAR(20) AS  cNumcte,
CHAR(1)  AS  iTipoCliente,
CHAR(5)  AS	 cValIne,
CHAR(5)  AS	 cListaNegra,
CHAR(5)	 AS	 cSespecial;

DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(20);
DEFINE iTipoCliente	CHAR(1);
DEFINE cValIne		CHAR(5);
DEFINE cResultINE	CHAR(50);
DEFINE cListaNegra	CHAR(5);
DEFINE cSespecial	CHAR(5);
DEFINE cStatuscte	CHAR(1);

DEFINE iSqlErr      INTEGER; 
DEFINE iIsamErr    	INTEGER; 
DEFINE cInfoErr 	CHAR(10); 

DEFINE icontEsp 	INTEGER;
DEFINE iContList	INTEGER;

--EPG
DEFINE cSituacion   CHAR(5);
DEFINE cCausa       CHAR(5);
DEFINE cRfc			CHAR(13);
DEFINE iContListRfc	INTEGER;

LET cCodRet	= "00000";
LET cNumcte = "0";
LET iTipoCliente = "0";
LET cValIne = "False";
LET cListaNegra = "False";
LET cSespecial = "False";
LET cStatuscte = "";
LET icontEsp 	 = 0;
LET iContList 	 = 0;

LET pNumIdentificacion = TRIM(pNumIdentificacion);

--EPG
LET cSituacion  = '';
LET cCausa      = '';
LET cRfc 		= '';
LET iContListRfc = 0;


--SET DEBUG FILE TO '/home/c90303528/sp_busquedacteremesa_identificacion.log';
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT FIRST 1  cterem.numcte, "1", cterem.status_cte, cte.rfc
	INTO cNumcte, iTipoCliente, cStatuscte, cRfc
	FROM bdinteg:"informix".si_cliente cte INNER JOIN
	bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte INNER JOIN
	bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
	WHERE ctepf.numidentifi = pNumIdentificacion;
			
	IF NVL(cNumcte,"") = "" THEN
		SELECT FIRST 1 cte.numcte, "2", cte.rfc
		INTO cNumcte, iTipoCliente, cRfc
		FROM bdinteg:"informix".si_cliente cte INNER JOIN
		bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
		WHERE ctepf.numidentifi = pNumIdentificacion AND cte.tipo_cliente in("1","2");
		
		IF NVL(cNumcte,"") = "" THEN
			LET cNumcte = "000000000";
			LET iTipoCliente = "3";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	ELSE
		IF TRIM(cStatuscte) <> "A" THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
		END IF;
	END IF;
	
	SELECT resultado 
	INTO cResultINE
	FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte AND fecha = (SELECT MAX(fecha) FROM bdinteg:"informix".si_bitacora_ife WHERE numcte = cNumcte);
	
	IF (TRIM(NVL(cResultINE,"")) = "") OR (UPPER(TRIM(cResultINE)) = "VERDADERO") OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN
		LET cValIne = "True";
	ELIF (UPPER(TRIM(cResultINE)) = "FALSO") OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN
		LET cValIne = "False";
	END IF;
	
  --IF EXISTS(SELECT * FROM bdiauditor:"informix".tbl_listainterna WHERE numcte = pNumCte) THEN
	SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna  WHERE numcte = cNumCte;
	SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
	LET iContList = iContList + iContListRfc;
	IF iContList > 0 THEN
		LET cListaNegra = "True";
	ELSE
		LET cListaNegra = "False";
	END IF;
	
  --IF EXISTS(SELECT * FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumCte) THEN
	SELECT COUNT(*) INTO icontEsp FROM bdisitesp:"informix".se_ctessitespcte where numcte = cNumCte;
	IF icontEsp > 0 THEN
		SELECT situacion, causa INTO cSituacion, cCausa FROM bdisitesp:"informix".se_ctessitespcte where numcte = cNumCte;
		LET cSituacion = TRIM(cSituacion)||TRIM(cCausa);
		IF 	cSituacion IN ('F42','P72','P108','U60') THEN
			LET cSespecial = "True";
		ELSE
			LET cSespecial = "False";
		END IF;
	ELSE
		LET cSespecial = "False";
	END IF;
	
	
	RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 433 REQ. Base de datos para el alta de usuarios de remesas',
'Autor: 98243217 Marco Rivera ',
'Fecha: 16/08/2018',
'Descripcion: Verifica e identifica el tipo de cliente realizando la busqueda por numero de identificacion.',
'Solicita: Leonardo Hernandez',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------',
'Folio: 496',
'Autor: 98243217 Marco Rivera ',
'Fecha: 23/10/2018',
'Descripcion: Se agrega validacion para la busqueda en si_bitacora_ife.',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_pago_remesas_cpl(
	pSucursal   		CHAR (4),
	pCategoria      	CHAR (2),
	pConvenio      		CHAR (5),
	pRefUno        		CHAR (20),
	pRefDos        		CHAR (20),
	pFormaPago     		CHAR (1),
	pMontoTotal    		DECIMAL (10,2),
	pImpComConv     	DECIMAL (6,2),
	pIvaComConv    		DECIMAL (6,2),
	pImpComCte     		DECIMAL (6,2),
	pIvaComCte     		DECIMAL (6,2),
	pNumEmp        		CHAR (8),
	pFolsuc        		CHAR (16),
	pTransSuc      		CHAR (4),
	pFechaPag      		DATE,
	pEmpresa     		CHAR (3),
	pNumcte				CHAR (9),
	pNombre1 			CHAR (40),
	pNombre2 			CHAR (40),
	pApellidoPat		CHAR (40),
	pApellidoMat		CHAR (40),
	pFechaNac			CHAR (8),
	pFechaHoy		 	CHAR (8),
	pMontoAPagar	 	CHAR (20),
	pMoneda 			CHAR (3),
	pMontoMoneda		MONEY (14,2),
	pTelefonoCasa 		CHAR (10),
	pTelefonoCel		CHAR (10),
	pAdress				VARCHAR(80),
	pCity				VARCHAR(40),
	pStateCodeAdr		VARCHAR(3),
	pZipCode 			VARCHAR(10),
	pCanalOrigen		CHAR(4),
	pCajaOrigen			CHAR(2),
	pSucursalOrigen		CHAR(4),
	pFolioOrigen		CHAR(16),
	pCodigoEstadoSuc	CHAR(20),
	pOcupacion        	CHAR(3),
	pParentesco       	CHAR(3),
	pRazonEnvio       	CHAR(3)
	)

	RETURNING CHAR (5) AS RetCode, CHAR (2) AS IdentificadorProceso, CHAR (5) AS RetCode2, CHAR(5) AS TransaccInt, CHAR(5) AS TransServicio, CHAR(2) AS NumIntentos, CHAR(3) AS ApprizaCode, CHAR(3) AS ChannelId, CHAR(15) AS LocationUnit, CHAR(3) AS TypeCode, CHAR(3) AS StateCode, CHAR(3) AS CountryCode, CHAR(3) AS Nacionalidad,CHAR(9) AS Numcte,CHAR(3) AS EstadoBenef , CHAR(20) AS TaxIdentificationNumber, CHAR(8) AS SupervisorId, CHAR(3) AS ProofOfDomicileTypeCode, CHAR(40) AS ProofOfDomicileDescription, CHAR(40) AS ProofOfDomicileReferenceNumber ,
	CHAR(300) AS BiometricAuthentication, CHAR(1) AS Genero, CHAR(20) AS UniqueResidentNumber ;

	-- Definicion de variables --
	DEFINE cTaxIdentificationNumber			CHAR(20);		--Datos nuevos para TN
	DEFINE cSupervisorId					CHAR(8);		--Datos nuevos para TN
	DEFINE cProofOfDomicileTypeCode			CHAR(3);		--Datos nuevos para TN
	DEFINE cProofOfDomicileDescription		CHAR(40);		--Datos nuevos para TN
	DEFINE cProofOfDomicileReferenceNumber	CHAR(40);		--Datos nuevos para TN
	DEFINE cBiometricAuthentication			CHAR(300);		--Datos nuevos para TN
	DEFINE cGenero							CHAR(1);		--Datos nuevos para TN
	DEFINE cUniqueResidentNumber			CHAR(20);		--Datos nuevos para TN

	DEFINE cNacionalidad		CHAR(3);	--campos nuevos
	DEFINE cEstadoBenef			CHAR(3);	--campos nuevos
	DEFINE cIdEstadoBenef		CHAR(3);
	DEFINE cYear					CHAR(4);
	DEFINE cDay				CHAR(4);
	DEFINE cMonth					CHAR(4);
	DEFINE cDoB DATE;
	DEFINE cIdNacionalidad		CHAR(3);
	DEFINE cTipoCliente			CHAR(2);
	DEFINE cValIne				CHAR(5);
	DEFINE cListaNegra			CHAR(5);
	DEFINE cSespecial			CHAR(5);

	DEFINE cCodErr 				 CHAR (5);
	DEFINE cIdentificadorProceso CHAR (2);
	DEFINE cRetCode2			 CHAR (5);
	DEFINE cFlagTelCel			 CHAR (1);
	DEFINE cFlagTelCasa			 CHAR (1);
	DEFINE cFlagTelOficina		 CHAR (1);
	DEFINE cCuenta				 CHAR(20);
	DEFINE cNoCte				 CHAR(20);
	DEFINE cApellPaterno		 CHAR(26);
	DEFINE cApellMaterno		 CHAR(26);
	DEFINE cNombre1				 CHAR(26);
	DEFINE cNombre2				 CHAR(26);
	DEFINE cRazonSocial		 	 CHAR(60);
	DEFINE cStatusCuenta	 	 CHAR(1);
	DEFINE mSdoDisponible	 	 MONEY(14,2);
	DEFINE mSdoRetenido		 	 MONEY(14,2);
	DEFINE mSdoCCC			 	 MONEY(14,2);
	DEFINE mSdoCCCDisp		 	 MONEY(14,2);
	DEFINE mSdoCuenta		 	 MONEY(14,2);
	DEFINE cTipoLinea		 	 CHAR(1);
	DEFINE cDescripcion1	 	 CHAR(40);
	DEFINE cDescripcion2	 	 CHAR(40);
	DEFINE mSaldoT1			 	 MONEY(14,2);
	DEFINE mSdoCongelado	 	 MONEY(14,2);
	DEFINE mSdoSBC			 	 MONEY(14,2);
	DEFINE cUsuarioBloqueo	 	 CHAR(8);
	DEFINE dFechaBloqueo	 	 DATE;
	DEFINE cCuentaClave		 	 CHAR(18);
	DEFINE dFechaExpTarjeta	 	 DATE;
	DEFINE cTranret			 	 CHAR(4);
	DEFINE dFechahoy			 DATE;
	DEFINE mSdodisp				 MONEY(14,2);
	DEFINE mMontoret			 MONEY(14,2);
	DEFINE cDescripcion			 CHAR(200);
	DEFINE iSqlErr               INTEGER;
	DEFINE cNoTarjeta			 CHAR(16);
	DEFINE dFecha			 	 DATE;
	DEFINE cTransaccInt			 CHAR(5);
	DEFINE cTransServicio		 CHAR(5);
	DEFINE cNumIntentos			 CHAR(2);
	DEFINE cApprizaCode			 CHAR(3);
	DEFINE cChannelId		     CHAR(3);
	DEFINE cLocationUnit	     CHAR(15);
	DEFINE cTypeCode			 CHAR(3);
	DEFINE cStateCode		     CHAR(3);
	DEFINE cCountryCode	         CHAR(3);
	DEFINE cFechaHoy			 CHAR(8);
	DEFINE cFechaNac			 CHAR(8);
	DEFINE vtransaccion			 SMALLINT;
	DEFINE v_fecha_nac 			 DATE;
	DEFINE vCuenta				 INTEGER;
	DEFINE cCodErrAux			 CHAR(6);
	DEFINE vCentroCostosHrem     CHAR(4);
	DEFINE cMes 				 CHAR(2);
	DEFINE cDia 				 CHAR(2);
	DEFINE cAnio				 CHAR(4);
	DEFINE cRfc 				 CHAR(13);
	DEFINE cValidaPLDteldom 	 INTEGER;
	DEFINE pHoraOrigen      	 CHAR(6);
	DEFINE cDesc_error        	 CHAR(150);
	DEFINE cPaisOrigen          CHAR(3);
	DEFINE iCodPais             CHAR(3);
	DEFINE iValPais             INTEGER;




	-- Inicializacion de variables --
	LET cTaxIdentificationNumber = 'BSI061110963';			--Datos nuevos para TN
	LET cSupervisorId = '';						--Datos nuevos para TN
	LET cProofOfDomicileTypeCode = '';			--Datos nuevos para TN
	LET cProofOfDomicileDescription = '';		--Datos nuevos para TN
	LET cProofOfDomicileReferenceNumber = '';	--Datos nuevos para TN
	LET cBiometricAuthentication = '';			--Datos nuevos para TN
	LET cGenero = '';							--Datos nuevos para TN
	LET cUniqueResidentNumber='';				--Datos nuevos para TN
	
	
	LET cNacionalidad				= "";		--campos nuevos
	LET cEstadoBenef				= "";		--campos nuevos
	LET cIdNacionalidad				= "";
	LET cIdEstadoBenef				= "";
	LET cYear= "";
	LET cDay = "";
	LET cMonth  ="";
	LET cDoB = "";

	LET cTipoCliente				= "";
	LET cValIne						= "";
	LET cListaNegra					= "";
	LET cSespecial					= "";

	LET cCodErr 					= "00000";
	LET cIdentificadorProceso		= "00";
  	LET cRetCode2 					= "00000";
	LET cFlagTelCel					= "1";
	LET cFlagTelCasa				= "1";
	LET cFlagTelOficina				= "1";
	LET cDescripcion  				= "";
	LET iSqlErr						= 0;
	LET cNoTarjeta 					= "";
	LET cNoCte						= "";
	LET	cTransaccInt				= "";
	LET	cTransServicio	        	= "";
	LET	cNumIntentos		    	= "";
	LET	cApprizaCode		    	= "";
	LET	cChannelId		        	= "";
	LET	cLocationUnit	        	= "";
	LET	cTypeCode		        	= "";
	LET	cStateCode		        	= "";
	LET	cCountryCode		    	= "";
	LET cFechaHoy					= "";
	LET cFechaNac					= "";
	LET vtransaccion				= 0;
	LET cCodErrAux					= "000000";

	-- Validar que ningun parametro obligatorio este vacio --
	LET pSucursal   		= NVL(pSucursal, "");
	LET pCategoria      	= NVL(pCategoria, "");
	LET pConvenio      		= NVL(pConvenio, "");
	LET pRefUno        		= NVL(pRefUno, "");
	LET pRefDos        		= NVL(pRefDos, "");
	LET pFormaPago     		= NVL(pFormaPago, "");
	LET pMontoTotal    		= NVL(pMontoTotal, 0);
	LET pImpComConv     	= NVL(pImpComConv, 0);
	LET pIvaComConv    		= NVL(pIvaComConv, 0);
	LET pImpComCte     		= NVL(pImpComCte, 0);
	LET pIvaComCte     		= NVL(pIvaComCte, 0);
	LET pNumEmp        		= NVL(pNumEmp, "");
	LET pFolsuc        		= NVL(pFolsuc, "");
	LET pTransSuc      		= NVL(pTransSuc, "");
	LET pFechaPag      		= NVL(pFechaPag, "");
	LET pEmpresa     		= NVL(pEmpresa, "");
	LET pNombre1 			= NVL(pNombre1, "");
	LET pNombre2 			= NVL(pNombre2, "");
	LET pApellidoPat		= NVL(pApellidoPat, "");
	LET pApellidoMat		= NVL(pApellidoMat, "");
	LET pFechaNac			= NVL(pFechaNac, "");
	LET pFechaHoy 			= NVL(pFechaHoy, "");
	LET pMontoAPagar 		= NVL(pMontoAPagar, "");
	LET pMoneda 			= NVL(pMoneda, "");
	LET pMontoMoneda		= NVL(pMontoMoneda, 0);
	LET pTelefonoCasa 		= NVL(pTelefonoCasa, "");
	LET pTelefonoCel 		= NVL(pTelefonoCel, "");
	LET pAdress				= NVL(pAdress, "");
	LET pCity				= NVL(pCity, "");
	LET pStateCodeAdr		= NVL(pStateCodeAdr, "");
	LET pZipCode 			= NVL(pZipCode, "");
	LET vCentroCostosHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87119);
	LET cDia	= '';
  	LET cMes	= '';
  	LET cAnio	= '';
	LET cRfc	= '';
	LET cValidaPLDteldom	= 0;
	LET cDesc_error 			 = '';
	LET cPaisOrigen              = '';
	LET iCodPais                 = '';
	LET iValPais                 = 0;
	LET dFecha=CURRENT;



	LET pHoraOrigen =(SELECT replace(substr(current,12,8),':','') FROM bdisac:sac_fechas);

  --SET DEBUG FILE TO "/home/c90307738/cpl/sp_pago_remesas_cpl.log";
  --TRACE ON;

  SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
				LET cDesc_error = 'Error no controlado';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
			END IF;
		END EXCEPTION;

		ON exception in (-535)
			let vtransaccion = 1;
		END exception with resume;
		IF vtransaccion = 1 then
			COMMIT WORK;
		END IF;

   BEGIN WORK;
			--Validacion Paises Permitidos
		SELECT LIMIT 1 r_countrycode INTO cPaisOrigen FROM sac_app_qryi WHERE fecha >= today AND txn_status = 'A' AND r_countrycode <> '' AND r_code = '0000' AND unirefnum = pRefUno;
		IF cPaisOrigen = '' OR cPaisOrigen IS NULL THEN
			LET cCodErr = "00001";
			LET cIdentificadorProceso = "11";
			LET cRetCode2 = "00222";
			LET cDesc_error = 'No cuenta con registros en la sac_app_qryi';
		
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
		
			RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
		END IF;
		
		SELECT pais INTO iCodPais FROM sac_paises_permitidos WHERE appbts = cPaisOrigen;
		
		SELECT COUNT(*) INTO iValPais FROM bdinteg:si_paises_remesadoras WHERE id_remesadora = '1' AND id_pais = iCodPais;
		
		IF iValPais = 0 THEN
		
					LET cCodErr = "00001";
					LET cIdentificadorProceso = "10";
					LET cRetCode2 = "00222";
					LET cDesc_error = 'Pais restringido';
		
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);

					RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,cNacionalidad, pNumcte, cEstadoBenef, cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  cBiometricAuthentication, cGenero, cUniqueResidentNumber;
		
		END IF;

		--Se valida que ninguna variable de entrada este vacia
		IF pSucursal = "" OR pCategoria = "" OR pConvenio = "" OR pRefUno = "" OR pFormaPago = "" OR pMontoTotal = 0  OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR pEmpresa = "" OR pNombre1 = "" OR pApellidoPat = "" OR pFechaNac = "" OR pFechaHoy = "" OR pMontoAPagar = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pTelefonoCasa = ""  OR pCodigoEstadoSuc = "" THEN
				LET cCodErr = "00001";
		ELSE

			--consultas para obtener los campos nuevos (nacionalidad,numero de cliente y estado beneficiario)
			--LET cYear= SUBSTRING(pFechaNac FROM 1 FOR 4);
			--LET cMonth = LPAD(SUBSTRING(pFechaNac FROM 5 FOR 6),2,'0');
			--LET cDay = LPAD(SUBSTRING(pFechaNac FROM 7 FOR 8),2,'0');
--
			--LET cDoB = MDY(cMonth,cDay,cYear);

			--CALL bdisac:"informix".sp_validausuarioremesa(pNombre1,pNombre2,pApellidoPat,pApellidoMat,cDoB)
			--RETURNING cRetCode2,pNumcte,cTipoCliente,cValIne,cListaNegra,cSespecial,cRFC; -- Se obtiene el numero de cliente

			--IF cRetCode2 ='00000' THEN
				SELECT  a.nacionalidad, a.sexo, b.rfc
				INTO	cIdNacionalidad, cGenero, cUniqueResidentNumber
				FROM	bdinteg:si_ctepf a
				INNER JOIN bdinteg:si_cliente b ON a.numcte=b.numcte
				WHERE 	a.numcte = pNumcte; --Se obtiene id de nacionalidad y genero del cliente

				SELECT	cve_pais
				INTO	cNacionalidad
				FROM	bdisac:sac_app_nacionalidad
				WHERE	cod_nacionalidad = cIdNacionalidad; -- Se obtiene la nacionalidad del beneficiario

				SELECT  FIRST 1 estado
				INTO	cIdEstadoBenef
				FROM	bdinteg:si_direcciones_actual
				WHERE	numcte = pNumcte
				AND 	tipo_dir='1';

				SELECT state_cd
				INTO	cEstadoBenef
				FROM 	bdisac:sac_app_catestados
				WHERE	cve_estado = cIdEstadoBenef; --Se obtiene el estado del beneficiario

				SELECT	NVL(dmapa,imapa)
				INTO	cBiometricAuthentication
				FROM	bdinteg:si_cte_huella
				WHERE	numcte=pNumcte
				AND 	estado='A';	--Se obtiene la huella del cliente
			--END IF;


			--Se validan los numeros de telefono
			--CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefonoCasa, pTelefonoCel, "")
			--RETURNING cRetCode2, cFlagTelCasa, cFlagTelCel, cFlagTelOficina;
			IF cFlagTelCasa <> "1" THEN
				LET cRetCode2 = "00001";
				LET cIdentificadorProceso = "08";
				LET cDesc_error = 'Telefono de casa no valido';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			ELIF cFlagTelCel <> "1" and pTelefonoCel <> "" THEN
				LET cRetCode2 = "00002";
				LET cIdentificadorProceso = "08";
				LET cDesc_error = 'Telefono movil no valido';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			ELSE
				--Validacion solicitada por PLD para limites de Direcciones y Telefonos ingresados en el cobro de remesas sp_sac_pldlim_teldom_cpl

				LET cDia = LPAD(SUBSTRING(pFechaHoy FROM 7 FOR 2), 2, '0');
				LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
				LET cAnio = LPAD(SUBSTRING(pFechaHoy FROM 1 FOR 4), 4, '0');



					EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom_cpl('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;

				IF cRetCode2 <> '00000' THEN
					--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
					LET cRetCode2 = "01245";
					LET cIdentificadorProceso = "02";
					LET cCodErrAux = '999999';
					LET cDesc_error = 'Error al validar limites por telefono y domicilio';
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				ELSE
					--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom_cpl en caso de reversion de la operacion
					LET cValidaPLDteldom = 1;
					--Se validan los montos
					LET pFechaHoy = cMEs||cDia||cAnio;

					CALL bdisac:"informix".sp_app_valmonto_cpl(pEmpresa, pNombre1, pNombre2, pApellidoPat, pApellidoMat, pFechaNac, pFechaHoy, pMontoAPagar, pSucursal, pMoneda, pMontoMoneda, pRefUno, pCodigoEstadoSuc)
					RETURNING cCodErrAux;

					IF cCodErrAux <> "00000" THEN
						LET cRetCode2 = SUBSTRING(cCodErrAux FROM 2 FOR 5);
					ELSE
						LET cRetCode2 = cCodErrAux;
					END IF;

					IF cRetCode2 <> "00000" THEN
						LET cIdentificadorProceso = "02";
						LET cDesc_error = 'Error al validar montos / sp_app_valmonto_cpl';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
					ELSE
						CALL bdisac:"informix".sp_grabapagoservicio_hs(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFormapago, pMontoTotal, pImpComConv, pIvaComConv, pImpComCte, pIvaComCte, '', pNumEmp, pFolsuc, pTransSuc, pFechaPag, pCanalOrigen, pSucursalOrigen, pCajaOrigen, pTransSuc, pHoraOrigen, pFolioOrigen, pCodigoEstadoSuc, '')
						RETURNING cRetCode2;

						IF vtransaccion = 1 then
							COMMIT WORK;
							BEGIN WORK;
						ELSE
							BEGIN WORK;
						END IF;

						IF cRetCode2 <> "00000" THEN
							LET cIdentificadorProceso = "03";
							LET cDesc_error = 'Error al grabar el registro en BD / sp_grabapagoservicio_hs';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
						ELSE
							LET v_fecha_nac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2), SUBSTRING(pFechaNac FROM 7 FOR 2), SUBSTRING(pFechaNac FROM 1 FOR 4));
							--Llamado a sp para actualizar datos
							IF EXISTS (SELECT * FROM sac_remesas_estadistica WHERE referencia = pRefUno AND numcategoria = pCategoria AND numconvenio  = pConvenio) THEN

								--Calculo el RFC del beneficiario
								EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(pApellidoPat, pApellidoMat, pNombre1, v_fecha_nac)
								INTO cRetCode2, cRfc;



								  UPDATE sac_remesas_estadistica
								  SET
									  nombre1        = pNombre1,
									  nombre2        = pNombre2,
									  appaterno      = pApellidoPat,
									  apmaterno      = pApellidoMat,
									  fecha_nac      = v_fecha_nac,
									  rfc            = cRfc,
									  moneda_origen  = pMoneda,
									  importe_origen = pMontoMoneda
								  WHERE  		referencia     = pRefUno
								  AND    		numcategoria = pCategoria
								  AND    		numconvenio  = pConvenio;

				        COMMIT;

								CALL bdisac:"informix".sp_confpagoservicio(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
								RETURNING cRetCode2, cDescripcion;

							ELSE

								LET cRetCode2 = "90001";
								LET cIdentificadorProceso = "09";

							END IF;
							IF cRetCode2 <> "00000" THEN
								LET cIdentificadorProceso = "04";
							ELSE
								--Llamado para obtener parametros para el servicio de pago
								CALL bdisac:"informix".sp_param_remesas_cpl(pCodigoEstadoSuc, "2")
								RETURNING cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
								LET cTransServicio = NVL(cTransServicio, "");
								IF cTransServicio <> "20068" THEN
									LET cIdentificadorProceso = "06";
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;

		IF cIdentificadorProceso != '00' THEN
			IF cCodErrAux != '999999' THEN
				IF cValidaPLDteldom = 1 THEN
						EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom_cpl('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
				END IF;
			END IF;
		END IF;

		RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode,NVL(cNacionalidad,''), NVL(pNumcte,''), NVL(cEstadoBenef,''), cTaxIdentificationNumber, cSupervisorId,  cProofOfDomicileTypeCode, cProofOfDomicileDescription, cProofOfDomicileReferenceNumber ,  NVL(cBiometricAuthentication,''), NVL(cGenero,''), NVL(cUniqueResidentNumber,'') ;
	END
END PROCEDURE;