CREATE PROCEDURE "informix".sp_conciliacionautomatica_mc (psCve_Usuario VARCHAR(10) , piHorario INTEGER)
RETURNING VARCHAR (5) AS CodRet, VARCHAR (150) AS Mensaje_Respuesta ;



	
	/*  DEFINICION DE VARIABLES */ --CONTROL GENERAL

	DEFINE vsCodRet 						VARCHAR(5);
	DEFINE vsCodRet2 						VARCHAR(5);
	DEFINE vsMensaje_Respuesta 				VARCHAR (250);
	DEFINE viSQLerr 						INTEGER;
	DEFINE viElemento 						INTEGER;
	DEFINE dtFecha_Hoy_Integral 			DATE;
	DEFINE vsFlag_Ciclo_BusrcarArch 		VARCHAR (1);
    DEFINE vsFlag_ArchPendiente 			VARCHAR(1);
	DEFINE vsFlag_Error_Reg 				VARCHAR(1);
	DEFINE viContadorErrores_Pase_Credito 	INTEGER;
    DEFINE viContadorErrores_Pase_Debito	INTEGER;
	DEFINE vdDiaHora						DATETIME YEAR TO FRACTION(5);
	DEFINE vdFechaDeHoy						DATE;
		
	--DATOS ARCHIVO_CONCILIACION	
    DEFINE viTot_Registros 				INTEGER;
    DEFINE vmTot_Monto 					MONEY;
    DEFINE viNum_Cargo 					INTEGER;
    DEFINE vmMonto_Cargo 				MONEY;
    DEFINE viNum_Abono 					INTEGER;
    DEFINE vmMonto_Abono 				MONEY;
	
	--CONTROL DE TRANSACCIONALIDAD	
	DEFINE viContadorRegistros 			INTEGER;
	DEFINE vsFlagEnTransaccion 			VARCHAR (1);
		
	--DATOS MOVIMIENTOS_CONCILIACION	
    DEFINE vsNombreArchivo 				VARCHAR (30);
    DEFINE vsArchivo_Origen 			VARCHAR (3);
    DEFINE vdtFecha_Archivo 			DATE;
    DEFINE vsCarga 						VARCHAR (3);
    DEFINE vsPrefijo_Archivo 			VARCHAR (15);
    DEFINE vsSistema 					VARCHAR (1);
    DEFINE vsConciliacion_Inter 		VARCHAR(1);
    DEFINE vsConciliacion_SIF 			VARCHAR(1);
    DEFINE vsConciliacion_Admin 		VARCHAR(1);
    DEFINE viBorra_Archivo_Fisico 		INTEGER;
    DEFINE vsTransaccion_Compra 		VARCHAR (4);
    DEFINE vsTransaccion_Liberacion 	VARCHAR (4);
    DEFINE vsTransaccion_Forzada 		VARCHAR (4);
    DEFINE vsTransaccion_Abono 			VARCHAR (4);
    DEFINE vsRep_Aix 					VARCHAR (50);
    DEFINE vsRep_Win 					VARCHAR (50);
    DEFINE vsArchivo_Companero 			VARCHAR(3);
    DEFINE vsArchivo_Report_Comisiones 	VARCHAR(3);
    DEFINE viTipo_LayOut 				INTEGER;
	
	DEFINE vsFlag_Ciclo_BusrcarReg 		VARCHAR (1);
	DEFINE vsFlagIntegridad 			VARCHAR(1);
	DEFINE vsAplicacion VARCHAR(1);
    DEFINE vsBandera_Proceso VARCHAR(1);
    DEFINE vsTransaccion_Aplica VARCHAR(4);
    DEFINE vsSistema_Registro VARCHAR(1);
    DEFINE vscodgironeg CHAR (4);    -- TFORZADAS
    DEFINE vsb_aplica CHAR(1);    -- TFORZADAS
	
	--DATOS MOVIMIENTOS_CONCILIACION
    DEFINE viConsecutivo INTEGER;
    DEFINE vsNumTarjeta VARCHAR (16);
    DEFINE vsTipoTransaccion325 VARCHAR (15);
    DEFINE vsMonto325 VARCHAR (13);
    DEFINE vsMontoCashBack325 VARCHAR (13);
    DEFINE vsCuenta varchar(20); -- Integracion de transfer
    define vsestransfer varchar(1);
    DEFINE vsFechaopetransfer char(6);
    DEFINE vsIdcomercio325 VARCHAR (15);
    DEFINE vsNomcomercio325 VARCHAR (30);
    DEFINE vsReferencia23_325 VARCHAR (23);
    DEFINE vsSecuencia325 VARCHAR (6);
    DEFINE vsDivisa325 VARCHAR (3);
    DEFINE vsRfc325 VARCHAR (15);
    DEFINE vsSecuencia VARCHAR(7);
    DEFINE vsSecuencia_Extendida VARCHAR(15);
    DEFINE vmMontoIntercard MONEY;
    DEFINE vmMontoCashBack MONEY;
    DEFINE vsFechaTransaccion DATETIME YEAR TO FRACTION (5);
    DEFINE vsInfReceptor VARCHAR(40);
    DEFINE vsIdTerminal VARCHAR(16);
    DEFINE vsMetodoCaptura VARCHAR(2);
    DEFINE vsMovConciliado VARCHAR(1);
    DEFINE vsMovReversado VARCHAR(1);
    DEFINE vsTipo_Mov VARCHAR(1);
    DEFINE vsFolio_Mov VARCHAR(16);
    DEFINE vdFechaConcilia DATETIME YEAR TO FRACTION (5);
    DEFINE viTipo_Conciliacion INTEGER;
    DEFINE vsDesc_Conciliacion VARCHAR(60);
    DEFINE vsConciliacion_Reg VARCHAR(1);
    DEFINE vsNumCuenta VARCHAR(20);
    DEFINE vsMonto_Divisa325 VARCHAR(13);
    DEFINE vsISO323	CHAR(2);
    DEFINE vsMovRev325 CHAR(1);
    DEFINE vsTipoMov VARCHAR(1);
	
	
	DEFINE vsBinDebito VARCHAR(6);
	DEFINE vsBinCredito VARCHAR(6);
	DEFINE viActualizacion INTEGER;
	DEFINE vsTransaccionMoneyGram VARCHAR (4);
	DEFINE vsTransaccionCashBack VARCHAR (16);
	DEFINE vsConciliacionAdminAtm CHAR(1);
	DEFINE vsNombreArchivo_Comi VARCHAR(23);
	DEFINE viContadorErroresCon INTEGER;
	
	/* Secuencia extendida generada desde la carga */
	
	DEFINE vssecuencia_ext_archivo CHAR(15);
	DEFINE vsarchivo_origenMC 	   CHAR(03);
	DEFINE vDescripcionConcMC 	   VARCHAR(50);
    DEFINE vArchivoOrigenBol	   CHAR (3);

	DEFINE vsIdProcesador			   VARCHAR (05);
	DEFINE vssec_extendida_archivo	   VARCHAR (16);
    
	/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL

	LET viSQLerr = 0;   
	LET vsCodRet = '00000';
	LET vsCodRet2 = '00000';
	LET vsMensaje_Respuesta = '';
	LET viElemento = 0;
	LET dtFecha_Hoy_Integral = CURRENT::DATE;
	LET vsFlag_Ciclo_BusrcarArch = 'V';
	LET vsFlag_ArchPendiente = 'F';
	LET vsFlag_Error_Reg = '';
	LET viContadorErrores_Pase_Credito = 0;
    LET viContadorErrores_Pase_Debito = 0;
	LET vdDiaHora = CURRENT;
	LET vdFechaDeHoy = CURRENT::DATE;
	
	--DATOS ARCHIVO_ORIGEN
    LET vsNombreArchivo = '';
    LET vsArchivo_Origen = '';
    LET vdtFecha_Archivo = CURRENT::DATE;
    LET vsCarga = '';
    LET vsPrefijo_Archivo = '';
    LET vsSistema = '';
    LET vsConciliacion_Inter = '';
    LET vsConciliacion_SIF = '';
    LET vsConciliacion_Admin = '';
    LET viBorra_Archivo_Fisico = 0;
    LET vsTransaccion_Compra = '';
    LET vsTransaccion_Liberacion = '';
    LET vsTransaccion_Forzada = '';
    LET vsTransaccion_Abono = '';
    LET vsRep_Aix = '';
    LET vsRep_Win = '';
    LET vsArchivo_Companero = '';
    LET vsArchivo_Report_Comisiones = '';
    LET viTipo_LayOut = 0;
	
	--DATOS ARCHIVO_CONCILIACION
    LET viTot_Registros = 0;
    LET vmTot_Monto = 0.0;
    LET viNum_Cargo = 0;
    LET vmMonto_Cargo = 0.0;
    LET viNum_Abono = 0;
    LET vmMonto_Abono = 0.0;
	
	LET vsFlag_Ciclo_BusrcarReg = 'V';
	LET vsFlagIntegridad = '';
	LET vsTipoMov = '';
    LET vsBandera_Proceso = '';
    LET vsTransaccion_Aplica = '';
    LET vsSistema_Registro = '';
    LET vscodgironeg = '';  -- TFORZADAS
    LET vsb_aplica = ''; --TFORZADAS
    --CONTROL DE TRANSACCIONALIDAD
    LET vsFlagEnTransaccion = '';
    LET viContadorRegistros = 0;
	
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

	LET vsBinDebito = '';
	LET vsBinCredito = '';
	LET viActualizacion = 0;
	LET vsTransaccionMoneyGram = '';
	LET vsTransaccionCashBack = '';
	LET vsConciliacionAdminAtm = '';
	LET vsNombreArchivo_Comi = '';
	LET viContadorErroresCon = 0;
	
	LET vssecuencia_ext_archivo = '';
	LET vsarchivo_origenMC = '';
	LET vDescripcionConcMC = NULL;
    LET vArchivoOrigenBol  = '';
 			   
	LET vsIdProcesador	= '';
	LET vssec_extendida_archivo	  = '';
	
	BEGIN

		ON EXCEPTION SET viSQLerr
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			
			
			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			--TRACE 'ENTRE AQui 1';
			UPDATE BdiTarjeta:"informix".Td_Param_Conciliacion_mc 
					SET Valor = 'F',
					Fecha_Modificacion = vdFechaDeHoy
				WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION MC EN EJECUCION' 
			AND Valor = 'V';
			
			LET viElemento = 0;	
			LET vsCodRet = '00020';
			LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta);
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_mc (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario)
								INTO vsCodRet2;
			RETURN vsCodRet, vsMensaje_Respuesta;
			
		END EXCEPTION;	
		
		ON EXCEPTION IN (-535) --EN CASO DE TRANSACCION ABIERTA Y TRATAR DE ABRIR OTRA
			COMMIT WORK; --TERMINA LA TRANSACCION ACTUAL Y CONTINUA
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO "/informix/LVRQ/seven_new/debug/TRACE_CONAUTO_MC.sql";
		--TRACE ON;


		
		--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
		SELECT LIMIT 1 Fecha_Hoy 
			INTO dtFecha_Hoy_Integral 
		FROM bdinteg:"informix".Si_Fechas WHERE empresa = '001';
		
        
        LET vDescripcionConcMC = (SELECT Descripcion FROM BdiTarjeta:"informix".Td_Param_Conciliacion_mc 
                WHERE Codigo = '001' AND Descripcion = 'CONCILIACION MC EN EJECUCION' AND TRIM(Valor) = 'V' );
                
             -- 
			 
        LET vArchivoOrigenBol =  (SELECT Archivo_Origen FROM BdiTarjeta:"informix".Td_Archivo_Origentmp_mc 
                WHERE Horario_Ejecucion_Hoy = piHorario OR Horario_Ejecucion_Ext = piHorario);
                    
		-- IF PRINCIPAL
		IF ( vDescripcionConcMC <> '' OR  vDescripcionConcMC IS NOT NULL )
			THEN --VALIDA QUE NO EXISTA UNA CONCILIACION EN EJECUCION (CONCREING)
			
			--TRACE 'SI ENTRE :) 1';
			
				LET vsCodRet = '00001'; --CONCILIACION EN EJECUCIÃN --CONCREIN
				LET vsMensaje_Respuesta = 'CONCILIACION EN EJECUCION (CONCREIN).';
			
			ELIF (dtFecha_Hoy_Integral < vdFechaDeHoy ) 
				
				THEN -- VALIDA QUE EL SISTEMA DE INTEGRA ESTE A CORDE A LA DEL SERVIDOR
			
				LET vsCodRet = '00003'; --FECHAS INTEGRAR-SERVIDOR DESFASADAS 
				LET vsMensaje_Respuesta = 'FECHAS INTEGRAL-SERVIDOR DESFASADAS.';
				
			ELIF (vArchivoOrigenBol = '' OR vArchivoOrigenBol IS NULL )
			
				THEN --VALIDA QUE EL JOB/EJECUCION ESTE CONTEMPLADA PARA ALGUNO DE LOS ARCHIVOS
			
				LET vsCodRet = '00005'; --JOB NO CONTEMPLADO EN NINGUN ARCHIVO
				LET vsMensaje_Respuesta = 'JOB NO CONTEMPLADO EN NINGUN ARCHIVO.';
				
				
		ELSE --OK
		
			--TRACE 'SI ENTRE :) 1.1';
			LET vsMensaje_Respuesta = 'MARCAR CONCILIACION EN EJECUCIÃN.';
			
			
			--MARCA LA BANDERA DE CONCILIACION EN EJECUCION
			
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_mc
				SET Valor = 'V',  
				Fecha_Modificacion = vdFechaDeHoy
				WHERE Codigo = '001'
				AND Descripcion = 'CONCILIACION MC EN EJECUCION'
			AND TRIM(Valor) = 'F';

			LET vsFlag_Ciclo_BusrcarArch = 'V'; --ACTIVAR PARA BUSCAR UN ARCHIVO.
			
			
			WHILE (vsFlag_Ciclo_BusrcarArch = 'V')  --CICLO DE BUSQUEDA DE ARCHIVOS PENDIENTES.
				
				--TRACE 'SI ENTRE :) 2';
				
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
				
				
				-- SE CREA TABLA TEMPORAL PARA OBTENER REGISTRSO DE CARGA 
				
				SELECT Horario_Ejecucion_Hoy, orden_proceso,'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
					ArchCon.Fecha_Archivo, ArchCon.Carga,ArchOri.Prefijo_Archivo,ArchOri.Sistema, ArchOri.Conciliacion_Inter,
					ArchOri.Conciliacion_SIF, ArchOri.Conciliacion_Admin,ArchOri.Borra_Archivo_Fisico,
					ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada,ArchOri.Transaccion_Abono,
					ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
					FROM BdiTarjeta:"informix".Td_Archivos_Conciliacion_mc AS ArchCon 
					LEFT JOIN BdiTarjeta:"informix".Td_Archivo_OrigenTmp_mc AS ArchOri 
					ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
					WHERE 	ArchCon.Proceso = 'P'
					AND ArchCon.Fecha_Archivo = (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE 
					AND Horario_Ejecucion_Hoy <= piHorario
					ORDER BY Horario_Ejecucion_Hoy, orden_proceso ASC
				INTO temp tb_config_archivo_normal WITH NO LOG ;
				
				
				-- SE OBTIENE DATOS PARA ARCHIVO NORMAL
				
				SELECT FIRST 1
					Flag_ArchPendiente, NombreArchivo, Archivo_Origen, Fecha_Archivo,Carga, 
					Prefijo_Archivo, Sistema, Conciliacion_Inter, Conciliacion_SIF, Conciliacion_Admin,
					Borra_Archivo_Fisico, Transaccion_Compra, Transaccion_Liberacion, Transaccion_Forzada, 
					Transaccion_Abono, Rep_Aix, Rep_Win, 
					Archivo_Companero, Archivo_Report_Comisiones, Tipo_LayOut
					INTO 
					vsFlag_ArchPendiente, vsNombreArchivo, vsArchivo_Origen, vdtFecha_Archivo, vsCarga, 
					vsPrefijo_Archivo, vsSistema, vsConciliacion_Inter, vsConciliacion_SIF, vsConciliacion_Admin,
					viBorra_Archivo_Fisico, vsTransaccion_Compra, vsTransaccion_Liberacion, vsTransaccion_Forzada, 
					vsTransaccion_Abono, vsRep_Aix, vsRep_Win,  
					vsArchivo_Companero, vsArchivo_Report_Comisiones, viTipo_LayOut
				FROM tb_config_archivo_normal ;
				
				
				-- ARCHIVOS EXTEMPORANEOS 
				
				IF (NVL(vsFlag_ArchPendiente, 'F') <> 'V') THEN --NO ENCONTRO MOVIMIENTO NORMAL IF(1)
				
					--BUSCA EXTEMPORANEO

						--TRACE 'SI ENTRE :) 3';
					LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS A CONCILIAR EXTEMPORANEO.';
					
					
					SELECT Horario_Ejecucion_Ext, orden_proceso, 'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
							ArchCon.Fecha_Archivo, ArchCon.Carga, ArchOri.Prefijo_Archivo, ArchOri.Sistema, ArchOri.Conciliacion_Inter, 
							ArchOri.Conciliacion_SIF, ArchOri.Conciliacion_Admin,ArchOri.Borra_Archivo_Fisico,
							ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada, ArchOri.Transaccion_Abono,
							ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
						FROM BdiTarjeta:"informix".Td_Archivos_Conciliacion_mc AS ArchCon 
							LEFT JOIN BdiTarjeta:"informix".Td_Archivo_OrigenTmp_mc AS ArchOri 
							ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
						WHERE ArchCon.Proceso = 'P'
							AND ArchCon.Fecha_Archivo <= (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE
							AND Horario_Ejecucion_Ext <= piHorario
							ORDER BY Horario_Ejecucion_Ext, orden_proceso ASC
					INTO temp tb_config_archivo_extenporaneo WITH NO LOG ;
				
					
					SELECT FIRST 1
							Flag_ArchPendiente, NombreArchivo, Archivo_Origen, Fecha_Archivo,Carga, 
							Prefijo_Archivo, Sistema, Conciliacion_Inter, Conciliacion_SIF, Conciliacion_Admin,
							Borra_Archivo_Fisico, Transaccion_Compra, Transaccion_Liberacion, Transaccion_Forzada, 
							Transaccion_Abono, Rep_Aix, Rep_Win, 
							Archivo_Companero, Archivo_Report_Comisiones, Tipo_LayOut
					INTO 
							vsFlag_ArchPendiente, vsNombreArchivo, vsArchivo_Origen, vdtFecha_Archivo, vsCarga, 
							vsPrefijo_Archivo, vsSistema, vsConciliacion_Inter, vsConciliacion_SIF, vsConciliacion_Admin,
							viBorra_Archivo_Fisico, vsTransaccion_Compra, vsTransaccion_Liberacion, vsTransaccion_Forzada, 
							vsTransaccion_Abono, vsRep_Aix, vsRep_Win,  
							vsArchivo_Companero, vsArchivo_Report_Comisiones, viTipo_LayOut
					FROM tb_config_archivo_extenporaneo;
					
					
				END IF; -- IF(1)
				
					IF (NVL(vsFlag_ArchPendiente, 'F') = 'V') THEN -- EXISTEN ARCHIVOS PENDIENTE POR PROCESAR --IF(2)
					
						--TRACE 'SI ENTRE :) 4';
					
						LET vsFlag_Ciclo_BusrcarArch = 'V'; --ENCONTRO UN REGISTRO, ACTIVAR PARA BUSCAR EL SIGUIENTE
						LET vsFlag_Error_Reg = 'F';
						
						
						--VALIDA ESTATUS DEL PASE DE MOVIMIENTOS HITORICOS DE CREDITO  -- IF (2.1)
						
					IF ((vsSistema = 'A') AND (NOT EXISTS (SELECT Status_Proc FROM BdiCred:"informix".Sd_ContProc  -- IF (2.1)
						WHERE Proceso = 'Trasl_Dia' AND Fecha = (TODAY-1) AND Cod_Ret = '000' AND Status_Proc = 'F')) ) THEN 
					
							LET vsCodRet = '00006'; --NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HISTORICOS DE CREDITO
							LET vsMensaje_Respuesta = 'ARCHIVO (' || vsNombreArchivo || ') NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HISTORICOS DE CREDITO.';
							LET viContadorErrores_Pase_Credito = viContadorErrores_Pase_Credito + 1;
						
										
					ELIF ((vsSistema IN ('A')) AND (NOT EXISTS (SELECT Fecha FROM BdiCheq:"informix".sc_ContProc WHERE Proceso = 'pasomovshist' AND Fecha = (TODAY-1))) ) THEN --VALIDA ESTATUS DEL PASE DE MOVIMIENTOS HITORICOS DE CHEQUES
						
							LET vsCodRet = '00007'; --NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HITORICOS DE DEBITO
							LET vsMensaje_Respuesta = 'ARCHIVO (' || vsNombreArchivo || ') NO SE HA REALIZADO EL PASE DE MOVIMIENTOS HISTORICOS DE DEBITO.';
							LET viContadorErrores_Pase_Debito = viContadorErrores_Pase_Debito + 1;
					
					ELSE
					
						--ACTUALIZA LA HORA DE INICIO DE PROCESO DEL ARCHIVO
						UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_mc
							SET Fecha_Hora_Ini_Proceso = vdDiaHora,
								Fecha_Proceso = vdFechaDeHoy
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;
						
						
						IF (vsCarga <> 'V') THEN --VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE -- IF (2.1.1)
							
							--TRACE 'SI ENTRE :) 5';
										
								--CARGA EL ARCHIVO A LA TABLA DE PASO
								EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cargaarchivos_mc ( vsRep_Aix, vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, vsSistema, vsRep_Aix)
									INTO vsCodRet, vsMensaje_Respuesta, viTot_Registros, vmTot_Monto, viElemento;

								--ACTUALIZA LA HORA DE FIN DE LA CARGAR DE ARCHIVO A LA BD
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_mc
								SET Fecha_Hora_Carga_Archivo = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
								
								--TRACE 'SI ENTRE soy codREt :)'|| vsCodRet ;
								
						END IF; -- (2.1.1)
						
						--VALIDA SI EL ARCHIVO SE CARGO A LA TABLA DE PASO.
						IF (vsCodRet = '00000') THEN -- IF(2.1.2)
						
						--TRACE 'SI ENTRE :) 6';
						
							--VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							IF (vsCarga <> 'V') THEN -- IF(2.1.2.A)
								--TRACE 'SI ENTRE :) 8';
								--CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA Td_Movimientos_Conciliacion_mc
								EXECUTE PROCEDURE BdiTarjeta:"informix".sp_obtenerregistroarchivo_mc (vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, psCve_Usuario )
									INTO vsCodRet, vsMensaje_Respuesta, viElemento;
									--TRACE 'SI ENTRE :) 8.1';
								--ACTUALIZA LA HORA DE FIN DE LA CARGAR DE LA TABLA Td_Movimientos_Conciliacion_mc
								UPDATE BdiTarjeta:"informix".Td_Archivos_Conciliacion_mc
								SET Fecha_Hora_Carga_Tabla = vdDiaHora,
									Num_Registros325 = viTot_Registros, 
									Monto325 = vmTot_Monto,
									Carga = DECODE(vsCodRet, '00000', 'V', 'F')                                
								WHERE NombreArchivo = vsNombreArchivo 
									AND Archivo_Origen = vsArchivo_Origen 
									AND Fecha_Archivo = vdtFecha_Archivo;
									
							END IF; -- IF(2.1.2.A)
							
							IF (vsCodRet = '00000') THEN  -- IF(2.1.2.B)
							
								--TRACE 'SI ENTRE :) 9';
							
								UPDATE BdiTarjeta:"informix".Td_Archivos_Conciliacion_mc
								SET Fecha_Hora_Ini_Concilia_Reg = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
							
							
								LET vsFlagEnTransaccion = 'F';
								LET viContadorRegistros = 0;
								LET vsFlag_Ciclo_BusrcarReg = 'V'; --ARCTIVAR PARA BUSCAR UN REGISTRO.
								
								WHILE (vsFlag_Ciclo_BusrcarReg = 'V')  --CICLO DE BUSQUEDA DE REGISTROS PENDIENTES.
									--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
									
									--TRACE 'SI ENTRE :) 8.2';
									
									IF (vsFlagEnTransaccion = 'F') THEN
											BEGIN WORK;
											LET vsFlagEnTransaccion = 'V';
									END IF;

									LET vsFlag_Ciclo_BusrcarReg = 'F'; --PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
									LET vsFlagIntegridad = '';
									LET vsCodRet = '00000';
									LET vsTipoMov = '';
									LET vsAplicacion = '';
									LET vsBandera_Proceso = '';
									LET vsTransaccion_Aplica = '';
									LET vsMensaje_Respuesta = 'OBTENER REGISTROS A CONCILIAR.';
									

									
									--OBTIENE LOS REGISTROS PERTENECIENTES AL ARCHIVO ACTUAL
									--TRACE 'ANTES DEL SELECT estoy AQUIII';
									
									SELECT FIRST 1 'V' AS Ciclo_BusrcarReg, Consecutivo, NumTarjeta, TipoTransaccion325, Monto325, montocashback325, numcuenta,
										estransfer, Idcomercio325, 	Nomcomercio325, Referencia23_325, Secuencia325, Divisa325, Rfc325, NumCuenta, Monto_Divisa325,
										Conciliacion, Secuencia, Secuencia_Extendida, MontoIntercard, MontoCashback, FechaTransaccion, 
										InfReceptor, IdTerminal, MetodoCaptura, MovConciliado, MovReversado, Tipo_Mov, Folio_Mov, 
										FechaConcilia, Tipo_Conciliacion, Desc_Conciliacion, ISO323, MovRev325,
										Transaccion_Aplica, Bandera_Proceso, b_aplica,sec_extendida_archivo,archivo_origen,sec_extendida_archivo,id_procesador
										INTO vsFlag_Ciclo_BusrcarReg, viConsecutivo, vsNumTarjeta, vsTipoTransaccion325, vsMonto325,vsMontoCashBack325, vsCuenta,
										vsestransfer, vsIdcomercio325, vsNomcomercio325, vsReferencia23_325, vsSecuencia325, vsDivisa325, vsRfc325, vsNumCuenta, vsMonto_Divisa325, 
										vsConciliacion_Reg, vsSecuencia, vsSecuencia_Extendida, vmMontoIntercard, vmMontoCashBack, vsFechaTransaccion, 
										vsInfReceptor, vsIdTerminal, vsMetodoCaptura, vsMovConciliado, vsMovReversado, vsTipo_Mov, vsFolio_Mov, 
										vdFechaConcilia, viTipo_Conciliacion, vsDesc_Conciliacion, vsISO323, vsMovRev325,
										vsTransaccion_Aplica, vsBandera_Proceso, vsb_aplica,vssecuencia_ext_archivo,vsarchivo_origenMC,vssec_extendida_archivo,vsIdProcesador
										FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion_mc
										WHERE NombreArchivo = vsNombreArchivo
										AND Archivo_Origen = vsArchivo_Origen
									AND Finalizado = 'F';

									IF (vsFlag_Ciclo_BusrcarReg = 'V') THEN --VALIDA SI EXISTE REGISTRO PARA PROCESAR
									
										--TRACE 'SI ENTRE :) 10';
										
										IF (vsSistema = 'A') THEN --VALIDA EL TIPO DE SISTEMA "A" PARA ARCHIVOS QUE TIENEN REGISTROS DE CRED Y DEB MEZCLADOS --- (ATMO, TNC)
											SELECT FIRST 1 NVL(CreditoDebito,'') 
												INTO vsSistema_Registro
												FROM Intercard:"informix".Bines 
											WHERE Bin = SUBSTR(vsNumTarjeta, 1, 6); --OBTIENE EL BIN CORRESPONDIENTE DE LA TARJETA

											IF (NVL(vsSistema_Registro,'') = '') THEN --LA TARJETA NO CONTIENE BIN VALIDO
												LET vsSistema_Registro = '';
											END IF;
											
										END IF;

										LET vsMensaje_Respuesta = 'VALIDAR INTEGRIDAD DEL REGISTRO.';

										--VALIDA LA INTEGRIDAD DE LOS REGISTROS INDIVIDUALES 
										
										EXECUTE PROCEDURE BdiTarjeta:"informix".Sp_ValidaIntegridad_mc ( vsArchivo_Origen, viConsecutivo,
										vsNumTarjeta, vsTipotransaccion325, vsMonto325, vsMontoCashBack325, vsIdcomercio325, vsNomcomercio325,
										vsReferencia23_325, vsSecuencia325, vsDivisa325, vsRfc325, vsBinDebito, vsBinCredito, vsSistema)
										INTO vsCodRet, vsFlagIntegridad, vsMensaje_Respuesta, viElemento;

										--VALIDA SI AL REGISTRO LE CORRESPONDE CONCILIACION INTERCARD Y QUE LA INTEGRIDAD SEA CORRECTA
										IF ((vsConciliacion_Inter = 'V') AND (vsCodRet = '00000') AND (viTipo_Conciliacion = 0)) THEN
										
											--TRACE 'SI ENTRE :) 11';
											
											LET vsMensaje_Respuesta = 'CONCILIACION INTERCARD.';

											-- Se modifica llamado por integracion de operaciones con cash back (vsmontocashback325)
											EXECUTE PROCEDURE BdiTarjeta:"informix".sp_conciliaintercard_mc ( psCve_usuario, vsArchivo_Origen, vsConciliacion_Inter, vsConciliacion_Reg,
											viConsecutivo, vsNumtarjeta, vsSecuencia325, vsMonto325,vsMontoCashBack325, vsTipotransaccion325, vsFlagIntegridad, viTipo_LayOut, vsISO323,
											vsMovRev325, vsb_aplica,vssecuencia_ext_archivo,vsarchivo_origenMC,vsIdProcesador) --TFROZADAS
											INTO vsCodRet, vsConciliacion_Reg, vsSecuencia, vsSecuencia_Extendida,vscodgironeg, vmMontoIntercard, vmMontoCashBack, vsFechaTransaccion, 
											vsInfReceptor, vsIdTerminal, vsMetodoCaptura, vsMovConciliado, vsMovReversado, vsTipo_Mov, vsb_aplica, vsFolio_Mov, 
											vdFechaConcilia, viTipo_Conciliacion, vsDesc_Conciliacion, vsMensaje_Respuesta, viElemento, viActualizacion; -- Se modifica retorno TForzadas 
										
										END IF;
										
											--TRACE 'SI ENTRE :)vsCodRet '|| vsCodRet;

										--VALIDA SI AL REGISTRO LE CORRESPONDE CONCILIACION INTERCARD
										IF ( (vsConciliacion_Admin = 'V') AND (vsCodRet = '00000') ) THEN
											
											--TRACE 'ENTRE A vsConciliacion_Admin '|| vsConciliacion_Admin;
											
											LET vsMensaje_Respuesta = 'CONCILIACION ADMINISTRATIVA.';

											IF (TRIM(vsTransaccion_Aplica) = '') THEN --NO CONTIENE INFO
											--######################   TRANSACCIONES DE CORRESPONSALES      #####################
												--TRACE 'ENTRE A vsTransaccion_Aplica '|| vsTransaccion_Aplica;
												
												IF vsTipoTransaccion325  = 'FREC' and vsSistema = 'A'  and vsIdProcesador = 'OXXO' AND vsSistema_Registro='D' then 
													select valor into vsTransaccion_Aplica 
													from Bditarjeta:"informix".td_param_conciliacion_mc where codigo = '351';
													
												ELIF vsTipoTransaccion325  = 'FREC' and vsSistema = 'A'  and vsIdProcesador = 'OXXO' AND vsSistema_Registro='C' then 
													select valor into vsTransaccion_Aplica 
													from Bditarjeta:"informix".td_param_conciliacion_mc where codigo = '352';
													
												ELIF vsTipoTransaccion325  = 'FREC' and vsSistema = 'A'  and vsIdProcesador = 'SEVEN' AND vsSistema_Registro='D' then 
													select valor into vsTransaccion_Aplica 
													from Bditarjeta:"informix".td_param_conciliacion_mc where codigo = '353';
													
												ELIF vsTipoTransaccion325  = 'FREC' and vsSistema = 'A'  and vsIdProcesador = 'SEVEN' AND vsSistema_Registro='C' then 
													select valor into vsTransaccion_Aplica 
													from Bditarjeta:"informix".td_param_conciliacion_mc where codigo = '354';
												
												ELSE
													--OBTIENE LA TRANSACCION APLICA CORRESPONDIENTE PARA EL ARCHIVO
													LET vsTransaccion_Aplica = vsTransaccion_Abono; 
												END IF; --Cierre de IF por cada vsTipoTransaccion325

											END IF; ----Cierre TRIM(vsTransaccion_Aplica) = ''

									
											--EXECUTE PROCEDURE DE LA CONCILIACION ADMINISTRATIVA

											EXECUTE PROCEDURE BdiTarjeta:"informix".sp_concreing_conadmin_mc 
												( 
												vsSistema_Registro, 
												vdtFecha_Archivo, --FECHA DEL ARCHIVO PARA MANEJO CORRECTO DE EXTEMPORANEOS
												vsBandera_Proceso, 
												vsNumTarjeta, 
												vsFolio_Mov, --REQUIERE CONCILIACION INTERCARD
												vsArchivo_Origen, 
												vsNombreArchivo, 
												vsTipo_Mov, --REQUIERE CONCILIACION INTERCARD
												vsMonto325::MONEY, 
												vsSecuencia_Extendida, --REQUIERE CONCILIACION INTERCARD
												vsFechaTransaccion, --REQUIERE CONCILIACION INTERCARD
												vmMontoIntercard,  --REQUIERE CONCILIACION INTERCARD
												vsIdTerminal, --REQUIERE CONCILIACION INTERCARD
												vsTransaccion_Aplica, 
												vsNombreArchivo_Comi, 
												psCve_usuario,
												vsIdProcesador
												) 
											INTO vsCodRet, vsMensaje_Respuesta, viElemento;
											
										END IF; --(vsConciliacion_Admin = 'V') AND (vsCodRet = '00000')


										IF (vsCodRet <> '00000') THEN --VALIDA QUE TODOS LOS PROCESOS PARA EL REGISTRO SEAN CORRECTOS
											LET vsMensaje_Respuesta = 'ACTUALIZA EL ESTATUS DEL REGISTRO.';
											--NIVEL DE REGISTRO
											LET vsFlag_Error_Reg = 'V';
											--GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
											EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_mc (viElemento, '(' || vsCodRet || ') [' || vsNombreArchivo || ']' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;

										END IF;
										--ACTUALIZA EL ESTATUS DEL REGISTRO A PROCESADO COMPLETAMENTE
										UPDATE BdiTarjeta:"informix".Td_Movimientos_Conciliacion_mc
										SET Finalizado = DECODE(vsCodRet, '00000', 'V', 'E') --'V'=OK, 'E'=ERROR
										WHERE Consecutivo = viConsecutivo
										AND NombreArchivo = vsNombreArchivo
										AND Archivo_Origen = vsArchivo_Origen
										AND Finalizado = 'F';


									END IF; --Cierre de IF (vsFlag_Ciclo_BusrcarReg = 'V') THEN --VALIDA SI EXISTE REGISTRO PARA PROCESAR
									
									LET viContadorRegistros = viContadorRegistros + 1;

									--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
									IF (viContadorRegistros = 100) THEN --VERIFICA SI ALCANZO EL MAXIMO DE TRANSACCIONES POR BLOQUE
										COMMIT WORK;
										LET vsFlagEnTransaccion = 'F';
										LET viContadorRegistros = 0;
									END IF;
										
								END WHILE; -- END REGISTRO 
							
							
							
							
							
								--Bloque utilizado para confirmar los cambios y cerrar la transaccion.
								IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN							
									COMMIT WORK;
									LET vsFlagEnTransaccion = 'F';
								END IF;
							
							END IF -- IF(2.1.2.B)
							
						END IF;						
					END IF; -- IF(2.1)
					
						UPDATE BdiTarjeta:"informix".Td_Archivos_Conciliacion_mc
						SET Fecha_Hora_Fin_Proceso = vdDiaHora,
						Proceso = (CASE 
										WHEN vsCodRet IN ('00006', '00007') THEN 'X'  --PENDIENTE PARA EL PROX CRON ()
										WHEN (vsCodRet = '00000' ) THEN 'T'  --TRABAJADO
									ELSE 'E' END) --ERROR DE CARGA 1-2
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;
					
				END IF; -- IF(2)
				
				DROP TABLE IF EXISTS tb_config_archivo_extenporaneo;
				DROP TABLE IF EXISTS tb_config_archivo_normal;
				
				IF (vsCodRet <> '00000') THEN
					-- NIVEL DE ARCHIVO
					--GUARDA EN BITACORA REGISTRO DEL ERROR EN CASO DE QUE EXISTA
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_mc (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
					LET viContadorErroresCon = viContadorErroresCon + 1;
				END IF;
				
				IF ( EXISTS (SELECT Descripcion FROM BdiTarjeta:"informix".Td_Param_Conciliacion_ConcReing 
					WHERE Codigo = '002' AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION' AND TRIM(Valor) = 'V') ) THEN --VALIDA QUE SI EXISTE UNA ORDEN DE DETENER LA CONCILIACION (CONCREIN)
					LET vsMensaje_Respuesta = 'PARO DE EMERGENCIA DE CONCILIACIÃN.';

					--LIBERA LA BANDERA DE PARO DE EMERGENCIA DE CONCILIACION
					UPDATE BdiTarjeta:"informix".Td_Param_Conciliacion_ConcReing
						SET Valor = 'F', Fecha_Modificacion = vdDiaHora
					WHERE Codigo = '002' 
						AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION'
						AND TRIM(Valor) = 'V';
						
					LET vsFlag_ArchPendiente = 'F'; 
					LET vsFlag_Ciclo_BusrcarArch = 'F'; --TERMINA EL CICLO 
					LET vsCodRet = '00010'; --CONCILIACION DETENIDA --CONCREIN
					LET vsMensaje_Respuesta = 'CONCILIACIÃN DETENIDA POR EL USUARIO.';
					
				END IF;
				
			END WHILE;
			
					--VALIDA SI ESXISTEN ARCHIVOS CON ESTATUS 'X'
			IF (EXISTS (SELECT NombreArchivo FROM BdiTarjeta:"informix".Td_Archivos_Conciliacion_mc WHERE Proceso = 'X')) THEN

				--MARCA DISPONIBLES LOS REGISTROS QUE NO SE PROCESARON POR PASES DE CRED O DEB
				UPDATE BdiTarjeta:"informix".Td_Archivos_Conciliacion
				SET Fecha_Hora_Fin_Proceso = vdDiaHora,
				Proceso = 'P'
				WHERE Proceso = 'X'; 
				
			END IF;
			
			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".Td_Param_Conciliacion_mc 
				SET Valor = 'F', 
				Fecha_Modificacion = vdDiaHora
			WHERE Codigo = '001' 
				AND Descripcion = 'CONCILIACION MC EN EJECUCION' 
				AND TRIM(Valor) = 'V';
			
			
		END IF -- IF PRINCIPAL 
		
		IF (vsCodRet <> '00000') THEN
			--NIVEL DE PROCESO
			--GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_mc (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
			ELSE
			LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA.' 
			|| DECODE ((viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)), 0, '', ' -- SE PRESENTARON [' || (viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)) || '] ERRORES DE PROCESO DE ARCHIVO.' )
			|| DECODE (viContadorErrores_Pase_Credito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Credito || '] ARCHIVOS POR LA FALTA DEL PASE DE CRÃDITO.' )
			|| DECODE (viContadorErrores_Pase_Debito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Debito || '] ARCHIVOS POR LA FALTA DEL PASE DE DÃBITO.' );

		END IF;
		
		RETURN vsCodRet, vsMensaje_Respuesta;
	END
	
END PROCEDURE
DOCUMENT
'*****AUTOR: Victoria QuiÃ±ones',
'Proyecto: Conciliacion MasterCard-Oxxo',
'Solicito: Jose Luis Puebla',
'Descripcion: PROCESO DE CONCILIACION AUTOMATICO.',
'Fecha: 2018/06/01',
'Version: 20180601.1300',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_conciliaintercard_mc(
	psCve_usuario 				CHAR (10), 	--USUARIO DEL SISTEMA
	psArchivo_origen 			CHAR (3), 	--TD_ARCHIVO_ORIGEN
	psConciliacionArchivo		CHAR (1),	--TD_ARCHIVO_ORIGEN
	psConciliacion 				CHAR(1),   	-- bditarjeta:td_movimientos_conciliacion_mc
	psConsecutivo 				INTEGER, 	--td_movimientos_conciliacion_mc	CONSECUTIVO
	psNumtarjeta 				CHAR (16), 	--td_movimientos_conciliacion_mc   NUMTARJETA
	psSecuencia325 				CHAR(6),  	--td_movimientos_conciliacion_mc	
	psMonto325 					CHAR(13),	--td_movimientos_conciliacion_mc    Monto de Operacion 
	psMontoCashBack325 			CHAR(13),    --td_movimientos_conciliacion_mc    Monto de Cash Back
	psTipotransaccion325 		CHAR(15),
	psIntegridad 				CHAR(1),    --PARAMETRO INICIAL
	piTipo_LayOut 				INTEGER,	 --BdiTarjeta:Td_Archivo_OrigenTmp ---
	psISO323 					CHAR(2),	--BdiTarjeta:td_movimientos_conciliacion_mc
	psMovRev325 				CHAR(1)	,	--BdiTarjeta:td_movimientos_conciliacion_mc
	psb_aplica 					CHAR(1),	--TForzadas de BdiTarjeta:td_movimientos_conciliacion_mc
	psvssecuencia_ext_archivo 	CHAR(15),	--BdiTarjeta:td_movimientos_conciliacion_mc
	psvsarchivo_origenMC 		CHAR(03),	--BdiTarjeta:td_movimientos_conciliacion_mc
	psIdProcesador 				CHAR(05)	--BdiTarjeta:td_movimientos_conciliacion_mc
)

	RETURNING   CHAR(5) AS Retorno,
				CHAR(1) AS Conciliacion ,
				CHAR(7) AS Secuencia,
				CHAR(15) AS Secuencia_extendida,
				CHAR(4) AS CodGiroNeg, --TFORZADAS
				MONEY AS Montointercard,
				MONEY AS Montointercardcashback,
				DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
				CHAR(40) AS Infreceptor,
				CHAR(16) AS Idterminal,
				CHAR(2) AS Metodocaptura,
				CHAR(1) AS Movconciliado,
				CHAR(1) AS Movreversado,
				CHAR(1) AS Tipo_mov,
				CHAR(1) AS b_aplica, --TFORZADAS
				CHAR(16) AS Folio_mov,
				DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
				INTEGER AS Tipo_conciliacion,
				CHAR(60) AS Desc_conciliacion,
				CHAR(250) AS ErrorActividad,
				INTEGER AS Elemento,
				INTEGER AS Actualizacion;

/*
*****************************************************************************************************
-- DESCRIPCION:  CONCILIACION INTERCARD  ------------------------------------------------------------
-- AUTOR : Victoria Quiñones  -----------------------------------------------------------------------
-- FECHA : 11/06/2018  ------------------------------------------------------------------------------
-- BD: bditarjeta  ----------------------------------------------------------------------------------
-- SISTEMA :Conciliacion automatica MasterCard - Oxxo  -----------------
*****************************************************************************************************
*//*DEFINICION DE VARIABLES*/
/*VARIABLES DE RETORNO*/
DEFINE viCodigo INTEGER;
DEFINE vssqlerr CHAR(5) ;
define vsretvm char(5);

DEFINE vsErrorActividad CHAR (250) ;
DEFINE viElemento INTEGER;
DEFINE viActualizacion INTEGER;

/*VARIABLES QUE CONTIENEN AL MOVIMIENTO DE INTERCARD*/
DEFINE vsRetorno CHAR(5);
DEFINE viRetorno INTEGER;
DEFINE vsSecuenciaorig CHAR(7);
DEFINE vsSecuencia_extendida CHAR(15);
DEFINE vmMontointercard MONEY;
DEFINE vmMontointercardCashback MONEY; --Integracion de CashBack
DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
DEFINE vsInfreceptor CHAR(40);
DEFINE vsIdterminal CHAR(16);
DEFINE vsMetodocaptura CHAR(2);
DEFINE vsMovconciliado CHAR(1);
DEFINE vsMovreversado CHAR(1);
DEFINE vsCodigoiso CHAR(2);

DEFINE vmSumaMonto325 MONEY;
DEFINE vmMonto325 MONEY;
-- Varibles para manejo de Cashback fraccionado
DEFINE vmSumaMontoCashback325 MONEY;
DEFINE VMMontoCashback325 MONEY; 

DEFINE vsConciliacion CHAR(1);
DEFINE vsSecuencia CHAR(7);

DEFINE vsTipo_mov CHAR(1);
DEFINE vsFolio_mov CHAR(16);
DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION(5);
DEFINE viTipo_conciliacion INTEGER;
DEFINE vsDesc_conciliacion CHAR(60);

/*VARIABLES DE RETORNO DE sp_cidentifica_tipoconciliacion*/
DEFINE vsRetornor CHAR(5);
DEFINE vsConciliacionr CHAR(1);
DEFINE vsSecuencia_extendidar CHAR(16);
DEFINE vsMonto325 CHAR(13);
DEFINE vsMontoCashBack325 CHAR(13); --- Monto CashBack
DEFINE vmMontointercardr MONEY;
DEFINE vmMontointercardCashbackr MONEY; -- Integracion de CashBack
DEFINE vdFechatransaccionr DATETIME YEAR TO FRACTION(5);
DEFINE vsInfreceptorr CHAR(40);
DEFINE vsIdterminalr CHAR(16);
DEFINE vsMetodocapturar CHAR(2);
DEFINE vsMovconciliador CHAR(1);
DEFINE vsMovreversador CHAR(1);
DEFINE vsFormato VARCHAR(4);

DEFINE vsNumCuenta CHAR(20);

DEFINE vsCodReversa CHAR(1); 	--Intercard:Movimiento
DEFINE vsCodigoCentral CHAR(5);	--Intercard:Movimiento

/* Proceso de actualizacion de montos en Bditarjeta:td_movimientos_conciliación*/
DEFINE vmregistromontototal 	money;
DEFINE vmmontocompra 			money;
DEFINE vmmontocashback 			money;
DEFINE vsRegistroComprareal		char(13);
DEFINE vsRegistroCashreal		char(13);
DEFINE viconcaracteres1			integer;
DEFINE viconcaracteres2			integer;
DEFINE a						integer;
DEFINE b						integer;

--  Para la bandera de aplicacion TFORZADAS
DEFINE vsb_aplica 			char(1); -- TFORZADAS
DEFINE vscodgironeg 		char(4); -- TFORZADAS
DEFINE vfporcentaje			float;
DEFINE vsvalor      		char(10);
DEFINE vmmontototal 		money;
DEFINE vmmontoporcentaje 	money;
DEFINE vmmontototalmaximo 	money;

/* folio regulatorio */

DEFINE vsfolio_reg      		CHAR(16);


--SET DEBUG FILE TO '/informix/LVRQ/CNC_MC_OXXO/NvoDev/dev/TraceCONCILIAINTERCARD.txt';
--TRACE ON;

/*INICIALIZACION DE VARIABLES*/

LET viCodigo = 0;
LET vssqlerr = '00000';
let vsretvm = '';

LET vsErrorActividad = '';
LET viElemento = 4;
LET viActualizacion = 0;

LET vsConciliacion = psConciliacion;

/*VARIABLES QUE CONTIENEN AL MOVIMIENTO DE INTERCARD*/
LET vsRetorno = '00000';
LET viRetorno = 0;
LET vsSecuenciaorig = '';
LET vsSecuencia_extendida = '';

LET vmMontointercard = 0;
LET vmMontointercardCashback = 0;
LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsInfreceptor = '';
LET vsIdterminal = '';
LET vsMetodocaptura = '';
LET vsMovconciliado = '';
LET vsMovreversado = '';
LET vsCodigoiso = '';

 
LET vmSumaMonto325 = 0;
LET vmSumaMontoCashback325 = 0; -- Para suma de CashBack


LET vsSecuencia = '';
LET vsTipo_mov = '';
LET vsFolio_mov = '';
LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET viTipo_conciliacion = 0;
LET vsDesc_conciliacion = '';

/*VARIABLES DE RETORNO DE sp_cidentifica_tipoconciliacion*/
LET vsRetornor = '00000';
LET vsConciliacionr = psConciliacion;
LET vsSecuencia_extendidar = '';
LET vmMontointercardr = 0;
LET vmMontointercardCashbackr = 0;
LET vdFechatransaccionr = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsInfreceptorr = '';
LET vsIdterminalr = '';
LET vsMetodocapturar = '';
LET vsMovconciliador = '';
LET vsMovreversador = '';
LET vsFormato = '';

LET vsNumCuenta  = '';

LET vsCodReversa = '';
LET vsCodigoCentral = '';

-- Proceso de Forzadas
LET vsb_aplica 			= '';
LET vscodgironeg 		= '';
LET vfporcentaje		= 0.0;
LET vsvalor      		= '';
LET vmmontototal 		= 0;
LET vmmontoporcentaje 	= 0;
LET vmmontototalmaximo 	= 0;


/* Proceso de actualizacion de montos en Bditarjeta:td_movimientos_conciliación*/
LET vmregistromontototal = 0;
LET vmmontocompra  = 0;
LET vmmontocashback = 0;
LET vsRegistroComprareal = '';
LET vsRegistroCashreal = '';
LET viconcaracteres1 = 0;
LET viconcaracteres2 = 0;
LET a = 0;
LET b = 0;

--LET vmMonto325 = 0;
LET vmMonto325 = ( ( REPLACE( psMonto325,'.',''))::MONEY /100 );
LET vsMonto325 = CAST(vmMonto325 AS CHAR(13));
LET vmSumaMonto325 = 0;

LET vmMontoCashback325 = ((REPLACE( psMontoCashBack325,'.',''))::MONEY /100 ); 
LET vsMontoCashback325 = CAST(vmMontoCashback325 AS CHAR(13));
LET vmSumaMontoCashback325 = 0; -- Para suma de CashBack


/* folio regulatorio */

LET vsfolio_reg = '';

	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

			LET vssqlerr = viCodigo;
			RETURN	vssqlerr,
				NVL(vsConciliacion,''),
				NVL(vsSecuencia,''),
				NVL(vsSecuencia_extendida,''),
				NVL(vsCodgironeg,''), -- TFORZADAS
				NVL(vmMontointercard,0),
				NVL(vmMontointercardCashback,0),
				NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
				NVL(vsInfreceptor,''),
				NVL(vsIdterminal,''),
				NVL(vsMetodocaptura,''),
				NVL(vsMovconciliado,''),
				NVL(vsMovreversado,''),
				NVL(vsTipo_mov,''),
				NVL(vsb_aplica,''), --TFORZADAS
				NVL(vsFolio_mov,''),
				NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
				NVL(viTipo_conciliacion,0),
				NVL(vsDesc_conciliacion,''),
				NVL(vsErrorActividad,''),
				NVL(viElemento,4),
				NVL(viActualizacion,0);
			
		END EXCEPTION;


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		/*SE VERIFICA LA INTEGRIDAD DEL REGISTRO*/
		
		let vsb_aplica = psb_aplica;
		IF ( psIntegridad = 'V') THEN
			/*CONTINUA FASE 2*/

			/*LECTURA DEL MOVIMIENTO ORIGINAL EN INTERCARD*/
			EXECUTE PROCEDURE bditarjeta:"informix".sp_buscar_mov_intercard_mc  -- Se Modidica retorno para baplica 
			( psCve_usuario, psNumtarjeta , psSecuencia325, psMonto325, psMontoCashBack325,psvssecuencia_ext_archivo,psvsarchivo_origenMC,psIdProcesador) -- Se agrega psmonto325 para validar montos
				INTO vsRetorno, vsSecuenciaorig, vsSecuencia_extendida, vmMontointercard, vmMontointercardCashback, vdFechatransaccion,
				vsInfreceptor, vsIdterminal, vsMetodocaptura, vsMovconciliado, vsMovreversado, vsCodigoiso, vsFormato, vsErrorActividad,
			vsCodReversa, vsCodigoCentral, vscodgironeg,vsfolio_reg; --TFORZADAS
			
			--LET vsErrorActividad = 'CONSULTA MOVIMIENTO INTERCARD' ;


			LET viRetorno = CAST( vsRetorno AS INTEGER);

			IF( viRetorno >= 0  ) THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_identifica_tipo_conciliacion_mc
				(
					vsRetorno,					--intercard:movimiento
					psConsecutivo,  			--bditarjeta:td_movimientos_conciliacion_mc
					psNumtarjeta,				--bditarjeta:td_movimientos_conciliacion_mc
					psSecuencia325,				--bditarjeta:td_movimientos_conciliacion_mc
					vsMovconciliado,			--intercard:movimiento
					vmMontointercard,			--intercard:movimiento resultado de busca movimiento intercard
					vmMontointercardCashback, 	-- Intercard:movimiento resultado de busca movimiento intercard
					psMonto325,					--bditarjeta:td_movimientos_conciliacion_mc
					vsMontoCashback325,         --bditarjeta:td_movimientos_conciliacion_mc
					--psSumaMonto325,			--bditarjeta:td_movimientos_conciliacion_mc  Suma de monto325
					vmSumaMonto325,				--bditarjeta:td_movimientos_conciliacion_mc  Suma de monto325
					vmSumaMontoCashback325,		--bditarjeta:td_movimientos_conciliacion_mc  Suma de montocashback325
					psTipotransaccion325,  --bditarjeta:td_movimientos_conciliacion_mc
					psConciliacionArchivo,	--bditarjeta:td_archivo_origen

					psConciliacion,   		-- bditarjeta:td_movimientos_conciliacion_mc
					vsSecuenciaorig,		--intercard:movimiento
					vsSecuencia_extendida,	--intercard:movimiento
					vdFechatransaccion, 	--intercard:movimiento
					vsInfreceptor,			--intercard:movimiento
					vsIdterminal,			--intercard:movimiento
					vsMetodocaptura,		--intercard:movimiento
					vsMovreversado,			--intercard:movimiento
					vsCodigoiso,			--intercard:movimiento
					vsFormato,				--intercard:movimiento
					
					piTipo_LayOut,			--BdiTarjeta:Td_Archivo_OrigenTmp ---
					psISO323,				--BdiTarjeta:td_movimientos_conciliacion_mc
					psMovRev325,			--BdiTarjeta:td_movimientos_conciliacion_mc
					vsCodReversa, 			--Intercard:Movimiento
					vsCodigoCentral,		--Intercard:Movimiento
					vsfolio_reg				--se genera folio regulatorio
				)
				INTO
					vsRetornor,              	-- Valor de retorno
					vsConciliacion,
					vsSecuencia,				-- Secuencia de trasaccion
					vsSecuencia_extendidar,  	-- Extendida de la transaccion
					vmMontointercardr,       	--
					vmMontointercardCashbackr,
					vdFechatransaccionr,     --
					vsInfreceptorr,          --
					vsIdterminalr,           --
					vsMetodocapturar,        --
					vsMovconciliador,        --
					vsMovreversador,         --
					vsTipo_mov,
					vsFolio_mov,
					vdFechaconcilia,
					viTipo_conciliacion,
					vsDesc_conciliacion,
					vsErrorActividad;

				LET vssqlerr = vsRetornor;
				LET viRetorno = CAST( vsRetornor AS INTEGER );

				IF ( viRetorno < 0  ) THEN
					LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_concreing_identificatipoconciliacion' ;
				ELIF ( viRetorno >= 0  ) THEN
					
					LET vsSecuencia_extendida = vsSecuencia_extendidar;
					LET vmMontointercard = vmMontointercardr;
					LET vmMontointercardCashback = vmMontointercardCashbackr;
					LET vdFechatransaccion = vdFechatransaccionr;
					LET vsInfreceptor = vsInfreceptorr;
					LET vsIdterminal = vsIdterminalr;
					LET vsMetodocaptura = vsMetodocapturar;
					LET vsMovconciliado = vsMovconciliador;
					LET vsMovreversado = vsMovconciliador;
					
				END IF;
				 
				 
				 LET vsb_aplica = vsb_aplica;

				UPDATE BdiTarjeta:"informix".td_movimientos_conciliacion_mc
					SET codgironeg = vscodgironeg,
						b_aplica = vsb_aplica
					WHERE 	NumTarjeta = psNumtarjeta 
					AND Secuencia325 = psSecuencia325 
				AND Consecutivo = psConsecutivo;
				
				--   PROCESO NUEVO PARA IDENTIFICACION  -- agregar variables utilizadas proceso nuevo 
				
			ELSE

				LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' OCURRIO UN ERROR NO CONTROLADO AL EJECUTAR sp_buscar_mov_intercard_mc';

			END IF;

		ELIF ( psIntegridad IN ('F','P')) THEN
			/*CONCLUYE LA ETAPA DE CONCILIACION DEL REGISTRO*/

			/*SE DEBE MANTENER P EN CONCILIACION */
			LET vsConciliacion = 'P';
			
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion_mc
			SET conciliacion = 'P'
			WHERE numtarjeta = psNumtarjeta AND secuencia325 = psSecuencia325 AND consecutivo = psConsecutivo;

			LET vssqlerr = '00402';

			LET vsErrorActividad = 'CONSECUTIVO ' || psConsecutivo || ' EL REGISTRO NO PRESENTA INTEGRIDAD CORRECTA';

		END IF;

		/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
		RETURN	vssqlerr,
		NVL(vsConciliacion,''),
		NVL(vsSecuencia,''),
		NVL(vsSecuencia_extendida,''),
		NVL(vsCodgironeg,''), -- TFORZADAS
		NVL(vmMontointercard,0),
		NVL(vmMontointercardCashback,0),
		NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
		NVL(vsInfreceptor,''),
		NVL(vsIdterminal,''),
		NVL(vsMetodocaptura,''),
		NVL(vsMovconciliado,''),
		NVL(vsMovreversado,''),
		NVL(vsTipo_mov,''),
		NVL(vsb_aplica,''), --TFORZADAS
		NVL(vsFolio_mov,''),
		NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
		NVL(viTipo_conciliacion,0),
		NVL(vsDesc_conciliacion,''),
		NVL(vsErrorActividad,''),
		NVL(viElemento,4),
		NVL(viActualizacion,1);
		


	END;
END PROCEDURE;