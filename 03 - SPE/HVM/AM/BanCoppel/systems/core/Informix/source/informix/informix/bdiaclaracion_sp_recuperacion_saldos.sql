CREATE PROCEDURE "informix".sp_recuperacion_saldos()
RETURNING CHAR(7) AS CODIGO
--V. 2.0.3
DEFINE v_folio CHAR(24);
DEFINE v_producto SMALLINT;
DEFINE v_credito SMALLINT;
--VARIABLES DE REGRESO DE SP DE RECUPERACION
DEFINE s_CodRet CHAR(6);
DEFINE v_mensaje CHAR(600);
DEFINE s_Mensaje CHAR(100);
DEFINE s_Cc SMALLINT;
DEFINE s_AfectacionC MONEY;
DEFINE s_CodleyendaC CHAR(3);
DEFINE s_Ci SMALLINT;
DEFINE s_AfectacionI MONEY;
DEFINE s_CodleyendaI CHAR(3);
DEFINE s_Ca SMALLINT;
DEFINE s_AfectacionA MONEY;
DEFINE s_CodleyendaA CHAR(3);
DEFINE s_Cin SMALLINT;
DEFINE s_AfectacionIn MONEY;
DEFINE s_CodleyendaIn CHAR(3);
--Variables para la bitacora
DEFINE v_descripcion LVARCHAR(625); 
DEFINE v_fechahora DATETIME YEAR TO FRACTION(5);
DEFINE v_folio_csuac CHAR(24);
DEFINE v_fky_accion INTEGER;
DEFINE v_fky_aclaracion INTEGER;
DEFINE v_fky_area INTEGER;
DEFINE v_fky_estatus_aclaracion INTEGER;
DEFINE v_estatus_corp_analisis INTEGER;
DEFINE v_estatus_corp_general INTEGER;
DEFINE v_fky_usuario INTEGER;
--Variable de retorno
DEFINE iSqlErr INTEGER;
DEFINE v_codigo_ret CHAR(7);

--535
DEFINE wBegin CHAR(1);


LET v_mensaje = 'ERROR GENERAL';
LET v_folio = '';
LET v_credito = 1;
--VARIABLES DE REGRESO DE SP DE RECUPERACION
LET s_CodRet = '';
LET v_mensaje = '';
LET s_Mensaje = '';
LET s_Cc = 0;
LET s_AfectacionC = 0;
LET s_CodleyendaC = '';
LET s_Ci = 0;
LET s_AfectacionI = 0;
LET s_CodleyendaI = '';
LET s_Ca = 0;
LET s_AfectacionA = 0;
LET s_CodleyendaA = '';
LET s_Cin = 0;
LET s_AfectacionIn = 0;
LET s_CodleyendaIn = '';

--Variables para la bitacora
LET v_descripcion = 'ERROR'; 
LET v_fechahora = CURRENT;
LET v_folio_csuac = 'ERROR';
LET v_fky_accion = 0;
LET v_fky_aclaracion = 0;
LET v_fky_area = 0;
LET v_fky_estatus_aclaracion = 0;
LET v_estatus_corp_analisis = 0;
LET v_estatus_corp_general = 0;
LET v_fky_usuario = 0;

--Codigo de retorno
LET v_codigo_ret = '';


--535
LET wBegin = 'N';


BEGIN

		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET v_codigo_ret = iSqlErr;
				RETURN v_codigo_ret;
			END IF;
		END EXCEPTION;
	
		ON EXCEPTION SET iSqlErr
			  LET v_codigo_ret = iSqlErr;
			  --ROLLBACK WORK;
			  IF (wBegin = "S") THEN
				 BEGIN WORK;
			  END IF;

			  RETURN v_codigo_ret;
		   END EXCEPTION;

		   ON EXCEPTION IN (-535)
			  LET wBegin = "S";
			  --ROLLBACK WORK;
			  COMMIT WORK;
				SET ISOLATION TO DIRTY READ;

			  --BEGIN WORK;
		   END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;   
	
--	BEGIN WORK;

    FOREACH v_folio WITH HOLD FOR
            SELECT DISTINCT (rec.FOLIO_CSUAC), tp.tipo_producto
            INTO v_folio, v_producto
            FROM ACL_RECUPERACION_SALDOS rec
            LEFT JOIN acl_aclaracion acl    ON acl.pky_aclaracion=rec.fky_aclaracion
            LEFT JOIN acl_producto producto ON producto.pky_producto=acl.fky_producto
            LEFT JOIN acl_tipo_producto tp  ON tp.pky_tipo_producto=producto.fky_tipo_producto 
            WHERE CRON_ACTIVO='1'
			
--		SET DEBUG FILE TO "/respaldos/importanew/htm/pba/bdiaclaracion/RECSALDOS"||v_folio||".out";
	---		SET DEBUG FILE TO "/respaldos/importanew/htm/pba/bdiaclaracion/sp_recuperacion_saldos.trc";
--			TRACE ON;

                IF (v_producto == 1) THEN
                    --CREDITO
                        CALL "informix".sp_upd_credrecuperacion(v_folio) RETURNING s_CodRet, 
						                                                                s_Mensaje, 
																						s_Cc, 
																						s_AfectacionC, 
																						s_CodleyendaC,
                                                                                        s_Ci,
																						s_AfectacionI, 
																						s_CodleyendaI,
                                                                                        s_Ca, 
																						s_AfectacionA, 
																						s_CodleyendaA,
                                                                                        s_Cin, 
																						s_AfectacionIn, 
																						s_CodleyendaIn;

						LET v_codigo_ret = s_CodRet;


							IF (s_CodRet == 'E-01') THEN
								LET v_mensaje = 'El registro es irrecuperable, por vencimiento de fecha.';
								--Variables para la bitacora
								LET v_descripcion = 'El registro es irrecuperable, por vencimiento de fecha...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;						
							IF (s_CodRet == 'E-02') THEN
								LET v_mensaje = 'El cliente no cuenta con saldo suficiente.';
								--Variables para la bitacora
								LET v_descripcion = 'El cliente no cuenta con saldo suficiente...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;
							IF (s_CodRet == '208') THEN
								LET v_mensaje = 'No se realizó la afectación de comision/iva. ';
								--Variables para la bitacora
								LET v_descripcion = 'No se realizó la afectación de comision/iva...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;							
							IF (s_CodRet == '000' OR s_CodRet == '000006' OR s_CodRet == '000000') THEN	
								IF (s_Cc == 1) THEN
									IF (s_CodleyendaC == 'CTC') THEN
										LET v_mensaje = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaC == 'CPC') THEN	
										LET v_mensaje = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;									
								END IF;
								
								IF (s_Ci == 1) THEN
									IF (s_CodleyendaI == 'CTI') THEN
										LET v_mensaje = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF(s_CodleyendaI == 'CPI') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	

									END IF;
								END IF;
								
								IF (s_Ca == 1) THEN
									IF (s_CodleyendaA == 'CTA') THEN
										LET v_mensaje = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaA == 'CPA') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	
										
									END IF;
								END IF;
								
							ELSE
							
							IF (s_CodRet <> 'E-02' AND s_CodRet <> 'E-01') THEN
								
								--Insertar a acl_bitacora_error_rec_saldo para errores
								LET v_fechahora = current; 
								INSERT INTO "informix".acl_bitacora_error_rec_saldo (
								codigo,
								folio_csuac,
								fecha
								)
								VALUES (
								s_CodRet,
								v_folio,
								v_fechahora
								);
								
							END IF;
								
							END IF;

                ELSE
                    --LET v_mensaje = 'ERROR CON PRODUCTO O PRODUCTO NULL.';
                END IF
				--DEBITO
                IF (v_producto == 2) THEN
                        CALL "informix".sp_upd_debrecuperacion(v_folio) RETURNING s_CodRet, 
						                                                                s_Mensaje, 
																						s_Cc, 
																						s_AfectacionC, 
																						s_CodleyendaC,
                                                                                        s_Ci,
																						s_AfectacionI, 
																						s_CodleyendaI,
                                                                                        s_Ca, 
																						s_AfectacionA, 
																						s_CodleyendaA,
                                                                                        s_Cin, 
																						s_AfectacionIn, 
																						s_CodleyendaIn;
						
						LET v_codigo_ret = s_CodRet;

							
							IF (s_CodRet == 'E-01') THEN
								LET v_mensaje = 'El registro es irrecuperable, por vencimiento de fecha.';
								--Variables para la bitacora
								LET v_descripcion = 'El registro es irrecuperable, por vencimiento de fecha...'; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;								
							IF (s_CodRet == 'E-02') THEN
								LET v_mensaje = 'El cliente no cuenta con saldo suficiente.';
								--Variables para la bitacora
								LET v_descripcion = 'El cliente no cuenta con saldo suficiente...'||' Folio: '||v_folio; 
								LET v_fechahora = CURRENT;
								LET v_folio_csuac = v_folio;
								LET v_fky_accion = null;
								LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
								LET v_fky_area = null;
								LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
								LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
								LET v_fky_usuario = 0;
							END IF;
							IF (s_CodRet == '000') THEN	
								IF (s_Cc == 1) THEN
									IF (s_CodleyendaC == 'CTC') THEN
										LET v_mensaje = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);	
									END IF;
									IF (s_CodleyendaC == 'CPC') THEN	
										LET v_mensaje = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de comisión por aclaración improcedente por: '||s_AfectacionC||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);		
									END IF;									
								END IF;
								
								IF (s_Ci == 1) THEN
									IF (s_CodleyendaI == 'CTI') THEN
										LET v_mensaje = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF(s_CodleyendaI == 'CPI') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de IVA de comisión por aclaración improcedente por: '||s_AfectacionI||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
								END IF;
								
								IF (s_Ca == 1) THEN
									IF (s_CodleyendaA == 'CTA') THEN
										LET v_mensaje = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo total de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
									IF (s_CodleyendaA == 'CPA') THEN
										LET v_mensaje = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA;
										--Variables para la bitacora
										LET v_descripcion = 'Cargo parcial de recuperación de abono temporal por: '||s_AfectacionA||' Folio: '||v_folio;
										LET v_fechahora = CURRENT;
										LET v_folio_csuac = v_folio;
										LET v_fky_accion = null;
										LET v_fky_aclaracion = (SELECT pky_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio); 
										LET v_fky_area = null;
										LET v_fky_estatus_aclaracion = (SELECT fky_estatus_aclaracion FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_analisis = (SELECT fky_estatus_corp_analisis FROM acl_aclaracion WHERE folio_csuac = v_folio AND 						      pky_aclaracion = v_fky_aclaracion);
										LET v_estatus_corp_general = (SELECT fky_estatus_corp_general FROM acl_aclaracion WHERE folio_csuac = v_folio AND 								pky_aclaracion = v_fky_aclaracion); 
										LET v_fky_usuario = 0;
										--Inserta a bitacora
										INSERT INTO acl_entrada_bitacora (pky_entrada_bitacora,descripcion,fechahora,folio_csuac,fky_accion,fky_aclaracion,fky_area,fky_estatus_aclaracion,fky_estatus_corp_analisis,fky_estatus_corp_general,fky_usuario)
										VALUES (
										"informix".ENTRADA_BITACORA_SEQ.NEXTVAL,
										v_descripcion,
										v_fechahora,
										v_folio_csuac,
										v_fky_accion,
										v_fky_aclaracion,
										v_fky_area,
										v_fky_estatus_aclaracion,
										v_estatus_corp_analisis,
										v_estatus_corp_general,
										v_fky_usuario);
										
									END IF;
								END IF;
								
							ELSE
								IF (s_CodRet <> 'E-02' AND s_CodRet <> 'E-01') THEN
									
									--Insertar a acl_bitacora_error_rec_saldo para errores
									LET v_fechahora = current; 
									INSERT INTO "informix".acl_bitacora_error_rec_saldo (
									codigo,
									folio_csuac,
									fecha
									)
									VALUES (
									s_CodRet,
									v_folio,
									v_fechahora
									);
									
								END IF;
							END IF;

                ELSE
                    --LET v_mensaje = 'ERROR CON PRODUCTO O PRODUCTO NULL.';
                END IF	
--           COMMIT;
    END FOREACH
	LET v_codigo_ret = '000000';
	RETURN v_codigo_ret;
END;
END PROCEDURE;