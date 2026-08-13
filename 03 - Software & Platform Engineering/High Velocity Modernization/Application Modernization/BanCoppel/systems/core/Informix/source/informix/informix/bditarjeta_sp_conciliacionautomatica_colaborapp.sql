CREATE PROCEDURE "informix".sp_conciliacionautomatica_colaborapp(psCve_Usuario VARCHAR(10) , piHorario INTEGER)
RETURNING VARCHAR (5) AS CodRet, VARCHAR (150) AS Mensaje_Respuesta ;

	-- DEFINICION DE VARIABLES CONTROL GENERAL
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
	--CONTROL DE TRANSACCIONALIDAD	
	DEFINE viContadorRegistros 			INTEGER;
	DEFINE vsFlagEnTransaccion 			VARCHAR (1);	
	--DATOS MOVIMIENTOS_CONCILIACION	
    DEFINE vsNombreArchivo 				VARCHAR (30);
    DEFINE vsArchivo_Origen 			VARCHAR (3);
    DEFINE vdtFecha_Archivo 			DATE;
    DEFINE vsCarga 						VARCHAR (3);
    DEFINE vsSistema 					VARCHAR (1);
    DEFINE vsRep_Aix 					VARCHAR (50);
    DEFINE viTipo_LayOut 				INTEGER;
	DEFINE vsFlag_Ciclo_BusrcarReg 		VARCHAR (1);
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
	DEFINE viContadorErroresCon INTEGER;
	DEFINE cFlagcnc 	   CHAR(1);
	DEFINE cFlagStop       CHAR(1);
	DEFINE iCount          INTEGER;
	--INICIALIZACION DE VARIABLES  CONTROL GENERAL
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
    LET vsSistema = '';
    LET vsRep_Aix = '';
    LET viTipo_LayOut = 0;
	--DATOS ARCHIVO_CONCILIACION
    LET viTot_Registros = 0;
    LET vmTot_Monto = 0.0;
	LET vsFlag_Ciclo_BusrcarReg = 'V';
    --CONTROL DE TRANSACCIONALIDAD
    LET vsFlagEnTransaccion = '';
    LET viContadorRegistros = 0;
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
	LET viContadorErroresCon = 0;
	LET cFlagcnc  = '';
	LET cFlagStop = '';
	LET iCount    = 0; 
	
	BEGIN

		ON EXCEPTION SET viSQLerr
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_colaborapp  
					SET Valor = 'F',
					Fecha_Modificacion = vdFechaDeHoy
				    WHERE Codigo = '001' AND Valor = 'V';
			
			LET viElemento = 0;	
			LET vsCodRet = '00020';
			LET vsMensaje_Respuesta = 'ERROR NO CONTROLADO (' || viSQLerr || '). ' || TRIM(vsMensaje_Respuesta);
			
			EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_colaborapp (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario)
								INTO vsCodRet2;
			RETURN vsCodRet, vsMensaje_Respuesta;
			
		END EXCEPTION;	
		
		ON EXCEPTION IN (-535) --EN CASO DE TRANSACCION ABIERTA Y TRATAR DE ABRIR OTRA
			COMMIT WORK; --TERMINA LA TRANSACCION ACTUAL Y CONTINUA
		END EXCEPTION WITH RESUME;
		
			--SET DEBUG FILE TO "/informix/mgap/trace_cnc_colaborapp.out";
			--TRACE ON;

		--OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
		SELECT LIMIT 1 Fecha_Hoy INTO dtFecha_Hoy_Integral 
		FROM bdinteg:"informix".Si_Fechas WHERE empresa = '001';	
		
			IF NOT EXISTS(SELECT Fecha FROM BdiCheq:"informix".sc_ContProc WHERE Proceso = 'pasomovshist' AND Fecha = (TODAY-1)) THEN  
				 
							LET vsCodRet = '00007';  
							LET vsMensaje_Respuesta = 'NO SE HA REALIZADO EL PASE HISTORICO DE DEBITO.';
							RETURN vsCodRet, vsMensaje_Respuesta;
		    END IF;

            SELECT valor INTO cFlagcnc FROM BdiTarjeta:"informix".td_param_conciliacion_colaborapp
            WHERE Codigo = '001';		
             
		-- IF PRINCIPAL
		IF       cFlagcnc = 'V'
		
			THEN --VALIDA QUE NO EXISTA UNA CONCILIACION EN EJECUCION 

				LET vsCodRet = '00001';   
				LET vsMensaje_Respuesta = 'CONCILIACION EN EJECUCION';
                RETURN vsCodRet, vsMensaje_Respuesta;
				
				--LET viContadorErroresCon = viContadorErroresCon + 1;
 				
			ELIF (dtFecha_Hoy_Integral < vdFechaDeHoy ) 
				
				THEN -- VALIDA QUE EL SISTEMA DE INTEGRA ESTE ACORDE A LA DEL SERVIDOR
			
				LET vsCodRet = '00002';  
				LET vsMensaje_Respuesta = 'FECHAS INTEGRAL-SERVIDOR DESFASADAS.';
				RETURN vsCodRet, vsMensaje_Respuesta;
					
					 --LET viContadorErroresCon = viContadorErroresCon + 1;
		ELSE 

			LET vsMensaje_Respuesta = 'MARCAR CONCILIACION EN EJECUCION.';

			--MARCA LA BANDERA DE CONCILIACION EN EJECUCION
			    UPDATE BdiTarjeta:"informix".td_param_conciliacion_colaborapp
				SET Valor = 'V',  
				Fecha_Modificacion = vdFechaDeHoy
				WHERE Codigo = '001'
		     	AND TRIM(Valor) = 'F';

			LET vsFlag_Ciclo_BusrcarArch = 'V'; --ACTIVAR PARA BUSCAR UN ARCHIVO.
			
			WHILE (vsFlag_Ciclo_BusrcarArch = 'V')  --CICLO DE BUSQUEDA DE ARCHIVOS PENDIENTES.

				--PERMANECE DESACTIVADO EL CICLO EN CASO DE NO ENCONTRAR OTRO REGISTRO.
				LET vsFlag_Ciclo_BusrcarArch = 'F';
				LET vsFlag_ArchPendiente = 'F';
				LET viElemento = 0;
				LET vsCodRet = '00000';
				LET viTot_Registros = 0;
				LET vmTot_Monto = 0.0;
				LET vsMensaje_Respuesta = '';

					LET vsMensaje_Respuesta = 'OBTENER ARCHIVOS A CONCILIAR.';
					
				IF (NVL(vsFlag_ArchPendiente, 'F') <> 'V') THEN  
					
					DROP TABLE IF EXISTS tb_config_archivo_extemporaneo;
					
					SELECT  'V' AS Flag_ArchPendiente,
          					ArchCon.NombreArchivo, ArchCon.Archivo_Origen, 
							ArchCon.Fecha_Archivo, ArchCon.Carga,  ArchOri.Sistema, 
							ArchOri.Rep_Aix, ArchOri.Tipo_LayOut
						FROM BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp AS ArchCon 
							LEFT JOIN BdiTarjeta:"informix".td_archivo_origen_colaborapp AS ArchOri 
							ON ArchCon.Archivo_Origen = ArchOri.Archivo_Origen
						WHERE ArchCon.Proceso = 'P'
						      AND ArchCon.Fecha_Archivo <=  dtFecha_Hoy_Integral    
							  ORDER BY Fecha_Archivo ASC
					INTO temp tb_config_archivo_extemporaneo WITH NO LOG ;
				
					
					SELECT FIRST 1
							Flag_ArchPendiente, NombreArchivo, Archivo_Origen, Fecha_Archivo,Carga,  
							 Sistema,  Rep_Aix ,Tipo_LayOut
					INTO 
							vsFlag_ArchPendiente, vsNombreArchivo, vsArchivo_Origen, vdtFecha_Archivo, vsCarga,  
							vsSistema,   vsRep_Aix , viTipo_LayOut
					FROM tb_config_archivo_extemporaneo;

				END IF;	
					
					
					IF (NVL(vsFlag_ArchPendiente, 'F') = 'V') THEN 

						LET vsFlag_Ciclo_BusrcarArch = 'V'; --ENCONTRO UN REGISTRO, ACTIVAR PARA BUSCAR EL SIGUIENTE
						LET vsFlag_Error_Reg = 'F';
		
						--ACTUALIZA LA HORA DE INICIO DE PROCESO DEL ARCHIVO
						UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
							SET Fecha_Hora_Ini_Proceso = vdDiaHora,
								Fecha_Proceso = vdFechaDeHoy
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;

						IF (vsCarga <> 'V') THEN   
			 
								--CARGA EL ARCHIVO A LA TABLA DE PASO
								EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cargaarchivos_colaborapp ( vsRep_Aix, vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, vsSistema)
									INTO vsCodRet, vsMensaje_Respuesta, viTot_Registros, vmTot_Monto, viElemento;

								--ACTUALIZA LA HORA DE FIN DE LA CARGAR DE ARCHIVO A LA BD
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
								SET Fecha_Hora_Carga_Archivo = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;
						END IF; --  
						--VALIDA SI EL ARCHIVO SE CARGO A LA TABLA DE PASO.
						IF (vsCodRet = '00000') THEN  
		
							--VALIDA QUE LA CARGA DEL ARCHIVO NO FUE REALIZADA PREVIAMENTE
							IF (vsCarga <> 'V') THEN  -- 
								--CARGA LA INFORMACION SIGNIFICATIVA DE LOS REGISTROS A LA TABLA sp_obtenerregistroarchivo_colaborapp 
								EXECUTE PROCEDURE BdiTarjeta:"informix".sp_obtenerregistroarchivo_colaborapp (vsNombreArchivo, vsArchivo_Origen, viTipo_LayOut, psCve_Usuario )
									INTO vsCodRet, vsMensaje_Respuesta, viElemento;
								--ACTUALIZA LA HORA DE FIN DE LA CARGAR DE LA TABLA td_archivos_conciliacion_colaborapp
								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
								SET Fecha_Hora_Carga_Tabla = vdDiaHora,
									Num_Registros325 = viTot_Registros,   
									Monto325 = vmTot_Monto,              
									Carga = DECODE(vsCodRet, '00000', 'V', 'F')                                
								WHERE NombreArchivo = vsNombreArchivo 
									AND Archivo_Origen = vsArchivo_Origen 
									AND Fecha_Archivo = vdtFecha_Archivo;
									
							END IF;  
 
							IF (vsCodRet = '00000') THEN  

								UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
								SET Fecha_Hora_Ini_Concilia_Reg = vdDiaHora
								WHERE NombreArchivo = vsNombreArchivo 
								AND Archivo_Origen = vsArchivo_Origen 
								AND Fecha_Archivo = vdtFecha_Archivo;

								LET vsFlagEnTransaccion = 'F';
								LET viContadorRegistros = 0;
								LET vsFlag_Ciclo_BusrcarReg = 'V';  
								--Bloque utilizado para confirmar los cambios y cerrar la transaccion.
								IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN							
									COMMIT WORK;
									LET vsFlagEnTransaccion = 'F';
								END IF;
							
							END IF 
							
						END IF;	 	 			
					END IF;  
  
  						UPDATE BdiTarjeta:"informix".td_archivos_conciliacion_colaborapp
						SET Fecha_Hora_Fin_Proceso = vdDiaHora,
						Proceso = (CASE 
										WHEN (vsCodRet = '00000' ) THEN 'T'  --TRABAJADO
									ELSE 'E' END) --ERROR DE CARGA 1-2
							WHERE NombreArchivo = vsNombreArchivo 
							AND Archivo_Origen = vsArchivo_Origen 
						AND Fecha_Archivo = vdtFecha_Archivo;
   
				IF (vsCodRet <> '00000') THEN
					--GUARDA EN BITACORA REGISTRO DEL ERROR EN CASO DE QUE EXISTA
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_guardabitacora_colaborapp (viElemento, '(' || vsCodRet || ') ' || vsMensaje_Respuesta, psCve_usuario) INTO vsCodRet2;
					LET viContadorErroresCon = viContadorErroresCon + 1;
				END IF;
				-----------				  
				  SELECT valor INTO cFlagStop FROM BdiTarjeta:"informix".td_param_conciliacion_colaborapp
                  WHERE Codigo = '002';	
 
                IF     cFlagStop = 'V' THEN  
					--LIBERA LA BANDERA DE PARO DE EMERGENCIA DE CONCILIACION
					    UPDATE BdiTarjeta:"informix".td_param_conciliacion_colaborapp
						SET Valor = 'F', Fecha_Modificacion = vdDiaHora
					    WHERE Codigo = '002' 
						AND TRIM(Valor) = 'V';
						
					LET vsFlag_ArchPendiente = 'F'; 
					LET vsFlag_Ciclo_BusrcarArch = 'F'; --TERMINA EL CICLO 
					LET vsCodRet = '00010'; --CONCILIACION DETENIDA 
					LET vsMensaje_Respuesta = 'CONCILIACION DETENIDA POR EL USUARIO.';
					
				END IF;
				
			END WHILE;

		END IF;
		-------------------------------------------- 
		--- ConAdmin.
				SELECT COUNT(*) INTO iCount FROM bditarjeta:td_archivos_conciliacion_colaborapp 	
					WHERE  Fecha_Proceso = vdFechaDeHoy
					AND archivo_origen = 'CAP'
					AND conadmin = ''   
                    AND Carga = 'V'
                    AND Proceso = 'T';	
 
				IF iCount >= 1 THEN 
				
		            EXECUTE PROCEDURE BdiTarjeta:"informix".sp_concreing_colaborapp (psCve_Usuario, piHorario,vdFechaDeHoy) INTO vsCodRet, vsMensaje_Respuesta; 
     			  
                        IF (vsCodRet > '00011')  THEN --'NO SE ENCONTRO REGISTROS PARA CONCILIAR';		 		   
		           
  				         LET viContadorErroresCon = viContadorErroresCon + 1;
					
		                END IF;
				          
			    END IF;
        --------------------------------------------
 			--LIBERA LA BANDERA DE CONCILIACION EN EJECUCION
			UPDATE BdiTarjeta:"informix".td_param_conciliacion_colaborapp 
				SET Valor = 'F', 
				Fecha_Modificacion = vdDiaHora
			WHERE Codigo = '001' 
				  AND TRIM(Valor) = 'V';	
		--------------------------------------------
		IF viContadorErroresCon > 0 then 
		
		  LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA. CON [' || viContadorErroresCon || '] ERRORES DE PROCESO';          
		  
        ELIF (vsCodRet = '00011')   then 
		
 		      LET vsCodRet = '00000';
              LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA SIN REGISTROS QUE CONCILIAR';
		
		ELIF  iCount = 0 THEN 
		
		      LET vsCodRet = '00000';
		      LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA SIN ARCHIVOS PROCESADOS';
		
		 ELSE 
		      LET vsCodRet = '00000';
		      LET vsMensaje_Respuesta = 'CONCILIACION FINALIZADA CORRECTAMENTE';
		
        END IF; 
			
		RETURN vsCodRet, vsMensaje_Respuesta;
	END
	
END PROCEDURE;