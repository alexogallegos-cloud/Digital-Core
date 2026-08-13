CREATE PROCEDURE "informix".sp_domi_receptor ( psNomArchivo CHAR(20), psNumEmpleado CHAR (8))
RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE DOMICILIACION -- RECEPTOR
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 13/07/2009
-- BD: BdiDomi
-- SISTEMA : Domiciliacion
--Modificacion:
--Autor: Alejandro Osuna
--Fecha : 02/02/2010
--Se Modifica para que se el consecutivo del archivo de respuesta sea el correcto
--Autor: Rocio Karina Marquez Coronel
--Fecha: 24/04/2015
--Se agrega validacion para los dias inhabiles bancarios, que mande un codigo de retorno "00113".
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE sPROCESANDO CHAR(1);
DEFINE sERROR CHAR(1);
DEFINE sFINALIZADO CHAR(1);
DEFINE vsDescripcionProceso CHAR (60);
DEFINE vsFlagTipoProceso CHAR (1);
DEFINE viTipoArchivo SMALLINT;
DEFINE vsFlagUnico CHAR (1);
DEFINE vsBloque CHAR (2);
DEFINE vsFecha_Presentacion CHAR (8);
DEFINE vsFecha_Presentacion1 CHAR (8);
DEFINE vsFecha_Presentacion2 CHAR (8);

DEFINE vsCodRetorno CHAR (5);
DEFINE vsCodRetorno2 CHAR (5);
DEFINE vsMensaje_Respuesta CHAR (100);
DEFINE vsValorParam CHAR (100);
DEFINE vsNomArchivo CHAR (20);
DEFINE vsNomArchivo11 CHAR (20);
DEFINE vsNomArchivo31 CHAR (20);
DEFINE vsNomArchivo32 CHAR (20);
DEFINE viContador INTEGER;
DEFINE vdtFecha DATE;
DEFINE visqlerr INTEGER ;

DEFINE vsRuta CHAR (100);

DEFINE vsNomProceso CHAR (20);
DEFINE sCodBanco CHAR(3);
DEFINE vsCodRetSub VARCHAR(115); ---descripcion
DEFINE vSFecha_aplica CHAR(8);
DEFINE vdFecha_aplicaDe DATE;

DEFINE viNumArchivos INTEGER;

DEFINE vsFlagArch11 CHAR(1);
DEFINE vsFlagArch31 CHAR(1);
DEFINE vsFlagArch32 CHAR(1);
DEFINE vdtFecha_Presentacion_Resp DATE;

DEFINE d_Fech_prox DATE;

DEFINE vsSQL CHAR(2204);
DEFINE vNumOperaciones INTEGER;
DEFINE vParam1 INTEGER;
DEFINE vParam2 INTEGER;
DEFINE vParam3 INTEGER;
DEFINE vParam4 INTEGER;
DEFINE vParam5 INTEGER;
DEFINE vParam6 INTEGER;
DEFINE vParam7 INTEGER;
DEFINE vParam8 INTEGER;
DEFINE vTotOper30 INTEGER;
DEFINE v_fechControl DATE;

/* INICIALIZACION DE VARIABLES */
--VARIABLES DE MONITOR
LET sPROCESANDO = '0';
LET sFINALIZADO = '1';
 LET sERROR = '3';
LET vsDescripcionProceso = '';
LET vsFlagTipoProceso = '';
LET viTipoArchivo = 0;
LET vsFlagUnico = 'F';
LET vsBloque = '00';
LET vsFecha_Presentacion = '';
LET vsFecha_Presentacion2 = '';

LET vsCodRetorno = '';
LET vsCodRetorno2 = '';
LET vsMensaje_Respuesta = '';
LET vsValorParam = '';
LET vsNomArchivo = '';
LET vsNomArchivo11 = '';
LET vsNomArchivo31 = '';
LET vsNomArchivo32 = '';
LET viContador = 0;
LET vdtFecha = CURRENT::DATE;

LET vsRuta = '';

LET vsNomProceso = '';

LET visqlerr = 0;
LET sCodBanco = "";
LET vsCodRetSub = "";
LET vSFecha_aplica = "";

LET viNumArchivos = 0;

LET vsFlagArch11 = 'F';
LET vsFlagArch31 = 'F';
LET vsFlagArch32 = 'F';
LET vdtFecha_Presentacion_Resp = CURRENT::DATE;
LET vNumOperaciones = 0;
LET vParam1 = 0;
LET vParam2 = 0;
LET vParam3 = 0;
LET vParam4 = 0;
LET vParam5 = 0;
LET vParam6 = 0;
LET vParam7 = 0;
LET vParam8 = 0;
LET vTotOper30 = 0;

LET vsSQL = "";

		

BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES

		EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
		sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;

		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || 'PROCESO: ' || TRIM(vsDescripcionProceso) ;

		RETURN  vsNomArchivo, visqlerr, vsMensaje_Respuesta ;

	END EXCEPTION;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/depuraremesas/tracedomi_receptor.out';
	--TRACE ON ;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET vsDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiDomi:Sp_Valida_Cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;

	LET vsDescripcionProceso = 'Validacion de parametros.';
	
	IF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR
		LET vsCodRetorno = '00101';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '02') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA
		LET vsCodRetorno = '00102';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '03') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS
		LET vsCodRetorno = '00103';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '04') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS
		LET vsCodRetorno = '00104';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '05') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL
		LET vsCodRetorno = '00105';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '06') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '00106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '43') THEN -- Valida que exista el NUEVO parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '00106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '07') THEN -- Valida que exista el parametro SUCURSAL CONTABLE DOMI
		LET vsCodRetorno = '00107';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '08') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR DOMI
		LET vsCodRetorno = '00108';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '09') THEN -- Valida que exista el parametro TRANSACCION DE ABONO
		LET vsCodRetorno = '00109';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '10') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN
		LET vsCodRetorno = '00110';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '11') THEN -- Valida que exista el parametro MAXIMO DE RECHAZOS PERMITIDOS
		LET vsCodRetorno = '00111';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '12') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
		LET vsCodRetorno = '00112';
--	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '13') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
--		LET vsCodRetorno = '00113';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '00114';
	ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPRLEADO VACIO
		LET vsCodRetorno = '00115';
	ELIF (LENGTH(TRIM(psNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS
		LET vsCodRetorno = '00116';
	ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS
		LET vsCodRetorno = '00117';
	ELIF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(psNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
		LET vsCodRetorno = '00132';
	ELSE --TODO LOS PARAMETROS EXISTEN
		SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas;
		
		--- OBTIENE CODIGO DE BANCOPPEL
		SELECT LIMIT 1 TRIM(valor)
		INTO sCodBanco
		FROM bdidomi: dom_parametros
		WHERE cod_param = "05";
		EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
		LET vsFecha_Presentacion = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
		-- Se guarda el valor para compararlo con el encabezado del archivo
		LET vsFecha_Presentacion1 = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
		
		IF EXISTS (SELECT fecha FROM bdinteg:si_feriado_banca WHERE pais = '001' AND fecha = vdtFecha) THEN
			LET vsCodRetorno = '00113';
		ELSE
			LET vsCodRetorno = '00000';
		END IF;					
		
		LET vsValorParam = TRIM(sCodBanco);
	END IF;

	IF (vsCodRetorno = '00000') THEN --TODO LOS PARAMETROS EXISTEN

		LET viContador = 0;
		LET vsFlagTipoProceso = 'A';

		LET vsFlagArch11 = 'F';
		LET vsFlagArch31 = 'F';
		LET vsFlagArch32 = 'F';

		WHILE ((viContador < 2) AND (vsFlagTipoProceso = 'A'))  --VERIFICA LA EXISTENCIA DE LOS 2 TIPOS DE ARCHIVO A PROCESAR

			LET vsDescripcionProceso = 'Obtencion de nombre de Archivo';

			LET viContador = viContador + 1;

			LET vsNomProceso = '';

			IF (TRIM(psNomArchivo) = '') THEN --Valida si es una corrida Automatica. --SIN NOMBRE DE ARCHIVO
				--OBTIENE EL NOPMBRE DEL ARCHIVO ESPERADO

				LET vsFlagTipoProceso = 'A'; --AUTOMATICO

				IF (viContador = 2) THEN --ARCHIVO 10
					LET viTipoArchivo = 10;
				ELIF (viContador = 1) THEN -- ARCHIVO 30
					LET viTipoArchivo = 30;
				ELSE --NINGUN TIPO DEFINIDO
					LET viTipoArchivo = 0;
				END IF;
				LET vsNomArchivo = 'S' --CONSTANTE
								|| '01'--CONSTANTE
								|| TRIM(sCodBanco) --ID BANCARIA BANCOPPEL 137
								|| 'A' --CONSTANTE
								|| '2' --DOMICILIACION EN MONEDA NAC.
								|| '.' --CONSTANTE
								|| 'A' --ARCHIVO DE DATOS
								|| viTipoArchivo::CHAR(2)
								|| LPAD(DAY(vdtFecha), 2, '0') --FECHA DEL ARCHIVO DIA DEL MES --DD--
								|| '98'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO

			ELSE -- Corrida Manual.  -- INDICA EL NOMBRE DEL ARCHIVO.

				LET vsFlagTipoProceso = 'M'; --MANUAL

				IF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '10' ) THEN --ARCHIVO 10
					LET viTipoArchivo = 10;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '30' ) THEN --ARCHIVO 30
					LET viTipoArchivo = 30;
				ELSE --ARCHIVO NO VALIDO
					LET viTipoArchivo = 0;
				END IF;

				LET vsNomArchivo = TRIM(psNomArchivo);

			END IF;

			IF (LENGTH (TRIM(vsNomArchivo)) >= 16) THEN --VALIDA EL EL NOMBRE DEL ARCHIVO POSEA LA EXTENCION ADECUADA
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(vsNomArchivo) FROM 15 FOR 2);
			ELSE -- ERROR DE LONGITUD DE NOMBRE DE ARCHIVO, ARCHIVO NO RECONOCIDO
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '00';
			END IF ;

			LET vsDescripcionProceso = 'Validacion de nombre de archivo';
			--VALIDA LA INTEGRIDAD DEL NOMBRE DEL ARCHIVO
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_ValidarNombreArchivos( viTipoArchivo, 'S', vsNomArchivo) INTO vsCodRetorno;

			IF (vsCodRetorno = '00000') THEN --NOMBRE DE ARCHIVO OK

				LET vsDescripcionProceso = 'Validacion de procesamientos previos.';
				
				IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sFINALIZADO ) THEN  --EL ARCHIVO FUE PROCESADO PREVIAMENTE
					LET vsCodRetorno = '00119';

					EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;

					INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Receptor', vsMensaje_Respuesta, psNumEmpleado, CURRENT);

				ELIF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
					LET vsCodRetorno = '00120';

					EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;

					INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Receptor', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
				--ELIF EXISTS(SELECT Nombre_Arch FROM BdiDomi:Dom_CCE_Archivos WHERE Nombre_Arch = TRIM(vsNomArchivo) AND Fecha_Presentacion = vsFecha_Presentacion) THEN  --EL ARCHIVO ESTA EN LA CCE_ARCHIVOS

					--LET vsCodRetorno = '00133';
				ELIF NOT EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sERROR ) THEN  --EL ARCHIVOFUE PROCESADO CON ERROR
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET vsDescripcionProceso = 'Registro de Reproceso del Archivo.';

					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '11') INTO vsCodRetorno2; --zachiel

					LET vsCodRetorno = '00000';
				ELSE  --EL ARCHIVO NO SE HA PROCESADO
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET vsDescripcionProceso = 'Registro de Procesamiento del Archivo.';

					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11' ) INTO vsCodRetorno2; --zachiel

					LET vsCodRetorno = '00000';
				END IF;
				--Se agrego esta validacion, para que en dado caso de que exista un error y se ejecute nuevamente, no marque un error -268
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo) AND fecha_presentacion = TRIM(vsFecha_Presentacion)) THEN			
					DELETE FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo) AND fecha_presentacion = TRIM(vsFecha_Presentacion);
					DELETE FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo) AND fecha_presentacion = TRIM(vsFecha_Presentacion);
					DELETE FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo) AND fecha_presentacion = TRIM(vsFecha_Presentacion);
				END IF;	
				IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ES APTO PARA SER PROCESADO

					LET vsDescripcionProceso = 'Borrado de tablas de paso';
					--LIMPIA LAS TABLAS DE PARA PROCESAR EL NUEVOA ARCHIVO
					EXECUTE PROCEDURE bdidomi:sp_Domi_MoverRegistrosHist(TRIM(vsNomArchivo), '', 'B') INTO vsCodRetorno;

					SELECT COUNT(Nombre_Arch) INTO viNumArchivos FROM BdiDomi:Dom_cce_Archivos WHERE Fecha_Presentacion = vsFecha_Presentacion AND SUBSTRING (Nombre_Arch FROM 1 FOR 14) = SUBSTRING (vsNomArchivo FROM 1 FOR 14); -- RUTA ARCHIVO PROCESAR

					IF ((viNumArchivos IS NULL) OR (viNumArchivos = 0)) THEN
						LET viNumArchivos = 1;
					ELSE
						LET viNumArchivos = viNumArchivos + 1;
					END IF;

					IF (vsCodRetorno = '00000') THEN

						EXECUTE FUNCTION BdInteg:SplValFecha ('001',(vdtFecha) + 1 ,0)INTO vsCodRetorno2, vdtFecha_Presentacion_Resp; --a qui ya tengo el dias siguiente habil
						--NOTA.- Se agrego la validacion de la fecha dado que se puede presentar el caso que la fecha sea habil para la banca e inabil para el banco.
						--Solicitada por jaime gonzales el dia 15/09/2008
						--Realizada por Alejandro Osuna
						SELECT fecha_prox INTO d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdtFecha_Presentacion_Resp;
						IF (d_Fech_prox IS NULL) OR (d_Fech_prox = "") THEN
							LET vdtFecha_Presentacion_Resp = vdtFecha_Presentacion_Resp;
						ELSE
							LET vdtFecha_Presentacion_Resp = d_Fech_prox;
						END IF;
						IF (viTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS
							LET vsNomArchivo11 = 'E'|| TRIM(vsValorParam) || LPAD(DAY(vdtFecha_Presentacion_Resp),2,'0')
							|| LPAD(MONTH(vdtFecha_Presentacion_Resp),2,'0')|| YEAR(vdtFecha_Presentacion_Resp) || '.11' || LPAD (viNumArchivos, 2, '0');

							LET vsNomArchivo31 = '';
							LET vsNomArchivo32 = '';

							EXECUTE PROCEDURE bdidomi:sp_Domi_MoverRegistrosHist(TRIM(vsNomArchivo11), '', 'B') INTO vsCodRetorno;

						ELIF (viTipoArchivo = 30) THEN --ARCHIVO 30 -- APLICAR CARGOS
							LET vsNomArchivo11 = '';
							LET vsNomArchivo31 = 'E'|| TRIM(vsValorParam) || LPAD(DAY(vdtFecha_Presentacion_Resp),2,'0')
							|| LPAD(MONTH(vdtFecha_Presentacion_Resp),2,'0')|| YEAR(vdtFecha_Presentacion_Resp) || '.31'
							|| LPAD (viNumArchivos, 2, '0');

							LET vsNomArchivo32 = 'E'|| TRIM(vsValorParam) || LPAD(DAY(vdtFecha_Presentacion_Resp),2,'0')
							|| LPAD(MONTH(vdtFecha_Presentacion_Resp),2,'0')|| YEAR(vdtFecha_Presentacion_Resp) || '.32'
							|| LPAD (viNumArchivos, 2, '0');

							EXECUTE PROCEDURE bdidomi:sp_Domi_MoverRegistrosHist(TRIM(vsNomArchivo31), '', 'B') INTO vsCodRetorno;

							IF (vsCodRetorno = '00000') THEN
								EXECUTE PROCEDURE bdidomi:sp_Domi_MoverRegistrosHist(TRIM(vsNomArchivo32), '', 'B') INTO vsCodRetorno;
							END IF;
						END IF;

					END IF;

					IF (vsCodRetorno = '00000') THEN -- VALIDA KE LAS TABLAS SE LIMPIARON CORRECTAMENTE

						SELECT LIMIT 1 Valor INTO vsRuta FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01'; -- RUTA ARCHIVO PROCESAR

						LET vsDescripcionProceso = 'Verifica que exista en archivo en la ruta';
						--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;

						IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO

							LET vsDescripcionProceso = 'Carga del archivo a las tablas de paso';
							--CARGA EL ARCHIVO A LAS TABLAS
							EXECUTE PROCEDURE BdiDomi:sp_Domi_SubirArchivos(vsFlagTipoProceso, '01'/*RUTA ARCHIVO PROCESAR*/, TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsCodRetSub;

							IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO SE CARGO CORRECTAMENTE A LAS TABLAS

								SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
							    -- Se valida que la fecha del encabezado sea la del dÃÂÃÂÃÂÃÂ­a de hoy	
							    IF vsFecha_Presentacion = vsFecha_Presentacion1 THEN
								UPDATE bdidomi: dom_cce_archivos SET fecha_presentacion = vsFecha_Presentacion where Nombre_Arch = TRIM(vsNomArchivo) AND fecha_presentacion = "";
								/*UPDATE bdidomi: dom_cce_archivos SET fecha_presentacion = vsFecha_Presentacion where Nombre_Arch = TRIM(vsNomArchivo) AND fecha_presentacion = "";
								SELECT unique(fecha_aplica) INTO vSFecha_aplica FROM bdidomi:dom_cce_detalle_paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
								LET vdFecha_aplicaDe = Substr(vSFecha_aplica,5,2) || "/" || Substr(vSFecha_aplica,7,2) || "/" || Substr(vSFecha_aplica,1,4);
								UPDATE bdidomi: dom_cce_archivos SET fecha_aplicacion = vdFecha_aplicaDe WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;*/

								LET vsDescripcionProceso = 'Validacion de Integridad del Archivo.';
								--INTEGRIDAD DEL ARCHIVO
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Valida_Datos( TRIM(vsNomArchivo), vsFecha_Presentacion, 'S' /*SALIDA CECOBAN*/, viTipoArchivo, 'R' /*RECEPTOR*/, TRIM(vsNomProceso)) INTO vsCodRetorno, vsBloque;
								
								IF (vsCodRetorno = '00000') THEN --VALIDA LA INTEGRIDAD DEL ARCHIVO

									SELECT LIMIT 1 fecha_aplica INTO vSFecha_aplica
									FROM bdidomi:dom_cce_detalle_paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
									LET vdFecha_aplicaDe = Substr(vSFecha_aplica,5,2) || "/" || Substr(vSFecha_aplica,7,2) || "/" || Substr(vSFecha_aplica,1,4);
									UPDATE bdidomi: dom_cce_archivos SET fecha_aplicacion = vdFecha_aplicaDe
									WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;


									LET vsDescripcionProceso = 'Procesamiento del Archivo Original.';
									IF (viTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS

										EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo10 (TRIM(vsNomArchivo), TRIM(vsNomArchivo11)) INTO vsCodRetorno;

									ELIF (viTipoArchivo = 30) THEN --ARCHIVO 30 -- APLICAR CARGOS
										
										SELECT ROUND(num_operaciones / 4) INTO vNumOperaciones FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo) AND fecha_presentacion = TRIM(vsFecha_Presentacion);
										
										IF vNumOperaciones > 0 THEN
										
											SELECT num_operaciones INTO vTotOper30 FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo) AND fecha_presentacion = TRIM(vsFecha_Presentacion);
										
											DELETE FROM bdidomi:dom_cce_control_hilos;
											
											LET v_fechControl = MDY(Substr(vsFecha_Presentacion,5,2),Substr(vsFecha_Presentacion,7,2),Substr(vsFecha_Presentacion,1,4)); 
										
											LET vParam1 = 2;
											LET vParam2 = vNumOperaciones;
											INSERT INTO bdidomi:dom_cce_control_hilos(nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,nombre_procesarch,rango1,rango2,user_insert,fecha_insert)
											VALUES(TRIM(vsNomArchivo),vsFecha_Presentacion,TRIM(vsNomArchivo31),TRIM(vsNomArchivo32),'sp_domi_procesararch30_1',vParam1,vParam2,psNumEmpleado,EXTEND(v_fechControl, YEAR to SECOND));
											LET vParam3 = vNumOperaciones + 1;
											LET vParam4 = vParam3 + vNumOperaciones;
											INSERT INTO bdidomi:dom_cce_control_hilos(nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,nombre_procesarch,rango1,rango2,user_insert,fecha_insert)
											VALUES (TRIM(vsNomArchivo),vsFecha_Presentacion,TRIM(vsNomArchivo31),TRIM(vsNomArchivo32),'sp_domi_procesararch30_2',vParam3,vParam4,psNumEmpleado,EXTEND(v_fechControl, YEAR to SECOND));
											LET vParam5 = vParam4 + 1;
											LET vParam6 = vParam5 + vNumOperaciones;
											INSERT INTO bdidomi:dom_cce_control_hilos(nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,nombre_procesarch,rango1,rango2,user_insert,fecha_insert)
											VALUES (TRIM(vsNomArchivo),vsFecha_Presentacion,TRIM(vsNomArchivo31),TRIM(vsNomArchivo32),'sp_domi_procesararch30_3',vParam5,vParam6,psNumEmpleado,EXTEND(v_fechControl, YEAR to SECOND));
											LET vParam7 = vParam6 + 1;
											LET vParam8 = vTotOper30 + 1;
											INSERT INTO bdidomi:dom_cce_control_hilos(nombre_arch30,fecha_presentacion,nombre_arch31,nombre_arch32,nombre_procesarch,rango1,rango2,user_insert,fecha_insert)
											VALUES (TRIM(vsNomArchivo),vsFecha_Presentacion,TRIM(vsNomArchivo31),TRIM(vsNomArchivo32),'sp_domi_procesararch30_4',vParam7,vParam8,psNumEmpleado,EXTEND(v_fechControl, YEAR to SECOND));
											
											LET vsCodRetorno = '00000';
										ELSE
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
											sERROR, vsCodRetorno, psNumEmpleado, 'insert_dom_cce_control_hilos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
											LET vsCodRetorno = '00111';
										END IF;
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArch30 (TRIM(vsNomArchivo), TRIM(vsNomArchivo31), TRIM(vsNomArchivo32), psNumEmpleado) INTO vsCodRetorno;

									END IF;
									----Se cambia de 777 a 666 CBM 09122009
									----Se comenta 
									IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE PROCESO CORRECTAMENTE
										--- SE OTORGAN DERECHOS AL ARCHIVO PROCESADO
										--IF TRIM(vsNomArchivo) <> "" AND vsNomArchivo IS NOT NULL THEN
											--LET vsSQL = '' ;
											--LET vsSQL = 'chmod 666 ' || TRIM(vsRuta) || TRIM (vsNomArchivo);
											--SYSTEM vsSQL ;
										--END IF


										LET vsDescripcionProceso = 'Generacion de Archivos de Respuesta.';
										--GENERAR DESCARGA DE ARCHIVOS
										IF (viTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS

											IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo11))THEN
												IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo11))THEN
													IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo11))THEN
														LET vsFlagArch11 = 'V';
														SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo11) ;
														EXECUTE PROCEDURE BdiDomi:Sp_Domi_GeneraArchivo (TRIM (vsNomArchivo11), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
													END IF;
												END IF;
											END IF;
										END IF;	
										/*ELSE --ERROR AL GUARDAR EN LA TABLA DE HILOS
												--GUARDAR BITACORA
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
													sERROR, vsCodRetorno, psNumEmpleado, 'dom_cce_control_hilos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ /*) INTO vsCodRetorno2;
												/*LET vsCodRetorno = '00124';
										END IF;*/

										IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS

											IF (viTipoArchivo = 10) THEN --ARCHIVO 10

												IF (vsFlagArch11 = 'V') THEN
													EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo11), vsFecha_Presentacion2, '01') INTO vsCodRetorno;
													IF (vsCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
														EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo11), vsFecha_Presentacion2, 'T') INTO vsCodRetorno;
													ELSE--ERROR
													END IF;
												END IF;
											END IF;
										 END IF;

										 IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO DE RESPUESTA SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS arch cod 10

											LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';

												--ACTUALIZA LOS ESTATUS DEL CCE_ACHIVO PARA KE LOS AMRQUE COMO TERMINADO
												IF (viTipoArchivo = 10) THEN

													IF (vsFlagArch11 = 'V') THEN
														--SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion FROM BdiDomi:Dom_cce_Encabezado WHERE Nombre_Arch = TRIM(vsNomArchivo);
														EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFecha_Presentacion, '01'/*EXITO*/) INTO vsCodRetorno;
														IF (vsCodRetorno = '00000') THEN --VALIDA KE SE GUARDO CORRECTAMENTE EL REGISTRO EN CCE_ARCHIVO
															EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vsFecha_Presentacion, 'T') INTO vsCodRetorno;
														ELSE--ERROR
														END IF;
													END IF;
												END IF;

										 ELSE --  ERROR AL MOVER LOS REGISTROS DEL ARCHIVO AL HITORICO
											IF (viTipoArchivo = 10) THEN -- ERROR DE ARCHIVO 11
												--GUARDAR BITACORA

												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
												sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
												LET vsCodRetorno = '00128';
											END IF;
										 END IF;
										 IF (vsCodRetorno = '00000') THEN
											IF (viTipoArchivo = 10) THEN
												LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '03' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO vsCodRetorno;
											END IF;
										 ELSE
											--GUARDAR BITACORA
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
											sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_MoverArchivos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
											LET vsCodRetorno = '00130';
										 END IF;
									ELSE --ERROR AL PROCESAR EL ARCHIVO
										--GUARDAR BITACORA
										IF (viTipoArchivo = 10) THEN
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
											sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ProcesarArchivo10', TRIM(vsNomArchivo) , vsFecha_Presentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
										END IF;
										LET vsCodRetorno = '00123';
									END IF;

								ELSE --ERROR DE INTEGRIDAD EN EL ARCHIVO
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
									sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_Valida_Datos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;

									EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;

									IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
										sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
									END IF;
									--Se agrego esta validacion para cuando el banco no este dado de alta para domiciliacion
									IF(vsCodRetorno2 = '34') THEN
										LET vsCodRetorno = '00139';
									ELSE
										LET vsCodRetorno = '00122';
									END IF;	
								END IF;
							    ELSE -- LA FECHA DEL ENCABEZADO ES DIFERENTE AL DIA DE HOY
								--GUARDAR BITACORA
								LET vsCodRetorno = '00603';
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno2;
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
								sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/  ) INTO vsCodRetorno2;
								LET vsCodRetorno = '00603';
							    END IF;

							ELSE -- ERROR AL CARGAR EL ARCHIVO A LAS TABLAS DE PASO
								--GUARDAR BITACORA
								--LET vsFecha_Presentacion = LPAD (YEAR(CURRENT::DATE), 4, '0') || LPAD (MONTH(CURRENT::DATE), 2, '0') || LPAD (DAY(CURRENT::DATE), 2, '0');
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno2;

								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
								sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/  ) INTO vsCodRetorno2;
--								LET vsCodRetorno = '00121';
							END IF;
						ELSE --NO EXISTE EL ARCHIVO
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
							sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_BuscarArchivo', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
							LET vsCodRetorno = '00131';
							-----
						END IF;

					ELSE -- ERROR AL LIMPIAR LAS TABLAS
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
						sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '03'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
						LET vsCodRetorno = '00130';
					END IF;

				ELSE -- ERROR EL ARCHIVO NO ES APTO PARA SER PROCESADO
					--GUARDAR BITACORA
					--EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
					--sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) ;
					--LET vsCodRetorno = '00130';
				END IF;
			ELSE -- NOMBRE DE ARCHIVO ERRONEO
				--GRABAR EN LA BITACORA  vsCodRetorno
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
				sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;

				SELECT LIMIT 1 Valor INTO vsRuta FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01'; -- RUTA ARCHIVO PROCESAR

				--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;

				IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO

					EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;

					IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
						sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
					END IF;
				END IF;

				LET vsCodRetorno = '00118';
			END IF;

			EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
			RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;

			IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
				IF (vsCodRetorno <> '00120') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'PROCESANDO'
					UPDATE BdiDomi:Dom_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ;
				END IF;
			END IF;

		END WHILE;

	ELSE -- PARAMETRO NO ENCONTRADO
		EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensaje_Respuesta;
		--LET vsCodRetorno = '00131'
	END IF;
END
END PROCEDURE;