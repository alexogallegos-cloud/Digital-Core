CREATE PROCEDURE "informix".sp_ics_personas(p_num_ejecucion INTEGER) 
		returning 
			CHAR(5) 		AS 		v_cod_ret;
			
	
			
	---Variables de retorno
	DEFINE v_cod_ret 						  CHAR(5);

	----Variables de interfaz
	DEFINE v_customer_id            		    VARCHAR(10); 
	DEFINE v_identity_code     		          	VARCHAR(13);
	DEFINE v_account_number						VARCHAR(20);
	DEFINE v_seq							    INTEGER;
	DEFINE v_first_surname		                VARCHAR(20);
	DEFINE v_first_name                         VARCHAR(20);
	DEFINE v_sex                                CHAR(1);
	DEFINE v_civil_estatus                      CHAR(1);
	DEFINE v_address_type1						VARCHAR(15);
	DEFINE v_zone1                              VARCHAR(60);
	DEFINE v_city1                              VARCHAR(60);
	DEFINE v_use_this_1                         CHAR(1);
	DEFINE v_address_type2                      VARCHAR(15);
	DEFINE v_zone2                              VARCHAR(60);
	DEFINE v_city2                              VARCHAR(60);
	DEFINE v_use_this_2                         CHAR(1);
	DEFINE v_telephone_type1                    VARCHAR(10);
	DEFINE v_addr_tel_type1                     VARCHAR(15);
	DEFINE v_telephone_type2                    VARCHAR(10);
	DEFINE v_addr_tel_type2                     VARCHAR(15);
	DEFINE v_income_payment_type                CHAR(1);
	DEFINE v_income_payment_day                 VARCHAR(10);
	DEFINE v_reviewed                           CHAR(1);
	DEFINE v_company                            VARCHAR(50);
	DEFINE v_second_surname                     VARCHAR(20);
	DEFINE v_middle_name                        VARCHAR(20);
	DEFINE v_birth_date                         DATE;
	DEFINE v_birth_date_char					CHAR(10);
	DEFINE v_addres_number1                     VARCHAR(200);
	DEFINE v_province1                          VARCHAR(60);
	DEFINE v_country1                           VARCHAR(30);
	DEFINE v_po_box1                            VARCHAR(30);
	DEFINE v_strata1                            VARCHAR(2);
	DEFINE v_addres_number2                     VARCHAR(200);
	DEFINE v_province2                          VARCHAR(60);
	DEFINE v_country2                           VARCHAR(30);
	DEFINE v_po_box2                            VARCHAR(30);
	DEFINE v_strata2                            VARCHAR(2);
	DEFINE v_area_code1                         CHAR(1);
	DEFINE v_telephone_number1                  VARCHAR(13);
	DEFINE v_extention1                         VARCHAR(5);
	DEFINE v_county_code1                       VARCHAR(5);
	DEFINE v_area_code2                         CHAR(1);
	DEFINE v_telephone_number2                  VARCHAR(13);
	DEFINE v_extention2                         VARCHAR(5);
	DEFINE v_county_code2                       VARCHAR(5);
	DEFINE v_ocupation                          VARCHAR(20);
	DEFINE v_profession                         VARCHAR(50);
	DEFINE v_income                             DECIMAL(15,2);
	DEFINE v_persons_in_charge                  VARCHAR(10);
	DEFINE v_work_timetable_start               DATE;
	DEFINE v_work_timetable_end                 DATE;
	DEFINE v_user_defined1                      VARCHAR(20);
	DEFINE v_return_id					        VARCHAR(80);
	DEFINE v_qualification                      VARCHAR(20);
	DEFINE v_common_id                          VARCHAR(20);
	DEFINE v_latitude1                          DECIMAL(9,6);
	DEFINE v_longitude1                         DECIMAL(9,6);
	DEFINE v_latitude2                          DECIMAL(9,6);
	DEFINE v_longitude2                         DECIMAL(9,6);
	DEFINE c_fecha_ejecucion				    DATE;
	DEFINE v_fecha_apertura                     DATE;
	DEFINE v_numero_interior					CHAR(10);
	DEFINE v_numero_exterior					CHAR(10);
	
	--Variable numero de cuenta
	DEFINE v_numero_credito					    VARCHAR(20);
	DEFINE aux_telefono_numero				    VARCHAR(13);
	
	--Variables para direcciones y telefonos de clientes con mas de 2 direcciones y telefonos
	DEFINE v_address_type3 					    VARCHAR(60);
	DEFINE v_use_this_3 					    CHAR(1);
	DEFINE v_zone3							    VARCHAR(60);
	DEFINE v_city3						        VARCHAR(60);
	DEFINE v_address_type4 					    VARCHAR(60);
	DEFINE v_use_this_4 					    CHAR(1);
	DEFINE v_zone4							    VARCHAR(60);
	DEFINE v_city4						        VARCHAR(60);
	DEFINE v_telephone_type3				    VARCHAR(15);
	DEFINE v_telephone_type4				    VARCHAR(15);
	DEFINE v_telephone_number3				    VARCHAR(13);
	DEFINE v_telephone_number4				    VARCHAR(13);
	DEFINE v_area_code3             		    CHAR(1);
	DEFINE v_extention3                         VARCHAR(5);
	DEFINE v_county_code3                       VARCHAR(5);
	DEFINE v_area_code4        				    CHAR(1);
	DEFINE v_extention4                         VARCHAR(5);
	DEFINE v_county_code4                       VARCHAR(5);
	DEFINE v_strata3                            VARCHAR(5);
	DEFINE v_addres_number3                     VARCHAR(200);
	DEFINE v_addres_number4                     VARCHAR(200);
	DEFINE v_province3                          VARCHAR(60);
	DEFINE v_country3                           VARCHAR(30);
	DEFINE v_po_box3                            VARCHAR(30);
	DEFINE v_province4                          VARCHAR(60);
	DEFINE v_country4                           VARCHAR(30);
	DEFINE v_po_box4                            VARCHAR(30);
	DEFINE v_strata4                            VARCHAR(10);
	DEFINE v_addr_tel_type3					    VARCHAR(60);
	DEFINE v_addr_tel_type4					    VARCHAR(60);
	--Variables generales                       
	DEFINE v_longitud_numero_telefono 	        INTEGER;
	DEFINE sql_err							    INTEGER;
	
	DEFINE iContador 							INTEGER;
	
	DEFINE horaActual							DATETIME YEAR TO FRACTION(5);
	DEFINE iContador1 							INTEGER;
	DEFINE v_valor_inicial 						varchar(20);	DEFINE v_valor_final						varchar(20);	DEFINE v_escolaridad      					char(5);
	DEFINE v_num_profeccion   					char(5);
	DEFINE v_pais_1           					char(5);
	DEFINE v_estado_1         					char(5);
	DEFINE v_num_calle_1      					INTEGER;
	DEFINE v_pais_2           					char(5);
	DEFINE v_estado_2         					char(5);
	DEFINE v_num_calle_2      					INTEGER;
	DEFINE v_pais_3           					char(5);
	DEFINE v_estado_3         					char(5);
	DEFINE v_num_calle_3      					INTEGER;
	DEFINE v_sec_ingreso	  					char(5);
	DEFINE v_transaccion				INTEGER;
	DEFINE v_proceso					CHAR(10);
	DEFINE c_fecha_actual				DATE;
	DEFINE c_fecha_actual_2				DATE;
	
	
	--Inicializamos variables
	LET v_cod_ret 					  = '00000';				
	LET v_customer_id            	  = 'BANCOPPEL';
	LET v_identity_code     		  = NULL;
	LET v_account_number			  = NULL;
	LET v_seq						  =  1;    
	LET v_first_surname		          = NULL;    
	LET v_first_name                  = NULL;    
	LET v_sex                         = NULL;    
	LET v_civil_estatus               = NULL;    
	LET v_address_type1               = NULL;    
	LET v_zone1                       = NULL;    
	LET v_city1                       = NULL;    
	LET v_use_this_1                  = NULL;    
	LET v_address_type2               = NULL;    
	LET v_zone2                       = NULL;    
	LET v_city2                       = NULL;    
	LET v_use_this_2                  = NULL;    
	LET v_telephone_type1             = NULL;    
	LET v_addr_tel_type1              = NULL;    
	LET v_telephone_type2             = NULL;    
	LET v_addr_tel_type2              = NULL;    
	LET v_income_payment_type         = NULL;    
	LET v_income_payment_day          = NULL;    
	LET v_reviewed                    = NULL;    
	LET v_company                     = NULL;    
	LET v_second_surname              = NULL;    
	LET v_middle_name                 = NULL;    
	LET v_birth_date                  = NULL; 
	LET v_birth_date_char			  = NULL;	 	
	LET v_addres_number1              = NULL;    
	LET v_province1                   = NULL;    
	LET v_country1                    = NULL;    
	LET v_po_box1                     = NULL;    
	LET v_strata1                     = '0';    
	LET v_addres_number2              = NULL;    
	LET v_province2                   = NULL;    
	LET v_country2                    = NULL;    
	LET v_po_box2                     = NULL;    
	LET v_strata2                     = '0';    
	LET v_area_code1                  = '0';    
	LET v_telephone_number1           = NULL;    
	LET v_extention1                  = NULL;    
	LET v_county_code1                = '+52';    
	LET v_area_code2                  = '0';    
	LET v_telephone_number2           = NULL;    
	LET v_extention2                  = NULL;    
	LET v_county_code2                = '+52';    
	LET v_ocupation                   = NULL;    
	LET v_profession                  = NULL;    
	LET v_income                      = 0.0;    
	LET v_persons_in_charge           = NULL;    
	LET v_work_timetable_start        = NULL;    
	LET v_work_timetable_end          = NULL;    
	LET v_user_defined1               = NULL;    
	LET v_return_id					  = NULL;    
	LET v_qualification               = NULL;    
	LET v_common_id                   = NULL;    
	LET v_latitude1                   = 0.0;    
	LET v_longitude1                  = 0.0;    
	LET v_latitude2                   = 0.0;    
	LET v_longitude2                  = 0.0;    
	LET c_fecha_ejecucion			  = NULL;	

	--Variable de busqueda de cliente
	LET v_numero_credito			  = NULL;
	LET sql_err						  = 0;
	LET aux_telefono_numero		      = NULL;
	
	--Variables para direcciones y telefonos de clientes con mas de 2 direcciones y telefonos
	LET v_address_type3 		      = NULL;
	LET v_use_this_3 		          = NULL;
	LET v_zone3						  = NULL;
	LET v_zone4   				      = NULL;
	LET v_address_type4 		      = NULL;
	LET v_use_this_4 		          = NULL;
	LET v_zone4					      = NULL;
	LET v_city4				          = NULL;
	LET v_telephone_type3	          = NULL;
	LET v_telephone_type4	          = NULL;
	LET v_area_code3                  = '0';
    LET v_telephone_number3           = NULL;
    LET v_extention3                  = NULL;
    LET v_county_code3                = '+52';
    LET v_area_code4        	      = NULL;
    LET v_telephone_number4           = NULL;
    LET v_extention4                  = NULL;
    LET v_county_code4                = '+52';
	LET v_longitud_numero_telefono    = 0;
	LET v_strata3                     = NULL;
	LET v_addres_number3			  = NULL;
	LET v_addres_number4              = NULL;
    LET v_province3                   = NULL;      
	LET v_country3                    = NULL;  
	LET v_po_box3                     = NULL;   
	LET v_province4                   = NULL;      
	LET v_country4                    = NULL;  
	LET v_po_box4                     = NULL;  
	LET v_strata4                     = NULL; 
	LET v_addr_tel_type3 			  = NULL;
	LET v_addr_tel_type4			  = NULL;
	
	LET v_escolaridad  				    = NULL;
	LET v_num_profeccion    			= NULL;
	LET v_pais_1            			= NULL;
	LET v_estado_1          			= NULL;
	LET v_num_calle_1       			= NULL;
	LET v_pais_2            			= NULL;
	LET v_estado_2          			= NULL;
	LET v_num_calle_2       			= NULL;
	LET v_pais_3            			= NULL;
	LET v_estado_3          			= NULL;
	LET v_num_calle_3       			= NULL;
	LET v_sec_ingreso	    			= NULL;
	LET v_fecha_apertura				= NULL;
	
	
	
	
	LET iContador 						= 0;
	
	LET horaActual						= NULL;
	LET iContador1 						= 0;
	LET v_valor_inicial 				= 0;
	LET v_valor_final				    = 0;
	LET v_transaccion					= 0;
	LET v_proceso 						='';
	LET c_fecha_actual					= NULL;
	LET c_fecha_actual_2				= NULL;

	LET v_numero_interior				='S/N';
	LET v_numero_exterior				='S/N';
	
	
	--SET DEBUG FILE TO "/resplogifx/cobranza/personas2.out";
  -- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			--COMMIT WORK;
			--Insertar error para tener control e identicar cual se esta presentando
				INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
				VALUES(v_account_number, v_user_defined1, '', sql_err, v_proceso, CURRENT);
			
			IF iContador > 0 Then
				COMMIT WORK;
			End IF;
			
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				--ROLLBACK WORK;
				RETURN v_cod_ret;				
			END IF;
		END EXCEPTION;
			
			ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  --COMMIT WORK;
			  --BEGIN WORK;
			  LET v_transaccion = 1;
			  INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto,descripcion_error, proceso, fecha_insert)
			  VALUES( v_account_number, v_user_defined1, '', 'ERROR -535',v_proceso, CURRENT);
			    COMMIT WORK;
				BEGIN WORK;

		   END EXCEPTION WITH RESUME;
		
		--Fecha de ejecuciÃÂÃÂ³n
		--SELECT fecha_hoy 
		--	INTO c_fecha_ejecucion
		--FROM bdinteg:si_fechas;
		
		
		SELECT fecha_hoy, fecha_hoy + 1--,  day(fecha_hoy)
			INTO c_fecha_actual, c_fecha_actual_2--, iDia_corte --rev
		FROM bdinteg:si_fechas where empresa = '001';
		
		
		LET horaActual = CURRENT;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) 
		VALUES (iContador1, horaActual, 'IN_CICLO_PER');

		/*SELECT DBINFO("utc_to_datetime", sh_curtime) 
			INTO horaActual 
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'IN_CICLO_PER');*/
		
		BEGIN WORK;
			LET v_proceso ='INFO PERSONAS CRED';
			LET  v_transaccion = 1 ;
		
				SELECT valor_inicial, valor_final, fecha_ejecucion
					INTO v_valor_inicial, v_valor_final, c_fecha_ejecucion
				FROM ics_numero_proceso 
				WHERE numero_hilo = p_num_ejecucion and tipo_cred = '1';
		
			FOREACH WITH HOLD --Este SP es el bueno
				
				SELECT numcte, num_credito, rfc, fecha_apertura
					INTO v_user_defined1, v_account_number, v_identity_code, v_fecha_apertura
				FROM ics_clientes WHERE num_credito BETWEEN v_valor_inicial AND v_valor_final and tipo_cred = '1'
				
				
				--IF v_fecha_apertura = c_fecha_actual OR v_fecha_apertura = c_fecha_actual_2 THEN
					/*SELECT rfc
						INTO v_identity_code
					FROM bdinteg:si_cliente 
					WHERE numcte = v_user_defined1;*/
					
					SELECT sc.apell_paterno, sc.nombre1, sc.apell_materno, sc.nombre2
						INTO  v_first_surname, v_first_name, v_second_surname, v_middle_name
					FROM   bdinteg:si_cliente sc
					WHERE  sc.numcte = v_user_defined1;
					
					LET v_first_surname = TRIM(v_first_surname);
					LET v_first_name = TRIM(v_first_name);
					LET v_second_surname = TRIM(v_second_surname);
					LET v_middle_name = TRIM(v_middle_name);
					
					LET v_second_surname = NULLIF(v_second_surname, '');
					/*IF v_second_surname = '' OR v_second_surname IS NULL THEN 
						LET v_second_surname = NULL;
					END IF;*/
					
					LET v_middle_name = NULLIF(v_middle_name, '');
					/*IF v_middle_name = '' OR v_middle_name IS NULL THEN 
						LET v_middle_name = NULL;
					END IF;*/
					
					
					select cte.sexo, cte.estado_civil, cte.fecha_nac, cte.dependientes, cte.escolaridad,cte.profesion
						INTO  v_sex, v_civil_estatus, v_birth_date, v_persons_in_charge, v_escolaridad, v_num_profeccion
					FROM   bdinteg:si_ctepf cte
					WHERE  cte.numcte = v_user_defined1;
	
					LET v_birth_date_char = TO_CHAR(v_birth_date,'%d/%m/%Y');
					
					--Codigo Postal, Colonia CON tipo de direccion 1
					
					SELECT da.numerocolonia, da.numerociudad, da.pais, da.estado, da.numerocalle, da.numeroextcalle, da.numerointcalle
						INTO v_zone1, v_city1, v_pais_1, v_estado_1, v_num_calle_1, v_numero_exterior, v_numero_interior
					FROM bdinteg:si_direcciones_actual da 
					WHERE da.numcte = v_user_defined1
						AND da.tipo_dir = '1';
						--INNER JOIN bdinteg:si_catzonas cz ON da.numerociudad = cz.numerociudad AND da.numerocolonia = cz.numerocolonia
					
					
					--ValidaciÃÂÃÂ³n para saber si tiene tipo de direcciÃÂÃÂ³n 1 = RESIDENCE
					
					LET v_address_type1 = 'CASA';
					LET v_use_this_1 = CASE 
					WHEN v_city1 IS NOT NULL AND v_zone1 IS NOT NULL THEN 'Y'
					ELSE 'N'
					END;
					
					/*IF v_city1 IS NOT NULL AND v_zone1 IS NOT NULL THEN 
						LET v_address_type1= 'CASA';
						LET v_use_this_1 = 'Y';
					ELSE 
						LET v_address_type1 = 'CASA';
						LET v_use_this_1 = 'N';
					END IF;*/
					--Fin Postal, Colonia
					
					--Codigo Postal, Colonia CON tipo de direccion 2
					SELECT da.numerocolonia, da.numerociudad, da.pais, da.estado, da.numerocalle
						INTO v_zone2, v_city2, v_pais_2, v_estado_2, v_num_calle_2
					FROM bdinteg:si_direcciones_actual da 
					WHERE da.numcte = v_user_defined1
						AND da.tipo_dir = '2';
						--INNER JOIN bdinteg:si_catzonas cz ON da.numerociudad = cz.numerociudad AND da.numerocolonia = cz.numerocolonia
					
					
					--ValidaciÃÂÃÂ³n para saber si tiene tipo de direcciÃÂÃÂ³n 2 = OFFICE
					
					LET v_address_type2 = 'TRABAJO';
					LET v_use_this_2 = CASE 
						WHEN v_city2 IS NOT NULL AND v_zone2 IS NOT NULL THEN 'Y'
						ELSE 'N'
					END;
					
					/*IF v_city2 IS NOT NULL AND v_zone2 IS NOT NULL THEN 
						LET  v_address_type2= 'TRABAJO';
						LET v_use_this_2 = 'Y';
					ELSE 
						LET v_address_type2 = 'TRABAJO';
						LET v_use_this_2 = 'N';
					END IF;*/
					--Fin Postal, Colonia
					
					--Codigo Postal, Colonia CON tipo de direccion 3
					SELECT da.numerocolonia, da.numerociudad, da.pais, da.estado, da.numerocalle
						INTO v_zone3, v_city3, v_pais_3, v_estado_3, v_num_calle_3
					FROM bdinteg:si_direcciones_actual da 
					WHERE da.numcte = v_user_defined1
						AND da.tipo_dir = '3';
						--INNER JOIN bdinteg:si_catzonas cz ON da.numerociudad = cz.numerociudad AND da.numerocolonia = cz.numerocolonia
					
					
					--ValidaciÃÂÃÂ³n para saber si tiene tipo de direcciÃÂÃÂ³n 3 = SUCURSAL
					
					LET v_address_type1 = 'OTRO';
					LET v_use_this_3 = CASE 
						WHEN v_city3 IS NOT NULL AND v_zone3 IS NOT NULL THEN 'Y'
						ELSE 'N'
					END;
					
					/*IF v_city3 IS NOT NULL AND v_zone3 IS NOT NULL THEN 
						LET  v_address_type3= 'OTRO';
						LET v_use_this_3 = 'Y';
					ELSE 
						LET v_address_type3 = 'OTRO';
						LET v_use_this_3 = 'N';
					END IF;*/
					--Fin Postal, Colonia
						
					
					--Tipo de telefono 1, numero de telefono del cliente 
					SELECT telefono, extension 	
						INTO aux_telefono_numero, v_extention1
					FROM bdinteg:si_telefonos_actual
					WHERE tipo_tel= 1 and status_tel <> 'C'
						AND numcte = v_user_defined1;
					
					LET v_extention1 = NVL(NULLIF(v_extention1, ''), '0');
		
					/*IF v_extention1= '' OR v_extention1 IS NULL THEN
						LET v_extention1 = '0';
					END IF;*/
						
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					LET v_telephone_number1 = CASE 
						WHEN aux_telefono_numero = '??????????' THEN '0'
						WHEN v_longitud_numero_telefono > 10 THEN SUBSTR(aux_telefono_numero, (v_longitud_numero_telefono - 10))
						ELSE aux_telefono_numero
					END;

					/*IF v_longitud_numero_telefono > 10 AND aux_telefono_numero <> '??????????'  THEN
						LET v_telephone_number1 =  SUBSTR(aux_telefono_numero,(v_longitud_numero_telefono-10));
					ELSE
						LET v_telephone_number1 = aux_telefono_numero;
					END IF;
					
					IF v_telephone_number1 = '??????????' THEN
						LET v_telephone_number1 = '0';
					END IF;
					*/
					LET v_telephone_type1 = 'CEL';
					LET v_addr_tel_type1 = 'MOVIL';	
					
					/*IF v_telephone_number1 IS NOT NULL THEN
						LET v_telephone_type1 = 'CEL';
						LET v_addr_tel_type1 = 'MOVIL';					ELSE
						LET v_telephone_type1 = 'CEL';
						LET v_addr_tel_type1 = 'MOVIL'; 
					END IF;*/
					--Fin de telefono 1
	
					--Tipo de telefono 2, numero de telefono del cliente 
					SELECT telefono, extension 	
						INTO aux_telefono_numero, v_extention2
					FROM bdinteg:si_telefonos_actual
					WHERE tipo_tel= 2 and status_tel <> 'C'
						AND numcte = v_user_defined1;
					
					LET v_extention2 = NVL(NULLIF(v_extention2, ''), '0');
					/*IF v_extention2= '' OR v_extention2 IS NULL THEN
						LET v_extention2 = '0';
					END IF;*/
					
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					LET v_telephone_number2 = CASE 
						WHEN aux_telefono_numero = '??????????' THEN '0'
						WHEN v_longitud_numero_telefono > 10 THEN SUBSTR(aux_telefono_numero, (v_longitud_numero_telefono - 10))
						ELSE aux_telefono_numero
					END;
					/*IF v_longitud_numero_telefono > 10 AND aux_telefono_numero <> '??????????'  THEN
						LET v_telephone_number2 =  SUBSTR(aux_telefono_numero,(v_longitud_numero_telefono-10));
					ELSE
						LET v_telephone_number2 = aux_telefono_numero;
					END IF;
					
					IF v_telephone_number2 = '??????????' THEN
						LET v_telephone_number2 = '0';
					END IF;*/
					
					LET v_telephone_type2 = 'TEL';
					LET v_addr_tel_type2 = 'PARTICULAR';
					/*IF v_telephone_number2 IS NOT NULL THEN
						LET v_telephone_type2 = 'TEL';
						LET v_addr_tel_type2 = 'PARTICULAR';					ELSE
						LET v_telephone_type2 = 'TEL';
						LET v_addr_tel_type2 = 'PARTICULAR'; 
					END IF;*/
					--Fin de telefono 2
					
					--Tipo de telefono 3, numero de telefono del cliente 
					SELECT telefono, extension 	
						INTO aux_telefono_numero, v_extention3
					FROM bdinteg:si_telefonos_actual
					WHERE tipo_tel= 3 and status_tel <> 'C'
						AND numcte = v_user_defined1;
					
					LET v_extention3 = NVL(NULLIF(v_extention3, ''), '0');
										
					/*IF v_extention3= '' OR v_extention3 IS NULL THEN
						LET v_extention3 = '0';
					END IF;*/
					
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					
					LET v_telephone_number3 = CASE 
						WHEN aux_telefono_numero = '??????????' THEN '0'
						WHEN v_longitud_numero_telefono > 10 THEN SUBSTR(aux_telefono_numero, (v_longitud_numero_telefono - 10))
						ELSE aux_telefono_numero
					END;
					
					/*IF v_longitud_numero_telefono > 10 AND aux_telefono_numero <> '??????????'  THEN
						LET v_telephone_number3 =  SUBSTR(aux_telefono_numero,(v_longitud_numero_telefono-10));
					ELSE
						LET v_telephone_number3 = aux_telefono_numero;
					END IF;
					
					IF v_telephone_number3 = '??????????' THEN
						LET v_telephone_number3 = '0';
					END IF;*/
					
					LET v_telephone_type3 = 'FAX';
					LET v_addr_tel_type3 = 'TRABAJO';
					
					/*IF v_telephone_number3 IS NOT NULL THEN
						LET v_telephone_type3 = 'FAX';
						LET v_addr_tel_type3 = 'TRABAJO';					ELSE
						LET v_telephone_type3 = 'FAX';
						LET v_addr_tel_type3 = 'TRABAJO'; 
					END IF;*/
					--Fin de telefono 3
					
					--Income_Payment_type
					LET v_income_payment_type = 'M';
					--Fin
					
					--Income_Payment_day
					LET v_income_payment_day = '30';
					--Fin
					
					LET v_reviewed = 'N';
					
					SELECT MAX(sec_ingreso)  INTO v_sec_ingreso FROM bdinteg:si_ingresos WHERE numcte = v_user_defined1;
					
					--Company
					SELECT  si.nombre_empresa
						INTO v_company
					FROM bdinteg:si_ingresos si
					WHERE si.numcte = v_user_defined1 AND si.sec_ingreso = v_sec_ingreso;
							--(SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos WHERE numcte = v_user_defined1);
					--Fin Company
					
					--Addres_number1, province1, country1, po_box1,strata1
					
					--Nombre Calle
					/*SELECT b.nombrecalle 
						INTO v_addres_number1
					FROM  bdinteg:si_direcciones_actual a
						INNER JOIN bdinteg:si_catcalles b ON a.numerocalle = b.numerocalle
					WHERE  a.tipo_dir = '1' AND a.numcte = v_user_defined1;*/
					
					SELECT nombrecalle 
					INTO v_addres_number1 
					FROM  bdinteg:si_catcalles  
					WHERE  numerocalle = v_num_calle_1;
					LET v_addres_number1 = v_addres_number1||'N-EXT: '||v_numero_exterior||'N-INT: '||v_numero_interior;
	
					
					--Estado
					/*SELECT a.nombre 
						INTO v_province1
					FROM bdinteg:si_estados a
						INNER JOIN bdinteg:si_direcciones_actual b ON a.estado = b.estado 
					WHERE b.tipo_dir = '1' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_province1 FROM bdinteg:si_estados WHERE estado = v_estado_1;
					
					--Pais
					/*SELECT a.nombre 
						INTO v_country1
					FROM bdinteg: si_paises a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.pais = b.pais
					WHERE b.tipo_dir = '1' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_country1 FROM bdinteg:si_paises WHERE pais = v_pais_1;
					
					--
					--Po_box1
					--Mismo codigo postal
					LET v_po_box1 = v_zone1;
					--
					--strata1
					LET v_strata1 = NULL;
					--
					--Fin
					
					--Addres_number2, province2, country2, po_box2,strata2
					--Nombre Calle
					/*SELECT b.nombrecalle 
						INTO v_addres_number2
					FROM  bdinteg: si_direcciones_actual a
						INNER JOIN bdinteg: si_catcalles b ON a.numerocalle = b.numerocalle
					WHERE  a.tipo_dir = '2' AND a.numcte = v_user_defined1;*/
					
					SELECT nombrecalle 	INTO v_addres_number2 FROM  bdinteg:si_catcalles  WHERE  numerocalle = v_num_calle_2;
					
					--Estado
					/*SELECT a.nombre 
						INTO v_province1
					FROM bdinteg: si_estados a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.estado = b.estado 
					WHERE b.tipo_dir = '2' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_province2 FROM bdinteg:si_estados WHERE estado = v_estado_2;
					
					--Pais
					/*SELECT a.nombre 
						INTO v_country2
					FROM bdinteg: si_paises a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.pais = b.pais
					WHERE b.tipo_dir = '2' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_country2 FROM bdinteg:si_paises WHERE pais = v_pais_2;
					--
					--Po_box2
					--Mismo codigo postal
					LET v_po_box2 = v_zone2;
					--
					--strata2
					LET v_strata2 = NULL;
					--
					--Fin
					
					--Addres_number3, province3, country3, po_box3,strata3
					--Nombre Calle
					/*SELECT b.nombrecalle 
						INTO v_addres_number3
					FROM bdinteg: si_direcciones_actual a
						INNER JOIN bdinteg: si_catcalles b ON a.numerocalle = b.numerocalle
					WHERE  a.tipo_dir = '3' AND a.numcte = v_user_defined1;*/
					
					SELECT nombrecalle INTO v_addres_number3 FROM  bdinteg:si_catcalles  WHERE  numerocalle = v_num_calle_3;
					
					--Estado
					/*SELECT a.nombre 
						INTO v_province3
					FROM bdinteg: si_estados a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.estado = b.estado 
					WHERE b.tipo_dir = '3' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_province3 FROM bdinteg:si_estados WHERE estado = v_estado_3;
					
					--Pais
					/*SELECT a.nombre
						INTO v_country3
					FROM bdinteg:si_paises a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.pais = b.pais
					WHERE b.tipo_dir = '3' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_country3 FROM bdinteg:si_paises WHERE pais = v_pais_3;
					--
					--Po_box3
					--Mismo codigo postal
					LET v_po_box3 = v_zone3;
					--
					--strata3
					LET v_strata3 = NULL;
					--
					--Fin
				
					--Ocupation, Profession
					/*SELECT b.descripcion, d.descripcion
						INTO v_ocupation, v_profession
					FROM bdinteg:si_ctepf a
						INNER JOIN bdinteg:si_escolaridad_am b ON b.elemento = a.escolaridad
						INNER JOIN bdinteg: si_profesion d ON d.profesion = a.profesion
					WHERE a.numcte = v_user_defined1;*/
					
					SELECT descripcion INTO v_ocupation FROM bdinteg:si_escolaridad_am WHERE elemento = v_escolaridad;
					SELECT descripcion INTO v_profession FROM bdinteg:si_profesion WHERE profesion = v_num_profeccion;
					--
					
					--Income, Persons_In_Chargue
					SELECT ingreso_mensual, bs_score
					INTO v_income, v_qualification
					FROM bdisolic:ss_revision_determinacion
					WHERE num_solicitud = v_account_number 
					AND numcte= v_user_defined1;
					
					--Persons_In_Chargue
					/*SELECT dependientes
					INTO   v_persons_in_charge
					FROM bdinteg: si_ctepf
						WHERE numcte = v_user_defined1;*/
					
					--Numero de cliente
					LET v_user_defined1 = v_user_defined1;

					LET v_income = NVL(NULLIF(v_income, ''), '0');
					/*IF v_income = '' OR v_income IS NULL THEN
						LET v_income = 0;
					END IF;*/
					
					LET v_persons_in_charge = NVL(NULLIF(v_persons_in_charge, ''), '0');
					/*IF v_persons_in_charge = '' OR v_persons_in_charge IS NULL THEN
						LET v_persons_in_charge = '0';
					END IF;*/
					
					LET v_telephone_number1 = replace(replace(v_telephone_number1,chr(9),''),chr(10),'');
					LET v_telephone_number2 = replace(replace(v_telephone_number2,chr(9),''),chr(10),'');
					
					INSERT INTO ics_personas
						(customer_id, identity_code, account_number, seq, first_surname,	first_name, sex, civil_status, address_type1, zone1, city1,                       
						use_this_1, address_type2, zone2, city2, use_this_2, telephone_type1, addr_tel_type1, telephone_type2,             
						addr_tel_type2, income_payment_type, income_payment_day, reviewed, company, second_surname,midlle_name, birth_date,                  
						addres_number1, province1, country1, po_box1, strata1, addres_number2, province2, country2, po_box2, strata2,                    
						area_code1, telephone_number1, extention1, county_code1, area_code2, telephone_number2, extention2, county_code2,                
						ocupation, profession, income, persons_in_charge, work_timetable_start, work_timetable_end, user_defined1, return_id,					
						qualification, common_id, latitude1, longitude1, latitude2, longitude2, fecha_ejecucion)
					VALUES
						(v_customer_id, v_identity_code, v_account_number, v_seq, v_first_surname,	v_first_name, v_sex, v_civil_estatus, v_address_type1, v_zone1, v_city1,                       
						
						
						
						v_use_this_1, v_address_type2, v_zone2, v_city2, v_use_this_2, v_telephone_type1, v_addr_tel_type1, v_telephone_type2,             
						v_addr_tel_type2, v_income_payment_type, v_income_payment_day, v_reviewed, v_company, v_second_surname, v_middle_name, v_birth_date_char,                  
						
						
						
						
						
						v_addres_number1, v_province1, v_country1, v_po_box1, v_strata1, v_addres_number2, v_province2, v_country2, v_po_box2, v_strata2,                    
						v_area_code1, v_telephone_number1, v_extention1, v_county_code1, v_area_code2, v_telephone_number2, v_extention2, v_county_code2,                
						v_ocupation, v_profession, v_income, v_persons_in_charge, v_work_timetable_start, v_work_timetable_end, v_user_defined1, v_return_id,					
						v_qualification, v_common_id, v_latitude1, v_longitude1, v_latitude2, v_longitude2, c_fecha_ejecucion);
				
						LET iContador = iContador + 1;
						LET iContador1 = iContador1 + 1;
				
					IF  v_addres_number3 IS NOT NULL OR  v_zone3 IS NOT NULL OR v_city3 IS NOT NULL OR v_telephone_number3 IS NOT NULL THEN
						
						LET v_seq = v_seq + 1;
						LET v_extention3 = '0';
						LET v_extention4 = '0';
						LET v_telephone_number4 = '0';
						LET v_telephone_number3 = replace(replace(v_telephone_number3,chr(9),''),chr(10),'');
				
						INSERT INTO ics_personas
							(customer_id, identity_code, account_number, seq, first_surname,first_name, sex, civil_status, address_type1, zone1, city1,                       
							use_this_1, address_type2, zone2, city2, use_this_2, telephone_type1, addr_tel_type1, telephone_type2,             
							addr_tel_type2, income_payment_type, income_payment_day, reviewed, company, second_surname,midlle_name, birth_date,                  
							addres_number1, province1, country1, po_box1, strata1, addres_number2, province2, country2, po_box2, strata2,                    
							area_code1, telephone_number1, extention1, county_code1, area_code2, telephone_number2, extention2, county_code2,                
							ocupation, profession, income, persons_in_charge, work_timetable_start, work_timetable_end, user_defined1, return_id,					
							qualification, common_id, latitude1, longitude1, latitude2, longitude2, fecha_ejecucion)
						VALUES
							(v_customer_id, v_identity_code, v_account_number, v_seq, v_first_surname,	v_first_name, v_sex, v_civil_estatus, v_address_type3, v_zone3, v_city3,                       
							v_use_this_3, v_address_type4, v_zone4, v_city4, v_use_this_4, v_telephone_type3, v_addr_tel_type3, v_telephone_type4,             
							v_addr_tel_type4, v_income_payment_type, v_income_payment_day, v_reviewed, v_company, v_second_surname, v_middle_name, v_birth_date_char,                  
							v_addres_number3, v_province3, v_country3, v_po_box3, v_strata3, v_addres_number4, v_province4, v_country4, v_po_box4, v_strata4,                    
							v_area_code3, v_telephone_number3, v_extention3, v_county_code3, v_area_code3, v_telephone_number4, v_extention4, v_county_code4,                
							v_ocupation, v_profession, v_income, v_persons_in_charge, v_work_timetable_start, v_work_timetable_end, v_user_defined1, v_return_id,					
							v_qualification, v_common_id, v_latitude1, v_longitude1, v_latitude2, v_longitude2, c_fecha_ejecucion);
							
							LET iContador = iContador + 1;
							LET iContador1 = iContador1 + 1;
							LET v_seq = 1;
					
					END IF;
				--END IF;
				
				--LET iContador1 = iContador1 + 1;
				
				IF iContador1 >= 100000 THEN
					LET horaActual = CURRENT;

					INSERT INTO ics_tiempos (num_registro, hora, proceso) 
					VALUES (iContador1, horaActual, 'CICLO_PER');

					LET iContador1 = 0;
				END IF;
				
				/*IF iContador1 >= 100000 THEN
					SELECT DBINFO("utc_to_datetime", sh_curtime) 
						INTO horaActual 
					FROM sysmaster:sysshmvals;
					INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'CICLO_PER');
					LET iContador1 = 0;
				END IF; */
				
				
				IF iContador >= 1000 THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF; 
				
			END FOREACH;
					
					

					LET iContador1 = 0;
					LET horaActual = CURRENT;
					INSERT INTO ics_tiempos (num_registro, hora, proceso) 
					VALUES (iContador1, horaActual, 'FIN_CICLO_PER');
			/*SELECT DBINFO("utc_to_datetime", sh_curtime) 
				INTO horaActual 
			FROM sysmaster:sysshmvals;
			INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'FIN_CICLO_PER');*/
			
		COMMIT WORK;
		
		LET  v_transaccion = 0;
		
		--============================ Consulta de personas crd por hilos =======================--
		BEGIN WORK;
			LET v_proceso ='INFO PERSONAS CRD';
			LET  v_transaccion = 1 ;
				SELECT valor_inicial, valor_final, fecha_ejecucion
					INTO v_valor_inicial, v_valor_final, c_fecha_ejecucion
				FROM ics_numero_proceso 
				WHERE numero_hilo = p_num_ejecucion and tipo_cred = '2';
		
			FOREACH WITH HOLD --Este SP es el bueno
				
				SELECT numcte, num_credito, rfc, fecha_apertura
					INTO v_user_defined1, v_account_number, v_identity_code, v_fecha_apertura
				FROM ics_clientes WHERE num_credito BETWEEN v_valor_inicial AND v_valor_final and tipo_cred = '2'
				
				/*SELECT rfc
					INTO v_identity_code
				FROM bdinteg:si_cliente 
				WHERE numcte = v_user_defined1;*/
				--IF v_fecha_apertura = c_fecha_actual OR v_fecha_apertura = c_fecha_actual_2 THEN
				
					SELECT sc.apell_paterno, sc.nombre1, sc.apell_materno, sc.nombre2
						INTO  v_first_surname, v_first_name, v_second_surname, v_middle_name
					FROM   bdinteg:si_cliente sc
					WHERE  sc.numcte = v_user_defined1;
					
					LET v_first_surname = TRIM(v_first_surname);
					LET v_first_name = TRIM(v_first_name);
					LET v_second_surname = TRIM(v_second_surname);
					LET v_middle_name = TRIM(v_middle_name);
					
					LET v_second_surname = NULLIF(v_second_surname, '');
					/*IF v_second_surname = '' OR v_second_surname IS NULL THEN 
						LET v_second_surname = NULL;
					END IF;*/
					
					LET v_middle_name = NULLIF(v_middle_name, '');
					/*IF v_middle_name = '' OR v_middle_name IS NULL THEN 
						LET v_middle_name = NULL;
					END IF;*/
					
					select cte.sexo, cte.estado_civil, cte.fecha_nac, cte.dependientes, cte.escolaridad, cte.profesion
						INTO  v_sex, v_civil_estatus, v_birth_date, v_persons_in_charge, v_escolaridad, v_num_profeccion
					FROM   bdinteg:si_ctepf cte
					WHERE  cte.numcte = v_user_defined1;
	
					LET v_birth_date_char = TO_CHAR(v_birth_date,'%d/%m/%Y');
					
					--Codigo Postal, Colonia CON tipo de direccion 1
					
					SELECT da.numerocolonia, da.numerociudad, da.pais, da.estado, da.numerocalle, da.numeroextcalle, da.numerointcalle
						INTO v_zone1, v_city1, v_pais_1, v_estado_1, v_num_calle_1, v_numero_exterior, v_numero_interior
					FROM bdinteg:si_direcciones_actual da																													
					WHERE da.numcte = v_user_defined1
						AND da.tipo_dir = '1';
						--INNER JOIN bdinteg:si_catzonas cz ON da.numerociudad = cz.numerociudad AND da.numerocolonia = cz.numerocolonia
					
					
					--ValidaciÃÂÃÂ³n para saber si tiene tipo de direcciÃÂÃÂ³n 1 = RESIDENCE
					
					LET v_address_type1 = 'CASA';
					LET v_use_this_1 = CASE 
					WHEN v_city1 IS NOT NULL AND v_zone1 IS NOT NULL THEN 'Y'
					ELSE 'N'
					END;
					
					/*IF v_city1 IS NOT NULL AND v_zone1 IS NOT NULL THEN 
						LET v_address_type1= 'CASA';
						LET v_use_this_1 = 'Y';
					ELSE 
						LET v_address_type1 = 'CASA';
						LET v_use_this_1 = 'N';
					END IF;*/
					--Fin Postal, Colonia
					
					--Codigo Postal, Colonia CON tipo de direccion 2
					SELECT da.numerocolonia, da.numerociudad, da.pais, da.estado, da.numerocalle
						INTO v_zone2, v_city2, v_pais_2, v_estado_2, v_num_calle_2
					FROM bdinteg:si_direcciones_actual da 																													
					WHERE da.numcte = v_user_defined1
						AND da.tipo_dir = '2';
						--INNER JOIN bdinteg:si_catzonas cz ON da.numerociudad = cz.numerociudad AND da.numerocolonia = cz.numerocolonia
					
					
					--ValidaciÃÂÃÂ³n para saber si tiene tipo de direcciÃÂÃÂ³n 2 = OFFICE
					
					LET v_address_type2 = 'TRABAJO';
					LET v_use_this_2 = CASE 
					WHEN v_city2 IS NOT NULL AND v_zone2 IS NOT NULL THEN 'Y'
					ELSE 'N'
					END;
					
					/*IF v_city2 IS NOT NULL AND v_zone2 IS NOT NULL THEN 
						LET  v_address_type2= 'TRABAJO';
						LET v_use_this_2 = 'Y';
					ELSE 
						LET v_address_type2 = 'TRABAJO';
						LET v_use_this_2 = 'N';
					END IF;*/
					
					--Fin Postal, Colonia
					
					--Codigo Postal, Colonia CON tipo de direccion 3
					SELECT da.numerocolonia, da.numerociudad, da.pais, da.estado, da.numerocalle
						INTO v_zone3, v_city3, v_pais_3, v_estado_3, v_num_calle_3
					FROM bdinteg:si_direcciones_actual da 																													
					WHERE da.numcte = v_user_defined1
						AND da.tipo_dir = '3';
						--INNER JOIN bdinteg:si_catzonas cz ON da.numerociudad = cz.numerociudad AND da.numerocolonia = cz.numerocolonia
					
					
					--ValidaciÃÂÃÂ³n para saber si tiene tipo de direcciÃÂÃÂ³n 3 = SUCURSAL
					
					LET v_address_type3 = 'OTRO';
					LET v_use_this_3 = CASE 
					WHEN v_city3 IS NOT NULL AND v_zone3 IS NOT NULL THEN 'Y'
					ELSE 'N'
					END;
					
					/*IF v_city3 IS NOT NULL AND v_zone3 IS NOT NULL THEN 
						LET  v_address_type3= 'OTRO';
						LET v_use_this_3 = 'Y';
					ELSE 
						LET v_address_type3 = 'OTRO';
						LET v_use_this_3 = 'N';
					END IF;*/
					--Fin Postal, Colonia
						
					
					--Tipo de telefono 1, numero de telefono del cliente 
					SELECT telefono, extension 	
						INTO aux_telefono_numero, v_extention1
					FROM bdinteg:si_telefonos_actual
					WHERE tipo_tel= 1 and status_tel <> 'C'
						AND numcte = v_user_defined1;
						
					LET v_extention1 = NVL(NULLIF(v_extention1, ''), '0');
			
					/*IF v_extention1= '' OR v_extention1 IS NULL THEN
						LET v_extention1 = '0';
					END IF;*/
						
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					LET v_telephone_number1 = CASE 
						WHEN aux_telefono_numero = '??????????' THEN '0'
						WHEN v_longitud_numero_telefono > 10 THEN SUBSTR(aux_telefono_numero, (v_longitud_numero_telefono - 10))
						ELSE aux_telefono_numero
					END;	
					
					/*IF v_longitud_numero_telefono > 10 AND aux_telefono_numero <> '??????????'  THEN
						LET v_telephone_number1 =  SUBSTR(aux_telefono_numero,(v_longitud_numero_telefono-10));
					ELSE
						LET v_telephone_number1 = aux_telefono_numero;
					END IF;
					
					IF v_telephone_number1 = '??????????' THEN
						LET v_telephone_number1 = '0';
					END IF;*/
					
					LET v_telephone_type1 = 'CEL';
					LET v_addr_tel_type1 = 'MOVIL';	
					
					/*IF v_telephone_number1 IS NOT NULL THEN
						LET v_telephone_type1 = 'CEL';
						LET v_addr_tel_type1 = 'MOVIL';					ELSE
						LET v_telephone_type1 = 'CEL';
						LET v_addr_tel_type1 = 'MOVIL'; 
					END IF;*/
					--Fin de telefono 1
	
					--Tipo de telefono 2, numero de telefono del cliente 
					SELECT telefono, extension 	
						INTO aux_telefono_numero, v_extention2
					FROM bdinteg:si_telefonos_actual
					WHERE tipo_tel= 2 and status_tel <> 'C'
						AND numcte = v_user_defined1;
					
					LET v_extention2 = NVL(NULLIF(v_extention2, ''), '0');
					/*IF v_extention2= '' OR v_extention2 IS NULL THEN
						LET v_extention2 = '0';
					END IF;*/
					
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					LET v_telephone_number2 = CASE 
						WHEN aux_telefono_numero = '??????????' THEN '0'
						WHEN v_longitud_numero_telefono > 10 THEN SUBSTR(aux_telefono_numero, (v_longitud_numero_telefono - 10))
						ELSE aux_telefono_numero
					END;
					
					/*IF v_longitud_numero_telefono > 10 AND aux_telefono_numero <> '??????????'  THEN
						LET v_telephone_number2 =  SUBSTR(aux_telefono_numero,(v_longitud_numero_telefono-10));
					ELSE
						LET v_telephone_number2 = aux_telefono_numero;
					END IF;
					
					IF v_telephone_number2 = '??????????' THEN
						LET v_telephone_number2 = '0';
					END IF;*/
					
					LET v_telephone_type2 = 'TEL';
					LET v_addr_tel_type2 = 'PARTICULAR';
					
					/*IF v_telephone_number2 IS NOT NULL THEN
						LET v_telephone_type2 = 'TEL';
						LET v_addr_tel_type2 = 'PARTICULAR';					ELSE
						LET v_telephone_type2 = 'TEL';
						LET v_addr_tel_type2 = 'PARTICULAR'; 
					END IF;*/
					--Fin de telefono 2
					
					--Tipo de telefono 3, numero de telefono del cliente 
					SELECT telefono, extension 	
						INTO aux_telefono_numero, v_extention3
					FROM bdinteg:si_telefonos_actual
					WHERE tipo_tel= 3 and status_tel <> 'C'
						AND numcte = v_user_defined1;
					
					LET v_extention2 = NVL(NULLIF(v_extention2, ''), '0');
				
					/*IF v_extention3= '' OR v_extention3 IS NULL THEN
						LET v_extention3 = '0';
					END IF;*/
					
					LET v_longitud_numero_telefono = length(trim(aux_telefono_numero)); 
					
					LET v_telephone_number3 = CASE 
						WHEN aux_telefono_numero = '??????????' THEN '0'
						WHEN v_longitud_numero_telefono > 10 THEN SUBSTR(aux_telefono_numero, (v_longitud_numero_telefono - 10))
						ELSE aux_telefono_numero
					END;					
					
					/*IF v_longitud_numero_telefono > 10 AND aux_telefono_numero <> '??????????'  THEN
						LET v_telephone_number3 =  SUBSTR(aux_telefono_numero,(v_longitud_numero_telefono-10));
					ELSE
						LET v_telephone_number3 = aux_telefono_numero;
					END IF;
					
					IF v_telephone_number3 = '??????????' THEN
						LET v_telephone_number3 = '0';
					END IF;*/
					
					LET v_telephone_type3 = 'FAX';
					LET v_addr_tel_type3 = 'TRABAJO';	
					/*IF v_telephone_number3 IS NOT NULL THEN
						LET v_telephone_type3 = 'FAX';
						LET v_addr_tel_type3 = 'TRABAJO';					ELSE
						LET v_telephone_type3 = 'FAX';
						LET v_addr_tel_type3 = 'TRABAJO'; 
					END IF;*/
					--Fin de telefono 3
					
					--Income_Payment_type
					LET v_income_payment_type = 'M';
					--Fin
					
					--Income_Payment_day
					LET v_income_payment_day = '30';
					--Fin
					
					LET v_reviewed = 'N';
					
					SELECT MAX(sec_ingreso)  INTO v_sec_ingreso FROM bdinteg:si_ingresos WHERE numcte = v_user_defined1;
					--Company
					SELECT  si.nombre_empresa
						INTO v_company
					FROM bdinteg:si_ingresos si
					WHERE si.numcte = v_user_defined1 AND si.sec_ingreso = v_sec_ingreso;
						--	(SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos WHERE numcte = v_user_defined1);
					--Fin Company
					
					--Addres_number1, province1, country1, po_box1,strata1
					
					--Nombre Calle
					/*SELECT b.nombrecalle 
						INTO v_addres_number1
					FROM  bdinteg: si_direcciones_actual a
						INNER JOIN bdinteg: si_catcalles b ON a.numerocalle = b.numerocalle
					WHERE  a.tipo_dir = '1' AND a.numcte = v_user_defined1;*/
					
					SELECT nombrecalle 	INTO v_addres_number1 FROM  bdinteg:si_catcalles  WHERE  numerocalle = v_num_calle_1;
						LET v_addres_number1 = v_addres_number1||'N-EXT: '||v_numero_exterior||'N-INT: '||v_numero_interior;
					
					--Estado
					/*SELECT a.nombre 
						INTO v_province1
					FROM bdinteg: si_estados a
						INNER JOIN bdinteg:si_direcciones_actual b ON a.estado = b.estado 
					WHERE b.tipo_dir = '1' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_province1 FROM bdinteg:si_estados WHERE estado = v_estado_1;
					
					--Pais
					/*SELECT a.nombre 
						INTO v_country1
					FROM bdinteg: si_paises a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.pais = b.pais
					WHERE b.tipo_dir = '1' AND b.numcte = v_user_defined1;*/
					
					
					SELECT nombre INTO v_country1 FROM bdinteg:si_paises WHERE pais = v_pais_1;
					
					--
					--Po_box1
					--Mismo codigo postal
					LET v_po_box1 = v_zone1;
					--
					--strata1
					LET v_strata1 = NULL;
					--
					--Fin
					
					--Addres_number2, province2, country2, po_box2,strata2
					--Nombre Calle
					/*SELECT b.nombrecalle 
						INTO v_addres_number2
					FROM  bdinteg: si_direcciones_actual a
						INNER JOIN bdinteg: si_catcalles b ON a.numerocalle = b.numerocalle
					WHERE  a.tipo_dir = '2' AND a.numcte = v_user_defined1;*/
					
					SELECT nombrecalle 	INTO v_addres_number2 FROM  bdinteg:si_catcalles  WHERE  numerocalle = v_num_calle_2;
					
					--Estado
					/*SELECT a.nombre 
						INTO v_province2
					FROM bdinteg: si_estados a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.estado = b.estado 
					WHERE b.tipo_dir = '2' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_province2 FROM bdinteg:si_estados WHERE estado = v_estado_2;
					
					--Pais
					/*SELECT a.nombre 
						INTO v_country2
					FROM bdinteg: si_paises a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.pais = b.pais
					WHERE b.tipo_dir = '2' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_country2 FROM bdinteg:si_paises WHERE pais = v_pais_2;
					
					--
					--Po_box2
					--Mismo codigo postal
					LET v_po_box2 = v_zone2;
					--
					--strata2
					LET v_strata2 = NULL;
					--
					--Fin
					
					--Addres_number3, province3, country3, po_box3,strata3
					--Nombre Calle
					/*SELECT b.nombrecalle 
						INTO v_addres_number3
					FROM bdinteg: si_direcciones_actual a
						INNER JOIN bdinteg: si_catcalles b ON a.numerocalle = b.numerocalle
					WHERE  a.tipo_dir = '3' AND a.numcte = v_user_defined1;*/
					
							
					SELECT nombrecalle 	INTO v_addres_number3 FROM  bdinteg:si_catcalles  WHERE  numerocalle = v_num_calle_3;
					
					--Estado
					/*SELECT a.nombre 
						INTO v_province3
					FROM bdinteg: si_estados a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.estado = b.estado 
					WHERE b.tipo_dir = '3' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_province3 FROM bdinteg:si_estados WHERE estado = v_estado_3;
					
					--Pais
					
					/*SELECT a.nombre
						INTO v_country3
					FROM bdinteg:si_paises a
						INNER JOIN bdinteg: si_direcciones_actual b ON a.pais = b.pais
					WHERE b.tipo_dir = '3' AND b.numcte = v_user_defined1;*/
					
					SELECT nombre INTO v_country3 FROM bdinteg:si_paises WHERE pais = v_pais_3;
					
					--
					--Po_box3
					--Mismo codigo postal
					LET v_po_box3 = v_zone3;
					--
					--strata3
					LET v_strata3 = NULL;
					--
					--Fin
				
					--Ocupation, Profession
					/*SELECT b.descripcion, d.descripcion
						INTO v_ocupation, v_profession
					FROM bdinteg: si_ctepf a
						INNER JOIN bdinteg: si_escolaridad_am b ON b.elemento = a.escolaridad
						INNER JOIN bdinteg: si_profesion d ON d.profesion = a.profesion
					WHERE a.numcte = v_user_defined1;*/
					--
					SELECT descripcion INTO v_ocupation FROM bdinteg:si_escolaridad_am WHERE elemento = v_escolaridad;
					SELECT descripcion INTO v_profession FROM bdinteg:si_profesion WHERE profesion = v_num_profeccion;
					
					--Income, Persons_In_Chargue
					SELECT ingreso_mensual, bs_score
						INTO v_income, v_qualification
					FROM bdisolic:ss_revision_determinacion
					WHERE num_solicitud = v_account_number 
						AND numcte= v_user_defined1;
					
					--Persons_In_Chargue
					/*SELECT dependientes
						INTO v_persons_in_charge
					FROM bdinteg: si_ctepf
						WHERE numcte = v_user_defined1;*/
					
					--Numero de cliente
					LET v_user_defined1 = v_user_defined1;
									
					LET v_income = NVL(NULLIF(v_income, ''), '0');
					/*IF v_income = '' OR v_income IS NULL THEN
						LET v_income = 0;
					END IF;*/
					
					LET v_persons_in_charge = NVL(NULLIF(v_persons_in_charge, ''), '0');
					/*IF v_persons_in_charge = '' OR v_persons_in_charge IS NULL THEN
						LET v_persons_in_charge = '0';
					END IF;*/
					
					LET v_telephone_number1 = replace(replace(v_telephone_number1,chr(9),''),chr(10),'');
					LET v_telephone_number2 = replace(replace(v_telephone_number2,chr(9),''),chr(10),'');
					
					INSERT INTO ics_personas
						(customer_id, identity_code, account_number, seq, first_surname,	first_name, sex, civil_status, address_type1, zone1, city1,                       
						use_this_1, address_type2, zone2, city2, use_this_2, telephone_type1, addr_tel_type1, telephone_type2,             
						addr_tel_type2, income_payment_type, income_payment_day, reviewed, company, second_surname,midlle_name, birth_date,                  
						addres_number1, province1, country1, po_box1, strata1, addres_number2, province2, country2, po_box2, strata2,                    
						area_code1, telephone_number1, extention1, county_code1, area_code2, telephone_number2, extention2, county_code2,                
						ocupation, profession, income, persons_in_charge, work_timetable_start, work_timetable_end, user_defined1, return_id,					
						qualification, common_id, latitude1, longitude1, latitude2, longitude2, fecha_ejecucion)
					VALUES
						(v_customer_id, v_identity_code, v_account_number, v_seq, v_first_surname,	v_first_name, v_sex, v_civil_estatus, v_address_type1, v_zone1, v_city1,                       
						
						
						
						
						
						
						v_use_this_1, v_address_type2, v_zone2, v_city2, v_use_this_2, v_telephone_type1, v_addr_tel_type1, v_telephone_type2,             
						v_addr_tel_type2, v_income_payment_type, v_income_payment_day, v_reviewed, v_company, v_second_surname, v_middle_name, v_birth_date_char,                  
						
						
						
						
						v_addres_number1, v_province1, v_country1, v_po_box1, v_strata1, v_addres_number2, v_province2, v_country2, v_po_box2, v_strata2,                    
						v_area_code1, v_telephone_number1, v_extention1, v_county_code1, v_area_code2, v_telephone_number2, v_extention2, v_county_code2,                
						v_ocupation, v_profession, v_income, v_persons_in_charge, v_work_timetable_start, v_work_timetable_end, v_user_defined1, v_return_id,					
						v_qualification, v_common_id, v_latitude1, v_longitude1, v_latitude2, v_longitude2, c_fecha_ejecucion);
				
						LET iContador = iContador + 1;
						LET iContador1 = iContador1 + 1;
				
					IF  v_addres_number3 IS NOT NULL OR  v_zone3 IS NOT NULL OR v_city3 IS NOT NULL OR v_telephone_number3 IS NOT NULL THEN
						
						LET v_seq = v_seq + 1;
						LET v_extention3 = '0';
						LET v_extention4 = '0';
						LET v_telephone_number4 = '0';
						LET v_telephone_number3 = replace(replace(v_telephone_number3,chr(9),''),chr(10),'');
				
						INSERT INTO ics_personas
							(customer_id, identity_code, account_number, seq, first_surname,first_name, sex, civil_status, address_type1, zone1, city1,                       
							use_this_1, address_type2, zone2, city2, use_this_2, telephone_type1, addr_tel_type1, telephone_type2,             
							addr_tel_type2, income_payment_type, income_payment_day, reviewed, company, second_surname,midlle_name, birth_date,                  
							addres_number1, province1, country1, po_box1, strata1, addres_number2, province2, country2, po_box2, strata2,                    
							area_code1, telephone_number1, extention1, county_code1, area_code2, telephone_number2, extention2, county_code2,                
							ocupation, profession, income, persons_in_charge, work_timetable_start, work_timetable_end, user_defined1, return_id,					
							qualification, common_id, latitude1, longitude1, latitude2, longitude2, fecha_ejecucion)
						VALUES
							(v_customer_id, v_identity_code, v_account_number, v_seq, v_first_surname,	v_first_name, v_sex, v_civil_estatus, v_address_type3, v_zone3, v_city3,                       
							v_use_this_3, v_address_type4, v_zone4, v_city4, v_use_this_4, v_telephone_type3, v_addr_tel_type3, v_telephone_type4,             
							v_addr_tel_type4, v_income_payment_type, v_income_payment_day, v_reviewed, v_company, v_second_surname, v_middle_name, v_birth_date_char,                  
							v_addres_number3, v_province3, v_country3, v_po_box3, v_strata3, v_addres_number4, v_province4, v_country4, v_po_box4, v_strata4,                    
							v_area_code3, v_telephone_number3, v_extention3, v_county_code3, v_area_code3, v_telephone_number4, v_extention4, v_county_code4,                
							v_ocupation, v_profession, v_income, v_persons_in_charge, v_work_timetable_start, v_work_timetable_end, v_user_defined1, v_return_id,					
							v_qualification, v_common_id, v_latitude1, v_longitude1, v_latitude2, v_longitude2, c_fecha_ejecucion);
							
							LET iContador = iContador + 1;
							LET iContador1 = iContador1 + 1;
							LET v_seq = 1;
					
					END IF;
				--END IF;
				--LET iContador1 = iContador1 + 1;
				
				IF iContador1 >= 100000 THEN
					LET horaActual = CURRENT;
					INSERT INTO ics_tiempos (num_registro, hora, proceso) 
					VALUES (iContador1, horaActual, 'CICLO_PER');
					
					/*SELECT DBINFO("utc_to_datetime", sh_curtime) 
						INTO horaActual 
					FROM sysmaster:sysshmvals;
					INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'CICLO_PER');*/
					LET iContador1 = 0;
				END IF; 
				
				
				IF iContador >= 1000 THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF; 
				
			END FOREACH;
			
				LET horaActual = CURRENT;
				INSERT INTO ics_tiempos (num_registro, hora, proceso) 
				VALUES (iContador1, horaActual, 'FIN_CICLO_PER');
			/*SELECT DBINFO("utc_to_datetime", sh_curtime) 
				INTO horaActual 
			FROM sysmaster:sysshmvals;
			INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'FIN_CICLO_PER');*/
			
		COMMIT WORK;
		
		LET  v_transaccion = 0;
		
		
	RETURN v_cod_ret;
	
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	iCS',
'CreaciÃÂÃÂ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Oct 2021',
'Requerimiento	:	RQM 09 596',
'VERSION		: 	1.0.0';

CREATE PROCEDURE "informix".apercred1_tc_upgrade(
			P_EMPRESA       VARCHAR(3),
			P_SOLICITUD     VARCHAR(20),
		 	P_EJECUTIVO     CHAR(8),
			P_SUCURSAL		CHAR(4))   --Sucursal para actualizar registro en sd_maecred  --DSB 22/05/2020
RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);
--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la busqueda de tabla si_ingresos

-----------------------------------------------------------------------------------------------------
-- MODIFICO:Jonathan Medina
-- FECHA:22/05/2020
-- DESCRIPCION: Se agrega parametro P_SUCURSAL para actualziar la tabla sd_maecred, cuando el cliente tenga una solicitud web y el producto sea 6001
-- SOLICITO: ABRAHAM NARVAEZ
-- FOLIO: 675  Adendum Solicitud Web Tarjeta de Credito Bancoppel y Tarjeta Departamental Coppel
-- DSB 22/05/2020
------------------------------------------------------------------------------------------------------

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE V_SECUENCIA_MAX       INTEGER;
DEFINE V_EQ_DIAS             INTEGER;
DEFINE V_EXISTE_REG          INTEGER;
DEFINE P_ERROR               VARCHAR(8);
DEFINE P_MENSAJE             VARCHAR(80);
DEFINE V_DIF_INT             INTEGER;
DEFINE V_FECHA_FIN_PRORRATEO DATE;
DEFINE V_INSERT              INTEGER;
DEFINE V_E_CODTRASP          INTEGER;
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_TASA_FAVOR          DECIMAL(9,6);
DEFINE V_SOBRETASA_FAV       DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_FACTOR_MORA         CHAR(1);
DEFINE V_FECHA_APERT         DATE;
DEFINE V_FECHA_VENC          DATE;
define v_num_credito         char(20);
define vdigverif             char(1);
DEFINE SQL_ERR               INTEGER;
DEFINE ISAM_ERR              INTEGER;
DEFINE ERROR_INFO            VARCHAR(80);
define vcodret               char(5);
DEFINE vNumCte               CHAR(20);
DEFINE vTpCte                CHAR(1);
DEFINE vIngreso              DECIMAL(14,2);
DEFINE V_FACTOR_FAV          CHAR(1);
DEFINE V_PRODUCTO            CHAR(4);
DEFINE VV_DIVISA             CHAR(2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE VV_SUCURSAL           CHAR(4);
DEFINE VV_FOLIO	             CHAR(16);
DEFINE vMensaje              CHAR(200);
DEFINE vFechaT               DATE;
DEFINE vDiaCorte        SMALLINT;
DEFINE i                SMALLINT;
DEFINE V_CATIVA		    DECIMAL(9,6);
DEFINE V_MERCADEO       CHAR(1);
DEFINE iSecIngreso      SMALLINT;
---I---RQM 10 960 TDC GC
DEFINE vPtosTasaPref		DECIMAL(9,6);
DEFINE vIdTasaFref			CHAR(1);
DEFINE v_cont				INTEGER;
---F---RQM 10 960 TDC GC						
--RQM 10 679 AAME
DEFINE cCodRetOro       CHAR(6);
DEFINE cMenRet          VARCHAR(100,1);
DEFINE dLinea           DECIMAL(18,2)	;
DEFINE cSolOro          CHAR(20) ;
DEFINE iConfirmaOro		SMALLINT ;
DEFINE cTelCel          CHAR(10) ;
DEFINE cCodRet          CHAR(6) ;
DEFINE cCodRetTDif		CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE dFechaT          DATE;
DEFINE iDiaPago      	INTEGER;
DEFINE iFrecuencia      INTEGER;

DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal        DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);

DEFINE cCobro_Apertu    CHAR(1);            -- INI RQM 10 993 CAT
DEFINE cCodComis_Apert  CHAR(4);
DEFINE cCobrComisAnual  CHAR(1);
DEFINE dClvComAnualTit  CHAR(4);
DEFINE dClvComAnualAdi  CHAR(4);      
DEFINE cCat_adicional   CHAR(1);            
DEFINE dMtoComAnualTit  DECIMAL(18,2);
DEFINE dMtoComAnualAdi  DECIMAL(18,2);			  
DEFINE mMntoComApert    DECIMAL(18,2);      
DEFINE dComisiones      DECIMAL(18,2);
DEFINE mMntoComAnual    DECIMAL(18,2);      -- FIN RQM 10 993 CAT
DEFINE dComs_GastCob	DECIMAL(18,2);		-- RQM 10 1253
--- Cuenta Clabe
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE gpo              CHAR(1); --RQM 10 1225
DEFINE evalcc           CHAR(1); --RQM 10 1225
DEFINE v_idi            CHAR(1); --RQM 10 1225
DEFINE vDispEfec        CHAR(1); --RQM 10 1225
DEFINE v_indde          SMALLINT; --RQM 10 1225

DEFINE BD_Solicitud		INTEGER;


DEFINE iSolicitud		SMALLINT; --DSB 22/05/2020

--IFRS
DEFINE val_ifrs  char(1);
DEFINE stat_aper char(2);
DEFINE vAct      Integer;
-- CAX 26112024
DEFINE valida_sucursal SMALLINT;
DEFINE sucursal_cred CHAR(7);
DEFINE num_tarje_sol SMALLINT;

--SET DEBUG FILE TO "/RESPALDOS/PruebasIFSR/ADN/out/apercred1_tc_upgrade.out";
--TRACE ON;

LET V_TASA_MORA = 0;
LET V_TASA_INTERES = 0;
LET V_MERCADEO = "";

---I---RQM 10 960 TDC GC
LET vPtosTasaPref = 0;
LET vIdTasaFref = "";
LET v_cont = 0;
---F---RQM 10 960 TDC GC					

--RQM 10 679 AAME
LET  cCodRetOro	= "";
LET  cMenRet = "";
LET  dLinea	 = 0;
LET  cSolOro = "";
LET  iConfirmaOro = 0;

LET cTelCel = "";
LET dFechaT = DATE(1);
LET iDiaPago = 0;
LET iFrecuencia = 0;
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET cCodRetTDif			= '';
LET vCatFinal =0;
LET dPagoReq =0;

LET cCobro_Apertu    = '';          -- INI RQM 10 993 CAT
LET cCodComis_Apert  = '';
LET cCobrComisAnual  = '';
LET dClvComAnualTit  = '';
LET dClvComAnualAdi  = '';
LET cCat_adicional   = '';
LET dMtoComAnualTit  = 0;
LET dMtoComAnualAdi  = 0;
LET mMntoComApert    = 0;
LET mMntoComAnual    = 0;
LET dComisiones      = 0;           -- FIN RQM 10 993 CAT
LET V_SOBRETASA		= 0;
LET V_SOBRETASA_MORA =0;
LET V_FACTOR	    = "";
LET V_FACTOR_MORA   = "";
LET dComs_GastCob	 = 0;			-- RQM 10 1253
--- Cuenta Clabe
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET gpo              =''; --RQM 10 1225
LET evalcc           =''; --RQM 10 1225
LET v_idi            =''; --RQM 10 1225
LET vDispEfec        =''; --RQM 10 1225
LET v_indde          = 0; --RQM 10 1225

LET BD_Solicitud		= 0;	


LET iSolicitud       = 0; --DSB 22/05/2020
--IFRS
LET val_ifrs ='';
LET stat_aper ='';
LET vAct = 0;

LET valida_sucursal = 0; -- CAX112024 valida sucursal
LET sucursal_cred = '';
LET num_tarje_sol = 0;

--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
SELECT valor INTO V_CATIVA
FROM   sd_param
WHERE  cod_param = '034';
IF V_CATIVA IS NULL THEN
   LET V_CATIVA = 0;
END IF


BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	

	 DELETE FROM SD_MAESDOS
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

	 DELETE FROM SD_MOVDIA
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

	 DELETE FROM SD_MAECREDANEXO
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

         UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AT"
          WHERE empresa = P_EMPRESA
            AND num_solicitud = P_SOLICITUD;

         DELETE FROM bdisolic:ss_autorizacion
          WHERE empresa = P_EMPRESA
            AND num_solicitud = P_SOLICITUD
	    AND status_solicitud = "AP";

	 DELETE FROM bdicred:sd_amortiza_credito
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

	 DELETE FROM SD_MAECRED
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM SD_INDICADOR_CRED
	  WHERE EMPRESA = P_EMPRESA
	    AND NUM_CREDITO = P_SOLICITUD;
		
		DELETE FROM bdicred:sd_tarjeta 
		WHERE NUM_CREDITO = P_SOLICITUD;
		
         RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
    END EXCEPTION;

      --***********************
      --INICIALIZA VARIABLE
      --***********************


    LET V_EXISTE_REG = 0;
    LET P_ERROR      = '00000';
    LET P_MENSAJE    = 'PROCESO EXITOSO';
    LET V_EQ_DIAS    = 0;
    LET V_DIF_INT    = 0;
    LET V_FECHA_FIN_PRORRATEO = NULL;
    LET v_num_credito = "";
    LET i = 0;

    -- ******************
    -- Determina Fechas *
    -- ******************
	--	SELECT fecha_hoy, fecha_hoy + 12 units month

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
IF P_SOLICITUD = "650000000000" THEN --TDC PAY
  LET P_ERROR      = '00000';
  LET P_MENSAJE    = 'PROCESO EXITOSO';
  LET V_CATIVA = 0;

ELSE --TDC PAY
	
	
    SELECT fecha_hoy
	INTO V_FECHA_APERT
	FROM sd_fechas
	WHERE empresa = P_EMPRESA;

    let  V_FECHA_VENC=date(0);

    call monthadd(V_FECHA_APERT,12) returning V_FECHA_VENC;

	---AAME RQM 10 679 Se lee si la solicitud es candidato a oro y confirmo que si la quiere en la pantalla de asignacion
	SELECT  confirma_oro	
	INTO iConfirmaOro
	FROM  bdisolic:"informix".ss_solicitudes_tdcoro 
	WHERE numero_solicitud_oro = P_SOLICITUD;

	--VAlida si esta activo el IFRS	
	select nvl(valor,'I') into val_ifrs from sd_param where cod_param = '700';

	IF val_ifrs = 'A' THEN
		LET stat_aper = 'E1';
		LET vAct      = 0;
	ELSE
		LET stat_aper = 'AA';
		LET vAct      = NULL;
	END IF;
	  
	 
	IF  NVL(iConfirmaOro,0) = 1 THEN --AAME RQM 10 679 Clientes que se les apertura la solicitud de oro
		SELECT valor INTO V_CATIVA
		FROM   "informix".sd_param
		WHERE  cod_param = '093';
		
	END IF;
	
	---- CAX Se agrega validacion para obtener tarjeta asignada
	SELECT count(*) into num_tarje_sol FROM bdicred:sd_tarjeta WHERE NUM_CREDITO = P_SOLICITUD;
	 
	
    -- ****************************
    -- Determina Tasas de Interes *
    -- ****************************
						
	--INTERES ORDINARIO E INTERES MORATORIO
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(P_EMPRESA, P_SOLICITUD, '') INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
	IF cCodRetTDif <> '000000' THEN
		LET P_ERROR = cCodRetTDif;
		
		IF num_tarje_sol > 0 THEN
			DELETE FROM bdicred:sd_tarjeta WHERE NUM_CREDITO = P_SOLICITUD;
		END IF;
		
		RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
	/*SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref
	  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte, vIdTasaFref, vPtosTasaPref
	  FROM sd_definicion a, bdisolic:ss_solicitudes b,
	       bdinteg:si_fechavalor c
	 WHERE b.empresa = P_EMPRESA
	   AND num_solicitud = P_SOLICITUD
	   AND a.empresa = b.empresa
	   AND a.num_producto = b.num_producto
	   AND c.empresa = a.empresa
	   AND c.tasa = a.cod_tasa_base
	   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
			   WHERE r.empresa = P_EMPRESA
			     AND r.tasa = a.cod_tasa_base);
	*/				--	RQM 10 1224

	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.id_tasa_pref, a.puntos_tasa_pref, a.fact_sobret_mora, a.sobretasa_mora, a.ind_disp_efec
	INTO V_FACTOR,           V_SOBRETASA, vDiaCorte,   vIdTasaFref,    vPtosTasaPref,		 V_FACTOR_MORA,		 V_SOBRETASA_MORA, vDispEfec
	FROM sd_definicion a
	INNER JOIN bdisolic:ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto AND b.num_solicitud = P_SOLICITUD)
	WHERE a.empresa = P_EMPRESA;

	IF v_factor = "+" THEN
		LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
	ELIF v_factor = "-" THEN
		LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
	ELIF v_factor = "*" THEN
		LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
	ELSE
		LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
	END IF

	---I---RQM 10 960 TDC GC
	---- VALIDACION PARA CALCULO DE TASA PREFERENCIAL
	IF vIdTasaFref = '1' THEN
	
		SELECT COUNT (*) 
		INTO v_cont
		FROM bdicred:"informix".sd_ctascarg
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
	
		IF v_cont <> 0 THEN
			LET V_TASA_INTERES = V_TASA_INTERES - vPtosTasaPref;
		END IF
		
		IF V_TASA_INTERES < 0 THEN
			LET V_TASA_INTERES = 0;
		END IF
		
	END IF
	---F---RQM 10 960 TDC GC						 
						   
	--INTERES MORATORIO
    /*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
    INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
    FROM sd_definicion a, bdisolic:ss_solicitudes b,
    bdinteg:si_fechavalor c
    WHERE b.empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto
    AND c.empresa = a.empresa
    AND c.tasa = a.cod_tasa_mora
    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
    WHERE r.empresa = P_EMPRESA
    AND r.tasa = a.cod_tasa_mora);
	*/

    IF V_FACTOR_MORA = "+" THEN
            LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
    ELIF V_FACTOR_MORA = "-" THEN
            LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
    ELIF V_FACTOR_MORA = "*" THEN
            LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
    ELSE
            LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
    END IF

    --INTERES A FAVOR DEL CLIENTE
    SELECT c.valor, a.factor_sobretasa, a.sobretasa
    INTO V_TASA_FAVOR   , V_FACTOR_FAV, V_SOBRETASA_FAV
    FROM sd_anexodefinicion a, bdisolic:ss_solicitudes b,
    bdinteg:si_fechavalor c
    WHERE b.empresa = P_EMPRESA
    AND num_solicitud = P_SOLICITUD
    AND a.empresa = b.empresa
    AND a.num_producto = b.num_producto
    AND c.empresa = a.empresa
    AND c.tasa = a.cod_tasa_base
    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
    WHERE r.empresa = P_EMPRESA
    AND r.tasa = a.cod_tasa_base);

    IF V_FACTOR_FAV = "+" THEN
            LET V_TASA_FAVOR = V_TASA_FAVOR + V_SOBRETASA_FAV;
    ELIF V_FACTOR_FAV = "-" THEN
            LET V_TASA_FAVOR = V_TASA_FAVOR - V_SOBRETASA_FAV;
    ELIF V_FACTOR_FAV = "*" THEN
            LET V_TASA_FAVOR = V_TASA_FAVOR * V_SOBRETASA_FAV;
    ELSE
            LET V_TASA_FAVOR = V_TASA_FAVOR / V_SOBRETASA_FAV;
    END IF

	--***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)



	SELECT a.num_producto, a.divisa, b.monto_solicitado, b.sucursal, nvl(a.cobro_comis_apertura,'0'), nvl(a.cod_comision_apertura,''), 
	a.cobro_comision_anual, substr(a.cod_comision_anualidad,1,4), substr(a.cod_comision_anualidad,5,4), a.cat_comi_anual_adicional 
	INTO V_PRODUCTO, VV_DIVISA, V_MONTO, VV_SUCURSAL, cCobro_Apertu, cCodComis_Apert, cCobrComisAnual, dClvComAnualTit, dClvComAnualAdi, cCat_adicional
	FROM bdisolic:ss_solicitudes b, sd_definicion a
	WHERE b.empresa = P_EMPRESA
	AND b.num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto;
		
	/*Se valida que el monto no sea nulo, negativo abril 2024*/
	IF V_MONTO is null OR V_MONTO = '' OR V_MONTO < 0 THEN
		LET V_MONTO = 0;
	END IF;
	
	-- CAX 09092025 se valida sucursal S operativa
	SELECT count(*) INTO valida_sucursal FROM bdinteg:si_sucursales WHERE sucursal = P_SUCURSAL and tpo_sucursal = 'S' and empresa ='001';
	
	IF valida_sucursal = 0 THEN
		LET P_ERROR = '00100';
		LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
		
		IF num_tarje_sol > 0 THEN
			DELETE FROM bdicred:sd_tarjeta WHERE NUM_CREDITO = P_SOLICITUD;
		END IF;
		
		RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
	END IF;
	
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,V_PRODUCTO)
	INTO vcod_ret, cta_Clabe;		  
	
	--***** ACTUALIZA SD_MAECRED
			
	INSERT INTO bdicred:sd_maecred
				(EMPRESA                ,NUM_CREDITO
				,NUM_PRODUCTO           ,EJECUTIVO
				,NUMCTE                 ,DIVISA
				,SUCURSAL               ,ID_ORIGEN
				,ORIGEN                 ,COD_TIPO_LINEA
				,COD_LINEA              ,PORC_REC_PROP
				,STATUS_CRED            ,BANDERA_RENOVAC
				,BANDERA_PRORROGA       ,PERIODO_PLAZO
				,PLAZO                  ,FECHA_APERTURA
				,FECHA_VENCIM           ,PERIOD_PAGO_CAP
				,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
				,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
				,COD_TASA_BASE          ,FACTOR_SOBRETASA
				,SOBRETASA              ,TASA_INTERES
				,COD_TASA_MORA          ,SOBRETASA_MORA
				,FACT_SOBRET_MORA       ,TASA_MORATORIOS
				,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
				,ES_FISICA              ,BANDERA_FI_FO
				,CODIGO_PRO             ,SUPERFICIE
				,ACTIVIDAD              ,CAL_EDOS_FIN
				,TIPO_CALCULO           ,ADMITE_TLP
				,REL_GARCRED            ,ID_UNIDAD_PROD
				,NUM_APER_ANT           ,REV_TASA_VAR_PER
				,DIA_PARA_REVISAR       ,COD_PROD
				,BANDERA_MINISTRA       ,NUM_FIDEICOMISO
				,CREDITO_EXTERNO        ,GRACIA_CAPITAL
				,DIFERIMIENTO_INT       ,FECHA_FIN_PRORRATEO
				,CAMPO_TRAB1            ,CAMPO_TRAB2
				,CAMPO_TRAB3            ,CAMPO_TRAB4
				,CALIFICACION_RIESGO    ,COD_AGRICOLA
				,TASA_BASE_PISO         ,SOBRETASA_PISO
				,FACTOR_PISO            ,TASA_PISO
				,TASA_BASE_TECHO        ,SOBRETASA_TECHO
				,FACTOR_TECHO           ,TASA_TECHO
				,cuenta_clabe
				)
		SELECT SOL.EMPRESA                ,P_SOLICITUD
				,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
				,SOL.NUMCTE                 ,DEF.DIVISA
				,SOL.SUCURSAL               ,''
				,''                         ,''
				,''                         ,100
				,stat_aper                  ,'N'
				,'N'                        ,DEF.PERIODO_PLAZO
				,0                          ,V_FECHA_APERT
				,V_FECHA_VENC               ,"3"
				,"2"                        ,CTR.DIAS_TRAS_CAP
				,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
				,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
				,DEF.SOBRETASA              ,V_TASA_INTERES
				,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
				,DEF.FACT_SOBRET_MORA       ,V_TASA_MORA
				,''                         ,''
				,TIP.ES_FISICA              ,''
				,DEF.COD_PROD               ,0
				,''                         ,''
				,DEF.TIPO_CALCULO           ,''
				,0                          ,''
				,''                         ,DEF.REV_TASA_VAR_PER
				,DEF.DIA_PARA_REVISAR       ,''
				,'M'                        ,''
				,''                         ,0
				,0                          ,V_FECHA_APERT
				,0                          ,0
				,''                         ,CASE WHEN (DEF.NUM_PRODUCTO='8100') THEN '1' ELSE '' END
				,'A'                        ,''
				,''                         ,''
				,''                         ,''
				,''                         ,''
				,''                         ,''
				,cta_Clabe
			FROM   BDISOLIC:SS_SOLICITUDES SOL
				, BDISOLIC:SS_ANEXOSOL    ANX
				, BDINTEG:SI_CLIENTE      CLI
				, BDINTEG:SI_TIPPER       TIP
				, SD_CODTRASP             CTR
				, SD_DEFINICION           DEF
			WHERE  DEF.EMPRESA         = SOL.EMPRESA
			AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
			AND    CTR.PERIOD_PAG_INT  = "2"
			AND    CTR.PERIOD_PAGO_CAP = "3"
			AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
			AND    CTR.EMPRESA         = DEF.EMPRESA
			AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
			AND    CLI.NUMCTE          = SOL.NUMCTE
			AND    CLI.EMPRESA         = SOL.EMPRESA
			AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
			AND    ANX.EMPRESA         = SOL.EMPRESA
			AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
			AND    SOL.EMPRESA         = P_EMPRESA;
			
		SELECT COUNT(*) INTO  BD_Solicitud FROM bdisolic:ss_solicitudes 
		WHERE num_solicitud = P_SOLICITUD AND user_insert = 'sys_cred';
				
		IF(BD_Solicitud = 1) THEN
			UPDATE bdicred:"informix".sd_maecred SET sucursal = P_SUCURSAL WHERE num_credito = P_SOLICITUD;
			LET VV_SUCURSAL = P_SUCURSAL;
		END IF
			
		--LET V_INSERT = DBINFO("SQLCA.SQLERRD1");
		--IF V_INSERT = 0 THEN
		--LET P_ERROR = '00001';
		--LET P_MENSAJE = 'EXISTE ERROR EN LA INFORMACION DEL CREDITO';
		--RETURN P_ERROR, P_MENSAJE,v_num_credito;
		--END IF;
			
			
		--DSB 22/05/2020 INICIO
		SELECT COUNT(num_solicitud)
		INTO iSolicitud
		FROM bdisolic:"informix".ss_prospecteo_solicitudes
		WHERE num_solicitud = P_SOLICITUD
		AND canal_sol = 4;
				
		IF iSolicitud > 0 THEN			
			UPDATE bdicred:"informix".sd_maecred SET sucursal = P_SUCURSAL WHERE num_credito = P_SOLICITUD AND sucursal = '8503';
		END IF; --DSB 22/05/2020 FIN
		
		/*CAX Se agrega validacion para sucursal operativa*/
		LET valida_sucursal = 0;
		
		SELECT sucursal into sucursal_cred from bdicred:sd_maecred where num_credito = P_SOLICITUD;
		SELECT count(*) INTO valida_sucursal FROM bdinteg:si_sucursales WHERE sucursal = sucursal_cred and tpo_sucursal = 'N' and empresa ='001';
		
		IF valida_sucursal > 0 THEN
			UPDATE bdicred:"informix".sd_maecred SET sucursal = P_SUCURSAL WHERE num_credito = P_SOLICITUD AND sucursal = '8503';
		END IF;
		
	
		--***** ACTUALIZA SD_MAESDOS
			
		INSERT INTO SD_MAESDOS (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
								,ACT
                                )
                          SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,TODAY                  ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,V_MONTO 				,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
								,vAct
                          FROM   BDISOLIC:SS_SOLICITUDES SOL
                          WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;
		SELECT USER
		|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
		INTO VV_FOLIO
		FROM sd_fechas;


		EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_SOLICITUD,
	                          V_PRODUCTO        , 1,
                                "001"             , V_FECHA_APERT,
                                V_MONTO           , VV_FOLIO,
                                VV_SUCURSAL       ,VV_DIVISA,
                                "0000")
		INTO P_ERROR, P_MENSAJE;

		-- *********************************************************
		-- INSERTA PRIMEROS 12 MESES DE LA TABLA DE AMORTIZACIONES *
		-- *********************************************************
		IF V_PRODUCTO  <> "7800" THEN
			LET vFechaT = MONTH(V_FECHA_APERT) || "/" || vDiaCorte || "/" ||
			YEAR(V_FECHA_APERT);
			IF DAY(V_FECHA_APERT) > vDiaCorte THEN
					CALL sp_calcula_fecha ("001" ,1 ,"M" ,vFechaT ,"01" ,"01")
					RETURNING P_ERROR, P_MENSAJE, vFechaT;
			END IF
			
			FOR i = 1 TO 12
			
				INSERT INTO sd_amortiza_credito values
				(P_EMPRESA,P_SOLICITUD,vFechaT,"3",0,0,0,"1","0","",
				0,0,"1","0","",
				0,0,"1","0","",
				0,0,0,0,0,0,0,"1",
				0,0,"1","",
				i,0,0,"","");
			
				EXECUTE PROCEDURE sp_calcula_fecha
				(P_EMPRESA ,1 ,"M" ,vFechaT ,"01" ,"01")
						INTO P_ERROR, P_MENSAJE, vFechaT;
			END FOR
		END IF
		-- **************************************
		-- Actualiza el Estatus de la Solicitud *
		-- **************************************
			
		UPDATE bdisolic:ss_solicitudes SET status_solicitud = "AP"
		WHERE empresa = P_EMPRESA
		AND num_solicitud = P_SOLICITUD;
		
		SELECT nombre INTO vMensaje
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = P_EJECUTIVO
		AND empresa = P_EMPRESA;
			
		LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);
		
		INSERT INTO bdisolic:ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud,
					comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
				VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
					V_FECHA_APERT, V_FECHA_APERT, USER, TODAY);
			
		INSERT INTO bdicred:"informix".sd_indicador_cred
						(empresa,num_credito, fecha_alta)
					VALUES(P_EMPRESA,P_SOLICITUD,V_FECHA_APERT );
		-- ******************************
		-- Actualiza Datos del Cliente  *
		-- ******************************
			
		SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
		INTO vNumCte, vTpCte, vIngreso
		FROM bdinteg:si_cliente a, bdisolic:ss_solicitudes b,
		bdisolic:ss_resum_scor_fin c
		WHERE a.numcte = b.numcte
		AND b.empresa = P_EMPRESA
		AND b.num_solicitud = P_SOLICITUD
		AND c.empresa = b.empresa
		AND c.num_solicitud = b.num_solicitud;
			
		-- Saca la Publicacion de si_ctepf Jose Luis Puebla
		SELECT string1 INTO V_MERCADEO 
		FROM   bdinteg:si_ctepf 
		WHERE  numcte = vNumCte;
				
				
	  
		IF  V_PRODUCTO   =  "7800" THEN

			--Se actualiza la solicitud de credito ligada a la cuenta y movil	
			SELECT  movil_cuenta ,frecuencia_pgo
			INTO cTelCel ,iFrecuencia
			FROM   bdisolic:"informix".ss_adn_solicitudcuenta		
			WHERE numcte = vNumCte
			AND num_solicitud  = P_SOLICITUD;
		
		
			--se obtiene la fecha de la proxima cuota.
			EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapagoadn('001',V_FECHA_APERT,P_SOLICITUD)
			INTO cCodRet,dFechaT,iDiaPago;
			
			INSERT INTO sd_maecredanexo
				(empresa,               num_credito,
				dia_corte,             dias_gracia_mora,
				tp_dias_calc_mora,     dias_fecha_max_pago,
				tp_dias_fecha_pago,    cod_tasa_base_cte,
				factor_sobretasa_cte,  sobretasa_cte,
				tasa_interes_cte,      fecha_proceso,prox_fecha_pago )
			SELECT P_EMPRESA,               P_SOLICITUD,
				DAY(dFechaT),           def.gracia_calc_mora,
				def.pago_adic_sig_cuo,   def.tipo_cliente,
				iFrecuencia,        def.cod_tasa_base,
				def.factor_sobretasa,    def.sobretasa,
				V_TASA_FAVOR,            V_FECHA_APERT ,dFechaT
			FROM sd_definicion def, sd_anexodefinicion b,
				bdisolic:ss_solicitudes c
			WHERE c.empresa = P_EMPRESA
			AND c.num_solicitud = P_SOLICITUD
			AND def.empresa = c.empresa
			AND def.num_producto = c.num_producto
			AND b.empresa = def.empresa
			AND b.num_producto = c.num_producto
			AND b.cod_prod = def.cod_tipcred;

	   
	   
			-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
			/*INSERT INTO "informix".sd_amortiza_credito
				(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
			)
			VALUES
			(
			P_EMPRESA,			P_SOLICITUD,
			dFechaT,			"3",
			0,					0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
			);*/

		ELSE
			INSERT INTO sd_maecredanexo
			(empresa,               num_credito,
			dia_corte,             dias_gracia_mora,
			tp_dias_calc_mora,     dias_fecha_max_pago,
			tp_dias_fecha_pago,    cod_tasa_base_cte,
			factor_sobretasa_cte,  sobretasa_cte,
			tasa_interes_cte,      fecha_proceso )
			SELECT P_EMPRESA,               P_SOLICITUD,
			def.dia_cuota,           def.gracia_calc_mora,
			def.pago_adic_sig_cuo,   def.tipo_cliente,
			def.maneja_linea,        def.cod_tasa_base,
			def.factor_sobretasa,    def.sobretasa,
			V_TASA_FAVOR,            V_FECHA_APERT
			FROM sd_definicion def, sd_anexodefinicion b,
			bdisolic:ss_solicitudes c
			WHERE c.empresa = P_EMPRESA
			AND c.num_solicitud = P_SOLICITUD
			AND def.empresa = c.empresa
			AND def.num_producto = c.num_producto
			AND b.empresa = def.empresa
			AND b.num_producto = c.num_producto
			AND b.cod_prod = def.cod_tipcred;


		END IF


	
		IF vTpCte = "1" THEN
			SELECT MAX(sec_ingreso) INTO iSecIngreso FROM bdinteg:si_ingresos WHERE empresa = P_EMPRESA
			AND numcte = vNumCte AND tipo_ingreso = 'T';
		
			UPDATE bdinteg:si_ingresos
			SET ingreso_mensual = vIngreso
			WHERE empresa = P_EMPRESA
			AND numcte = vNumCte
			AND tipo_ingreso = "T"
			AND sec_ingreso = iSecIngreso;
		ELSE
	
			UPDATE bdinteg:si_cliente
			SET tipo_cliente = "1"
			WHERE numcte = vNumCte;
		
			SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO iSecIngreso
			FROM bdinteg:si_ingresos 
			WHERE empresa = P_EMPRESA 
			AND numcte = vNumCte 
			AND tipo_ingreso = "T";

			INSERT INTO bdinteg:si_ingresos
			(empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
			VALUES
			(P_EMPRESA, vNumCte, iSecIngreso, "T", vIngreso);
		END IF

		-- Resta el Valor de la Tasa Moratoria con la de Intereses
		-- Solicitado por el Banco JLP 23May2008
		LET V_TASA_MORA = V_TASA_MORA - V_TASA_INTERES;
		IF V_TASA_MORA < 0 THEN --Si es Menor a Cero la vuelve Positivo
			LET V_TASA_MORA = V_TASA_MORA * -1;
		END IF
	
		IF V_PRODUCTO  = "7800" THEN
	
			--Mandar el registra evento para el envio de mensajes
		
			--insertar en la tabla para enviar sms Felicidades Tu Anticipo de Nomina ha sido autorizado, puedes disponer de hasta $#,### cuando lo necesites.	
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_1' , '000000000','', '','1', V_MONTO, '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;			
			--insertar en la tabla para enviar sms Solicita tu Anticipo de Nomina enviando un SMS al ###### con la palabra Anticipo + monto que deseas sin signo de pesos?	
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1 , 'ADN_SMS' ,'ADN_SMS_2' , '000000000','', '','1', '', '', '', '', '', '', '', '', '', '', '', cTelCel, 0, 0,0, 0, 0, current, current) INTO cCodRet;	
		ELSE

			LET dPagoReq = V_MONTO * (V_TASA_INTERES /100) / 360 * 30;

			IF cCobro_Apertu = '1' THEN    -- Si el producto tiene cobro de comision por apertura.
				SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
				LET mMntoComApert = NVL(mMntoComApert,0);                                       -- Se toma cat originacion. Se agrega com apertura
			END IF;
			-- AAME 17072019 INI Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253
			IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
				SELECT monto INTO dMtoComAnualTit FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualTit;    -- Monto anualidad titular
				SELECT monto INTO dMtoComAnualAdi FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
				LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
				LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);
				IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
				LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
			ELSE
				LET mMntoComAnual = 0;
			END IF;
			-- Para 6001 solo cobra apertura, para <> 6001 no cobra apertura, cobra anualidad
			LET dComisiones = dComisiones + mMntoComApert;		
			--LET dComisiones = NVL(mMntoComApert,0) + NVL(mMntoComAnual,0);

			--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36,50) 
			--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36, dComisiones) 
			EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO, dPagoReq, 36, 36, dComisiones, dComs_GastCob, mMntoComAnual, V_TASA_INTERES) 		
			into cCodRet,cMensajeRet,vCatFinal;	
			IF cCodRet::INTEGER =0 AND  vCatFinal <> 0  THEN
				LET V_CATIVA = vCatFinal;			
			END IF;
			-- AAME 17072019 FIN Se modifica calculo del CAT igual al de Portada de Apertura RQM 10 1253
			UPDATE bdisolic:ss_revision_determinacion SET cat = V_CATIVA 	WHERE empresa = P_EMPRESA 	AND num_solicitud = P_SOLICITUD;
		END IF;
	
		--***** ACTUALIZA SD_BITACORA_DISPEFEC RQM 10 1225
		IF vDispEfec  = '1' THEN
			SELECT b.grupo,b.evalua_cc  
			INTO  gpo,evalcc
			FROM  bdisolic:ss_revision_determinacion b 
			WHERE b.EMPRESA = P_EMPRESA 
			AND   b.num_solicitud = P_SOLICITUD;
		
			IF gpo = '1' AND evalcc IN ('0','X')  THEN --A+ -> HIT / NO HIT
				LET v_idi = '2';
			ELIF gpo <> '1' AND evalcc IN ('0')  THEN -- NO A+ -> HIT
				LET v_idi = '2';
			ELIF gpo <> '1' AND nvl(evalcc,'X') = 'X' THEN-- NO A+ -> NO HIT
				LET v_idi = '1';
			ELSE 
				LET v_idi = '0';
			END IF;	
		   
			--INSERCION EN TABLA BITACORA DISPOSICION EN EFECTIVO
			 INSERT INTO bdicred:sd_bitacora_dispefec
				   (EMPRESA                ,NUM_CREDITO
				   ,FECHA_STATUS           ,IND_DISP_INI
				   ,IND_DISP_ACT           ,GRUPO
				   ,EVALUA_CC              ,FECHA_INSERT)
			 VALUES(P_EMPRESA,P_SOLICITUD,null,v_idi,null,gpo,evalcc,TODAY);
			 
			--SE ACTUALIZA TABLA SD_MAECRED CON EL VALOR DEL PERIODO_POR_EVALUAR REUSANDO EL CAMPO DIFERIMIENTO_INT
		    LET v_indde = v_idi::INTEGER;
		    UPDATE bdicred:"informix".sd_maecred SET diferimiento_int = v_indde
			WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD ;
        		
		END IF;
    ----------------------------
	
END IF; --TDC PAY	

    RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
END;
END PROCEDURE;