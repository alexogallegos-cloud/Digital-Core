CREATE PROCEDURE "informix".sp_conciliacionautomatica_atm_stat06_pagos(psCve_Usuario VARCHAR(10) , piHorario INTEGER)
RETURNING VARCHAR (5) AS CodRet, VARCHAR (150) AS Mensaje_Respuesta ;

	/*  DEFINICION DE VARIABLES */ 
	
	-- CONTROL GENERAL
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
		
	-- DATOS ARCHIVO_CONCILIACION	
    DEFINE viTot_Registros 				INTEGER;
    DEFINE vmTot_Monto 					MONEY;
    DEFINE viNum_Cargo 					INTEGER;
    DEFINE vmMonto_Cargo 				MONEY;
    DEFINE viNum_Abono 					INTEGER;
    DEFINE vmMonto_Abono 				MONEY;
	
	-- CONTROL DE TRANSACCIONALIDAD	
	DEFINE viContadorRegistros 			INTEGER;
	DEFINE vsFlagEnTransaccion 			VARCHAR (1);
		
	-- DATOS MOVIMIENTOS_CONCILIACION	
    DEFINE vsNombreArchivo 				VARCHAR (30);
    DEFINE vsArchivo_Origen 			VARCHAR (3);
    DEFINE vdtFecha_Archivo 			DATE;
    DEFINE vsCarga 						VARCHAR (3);
    DEFINE vsConadmin 					VARCHAR (3);
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
	DEFINE vsAplicacion 				VARCHAR(1);
    DEFINE vsBandera_Proceso 			VARCHAR(1);
    DEFINE vsTransaccion_Aplica 		VARCHAR(4);
    DEFINE vsSistema_Registro 			VARCHAR(1);
    DEFINE vscodgironeg 				CHAR (4); -- TFORZADAS
    DEFINE vsb_aplica 					CHAR(1); -- TFORZADAS
	
	-- DATOS MOVIMIENTOS_CONCILIACION
    DEFINE viConsecutivo 			INTEGER;
    DEFINE vsNumTarjeta 			VARCHAR (16);
    DEFINE vsTipoTransaccion325 	VARCHAR (15);
    DEFINE vsMonto325 				VARCHAR (13);
    DEFINE vsMontoCashBack325 		VARCHAR (13);
    DEFINE vsCuenta 				VARCHAR(20); -- Integracion de transfer
    define vsestransfer 			VARCHAR(1);
    DEFINE vsFechaopetransfer 		CHAR(6);
    DEFINE vsIdcomercio325 			VARCHAR (15);
    DEFINE vsNomcomercio325 		VARCHAR (30);
    DEFINE vsReferencia23_325 		VARCHAR (23);
    DEFINE vsSecuencia325 			VARCHAR (6);
    DEFINE vsDivisa325 				VARCHAR (3);
    DEFINE vsRfc325 				VARCHAR (15);
    DEFINE vsSecuencia 				VARCHAR(7);
    DEFINE vsSecuencia_Extendida 	VARCHAR(15);
    DEFINE vmMontoIntercard 		MONEY;
    DEFINE vmMontoCashBack 			MONEY;
    DEFINE vsFechaTransaccion 		DATETIME YEAR TO FRACTION (5);
    DEFINE vsInfReceptor 			VARCHAR(40);
    DEFINE vsIdTerminal 			VARCHAR(16);
    DEFINE vsMetodoCaptura 			VARCHAR(2);
    DEFINE vsMovConciliado 			VARCHAR(1);
    DEFINE vsMovReversado 			VARCHAR(1);
    DEFINE vsTipo_Mov 				VARCHAR(1);
    DEFINE vsFolio_Mov 				VARCHAR(16);
    DEFINE vdFechaConcilia 			DATETIME YEAR TO FRACTION (5);
    DEFINE viTipo_Conciliacion 		INTEGER;
    DEFINE vsDesc_Conciliacion 		VARCHAR(60);
    DEFINE vsConciliacion_Reg 		VARCHAR(1);
    DEFINE vsNumCuenta 				VARCHAR(20);
    DEFINE vsMonto_Divisa325 		VARCHAR(13);
    DEFINE vsISO323					CHAR(2);
    DEFINE vsMovRev325 				CHAR(1);
    DEFINE vsTipoMov 				VARCHAR(1);
	
	
	DEFINE vsBinDebito 				VARCHAR(6);
	DEFINE vsBinCredito 			VARCHAR(6);
	DEFINE viActualizacion 			INTEGER;
	DEFINE vsTransaccionMoneyGram 	VARCHAR (4);
	DEFINE vsTransaccionCashBack 	VARCHAR (16);
	DEFINE vsConciliacionAdminAtm 	CHAR(1);
	DEFINE vsNombreArchivo_Comi 	VARCHAR(23);
	DEFINE viContadorErroresCon 	INTEGER;
	
	/* Secuencia extendida generada desde la carga */
	
	DEFINE vssecuencia_ext_archivo CHAR(15);
	DEFINE vsarchivo_origenMC 	   CHAR(03);
	DEFINE vDescripcionConcMC 	   VARCHAR(50);
    DEFINE vArchivoOrigenBol	   CHAR (3);
	
	/* Variables para total de resgistros Cargados */
	
	DEFINE vsTotaltxn 	   INTEGER;
	DEFINE vsTotalMonto    MONEY;
   
    
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
    LET vsConadmin = '';
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
    LET vscodgironeg = ''; -- TFORZADAS
    LET vsb_aplica = ''; -- TFORZADAS
	
    -- CONTROL DE TRANSACCIONALIDAD
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
	
	
	/* Variables para total de resgistros Cargados */
	LET vsTotaltxn = 0;
	LET vsTotalMonto = 0.0;
   
	BEGIN
	
		ON EXCEPTION SET viSQLerr
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			
			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			
			UPDATE bditarjeta:td_param_conciliacion_atm_06_pagos 
			SET Valor = 'F',
				Fecha_Modificacion = vdFechaDeHoy
			WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION ATM PAGOS EN EJECUCION' 
			AND Valor = 'V';
			
			LET viElemento = 0;	
			LET vsCodRet = '00020';
			LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta);
			
			EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_atm_stat06_pagos (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario)
			INTO vsCodRet2;
			
			RETURN vsCodRet, vsMensaje_Respuesta;
			
		END EXCEPTION;	
		
		ON EXCEPTION IN (-535) -- EN CASO DE TRANSACCION ABIERTA Y TRATAR DE ABRIR OTRA
			COMMIT WORK; -- TERMINA LA TRANSACCION ACTUAL Y CONTINUA
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/e10000656/TRACE_CONCILIACION.sql";
		--TRACE ON;

		-- OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
		SELECT LIMIT 1 Fecha_Hoy 
		INTO dtFecha_Hoy_Integral 
		FROM bdinteg:Si_Fechas WHERE empresa = '001';
		
        LET vDescripcionConcMC = 
		(
			SELECT Descripcion 
			---pendiente
			FROM bditarjeta:td_param_conciliacion_atm_06_pagos 
            WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION ATM PAGOS EN EJECUCION' 
			AND TRIM(Valor) = 'V'
		);
                       
        LET vArchivoOrigenBol =  
		(
			SELECT Archivo_Origen 
            FROM bditarjeta:"informix".td_archivo_origen_atm_stat06 
            where archivo_origen = 'COB'
            AND (Horario_Ejecucion_Hoy = piHorario OR Horario_Ejecucion_Ext = piHorario)

		
		);
                    
		-- IF PRINCIPAL
		IF ( vDescripcionConcMC <> '' OR vDescripcionConcMC IS NOT NULL ) THEN 
			-- VALIDA QUE NO EXISTA UNA CONCILIACION EN EJECUCION (CONCREING)
			
		
			
			LET vsCodRet = '00001'; -- CONCILIACION EN EJECUCION --CONCREIN
			LET vsMensaje_Respuesta = 'CONCILIACION EN EJECUCION (CONCREIN).';
			
		ELIF ( dtFecha_Hoy_Integral < vdFechaDeHoy ) THEN 
			-- VALIDA QUE EL SISTEMA DE INTEGRA ESTE A CORDE A LA DEL SERVIDOR
			
			LET vsCodRet = '00003'; -- FECHAS INTEGRAR-SERVIDOR DESFASADAS 
			LET vsMensaje_Respuesta = 'FECHAS INTEGRAL-SERVIDOR DESFASADAS.';
				
		ELIF ( vArchivoOrigenBol = '' OR vArchivoOrigenBol IS NULL ) THEN 
			-- VALIDA QUE EL JOB/EJECUCION ESTE CONTEMPLADA PARA ALGUNO DE LOS ARCHIVOS
			
			LET vsCodRet = '00005'; --JOB NO CONTEMPLADO EN NINGUN ARCHIVO
			LET vsMensaje_Respuesta = 'JOB NO CONTEMPLADO EN NINGUN ARCHIVO.';
					
		ELSE --OK
		
			
			LET vsMensaje_Respuesta = 'MARCAR CONCILIACION EN EJECUCION.';
			
			-- MARCA LA BANDERA DE CONCILIACION EN EJECUCION
			
			UPDATE bditarjeta:td_param_conciliacion_atm_06_pagos
			SET Valor = 'V',  
				Fecha_Modificacion = vdFechaDeHoy
			WHERE Codigo = '001'
			AND Descripcion = 'CONCILIACION ATM PAGOS EN EJECUCION'
			AND TRIM(Valor) = 'F';

			LET vsFlag_Ciclo_BusrcarArch = 'V'; -- ACTIVAR PARA BUSCAR UN ARCHIVO.
			
			
			WHILE ( vsFlag_Ciclo_BusrcarArch = 'V' )  -- CICLO DE BUSQUEDA DE ARCHIVOS PENDIENTES.
				
			
				
				-- PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
				
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
					ArchCon.Fecha_Archivo, ArchCon.Carga,ArchCon.conadmin,ArchOri.Prefijo_Archivo,ArchOri.Sistema, ArchOri.Conciliacion_Inter,
					ArchOri.Conciliacion_SIF, ArchOri.Conciliacion_Admin,ArchOri.Borra_Archivo_Fisico,
					ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada,ArchOri.Transaccion_Abono,
					ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
				FROM bditarjeta:td_archivos_conciliacion_atm_stat06_pagos AS ArchCon 
				LEFT JOIN bditarjeta:td_archivo_origen_atm_stat06 AS ArchOri 
				ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
				WHERE 	ArchCon.Proceso = 'P'
				AND ArchCon.Fecha_Archivo = (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE 
				AND Horario_Ejecucion_Hoy <= piHorario
				ORDER BY Horario_Ejecucion_Hoy, orden_proceso ASC
				INTO temp tb_config_archivo_normal WITH NO LOG ;
				
				-- SE OBTIENE DATOS PARA ARCHIVO NORMAL
				
				SELECT FIRST 1
					Flag_ArchPendiente, NombreArchivo, Archivo_Origen, Fecha_Archivo,Carga, conadmin,
					Prefijo_Archivo, Sistema, Conciliacion_Inter, Conciliacion_SIF, Conciliacion_Admin,
					Borra_Archivo_Fisico, Transaccion_Compra, Transaccion_Liberacion, Transaccion_Forzada, 
					Transaccion_Abono, Rep_Aix, Rep_Win, Archivo_Companero, Archivo_Report_Comisiones, Tipo_LayOut
				INTO 
					vsFlag_ArchPendiente, vsNombreArchivo, vsArchivo_Origen, vdtFecha_Archivo, vsCarga,vsConadmin, 
					vsPrefijo_Archivo, vsSistema, vsConciliacion_Inter, vsConciliacion_SIF, vsConciliacion_Admin,
					viBorra_Archivo_Fisico, vsTransaccion_Compra, vsTransaccion_Liberacion, vsTransaccion_Forzada, 
					vsTransaccion_Abono, vsRep_Aix, vsRep_Win, vsArchivo_Companero, vsArchivo_Report_Comisiones, viTipo_LayOut
				FROM tb_config_archivo_normal ;
				
				
				-- ARCHIVOS EXTEMPORANEOS 
				
				IF (NVL(vsFlag_ArchPendiente, 'F') <> 'V') THEN 
					-- NO ENCONTRO MOVIMIENTO NORMAL IF(1)
				
					-- BUSCA EXTEMPORANEO

					-- TRACE 'SI ENTRE :) 3';
					LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS A CONCILIAR EXTEMPORANEO.';
					
					SELECT Horario_Ejecucion_Ext, orden_proceso, 'V' AS Flag_ArchPendiente, ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
						ArchCon.Fecha_Archivo, ArchCon.Carga,ArchCon.conadmin,ArchOri.Prefijo_Archivo, ArchOri.Sistema, ArchOri.Conciliacion_Inter, 
						ArchOri.Conciliacion_SIF, ArchOri.Conciliacion_Admin,ArchOri.Borra_Archivo_Fisico,
						ArchOri.Transaccion_Compra, ArchOri.Transaccion_Liberacion, ArchOri.Transaccion_Forzada, ArchOri.Transaccion_Abono,
						ArchOri.Rep_Aix, ArchOri.Rep_Win, ArchOri.Archivo_Companero, ArchOri.Archivo_Report_Comisiones, ArchOri.Tipo_LayOut
					FROM bditarjeta:td_archivos_conciliacion_atm_stat06_pagos AS ArchCon 
					LEFT JOIN bditarjeta:td_archivo_origen_atm_stat06 AS ArchOri 
					ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
					WHERE ArchCon.Proceso = 'P'
					AND ArchCon.Fecha_Archivo <= (dtFecha_Hoy_Integral::DATE - ArchOri.Dias_Desfase)::DATE
					AND Horario_Ejecucion_Ext <= piHorario
					ORDER BY Horario_Ejecucion_Ext, orden_proceso ASC
					INTO temp tb_config_archivo_extenporaneo WITH NO LOG ;
				
					SELECT FIRST 1
						Flag_ArchPendiente, NombreArchivo, Archivo_Origen, Fecha_Archivo,Carga, conadmin,
						Prefijo_Archivo, Sistema, Conciliacion_Inter, Conciliacion_SIF, Conciliacion_Admin,
						Borra_Archivo_Fisico, Transaccion_Compra, Transaccion_Liberacion, Transaccion_Forzada, 
						Transaccion_Abono, Rep_Aix, Rep_Win, 
						Archivo_Companero, Archivo_Report_Comisiones, Tipo_LayOut
					INTO 
						vsFlag_ArchPendiente, vsNombreArchivo, vsArchivo_Origen, vdtFecha_Archivo, vsCarga, vsConadmin,
						vsPrefijo_Archivo, vsSistema, vsConciliacion_Inter, vsConciliacion_SIF, vsConciliacion_Admin,
						viBorra_Archivo_Fisico, vsTransaccion_Compra, vsTransaccion_Liberacion, vsTransaccion_Forzada, 
						vsTransaccion_Abono, vsRep_Aix, vsRep_Win, vsArchivo_Companero, vsArchivo_Report_Comisiones, viTipo_LayOut
					FROM tb_config_archivo_extenporaneo;
					
				END IF; -- IF(1)
				
				IF (NVL(vsFlag_ArchPendiente, 'F') = 'V') THEN 
					
					
					LET vsFlag_Ciclo_BusrcarArch = 'V'; --ENCONTRO UN REGISTRO, ACTIVAR PARA BUSCAR EL SIGUIENTE
					LET vsFlag_Error_Reg = 'F';
					
					
					IF ( vsSistema = 'A' ) THEN
					
						-- ACTUALIZA LA HORA DE INICIO DE PROCESO DEL ARCHIVO
						UPDATE bditarjeta:td_archivos_conciliacion_atm_stat06_pagos
						SET Fecha_Hora_Ini_Proceso = vdDiaHora,
							Fecha_Proceso = vdFechaDeHoy
						WHERE NombreArchivo = vsNombreArchivo 
						AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;
						
						
						IF ( vsCarga <> 'V' ) THEN 
							
										
							-- CARGA EL ARCHIVO A LA TABLA DE PASO
							EXECUTE PROCEDURE bditarjeta:sp_cargaarchivos_atm_stat06_pagos ( vsRep_Aix, vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, vsSistema, vsRep_Aix )
							INTO vsCodRet, vsMensaje_Respuesta, viTot_Registros, vmTot_Monto, viElemento;

							-- ACTUALIZA LA HORA DE FIN DE LA CARGAR DE ARCHIVO A LA BD
							UPDATE bditarjeta:td_archivos_conciliacion_atm_stat06_pagos
							SET Fecha_Hora_Carga_Archivo = vdDiaHora
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
							AND Fecha_Archivo = vdtFecha_Archivo;
								
						
								
						END IF; -- (2.1.1)
						
						IF ( vsCodRet = '00000' ) THEN 
							-- VALIDA SI EL ARCHIVO SE CARGO A LA TABLA DE PASO. IF(2.1.2)
						
							
						
							IF ( vsCarga <> 'V' ) THEN 
								
								
								-- CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA Td_Movimientos_Conciliacion_mc
								EXECUTE PROCEDURE bditarjeta:sp_obtenerregistroarchivoatm_stat06_pagos (vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, psCve_Usuario )
								INTO vsCodRet, vsMensaje_Respuesta, viElemento;
								
								
								
								-- ACTUALIZA LA HORA DE FIN DE LA CARGAR DE LA TABLA Td_Movimientos_Conciliacion_mc
								UPDATE BdiTarjeta:td_archivos_conciliacion_atm_stat06_pagos
								SET Fecha_Hora_Carga_Tabla = vdDiaHora,
									Num_Registros325 = viTot_Registros, 
									Monto325 = vmTot_Monto,
									Carga = DECODE(vsCodRet, '00000', 'V', 'F')                                
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
									
							END IF; -- IF(2.1.2.A)
							
							-- TRACE 'SOY CODADMIN '|| vsConadmin;
							
							IF ( vsConadmin = '' ) THEN 
							
								EXECUTE PROCEDURE bditarjeta:sp_concreing_atm_stat06_pagos (psCve_Usuario, piHorario)
								INTO vsCodRet, vsMensaje_Respuesta;
								
							
								
								LET vsTotaltxn = NVL( viTot_Registros,0.0 );
								LET vsTotalMonto = NVL( vmTot_Monto,0.0 );
								
								UPDATE bditarjeta:td_archivos_conciliacion_atm_stat06_pagos
								SET fecha_hora_gen_conadmin = vdDiaHora,
									Num_Registros325 = vsTotaltxn, 
									Monto325 = vsTotalMonto,
									Carga = DECODE(vsCodRet, '00000', 'V', 'F')                                
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
									
							END IF; -- IF(2.1.2.A)
							
							IF (vsCodRet = '00000') THEN  -- IF(2.1.2.B)
							
								--TRACE 'SI ENTRE :) 9';
							
								UPDATE BdiTarjeta:td_archivos_conciliacion_atm_stat06_pagos
								SET Fecha_Hora_Ini_Concilia_Reg = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
							
								LET vsFlagEnTransaccion = 'F';
								LET viContadorRegistros = 0;
								LET vsFlag_Ciclo_BusrcarReg = 'V'; -- ARCTIVAR PARA BUSCAR UN REGISTRO.
								
							
							
								-- Bloque utilizado para confirmar los cambios y cerrar la transaccion
								
								IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN							
									COMMIT WORK;
									LET vsFlagEnTransaccion = 'F';
								END IF;
							
							END IF -- IF(2.1.2.B)
						END IF;						
					END IF; -- IF(2.1)
					
					UPDATE bditarjeta:td_archivos_conciliacion_atm_stat06_pagos
					SET Fecha_Hora_Fin_Proceso = vdDiaHora,
					Proceso = (
						CASE 
							WHEN vsCodRet IN ('00006', '00007') THEN 'X'  -- PENDIENTE PARA EL PROX CRON ()
							WHEN vsCodRet = '00000' THEN 'T'  -- TRABAJADO
							ELSE 'E' 
						END ) --ERROR DE CARGA 1-2
					WHERE NombreArchivo = vsNombreArchivo 
					AND Archivo_Origen = vsArchivo_Origen 
					AND Fecha_Archivo = vdtFecha_Archivo;
					
				END IF; -- IF(2)
				
				DROP TABLE IF EXISTS tb_config_archivo_extenporaneo;
				DROP TABLE IF EXISTS tb_config_archivo_normal;
				
				IF (vsCodRet <> '00000') THEN
					-- NIVEL DE ARCHIVO
					-- GUARDA EN BITACORA REGISTRO DEL ERROR EN CASO DE QUE EXISTA
					
					EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_atm_stat06_pagos (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
					
					LET viContadorErroresCon = viContadorErroresCon + 1;
				END IF;
				
				IF ( EXISTS 
					(
						SELECT Descripcion 
						FROM bditarjeta:td_param_conciliacion_atm_06_pagos 
						WHERE Codigo = '002' 
						AND Descripcion = 'PARO DE EMERGENCIA DE CONCILIACION' 
						AND TRIM(Valor) = 'V'
					) 
				) THEN -- VALIDA QUE SI EXISTE UNA ORDEN DE DETENER LA CONCILIACION (CONCREIN)
				
					LET vsMensaje_Respuesta = 'PARO DE EMERGENCIA DE CNC ATM PAGOS.';

					-- LIBERA LA BANDERA DE PARO DE EMERGENCIA DE CONCILIACION
					UPDATE bditarjeta:td_param_conciliacion_atm_06_pagos
					SET Valor = 'F', Fecha_Modificacion = vdDiaHora
					WHERE Codigo = '002' 
					AND Descripcion = 'PARO DE EMERGENCIA DE CNC ATM PAGOS'
					AND TRIM(Valor) = 'V';
							
					LET vsFlag_ArchPendiente = 'F'; 
					LET vsFlag_Ciclo_BusrcarArch = 'F'; -- TERMINA EL CICLO 
					LET vsCodRet = '00010'; -- CONCILIACION DETENIDA --CONCREIN
					LET vsMensaje_Respuesta = 'CONCILIACION DETENIDA POR EL USUARIO.';
					
				END IF;	
			END WHILE;
			
			-- VALIDA SI ESXISTEN ARCHIVOS CON ESTATUS 'X'
			IF (EXISTS 
				(
					SELECT NombreArchivo 
					FROM bditarjeta:td_archivos_conciliacion_atm_stat06_pagos 
					WHERE Proceso = 'X'
				)
			) THEN
				-- MARCA DISPONIBLES LOS REGISTROS QUE NO SE PROCESARON POR PASES DE CRED O DEB
				UPDATE bditarjeta:Td_Archivos_Conciliacion
				SET Fecha_Hora_Fin_Proceso = vdDiaHora,
					Proceso = 'P'
				WHERE Proceso = 'X'; 
			END IF;
			
			-- LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE bditarjeta:td_param_conciliacion_atm_06_pagos 
			SET Valor = 'F', 
				Fecha_Modificacion = vdDiaHora
			WHERE Codigo = '001' 
			AND Descripcion = 'CONCILIACION ATM PAGOS EN EJECUCION' 
			AND TRIM(Valor) = 'V';
			
		END IF; -- IF PRINCIPAL 
		
		IF ( vsCodRet <> '00000' ) THEN
			-- NIVEL DE PROCESO
			
			-- GUARDA EN BITACORA REGIOSTRO DEL ERROR EN CASO DE QUE EXISTA
			EXECUTE PROCEDURE bditarjeta:sp_guardabitacora_atm_stat06_pagos (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
		
		ELSE
			LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA.' 
			|| DECODE ((viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)), 0, '', ' -- SE PRESENTARON [' || (viContadorErroresCon - (viContadorErrores_Pase_Credito + viContadorErrores_Pase_Debito)) || '] ERRORES DE PROCESO DE ARCHIVO.' )
			|| DECODE (viContadorErrores_Pase_Credito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Credito || '] ARCHIVOS POR LA FALTA DEL PASE DE CREDITO.' )
			|| DECODE (viContadorErrores_Pase_Debito, 0, '', ' -- NO SE PROCESARON [' || viContadorErrores_Pase_Debito || '] ARCHIVOS POR LA FALTA DEL PASE DE DEBITO.' );
		END IF;
		
		RETURN vsCodRet, vsMensaje_Respuesta;
	END	
END PROCEDURE;