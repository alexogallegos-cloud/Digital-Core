CREATE PROCEDURE "informix".sp_domi_presentador ( psNomArchivo CHAR(20), psNumEmpleado CHAR (8))
RETURNING CHAR (20) AS Nom_Archivo, CHAR (5) AS Codigo_Respuesta, CHAR (100) AS Mensaje_Respuesta;

--****************************************************************************************************
-- DESCRIPCION:  SP PRINCIPAL DE DOMICILIACION -- PRESENTADOR
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 20/07/2009
-- BD: BdiDomi
-- SISTEMA : Domiciliacion
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
DEFINE vSFecha_aplica CHAR(8);
DEFINE vdFecha_aplicaDe DATE;
DEFINE vsMensaje CHAR (80) ;
DEFINE vsRuta CHAR (100);

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

DEFINE vsNomProceso CHAR (20);
DEFINE vsEstatusTemp CHAR(1);
DEFINE cCuentaAbono_Prov	CHAR(20);
DEFINE cNumCteCoppel		CHAR(20);
DEFINE cNom_Arch_Salida		CHAR(20);
DEFINE cCodret				CHAR(5);

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
LET vSFecha_aplica = '';
LET vsMensaje = '';
LET vsRuta = '';

LET vsCodRetorno = '00000';
LET vsCodRetorno2 = '';
LET vsMensaje_Respuesta = '';
LET vsValorParam = '';
LET vsNomArchivo = '';
LET vsNomArchivo11 = '';
LET vsNomArchivo31 = '';
LET vsNomArchivo32 = '';
LET viContador = 0;
LET vdtFecha = CURRENT::DATE;
LET vdFecha_aplicaDe = CURRENT::DATE;

LET vsNomProceso = '';
LET vsEstatusTemp = '';
LET cCuentaAbono_Prov = '';
LET cNumCteCoppel = '';
LET cNom_Arch_Salida = '';
LET cCodret = '';

LET visqlerr = 0;


BEGIN

	ON EXCEPTION SET visqlerr   --CONTROL DE ERRORES
	 
		EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomArchivo), vsDescripcionProceso, 
		sERROR, visqlerr, psNumEmpleado, 'ERROR NO CONTROLADO', TRIM(vsNomArchivo), vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
		
		LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO(' || visqlerr || ') ARCHIVO: ' || TRIM(vsNomArchivo) || 'PROCESO: ' || TRIM(vsDescripcionProceso) ;
		
		RETURN vsNomArchivo, visqlerr, vsMensaje_Respuesta ;
		
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysdomi/sp_domi_presentador.out";
	--TRACE ON;
	
--F ( psNumEmpleado = '99999999' ) THEN
		--SET DEBUG FILE TO '/home/sysdomi/TraceDomi_Presentador.out';
		--TRACE ON ;
	--D IF ;
	
	LET vsDescripcionProceso = 'Validacion de numero de empleado.';
	EXECUTE PROCEDURE BdiDomi:Sp_Valida_Cadena(TRIM(psNumEmpleado),'T') INTO vsCodRetorno;
	
	LET vsDescripcionProceso = 'Validacion de parametros.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01') THEN -- Valida que exista el parametro RUTA ARCHIVO PROCESAR
		LET vsCodRetorno = '01401';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '02') THEN -- Valida que exista el parametro RUTA ARCHIVO RESPUESTA
		LET vsCodRetorno = '01402';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '03') THEN -- Valida que exista el parametro RUTA ARCHIVOS PROCESADOS
		LET vsCodRetorno = '01403';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '04') THEN -- Valida que exista el parametro RUTA ARCHIVOS ERRONEOS
		LET vsCodRetorno = '01404';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '05') THEN -- Valida que exista el parametro CLAVE BANCARIA BANCOPPEL
		LET vsCodRetorno = '01405';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '06') THEN -- Valida que exista el parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '10106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '43') THEN -- Valida que exista el NUEVO parametro BIN CORRESPONDIENTE TARJETA DEBITO
		LET vsCodRetorno = '10106';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '07') THEN -- Valida que exista el parametro SUCURSAL CONTABLE DOMI
		LET vsCodRetorno = '01407';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '08') THEN -- Valida que exista el parametro TRANSACCION DE CARGO POR DOMI
		LET vsCodRetorno = '01408';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '09') THEN -- Valida que exista el parametro TRANSACCION DE ABONO
		LET vsCodRetorno = '01409';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '10') THEN -- Valida que exista el parametro IMPORTE MAXIMO CECOBAN
		LET vsCodRetorno = '01410';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '11') THEN -- Valida que exista el parametro MAXIMO DE RECHAZOS PERMITIDOS
		LET vsCodRetorno = '01411';
	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '12') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
		LET vsCodRetorno = '01412';
--	ELIF NOT EXISTS (SELECT Valor FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '13') THEN -- Valida que exista el parametro PRODUCTOS PERMITIDOS PARA DOMI
--		LET vsCodRetorno = '01413';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '01414';
	ELIF (TRIM(psNumEmpleado) = '') THEN --NUMERO DE EMPRLEADO VACIO
		LET vsCodRetorno = '01415';
	ELIF (LENGTH(TRIM(psNumEmpleado)) NOT IN(7,8)) THEN --NUMERO DE EMPLEADO NO CONTIENE LOS 8 DIGITOS REQUERIDOS
		LET vsCodRetorno = '01416';
	ELIF (vsCodRetorno <> '00000') THEN --ERROR EL NUMERO DE EMPLEADO CONTIENE  CARACTERES INVALIDOS
		LET vsCodRetorno = '01417';
	ELIF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(psNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
		LET vsCodRetorno = '00132';
	ELSE --TODO LOS PARAMETROS EXISTEN
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT LIMIT 1 Fecha_Hoy INTO vdtFecha FROM BdiCheq:Sc_Fechas; 
		
		SELECT LIMIT 1 TRIM(valor)
		INTO vsValorParam
		FROM bdidomi: dom_parametros
		WHERE cod_param = "05";
		
		EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0')) INTO vsCodRetorno;
		
		LET vsFecha_Presentacion = LPAD (YEAR(vdtFecha), 4, '0') || LPAD (MONTH(vdtFecha), 2, '0') || LPAD (DAY(vdtFecha), 2, '0');
		
		IF (vsCodRetorno <> '00000') THEN --DIA NO LABORAL
			LET vsCodRetorno = '01413';
		ELSE --DIA LABORAL
			LET vsCodRetorno = '00000';
		END IF;
		
	END IF;
	
	IF (vsCodRetorno = '00000') THEN --TODO LOS PARAMETROS EXISTEN

		LET viContador = 0;
		LET vsFlagTipoProceso = 'A';
		
		WHILE ((viContador < 5) AND (vsFlagTipoProceso = 'A'))  --VERIFICA LA EXISTENCIA DE LOS 2 TIPOS DE ARCHIVO A PROCESAR
			
			LET vsDescripcionProceso = 'Obtencion de nombre de Archivo';
			
			LET vsNomProceso = '';
			
			LET viContador = viContador + 1;
			
			IF (TRIM(psNomArchivo) = '') THEN --Valida si es una corrida Automatica. --SIN NOMBRE DE ARCHIVO
				--OBTIENE EL NOPMBRE DEL ARCHIVO ESPERADO
				
				LET vsFlagTipoProceso = 'A'; --AUTOMATICO
				
				IF (viContador = 1) THEN --ARCHIVO 11
					LET viTipoArchivo = 11;
				ELIF (viContador = 2) THEN -- ARCHIVO 31
					LET viTipoArchivo = 31;
				ELIF (viContador = 3) THEN -- ARCHIVO 32
					LET viTipoArchivo = 32;
				ELIF (viContador = 4) THEN -- ARCHIVO 34
					LET viTipoArchivo = 34;
				ELIF (viContador = 5) THEN -- ARCHIVO 36
					LET viTipoArchivo = 36;
				ELSE --NINGUN TIPO DEFINIDO
					LET viTipoArchivo = 0;
				END IF;
					
					
				LET vsNomArchivo = 'S' --CONSTANTE
								|| '01'--CONSTANTE
								|| TRIM(vsValorParam) --ID BANCARIA BANCOPPEL 137
								|| 'A' --CONSTANTE 
								|| '2' --DOMICILIACION EN MONEDA NAC. 
								|| '.' --CONSTANTE
								|| 'A' --ARCHIVO DE DATOS
								|| viTipoArchivo::CHAR(2)
								|| LPAD(DAY(vdtFecha), 2, '0') --FECHA DEL ARCHIVO DIA DEL MES --DD--
								|| '98'; --SECUENCIA DEL ARCHIVO 98 PARA AUTOMATICO
						
			ELSE -- Corrida Manual.  -- INDICA EL NOMBRE DEL ARCHIVO.
				
				LET vsFlagTipoProceso = 'M'; --MANUAL
				
				IF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '11' ) THEN --ARCHIVO 11
					LET viTipoArchivo = 11;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '31' ) THEN --ARCHIVO 31
					LET viTipoArchivo = 31;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '32' ) THEN --ARCHIVO 32
					LET viTipoArchivo = 32;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '34' ) THEN --ARCHIVO 34
					LET viTipoArchivo = 34;
				ELIF ( SUBSTRING (TRIM(psNomArchivo) FROM 11 FOR 2) = '36' ) THEN --ARCHIVO 36
					LET viTipoArchivo = 36;
				ELSE --ARCHIVO NO VALIDO
					LET viTipoArchivo = 0;
				END IF;
					
				LET vsNomArchivo = TRIM(psNomArchivo);
				
			END IF;
			
			IF (LENGTH (TRIM(psNomArchivo)) >= 16) THEN --VALIDA EL EL NOMBRE DEL ARCHIVO POSEA LA EXTENCION ADECUADA
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || SUBSTRING (TRIM(psNomArchivo) FROM 15 FOR 2);
			ELSE -- ERROR DE LONGITUD DE NOMBRE DE ARCHIVO, ARCHIVO NO RECONOCIDO
				LET vsNomProceso = 'RECARCH_' || LPAD (viTipoArchivo, 2, '0') || '.' || '98';
			END IF ;
			
			LET vsDescripcionProceso = 'Validacion de nombre de archivo';
			--VALIDA LA INTEGRIDAD DEL NOMBRE DEL ARCHIVO
			EXECUTE PROCEDURE BdiDomi:Sp_Domi_ValidarNombreArchivos( viTipoArchivo, 'S', vsNomArchivo) INTO vsCodRetorno;
			
			IF (vsCodRetorno = '00000') THEN --NOMBRE DE ARCHIVO OK
			
				LET vsDescripcionProceso = 'Validacion de procesamientos previos.';
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF EXISTS(SELECT Cve_Proceso FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) ) THEN  --VALIDA SI EXISTE EL REGISTRO DE LA OPERACION
					
					SELECT LIMIT 1 Estatus INTO vsEstatusTemp FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso);
					
					IF (vsEstatusTemp = sFINALIZADO) THEN --EL ARCHIVO FUE PROCESADO PREVIAMENTE
						LET vsCodRetorno = '01419';
						EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
					
						INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Presentador', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
						
					ELIF (vsEstatusTemp = sPROCESANDO) THEN --EL ARCHIVO SE ENCUENTRA PROCESANDO
						LET vsCodRetorno = '01420';
						
						EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
					
						INSERT INTO BdiDomi:Dom_Errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
						VALUES (CURRENT, CURRENT HOUR TO FRACTION, vsCodRetorno, vsNomArchivo, 'sp_Domi_Presentador', vsMensaje_Respuesta, psNumEmpleado, CURRENT);
						
					ELIF (vsEstatusTemp = sERROR) THEN --EL ARCHIVOFUE PROCESADO CON ERROR 
						--CREA REGISTRO DEL PROCESO DEL ARCHIVO
						LET vsDescripcionProceso = 'Registro de Reproceso del Archivo.';
						
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
					END IF;
				
				ELSE --EL REGISTRO NO EXISTE
					--CREA REGISTRO DEL PROCESO DEL ARCHIVO
					LET vsDescripcionProceso = 'Registro de Procesamiento del Archivo.';
					
					EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
					sPROCESANDO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*NO GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
					
				END IF;
				
				IF (vsCodRetorno = '00000') THEN -- VALIDA SI EL ARCHIVO ES APTO ÃÂÃÂÃÂÃÂ´PARA SER PROCESADO
				
					LET vsDescripcionProceso = 'Borrado de tablas de paso';
					--LIMPIA LAS TABLAS DE PARA PROCESAR EL NUEVOA ARCHIVO
					EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), '', 'B') INTO vsCodRetorno;
					
					IF (vsCodRetorno = '00000') THEN -- VALIDA KE LAS TABLAS SE LIMPIARON CORRECTAMENTE 
					
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;
						SELECT LIMIT 1 Valor INTO vsRuta FROM BdiDomi:Dom_Parametros WHERE Cod_Param = '01'; -- RUTA ARCHIVO PROCESAR
						
						--VALIDA QUE EL ARCHIVO EXISTA EN EL REPOSITORIO DE PROCESO
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_BuscarArchivo( TRIM(vsRuta), TRIM(vsNomArchivo)) INTO vsCodRetorno, vsFlagUnico;
						
						IF ((vsCodRetorno = '00000') AND (vsFlagUnico = 'V')) THEN --VALIDA QUE EXISTA EL ARCHIVO EN EL REPOSITORIO
						
							LET vsDescripcionProceso = 'Carga del archivo a las tablas de paso';
							--CARGA EL ARCHIVO A LAS TABLAS
							EXECUTE PROCEDURE BdiDomi:sp_Domi_SubirArchivos(vsFlagTipoProceso, '01'/*RUTA ARCHIVO PROCESAR*/, TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
													
							IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO SE CARGO CORRECTAMENTE A LAS TABLAS
								
								SET LOCK MODE TO WAIT 3;
								SET ISOLATION TO DIRTY READ;
								SELECT LIMIT 1 Fecha_Presentacion INTO vsFecha_Presentacion FROM BdiDomi:Dom_cce_Encabezado_Paso WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
								
								UPDATE bdidomi: dom_cce_archivos SET fecha_presentacion = vsFecha_Presentacion where Nombre_Arch = TRIM(vsNomArchivo) AND fecha_presentacion = "";
								LET vsDescripcionProceso = 'Validacion de Integridad del Archivo.';
								--INTEGRIDAD DEL ARCHIVO
								EXECUTE PROCEDURE BdiDomi:Sp_Domi_Valida_Datos( TRIM(vsNomArchivo), vsFecha_Presentacion, 'S' /*SALIDA CECOBAN*/, viTipoArchivo, 'R' /*RECEPTOR*/, TRIM(vsNomProceso) ) INTO vsCodRetorno, vsBloque;
								
								IF (vsCodRetorno = '00000') THEN --VALIDA LA INTEGRIDAD DEL ARCHIVO
								
									IF (viTipoArchivo = 34) THEN --ARCHIVO 34
									
										SELECT MAX(fecha_aplica) INTO vSFecha_aplica 
										FROM bdidomi:dom_cce_detalle_paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
									
									ELSE
									
										SELECT unique(fecha_aplica) INTO vSFecha_aplica 
										FROM bdidomi:dom_cce_detalle_paso WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
									
									END IF;
										
									LET vdFecha_aplicaDe = Substr(vSFecha_aplica,5,2) || "/" || Substr(vSFecha_aplica,7,2) || "/" || Substr(vSFecha_aplica,1,4);
									
									UPDATE bdidomi: dom_cce_archivos SET fecha_aplicacion = vdFecha_aplicaDe 
									WHERE Nombre_Arch = TRIM(vsNomArchivo)  AND fecha_presentacion = vsFecha_Presentacion;
										
									LET vsDescripcionProceso = 'Procesamiento del Archivo Original.';
									IF (viTipoArchivo = 11) THEN --ARCHIVO 11
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo11 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE "informix".Sp_Domi_ProcesarArchivo11 ('02', TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) AND motivo_dev = '99' ;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '02' WHERE Nombre_Arch = TRIM(vsNomArchivo) AND motivo_dev <> '99';
									ELIF (viTipoArchivo = 31) THEN --ARCHIVO 31 
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo31 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE Sp_Domi_ProcesarArchivo31(TRIM(vsNomArchivo), vsFecha_Presentacion, psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '02' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									ELIF (viTipoArchivo = 32) THEN --ARCHIVO 32
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo32 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo32 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									ELIF (viTipoArchivo = 34) THEN --ARCHIVO 34
										--EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo34 (TRIM(vsNomArchivo)) INTO vsCodRetorno;
										EXECUTE PROCEDURE sp_domi_ProcesarArchivo34 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno, vsMensaje;
										IF (vsCodRetorno = '00000') THEN
											UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
										END IF ;
									ELIF (viTipoArchivo = 36) THEN --ARCHIVO 36
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_ProcesarArchivo36 (TRIM(vsNomArchivo), psNumEmpleado) INTO vsCodRetorno;
										UPDATE BdiDomi:Dom_CCE_Detalle_Paso SET cve_Estatus = '01' WHERE Nombre_Arch = TRIM(vsNomArchivo) ;
									END IF;
									
									IF (vsCodRetorno = '00000') THEN --VALIDA KE EL ARCHIVO SE PROCESO CORRECTAMENTE
										
										LET vsDescripcionProceso = 'Mover Registros Procesados a la Tabla de Historico.';
										--ARCHIVO ORIGINAL
										--EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vdtFecha, 'T') INTO vsCodRetorno;
										EXECUTE PROCEDURE BdiDomi:sp_Domi_MoverRegistrosHist (TRIM (vsNomArchivo), vsFecha_Presentacion, 'T') INTO vsCodRetorno;
										
										IF (vsCodRetorno = '00000') THEN -- VALIDA QUE LOS DATOS DEL ARCHIVO SE TRANSFIRIERON CORRECTAMENTE A LOS HISTORICOS
											
											LET vsDescripcionProceso = 'Mover Archivo Procesado al Repositorio Historico.';
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '03' /*RUTA ARCVHIVOS PROCESADOS*/ ) INTO vsCodRetorno;
											
											IF (vsCodRetorno = '00000') THEN -- VALIDA KE EL ARCHIVO ORIGINAL SE PASO CORRECTAMENTE AL REPOSITORIO HISTORICO
												--GUARDA BITACORA EXITO
												LET vsDescripcionProceso = 'Domiciliacion Finalizada Exitosamente.';
												LET vsCodRetorno = '00000';
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sFINALIZADO, vsCodRetorno, psNumEmpleado, 'sp_Domi_Receptor', TRIM(vsNomArchivo), vsFecha_Presentacion, '02'/*EXITO*/ ) INTO vsCodRetorno2;
												
												EXECUTE PROCEDURE Sp_Domi_GuardarCCEArchivos (psNumEmpleado, TRIM (vsNomArchivo), vsFecha_Presentacion, '02') INTO vsCodRetorno2;
												
											ELSE --ERROR DE PASO DE ARCHIVO ORIGINAL AL REPOSITORIO DE HISTORICO
												--GUARDAR BITACORA
												EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
												sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_MoverArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/* GUARDAR CCE_ARCHIVO*/) INTO vsCodRetorno2;
												LET vsCodRetorno = '01430';
											END IF;
											
										ELSE --ERROR AL MOVER LOS REGISTROS DEL ARCHIVO ORIGINAL AL HITORICO
											--GUARDAR BITACORA
											EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_MoverRegistrosHist', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/* GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
											LET vsCodRetorno = '01424';
										END IF;
										
									ELSE --ERROR AL PROCESAR EL ARCHIVO
										
										--GUARDAR BITACORA
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
											sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ProcesarArchivo' || viTipoArchivo::CHAR(2), TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/* RECHAZADO*/ ) INTO vsCodRetorno2;
										
										LET vsCodRetorno = '01423';
									END IF;
									
								ELSE --ERROR DE INTEGRIDAD EN EL ARCHIVO
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_Valida_Datos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/* RECHAZADO*/) INTO vsCodRetorno2;
									
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_MoverArchivos (TRIM (vsNomArchivo), '01' /*RUTA  ARCHIVO PROCESAR*/, '04' /*RUTA ARCVHIVOS ERRONEOS*/ ) INTO vsCodRetorno;
									
									IF (vsCodRetorno <> '00000') THEN --ERROR DE TRANSFERENCIA DE ARCHIVO
										EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
										sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '03'/*RECHAZADO*/ ) INTO vsCodRetorno2;
									END IF; 
									
									LET vsCodRetorno = '01422';
								END IF;
								
							ELSE -- ERROR AL CARGAR EL ARCHIVO A LAS TABLAS DE PASO
								IF (vsCodRetorno = '00411') THEN
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
									LET vsCodRetorno = '01426';								
								ELSE										
									--GUARDAR BITACORA
									EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
									sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
									LET vsCodRetorno = '01421';										
								END IF;									
							END IF;						
														
						ELSE --NO EXISTE EL ARCHIVO
							EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
							sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_BuscarArchivo', TRIM(vsNomArchivo) , vsFecha_Presentacion, '11'/*NO GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
							LET vsCodRetorno = '01426';
						END IF;
					ELSE -- ERROR AL LIMPIAR LAS TABLAS
						--GUARDAR BITACORA
						EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
						sERROR, vsCodRetorno, psNumEmpleado, 'sp_Domi_SubirArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
						LET vsCodRetorno = '01425';
					END IF; 
				ELSE --EL ARCHIVO NO ES APTO PARA SER PROCESADO
				
				END IF;
			ELSE -- NOMBRE DE ARCHIVO ERRONEO
				--GRABAR EN LA BITACORA  vsCodRetorno
				EXECUTE PROCEDURE BdiDomi:Sp_Domi_Bitacora(vsFlagTipoProceso, CURRENT::DATE, TRIM(vsNomProceso), vsDescripcionProceso, 
				sERROR, vsCodRetorno, psNumEmpleado, 'Sp_Domi_ValidarNombreArchivos', TRIM(vsNomArchivo), vsFecha_Presentacion, '01'/*GUARDAR CCE_ARCHIVO*/ ) INTO vsCodRetorno2;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
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
				
				LET vsCodRetorno = '01418';
			END IF;
		
			EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
			RETURN vsNomArchivo, vsCodRetorno, vsMensaje_Respuesta WITH RESUME; 
			
			IF EXISTS(SELECT descripcion FROM BdiDomi:Dom_Procesos WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ) THEN  --EL ARCHIVO SE ENCUENTRA PROCESANDO
				IF (vsCodRetorno <> '01420') THEN --VALIDA SI EL ERROR ES DISTINTO DE 'PROCESANDO'
					UPDATE BdiDomi:Dom_Procesos SET Estatus = sERROR WHERE Fecha_Proceso = vdtFecha AND TRIM(Cve_Proceso) = TRIM(vsNomProceso) AND Estatus = sPROCESANDO ;
				END IF;
			END IF;
			
		END WHILE;
		
		--SE OBTIENE NUMERO DE CLIENTE COPPEL
		SELECT TRIM(valor) 
		INTO cNumCteCoppel FROM dom_parametros
		WHERE cod_param = '45';
		
		--SE OBTIENE NUMERO DE CUENTA COPPEL
		SELECT TRIM(valor) 
		INTO cCuentaAbono_Prov FROM dom_parametros
		WHERE cod_param = '46';
				
		LET cNom_Arch_Salida = 	'S'||
								TRIM(cNumCteCoppel)||
								'D'||
								LPAD(DAY(vdtFecha),2,'0') || 	LPAD(MONTH(vdtFecha),2,'0') || SUBSTR(YEAR(vdtFecha)::CHAR(4),3,2)||
								'.'||
								'01';
								
		IF EXISTS(SELECT 1 FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida) THEN
			
			IF EXISTS (SELECT 1 FROM dom_cte_archivos WHERE nombre_arch = cNom_Arch_Salida) THEN
				DELETE FROM  dom_cte_sumario WHERE nombre_arch = cNom_Arch_Salida;
				DELETE FROM  dom_cte_encabezado WHERE nombre_arch = cNom_Arch_Salida;
				DELETE FROM  dom_cte_archivos WHERE nombre_arch = cNom_Arch_Salida;
			END IF;
			
			--INSERTA EN ARCHIVOS
			INSERT INTO dom_cte_archivos(nombre_arch, fecha_envio, num_cte, fecha_carga, cve_status, user_insert, fecha_insert)
			VALUES (cNom_Arch_Salida, vdtFecha, cNumCteCoppel, vdtFecha, '01', psNumEmpleado, CURRENT::DATE);
			
			LET cNumCteCoppel = LPAD(TRIM(cNumCteCoppel), 20,'0');
			
			--INSERTA EN ENCABEZADO
			INSERT INTO dom_cte_encabezado(nombre_arch, fecha_envio, tipo_registro, num_cte, cuenta_abono, 
						num_operaciones, 
						fecha_inicial, fecha_final, user_insert, fecha_insert)
			SELECT LIMIT 1 nombre_arch, vdtFecha, 'E', cNumCteCoppel, LPAD(TRIM(cCuentaAbono_Prov),20,'0'), 
				   LPAD((SELECT COUNT(*)	FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),8,'0'),
				   (SELECT MIN(fecha_cargo) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
				   (SELECT MAX(fecha_cargo) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
				   psNumEmpleado, CURRENT::DATE
			FROM dom_cte_detalle_paso 
			WHERE nombre_arch = cNom_Arch_Salida;
			
			---INSERTA DE LA TABLA DETALLE_PASO A LA DE DETALLE MAESTRA
			INSERT INTO dom_cte_detalle (nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
			cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
			ref_titular_serv, accion, reintentar_cuenta, estatus,
			causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
			fecha_insert, tipo_cta_abono)
			SELECT nombre_arch,fecha_envio,tipo_registro,consecutivo,fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,
			cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio,
			ref_titular_serv, accion, reintentar_cuenta, estatus,
			causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert,
			fecha_insert, tipo_cta_abono
			FROM dom_cte_detalle_paso
			WHERE nombre_arch = cNom_Arch_Salida;
			
			--INSERTA EN SUMARIO
			INSERT INTO dom_cte_sumario(nombre_arch, fecha_envio, tipo_registro, num_operaciones, imp_operaciones, num_oper_pend, imp_oper_pend, num_oper_apli, 
						imp_oper_apli, num_oper_rech, imp_oper_rech, user_insert, fecha_insert)
			SELECT LIMIT 1 nombre_arch, vdtFecha, 'S', LPAD((SELECT COUNT(*)	FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),8,'0'),
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida),
			LPAD ((SELECT COUNT (*) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR'),8, '0'), 
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo = 'PR'),
			LPAD ((SELECT COUNT (*) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01'),8, '0'), 
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '01'),
			LPAD ((SELECT COUNT (*) FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR'),8, '0'),
			(SELECT LPAD( NVL(SUM(imp_operacion::INTEGER),0),18,'0') FROM dom_cte_detalle_paso WHERE nombre_arch = cNom_Arch_Salida AND estatus = '02' AND causa_rechazo <> 'PR'),
			psNumEmpleado, CURRENT::DATE
			FROM dom_cte_detalle_paso 
			WHERE nombre_arch = cNom_Arch_Salida;	

			TRUNCATE TABLE dom_cte_detalle_paso;
		
			EXECUTE PROCEDURE "informix".sp_domi_cop_generaarchivo(cNom_Arch_Salida, '02') INTO cCodret;	
			
		END IF;
	ELSE -- PARAMETRO NO ENCONTRADO
		EXECUTE PROCEDURE BdiDomi:sp_ObtenerMensajeError(vsCodRetorno) INTO vsCodRetorno2, vsMensaje_Respuesta;
		RETURN 'GENERAL', vsCodRetorno, vsMensaje_Respuesta;
		--LET vsCodRetorno = '01431'
	END IF;
	
END

END PROCEDURE;