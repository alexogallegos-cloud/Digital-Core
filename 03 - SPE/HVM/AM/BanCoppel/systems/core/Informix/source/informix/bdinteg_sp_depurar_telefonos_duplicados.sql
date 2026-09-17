CREATE PROCEDURE "informix".sp_depurar_telefonos_duplicados()
	RETURNING CHAR(6), CHAR(100);

	--DEFINE VARIABLES
	DEFINE vCodRet			CHAR(6);
	DEFINE cEstado			CHAR(100);
	DEFINE cDescErr			CHAR(100);
	DEFINE iNomErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iEnTransaccion	SMALLINT;
	DEFINE cProceso			CHAR(100);
	DEFINE cEvento			CHAR(100);
	DEFINE cCantidadTels	CHAR(40);
	DEFINE iCantidadTels	INTEGER;
	DEFINE cRegCommit		CHAR(40);
	DEFINE MAXTRANSACCION	INTEGER;
	DEFINE cTelDepura		CHAR(13);
	--DEFINE cNumcte			CHAR(20);
	DEFINE iRowID 			INTEGER;
	DEFINE cNumCteTelsActual	CHAR(20);
	DEFINE cNumCteTelVerificado	CHAR(20);
	DEFINE cNumCtePropietario	CHAR(20);
	DEFINE cNumCtePropietario2	CHAR(20);
	DEFINE cNumCteCtaTel	CHAR(20);
	DEFINE iCantDepurada	INTEGER;
	DEFINE cNumCteDepurar	CHAR(20);
	DEFINE vIndTelefono		CHAR(1);
	DEFINE vIndCorreo		CHAR(1);
	DEFINE vCodRetRev		CHAR(5);
	
	DEFINE cQuery			CHAR(1000);
	DEFINE iProcesados		INTEGER;
	DEFINE iId				INTEGER;
	DEFINE iRegs_actuales	INTEGER;
	DEFINE iPorProcesar 	INTEGER;
	DEFINE iTipoDepuracion 	SMALLINT;
	DEFINE iTel_depurados 	SMALLINT;
	DEFINE iExiste_tmp_si_telefonos SMALLINT;
	DEFINE iExiste_tmp_telefonos_dup SMALLINT;
	DEFINE iReversar		INTEGER;
	DEFINE iError			INTEGER;
	DEFINE iInstancia		INTEGER;
	DEFINE iSalto			INTEGER;

	--INICIALIZACION DE VARIABLES
	LET vCodRet 				= '000000';
	LET cEstado 				= 'PROCESO DE DEPURACION DE TELEFONOS DUPLICADOS GENERADO CORRECTAMENTE';
	LET cDescErr				= '';
	LET iEnTransaccion 			= 0;
	LET cProceso 				= 'sp_depurar_telefonos_duplicados';
	LET cEvento					= 'INICIO DEL PROCEDIMIENTO';
	LET cCantidadTels 			= '';
	LET iCantidadTels	 		= 0;
	LET cRegCommit	 			= '';
	LET MAXTRANSACCION 			= 0;
	LET cTelDepura				= '';
	LET cNumCteTelsActual		= '';
	LET cNumCteTelVerificado	= '';
	LET cNumCtePropietario		= '';
	LET cNumCtePropietario2		= '';
	LET cNumCteCtaTel			= '';
	LET iCantDepurada			= 0;
	LET cNumCteDepurar			= '';
	LET vIndTelefono     		= '';
	LET vIndCorreo      		= '';
	LET vCodRetRev       		= '';

	LET cQuery					= '';
	LET iProcesados				= 0;
	LET iId						= 0;
	LET iRegs_actuales			= 0;
	LET iTipoDepuracion = 0;
	LET iPorProcesar		= 0;
	LET iTel_depurados		= 0;
	LET iReversar			= 0;
	LET iExiste_tmp_si_telefonos = 0;
	LET iExiste_tmp_telefonos_dup = 0;
	LET iError			= 0;
	LET iInstancia		= 0;
	LET iSalto		= 0;
	

	--SET DEBUG FILE TO "/tmp/josea/64112/sp_depurar_telefonos_duplicados.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iNomErr, iIsamErr, cDescErr
			IF iNomErr <> 0 THEN
				LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN
					LET iEnTransaccion = 0;
					ROLLBACK WORK;
				END IF;
				
				UPDATE si_param 
				SET valor = valor::INTEGER - 1
				WHERE cod_param = 381;
				
				LET cEstado = 'PROCESO DE DEPURACION DE TELEFONOS DUPLICADOS GENERADO CON ERRORES';
				INSERT INTO bdinteg: si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
				VALUES (CURRENT, cTelDepura, cProceso, cEvento, vCodRet, cDescErr||': '|| iTipoDepuracion, USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
				
				IF iExiste_tmp_telefonos_dup = 1 THEN
					DROP TABLE stat_tmp_telefonos_en_proceso;
					LET iExiste_tmp_telefonos_dup = 0;
				END IF;
				
				RETURN vCodRet, iIsamErr || ' ' || TRIM(cDescErr);
			END IF;			
		END EXCEPTION;
		--DEFINE dtFechaInsercion DATETIME HOUR TO FRACTION;
		--SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
		
		SELECT valor::INTEGER 
		INTO iInstancia 
		FROM si_param 
		WHERE cod_param = 381;
		
		LET iInstancia = iInstancia + 1;
		
		UPDATE si_param 
		SET valor = iInstancia 
		WHERE cod_param = 381;
		
		LET cEvento = 'VALIDA EXISTENCIA DE PARAMETRO LIMITE DE DEPURACIONES';		
		IF EXISTS (SELECT 1 FROM bdinteg:si_param WHERE cod_param = 370) THEN
		
			SELECT {+INDEX(bdinteg:si_param ix_si_param)} valor 
			INTO cCantidadTels 
			FROM bdinteg:si_param 
			WHERE cod_param = 370;
			
			LET cEvento = 'VALIDA PARAMETRO LIMITE DE DEPURACIONES';
			IF NVL(cCantidadTels,'0')::INTEGER > 0 THEN
			
				LET cEvento = 'VALIDA EXISTENCIA DE PARAMETRO TAMA#O TRANSACCION';
				IF EXISTS(SELECT 1 FROM bdinteg:si_param WHERE cod_param = 376) THEN
					
					SELECT {+INDEX(bdinteg:si_param ix_si_param)} valor 
					INTO cRegCommit 
					FROM bdinteg:si_param 
					WHERE cod_param = 376;
					
					LET cEvento = 'VALIDA PARAMETRO TAMA#O DE TRANSACCION';
					IF NVL(cRegCommit,'0')::INTEGER > 0 THEN

						LET iCantidadTels = TRIM(cCantidadTels)::INTEGER;
						LET MAXTRANSACCION = TRIM(cRegCommit)::INTEGER;
						
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;
						
						SELECT {+INDEX(bdinteg:si_telefonos_duplicados idx_si_telefonos_duplicados_01)}LIMIT 1 1 
						INTO iSalto
						FROM bdinteg:si_telefonos_duplicados 
						WHERE tipo_tel = 2 AND estatus = '0';
						
						--IF EXISTS(SELECT {+INDEX(bdinteg:si_telefonos_duplicados idx_si_telefonos_duplicados_01)}1 FROM bdinteg:si_telefonos_duplicados WHERE tipo_tel = 2 AND estatus = '0')THEN
						IF iSalto = 1 THEN	
							LET iSalto = iCantidadTels * (iInstancia - 1);
							
							SET ISOLATION TO DIRTY READ;
							SET LOCK MODE TO WAIT 3;
							
							LET cEvento = 'OBTIENE NUMEROS DUPLICADOS';

							INSERT INTO bdinteg:stat_tmp_telefonos_en_proceso (instancia, id, telefono, tipo_tel)
							SELECT {+INDEX(bdinteg:si_telefonos_duplicados idx_si_telefonos_duplicados_02)} LIMIT iCantidadTels iInstancia, a.id, a.telefono, a.tipo_tel
							FROM bdinteg:si_telefonos_duplicados a LEFT JOIN bdinteg:stat_tmp_telefonos_en_proceso b
							ON a.id = b.id
							WHERE a.estatus = '0' AND a.tipo_tel = '2'
							AND b.id IS NULL;
							
							/*SELECT {+INDEX(bdinteg:si_telefonos_duplicados idx_si_telefonos_duplicados_02)} LIMIT iCantidadTels id, telefono, tipo_tel
							FROM bdinteg:si_telefonos_duplicados
							WHERE estatus = '0' AND tipo_tel = '2'
							INTO TEMP stat_tmp_telefonos_en_proceso WITH NO LOG;*/
							
							--LET iExiste_tmp_telefonos_dup = 1;							
							FOREACH WITH HOLD
								SELECT {+INDEX(bdinteg:si_telefonos_duplicados idx_si_telefonos_duplicados_02)} a.id, a.telefono
								INTO iId, cTelDepura
								FROM bdinteg:stat_tmp_telefonos_en_proceso a
								WHERE a.instancia = iInstancia
								
								BEGIN
									ON EXCEPTION SET iNomErr, iIsamErr, cDescErr
										IF iNomErr <> 0 THEN
											SET ISOLATION TO DIRTY READ;
											SET LOCK MODE TO WAIT 5;
											UPDATE si_telefonos_duplicados
											SET estatus = '2', cod_retorno = iNomErr, proceso = cDescErr||': '||iTipoDepuracion, tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE
											WHERE id = iId;
												
											INSERT INTO bdinteg: si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
											VALUES (CURRENT, cTelDepura, cProceso, cEvento, iNomErr::CHAR(6), cDescErr ||': '||iTipoDepuracion, USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
											
											IF iReversar = 1 THEN											
												INSERT INTO bdinteg:si_telefonos_actual (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
												SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado 
												FROM bdinteg: si_telefonos_actual_resp
												WHERE id = iId;
												
												IF iExiste_tmp_si_telefonos = 1 THEN
													MERGE INTO bdinteg:si_telefonos AS a 
													USING tmp_si_telefonos AS b
													ON a.telefono = b.telefono AND a.tipo_tel = b.tipo_tel AND a.numcte = b.numcte AND a.secuencia = b.secuencia
													WHEN MATCHED THEN UPDATE
													SET a.status_tel = b.status_tel;
												END IF;
												
												--DELETE bdinteg: si_telefonos_actual_resp
												--WHERE id = iId;
											END IF;
											
											LET cEstado = 'PROCESO DE DEPURACION DE TELEFONOS DUPLICADOS GENERADO CON ERRORES';
											
											CONTINUE FOREACH;
										END IF;			
									END EXCEPTION WITH RESUME;
									
									IF iExiste_tmp_si_telefonos = 1 THEN												
										DROP TABLE tmp_si_telefonos;
										LET iExiste_tmp_si_telefonos = 0;
									END IF;

									IF iProcesados = 0 THEN
										--IF iEnTransaccion = 0 THEN
											LET iEnTransaccion = 1;
											BEGIN WORK;
										--END IF;
									END IF;
									LET iProcesados = iProcesados + 1;
									LET iTipoDepuracion = 0;					
									LET iCantDepurada = 0;
									LET cNumCtePropietario = '';
									LET cNumCtePropietario2 = '';
									LET iReversar = 0;
									LET iTel_depurados = 0;
									LET iError = 0;
																		
									IF EXISTS(SELECT 1 FROM si_telefonos_actual WHERE tipo_tel = 2 AND telefono = cTelDepura HAVING COUNT(*) > 1) THEN
									
										LET cEvento = 'VALIDA SI EL TELEFONO HA SIDO VERIFICADO';								
										IF EXISTS (SELECT {+INDEX(bdinteg:si_telefonos idx_si_telefonos_telefono)} telefono FROM bdinteg: si_telefonos WHERE tipo_tel = 2 AND telefono = cTelDepura AND verificado = 'V') THEN
																					
											LET cEvento = 'OBTIENE CLIENTE RELACIONADO A REGISTRO MAS RECIENTE TEL_VER';
											LET cQuery = "SELECT FIRST 1 numcte";
											LET cQuery = TRIM(cQuery)||" FROM bdinteg: si_telefonos";
											LET cQuery = TRIM(cQuery)||" WHERE tipo_tel = 2 AND verificado = 'V' AND telefono = '"||cTelDepura||"'";
											LET cQuery = TRIM(cQuery)||" ORDER BY fecha_hora DESC";
											
											SET ISOLATION TO DIRTY READ;
											PREPARE stmtId FROM TRIM(cQuery);
											DECLARE custCur CURSOR FOR stmtId;
											OPEN custCur;
											FETCH custCur INTO cNumCteTelVerificado;
											CLOSE custCur;
											FREE custCur;
											FREE stmtId;
											
											LET cEvento = 'VALIDA SI EL TEL_VER ESTA RELACIONADO CON ALGUNA CUENTA: 1';
											SET ISOLATION TO DIRTY READ;
											IF EXISTS (SELECT telefono FROM bdicheq: sc_cuenta_telefono WHERE telefono = cTelDepura) THEN
											
												LET cEvento = 'OBTIENE CLIENTE TEL_CTA: 1';
												SELECT num_cte 
												INTO cNumCteCtaTel
												FROM bdicheq: sc_cuenta_telefono
												WHERE telefono = cTelDepura;
												
												LET cEvento = 'VALIDA CLIENTE TEL_VER vs CLIENTE CTA_TEL: 1';
												IF  cNumCteCtaTel = cNumCteTelVerificado THEN --Si es el mismo se considera como unico propietario y se depuran telefonos de los demas clientes
													LET iTipoDepuracion = 1;
													LET cNumCtePropietario = cNumCteTelVerificado;
																								
												ELSE --Se considera a ambos clientes como propiertarios del numero telefonico
													LET iTipoDepuracion = 2;
													LET cNumCtePropietario = cNumCteTelVerificado;
													LET cNumCtePropietario2 = cNumCteCtaTel;												
												END IF;
											ELSE  --Solo se considera al cliente que tiene verificado el telefono como propietario
												LET iTipoDepuracion = 1;
												LET cNumCtePropietario = cNumCteTelVerificado;
											END IF;											
										ELSE
											--Si el telefono no ha sido verificado por ningun cliente											
											--Se identifica si existe un registro de relacion cuenta-telefono con el numero de celular procesado (solo el numero telefonico)
											LET cEvento = 'VALIDA SI EL TELEFONO ESTA RELACIONADO CON ALGUNA CUENTA: 2';
											SET ISOLATION TO DIRTY READ;
											IF EXISTS (SELECT telefono FROM bdicheq: sc_cuenta_telefono WHERE telefono = cTelDepura) THEN												
												LET cEvento = 'OBTIENE CLIENTE TEL_CTA: 2';
												SELECT num_cte 
												INTO cNumCteCtaTel
												FROM bdicheq: sc_cuenta_telefono
												WHERE telefono = cTelDepura;
												
												LET iTipoDepuracion = 1;
												LET cNumCtePropietario = cNumCteCtaTel;												
											ELSE
												--Depura telefonos de clientes que tengan relacionado el numero telefonico y que NO tengan productos asociados
												LET iTipoDepuracion = 3;
											END IF;
										END IF;
										
										LET cEvento = 'INICIA DEPURACION DE INFORMACION';
										IF iTipoDepuracion = 1 THEN
											LET cEvento = 'RESPALDO DE INFORMACION DE CLIENTES NO PROPIETARIOS: 1';
											
											SET ISOLATION TO DIRTY READ;
											FOREACH
												SELECT numcte 
												INTO cNumCteDepurar
												FROM si_telefonos_actual 
												WHERE tipo_tel = 2 AND telefono = cTelDepura
												
												IF cNumCteDepurar <> cNumCtePropietario THEN
													
													INSERT INTO bdinteg:si_telefonos_actual_resp (id, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
													SELECT {+INDEX (bdinteg: si_telefonos_actual idx_telact_tel)}
														iId, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
													FROM bdinteg: si_telefonos_actual 
													WHERE numcte = cNumCteDepurar AND tipo_tel = 2 AND telefono = cTelDepura;
													--ROWID = iRowID;
																								
													LET cEvento = 'ELIMINA TELEFONOS DE CLIENTES NO PROPIETARIOS: 1';
													DELETE FROM bdinteg:si_telefonos_actual 
													WHERE numcte = cNumCteDepurar AND tipo_tel = 2 AND telefono = cTelDepura;
													--WHERE ROWID = iRowID;
																				
													LET iReversar = 1;
													IF iExiste_tmp_si_telefonos = 0 THEN
														SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza
														FROM si_telefonos
														WHERE numcte = cNumCteDepurar
														INTO TEMP tmp_si_telefonos WITH NO LOG;
														
														LET iExiste_tmp_si_telefonos = 1;
													ELSE
														INSERT INTO tmp_si_telefonos (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
														SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza
														FROM si_telefonos
														WHERE numcte = cNumCteDepurar;
													END IF;
													
													LET cEvento = 'CANCELA TELEFONOS DE CLIENTES NO PROPIETARIOS: 1';
													SET ISOLATION TO DIRTY READ;
													SET LOCK MODE TO WAIT 3;
													UPDATE {+INDEX(bdinteg:si_telefonos idx_si_telefonos_telefono)} bdinteg: si_telefonos 
													SET status_tel = 'C' 
													WHERE tipo_tel = 2 AND telefono = cTelDepura AND numcte = cNumCteDepurar;													
													
													LET cEvento = 'sp_valrevtelefonos: MARCA CLIENTES PARA ACTUALIZAR TELEFONOS: 1';
													EXECUTE PROCEDURE bdinteg: sp_valrevtelefonos(cNumCteDepurar)
													INTO vCodRetRev, vIndTelefono, vIndCorreo;

													IF TRIM(vCodRetRev) <> '000' THEN
														
														LET cEvento = 'REVERSO DE DEPURACION DE TELEFONO: 1';														
														LET iError = 1;
														
														SET ISOLATION TO DIRTY READ;
														SET LOCK MODE TO WAIT 3;
														MERGE INTO bdinteg:si_telefonos AS a 
														USING tmp_si_telefonos AS b
														ON a.telefono = b.telefono AND a.tipo_tel = b.tipo_tel AND a.numcte = b.numcte AND a.secuencia = b.secuencia
														WHEN MATCHED THEN UPDATE
														SET a.status_tel = b.status_tel;
														 
														INSERT INTO bdinteg:si_telefonos_actual (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
														SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
														FROM bdinteg: si_telefonos_actual_resp
														WHERE id = iId;
														
														--DELETE bdinteg: si_telefonos_actual_resp
														--WHERE id = iId;
														SET ISOLATION TO DIRTY READ;
														SET LOCK MODE TO WAIT 5;
														UPDATE si_telefonos_duplicados
														SET estatus = '2', cod_retorno = vCodRetRev, proceso = 'sp_valrevtelefonos: 1', tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE
														WHERE id = iId;
																													
														INSERT INTO bdinteg: si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
														VALUES (CURRENT, cTelDepura, cProceso, cEvento, vCodRetRev, 'sp_valrevtelefonos: 1', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
														
														EXIT FOREACH;
													END IF;																								
												END IF;
											END FOREACH;
											
											IF iExiste_tmp_si_telefonos = 1 THEN												
												DROP TABLE tmp_si_telefonos;
												LET iExiste_tmp_si_telefonos = 0;
											END IF;
											
											SET ISOLATION TO DIRTY READ;
											SET LOCK MODE TO WAIT 3;
											IF iError = 0 THEN		
												LET cEvento = 'MARCA TELEFONO COMO DEPURADO: 1';
												SET ISOLATION TO DIRTY READ;
												SET LOCK MODE TO WAIT 5;
												UPDATE si_telefonos_duplicados
												SET estatus = '1', cod_retorno = '000000', proceso = 'TELEFONO DEPURADO', tipo_depuracion = iTipoDepuracion,fecha_proceso = CURRENT::DATE, fecha_depuracion = CURRENT::DATE
												WHERE id = iId;
											END IF;

										ELIF iTipoDepuracion = 2 THEN
											LET cEvento = 'RESPALDO DE INFORMACION DE CLIENTES NO PROPIETARIOS: 2';
											SET ISOLATION TO DIRTY READ;
											FOREACH											
												--SELECT ROWID, numcte
												SELECT numcte
												INTO cNumCteDepurar
												FROM si_telefonos_actual 
												WHERE tipo_tel = 2 AND telefono = cTelDepura
												
												IF cNumCteDepurar NOT IN(cNumCtePropietario, cNumCtePropietario2)  THEN
													LET iTel_depurados = 1;
													INSERT INTO bdinteg:si_telefonos_actual_resp (id, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
													SELECT {+INDEX (bdinteg: si_telefonos_actual idx_telact_tel)}
														iId, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
													FROM bdinteg: si_telefonos_actual 
													WHERE numcte = cNumCteDepurar AND tipo_tel = 2 AND telefono = cTelDepura;
													--WHERE ROWID = iRowID;
													
													LET cEvento = 'ELIMINA TELEFONOS DE CLIENTES NO PROPIETARIOS: 2';
													DELETE FROM bdinteg:si_telefonos_actual 
													WHERE numcte = cNumCteDepurar AND tipo_tel = 2 AND telefono = cTelDepura;
													--WHERE ROWID = iRowID;
													
													LET iReversar = 1;
													SET ISOLATION TO DIRTY READ;
													SET LOCK MODE TO WAIT 3;
													IF iExiste_tmp_si_telefonos = 0 THEN
														SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza
														FROM si_telefonos
														WHERE numcte = cNumCteDepurar
														INTO TEMP tmp_si_telefonos WITH NO LOG;
														
														LET iExiste_tmp_si_telefonos = 1;
													ELSE
														INSERT INTO tmp_si_telefonos (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
														SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza
														FROM si_telefonos
														WHERE numcte = cNumCteDepurar;
													END IF;
													
													LET cEvento = 'CANCELA TELEFONOS DE CLIENTES NO PROPIETARIOS: 2';
													UPDATE {+INDEX(bdinteg:si_telefonos idx_si_telefonos_telefono)} bdinteg: si_telefonos 
													SET status_tel = 'C' 
													WHERE tipo_tel = 2 AND telefono = cTelDepura AND numcte = cNumCteDepurar;
													
													LET cEvento = 'INICIA PROCESO DE MARCAJE DE CLIENTES: 1';
													
													LET cEvento = 'sp_valrevtelefonos: MARCA CLIENTES PARA ACTUALIZAR TELEFONOS: 1';
													EXECUTE PROCEDURE bdinteg: sp_valrevtelefonos(cNumCteDepurar)
													INTO vCodRetRev, vIndTelefono, vIndCorreo;

													IF TRIM(vCodRetRev) <> '000' THEN
														
														LET iError = 1;
														LET cEvento = 'REVERSO DE DEPURACION DE TELEFONO: 2';
														MERGE INTO bdinteg:si_telefonos AS a 
														USING tmp_si_telefonos AS b
														ON a.telefono = b.telefono AND a.tipo_tel = b.tipo_tel AND a.numcte = b.numcte AND a.secuencia = b.secuencia
														WHEN MATCHED THEN UPDATE
														SET a.status_tel = b.status_tel;
														
														INSERT INTO bdinteg:si_telefonos_actual (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
														SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
														FROM bdinteg: si_telefonos_actual_resp
														WHERE id = iId;
														
														--DELETE bdinteg: si_telefonos_actual_resp
														--WHERE id = iId;
																
														SET ISOLATION TO DIRTY READ;
														SET LOCK MODE TO WAIT 5;
														UPDATE si_telefonos_duplicados
														SET estatus = '2', cod_retorno = vCodRetRev, proceso = 'sp_valrevtelefonos: 2', tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE
														WHERE id = iId;
																													
														INSERT INTO bdinteg: si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
														VALUES (CURRENT, cTelDepura, cProceso, cEvento, vCodRetRev, 'sp_valrevtelefonos: 2', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
														
														EXIT FOREACH;
													END IF;																								
												END IF;
											END FOREACH;
											
											IF iExiste_tmp_si_telefonos = 1 THEN												
												DROP TABLE tmp_si_telefonos;
												LET iExiste_tmp_si_telefonos = 0;
											END IF;
											
											IF iError = 0 THEN
												IF iTel_depurados = 1 THEN
													LET cEvento = 'MARCA TELEFONO COMO DEPURADO: 2';
													SET ISOLATION TO DIRTY READ;
													SET LOCK MODE TO WAIT 5;
													UPDATE si_telefonos_duplicados
													SET estatus = '1', cod_retorno = '000000', proceso = 'TELEFONO DEPURADO', tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE, fecha_depuracion = CURRENT::DATE
													WHERE id = iId;
												ELSE
													LET cEvento = 'ACTUALIZA REGISTRO DE INSTRUCCIONES DE DEPURACION: 2';
													SET ISOLATION TO DIRTY READ;
													SET LOCK MODE TO WAIT 5;
													UPDATE si_telefonos_duplicados
													SET estatus = '2', cod_retorno = '000007', proceso = 'TELEFONO NO DEPURADO: SOLO ESTA RELACIONADO A PROPIETARIOS',tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE
													WHERE id = iId;												
												END IF;
											END IF;
											
										ELIF iTipoDepuracion = 3 THEN
											SET ISOLATION TO DIRTY READ;
											SET LOCK MODE TO WAIT 3;
											
											FOREACH											
												SELECT numcte 
												INTO cNumCteDepurar
												FROM si_telefonos_actual 
												WHERE tipo_tel = 2 AND telefono = cTelDepura
																							
												LET cEvento = 'IDENTIFICA CLIENTES CON PRODUCTOS ASOCIADOS: 3';
												IF NOT EXISTS (SELECT {+INDEX(bdicheq: sc_maechq mae1)} 1 FROM bdicheq:sc_maechq WHERE num_cte = cNumCteDepurar) THEN
													IF NOT EXISTS(SELECT {+INDEX(bdicred: sd_maecred idx_11a)} 1 FROM bdicred:sd_maecred WHERE numcte = cNumCteDepurar) THEN
														IF NOT EXISTS (SELECT {+INDEX(bdinvers: sv_maeinv mai3)} 1 FROM bdinvers:sv_maeinv WHERE num_cte = cNumCteDepurar) THEN
															IF NOT EXISTS (SELECT {+INDEX(bdisolic: ss_solicitudes idx_numctesolic)} 1 FROM bdisolic:ss_solicitudes WHERE numcte = cNumCteDepurar) THEN
																LET cEvento = 'RESPALDO DE INFORMACION DE CLIENTE NO PROPIETARIO: 3';
																LET iTel_depurados = 1;
																
																INSERT INTO bdinteg:si_telefonos_actual_resp (id, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
																SELECT {+INDEX (bdinteg: si_telefonos_actual idx_telact_tel)}
																	iId, empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
																FROM bdinteg: si_telefonos_actual 
																WHERE numcte = cNumCteDepurar AND tipo_tel = 2 AND telefono = cTelDepura;
																--WHERE ROWID = iRowID;
																																
																LET cEvento = 'ELIMINA TELEFONOS DE CLIENTE NO PROPIETARIO: 3';
																DELETE FROM bdinteg:si_telefonos_actual 
																WHERE numcte = cNumCteDepurar AND tipo_tel = 2 AND telefono = cTelDepura;
																--WHERE ROWID = iRowID;
													
																LET iReversar = 1;
																SET ISOLATION TO DIRTY READ;
																SET LOCK MODE TO WAIT 3;
																
																IF iExiste_tmp_si_telefonos = 0 THEN
																	SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza
																	FROM si_telefonos
																	WHERE numcte = cNumCteDepurar
																	INTO TEMP tmp_si_telefonos WITH NO LOG;
																	
																	LET iExiste_tmp_si_telefonos = 1;
																ELSE
																	INSERT INTO tmp_si_telefonos (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza)
																	SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza
																	FROM si_telefonos
																	WHERE numcte = cNumCteDepurar;
																END IF;
													
																LET cEvento = 'CANCELA TELEFONOS DE CLIENTE NO PROPIETARIO: 3';
																SET ISOLATION TO DIRTY READ;
																SET LOCK MODE TO WAIT 3;

																UPDATE {+INDEX(bdinteg:si_telefonos idx_si_telefonos_telefono)} bdinteg: si_telefonos 
																SET status_tel = 'C' 
																WHERE tipo_tel = 2 AND telefono = cTelDepura AND numcte = cNumCteDepurar;
													
																LET cEvento = 'INICIA PROCESO DE MARCAJE DE CLIENTE: 3';
																
																EXECUTE PROCEDURE bdinteg: sp_valrevtelefonos(cNumCteDepurar)
																INTO vCodRetRev, vIndTelefono, vIndCorreo;
																
																LET cEvento = 'VALIDA RESPUESTA sp_valrevtelefonos: 3';
																IF TRIM(vCodRetRev) <> '000' THEN													
																	LET iError = 1;
																	LET cEvento = 'REVERSO DE DEPURACION DE TELEFONO: 3';
																	SET ISOLATION TO DIRTY READ;
																	SET LOCK MODE TO WAIT 3;

																	MERGE INTO bdinteg:si_telefonos AS a 
																	USING tmp_si_telefonos AS b
																	ON a.telefono = b.telefono AND a.tipo_tel = b.tipo_tel AND a.numcte = b.numcte AND a.secuencia = b.secuencia
																	WHEN MATCHED THEN UPDATE
																	SET a.status_tel = b.status_tel;
																	
																	INSERT INTO bdinteg: si_telefonos_actual (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado)
																	SELECT empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, tel_confirmado, fech_confirmado
																	FROM bdinteg:si_telefonos_actual_resp
																	WHERE id = iId;
																			
																	--DELETE bdinteg: si_telefonos_actual_resp
																	--WHERE id = iId;
																	SET ISOLATION TO DIRTY READ;
																	SET LOCK MODE TO WAIT 5;
																	UPDATE bdinteg:si_telefonos_duplicados
																	SET estatus = '2', cod_retorno = vCodRetRev, proceso = 'sp_valrevtelefonos: 3', tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE
																	WHERE id = iId;														
																																
																	INSERT INTO bdinteg:si_log_depuracion_telefonos (fecha, telefono, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
																	VALUES (CURRENT, cTelDepura, cProceso, cEvento, vCodRetRev, 'sp_valrevtelefonos: 3', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
																	
																	EXIT FOREACH;
																END IF;																
															END IF;
														END IF;
													END IF;
												END IF;
											END FOREACH;
											
											IF iError = 0 THEN
												IF iTel_depurados = 1 THEN
													LET cEvento = 'MARCA TELEFONO COMO DEPURADO: 3';
													SET ISOLATION TO DIRTY READ;
													SET LOCK MODE TO WAIT 5;
													UPDATE si_telefonos_duplicados
													SET estatus = '1', cod_retorno = '000000', proceso = 'TELEFONO DEPURADO', tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE, fecha_depuracion = CURRENT::DATE
													WHERE id = iId;													
												ELSE
													LET cEvento = 'ACTUALIZA REGISTRO DE INSTRUCCIONES DE DEPURACION: 3';
													SET ISOLATION TO DIRTY READ;
													SET LOCK MODE TO WAIT 5;
													UPDATE si_telefonos_duplicados
													SET estatus = '2', cod_retorno = '000008', proceso = 'TELEFONO NO DEPURADO: CLIENTES CON PRODUCTOS ASOCIADOS', tipo_depuracion = iTipoDepuracion, fecha_proceso = CURRENT::DATE
													WHERE id = iId;
												END IF;
											END IF;
											
											IF iExiste_tmp_si_telefonos = 1 THEN
												DROP TABLE tmp_si_telefonos;
												LET iExiste_tmp_si_telefonos = 0;
											END IF;
										END IF;
									ELSE
										LET iTipoDepuracion = 0;
										LET cEvento = 'ACTUALIZA REGISTRO DE INSTRUCCIONES DE DEPURACION: 2';
										SET ISOLATION TO DIRTY READ;
										SET LOCK MODE TO WAIT 5;
										UPDATE si_telefonos_duplicados
										SET estatus = '2', cod_retorno = '000006', proceso = 'TELEFONO NO DEPURADO: NO ESTA DUPLICADO EN BD', 
											fecha_proceso = CURRENT::DATE
										WHERE id = iId;
									END IF;
									
									IF iProcesados >= MAXTRANSACCION THEN									
										COMMIT WORK;
										LET iProcesados = 0;
										LET iEnTransaccion = 0;
									END IF;									
								END;
							END FOREACH;										
							
							IF iEnTransaccion = 1 THEN							
								COMMIT WORK;
								LET iProcesados = 0;
								LET iEnTransaccion = 0;
							END IF;
							
							DELETE FROM bdinteg:stat_tmp_telefonos_en_proceso
							WHERE instancia = iInstancia;
						ELSE
							INSERT INTO si_log_depuracion_telefonos(fecha, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
							VALUES(CURRENT::DATE, cProceso, cEvento, '000005', 'NO EXISTEN INSTRUCCIONES POR PROCESAR', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
							
							LET cEstado = 'PROCESO NO REALIZADO, NO EXISTEN INSTRUCCIONES DE DEPURACION POR PROCESAR';						
							END IF;
					ELSE
						INSERT INTO si_log_depuracion_telefonos(fecha, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
						VALUES(CURRENT::DATE, cProceso, cEvento, '000004', 'PARAMETRO TAMA#O DE TRANSACCION ES NULO o CERO', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));	
						
						LET cEstado = 'PROCESO NO REALIZADO, PARAMETRO TAMA#O DE TRANSACCION ES NULO o CERO';
					END IF;
				ELSE
					INSERT INTO si_log_depuracion_telefonos(fecha, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
					VALUES(CURRENT::DATE, cProceso, cEvento, '000003', 'PARAMETRO TAMA#O DE TRANSACCION NO EXISTE', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
					
					LET cEstado = 'PROCESO NO REALIZADO, PARAMETRO TAMA#O DE TRANSACCION NO EXISTE';				
				END IF;
			ELSE
				INSERT INTO si_log_depuracion_telefonos(fecha, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
				VALUES(CURRENT::DATE, cProceso, cEvento, '000002', 'PARAMETRO LIMITE DE DEPURACIONES ES NULO o CERO', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));	
				
				LET cEstado = 'PROCESO NO REALIZADO, PARAMETRO LIMITE DE DEPURACIONES ES NULO o CERO';			
			END IF;
		ELSE
			INSERT INTO si_log_depuracion_telefonos(fecha, proceso, evento, cod_error, mensaje, user_insert, fecha_insert)
			VALUES(CURRENT::DATE, cProceso, cEvento, '000001', 'PARAMETRO LIMITE DE DEPURACIONES NO EXISTE', USER, (SELECT DBINFO('utc_to_datetime',sh_curtime)FROM sysmaster:"informix".sysshmvals));
			
			LET cEstado = 'PROCESO NO REALIZADO, PARAMETRO LIMITE DE DEPURACIONES NO EXISTE';
		END IF;
		
		IF iExiste_tmp_si_telefonos = 1 THEN
			DROP TABLE tmp_si_telefonos;
			LET iExiste_tmp_si_telefonos = 0;
		END IF;
		
		/*IF iExiste_tmp_telefonos_dup = 1 THEN
			DROP TABLE stat_tmp_telefonos_en_proceso;
			LET iExiste_tmp_telefonos_dup = 0;
		END IF;*/
		UPDATE si_param 
		SET valor = valor::INTEGER - 1
		WHERE cod_param = 381;
		
		RETURN vCodRet, cEstado;
	END
END PROCEDURE
DOCUMENT
'FECHA: 18/12/2015',
'RQI 64 112 DEPURACION DE TELEFONOS',
'DESCRIPCION: PROCEDIMIENTO PARA DEPURAR LOS NUMEROS DE TELEFONOS DUPLICADOS',
'TRANSACCIONNAL CADA N REGISTROS, SIN TEMPORALES: 6',
'---------------------------------------------------------------------------',
'FECHA: 18/02/2016',
'DESCRIPCION: SE MODIFICA PARA IMPLEMENTAR EL USO TABLA TEMPORAL ESTATICA PARA CONTROLAR LOS REGISTROS QUE SERAN PROCESADOS POR CADA INSTANCIA EJECUTADA',
'TRANSACCIONNAL CADA N REGISTROS, UNA TEMPORAL',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_actualizastatususuario_bpi(pEmpresa char(3), pIdUsuario char(20), pUsuario char(50), pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
   returning char(5);
   
   
   
   --Modificó: Javier A. Chávez T.
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Solicito: Mauricio León
   --Fecha: 05-03-09
   -- Se agregó filtro por estatus para definir si se envia id de usuario o número de cliente en parámetro pIdUsuario
   -- 12/02/2016
   -- Bibiana Gaxiola Verdugo

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE iStatus integer;
   DEFINE cNumcte char(9);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";
   LET iStatus = "0";
   LET cNumcte = "";

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

    --SET DEBUG FILE TO '/home/informix/bibiana/sp_actualizastatususuario_bpi.out';
    --TRACE ON;
		
    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

    IF pIdUsuario <> 0 THEN
	
		IF pStatus = 40 THEN
			  
			SELECT bpi.numcte INTO cNumcte
			FROM bdinteg:si_bpiusuarios bpi INNER JOIN bdibpi:bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;
		
		ELSE 
			SELECT bpi.numcte INTO cNumcte
			FROM bdinteg:si_bpiusuarios bpi INNER JOIN bdibpi:bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE empresa = pEmpresa AND numcte = pIdUsuario;
		
		END IF;
					
	ELSE
		LET cod_ret = '003';
	END IF;

    IF cNumcte <> "" THEN

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumcte ) THEN
		
			SELECT id_status INTO iStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and numcte = cNumcte;
							
				INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (cNumcte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);
				
				UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND numcte = cNumcte;
				
				LET cod_ret = '000';  -- Usuario bloqueado

        ELSE

            LET cod_ret = '001';  -- No existe el Cliente

        END IF ;

    ELSE

        LET cod_ret = '002';  -- No existe el Usuario

    END IF ;

    RETURN cod_ret;

END

END PROCEDURE ;