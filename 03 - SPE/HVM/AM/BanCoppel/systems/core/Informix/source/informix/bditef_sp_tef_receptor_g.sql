CREATE PROCEDURE "informix".sp_tef_receptor_g(psNombreArchivo CHAR(20),psNumEmpleado CHAR (8))

RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE TEF -- RECEPTOR GENERADOR ARCH. 63.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 16/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
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
DEFINE vsCodRetorno3 			CHAR (5);
DEFINE vdtFecha 				DATE;
DEFINE vdtFecha1 				DATE;
DEFINE vdtFechaInsert 			DATE;
DEFINE vsMensajeRespuesta 		CHAR (100);
DEFINE viTipoArchivo 			INTEGER;
DEFINE vsDia 					CHAR(2);
DEFINE vsMes 					CHAR(2);
DEFINE vsAno 					CHAR(4);
DEFINE vsSpLlamado 				CHAR(24);
DEFINE vsCveBanc 				CHAR(3);
DEFINE vdtFechaHabil			DATE;

--INICIALIZACION DE VARIABLES.
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
LET vsCodRetorno3				= '';
LET vdtFecha					= CURRENT::DATE;
LET vdtFechaInsert				= CURRENT::DATE;
LET vdtFecha1    				= CURRENT::DATE;
LET vsMensajeRespuesta			= '';
LET viTipoArchivo				= 0;
LET vsDia						= '';
LET vsMes						= '';
LET vsAno						= '';
LET vsSpLlamado					= '';
LET vsCveBanc					= '';
LET vdtFechaHabil  				= CURRENT::DATE;



--SET DEBUG FILE TO "/tmp/TEF/respuesta/sp_tef_receptor_G.out";
--TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET LOCK MODE TO WAIT 3;

BEGIN

ON EXCEPTION SET visqlerr --Control de errores.
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
	sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno;
	LET vsMensajeRespuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || ' PROCESO: ' || TRIM(vsDescripcionProceso) ;
	RETURN  vsNomArchivo, visqlerr, vsMensajeRespuesta;
END EXCEPTION;

	LET vsDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Cadena(TRIM(psNumEmpleado),'N') INTO vsCodRetorno;

	LET vsDescripcionProceso = 'Validacion de parametros.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '71') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR.
		LET vsCodRetorno = '00300';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '72') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA.
		LET vsCodRetorno = '00301';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '73') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS.
		LET vsCodRetorno = '00302';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '74') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS.
		LET vsCodRetorno = '00303';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '75') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL.
		LET vsCodRetorno = '00304';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO.
		LET vsCodRetorno = '00305';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77') THEN -- Valida que exista el parametro SUCURSAL CONTABLE TEF.
		LET vsCodRetorno = '00306';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '78') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR TEF.
		LET vsCodRetorno = '00307';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '79') THEN -- Valida que exista el parametro TRANSACCION DE ABONO.
		LET vsCodRetorno = '00308';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '80') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN.
		LET vsCodRetorno = '00309';
	ELIF(NOT EXISTS (SELECT Cve_Producto FROM BdiTef:"informix".Tef_Prod_Permitidos WHERE Cve_Producto <> '') ) THEN--Valida que existan PRODUCTOS PERMITIDOS PARA TEF.
	--ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA TEF.
		LET vsCodRetorno = '00311';
	ELIF NOT EXISTS (SELECT Valor FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '81') THEN -- Valida que exista el parametro DIAS NATURALES PARA REVERSOS.
		LET vsCodRetorno = '00330';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:"informix".Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '00313';
	ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPLEADO VACIO.
		LET vsCodRetorno = '00314';
	ELIF (LENGTH(TRIM(psNumEmpleado)) < 8 ) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS.
		LET vsCodRetorno = '00315';
	ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS.
		LET vsCodRetorno = '00316';
	ELIF NOT EXISTS(SELECT ejecutivo FROM bdinteg:si_ejecut WHERE ejecutivo = psNumEmpleado)THEN --EL NUM EMPLEADO NO EXISTE EN SI_EJECUT
		LET vsCodRetorno = '00317';
	ELSE
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Se obtiene la fecha del dia actual.
		SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:"informix".Sc_Fechas;
		--Ya que se generara un archivo 63 se incrementa la fecha hoy en 1.
	 	  LET vdtFecha1 = vdtFecha + 1;
          let vdtFecha = vdtFecha;
		--Valida que la fecha actual sea dia laboral.
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
			--Valida si el codigo de retorno es diferente a '00000' el dia es no laboral.
			IF(vsCodRetorno <> '00000') THEN
				--El dia no es laboral.
				LET vsCodRetorno = '00312';
				--Mientras el mensaje de error indique que es un dia no laboral.
				WHILE(vsCodRetorno <> '00000')
					--Se incrementa la fecha en uno.
					LET vdtFecha = vdtFecha + 1;
					--Valida que la fecha incrementada sea un dia laboral.
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
				END WHILE;
			ELSE --DIA LABORAL.
				LET vsCodRetorno = '00000';
			END IF;
		--Valida que la fecha t+1 sea dia laboral.
		EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(vdtFecha1), 4, '0') || LPAD (MONTH(vdtFecha1), 2, '0') || LPAD (DAY(vdtFecha1), 2, '0')) INTO vsCodRetorno;
			--Valida si el codigo de retorno es diferente a '00000' el dia es no laboral.
			IF(vsCodRetorno <> '00000') THEN
				--El dia no es laboral.
				LET vsCodRetorno = '00312';
				--Mientras el mensaje de error indique que es un dia no laboral.
				WHILE(vsCodRetorno <> '00000')
					--Se incrementa la fecha en uno.
					LET vdtFecha1 = vdtFecha1 + 1;
					--Valida que la fecha incrementada sea un dia laboral.
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Valida_Fecha(LPAD (YEAR(vdtFecha1), 4, '0') || LPAD (MONTH(vdtFecha1), 2, '0') || LPAD (DAY(vdtFecha1), 2, '0')) INTO vsCodRetorno;
				END WHILE;
			ELSE --DIA LABORAL.
				LET vsCodRetorno = '00000';
			END IF;
		
		IF EXISTS (SELECT fecha FROM bdinteg:"informix".si_feriado_banca WHERE fecha = vdtFecha1) THEN
			SELECT fecha_prox INTO vdtFechaHabil FROM bdinteg:"informix".si_feriado_banca WHERE fecha = vdtFecha1;
			LET vdtFecha1 = vdtFechaHabil;
		END IF;
		
	END IF;
	

	--Valida si todos los parametros existen y si la fecha con la que se generara el archivo corresponde a un dia habil.
	IF(vsCodRetorno = '00000')THEN
		--Se inicializa contador en cero para realizar procedimiento automatico  archivo 63 tambien se marca con 'A' de automatico el tipoflag.
		LET vsFlagTipoProceso = 'A';
		--Se guarda en variable la clave bancaria correspondiente con la que se generaran archivos.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT valor INTO vsCveBanc FROM BdiTef:"informix".Tef_Parametros  WHERE cod_param = '75';
		--Valida si el flagproceso sea 'A' automatico.
		IF(vsFlagTipoProceso = 'A')THEN
			LET vsDescripcionProceso = 'Obtencion de nombre de archivo';
			
			--Valida que el nombre del archivo se recibe en blanco.
			IF(TRIM(psNombreArchivo) = '') THEN
				--Se arma la fecha dia mes y año para el armado completo del nombre de archivo.
				LET vsDia = LPAD (DAY(vdtFecha1), 2, '0');
				LET vsMes = LPAD (MONTH(vdtFecha1), 2, '0');
				LET vsAno = LPAD (YEAR(vdtFecha1), 4, '0');
				--LET vsFechaPresentacion = vsAno || vsMes || vsDia;
				LET viTipoArchivo = 63;
				-- Se asigna a variable el nombre completo del archivo.
				LET vsNomArchivo = 'E' --CONSTANTE
								|| TRIM(vsCveBanc)--CONSTANTE
								|| vsDia
								|| vsMes
								|| vsAno
								|| '.' --CONSTANTE
								|| viTipoArchivo::CHAR(2)
								|| '01'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				--Se obtiene la fecha del dia actual.
				SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:"informix".Sc_Fechas;
				LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
				LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
				LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
				LET vsFechaPresentacion = vsAno || vsMes || vsDia;
								
			ELIF(TRIM(psNombreArchivo) <> '')THEN
				--Se marca el proceso como manual.
				LET vsFlagTipoProceso = 'M';
				LET vsNomArchivo = psNombreArchivo;
				SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:"informix".Sc_Fechas;
				LET vsDia = LPAD (DAY(vdtFecha), 2, '0');
				LET vsMes = LPAD (MONTH(vdtFecha), 2, '0');
				LET vsAno = LPAD (YEAR(vdtFecha), 4, '0');
				
				LET vsFechaPresentacion = vsAno || vsMes || vsDia;
				--LET vsFechaPresentacion = SUBSTR(vsNomArchivo,9,4) || SUBSTR(vsNomArchivo,7,2) || SUBSTR(vsNomArchivo,5,2) ; --AAAAMMDD
				IF( SUBSTRING (TRIM(vsNomArchivo) FROM 14 FOR 2) = '63' ) THEN --ARCHIVO 60
					LET viTipoArchivo = 63;
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
				EXECUTE PROCEDURE BdiTef:"informix".sp_tef_validarnombrearchivos(viTipoArchivo, 'E', vsNomArchivo) INTO vsCodRetorno;
			END IF;
			--Valida si el nombre del archivo fue integro.
			IF(vsCodRetorno = '00000')THEN
				LET vsDescripcionProceso = 'Validacion de generaciones previas.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sFINALIZADO ) THEN  --EL ARCHIVO FUE GENERADO PREVIAMENTE
					LET vsCodRetorno = '00318';
					EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
					INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Tef_Generador_Receptor', vsMensajeRespuesta, psNumEmpleado, CURRENT);
				ELIF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
					LET vsCodRetorno = '00319';
					EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
					INSERT INTO BdiTef:"informix".Tef_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
					VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Tef_Generador_Receptor', vsMensajeRespuesta, psNumEmpleado, CURRENT);
				ELIF NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sERROR ) THEN  --EL ARCHIVO FUE GENERADO CON ERROR 
					--Crea registro de generacion de archivo.
					LET vsDescripcionProceso = 'Registro de generacion del archivo.';
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
					sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Generador_Receptor', TRIM(vsNomArchivo), vsFechaPresentacion, '11') INTO vsCodRetorno2;
					LET vsCodRetorno = '00000';
				ELSE
					LET vsDescripcionProceso = 'Registro de regeneracion del archivo.';
					EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
					sGENERANDO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Generador_Receptor', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
					LET vsCodRetorno = '00000';
				END IF;
					IF(vsCodRetorno = '00000')THEN
						LET vsDescripcionProceso = 'Borrado de tablas de paso.';
						--Limpia las tablas de paso para generar el nuevo archivo.
						EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B', '') INTO vsCodRetorno;
						--Valida que las tablas se limpiaron correctamente.
						IF(vsCodRetorno = '00000')THEN
							LET vsDescripcionProceso = 'Generar informacion a tablas de paso.';
							IF(viTipoArchivo = 63)THEN
								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GenerarArchivo63(vsNomArchivo, vsFechaPresentacion, psNumEmpleado) INTO vsCodRetorno;
								LET vsSpLlamado = 'Sp_Tef_GenerarArchivo63';
							END IF; 
							--Valida que se genero la informacion correctamente.
							IF(vsCodRetorno = '00000') THEN
								LET vsDescripcionProceso = 'Verificar existencia de registros.';
								IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
									IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_detalle_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
										IF EXISTS(SELECT nombre_arch FROM BdiTef:"informix".Tef_cce_sumario_paso WHERE nombre_arch = TRIM(vsNomArchivo))THEN
											LET vsDescripcionProceso = 'Descargar archivo a repositorio.';
											SET LOCK MODE TO WAIT 3;
											SET ISOLATION TO DIRTY READ;
											SELECT Fecha_Presentacion INTO vsFechaPresentacion1 FROM BdiTef:"informix".Tef_cce_encabezado_paso WHERE nombre_arch = TRIM(vsNomArchivo) ;
											EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_GeneraArchivo(63, vsNomArchivo, vsFechaPresentacion1, '72') INTO vsCodRetorno;
											--Verifica si se genero el archivo correctamente.
											IF (vsCodRetorno = '00000')THEN
												LET vsDescripcionProceso = 'Guardar en ccearchivos.';
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFechaPresentacion1, '01') INTO vsCodRetorno;
												--Verifica si guardo en ccearchivos correctamente.
												IF (vsCodRetorno = '00000')THEN
													SET LOCK MODE TO WAIT 3;
													SET ISOLATION TO DIRTY READ;
													SELECT LIMIT 1 fecha_presentacion INTO vsFechaPresentacion3 FROM Tef_cce_encabezado_paso WHERE nombre_arch = vsNomArchivo;
													LET vsDescripcionProceso = 'Guardar historico.';
													EXECUTE PROCEDURE BdiTef:"informix".sp_Tef_MoverRegistrosHist (TRIM (vsNomArchivo), vsFechaPresentacion1, 'T', '02') INTO vsCodRetorno;
													--Vallida que se paso informacion a historico correctamente.
													IF (vsCodRetorno = '00000')THEN
														--Guarda bitacora exito.
														LET vsDescripcionProceso = 'Generacion de archivo exitosa.';
														EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
														sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Tef_Generador_Receptor', TRIM(vsNomArchivo) , vsFechaPresentacion, '02') INTO vsCodRetorno2;
														--Actualiza la tabla Tef_Reversos el campo nom_archivo_rev con el nombre de archivo que se esta generando.
														
													ELSE
														LET vsCodRetorno3 = vsCodRetorno;
														LET vsCodRetorno = '00329';
														EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
														sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion1, '01' ) INTO vsCodRetorno2;
													END IF;
												--Error al descargar archivo a repositorio.
												ELSE
													LET vsCodRetorno3 = vsCodRetorno;
													LET vsCodRetorno = '00328';
													EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
													sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Tef_GuardarCCEArchivos', TRIM(vsNomArchivo) , vsFechaPresentacion1, '01' ) INTO vsCodRetorno2;
												END IF;
											ELSE
												LET vsCodRetorno3 = vsCodRetorno;
												LET vsCodRetorno = '00327';
												EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_GeneraArchivo', TRIM(vsNomArchivo) , vsFechaPresentacion1, '01' ) INTO vsCodRetorno2;
											END IF;
										--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla sumario.
										ELSE
											LET vsCodRetorno3 = vsCodRetorno;
											LET vsCodRetorno = '00326';
											EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
										END IF;
									--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla detalle.
									ELSE
										LET vsCodRetorno3 = vsCodRetorno;
										LET vsCodRetorno = '00325';
										EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
										sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
									END IF;
								--No se puede descargar el archivo por que no existen registros para el nombre de archivo indicado en tabla encabezado.
								ELSE
									LET vsCodRetorno3 = vsCodRetorno;
									LET vsCodRetorno = '00324';
									EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, '', TRIM(vsNomArchivo) , vsFechaPresentacion, '11' ) INTO vsCodRetorno2;
								END IF;
							--Error al generar informacion a tablas de paso.
							ELSE
								EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
								sERROR, vsCodRetorno, psNumEmpleado, vsSpLlamado, TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
								--LET vsCodRetorno = '00323';
							END IF;
						--Error al limpiar las tablas de paso.
						ELSE
							LET vsCodRetorno3 = vsCodRetorno;
							LET vsCodRetorno = '00322';
							EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
							sERROR, vsCodRetorno, psNumEmpleado, 'sp_Tef_MoverRegistrosHist', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
						END IF;
					--El archivo ya fue generado previamente o el archivo se encuentra generando.
					END IF;
			--Error al validar la integridad del nombre del archivo.
			ELSE
				LET vsCodRetorno3 = vsCodRetorno;
				LET vsCodRetorno = '00321';
				EXECUTE PROCEDURE BdiTef:"informix".Sp_Tef_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
				sERROR, vsCodRetorno, psNumEmpleado, 'sp_tef_validarnombrearchivos', TRIM(vsNomArchivo) , vsFechaPresentacion, '01' ) INTO vsCodRetorno2;
			END IF;
			IF EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ) THEN  --EL ARCHIVO SE ENCUENTRA GENERANDO
				IF(vsCodRetorno <> '00319') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'GENERANDO'
					UPDATE BdiTef:"informix".Tef_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sGENERANDO ;
				END IF;
			END IF;
			EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
			--RETURN vsNomArchivo, vsCodRetorno, vsMensajeRespuesta WITH RESUME;
			RETURN vsNomArchivo, vsCodRetorno, (TRIM(vsMensajeRespuesta) || DECODE (vsCodRetorno3, '00000', '', ' (' || vsCodRetorno3 || ')') ) WITH RESUME;
		END IF;
	--Error en la validacion de parametros.
	ELSE
		
		LET vsCodRetorno = vsCodRetorno;
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensajeRespuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensajeRespuesta;
	END IF;
	
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SP PRINCIPAL DE TEF -- RECEPTOR GENERADOR ARCH. 63.',
'Fecha: 2011/03/16',
'Version: 20110316.1020',
'BD: BdiTef';

CREATE PROCEDURE "informix".cons_img_nula1_mx2(pempresa       CHAR(3),
                                          pcvebanco   	 CHAR(3),
                                          pnumcuenta   	 CHAR(20),
                                          pnumcheque   	 CHAR(7),
                                          plado_ft       CHAR(1),
                                          pfechapresenta CHAR(10))
RETURNING CHAR(5);  

    DEFINE v_codret CHAR(5);
    DEFINE sql_err,isam_err INT;   
    --DEFINE v_existe CHAR(1);
	DEFINE iimagen  INT;

    -- // Inicializa variables
    LET v_codret    = "000";
    --LET v_existe    = "0";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  IS NULL OR
       pcvebanco      IS NULL OR
       pnumcuenta     IS NULL OR
       pnumcheque     IS NULL OR
       plado_ft       IS NULL OR
       pfechapresenta IS NULL THEN
        LET v_codret = 110; -- // datos de entrada incompletos
        RETURN v_codret; 
    END IF;
	
	--SET DEBUG FILE TO "/tmp/Guicho/cons_img_nula1.out";
	--TRACE ON;
    
    BEGIN

		ON EXCEPTION SET sql_err,isam_err
			if sql_err <> 0 OR isam_err <> 0 THEN
				let v_codret = sql_err;
				RETURN v_codret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
		SELECT COUNT(*)
		INTO iimagen
		FROM "informix".cce_cheques_img
		WHERE empresa = pempresa
		AND cvebanco = pcvebanco
		AND numcuenta = pnumcuenta
		AND numcheque = pnumcheque
		AND fechapresenta = pfechapresenta
		--AND imagen IS NULL OR length(imagen::lvarchar) =0;
		AND (imagen IS NULL OR length(imagen::lvarchar) =0);

		IF iimagen > 0 THEN
			LET v_codret = 130; 
			RETURN v_codret;  
        END IF;	
    
    END;    

    RETURN v_codret;

END PROCEDURE
DOCUMENT
'FECHA: 30/11/2017',
'AUTOR: Jesus Ivan Garcia Guicho.',
'FOLIO: 1856',
'SUSTENTO: INC 24 066 Cheque en blanco.pdf.',
'SOLICITA: Cutberto Gonzalez Perez.',
'DESCRIPCION: Se modifica nombre del SP para ponerlo en pruebas en piloto.',
'BD: bditef';

CREATE PROCEDURE "informix".sp_tef_subirarchivos(psTipo CHAR(1), psCodRuta CHAR(2), psNombreArchivo VARCHAR(20), psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet, VARCHAR(115) AS DESCRIPCION;

--****************************************************************************************************
-- DESCRIPCION:  PROCEDIMIENTO PARA REALIZAR LA CARGA DE LOS ARCHIVOS QUE SE RECIBEN A LAS TABLAS DE INFORMIX.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 10/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

---DECLARACIONES
DEFINE vsCodRef                   CHAR(5);
DEFINE iSqlErr                    INTEGER;
DEFINE iSamErr                    INTEGER;

DEFINE sDescMensajeError	      VARCHAR(95);
DEFINE vsRuta				      CHAR(100);
DEFINE sCadSql				      LVARCHAR(1000);
DEFINE sLinea				      LVARCHAR(500);

--- VARIABLES PARA EL ENCABEZADO
DEFINE sEncTipoReg				  CHAR(2);
DEFINE sEncNumSec				  CHAR(7);
DEFINE sEncCodOper				  CHAR(2);
DEFINE sEncBanco				  CHAR(3);
DEFINE sEncSentido				  CHAR(1);
DEFINE sEncServicio				  CHAR(1);
DEFINE sEncNumBloque			  CHAR(7);
DEFINE sEncFechaPres			  CHAR(8);
DEFINE sEncCodDivisa			  CHAR(2);
DEFINE sEncCausaRechazo			  CHAR(2);
DEFINE sEncModalidad			  CHAR(1);
DEFINE sEncUsoFuturoCCEN		  CHAR(41);
DEFINE sEncUsoFuturoBANCO		  CHAR(370);

--- VARIABLE PARA EL DETALLE
DEFINE sDetTipoReg				  CHAR(2);
DEFINE sDetNumSec				  CHAR(7);
DEFINE sDetCodOper				  CHAR(2);
DEFINE sDetCodDivisa			  CHAR(2);
DEFINE SDetFechaTrans			  CHAR(8);
DEFINE sDetBancoPres			  CHAR(3);
DEFINE sDetBancoRec				  CHAR(3);
DEFINE sDetImpOperacion			  CHAR(15);
DEFINE sDetUsoFuturoCCEN		  CHAR(16);
DEFINE sDetTipoOperacion		  CHAR(2);
DEFINE sDetFechaApli			  CHAR(8);
DEFINE sDetTipoCtaOrdenante		  CHAR(2);
DEFINE sDetNumCtaOrdenante		  CHAR(20);
DEFINE sDetNombreOrdenante		  CHAR(40);
DEFINE sDetRFCCURPOrdenante		  CHAR(18);
DEFINE sDetTipoCtaReceptor		  CHAR(2);
DEFINE sDetNumCtaReceptor		  CHAR(20);
DEFINE sDetNombreReceptor		  CHAR(40);
DEFINE sDetRFCCURPReceptor		  CHAR(18);
DEFINE sDetRefServEmisor		  CHAR(40);
DEFINE sDetNomTitularServ		  CHAR(40);
DEFINE sDetImpIvaOperacion		  CHAR(15);
DEFINE sDetRefNumOrdenante		  CHAR(7);
DEFINE sDetRefLeyendaOrdenante    CHAR(40);
DEFINE sDetClaveRastreo			  CHAR(30);
DEFINE sDetMotivoDev			  CHAR(2);
DEFINE sDetFecPresInicial	  	  CHAR(8);
DEFINE sDetUsoFuturoBanco		  CHAR(12);

DEFINE sDetSolicitud_Confirmacion CHAR(1);
DEFINE sDetRef_Confirmacion       CHAR(30);
DEFINE sDetUsoFuturoCce           CHAR(1);
DEFINE sDetTasa_Tiie_Prom         CHAR(7);
DEFINE sDetDias_Retraso           CHAR(3);
DEFINE sDetImp_Tot_Int            CHAR(15);

--- VARIABLES PARA EL SUMARIO
DEFINE sSumTipoReg				  CHAR(2);
DEFINE sSumNumSec				  CHAR(7);
DEFINE sSumCodOper				  CHAR(2);
DEFINE sSumNumBloque			  CHAR(7);
DEFINE sSumNumOper				  CHAR(7);
DEFINE sSumImpTotOper			  CHAR(18);
DEFINE sSumUsoFuturoCCEN		  CHAR(40);
DEFINE sSumUsoFuturoBanco		  CHAR(364);

DEFINE bBandArchivo				  BOOLEAN;
DEFINE iNumCaracteres			  INTEGER;
DEFINE iContador				  SMALLINT;
DEFINE iNumReg					  INTEGER;
DEFINE cHora                      CHAR(8);
DEFINE cFechaArchivoOUT			  CHAR(15);
DEFINE iTemporales		 SMALLINT;
DEFINE iPaso			 SMALLINT;
DEFINE cMensaje			 CHAR(40);


---INICIALIZACIONES
LET vsCodRef 					  = '00000';
LET vsRuta						  = "";
LET sLinea						  = "";
LET sDescMensajeError			  = "";

--- INICIALIZACIONES PARA EL ENCABEZADO
LET sEncTipoReg					  = "";
LET sEncNumSec					  = "";
LET sEncCodOper					  = "";
LET sEncBanco					  = "";
LET sEncSentido					  = "";
LET sEncServicio				  = "";
LET sEncNumBloque				  = "";
LET sEncFechaPres				  = "";
LET sEncCodDivisa				  = "";
LET sEncCausaRechazo			  = "";
LET sEncModalidad				  = "";
LET sEncUsoFuturoCCEN			  = "";
LET sEncUsoFuturoBANCO			  = "";

--- INICIALIZACIONES PARA EL DETALLE
LET sDetTipoReg					  = "";
LET sDetNumSec					  = "";
LET sDetCodOper					  = "";
LET sDetCodDivisa				  = "";
LET SDetFechaTrans				  = "";
LET sDetBancoPres				  = "";
LET sDetBancoRec				  = "";
LET sDetImpOperacion			  = "";
LET sDetUsoFuturoCCEN			  = "";
LET sDetTipoOperacion			  = "";
LET sDetFechaApli				  = "";
LET sDetTipoCtaOrdenante		  = "";
LET sDetNumCtaOrdenante			  = "";
LET sDetNombreOrdenante			  = "";
LET sDetRFCCURPOrdenante		  = "";
LET sDetTipoCtaReceptor			  = "";
LET sDetNumCtaReceptor			  = "";
LET sDetNombreReceptor			  = "";
LET sDetRFCCURPReceptor			  = "";
LET sDetRefServEmisor			  = "";
LET sDetNomTitularServ			  = "";
LET sDetImpIvaOperacion			  = "";
LET sDetRefNumOrdenante			  = "";
LET sDetRefLeyendaOrdenante  	  = "";
LET sDetClaveRastreo			  = "";
LET sDetMotivoDev				  = "";
LET sDetFecPresInicial			  = "";
LET sDetUsoFuturoBanco			  = "";

LET sDetSolicitud_Confirmacion    = '';
LET sDetRef_Confirmacion          = '';
LET sDetUsoFuturoCce              = '';
LET sDetTasa_Tiie_Prom            = '';
LET sDetDias_Retraso              = '';
LET sDetImp_Tot_Int               = '';


--- INICIALIZACIONES PARA EL SUMARIO
LET sSumTipoReg					  = "";
LET sSumNumSec					  = "";
LET sSumCodOper					  = "";
LET sSumNumBloque				  = "";
LET sSumNumOper					  = "";
LET sSumImpTotOper				  = "";
LET sSumUsoFuturoCCEN			  = "";
LET sSumUsoFuturoBanco			  = "";

LET bBandArchivo				  = "f";
LET iNumCaracteres				  = 0;
LET iContador					  = 0;
LET iNumReg						  = 0;
LET cHora                         = TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
LET cFechaArchivoOUT              = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_';
LET iTemporales			= 0;
LET iPaso				= 0;
LET cMensaje			= 'ERROR EN PASO: ';

--SET DEBUG FILE TO "/home/systef/procesar/sp_tef_subirarchivos.out";
--TRACE ON;

BEGIN
ON EXCEPTION
	SET iSqlErr, iSamErr
	IF iSqlErr <> 0 THEN
	
	INSERT INTO tef_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
		VALUES(CURRENT, CURRENT HOUR TO FRACTION, iSqlErr, psNombreArchivo, 'sp_tef_subirarchivos', cMensaje||iPaso, USER, CURRENT);
	
		LET vsCodRef = iSqlErr;
	END IF;

	RETURN vsCodRef, NULL;
END EXCEPTION;

ON EXCEPTION IN(-668) SET iSqlErr

	INSERT INTO tef_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
		VALUES(CURRENT, CURRENT HOUR TO FRACTION, iSqlErr, psNombreArchivo, 'sp_tef_subirarchivos', cMensaje||iPaso, USER, CURRENT);
		
	IF iTemporales = 1 AND iPaso <> 2 THEN 
		LET vsCodRef = iSqlErr;
		RETURN vsCodRef,NULL;
	END IF;
END EXCEPTION WITH RESUME;


	--- VALIDA QUE SEA UNA TIPO DE OPERACION AUTOMATICA O MANUAL
	IF UPPER(psTipo) NOT IN ("A","M") THEN
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02400") INTO vsCodRef, sDescMensajeError;
		RETURN vsCodRef, sDescMensajeError;
	END IF
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--- OBTIENE LA RUTA DONDE SE ENCUENTRA EL ARCHIVO
	SELECT FIRST 1 TRIM(valor) INTO vsRuta FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = psCodRuta;
	
	
	IF (NVL(vsRuta, '') = '') THEN --valida ke la ruta contenga info
		EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02401") INTO vsCodRef, sDescMensajeError;
		RETURN vsCodRef, sDescMensajeError;
	END IF

	--- PARA UNA OPERACION AUTOMATICA
	IF UPPER(psTipo) = "A" THEN
		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tef_tmp_trabajo_aut') THEN
			DROP TABLE "informix".tef_tmp_trabajo_aut;
		END IF

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE "informix".tef_tmp_trabajo_aut
		(linea LVARCHAR(500));

		--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
		LET iPaso = 1;
		LET sCadSql = 'ls ' || TRIM(vsRuta) || ' > ' || TRIM(vsRuta) || 'carpeta.car ';
		SYSTEM sCadSql;
		LET iTemporales = 1;
				
        --- SE LE ASIGNA PERMISOS AL ARCHIVO CARPETA.CAR
		LET iPaso = 2;
        LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) || 'carpeta.car';
		SYSTEM sCadSql ;
		
		LET iPaso = 3;
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(vsRuta) || 'carpeta.car' || ' INSERT INTO tef_tmp_trabajo_aut" > '|| TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
		SYSTEM sCadSql;
		
		LET iPaso = 4;
        LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
		SYSTEM sCadSql ;
		
		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		--- PRODUCCION
		LET iPaso = 5;
		LET sCadSql = '/ifxsif01/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
		
		--DESARROLLO
		--LET sCadSql = '/informix/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
		SYSTEM sCadSql;
		
		LET iPaso = 6;
        LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
		SYSTEM sCadSql ;
				
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea
			INTO sLinea
			FROM  "informix".tef_tmp_trabajo_aut

			IF sLinea = psNombreArchivo THEN
				LET bBandArchivo = "t";
				EXIT FOREACH;
			END IF

		END FOREACH

		--- BORRAR LA TABLA PARA VOLVER A USARLA
		TRUNCATE TABLE "informix".tef_tmp_trabajo_aut;
		
		--- BORRA EL ARCHIVO CARPETA.CAR
		LET iPaso = 7;
		LET sCadSql = 'rm ' || TRIM(vsRuta) || 'carpeta.car';
		SYSTEM sCadSql;
		
		--- BORRA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.SQL
		LET iPaso = 8;
		LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
		SYSTEM sCadSql;
		
		--- BORA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.out
		LET iPaso = 9;
		LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
		SYSTEM sCadSql;

		--- VALIDA QUE EL ARCHIVO EXISTA
		IF bBandArchivo = "f" THEN
			EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02402") INTO vsCodRef, sDescMensajeError;
			RETURN vsCodRef, sDescMensajeError;
		ELSE
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET iPaso = 10;
			LET sCadSql = 'echo "LOAD FROM ' || TRIM(vsRuta) || psNombreArchivo || ' INSERT INTO tef_tmp_trabajo_aut" > '|| TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
			SYSTEM sCadSql;
			
			LET iPaso = 11;
			LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
			SYSTEM sCadSql ;
			
			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			LET iPaso = 12;
			--PRODUCCION
			LET sCadSql = '/ifxsif01/bin/dbaccess bditef ' ||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
			
			--DESARROLLO
		    --LET sCadSql = '/informix/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
		    SYSTEM sCadSql;

			LET iPaso = 13;
			LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
			SYSTEM sCadSql ;
			
			--- BORRA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.SQL
			LET iPaso = 14;
			LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
			SYSTEM sCadSql;
			
			--- BORA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.out
			LET iPaso = 15;
			LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
			SYSTEM sCadSql;
			
			FOREACH
				--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
				SELECT DISTINCT LENGTH(REPLACE(linea," ","*"))
				INTO iNumCaracteres
				FROM "informix".tef_tmp_trabajo_aut

				LET iContador = iContador + 1;
			END FOREACH
			--- VALIDA QUE NO EXISTAN DIFERENTES LONGITUDES EN LA TABLA
			IF (iContador > 1) THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02403") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			--- VALLIDA QUE SI EXISTE EL MISMO NUMERO DE CARACTERES POR LINEA ESTE SEA EL ADECUADO
			ELIF iContador = 1 AND iNumCaracteres NOT IN (422,442,447,423,443,448)  THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02403") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF
				
			IF (iNumCaracteres IN (423,443,448)) THEN --RESTAR 1
				LET iNumCaracteres = iNumCaracteres - 1;
			END IF;
				
			--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
			IF EXISTS(SELECT linea FROM BdiTef:"informix".tef_tmp_trabajo_aut WHERE SUBSTR(linea,1,2) NOT IN ("01","02","09")) THEN
				SELECT descripcion
				INTO sDescMensajeError
				FROM BdiTef:"informix".Tef_Cat_Rechazos
				WHERE cve_rechazo::SMALLINT = 28;

				LET vsCodRef = "02404";

				RETURN vsCodRef, sDescMensajeError;
			END IF;

			LET iNumReg		= 0;
			
			--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  "informix".tef_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "01";

			IF iNumReg = 0 THEN --NO SE ENCONTRO REGISTRO DE ENCABEZADO
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02405") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			ELIF iNumReg > 1 THEN -- MAS DE UN REGISTRO DE ENCABEZADO
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02406") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF;

			LET iNumReg		= 0;
			
			--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  "informix".tef_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "09";

			IF iNumReg = 0 THEN --NO SE ENCONTRO REGISTRO DE SUMARIO
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02407") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			ELIF iNumReg > 1 THEN -- MAS DE UN REGISTRO DE SUMARIO
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02408") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  "informix".tef_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "02";

			IF iNumReg = 0 THEN -- NO SE ENCONTRARON REGISTROS DE DETALLE
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02409") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tef_tmp_secuencia_aut') THEN
				DROP TABLE "informix".tef_tmp_secuencia_aut;
			END IF

			--- CREAR LA TABLA DE TRABAJO
			CREATE TABLE "informix".tef_tmp_secuencia_aut
			(secuencia CHAR(7));

			INSERT INTO "informix".tef_tmp_secuencia_aut
			SELECT  SUBSTR(linea,3,7) AS SECUENCIA
			FROM  BdiTef:"informix".tef_tmp_trabajo_aut
			WHERE SUBSTR(linea,1,2) = "02";
			
			---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
			IF EXISTS(SELECT SECUENCIA FROM "informix".tef_tmp_secuencia_aut GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02410") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT linea
				INTO sLinea
				FROM "informix".tef_tmp_trabajo_aut

				IF SUBSTR(sLinea,1,2) = "01" THEN --- ASIGNACIONES PARA ENCABEZADO
					LET sEncTipoReg					= SUBSTR(sLinea,1,2);
					LET sEncNumSec					= SUBSTR(sLinea,3,7);
					LET sEncCodOper					= SUBSTR(sLinea,10,2);
					LET sEncBanco					= SUBSTR(sLinea,12,3);
					LET sEncSentido					= SUBSTR(sLinea,15,1);
					LET sEncServicio				= SUBSTR(sLinea,16,1);
					LET sEncNumBloque				= SUBSTR(sLinea,17,7);
					LET sEncFechaPres				= SUBSTR(sLinea,24,8);
					LET sEncCodDivisa				= SUBSTR(sLinea,32,2);
					LET sEncCausaRechazo			= SUBSTR(sLinea,34,2);
					LET sEncModalidad				= SUBSTR(sLinea,36,1);
					LET sEncUsoFuturoCCEN			= SUBSTR(sLinea,37,41);
					IF (iNumCaracteres = 422) THEN --ARCHIVO  60 - 61
						LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,345);
					ELIF (iNumCaracteres = 442) THEN --ARCHIVO  62
						LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,365);
					ELIF (iNumCaracteres = 447) THEN --ARCHIVO  63
						LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,370);
					END IF;
					
					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO BdiTef:"informix".tef_cce_encabezado_paso (nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio
														,num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (psNombreArchivo,sEncFechaPres,sEncTipoReg,sEncNumSec,sEncCodOper,sEncBanco,sEncSentido,sEncServicio,sEncNumBloque
							,sEncCodDivisa,sEncCausaRechazo,sEncModalidad,sEncUsoFuturoCCEN,sEncUsoFuturoBANCO,psUsuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "02" THEN --- ASIGNACIONES PARA DETALLE
					LET sDetTipoReg					= SUBSTR(sLinea,1,2);
					LET sDetNumSec					= SUBSTR(sLinea,3,7);
					LET sDetCodOper					= SUBSTR(sLinea,10,2);
					LET sDetCodDivisa				= SUBSTR(sLinea,12,2);
					LET SDetFechaTrans				= SUBSTR(sLinea,14,8);
					LET sDetBancoPres				= SUBSTR(sLinea,22,3);
					LET sDetBancoRec				= SUBSTR(sLinea,25,3);
					LET sDetImpOperacion			= SUBSTR(sLinea,28,15);
					LET sDetUsoFuturoCCEN			= SUBSTR(sLinea,43,16);
					LET sDetTipoOperacion			= SUBSTR(sLinea,59,2);
					LET sDetFechaApli				= SUBSTR(sLinea,61,8);
					LET sDetTipoCtaOrdenante		= SUBSTR(sLinea,69,2);
					LET sDetNumCtaOrdenante			= SUBSTR(sLinea,71,20);
					LET sDetNombreOrdenante			= SUBSTR(sLinea,91,40);
					LET sDetRFCCURPOrdenante		= SUBSTR(sLinea,131,18);
					LET sDetTipoCtaReceptor			= SUBSTR(sLinea,149,2);
					LET sDetNumCtaReceptor			= SUBSTR(sLinea,151,20);
					LET sDetNombreReceptor			= SUBSTR(sLinea,171,40);
					LET sDetRFCCURPReceptor			= SUBSTR(sLinea,211,18);
					LET sDetRefServEmisor			= SUBSTR(sLinea,229,40);
					LET sDetNomTitularServ			= SUBSTR(sLinea,269,40);
					LET sDetImpIvaOperacion			= SUBSTR(sLinea,309,15);
					LET sDetRefNumOrdenante			= SUBSTR(sLinea,324,7);
					LET sDetRefLeyendaOrdenante  	= SUBSTR(sLinea,331,40);
					LET sDetClaveRastreo			= SUBSTR(sLinea,371,30);
					LET sDetMotivoDev				= SUBSTR(sLinea,401,2);
					LET sDetFecPresInicial			= SUBSTR(sLinea,403,8);
					LET sDetSolicitud_Confirmacion 	= SUBSTR(sLinea,411,1);									
					
					IF (iNumCaracteres = 422) THEN --ARCHIVO  60 - 61
						LET sDetUsoFuturoBanco			= SUBSTR(sLinea,412,11);
						LET sDetRef_Confirmacion 		= '';
						LET sDetUsoFuturoCce 			= '';
						LET sDetTasa_Tiie_Prom 			= '';
						LET sDetDias_Retraso 			= '';
						LET sDetImp_Tot_Int 			= '';
					ELIF (iNumCaracteres = 442) THEN --ARCHIVO  62
						LET sDetUsoFuturoBanco			= '';
						LET sDetRef_Confirmacion 		= SUBSTR(sLinea,412,30);
						LET sDetUsoFuturoCce 			= SUBSTR(sLinea,442,1);
						LET sDetTasa_Tiie_Prom 			= '';
						LET sDetDias_Retraso 			= '';
						LET sDetImp_Tot_Int 			= '';
					ELIF (iNumCaracteres = 447) THEN --ARCHIVO  63
						LET sDetUsoFuturoBanco			= SUBSTR(sLinea,412,11);
						LET sDetRef_Confirmacion 		= '';
						LET sDetUsoFuturoCce 			= '';
						LET sDetTasa_Tiie_Prom 			= SUBSTR(sLinea,423,7);
						LET sDetDias_Retraso 			= SUBSTR(sLinea,430,3);
						LET sDetImp_Tot_Int 			= SUBSTR(sLinea,433,15);
					END IF;
					
					
					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO BdiTef:"informix".tef_cce_detalle_paso(nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,fecha_trans,banco_presentador,
													banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,nombre_ord,rfc_ord,
													tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,ref_leyenda,
													clave_rastreo,motivo_dev, fecha_pres_ini,
													Solicitud_Confirmacion, uso_futuro_banco,Ref_Confirmacion, 
													Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int, 
													cve_Status,folio_suc,user_insert,fecha_insert)
													
					VALUES (psNombreArchivo,sEncFechaPres,sDetTipoReg,sDetNumSec,sDetCodOper,sDetCodDivisa,SDetFechaTrans,sDetBancoPres,sDetBancoRec,sDetImpOperacion,sDetUsoFuturoCCEN,
							sDetTipoOperacion,sDetFechaApli,sDetTipoCtaOrdenante,sDetNumCtaOrdenante,sDetNombreOrdenante,sDetRFCCURPOrdenante,sDetTipoCtaReceptor,
							sDetNumCtaReceptor,sDetNombreReceptor,sDetRFCCURPReceptor,sDetRefServEmisor,sDetNomTitularServ,sDetImpIvaOperacion,sDetRefNumOrdenante,
							sDetRefLeyendaOrdenante,sDetClaveRastreo,sDetMotivoDev,sDetFecPresInicial, 
							sDetSolicitud_Confirmacion, sDetUsoFuturoBanco, sDetRef_Confirmacion, 
							sDetUsoFuturoCce, sDetTasa_Tiie_Prom, sDetDias_Retraso, sDetImp_Tot_Int, 
							"00","",psUsuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "09" THEN--- ASIGNACIONES PARA SUMARIO
					LET sSumTipoReg					= SUBSTR(sLinea,1,2);
					LET sSumNumSec					= SUBSTR(sLinea,3,7);
					LET sSumCodOper					= SUBSTR(sLinea,10,2);
					LET sSumNumBloque				= SUBSTR(sLinea,12,7);
					LET sSumNumOper					= SUBSTR(sLinea,19,7);
					LET sSumImpTotOper				= SUBSTR(sLinea,26,18);
					LET sSumUsoFuturoCCEN			= SUBSTR(sLinea,44,40);
					
					IF (iNumCaracteres = 422) THEN --ARCHIVO  60 - 61
						LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,339);
					ELIF (iNumCaracteres = 442) THEN --ARCHIVO  62
						LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,365);
					ELIF (iNumCaracteres = 447) THEN --ARCHIVO  63
						LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,370);
					END IF;

					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO BdiTef:"informix".tef_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,num_bloque,num_operaciones
													,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (psNombreArchivo,sEncFechaPres,sSumTipoReg,sSumNumSec,sSumCodOper,sSumNumBloque,sSumNumOper,sSumImpTotOper
							,sSumUsoFuturoCCEN,sSumUsoFuturoBanco,psUsuario,CURRENT);
				END IF
			END FOREACH
		END IF
	--- PARA UNA OPERACION MANUAL

	ELIF UPPER(psTipo) = "M" THEN
		--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tef_tmp_trabajo_man') THEN
			DROP TABLE "informix".tef_tmp_trabajo_man;
		END IF

		--- CREAR LA TABLA DE TRABAJO
		CREATE TABLE "informix".tef_tmp_trabajo_man
		(linea LVARCHAR(500));

		--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
		LET iPaso = 16;
		LET sCadSql = 'ls ' || TRIM(vsRuta) || ' > ' || TRIM(vsRuta) || 'carpeta.car';
		SYSTEM sCadSql;
		LET iTemporales = 1;		
		
		--- SE LE ASIGNA PERMISOS AL ARCHIVO CARPETA.CAR
		LET iPaso = 17;
        LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) || 'carpeta.car';
		SYSTEM sCadSql;
		
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET iPaso = 18;
		LET sCadSql = 'echo "LOAD FROM ' || TRIM(vsRuta) || 'carpeta.car' || ' INSERT INTO tef_tmp_trabajo_man" > '|| TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
		SYSTEM sCadSql;
		
		LET iPaso = 19;
		LET sCadSql = 'chmod 777 ' || TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
		SYSTEM sCadSql;

		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		--PRODUCCION
		LET iPaso = 20;
		LET sCadSql = '/ifxsif01/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
		
		--DESARROLLO
		--LET sCadSql = '/informix/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
		SYSTEM sCadSql;
		
		LET iPaso = 21;
		LET sCadSql = 'chmod 777 ' || TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
		SYSTEM sCadSql;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea
			INTO sLinea
			FROM  "informix".tef_tmp_trabajo_man

			IF sLinea = psNombreArchivo THEN
				LET bBandArchivo = "t";
				EXIT FOREACH;
			END IF

		END FOREACH

		--- BORRAR LA TABLA PARA VOLVER A USARLA
		TRUNCATE TABLE "informix".tef_tmp_trabajo_man;
		
		--Se crea respaldo del archivo a procesar
	    LET iPaso = 22;
		LET sCadSql = 'cp ' || TRIM(vsRuta) || psNombreArchivo  ||' '|| TRIM(vsRuta)|| psNombreArchivo  ||'.resp';
		SYSTEM sCadSql;

		LET iPaso = 23;
		LET sCadSql = 'rm ' || TRIM(vsRuta) || psNombreArchivo;
		SYSTEM sCadSql;
			
		-- SE REEMPLAZA DIAGONAL
		LET iPaso = 24;
		--LET sCadSql = 'grep -lr -e "1" ' || TRIM(vsRuta) || psNombreArchivo  ||'.resp | xargs sed ''s/\\/\\\\/g'' > '|| TRIM(vsRuta)|| psNombreArchivo;
		LET sCadSql = 'grep -lr -e "1" ' || TRIM(vsRuta) || psNombreArchivo  ||'.resp | xargs sed ''s/\\\\/\\/g;s/\\/\\\\/g'' > '|| TRIM(vsRuta)|| psNombreArchivo;
		SYSTEM sCadSql;
		-- BORRA EL ARCHIVO .RESP
		LET iPaso = 25;
		LET sCadSql = 'rm '|| TRIM(vsRuta) || TRIM (psNombreArchivo)  ||'.resp';
		SYSTEM sCadSql;
					
		--- BORRA EL ARCHIVO CARPETA.CAR
		LET iPaso = 26;
		LET sCadSql = 'rm ' || TRIM(vsRuta) || 'carpeta.car';
		SYSTEM sCadSql;
		
		--- BORRA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.SQL
		LET iPaso = 27;
		LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
		SYSTEM sCadSql;
		
		--- BORA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.out
		LET iPaso = 28;
		LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
		SYSTEM sCadSql;

		--- VALIDA QUE EL ARCHIVO EXISTA
		IF bBandArchivo = "f" THEN
			EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02402") INTO vsCodRef, sDescMensajeError;
			RETURN vsCodRef, sDescMensajeError;
		ELSE
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET iPaso = 29;
			LET sCadSql = 'echo "LOAD FROM ' || TRIM(vsRuta) || psNombreArchivo || ' INSERT INTO tef_tmp_trabajo_man" > '|| TRIM(vsRuta) || TRIM(cFechaArchivoOUT)|| 'EjecutaCarga_sp_Tef_SubirArchivos.sql';
			SYSTEM sCadSql;

			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			--PRODUCCION
			LET iPaso = 30;
			LET sCadSql = '/ifxsif01/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
			
			--DESARROLLO
		    --LET sCadSql = '/informix/bin/dbaccess bditef ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql > '||TRIM(vsRuta)||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out 2>&1';
		    SYSTEM sCadSql;
			
			LET iPaso = 31;
			LET sCadSql = 'chmod 777 ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
			SYSTEM sCadSql ;
			
			--- BORRA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.SQL
			LET iPaso = 32;
			LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.sql';
			SYSTEM sCadSql;
			
			--- BORA EL ARCHIVO EJECUTACARGA_SP_TEF_SUBIRARCHIVOS.out
			LET iPaso = 33;
			LET sCadSql = 'rm ' || TRIM(vsRuta) ||TRIM(cFechaArchivoOUT)||'EjecutaCarga_sp_Tef_SubirArchivos.out';
			SYSTEM sCadSql;

			LET iContador = 0;

			FOREACH
				--- CUENTA LA LONGITUD DE CARACTERES DE LAS CADENAS EN LA TABLA
				SELECT DISTINCT LENGTH(REPLACE(linea," ","*"))
				INTO iNumCaracteres
				FROM "informix".tef_tmp_trabajo_man

				LET iContador = iContador + 1;
			END FOREACH
			--- VALIDA QUE NO EXISTAN DIFERENTES LONGITUDES EN LA TABLA
			IF iContador > 1 THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02403") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			--- VALLIDA QUE SI EXISTE EL MISMO NUMERO DE CARACTERES POR LINEA ESTE SEA EL ADECUADO
			ELIF iContador = 1 AND iNumCaracteres NOT IN (422,442,447,423,443,448) THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02403") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  "informix".tef_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "01";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02405") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			ELIF iNumReg > 1 THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02406") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  "informix".tef_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "09";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02407") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			ELIF iNumReg > 1 THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02408") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
			IF EXISTS(SELECT linea FROM BdiTef:"informix".tef_tmp_trabajo_man WHERE SUBSTR(linea,1,2) NOT IN ("01","02","09")) THEN
				SELECT descripcion
				INTO sDescMensajeError
				FROM BdiTef:"informix".Tef_Cat_Rechazos
				WHERE cve_rechazo::SMALLINT = 28;

				LET vsCodRef = "02404";

				RETURN vsCodRef, sDescMensajeError;
			END IF

			LET iNumReg		= 0;
			--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
			SELECT COUNT(*)::INTEGER
			INTO iNumReg
			FROM  "informix".tef_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "02";

			IF iNumReg = 0 THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02409") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tef_tmp_secuencia_man') THEN
				DROP TABLE "informix".tef_tmp_secuencia_man;
			END IF

			--- CREAR LA TABLA DE TRABAJO
			CREATE TABLE "informix".tef_tmp_secuencia_man
			(secuencia CHAR(7));

			INSERT INTO "informix".tef_tmp_secuencia_man
			SELECT  SUBSTR(linea,3,7) AS SECUENCIA
			FROM  BdiTef:"informix".tef_tmp_trabajo_man
			WHERE SUBSTR(linea,1,2) = "02";
			---VERIFICAR QUE NO VENGAN REPETIDOS LOS NUMEROS DE SECUENCIA
			IF EXISTS(SELECT SECUENCIA FROM "informix".tef_tmp_secuencia_man GROUP BY SECUENCIA HAVING COUNT(*) > 1) THEN
				EXECUTE PROCEDURE BdiTef:"informix".sp_ObtenerMensajeError("02410") INTO vsCodRef, sDescMensajeError;
				RETURN vsCodRef, sDescMensajeError;
			END IF

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT linea
				INTO sLinea
				FROM "informix".tef_tmp_trabajo_man

				IF SUBSTR(sLinea,1,2) = "01" THEN --- ASIGNACIONES PARA ENCABEZADO
					LET sEncTipoReg					= SUBSTR(sLinea,1,2);
					LET sEncNumSec					= SUBSTR(sLinea,3,7);
					LET sEncCodOper					= SUBSTR(sLinea,10,2);
					LET sEncBanco					= SUBSTR(sLinea,12,3);
					LET sEncSentido					= SUBSTR(sLinea,15,1);
					LET sEncServicio				= SUBSTR(sLinea,16,1);
					LET sEncNumBloque				= SUBSTR(sLinea,17,7);
					LET sEncFechaPres				= SUBSTR(sLinea,24,8);
					LET sEncCodDivisa				= SUBSTR(sLinea,32,2);
					LET sEncCausaRechazo			= SUBSTR(sLinea,34,2);
					LET sEncModalidad				= SUBSTR(sLinea,36,1);
					LET sEncUsoFuturoCCEN			= SUBSTR(sLinea,37,41);
					
					IF (iNumCaracteres = 422) THEN --ARCHIVO  60 - 61
						LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,345);
					ELIF (iNumCaracteres = 442) THEN --ARCHIVO  62
						LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,365);
					ELIF (iNumCaracteres = 447) THEN --ARCHIVO  63
						LET sEncUsoFuturoBANCO			= SUBSTR(sLinea,78,370);
					END IF;
					
					
					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO BdiTef:"informix".tef_cce_encabezado_paso (nombre_arch,fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio
														,num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (psNombreArchivo,sEncFechaPres,sEncTipoReg,sEncNumSec,sEncCodOper,sEncBanco,sEncSentido,sEncServicio,sEncNumBloque
							,sEncCodDivisa,sEncCausaRechazo,sEncModalidad,sEncUsoFuturoCCEN,sEncUsoFuturoBANCO,psUsuario,CURRENT);

				ELIF SUBSTR(sLinea,1,2) = "02" THEN --- ASIGNACIONES PARA DETALLE
					LET sDetTipoReg					= SUBSTR(sLinea,1,2);
					LET sDetNumSec					= SUBSTR(sLinea,3,7);
					LET sDetCodOper					= SUBSTR(sLinea,10,2);
					LET sDetCodDivisa				= SUBSTR(sLinea,12,2);
					LET SDetFechaTrans				= SUBSTR(sLinea,14,8);
					LET sDetBancoPres				= SUBSTR(sLinea,22,3);
					LET sDetBancoRec				= SUBSTR(sLinea,25,3);
					LET sDetImpOperacion			= SUBSTR(sLinea,28,15);
					LET sDetUsoFuturoCCEN			= SUBSTR(sLinea,43,16);
					LET sDetTipoOperacion			= SUBSTR(sLinea,59,2);
					LET sDetFechaApli				= SUBSTR(sLinea,61,8);
					LET sDetTipoCtaOrdenante		= SUBSTR(sLinea,69,2);
					LET sDetNumCtaOrdenante			= SUBSTR(sLinea,71,20);
					LET sDetNombreOrdenante			= SUBSTR(sLinea,91,40);
					LET sDetRFCCURPOrdenante		= SUBSTR(sLinea,131,18);
					LET sDetTipoCtaReceptor			= SUBSTR(sLinea,149,2);
					LET sDetNumCtaReceptor			= SUBSTR(sLinea,151,20);
					LET sDetNombreReceptor			= SUBSTR(sLinea,171,40);
					LET sDetRFCCURPReceptor			= SUBSTR(sLinea,211,18);
					LET sDetRefServEmisor			= SUBSTR(sLinea,229,40);
					LET sDetNomTitularServ			= SUBSTR(sLinea,269,40);
					LET sDetImpIvaOperacion			= SUBSTR(sLinea,309,15);
					LET sDetRefNumOrdenante			= SUBSTR(sLinea,324,7);
					LET sDetRefLeyendaOrdenante  	= SUBSTR(sLinea,331,40);
					LET sDetClaveRastreo			= SUBSTR(sLinea,371,30);
					LET sDetMotivoDev				= SUBSTR(sLinea,401,2);
					LET sDetFecPresInicial			= SUBSTR(sLinea,403,8);
					LET sDetSolicitud_Confirmacion 	= SUBSTR(sLinea,411,1);

					IF (iNumCaracteres = 422) THEN --ARCHIVO  60 - 61
						LET sDetUsoFuturoBanco			= SUBSTR(sLinea,412,11);
						LET sDetRef_Confirmacion 		= '';
						LET sDetUsoFuturoCce 			= '';
						LET sDetTasa_Tiie_Prom 			= '';
						LET sDetDias_Retraso 			= '';
						LET sDetImp_Tot_Int 			= '';
					ELIF (iNumCaracteres = 442) THEN --ARCHIVO  62
						LET sDetUsoFuturoBanco			= '';
						LET sDetRef_Confirmacion 		= SUBSTR(sLinea,412,30);
						LET sDetUsoFuturoCce 			= SUBSTR(sLinea,442,1);
						LET sDetTasa_Tiie_Prom 			= '';
						LET sDetDias_Retraso 			= '';
						LET sDetImp_Tot_Int 			= '';
					ELIF (iNumCaracteres = 447) THEN --ARCHIVO  63
						LET sDetUsoFuturoBanco			= SUBSTR(sLinea,412,11);
						LET sDetRef_Confirmacion 		= '';
						LET sDetUsoFuturoCce 			= '';
						LET sDetTasa_Tiie_Prom 			= SUBSTR(sLinea,423,7);
						LET sDetDias_Retraso 			= SUBSTR(sLinea,430,3);
						LET sDetImp_Tot_Int 			= SUBSTR(sLinea,433,15);
					END IF;
					

				--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
				INSERT INTO BdiTef:"informix".tef_cce_detalle_paso(nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,cod_divisa,fecha_trans,banco_presentador
												,banco_receptor,importe,uso_futuro_ccen,tipo_operacion,fecha_aplica,tipo_cta_ord,num_cta_ord,nombre_ord,rfc_ord
												,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,ref_leyenda
												,clave_rastreo,motivo_dev,
												fecha_pres_ini,
												Solicitud_Confirmacion, uso_futuro_banco,Ref_Confirmacion, 
												Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int, 
												cve_Status,folio_suc,user_insert,fecha_insert)
												
				VALUES (psNombreArchivo,sEncFechaPres,sDetTipoReg,sDetNumSec,sDetCodOper,sDetCodDivisa,SDetFechaTrans,sDetBancoPres,sDetBancoRec,sDetImpOperacion,sDetUsoFuturoCCEN
						,sDetTipoOperacion,sDetFechaApli,sDetTipoCtaOrdenante,sDetNumCtaOrdenante,sDetNombreOrdenante,sDetRFCCURPOrdenante,sDetTipoCtaReceptor
						,sDetNumCtaReceptor,sDetNombreReceptor,sDetRFCCURPReceptor,sDetRefServEmisor,sDetNomTitularServ,sDetImpIvaOperacion,sDetRefNumOrdenante
						,sDetRefLeyendaOrdenante,sDetClaveRastreo,sDetMotivoDev,
						sDetFecPresInicial,
						sDetSolicitud_Confirmacion, sDetUsoFuturoBanco, sDetRef_Confirmacion, 
						sDetUsoFuturoCce, sDetTasa_Tiie_Prom, sDetDias_Retraso, sDetImp_Tot_Int, 
						"00","",psUsuario,CURRENT);
						
						
				ELIF SUBSTR(sLinea,1,2) = "09" THEN--- ASIGNACIONES PARA SUMARIO
					LET sSumTipoReg					= SUBSTR(sLinea,1,2);
					LET sSumNumSec					= SUBSTR(sLinea,3,7);
					LET sSumCodOper					= SUBSTR(sLinea,10,2);
					LET sSumNumBloque				= SUBSTR(sLinea,12,7);
					LET sSumNumOper					= SUBSTR(sLinea,19,7);
					LET sSumImpTotOper				= SUBSTR(sLinea,26,18);
					LET sSumUsoFuturoCCEN			= SUBSTR(sLinea,44,40);
					
					IF (iNumCaracteres = 422) THEN --ARCHIVO  60 - 61
						LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,339);
					ELIF (iNumCaracteres = 442) THEN --ARCHIVO  62
						LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,365);
					ELIF (iNumCaracteres = 447) THEN --ARCHIVO  63
						LET sSumUsoFuturoBanco			= SUBSTR(sLinea,84,370);
					END IF;
					
					--- INSERTA EN LAS TABLAS DE PASO DESPUES DE VALIDAR LOS TIPOS DE CAMPOS
					INSERT INTO BdiTef:"informix".tef_cce_sumario_paso (nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,cod_operacion,num_bloque,num_operaciones
													,imp_operaciones,uso_futuro_ccen,uso_futuro_banco,user_insert,fecha_insert)
					VALUES (psNombreArchivo,sEncFechaPres,sSumTipoReg,sSumNumSec,sSumCodOper,sSumNumBloque,sSumNumOper,sSumImpTotOper
							,sSumUsoFuturoCCEN,sSumUsoFuturoBanco,psUsuario,CURRENT);
				END IF 
			END FOREACH
		END IF
	END IF

	RETURN vsCodRef, sDescMensajeError;
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA REALIZAR LA CARGA DE LOS ARCHIVOS QUE SE RECIBEN A LAS TABLAS DE INFORMIX.',
'Fecha: 2011/03/10',
'Version: 20110310.1830',
'----------------------------------------------------------------------------------------------------------',
'Fecha: 2016/02/18',
'Descripcion: Se modifica para concatenar fechas en los archivos .sql y .out generados para facilitar el seguimiento de incidencias',
'Ademas, se les asignan privilegios 777 a los mismos archivos para evitar errores de uso compartido con los usuarios que participan en TEF',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_procesararchivo61(psNombreArchivo CHAR(20),psFechaPresentacion CHAR(8), psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 61.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 05/04/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

DEFINE VSCONSULTA CHAR(2000);
--DEFINICION DE VARIABLES.
DEFINE vsCodRet CHAR(5);
DEFINE vsPrefijoTarjeta CHAR(100);


DEFINE vsCuenta CHAR(11);
DEFINE vsStatus_Cta CHAR (1);
DEFINE vsProducto CHAR (4);
DEFINE vdFecha_Hoy DATE;
DEFINE vdFecha_Manana DATE;

DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsTipo_Registro CHAR(2);
DEFINE vsNum_Secuencia CHAR(7);
DEFINE vsCod_Operacion CHAR(2);
DEFINE vsCod_Divisa CHAR(2);
DEFINE vsFecha_Trans CHAR(8);
DEFINE vsBanco_Presentador CHAR(3);
DEFINE vsBanco_Receptor CHAR(3);
DEFINE vsImporte CHAR(15);
DEFINE vsUso_Futuro_ccen CHAR(16);
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsFecha_Aplica CHAR(8);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsNombre_Ord CHAR(40);
DEFINE vsRfc_Ord CHAR(18);
DEFINE vsTipo_Cta_Rec CHAR(2);
DEFINE vsNum_Cta_Rec CHAR(20);
DEFINE vsNombre_Rec CHAR(40);
DEFINE vsRfc_Rec CHAR(18);
DEFINE vsRef_Servicio CHAR(40);
DEFINE vsNombre_Titular_Serv CHAR(40);
DEFINE vsImporte_Iva CHAR(15);
DEFINE vsRef_Numerica CHAR(7);
DEFINE vsRef_Leyenda CHAR(40);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsFecha_Pres_Ini CHAR(8);
DEFINE vsSolicitud_Confirmacion CHAR(1);
DEFINE vsUso_Futuro_Banco CHAR(11);
DEFINE vsRef_Confirmacion CHAR(30); 
DEFINE vsUso_Futuro_Cce CHAR(1);
DEFINE vsTasa_Tiie_Prom CHAR(7);
DEFINE vsDias_Retraso CHAR(3);
DEFINE vsImp_Tot_Int CHAR(15);
DEFINE vsCve_Estatus CHAR(11);
DEFINE vsFolio_Suc CHAR(30);


DEFINE vsNum_Secuencia_S CHAR(7);
DEFINE vsNum_Operaciones_S CHAR(18);

DEFINE vsNombre_Arch60 CHAR (20);
DEFINE vsFecha_Presentacion60 CHAR (8);

DEFINE vsSucursalContable CHAR(4);
DEFINE vsNumeroFolioAbono CHAR (16);
DEFINE vsTransaccAbono CHAR(4);
DEFINE vsReferenciaAbono CHAR(50);
DEFINE vmSaldoAPagar MONEY(16,2);

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;
DEFINE nSucursal		   INTEGER;


DEFINE iSQLerr INTEGER;

--INICIALIZACION DE VARIABLES.
LET vsCodRet = '00000';

LET vsPrefijoTarjeta = '';

LET vsCuenta = '';
LET vsStatus_Cta = '';
LET vsProducto = '';
LET vdFecha_Hoy = CURRENT;
LET vdFecha_Manana = CURRENT;

LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsTipo_Registro = '';
LET vsNum_Secuencia = '';
LET vsCod_Operacion = '';
LET vsCod_Divisa = '';
LET vsFecha_Trans = '';
LET vsBanco_Presentador = '';
LET vsBanco_Receptor = '';
LET vsImporte = '';
LET vsUso_Futuro_ccen = '';
LET vsTipo_Operacion = '';
LET vsFecha_Aplica = '';
LET vsTipo_Cta_Ord = '';
LET vsNum_Cta_Ord = '';
LET vsNombre_Ord = '';
LET vsRfc_Ord = '';
LET vsTipo_Cta_Rec = '';
LET vsNum_Cta_Rec = '';
LET vsNombre_Rec = '';
LET vsRfc_Rec = '';
LET vsRef_Servicio = '';
LET vsNombre_Titular_Serv = '';
LET vsImporte_Iva = '';
LET vsRef_Numerica = '';
LET vsRef_Leyenda = '';
LET vsClave_Rastreo = '';
LET vsMotivo_Dev = '';
LET vsFecha_Pres_Ini = '';
LET vsSolicitud_Confirmacion = '';
LET vsUso_Futuro_Banco = '';
LET vsRef_Confirmacion = ''; 
LET vsUso_Futuro_Cce = '';
LET vsTasa_Tiie_Prom = '';
LET vsDias_Retraso = '';
LET vsImp_Tot_Int = '';
LET vsCve_Estatus = '';
LET vsFolio_Suc = '';

LET vsNum_Secuencia_S = '';
LET vsNum_Operaciones_S = '';

LET vsNombre_Arch60 = '';
LET vsFecha_Presentacion60 = '';


LET vsSucursalContable = '';
LET vsNumeroFolioAbono = '';
LET vsTransaccAbono = '';
LET vsReferenciaAbono = '';
LET vmSaldoAPagar = 0.0;

--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
LET nSucursal			= 0;


LET iSQLerr = 0;

--SET DEBUG FILE TO "/dbexport/TEF/trace/TRACEsp_tef_procesararchivo61.sql";
--TRACE ON;


BEGIN 
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET vsCodRet = iSQLerr;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		RETURN vsCodRet;
	END IF;
END EXCEPTION;

	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	-------SE OBTIENEN LOS PARAMETROS----
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 Valor INTO vsPrefijoTarjeta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA
	
	SELECT FIRST 1 Valor INTO vsSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE
	
	SELECT FIRST 1 Valor INTO vsTransaccAbono FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82'; --TRANSACCION ABONO TEF
	
	SELECT COUNT (*)
	INTO nSucursal
	FROM BdInteg:Si_Sucursales WHERE Sucursal = vsSucursalContable;
	
	IF (nSucursal <= 0) THEN --VALIDAR SI EXISTE EN EL CATÁLOGO LA SUCURSAL CONTABLE.
		LET vsCodRet = '02000';
	ELSE 
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		

		--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
		FOREACH WITH HOLD
		SELECT 
		Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
		Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
		Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
		Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
		Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
		Imp_Tot_Int, Cve_Status, Folio_Suc
		INTO 
		vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
		vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
		vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
		vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
		vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
		vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
		WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '61'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET vsNombre_Arch60 = '';
			LET vsFecha_Presentacion60 = '';
			
			/*
			LET VSCONSULTA  = "SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion "
			|| "FROM BdiTef:"informix".Tef_Cce_Detalle "
			|| "WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_estatus = '02' "
			|| "AND Importe = '" || vsImporte || "' AND Tipo_Operacion = '" || vsTipo_Operacion || "' AND Fecha_Aplica = '" || vsFecha_Aplica || "' "
			|| "AND Tipo_Cta_Ord = '" ||vsTipo_Cta_Ord || "' AND Num_Cta_Ord = '" ||vsNum_Cta_Ord || "' AND Rfc_Ord = '" ||vsRfc_Ord || "' "
			|| "AND Tipo_Cta_Rec = '" ||vsTipo_Cta_Rec || "' AND Num_Cta_Rec = '" ||vsNum_Cta_Rec || "' AND Rfc_Rec = '" ||vsRfc_Rec  || "' "
			|| "AND Ref_Servicio = '" ||vsRef_Servicio || "' AND Fecha_Pres_Ini = '" ||vsFecha_Pres_Ini || "'; ";
			*/
			
			--OBTIENE NOMBRE DE ARCHIVO 60 Y FECHA DE PRESENTACION DEL MOVIMIENTO
			SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion
			INTO vsNombre_Arch60, vsFecha_Presentacion60 
			FROM BdiTef:"informix".Tef_Cce_Detalle 
			--WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '02'
			WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '01' 
			AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
			AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord
			AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec 
			AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini;
			--AND Clave_Rastreo = vsClave_Rastreo;
			
			
			IF (NVL(vsNombre_Arch60, '') = '') THEN --VALIDA KE EL REGISTRO EXISTA EN EL ARCHIVO 60
				--'NO EXISTE UN REGISTRO CON CÓDIGO 30 QUE CORROBORE EL REGISTRO QUE SE ESTA VALIDANDO';
				LET vsCodRet = '02001';
				EXIT FOREACH;
			END IF;
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		IF (vsCodRet = '00000') THEN --VALIDA KE TODOS LOS REGISTROS ESTEN EN EL ARCHIVO 60
				
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			

			--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
			FOREACH WITH HOLD
			SELECT 
			Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
			Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
			Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
			Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
			Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
			Imp_Tot_Int, Cve_Status, Folio_Suc
			INTO 
			vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
			vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
			vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
			vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
			vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
			vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
			FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
			WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '61'
				
				--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (vsFlagEnTransaccion = 'F') THEN 
					 BEGIN WORK;
					 LET vsFlagEnTransaccion = 'V';
				END IF;
				
				--IF (SUBSTR(vsNum_Cta_Ord,5,6) = TRIM(vsPrefijoTarjeta)) THEN --ES UNA TARJETA
				IF (TRIM(vsPrefijoTarjeta) MATCHES '*'|| SUBSTR(vsNum_Cta_Ord,5,6) || '*')THEN
					

					--SE OBTIENE LA CUENTA RELACIONADA A LA TARJETA
					SELECT FIRST 1 NVL(Cuenta,'') INTO vsCuenta FROM BdiCheq:Sc_Tarjeta WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(vsNum_Cta_Ord),5,16);
					
				ELSE
					LET vsCuenta = SUBSTR(vsNum_Cta_Ord,9,11); --CUENTA
				END IF;
				
				
				LET vsNumeroFolioAbono = '';
				LET vmSaldoAPagar = ((vsImporte::INTEGER)/100);
				
				--OBTIENE FOLIO DEL ABONO
				EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(psUsuario) INTO vsCodRet, vsNumeroFolioAbono;
				LET vsCodRet = LPAD(TRIM(vsCodRet),5,'0');
				
				IF (vsCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
					LET vsCodRet = '02002';
					EXIT FOREACH;
					
				ELSE --OK
				
					--REALIZA EL ABONO
					EXECUTE PROCEDURE BdiCheq:"informix".Abono_Ref ("001", vsSucursalContable, psUsuario,  vsTransaccAbono, "0000", vsNumeroFolioAbono, vsCuenta,
						0, vmSaldoAPagar, vmSaldoAPagar, 0, 0, 0, "01",vsRef_Leyenda, '', psUsuario) INTO vsCodRet;
					
					IF (vsCodRet::INTEGER <> 0) THEN --ERROR AL REALIZAR EL ABONO
						LET vsCodRet = '02003';
						EXIT FOREACH;
					ELSE -- OK
					
						--ACTUALIZA EL REGISTRO ORIGINAL DEL ARCHIVO 60
						UPDATE BdiTef:"informix".Tef_Cce_Detalle 
						SET Cve_Status = '02', Motivo_Dev = vsMotivo_Dev
						WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '01' --APLICADO EN 60
						AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
						AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord 
						AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec  
						AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini
						AND Clave_Rastreo = vsClave_Rastreo;
											
						--ACTUALIZA EL REGISTRO ORIGINAL DE LA TABLA DE OPERACIONES
						UPDATE BdiTef:"informix".Tef_Operaciones 
						SET Cve_Status = '02', Motivo_dev = vsMotivo_Dev
						WHERE Nombre_Arch = vsNombre_Arch60
						AND Fecha_Presentacion = vsFecha_Presentacion60
						AND Clave_Rastreo = vsClave_Rastreo;
						
						--ACTUALIZA EL REGISTRO ORIGINAL DEL ARCHIVO 61
						UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso
						SET Folio_Suc = vsNumeroFolioAbono, Cve_Status = '02'						
						WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '61' AND Tipo_Registro = '02' --APLICADO EN 60
						AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
						AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord 
						AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec  
						AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini
						AND Clave_Rastreo = vsClave_Rastreo;
					
					END IF;
				END IF;
				
				LET viContadorRegistros = viContadorRegistros + 1;
				
				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccion = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				END IF;
				
			END FOREACH;
			
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
				
			LET vsCodRet = '00000';
			
		END IF;
		
	END IF;
	
	RETURN vsCodRet;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 61.',
'Fecha: 2011/04/05',
'Version: 20110405.1120',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_procesararchivo62(psNombreArchivo CHAR(20), psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 62.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 15/04/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************


--DEFINICION DE VARIABLES.
DEFINE VSCONSULTA CHAR(2000);
DEFINE vsCodRet CHAR(5);

DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsTipo_Registro CHAR(2);
DEFINE vsNum_Secuencia CHAR(7);
DEFINE vsCod_Operacion CHAR(2);
DEFINE vsCod_Divisa CHAR(2);
DEFINE vsFecha_Trans CHAR(8);
DEFINE vsBanco_Presentador CHAR(3);
DEFINE vsBanco_Receptor CHAR(3);
DEFINE vsImporte CHAR(15);
DEFINE vsUso_Futuro_ccen CHAR(16);
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsFecha_Aplica CHAR(8);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsNombre_Ord CHAR(40);
DEFINE vsRfc_Ord CHAR(18);
DEFINE vsTipo_Cta_Rec CHAR(2);
DEFINE vsNum_Cta_Rec CHAR(20);
DEFINE vsNombre_Rec CHAR(40);
DEFINE vsRfc_Rec CHAR(18);
DEFINE vsRef_Servicio CHAR(40);
DEFINE vsNombre_Titular_Serv CHAR(40);
DEFINE vsImporte_Iva CHAR(15);
DEFINE vsRef_Numerica CHAR(7);
DEFINE vsRef_Leyenda CHAR(40);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsFecha_Pres_Ini CHAR(8);
DEFINE vsSolicitud_Confirmacion CHAR(1);
DEFINE vsUso_Futuro_Banco CHAR(11);
DEFINE vsRef_Confirmacion CHAR(30); 
DEFINE vsUso_Futuro_Cce CHAR(1);
DEFINE vsTasa_Tiie_Prom CHAR(7);
DEFINE vsDias_Retraso CHAR(3);
DEFINE vsImp_Tot_Int CHAR(15);
DEFINE vsCve_Estatus CHAR(11);
DEFINE vsFolio_Suc CHAR(30);


DEFINE vsNum_Secuencia_S CHAR(7);
DEFINE vsNum_Operaciones_S CHAR(18);

DEFINE vsNombre_Arch60 CHAR (20);
DEFINE vsFecha_Presentacion60 CHAR (8);

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;


DEFINE iSQLerr INTEGER;

--INICIALIZACION DE VARIABLES.
LET vsCodRet = '00000';


LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsTipo_Registro = '';
LET vsNum_Secuencia = '';
LET vsCod_Operacion = '';
LET vsCod_Divisa = '';
LET vsFecha_Trans = '';
LET vsBanco_Presentador = '';
LET vsBanco_Receptor = '';
LET vsImporte = '';
LET vsUso_Futuro_ccen = '';
LET vsTipo_Operacion = '';
LET vsFecha_Aplica = '';
LET vsTipo_Cta_Ord = '';
LET vsNum_Cta_Ord = '';
LET vsNombre_Ord = '';
LET vsRfc_Ord = '';
LET vsTipo_Cta_Rec = '';
LET vsNum_Cta_Rec = '';
LET vsNombre_Rec = '';
LET vsRfc_Rec = '';
LET vsRef_Servicio = '';
LET vsNombre_Titular_Serv = '';
LET vsImporte_Iva = '';
LET vsRef_Numerica = '';
LET vsRef_Leyenda = '';
LET vsClave_Rastreo = '';
LET vsMotivo_Dev = '';
LET vsFecha_Pres_Ini = '';
LET vsSolicitud_Confirmacion = '';
LET vsUso_Futuro_Banco = '';
LET vsRef_Confirmacion = ''; 
LET vsUso_Futuro_Cce = '';
LET vsTasa_Tiie_Prom = '';
LET vsDias_Retraso = '';
LET vsImp_Tot_Int = '';
LET vsCve_Estatus = '';
LET vsFolio_Suc = '';

LET vsNum_Secuencia_S = '';
LET vsNum_Operaciones_S = '';

LET vsNombre_Arch60 = '';
LET vsFecha_Presentacion60 = '';

--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET iSQLerr = 0;


LET VSCONSULTA  = '';
--SET DEBUG FILE TO "/dbexport/TEF/trace/TRACEsp_tef_procesararchivo62.sql";
--TRACE ON;


BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET vsCodRet = iSQLerr;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		RETURN vsCodRet;
	END IF;
END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
	FOREACH WITH HOLD
	SELECT 
	Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
	Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
	Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
	Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
	Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
	Imp_Tot_Int, Cve_Status, Folio_Suc
	INTO 
	vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
	vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
	vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
	vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
	vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
	vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
	FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
	WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '62'
		
		--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN 
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
		
		
		LET vsNombre_Arch60 = '';
		LET vsFecha_Presentacion60 = '';
		
		/*
		LET VSCONSULTA  = "SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion "
		|| "FROM BdiTef:"informix".Tef_Cce_Detalle "
		|| "WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_estatus = '02' "
		|| "AND Importe = '" || vsImporte || "' AND Tipo_Operacion = '" || vsTipo_Operacion || "' AND Fecha_Aplica = '" || vsFecha_Aplica || "' "
		|| "AND Tipo_Cta_Ord = '" ||vsTipo_Cta_Ord || "' AND Num_Cta_Ord = '" ||vsNum_Cta_Ord || "' AND Rfc_Ord = '" ||vsRfc_Ord || "' "
		|| "AND Tipo_Cta_Rec = '" ||vsTipo_Cta_Rec || "' AND Num_Cta_Rec = '" ||vsNum_Cta_Rec || "' AND Rfc_Rec = '" ||vsRfc_Rec  || "' "
		|| "AND Ref_Servicio = '" ||vsRef_Servicio || "' AND Fecha_Pres_Ini = '" ||vsFecha_Pres_Ini || "'; ";
		*/

		--OBTIENE NOMBRE DE ARCHIVO 60 Y FECHA DE PRESENTACION DEL MOVIMIENTO
		SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion
		INTO vsNombre_Arch60, vsFecha_Presentacion60 
		FROM BdiTef:"informix".Tef_Cce_Detalle 
		--WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '02' --APLICADO EN 60
		WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '01' --APLICADO EN 60
		AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
		AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord
		AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec 
		AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini;
		--AND Clave_Rastreo = vsClave_Rastreo;
		
		
		IF (NVL(vsNombre_Arch60, '') = '') THEN --VALIDA KE EL REGISTRO EXISTA EN EL ARCHIVO 60
			--'NO EXISTE UN REGISTRO CON CÓDIGO 30 QUE CORROBORE EL REGISTRO QUE SE ESTA VALIDANDO';
			LET vsCodRet = '02100';
			EXIT FOREACH;
		END IF;
		
		LET viContadorRegistros = viContadorRegistros + 1;
			
		--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;
		
	END FOREACH;
	
	-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
	END IF;
	
	IF (vsCodRet = '00000') THEN --VALIDA KE TODOS LOS REGISTROS ESTEN EN EL ARCHIVO 60
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		

		--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
		FOREACH WITH HOLD
		SELECT 
		Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
		Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
		Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
		Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
		Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
		Imp_Tot_Int, Cve_Status, Folio_Suc
		INTO 
		vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
		vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
		vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
		vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
		vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
		vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
		WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '62'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			--ACTUALIZA EL REGISTRO ORIGINAL DEL ARCHIVO 60
			UPDATE BdiTef:"informix".Tef_Cce_Detalle 
			SET Cve_Status = '01', Motivo_Dev = '00', ref_confirmacion = vsRef_Confirmacion
			--WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '02' --APLICADO EN 60
			WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '01' --APLICADO EN 60
			AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
			AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord 
			AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec  
			AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini
			AND Clave_Rastreo = vsClave_Rastreo;
								
          
			
			--ACTUALIZA EL REGISTRO ORIGINAL DE LA TABLA DE OPERACIONES
			UPDATE BdiTef:"informix".Tef_Operaciones 
			SET Cve_Status = '01', Motivo_dev = '00'
			WHERE Nombre_Arch = vsNombre_Arch60
			AND Fecha_Presentacion = vsFecha_Presentacion60
			AND Clave_Rastreo = vsClave_Rastreo;
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
	END IF;
	
	RETURN vsCodRet;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 62.',
'Fecha: 2011/04/15',
'Version: 20110415.1540',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_tef_procesararchivo63(psNombreArchivo CHAR(20),psFechaPresentacion CHAR(8), psUsuario CHAR(8))
RETURNING CHAR(5) AS CodRet;

--****************************************************************************************************
-- DESCRIPCION:  PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 63.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 19/04/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

--DEFINICION DE VARIABLES.
DEFINE VSCONSULTA CHAR(2000);
DEFINE vsCodRet CHAR(5);
DEFINE vsPrefijoTarjeta CHAR(100);


DEFINE vsCuenta CHAR(11);
DEFINE vsStatus_Cta CHAR (1);
DEFINE vsProducto CHAR (4);
DEFINE vdFecha_Hoy DATE;
DEFINE vdFecha_Manana DATE;

DEFINE vsNombre_Arch CHAR(20);
DEFINE vsFecha_Presentacion CHAR(8);
DEFINE vsTipo_Registro CHAR(2);
DEFINE vsNum_Secuencia CHAR(7);
DEFINE vsCod_Operacion CHAR(2);
DEFINE vsCod_Divisa CHAR(2);
DEFINE vsFecha_Trans CHAR(8);
DEFINE vsBanco_Presentador CHAR(3);
DEFINE vsBanco_Receptor CHAR(3);
DEFINE vsImporte CHAR(15);
DEFINE vsUso_Futuro_ccen CHAR(16);
DEFINE vsTipo_Operacion CHAR(2);
DEFINE vsFecha_Aplica CHAR(8);
DEFINE vsTipo_Cta_Ord CHAR(2);
DEFINE vsNum_Cta_Ord CHAR(20);
DEFINE vsNombre_Ord CHAR(40);
DEFINE vsRfc_Ord CHAR(18);
DEFINE vsTipo_Cta_Rec CHAR(2);
DEFINE vsNum_Cta_Rec CHAR(20);
DEFINE vsNombre_Rec CHAR(40);
DEFINE vsRfc_Rec CHAR(18);
DEFINE vsRef_Servicio CHAR(40);
DEFINE vsNombre_Titular_Serv CHAR(40);
DEFINE vsImporte_Iva CHAR(15);
DEFINE vsRef_Numerica CHAR(7);
DEFINE vsRef_Leyenda CHAR(40);
DEFINE vsClave_Rastreo CHAR(30);
DEFINE vsMotivo_Dev CHAR(2);
DEFINE vsFecha_Pres_Ini CHAR(8);
DEFINE vsSolicitud_Confirmacion CHAR(1);
DEFINE vsUso_Futuro_Banco CHAR(11);
DEFINE vsRef_Confirmacion CHAR(30); 
DEFINE vsUso_Futuro_Cce CHAR(1);
DEFINE vsTasa_Tiie_Prom CHAR(7);
DEFINE vsDias_Retraso CHAR(3);
DEFINE vsImp_Tot_Int CHAR(15);
DEFINE vsCve_Estatus CHAR(11);
DEFINE vsFolio_Suc CHAR(30);


DEFINE vsNum_Secuencia_S CHAR(7);
DEFINE vsNum_Operaciones_S CHAR(18);

DEFINE vsNombre_Arch60 CHAR (20);
DEFINE vsFecha_Presentacion60 CHAR (8);

DEFINE vsSucursalContable CHAR(4);
DEFINE vsNumeroFolioAbono CHAR (16);
DEFINE vsTransaccAbono CHAR(4);
DEFINE vsReferenciaAbono CHAR(50);
DEFINE vmSaldoAPagar MONEY(16,2);

DEFINE viDiasNaturales INTEGER;
--DEFINE vdFecha_Hoy DATE;
DEFINE vdFechaLimite DATE;
DEFINE vdFechaPresOriginal DATE;

--*
DEFINE cNumCte 					CHAR(20);
DEFINE sCanal					SMALLINT;
DEFINE cEsTransfer				CHAR(1);
DEFINE cUserInsert				CHAR(8);
DEFINE dtFechaHoraInsert		DATETIME YEAR TO SECOND;
--*

--TRANSACCIONES
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;
DEFINE nSucursal			INTEGER;


DEFINE iSQLerr INTEGER;

--SET DEBUG FILE TO '/respaldosbd/Benitez/sp_tef_procesararchivo63.out';
--TRACE ON;


--INICIALIZACION DE VARIABLES.
LET vsCodRet = '00000';

LET vsPrefijoTarjeta = '';

LET vsCuenta = '';
LET vsStatus_Cta = '';
LET vsProducto = '';
LET vdFecha_Hoy = CURRENT;
LET vdFecha_Manana = CURRENT;

LET vsNombre_Arch = '';
LET vsFecha_Presentacion = '';
LET vsTipo_Registro = '';
LET vsNum_Secuencia = '';
LET vsCod_Operacion = '';
LET vsCod_Divisa = '';
LET vsFecha_Trans = '';
LET vsBanco_Presentador = '';
LET vsBanco_Receptor = '';
LET vsImporte = '';
LET vsUso_Futuro_ccen = '';
LET vsTipo_Operacion = '';
LET vsFecha_Aplica = '';
LET vsTipo_Cta_Ord = '';
LET vsNum_Cta_Ord = '';
LET vsNombre_Ord = '';
LET vsRfc_Ord = '';
LET vsTipo_Cta_Rec = '';
LET vsNum_Cta_Rec = '';
LET vsNombre_Rec = '';
LET vsRfc_Rec = '';
LET vsRef_Servicio = '';
LET vsNombre_Titular_Serv = '';
LET vsImporte_Iva = '';
LET vsRef_Numerica = '';
LET vsRef_Leyenda = '';
LET vsClave_Rastreo = '';
LET vsMotivo_Dev = '';
LET vsFecha_Pres_Ini = '';
LET vsSolicitud_Confirmacion = '';
LET vsUso_Futuro_Banco = '';
LET vsRef_Confirmacion = ''; 
LET vsUso_Futuro_Cce = '';
LET vsTasa_Tiie_Prom = '';
LET vsDias_Retraso = '';
LET vsImp_Tot_Int = '';
LET vsCve_Estatus = '';
LET vsFolio_Suc = '';

LET vsNum_Secuencia_S = '';
LET vsNum_Operaciones_S = '';

LET vsNombre_Arch60 = '';
LET vsFecha_Presentacion60 = '';


LET vsSucursalContable = '';
LET vsNumeroFolioAbono = '';
LET vsTransaccAbono = '';
LET vsReferenciaAbono = '';
LET vmSaldoAPagar = 0.0;

LET viDiasNaturales = 0;
LET vdFecha_Hoy = CURRENT;
LET vdFechaLimite = CURRENT;
LET vdFechaPresOriginal = CURRENT;

--*
LET cNumCte 				= "";
LET sCanal					= 0;
LET cEsTransfer				= "";
LET cUserInsert				= "";
LET dtFechaHoraInsert		= DATE(1);
--*

--TRANSACCIONES
LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;
LET nSucursal			= 0;

LET iSQLerr = 0;




BEGIN
ON EXCEPTION SET iSQLerr
	IF iSQLerr <> 0 THEN
		LET vsCodRet = iSQLerr;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		RETURN vsCodRet;
	END IF;
END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
	END EXCEPTION WITH RESUME;
	
	-------SE OBTIENEN LOS PARAMETROS----
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 NVL(Valor,'0')::INTEGER INTO viDiasNaturales FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '81'; -- DIAS NATURALES PARA EL REVERSO
	
	SELECT FIRST 1 Valor INTO vsPrefijoTarjeta FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '76'; -- PREFIJO TARJETA
	
	SELECT FIRST 1 Valor INTO vsSucursalContable FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '77'; --SUCURSAL CONTABLE
	
	SELECT FIRST 1 Valor INTO vsTransaccAbono FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '82'; --TRANSACCION ABONO TEF
	
	SELECT FIRST 1 Fecha_Hoy INTO vdFecha_Hoy FROM BdiCheq:Sc_Fechas; -- FECHA_HOY
	
	--FECHA LIMITE
	LET vdFechaLimite = vdFecha_Hoy - viDiasNaturales;
	
	SELECT COUNT (*)
	INTO nSucursal
	FROM BdInteg:Si_Sucursales WHERE Sucursal = vsSucursalContable;
	
	IF (nSucursal <= 0) THEN --VALIDAR SI EXISTE EN EL CATÁLOGO LA SUCURSAL CONTABLE.
		LET vsCodRet = '02200';
	ELSE 
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
		FOREACH WITH HOLD
		SELECT 
		Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
		Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
		Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
		Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
		Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
		Imp_Tot_Int, Cve_Status, Folio_Suc
		INTO 
		vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
		vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
		vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
		vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
		vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
		vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
		FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
		WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '63'
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			--PASA A FORMATO DE FECHA LA FECHA DE PRESENTACION PARA VALIDAR EL RANGO DE FECHAS
			LET vdFechaPresOriginal = MDY(SUBSTR(vsFecha_Pres_Ini, 5, 2), SUBSTR(vsFecha_Pres_Ini, 7, 2), SUBSTR(vsFecha_Pres_Ini, 1, 4));
			
			/*
			LET VSCONSULTA  = "SELECT FIRST 1 Nombre_Arch, Fecha_Presentacion "
			|| "FROM BdiTef:"informix".Tef_Cce_Detalle "
			|| "WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_estatus = '01' "
			|| "AND Importe = '" || vsImporte || "' AND Tipo_Operacion = '" || vsTipo_Operacion || "' AND Fecha_Aplica = '" || vsFecha_Aplica || "' "
			|| "AND Tipo_Cta_Ord = '" ||vsTipo_Cta_Ord || "' AND Num_Cta_Ord = '" ||vsNum_Cta_Ord || "' AND Rfc_Ord = '" ||vsRfc_Ord || "' "
			|| "AND Tipo_Cta_Rec = '" ||vsTipo_Cta_Rec || "' AND Num_Cta_Rec = '" ||vsNum_Cta_Rec || "' AND Rfc_Rec = '" ||vsRfc_Rec  || "' "
			|| "AND Ref_Servicio = '" ||vsRef_Servicio || "' AND Fecha_Pres_Ini = '" ||vsFecha_Pres_Ini || "'; ";
			*/
			
			
			IF (NOT(vdFechaPresOriginal BETWEEN vdFechaLimite AND (vdFecha_Hoy -1))) THEN --VALIDA QUE EL REGISTRO SE ENCUENTRE DENTRO DE LOS 60 DIAS NATURALES PARA HACER EL REVERSO
				
				LET vsCodRet = '02201';
				EXIT FOREACH;
				
			ELIF (NOT EXISTS (
				SELECT Nombre_Arch FROM BdiTef:"informix".Tef_Cce_Detalle 
				WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '01'
				AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
				AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord
				AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec 
				AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini) 
			) THEN --VALIDA KE EXISTA EL REGISTRO ORIGINAL EN UN ARCHIVO 60
				
				LET vsCodRet = '02202';
				EXIT FOREACH;
				
			END IF;
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		IF (vsCodRet = '00000') THEN --VALIDA KE TODOS LOS REGISTROS ESTEN EN EL ARCHIVO 60 Y EN EL RANGO DE FECHAS VALIDO
			
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
			
			--OBTIENE LOS REGISTROS DEL ARCHIVO PARA PROCESAR
			FOREACH WITH HOLD
			SELECT 
			Nombre_Arch, Fecha_Presentacion, Tipo_Registro, Num_Secuencia, Cod_Operacion, Cod_Divisa, Fecha_Trans, 
			Banco_Presentador, Banco_Receptor, Importe, Uso_Futuro_ccen, Tipo_Operacion, Fecha_Aplica, Tipo_Cta_Ord, 
			Num_Cta_Ord, Nombre_Ord, Rfc_Ord, Tipo_Cta_Rec, Num_Cta_Rec, Nombre_Rec, Rfc_Rec, Ref_Servicio, 
			Nombre_Titular_Serv, Importe_Iva, Ref_Numerica, Ref_Leyenda, Clave_Rastreo, Motivo_Dev, Fecha_Pres_Ini, 
			Solicitud_Confirmacion, Uso_Futuro_Banco, Ref_Confirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, 
			Imp_Tot_Int, Cve_Status, Folio_Suc
			INTO 
			vsNombre_Arch, vsFecha_Presentacion, vsTipo_Registro, vsNum_Secuencia, vsCod_Operacion, vsCod_Divisa, vsFecha_Trans, 
			vsBanco_Presentador, vsBanco_Receptor, vsImporte, vsUso_Futuro_ccen, vsTipo_Operacion, vsFecha_Aplica, vsTipo_Cta_Ord, 
			vsNum_Cta_Ord, vsNombre_Ord, vsRfc_Ord, vsTipo_Cta_Rec, vsNum_Cta_Rec, vsNombre_Rec, vsRfc_Rec, vsRef_Servicio, 
			vsNombre_Titular_Serv, vsImporte_Iva, vsRef_Numerica, vsRef_Leyenda, vsClave_Rastreo, vsMotivo_Dev, vsFecha_Pres_Ini, 
			vsSolicitud_Confirmacion, vsUso_Futuro_Banco, vsRef_Confirmacion, vsUso_Futuro_Cce, vsTasa_Tiie_Prom, vsDias_Retraso, 
			vsImp_Tot_Int, vsCve_Estatus, vsFolio_Suc
			FROM BdiTef:"informix".Tef_Cce_Detalle_Paso 
			WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '63'
				
				--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (vsFlagEnTransaccion = 'F') THEN 
					 BEGIN WORK;
					 LET vsFlagEnTransaccion = 'V';
				END IF;
				
				--IF (SUBSTR(vsNum_Cta_Ord,5,6) = TRIM(vsPrefijoTarjeta)) THEN --ES UNA TARJETA
				IF( TRIM(vsPrefijoTarjeta) MATCHES '*'|| SUBSTR(vsNum_Cta_Ord,5,6) ||'*')THEN --ES UNA TARJETA

					--SE OBTIENE LA CUENTA RELACIONADA A LA TARJETA
					SELECT FIRST 1 NVL(Cuenta,'') INTO vsCuenta FROM BdiCheq:"informix".Sc_Tarjeta WHERE Empresa = '001' AND Num_Tarjeta = SUBSTR(TRIM(vsNum_Cta_Ord),5,16);
					
				ELSE
					LET vsCuenta = SUBSTR(vsNum_Cta_Ord,9,11); --CUENTA
				END IF;
				--*
				IF  TRIM(NVL(vsTipo_Cta_Rec, '')) = '10' THEN -- VALIDAMOS TIPO CUENTA MOVIL				
					EXECUTE PROCEDURE bdicheq:"informix".sp_tef_constelctacte (SUBSTR(vsNum_Cta_Rec, 11,10)) -- OBTENEMOS LA CUENTA DEL NUMERO MOVIL 
					INTO vsCodRet, cNumCte, vsCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert; 
					
					-- SI NO HAY CUENTA PARA EL  MOVIL, ASIGNAMOS MOTIVO DEVOLUCIÓN.
					IF NVL(vsCuenta, '') = '' THEN	
						LET vsMotivo_Dev = '01'; -- NO SE ENCONTRO CUENTA MOVIL ASOCIADA.
						CONTINUE FOREACH;
					END IF;
				END IF;
				--*
				
				LET vsNumeroFolioAbono = '';
				LET vmSaldoAPagar = ((vsImporte::INTEGER)/100);
				
				--OBTIENE FOLIO DEL ABONO
				EXECUTE PROCEDURE BdiCheq:"informix".Sp_GeneraFolioNomina(psUsuario) INTO vsCodRet, vsNumeroFolioAbono;
				LET vsCodRet = LPAD(TRIM(vsCodRet),5,'0');
				
				IF (vsCodRet <> '00000') THEN --ERROR AL OBTENER EL FOLIO DEL ABONO
					LET vsCodRet = '02203';
					EXIT FOREACH;
					
				ELSE --OK
					
					--REALIZA EL ABONO
					EXECUTE PROCEDURE BdiCheq:"informix".Abono_Ref ("001", vsSucursalContable, psUsuario,  vsTransaccAbono, "0000", vsNumeroFolioAbono, vsCuenta,
						0, vmSaldoAPagar, vmSaldoAPagar, 0, 0, 0, "01",vsRef_Leyenda, '', psUsuario) INTO vsCodRet;
					
					IF (vsCodRet::INTEGER <> 0) THEN --ERROR AL REALIZAR EL ABONO
						LET vsCodRet = '02204';
						EXIT FOREACH;
					ELSE -- OK
						
						--ACTUALIZA EL REGISTRO ORIGINAL DEL ARCHIVO 60
						UPDATE BdiTef:"informix".Tef_Cce_Detalle 
						SET Cve_Status = '02', Motivo_Dev = vsMotivo_Dev
						WHERE Cod_Operacion = '60' AND Tipo_Registro = '02' AND Cve_Status = '01'
						AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
						AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord 
						AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec  
						AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini
						AND Clave_Rastreo = vsClave_Rastreo;
											
						--ACTUALIZA EL REGISTRO ORIGINAL DE LA TABLA DE OPERACIONES
						UPDATE BdiTef:"informix".Tef_Operaciones 
						SET Cve_Status = '02', Motivo_dev = vsMotivo_Dev
						WHERE Clave_Rastreo = vsClave_Rastreo;
                         --Nombre_Arch = vsNombre_Arch60
						--AND Fecha_Presentacion = vsFecha_Presentacion60
						--AND Clave_Rastreo = vsClave_Rastreo;
						
						
						--ACTUALIZA EL REGISTRO ORIGINAL DEL ARCHIVO 63
						UPDATE BdiTef:"informix".Tef_Cce_Detalle_Paso
						SET Folio_Suc = vsNumeroFolioAbono, Cve_Status = '02'
						WHERE Nombre_Arch = psNombreArchivo AND Cod_operacion = '63' AND Tipo_Registro = '02' 
						AND Importe = vsImporte AND Tipo_Operacion = vsTipo_Operacion AND Fecha_Aplica = vsFecha_Aplica 
						AND Tipo_Cta_Ord = vsTipo_Cta_Ord AND Num_Cta_Ord = vsNum_Cta_Ord AND Rfc_Ord = vsRfc_Ord 
						AND Tipo_Cta_Rec = vsTipo_Cta_Rec AND Num_Cta_Rec = vsNum_Cta_Rec AND Rfc_Rec = vsRfc_Rec  
						AND Ref_Servicio = vsRef_Servicio AND Fecha_Pres_Ini = vsFecha_Pres_Ini
						AND Clave_Rastreo = vsClave_Rastreo;
						
					END IF;
					
				END IF;
				
				LET viContadorRegistros = viContadorRegistros + 1;
				
				--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
				IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
					COMMIT WORK;
					LET vsFlagEnTransaccion = 'F';
					LET viContadorRegistros = 0;
					CONTINUE FOREACH;
				END IF;
				
			END FOREACH;
			
			-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
			
			LET vsCodRet = '00000';
			
		END IF;
		
	END IF;
	
	RETURN vsCodRet;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCESA  LOS DATOS DE LAS CUENTAS DEL ARCHIVO 63.',
'Fecha: 2011/04/19',
'Version: 20110419.1115',
'BD: BdiTef',
'',
'Modificado: Francisco Eduardo Benitez Baez',
'Proyecto: Número móvil en transferencias TEF',
'Solicito: Martín Pineda',
'Descripcion: Se agrega nuevo procedimiento de busqueda de telefono',
'		y se valida en caso de que no haya despliega mensaje', 
'Fecha: 24/09/2014',
'Version: 20140924.0937';

CREATE PROCEDURE "informix".sp_tef_valida_datos(psNombreArchivo CHAR(20), psFecha_Presentacion CHAR(8),psTipoArchivo CHAR(1), piNumArchivo INTEGER,psRol CHAR(1),psNomProceso CHAR(20))

RETURNING CHAR(5), CHAR (2);

--****************************************************************************************************
-- DESCRIPCION:  PROCEDIMIENTO PARA VALIDAR LOS DATOS EN LAS TABLAS DE PASO.
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 15/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

DEFINE vsFlagNumSecuencia CHAR(5);
DEFINE vsFlagFechaAplicacion CHAR(5);
DEFINE vsFlagNombreOrdenante CHAR(5);
DEFINE v_iCodReSP2 INTEGER;
DEFINE v_iDigVeSP2 INTEGER;
DEFINE vsFlagNumCtaReceptor CHAR(5);
DEFINE vsFlagNombreReceptor CHAR(5);
DEFINE vsFlagRef_Serv CHAR(5);

DEFINE	nom_arch CHAR(20);
DEFINE	fec_presen CHAR(8);
DEFINE	vsCodRet CHAR(5);
DEFINE  v_nivel CHAR(2);
DEFINE	sql_err INTEGER;
DEFINE v_contusoba INTEGER;
DEFINE v_ciclo  INTEGER;
DEFINE v_bancorev char(3);
DEFINE v_ini INTEGER;
DEFINE v_bancComa CHAR(1);
DEFINE v_BancoCoppel	CHAR(3);
DEFINE v_f_ENC CHAR(8);
DEFINE i_importe INTEGER;
DEFINE i_Valormax INTEGER;
DEFINE	no_cod_oper CHAR(2);
--Se declaran las variables para utilizar en  las validaciones del bloque

DEFINE	e_tpo_reg CHAR(2);
DEFINE	e_num_secu CHAR(7);
DEFINE	e_cod_oper CHAR(2);
DEFINE	e_cve_ban CHAR(3);
DEFINE	e_sentido CHAR(1);
DEFINE	e_servicio CHAR(1);
DEFINE	e_num_bloq CHAR(7);
DEFINE v_fecha_prese	CHAR(8);
DEFINE	e_cod_divi CHAR(2);
DEFINE	e_cve_rech_bl CHAR(2);
DEFINE	e_modalidad CHAR(1);
DEFINE	e_fut_ccen CHAR(41);
DEFINE	e_fut_banco CHAR(370);

DEFINE vsFlagValUsoFuturo CHAR(5);
DEFINE vsFlagValUsoFuturoBanco CHAR(5);


--Se declaran las variables para utilizar en Detalle
DEFINE vsFlagImporte CHAR(5);
DEFINE vsFechaAplica CHAR(5);
--nombre_arch CHAR(20),

DEFINE	d_tpo_reg CHAR(2);
DEFINE	d_num_secu CHAR(7);
DEFINE	d_cod_oper CHAR(2);
DEFINE	d_cod_divi CHAR(2);
DEFINE	d_fec_trans CHAR(8);
DEFINE	d_ban_pres CHAR(3);
DEFINE	d_ban_rece CHAR(3);
DEFINE	d_importe CHAR(15);
DEFINE	d_futuro_ccen CHAR(16);
DEFINE	d_tpo_opera CHAR(2);
DEFINE	d_fec_aplica CHAR(8);
DEFINE	d_tpo_cta_ord CHAR(2);
DEFINE	d_num_cta_ord CHAR(20);
DEFINE	d_nombre_ord CHAR(40);
DEFINE	d_rfc_ord CHAR(18);
DEFINE	d_tpo_cta_rec CHAR(2);
DEFINE	d_num_cta_rec CHAR(20);
DEFINE	d_nombre_rec CHAR(10);
DEFINE	d_rfc_rec CHAR(18);
--no vienen en la descripcion, pero si en el manual de cecoban
DEFINE	d_ref_serv CHAR(40);
DEFINE	d_nom_tit_serv CHAR(40);
DEFINE	d_imp_iva CHAR(15);
DEFINE	d_ref_nume CHAR(7);
DEFINE	d_ref_leyen CHAR(40);
DEFINE	d_cve_rast CHAR(30);
--Si vienen
DEFINE	d_motivo_dev CHAR(2);
DEFINE	d_fec_pres_ini CHAR(8);
DEFINE	d_futuro_banco CHAR(11);

DEFINE	d_Solicitud_Confirmacion CHAR(1);
DEFINE	d_Ref_COnfirmacion CHAR(30);
DEFINE	d_Uso_Futuro_Cce CHAR(1);
DEFINE	d_Tasa_Tiie_Prom CHAR(7);
DEFINE	d_Dias_Retraso CHAR(1);
DEFINE	d_Imp_Tot_Int CHAR(15);

--No se ocupa para la generacion del archivo
DEFINE	vscve_estatus CHAR(2);
DEFINE	vsfolio_suc CHAR(16);

--Se declaran las variables para utilizar en Sumario de bloque
DEFINE	s_tpo_reg CHAR(2);
DEFINE	s_num_secu CHAR(7);
DEFINE	s_cod_oper CHAR(2);
DEFINE	s_num_bloq CHAR(7);
DEFINE	s_num_oper CHAR(7);
DEFINE	s_imp_oper CHAR(18);
DEFINE	s_uso_fut_ccen CHAR(40);
DEFINE	s_uso_fut_banco CHAR(364);

---Variables a utilizar para validaciones de amarre
DEFINE v_sPriNomb CHAR(1);
DEFINE v_cRespSP  CHAR(5);
DEFINE v_dFechaSp DATE;
DEFINE v_sRetCodSP CHAR(5);
DEFINE v_dFechaReSp DATE;
DEFINE v_secu_bANDera CHAR(7);
DEFINE v_secu_max CHAR(7);
DEFINE v_fecha_dia CHAR(2);
DEFINE v_fecha_mes CHAR(2);
DEFINE v_fecha_ano CHAR(4);
DEFINE v_sValorMax CHAR(15);
DEFINE v_dFechaProce DATE;
DEFINE v_LogTarDeb	INTEGER;
DEFINE v_BancTar 	CHAR(3);
DEFINE v_iCodReSP INTEGER;
DEFINE v_iDigVeSP INTEGER;
DEFINE v_iNombre	INTEGER;
DEFINE v_iBanNume	INTEGER;
DEFINE v_fec_40		CHAR(8);
DEFINE v_iCont_blo	INTEGER;
DEFINE v_SumOper	CHAR(20);
DEFINE v_cRechBlo	CHAR(3);
DEFINE dFechaSis 	DATE;
DEFINE cCicloFech CHAR(1);
DEFINE cBancNom CHAR(3);
DEFINE cDiaNom CHAR(2);
DEFINE cAnoNom CHAR(4);
DEFINE cMesNom CHAR(2);
DEFINE cConseNom CHAR(2);
DEFINE cNomFecha CHAR(20);
DEFINE cCeroTar  CHAR(16);
DEFINE cCeroClabe  CHAR(18);
DEFINE v_cuenta_sp CHAR(18);
DEFINE v_bancoNomb	CHAR(3);
DEFINE v_diablokNomb	CHAR(2);
DEFINE v_dianombre		CHAR(2);
DEFINE v_cfec_presen DATE;
DEFINE v_NombrePruBlo CHAR(20);
DEFINE v_counBloc	INTEGER;
DEFINE v_contaBlco	char(2);


LET vsFlagNumSecuencia = '';
LET vsFlagFechaAplicacion = '';
LET vsFlagNombreOrdenante = '';
LET v_iCodReSP2 = 0;
LET v_iDigVeSP2 = 0;
LET vsFlagNumCtaReceptor = '';
LET vsFlagNombreReceptor = '';
LET vsFlagRef_Serv = '';



LET nom_arch = '';
LET	fec_presen = '';
let	vsCodRet ='00000';
LET v_nivel = '00';
LET v_NombrePruBlo = '';
LET v_contaBlco = '';
LET v_ciclo = 0;
let v_bancorev = '';
let v_ini = 0;
LET v_bancComa = '';
LET v_BancoCoppel = '';
LET v_f_ENC = '';
LET no_cod_oper = '';

--Se Inicializan las variables para utilizar  en las validaciones del bloque
--LET	e_fec_pres = '';
LET	e_tpo_reg = '';
LET	e_num_secu = '';
LET	e_cod_oper = '';
LET	e_cve_ban = '';
LET	e_sentido = '';
LET	e_servicio = '';
LET	e_num_bloq = '';
LET	e_cod_divi = '';
LET	e_cve_rech_bl = '';
LET	e_modalidad = '';
LET	e_fut_ccen = '';
LET	e_fut_banco = '';
LET vsFlagValUsoFuturo = '';
LET vsFlagValUsoFuturoBanco = '';


--Se Inicializan las variables para utilizar en Detalle
LET vsFlagImporte = '';
LET vsFechaAplica = '';

LET	d_tpo_reg = '';
LET	d_num_secu = '';
LET	d_cod_oper = '';
LET	d_cod_divi = '';
LET	d_fec_trans = '';
LET	d_ban_pres = '';
LET	d_ban_rece = '';
LET	d_importe = '';
LET	d_futuro_ccen  = '';
LET	d_tpo_opera = '';
LET	d_fec_aplica = '';
LET	d_tpo_cta_ord = '';
LET	d_num_cta_ord = '';
LET	d_nombre_ord = '';
LET	d_rfc_ord = '';
LET	d_tpo_cta_rec = '';
LET	d_num_cta_rec = '';
LET	d_nombre_rec = '';
LET	d_rfc_rec = '';

LET	d_ref_serv = '';
LET	d_nom_tit_serv = '';
LET	d_imp_iva = '';
LET	d_ref_nume = '';
LET	d_ref_leyen = '';
LET	d_cve_rast = '';
LET	d_motivo_dev = '';
LET	d_fec_pres_ini = '';
LET d_futuro_banco = '';

LET d_Solicitud_Confirmacion = '';
LET d_Ref_COnfirmacion = '';
LET d_Uso_Futuro_Cce = '';
LET d_Tasa_Tiie_Prom = '';
LET d_Dias_Retraso = '';
LET d_Imp_Tot_Int = '';


LET vscve_estatus = '';
LET	vsfolio_suc = '';


--Se Inicializan las variables para utilizar en sumario de bloque
LET	s_tpo_reg = '';
LET	s_num_secu = '';
LET	s_cod_oper = '';
LET	s_num_bloq = '';
LET	s_num_oper = '';
LET	s_imp_oper = '';
LET s_uso_fut_ccen = '';
LET s_uso_fut_banco = '';

--Se valida que los datos no vengan en blancos o null

---SE inicializan las variables que se utlizan para validacion especiales
LET v_cRespSP = '';
LET v_sRetCodSP = '';
LET v_secu_bANDera = '0000002';
LET v_fecha_ano = '';
LET v_fecha_mes = '';
LET v_fecha_dia = '';
LET v_sValorMax = '';
LET v_fec_40 = '';
LET v_cRechBlo = '';
LET cCicloFech = 'S';
LET cBancNom = '';
LET cDiaNom = '';
LET cAnoNom = '';
LET cMesNom = '';
LET cConseNom = '';
LET cNomFecha = '';
LET v_cuenta_sp = '';
LET v_bancoNomb = '';
LET v_dianombre = '';
LET v_dFechaProce = CURRENT;  --'01/01/1900';


--SET DEBUG FILE TO "/dbexport/TEF/trace/TRACEsp_tef_valida_datos.sql";
--SET DEBUG FILE TO "/tmp/Cesar/1221/TEF/TRACEsp_tef_valida_datos.sql";
--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vsCodRet = sql_err;
			RETURN vsCodRet,v_nivel;
		END IF;
	END EXCEPTION;
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--VALIDA LA FECHA
	EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(psFecha_Presentacion,'N') INTO v_cRespSP;
	
	IF (NVL(psTipoArchivo, '') NOT IN ('E','S','R')) THEN --VALIDA EL TIPO DE ARCHIVO
		LET vsCodRet = '00601';
	ELIF (TRIM(NVL(psNombreArchivo, '')) = '') THEN --VALIDA KE NO ESTE EN BLANCO
		LET vsCodRet = '00602';
	ELIF ((v_cRespSP <> '00000') OR (TRIM(NVL(psFecha_Presentacion, '')) = '')) THEN --VALIDA LA FECHA
		LET vsCodRet = '00603';
	ELIF (NVL(piNumArchivo, '') NOT IN ('10','11','60','61','62','63')) THEN --VALIDA EL NUMERO DE ARCHIVO
		--LET vsCodRet = '00618';
		LET vsCodRet = '00604';
	ELIF (NVL(psRol, '') NOT IN ('P','R')) THEN --VALIDA EL EL ROL 
		--LET vsCodRet = '00619';
		LET vsCodRet = '00605';
	ELIF(NOT EXISTS (SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion)) THEN --NO EXISTE EL REGISTRO DEL ENCABEZADO
		LET vsCodRet = '00606';
	ELIF (NOT EXISTS (SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Detalle_Paso WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion)) THEN --NO EXISTE EL REGISTRO DEL DETALLE
		LET vsCodRet = '00607';
	ELIF (NOT EXISTS (SELECT nombre_arch FROM BdiTef:"informix".Tef_Cce_Sumario_Paso WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion)) THEN --NO EXISTE EL REGISTRO DEL SUMARIO
		LET vsCodRet = '00608';
	ELSE -- OK EXISNTEN REGISTROS EN LA 3 TABLAS PARA EL MISMO NOMBRE DE ARCHIVO
		
		LET v_nivel = '02';
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--OBTIENE LOS DATOS DEL ENCABEZADO
		SELECT FIRST 1 fecha_presentacion,tpo_registro,num_secuencia,cod_operacion,cve_banco,sentido,servicio,
		num_bloque,cod_divisa,cve_rechazo_bl,modalidad,uso_futuro_ccen,uso_futuro_banco
		INTO v_fecha_prese,e_tpo_reg, e_num_secu,e_cod_oper,e_cve_ban,e_sentido,e_servicio,
		e_num_bloq,e_cod_divi,e_cve_rech_bl,e_modalidad,e_fut_ccen,e_fut_banco
		FROM BdiTef:"informix".Tef_Cce_Encabezado_Paso 
		WHERE nombre_arch = psNombreArchivo 
		AND fecha_presentacion = psFecha_Presentacion;
		
		
		--OBTIENEN LA CLAVE DE BANCO
		SELECT FIRST 1 Valor INTO v_BancoCoppel FROM BdiTef:"informix".Tef_Parametros WHERE cod_param = '75';
		
		--VALIDA LA FECHA
		EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(e_num_bloq,'N') INTO vsCodRet;
		
		--8--SE VALIDA LA FECHA DE PRESENTACION
		EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(v_fecha_prese) INTO v_cRespSP;
		
		--12--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
		EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(e_fut_ccen,'B') INTO vsFlagValUsoFuturo;
		--13--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
		EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(e_fut_banco,'B') INTO vsFlagValUsoFuturoBanco;
		
		
		IF (vsCodRet <> '00000') THEN -- FECHA NO VALIDA
			LET vsCodRet = '00609';
		ELIF (e_tpo_reg <> '01') THEN --1--VALIDACION DEL TIPO DE REGISTRO
			LET vsCodRet = '00610';
		ELIF (e_num_secu <> '0000001') THEN --2--SE VALIDA EN NUMERO DE SECUENCIA
			LET vsCodRet = '00611';
		ELIF (((SUBSTR(psNombreArchivo,11,2) <> e_cod_oper) AND (SUBSTR(psNombreArchivo,14,2) <> e_cod_oper) ) 
			OR (NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Codigo_Oper  WHERE cod_operacion = e_cod_oper )))  THEN --3--SE VALIDA EL CODIGO DE OPERACION (10,11,60,61,62,63)
			LET vsCodRet = '00612';
		ELIF (SUBSTR(psNombreArchivo,(DECODE(LENGTH(TRIM(psNombreArchivo)),16,4,2)),3) <> v_BancoCoppel)  THEN  ---4--VALIDACION DEL BANCO  ARCHIVO - NOMARCHIVO -BD
			--Ebbbddmmyyyy.oocc 
			--S01137A2.A6121098
			--E13720042011.6001
			LET vsCodRet = '00613';
		ELIF ((e_sentido NOT IN ('S','E','R')) OR (SUBSTR(psNombreArchivo,1,1) NOT IN ('S','E','R'))) THEN --5--VALIDACION DEL SENTIDO    ---VALIDACION DE LA PRIMERA LETRA DEL NOMBRE CON EL SENTIDO
			LET vsCodRet = '00614';
		ELIF (e_servicio <> '2') THEN --6--SE VALIDA EL SERVICIO
			LET vsCodRet = '00615';
		ELIF (SUBSTR(psNombreArchivo,(DECODE(LENGTH(TRIM(psNombreArchivo)),16,15,5)),2) <> SUBSTR(e_num_bloq, (LENGTH(e_num_bloq)-1),2)) THEN --7 ----SE VALIDA QUE EL DIA DEL BLOKE SEA EL MISMO DEL ARCHIVO.
			LET vsCodRet = '00616';
			
		--COMENTADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN
		--PERMITIR EL PROCESO DE ARCHIVOS DE FECHA DISTINTA A LA ACTUAL
		/*
		ELIF ((v_cRespSP <> '00000') 
		OR (psFecha_Presentacion <> v_fecha_prese) 
		OR (NOT EXISTS (SELECT Fecha_proceso FROM BdiTef:"informix".Tef_Procesos 
			WHERE Cve_Proceso  = psNomProceso 
			AND Fecha_Proceso = (SUBSTR(psFecha_Presentacion,5,2) || '/' || SUBSTR(psFecha_Presentacion,7,2) || '/' || SUBSTR(psFecha_Presentacion,1,4)))) 
			) THEN --8--SE VALIDA LA FECHA DE PRESENTACION
			LET vsCodRet = '00617';
		*/
			
		ELIF (e_cod_divi <> '01') THEN --9-- VALIDA EL CODIGO DE DIVISAS
			LET vsCodRet = '00618';
		ELIF (e_cve_rech_bl <> '00') OR (NOT EXISTS(SELECT descripcion FROM  BdiTef:"informix".Tef_Cat_Rechazos WHERE cve_rechazo = e_cve_rech_bl)) THEN --10--VALIDA LA CAUSA DE RECHAZO DE BLOQUE
			LET vsCodRet = '00619';
		ELIF (e_modalidad <> '2') THEN --11--VALIDA LA MODALIDAD
			LET vsCodRet = '00620';
		ELIF (vsFlagValUsoFuturo <> '00000') THEN --12--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
			LET vsCodRet = '00621';
		ELIF (vsFlagValUsoFuturoBanco <> '00000') THEN --13--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
			LET vsCodRet = '00622';
		ELSE -- ENCABEZADO OK
			
			LET v_nivel = '03';
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--15--VALIDACION DEL NUMERO DE SECUENCIA
			SELECT MAX(num_secuencia) INTO v_secu_max FROM   BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion;
			
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--SE TOMA EL VALOR MAXIMO VALOR PERMITIDO ($$$) PARA TRANSACCIONES
			SELECT FIRST 1 Valor INTO v_sValorMax FROM BdiTef:"informix".Tef_Parametros WHERE Cod_Param = '80';
			
			
			--15--VALIDACION DEL NUMERO DE SECUENCIA
			SELECT COUNT(num_secuencia) INTO v_secu_max FROM BdiTef:"informix".Tef_Cce_Detalle_Paso
			WHERE nombre_arch = psNombreArchivo AND fecha_presentacion = psFecha_Presentacion;
			
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--OBTIENE LOS REGISTROS DEL DETALLE
			FOREACH
				SELECT tipo_registro, num_secuencia, cod_operacion, cod_divisa, fecha_trans, banco_presentador, banco_receptor,
						importe, uso_futuro_ccen, tipo_operacion, fecha_aplica, tipo_cta_ord, num_cta_ord, nombre_ord, rfc_ord, tipo_cta_rec, num_cta_rec, nombre_rec,
						rfc_rec, ref_servicio, nombre_titular_serv, importe_iva, ref_numerica, ref_leyenda, clave_rastreo, motivo_dev, fecha_pres_ini, 
						uso_futuro_banco,
						Solicitud_Confirmacion, Ref_COnfirmacion, Uso_Futuro_Cce, Tasa_Tiie_Prom, Dias_Retraso, Imp_Tot_Int,
						cve_Status, folio_suc
				INTO 	d_tpo_reg,d_num_secu,d_cod_oper,d_cod_divi,d_fec_trans,d_ban_pres,d_ban_rece,
						d_importe,d_futuro_ccen,d_tpo_opera,d_fec_aplica,d_tpo_cta_ord,d_num_cta_ord,d_nombre_ord,d_rfc_ord,d_tpo_cta_rec,d_num_cta_rec,d_nombre_rec,
						d_rfc_rec,d_ref_serv,d_nom_tit_serv,d_imp_iva,d_ref_nume,d_ref_leyen,d_cve_rast,d_motivo_dev,d_fec_pres_ini,
						d_futuro_banco,
						d_Solicitud_Confirmacion, d_Ref_COnfirmacion, d_Uso_Futuro_Cce, d_Tasa_Tiie_Prom, d_Dias_Retraso, d_Imp_Tot_Int,
						vscve_estatus,vsfolio_suc
				FROM  BdiTef:"informix".Tef_Cce_Detalle_Paso
				WHERE nombre_arch = psNombreArchivo
				AND fecha_presentacion = psFecha_Presentacion
				ORDER BY num_secuencia
				
				--15--VALIDA LA SECUENCIA
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_num_secu,'N') INTO vsFlagNumSecuencia;
				
				--18-- VALIDA LA FECHA DE TRANSFERENCIA
				IF piNumArchivo <> 10 THEN
				  EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(d_fec_trans) INTO v_cRespSP;
				END IF;
				
				--21--VALIDA EL IMPORTE D_IMPORTE
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_importe,'N') INTO vsFlagImporte;
				
				--22--VALIDA QUE LOS CAMPOS DE USO FUTURO CCE VENGA EN BLANCO
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_futuro_ccen,'B') INTO vsFlagValUsoFuturo;
				
				--24-- VALIDA LA FECHA DE APLICACON
				EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(d_fec_aplica) INTO vsFlagFechaAplicacion;
				
				--26-- VALIDA EL DIGITO VERIFICADOR -ORDENANTE
				IF piNumArchivo <> 10 THEN
					EXECUTE PROCEDURE BdiSpei:"informix".sp_validadv(SUBSTR(d_num_cta_ord,3,18)) INTO v_iCodReSP, v_iDigVeSP;
				END IF;
				--27-- VALIDA QUE EL NOMBRE CONTENGA CARACTERES VALIDOS
				IF piNumArchivo <> 10 THEN
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_nombre_ord,'T') INTO vsFlagNombreOrdenante;
				END IF;
				--30--SE VALIDA  EL NUMERO DE CUENTA DEL RECEPTOR
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_num_cta_rec,'N') INTO vsFlagNumCtaReceptor;
				
				--30-- VALIDA EL DIGITO VERIFICADOR -RECEPTOR
				EXECUTE PROCEDURE BdiSpei:"informix".sp_validadv(SUBSTR(d_num_cta_rec,3,18)) INTO v_iCodReSP2, v_iDigVeSP2;
				
				--31-- VALIDA QUE EL NOMBREDEL RECEPTOR NO VENGA VACIO
				--EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_nombre_rec,'T') INTO vsFlagNombreReceptor;
				
				--33--VALIDA LA REFERENCIA DEL SERVICIO CON EL EMISOR
				--EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_ref_serv,'T') INTO vsFlagRef_Serv;
				
				
				IF (d_tpo_reg <> '02') THEN --- 14--VALIDA EL TIPO DE REGISTRO DE DETALLE
					LET vsCodRet = '00622';
				ELIF ((vsFlagNumSecuencia <> '00000') AND (NOT(d_num_secu::INTEGER BETWEEN 2 AND (v_secu_max::INTEGER + 1))))  THEN --15 VALIDA EL NUMERO DE SECUENCIA
					LET vsCodRet = '00623';
				ELIF (e_cod_oper <>  d_cod_oper) THEN --16-- VALIDA QUE EL CODIGO DE OPERACION SEA IGUAL AL ENCABEZADO
					LET vsCodRet = '00624';
				ELIF (e_cod_divi <> d_cod_divi) THEN --17--VALIDA QUE EL CODIGO DE DIVISA SEA IGUAL AL ENCABEZADO
					LET vsCodRet = '00625';
				ELIF ((v_cRespSP = '00001') OR (v_cRespSP = '00002')) THEN --18-- VALIDA LA FECHA DE TRANSFERENCIA
					LET vsCodRet = '00626';
				ELIF ((EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = d_ban_pres AND flg_tef_r =  '0'  AND flg_tef_p = '0' ))
						OR ((SUBSTR(psNombreArchivo,1,1) = 'S') AND (d_ban_pres = v_BancoCoppel))/*receptor*/ 
						OR ((SUBSTR(psNombreArchivo,1,1) = 'E') AND (d_ban_pres <> v_BancoCoppel)) /*presentador*/) THEN  --19--SE VALIDA QUE EL BANCO SEA EL MISMO QUE EL DEL ENCABEZADO
					LET vsCodRet = '00627';
				ELIF ((EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = d_ban_rece AND flg_tef_r = '0'  AND flg_tef_p = '0' ))
						OR (d_ban_rece = d_ban_pres) 
						OR ((SUBSTR(psNombreArchivo,1,1) = 'S') AND (d_ban_rece <> v_BancoCoppel)) 
						OR ((SUBSTR(psNombreArchivo,1,1) = 'E') AND (d_ban_rece = v_BancoCoppel))) THEN ---20--VALIDACION DEL BANCO RECEPTOR
					LET vsCodRet = '00628';
				ELIF ((vsFlagImporte <> '00000') --ES NUMERICO
						OR ((piNumArchivo IN ('10', '11')) AND (d_importe::INTEGER <> 0)) --VERIFICACION DE CU8ENTAS DEBE DE SER 0
						OR ((piNumArchivo IN ('60','61','62','63')) AND (d_importe::INTEGER = 0)) -- MOVIMIENTO, DEBE DE SER DIFERENNTE DE 0
						OR(((d_importe::INTEGER)/100) > v_sValorMax::INTEGER)) --VALIDA QUE NO SOBREPASE EL VALOR MAXIMO PERMITIDO
						THEN --21 VALIDA EL IMPORTE D_IMPORTE
					LET vsCodRet = '00629';
				ELIF (vsFlagValUsoFuturo <> '00000') THEN --22--VALIDA QUE LOS CAMPOS DE USO FUTURO CCE VENGA EN BLANCO
					LET vsCodRet = '00630';
				ELIF ((piNumArchivo <> 10) and (NOT EXISTS (SELECT Cod_Operacion FROM BdiTef:"informix".Tef_Codigo_Oper WHERE Cod_Operacion = d_cod_oper))) THEN -- 23 VALIDA EL TIPO DE OPERACION
					LET vsCodRet = '00631';
				--ELIF ((vsFlagFechaAplicacion = '00001') OR (vsFlagFechaAplicacion = '00002')) THEN --24-- VALIDA LA FECHA DE APLICACON
				ELIF (vsFlagFechaAplicacion <> '00000') THEN --24-- VALIDA LA FECHA DE APLICACON
				LET vsCodRet = '00632';
				ELIF ((piNumArchivo <> 10) AND (NOT EXISTS(SELECT  descripcion  FROM BdiTef:"informix".Tef_Tipo_Cta WHERE  tipo_cta = d_tpo_cta_ord))) THEN --25--VALIDA EL TIPO DE CUENTA DEL ORDENANTE
					LET vsCodRet = '00633';
				ELIF (((piNumArchivo <> 10) AND ((d_tpo_cta_ord IN ('03', '05')) AND (LENGTH(TRIM(SUBSTR(d_num_cta_ord,5,20))) <> 16))) --VALIDA LA LONGITUD QUE DEBE DE SER DE 16 CARACTERES --tarjeta
						OR ((d_tpo_cta_ord ='40') 
						AND ((LENGTH(TRIM(SUBSTR(d_num_cta_ord,3,20))) <> 18) --VALIDA LA LONGITUD QUE DEBE DE SER DE 18 CARACTERES --cuenta
						OR ((piNumArchivo IN ('11', '61', '62', '63')) AND ((SUBSTR(d_num_cta_ord,3,3) <> d_ban_rece)  --EL BANCO DE LA CUENTA CLABE NO ES EL MISMO BANCO
						OR (NOT EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = SUBSTR(d_num_cta_ord,3,3) )) --NO EXISTE EL BANCO 
						--OR ((v_iCodReSP <> 0) OR (v_iDigVeSP <> 1))
						) ))) OR (d_num_cta_ord = '00000000000000000000') and  (piNumArchivo <> '10')) --DIGITO VERIFICADOR INVALIDO
						THEN -- 26 VALIDA EL DIGITO VERIFICADOR
					LET vsCodRet = '00634';
				ELIF ((piNumArchivo <> 10) AND ((LENGTH(TRIM(d_nombre_ord)) = 0) OR (vsFlagNombreOrdenante <> '00000')))  THEN --27-- VALIDA QUE EL NOMBRE NO VENGA VACIO   -- MENOS EL ARCHIVOS 10
					LET vsCodRet = '00635';
				--ELIF ((piNumArchivo <> 10) AND (TRIM(NVL(d_rfc_ord, '')) = '')) THEN --28--VALIDA EL RFC DEL ORDENANDTE    -- MENOS EL ARCHIVOS 10
					--LET vsCodRet = '00636';--01/07/211			
				ELIF (NOT EXISTS(SELECT descripcion  FROM BdiTef:"informix".Tef_Tipo_Cta WHERE  tipo_cta = d_tpo_cta_rec)) THEN --29--VALIDA EL TIPO DE CUENTA DEL RECEPTOR
					LET vsCodRet = '00637';
				ELIF ((vsFlagNumCtaReceptor <> '00000') -- VALIDA KE CONTENGA NUMEROS
						--OR ((d_tpo_cta_rec = '03') AND (LENGTH(TRIM(SUBSTR(d_num_cta_rec,5,20))) <> 16)) --VALIDA LA LONGITUD QUE DEBE DE SER DE 18 CARACTERES --tarjeta
						--OR ((d_tpo_cta_rec = '40') 
						--AND ((LENGTH(TRIM(SUBSTR(d_num_cta_rec,3,18/*20*/))) <> 18) --VALIDA LA LONGITUD QUE DEBE DE SER DE 18 CARACTERES --cuenta
						--OR ((piNumArchivo IN ('11','61','62','63'))  AND (SUBSTR(d_num_cta_rec,3,3) <> d_ban_pres)) --EL BANCO DE LA CUENTA CLABE NO ES EL MISMO BANCO
						--OR (NOT EXISTS(SELECT descripcion FROM BdInteg:"informix".Si_Bancos WHERE banco = SUBSTR(d_num_cta_rec,3,3))) --NO EXISTE EL BANCO
						------OR ((v_iCodReSP2 <> 0) OR (v_iDigVeSP2 <> 1)) --DIGITO VERIFICADOR INVALIDO
						--))
						) THEN --30--VALIDA  EL NUMERO DE CUENTA DEL RECEPTOR
					LET vsCodRet = '00638';
				--ELIF (LENGTH(TRIM(d_nombre_rec)) = 0) OR (vsFlagNombreReceptor <> '00000')  THEN --31-- VALIDA QUE EL NOMBREDEL RECEPTOR NO VENGA VACIO
					--LET vsCodRet = '00639';
				--ELIF (NVL(d_rfc_rec, '') = '') THEN --32--SE VALIDA EL RFC DEL RECEPTOR
				--	LET vsCodRet = '00640';
				--ELIF ((piNumArchivo <> 10) AND ((LENGTH(TRIM(NVL(d_ref_serv, ''))) = 0) OR (vsFlagRef_Serv <> '00000') )) THEN --33--VALIDA LA REFERENCIA DEL SERVICIO CON EL EMISOR
					--LET vsCodRet = '00641';   --01/07/211
				ELSE --OTRAS VALIDACIONES
					
					LET v_cRespSP = '';
					LET vsCodRet = '00000';
					
					--34--VALIDA EL NOMBRE DEL TITULAR
					--EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_nom_tit_serv,'T') INTO v_cRespSP;--01/07/211
					
					--IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_nom_tit_serv)) = 0) )) THEN --34--VALIDA EL NOMBRE DEL TITULAR
						--LET vsCodRet = '00642';
					--END IF;--01/07/211
					
					--35--VALIDA EL IMPORTE DEL IVA DE LA OPERACION
					/*EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_imp_iva,'N') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (d_imp_iva::FLOAT < 0.0 ) )) THEN --35--VALIDA EL IMPORTE DEL IVA DE LA OPERACION
						LET vsCodRet = '00643';
					END IF;*/
					
					--36--VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
					IF piNumArchivo <> 10 THEN
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_ref_nume,'N') INTO v_cRespSP;
						
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --36--VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
							LET vsCodRet = '00644';
						END IF;
					END IF;
					
					--37-- VALIDA LA REFERENCIA LEYENDA DEL ORDENANTE
					IF piNumArchivo <> 10 THEN
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_ref_leyen,'T') INTO v_cRespSP;
						
						IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_ref_leyen)) = 0) )) THEN --37-- VALIDA LA REFERENCIA LEYENDA DEL ORDENANTE
							LET vsCodRet = '00645';
						END IF;
					END IF;
					
					--38--VALIDA LA CLAVE DE RASTREO
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_cve_rast,'T') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_cve_rast)) = 0) )) THEN --38--VALIDA LA CLAVE DE RASTREO
						LET vsCodRet = '00646';
					END IF;
					
					--39--VALIDA EL MOTIVO DE DEVOLUCION
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_motivo_dev,'N') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND ((v_cRespSP <> '00000') OR (LENGTH(TRIM(d_motivo_dev)) = 0) 
						OR (NOT EXISTS(SELECT descripcion FROM BdiTef:"informix".Tef_Cat_Devoluciones WHERE motivo_dev = d_motivo_dev))) 
						OR (((piNumArchivo = 61) OR (piNumArchivo = 63)) AND (d_motivo_dev = '00'))) THEN --39--VALIDA EL MOTIVO DE DEVOLUCION
						LET vsCodRet = '00647';
					END IF;
					
					--40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_fec_pres_ini,'N') INTO v_cRespSP;
					
					IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
						LET vsCodRet = '00648';
					END IF;
					
					--40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
					EXECUTE PROCEDURE BdiTef:"informix".sp_valida_fecha(d_fec_pres_ini) INTO v_cRespSP;
					IF ((vsCodRet = '00000') AND ((v_cRespSP = '00001') OR (v_cRespSP = '00002'))) THEN --40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
						LET vsCodRet = '00648';
					END IF;
					
					--40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
					IF ((vsCodRet = '00000') AND((piNumArchivo = 60) AND (psFecha_Presentacion <> d_fec_pres_ini))) THEN --40--VALIDA LA FECHA DE PRESENTACION INICIAL  V_FEC_40, D_FEC_PRES_INI
						LET vsCodRet = '00648';
					END IF;
					
					--41--VALIDA SOLICITUD DE CONFIRMACION
					IF ((vsCodRet = '00000') AND (d_Solicitud_Confirmacion NOT IN (' ', '1'))) THEN --36--VALIDA LA REFERENCIA NUMERICA DEL ORDENATNE
						LET vsCodRet = '00649';
					END IF;
					
					--42--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO -11-
					EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_futuro_banco,'B') INTO v_cRespSP;
					IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --42--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO -11-
						LET vsCodRet = '00650';
					END IF;
					
					IF (piNumArchivo = 62) THEN 
						--42--VALIDA REFERENCIA CONFIRMACION
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Ref_COnfirmacion,'T') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --42--VALIDA REFERENCIA CONFIRMACION
							--LET vsCodRet = '00651';
						END IF;
						
						--43--VALIDA QUE LOS CAMPOS DE USO FUTURO CEE VENGAN EN BLANCO -1-
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Uso_Futuro_Cce,'B') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --43--VALIDA QUE LOS CAMPOS DE USO FUTURO CEE VENGAN EN BLANCO -1-
							LET vsCodRet = '00652';
						END IF;
					
					ELIF (piNumArchivo = 63) THEN 
						
						--49--VALIDA TASA TIIE PROMEDIO
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Tasa_Tiie_Prom,'N') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --49--VALIDA TASA TIIE PROMEDIO
							LET vsCodRet = '00653';
						END IF;
						
						--50--VALIDA DIAS DE RETRASO
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Dias_Retraso,'N') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --50--VALIDA DIAS DE RETRASO
							LET vsCodRet = '00654';
						END IF;
						
						--51--VALIDA IMPORTE TOTAL INTERES
						EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(d_Imp_Tot_Int,'N') INTO v_cRespSP;
						IF ((vsCodRet = '00000') AND (v_cRespSP <> '00000')) THEN --51--VALIDA IMPORTE TOTAL INTERES
							LET vsCodRet = '00655';
						END IF;
						
					END IF;
					
					
				END IF;
				
				IF (vsCodRet <> '00000') THEN -- INDICA EL ERROR Y TERMINA LA VALIDACION DEL ARCHIVO
					RETURN vsCodRet, v_nivel;
				END IF;
				
			END FOREACH;
			
			LET v_nivel = '04';
			IF (vsCodRet = '00000') THEN 
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				----OBTIENE EL REGISTRO DEL SUMARIO DE LA TEF_CCE_SUMARIO
				SELECT tipo_registro, num_secuencia, cod_operacion, num_bloque, num_operaciones, imp_operaciones,uso_futuro_ccen, uso_futuro_banco
				INTO s_tpo_reg,s_num_secu,s_cod_oper,s_num_bloq,s_num_oper,s_imp_oper,s_uso_fut_ccen,s_uso_fut_banco
				FROM BdiTef:"informix".Tef_Cce_Sumario_Paso
				WHERE nombre_arch = psNombreArchivo
				AND fecha_presentacion = psFecha_Presentacion;
				
				--46--VALIDA QUE EL NUMERO TOTAL DE OPERACIONES EN EL BLOQUE CORRESPONDA CON LAS DEL DETALLE
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_num_oper,'N') INTO v_cRespSP;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				
				--47--VALIDA QUE EL IMPORTE TOTAL DE OPERACIOENS 
				SELECT SUM(importe::BIGINT) INTO v_SumOper
				FROM BdiTef:"informix".Tef_Cce_Detalle_Paso  
				WHERE nombre_arch = psNombreArchivo 
				AND fecha_presentacion = psFecha_Presentacion;
				
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_imp_oper,'N') INTO v_cRespSP;
				
				--48--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_uso_fut_ccen,'B') INTO vsFlagValUsoFuturo;
				
				--49--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
				EXECUTE PROCEDURE BdiTef:"informix".sp_Valida_Cadena(s_uso_fut_banco,'B') INTO vsFlagValUsoFuturoBanco;
				
				
				IF (s_tpo_reg <> '09') THEN --42 -- VALIDA EL TIPO DE REIGISTRO DE SUMARIO
					LET vsCodRet = '00656';
				ELIF (s_num_secu::INTEGER <> (v_secu_max::INTEGER + 2)) THEN --43--VALIDA QUE CONCUERDE EL NUMERO DE SECUENCIA CON EL CONSECUTIVO
					LET vsCodRet = '00657';
				ELIF (s_cod_oper <> e_cod_oper) THEN --44--VALIDA QUE LOS CODIGOS DE OPERACION SEAN IGUALES
					LET vsCodRet = '00658';
				ELIF (s_num_bloq <> e_num_bloq) THEN --45--VALIDA QUE EL NUMERO DE BLOQUE SEA IGUAL AL ENCABEZADO
					LET vsCodRet = '00659';
				ELIF ((v_cRespSP <> '00000') OR (s_num_oper::INTEGER <> v_secu_max::INTEGER)) THEN --46--VALIDA QUE EL NUMERO TOTAL DE OPERACIONES EN EL BLOQUE CORRESPONDA CON LAS DEL DETALLE
					LET vsCodRet = '00660';
				ELIF ((LENGTH(s_imp_oper) <> 18) OR (s_imp_oper::BIGINT <> v_SumOper) ) THEN --47--SE VALIDA QUE EL IMPORTE TOTAL DE OPERACIOENS SEA MENOR DE 18 DIGITOS Y CORRESPONDA A LA SUMATORIA DE LIOS IMPORTES DEL BLOQUE DE DETALLE
					LET vsCodRet = '00661';
				ELIF (vsFlagValUsoFuturo <> '00000') THEN --48--VALIDA QUE LOS CAMPOS DE USO FUTURO VENGAN EN BLANCO
					LET vsCodRet = '00662';
				ELIF (vsFlagValUsoFuturoBanco <> '00000') THEN --49--VALIDA QUE LOS CAMPOS DE USO FUTURO BANCO VENGAN EN BLANCO
					LET vsCodRet = '00663';
				END IF;
				
			END IF;
			
		END IF;
		
		--Ebbbddmmyyyy.oocc  --17
		--E01bbbAs.tffddcc --16
		
	END IF;
	
	RETURN vsCodRet,v_nivel;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: PROCEDIMIENTO PARA VALIDAR LOS DATOS EN LAS TABLAS DE PASO.',
'Fecha: 2011/03/15',
'Version: 20110315.1220',
'BD: BdiTef', 
'',
'MODIFICACION: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: SE OMITIERON LA VALIDACION 00635 Y 00636 PARA LOS ARCHIVOS 10 DEBIDO A QUE NO SON OBLIGATORIOS PARA ESTE ARCHIVO.',
'Fecha: 2011/06/29',
'Version: 20110629.1200',
'BD: BdiTef',
'',
'Modificado: Casanova Edeza HÃÂ©ctor Juan',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: MODIFICADO A PETICION DE JAIME GONZALEZ PARA LA FASE 2 DE PRUEBAS CON CECOBAN.',
'Fecha: 2011/09/29',
'Version: 20110929.1534',
'BD: BdiTef';

create procedure "informix".cal_fechapre(
                       pempresa         char(3),
                       pcvebanco   	char(3),
                       pnumcuenta   	char(20),
                       pnumcheque   	char(7),
                       pfechaofi	date)
                       RETURNING char(5),date;  

   DEFINE v_codret 	char(5);
   DEFINE v_fechapre 	date;
   DEFINE v_horacheque 	char(5);
   DEFINE v_paramhora  	char(5);
   DEFINE v_esferiadox 	char(1);
   DEFINE sql_err,isam_err int;   
   DEFINE inumcheque INTEGER;
   DEFINE inumcuenta DECIMAL(20,0);


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fechapre    = "";
   let inumcheque = 0;
   let inumcuenta = 0;

   let v_horacheque = '';

   let v_paramhora  = '';
   let v_esferiadox = '';
   let sql_err      = 0;
   let isam_err     = 0;   


BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret,v_fechapre;
      end if;
   end exception;

  --set debug file to "/resplogifx/conciliachq/cal_fechapre.txt";
  --trace on;

set isolation to dirty read;
set lock mode to wait 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    --let pempresa = '001';

	IF  pempresa    	is null or
		pcvebanco       is null or
		pnumcuenta      is null or
		pnumcheque      is null or
		pfechaofi	    is null THEN
	
	   -- datos de entrada incompletos
	   
	   LET v_codret = 210; 
	   RETURN v_codret, v_fechapre; 
	END IF;


-- obtener el parametro de la hora tope t+1
	
	select valor
	into v_paramhora
	from cce_param
	where empresa = pempresa
	and cod_param=1;

	IF v_paramhora is null THEN
	   -- no existe el parametro en cce_param
	   LET v_codret = 220; 
	   RETURN v_codret, v_fechapre; 	
	END IF;


-- obtener la hora de presentacion del cheque
	let pcvebanco = pcvebanco;
	let pnumcuenta = pnumcuenta;
	let pnumcheque = pnumcheque;
	let pfechaofi = pfechaofi;
    
    let inumcheque = pnumcheque;
    let inumcuenta = pnumcuenta;
	
	IF pcvebanco <> '137'THEN
	
		-- MOHA
		select {+INDEX(bdicheq:sc_docret_sbc idx_docret5)} to_char(fech_hor,'%H:%M')
		into v_horacheque
		from bdicheq:sc_docret_sbc  --MOHA
		where empresa=pempresa
		and banco = pcvebanco
		and numcuenta = inumcuenta
		and num_chq = inumcheque
		and cancelado = "T"
		and fecha_alta = pfechaofi;
	

		IF v_horacheque is null THEN
			-- no existe el cheque en central
			LET v_codret = 230; 
			RETURN v_codret, v_fechapre; 	
		END IF;
		
	END IF;	

-- validar feriado, sab o dom

	select "1"
	into v_esferiadox
	from bdinteg:si_feriado
	where fecha=pfechaofi;
	
	IF v_esferiadox is null THEN
		LET v_esferiadox = "0";
	END IF


	
	-- cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
	
	IF v_esferiadox ="1" 
	   or to_char(pfechaofi,"%A") = "Saturday" 
	   or to_char(pfechaofi,"%A") = "Sunday" 
	   or v_horacheque > v_paramhora THEN
	   
		-- calcular la fecha correcta
		call cal_fecha_pre_fh(pfechaofi)
		returning v_codret,v_fechapre;	
		RETURN v_codret,v_fechapre;
		
	END IF

	LET v_fechapre = pfechaofi;	

END;    

RETURN v_codret,v_fechapre;

END PROCEDURE;