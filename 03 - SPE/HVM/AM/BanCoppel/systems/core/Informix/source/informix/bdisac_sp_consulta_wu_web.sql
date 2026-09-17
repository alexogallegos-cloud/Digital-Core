CREATE PROCEDURE "informix".sp_consulta_wu_web
(
	pTransaccionQryi      CHAR(9),
	pNoCte                CHAR(9),
	pSucursal             CHAR(4),
	pNmReferencia         CHAR(16),
	pNumTrama             CHAR(1),
	pUserName             CHAR(21),
	pFechaConsulta        CHAR(8),
	pHoraConsulta         CHAR(6),
	pClienteRemesa        CHAR(1),
	pNombreCliente        CHAR(164),
	pFechaNacimiento      DATE,
	pNumeroIdentificacion CHAR(30),
	pEmpresa			  CHAR(3),
	pUsuario			  CHAR(8),
	pMarca				  CHAR(2),
	pCanalOrigen		  CHAR(4),
	pCajaOrigen			  CHAR(2),
	pSucursalOrigen		  CHAR(4),
	pCampoGenerico1		  CHAR(20),
	pCampoGenerico2		  CHAR(20),
	pCampoGenerico3		  CHAR(20)
)

RETURNING

CHAR(5)     AS CodErr,
CHAR(2)     AS IdentificadorProceso,
CHAR(5)     AS CodErr2,
CHAR(20)    AS numcte,
CHAR(1)     AS TipoCliente,
CHAR(1)     AS FlagEnrolamiento,
CHAR(40)    AS PrimerNombreB,
CHAR(40)    AS SegundoNombreB,
CHAR(40)    AS ApellidoPaternoB,
CHAR(40)    AS ApellidoMaternoB,
CHAR(10)    AS FechaNacimientoB,
CHAR(3)     AS IdNacionalidad,
CHAR(3)     AS IdPaisNacimiento,
CHAR(2)     AS IdEstadoNacimiento,
CHAR(1)     AS Sexo,
CHAR(2)     AS TipoIdentificacion,
CHAR(30)    AS NoIdentificacion,
CHAR(3)     AS IdPaisEmision,
CHAR(10)    AS FechaVencimiento,
CHAR(3)     AS IdOcupacion,
CHAR(2)     AS TipoCteRem,
CHAR(2)     AS IdEstado,
CHAR(3)     AS IdCiudad,
CHAR(5)     AS IdMunicipio,
CHAR(10)    AS NumColonia,
CHAR(10)    AS NumCalle,
CHAR(10)    AS NumeroCiudad,
CHAR(10)    AS NumExterior,
CHAR(10)    AS NumInterior,
CHAR(10)    AS Departamento,
CHAR(5)     AS CodPostal,
CHAR(13)    AS Telefono,
CHAR(13)    AS TelefonoCelular,
CHAR(3)     AS IdPaisDomExt,
CHAR(100)   AS CorreoElectronico,
CHAR(10)    AS ClavePuesto,
CHAR(10)    AS ClaveSubPuesto,
CHAR(2)     AS EstadoOriginadorSucursal,
CHAR(1)     AS StatusCancelado,
CHAR(4) 	AS ChannelType,
CHAR(4) 	AS ChannelName,
CHAR(4) 	AS ChannelVersion,
CHAR(11) 	AS FrsIdentifier,
CHAR(13) 	AS FrsCounterId;

	-- Definicion de variables --
	DEFINE cCodErr 						CHAR(5);
	DEFINE cIdentificadorProceso 		CHAR(2);
	DEFINE cCodErr2 					CHAR(5);
	DEFINE cFlagEnrolamiento 			CHAR(1);
	DEFINE cPrimerNombre 				CHAR(40);
	DEFINE cSegundoNombre 				CHAR(40);
	DEFINE cApellidoPaterno 			CHAR(40);
	DEFINE cApellidoMaterno 			CHAR(40);
	DEFINE cFechaNacimiento 			CHAR(10);
	DEFINE cIdNacionalidad 				CHAR(3);
	DEFINE cIdPaisNacimiento 			CHAR(3);
	DEFINE cIdEstadoNacimiento 			CHAR(2);
	DEFINE cSexo 						CHAR(1);
	DEFINE cTipoIdentificacion 			CHAR(2);
	DEFINE cNoIdentificacion 			CHAR(30);
	DEFINE cIdPaisEmision 				CHAR(3);
	DEFINE cFechaVencimiento 			CHAR(10);
	DEFINE cIdOcupacion 				CHAR(3);
	DEFINE cTipoCte 					CHAR(2);
	DEFINE cIdEstado 					CHAR(2);
	DEFINE cIdCiudad 					CHAR(3);
	DEFINE cIdMunicipio 				CHAR(5);
	DEFINE cNumColonia 					CHAR(10);
	DEFINE cNumCalle 					CHAR(10);
	DEFINE cNumeroCiudad 				CHAR(10);
	DEFINE cNumExterior 				CHAR(10);
	DEFINE cNumInterior 				CHAR(10);
	DEFINE cDepartamento 				CHAR(10);
	DEFINE cCodPostal 					CHAR(5);
	DEFINE cTelefono					CHAR(13);
	DEFINE cTelefonoCelular 			CHAR(13);
	DEFINE cIdPaisDomExt 				CHAR(3);
	DEFINE cCorreoElectronico 			CHAR(100);
	DEFINE cClavePuesto 				CHAR(10);
	DEFINE cClaveSubPuesto 				CHAR(10);
	DEFINE cEstadoOriginadorSucursal	CHAR(2);
	DEFINE cStatusCancelado 			CHAR(1);
	DEFINE iSqlErr                     	INTEGER;
	DEFINE dFechaSistema				DATE;
	DEFINE cMes							CHAR(2);
	DEFINE cCodRetRes					CHAR(5);
	DEFINE cStatusMnsj					CHAR(1);
	DEFINE iContList					INTEGER;
	DEFINE iCont						INTEGER;
	DEFINE cNumCte					    CHAR(9);
	DEFINE cTipoCliente 				CHAR(1);
	DEFINE cValIne 						CHAR(5);
	DEFINE cListaNegra 					CHAR(5);
	DEFINE cSespecial 					CHAR(5);
	DEFINE cRFC 						CHAR(15);
	DEFINE cNombreAux 					CHAR(164);
	DEFINE iIni							INTEGER;
	DEFINE iFin							INTEGER;

	DEFINE cCod_estado_sucursal 		CHAR(5);
	DEFINE iMensaje 					CHAR(50);
	DEFINE cid_ptf 						CHAR(5);
	DEFINE ccve_pais 					CHAR(3);
	DEFINE cnompais 					CHAR(20);
	DEFINE ccalle 						VARCHAR(100);
	DEFINE cnum_ext 					VARCHAR(6);
	DEFINE cnum_int 					VARCHAR(5);
	DEFINE ccve_col 					CHAR(8);
	DEFINE cnomcol 						VARCHAR(100);
	DEFINE ccve_mun 					CHAR(3);
	DEFINE cnommunicipio 				VARCHAR(60);
	DEFINE ccve_localidad 				CHAR(14);
	DEFINE cnomlocalidad 				VARCHAR(60);
	DEFINE ccp 							CHAR(5);
	DEFINE ccve_ciudad 					CHAR(3);
	DEFINE cnomciudad 					VARCHAR(60);

	DEFINE cnomestado 					VARCHAR(30);
	DEFINE ctel1 						VARCHAR(14);
	DEFINE ctel2 						VARCHAR(14);
	DEFINE ctipo 						VARCHAR(5);
	
	DEFINE cDesc_error        			CHAR(150);
	DEFINE dFecha	        			DATETIME YEAR TO SECOND;

	DEFINE cError_Desc					CHAR(30);
	DEFINE cChannel_Type				CHAR(4);
	DEFINE cChannel_Name				CHAR(4);
	DEFINE cChannel_Version				CHAR(4);
	DEFINE cFrs_Identifier				CHAR(11);
	DEFINE cFrs_Counter_Id				CHAR(13);
	DEFINE cTemplete_Id					CHAR(10);
	DEFINE cNo_reintentos				CHAR(1);
	DEFINE cUsuario						CHAR(8);
	DEFINE fechahora_insertCURRENT		CHAR(22);
	--Control de transacciones
	DEFINE vtransaccion			 		SMALLINT;
	DEFINE cConvenio					CHAR(3);
	DEFINE cStatuConv	 				CHAR(1);							  
	DEFINE vCajeroWU			CHAR(8);

	--Cliente valido para el INE EPG
	DEFINE cNoCteValido CHAR(9);

	-- Inicializacion de variables --

	LET cCodErr 					= '00000';
	LET cIdentificadorProceso 		= '00';
    LET cCodErr2 					= '00000';
    LET cFlagEnrolamiento 			= '0';
    LET cPrimerNombre 				= '';
    LET cSegundoNombre 				= '';
    LET cApellidoPaterno 			= '';
    LET cApellidoMaterno 			= '';
    LET cFechaNacimiento 			= '';
    LET cIdNacionalidad 			= '';
    LET cIdPaisNacimiento 			= '';
    LET cIdEstadoNacimiento 		= '';
    LET cSexo 						= '';
    LET cTipoIdentificacion 		= '';
    LET cNoIdentificacion 			= '';
    LET cIdPaisEmision 				= '';
    LET cFechaVencimiento 			= '';
    LET cIdOcupacion 				= '';
    LET cTipoCte 					= '';
    LET cIdEstado 					= '';
    LET cIdCiudad 					= '';
    LET cIdMunicipio 				= '';
    LET cNumColonia 				= '';
    LET cNumCalle 					= '';
    LET cNumeroCiudad 				= '';
    LET cNumExterior 				= '';
    LET cNumInterior 				= '';
    LET cDepartamento 				= '';
    LET cCodPostal 					= '';
    LET cTelefono					= '';
    LET cTelefonoCelular 			= '';
    LET cIdPaisDomExt 				= '';
    LET cCorreoElectronico 			= '';
    LET cClavePuesto 				= '';
    LET cClaveSubPuesto 			= '';
    LET cEstadoOriginadorSucursal	= '';
    LET cStatusCancelado 			= '';
	LET dFechaSistema				= '';
	LET cMes						= '';
	LET cCodRetRes					= '';
	LET cStatusMnsj					= '';
	LET iContList					= 0;
	LET iCont						= 0;
	LET cNumCte                     = '';
	LET cTipoCliente                = '';
	LET cValIne                     = '';
	LET cListaNegra                 = '';
	LET cSespecial                  = '';
	LET cRFC                        = '';
	LET cDesc_error 			 	= '';
	LET dFecha						= CURRENT;

	LET iMensaje 					= '';
	LET cid_ptf 					= '';
	LET ccve_pais 					= '';
	LET cnompais 					= '';
	LET ccalle 						= '';
	LET cnum_ext 					= '';
	LET cnum_int 					= '';
	LET ccve_col 					= '';
	LET cnomcol 					= '';
	LET ccve_mun 					= '';
	LET cnommunicipio 				= '';
	LET ccve_localidad 				= '';
	LET cnomlocalidad 				= '';
	LET ccp 						= '';
	LET ccve_ciudad 				= '';
	LET cnomciudad 					= '';
	LET cCod_estado_sucursal 		= '';
	LET cnomestado 					= '';
	LET ctel1 						= '';
	LET ctel2 						= '';
	LET ctipo 						= '';

	LET cError_Desc				    = '';
	LET cChannel_Type			    = '';
	LET cChannel_Name			    = '';
	LET cChannel_Version			= '';
	LET cFrs_Identifier			    = '';
	LET cFrs_Counter_Id			    = '';
	LET cTemplete_Id				= '';
	LET cNo_reintentos			    = '';
	LET cUsuario					= '';
	LET fechahora_insertCURRENT		= '';

	LET cNombreAux					= pNombreCliente;
	LET iIni						= 1;
	LET iFin 						= length(cNombreAux);

	LET pTransaccionQryi 			= NVL(pTransaccionQryi,'');
	LET pNoCte 						= NVL(pNoCte,'');
	LET pSucursal 					= NVL(pSucursal,'');
	LET pNmReferencia 				= NVL(pNmReferencia,'');
	LET pUserName 					= NVL(pUserName,'');
	LET pNumTrama 					= NVL(pNumTrama,'');
	LET pFechaConsulta 				= NVL(pFechaConsulta,'');
	LET pHoraConsulta 				= NVL(pHoraConsulta,'');
	LET pClienteRemesa 				= NVL(pClienteRemesa,'');
	LET pFechaNacimiento 			= NVL(pFechaNacimiento, '');
	LET pNombreCliente 				= NVL(pNombreCliente,'');
	LET pNumeroIdentificacion 		= NVL(pNumeroIdentificacion,'');

	--Control de transacciones
	LET vtransaccion				= 0;

	LET vCajeroWU = (SELECT first 1 ejecutivo FROM bdinteg:"informix".si_ejecut WHERE empresa = '001' AND sucursal=pSucursal and password <> 'BAJA' and nombramiento like 'CAJERO%');

	--Cliente valido para el INE
	LET cNoCteValido = '';

	--SET DEBUG FILE TO "/home/c90302774/sp_consulta_wu_web.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				LET cCodErr = iSqlErr;
				LET cDesc_error = 'Error no controlado';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES(pMarca, 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumCte,''),NVL(cTipoCliente,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(cTipoCte,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorSucursal,''),NVL(cStatusCancelado,''),NVL(cChannel_Type,''),NVL(cChannel_Name,''),NVL(cChannel_Version,''),NVL(cFrs_Identifier,''),NVL(cFrs_Counter_Id,'');
			END IF;
        END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;

		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;

	--Validar que los parametros de entrada no vengan vacios o nulos
		IF pTransaccionQryi = '' OR  pSucursal = '' OR pNmReferencia = '' OR pUserName = '' OR pNumTrama = '' OR pFechaConsulta = '' OR pHoraConsulta = ''OR (pNoCte = '' AND pNumeroIdentificacion = '' AND (pNombreCliente = '' OR pFechaNacimiento = '')) THEN
			LET cCodErr2 = '00001';
			LET cDesc_error = 'Parametros vacios';
		END IF;
			--Se valida que el servicio este activo
		IF TRIM(pMarca) = 'WU' THEN
			LET cConvenio = '006';
		ELIF TRIM(pMarca) = 'OV' THEN
			LET cConvenio = '007';
		ELIF TRIM(pMarca) = 'VG' THEN
			LET cConvenio = '008';
		END IF;
		
		SELECT statusconvenio 
		INTO cStatuConv
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = "07" and numconvenio = cConvenio;

		IF TRIM(cStatuConv) = "I" THEN
			LET cCodErr2 = '00128';
			LET cIdentificadorProceso = '09';
			LET cDesc_error = 'Estatus del convenio Inactivo';
		END IF;									 
		
		EXECUTE PROCEDURE sp_consulta_suc_rem_cpl(TRIM(pNmReferencia), TRIM(pSucursal)) INTO cCodErr2;
		LET cDesc_error = 'Error en sp_consulta_suc_rem_cpl';

		
		IF cCodErr2 = '00000' THEN
			IF pNombreCliente <> '' THEN
				LET cIdentificadorProceso = '01'; -- Guarda el request del servicio BTS

				LET cPrimerNombre = substring(cNombreAux from (iIni)for charindex ('|', substring(cNombreAux from iIni for iFin))-1);
				LET iIni = iIni + charindex ('|', substring(cNombreAux from iIni for iFin));

				LET cSegundoNombre = substring(cNombreAux from iIni for charindex ('|', substring(cNombreAux from iIni for iFin))-1);
				LET iIni = iIni + charindex ('|', substring(cNombreAux from iIni for iFin));

				LET cApellidoPaterno = substring(cNombreAux from iIni for charindex ('|', substring(cNombreAux from iIni for iFin))-1);
				LET iIni = iIni + charindex ('|', substring(cNombreAux from iIni for iFin));

				LET cApellidoMaterno = substring(cNombreAux from iIni for iFin);

				LET cPrimerNombre 	 = NVL(cPrimerNombre,'');
				LET cSegundoNombre   = NVL(cSegundoNombre,'');
				LET cApellidoPaterno = NVL(cApellidoPaterno,'');
				LET cApellidoMaterno = NVL(cApellidoMaterno,'');
			END IF;

			INSERT INTO "informix".sac_consulta_wu_web (transaccionqryi, nocte, sucursal, nmreferencia, numtrama, username, fechaconsulta, horaconsulta, clienteremesa, nombrecliente, fechanacimiento, numeroidentificacion, origen, caja_origen, sucursal_origen, campo_generico1, campo_generico2, campo_generico3)
			VALUES (pTransaccionQryi,pNoCte,pSucursal,pNmReferencia,pNumTrama,pUserName,pFechaConsulta,pHoraConsulta, pClienteRemesa, pNombreCliente, pFechaNacimiento, pNumeroIdentificacion, pCanalOrigen, pCajaOrigen, pSucursalOrigen, pCampoGenerico1, pCampoGenerico2, pCampoGenerico3);

			EXECUTE PROCEDURE "informix".sp_sac_consucursales(TRIM(pSucursal)) INTO cCodErr2,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,cEstadoOriginadorSucursal,cnomestado,ctel1,ctel2,ctipo;

			--EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, pUsuario, pMarca, CURRENT) INTO cCodErr2, cError_Desc, cChannel_Type, cChannel_Name, cChannel_Version, cFrs_Identifier, cFrs_Counter_Id, cTemplete_Id, cNo_reintentos, cUsuario, fechahora_insertCURRENT;

			IF pCanalOrigen='CPL' THEN 
				EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, vCajeroWU, pMarca, CURRENT) INTO cCodErr2, cError_Desc, cChannel_Type, cChannel_Name, cChannel_Version, cFrs_Identifier, cFrs_Counter_Id, cTemplete_Id, cNo_reintentos, cUsuario, fechahora_insertCURRENT;
			ELSE
				EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, pUsuario, pMarca, CURRENT) INTO cCodErr2, cError_Desc, cChannel_Type, cChannel_Name, cChannel_Version, cFrs_Identifier, cFrs_Counter_Id, cTemplete_Id, cNo_reintentos, cUsuario, fechahora_insertCURRENT;
			END IF;
			
			LET cDesc_error = 'Error en sp_wu_obtparamsgenerales';

			IF cCodErr2 = '00000' THEN
				--Obtener el codigo del estado del catalogo de bts
				SELECT state_cd INTO cCod_estado_sucursal FROM sac_bts_catestados WHERE cve_estado = cEstadoOriginadorSucursal;

				--Obtener fecha del sistema para posteriormente llamar sp_consulta_sac_cte_mnsj_remesas
				SELECT fecha_hoy INTO dFechaSistema FROM "informix".sac_fechas;
				LET cMes = MONTH(dFechaSistema);

				LET cIdentificadorProceso = '02'; --Obtener mensaje de estatus
				LET cDesc_error = 'Error en sp_consulta_sac_cte_mnsj_remesas';
				CALL "informix".sp_consulta_sac_cte_mnsj_remesas(cMes, SUBSTR(pNmReferencia,LENGTH(pNmReferencia),1) )
				RETURNING cCodRetRes, cFlagEnrolamiento;

				IF NVL(cCodRetRes,'') = '' OR TRIM(cCodRetRes) <> '00000' THEN
					LET cCodErr2 = cCodRetRes;
				ELSE
					LET cIdentificadorProceso = '03'; -- Valida intentos previos de pago
					SELECT NVL(status_cancelado,'')
					INTO cStatusCancelado
					FROM "informix".sac_movimientos
					WHERE numcategoria = '07' AND numconvenio = cConvenio
					AND referencia1 =  pNmReferencia AND status_cancelado = 'N'
					AND flag_confirmacion_sucursal = '0';

					IF pNoCte <> '' THEN
						LET cNumCte = pNoCte;
						LET cIdentificadorProceso = '04'; -- Busqueda cliente remesa por numero de cliente
						CALL "informix".sp_valida_numerocteremesa(cNumCte)
						RETURNING cCodErr2,cNumCte,cTipoCliente,cValIne,cListaNegra,cSespecial;
					ELIF NVL(pNumeroIdentificacion,'') <> '' THEN
						LET cIdentificadorProceso = '05'; -- Busqueda cliente remesa por numero de id
						CALL "informix".sp_busquedacteremesa_identificacion(pNumeroIdentificacion)
						RETURNING cCodErr2,cNumCte,cTipoCliente,cValIne,cListaNegra,cSespecial;
					ELIF NVL(pNombreCliente,'') <> '' THEN
						LET cIdentificadorProceso = '06'; -- Busqueda cliente remesa por nombre y fecha de nacimiento
						CALL "informix".sp_validausuarioremesa(CPrimerNombre,CSegundoNombre,CApellidoPaterno,cApellidoMaterno,pFechaNacimiento)
						RETURNING cCodErr2,cNumCte,cTipoCliente,cValIne,cListaNegra,cSespecial,cRFC;
					ELSE
						LET cIdentificadorProceso = '07';
						LET cCodErr2 = '00002';
					END IF;
					
					IF cCodErr2 <> '00000' THEN
						
						LET cDesc_error = 'Error en busqueda cliente remesa por numero de cliente, id y nombre';
						
					ELIF cCodErr2 = '00000' THEN

						IF cTipoCliente = "3" THEN
							LET cFlagEnrolamiento = '1';
							LET cDesc_error = 'No existe el cliente';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES(pMarca, 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
						ELIF cListaNegra = 'True' OR cSespecial = 'True' THEN
							LET cCodErr2 = '00004';
							LET cDesc_error = 'Caso especial o Lista negra';
						ELIF cValIne = 'False' THEN
							LET cCodErr2 = '00005';
							LET cDesc_error = 'INE no validada';
						ELSE
							IF cCodErr2 = '00000' THEN
								--Se valida que el cliente exista en base de datos remesas para obtener sus datos
								SELECT COUNT(*) INTO iCont FROM sac_cte_remesas WHERE numcte = cNumCte;
	
								IF iCont <> 0 THEN
									LET cFlagEnrolamiento = '0';
								ELSE
									LET cFlagEnrolamiento = '1';
								END IF;
	
								--Consultar sp para llenar los campos en caso de que sea cliente remesa
								CALL "informix".sp_consulta_datoscteremesa(cNumCte)
								RETURNING cCodRetRes, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, cFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento,
								cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, cFechaVencimiento, cIdOcupacion, cTipoCte, cIdEstado, cIdCiudad, cIdMunicipio, cNumColonia,
								cNumCalle, cNumeroCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, cClavePuesto,
								cClaveSubPuesto;
	
								--EPG 26/03/2021 Validacion si el cliente fue a dar mantenimiento a sus datos
								IF (cFechaVencimiento = '' OR cFechaVencimiento IS NULL OR cFechaVencimiento < dFechaSistema) AND cTipoIdentificacion = 'A' THEN  
							
								--LET cFechaVencimiento = dFechaSistema;	
							
								SELECT LIMIT 1 numcte INTO cNoCteValido
									FROM bdinteg:si_bitacora_ife 
									WHERE fecha >=  EXTEND(MDY(01,01,YEAR(dFechaSistema)), YEAR to SECOND)
									AND numcte = pNoCte 
									AND cod_resp_ife = '91' 
									AND resultado = 'Verdadero';
									
									IF DBINFO("sqlca.sqlerrd2") > 0 THEN
										UPDATE sac_cte_remesas SET fecha_vencimiento =  MDY(12,31,YEAR(dFechaSistema)) WHERE numcte = pNoCte;
										LET cFechaVencimiento = dFechaSistema;
									END IF;
	
								END IF;
								
								IF (cTelefono = '' OR cTelefono IS NULL) AND (cTelefonoCelular <> '' OR cTelefonoCelular IS NOT NULL) THEN
									LET cTelefono = cTelefonoCelular;
								END IF;
								--EPG 26/03/2021
	
								IF cCodRetRes IS NULL OR cCodRetRes <> "00000" THEN
									LET cCodErr2 = cCodRetRes;
									LET cDesc_error = 'Error en la validacion cliente/remesa';
								ELSE
									LET cIdentificadorProceso = '08'; --Validar que el cliente no exista en listas negras
									SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna WHERE rfc = cRFC AND numcte = cNumCte;
									IF iContList > 0 THEN
										LET cCodErr = "00006";
										LET cDesc_error = 'Cliente existe listas negras';
										INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
										VALUES(pMarca, 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;

			IF vtransaccion = 1 THEN
				COMMIT WORK;
				BEGIN WORK;
			ELSE
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			END IF;
	IF cCodErr2 = '00000' THEN
		LET cIdentificadorProceso = '00';
	ELIF cCodErr2 <> '00000' THEN
		INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
		VALUES(pMarca, 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
	END IF;

    RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumCte,''),NVL(cTipoCliente,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(cTipoCte,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorSucursal,''),NVL(cStatusCancelado,''),NVL(cChannel_Type,''),NVL(cChannel_Name,''),NVL(cChannel_Version,''),NVL(cFrs_Identifier,''),NVL(cFrs_Counter_Id,'');
END;
END PROCEDURE
DOCUMENT
'FOLIO.........: Remesas WEB',
'AUTOR.........: 97832715 - Bruno Medina',
'FECHA.........: 06/03/2019	DSB06032019',
'MODIFICACION..: Se crea procedimiento que realiza los llamados a procedimientos para la consulta de remesas',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC';

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
										   pTelCelBenef			VARCHAR(20))                         
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
	
	--SET DEBUG FILE TO '/home/c90302774/sp_pago_wu_web.out';
	--TRACE ON;

	
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
	
	LET cDesc_error 			 = '';
	LET cCod_err2         		 = '00000';
	
	
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
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	 
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodErr = iSqlErr;
			LET cDesc_error = 'Error no controlado';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
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
	
	--Validacion Paises Permitidos
	SELECT LIMIT 1 emisor_cod_pais INTO cPaisOrigen FROM sac_wu_search WHERE fecha_insert >= today AND txn_status = 'A' AND emisor_cod_pais <> '' AND retcode = '00000' AND mtcn = pRefUno;
	
	IF cPaisOrigen = '' OR cPaisOrigen IS NULL THEN
		
		LET cCodErr = "00001";
		LET cIdentificadorProceso = "12";
		LET cRetCode2 = "00222";
		LET cDesc_error = 'No cuenta con registros en la sac_wu_search';
		
		INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
		VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
		
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
				VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
			
				RETURN NVL(cCodErr,""), NVL(cIdentificadorProceso,""), NVL(cRetCode2,""), NVL(cChannelType,""), NVL(cChannelName,""), NVL(cChannelVersion,""), NVL(cFrsIdentifier,""), NVL(cFrsCounterId,"");
			
	END IF;
	
	--Se obtiene el valor de identificador del pago para saber si es la segunda ejecucion para la SEGUNDA IDENTIFICACION, PAGO o DESPAGO
	LET cSegIdentFlag = SUBSTRING(pRefDos FROM 2 FOR 1);
	LET pRefDos = SUBSTRING(pRefDos FROM 1 FOR 1);
	
	IF cSegIdentFlag = 'D' THEN
		--falta un parametro para poder ejecutar el sp de parametros para el servicio para desbloquear la remesa
		IF pEmpresa = "" OR pNumEmp = "" OR pMarca = "" THEN
			LET cCodErr = "00003";
			LET cDesc_error = 'Falta un parametro para poder ejecutar el sp de parametros para el servicio para desbloquear la remesa';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
		ELSE 
			--SP que obtiene los parametros para el servicio de WU/VG/OV
			EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, pNumEmp, pMarca, CURRENT) INTO cRetCode2, cErrorDesc, cChannelType, cChannelName, cChannelVersion, cFrsIdentifier, cFrsCounterId, cTempleteId, cNoreintentos, cUsuario, fechahorainsertCURRENT;
		END IF;
	
	--Se valida que ninguna variable de entrada este vacia 
	ELIF pEmpresa = "" OR pNombre1 = "" OR pApellidoPaterno = "" OR pFechaHoy = "" OR pEstado = "" OR pMontoAPagar = "" OR pSucursal = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pRefUno = "" OR pRetCode = "" OR pDescError = "" OR pMtcn = "" OR pNewMtcn = "" OR pFolSucEmp = "" OR pEmisorNameType = "" OR pBenefNameType = "" OR pMoneyTransKey = "" OR pNumRefRp = "" OR pFusionStatus = "" OR pEmisorCodMoneda = "" OR pBenefEdo = "" OR pSystemIdRp = "" OR pTelefonoCasa = "" OR pCategoria = "" OR pConvenio = "" OR pRefDos = "" OR (pFormaPago <> "1" AND pNumTarjeta = "" AND pCuentaAbono = "") OR peMontoTotal = 0 OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR (pTranEquivCargo = "" AND pTranEquivAbono = "") OR (pFormaPago <> "1" AND pTransSucRef = "") OR pCuentaCargo = "" OR pCheque = "" OR pMontoTotalRef = 0 OR pDivisa = "" OR pReferenciaCargo = "" OR (pFormaPago <> "1" AND pTranEquivAbono = "") OR (pFormaPago <> "1" AND pCuentaAbono = "") OR pMontoFirme = "" OR pMtoSBC = "" OR pMtoRem = "" OR pDiasRet = "" OR (pFormaPago <> "1" AND pReferenciaAbono = "") OR pMtcnConf = "" OR pCiudad = "" OR pEstadoConf = "" OR ptFechaHora = "" OR ptFechaInsert = "" OR pForeignRefNumRq = "" OR pForeingRefNumRp = "" OR pConfPago = "" OR pMarca = "" THEN
			LET cCodErr = "00001";	
			LET cDesc_error = 'Parametros vacios';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
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
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,pNumEmp,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;
			
		IF cRetCode2 <> '00000' THEN
			--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
			--LET cRetCode2 = "00169";
			LET cRetCode2 = "01245";
			LET cIdentificadorProceso = "02";
			LET cCodErrAux = '999999';
			LET cDesc_error = 'Error en sp sp_sac_pldlim_teldom';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
			
		ELSE
			--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom en caso de reversion de la operacion
			LET cValidaPLDteldom = 1;
		
			--SP que obtiene los parametros para el servicio de WU/VG/OV
			EXECUTE PROCEDURE "informix".sp_wu_obtparamsgenerales(pEmpresa, pNumEmp, pMarca, CURRENT) INTO cRetCode2, cErrorDesc, cChannelType, cChannelName, cChannelVersion, cFrsIdentifier, cFrsCounterId, cTempleteId, cNoreintentos, cUsuario, fechahorainsertCURRENT;
			
			IF cRetCode2 <> "00000" THEN
				LET cIdentificadorProceso = "11";
				LET cDesc_error = 'Error en sp sp_wu_obtparamsgenerales';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
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
						VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
					ELIF cFlagTelCasa <> "1" THEN
						LET cRetCode2 = "00001";
						LET cIdentificadorProceso = "08";
						LET cDesc_error = 'Telefono de casa no valido';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
					ELIF cFlagTelCel <> "1" AND pTelefonoCelular <> "" THEN
						LET cRetCode2 = "00002";
						LET cIdentificadorProceso = "08";
						LET cDesc_error = 'Telefono movil no valido';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
					ELSE
						--Se validan los montos
						LET pFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 2)||SUBSTRING(pFechaHoy FROM 7 FOR 2)||SUBSTRING(pFechaHoy FROM 1 FOR 4);
						EXECUTE PROCEDURE "informix".sp_validamontoremesawu_web(pEmpresa, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, pFechaNacimiento, pFechaHoy, pEstado, pMontoAPagar, pSucursal, pMoneda, pMontoMoneda, pRefUno, pRetCode, pDescError, pMtcn, pNewMtcn, pForeignRefNumRq, pEmisorNameType, pBenefNameType, pMoneyTransKey, pForeingRefNumRp, pFusionStatus, pMoneda, pBenefEdo, pSystemIdRp) INTO cRetCode2;
						
						IF cRetCode2 <> "00000" THEN
							LET cIdentificadorProceso = "02";
							LET cDesc_error = 'Error en sp sp_validamontoremesawu_web';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
						ELSE
							--Registrar movimientos
							CALL bdisac:"informix".sp_grabapagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFormaPago, peMontoTotal, peImpComConv, peIvaComConv, peImpComCte, peIvaComCte, pCuentaAbono, pNumEmp, pFolsuc, pTransSuc, pFechaPag)
							RETURNING cRetCode2;
							
							IF vtransaccion = 1 THEN
								COMMIT WORK;
								BEGIN WORK;
							ELSE
								BEGIN WORK;
							END IF;
							
							IF cRetCode2 <> "00000" THEN
								LET cIdentificadorProceso = "03";
								LET cDesc_error = 'Error en sp sp_grabapagoservicio';
								INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
								VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
							ELSE
								--Busco datos de query
								EXECUTE PROCEDURE bdisac:"informix".sp_obtieneremadic(pCategoria, '999', pMtcn)
								INTO cRetCode2, cMoneda, mPaisImporte;
	
								--Actualizo tabla de datos para limites de remesas mensuales
								LET vfec_nac = SUBSTRING(pFechaNacimiento FROM 3 FOR 2) || SUBSTRING(pFechaNacimiento FROM 1 FOR 2) || SUBSTRING(pFechaNacimiento FROM 5 FOR 4);
								EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(pCategoria, pConvenio, pMtcn, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, vfec_nac, cMoneda, mPaisImporte)
								INTO cRetCode2, vcuenta;
								
								IF cRetCode2 <> "00000" THEN
									LET cIdentificadorProceso = "09";
									LET cDesc_error = 'Error en sp sp_actualizaremesa';
									INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
									VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
								ELSE
									
									IF pFormaPago = "1" THEN
										LET pTransSucRef = pTransSuc;
									END IF;								
									--Llamado a sp para aplicar el cargo
									CALL bdicheq:"informix".cargo_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)	
									RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;
									
									IF cRetCode2 <> "000" THEN
										LET cIdentificadorProceso = "07";
										LET cDesc_error = 'Error en sp cargo_ref';
										INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
										VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
									ELSE
										--Se valida que la forma de pago fue en efectivo para evitar el llamado a el sp abono_ref
										IF pFormaPago <> "1" THEN
											--Llamado a sp para el cargo a la cuenta
											CALL bdicheq:"informix".abono_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivAbono, pTransSucRef, pFolsuc, pCuentaAbono, pDocto, pMontoTotalRef, pMontoFirme, pMtoSBC, pMtoRem, pDiasRet, pDivisa, pReferenciaAbono, pNumTarjeta, pUsuAutoriza)
											RETURNING cRetCode2;
										END IF;
										IF cRetCode2 <> "000" THEN
											LET cIdentificadorProceso = "05";
											LET cDesc_error = 'Error en sp abono_ref';
											INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
											VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
										ELSE
											-- Llamado al sp para validar los montos
											SELECT * INTO cRetCode2,cMoneda, mMontoServ, mMontoCargoServ, cDescripcion, iMovtoServ,iMovtoCargoServ 
											FROM TABLE(bdicheq:"informix".sp_mini21(pEmpresa,pNumEmp,pSucursal,pFolsuc));
											IF cRetCode2 <> "00000" THEN
												LET cIdentificadorProceso = "06";
												LET cDesc_error = 'Error en sp sp_mini21';
												INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
												VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
											ELSE
												--Verificar que no hay descuadre en caja
												IF mMontoCargoServ = pValorCargo AND mMontoServ = pValorAbono THEN
													-- Llamado para confirmar el pago
													CALL bdisac:"informix".sp_confpagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
													RETURNING cRetCode2, cDescripcion;
													
													IF cRetCode2 <> "00000" THEN
														LET cIdentificadorProceso = "04";
														LET cDesc_error = 'Error en sp sp_confpagoservicio';
														INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
														VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
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
					VALUES(pMarca, 'Payi', pRefUno, ptFechaInsert, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
				END IF;
			END IF;
		END IF;	
	END IF;
	
	
	IF cIdentificadorProceso != '00' THEN
		IF cCodErrAux != '999999' THEN 
			IF cValidaPLDteldom = 1 THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom(pMarca1,pDirLinea1Benef,pDirLinea2Benef,pBenefEdo,pCodigoPostalBenef1,cAnio||cMEs,pNumEmp,pTelCasaBenef,pTelCelBenef,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
			END IF;	
		END IF;
	END IF;
	
	RETURN NVL(cCodErr,""), NVL(cIdentificadorProceso,""), NVL(cRetCode2,""), NVL(cChannelType,""), NVL(cChannelName,""), NVL(cChannelVersion,""), NVL(cFrsIdentifier,""), NVL(cFrsCounterId,"");
END
END PROCEDURE;