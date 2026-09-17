CREATE PROCEDURE "informix".sp_consulta_remesas_cpl
(
	pTransaccionQryi      CHAR(9), 		--
	pNoCte                CHAR(9), 		--
	pSucursal             CHAR(4), 		--
	pNmReferencia         CHAR(11), 	--
	pOperador			  CHAR(8), 		--
	pFechaConsulta        CHAR(8), 		--
	pHoraConsulta         CHAR(6), 		--
	pClienteRemesa        CHAR(1), 		--
	pNombreCliente        CHAR(164),	--
	pFechaNacimiento      DATE, 			--
	pNumeroIdentificacion CHAR(30), 	--
	pCanalOrigen		  CHAR(4), 		--
	pCajaOrigen			  CHAR(2), 		--
	pSucursalOrigen		  CHAR(4), 		--
	pCodigoEstadoSuc	  CHAR(2) 	 	--
)
RETURNING
CHAR(5)   As codErr,
CHAR(2)   As IdentificadorProceso,
CHAR(5)   As codErr2,
CHAR(5)   As SNumServicio,
CHAR(1)   As SNumIntentos,
CHAR(3)   As SApprizacode,
CHAR(3)   As SCchannelid,
CHAR(3)   As SClocationunit,
CHAR(3)   As STypeCode,
CHAR(3)   As SStateCode,
CHAR(3)   As SCountryCode,
CHAR(20)  As Numcte,
CHAR(1)   As TipoCliente,
CHAR(1)   As flagEnrolamiento,
CHAR(40)  As PrimerNombre,
CHAR(40)  As SegundoNombre,
CHAR(40)  As ApellidoPaterno,
CHAR(40)  As ApellidoMaterno,
CHAR(10)  As FechaNacimiento,
CHAR(3)   As IdNacionalidad,
CHAR(3)   As IdPaisNacimiento,
CHAR(2)   As IdEstadoNacimiento,
CHAR(1)   As Sexo,
CHAR(2)   As TipoIdentificacion,
CHAR(30)  As NoIdentificacion,
CHAR(3)   As IdPaisEmision,
CHAR(10)  As FechaVencimiento,
CHAR(3)   As IdOcupacion,
CHAR(2)   As TipoCteRem,
CHAR(2)   As IdEstado,
CHAR(3)   As IdCiudad,
CHAR(5)   As IdMunicipio,
CHAR(10)  As NumColonia,
CHAR(10)  As NumCalle,
CHAR(10)  As NumeroCiudad,
CHAR(10)  As NumExterior,
CHAR(10)  As NumInterior,
CHAR(10)  As Departamento,
CHAR(5)   As CodPostal,
CHAR(13)  As Telefono,
CHAR(13)  As TelefonoCelular,
CHAR(3)   As IdPaisDomExt,
CHAR(100) As CorreoElectronico,
CHAR(10)  As ClavePuesto,
CHAR(10)  As ClaveSubPuesto,
CHAR(2)   As cEstadoOriginadorRemesa,
CHAR(1)   As StatusCancelado;

	-- Definicion de variables --
	DEFINE cCodErr CHAR(5);
	DEFINE cIdentificadorProceso CHAR(2);
	DEFINE cCodErr2 CHAR(5);
	DEFINE cFlagEnrolamiento CHAR(1);
	DEFINE cNumServicio CHAR(5);
	DEFINE cApprizacode CHAR(3);
	DEFINE cCchannelid CHAR(3);
	DEFINE cClocationunit CHAR(15);
	DEFINE cTypeCode CHAR(3);
	DEFINE cCountryCode CHAR(3);
	DEFINE cStateCode CHAR(3);
	DEFINE cTerminalId CHAR(15);
	DEFINE cProcessDate CHAR(8);
	DEFINE cProcessTime CHAR(6);
	DEFINE cPrimerNombre CHAR(40);
	DEFINE cSegundoNombre CHAR(40);
	DEFINE cApellidoPaterno CHAR(40);
	DEFINE cApellidoMaterno CHAR(40);
	DEFINE cFechaNacimiento CHAR(10);
	DEFINE cIdNacionalidad CHAR(3);
	DEFINE cIdPaisNacimiento CHAR(3);
	DEFINE cIdEstadoNacimiento CHAR(2);
	DEFINE cSexo CHAR(1);
	DEFINE cTipoIdentificacion CHAR(2);
	DEFINE cNoIdentificacion CHAR(30);
	DEFINE cIdPaisEmision CHAR(3);
	DEFINE cFechaVencimiento CHAR(10);
	DEFINE cIdOcupacion CHAR(3);
	DEFINE cTipoCte CHAR(2);
	DEFINE cIdEstado CHAR(2);
	DEFINE cIdCiudad CHAR(3);
	DEFINE cIdMunicipio CHAR(5);
	DEFINE cNumColonia CHAR(10);
	DEFINE cNumCalle CHAR(10);
	DEFINE cNumeroCiudad CHAR(10);
	DEFINE cNumExterior CHAR(10);
	DEFINE cNumInterior CHAR(10);
	DEFINE cDepartamento CHAR(10);
	DEFINE cCodPostal CHAR(5);
	DEFINE cTelefono CHAR(13);
	DEFINE cTelefonoCelular CHAR(13);
	DEFINE cIdPaisDomExt CHAR(3);
	DEFINE cCorreoElectronico CHAR(100);
	DEFINE cEstadoOriginadorRemesa CHAR(2);
	DEFINE cStatusCancelado CHAR(1);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechaSistema DATE;
	DEFINE cMes CHAR(2);
	DEFINE cCodRetRes CHAR(5);
	DEFINE cStatusMnsj CHAR(1);
	DEFINE iContList INTEGER;
	DEFINE iCont INTEGER;
	DEFINE cNumCte CHAR(9);
	DEFINE cTipoCliente CHAR(1);
	DEFINE cValIne CHAR(5);
	DEFINE cListaNegra CHAR(5);
	DEFINE cSespecial CHAR(5);
	DEFINE cRFC CHAR(15);
	DEFINE cNombreAux CHAR(164);
	DEFINE iPosicion INTEGER;
	DEFINE cCod_estado_sucursal CHAR(2);
	DEFINE cValordesc CHAR (100);
	DEFINE cValor CHAR(5);
	DEFINE cClavePuesto CHAR(10);
	DEFINE cClaveSubPuesto CHAR(10);
	DEFINE TipoCteRem CHAR(2);
	DEFINE cCodRet CHAR(5);
	DEFINE cTransaccInt CHAR(5);
	DEFINE cTransServicio CHAR(5);
	DEFINE cNumIntentos CHAR(1);
	DEFINE cChannelID CHAR(3);
	DEFINE cDesc_error CHAR(150);
	DEFINE dFecha DATETIME YEAR to SECOND;


	--Control de transacciones
	DEFINE vtransaccion	SMALLINT;
    DEFINE cStatuConv	 		CHAR(1);

    --Control estatus convenio remesadoras
    DEFINE cStatuConv_REM        CHAR(1);
    DEFINE cCodErrRem            CHAR(5);
    DEFINE cNmReferencia        CHAR(12);

	--Cliente valido para el INE EPG
	DEFINE cNoCteValido CHAR(9);

	-- Inicializacion de variables --
	LET cCodErr = '00000';
	LET cIdentificadorProceso = '01';
	LET cCodErr2 = '00000';
	LET cFlagEnrolamiento = '';
	LET cNumServicio = '';
	LET cApprizacode = '';
	LET cCchannelid = '';
	LET cClocationunit = '';
	LET cTypeCode = '';
	LET cCountryCode = '';
	LET cStateCode = '';
	LET cTerminalId = '';
	LET cProcessDate = '';
	LET cProcessTime = '';
	LET cPrimerNombre = '';
	LET cSegundoNombre = '';
	LET cApellidoPaterno = '';
	LET cApellidoMaterno = '';
	LET cFechaNacimiento = '';
	LET cIdNacionalidad = '';
	LET cIdPaisNacimiento = '';
	LET cIdEstadoNacimiento = '';
	LET cSexo = '';
	LET cTipoIdentificacion = '';
	LET cNoIdentificacion = '';
	LET cIdPaisEmision = '';
	LET cFechaVencimiento = '';
	LET cIdOcupacion = '';
	LET cTipoCte = '';
	LET cIdEstado = '';
	LET cIdCiudad = '';
	LET cIdMunicipio = '';
	LET cNumColonia = '';
	LET cNumCalle = '';
	LET cNumeroCiudad = '';
	LET cNumExterior = '';
	LET cNumInterior = '';
	LET cDepartamento = '';
	LET cCodPostal = '';
	LET cTelefono = '';
	LET cTelefonoCelular = '';
	LET cIdPaisDomExt = '';
	LET cCorreoElectronico = '';
	LET cEstadoOriginadorRemesa = '';
	LET cStatusCancelado = '';
	LET iSqlErr = 0;
	LET dFechaSistema = '01-01-1900';
	LET cMes = '';
	LET cCodRetRes = '';
	LET cStatusMnsj = '';
	LET iContList = 0;
	LET iCont = 0;
	LET cNumCte = '';
	LET cTipoCliente = '';
	LET cValIne = '';
	LET cListaNegra = '';
	LET cSespecial = '';
	LET cRFC = '';
	LET cNombreAux = '';
	LET iPosicion = 0;
	LET cStatuConv_REM = '';
	LET cCodErrRem = '00128';
	LET cValor = '';
	LET cClavePuesto = '';
	LET cClaveSubPuesto = '';
	LET cNumIntentos = '';
	LET TipoCteRem = '';
	LET cDesc_error = '';
	LET dFecha = CURRENT;


	--Control de transacciones	EPG
	LET vtransaccion = 0;
	LET cStatuConv =    '';

    LET cStatuConv_REM = 'A';
    LET cNmReferencia = '';
	--Cliente valido para el INE
	LET cNoCteValido =  '';

	--Cliente valido para el INE
	LET cNoCteValido = '';

	--SET DEBUG FILE TO "/home/c90307738/cpl/sp_consulta_remesas_cpl.log";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				

				RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumServicio,''),NVL(cNumIntentos,''),NVL(cApprizacode,''),NVL(cCchannelid,''),NVL(cClocationunit,''),NVL(cTypeCode,''),NVL(cStateCode,''),NVL(cCountryCode,''),NVL(cNumCte,''),NVL(cTipoCliente,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(TipoCteRem,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorRemesa,''),NVL(cStatusCancelado,'');
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
		IF NVL(pTransaccionQryi,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNmReferencia,'') = '' OR NVL(pFechaConsulta,'') = '' OR NVL(pHoraConsulta,'') = '' OR NVL(pCodigoEstadoSuc,'') = ''  THEN
			LET cCodErr2 = '00001';
		END IF;
				--lONGITUD DE LA REFERENCIA
			LET cNmReferencia = LENGTH(TRIM(NVL(pNmReferencia,'')));

			--VERIFICAR ESTATUS DE LOS CONVENIOS
		SELECT statusconvenio
		INTO cStatuConv
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = "07" and numconvenio = "009";


		--CONVENIO INACTIVO
		IF TRIM(cStatuConv) = "I" OR cStatuConv_REM = "I" THEN
			LET cCodErr2 = cCodErrRem;
			LET cIdentificadorProceso = '09';
		END IF;


		IF TRIM(cCodErr2) = '00000' THEN
			LET cIdentificadorProceso = '01'; -- Guarda el request del servicio Appriza

			LET iPosicion = INSTR(pNombreCliente,'|');
			LET cPrimerNombre  = SUBSTR(pNombreCliente,0,iPosicion-1);
			LET cNombreAux     = SUBSTR(pNombreCliente,iPosicion + 1,LENGTH(TRIM(pNombreCliente)));

			LET iPosicion = INSTR(cNombreAux,'|');
			LET cSegundoNombre = SUBSTR(cNombreAux,0,iPosicion-1);
			LET cNombreAux     = SUBSTR(cNombreAux,iPosicion + 1,LENGTH(TRIM(cNombreAux)));

			LET iPosicion = INSTR(cNombreAux,'|');
			LET cApellidoPaterno = SUBSTR(cNombreAux,0,iPosicion-1);
			LET cNombreAux     = SUBSTR(cNombreAux,iPosicion + 1,LENGTH(TRIM(cNombreAux)));

			LET cApellidoMaterno = cNombreAux;

			LET cPrimerNombre = NVL(cPrimerNombre,'');
			LET cSegundoNombre = NVL(cSegundoNombre,'');
			LET cApellidoPaterno = NVL(cApellidoPaterno,'');
			LET cApellidoMaterno = NVL(cApellidoMaterno,'');

			INSERT INTO bdisac:"informix".sac_consulta_app_web (transaccionQryi, noCte, sucursal, nmReferencia, fechaConsulta, horaConsulta, clienteRemesa, nombreCliente, fechaNacimiento, numeroIdentificacion, origen, caja_origen, sucursal_origen, campo_generico1, campo_generico2, campo_generico3)
			VALUES (pTransaccionQryi,pNoCte,pSucursal,pNmReferencia,pFechaConsulta,pHoraConsulta,pClienteRemesa,pNombreCliente,pFechaNacimiento,pNumeroIdentificacion, pCanalOrigen, pCajaOrigen, pSucursalOrigen, pCodigoEstadoSuc, '', '');

			SELECT trans_servicio
			INTO cValor
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '1';

			IF cValor = '20067' THEN
				LET cIdentificadorProceso = '02'; -- Valida Estatus Convenio
				CALL sp_verificaconvenio(cValor) returning cCodErr2, cValordesc;
				IF TRIM(cCodErr2) = '00000' THEN
					LET cIdentificadorProceso = '03'; 

					CALL bdisac:"informix".sp_param_remesas_cpl(pCodigoEstadoSuc, "1")
					RETURNING cCodErr2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cCchannelid, cClocationunit, cTypeCode, cStateCode, cCountryCode;
					IF TRIM(cCodErr2) = '00000' THEN

						--Obtener fecha del sistema para posteriormente llamar sp_consulta_sac_cte_mnsj_remesas
						SELECT fecha_hoy INTO dFechaSistema FROM bdisac:"informix".sac_fechas;
						LET cMes = MONTH(dFechaSistema);

						LET cIdentificadorProceso = '02'; --Obtener mensaje de estatus
				
						CALL "informix".sp_consulta_sac_cte_mnsj_remesas(cMes, SUBSTR(pNmReferencia,LENGTH(pNmReferencia),1) )
						RETURNING cCodErr2, cFlagEnrolamiento;

						IF TRIM(cCodErr2) = '00000' THEN

							LET cIdentificadorProceso = '03'; -- Valida intentos previos de pago
							SELECT NVL(status_cancelado,'')
							INTO cStatusCancelado
							FROM bdisac:"informix".sac_movimientos
							WHERE numcategoria = '07' AND numconvenio = '009'
							AND referencia1 =  pNmReferencia AND status_cancelado = 'N'
							AND flag_confirmacion_sucursal = '0';

							IF pNoCte <> '' THEN

								LET cNumCte = pNoCte;
								LET cIdentificadorProceso = '04'; -- Busqueda cliente remesa por numero de cliente
								CALL "informix".sp_valida_numerocteremesa(cNumCte)
								RETURNING cCodErr2,cNumCte,cTipoCliente,cValIne,cListaNegra,cSespecial;

							ELIF NVL(pNumeroIdentificacion,'') <> '' THEN

								LET cIdentificadorProceso = '05'; -- Busqueda cliente remesa por numero de id
								CALL bdisac:"informix".sp_busquedacteremesa_identificacion(pNumeroIdentificacion)
								RETURNING cCodErr2,cNumCte,cTipoCliente,cValIne,cListaNegra,cSespecial;

							ELIF NVL(pNombreCliente,'') <> '' THEN

								LET cIdentificadorProceso = '06'; -- Busqueda cliente remesa por nombre y fecha de nacimiento
								CALL bdisac:"informix".sp_validausuarioremesa(CPrimerNombre,CSegundoNombre,CApellidoPaterno,cApellidoMaterno,pFechaNacimiento)
								RETURNING cCodErr2,cNumCte,cTipoCliente,cValIne,cListaNegra,cSespecial,cRFC;

							ELSE
								LET cIdentificadorProceso = '07'; -- Busqueda cliente remesa por numero de cliente
								LET cCodErr2 = '00002';
							END IF;

							IF cCodErr2 <> '00000' THEN
						
							LET cDesc_error = 'Error en busqueda cliente remesa por numero de cliente, id y nombre';

							ELIF cCodErr2 = '00000' THEN
								IF cTipoCliente = "3" THEN
									LET cFlagEnrolamiento = '1';
									LET cDesc_error = 'No existe el cliente';
									INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, 	fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
									VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, 	pSucursal, pCanalOrigen);
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
											LET cFlagEnrolamiento = '0'; --ENROLADO
										ELSE
											LET cFlagEnrolamiento = '1'; --NO ENROLADO
										END IF;

										--Consultar sp para llenar los campos en caso de que sea cliente remesa
										CALL bdisac:"informix".sp_consulta_datoscteremesa(cNumCte)
										RETURNING cCodRetRes, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, 	cFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento,
										cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, cFechaVencimiento, cIdOcupacion, 	TipoCteRem, cIdEstado, cIdCiudad, cIdMunicipio, cNumColonia,
										cNumCalle, cNumeroCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, 	cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, cClavePuesto,
										cClaveSubPuesto;

									--Validacion si el cliente fue a dar mantenimiento a sus datos
										IF (cFechaVencimiento = '' OR cFechaVencimiento IS NULL OR 	cFechaVencimiento < dFechaSistema) AND cTipoIdentificacion = 'A' THEN



										SELECT LIMIT 1 numcte INTO cNoCteValido
										FROM bdinteg:si_bitacora_ife
										WHERE fecha >=  EXTEND(MDY(01,01,YEAR(dFechaSistema)), YEAR to SECOND)
										AND numcte = pNoCte
										AND cod_resp_ife = '91'
										AND resultado = 'Verdadero';

										IF DBINFO("sqlca.sqlerrd2") > 0 THEN
											UPDATE sac_cte_remesas SET fecha_vencimiento =  MDY(12,31,YEAR(dFechaSistema)) WHERE numcte = 	pNoCte;
											LET cFechaVencimiento = dFechaSistema;
										END IF;

									END IF;

									IF (cTelefono = '' OR cTelefono IS NULL) AND (cTelefonoCelular <> '' OR cTelefonoCelular IS NOT NULL) 	THEN
										LET cTelefono = cTelefonoCelular;
									END IF;

										IF cCodRetRes IS NULL OR cCodRetRes <> "00000" THEN
											LET cCodErr2 = cCodRetRes;
										ELSE
											LET cIdentificadorProceso = '08'; --Validar que el cliente no exista en listas negras
											SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna WHERE rfc=cRFC AND 	numcte = cNumCte;
											IF iContList > 0 THEN
												LET cCodErr = "00006";
												LET cDesc_error = 'Cliente existe listas negras';
												INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, 	referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, 	sucursal, user_insert)
												VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, 	cDesc_error, pSucursal, pCanalOrigen);
												END IF;
										END IF;
									END IF;
								END IF;
							END IF;	
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
		COMMIT WORK;
		IF cCodErr2 = '00000' THEN
			LET cIdentificadorProceso = '00';
		ELIF cCodErr2 <> '00000' THEN
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, 	identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
		END IF;
		RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumServicio,''),NVL(cNumIntentos,''),NVL(cApprizacode,''),NVL(cCchannelid,''),NVL(cClocationunit,''),NVL(cTypeCode,''),NVL(cStateCode,''),NVL(cCountryCode,''),NVL(cNumCte,''),NVL(cTipoCliente,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(TipoCteRem,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorRemesa,''),NVL(cStatusCancelado,'');
	END;

END PROCEDURE
DOCUMENT
'FOLIO.........: Homologacion Coppel',
'FECHA.........: 19/10/2023',
'DESCRIPCION..:  Procedimiento para consultar remesas para cajas de abono Coppel',
'SOLICITA......: Edgar Navarro',
'BD............: Bdisac';

CREATE PROCEDURE "informix".sp_param_remesas_cpl(pClaveEstado CHAR(2), pTipoConsulta CHAR (1))
RETURNING CHAR(5) AS cCodRet, CHAR(5) AS cTransaccInt, CHAR(5) AS cTransServicio,CHAR (1) AS cNumIntentos,CHAR(3) AS cApprizaCode, CHAR(3) AS cChannelID, CHAR(3) AS cLocationUnit ,CHAR(3) AS cTypeCode, CHAR (3) AS cStateCode ,CHAR (3) AS cCountryCode;

--
	DEFINE sql_err			INTEGER;
	DEFINE cCodRet			CHAR(5);
	DEFINE cTransaccInt		CHAR(5);
	DEFINE cTransServicio	CHAR(5);
	DEFINE cApprizaCode		CHAR(3);
	DEFINE cChannelID		CHAR(3);
	DEFINE cTypeCode		CHAR(3);
	DEFINE cCountryCode		CHAR(3);
	DEFINE cStateCode		CHAR(3);
	DEFINE cLocationUnit	CHAR(3);
	DEFINE cNumIntentos		INT;
	DEFINE iCodParamAppriza	INT;
	DEFINE iCodParamChanID	INT;
	DEFINE iCodParamTypCode	INT;
	DEFINE iCodParamIdPais	INT;
	DEFINE iCodParamLocUnit	INT;
	DEFINE cSPCodRet 		CHAR(5);
	DEFINE iMensaje 		CHAR(50);
	DEFINE cid_ptf 			CHAR(5);
	DEFINE ccve_pais 		CHAR(3);
	DEFINE cnompais 		CHAR(20);
	DEFINE ccalle 			VARCHAR(100);
	DEFINE cnum_ext 		VARCHAR(6);
	DEFINE cnum_int 		VARCHAR(5);
	DEFINE ccve_col 		CHAR(8);
	DEFINE cnomcol 			VARCHAR(100);
	DEFINE ccve_mun 		CHAR(3);
	DEFINE cnommunicipio 	VARCHAR(60);
	DEFINE ccve_localidad 	CHAR(14);
	DEFINE cnomlocalidad 	VARCHAR(60);
	DEFINE ccp 				CHAR(5);
	DEFINE ccve_ciudad 		CHAR(3);
	DEFINE cnomciudad 		VARCHAR(60);
	DEFINE ccve_estado 		CHAR(2);
	DEFINE cnomestado 		VARCHAR(30);
	DEFINE ctel1 			VARCHAR(14);
	DEFINE ctel2 			VARCHAR(14);
	DEFINE ctipo 			VARCHAR(5);

	LET sql_err				= 0;
	LET cCodRet				= '00000';
	LET cTransaccInt		= '';
	LET cTransServicio		= '';
	LET cApprizaCode		= '';
	LET cChannelID			= '';
	LET cTypeCode			= '';
	LET cCountryCode		= '';
	LET cStateCode			= '';
	LET cLocationUnit		= '';
	LET cNumIntentos		= '';
	LET iCodParamAppriza	= 87117;
	LET iCodParamChanID		= 87123;
	LET iCodParamLocUnit	= 87118;
	LET iCodParamTypCode	= 87105;
	LET iCodParamIdPais		= 87106;

	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = '';
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = '';
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';

--------------------------------------------------------------------------
--SET DEBUG FILE TO "/informix/BDHS/homologacionCPL/logs/sp_param_remesas_cpl.log";
--    TRACE ON;
--------------------------------------------------------------------------

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
	    RETURN cCodRet, cTransaccInt, cTransServicio, cNumIntentos,cApprizaCode, cChannelID, cLocationUnit,cTypeCode, cStateCode,cCountryCode;
      END IF;
END EXCEPTION;

	SELECT TRIM(valor)
	INTO cApprizaCode
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamAppriza;


	SELECT TRIM(valor)
	INTO cChannelID
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamChanID;

	SELECT TRIM(valor)
	INTO cLocationUnit
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamLocUnit;

	SELECT TRIM(valor)
	INTO cTypeCode
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamTypCode;

	SELECT TRIM(valor)
	INTO cCountryCode
    FROM BDISAC:"informix".sac_param
    WHERE cod_param = iCodParamIdPais;

	SELECT trans_interact, trans_servicio,campo_codresp::INT
	INTO cTransaccInt,cTransServicio,cNumIntentos
	FROM BDISAC:"informix".sac_intrfz_serv
	WHERE numcategoria = '07'
	AND numconvenio = '009'
	AND num_trama = pTipoConsulta;

	SELECT state_cd
	INTO cStateCode
	FROM BDISAC:"informix".sac_app_catestados
	WHERE cve_estado = pClaveEstado;

	IF cTransaccInt IS NULL OR cTransServicio IS NULL  OR cApprizaCode IS NULL OR cChannelID IS NULL OR cTypeCode IS NULL OR cCountryCode IS NULL OR cStateCode IS NULL THEN
		LET cCodRet = '99999';
	END IF;
	--
	RETURN cCodRet, cTransaccInt, cTransServicio, cNumIntentos,cApprizaCode, cChannelID, cLocationUnit,cTypeCode, cStateCode,cCountryCode;


   END;
END PROCEDURE;