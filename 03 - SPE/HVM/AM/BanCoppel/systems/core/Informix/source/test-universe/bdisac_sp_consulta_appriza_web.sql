CREATE PROCEDURE "informix".sp_consulta_appriza_web
(
	pTransaccionQryi      CHAR(9),
	pNoCte                CHAR(9),
	pSucursal             CHAR(4),
	pNmReferencia         CHAR(11),
	pOperador			  CHAR(8),
	pFechaConsulta        CHAR(8),
	pHoraConsulta         CHAR(6),
	pClienteRemesa        CHAR(1),
	pNombreCliente        CHAR(164),
	pFechaNacimiento      DATE,
	pNumeroIdentificacion CHAR(30)
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
CHAR(15)  As STerminalId,
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
CHAR(2)   As EstadoOriginadorSucursal,
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
	DEFINE cEstadoOriginadorSucursal CHAR(2);
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
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5);
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100);
	DEFINE cnum_ext VARCHAR(6);
	DEFINE cnum_int VARCHAR(5);
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5);
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14);
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);
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
	DEFINE dFecha DATETIME YEAR to SECOND;
	DEFINE cDesc_error CHAR(150);
    
	
	--Control de transacciones
	DEFINE vtransaccion			SMALLINT;
    DEFINE cStatuConv	 		CHAR(1);
    
    --Control MG
    DEFINE cStatuConv_MG        CHAR(1);
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
	LET cEstadoOriginadorSucursal = '';
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
	LET cCod_estado_sucursal = '';
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
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';
	LET cValor = '';
	LET cClavePuesto = '';
	LET cClaveSubPuesto = '';
	LET cNumIntentos = '';
	LET TipoCteRem = '';
	LET dFecha = CURRENT;
	LET cDesc_error = '';
	
	--Control de transacciones	
	LET vtransaccion =   0;
    LET cStatuConv =    '';

    LET cStatuConv_MG = 'A';
    LET cNmReferencia = '';
	--Cliente valido para el INE
	LET cNoCteValido =  '';
	
	--SET DEBUG FILE TO "/informix/RPT/trace.sql";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cDesc_error = 'Error no controlado';
				LET cCodErr = iSqlErr;
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pOperador);
				RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumServicio,''),NVL(cNumIntentos,''),NVL(cApprizacode,''),NVL(cCchannelid,''),NVL(cClocationunit,''),NVL(cTypeCode,''),NVL(cStateCode,''),NVL(cCountryCode,''),NVL(cTerminalId,''),NVL(cNumCte,''),NVL(cTipoCte,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(TipoCteRem,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorRemesa,''),NVL(cStatusCancelado,'');
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
	IF NVL(pTransaccionQryi,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNmReferencia,'') = '' OR NVL(pFechaConsulta,'') = '' OR NVL(pHoraConsulta,'') = ''  THEN
		LET cCodErr2 = '00001';
	END IF;
	
    --lONGITUD DE LA REFERENCIA	
    LET cNmReferencia = LENGTH(TRIM(NVL(pNmReferencia,'')));

    --Se valida que el servicio este activo -- Appriza Pay - Money Gram
	SELECT statusconvenio 
	INTO cStatuConv
	FROM bdisac:"informix".sac_convenios
	WHERE numcategoria = "07" and numconvenio = "009";
         
    IF cNmReferencia = 8 THEN
        SELECT statusconvenio 
        INTO cStatuConv_MG
        FROM bdisac:"informix".sac_convenios
        WHERE numcategoria = "07" and numconvenio = "010";
    END IF;

	IF TRIM(cStatuConv) = "I" THEN
		LET cCodErr2 = '00128';
		LET cIdentificadorProceso = '09';
		LET cDesc_error = 'Estatus Inactivo para el servicio REMESAS APPRIZA';
	END IF;	

	IF TRIM(cStatuConv_MG) = "I" THEN -- SERVICIO DE MG INACTIVO
		LET cCodErr2 = '01927';
		LET cIdentificadorProceso = '09';
		LET cDesc_error = 'Estatus Inactivo para el servicio REMESAS MONEYGRAM';
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

		INSERT INTO bdisac:"informix".sac_consulta_app_web (transaccionQryi,noCte,sucursal,nmReferencia,fechaConsulta,horaConsulta,clienteRemesa,nombreCliente,fechaNacimiento,numeroIdentificacion) 
		VALUES (pTransaccionQryi,pNoCte,pSucursal,pNmReferencia,pFechaConsulta,pHoraConsulta,pClienteRemesa,pNombreCliente,pFechaNacimiento,pNumeroIdentificacion);
	 
		SELECT trans_servicio
		INTO cValor
		FROM bdisac:"informix".sac_intrfz_serv
		WHERE numcategoria = '07'
		AND numconvenio = '009'
		AND num_trama = '1';

		IF cValor = '20067' THEN
			LET cDesc_error = 'Error en sp_verificaconvenio';
			LET cIdentificadorProceso = '02'; -- Valida Estatus Convenio
			CALL sp_verificaconvenio(cValor) returning cCodErr2, cValordesc;
			IF TRIM(cCodErr2) = '00000' THEN
				LET cDesc_error = 'Sucursal inexistente (sp_consultasucursalAppriza, sp_sac_consucursales)';
				LET cIdentificadorProceso = '03'; -- Obtiene datos de Sucursal Appriza
				CALL bdisac:"informix".sp_consultasucursalAppriza(pSucursal,'1')
				RETURNING cCodErr2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cCchannelid, cClocationunit, cTypeCode, cStateCode, cCountryCode;

				EXECUTE PROCEDURE bdisac:"informix".sp_sac_consucursales(TRIM(pSucursal)) into cCodErr2,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,cEstadoOriginadorSucursal,cnomestado,ctel1,ctel2,ctipo;

				IF TRIM(cCodErr2) = '00000' THEN

					--Obtener fecha del sistema para posteriormente llamar sp_consulta_sac_cte_mnsj_remesas
					SELECT fecha_hoy INTO dFechaSistema FROM bdisac:"informix".sac_fechas;
					LET cMes = MONTH(dFechaSistema);

					LET cIdentificadorProceso = '02'; --Obtener mensaje de estatus
					LET cDesc_error = 'Error en sp sp_consulta_sac_cte_mnsj_remesas';
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
								INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
								VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pOperador);
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
									CALL bdisac:"informix".sp_consulta_datoscteremesa(cNumCte)
									RETURNING cCodRetRes, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, cFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento,
									cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, cFechaVencimiento, cIdOcupacion, TipoCteRem, cIdEstado, cIdCiudad, cIdMunicipio, cNumColonia,
									cNumCalle, cNumeroCiudad, cNumExterior, cNumInterior, cDepartamento, cCodPostal, cTelefono, cTelefonoCelular, cIdPaisDomExt, cCorreoElectronico, cClavePuesto,
									cClaveSubPuesto;
	
								--EPG 26/03/2021 Validacion si el cliente fue a dar mantenimiento a sus datos
								IF (cFechaVencimiento = '' OR cFechaVencimiento IS NULL OR cFechaVencimiento < dFechaSistema) AND cTipoIdentificacion = 'A' THEN  
							
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
								
								--EPG 26/03/2021
									
									IF cCodRetRes IS NULL OR cCodRetRes <> "00000" THEN
										LET cCodErr2 = cCodRetRes;
										LET cDesc_error = 'Error en la validacion cliente/remesa';
									ELSE
										LET cIdentificadorProceso = '08'; --Validar que el cliente no exista en listas negras
										SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna WHERE rfc=cRFC and  numcte = cNumCte;
										IF iContList > 0 THEN
											LET cCodErr = "00006";
											LET cDesc_error = 'Cliente existe listas negras';
											INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
											VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pOperador);
										END IF;
									END IF;
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
		VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pOperador);
	END IF;
    RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumServicio,''),NVL(cNumIntentos,''),NVL(cApprizacode,''),NVL(cCchannelid,''),NVL(cClocationunit,''),NVL(cTypeCode,''),NVL(cStateCode,''),NVL(cCountryCode,''),NVL(cTerminalId,''),NVL(cNumCte,''),NVL(cTipoCliente,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(TipoCteRem,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorRemesa,''),NVL(cStatusCancelado,'');
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

CREATE PROCEDURE "informix".sp_consulta_appriza_web
(
	pTransaccionQryi      CHAR(9),
	pNoCte                CHAR(9),
	pSucursal             CHAR(4),
	pNmReferencia         CHAR(11),
	pOperador			  CHAR(8),
	pFechaConsulta        CHAR(8),
	pHoraConsulta         CHAR(6),
	pClienteRemesa        CHAR(1),
	pNombreCliente        CHAR(164),
	pFechaNacimiento      DATE,
	pNumeroIdentificacion CHAR(30),
	pCanalOrigen		  CHAR(4),
	pCajaOrigen			  CHAR(2),
	pSucursalOrigen		  CHAR(4),
	pCampoGenerico1		  CHAR(20),
	pCampoGenerico2		  CHAR(20),
	pCampoGenerico3		  CHAR(20)
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
CHAR(15)  As STerminalId,
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
CHAR(2)   As EstadoOriginadorSucursal,
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
	DEFINE cEstadoOriginadorSucursal CHAR(2);
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
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5);
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100);
	DEFINE cnum_ext VARCHAR(6);
	DEFINE cnum_int VARCHAR(5);
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5);
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14);
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);
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
	DEFINE dFecha DATETIME YEAR to SECOND;
	DEFINE cDesc_error CHAR(150);
	
	--Control de transacciones
	DEFINE vtransaccion	SMALLINT;
    DEFINE cStatuConv	 		CHAR(1);
    
    --Control MG
    DEFINE cStatuConv_MG        CHAR(1);
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
	LET cEstadoOriginadorSucursal = '';
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
	LET cCod_estado_sucursal = '';
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
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';
	LET cValor = '';
	LET cClavePuesto = '';
	LET cClaveSubPuesto = '';
	LET cNumIntentos = '';
	LET TipoCteRem = '';
	LET dFecha = CURRENT;
	LET cDesc_error = '';
	
	--Control de transacciones	EPG
	LET vtransaccion = 0;
	LET cStatuConv =    '';

    LET cStatuConv_MG = 'A';
    LET cNmReferencia = '';
	--Cliente valido para el INE
	LET cNoCteValido =  '';
	
	--Cliente valido para el INE
	LET cNoCteValido = '';

	--SET DEBUG FILE TO "/informix/EPG/sp_consulta_appriza_web.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cDesc_error = 'Error no controlado';
				LET cCodErr = iSqlErr;
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumServicio,''),NVL(cNumIntentos,''),NVL(cApprizacode,''),NVL(cCchannelid,''),NVL(cClocationunit,''),NVL(cTypeCode,''),NVL(cStateCode,''),NVL(cCountryCode,''),NVL(cTerminalId,''),NVL(cNumCte,''),NVL(cTipoCte,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(TipoCteRem,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorRemesa,''),NVL(cStatusCancelado,'');
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
	IF NVL(pTransaccionQryi,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pNmReferencia,'') = '' OR NVL(pFechaConsulta,'') = '' OR NVL(pHoraConsulta,'') = ''  THEN
		LET cCodErr2 = '00001';
	END IF;

	EXECUTE PROCEDURE sp_consulta_suc_rem_cpl(TRIM(pNmReferencia), TRIM(pSucursal)) INTO cCodErr2;
	LET cDesc_error = 'Error en el sp sp_consulta_suc_rem_cpl';
	    --lONGITUD DE LA REFERENCIA	
    LET cNmReferencia = LENGTH(TRIM(NVL(pNmReferencia,'')));
	
    --Se valida que el servicio este activo -- Appriza Pay - Money Gram
	SELECT statusconvenio 
	INTO cStatuConv
	FROM bdisac:"informix".sac_convenios
	WHERE numcategoria = "07" and numconvenio = "009";
         
    IF cNmReferencia = 8 THEN
        SELECT statusconvenio 
        INTO cStatuConv_MG
        FROM bdisac:"informix".sac_convenios
        WHERE numcategoria = "07" and numconvenio = "010";
    END IF;

	IF TRIM(cStatuConv) = "I" THEN
		LET cCodErr2 = '00128';
		LET cIdentificadorProceso = '09';
		LET cDesc_error = 'Estatus Inactivo para el servicio REMESAS APPRIZA';
	END IF;	

	IF TRIM(cStatuConv_MG) = "I" THEN -- SERVICIO DE MG INACTIVO
		LET cCodErr2 = '01927';
		LET cIdentificadorProceso = '09';
		LET cDesc_error = 'Estatus Inactivo para el servicio REMESAS MONEYGRAM';
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
		VALUES (pTransaccionQryi,pNoCte,pSucursal,pNmReferencia,pFechaConsulta,pHoraConsulta,pClienteRemesa,pNombreCliente,pFechaNacimiento,pNumeroIdentificacion, pCanalOrigen, pCajaOrigen, pSucursalOrigen, pCampoGenerico1, pCampoGenerico2, pCampoGenerico3);
	 
		SELECT trans_servicio
		INTO cValor
		FROM bdisac:"informix".sac_intrfz_serv
		WHERE numcategoria = '07'
		AND numconvenio = '009'
		AND num_trama = '1';

		IF cValor = '20067' THEN
			LET cDesc_error = 'Error en sp_verificaconvenio';
			LET cIdentificadorProceso = '02'; -- Valida Estatus Convenio
			CALL sp_verificaconvenio(cValor) returning cCodErr2, cValordesc;
			IF TRIM(cCodErr2) = '00000' THEN
				LET cDesc_error = 'Sucursal inexistente (sp_consultasucursalAppriza, sp_sac_consucursales)';
				LET cIdentificadorProceso = '03'; -- Obtiene datos de Sucursal Appriza
				CALL bdisac:"informix".sp_consultasucursalAppriza(pSucursal,'1')
				RETURNING cCodErr2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cCchannelid, cClocationunit, cTypeCode, cStateCode, cCountryCode;

				EXECUTE PROCEDURE bdisac:"informix".sp_sac_consucursales(TRIM(pSucursal)) into cCodErr2,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,cEstadoOriginadorSucursal,cnomestado,ctel1,ctel2,ctipo;

				IF TRIM(cCodErr2) = '00000' THEN

					--Obtener fecha del sistema para posteriormente llamar sp_consulta_sac_cte_mnsj_remesas
					SELECT fecha_hoy INTO dFechaSistema FROM bdisac:"informix".sac_fechas;
					LET cMes = MONTH(dFechaSistema);

					LET cIdentificadorProceso = '02'; --Obtener mensaje de estatus
					LET cDesc_error = 'Error en sp sp_consulta_sac_cte_mnsj_remesas';
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
								INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
								VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
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
									CALL bdisac:"informix".sp_consulta_datoscteremesa(cNumCte)
									RETURNING cCodRetRes, cPrimerNombre, cSegundoNombre, cApellidoPaterno,  cApellidoMaterno, cFechaNacimiento, cIdNacionalidad, cIdPaisNacimiento, cIdEstadoNacimiento,
									cSexo, cTipoIdentificacion, cNoIdentificacion, cIdPaisEmision, cFechaVencimiento, cIdOcupacion, TipoCteRem, cIdEstado, cIdCiudad, cIdMunicipio, cNumColonia,
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
										SELECT COUNT(*) INTO iContList FROM bdiauditor:"informix".tbl_listainterna WHERE rfc=cRFC and  numcte = cNumCte;
										IF iContList > 0 THEN
											LET cCodErr = "00006";
											LET cDesc_error = 'Cliente existe listas negras';
											INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
											VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
										END IF;
									END IF;
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
		VALUES('APP', 'Qryi', pNmReferencia, dFecha, cCodErr, cCodErr2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
	END IF;
    RETURN NVL(cCodErr,''),NVL(cIdentificadorProceso,''),NVL(cCodErr2,''),NVL(cNumServicio,''),NVL(cNumIntentos,''),NVL(cApprizacode,''),NVL(cCchannelid,''),NVL(cClocationunit,''),NVL(cTypeCode,''),NVL(cStateCode,''),NVL(cCountryCode,''),NVL(cTerminalId,''),NVL(cNumCte,''),NVL(cTipoCliente,''),NVL(cFlagEnrolamiento,''),NVL(cPrimerNombre,''),NVL(cSegundoNombre,''),NVL(cApellidoPaterno,''),NVL(cApellidoMaterno,''),NVL(cFechaNacimiento,''),NVL(cIdNacionalidad,''),NVL(cIdPaisNacimiento,''),NVL(cIdEstadoNacimiento,''),NVL(cSexo,''),NVL(cTipoIdentificacion,''),NVL(cNoIdentificacion,''),NVL(cIdPaisEmision,''),NVL(cFechaVencimiento,''),NVL(cIdOcupacion,''),NVL(TipoCteRem,''),NVL(cIdEstado,''),NVL(cIdCiudad,''),NVL(cIdMunicipio,''),NVL(cNumColonia,''),NVL(cNumCalle,''),NVL(cNumeroCiudad,''),NVL(cNumExterior,''),NVL(cNumInterior,''),NVL(cDepartamento,''),NVL(cCodPostal,''),NVL(cTelefono,''),NVL(cTelefonoCelular,''),NVL(cIdPaisDomExt,''),NVL(cCorreoElectronico,''),NVL(cClavePuesto,''),NVL(cClaveSubPuesto,''),NVL(cEstadoOriginadorRemesa,''),NVL(cStatusCancelado,'');
END;
END PROCEDURE
DOCUMENT
'FOLIO.........: Remesas WEB',
'AUTOR.........: 957360420 - Eduardo Pineda',
'FECHA.........: 26/03/2021',
'MODIFICACION..: Se crea aÃÂ±ade validacion si el cliente fue a dar mantenimiento a sus datos',
'SUSTENTO......: Clientes enrolados sin fecha de vencimiento o fecha de vencimiendo vencida',
'SOLICITA......: LEONARDO HERNANDEZ',
'FOLIO.........: HomologaciÃÂ³n de Remesas',
'AUTOR.........: 93440138 - Noe Medina',
'FECHA.........: 04/06/2020',
'MODIFICACION..: Se crea procedimiento que realiza los llamados a procedimientos para la consulta de remesas Appriza',
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
												pTelefonoCel		CHAR (10),
												pAdress				VARCHAR(80),
												pCity				VARCHAR(40),
												pStateCodeAdr		VARCHAR(3),
												pZipCode 			VARCHAR(10),
												pCanalOrigen          CHAR(4),
												pCajaOrigen           CHAR(2),
												pSucursalOrigen       CHAR(4),
												pFolioOrigen          CHAR(16),
												pCampoGenerico1       CHAR(20),
												pCampoGenerico2       CHAR(20),
												pCampoGenerico3       CHAR(20)
												)

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
	DEFINE dFecha			 	 DATETIME YEAR to SECOND;
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
	
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cValidaPLDteldom INTEGER;

	DEFINE pHoraOrigen      CHAR(6);

	DEFINE vCentroCostosHrem    CHAR(4);
	DEFINE vUsuarioHrem         CHAR(8);
	
	DEFINE cPaisOrigen          CHAR(3);
	DEFINE iCodPais             CHAR(3);
	DEFINE iValPais             INTEGER;	
	DEFINE cDesc_error        	CHAR(150);
	DEFINE cCadena_ent        	CHAR(100);
	DEFINE cHora		      	CHAR(6);
	DEFINE cCod_err2          	CHAR(5);
	
	--SET DEBUG FILE TO '/informix/noe/sp_pago_appriza_web.out';
	--TRACE ON;


	-- Inicializacion de variables --
	LET cCadena_ent 	  		 = TRIM(NVL(pNumEmp,'NULL'))||"|" 
								||TRIM(NVL(pRefUno,'NULL'))||"|" 
								||TRIM(NVL(pFechaHoy,'NULL'));
	LET cHora		    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cDesc_error 			 = '';
	LET cCod_err2         		 = '00000';
	LET cPaisOrigen              = '';        
	LET iCodPais                 = '';    
	LET iValPais                 = 0;
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
	LET pAdress			 = NVL(pAdress, "");
	LET pCity			 = NVL(pCity, "");
	LET pStateCodeAdr	 = NVL(pStateCodeAdr, "");
	LET pZipCode 		 = NVL(pZipCode, "");
	
	LET cDia = '';
	LET cMes = '';
	LET cAnio = '';
	LET cValidaPLDteldom = 0;
	LET dFecha = CURRENT;

	LET pHoraOrigen =(SELECT replace(substr(current,12,8),':','') FROM bdisac:sac_fechas);

	LET vCentroCostosHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87121);
	LET vUsuarioHrem = (SELECT trim(valor) FROM "informix".sac_param WHERE cod_param =87122);

	--SET DEBUG FILE TO "/informix/noe/sp_pago_appriza_web.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodErr = iSqlErr;
			LET cDesc_error = 'Error no controlado';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
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

	--Validacion Paises Permitidos
	SELECT LIMIT 1 r_countrycode INTO cPaisOrigen FROM sac_app_qryi WHERE fecha >= today AND txn_status = 'A' AND r_countrycode <> '' AND r_code = '0000' AND unirefnum = pRefUno; 
		
	IF cPaisOrigen = '' OR cPaisOrigen IS NULL THEN
		LET cCodErr = "00001";
		LET cIdentificadorProceso = "11";
		LET cRetCode2 = "00222";
		LET cDesc_error = 'No cuenta con registros en la sac_app_qryi';
		
		INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
		VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
		
		RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
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
			
				RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
			
	END IF;

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
			--Validacion solicitada por PLD para limites de Direcciones y Telefonos ingresados en el cobro de remesas sp_sac_pldlim_teldom
			
			LET cDia = LPAD(SUBSTRING(pFechaHoy FROM 7 FOR 2), 2, '0');
			LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
			LET cAnio = LPAD(SUBSTRING(pFechaHoy FROM 1 FOR 4), 4, '0');	
			
			IF pCanalOrigen='CPL' THEN 
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,vUsuarioHrem,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;
			ELSE
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;
			END IF;
			
							
			IF cRetCode2 <> '00000' THEN
				--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
				LET cRetCode2 = "01245";
				LET cIdentificadorProceso = "02";
				LET cCodErrAux = '999999';
				LET cDesc_error = 'Error en sp_sac_pldlim_teldom';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
			ELSE
				--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom en caso de reversion de la operacion
				LET cValidaPLDteldom = 1;
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
					LET cDesc_error = 'Error en sp_app_valmonto';
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
				ELSE
					IF pCanalOrigen='CPL' THEN 
						CALL bdisac:"informix".sp_grabapagoservicio_hs(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFormapago, pMontoTotal, pImpComConv, pIvaComConv, pImpComCte, pIvaComCte, pCuentaAbono, vUsuarioHrem, pFolsuc, pTransSuc, pFechaPag, pCanalOrigen, pSucursalOrigen, pCajaOrigen, pTransSuc, pHoraOrigen, pFolioOrigen, pCampoGenerico1, pCampoGenerico2)
						RETURNING cRetCode2;
					ELSE
						CALL bdisac:"informix".sp_grabapagoservicio_hs(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFormapago, pMontoTotal, pImpComConv, pIvaComConv, pImpComCte, pIvaComCte, pCuentaAbono, pNumEmp, pFolsuc, pTransSuc, pFechaPag, pCanalOrigen, pSucursalOrigen, pCajaOrigen, pTransSuc, pHoraOrigen, pFolioOrigen, pCampoGenerico1, pCampoGenerico2)
						RETURNING cRetCode2;
					END IF;	
					
	
					if vtransaccion = 1 then
						COMMIT WORK;
						BEGIN WORK;
					else
						BEGIN WORK;
					end if;
	
					IF cRetCode2 <> "00000" THEN
						LET cIdentificadorProceso = "03";
						LET cDesc_error = 'Error en sp_grabapagoservicio_hs';
						INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
						VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
					ELSE
						LET v_fecha_nac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2), SUBSTRING(pFechaNac FROM 7 FOR 2), SUBSTRING(pFechaNac FROM 1 FOR 4));
						--Llamado a sp para actualizar datos
						CALL bdisac:"informix".sp_actualizaremesa(pCategoria, pConvenio, pRefUno, pNombre1, pNombre2, pApellidoPat, pApellidoMat, v_fecha_nac, pMoneda, pMontoMoneda)
						RETURNING cRetCode2, vCuenta;
	
						IF cRetCode2 <> "00000" THEN
							LET cIdentificadorProceso = "09";
							LET cDesc_error = 'Error en sp_actualizaremesa';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
						ELSE
							--IF pCanalOrigen='CPL' THEN LET pNumEmp='sys_hrem'; END IF;
							
							--Llamado a sp cargo_ref para aplicar el cargo
							IF pCanalOrigen='CPL' THEN 
								CALL bdicheq:"informix".cargo_ref(pEmpresa, vCentroCostosHrem, vUsuarioHrem, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)
								RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;
							ELSE
								CALL bdicheq:"informix".cargo_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)
								RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;
							END IF;	

							
	
							IF cRetCode2 <> "000" THEN
								LET cIdentificadorProceso = "07";
								LET cDesc_error = 'Error en cargo_ref';
								INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
								VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
							ELSE
								--Se valida que la forma de pago fue en efectivo para evitar el llamado a el sp abono_ref
								IF pFormaPago <> "1" THEN
									--Llamado a sp abono_ref para el cargo a la cuenta
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
									LET cDesc_error = 'Error en abono_ref';
									INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
									VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
								ELSE
									IF pCanalOrigen='CPL' THEN 
										CALL bdisac:"informix".sp_confpagoservicio(vCentroCostosHrem, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
										RETURNING cRetCode2, cDescripcion;
									ELSE
										CALL bdisac:"informix".sp_confpagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
										RETURNING cRetCode2, cDescripcion;
									END IF;
									
	
									IF cRetCode2 <> "00000" THEN
										LET cIdentificadorProceso = "04";
										LET cDesc_error = 'Error en sp_confpagoservicio';
										INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
										VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
									ELSE
										--Llamado para obtener parametros para el servicio de pago
										CALL bdisac:"informix".sp_consultasucursalAppriza(pSucursal, "2")
										RETURNING cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
										LET cTransServicio = NVL(cTransServicio, "");
										IF cTransServicio <> "20068" THEN
											LET cIdentificadorProceso = "06";
											LET cDesc_error = 'Error en sp_consultasucursalAppriza';
											INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
											VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pCanalOrigen);
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
	
	
	IF cIdentificadorProceso != '00' THEN
		IF cCodErrAux != '999999' THEN 
			IF cValidaPLDteldom = 1 THEN
				IF pCanalOrigen='CPL' THEN 
					EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,vUsuarioHrem,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
				ELSE
					EXECUTE PROCEDURE "informix".sp_sac_pldlim_teldom('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
				END IF;
				
			END IF;	
		END IF;
	END IF;

	RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
END
END PROCEDURE;