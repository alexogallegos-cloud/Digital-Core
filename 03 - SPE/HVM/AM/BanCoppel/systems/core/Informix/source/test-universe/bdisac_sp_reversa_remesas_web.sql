CREATE PROCEDURE "informix".sp_reversa_remesas_web
(
	pempresa  	CHAR(3),
	psucursal 	CHAR(4),
	pusuario  	CHAR(8),
	pfolio    	CHAR(16),
	ptiporev  	CHAR(1),
	pNumCredito CHAR(20),
	pTipoEjec 	SMALLINT  	
)
RETURNING 
CHAR(5)     AS CodErr,
CHAR(2)     AS IdentificadorProceso,
CHAR(5)     AS CodErr2,
CHAR(80) 	AS descripcion;
			  
	-- Definicion de variables --
	DEFINE cCodErr 						CHAR(5);
	DEFINE cIdentificadorProceso 		CHAR(2);
	DEFINE cCodErr2 					CHAR(5);	
	DEFINE cDescripcion					CHAR(80);
	DEFINE cCodRetRes					CHAR(5);
	DEFINE cCodRetRes2					CHAR(5);
	DEFINE iSqlErr                     	INTEGER;
	DEFINE vtransaccion					SMALLINT;
	
	-- Inicializacion de variables --
	LET cCodErr 					= '00000';	
	LET cIdentificadorProceso 		= '00';
    LET cCodErr2 					= '000';
	LET cDescripcion 				= '';
	LET cCodRetRes					= '';
	LET cCodRetRes2					= '';
	
	LET pempresa = NVL(pempresa,'');	
	LET pSucursal = NVL(pSucursal,'');
	LET pusuario = NVL(pusuario,'');
	LET pfolio = NVL(pfolio,'');
	LET ptiporev = NVL(ptiporev,'');
	LET pNumCredito = NVL(pNumCredito,'');
	LET vtransaccion = 0;
	
	-- SET DEBUG FILE TO "/informix/remesasweb/trace.sql";
    -- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				RETURN cCodErr, cIdentificadorProceso, cCodErr2, cDescripcion;
			END IF;
        END EXCEPTION;		

		ON EXCEPTION IN (-535)
			let vtransaccion = 1;
		END EXCEPTION WITH resume;
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;		
		
		--Validar que los parametros de entrada no vengan vacios o nulos
		IF pempresa = '' OR  psucursal = '' OR pusuario = '' OR pfolio = '' OR ptiporev = '' OR pTipoEjec = '' THEN
			LET cCodErr = '00001';
			LET cCodErr2 = '001';
			LET cIdentificadorProceso = '01';		
		END IF;
		IF cCodErr2 = '000' THEN
			--Aplica el reversio en bdicheq
			CALL bdicheq:"informix".reversion(pempresa, psucursal, pusuario, pfolio, ptiporev)
			RETURNING cCodRetRes;
			
			LET cCodRetRes = NVL(cCodRetRes,'');
			LET cCodRetRes = TRIM(cCodRetRes);
			
			IF cCodRetRes = '' OR cCodRetRes <> '000' THEN
				LET cCodErr = '00001';
				LET cCodErr2 = cCodRetRes;
				LET cIdentificadorProceso = '02';
			ELSE
				--Aplica el reversio en bdinvers				
				LET cCodRetRes = '';		
				CALL bdinvers:"informix".reversion(pempresa, psucursal, pusuario, pfolio, ptiporev)
				RETURNING cCodRetRes, cCodRetRes2 ;	
				
				LET cCodRetRes = NVL(cCodRetRes,'');
				LET cCodRetRes = TRIM(cCodRetRes);
				
				IF cCodRetRes = '' OR cCodRetRes <> '000' THEN
					LET cCodErr = '00001';
					LET cCodErr2 = cCodRetRes;
					LET cIdentificadorProceso = '03';
				ELSE
					--Aplica el reversio en bdicred
					LET cCodRetRes = '';
					CALL bdicred:"informix".reversion(pempresa, psucursal, pusuario, pfolio, ptiporev)
					RETURNING cCodRetRes;
					
					LET cCodRetRes = NVL(cCodRetRes,'');
					LET cCodRetRes = TRIM(cCodRetRes);
					
					IF cCodRetRes = '' OR cCodRetRes <> '000' THEN
						LET cCodErr = '00001';
						LET cCodErr2 = cCodRetRes;
						LET cIdentificadorProceso = '04';
					ELSE
						--Aplica el reversio en bditrans
						LET cCodRetRes = '';
						CALL bditrans:"informix".reversion(pempresa, psucursal, pusuario, pfolio, ptiporev)
						RETURNING cCodRetRes;
						
						LET cCodRetRes = NVL(cCodRetRes,'');
						LET cCodRetRes = TRIM(cCodRetRes);
						
						IF cCodRetRes = '' OR cCodRetRes <> '000' THEN
							LET cCodErr = '00001';
							LET cCodErr2 = cCodRetRes;
							LET cIdentificadorProceso = '05';
						ELSE
							--Aplica el reversio en bdisuc
							LET cCodRetRes = '';
							CALL bdisuc:"informix".reversion(pempresa, psucursal, pusuario, pfolio, ptiporev)
							RETURNING cCodRetRes;
							
							LET cCodRetRes = NVL(cCodRetRes,'');
							LET cCodRetRes = TRIM(cCodRetRes);
							
							IF cCodRetRes = '' OR cCodRetRes <> '000' THEN
								LET cCodErr = '00001';
								LET cCodErr2 = cCodRetRes;
								LET cIdentificadorProceso = '06';
							END IF;	
						END IF;						
					END IF;					
				END IF;
			END IF;			
		END IF;		
    RETURN cCodErr, cIdentificadorProceso, cCodErr2, cDescripcion;
END
END PROCEDURE
DOCUMENT
'FOLIO.........: Remesas WEB',
'AUTOR.........: 92473997 - Isaac Quintero',
'FECHA.........: 26/06/2019	DSB06032019',
'MODIFICACION..: Se crea procedimiento que realiza los llamados a procedimientos para el reverso de remesas',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC';

CREATE PROCEDURE "informix".sp_pago_appriza_web(pSucursal   		CHAR (4),
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
												pCuentaCargo    	CHAR (12),
												pCuentaAbono    	CHAR (12),
												pNumEmp        		CHAR (8),
												pFolsuc        		CHAR (16),
												pTransSuc      		CHAR (4),
												pFechaPag      		DATE,
												pEmpresa     		CHAR (3),
												pNombre1 			CHAR (40),
												pNombre2 			CHAR (40),
												pApellidoPat		CHAR (40),
												pApellidoMat		CHAR (40),
												pFechaNac			CHAR (8),
												pFechaHoy 			CHAR (8),
												pMontoAPagar 		CHAR (20),
												pMoneda 			CHAR (3),
												pMontoMoneda		MONEY (14,2),
												pTranEquivCargo		CHAR (4),
												pTransSucRef    	CHAR (4),
												pCheque				INTEGER,
												pMontoTotalRef  	MONEY (14,2),
												pDivisa      		CHAR (2),
												pReferenciaCargo  	CHAR (40),
												pReferenciaAbono  	CHAR (40),
												pNumTarjeta 		CHAR (16),
												pUsuAutoriza		CHAR (8),
												pTranEquivAbono		CHAR (4),
												pDocto       		INTEGER,
												pMontoFirme   		MONEY (14,2),
												pMtoSBC     		MONEY (14,2),
												pMtoRem     		MONEY (14,2),
												pDiasRet			SMALLINT,
												pTelefonoCasa 		CHAR (10),
												pTelefonoCel		CHAR (10))

	RETURNING CHAR (5) AS RetCode, CHAR (2) AS IdentificadorProceso, CHAR (5) AS RetCode2, CHAR(5) AS TransaccInt, CHAR(5) AS TransServicio, CHAR(2) AS NumIntentos, CHAR(3) AS ApprizaCode, CHAR(3) AS ChannelId, CHAR(15) AS LocationUnit, CHAR(3) AS TypeCode, CHAR(3) AS StateCode, CHAR(3) AS CountryCode;

	-- Definicion de variables --
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
	DEFINE cNoCuentaAbono		 CHAR(11);
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

	-- Inicializacion de variables --
	LET cCodErr 				 = "00000";
	LET cIdentificadorProceso 	 = "00";
    LET cRetCode2 				 = "00000";
	LET cFlagTelCel				 = "0";
	LET cFlagTelCasa			 = "0";
	LET cFlagTelOficina			 = "0";
	LET cNoCuentaAbono			 = "";
	LET cDescripcion  			 = "";
	LET iSqlErr					 = 0;
	LET cNoTarjeta 				 = "";
	LET cNoCte					 = "";
	LET	cTransaccInt			 = "";
	LET	cTransServicio	         = "";
	LET	cNumIntentos		     = "";
	LET	cApprizaCode		     = "";
	LET	cChannelId		         = "";
	LET	cLocationUnit	         = "";
	LET	cTypeCode		         = "";
	LET	cStateCode		         = "";
	LET	cCountryCode		     = "";
	LET cFechaHoy				 = "";
	LET cFechaNac				 = "";
	LET vtransaccion			 = 0;
	LET cCodErrAux				 = "000000";

	-- Validar que ningun parametro obligatorio este vacio --
	LET pSucursal   	 = NVL(pSucursal, "");
	LET pCategoria       = NVL(pCategoria, "");
	LET pConvenio      	 = NVL(pConvenio, "");
	LET pRefUno        	 = NVL(pRefUno, "");
	LET pRefDos        	 = NVL(pRefDos, "");
	LET pFormaPago     	 = NVL(pFormaPago, "");
	LET pMontoTotal    	 = NVL(pMontoTotal, 0);
	LET pImpComConv      = NVL(pImpComConv, 0);
	LET pIvaComConv    	 = NVL(pIvaComConv, 0);
	LET pImpComCte     	 = NVL(pImpComCte, 0);
	LET pIvaComCte     	 = NVL(pIvaComCte, 0);
	LET pCuentaCargo     = NVL(pCuentaCargo, "");
	LET pCuentaAbono     = NVL(pCuentaAbono, "");
	LET pNumEmp        	 = NVL(pNumEmp, "");
	LET pFolsuc        	 = NVL(pFolsuc, "");
	LET pTransSuc      	 = NVL(pTransSuc, "");
	LET pFechaPag      	 = NVL(pFechaPag, "");
	LET pEmpresa     	 = NVL(pEmpresa, "");
	LET pTranEquivCargo	 = NVL(pTranEquivCargo, "");
	LET pTransSucRef     = NVL(pTransSucRef, "");
	LET pCheque			 = NVL(pCheque, 0);
	LET pMontoTotalRef   = NVL(pMontoTotalRef, 0);
	LET pDivisa      	 = NVL(pDivisa, "");
	LET pReferenciaCargo = NVL(pReferenciaCargo, "");
	LET pReferenciaAbono = NVL(pReferenciaAbono, "");
	LET pNumTarjeta 	 = NVL(pNumTarjeta, "");
	LET pUsuAutoriza	 = NVL(pUsuAutoriza, "");
	LET pTranEquivAbono	 = NVL(pTranEquivAbono, "");
	LET pDocto       	 = NVL(pDocto, 0);
	LET pMontoFirme   	 = NVL(pMontoFirme, 0);
	LET pMtoSBC     	 = NVL(pMtoSBC, 0);
	LET pMtoRem     	 = NVL(pMtoRem, 0);
	LET pDiasRet		 = NVL(pDiasRet, 0);
	LET pNombre1 		 = NVL(pNombre1, "");
	LET pNombre2 		 = NVL(pNombre2, "");
	LET pApellidoPat	 = NVL(pApellidoPat, "");
	LET pApellidoMat	 = NVL(pApellidoMat, "");
	LET pFechaNac		 = NVL(pFechaNac, "");
	LET pFechaHoy 		 = NVL(pFechaHoy, "");
	LET pMontoAPagar 	 = NVL(pMontoAPagar, "");
	LET pMoneda 		 = NVL(pMoneda, "");
	LET pMontoMoneda	 = NVL(pMontoMoneda, 0);
	LET pTelefonoCasa 	 = NVL(pTelefonoCasa, "");
	LET pTelefonoCel 	 = NVL(pTelefonoCel, "");

	--SET DEBUG FILE TO "/informix/BRMS/APP/PAGO/sp_pago_appriza_web.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodErr = iSqlErr;
			RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
		END IF;
	END EXCEPTION;

	on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
	if vtransaccion = 1 then
		COMMIT WORK;
		BEGIN WORK;
	else
		BEGIN WORK;
	end if;

	--Se valida que ninguna variable de entrada este vacia
	IF pSucursal = "" OR pCategoria = "" OR pConvenio = "" OR pRefUno = "" OR pFormaPago = "" OR pMontoTotal = 0 OR pCuentaCargo = "" OR (pFormaPago <> "1" AND (pNumTarjeta = "" AND pCuentaAbono = "")) OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR pEmpresa = "" OR pTranEquivCargo = "" OR (pFormaPago <> "1" AND pTranEquivAbono = "") OR pMontoTotalRef = 0 OR pDivisa = "" OR (pFormaPago <> "1" AND pReferenciaAbono = "") OR pReferenciaCargo = "" OR (pFormaPago <> "1" AND pDocto = 0) OR pMontoFirme = 0 OR pNombre1 = "" OR pApellidoPat = "" OR pFechaNac = "" OR pFechaHoy = "" OR pMontoAPagar = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pTelefonoCasa = "" THEN
			LET cCodErr = "00001";
	ELSE
		--Se validan los numeros de telefono
		CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefonoCasa, pTelefonoCel, "")
		RETURNING cRetCode2, cFlagTelCasa, cFlagTelCel, cFlagTelOficina;
		--IF cRetCode2 <> "000" THEN
		IF cFlagTelCasa <> "1" THEN
			LET cRetCode2 = "00001";
			LET cIdentificadorProceso = "08";
		ELIF cFlagTelCel <> "1" and pTelefonoCel <> "" THEN
			LET cRetCode2 = "00002";
			LET cIdentificadorProceso = "08";
		ELSE
			--Se validan los montos
			--LET pFechaHoy = pFechaHoy;
			LET pFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 2)||SUBSTRING(pFechaHoy FROM 7 FOR 2)||SUBSTRING(pFechaHoy FROM 1 FOR 4);
			CALL bdisac:"informix".sp_app_valmonto(pEmpresa, pNombre1, pNombre2, pApellidoPat, pApellidoMat, pFechaNac, pFechaHoy, pMontoAPagar, pSucursal, pMoneda, pMontoMoneda, pRefUno)
			RETURNING cCodErrAux;

			IF cCodErrAux <> "00000" THEN
				LET cRetCode2 = SUBSTRING(cCodErrAux FROM 2 FOR 5);
			ELSE
				LET cRetCode2 = cCodErrAux;
			END IF;

			IF cRetCode2 <> "00000" THEN
				LET cIdentificadorProceso = "02";
			ELSE
				CALL bdisac:"informix".sp_grabapagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFormaPago, pMontoTotal, pImpComConv, pIvaComConv, pImpComCte, pIvaComCte, pCuentaAbono, pNumEmp, pFolsuc, pTransSuc, pFechaPag)
				RETURNING cRetCode2;

				if vtransaccion = 1 then
					COMMIT WORK;
					BEGIN WORK;
				else
					BEGIN WORK;
				end if;

				IF cRetCode2 <> "00000" THEN
					LET cIdentificadorProceso = "03";
				ELSE
					LET v_fecha_nac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2), SUBSTRING(pFechaNac FROM 7 FOR 2), SUBSTRING(pFechaNac FROM 1 FOR 4));
					--Llamado a sp para actualizar datos
					CALL bdisac:"informix".sp_actualizaremesa(pCategoria, pConvenio, pRefUno, pNombre1, pNombre2, pApellidoPat, pApellidoMat, v_fecha_nac, pMoneda, pMontoMoneda)
					RETURNING cRetCode2, vCuenta;

					IF cRetCode2 <> "00000" THEN
						LET cIdentificadorProceso = "09";
					ELSE
						--Llamado a sp cargo_ref para aplicar el cargo
						CALL bdicheq:"informix".cargo_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)
						RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;

						IF cRetCode2 <> "000" THEN
							LET cIdentificadorProceso = "07";
						ELSE
							--Se valida que la forma de pago fue en efectivo para evitar el llamado a el sp abono_ref
							IF pFormaPago <> "1" THEN
								--Llamado a sp abono_ref para el cargo a la cuenta
								CALL bdicheq:"informix".abono_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivAbono, pTransSucRef, pFolsuc, pCuentaAbono, pDocto, pMontoTotalRef, pMontoFirme, pMtoSBC, pMtoRem, pDiasRet, pDivisa, pReferenciaAbono, pNumTarjeta, pUsuAutoriza)
								RETURNING cRetCode2;
							END IF;
							IF cRetCode2 <> "000" THEN
								LET cIdentificadorProceso = "05";
							ELSE
								CALL bdisac:"informix".sp_confpagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
								RETURNING cRetCode2, cDescripcion;

								IF cRetCode2 <> "00000" THEN
									LET cIdentificadorProceso = "04";
								ELSE
									--Llamado para obtener parametros para el servicio de pago
									CALL bdisac:"informix".sp_consultasucursalAppriza(pSucursal, "2")
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
		END IF;
	END IF;

	RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
END
END PROCEDURE
DOCUMENT
'FOLIO.........: Remesas WEB',
'AUTOR.........: 97832715 - Bruno Medina',
'FECHA.........: 06/03/2019	DSB06032019',
'MODIFICACIÃ?Â??N..: Se crea procedimiento que realiza los llamados a procedimientos para el pago de remesa de appriza',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC';

CREATE PROCEDURE "informix".sp_pago_servicios(pEmpresa char(3), pSucursal char(4), pUsuario char(8), pTransCargo char(4), pTransAbono char(4), 
pTransSuc char(4), pFolioSuc char(16), pNumCtaOrigen char(12), pNumCtaDestino char(12), pCheque integer, pMonto money(14,2), pMoneda char(2), pReferencia char(40),
pNumTarjetaOrigen char(16), pNumTarjetaDestino char(16), pUsuAutoriza char(8), pMontoTotal money(14,2), pMontoFirme money(14,2), pMontoSBC money(14,2),
pMontoRem money(14,2), pDiasRet smallint, pDocto integer, pCategoria Char(2), pConvenio Char(3), cRefTelefono Char(40), cRefVerificador Char(20), cFormaPago Char(1),
cCuentaCargo CHAR (12), cTransacc_suc CHAR(4), dFechaPago DATE)
RETURNING char(5), char(5);

    -- Realizo   : Ramon Octavio Romero MascareÃÂ±o
    -- Actividad : Pago de Servicios
    -- SolicitÃÂ³  : Mauricio Leon
    -- Fecha     : 14/07/2009
	--****************************************
	-- Realizo   : Manuel Osuna Valencia
    -- Actividad : Se modifica el tipo de dato de las variables de comisiones
    -- SolicitÃÂ³  : Mauricio Leon
    -- Fecha     : 05/08/2009
	--****************************************
	--RealizÃÂ³    : Walber Castro
	--Actividad  : Se agrega validaciÃÂ³n de SKY para el cÃÂ¡lculo de vImporteCompuesto
	--SolicitÃÂ³   : Diana Castellanos
	--Fecha      : 11/08/2010
	--****************************************
	--RealizÃÂ³    : JosÃÂ© de JesÃÂºs Nevarez.
	--Actividad  : Se agrega validaciÃÂ³n de DISH y MASTV para el cÃÂ¡lculo de vImporteCompuesto.
	--SolicitÃÂ³   : Mauricio LeÃÂ³n
	--Fecha      : 31/08/2010
	--****************************************
	--RealizÃÂ³    : Ing. Cruz
	--Actividad  : Se agrega validacion ECI, Arabela para el cÃÂ¡lculo de vImporteCompuesto, se agrega el usuario "informix" a cada ejecuciÃÂ³n de SPL's
	--SolicitÃÂ³   : JosÃÂ© de Jesus Nevarez
	--Fecha      : 28/05/2012
	--****************************************
	--RealizÃÂ³    : Aaron QuiÃÂ±onez
	--Actividad  : Se agrega validacion CFE(cat:04,conv:001) para el cÃÂ¡lculo de vImporteCompuesto.
	--SolicitÃÂ³   : Alejandro Vazquez
	--Fecha      : 26/09/2017
	--**********************************************
	--Realiza    : Gabriela Aguilar
	--Actividad  : Se agrega validacion para Tiempo Aire
	--Solicita   : Alejandro Vazquez
	--Fecha      : 09/10/2019
	
	
       DEFINE vcodret   			char(5);
       DEFINE vcodretRev   			char(5);
	   DEFINE vcodretConv   		char(5);
       DEFINE sql_err   			integer;
       DEFINE vTrans    			char(4);
       DEFINE vFechaHoy 			date;
       DEFINE vSdoDisp  			money(14,2);
       DEFINE vMontoRet 			money(14,2);
       DEFINE vPasoCargo 			char(1);
	   Define vPasoAbono			char(1);
	   DEFINE vimpcomconvenio 		money(14,2);
	   DEFINE vIVAimpconvenio		money(14,2);
	   DEFINE vimpcomcte			money(14,2);
	   DEFINE vIVAimpcomcte			money(14,2);
	   DEFINE vImporteCompuesto		money(14,2);
	   DEFINE cTipoServ				integer;
	   DEFINE fechadia  			date;							 

	    LET vPasoCargo 				= '0';
		LET vcodret 				= '000';
		LET vcodretRev 				= '000';
	    LET vcodretConv   			= '000';
	    LET vimpcomconvenio 		= 0;
	    LET vIVAimpconvenio			= 0;
	    LET vimpcomcte				= 0;
	    LET vIVAimpcomcte			= 0;
		LET vImporteCompuesto		= 0;
		LET cTipoServ 				= 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
		--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_pago_servicios.out';
		--TRACE ON;

BEGIN
--si el sp falla checa si ya fue realizada la transaccion de Cargo y Abono, en caso de haber sido realizada una o ambas,
--se realiza la reversion de estas.
ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
				EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
													pSucursal,
													pUsuario,
													pFolioSuc,
													'A') INTO vcodretRev;
				IF vcodretRev = '000' THEN
					LET vcodretRev = '004'; --Error no Controlado de SQL.
				END IF;
        LET vcodret = sql_err;
        RETURN vcodret, vcodretRev;
       END IF;
END EXCEPTION;

	    EXECUTE PROCEDURE bdisac:sp_calcula_comisiones(pCategoria,
														pConvenio,
														pMonto)
		INTO vcodretConv, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;

		--Validacion para checar que el sp_calcula_comisiones se ejecuto correctament y
		--despues valida el convenio , ejemplo si el pCategoria = 02 y el pConvenio = 001
		--es un pago telmex y se asignan las comisiones correspondientes.
	    if vcodretConv <> 0 THEN
				LET vcodretConv = '002'; --Error al ejecutar sp_calcula_comisiones
			RETURN vcodretConv, vcodretRev;
		ELSE
		/* 
			IF ( pCategoria IN ('02','04','06','09')) AND (pConvenio IN ('001','002','003' )) THEN--TELMEX(02) y SKY,DISH,MASTV(06), ECI Y ARABELA (09, 001 Y 002)
				LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
			END IF;
		*/
			IF pCategoria = ('02') THEN
				IF pConvenio IN ('001','003') THEN --TELMEX--AXTEL
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			ELIF pCategoria = ('04') THEN
				IF pConvenio = '001' THEN --CFE
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			ELIF pCategoria = ('06') THEN
				IF pConvenio IN  ('001','002','004') THEN --SKY--DISH--CABLEMAS
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			ELIF pCategoria = ('09') THEN
				IF pConvenio IN ('001','002','003') THEN --EDICIONES CULTURALES INTERNACIONALES--ARABELA--AVON
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			
			
			ELIF pCategoria = ('03') THEN
				IF pConvenio IN ('001') THEN --Tiempo Aire
					LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
				END IF;
			END IF;
				
		END IF;
		
		IF ( pSucursal IN ('5002','5003','5007','5011')) THEN -----Sucursales moviles --> otros canales
			SELECT fecha_hoy INTO fechadia FROM sac_fechas;
			IF (fechadia <> dfechapago) THEN 
				LET vcodret = '004';
				RETURN vcodret, vcodretRev;
			END IF;
		END IF;


    EXECUTE PROCEDURE bdicheq:cargo_ref(pEmpresa,
										pSucursal,
										pUsuario,
										pTransCargo,
										pTransSuc,
										pFolioSuc,
										pNumCtaOrigen,
										pCheque,
										vImporteCompuesto,
										pMoneda,
										pReferencia,
										pNumTarjetaOrigen,
										pUsuAutoriza)
	INTO vcodret,vTrans, vFechaHoy, vSdoDisp,vMontoRet;

    IF vcodret <> '000' THEN
		EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
											pSucursal,
											pUsuario,
											pFolioSuc,
											'A') INTO vcodretRev;
		IF vcodretRev = '000' THEN
            LET vcodretRev = '001';
        END IF;
        RETURN vcodret, vcodretRev;

    END IF;

    EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa,
										pSucursal,
										pUsuario,
										pTransAbono,
										pTransSuc,
										pFolioSuc,
										pNumCtaDestino,
										pDocto,
										vImporteCompuesto,
										vImporteCompuesto,
										pMontoSBC,
										pMontoRem,
										pDiasRet,
										pMoneda,
										pReferencia,
										pNumTarjetaDestino,
										pUsuAutoriza)
	INTO vcodret;

    IF vcodret <> '000' THEN
        EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
											pSucursal,
											pUsuario,
											pFolioSuc,
											'A') INTO vcodretRev;
        IF vcodretRev = '000' THEN
            LET vcodretRev = '002';
        END IF;
        RETURN vcodret, vcodretRev;
    END IF;

	SELECT numrephompag 
	INTO cTipoServ
	FROM sac_servicios_cpl
	WHERE numcategoria = pCategoria
	AND numconvenio = pConvenio;
	
	IF cTipoServ = 1 then
		EXECUTE PROCEDURE bdisac:sp_grabapgserv_dina(pSucursal,
												   pCategoria,
												   pConvenio,
												   cRefTelefono,
												   cRefVerificador,
												   cFormaPago,
												   pMonto,
												   vimpcomconvenio,
												   vIVAimpconvenio,
												   vimpcomcte,
												   vIVAimpcomcte,
												   cCuentaCargo,
												   pUsuario,
												   pFolioSuc,
												   cTransacc_suc,
												   dFechaPago)
		INTO vcodret;
	ELSE 
		EXECUTE PROCEDURE bdisac:sp_grabapagoservicio(pSucursal,
												   pCategoria,
												   pConvenio,
												   cRefTelefono,
												   cRefVerificador,
												   cFormaPago,
												   pMonto,
												   vimpcomconvenio,
												   vIVAimpconvenio,
												   vimpcomcte,
												   vIVAimpcomcte,
												   cCuentaCargo,
												   pUsuario,
												   pFolioSuc,
												   cTransacc_suc,
												   dFechaPago)
		INTO vcodret;
	END IF;

	IF vcodret <> '00000' THEN
			EXECUTE PROCEDURE bdicheq:reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'A') INTO vcodretRev;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '003';
			END IF;
        RETURN vcodret, vcodretRev;
    END IF;

	RETURN vcodret, vcodretRev;

END;
END PROCEDURE;