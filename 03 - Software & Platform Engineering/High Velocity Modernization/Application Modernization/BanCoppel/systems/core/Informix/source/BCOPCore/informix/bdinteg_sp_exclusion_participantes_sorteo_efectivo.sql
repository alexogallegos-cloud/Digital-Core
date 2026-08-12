CREATE PROCEDURE "informix".sp_exclusion_participantes_sorteo_efectivo(pNumero char(1))
RETURNING CHAR(5) AS cCod_Ret;
-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE cMes_Mes_Anterior			CHAR(2);
DEFINE cAnio_Mes_Anterior			CHAR(4);
DEFINE vCadena_req					CHAR(334);


DEFINE dFecha_Hoy					DATE;
DEFINE dFecha_Max_Procesada			DATE;
DEFINE vNum_cte						CHAR(20);
DEFINE vCuenta						CHAR(20);
DEFINE vStatus_cred					CHAR(2);
DEFINE vNum_producto				CHAR(2);
DEFINE vContadorCuenta				INTEGER;
DEFINE vcontador					INTEGER;
DEFINE v_cliente_val					CHAR(20);
DEFINE v_cliente_inicial            CHAR(20);
DEFINE v_cliente_final              CHAR(20);
DEFINE v_cte_exclusion					CHAR(20);
DEFINE v_sin_te 						INTEGER;
DEFINE v_sin_cel						INTEGER;
DEFINE v_tel_casa			CHAR(12);
DEFINE v_celular			CHAR(12);
DEFINE v_id					INTEGER;
DEFINE v_correo_elec		CHAR(40);
--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET iSqlErr						= 0;
LET cDia						= '';
LET cMes						= '';
LET cAnio						= '';
LET cMes_Mes_Anterior			= '';
LET cAnio_Mes_Anterior			= '';
LET vCadena_req					= '';
LET dFecha_Max_Procesada		= MDY('01','01','1900');
LET vNum_cte					= '';
LET vCuenta						= '';
LET vStatus_cred				= '';
LET vNum_producto				= '';
LET vContadorCuenta				= 0;
LET vcontador					= 0;
LET v_cliente_val				= '';
LET v_cliente_inicial           = '';
LET v_cliente_final             = '';
LET v_cte_exclusion				= '';
LET v_sin_te 					= 0;
LET v_sin_cel					= 0;
LET v_tel_casa					= '';
LET v_celular					= '';
LET v_id						= 0;
LET v_correo_elec				= '';

	 --SET DEBUG FILE TO  '/ifxsif01/sor/sp_exclu_sorteo_efectivo.out';
	 --TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				/*insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				values (cCodRet,vCadena_req,sysdate);*/
				rollback WORK;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
--Consulta que regresa la fecha del dia actual
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".si_fechas
		WHERE empresa = "001";
		
--Se inicializa la variable dFecha_Max_Procesada con el valor dFecha_Hoy
		--LET dFecha_Max_Procesada = dFecha_Hoy;
		
--Se asignan los valores a las variables cDia,cMes,cAnio, vMesActualCadena

		LET dFecha_Max_Procesada = EXTEND(dFecha_Hoy, YEAR TO DAY) - 1 UNITS MONTH;

		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0'); 
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');
		
		
		SELECT cliente_inicial, cliente_final, cte_exclucion
			INTO v_cliente_inicial, v_cliente_final, v_cte_exclusion
		FROM "informix".si_sorteo_hilos WHERE numero_proceso = pNumero;

		
		IF v_cte_exclusion  > '0' THEN
			LET v_cliente_inicial = v_cte_exclusion + 1;
		END IF;
--Se verificara que los clientes cumplan con las reglas para participar

		BEGIN WORK;

			FOREACH WITH HOLD

				SELECT DISTINCT num_cliente
					INTO vNum_cte
				FROM "informix".si_sorteos_cuentas_participantes where num_cliente BETWEEN v_cliente_inicial and v_cliente_final and mes = cMes --limit 150

				--Productos relacionados a tarjetas de credito

				SELECT distinct(numcte)
				INTO v_cliente_val
				FROM bdicred:"informix".sd_maecred
				WHERE numcte = vNum_cte and status_cred in('E2','E3','CV'); 

				IF v_cliente_val IS NULL OR v_cliente_val = '' THEN

					SELECT distinct(numcte)
						INTO v_cliente_val
					FROM bdicred:"informix".sd_maecredcrd WHERE numcte = vNum_cte AND status_cred in('E2','E3','CV'); 
					
					IF v_cliente_val IS NULL OR v_cliente_val = '' THEN
						
						SELECT distinct(numcte)
							INTO v_cliente_val
						FROM bdicred:"informix".sd_maecredcrd
						WHERE numcte = vNum_cte AND num_producto = '6011'; 
					
						IF v_cliente_val IS NULL OR v_cliente_val = '' THEN
						
							SELECT count(numcte)
								INTO vContadorCuenta
							FROM bdinteg:"informix".si_autorizacion_privacidad
							WHERE numcte = vNum_cte AND respuesta = 1;
			
							IF vContadorCuenta = 0 THEN
	
								DELETE FROM "informix".si_sorteos_cuentas_participantes	WHERE num_cliente = vNum_cte and mes = cMes;
								--INSERT INTO  si_cliente_eli VALUES(vNum_cte,'AVISO');
							ELSE
							
								SELECT count(numcte)
									INTO vContadorCuenta
								FROM bdinteg:"informix".si_empleado_cliente_coppel 	WHERE numcte = vNum_cte;
								
								IF vContadorCuenta > 0 THEN
	
									DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
									--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'EMPLEADO');
								ELSE
								
									SELECT telefono
										into v_tel_casa
									FROM bdinteg:si_telefonos_actual  where numcte = vNum_cte and tipo_tel = '1' and status_tel = 'A' limit 1;
				
									SELECT telefono
										into v_celular
									FROM bdinteg:si_telefonos_actual  where numcte = vNum_cte and tipo_tel = '2' and status_tel = 'A' limit 1;
                
									EXECUTE PROCEDURE "informix".sp_sorteo_caracteres(v_celular) INTO v_celular;
									EXECUTE PROCEDURE "informix".sp_sorteo_caracteres(v_tel_casa) INTO v_tel_casa;
									
									IF v_tel_casa IS NULL OR v_tel_casa = '' THEN
										LET v_sin_te = 1;
									ELSE 
										LET v_sin_te = 0;
									END IF;
									
									IF v_celular IS NULL OR v_celular = '' THEN
										LET v_sin_cel = 1;
									else 
										LET v_sin_cel = 0;
									END IF;
									
									IF v_sin_cel = 1 AND v_sin_te = 1 THEN
										
										DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
										--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'SIN TELEFONO');
									
									ELSE
									
										SELECT correo_elec INTO v_correo_elec FROM "informix".si_correos WHERE  numcte   =  vNum_cte and tipo_correo   = '1' and status_correo = 'A' limit 1;
										
										LET v_correo_elec =  TRIM(v_correo_elec);
										
										IF v_correo_elec IS NULL OR v_correo_elec = '' THEN
										
										ELSE
										
											SELECT  count(*) INTO v_id FROM "informix".si_sorteo_reus WHERE correo_particular = v_correo_elec;
										
											IF v_id > 0 THEN
													DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
													--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'CORREO REUS');
											ELSE
												SELECT  count(*) INTO v_id FROM "informix".si_sorteo_reus WHERE telefono_movil = v_celular;
												
												IF v_id > 0 THEN
													DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
													--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'CEL REUS');
												ELSE
												
													SELECT COUNT(*) INTO v_id FROM "informix".si_sorteo_reus WHERE telefono_fijo = v_tel_casa;
													
													IF v_id > 0 THEN
															DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
															--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'CASA REUS');
													
													END IF;								
												END IF;
											
											END IF;
										END IF;
										
									END IF;
								
								END IF;
	
							END IF;
						ELSE
							DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
							--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'RESTRUCTURA');
						END IF;

					ELSE				
						DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
						--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'Prestamo');
					END IF;
				ELSE				
					DELETE FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente = vNum_cte and mes = cMes;
					--INSERT INTO  si_cliente_eli VALUES(vNum_cte, 'tar cred');
				END IF;

			
				LET vcontador = vcontador + 1;
	
				IF vcontador = 1000 THEN
					COMMIT WORK;
					UPDATE "informix".si_sorteo_hilos SET cte_exclucion = vNum_cte where numero_proceso = pNumero;
					LET vcontador = 0;
					BEGIN WORK;
				END IF;
		
			END FOREACH;
		COMMIT WORK;		
			UPDATE "informix".si_sorteo_hilos SET cte_exclucion = '0' where numero_proceso = pNumero;
		RETURN cCodRet;
	
	END;
END PROCEDURE;