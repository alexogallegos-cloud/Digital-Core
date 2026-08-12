CREATE PROCEDURE "informix".sp_domi_pagocreditos(	p_tpo_pro CHAR(1),p_numcte CHAR(20),p_cuenta CHAR(20),
										p_rfc CHAR(18),p_cve_domi CHAR(1), p_imp_fijo MONEY(16,2), p_tpo_cta_car CHAR(2),
										p_cta_car CHAR(20), p_cve_banco CHAR(3), p_imp_max MONEY(16,2),p_cve_canal CHAR(2),
										num_rechazos integer,cve_sucursal CHAR(4),user_estatus CHAR(8))
		returning char(5), CHAR (100);

			--ElaborÃ³: Alejandro Osuna Iza
			--Actividad: Realiza la validacion correspondiente de datos e inserta o realiza los cambios pedidos 
			--Solicito: Jorge NuÃ±ez
			--Fecha: 08 de febrero  de 2010
		DEFINE c_CodRet 		CHAR(5);
		DEFINE c_Mensaje 		CHAR(100);
		DEFINE m_Monto_max		MONEY(16,2);
		DEFINE v_cRespSP 		CHAR(5);
		DEFINE v_LogTar			Integer;
		DEFINE v_iCodReSP		 INTEGER;
		DEFINE v_iDigVeSP 		INTEGER;
		DEFINE	sql_err 		INTEGER;
		DEFIne v_banCuenta		INTEGER;
		DEFINE v_binCuenta      INTEGER;
		
		BEGIN
			
			on exception set sql_err
			    if sql_err <> 0 then
					let c_CodRet = sql_err;
					LET c_Mensaje = "Error no controlado";
					return c_CodRet,c_Mensaje;
			    end if;
			end exception;
			
			LET c_CodRet 			= "";
			LET c_Mensaje 			= "";
			LET m_Monto_max 		= 0.0;
			LET v_cRespSP			= "";
			LET v_LogTar			= 0;
			LET v_iCodReSP			= 0;
			LET v_iDigVeSP			= 0;
			LET v_binCuenta         = 0;
			
			
			--SET DEBUG FILE TO "/informix/EGC/sp_domi_PagoCreditos.out";
			--TRACE ON;
			
			--se realizan las validaciones correspondientes
			IF (p_tpo_pro = "") OR (p_tpo_pro is null)  THEN
				LET c_CodRet = '00001';
				LET c_Mensaje = "Tipo de Proceso es blanco o nulo";
				return c_CodRet,c_Mensaje;
			END IF;
			IF (p_numcte = "") OR (p_numcte is null)  THEN
				LET c_CodRet = '00002';
				LET c_Mensaje = "NÃºmero de Cliente es blanco o nulo";
				return c_CodRet,c_Mensaje;
			END IF;
			IF (p_cuenta = "") OR (p_cuenta is null)  THEN
				LET c_CodRet = '00004';
				LET c_Mensaje = "NÃºmero de Tarjeta es blanco o nulo";
				return c_CodRet,c_Mensaje;
			END IF;
			IF (p_cve_domi = "") OR (p_cve_domi is null)  THEN
				LET c_CodRet = '00005';
				LET c_Mensaje = "Tipo de Pago Domiciliado es blanco o nulo";
				return c_CodRet,c_Mensaje;
			END IF;
			IF NOT EXISTS(select descripcion from bdidomi:dom_cat_imptc where cve_domiciliar_tc = p_cve_domi) THEN
				LET c_CodRet = '00013';
				LET c_Mensaje = "Tipo de Pago Domiciliado InvÃ¡lido";
				return c_CodRet,c_Mensaje;
			END IF;
			IF (p_cve_banco = "") OR (p_cve_banco is null)  THEN
				LET c_CodRet = '00007';
				LET c_Mensaje = "Clave de Banco es blanco o nulo";
				return c_CodRet,c_Mensaje;
			END IF;
			
			IF (p_tpo_cta_car = "") OR (p_tpo_cta_car is null)  THEN
				LET c_CodRet = '00006';
				LET c_Mensaje = "Tipo de Cuenta es blanco o nulo";
				return c_CodRet,c_Mensaje;
			ELSE
				IF NOT EXISTS (SELECT descripcion FROM bdidomi:dom_tipo_cta WHERE tipo_cta = p_tpo_cta_car) THEN
					LET c_CodRet = '00020';
					LET c_Mensaje = "Tipo de Cuenta  Cargo es InvÃ¡lido";
					return c_CodRet,c_Mensaje;
				END IF;	
			END IF;
			If p_cta_car = p_cuenta THEN
					LET c_CodRet = '00026';
					LET c_Mensaje = "Las cuentas no deben de ser iguales";
					return c_CodRet,c_Mensaje;
			END IF;
			IF (p_cta_car = "") OR (p_cta_car is null)  THEN
				LET c_CodRet = '00018';
				LET c_Mensaje = "Cuenta Cargo es blanco o nulo";
				return c_CodRet,c_Mensaje;
			ELSE
				execute PROCEDURE bdidomi:sp_valida_cadena(p_cta_car,'N') INTO v_cRespSP;
				IF v_cRespSP <> "00000" THEN
					LET c_CodRet = '00019';
					LET c_Mensaje = "Cuenta Cargo es InvÃ¡lida";
					return c_CodRet,c_Mensaje;
				END IF;
				IF (p_tpo_cta_car = '03')  or (p_tpo_cta_car = '05')THEN
					LET v_LogTar = LENGTH(p_cta_car);
					IF v_LogTar <> 16 THEN
						LET c_CodRet = '00021';
						LET c_Mensaje = "Longitud de la cuenta cargo InvÃ¡lida";
						return c_CodRet,c_Mensaje;
					END IF;
					LET v_banCuenta = Substr(p_cta_car,1,6);
					
					SELECT COUNT(*) INTO v_binCuenta FROM bdicheq:sc_bines WHERE bin = v_banCuenta AND cve_banco = p_cve_banco;
					
					IF v_binCuenta <= 0 THEN
						LET c_CodRet = '00023';
						LET c_Mensaje = "Numero de Tarjeta de Debito es diferente al Banco";
						return c_CodRet,c_Mensaje;
					END IF;
					
				ELIF p_tpo_cta_car = '40' THEN
					LET v_LogTar = LENGTH(p_cta_car);
					IF v_LogTar <> 18 THEN
						LET c_CodRet = '00022';
						LET c_Mensaje = "Longitud de la cuenta cargo InvÃ¡lida(CLABE)";
						return c_CodRet,c_Mensaje;
					ELSE
						LET v_banCuenta = Substr(p_cta_car,1,3);
						IF v_banCuenta <> p_cve_banco THEN
							LET c_CodRet = '00023';
							LET c_Mensaje = "Clave de Banco es diferente a la cuenta";
							return c_CodRet,c_Mensaje;
						ELSE
							EXECUTE PROCEDURE bdispei:sp_validadv(p_cta_car) INTO v_iCodReSP, v_iDigVeSP;
							IF  (v_iCodReSP = 0)  AND (v_iDigVeSP = 1) THEN
							ELSE
								LET c_CodRet = '00024';
								LET c_Mensaje = "Digito Verificar InvÃ¡lido";
								return c_CodRet,c_Mensaje;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
			
			SELECT TRIM(valor)::money(16,2) INTO m_Monto_max FROM bdidomi:"informix".dom_parametros WHERE cod_param = '10';
			IF (p_imp_fijo = "") OR (p_imp_fijo is null)  THEN
				LET c_CodRet = '00008';
				LET c_Mensaje = "Monto Fijo es blanco o nulo";
				return c_CodRet,c_Mensaje;
			ELSE
				IF p_imp_fijo < 0 THEN
					LET c_CodRet = '00015';
					LET c_Mensaje = "Monto Fijo debe ser igual o  mayor que 0";
					return c_CodRet,c_Mensaje;
				END IF;
				IF m_Monto_max < p_imp_fijo THEN
					LET c_CodRet = '00016';
					LET c_Mensaje = "Monto Fijo debe ser menor que el mÃ¡ximo permitido";
					return c_CodRet,c_Mensaje;
				END IF;
			END IF;
			IF p_cve_domi = "F" THEN
				IF NOT p_imp_fijo > 0  THEN
					LET c_CodRet = '00014';
					LET c_Mensaje = "Monto Fijo debe ser mayor que 0";
					return c_CodRet,c_Mensaje;
				END IF;
			END IF;
			IF (p_imp_max = "") OR (p_imp_max is null)  THEN
				LET c_CodRet = '00009';
				LET c_Mensaje = "Monto MÃ¡ximo Autorizado es blanco o nulo";
				return c_CodRet,c_Mensaje;
			ELSE
				IF p_imp_max < 0 THEN
					LET c_CodRet = '00016';
					LET c_Mensaje = "Monto MÃ¡ximo debe ser igual o  mayor que 0";
					return c_CodRet,c_Mensaje;
				END IF;	
				IF m_Monto_max < p_imp_max THEN
					LET c_CodRet = '00017';
					LET c_Mensaje = "Monto MÃ¡ximo debe ser menor que el mÃ¡ximo permitido";
					return c_CodRet,c_Mensaje;
				END IF;
			END IF;
			IF (p_rfc = "") OR (p_rfc is null)  THEN
				LET c_CodRet = '00010';
				LET c_Mensaje = "RFC es blanco o nulo";
				return c_CodRet,c_Mensaje;
			END IF;
			IF  (p_tpo_pro = "I") OR (p_tpo_pro = "U") THEN
			ELSE
				LET c_CodRet = '00011';
				LET c_Mensaje = "Tipo de Proceso InvÃ¡lido";
				return c_CodRet,c_Mensaje;
			END IF;
			
			---Insercion
			IF p_tpo_pro = "I"THEN
				IF EXISTS(SELECT cve_canal FROM  bdidomi:"informix".dom_autorizaciones
							WHERE cuenta = p_cuenta AND rfc = p_rfc) THEN
					LET c_CodRet = '00012';
					LET c_Mensaje = "Existe domicilizaciÃ³n con los datos proporcionados";
					return c_CodRet,c_Mensaje;
				ELSE
					insert into bdidomi:"informix".dom_autorizaciones (cuenta, 
															rfc, 
															num_cte, 
															cve_canal, 
															imp_maximo, 
															num_rechazos, 
															cve_sucursal, 
															cve_estatus, 
															fecha_estatus, 
															user_estatus, 
															cve_causa, 
															user_insert, 
															fecha_insert, 
															cve_domiciliar_tc, 
															imp_fijo_tc, 
															tipo_cuenta_cargo, 
															cuenta_cargo, 
															cve_banco_cargo) 
					values (p_cuenta, --cuenta
							p_rfc, --rfc
							p_numcte, --num_cte
							p_cve_canal, 
							p_imp_max, --imp_maximo
							num_rechazos,
							cve_sucursal, --cve_sucursal--------FALTA
							'01', --cve_estatus--------FALTA
							CURRENT, --fecha_estatus
							user_estatus,-- user_estatus----FALTA
							'00', --cve_causa-----FALTA
							user_estatus, --user_insert---FALTA
							CURRENT, --fecha_insert
							p_cve_domi, --cve_domiciliar_tc
							p_imp_fijo, --imp_fijo_tc
							p_tpo_cta_car, --tipo_cuenta_cargo
							p_cta_car, --cuenta_cargo
							p_cve_banco);
				END IF;
			END IF;
			--UPDATE
			
			IF p_tpo_pro = "U"THEN
				IF NOT EXISTS(SELECT cve_canal FROM  bdidomi:"informix".dom_autorizaciones 
							WHERE cuenta = p_cuenta AND rfc = p_rfc  ) THEN
						LET c_CodRet = '00025';
						LET c_Mensaje = "No existe domicilizaciÃ³n con los datos proporcionados";
						return c_CodRet,c_Mensaje;
					ELSE 
					
						UPDATE bdidomi:"informix".dom_autorizaciones SET cve_domiciliar_tc = p_cve_domi, tipo_cuenta_cargo = p_tpo_cta_car, cve_banco_cargo = p_cve_banco,
																imp_fijo_tc = p_imp_fijo,cuenta_cargo = p_cta_car, imp_maximo = p_imp_max
						WHERE cuenta = p_cuenta AND rfc = p_rfc AND num_cte =  p_numcte;										
				END IF;
			END IF;
			LET c_CodRet = '00000';
			LET c_Mensaje = "Proceso realizado Satisfactoriamente";
			return c_CodRet,c_Mensaje;
		END;
									
END PROCEDURE;