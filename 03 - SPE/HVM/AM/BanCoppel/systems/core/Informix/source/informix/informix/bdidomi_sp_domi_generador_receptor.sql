CREATE PROCEDURE "informix".sp_domi_generador_receptor(
psNombreArchivo CHAR(20),
psNumEmpleado CHAR (8)
)

RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE DOMICILIACION -- RECEPTOR
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 23/07/2009
-- BD: BdiDomi
-- SISTEMA : Domiciliacion
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE vsFlagTipoProceso 		CHAR(1);
DEFINE vsNomProceso 			CHAR(20);
DEFINE vsDescripcionProceso 	CHAR(60);
DEFINE sGENERANDO 				CHAR(1);
DEFINE sFINALIZADO				CHAR(1);
DEFINE sERROR 					CHAR(1);
DEFINE visqlerr 				INTEGER;
DEFINE vsNomArchivo 			CHAR(20);
DEFINE vsFechaPresentacion 		CHAR(8);
DEFINE vsFechaPresentacion1		CHAR(8);
DEFINE vsFechaPresentacion2		CHAR(8);
DEFINE vsFechaPresentacion3		CHAR(8);
DEFINE vsCodRetorno 			CHAR(5);
DEFINE vsCodRetorno2 			CHAR(5);
DEFINE vdtFecha 				DATE;
DEFINE vdtFechaInsert 			DATE;
DEFINE vsMensajeRespuesta 		CHAR (100);
DEFINE viTipoArchivo 			INTEGER;
DEFINE vsDia 					CHAR(2);
DEFINE vsMes 					CHAR(2);
DEFINE vsAno 					CHAR(4);
DEFINE vsSpLlamado 				CHAR(24);
DEFINE vsCveBanc 				CHAR(3);

--INICIALIZACION DE VARIABLES.
LET vsFlagTipoProceso			= '';
LET vsNomProceso				= '';
LET vsDescripcionProceso		= '';
LET sGENERANDO					= '0';
LET sFINALIZADO					= '1';
LET sERROR						= '3';
LET visqlerr					= 0;
LET vsNomArchivo				= '';
LET vsFechaPresentacion			= '';
LET vsFechaPresentacion1		= '';
LET vsFechaPresentacion2		= '';
LET vsFechaPresentacion3		= '';
LET vsCodRetorno				= '';
LET vsCodRetorno2				= '';
LET vdtFecha					= CURRENT::DATE;
LET vdtFechaInsert				= CURRENT::DATE;
LET vsMensajeRespuesta			= '';
LET viTipoArchivo				= 0;
LET vsDia						= '';
LET vsMes						= '';
LET vsAno						= '';
LET vsSpLlamado					= '';
LET vsCveBanc					= '';

--SET DEBUG FILE TO "/tmp/sp_Domi_Generador_Receptor.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET visqlerr --Control de errores.
	EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
	sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno;
	LET vsMensajeRespuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || ' PROCESO: ' || TRIM(vsDescripcionProceso) ;
	RETURN  vsNomArchivo, visqlerr, vsMensajeRespuesta;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

LET vsDescripcionProceso = 'Validacion de numero de empleado.';
EXECUTE PROCEDURE BdiDomi:Sp_Valida_Cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;

LET vsDescripcionProceso = 'Validacion de parametros.';

IF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR.
	LET vsCodRetorno = '02100';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '02') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA.
	LET vsCodRetorno = '02101';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '03') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS.
	LET vsCodRetorno = '02102';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '04') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS.
	LET vsCodRetorno = '02103';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '05') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL.
	LET vsCodRetorno = '02104';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '06') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO.
	LET vsCodRetorno = '02105';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '43') THEN -- Valida que exista el nuevo parametro BIN CORRESPONDIENTE TARJETA DEBITO.
	LET vsCodRetorno = '02105';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '07') THEN -- Valida que exista el parametro SUCURSAL CONTABLE DOMI.
	LET vsCodRetorno = '02106';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '08') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR DOMI.
	LET vsCodRetorno = '02107';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '09') THEN -- Valida que exista el parametro TRANSACCION DE ABONO.
	LET vsCodRetorno = '02108';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '10') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN.
	LET vsCodRetorno = '02109';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '11') THEN -- Valida que exista el parametro MAXIMO DE RECHAZOS PERMITIDOS.
	LET vsCodRetorno = '02110';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '12') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI.
	LET vsCodRetorno = '02111';
ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '17') THEN -- Valida que exista el parametro DIAS NATURALES PARA REVERSOS.
	LET vsCodRetorno = '02130';
--ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '13') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI.
--	LET vsCodRetorno = '02112';
ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
	LET vsCodRetorno = '02113';
ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPLEADO VACIO.
	LET vsCodRetorno = '02114';
ELIF (LENGTH(TRIM(psNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS.
	LET vsCodRetorno = '02115';
ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS.
	LET vsCodRetorno = '02116';
ELIF NOT EXISTS(SELECT ejecutivo FROM bdinteg:si_ejecut WHERE ejecutivo = psNumEmpleado)THEN --EL NUM EMPLEADO NO EXISTE EN SI_EJECUT
	LET vsCodRetorno = '02117';
ELSE
	
	--Se obtiene la fecha del dia actual.
	SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas;
	--Ya que se generara un archivo 34 se incrementa la fecha hoy en 1.
	LET vdtFecha = vdtFecha + 1;
	--Valida que la fecha actual sea dia laboral.
	EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
		--Valida si el codigo de retorno es diferente a '00000' el dia es no laboral.
		IF(vsCodRetorno <> '00000') THEN
			--El dia no es laboral.
			LET vsCodRetorno = '02112';
			--Mientras el mensaje de error indique que es un dia no laboral.
			WHILE(vsCodRetorno <> '00000')
				--Se incrementa la fecha en uno.
				LET vdtFecha = vdtFecha + 1;
				--Valida que la fecha incrementada sea un dia laboral.
				EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
			END WHILE;
		ELSE --DIA LABORAL.
			LET vsCodRetorno = '00000';
		END IF;
END IF;

--Valida si todos los parametros existen y si la fecha con la que se generara el archivo corresponde a un dia habil.
IF(vsCodRetorno = '00000')THEN
	--Se inicializa contador en cero para realizar procedimiento automatico 3 veces archivo 10,30 y 34 tambien se marca con 'A' de automatico el tipoflag.
	LET vsFlagTipoProceso = 'A';
	--Se guarda en variable la clave bancaria correspondiente con la que se generaran archivos.
	
	SELECT valor INTO vsCveBanc FROM bdidomi:dom_parametros  WHERE cod_param = '05';
	--Valida si el flagproceso sea 'A' automatico.
	IF(vsFlagTipoProceso = 'A')THEN
		LET vsDescripcionProceso = 'Obtencion de nombre de archivo';
		--Valida que el nombre del archivo se recibe en blanco.
		IF(TRIM(psNombreArchivo) = '') THEN
			--Se arma la fecha dia mes y aÃ±o para el armado completo del nombre de archivo.
			LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
			LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
			LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
			LET vsFechaPresentacion = vsAno || vsMes || vsDia;
			LET viTipoArchivo = 34;
			-- Se asigna a variable el nombre completo del archivo.
			LET vsNomArchivo = 'E' --CONSTANTE
									|| TRIM(vsCveBanc)--CONSTANTE
									|| vsDia
									|| vsMes
									|| vsAno
									|| '.' --CONSTANTE
									|| viTipoArchivo::CHAR(2)
									|| '01'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
		ELIF(TRIM(psNombreArchivo) <> '')THEN
			--Se marca el proceso como manual.
			LET vsFlagTipoProceso = 'M';
			LET vsNomArchivo = psNombreArchivo;
			LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
			LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
			LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
			LET vsFechaPresentacion = vsAno || vsMes || vsDia;
			IF( SUBSTRING (TRIM(vsNomArchivo) FROM 14 FOR 2) = '34' ) THEN --ARCHIVO 34
				LET viTipoArchivo = 34;
			--Archivo no valido.
			ELSE
				LET viTipoArchivo = 0;
			END IF;
		END IF;
		--Valida que el nombre del archivo posea la extension adecuada.
		IF (LENGTH (TRIM(vsNomArchivo)) >= 16)THEN
				LET vsNomProceso = 'GENARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(vsNomArchivo) FROM 16 FOR 2);
		--Error de longitud del archivo archivo no reconocido.
		ELSE 
				LET vsNomProceso = 'GENARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '00';
		END IF ;
		IF(vsFlagTipoProceso = 'M')THEN
		LET vsDescripcionProceso = 'Validacion nombre archivo.';
		--Valida la integridad del nombre de archivo.
			EXECUTE PROCEDURE BdiDomi:sp_domi_validarnombrearchivos(viTipoArchivo, 'E', vsNomArchivo) INTO vsCodRetorno;
		END IF;
		--Valida si el nombre del archivo fue integro.
		IF(vsCodRetorno = '00000')THEN
			LET vsDescripcionProceso = 'Validacion de generaciones previas.';
			
			IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sFINALIZADO ) THEN  --EL ARCHIVO FUE GENERADO PREVIAMENTE
				LET vsCodRetorno = '02118';
				EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
				INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Generador_Receptor', vsMensajeRespuesta, psNumEmpleado, CURRENT);
			ELIF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
				LET vsCodRetorno = '02119';
				EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
				INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Generador_Receptor', vsMensajeRespuesta, psNumEmpleado, CURRENT);
			ELIF NOT EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sERROR ) THEN  --EL ARCHIVO FUE GENERADO CON ERROR 
				--Crea registro de generacion de archivo.
				LET vsDescripcionProceso = 'Registro de generacion del archivo.';
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
				sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Generador_Receptor', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno2;
				LET vsCodRetorno = '00000';
			ELSE
				LET vsDescripcionProceso = 'Registro de regeneracion del archivo.';
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
				sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Generador_Receptor', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
				LET vsCodRetorno = '00000';
			END IF;
				IF(vsCodRetorno = '00000')THEN
					LET vsDescripcionProceso = 'Borrado de tablas de paso.';
					--Limpia las tablas de paso para generar el nuevo archivo.
					EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B') INTO vsCodRetorno;
					--Valida que las tablas se limpiaron correctamente.
					IF(vsCodRetorno = '00000')THEN
						LET vsDescripcionProceso = 'Generar informacion a tablas de paso.';
						IF(viTipoArchivo = 34)THEN
							EXECUTE PROCEDURE BdiDomi:sp_domi_generarArch34(vsNomArchivo, vsFechaPresentacion, psNumEmpleado) INTO vsCodRetorno;
							LET vsSpLlamado = 'sp_domi_generarArch34';
						END IF; 
						--Valida que se genero la informacion correctamente.
						IF(vsCodRetorno = '00000') THEN
							LET vsDescripcionProceso = 'Verificar existencia de registros.';
							IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
								IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
									IF EXISTS(SELECT nombre_arch FROM bdidomi:dom_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
										LET vsDescripcionProceso = 'Descargar archivo a repositorio.';
									
										SELECT Fecha_Presentacion INTO vsFechaPresentacion1 FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE nombre_arch = TRIM(vsNomArchivo) ;
										EXECUTE PROCEDURE BdiDomi:sp_Domi_GeneraArchivo(vsNomArchivo, vsFechaPresentacion1, '01') INTO vsCodRetorno;
										--Verifica si se genero el archivo correctamente.
										IF (vsCodRetorno = '00000')THEN
											LET vsDescripcionProceso = 'Guardar en ccearchivos.';
											EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFechaPresentacion, '01') INTO vsCodRetorno;
											--Verifica si guardo en ccearchivos correctamente.
											IF (vsCodRetorno = '00000')THEN
											
												SELECT LIMIT 1 fecha_presentacion INTO vsFechaPresentacion3 FROM dom_cce_encabezado_paso WHERE nombre_arch = vsNomArchivo;
												LET vsDescripcionProceso = 'Guardar historico.';
												EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vsFechaPresentacion1, 'T') INTO vsCodRetorno;
												--Vallida que se paso informacion a historico correctamente.
												IF (vsCodRetorno = '00000')THEN
													--Guarda bitacora exito.
													LET vsDescripcionProceso = 'Generacion de archivo exitosa.';
													EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
													sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Generador_Receptor', TRIM(vsNomArchivo) , vsFechaPresentacion, '02') INTO vsCodRetorno2;
													--Actualiza la tabla dom_reversos el campo nom_archivo_rev con el nombre de archivo que se esta generando.
													
													--Se obtiene la fecha del dia actual.
													SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas;
													LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
													LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
													LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
													LET vsFechaPresentacion2 = vsAno || vsMes || vsDia;
													UPDATE bdidomi:dom_reversos SET nom_archivo_rev = vsNomArchivo, fecha_presentacion_rev = vsFechaPresentacion3 WHERE procesado = 'S' AND fecha_presentacion = vsFechaPresentacion2;
													--Error al guardar informacion a tablas historico.
												ELSE
													LET vsCodRetorno = '02129';
													EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
													sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
												END IF;
											--Error al descargar archivo a repositorio.
											ELSE
												LET vsCodRetorno = '02128';
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_GuardarCCEArchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
											END IF;
										ELSE
											LET vsCodRetorno = '02127';
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_GeneraArchivo', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
										END IF;
									--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla sumario.
									ELSE
										LET vsCodRetorno = '02126';
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
										sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
									END IF;
								--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla detalle.
								ELSE
									LET vsCodRetorno = '02125';
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
								END IF;
							--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla encabezado.
							ELSE
								LET vsCodRetorno = '02124';
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
								sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
							END IF;
						--Error al generar informacion a tablas de paso.
						ELSE
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
							sERROR, vsCodRetorno, psNumEmpleado, vsSpLlamado, TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
							--LET vsCodRetorno = '02123';
						END IF;
					--Error al limpiar las tablas de paso.
					ELSE
						LET vsCodRetorno = '02122';
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
					END IF;
				--El archivo ya fue generado previamente o el archivo se encuentra generando.
				END IF;
		--Error al validar la integridad del nombre del archivo.
		ELSE
			LET vsCodRetorno = '02121';
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
			sERROR, vsCodRetorno, psNumEmpleado, 'sp_domi_validarnombrearchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
		END IF;
		IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
			IF(vsCodRetorno <> '02119') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'GENERANDO'
				UPDATE BdiDomi:Dom_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ;
			END IF;
		END IF;
		EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
		RETURN vsNomArchivo, vsCodRetorno, vsMensajeRespuesta WITH RESUME;
	END IF;
--Error en la validacion de parametros.
ELSE
	LET vsCodRetorno = vsCodRetorno;
	EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
	RETURN 'GENERAL', vsCodRetorno, vsMensajeRespuesta;
END IF;

END;
END PROCEDURE;