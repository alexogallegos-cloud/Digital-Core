CREATE PROCEDURE "informix".sp_domi_receptor_test( psNomArchivo CHAR(20), psNumEmpleado CHAR (8))
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
DEFINE viTipoArchivo SMALLINT ;
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

/* INICIALIZACION DE VARIABLES */
--VARIABLES DE MONITOR
LET sPROCESANDO = '0';
LET sFINALIZADO = '0';
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
LET vdtFecha = CURRENT::DATE-1;

LET vsRuta = '';

LET vsNomProceso = '';

LET visqlerr = 0;
LET sCodBanco = "";
LET vsCodRetSub = "";
LET vSFecha_aplica = "";

LET viNumArchivos = 1;

LET vsFlagArch11 = 'F';
LET vsFlagArch31 = 'F';
LET vsFlagArch32 = 'F';
LET vdtFecha_Presentacion_Resp = CURRENT::DATE-1;

LET vsSQL = "";

		--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/tracedomi_receptor.out';
		--TRACE ON ;

BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES

		EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
		sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;

		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || 'PROCESO: ' || TRIM(vsDescripcionProceso) ;

		RETURN  vsNomArchivo, visqlerr, vsMensaje_Respuesta ;

	END EXCEPTION;
	SET DEBUG FILE TO '/home/sysdomi/tracedomi_receptor.out';
    TRACE ON ;

	--IF ( psNumEmpleado = '99999999' ) THEN
		--SET DEBUG FILE TO '/tmp/domi/tracedomi_receptor.out';
		--TRACE ON ;
	---END IF ;
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
		--SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas;
		LET vdtFecha = TODAY-1;
		
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
			
			LET viTipoArchivo = viTipoArchivo;
			
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

				LET vsNomArchivo11 = vsNomArchivo11;
				LET vsNomArchivo31 = '';
				LET vsNomArchivo32 = '';

				--EXECUTE PROCEDURE bdidomi:sp_Domi_MoverRegistrosHist(TRIM(vsNomArchivo11), '', 'B') INTO vsCodRetorno;
				LET vsCodRetorno = '00000';
			ELIF (viTipoArchivo = 30) THEN --ARCHIVO 30 -- APLICAR CARGOS
				LET vsNomArchivo11 = '';
				LET vsNomArchivo31 = 'E'|| TRIM(vsValorParam) || LPAD(DAY(vdtFecha_Presentacion_Resp),2,'0')
				|| LPAD(MONTH(vdtFecha_Presentacion_Resp),2,'0')|| YEAR(vdtFecha_Presentacion_Resp) || '.31'
				|| LPAD (viNumArchivos, 2, '0');

				LET vsNomArchivo32 = 'E'|| TRIM(vsValorParam) || LPAD(DAY(vdtFecha_Presentacion_Resp),2,'0')
				|| LPAD(MONTH(vdtFecha_Presentacion_Resp),2,'0')|| YEAR(vdtFecha_Presentacion_Resp) || '.32'
				|| LPAD (viNumArchivos, 2, '0');

				--EXECUTE PROCEDURE bdidomi:sp_Domi_MoverRegistrosHist(TRIM(vsNomArchivo31), '', 'B') INTO vsCodRetorno;
				LET vsCodRetorno = '00000';
			END IF;
			
			IF (viTipoArchivo = 10) THEN --ARCHIVO 10 -- VALIDAR CUENTAS
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo11))THEN
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo11))THEN
						IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo11))THEN
							LET vsFlagArch11 = 'V';
							SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo11) ;
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_GeneraArchivo_test(TRIM (vsNomArchivo11), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
						END IF;
					END IF;
				END IF;
			ELIF (viTipoArchivo = 30) THEN --ARCHIVO 30 -- CARGOS ACUENTAS
				IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo31))THEN
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo31))THEN
						IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo31))THEN
							LET vsFlagArch31 = 'V';
							SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo31) ;
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_GeneraArchivo_test(TRIM (vsNomArchivo31), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
						END IF;
					END IF;
				END IF;

				IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO 31 SE GENERO CORRECTAMENTE
					IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo32))THEN
						IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo32))THEN
							IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo32))THEN
								LET vsFlagArch32 = 'V';
								SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion2 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo32) ;
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_GeneraArchivo_test(TRIM (vsNomArchivo32), vsFecha_Presentacion2, '02'/*RUTA ARCHIVO RESPUESTA*/ ) INTO vsCodRetorno;
							END IF;
						END IF;
					END IF;
				ELSE --ERROR AL GENERAR ARCHIVO 31
					--GUARDAR BITACORA
					--EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso,
						--sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_GeneraArchivo', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
					LET vsCodRetorno = '00124';
				END IF;
			END IF;
			
			
			EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
			RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME;

		END WHILE;

	ELSE -- PARAMETRO NO ENCONTRADO
		--EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensaje_Respuesta;
		--LET vsCodRetorno = '00131'
	END IF;
END
END PROCEDURE;