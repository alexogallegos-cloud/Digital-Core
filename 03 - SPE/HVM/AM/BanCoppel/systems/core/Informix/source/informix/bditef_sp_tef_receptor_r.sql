CREATE PROCEDURE "informix".sp_tef_receptor_r ( cNombreArchivo CHAR(20), cNumEmpleado CHAR (8))

RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE TEF -- RECEPTOR RECEPTOR  PROCESAR ARCH. 10 Y 60.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 16/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE cPROCESANDO					CHAR(1);
DEFINE cERROR 						CHAR(1);
DEFINE cFINALIZADO					CHAR(1);
DEFINE cDescripcionProceso			CHAR (60);
DEFINE cFlagTipoProceso 			CHAR (1);
DEFINE iTipoArchivo					SMALLINT ;
DEFINE cFlagUnico					CHAR (1);
DEFINE cBloque 						CHAR (2);
DEFINE cFechaPresentacion			CHAR (8);
DEFINE cFechaPresentacion1			CHAR (8);
DEFINE cFechaPresentacion2			CHAR (8);

DEFINE cCodRetorno					CHAR (5);
DEFINE cCodRetorno2					CHAR (5);
DEFINE cCodRetorno3					CHAR (5);
DEFINE cMensajeRespuesta			CHAR (100);
DEFINE cValorParam					CHAR (100);
DEFINE csNomArchivo					CHAR (20);
DEFINE csNomArchivo11				CHAR (20);
DEFINE csNomArchivo61				CHAR (20);
--DEFINE csNomArchivo62 CHAR (20);--dsb-27/04/2012
DEFINE iContador					INTEGER;
DEFINE dFecha						DATE;
DEFINE iSqlErr						INTEGER ;

DEFINE cRuta						CHAR (100);

DEFINE cNomProceso					CHAR (20);
DEFINE cCodBanco					CHAR(3);
DEFINE cCodRetSub					VARCHAR(115); ---descripcion
DEFINE cFechaAplica					CHAR(8);
DEFINE dFechaAplicaDe				DATE;

DEFINE iNumArchivos					INTEGER;

DEFINE cFlagArch11					CHAR(1);
DEFINE cFlagArch61					CHAR(1);
--DEFINE vsFlagArch62 CHAR(1);--dsb-27/04/2012
DEFINE dFechaPresentacionResp		DATE;

DEFINE dFechProx					DATE;
DEFINE dFechaAux					DATE;
DEFINE iContadorDias				INTEGER;

--DEFINE vsSQL						CHAR(2204);--27/04/2012

	--SET DEBUG FILE TO "/informix/frg/sp_tef_receptor_r.out";
	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
--VARIABLES DE MONITOR
LET cPROCESANDO 			='0';
LET cFINALIZADO				='1';
LET cERROR					='3';
LET cDescripcionProceso		= '';
LET cFlagTipoProceso		= '';
LET iTipoArchivo			= 0;
LET cFlagUnico				= 'F';
LET cBloque					= '00';
LET cFechaPresentacion		= '';
LET cFechaPresentacion2		= '';

LET cCodRetorno				= '';
LET cCodRetorno2			= '';
LET cCodRetorno3			= '';
LET cMensajeRespuesta		= '';
LET cValorParam				= '';
LET csNomArchivo			= '';
LET csNomArchivo11			= '';
LET csNomArchivo61			= '';
--LET csNomArchivo62 = '';--dsb-27/04/2012
LET iContador				= 0;
LET dFecha					= CURRENT::DATE;

LET cRuta					= '';

LET cNomProceso				= '';

LET iSqlErr					= 0;
LET cCodBanco				= "";
LET cCodRetSub				= "";
LET cFechaAplica			= "";

LET iNumArchivos			= 0;

LET cFlagArch11				= 'F';
LET cFlagArch61				= 'F';
--LET vsFlagArch62 = 'F';--dsb-27/04/2012
LET dFechaPresentacionResp	= CURRENT::DATE;

LET iContadorDias			= 0;
LET dFechaAux				= CURRENT::DATE;

--LET vsSQL					= "";--27/04/2012

BEGIN

	ON EXCEPTION SET iSqlErr   --CONTROL DE ERRORES

		EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
		cERROR, iSqlErr, cNumEmpleado, 'ERROR NO CONTROLADO', TRIM(csNomArchivo), cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;

		LET cMensajeRespuesta = 'ERROR NO CONTROLADO(' || iSqlErr || ') ARCHIVO: ' || TRIM(csNomArchivo) || 'PROCESO: ' || TRIM(cDescripcionProceso) ;

		RETURN  csNomArchivo, iSqlErr, cMensajeRespuesta ;

	END EXCEPTION;

	LET cDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Cadena(TRIM(cNumEmpleado),'N') INTO cCodRetorno;

	LET cDescripcionProceso = 'Validacion de parametros.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR
		LET cCodRetorno = '00401';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '72') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA
		LET cCodRetorno = '00402';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '73') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS
		LET cCodRetorno = '00403';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '74') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS
		LET cCodRetorno = '00404';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL
		LET cCodRetorno = '00405';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET cCodRetorno = '00406';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77') THEN -- Valida que exista el parametro SUCURSAL CONTABLE TEF
		LET cCodRetorno = '00407';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR TEF
		LET cCodRetorno = '00408';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79') THEN -- Valida que exista el parametro TRANSACCION DE ABONO
		LET cCodRetorno = '00409';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '80') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN
		LET cCodRetorno = '00410';
	ELIF(NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto <> '') ) THEN--Valida que existan PRODUCTOS PERMITIDOS PARA TEF.
	--ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA TEF
		LET cCodRetorno = '00412';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:"informix".Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET cCodRetorno = '00414';
	ELIF (TRIM(cNumEmpleado) = '') THEN --NUMERO DE EMPLEADO VACIO
		LET cCodRetorno = '00415';
	ELIF (LENGTH(TRIM(cNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS
		LET cCodRetorno = '00416';
	ELIF (cCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS
		LET cCodRetorno = '00417';
	ELIF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(cNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
		LET cCodRetorno = '00462';
	ELSE --TODO LOS PARAMETROS EXISTEN

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT LIMIT 1 Fecha_Hoy INTO dFecha FROM BdiCheq:"informix".Sc_Fechas;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- OBTIENE CODIGO DE BANCOPPEL
		SELECT LIMIT 1 TRIM(valor) INTO cCodBanco FROM BdiTef:"informix". Tef_Parametros WHERE cod_param = '75';

		--MODIFICADO A SOLICITUD DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
		--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
		--2011/09/29
		/*EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(dFecha), 4, '0') || LPAD (MONTH(dFecha), 2, '0') || LPAD (DAY(dFecha), 2, '0')) INTO cCodRetorno;
		LET cFechaPresentacion = LPAD (YEAR(dFecha), 4, '0') || LPAD (MONTH(dFecha), 2, '0') || LPAD (DAY(dFecha), 2, '0');

		-- Se guarda el valor para compararlo con el encabezado del archivo
		LET cFechaPresentacion1 = LPAD (YEAR(dFecha), 4, '0') || LPAD (MONTH(dFecha), 2, '0') || LPAD (DAY(dFecha), 2, '0');
		*/
		
		
		IF ((cNombreArchivo = '') 
		OR ((SUBSTR(cNombreArchivo, 13, 2)) /*DIA ARCHIVO*/ = (LPAD(DAY(dFecha),2,'0')) /*DIA PROCESO*/ ) --MANUAL --HOY
		) THEN --AUTOMATICO --HOY
			--ARCHIVO DEL DIA -- OK
			EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(dFecha), 4, '0') || LPAD (MONTH(dFecha), 2, '0') || LPAD (DAY(dFecha), 2, '0')) INTO cCodRetorno;
			LET cFechaPresentacion = LPAD (YEAR(dFecha), 4, '0') || LPAD (MONTH(dFecha), 2, '0') || LPAD (DAY(dFecha), 2, '0');

			-- Se guarda el valor para compararlo con el encabezado del archivo
			LET cFechaPresentacion1 = LPAD (YEAR(dFecha), 4, '0') || LPAD (MONTH(dFecha), 2, '0') || LPAD (DAY(dFecha), 2, '0');
			
		ELIF ((SUBSTR(cNombreArchivo, 13, 2)) /*DIA ARCHIVO*/ < (LPAD(DAY(dFecha),2,'0')) /*DIA PROCESO*/ ) THEN
			--ARCHIVO DEL DIA ANTERIOR 
			LET iContadorDias = 0;
			LET dFechaAux = dFecha; --FORZAR ENTRADA AL CICLO
			
			WHILE (dFechaAux = dFecha)
				LET iContadorDias = iContadorDias + 1;
				
				EXECUTE FUNCTION BdInteg:"informix".SplValFecha ('001',(dFecha - iContadorDias ) + 1 ,0) INTO cCodRetorno2, dFechaAux; --a qui ya tengo el dias siguiente habil
				
			END WHILE;
			
			LET dFechaAux = dFecha - (iContadorDias -1); --DIA HABIL ANTERIOR
			
			
			EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(dFechaAux), 4, '0') || LPAD (MONTH(dFechaAux), 2, '0') || LPAD (DAY(dFechaAux), 2, '0')) INTO cCodRetorno;
			LET cFechaPresentacion = LPAD (YEAR(dFechaAux), 4, '0') || LPAD (MONTH(dFechaAux), 2, '0') || LPAD (DAY(dFechaAux), 2, '0');

			-- Se guarda el valor para compararlo con el encabezado del archivo
			LET cFechaPresentacion1 = LPAD (YEAR(dFechaAux), 4, '0') || LPAD (MONTH(dFechaAux), 2, '0') || LPAD (DAY(dFechaAux), 2, '0');
			
		END IF;
		
		
		IF (cCodRetorno <> '00000') THEN --DIA NO LABORAL
			LET cCodRetorno = '00413';
		ELSE --DIA LABORAL
			LET cCodRetorno = '00000';
		END IF;

		LET cValorParam = TRIM(cCodBanco);

	END IF;

	IF (cCodRetorno = '00000') THEN --TODO LOS PARAMETROS EXISTEN

		LET iContador = 0;
		LET cFlagTipoProceso = 'A';

		LET cFlagArch11 = 'F';
		LET cFlagArch61 = 'F';
		--LET vsFlagArch62 = 'F';--dsb-27/04/2012

		WHILE ((iContador < 2) AND (cFlagTipoProceso = 'A'))  --VERIFICA LA EXISTENCIA DE LOS 2 TIPOS DE ARCHIVO A PROCESAR

			LET cCodRetorno = '00000';
			LET cCodRetorno3 = '00000';

			LET cDescripcionProceso = 'Obtencion de nombre de Archivo';

			LET iContador = iContador + 1;

			LET cNomProceso = '';

			IF (TRIM(cNombreArchivo) = '') THEN --Valida si es una corrida Automatica. --SIN NOMBRE DE ARCHIVO
				--OBTIENE EL NOPMBRE DEL ARCHIVO ESPERADO

				LET cFlagTipoProceso = 'A'; --AUTOMATICO

				IF (iContador = 2) THEN --ARCHIVO 10
					LET iTipoArchivo = 10;
				ELIF (iContador = 1) THEN -- ARCHIVO 60
					LET iTipoArchivo = 60;
				ELSE --NINGUN TIPO DEFINIDO
					LET iTipoArchivo = 0;
				END IF;
				--S01137A2.A602098
				LET csNomArchivo = 'S' --CONSTANTE
								|| '01'--CONSTANTE
								|| TRIM(cCodBanco) --ID BANCARIA BANCOPPEL 137
								|| 'A' --CONSTANTE
								|| '2' --SERVICIO TEF  [2 . TRANSFERENCIA ELECTRÓNICA DE FONDOS]
								|| '.' --CONSTANTE
								|| 'A' --ARCHIVO DE DATOS
								|| iTipoArchivo::CHAR(2)
								|| LPAD(DAY(dFecha), 2, '0') --FECHA DEL ARCHIVO DIA DEL MES --DD--
								|| '98'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO

			ELSE -- Corrida Manual.  -- INDICA EL NOMBRE DEL ARCHIVO.

				LET cFlagTipoProceso = 'M'; --MANUAL

				IF ( SUBSTRING (TRIM(cNombreArchivo) FROM 11 FOR 2) = '10' ) THEN --ARCHIVO 10
					LET iTipoArchivo = 10;
				ELIF ( SUBSTRING (TRIM(cNombreArchivo) FROM 11 FOR 2) = '60' ) THEN --ARCHIVO 60
					LET iTipoArchivo = 60;
				ELSE --ARCHIVO NO VALIDO
					LET iTipoArchivo = 0;
				END IF;

				LET csNomArchivo = TRIM(cNombreArchivo);

			END IF;

			IF (LENGTH (TRIM(csNomArchivo)) >= 16) THEN --VALIDA EL EL NOMBRE DEL ARCHIVO POSEA LA EXTENCION ADECUADA
				LET cNomProceso = 'RECARCH_' || LPAD (iTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(csNomArchivo) FROM 15 FOR 2);
			ELSE -- ERROR DE LONGITUD DE NOMBRE DE ARCHIVO, ARCHIVO NO RECONOCIDO
				LET cNomProceso = 'RECARCH_' || LPAD (iTipoArchivo, 2, '0') || '.' || '00';
			END IF ;

			LET cDescripcionProceso = 'Validacion de nombre de archivo';
			--VALIDA LA INTEGRIDAD DEL NOMBRE DEL ARCHIVO
			EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ValidarNombreArchivos( iTipoArchivo, 'S', csNomArchivo) INTO cCodRetorno;

			IF (cCodRetorno = '00000') THEN --NOMBRE DE ARCHIVO OK

				LET cDescripcionProceso = 'Validacion de procesamientos previos.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = dFecha AND TRIM(Cve_Proceso) = TRIM(cNomProceso) AND Estatus = cFINALIZADO ) THEN  --EL ARCHIVO FUE PROCESADO PREVIAMENTE
					LET cCodRetorno = '00419';

					EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(cCodRetorno) INTO cCodRetorno2, cMensajeRespuesta;

					INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodRetorno, csNomArchivo, 'sp_Tef_Receptor_R', cMensajeRespuesta, cNumEmpleado, CURRENT);

				ELIF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = dFecha AND TRIM(Cve_Proceso) = TRIM(cNomProceso) AND Estatus = cPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
					LET cCodRetorno = '00420';

					EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(cCodRetorno) INTO cCodRetorno2, cMensajeRespuesta;

					INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodRetorno, csNomArchivo, 'sp_Tef_Receptor_R', cMensajeRespuesta, cNumEmpleado, CURRENT);

				ELIF NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = dFecha AND TRIM(Cve_Proceso) = TRIM(cNomProceso) AND Estatus = cERROR ) THEN  --EL ARCHIVOFUE PROCESADO CON ERROR
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET cDescripcionProceso = 'Registro de Reproceso del Archivo.';

					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
					cPROCESANDO, cCodRetorno, cNumEmpleado, 'sp_Tef_Receptor_R', TRIM(csNomArchivo), cFechaPresentacion, '11') INTO cCodRetorno2; --zachiel

					LET cCodRetorno = '00000';
				ELSE  --EL ARCHIVO NO SE HA PROCESADO
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET cDescripcionProceso = 'Registro de Procesamiento del Archivo.';

					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
					cPROCESANDO, cCodRetorno, cNumEmpleado, 'sp_Tef_Receptor_R', TRIM(csNomArchivo) , cFechaPresentacion, '11' ) INTO cCodRetorno2; --zachiel

					LET cCodRetorno = '00000';
				END IF;

				IF (cCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ES APTO PARA SER PROCESADO

					LET cDescripcionProceso = 'Borrado de tablas de paso';
					--LIMPIA LAS TABLAS DE PARA PROCESAR EL NUEVOA ARCHIVO
					EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(TRIM(csNomArchivo), '', 'B', '') INTO cCodRetorno;
                    
					
					--vector
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					SELECT COUNT(Nombre_Arch) INTO iNumArchivos FROM BdiTef:"informix".Tef_CCE_Archivos WHERE Fecha_Presentacion = cFechaPresentacion AND SUBSTRING (Nombre_Arch FROM 1 FOR 14) = SUBSTRING (csNomArchivo FROM 1 FOR 14) AND tot_registros > 0 and cve_status= '02'; -- RUTA ARCHIVO PROCESAR

					IF ((iNumArchivos IS NULL) OR (iNumArchivos = 0)) THEN
						LET iNumArchivos = 1;
					ELSE
						LET iNumArchivos = iNumArchivos + 1;
					END IF;

					IF (cCodRetorno = '00000') THEN
						
						
						
						--MODIFICADO A SOLICITUD DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
						--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
						--2011/09/29
						EXECUTE FUNCTION BdInteg:"informix".SplValFecha ('001',(dFecha) + 1 ,0)INTO cCodRetorno2, dFechaPresentacionResp; --a qui ya tengo el dias siguiente habil
						
						--IF ((SUBSTR(csNomArchivo, 13, 2)) /*DIA ARCHIVO*/ = (LPAD(DAY(dFecha),2,'0')) /*DIA PROCESO*/ ) THEN --VALIDA SI LA FECHA ACTUAL ES IGUAL A LA DEL SISTEMA 
						--	--ARCHIVO DEL DIA -- OK
						--	EXECUTE FUNCTION BdInteg:"informix".SplValFecha ('001',(dFecha) + 1 ,0)INTO cCodRetorno2, dFechaPresentacionResp; --a qui ya tengo el dias siguiente habil
						--ELIF ((SUBSTR(csNomArchivo, 13, 2)) /*DIA ARCHIVO*/ < (LPAD(DAY(dFecha),2,'0')) /*DIA PROCESO*/ ) THEN
						--	--ARCHIVO DEL DIA ANTERIOR 
						--	LET dFechaPresentacionResp = dFecha; --HOY COMO FECHA DE RESPUESTA (DIA HABIL T) AL ARCHIVO DEL DIA ANTERIOR (T-1)
						--END IF;
						
						
						SELECT fecha_prox INTO dFechProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = dFechaPresentacionResp;

						IF (dFechProx IS NULL) OR (dFechProx = "") THEN
							LET dFechaPresentacionResp = dFechaPresentacionResp;
						ELSE
							LET dFechaPresentacionResp = dFechProx;
						END IF;
						--S13721042011.1198
						IF (iTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS
							LET csNomArchivo11 = 'E'
											|| TRIM(cCodBanco) --ID BANCARIA BANCOPPEL 137
											|| LPAD(DAY(dFechaPresentacionResp),2,'0') --dd
											|| LPAD(MONTH(dFechaPresentacionResp),2,'0')  --mm
											|| YEAR(dFechaPresentacionResp)  --aaaa
											|| '.11' --oo
											|| LPAD (iNumArchivos, 2, '0'); --cc

							LET csNomArchivo61 = '';
							--LET csNomArchivo62 = ''; --dsb-27/04/2012

							EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(TRIM(csNomArchivo11), '', 'B', '') INTO cCodRetorno;

						ELIF (iTipoArchivo = 60) THEN --ARCHIVO 60 -- APLICAR CARGOS
							LET csNomArchivo11 = '';

							--dFechaPresentacionResp  CONTIENE T+1

							LET csNomArchivo61 = 'E'
											|| TRIM(cCodBanco) --ID BANCARIA BANCOPPEL 137
											|| LPAD(DAY(dFechaPresentacionResp),2,'0') --dd
											|| LPAD(MONTH(dFechaPresentacionResp),2,'0') --mm
											|| YEAR(dFechaPresentacionResp) --aaaa
											|| '.61' --oo
											|| LPAD (iNumArchivos, 2, '0'); --cc

							/*LET csNomArchivo62 = 'E' --dsb-27/04/2012
											|| TRIM(cCodBanco) --ID BANCARIA BANCOPPEL 137
											|| LPAD(DAY(dFechaPresentacionResp),2,'0') --dd
											|| LPAD(MONTH(dFechaPresentacionResp),2,'0') --mm
											|| YEAR(dFechaPresentacionResp)  --aaaa
											|| '.62'--oo
											|| LPAD (iNumArchivos, 2, '0'); --cc*/

							EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(TRIM(csNomArchivo61), '', 'B', '') INTO cCodRetorno;

							/*IF (cCodRetorno = '00000') THEN --dsb-27/04/2012
								EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist(TRIM(csNomArchivo62), '', 'B', '') INTO cCodRetorno;
							END IF;*/
						END IF;

					END IF;

					IF (cCodRetorno = '00000') THEN -- VALIDA KE LAS TABLAS SE LIMPIARON CORRECTAMENTE

						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						SELECT LIMIT 1 Valor INTO cRuta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71'; -- RUTA ARCHIVO PROCESAR

						LET cDescripcionProceso = 'Verifica que exista en archivo en la ruta';
						--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_BuscarArchivo( TRIM(cRuta), TRIM(csNomArchivo)) INTO cCodRetorno, cFlagUnico;

						IF ((cCodRetorno = '00000') AND (cFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO

							LET cDescripcionProceso = 'Carga del archivo a las tablas de paso';
							--CARGA EL ARCHIVO A LAS TABLAS
							EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_SubirArchivos(cFlagTipoProceso, '71'/*RUTA ARCHIVO PROCESAR*/, TRIM(csNomArchivo), cNumEmpleado) INTO cCodRetorno, cCodRetSub;

							IF (cCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO SE CARGO CORRECTAMENTE A LAS TABLAS

								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(csNomArchivo) ;
								
								--MODIFICADO A SOLICITUD DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
								--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
								--IF (cFechaPresentacion = cFechaPresentacion1) THEN
								-- SE VALIDA QUE LA FECHA DEL ENCABEZADO SEA LA DEL DÍA DE HOY
								--IF ((cFechaPresentacion = cFechaPresentacion1) OR (cFechaPresentacion = cFechaPresentacion1_AUX)) THEN -- NO APLICA PARA FINES DE SEMANA
								IF (cFechaPresentacion = cFechaPresentacion) THEN  -- SIEMPRE OK -- TEMPORAL

									UPDATE BdiTef:"informix". Tef_CCE_Archivos SET fecha_presentacion = cFechaPresentacion WHERE Nombre_Arch = TRIM(csNomArchivo) AND fecha_presentacion = "";

									LET cDescripcionProceso = 'Validacion de Integridad del Archivo.';
									--INTEGRIDAD DEL ARCHIVO
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Valida_Datos( TRIM(csNomArchivo), cFechaPresentacion, 'S' /*SALIDA CECOBAN*/, iTipoArchivo, 'R' /*RECEPTOR*/, TRIM(cNomProceso)) INTO cCodRetorno, cBloque;

									IF (cCodRetorno = '00000') THEN --VALIDA LA INTEGRIDAD DEL ARCHIVO

										SELECT LIMIT 1 fecha_aplica INTO cFechaAplica
										FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE Nombre_Arch = TRIM(csNomArchivo)  AND fecha_presentacion = cFechaPresentacion;
										LET dFechaAplicaDe = SUBSTR(cFechaAplica,5,2) || "/" || SUBSTR(cFechaAplica,7,2) || "/" || SUBSTR(cFechaAplica,1,4);
										UPDATE BdiTef:"informix". Tef_CCE_Archivos SET fecha_aplicacion = dFechaAplicaDe
										WHERE Nombre_Arch = TRIM(csNomArchivo)  AND fecha_presentacion = cFechaPresentacion;

										LET cDescripcionProceso = 'Procesamiento del Archivo Original.';
										IF (iTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS

											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ProcesarArchivo10 (TRIM(csNomArchivo), TRIM(csNomArchivo11)) INTO cCodRetorno;

										ELIF (iTipoArchivo = 60) THEN --ARCHIVO 60 -- APLICAR CARGOS

											--EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ProcesarArchivo60 (TRIM(csNomArchivo), TRIM(csNomArchivo61), TRIM(csNomArchivo62), cNumEmpleado) INTO cCodRetorno;
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_ProcesarArchivo60 (TRIM(csNomArchivo), TRIM(csNomArchivo61), cNumEmpleado) INTO cCodRetorno;
											--reemplazar por nuevo sp
										END IF;

										IF (cCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE PROCESO CORRECTAMENTE

											LET cDescripcionProceso = 'Generacion de Archivos de Respuesta.';
											--GENERAR DESCARGA DE ARCHIVOS
											IF (iTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS

												SET LOCK MODE TO WAIT 3;
												SET ISOLATION TO DIRTY READ;
												IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE nombre_arch = TRIM(csNomArchivo11))THEN
													IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = TRIM(csNomArchivo11))THEN
														IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = TRIM(csNomArchivo11))THEN
															LET cFlagArch11 = 'V';
															SET LOCK MODE TO WAIT 3;
															SET ISOLATION TO DIRTY READ;
															SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion2 FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(csNomArchivo11) ;
															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GeneraArchivo (11, TRIM (csNomArchivo11), cFechaPresentacion2, '72'/*RUTA ARCHIVO RESPUESTA*/ ) INTO cCodRetorno;
														END IF;
													END IF;
												END IF;
											ELIF (iTipoArchivo = 60) THEN --ARCHIVO 60 -- CARGOS ACUENTAS

												IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE nombre_arch = TRIM(csNomArchivo61))THEN
													IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = TRIM(csNomArchivo61))THEN
														IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = TRIM(csNomArchivo61))THEN
															LET cFlagArch61 = 'V';
															SET LOCK MODE TO WAIT 3;
															SET ISOLATION TO DIRTY READ;
															SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion2 FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(csNomArchivo61) ;
															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GeneraArchivo (61, TRIM (csNomArchivo61), cFechaPresentacion2, '72'/*RUTA ARCHIVO RESPUESTA*/ ) INTO cCodRetorno;
														END IF;
													END IF;
												END IF;

												IF (cCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO 61 SE GENERO CORRECTAMENTE

													/*IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE nombre_arch = TRIM(csNomArchivo62))THEN --dsb-27/04/2012
														IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = TRIM(csNomArchivo62))THEN
															IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = TRIM(csNomArchivo62))THEN
																LET vsFlagArch62 = 'V';
																SET LOCK MODE TO WAIT 3;
																SET ISOLATION TO DIRTY READ;
																SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion2 FROM BdiTef:"informix".Tef_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(csNomArchivo62) ;
																EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GeneraArchivo (62, TRIM (csNomArchivo62), cFechaPresentacion2, '72'RUTA ARCHIVO RESPUESTA ) INTO cCodRetorno;
															END IF;
														END IF;
													END IF;*/
												ELSE --ERROR AL GENERAR ARCHIVO 61
													--GUARDAR BITACORA
													EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
														cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_GeneraArchivo', TRIM(csNomArchivo) , cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
													LET cCodRetorno3 = cCodRetorno;
													LET cCodRetorno = '00424';
												END IF;

											END IF;

											IF (cCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE GENERO CORRECTAMENTE

												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo), cFechaPresentacion, '01') INTO cCodRetorno;

												LET cDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
												--ARCHIVO ORIGINAL
												--EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (csNomArchivo), cFechaPresentacion, 'T', '01') INTO cCodRetorno;
												EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (csNomArchivo), cFechaPresentacion, 'T', '') INTO cCodRetorno;

												IF (cCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

													IF (iTipoArchivo = 10) THEN --ARCHIVO 10

														IF (cFlagArch11 = 'V') THEN
															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo11), cFechaPresentacion2, '01') INTO cCodRetorno;
															IF (cCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
																EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (csNomArchivo11), cFechaPresentacion2, 'T', '01') INTO cCodRetorno;
															ELSE--ERROR
															END IF;
														END IF;

													ELIF (iTipoArchivo = 60) THEN --ARCHIVO 60

														IF (cFlagArch61 = 'V') THEN
															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo61), cFechaPresentacion2, '01') INTO cCodRetorno;
														END IF;

														IF (cCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO

															IF (cFlagArch61 = 'V') THEN
																EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (csNomArchivo61), cFechaPresentacion2, 'T', '') INTO cCodRetorno;
															END IF;

															IF (cCodRetorno = '00000') THEN --VALIDA KE LOS DATOS DEL ARCHIVO 61 SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

																/*IF (vsFlagArch62 = 'V') THEN --dsb-27/04/2012
																	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo62), cFechaPresentacion2, '01') INTO cCodRetorno;

																	IF (cCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
																		EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (csNomArchivo62), cFechaPresentacion2, 'T', '') INTO cCodRetorno;
																	ELSE --ERROR

																	END IF;
																END IF;*/

															ELSE -- ERROR AL MOVER LOS REGISTROS DEL ARCHIVO 61 AL HITORICO
																--GUARDAR BITACORA
																EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
																cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(csNomArchivo) , cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
																LET cCodRetorno3 = cCodRetorno;
																LET cCodRetorno = '00427';
															END IF;
														ELSE --ERROR

														END IF;
													END IF;

													IF (cCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO DE RESPUESTA SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

														LET cDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
														EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '73' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO cCodRetorno;

														IF (cCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ORIGINAL SE PASO CORRECTAMENTE AL REPOSITORIO HISTORICO
															--GUARDA BITACORA EXITO
															LET cDescripcionProceso = 'TEF Finalizado Exitosamente.';
															LET cCodRetorno = '00000';
															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
															cFINALIZADO, cCodRetorno, cNumEmpleado, 'sp_Tef_Receptor_R', TRIM(csNomArchivo) , cFechaPresentacion, '02'/*EXITO*/ ) INTO cCodRetorno2;

															--zachiel
															--EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo), cFechaPresentacion, '02'/*EXITO*/) INTO cCodRetorno2;

															--ACTUALIZA LOS ESTATUS DEL CCE_ACHIVO PARA KE LOS AMRQUE COMO TERMINADO
															IF (iTipoArchivo = 10) THEN

																IF (cFlagArch11 = 'V') THEN
																	SET LOCK MODE TO WAIT 3;
																	SET ISOLATION TO DIRTY READ;
																	SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion2 FROM BdiTef:"informix".Tef_Cce_Encabezado WHERE Nombre_Arch = TRIM(csNomArchivo11) ;
																	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo11), cFechaPresentacion2, '02'/*EXITO*/) INTO cCodRetorno2;
																END IF;
															ELIF (iTipoArchivo = 60) THEN --

																IF (cFlagArch61 = 'V') THEN
																	SET LOCK MODE TO WAIT 3;
																	SET ISOLATION TO DIRTY READ;
																	SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion2 FROM BdiTef:"informix".Tef_Cce_Encabezado WHERE Nombre_Arch = TRIM(csNomArchivo61) ;
																	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo61), cFechaPresentacion2, '02'/*EXITO*/) INTO cCodRetorno2;
																END IF;

																/*IF (vsFlagArch62 = 'V') THEN --dsb-27/04/2012
																	SET LOCK MODE TO WAIT 3;
																	SET ISOLATION TO DIRTY READ;
																	SELECT LIMIT 1 Fecha_Presentacion INTO cFechaPresentacion2 FROM BdiTef:"informix".Tef_Cce_Encabezado WHERE Nombre_Arch = TRIM(csNomArchivo62) ;
																	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (cNumEmpleado, TRIM (csNomArchivo62), cFechaPresentacion2, '02' --EXITO) INTO cCodRetorno; 
																END IF;*/

															END IF;

														ELSE --ERROR DE PASO DE ARCHIVO ORIGINAL AL REPOSITORIO DE HISTORICO
															--GUARDAR BITACORA
															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
															cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_MoverArchivos', TRIM(csNomArchivo) , cFechaPresentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
															LET cCodRetorno3 = cCodRetorno;
															LET cCodRetorno = '00430';
														END IF;

													ELSE --  ERROR AL MOVER LOS REGISTROS DEL ARCHIVO AL HISTORICO
														IF (iTipoArchivo = 10) THEN -- ERROR DE ARCHIVO 11
															--GUARDAR BITACORA

															EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
															cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(csNomArchivo) , cFechaPresentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
															LET cCodRetorno3 = cCodRetorno;
															LET cCodRetorno = '00428';
														ELSE -- ERROR DE ARCHIVO 62
															--GUARDAR BITACORA

															/*EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso, --dsb-27/04/2012
															cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(csNomArchivo) , cFechaPresentacion, '01'--NO GUARDAR CCE_ARCHIVO ) INTO cCodRetorno2;
															LET cCodRetorno3 = cCodRetorno;
															LET cCodRetorno = '00429';*/
														END IF;
													END IF;

												ELSE --ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HITORICO
													--GUARDAR BITACORA
													EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno2;

													EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
													cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(csNomArchivo) , cFechaPresentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
													LET cCodRetorno3 = cCodRetorno;
													LET cCodRetorno = '00426';
												END IF;

											ELSE --ERROR AL GENERAR EL ARCHIVO DE RESPUESTA
												--GUARDAR BITACORA
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno2;

												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
												cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_GeneraArchivo', TRIM(csNomArchivo) , cFechaPresentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
												LET cCodRetorno3 = cCodRetorno;
												LET cCodRetorno = '00425';
											END IF;

										ELSE --ERROR AL PROCESAR EL ARCHIVO
											--GUARDAR BITACORA
											IF (iTipoArchivo = 10) THEN
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
												cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_ProcesarArchivo10', TRIM(csNomArchivo) , cFechaPresentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
											ELIF (iTipoArchivo = 60) THEN
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(csNomArchivo), cDescripcionProceso,
												cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_ProcesarArchivo60', TRIM(csNomArchivo) , cFechaPresentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
											END IF;
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno;

											IF (cCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
												cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(csNomArchivo) , cFechaPresentacion, '03'/*RECHAZADO*/ ) INTO cCodRetorno2;
											END IF;
											LET cCodRetorno3 = cCodRetorno;
											LET cCodRetorno = '00423';
										END IF;

									ELSE --ERROR DE INTEGRIDAD EN EL ARCHIVO
										--GUARDAR BITACORA
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
										cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_Valida_Datos', TRIM(csNomArchivo) , cFechaPresentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;

										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno;

										IF (cCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
											cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(csNomArchivo) , cFechaPresentacion, '03'/*RECHAZADO*/ ) INTO cCodRetorno2;
										END IF;

										-- SE ELIMINAN LOS REGISTROS (PETICIÓN DE E. GARNICA) 16-Ene-2026
										DELETE FROM bditef:tef_cce_sumario_paso WHERE nombre_arch=csNomArchivo AND Fecha_Presentacion=cFechaPresentacion ;
										DELETE FROM bditef:tef_cce_detalle_paso WHERE nombre_arch=csNomArchivo AND Fecha_Presentacion=cFechaPresentacion ;
										DELETE FROM bditef:tef_cce_encabezado_paso WHERE nombre_arch=csNomArchivo AND Fecha_Presentacion=cFechaPresentacion ;										
										DELETE FROM bditef:tef_cce_archivos WHERE nombre_arch=csNomArchivo AND Fecha_Presentacion=cFechaPresentacion ;
										
										LET cCodRetorno3 = cCodRetorno;
										LET cCodRetorno = '00422';
									END IF;

								ELSE -- LA FECHA DEL ENCABEZADO ES DIFERENTE AL DIA DE HOY
									--GUARDAR BITACORA
									-- LET cCodRetorno = '00603';
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno2;
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
									cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_SubirArchivos', TRIM(csNomArchivo), cFechaPresentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/  ) INTO cCodRetorno2;
									LET cCodRetorno3 = cCodRetorno;
									LET cCodRetorno = '00434';
								END IF;

							ELSE -- ERROR AL CARGAR EL ARCHIVO A LAS TABLAS DE PASO
								--GUARDAR BITACORA
								--LET cFechaPresentacion = LPAD (YEAR(CURRENT::DATE), 4, '0') || LPAD (MONTH(CURRENT::DATE), 2, '0') || LPAD (DAY(CURRENT::DATE), 2, '0');
								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno2;

								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
								cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_SubirArchivos', TRIM(csNomArchivo), cFechaPresentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/  ) INTO cCodRetorno2;
								LET cCodRetorno = '00421';
							END IF;
						ELSE --NO EXISTE EL ARCHIVO
							EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
							cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_BuscarArchivo', TRIM(csNomArchivo) , cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
							LET cCodRetorno3 = cCodRetorno;
							LET cCodRetorno = '00435';
							-----
						END IF;

					ELSE -- ERROR AL LIMPIAR LAS TABLAS
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
						cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_SubirArchivos', TRIM(csNomArchivo) , cFechaPresentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO cCodRetorno2;
						LET cCodRetorno3 = cCodRetorno;
						LET cCodRetorno = '00430';
					END IF;

				ELSE -- ERROR EL ARCHIVO NO ES APTO PARA SER PROCESADO
					--GUARDAR BITACORA
					--EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
					--cERROR, cCodRetorno, cNumEmpleado, 'sp_Tef_SubirArchivos', TRIM(csNomArchivo) , cFechaPresentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) ;
					--LET cCodRetorno = '00430';
				END IF;
			ELSE -- NOMBRE DE ARCHIVO ERRONEO
				--GRABAR EN LA BITACORA  cCodRetorno
				EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
				cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(csNomArchivo), cFechaPresentacion, '03'/*RECHAZADO*/ ) INTO cCodRetorno2;

				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT LIMIT 1 Valor INTO cRuta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71'; -- RUTA ARCHIVO PROCESAR

				--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
				EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_BuscarArchivo( TRIM(cRuta), TRIM(csNomArchivo)) INTO cCodRetorno, cFlagUnico;

				IF ((cCodRetorno = '00000') AND (cFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO

					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_MoverArchivos (TRIM (csNomArchivo), '71' /*RUTA  ARCHIVO PROCESAR*/, '74' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO cCodRetorno;

					IF (cCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
						EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(cFlagTipoProceso, CURRENT::DATE, TRIM(cNomProceso), cDescripcionProceso,
						cERROR, cCodRetorno, cNumEmpleado, 'Sp_Tef_ValidarNombreArchivos', TRIM(csNomArchivo), cFechaPresentacion, '03'/*RECHAZADO*/ ) INTO cCodRetorno2;
					END IF;
				END IF;
				LET cCodRetorno3 = cCodRetorno;
				LET cCodRetorno = '00418';
			END IF;

			EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(cCodRetorno) INTO cCodRetorno2, cMensajeRespuesta;
			RETURN csNomArchivo, cCodRetorno, cMensajeRespuesta WITH RESUME;

			IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = dFecha AND TRIM(Cve_Proceso) = TRIM(cNomProceso) AND Estatus = cPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
				IF (cCodRetorno <> '00420') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'PROCESANDO'
					UPDATE BdiTef:"informix".Tef_Procesos SET Estatus = cERROR WHERE Fecha_Proceso = dFecha AND TRIM(Cve_Proceso) = TRIM(cNomProceso) AND Estatus = cPROCESANDO ;
				END IF;
			END IF;

		END WHILE;

	ELSE -- PARAMETRO NO ENCONTRADO
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(cCodRetorno) INTO cCodRetorno2, cMensajeRespuesta;
		RETURN 'GENERAL', cCodRetorno, cMensajeRespuesta;
		--LET cCodRetorno = '00461'
	END IF;

END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SP PRINCIPAL DE TEF -- RECEPTOR RECEPTOR  ARCH. 10 Y 60.',
'Fecha: 2011/03/16',
'Version: 20110616.1220',
'BD: BdiTef',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: MODIFICADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN.',
'Fecha: 2011/09/29',
'Version: 20110929.1555',
'BD: BdiTef',
'Modificado: Victor Hugo Nuñez',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se quita todo lo referente al archivo 62 para el procesado en la fecha de aplicacion.',
'Fecha: 27-04-2012',
'Version: 20120427.0907',
'BD: BdiTef';


grant  execute on function "informix".cal_fecha_pre_fh (char) to "ifxprod" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh (char) to "public" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh (char) to "systelmex" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh (char) to "syssifn_app" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh (char) to "c90306542" as "informix";
grant  execute on function "informix".cal_habil_ant (date) to "all_role_bditef" as "informix";
grant  execute on function "informix".cal_habil_ant (date) to "ifxprod" as "informix";
grant  execute on function "informix".cal_habil_ant (date) to "syssifn_app" as "informix";
grant  execute on function "informix".cal_habil_ant (date) to "public" as "informix";
grant  execute on function "informix".cal_habil_ant (date) to "select_role_bditef" as "informix";
grant  execute on function "informix".cal_habil_ant (date) to "c90306542" as "informix";
grant  execute on function "informix".cons_dev_suc (char,char,date,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".cons_dev_suc (char,char,date,smallint) to "public" as "informix";
grant  execute on function "informix".cons_dev_suc (char,char,date,smallint) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_dev_suc (char,char,date,smallint) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_dev_suc (char,char,date,smallint) to "c90306542" as "informix";
grant  execute on function "informix".consnomcte (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".consnomcte (char,char) to "public" as "informix";
grant  execute on function "informix".consnomcte (char,char) to "c90306542" as "informix";
grant  execute on function "informix".consnomcte (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".consnomcte (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_tels (char) to "ifxprod" as "informix";
grant  execute on function "informix".cons_tels (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_tels (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_tels (char) to "c90306542" as "informix";
grant  execute on function "informix".cons_tels (char) to "public" as "informix";
grant  execute on function "informix".cons_dev_coppel (char,char,char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_dev_coppel (char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_dev_coppel (char,char,char,char,char,char,char) to "syssifn" as "informix";
grant  execute on function "informix".cons_dev_coppel (char,char,char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_dev_coppel (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".cons_dev_coppel (char,char,char,char,char,char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtenerbancosregistrados () to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerbancosregistrados () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerbancosregistrados () to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerbancosregistrados () to "public" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce (char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cal_fecharet (date) to "ifxprod" as "informix";
grant  execute on function "informix".cal_fecharet (date) to "c90306542" as "informix";
grant  execute on function "informix".cal_fecharet (date) to "select_role_bditef" as "informix";
grant  execute on function "informix".cal_fecharet (date) to "all_role_bditef" as "informix";
grant  execute on function "informix".cal_fecharet (date) to "public" as "informix";
grant  execute on function "informix".abono_cta (char,char,integer,decimal,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".abono_cta (char,char,integer,decimal,char,char) to "public" as "informix";
grant  execute on function "informix".abono_cta (char,char,integer,decimal,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".abono_cta (char,char,integer,decimal,char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".abono_cta (char,char,integer,decimal,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_nom_cte (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_nom_cte (char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_nom_cte (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".cons_nom_cte (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_nom_cte (char,char) to "public" as "informix";
grant  execute on function "informix".ins_propios_det (char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".ins_propios_det (char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".ins_propios_det (char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".ins_propios_det (char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".ins_propios_det (char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".procesa_cargos (char,char,date,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".procesa_cargos (char,char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".procesa_cargos (char,char,date,char) to "ifxprod" as "informix";
grant  execute on function "informix".procesa_cargos (char,char,date,char) to "syssifn_app" as "informix";
grant  execute on function "informix".procesa_cargos (char,char,date,char) to "public" as "informix";
grant  execute on function "informix".procesa_cargos (char,char,date,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_consultaconsecutivoarchivo (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconsecutivoarchivo (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_consultaconsecutivoarchivo (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultaconsecutivoarchivo (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consultaconsecutivoarchivo (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consarchivos_tef (char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consarchivos_tef (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consarchivos_tef (char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consarchivos_tef (char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_consarchivos_tef (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consdevext_tef (char,char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consdevext_tef (char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consdevext_tef (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consdevext_tef (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdevext_tef (char,char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_generarepopertef (char,date,integer) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_generarepopertef (char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_generarepopertef (char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_generarepopertef (char,date,integer) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_generarepopertef (char,date,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerinformaciontef (char,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerinformaciontef (char,char,date,integer) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerinformaciontef (char,char,date,integer) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerinformaciontef (char,char,date,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerinformaciontef (char,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtenernomarch_tef (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenernomarch_tef (integer) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenernomarch_tef (integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenernomarch_tef (integer) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenernomarch_tef (integer) to "public" as "informix";
grant  execute on function "informix".sp_obtienebancostef (integer) to "public" as "informix";
grant  execute on function "informix".sp_obtienebancostef (integer) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienebancostef (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienebancostef (integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtienebancostef (integer) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienecveratreo (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienecveratreo (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtienecveratreo (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienecveratreo (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienecveratreo (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienecveratreo (char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtieneparamtef (char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtieneparamtef (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtieneparamtef (char) to "public" as "informix";
grant  execute on function "informix".sp_obtieneparamtef (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtieneparamtef (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtieneparamtef (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienetipoctastef (char,char,smallint) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienetipoctastef (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienetipoctastef (char,char,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtienetipoctastef (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_obtienetipoctastef (char,char,smallint) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienetipoopertef (integer) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienetipoopertef (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienetipoopertef (integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtienetipoopertef (integer) to "public" as "informix";
grant  execute on function "informix".sp_obtienetipoopertef (integer) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_revoperacionestef (char,date,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_revoperacionestef (char,date,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_revoperacionestef (char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_revoperacionestef (char,date,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_revoperacionestef (char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_actualizar_cte_detalle (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_actualizar_cte_detalle (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_actualizar_cte_detalle (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_actualizar_cte_detalle (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_actualizar_cte_detalle (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_generararchivo63 (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_generararchivo63 (char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_generararchivo63 (char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_generararchivo63 (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_generararchivo63 (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_guardarccearchivos (char,varchar,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_guardarccearchivos (char,varchar,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_guardarccearchivos (char,varchar,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_guardarccearchivos (char,varchar,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_guardarccearchivos (char,varchar,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_moverarchivos (char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_moverarchivos (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_moverarchivos (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_moverarchivos (char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_moverarchivos (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_moverregistroshist (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_moverregistroshist (char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_moverregistroshist (char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_moverregistroshist (char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_moverregistroshist (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_presentador_g (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_presentador_g (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_presentador_g (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_presentador_g (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_presentador_g (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_presentador_r (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_presentador_r (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_presentador_r (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_presentador_r (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_presentador_r (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo10 (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo10 (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo10 (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo10 (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo10 (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_validarnombrearchivos (smallint,char,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_validarnombrearchivos (smallint,char,varchar) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validarnombrearchivos (smallint,char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_tef_validarnombrearchivos (smallint,char,varchar) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validarnombrearchivos (smallint,char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_valida_cadena (lvarchar,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_valida_fecha (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validadiahabiltef (char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_validadiahabiltef (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validadiahabiltef (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validadiahabiltef (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_validadiahabiltef (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validadiahabiltef (char) to "public" as "informix";
grant  execute on function "informix".sp_validahorariotef () to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_validahorariotef () to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validahorariotef () to "public" as "informix";
grant  execute on function "informix".sp_validahorariotef () to "ifxprod" as "informix";
grant  execute on function "informix".sp_validahorariotef () to "c90306542" as "informix";
grant  execute on function "informix".sp_validaproductopermitido (char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaproductopermitido (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_validaproductopermitido (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validaproductopermitido (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaproductopermitido (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_validaproductopermitido (char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_consultarepop_tef (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultarepop_tef (char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_consultarepop_tef (char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consultarepop_tef (char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consultarepop_tef (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_consnombrenumcte (char,char,char,char,char,date,char,char,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_consnombrenumcte (char,char,char,char,char,date,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_tef_consnombrenumcte (char,char,char,char,char,date,char,char,smallint) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_consnombrenumcte (char,char,char,char,char,date,char,char,smallint) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_consnombrenumcte (char,char,char,char,char,date,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizaestatusimagencheque (char,char,char,char,date,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_actualizaestatusimagencheque (char,char,char,char,date,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_actualizaestatusimagencheque (char,char,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_actualizaestatusimagencheque (char,char,char,char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabaimageneschqdevueltos (char,char,char,char,date,char,char,smallint,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabaimageneschqdevueltos (char,char,char,char,date,char,char,smallint,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_grabaimageneschqdevueltos (char,char,char,char,date,char,char,smallint,char) to "public" as "informix";
grant  execute on function "informix".sp_grabaimageneschqdevueltos (char,char,char,char,date,char,char,smallint,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consultarimageneschqdevueltos (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_consultarimageneschqdevueltos (char) to "public" as "informix";
grant  execute on function "informix".sp_consultarimageneschqdevueltos (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultarimageneschqdevueltos (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consultarimageneschqdevueltos (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_consultageneralcheques (char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultageneralcheques (char,char,char,date) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_consultageneralcheques (char,char,char,date) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_consultageneralcheques (char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_tef_generararchivo60 (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_generararchivo60 (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_generararchivo60 (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_generararchivo60 (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_generararchivo60 (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagencheque (char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagencheque (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaimagencheque (char,char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_validaimagencheque (char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagencheque (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaimagencheque_dev (char,char,char,char,date) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagencheque_dev (char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaimagencheque_dev (char,char,char,char,date) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagencheque_dev (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_obtbines_sif (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtbines_sif (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtbines_sif (char) to "public" as "informix";
grant  execute on function "informix".sp_obtbines_sif (char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtbines_sif (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_buscaoperacion (date,char,char,varchar) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_buscaoperacion (date,char,char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_tef_buscaoperacion (date,char,char,varchar) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_buscaoperacion (date,char,char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_grabaoperacion (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_grabaoperacion (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_grabaoperacion (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_grabaoperacion (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_grabaoperacion (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_obtcodbanco (integer,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_obtcodbanco (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_obtcodbanco (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_obtcodbanco (integer,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_obtcodbanco (integer,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_obtinforpt (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_obtinforpt (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_obtinforpt (char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_obtinforpt (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_obtinforpt (char) to "public" as "informix";
grant  execute on function "informix".sp_tef_obttipocta () to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_obttipocta () to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_obttipocta () to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_obttipocta () to "public" as "informix";
grant  execute on function "informix".sp_tef_obttipocta () to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_reversoperacion (date,char,char,varchar) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_reversoperacion (date,char,char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_reversoperacion (date,char,char,varchar) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_reversoperacion (date,char,char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_tef_validahorario (datetime) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validahorario (datetime) to "public" as "informix";
grant  execute on function "informix".sp_tef_validahorario (datetime) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_validahorario (datetime) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validahorario (datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_validarchcod60 (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validarchcod60 (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_validarchcod60 (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_validarchcod60 (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validarchcod60 (char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_validarecepcion (integer,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validarecepcion (integer,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_validarecepcion (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_validarecepcion (integer,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_tef_validarecepcion (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".stat_cheque (char,char,integer) to "all_role_bditef" as "informix";
grant  execute on function "informix".stat_cheque (char,char,integer) to "public" as "informix";
grant  execute on function "informix".stat_cheque (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".stat_cheque (char,char,integer) to "select_role_bditef" as "informix";
grant  execute on function "informix".stat_cheque (char,char,integer) to "syssifn_app" as "informix";
grant  execute on function "informix".stat_cheque (char,char,integer) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce_pba (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce_pba (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce_pba (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerparametroscce_pba (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienebancos_pba (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienebancos_pba (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienebancos_pba (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtienebancos_pba (char) to "public" as "informix";
grant  execute on function "informix".ins_reg_devo (char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".ins_reg_devo (char,char,char,char,char,char,date) to "ifxprod" as "informix";
grant  execute on function "informix".ins_reg_devo (char,char,char,char,char,char,date) to "all_role_bditef" as "informix";
grant  execute on function "informix".ins_reg_devo (char,char,char,char,char,char,date) to "select_role_bditef" as "informix";
grant  execute on function "informix".ins_reg_devo (char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_devcoppel (char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_devcoppel (char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_devcoppel (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_devcoppel (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_guardar_detalle (char,char,char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_detalle (char,char,char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_guardar_detalle (char,char,char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_guardar_detalle (char,char,char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_encabezado (char,char,char,char,char,char,char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_cce_guardar_encabezado (char,char,char,char,char,char,char,char,char,char,char,char,date) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_encabezado (char,char,char,char,char,char,char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_guardar_encabezado (char,char,char,char,char,char,char,char,char,char,char,char,date) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_gransumario (char,char,char,char,char,char,char,char,char,decimal,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_gransumario (char,char,char,char,char,char,char,char,char,decimal,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_guardar_gransumario (char,char,char,char,char,char,char,char,char,decimal,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_gransumario (char,char,char,char,char,char,char,char,char,decimal,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_guardar_sumario (char,char,char,char,char,decimal,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_guardar_sumario (char,char,char,char,char,decimal,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_sumario (char,char,char,char,char,decimal,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_guardar_sumario (char,char,char,char,char,decimal,char) to "public" as "informix";
grant  execute on function "informix".cons_dir_cte (char,smallint) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_dir_cte (char,smallint) to "public" as "informix";
grant  execute on function "informix".cons_dir_cte (char,smallint) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_dir_cte (char,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".cons_dir_cte (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_dir_cte (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_dir_cte (char,char) to "public" as "informix";
grant  execute on function "informix".cons_presenta (char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".cons_presenta (char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_presenta (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_presenta (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_presenta (char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaimagenescheques_pba (char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagenescheques_pba (char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagenescheques_pba (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaimagenescheques_pba (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_dev_coppel_pba (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".cons_dev_coppel_pba (char,char,char,char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_dev_coppel_pba (char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_dev_coppel_pba (char,char,char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_presenta_pba (char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_presenta_pba (char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".cons_presenta_pba (char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".cons_presenta_pba (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques_pba (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques_pba (char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques_pba (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques_pba (char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques (char,char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques (char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_detallecheques (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtenermensajeerror (char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtenermensajeerror (char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenermensajeerror (char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_obtenermensajeerror (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenermensajeerror (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_imagencheque (char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_imagencheque (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_valida_imagencheque (char,char,char,char,date) to "select_role_bditef" as "informix";
grant  execute on function "informix".obtenerimagennula (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".obtenerimagennula (char,char,char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".obtenerimagennula (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".ins_reg_devo_pba (char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".ins_reg_devo_pba (char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_tef_grab_arch_cam (char,integer,decimal,integer,char,smallint,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_grab_arch_cam (char,integer,decimal,integer,char,smallint,integer) to "public" as "informix";
grant  execute on function "informix".sp_cce_controlusuariosaut (integer,integer,varchar,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_controlusuariosaut (integer,integer,varchar,date) to "public" as "informix";
grant  execute on function "informix".sp_firma_ejec (char,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_firma_ejec (char,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_insert_cedula (varchar,varchar,varchar,varchar,money) to "public" as "informix";
grant  execute on function "informix".sp_insert_cedula (varchar,varchar,varchar,varchar,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_act_rep_sicam (char,money,money,money,money,money,money,money,money,money,money,money,money,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_act_rep_sicam (char,money,money,money,money,money,money,money,money,money,money,money,money,smallint) to "public" as "informix";
grant  execute on function "informix".sp_tef_obt_arch_cam_recibyprest40y41 (integer,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_obt_arch_cam_recibyprest40y41 (integer,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_tef_rep_lib_sif () to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_rep_lib_sif () to "public" as "informix";
grant  execute on function "informix".sp_tef_domi_genrep30y60 (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_tef_domi_genrep30y60 (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscaarchivo_tef (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscaarchivo_tef (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_eliminaarchivo_tef (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_eliminaarchivo_tef (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_buscararchivo (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_buscararchivo (varchar,varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_buscararchivo (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_tef_bitacora (char,date,varchar,char,char,char,char,varchar,varchar,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_bitacora (char,date,varchar,char,char,char,char,varchar,varchar,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_bitacora (char,date,varchar,char,char,char,char,varchar,varchar,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscararchivos_tef (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscararchivos_tef (varchar) to "public" as "informix";
grant  execute on function "informix".sp_buscararchivos_tef (varchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_generaarchivo (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_generaarchivo (integer,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_generaarchivo (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_cedulausrmtto (integer,integer,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_cedulausrmtto (integer,integer,char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_graba_cam_arch41 (char,integer,decimal,integer,char,smallint,integer) to "public" as "informix";
grant  execute on function "informix".sp_tef_graba_cam_arch41 (char,integer,decimal,integer,char,smallint,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_obt_arch_cam_recib41 (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_obt_arch_cam_recib41 (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_grabaoperaciontef (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabaoperaciontef (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_grabaoperaciontef (char,char,date,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportearchivos_tef (char,char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_reportearchivos_tef (char,char,char,char,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportearchivos_tef (char,char,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_generararchivo62 (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_generararchivo62 (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerchequescce_pba3 (char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerchequescce_pba3 (char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_obtenerchequescce_pbas2 (char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerchequescce_pbas2 (char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_obtenerchequescce (char,char,char,char,char,date) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_obtenerchequescce (char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerchequescce (char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".cons_img_nula (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".cons_img_nula (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_img_nula (char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_obtienecheques (char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienecheques (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".cons_img_nula1 (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".cons_img_nula1 (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_dev_suc_web (char,char,date,smallint) to "public" as "informix";
grant  execute on function "informix".cons_dev_suc_web (char,char,date,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_consdev (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_consdev (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_receptor_g (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_receptor_g (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_receptor_g (char,char) to "public" as "informix";
grant  execute on function "informix".cons_img_nula1_mx2 (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_img_nula1_mx2 (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_subirarchivos (char,char,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_subirarchivos (char,char,varchar,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_subirarchivos (char,char,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo61 (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo61 (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo61 (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo62 (char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo62 (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo62 (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo63 (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo63 (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo63 (char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_valida_datos (char,char,char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_valida_datos (char,char,char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_valida_datos (char,char,char,integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".cal_fechapre (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".cal_fechapre (char,char,char,char,date) to "ifxprod" as "informix";
grant  execute on function "informix".cal_fechapre (char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".ins_img_det (char,char,char,char,char,char,char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".ins_img_det (char,char,char,char,char,char,char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".ins_img_det (char,char,char,char,char,char,char,integer,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_generarepopertef_web (char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_generarepopertef_web (char,date,integer) to "public" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh_web (char) to "c90306542" as "informix";
grant  execute on function "informix".cal_fecha_pre_fh_web (char) to "public" as "informix";
grant  execute on function "informix".sp_consimgnullcheque_web (char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consimgnullcheque_web (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultarchequesdevueltos (char,date,date,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultarchequesdevueltos (char,date,date,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consultarchequesdevueltos (char,date,date,smallint) to "ifxprod" as "informix";
grant  execute on function "informix".ins_img_det_web (char,char,char,char,char,char,char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".ins_img_det_web (char,char,char,char,char,char,char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_img_nula1_web (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".cons_img_nula1_web (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cons_tels_web (char) to "public" as "informix";
grant  execute on function "informix".cons_tels_web (char) to "c90306542" as "informix";
grant  execute on function "informix".ins_cheq_det (char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".ins_cheq_det (char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".ins_cheq_det (char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".ins_cheq_det_web (char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".ins_cheq_det_web (char,char,char,char,char,decimal,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_nombre_img_faltante (char,date) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_nombre_img_faltante (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportearchivos_tef2 (char,char,char,char,smallint,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_reportearchivos_tef2 (char,char,char,char,smallint,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_consultausuariosaut (integer) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultausuariosaut (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_cce_chequesrevisados (char,char,char,char,char,char,date,char,char,decimal,char,char,char,date,datetime,datetime,char,char) to "public" as "informix";
grant  execute on function "informix".sp_cce_chequesrevisados (char,char,char,char,char,char,date,char,char,decimal,char,char,char,date,datetime,datetime,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaimagenescheques (char,char,char) to "all_role_bditef" as "informix";
grant  execute on function "informix".sp_validaimagenescheques (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validaimagenescheques (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validaimagenescheques (char,char,char) to "select_role_bditef" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_consdev2 (char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_cce_consultar_chequesdev_consdev2 (char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo60 (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tef_procesararchivo60 (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".cargo_cta (char,char,integer,decimal,char,integer,char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".cargo_cta (char,char,integer,decimal,char,integer,char,date,char) to "ifxprod" as "informix";
grant  execute on function "informix".cargo_cta (char,char,integer,decimal,char,integer,char,date,char) to "public" as "informix";
grant  execute on function "informix".cargo_cta (char,char,integer,decimal,char,integer,char,date,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_tef_receptor_r (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tef_receptor_r (char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_tef_receptor_r (char,char) to "public" as "informix";
revoke  execute on function "informix".sp_cons_presenta2 (char,date) from public as "informix";
revoke  execute on function "informix".sp_cons_presenta2_totales (char,date) from public as "informix";
revoke  execute on function "informix".sp_consultarchequesdevueltos2 (char,date,date,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_consultarchequesdevueltos2_totales (char,date,date) from public as "informix";
revoke  execute on function "informix".sp_consultarchequesdevueltos3 (char,date,date,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_consultarchequesdevueltos3_totales (char,date,date) from public as "informix";
revoke  execute on function "informix".ins_reg_devo2 (char,char,char,char,char,char,date) from public as "informix";
revoke  execute on function "informix".cons_dev_coppel2 (char,date,char,char,char,char,char,integer,integer) from public as "informix";
revoke  execute on function "informix".cons_dev_coppel2_totales (char,date,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cce_consultar_chequesdev_devcoppel2 (char,char,char,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_cce_consultar_chequesdev_devcoppel2_totales (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_obtienecheques2 (char,char,char,char,date,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_obtienecheques2_totales (char,char,char,char,date) from public as "informix";
revoke  execute on function "informix".sp_cce_consultar_chequesdev_consdev2_totales (char,char) from public as "informix";
revoke  execute on function "informix".cons_dev_suc_web2 (char,char,date,smallint) from public as "informix";
revoke  execute on function "informix".sp_tef_generareplistnegra () from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


create index "informix".idx_encabezado1 on "informix".cce_encabezado 
    (nombrearchivo,fecha_presenta) using btree  in dbsco_detpol;
    
create index "informix".idx_cce_gransumario on "informix".cce_gransumario 
    (cod_operacion) using btree  in datos03;
create index "informix".idx_cce_gransumario_nombrearchivo on 
    "informix".cce_gransumario (nombrearchivo,total_reg_ti) using 
    btree  in datos02_idx;
create index "informix".idx_cce_cheques_dev on "informix".cce_cheques_dev 
    (fecha_alta) using btree  in dbs_idxinteg;
create index "informix".idx_cce_cheques_dev_sucursal on "informix"
    .cce_cheques_dev (sucursal,cvebanco,monto,numcheque) using 
    btree  in idx_info03;
create index "informix".idx_chqdev on "informix".cce_cheques_dev 
    (numcheque,numcuenta,monto) using btree  in datos00;
create index "informix".idx_numcte_fp on "informix".cce_cheques_dev 
    (numcte,empresa,cvebanco,numcuenta,numcheque,fechapresenta) 
    using btree  in datos02_idx;
create index "informix".idx_param on "informix".cce_param (cod_param) 
    using btree  in datos00;
create index "informix".idx_cce_mapeo_cecoban_transacc on "informix"
    .cce_mapeo_cecoban (transacc) using btree  in datos01_idx;
    
create index "informix".idx_detalle1 on "informix".cce_detalle 
    (nombrearchivo,fecha_transfer,cod_operacion) using btree 
     in dbsco_detpol;
create index "informix".idx_detalle2 on "informix".cce_detalle 
    (fecha_presini,cod_operacion,bco_receptor,num_cuenta,num_cheque,
    importe) using btree  in datos01_idx;
create index "informix".idx_detalle3 on "informix".cce_detalle 
    (fecha_presini,bco_receptor,cod_operacion,num_cuenta,num_cheque) 
    using btree  in datos01_idx;
create index "informix".idx_detalle4 on "informix".cce_detalle 
    (nombrearchivo,fecha_transfer,bco_receptor,cod_operacion,
    num_cheque) using btree  in datos01_idx;
create index "informix".idx_detalle5 on "informix".cce_detalle 
    (fecha_transfer,cod_operacion,bco_receptor,num_cuenta,num_cheque) 
    using btree  in datos01_idx;
create index "informix".idx_cce_archivos_ctl_fecha_entrada on 
    "informix".cce_archivos_ctl (fecha_entrada) using btree  in 
    datos00_idx;
create index "informix".idx_cce_contproc_empresa_fecha on "informix"
    .cce_contproc (empresa,fecha) using btree  in datos02_idx;
    
create index "informix".idx_cce_cheques_imgcont on "informix".cce_cheques_imgcont 
    (numcuenta,cvebanco,numcheque,imagen_formato,empresa) using 
    btree  in datos00;
create index "informix".idx_cce_consec_proc on "informix".cce_consecutivo_proc 
    (fecha_proceso,sistema) using btree  in datos00;
create index "informix".inx_numero_secuencia on "informix".tef_cce_detalle_paso 
    (num_secuencia) using btree  in datos00;
create index "informix".inx_cod_oper_enc_p on "informix".tef_cce_encabezado_paso 
    (cod_operacion) using btree  in datos00;
create index "informix".inx_cod_oper_sum_p on "informix".tef_cce_sumario_paso 
    (cod_operacion) using btree  in datos00;
create index "informix".inx_codigo_error on "informix".tef_errores 
    (cod_error) using btree  in datos00;
create index "informix".inx_nombre_archivo on "informix".tef_errores 
    (nombre_arch) using btree  in datos00;
create index "informix".idx_tef_operaciones1 on "informix".tef_operaciones 
    (folio_suc,clave_rastreo) using btree  in datos00;
create index "informix".idx_tef_operaciones2 on "informix".tef_operaciones 
    (fecha_trans,cve_status,sucursal) using btree  in datos00;
    
create index "informix".idx_tef_operaciones3 on "informix".tef_operaciones 
    (fecha_trans,folio_suc,sucursal) using btree  in datos00;
    
create index "informix".inx_clave_rastreo on "informix".tef_operaciones 
    (clave_rastreo) using btree  in datos00;
create index "informix".idx_tef_tipo_cta on "informix".tef_tipo_cta 
    (tipo_cta,receptor) using btree  in datos00;
create index "informix".idx_tef_tipo_cta_ord on "informix".tef_tipo_cta 
    (tipo_cta,ordenante) using btree  in datos00;
create index "informix".idx_cce_rpt_chq on "informix".cce_reportes_cheques 
    (empleado) using btree  in datos00;
create index "informix".idx_cce_cheques_revisados on "informix"
    .cce_cheques_revisados (numcheque,numcuenta,numcte,revisado) 
    using btree  in datos00;
create index "informix".idx_cce_cheques_revisados2 on "informix"
    .cce_cheques_revisados (numcheque,numcuenta,fechapresenta) 
    using btree  in datos00;
create index "informix".idx_cce_cheques_revisados3 on "informix"
    .cce_cheques_revisados (numcuenta,numcte,fechapresenta) using 
    btree  in dbs_idxinteg;
create index "informix".idx_cce_cheques_revisados_ejecutivo on 
    "informix".cce_cheques_revisados (fecha_revision,ejecutivo_reviso,
    revisado) using btree  in idx_info03;
create index "informix".idx_cce_archivos_camara on "informix".cce_archivos_camara 
    (clave_archivo) using btree  in datos03;
create index "informix".idx_cce_archivos_camara1 on "informix"
    .cce_archivos_camara (codigo_operacion) using btree  in datos03;
    
create index "informix".idx_cce_archivos_camara2 on "informix"
    .cce_archivos_camara (fecha) using btree  in datos03;
create index "informix".idx_cce_cedulacontable on "informix".cce_cedulacontable 
    (fecha_elaboracion) using btree  in datos00;
create index "informix".idx_cce_cheques_img2_old on "informix"
    .cce_cheques_img_old (fechapresenta,cvebanco,numcuenta,numcheque) 
    using btree  in datos03;
create index "informix".idx_cce_cheques_img3_old on "informix"
    .cce_cheques_img_old (fechapresenta,numcheque) using btree 
     in datos03;
create index "informix".idx_cce_cheques_img_old on "informix".cce_cheques_img_old 
    (numcuenta,cvebanco,numcheque,imagen_formato,empresa) using 
    btree  in datos03;
create index "informix".idx_chequesimg_banco_old on "informix"
    .cce_cheques_img_old (cvebanco) using btree  in datos03;
create index "informix".idx_chequesimg_fecha_old on "informix"
    .cce_cheques_img_old (fechapresenta) using btree  in datos03;
    
create index "informix".idx_chequesimg_fechbco_old on "informix"
    .cce_cheques_img_old (fechapresenta,cvebanco) using btree 
     in datos03;
create unique index "informix".cheques_det2_old on "informix".cce_cheques_det_old 
    (cvebanco,numcuenta,numcheque,fechapresenta,monto,fecha_alta,
    empresa) using btree  in dbs_cierrechqidxanexo;
create index "informix".idx_cce_cheques_det_old on "informix".cce_cheques_det_old 
    (fecha_alta,cvebanco,numcuenta,numcheque) using btree  in 
    datos03;
create index "informix".idx_cheques_det3_old on "informix".cce_cheques_det_old 
    (fechapresenta,cvebanco) using btree  in datos03;
create index "informix".idx_cheques_det4_old on "informix".cce_cheques_det_old 
    (numcheque,numcuenta,cvebanco) using btree  in datos03;
create index "informix".idx_chqdet_old on "informix".cce_cheques_det_old 
    (numcheque,numcuenta,monto) using btree  in datos03;
create index "informix".idx_cce_propios_det_fpres_cheque_cod_status 
    on "informix".cce_propios_det (fecha_presini,c_cheque,cod_operacion,
    status) using btree  in datos00_idx;
create index "informix".idx_sw_cce_propios_det_fecha_presini_c_cuenta_cod_operacion_status 
    on "informix".cce_propios_det (fecha_presini,c_cuenta,cod_operacion,
    status) using btree  in datos02_idx;
create index "informix".idxccectamotdevol on "informix".cce_propios_det 
    (c_cuenta,mot_devol) using btree  in datos03;
create index "informix".idx_cce_cheques_det on "informix".cce_cheques_det 
    (fecha_alta,cvebanco,numcuenta,numcheque) using btree  in 
    datos01_idx;
create unique index "informix".idx_cce_cheques_det2 on "informix"
    .cce_cheques_det (cvebanco,numcuenta,numcheque,fechapresenta,
    monto,fecha_alta,empresa) using btree  in datos00_idx;
create index "informix".idx_cheques_det3 on "informix".cce_cheques_det 
    (fechapresenta,cvebanco) using btree  in dbs_cfd_idxs;
create index "informix".idx_cheques_det4 on "informix".cce_cheques_det 
    (numcheque,numcuenta,cvebanco) using btree  in datos00_idx;
    
create index "informix".idx_chqdet on "informix".cce_cheques_det 
    (numcheque,numcuenta,monto) using btree  in datos01_idx;
create index "informix".idx_cce_cheques_img on "informix".cce_cheques_img 
    (numcuenta,cvebanco,numcheque,imagen_formato,empresa) using 
    btree  in idx_info01;
create index "informix".idx_cce_cheques_img2 on "informix".cce_cheques_img 
    (fechapresenta,cvebanco,numcuenta,numcheque) using btree 
     in dbs_info02;
create index "informix".idx_cce_cheques_img3 on "informix".cce_cheques_img 
    (fechapresenta,numcheque) using btree  in dbs_info03;
create index "informix".idx_chequesimg_banco on "informix".cce_cheques_img 
    (cvebanco) using btree  in dbs_movhis_idx1;
create index "informix".idx_chequesimg_fecha on "informix".cce_cheques_img 
    (fechapresenta) using btree  in dbs_movhis_idx2;
create index "informix".idx_chequesimg_fechbco on "informix".cce_cheques_img 
    (fechapresenta,cvebanco) using btree  in dbs_movhis_idx1;
    
create unique index "informix".idx_cli_list_negra on "informix"
    .tef_cte_lista_negra (num_cta_ord,cuenta,num_cte) using btree 
     in datos02_idx;


alter table "informix".tef_cce_archivos add constraint (foreign 
    key (cve_status) references "informix".tef_status_archcce 
    );
alter table "informix".tef_cce_encabezado add constraint (foreign 
    key (nombre_arch,fecha_presentacion) references "informix"
    .tef_cce_archivos );
alter table "informix".tef_cce_encabezado add constraint (foreign 
    key (cod_operacion) references "informix".tef_codigo_oper 
    );
alter table "informix".tef_cce_detalle add constraint (foreign 
    key (nombre_arch,fecha_presentacion) references "informix"
    .tef_cce_encabezado );
alter table "informix".tef_cce_detalle add constraint (foreign 
    key (cod_operacion) references "informix".tef_codigo_oper 
    );
alter table "informix".tef_cce_detalle add constraint (foreign 
    key (tipo_cta_ord) references "informix".tef_tipo_cta );
alter table "informix".tef_cce_detalle add constraint (foreign 
    key (tipo_cta_rec) references "informix".tef_tipo_cta );
alter table "informix".tef_cce_detalle add constraint (foreign 
    key (motivo_dev) references "informix".tef_cat_devoluciones 
    );
alter table "informix".tef_cce_detalle add constraint (foreign 
    key (cve_status) references "informix".tef_status_pago );
alter table "informix".tef_cce_sumario add constraint (foreign 
    key (nombre_arch,fecha_presentacion) references "informix"
    .tef_cce_encabezado );
alter table "informix".tef_cce_sumario add constraint (foreign 
    key (cod_operacion) references "informix".tef_codigo_oper 
    );
alter table "informix".tef_operaciones add constraint (foreign 
    key (cve_canal) references "informix".tef_canal );
alter table "informix".tef_operaciones add constraint (foreign 
    key (cve_status) references "informix".tef_status_pago );
alter table "informix".tef_operaciones add constraint (foreign 
    key (motivo_dev) references "informix".tef_cat_devoluciones 
    );