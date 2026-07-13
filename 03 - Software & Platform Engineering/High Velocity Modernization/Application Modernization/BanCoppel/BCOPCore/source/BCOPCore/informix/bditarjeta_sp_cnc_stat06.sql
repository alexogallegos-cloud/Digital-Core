CREATE PROCEDURE "informix".sp_cnc_stat06
(
	psCve_Usuario VARCHAR(10), 
	piHorario INTEGER
)

    RETURNING VARCHAR (5) AS CodRet, VARCHAR (150) AS Mensaje_Respuesta ;
    
    /*  DEFINICION DE VARIABLES */
	
    --CONTROL GENERAL
    DEFINE viSQLerr 						INTEGER;
    DEFINE vsCodRet 						VARCHAR(5);
    DEFINE vsCodRet2 						VARCHAR(5);
    DEFINE vsMensaje_Respuesta 				VARCHAR (250);
    DEFINE viElemento 						INTEGER;
    DEFINE viActualizacion 					INTEGER;
    DEFINE dtFecha_Hoy_Integral 			DATE;
    DEFINE vsBinCredito 					VARCHAR(6);
    DEFINE vsBinDebito 						VARCHAR(6);
    DEFINE viContadorErroresCon 			INTEGER;
    DEFINE viContadorErrores_Pase_Credito 	INTEGER;
    DEFINE viContadorErrores_Pase_Debito 	INTEGER;
    DEFINE vmComisionDeb 					DECIMAL(16,6);
    DEFINE vmComisionCred 					DECIMAL(16,6);
    DEFINE vmIVAComisionDeb 				DECIMAL(16,6);
    DEFINE vmIVAComisionCred 				DECIMAL(16,6);
    DEFINE vsFlag_Error_Reg 				VARCHAR(1);
	DEFINE vdDiaHora						DATETIME YEAR TO FRACTION(5);
	DEFINE vdFechaDeHoy						DATE;
	
    --DATOS MOVIMIENTOS_CONCILIACION
	DEFINE vsConadmin 						VARCHAR (3);
    DEFINE vsNombreArchivo 					VARCHAR (23);
    DEFINE vsArchivo_Origen 				VARCHAR (3);
    DEFINE vsArchivoOriIST 					VARCHAR (3);
    DEFINE vdtFecha_Archivo 				DATE;
    DEFINE vsCarga 							VARCHAR (3);
    DEFINE vsPrefijo_Archivo 				VARCHAR (15);
    DEFINE vsSistema 						VARCHAR (1);
    DEFINE vsConciliacion_Inter 			VARCHAR(1);
	
    --DEFINE vsConciliacion_SIF VARCHAR(1);
    DEFINE vsConciliacion_Admin 			VARCHAR(1);
    DEFINE viBorra_Archivo_Fisico 			INTEGER;
    DEFINE vsTransaccion_Compra 			VARCHAR (4);
    DEFINE vsTransaccion_Liberacion 		VARCHAR (4);
    DEFINE vsTransaccion_Forzada 			VARCHAR (4);
    DEFINE vsTransaccion_Abono 				VARCHAR (4);
    DEFINE vsTransaccionMoneyGram 			VARCHAR (4);
    DEFINE vsTransaccionCashBack 			VARCHAR (16); 
    DEFINE vsRep_Aix 						VARCHAR (50);
    DEFINE vsRep_Win 						VARCHAR (50);
    DEFINE vsArchivo_Companero 				VARCHAR(3);
    DEFINE vsArchivo_Report_Comisiones 		VARCHAR(3);
    DEFINE viTipo_LayOut 					INTEGER;
    DEFINE vsRuta_Archivo_Comisiones 		VARCHAR(50);
	
    --DATOS CONADMIN
    DEFINE vsNombreArchivo_Comi 			VARCHAR(23);
    DEFINE vsNombreArchivoCompanero 		VARCHAR(23);
	
    --DATOS ARCHIVO_CONCILIACION
    DEFINE viTot_Registros 					INTEGER;
    DEFINE vmTot_Monto 						MONEY;
    DEFINE viNum_Cargo 						INTEGER;
    DEFINE vmMonto_Cargo 					MONEY;
    DEFINE viNum_Abono 						INTEGER;
    DEFINE vmMonto_Abono 					MONEY;
	
    --CONTROL CICLOS
    DEFINE vsFlag_Ciclo_BusrcarArch 		VARCHAR (1);
    DEFINE vsFlag_ArchPendiente 			VARCHAR(1);
    DEFINE vsFlag_Ciclo_BusrcarReg 			VARCHAR (1);
	
    --DATOS MOVIMIENTOS_CONCILIACION
    DEFINE viConsecutivo 					INTEGER;
    DEFINE vsNumTarjeta 					VARCHAR (16);
    DEFINE vsTipoTransaccion325 			VARCHAR (15);
    DEFINE vsMonto325 						VARCHAR (13);
    DEFINE vsMontoCashBack325 				VARCHAR (13);
    DEFINE vsCuenta 						varchar(20); 
    define vsestransfer 					varchar(1);
    DEFINE vsFechaopetransfer 				char(6);
    DEFINE vsIdcomercio325 					VARCHAR (15);
    DEFINE vsNomcomercio325 				VARCHAR (30);
    DEFINE vsReferencia23_325 				VARCHAR (23);
    DEFINE vsSecuencia325 					VARCHAR (6);
    DEFINE vsDivisa325 						VARCHAR (3);
    DEFINE vsRfc325 						VARCHAR (15);
    DEFINE vsSecuencia 						VARCHAR(7);
    DEFINE vsSecuencia_Extendida 			VARCHAR(15);
    DEFINE vmMontoIntercard 				MONEY;
    DEFINE vmMontoCashBack 					MONEY;
    DEFINE vsFechaTransaccion 				DATETIME YEAR TO FRACTION (5);
    DEFINE vsInfReceptor 					VARCHAR(40);
    DEFINE vsIdTerminal 					VARCHAR(16);
    DEFINE vsMetodoCaptura 					VARCHAR(2);
    DEFINE vsMovConciliado 					VARCHAR(1);
    DEFINE vsMovReversado 					VARCHAR(1);
    DEFINE vsTipo_Mov 						VARCHAR(1);
    DEFINE vsFolio_Mov 						VARCHAR(16);
    DEFINE vdFechaConcilia 					DATETIME YEAR TO FRACTION (5);
    DEFINE viTipo_Conciliacion 				INTEGER;
    DEFINE vsDesc_Conciliacion 				VARCHAR(60);
    DEFINE vsConciliacion_Reg 				VARCHAR(1);
    DEFINE vsNumCuenta 						VARCHAR(20);
    DEFINE vsMonto_Divisa325 				VARCHAR(13);
    DEFINE vsISO323							CHAR(2);
    DEFINE vsMovRev325 						CHAR(1);
    DEFINE vsTipoMov 						VARCHAR(1);
    DEFINE vsAplicacion 					VARCHAR(1);
    DEFINE vsBandera_Proceso 				VARCHAR(1);
    DEFINE vsTransaccion_Aplica 			VARCHAR(4);
    DEFINE vsSistema_Registro 				VARCHAR(1);
    DEFINE vsFlagIntegridad 				VARCHAR(1);
    DEFINE vscodgironeg 					CHAR(4);    
    DEFINE vsb_aplica 						CHAR(1);    
    DEFINE vssecuencia_ext_archivo 			CHAR(15);    
	
    --CONTROL DE TRANSACCIONALIDAD
    DEFINE vsFlagEnTransaccion VARCHAR (1);
    DEFINE viContadorRegistros INTEGER;
    
	/*Coppel BOT*/
	DEFINE txn_CoppelBot VARCHAR(4);
	DEFINE vsNomArch_ComiBot VARCHAR(35);
	
    DEFINE vsConciliacionAdminAtm CHAR(1);
	
	/* VARIABLES DE FAST FUNDS*/
	DEFINE vsTxn_code				VARCHAR(1);
	DEFINE vsIndicador_fastfounds	VARCHAR(1);
	DEFINE vsRef_num_fastfounds		VARCHAR(1);
	
	/* VARIEBLES PARA MSI */
	DEFINE vspromoMSI				VARCHAR(02);
	DEFINE vsMSi					VARCHAR(02);
    
    /* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
    LET viSQLerr = 0;    
    LET vsCodRet = '00000';
    LET vsCodRet2 = '00000';
    LET vsMensaje_Respuesta = '';
    LET viElemento = 0;
    LET viActualizacion = 0;
    LET dtFecha_Hoy_Integral = CURRENT::DATE;
    LET vsBinCredito = '';
    LET vsBinDebito = '';
    LET viContadorErroresCon = 0;
    LET viContadorErrores_Pase_Credito = 0;
    LET viContadorErrores_Pase_Debito = 0;
    LET vmComisionDeb = 0.0;
    LET vmComisionCred = 0.0;
    LET vmIVAComisionDeb = 0.0;
    LET vmIVAComisionCred = 0.0;
    LET vsFlag_Error_Reg = '';
	
    --DATOS ARCHIVO_ORIGEN
	LET vsConadmin = '';
    LET vsNombreArchivo = '';
    LET vsArchivo_Origen = '';
    LET vsArchivoOriIST = '';
    LET vdtFecha_Archivo = CURRENT::DATE;
	LET vdFechaDeHoy = CURRENT::DATE;
    LET vsCarga = '';
    LET vsPrefijo_Archivo = '';
    LET vsSistema = '';
    LET vsConciliacion_Inter = '';
	
    --LET vsConciliacion_SIF = '';
    LET vsConciliacion_Admin = '';
    LET viBorra_Archivo_Fisico = 0;
    LET vsTransaccion_Compra = '';
    LET vsTransaccion_Liberacion = '';
    LET vsTransaccion_Forzada = '';
    LET vsTransaccion_Abono = '';
    LET vsTransaccionMoneyGram = '';
    LET vsTransaccionCashBack = ''; -- Inicializacion de Variable de para transacciones Cash Back
    LET vsRep_Aix = '';
    LET vsRep_Win = '';
    LET vsArchivo_Companero = '';
    LET vsArchivo_Report_Comisiones = '';
    LET viTipo_LayOut = 0;
    LET vsRuta_Archivo_Comisiones = '';
	
    --DATOS CONADMIN
    LET vsNombreArchivo_Comi = '';
    LET vsNombreArchivoCompanero = '';
	
    --DATOS ARCHIVO_CONCILIACION
    LET viTot_Registros = 0;
    LET vmTot_Monto = 0.0;
    LET viNum_Cargo = 0;
    LET vmMonto_Cargo = 0.0;
    LET viNum_Abono = 0;
    LET vmMonto_Abono = 0.0;
	
    --CONTROL CICLOS
    LET vsFlag_Ciclo_BusrcarArch = 'V';
    LET vsFlag_ArchPendiente = 'F';
    LET vsFlag_Ciclo_BusrcarReg = 'V';
	
    --DATOS MOVIMIENTOS_CONCILIACION
    LET viConsecutivo = 0;
    LET vsNumTarjeta = '';
    LET vsTipoTransaccion325 = '';
    LET vsMonto325 = '';
    LET vsMontoCashBack325 = '';
    LET vscuenta = ''; -- Integracion Transfer
    LET vsestransfer = '';
    LET vsfechaopetransfer = '';
    LET vsIdcomercio325 = '';
    LET vsNomcomercio325 = '';
    LET vsReferencia23_325 = '';
    LET vsSecuencia325 = '';
    LET vsDivisa325 = '';
    LET vsRfc325 = '';
    LET vsSecuencia = '';
    LET vsSecuencia_Extendida = '';
    LET vmMontoIntercard = 0.0;
    LET vmMontoCashBack = 0.0;
    LET vsFechaTransaccion = CURRENT;
    LET vsInfReceptor = '';
    LET vsIdTerminal = '';
    LET vsMetodoCaptura = '';
    LET vsMovConciliado = '';
    LET vsMovReversado = '';
    LET vsTipo_Mov = '';
    LET vsFolio_Mov = '';
    LET vdFechaConcilia = CURRENT;
    LET viTipo_Conciliacion = 0;
    LET vsDesc_Conciliacion = '';
    LET vsNumCuenta = '';
    LET vsMonto_Divisa325 = '';
    LET vsISO323 = '';
    LET vsMovRev325 = '';
    LET vsConciliacion_Reg = '';
    LET vsTipoMov = '';
    LET vsAplicacion = '';
    LET vsBandera_Proceso = '';
    LET vsTransaccion_Aplica = '';
    LET vsSistema_Registro = '';
    LET vsFlagIntegridad = '';
    LET vscodgironeg = '';  -- TFORZADAS
    LET vsb_aplica = ''; --TFORZADAS
    LET vssecuencia_ext_archivo = ''; --TFORZADAS
    --CONTROL DE TRANSACCIONALIDAD
    LET vsFlagEnTransaccion = '';
    LET viContadorRegistros = 0;
	LET vdDiaHora = CURRENT;
    
    LET vsConciliacionAdminAtm = NULL;
	
	/*Coppel BOT*/
	LET txn_CoppelBot 	  = '';
	LET vsNomArch_ComiBot = '';
	
	/* VARIABLES DE FAST FUNDS*/
	LET vsTxn_code				= '';
	LET vsIndicador_fastfounds	= '';
	LET vsRef_num_fastfounds	= '';
	
	/* VARIEBLES PARA MSI */
	LET vsMSi = '';
	LET vspromoMSI = '';
 
	-- SET DEBUG FILE TO "/home/c90296115/sp_cnc_stat06.out";
	-- TRACE ON;
	 
	BEGIN
		ON EXCEPTION SET viSQLerr
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
			
			-- LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 
			SET Valor = 'F', 
				Fecha_Modificacion = 
				(
					SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) 
					FROM SysMaster:"informix".Sysshmvals
				)
			WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION STAT06 EN  EJECUCION' 
			AND TRIM(Valor) = 'V';
			
			LET viElemento = 0;
			LET vsCodRet = '00020';
			LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta);
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
			RETURN vsCodRet, vsMensaje_Respuesta;
			
		END EXCEPTION;
    
		-- EN CASO DE TRANSACCION ABIERTA Y TRATAR DE ABRIR OTRA
		ON EXCEPTION IN (-535)
			COMMIT WORK; -- TERMINA LA TRANSACCION ACTUAL Y CONTINUA
		END EXCEPTION WITH RESUME;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		-- OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
		SELECT LIMIT 1 Fecha_Hoy 
		INTO dtFecha_Hoy_Integral 
		FROM bdinteg:"informix".Si_Fechas WHERE empresa = '001';
		
		IF (EXISTS (SELECT Descripcion FROM BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 WHERE Codigo = '001' AND Descripcion = 'CONCILIACION STAT06 EN EJECUCION' AND TRIM(Valor) = 'V') ) THEN --VALIDA QUE NO EXISTA UNA CONCILIACION EN EJECUCION (CONCREING)
			
			LET vsCodRet = '00001'; --CONCILIACION EN EJECUCION --CONCREIN
			LET vsMensaje_Respuesta = 'CONCILIACION STAT06 EN EJECUCION';
		
		ELIF (dtFecha_Hoy_Integral < CURRENT::DATE) THEN -- VALIDA QUE EL SISTEMA DE INTEGRA ESTE A CORDE A LA DEL SERVIDOR
			
			LET vsCodRet = '00003'; --FECHAS INTEGRAR-SERVIDOR DESFASADAS 
			LET vsMensaje_Respuesta = 'FECHAS INTEGRAR-SERVIDOR DESFASADAS.';
		
		ELIF (NOT EXISTS (SELECT Archivo_Origen FROM BdiTarjeta:"informix".td_archivo_origen_atm_stat06 WHERE Horario_Ejecucion_Hoy = piHorario OR Horario_Ejecucion_Ext = piHorario)) THEN --VALIDA QUE EL CRON/EJECUCION ESTE CONTEMPLADAPARA ALGUNO DE LOS ARCHIVOS
			
			LET vsCodRet = '00005'; --CRON NO CONTEMPLADO EN NINGUN ARCHIVO
			LET vsMensaje_Respuesta = 'CRON NO CONTEMPLADO EN NINGUN ARCHIVO.';
		
		ELSE -- OK
		
			LET vsMensaje_Respuesta = 'MARCAR CONCILIACION EN EJECUCION';
			
			--MARCA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06
			SET Valor = 'V',  
				Fecha_Modificacion = current
			WHERE Codigo = '001'
			AND Descripcion = 'CONCILIACION SAT06 EN EJECUCION'
			AND TRIM(Valor) = 'F';

			LET vsFlag_Ciclo_BusrcarArch = 'V'; -- ACTIVAR PARA BUSCAR UN ARCHIVO.
			
			WHILE (vsFlag_Ciclo_BusrcarArch = 'V')  -- CICLO DE BUSQUEDA DE ARCHIVOS PENDIENTES.
				
				--PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
				LET vsFlag_Ciclo_BusrcarArch = 'F';
				LET vsFlag_ArchPendiente = 'F';
				LET viElemento = 0;
				LET vsCodRet = '00000';
				LET viTot_Registros = 0;
				LET vmTot_Monto = 0.0;
				LET viNum_Cargo = 0;
				LET vmMonto_Cargo = 0.0;
				LET viNum_Abono = 0;
				LET vmMonto_Abono = 0.0;
				LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS POR CONCILIAR.';

				-------------Obtiene Datos del Archivo a conciliar 
				SELECT Horario_Ejecucion_Ext, orden_proceso, 'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
					ArchCon.Fecha_Archivo, ArchCon.Carga,ArchOri.Prefijo_Archivo, ArchOri.Sistema, 
					ArchOri.Conciliacion_Inter, ArchOri.conciliacion_admin_atm,ArchOri.conciliacion_admin,ArchOri.Borra_Archivo_Fisico,
					ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada, ArchOri.Transaccion_Abono,
					ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
				FROM bditarjeta:"informix".td_archivos_conciliacion_atm_stat06 AS ArchCon 
				LEFT JOIN bditarjeta:"informix".td_archivo_origen_atm_stat06 AS ArchOri 
				ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
				WHERE ArchCon.Proceso = 'P'
				AND ArchCon.Fecha_Archivo = (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE 
				AND Horario_Ejecucion_Hoy <= piHorario
				ORDER BY Horario_Ejecucion_Ext, orden_proceso ASC
				INTO temp tb_config_archivo_normal WITH NO LOG ;
					
				-- SE OBTIENE DATOS PARA ARCHIVO NORMAL
				LET vsMensaje_Respuesta = 'Inserta Datos de Tab_Tem a Vars';

				SELECT FIRST 1
						Flag_ArchPendiente, 
						NombreArchivo, 
						Archivo_Origen,
						Fecha_Archivo,
						Carga, 
						Prefijo_Archivo,
						Sistema,
						Conciliacion_Inter,
						conciliacion_admin_atm,
						Conciliacion_Admin,
						Borra_Archivo_Fisico,
						Transaccion_Compra,
						Transaccion_Liberacion,
						Transaccion_Forzada, 
						Transaccion_Abono,
						Rep_Aix, 
						Rep_Win,
						Archivo_Companero, 
						Archivo_Report_Comisiones,
						Tipo_LayOut
				INTO 
					vsFlag_ArchPendiente, 
					vsNombreArchivo, 
					vsArchivo_Origen,
					vdtFecha_Archivo, 
					vsCarga, 
					vsPrefijo_Archivo,
					vsSistema,
					vsConciliacion_Inter,
					vsConciliacionAdminAtm,
					vsConciliacion_Admin,
					viBorra_Archivo_Fisico,
					vsTransaccion_Compra, 
					vsTransaccion_Liberacion, 
					vsTransaccion_Forzada, 
					vsTransaccion_Abono,
					vsRep_Aix,
					vsRep_Win,  
					vsArchivo_Companero,
					vsArchivo_Report_Comisiones,
					viTipo_LayOut
				FROM tb_config_archivo_normal ;
						
				IF (NVL(vsFlag_ArchPendiente, 'F') <> 'V') THEN -- NO ENCONTRO MOVIMIENTO NORMAL 
					-- BUSCA EXTEMPORANEO
					LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS A CONCILIAR EXTEMPORANEO.';
					
					SELECT Horario_Ejecucion_Ext, orden_proceso, 'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
						ArchCon.Fecha_Archivo, ArchCon.Carga,ArchOri.Prefijo_Archivo, ArchOri.Sistema,  
						ArchOri.Conciliacion_Inter, ArchOri.conciliacion_admin_atm,ArchOri.conciliacion_admin,ArchOri.Borra_Archivo_Fisico,
						ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada, ArchOri.Transaccion_Abono,
						ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
					FROM bditarjeta:"informix".td_archivos_conciliacion_atm_stat06 AS ArchCon 
					LEFT JOIN bditarjeta:"informix".td_archivo_origen_atm_stat06 AS ArchOri 
					ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
					WHERE ArchCon.Proceso = 'P'
					AND ArchCon.Fecha_Archivo <= (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE
					AND Horario_Ejecucion_Ext <= piHorario
					ORDER BY Horario_Ejecucion_Ext, orden_proceso ASC
					INTO temp tb_config_archivo_extenporaneo  WITH NO LOG ;
					
					SELECT FIRST 1
						Flag_ArchPendiente, 
						NombreArchivo, 
						Archivo_Origen,
						Fecha_Archivo,
						Carga, 
						Prefijo_Archivo,
						Sistema,
						Conciliacion_Inter,
						conciliacion_admin_atm,
						Conciliacion_Admin,
						Borra_Archivo_Fisico,
						Transaccion_Compra,
						Transaccion_Liberacion,
						Transaccion_Forzada, 
						Transaccion_Abono,
						Rep_Aix, 
						Rep_Win,
						Archivo_Companero, 
						Archivo_Report_Comisiones,
						Tipo_LayOut
					INTO 
						vsFlag_ArchPendiente, 
						vsNombreArchivo, 
						vsArchivo_Origen,
						vdtFecha_Archivo, 
						vsCarga, 
						vsPrefijo_Archivo,
						vsSistema,
						vsConciliacion_Inter,
						vsConciliacionAdminAtm,
						vsConciliacion_Admin,
						viBorra_Archivo_Fisico,
						vsTransaccion_Compra, 
						vsTransaccion_Liberacion, 
						vsTransaccion_Forzada, 
						vsTransaccion_Abono,
						vsRep_Aix,
						vsRep_Win,  
						vsArchivo_Companero,
						vsArchivo_Report_Comisiones,
						viTipo_LayOut
					FROM tb_config_archivo_extenporaneo ;
				END IF; --IF(1)
				
						
				IF (NVL(vsFlag_ArchPendiente, 'F') = 'V') THEN -- EXISTEN ARCHIVOS PENDIENTE POR PROCESAR
				
					LET vsFlag_Ciclo_BusrcarArch = 'V'; -- ENCONTRO UN REGISTRO, ACTIVAR PARA BUSCAR EL SIGUIENTE
					LET vsFlag_Error_Reg = 'F';
				  

					IF ( vsSistema = 'A' ) THEN
						LET vdDiaHora = CURRENT;
					
						-- ACTUALIZA LA HORA DE INICIO DE PROCESO DEL ARCHIVO
						UPDATE bditarjeta:"informix".td_archivos_conciliacion_atm_stat06
						SET Fecha_Hora_Ini_Proceso = vdDiaHora,
							Fecha_Proceso = vdFechaDeHoy
						WHERE NombreArchivo = vsNombreArchivo 
						AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;
		  
						IF (vsCarga <> 'V') THEN -- VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							
							-- CARGA EL ARCHIVO A LA TABLA DE PASO
							EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_cga_stat06 ( vsRep_Aix, vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, vsSistema, vsRep_Aix)
							INTO vsCodRet, vsMensaje_Respuesta, viTot_Registros, vmTot_Monto, viElemento;
							
							LET vdDiaHora = CURRENT;
							
							-- ACTUALIZA LA HORA DE FIN DE LA CARGAR DE ARCHIVO A LA BD
							UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
							SET Fecha_Hora_Carga_Archivo = vdDiaHora
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
							AND Fecha_Archivo = vdtFecha_Archivo;
							
						END IF; -- (2.1.1) Cierre del IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
						
						IF (vsCodRet = '00000') THEN --VALIDA SI EL ARCHIVO SE CARGO A LA TABLA DE PASO.
						
							IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							
								-- CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA TD_MOVIMIENTOS_CONCILIACION
								EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_obtenerregistroarchivo_stat06 (vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, psCve_Usuario )
								INTO vsCodRet, vsMensaje_Respuesta, viElemento;
							
								-- ACTUALIZA LA HORA DE FIN DE LA CARGAR DE LA TABLA Td_Movimientos_Conciliacion
								 LET vdDiaHora = CURRENT;
								
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
								SET Fecha_Hora_Carga_Tabla = vdDiaHora,
									Num_Registros325 = viTot_Registros, 
									Monto325 = vmTot_Monto,
									Carga = DECODE(vsCodRet, '00000', 'V', 'F')                                
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
									
							END IF;  -- IF(2.1.2.A) Cierre del segundo IF IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							
							
							-- VALIDA SI SE PASO LA INFORMACION A LA TABLA DE TD_MOVIMIENTOS_CONCILIACION
							IF (vsCodRet = '00000') THEN -- IF(2.1.2.B)
								
								LET vdDiaHora = CURRENT;
								-- ACTUALIZA LA HORA DE INICIO DE LA CONCILIACION DE LOS REGISTROS
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
								SET Fecha_Hora_Ini_Concilia_Reg = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
									
								LET vsFlagEnTransaccion = 'F';
								LET viContadorRegistros = 0;
								LET vsFlag_Ciclo_BusrcarReg = 'V'; -- ARCTIVAR PARA BUSCAR UN REGISTRO.
								
								WHILE (vsFlag_Ciclo_BusrcarReg = 'V')  -- CICLO DE BUSQUEDA DE REGISTROS PENDIENTES.
									
									-- ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
									IF (vsFlagEnTransaccion = 'F') THEN
										BEGIN WORK;
										LET vsFlagEnTransaccion = 'V';
									END IF;
									
									LET vsFlag_Ciclo_BusrcarReg = 'F'; -- PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
									LET vsFlagIntegridad = '';
									LET vsCodRet = '00000';
									LET vsTipoMov = '';
									LET vsAplicacion = '';
									LET vsBandera_Proceso = '';
									LET vsTransaccion_Aplica = '';
									LET vsMensaje_Respuesta = 'OBTENER REGISTROS A CONCILIAR.';

									-- OBTIENE LOS REGISTROS PERTENECIENTES AL ARCHIVO ACTUAL

									SELECT {+AVOID_FULL(bditarjeta:td_movimientos_conciliacion)} FIRST 1 'V' AS Ciclo_BusrcarReg, Consecutivo, NumTarjeta, TipoTransaccion325, Monto325, montocashback325, numcuenta,
										estransfer, Idcomercio325, 	Nomcomercio325, Referencia23_325, Secuencia325, Divisa325, Rfc325, NumCuenta, Monto_Divisa325,
										Conciliacion, Secuencia, Secuencia_Extendida, MontoIntercard, MontoCashback, FechaTransaccion, 
										InfReceptor, IdTerminal, MetodoCaptura, MovConciliado, MovReversado, Tipo_Mov, Folio_Mov, 
										FechaConcilia, Tipo_Conciliacion, Desc_Conciliacion, ISO323, MovRev325,
										Transaccion_Aplica, Bandera_Proceso, b_aplica,secuencia_ext_archivo,archivo_origen,
										txn_code,indicador_fastfounds,ref_num_fastfounds,parcialiacion_promo,tipo_plan_promo
									INTO vsFlag_Ciclo_BusrcarReg, viConsecutivo, vsNumTarjeta, vsTipoTransaccion325, vsMonto325,vsMontoCashBack325, vsCuenta,
										vsestransfer, vsIdcomercio325, vsNomcomercio325, vsReferencia23_325, vsSecuencia325, vsDivisa325, vsRfc325, vsNumCuenta, vsMonto_Divisa325, 
										vsConciliacion_Reg, vsSecuencia, vsSecuencia_Extendida, vmMontoIntercard, vmMontoCashBack, vsFechaTransaccion, 
										vsInfReceptor, vsIdTerminal, vsMetodoCaptura, vsMovConciliado, vsMovReversado, vsTipo_Mov, vsFolio_Mov, 
										vdFechaConcilia, viTipo_Conciliacion, vsDesc_Conciliacion, vsISO323, vsMovRev325,
										vsTransaccion_Aplica, vsBandera_Proceso, vsb_aplica,vssecuencia_ext_archivo,vsArchivoOriIST,
										vsTxn_code,vsIndicador_fastfounds,vsRef_num_fastfounds,vspromoMSI,vsMSi
									FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion
									WHERE NombreArchivo = vsNombreArchivo
									AND Archivo_Origen = vsArchivo_Origen
									AND Finalizado = 'F';
									
									IF (vsFlag_Ciclo_BusrcarReg = 'V') THEN --VALIDA SI EXISTE REGISTRO PARA PROCESAR
									
										SELECT FIRST 1 NVL(CreditoDebito,'') 
										INTO vsSistema_Registro
										FROM Intercard:"informix".Bines 
										WHERE Bin = SUBSTR(vsNumTarjeta, 1, 6); --OBTIENE EL BIN CORRESPONDIENTE DE LA TARJETA
											
										IF (NVL(vsSistema_Registro,'') = '') THEN --LA TARJETA NO CONTIENE BIN VALIDO
											LET vsSistema_Registro = '';
										END IF;
										
										LET vsMensaje_Respuesta = 'VALIDAR INTEGRIDAD DEL REGISTRO.';
										
										-- VALIDA LA INTEGRIDAD DE LOS REGISTROS INDIVIDUALES --07/2013 Se integra nuevo campo de validacion vsmontocashback325, elemento 3
										EXECUTE PROCEDURE BdiTarjeta:"informix".sp_concreing_validaintegridad_stat06( vsArchivo_Origen, viConsecutivo, vsNumTarjeta, vsTipotransaccion325, vsMonto325, vsMontoCashBack325, vsIdcomercio325, vsNomcomercio325, vsReferencia23_325, vsSecuencia325, vsDivisa325, vsRfc325, vsBinDebito, vsBinCredito, vsSistema)
										INTO vsCodRet, vsFlagIntegridad, vsMensaje_Respuesta, viElemento;
											
										-- VALIDA SI AL REGISTRO LE CORRESPONDE CONCILIACION INTERCARD Y QUE LA INTEGRIDAD SEA CORRECTA
										IF ((vsConciliacion_Inter = 'V') AND (vsCodRet = '00000') AND (viTipo_Conciliacion = 0)) THEN
											
											LET vsMensaje_Respuesta = 'CONCILIACION INTERCARD.';

											-- Se modifica llamado por integracion de operaciones con cash back (vsmontocashback325)
											EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_ConciliaIntercard ( psCve_usuario, vsArchivo_Origen, vsConciliacion_Inter, vsConciliacion_Reg,
												viConsecutivo, vsNumtarjeta, vsSecuencia325, vsMonto325,vsMontoCashBack325, vsTipotransaccion325, vsFlagIntegridad, viTipo_LayOut, vsISO323,
												vsMovRev325, vsb_aplica,vssecuencia_ext_archivo,vsArchivoOriIST,vsTxn_code,vsIndicador_fastfounds,vsMSi,vspromoMSI) --TFROZADAS
											INTO vsCodRet, vsConciliacion_Reg, vsSecuencia, vsSecuencia_Extendida,vscodgironeg, vmMontoIntercard, vmMontoCashBack, vsFechaTransaccion, 
												vsInfReceptor, vsIdTerminal, vsMetodoCaptura, vsMovConciliado, vsMovReversado, vsTipo_Mov, vsb_aplica, vsFolio_Mov, 
												vdFechaConcilia, viTipo_Conciliacion, vsDesc_Conciliacion, vsMensaje_Respuesta, viElemento, viActualizacion; -- Se modifica retorno TForzadas 
										END IF
									
										-- Validacion para cajeros automaticos
										IF ( (vsConciliacionAdminAtm = 'V') AND (vsCodRet = '00000') ) THEN

											EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ConcReing_ConAdmin_Atms 
											( 
												vsSistema_Registro, 
												vdtFecha_Archivo, --FECHA DEL ARCHIVO PARA MANEJO CORRECTO DE EXTEMPORANEOS
												vsMovReversado, 
												vsNumTarjeta, 
												vsFolio_Mov, --REQUIERE CONCILIACION INTERCARD
												vsArchivo_Origen, 
												vsNombreArchivo, 
												vsTipo_Mov, --REQUIERE CONCILIACION INTERCARD
												((vsMonto325::MONEY)/100), 
												vsSecuencia_Extendida, --REQUIERE CONCILIACION INTERCARD
												vsFechaTransaccion, --REQUIERE CONCILIACION INTERCARD
												vmMontoIntercard,  --REQUIERE CONCILIACION INTERCARD
												vsIdTerminal, --REQUIERE CONCILIACION INTERCARD
												vsTransaccion_Aplica, 
												vsNombreArchivo_Comi, 
												psCve_usuario 
											) 
											INTO vsCodRet, vsMensaje_Respuesta, viElemento;
											
											END IF; --(vsConciliacion_Admin = 'V') AND (vsCodRet = '00000')
										
										IF (vsCodRet <> '00000') THEN --VALIDA QUE TODOS LOS PROCESOS PARA EL REGISTRO SEAN CORRECTOS
											--LET vsMensaje_Respuesta = 'ACTUALIZA EL ESTATUS DEL REGISTRO.';
											--NIVEL DE REGISTRO
											LET vsFlag_Error_Reg = 'V';
											
											--GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
											EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') [' || vsNombreArchivo || ']' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
										
										END IF;

										LET vdDiaHora = CURRENT;
										
										--ACTUALIZA EL ESTATUS DEL REGISTRO A PROCESADO COMPLETAMENTE
										UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion
										SET Finalizado = DECODE(vsCodRet, '00000', 'V'/*OK*/, 'E'/*ERROR*/)
										WHERE Consecutivo = viConsecutivo
										AND NombreArchivo = vsNombreArchivo
										AND Archivo_Origen = vsArchivo_Origen
										AND Finalizado = 'F';
						   
									END IF;
									
									LET viContadorRegistros = viContadorRegistros + 1;
									
									-- TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
									IF (viContadorRegistros = 1000) THEN -- VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
										COMMIT WORK;
										LET vsFlagEnTransaccion = 'F';
										LET viContadorRegistros = 0;
									END IF;
								
									IF (vsTransaccion_Aplica = '0417' ) THEN
									
									LET txn_CoppelBot = vsTransaccion_Aplica;
									
									LET vsNomArch_ComiBot = 'conciWas'|| SUBSTR(vsNombreArchivo,11,2) || SUBSTR(vsNombreArchivo,9,2)  || SUBSTR(vsNombreArchivo,13,4) || '.txt'; 
									
									END IF;
								END WHILE; -- REGISTRO

								LET vsMensaje_Respuesta = 'ACTUALIZA LA HORA DE FIN DE LA CONCILIACION DE LOS REGISTROS Y TOTALES.';

								LET vdDiaHora = CURRENT;
								
								-- ACTUALIZA LA HORA DE FIN DE LA CONCILIACION DE LOS REGISTROS
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
								SET Fecha_Hora_Fin_Concilia_Reg =
								(
									SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) 
									FROM SysMaster:"informix".Sysshmvals
								) 
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
								
								-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
								IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
									COMMIT WORK;
									LET vsFlagEnTransaccion = 'F';
								END IF;
							END IF; -- IF(2.1.2.B)
						END IF;
					END IF; -- IF(2.1)

					LET vdDiaHora = CURRENT;
					
					-- ACTUALIZA LA HORA DE FIN DE PROCESO DEL ARCHIVO
					UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
					SET Fecha_Hora_Fin_Proceso = vdDiaHora,
					Proceso =
					(
						CASE 
							WHEN vsCodRet IN ('00006', '00007') 
								THEN 'X'  --PENDIENTE PARA EL PROX CRON ()
							WHEN vsCodRet IN  ('00000') 
								THEN 'T'  --TRABAJADO
							ELSE 'E' 
						END
					) --ERROR DE CARGA 1-2
					WHERE NombreArchivo = vsNombreArchivo 
					AND Archivo_Origen = vsArchivo_Origen 
					AND Fecha_Archivo = vdtFecha_Archivo;		
				END IF; -- IF(2)
				
				--Vacia las tablas Tmp
				DROP TABLE IF EXISTS tb_config_archivo_extenporaneo;
				DROP TABLE IF EXISTS tb_config_archivo_normal;
				
				IF (vsCodRet <> '00000') THEN
				
					-- NIVEL DE ARCHIVO
					-- GUARDA EN BITACORA REGISTRO DEL ERROR EN CASO DE QUE EXISTA
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
					
					LET viContadorErroresCon = viContadorErroresCon + 1;
				
				END IF;
				
				IF 
				( EXISTS (
					SELECT Descripcion 
					FROM BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 
					WHERE Codigo = '002' 
					AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION' 
					AND TRIM(Valor) = 'V'
				) ) THEN --VALIDA QUE SI EXISTE UNA ORDEN DE DETENER LA CONCILIACION (CONCREIN)
					LET vsMensaje_Respuesta = 'PARO DE EMERGENCIA DE CONCILIACION.';
					
					LET vdDiaHora = CURRENT;
					--LIBERA LA BANDERA DE PARO DE EMERGENCIA DE CONCILIACION
					UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06
					SET Valor = 'F', Fecha_Modificacion = (SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals) 
					WHERE Codigo = '002' 
					AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION'
					AND TRIM(Valor) = 'V';
						
					LET vsFlag_ArchPendiente = 'F'; 
					LET vsFlag_Ciclo_BusrcarArch = 'F'; --TERMINA EL CICLO 
					LET vsCodRet = '00010'; --CONCILIACION DETENIDA --CONCREIN
					LET vsMensaje_Respuesta = 'CONCILIACION DETENIDA POR EL USUARIO.';
					
				END IF;
			END WHILE; -- ARCHIVO
			
			-- VALIDA SI ESXISTEN ARCHIVOS CON ESTATUS 'X'
			IF 
			(EXISTS (
				SELECT NombreArchivo 
				FROM BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06 
				WHERE Proceso = 'X'
			)) THEN
				
				LET vdDiaHora = CURRENT;
				
				-- MARCA DISPONIBLES LOS REGISTROS QUE NO SE PROCESARON POR PASES DE CRED O DEB
				UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
				SET Fecha_Hora_Fin_Proceso = vdDiaHora,
				Proceso = 'P'
				WHERE Proceso = 'X'; 

			END IF;

			LET vdDiaHora = CURRENT;
			
			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_atm_stat06 
			SET Valor = 'F',
				Fecha_Modificacion = vdDiaHora
			WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION EN EJECUCION' 
			AND TRIM(Valor) = 'V';
			
		END IF;
		
		IF (vsCodRet <> '00000') THEN
		
			-- NIVEL DE PROCESO
			-- GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
		
		ELSE
			
			LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA.' 
			|| DECODE ((viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)), 0, '', ' -- SE PRESENTARON [' || (viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)) || '] ERRORES DE PROCESO DE ARCHIVO.' )
			|| DECODE (viContadorErrores_Pase_Credito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Credito || '] ARCHIVOS POR LA FALTA DEL PASE DE CREDITO.' )
			|| DECODE (viContadorErrores_Pase_Debito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Debito || '] ARCHIVOS POR LA FALTA DEL PASE DE DEBITO.' );
			
		END IF;
	RETURN vsCodRet, vsMensaje_Respuesta;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de la ejecucion principal de la conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_cga_stat06 ( 
    psRuta_Repositorio 	VARCHAR (90), 
    psNomArchivo 		VARCHAR (30), 
    psArchivoOrigen 	VARCHAR (3), 
    piTipoLayOut 		INTEGER, 
    psSistema 			VARCHAR (1),
    psRuta_Procesos 	VARCHAR (90) 
)
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Tot_Registros, MONEY AS Tot_Monto, INTEGER AS Elemento;

    DEFINE vsSQL 				VARCHAR (200) ;
    DEFINE viSQLerr 			INTEGER ;
    DEFINE vsCodRet 			VARCHAR(5);
	DEFINE vCodRetAux 			VARCHAR(5);
    DEFINE vsMensaje_Respuesta 	VARCHAR(250);
    DEFINE viTotalRegistros 	INTEGER;
    DEFINE vmTotalMonto 		MONEY;
    DEFINE viInicioCadena_Reg	INTEGER;
    DEFINE viPosMontoReg_Ini 	INTEGER;
    DEFINE viPosMontoReg_Fin 	INTEGER;
    DEFINE viInicioCadena_Monto	INTEGER;
    DEFINE vsTipoSumario 		VARCHAR(35);
    DEFINE vsposicion_Regtxn	INTEGER;
    DEFINE vsposicion_Montotxn	INTEGER;
    DEFINE vsRegistros_txn		VARCHAR(12);
    DEFINE vsMonto_txn			VARCHAR(12);
    DEFINE vdRegistros_txn		VARCHAR(01);
    DEFINE vdMonto_txn			VARCHAR(01);
	
	----Monitoreo 
	DEFINE vFlagProceso VARCHAR(22);

    LET vsSQL 					= '' ;
    LET viSQLerr 				= 0;
    LET vsCodRet 				= '00000';
	LET vCodRetAux 				= '00000';
    LET vsMensaje_Respuesta	 	= 'PROCESO EXITOSO';	
    LET viTotalRegistros 		= 0;
    LET vmTotalMonto 			= 0.0;
    LET viPosMontoReg_Ini 		= 0;
    LET viPosMontoReg_Fin 		= 0;
    LET viInicioCadena_Monto	= 0;
	LET vsTipoSumario = '*Total de Transacciones:*';
    LET vsposicion_Regtxn		= 35;
    LET vsposicion_Montotxn		= 68;
    LET vsRegistros_txn	 		= ''; 
    LET vsMonto_txn				= ''; 
    LET vdRegistros_txn			= '';
    LET vdMonto_txn			= '';
	LET viPosMontoReg_Ini = 181;  --10
	LET viPosMontoReg_Fin = 10;
	
	 --SET DEBUG FILE TO "/RESPALDOSNEW/MALG/sp_cga_atm_stat06.out";
	 --TRACE ON;
    
	BEGIN
	
		ON EXCEPTION SET viSQLerr

            -- SET DEBUG FILE TO "/RESPALDOSNEW/MALG/excep_sp_cargaarchivos_stat06.out" WITH APPEND;
            -- TRACE ON;
    
			TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;
            
			LET vsCodRet = '00107';
			
			RETURN vsCodRet, ('[' || vsCodRet ||  '] ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 0, 0.0, 1;
			
		END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_dbload_archivos_stat06(psRuta_Repositorio, psNomArchivo, psArchivoOrigen , piTipoLayOut ,  psSistema)
        INTO vsCodRet, vsMensaje_Respuesta;
            
		IF ( vsCodRet  <> '00000' ) THEN
		
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
            RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' CÃÂ³digo Bitacora Final: ' || vCodRetAux), NVL(viTotalRegistros, 0), NVL((vmTotalMonto), 0.0), 1;          
			
        END IF

		IF 
		( NOT EXISTS 
			(
				SELECT Registro 
				FROM bditarjeta:"informix".td_carga_archivo_stat06  
                WHERE Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES POR CAJERO*'
			)
		) THEN -- IF (1)
            
            LET vsTipoSumario 			= 'ERROR HEADER';
            LET viInicioCadena_Reg 		= -1;
            LET viInicioCadena_Monto 	= -1;
            LET viPosMontoReg_Ini 		= -1;
            LET viPosMontoReg_Fin 		= -1;
			
			LET vsCodRet = '00101';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE PROCESO EL ARCHIVO ESPERADO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF 
		( NOT EXISTS 
			(
				SELECT TRIM(Registro) 
				FROM bditarjeta:"informix".td_carga_archivo_stat06 
				WHERE Registro MATCHES vsTipoSumario 
			)
		) THEN --NO CONTIENE REGISTRO DE SUMARIO

            LET vsCodRet = '00102';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE REGISTRO DE SUMARIO/TRAILER.';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		ELIF( 	(piTipoLayOut = 4) -- PRS_STAT06  PROSA  // TARJETAS DE OTROS BANCOS EN NUESTROS CAJEROS
				OR 
				(piTipoLayOut = 7)
			) THEN  --ELIF (1.1)

			SELECT FIRST 1 
			( SUBSTR(Registro, vsposicion_Regtxn, 12) ) AS Registros_txn,  -- TOTAL REGISTROS 
			( SUBSTR(Registro, vsposicion_Montotxn, 12) ) AS Monto_txn	-- MONTO TOTAL
			INTO vsRegistros_txn, vsMonto_txn
			FROM bditarjeta:"informix".td_carga_archivo_stat06 
			WHERE Registro MATCHES '*Total de Transacciones:*';

			-- BORRA LOS REGISTROS DE ENCABEZADO
			DELETE FROM BdiTarjeta:"informix".td_carga_archivo_stat06 
			WHERE ((Registro MATCHES '  Adquirente*') 
			OR (Registro MATCHES '===============*') 
			OR (Registro MATCHES '*Institucion            Clave:*') 
			OR (Registro MATCHES '*Codigo: STAT0*') 
			OR (Registro MATCHES '    *' ) 
			OR (Registro MATCHES '   ' ) 
			OR (Registro MATCHES '  Emisor*' ) 
			OR (Registro = '' ) ) 
			AND NOT (Registro MATCHES '        Total de Transacciones: *' );

		ELSE -- ERROR EN CASO QUE NO SE ENCUENTRE ALGUN LAYOUT

            LET vsTipoSumario 			= 'ERROR LAYOUT';
            LET viInicioCadena_Reg 		= 0;
            LET viInicioCadena_Monto 	= 0;
            LET viPosMontoReg_Ini 		= 0;
            LET viPosMontoReg_Fin 		= 0;
			
			LET vsCodRet = '00103';
            LET vsMensaje_Respuesta = '[' || vsCodRet ||  '] NO SE ESPECIFICO EL TIPO DE LAYOUT DEL ARCHIVO (' || psNomArchivo || ').';		
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;

		END IF; -- IF (1)
		
		LET vsMensaje_Respuesta = 'PROCESO EXITOSO';
		
		IF (TRIM(vsTipoSumario) = 'ERROR HEADER') THEN --ERROR. NO CONTIENE EL ENCABEZADO CORRESPONDIENTE IF (2)
			
			LET vsCodRet = '00104';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE EL ENCABEZADO CORRESPONDIENTE AL TIPO LAYOUT: ' || piTipoLayOut || '.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF (TRIM(vsTipoSumario) = 'ERROR LAYOUT') THEN --ERROR. NO CORRESPONDE A NINGUN LAYOUT
			
			LET vsCodRet = '00105';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CORRESPONDE A NINGUN TIPO DE LAYOUT REGISTRADO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELSE
		
            LET vsMensaje_Respuesta = 'VALIDANDO REGISTROS EN SUMARIO/TRAILER SON NUMERICOS.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsRegistros_txn ) INTO vdRegistros_txn;
			EXECUTE PROCEDURE bditarjeta:"informix".sp_ConcReing_EsNumerico( vsMonto_txn ) INTO vdMonto_txn;
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		END IF; -- IF (2)	

		IF ( vdRegistros_txn = 'F' ) THEN --ERROR TOTAL REGISTROS NO ES NUMERICO -- IF (2.3)
			
			LET vsCodRet = '00106';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN TOTAL REGISTROS NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
			
		ELIF ( vdMonto_txn = 'F' ) THEN --ERROR MONTO TOTAL NO ES NUMERICO
			
			LET vsCodRet = '00107';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') CONTIENE UN MONTO TOTAL NO NUMERICO.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELIF ( vdRegistros_txn = 'V'  AND vdMonto_txn = 'V' ) THEN -- SI TODO LOS REGISTROS SON NUMERICOS SE REALIZA LO SIGUIENTE:
		
			LET vsMensaje_Respuesta = 'SE VÃÂLIDO QUE SE TIENEN NÃÂMEROS EN LAS TXN DE REGISTROS Y MONTO';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
		
		ELSE 
	
			LET vsCodRet = '00108';
			LET vsMensaje_Respuesta = '[' || vsCodRet ||  ']EL ARCHIVO (' || psNomArchivo || ') NO CONTIENE INFORMACIÃÂN O PRESENTA ALGUNA INCONSISTENCIA.';
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'CodigoRetorno: ' || vsCodRet || ' Mensaje: ' || vsMensaje_Respuesta, 'sysconau')
			INTO vCodRetAux;
	
		END IF; -- IF (2.3)

	RETURN vsCodRet, DECODE (vsCodRet, '00000', '', vsMensaje_Respuesta || ' CÃÂ³digo Bitacora Final: ' || vCodRetAux), NVL(vsRegistros_txn, 0), NVL((vsMonto_txn), 0.0), 1;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de obtener los datos principales del archivo de conciliacion ATM STAT06 y validar su integridad/estructura',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_dbload_archivos_stat06
(
	psRuta_Repositorio VARCHAR (90),
	psNomArchivo VARCHAR (30),
	psArchivoOrigen VARCHAR(3), 
	piTipoLayOut INTEGER,
	psSistema VARCHAR(1)
)

RETURNING VARCHAR (5) AS rCodigoRetorno, VARCHAR(250) AS rMensajeRespuesta;

    DEFINE SQLERR 					INTEGER;
	DEFINE ISAM_ERR 				INTEGER;
	DEFINE ERROR_INFO 				VARCHAR(250);    
    DEFINE vCODIGO_RETORNO 			VARCHAR(5);
    DEFINE vMENSAJE_RETORNO 		VARCHAR(250);
    DEFINE CONTADOR_TRANSACCIONES 	SMALLINT;
    DEFINE RUTA_ORIGEN 				VARCHAR(100);
    DEFINE vExecuteSQL 				LVARCHAR(1000);
    DEFINE vNombreTablaCarga 		VARCHAR(90);
    DEFINE vCaracterDelimitador 	CHAR(1);    
    DEFINE vNomCarga_DBLOAD 		VARCHAR(20);
    DEFINE vNomError_DBLOAD 		VARCHAR(20);
    DEFINE vNomError_Ejecucion 		VARCHAR(16);
    DEFINE vNombreArchivo 			VARCHAR(23);
    DEFINE vNombreCompScript 		VARCHAR(113); -- suma de psRuta_Repositorio + vNomCarga_DBLOAD + psArchivoOrigen
    DEFINE vNombreCompTXT 			VARCHAR(113);
    DEFINE vNombreCompLog 			VARCHAR(113);
    DEFINE vNombreEjecucionLog 		VARCHAR(113);
    DEFINE vNombreArchivoLog 		VARCHAR(113);
    
	LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET vCODIGO_RETORNO = '';
    LET vMENSAJE_RETORNO = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vExecuteSQL = '';    
	LET vNombreTablaCarga = '';
    LET vCaracterDelimitador = '';
	LET vNomCarga_DBLOAD = 'dbload_carga_';
	LET vNomError_DBLOAD = 'dbload_error_';    
	LET vNomError_Ejecucion = 'error_ejecucion_';    
    
    LET vNombreCompScript = TRIM(psRuta_Repositorio)||'/'||vNomCarga_DBLOAD||LOWER(psArchivoOrigen)||'.sql';
	LET vNombreCompTXT = TRIM(psRuta_Repositorio)||'/'||vNomCarga_DBLOAD||LOWER(psArchivoOrigen)||'.txt';
	LET vNombreCompLog = TRIM(psRuta_Repositorio)||'/'||vNomError_DBLOAD||LOWER(psArchivoOrigen)||'.log';
	LET vNombreEjecucionLog = TRIM(psRuta_Repositorio)||'/'||vNomError_Ejecucion||LOWER(psArchivoOrigen)||'.log';
	LET vNombreArchivoLog = vNomError_Ejecucion||LOWER(psArchivoOrigen)||'.log';
    
    LET vNombreArchivo = psNomArchivo;
    
    -- SET DEBUG FILE TO RUTA_ORIGEN||"debug_sp_cnc_dbload_archivos.out";
    -- TRACE ON;

	BEGIN
        
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            -- SET DEBUG FILE TO RUTA_ORIGEN||"excep_sp_cnc_dbload_archivos.err.out" WITH APPEND;
            -- TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN                
                LET vMENSAJE_RETORNO = 'Archivo '||vNombreArchivo||' Proceso '||vCODIGO_RETORNO||' SQL_ERR '||SQLERR||' '||'Leer archivo '||vNombreArchivoLog||' '||current;
                LET vCODIGO_RETORNO = SQLERR;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        LET vCaracterDelimitador = '+';
        LET vNombreTablaCarga = 'td_carga_archivo_stat06';        
        LET vNomCarga_DBLOAD = 'dbload_carga_';
        LET vNomError_DBLOAD = 'dbload_error_';        
        
        LET vCODIGO_RETORNO = '00001';
        LET vMENSAJE_RETORNO = 'LIMPIAR TABLA DE TRABAJO.';

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo truncate table bditarjeta:'||vNombreTablaCarga||' drop storage  > '|| vNombreCompScript;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess bditarjeta '||vNombreCompScript;
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "rm -f "||vNombreCompScript;
        SYSTEM vExecuteSQL;        
        
        LET vCODIGO_RETORNO = '00002';        
        LET vMENSAJE_RETORNO = 'GENERAR COMANDO DE CARGA.';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo)|| "' delimiter '"||vCaracterDelimitador||"' "|| '1'||
                    "; INSERT INTO "||vNombreTablaCarga|| ";"||'"'||' > '||vNombreCompTXT;
        SYSTEM vExecuteSQL;
        
        LET vCODIGO_RETORNO = '00003';        
        LET vMENSAJE_RETORNO = 'EJECUTAR CARGA DE ARCHIVO.';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d bditarjeta -c "||vNombreCompTXT||" -l "||vNombreCompLog||" -n "||CONTADOR_TRANSACCIONES||" -r > "||vNombreEjecucionLog;
        SYSTEM vExecuteSQL;        
        
        LET vCODIGO_RETORNO = '00004';        
        LET vMENSAJE_RETORNO = 'BORRAR ARCHIVOS DE DBLOAD CARGA | ERROR CARGA | DE EJECUCION';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||vNombreCompTXT ||' '||vNombreCompLog||' '||vNombreEjecucionLog;
        SYSTEM vExecuteSQL;        
    
        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'CARGA DE ARCHIVO EXITOSA.'||psNomArchivo;

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
	
    END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de carga la informacion en bruto a una tabla de paso del archivo de conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_obtenerregistroarchivo_stat06 
(
	psNomArchivo VARCHAR (23),     --  Nombre del archivo el cual se esta cargando
	psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
	piTipoLayOut INTEGER, 		   --  Tipo de layout
	psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;

	/*  DEFINICION DE VARIABLES */
	DEFINE viSQLerr 				INTEGER ;
	DEFINE vsCodRet 				VARCHAR(5);
	DEFINE vsMensaje_Respuesta 		VARCHAR(250);	
	DEFINE vsRegistro 				CHAR(500);  		-- Se actualizo de 325 a 500
	DEFINE vsfechalocaldia 			CHAR(2);  			
	DEFINE vsfechalocalmes 			CHAR(2);  			
	DEFINE vshoralocalhr 			CHAR(2);  			
	DEFINE vshoralocalmin  			CHAR(2);  			
	DEFINE vsIDSecuencia 			CHAR(1);  			
	DEFINE vsSecuencia 				CHAR(6);  			
	DEFINE vsSecuencia_extendida 	CHAR(15);  			

	-- Para CashBack
	DEFINE vsRegistroMontototal 		Char(13);
	DEFINE vsRegistroMontoCashBack 		Char (13);
	DEFINE vsRegistroComprareal 		Char(13);
	DEFINE viconcaracteres 				integer;
	define a 							integer;
	DEFINE vmRegistroMontototal 		money;
	DEFINE vmRegistroMontoCashBack 		money;
	DEFINE vmRegistroComprareal 		money;

	DEFINE vsFlagEnTransaccion 			VARCHAR (1);
	DEFINE viContadorRegistros 			INTEGER;

	-- Para identificar el tipo de bin 
	DEFINE vsbin 					char (6);
	DEFINE vsbbin 					char (3);
	DEFINE vstpotarjeta 			char(1);
	DEFINE vsprefijo 				char(10);
	DEFINE vsfoliocorresponsales 	char(16); -- Para extraer folio suc
	DEFINE vsnumtarjeta 			char(16);
	DEFINE vsnocredito 				char(20);
	DEFINE vsinicredito 			char(1);

	-- Para recuperar desde carga nÃÂÃÂºmero de cuenta Proceso Transfer
	Define vscuenta 				char (12);
	define vsnumtarjetaini 			char(16);
	define vsvalor 					char(90);
	define vsestransfer 			char(1);

	/* Variable para cajeros idenfificar bines no propios */
	DEFINE vsCompania 				CHAR (01);

	--Fechas para identificar procesos en layout 1 y 6 Coppel Pay
	DEFINE dFechaProceso 			DATETIME YEAR to SECOND;
	DEFINE dFechaReproceso 			DATETIME YEAR to SECOND;
	DEFINE dFechaProcesoAux 		DATETIME YEAR to SECOND;
	DEFINE iTotRegistrosAux 		INTEGER;
	DEFINE iTotRegEglobal 			INTEGER;	

	-- SET DEBUG FILE TO "/informix/LVRQ/SecuenciayATM/debug/obtieneregistro.out";
	-- TRACE ON;

	/* INICIALIZACION DE VARIABLES */
	LET viSQLerr 				= 0;    
	 
	LET vsCodRet 				= '00000';
	LET vsMensaje_Respuesta 	= '';
	LET vsRegistro  			= '';
	LET vsfechalocaldia 		= '';  
	LET vsfechalocalmes 		= '';  
	LET vshoralocalhr 			= '';  
	LET vshoralocalmin 			= '';  
	LET vsIDSecuencia 			= '1';  
	LET vsSecuencia 			= '';  
	LET vsSecuencia_extendida 	= '';  


	--Para CashBack
	LET vsRegistroMontototal 	= '';
	LET vsRegistroMontoCashBack = '';
	LET vsRegistroComprareal 	= '';
	LET viconcaracteres 		= 0;
	let a 						= 0;
	LET vmRegistroMontototal 	= 0.0;
	LET vmRegistroMontoCashBack = 0.0;
	LET vmRegistroComprareal 	= 0.0;

	LET vsFlagEnTransaccion 	= '';
	LET viContadorRegistros 	= 0;

	-- Para identificar el tipo de bin 
	LET vsbin 						= '';
	LET vsbbin 						= '';
	LET vstpotarjeta 				= '';
	LET vsprefijo 					= '';
	LET vsfoliocorresponsales 		= '';
	LET vsnumtarjeta 				= '';
	let vsnocredito 				= '';
	let vsinicredito 				= '';

	-- Para recuperar desde carga numero de cuenta
	let vscuenta 			= '';
	let vsnumtarjetaini 	= '';
	let vsvalor 			= '';
	let	vsestransfer 		= '';

	/* Variable para cajeros idenfificar bines no propios */
	LET vsCompania 	= '';

	--Fechas para identificar procesos en layout 1 y 6 Coppel Pay
	LET dFechaProceso = CURRENT;
	LET dFechaReproceso = CURRENT;
	LET iTotRegistrosAux = 0;
	LET iTotRegEglobal = 0;

	BEGIN

	ON EXCEPTION SET viSQLerr
		-- SET DEBUG FILE TO "/home/c90296115/exc_sp_cnc_obtener_registro_archivo.out" WITH APPEND;
		-- TRACE ON;
		
		TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		BEGIN WORK;
		
		DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCIONPENDIENTE PARA TABLA td_movimientos_cnc_coppel_pay.								
		DELETE FROM BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen; 
		
		COMMIT WORK;
		
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		BEGIN WORK;
		
		-- BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
		TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_stat06;
		COMMIT WORK;
		
		BEGIN WORK;
		
		-- BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA.
		DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
		
		LET vsCodRet = '00200';	
		
		RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;
	
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	-- Se elimina el registro con el detalle total de tsn y monto
	DELETE FROM BdiTarjeta:"informix".td_carga_archivo_stat06 
	WHERE (Registro MATCHES '        Total de Transacciones: *' );
	
	SELECT COUNT(*) 
	INTO iTotRegistrosAux
	FROM Td_Movimientos_Conciliacion 
	WHERE NombreArchivo = psNomArchivo 
	AND Archivo_Origen = psArchivoOrigen;

	IF iTotRegistrosAux = iTotRegEglobal AND iTotRegEglobal <> 0 THEN
	
		--REPROCESO.
		DELETE FROM Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		DELETE FROM td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
	end if
	
    FOREACH WITH HOLD

		-- RECORRE LA TABLA PARA OBTENER LOS REGISTROS
		-- Esta tabla es de paso, y se emplea para carga la informacion de los archivos de conciliacion
		-- solo tiene un campo, por tanto es esperado el sequential scan
		SELECT Registro
		INTO vsRegistro
		FROM BdiTarjeta:"informix".td_carga_archivo_stat06
		
		IF (vsFlagEnTransaccion = 'F') THEN 
			BEGIN WORK;
			LET vsFlagEnTransaccion = 'V';
		END IF;

		IF ((piTipoLayOut = 4) or (piTipoLayOut = 7)) THEN -- ATM BANCOPPEL y ATM IST
			LET vsbin =  TRIM(SUBSTR (vsRegistro,37,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,37,16));
		END IF;
			
		-- OBTENCION DE NUMERO CUENTA DEBIDO A QUE TRAIA MAS DE UNA CUENTA EL REGISTRO 
		SELECT FIRST 1 numcuenta  
		INTO vscuenta 
		FROM Intercard:"informix".tarjetacuenta
		where  numcuenta != ''
		AND numtarjeta = vsnumtarjetaini;
	
		if vscuenta is null or vscuenta = '' then
			let vscuenta = '000000000000';
		END IF;
		
		if (vsbin <> 'NPT')  then
			select creditodebito, prefijo 
			into vstpotarjeta, vsprefijo 
			from Intercard:"informix".bines 
			where bin = vsbin;
		END IF;

		if ((vsbin <> '') and (vsbin <> 'NPT')) then
			LET vsbbin = 	
				CASE 	
					WHEN (vstpotarjeta = 'D') and (vsprefijo = 'DEBC') THEN 
						'VDE' 	--VISA DEBITO
					WHEN (vstpotarjeta = 'C') and (vsprefijo = 'CRED') THEN 
						'VCR'	-- VISA CREDITO
					WHEN ((vstpotarjeta = 'D') and (vsprefijo = 'MDP')) OR ((vstpotarjeta = 'D') and (vsprefijo = 'MPG')) THEN 
						'MDE'	--  MASTERCARD DEBITO
					WHEN ((vstpotarjeta = 'C') and (vsprefijo = 'MPL')) OR ((vstpotarjeta = 'C') and (vsprefijo = 'MSC')) OR  ((vstpotarjeta = 'C') and (vsprefijo = 'MCPL'))THEN 
						'MCR'	--  MASTERCARD CREDITO
					ELSE 
						'BNI'
				END;
		elif vsbin = 'NPT' then
			LET vsbbin = 'NPT';
		else
			LET vsbbin = 'BNI';
		end if;
		
		LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA CONCILIACION_ATM_STAT06.';
		
		IF (piTipoLayOut = 7) THEN 
			
			LET vsfechalocaldia = TRIM(SUBSTRING (vsRegistro FROM 150 FOR 2 )); --FECHA_dia
			LET vsfechalocalmes = TRIM(SUBSTRING (vsRegistro FROM 153 FOR 2 )); --FECHA_mes
			LET vshoralocalhr = TRIM(SUBSTRING (vsRegistro FROM 159 FOR 2 )); --hora
			LET vshoralocalmin = TRIM(SUBSTRING (vsRegistro FROM 162 FOR 2 )); -- minutos
			LET vsSecuencia = TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )); -- autorizacion
			
			LET vsSecuencia_extendida = vsfechalocalmes||vsfechalocaldia||vshoralocalhr||vshoralocalmin||vsIDSecuencia||vsSecuencia;
			
			LET vsCompania = TRIM(SUBSTRING (vsRegistro FROM 234 FOR 1 ));
			
			IF (vsbbin = 'BNI') THEN 
			
				IF (vsCompania = 'D') THEN
				
					LET vsbbin ='BND';
				
				ELIF (vsCompania ='C') THEN
				
					LET vsbbin ='BNC';
				
				END IF;
			 
			END IF;
			
			INSERT INTO Intercard:"informix".Conciliacion_ATM_Stat06 
			( 
				FechaConciliacion, 
				ArchivoOrigen, 
				NombreArchivo, 
				Emisor, 
				NumCajero, 
				NumTarjeta, 
				NumCuenta, 
				IndicadordeReversa, 
				Descripcion, 
				Respuesta, 
				CodigoISO, 
				Secuencia, 
				Fecha, 
				Hora, 
				Orden, 
				Red, 
				Monto, 
				Dolares, 
				ComisionSurcharge, 
				Donativo, 
				Emp, 
				Autorizacion, 
				Compania, 
				Comision_LoyaltyFee, 
				Comision_UsoLinea,
				pos_entry_mode,
				service_code,
				terminal_capability,
				arqc, 
				arpc,
				arqc_verify,
				secuenciaextendida
			)
			VALUES 
			(
				CURRENT,
				psArchivoOrigen,
				TRIM(psNomArchivo),
				TRIM(SUBSTRING (vsRegistro FROM 3 FOR 4 )), --EMISOR
				TRIM(SUBSTRING (vsRegistro FROM 25 FOR 12 )), --NUMCANERO
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )), -- NUMTARJETA
				TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--NUMCUENTA
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --DESCRIPCION
				TRIM(SUBSTRING (vsRegistro FROM 121 FOR 6 )), --RESPUESTA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --CODIGOISO
				TRIM(SUBSTRING (vsRegistro FROM 133 FOR 12 )), --SECUENCIA
				TRIM(SUBSTRING (vsRegistro FROM 150 FOR 8 )), --FECHA
				TRIM(SUBSTRING (vsRegistro FROM 159 FOR 8 )), --HORA
				TRIM(SUBSTRING (vsRegistro FROM 170 FOR 6 )), --ORDEN
				TRIM(SUBSTRING (vsRegistro FROM 176 FOR 4 )), --RED 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 192 FOR 7 )),  --DOLARES
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --COMISIONSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 211 FOR 10 )),  --DONATIVO
				TRIM(SUBSTRING (vsRegistro FROM 222 FOR 4 )),  --EMP
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )),  --AUTORIZACION
				vsbbin,  --TRIM(SUBSTRING (vsRegistro FROM 234 FOR 10 )), --COMPAÃÂ?IA  -- SE QUITA Y PONE BANDERA DE BIN
				TRIM(SUBSTRING (vsRegistro FROM 245 FOR 10 )),  --COMISION_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistro FROM 256 FOR 10 )),  --COMISION_USOLINEA
				TRIM(SUBSTR(vsRegistro, 271, 3)), -- POS ENTRY MODE
				TRIM(SUBSTR(vsRegistro, 275, 1)), -- SERVICE CODE
				TRIM(SUBSTR(vsRegistro, 277, 8)), -- Terminal capability
				TRIM(SUBSTR(vsRegistro, 286, 16)), -- ARQC
				TRIM(SUBSTR(vsRegistro, 303, 32)), -- ARPC
				TRIM(SUBSTR(vsRegistro, 336, 1)), -- ARQC verification
				vsSecuencia_extendida -- secuencia extendida generada del archivo
			);				
			
			LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA TD_MOVIMIENTOS_CONCILIACION';	
			
			--Se agrega la InserciÃÂÃÂ³n en td_movimientos_conciliaciÃÂÃÂ³n para registros del Stat06 LAGS
			INSERT INTO BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
			(
				NombreArchivo,
				Archivo_Origen,
				NumTarjeta,
				ban_bin,
				Secuencia325,
				Monto325,
				MontoSurcharge325,
				NumCuenta,
				estransfer,
				IdComercio325,
				NomComercio325,
				TipoTransaccion325,
				Referencia23_325,
				RFC325,
				Divisa325,
				Monto_Divisa325,
				ISO323, 
				MovRev325,
				Cve_Usuario,
				secuencia_ext_archivo
			)
			VALUES
			(
				psNomArchivo,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistro FROM 37 FOR 16 )),  --NUMTARJETA
				vsbbin,
				TRIM(SUBSTRING (vsRegistro FROM 227 FOR 6 )), --SECUENCIAAUTH 
				TRIM(SUBSTRING (vsRegistro FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistro FROM 200 FOR 10 )),  --MONTOSURCHARGE
				TRIM(SUBSTRING (vsRegistro FROM 60 FOR 20 )),	--NUMCUENTA LVRQ se obtiene de archivo
				trim(vsestransfer),
				'',  --IDCOMERCIO
				'',  --NOMCOMERCIO
				TRIM(SUBSTRING (vsRegistro FROM 103 FOR 15 )), --TIPOTRANSACCION
				'',  --REFTRANSACCION
				'',  --RFC
				'',  --DIVISA
				'',  --MONTODIVISA
				TRIM(SUBSTRING (vsRegistro FROM 128 FOR 2 )), --ISO325 
				TRIM(SUBSTRING (vsRegistro FROM 82 FOR 19 )), --MOVREV325 
				psCve_Usuario,
				vsSecuencia_extendida
			);
		END IF;
		
		IF (piTipoLayOut = 7) THEN
			LET viContadorRegistros = viContadorRegistros + 2;
		ELSE 
			LET viContadorRegistros = viContadorRegistros + 1;		
		END IF;
		
		LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
		
		-- TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros >= 1000) THEN                
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
	END FOREACH;

	LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
	
	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
	END IF;
	
	LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE TD_CARGA_ARCHIVO_STAT06.';
	
	BEGIN WORK;	
	
	LET vsFlagEnTransaccion = 'V';

	-- BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
    TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;

	COMMIT WORK;
	
	LET vsFlagEnTransaccion = 'F';
	LET vsMensaje_Respuesta = '';

	RETURN vsCodRet, vsMensaje_Respuesta, 2;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de parsear la ifnromacion del archivo de conciliacion ATM STAT06 para guardar los datos en la tabla principal de la conciliacion',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_validaintegridad_stat06 
( 
	psArchivo_origen CHAR (3), 
	psConsecutivo INTEGER,
	psNumTarjeta CHAR(16),
	psTipotransaccion325 CHAR(15),
	pmMonto325 CHAR(13),
	pmMontoCashBack325 CHAR (13), 
	psIdcomercio325 CHAR(15), 
	psNomcomercio325 CHAR(30),
	psReferencia23_325 CHAR(23),
	psSecuencia325 CHAR(6),
	psDivisa325 CHAR(3), 
	psRfc325 CHAR(16),
	psBinDebito CHAR(6), 
	psBinCredito CHAR(6),
	psSistema CHAR(1)
)

RETURNING CHAR (5) AS Retorno, CHAR (1) AS Integridad, CHAR(250) AS ErrorActividad, INTEGER AS Elemento;

	/*VARIABLES DE ERRORES*/
	DEFINE vsIntegridad	CHAR(1);
	DEFINE vsErrorIntegridad CHAR(20);
	DEFINE vsErrorActividad	CHAR(250);

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsFlagError CHAR (1) ;

	DEFINE vsEsNumTarjeta	CHAR(1);
	DEFINE vsEsIdComercio	CHAR(1);
	DEFINE vsEsReferencia23_325	CHAR(1);
	DEFINE vsEsSecuencia325	CHAR(1);
	DEFINE vsEsDivisa325	CHAR(1);
	DEFINE vsEsMonto		CHAR(1);
	--DEFINE vmMonto325 MONEY(19,4);
	DEFINE vmMonto325 MONEY;
	DEFINE vsEsMontoCashBack325 CHAR(1);
	DEFINE vmMontoCashBack325 MONEY;

	DEFINE vsBine	CHAR(6);

	/* INICIALIZACION DE VARIABLES */
	LET vsIntegridad = '';
	LET vsErrorIntegridad = '';
	LET vsErrorActividad = '';

	LET vsEsNumTarjeta = '';
	LET vsEsIdComercio = '';
	LET vsEsReferencia23_325 = '';
	LET vsEsSecuencia325 = '';
	LET vsEsDivisa325 = '';
	LET vsEsMonto = '';
	LET vmMonto325 = 0;
	LET vsEsMontoCashBack325 = '';
	LET vmMontoCashBack325 = 0;
	
	LET vsBine = '';

	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsFlagError = '' ;

	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;
				LET vsFlagError = 'F';

				RETURN vssqlerr, vsFlagError, vsErrorActividad, 3;

		END EXCEPTION;

		--SET DEBUG FILE TO '/home/c90296115/TraceINTEGRIDAD_mike.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		/*OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA*/
		
		LET vsBine = NVL(SUBSTRING (psNumTarjeta FROM 1 FOR 6),'');
		LET vmMonto325 = ( ( REPLACE( pmMonto325,'.',''))::MONEY/100 );
		LET vmMontoCashBack325 = ((REPLACE (pmMontoCashBack325,'.',''))::MONEY/100); --Conversion de string de monto cashback a money
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico ( psNumTarjeta ) INTO vsEsNumTarjeta;

		-- VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL VENTAS INTERNACIONALES
		-- BCPLVID Y BCPLVIC
		IF TRIM(NVL(psArchivo_origen,''))='' THEN
			
			LET vssqlerr = '00307';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';

		-- VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS PROSA
		-- BCPL_ATMOL Y BCPL_ATMPL
		ELIF ( ( psArchivo_origen = 'TMO' ) OR ( psArchivo_origen = 'TMP' ) OR ( psArchivo_origen = 'IST' ) ) THEN
			LET vssqlerr = '00305';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			--VALIDACION DEL NUMERO DE TARJETA
			IF LENGTH(psNumTarjeta)!=16 THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: DEBE SER IGUAL A 16 CARACTERES';
				
			ELIF TRIM(NVL(psNumTarjeta,''))='' THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE ESTAR VACIO';
				
			ELIF (vsEsNumTarjeta != 'V' ) THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR3 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: SOLO DEBE CONTENER DIGITOS';
				
			ELIF psNumTarjeta = '0000000000000000' THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR4 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE TENER SOLO CEROS';
				
			ELSE
			
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';

			END IF;

		ELSE
			LET vssqlerr = '00306';
			
			/*SE HA MANDADO COMO PARAMETRO OTRO TIPO DE ARCHIVO*/
			LET vsIntegridad = 'F';
			LET vsErrorIntegridad = 'ERROR archivo_origen';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';
			
		END IF;

			/*ACTUALIZAR VARIABLES DE RETORNO*/
			LET vsFlagError = vsIntegridad;
		
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET integridad = vsIntegridad, integridad_error = vsErrorIntegridad
			WHERE consecutivo = psConsecutivo;

			IF (vsIntegridad NOT IN ('V')) THEN

				LET vsErrorActividad ='CONSECUTIVO '|| psConsecutivo || ' CONTIENE ' || vsErrorActividad;
				
				IF (vssqlerr = '00305') THEN 
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 ('3', '(' || psConsecutivo || ') ' || vsErrorActividad, 'sysconau');
					LET vssqlerr = '00000';
				END IF;
				
			END IF;

		RETURN vssqlerr, NVL(vsFlagError,''),'', 3 ;

	END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de valdiar la integridad de los registros del archivo de conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_guardabitacora_stat06
(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsFechaHora DATETIME YEAR TO FRACTION(5);

	/*INICIALIZACION DE VARIABLES*/
	LET visqlerr = 0;
	LET vssqlerr = '00000';
	LET vsFechaHora = CURRENT;

	BEGIN

		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

		
		-- SET DEBUG FILE TO '/home/c90296115/guardaBitacoraDep.txt';
		-- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_atm_stat06 (elemento, fecha_hora, actividad, cve_usuario)
		VALUES (psElemento,vsFechaHora,psActividad,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;

	END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Bitacora conciliacion ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_obt_archivo_stat06()

	RETURNING VARCHAR (5) AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
	
	/* DEFINICION DE VARIABLES */

	-- CONTROL DE ERRORES
		
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
		
	--CONTROL GENERAL
	
	DEFINE CODIGO				CHAR (6);
	DEFINE MENSAJE_RPTA			CHAR (80);
	DEFINE vRUTA_ESTAT_06		CHAR (33);
	DEFINE vCodigo				CHAR (6);
	DEFINE vListArchivo			CHAR (20);
	DEFINE vArchiBat			CHAR (20);
	DEFINE vExecuteSQL 			CHAR (300);
	DEFINE vsNombreArchivo 		CHAR (30);
	DEFINE dsFechaArchivo 		CHAR (10);
	DEFINE FlagTrace 		CHAR (10);
			
	BEGIN	
				
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			LET CODIGO    		= SQL_ERR;
			LET MENSAJE_RPTA  	= ERROR_INFO;

			DELETE FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06;
			
			RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
				
		--SET DEBUG FILE TO "/home/c90296115/nombre_archivo_atm_stat06.out";
		--TRACE ON;
				
		/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
		
		LET CODIGO					= '00000';
		LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
		LET vRUTA_ESTAT_06			= '';
		LET vCodigo					= '00000';
		LET vListArchivo			= 'listado_archivos.txt';
		LET vArchiBat				= 'bat_stat06.bat';
		LET vExecuteSQL				= '';
		LET vsNombreArchivo			= '';
		LET dsFechaArchivo			= '';
		LET FlagTrace				= '';
		
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		LET FlagTrace = 'Se inicializan excepciones ';
		
		-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
		DELETE FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06;
					
		---DEFINE  Ruta de obtencion  
		SELECT rep_aix
		INTO vRUTA_ESTAT_06
		FROM bditarjeta:td_archivo_origen_atm_stat06
		WHERE archivo_origen = "IST";
		
		
	LET FlagTrace = 'Se obtuvo la ruta de la tabla ';	 
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "ls '|| vRUTA_ESTAT_06|| '| grep BCPL_STAT06_ " > ' || vRUTA_ESTAT_06||'/'||vArchiBat;
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 1';	
		LET vExecuteSQL ='';
		LET vExecuteSQL= 'chmod 777 ' || vRUTA_ESTAT_06||'/'||vArchiBat;
		system vExecuteSQL;
	LET FlagTrace = 'Paso 2';	
		LET vExecuteSQL = ''; 
		LET vExecuteSQL =  vRUTA_ESTAT_06||'/'||vArchiBat ||'>'|| vRUTA_ESTAT_06||'/'||vListArchivo; 
		SYSTEM vExecuteSQL; 
	LET FlagTrace = 'Paso 3';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm '||vRUTA_ESTAT_06||'/'||vArchiBat;
		system vExecuteSQL;
	LET FlagTrace = 'Paso 4';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_ESTAT_06) || '/' || TRIM(vListArchivo) ||
						 ' INSERT INTO bditarjeta:td_cga_nombre_archivo_atm_stat06;" > ' || TRIM(vRUTA_ESTAT_06) ||  '/load_nombre_archivo.sql';
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 5';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_ESTAT_06) ||  '/load_nombre_archivo.sql';
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 6';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm '||vRUTA_ESTAT_06||'/'||vListArchivo;
		system vExecuteSQL;
		
				
		FOREACH cursor_archivo FOR
				
			SELECT nom_archivo_stat06
				INTO vsNombreArchivo
			FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06
			                       
			IF SUBSTR(vsNombreArchivo,19,4) = '.txt' THEN
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'Registrando archivo ' || vsNombreArchivo || 'para procesar.' , 'sysconau')
				INTO vCodigo;
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,13,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,1,2)||'/'||SUBSTR(dsFechaArchivo,5,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				LET FlagTrace = 'Proceso el nombre del archivo para inserta';			
				-- TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
			
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_atm_stat06
					(nombrearchivo,
					archivo_origen,
					fecha_archivo,
					num_registros325,
					monto325,
					fecha_proceso,
					fecha_hora_transferencia, 
					fecha_hora_ini_proceso, 
					fecha_hora_carga_archivo, 
					fecha_hora_carga_tabla,					
					fecha_hora_ini_concilia_reg, 
					fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,
					fecha_hora_fin_conadminatm_intercard, 
					transferencia,
					carga,
					conciliacion_inter,
					conciliacion_admin_atm, 
					conciliacion_admin,
					traspaso_historico, 
					num_cargo, 
					monto_cargo,
					num_abono,
					monto_abono, 
					proceso) 
					VALUES( vsNombreArchivo, 'IST', dsFechaArchivo, 0, 0, CURRENT, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
						'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', 'V', 'V','F','F' ,0, 0, 0, 0, 'P');
			ELSE
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'El archivo de conciliacion STAT06 < ' || vsNombreArchivo || ' > no se puede procesar por el formato.', 'sysconau')
				INTO vCodigo;
				
				LET CODIGO = '00001';
				
			END IF
					
		END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO STAT06 ATM	

		IF CODIGO = '00001' THEN
		
			LET MENSAJE_RPTA = MENSAJE_RPTA || ' Se intento procesar un archivo con formato diferente. Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06 );
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , MENSAJE_RPTA, 'sysconau')
			INTO vCodigo;
				
		ELSE
		
			LET MENSAJE_RPTA = MENSAJE_RPTA || ' Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06 );
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , MENSAJE_RPTA, 'sysconau')
			INTO vCodigo;
			LET CODIGO = '00000';
		END IF
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE 
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de obtener el archivo del STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_mueve_archivo_atm_stat06_resp ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_STAT06			CHAR (34);
			DEFINE vRuta_Resp			CHAR (44);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;
			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/c98188925/debug/mov_archivo_dep_atm.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_STAT06				= '';
				LET vRuta_Resp				= '/home/sysconau/conciliacion/istsw/Respaldo';
				LET vListArchivo			= 'hay_archivos.txt';
				LET vArchiBat				= 'archivos_atm_stat06.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
				SELECT rep_aix
				INTO vRUTA_STAT06
				FROM BdiTarjeta:"informix".td_archivo_origen_atm_stat06
				WHERE archivo_origen='IST';
				

			FOREACH cursor_move FOR	
			
				SELECT nombrearchivo
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
				WHERE fecha_proceso = today 
				AND proceso='T'
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' if  [ -f '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)||' ]; ' ||     
				  ' then ' ||     
					' mv '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)|| ' ' ||vRuta_Resp||';'||  
				 ' fi  >' ||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				 SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' chmod 777 '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = 'rm -f '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
	

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE
	DOCUMENT
'Autor: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerencia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de realizar el respaldo del archivo de la conciliacion de ATM STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_carga_buen_fin_cnc(vArchivoDBLOAD CHAR(100), RUTA CHAR(100))

	RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	-- Define Var Init Var Control 
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE vNombreCompTXT		VARCHAR(100);
	DEFINE vNombreCompLog		VARCHAR(100);
	DEFINE vNombreEjecucionLog  VARCHAR(100);
	DEFINE nomArch              VARCHAR(100);
	DEFINE nomRut		    	VARCHAR(100);
	
	-- Define Var EXCEPTION
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Init Var Control
	LET nomRut = TRIM(RUTA);
	LET nomArch = vArchivoDBLOAD;
	LET vIntervaloCommit = 1000;
	LET vExecuteSQL	='';
	LET vNombreCompTXT = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.txt";
	LET vNombreCompLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023_log.log";
	LET vNombreEjecucionLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.log";
	
	-- Init Var Exception
	LET vCodigoRetorno = '00000';
	LET vMensaje = '';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	BEGIN 
		-- Flujo de Excepciones
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
					
			SET DEBUG FILE TO RUTA || "carga_.err.out";
			TRACE ON;
			
			IF ( SQLERR <> 0 ) THEN
				LET vCodigoRetorno = SQLERR;
				LET vMensaje = ERROR_INFO;                
				RETURN vCodigoRetorno, vMensaje;
			END IF;
					
		END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Termina Flujo de Exepciones 			
		
		-- Comienza Load de archivo 
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(nomRut) || '/' || TRIM(nomArch)|| "' delimiter '"|| '|' ||"' "|| '17'||
					"; INSERT INTO "|| 'tbl_bf_movs_cnc_sorteo' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
		LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d bditarjeta -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vIntervaloCommit ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL; 
		
		LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';

		RETURN vCodigoRetorno, vMensaje;
	END;
END PROCEDURE;