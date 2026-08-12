CREATE PROCEDURE "informix".sp_depuractanvl2 (p_tipoproc CHAR(1), pcliente CHAR(20), ptelefono CHAR(10))
    RETURNING   CHAR(5);
       
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vCodRet          CHAR(5);
	DEFINE vNumcte          CHAR(20);
	DEFINE vProceso         CHAR(2);
	DEFINE vCuenta          CHAR(20);
	DEFINE vFechaHoy        DATE;
	DEFINE vSucReg          CHAR(4);
	DEFINE vEstus           SMALLINT;
	DEFINE vValExis         INTEGER;
	DEFINE vRanTiem         INTEGER;
	DEFINE vFecHoraRa       DATETIME YEAR TO FRACTION(5);
	DEFINE vExiClie         INTEGER;
	DEFINE vVallong         INTEGER;
	DEFINE vProducto        CHAR(4);
	DEFINE vExisCta         INTEGER;
	DEFINE vExisteMoc       INTEGER;
	DEFINE vTelcel          CHAR(10);
	DEFINE vCliTel          CHAR(20);
	DEFINE vExiTel          CHAR(10);
	DEFINE vEstatus         CHAR(1);
	DEFINE vExiCta          CHAR(20);
	DEFINE vProceda         CHAR(1);
	DEFINE vExiFolio        INTEGER;
	

			  		
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vCodRet             = "00000";
	LET vNumcte             = '';
	LET vProceso            = '';
	LET vCuenta             = '';
	LET vSucReg             = "5001";
	LET vEstus              = 10;
	LET vFecHoraRa          = '';
	LET vExiClie            = 0;
	LET vProducto           = "2900";
	LET vExisCta            = 0;
	LET vExisteMoc          = 0;
	LET vTelcel             = "";
	LET vCliTel             = "";
	LET vExiTel             = "";
	LET vEstatus            = "";
	LET vExiCta             = "";
	LET vProceda            = "";
	LET vExiFolio           = 0;
	

		
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depuractanvl2.err";
	 	    TRACE ON;
			LET vCodRet    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
	        RETURN vCodRet;
        END IF;
    END EXCEPTION;
	
    --SET   DEBUG FILE TO '/informix/rsv/bpi/produ/sp_depuractanvl2.txt';
    --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

	--- VALIDACION DE CAMPOS REQUERIDOS
	IF  p_tipoproc NOT IN ("1","2","3") THEN 
	    LET vCodRet = '00110';
        RETURN vCodRet;
    END IF;	
	
    --- VALIDACION DE CAMPOS REQUERIDOS
	IF  p_tipoproc IS NULL OR p_tipoproc = "" THEN 
	    LET vCodRet = '00110';
        RETURN vCodRet;
    END IF;	
		
	--- VALIDACION DE CAMPOS REQUERIDOS	
	IF  p_tipoproc = "2" THEN 
	    LET vVallong  = LEN(pcliente);
        IF  pcliente IS NULL OR pcliente = " " OR vVallong <> 9 THEN 
            LET vCodRet = '00110';
            RETURN vCodRet;
        END IF;
	END IF;
	
	--- VALIDACION DE CAMPOS REQUERIDOS	
	IF  p_tipoproc = "3" THEN 
	    LET vVallong  = LEN(ptelefono);
		IF  vVallong <> 10 OR vVallong IS NULL OR vVallong = "" THEN 
		    LET vCodRet = '00110';
            RETURN vCodRet;
        END IF;
	END IF; 
	

	SELECT fecha_hoy
	INTO   vFechaHoy
	FROM   bdicheq:sc_fechas;

	-- RANGO DE TIEMPO   
	SELECT valor
    INTO   vRanTiem
	FROM   bdicheq:sc_param 
    WHERE  codparam = 'timedep';
	

	
	--//RENGO DE FECHA HORA PARA BORRAR REGISTRO
	LET vFecHoraRa = CURRENT YEAR TO FRACTION(5) - vRanTiem units MINUTE; 
	
	--PROCESO GENERAL 
	IF  p_tipoproc = "1" THEN 

	    FOREACH WITH HOLD 
	    
	            SELECT numcte,  proceso,   estatus,  procesada
	    		INTO   vNumcte, vProceso,  vEstatus, vProceda
	    		FROM   bdinteg:si_ctanvl2_ctrl 
	            WHERE  (proceso <> "5" AND estatus <>"F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa)
                OR     (proceso <> "5" AND proceso <> "6" AND proceso <> "7" AND procesada <>"S" AND fechora_fin <= vFecHoraRa)
                OR     (estatus <> "F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa)
				
				
				--VALIDACION DE DATOS PARA CLIENTES QUE YA EXISTEN "6"
				IF  vProceso =  '6' AND  vEstatus = 'I' THEN 
				    SELECT a.cuenta 
	    		    INTO   vExiCta
	    		    FROM   bdicheq:sc_maechq as a,
				           bdicheq:sc_maenoc as b
				    WHERE  a.cuenta = b.cuenta
	    		    AND    a.num_cte  = vNumcte
					AND    a.producto = vProducto;
					
								
					IF  vExiCta IS NOT NULL THEN
				        DELETE FROM bdicheq:sc_maechq
                        WHERE  cuenta = vExiCta
					    AND    producto = vProducto;
					   		    
					    DELETE FROM bdicheq:sc_maenoc
                        WHERE cuenta = vExiCta;
                                   
                        DELETE FROM bdicheq:sc_firmantes
                        WHERE cuenta = vExiCta;
						
						UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
					ELSE 
					    SELECT cuenta 
						INTO   vExiCta
						FROM   bdicheq:sc_firmantes
						WHERE  numcte = vNumcte; 
						
						IF  vExiCta IS NOT NULL THEN 
						    DELETE FROM bdicheq:sc_maechq
                            WHERE  cuenta = vExiCta
					        AND    producto = vProducto;
					   	    	    
					        DELETE FROM bdicheq:sc_maenoc
                            WHERE cuenta = vExiCta;
                                       
                            DELETE FROM bdicheq:sc_firmantes
                            WHERE cuenta = vExiCta;
							
							UPDATE bdinteg:si_ctanvl2_ctrl
	    				    SET    procesada = 'S'
						    WHERE  numcte    = vNumcte
						    AND    proceso   = vProceso;
						END IF; 
					END IF; 
				END IF;

	            -- SE VALIDA QUE EL CLIENTE CUMPLA CON LAS REGLAS REQUERIDAS			
	            SELECT COUNT(*)
	    		INTO   vValExis
	    		FROM   bdinteg:si_cliente
	    		WHERE  numcte       = vNumcte
	    		AND    tipo_cliente = '2'
	    		AND    fecha_insert = vFechaHoy;   
                
                IF  vValExis = 1 THEN 
	    		    --//En la ejecucion del SPL sp_ctanvl2_gencte
	                IF  vProceso = '1' THEN 
	                
	                    DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                    
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    				
	    				UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    		    
                    --//En la ejecucion del SPL sp_ctanvl2_regdomicilio			
	                ELIF vProceso = '2' THEN 
	    		    
	    		        DELETE FROM bdinteg:si_direcciones
                        WHERE numcte       = vNumcte
	    		    	AND   fecha_insert = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_direcciones_actual
                        WHERE numcte       = vNumcte
	    		    	AND   fecha_insert = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                    
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    				
	    				UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    		    
	    		    --//En la ejecucion del SPL sp_ctanvl2_regtelefonos	
	    		    ELIF vProceso = '3' THEN -- 
					
					    SELECT telefono
						INTO   vExiTel 
						FROM   bdinteg:si_telefonos
						WHERE  numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy; 
						        
						DELETE FROM bdibpi:pr_validaciondigital
					    WHERE  celular = vExiTel;
						
	    		        DELETE FROM bdinteg:si_telefonos
                        WHERE numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy;
                    
                        DELETE FROM bdinteg:si_telefonos_actual
                        WHERE numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_direcciones
                        WHERE numcte       = vNumcte
	    		    	AND   fecha_insert = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_direcciones_actual
                        WHERE numcte       = vNumcte
	    		    	AND   fecha_insert = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                    
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    				
	    				UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    		    
	    		    --//En la ejecucion del SPL sp_ctanvl2_regcorreos
	    		    ELIF vProceso = '4' THEN  
	    		    
	    		        DELETE FROM bdinteg:si_correos
                        WHERE numcte = vNumcte
	    		    	AND SUBSTR(fecha_hora, 1, 4) =  SUBSTR(vFechaHoy,7,4)
                        AND SUBSTR(fecha_hora, 6, 2) =  SUBSTR(vFechaHoy,0,2)
                        AND SUBSTR(fecha_hora, 9, 2) =  SUBSTR(vFechaHoy,4,2);
						
						SELECT telefono
						INTO   vExiTel 
						FROM   bdinteg:si_telefonos
						WHERE  numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy; 
						        
						DELETE FROM bdibpi:pr_validaciondigital
					    WHERE  celular = vExiTel;
						
	    		        DELETE FROM bdinteg:si_telefonos
                        WHERE numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy;
                    
                        DELETE FROM bdinteg:si_telefonos_actual
                        WHERE numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy;    
	    		    	
	    		    	DELETE FROM bdinteg:si_direcciones
                        WHERE numcte       = vNumcte
	    		    	AND   fecha_insert = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_direcciones_actual
                        WHERE numcte       = vNumcte
	    		    	AND   fecha_insert = vFechaHoy;
	    		    	
	    		    	DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                    
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    				
	    				UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    		    	
	    		    --//En la ejecucion del SPL sp_ctanvl2_gencta	
	    		    ELIF vProceso = '5' THEN 
	    		        -- SE VALIDA QUE EL CLIENTE TENGA UNA CUENTA QUE CORRESPONDA A UN PRODUCTO 2900
	    		        SELECT COUNT(*) 
	    		    	INTO   vExisCta
	    		    	FROM   bdicheq:sc_maechq
	    		    	WHERE  num_cte  = vNumcte
						AND    producto = vProducto;
						
						IF vExisCta = 1 THEN 

						   SELECT cuenta 
	    		    	   INTO   vCuenta
	    		    	   FROM   bdicheq:sc_maechq
	    		    	   WHERE  num_cte  = vNumcte
						   AND    producto = vProducto;
						   
						   --SE VALIDA QUE LA CUENTA NO TENGA MOVIMIENTOS
						   SELECT COUNT(*)
						   INTO   vExisteMoc						   
						   FROM   bdicheq:sc_maechq a, 
						          bdicheq:sc_maenoc b
						   WHERE  a.cuenta = b.cuenta
						   AND    a.cuenta = vCuenta
						   AND    b.fecha_alta = vFechaHoy
						   AND    a.fecultdep IS NULL
						   AND    a.fecultret IS NULL
						   AND    a.sdo_actual = 0.00;
						   
						    IF  vExisteMoc = 1 THEN 
								--VALIDA SI SE GENERO UN FOLIO NUEVO.
								SELECT COUNT(*)
								INTO   vExiFolio
								FROM   bdinteg:si_ctanvl2_ctrl
								WHERE  numcte   = vNumcte
								AND    proceso  = "7"
								AND    DATE (fechora_fin) = vFechaHoy;
								
								IF vExiFolio > 0 THEN 
                                   --// SUCURSAL "5001", ESTATUS "10"
	    		                   DELETE FROM bdinteg:si_bpiusuarios
	    		    	           WHERE  numcte       = vNumcte
	    		    	           AND    suc_registro = vSucReg
	    		                   AND	  id_status    = vEstus
                                   AND    DATE(f_registro) = vFechaHoy;
								END IF; 
                                
	    		                DELETE FROM bdicheq:sc_maechq
                                WHERE  cuenta = vCuenta
						        AND    producto = vProducto;
							    
							    DELETE FROM bdicheq:sc_maenoc
                                WHERE cuenta = vCuenta;
                                
                                DELETE FROM bdicheq:sc_firmantes
                                WHERE cuenta = vCuenta;
	    		    	        
	    		    	        DELETE FROM bdinteg:si_correos
                                WHERE numcte = vNumcte
	    		    	        AND SUBSTR(fecha_hora, 1, 4) =  SUBSTR(vFechaHoy,7,4)
                                AND SUBSTR(fecha_hora, 6, 2) =  SUBSTR(vFechaHoy,0,2)
                                AND SUBSTR(fecha_hora, 9, 2) =  SUBSTR(vFechaHoy,4,2);
								
								SELECT telefono
						        INTO   vExiTel 
						        FROM   bdinteg:si_telefonos
						        WHERE  numcte = vNumcte
	    		    	        AND DATE(fecha_hora) = vFechaHoy; 
						                
						        DELETE FROM bdibpi:pr_validaciondigital
					            WHERE  celular = vExiTel;
						        
	    		                DELETE FROM bdinteg:si_telefonos
                                WHERE numcte = vNumcte
	    		    	        AND DATE(fecha_hora) = vFechaHoy;
                                
                                DELETE FROM bdinteg:si_telefonos_actual
                                WHERE numcte = vNumcte
	    		    	        AND DATE(fecha_hora) = vFechaHoy;  
	    		    	        
	    		    	        DELETE FROM bdinteg:si_direcciones
                                WHERE numcte       = vNumcte
	    		    	        AND   fecha_insert = vFechaHoy;
	    		    	        
	    		    	        DELETE FROM bdinteg:si_direcciones_actual
                                WHERE numcte       = vNumcte
	    		    	        AND   fecha_insert = vFechaHoy;
	    		    	        
	    		    	        DELETE FROM bdinteg:si_cliente
                                WHERE numcte = vNumcte;
                                
                                DELETE FROM bdinteg:si_ctepf
                                WHERE numcte = vNumcte;
	    				        
	    				        UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso;
							
						    ELIF vExisteMoc = 0 THEN  
							
							    UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso;
								
							END IF; 	  
	    		    	END IF;
	    		    END IF;
	    		END IF;
	    END FOREACH; 
		
		
	ELIF    p_tipoproc = "2" THEN 
	
	        -- SE VALIDA QUE EL CLIENTE CUMPLA CON LAS REGLAS REQUERIDAS 
	        SELECT COUNT(*)
	    	INTO   vExiClie
	    	FROM   bdinteg:si_ctanvl2_ctrl 
	    --  WHERE  numcte = pcliente
	        WHERE  (proceso <> "5" AND estatus <>"F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = pcliente)
            OR     (proceso <> "5" AND proceso <> "6" AND proceso <> "7" AND procesada <>"S"  AND fechora_fin <= vFecHoraRa AND  numcte = pcliente)
            OR     (estatus <> "F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = pcliente);
			
	        IF  vExiClie = 1 THEN			
			    SELECT numcte,  proceso,   estatus,  procesada
	    		INTO   vNumcte, vProceso,  vEstatus, vProceda
	    	    FROM   bdinteg:si_ctanvl2_ctrl 
			  --  WHERE  numcte = pcliente
	    	    WHERE  (proceso <> "5" AND estatus <>"F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = pcliente)
                OR     (proceso <> "5" AND proceso <> "6" AND proceso <> "7" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = pcliente)
                OR     (estatus <> "F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = pcliente);
				
				
				--VALIDACION DE DATOS PARA CLIENTES QUE YA EXISTEN "6"
				IF  vProceso =  '6' AND  vEstatus = 'I' THEN 
				    SELECT a.cuenta 
	    		    INTO   vExiCta
	    		    FROM   bdicheq:sc_maechq as a,
				           bdicheq:sc_maenoc as b
				    WHERE  a.cuenta = b.cuenta
	    		    AND    a.num_cte  = vNumcte
					AND    a.producto = vProducto;
					
								
					IF  vExiCta IS NOT NULL THEN
				        DELETE FROM bdicheq:sc_maechq
                        WHERE  cuenta = vExiCta
					    AND    producto = vProducto;
					   		    
					    DELETE FROM bdicheq:sc_maenoc
                        WHERE cuenta = vExiCta;
                                   
                        DELETE FROM bdicheq:sc_firmantes
                        WHERE cuenta = vExiCta;
						
						UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso;
					ELSE 
					    SELECT cuenta 
						INTO   vExiCta
						FROM   bdicheq:sc_firmantes
						WHERE  numcte = vNumcte; 
						
						IF  vExiCta IS NOT NULL THEN 
						    DELETE FROM bdicheq:sc_maechq
                            WHERE  cuenta = vExiCta
					        AND    producto = vProducto;
					   	    	    
					        DELETE FROM bdicheq:sc_maenoc
                            WHERE cuenta = vExiCta;
                                       
                            DELETE FROM bdicheq:sc_firmantes
                            WHERE cuenta = vExiCta;
							
							UPDATE bdinteg:si_ctanvl2_ctrl
	    				    SET    procesada = 'S'
						    WHERE  numcte    = vNumcte
						    AND    proceso   = vProceso;
						END IF; 
					END IF; 
				END IF;
				
			    -- SE VALIDA QUE EL CLIENTE CUMPLA CON LAS REGLAS REQUERIDAS
			    SELECT COUNT(*)
	    		INTO   vValExis
	    		FROM   bdinteg:si_cliente
	    		WHERE  numcte = vNumcte
	    		AND    tipo_cliente = '2'
	    		AND    fecha_insert = vFechaHoy; 
			
                IF  vValExis = 1 THEN 
	    	        --//En la ejecucion del SPL sp_ctanvl2_gencte
	                IF  vProceso = '1' THEN 
	               
	                    DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                        
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    			    
	    			    UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    	    
                    --//En la ejecucion del SPL sp_ctanvl2_regdomicilio			
	                ELIF vProceso = '2' THEN 
	    	    
	    	            DELETE FROM bdinteg:si_direcciones
                        WHERE numcte       = vNumcte
	    	    	    AND   fecha_insert = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_direcciones_actual
                        WHERE numcte       = vNumcte
	    	    	    AND   fecha_insert = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                        
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    			    
	    			    UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    	    
	    	        --//En la ejecucion del SPL sp_ctanvl2_regtelefonos	
	    	        ELIF vProceso = '3' THEN -- 
					
					    SELECT telefono
						INTO   vExiTel 
						FROM   bdinteg:si_telefonos
						WHERE  numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy; 
						        
						DELETE FROM bdibpi:pr_validaciondigital
					    WHERE  celular = vExiTel;
	    	    
	    	            DELETE FROM bdinteg:si_telefonos
                        WHERE numcte = vNumcte
	    	    	    AND DATE(fecha_hora) = vFechaHoy;
                        
                        DELETE FROM bdinteg:si_telefonos_actual
                        WHERE numcte = vNumcte
	    	    	    AND DATE(fecha_hora) = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_direcciones
                        WHERE numcte       = vNumcte
	    	    	    AND   fecha_insert = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_direcciones_actual
                        WHERE numcte       = vNumcte
	    	    	    AND   fecha_insert = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                        
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    			    
	    			    UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    	    
	    	        --//En la ejecucion del SPL sp_ctanvl2_regcorreos
	    	        ELIF vProceso = '4' THEN  
	    	    
	    	            DELETE FROM bdinteg:si_correos
                        WHERE numcte = vNumcte
	    		    	AND SUBSTR(fecha_hora, 1, 4) =  SUBSTR(vFechaHoy,7,4)
                        AND SUBSTR(fecha_hora, 6, 2) =  SUBSTR(vFechaHoy,0,2)
                        AND SUBSTR(fecha_hora, 9, 2) =  SUBSTR(vFechaHoy,4,2);
						
						SELECT telefono
						INTO   vExiTel 
						FROM   bdinteg:si_telefonos
						WHERE  numcte = vNumcte
	    		    	AND DATE(fecha_hora) = vFechaHoy; 
						        
						DELETE FROM bdibpi:pr_validaciondigital
					    WHERE  celular = vExiTel;
	    	    
	    	            DELETE FROM bdinteg:si_telefonos
                        WHERE numcte = vNumcte
	    	    	    AND DATE(fecha_hora) = vFechaHoy;
                        
                        DELETE FROM bdinteg:si_telefonos_actual
                        WHERE numcte = vNumcte
	    	    	    AND DATE(fecha_hora) = vFechaHoy;    
	    	    	    
	    	    	    DELETE FROM bdinteg:si_direcciones
                        WHERE numcte       = vNumcte
	    	    	    AND   fecha_insert = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_direcciones_actual
                        WHERE numcte       = vNumcte
	    	    	    AND   fecha_insert = vFechaHoy;
	    	    	    
	    	    	    DELETE FROM bdinteg:si_cliente
                        WHERE numcte = vNumcte;
                        
                        DELETE FROM bdinteg:si_ctepf
                        WHERE numcte = vNumcte;
	    			    
	    			    UPDATE bdinteg:si_ctanvl2_ctrl
	    				SET    procesada = 'S'
						WHERE  numcte    = vNumcte
						AND    proceso   = vProceso; 
	    	    	
					--//En la ejecucion del SPL sp_ctanvl2_gencta	
	    	        ELIF vProceso = '5' THEN 
					    --SE VALIDA QUE EL CLIENTE TENGA UNA CUENTA QUE CORRESPONDA A UN PRODUCTO 2900
					    SELECT COUNT(*) 
	    		    	INTO   vExisCta
	    		    	FROM   bdicheq:sc_maechq
	    		    	WHERE  num_cte  = vNumcte
						AND    producto = vProducto;
	    	    
				        IF  vExisCta = 1 THEN 						
	    	                SELECT cuenta 
	    	    	        INTO   vCuenta
	    	    	        FROM   bdicheq:sc_maechq
	    		    	    WHERE  num_cte  = vNumcte
						    AND    producto = vProducto;
							
						    -- SE VALIDA QUE LA CUENTA NO TENGA MOVIMIENTOS 
						    SELECT COUNT(*)
						    INTO   vExisteMoc						   
						    FROM   bdicheq:sc_maechq a, 
						           bdicheq:sc_maenoc b
						    WHERE  a.cuenta = b.cuenta
						    AND    a.cuenta = vCuenta
						    AND    b.fecha_alta = vFechaHoy
						    AND    a.fecultdep IS NULL
						    AND    a.fecultret IS NULL
						    AND    a.sdo_actual = 0.00;
						   
						    IF  vExisteMoc = 1 THEN 
							    --VALIDA SI SE GENERO UN FOLIO NUEVO.
							    SELECT COUNT(*)
							    INTO   vExiFolio
							    FROM   bdinteg:si_ctanvl2_ctrl
							    WHERE  numcte   = vNumcte
							    AND    proceso  = "7"
							    AND    DATE (fechora_fin) = vFechaHoy;
							
							    IF  vExiFolio > 0 THEN 
                                    --// SUCURSAL "5001", ESTATUS "10"
	    		                    DELETE FROM bdinteg:si_bpiusuarios
	    		    	            WHERE  numcte       = vNumcte
	    		    	            AND    suc_registro = vSucReg
	    		                    AND	   id_status    = vEstus
                                    AND    DATE(f_registro) = vFechaHoy;
							    END IF;
	
	    	                    DELETE FROM bdicheq:sc_maechq
                                WHERE  cuenta = vCuenta
						        AND    producto = vProducto;
                                
                                DELETE FROM bdicheq:sc_maenoc
                                WHERE cuenta = vCuenta;
                                
                                DELETE FROM bdicheq:sc_firmantes
                                WHERE cuenta = vCuenta;
	    	    	            
	    	    	            DELETE FROM bdinteg:si_correos
                                 WHERE numcte = vNumcte
	    		    	        AND SUBSTR(fecha_hora, 1, 4) =  SUBSTR(vFechaHoy,7,4)
                                AND SUBSTR(fecha_hora, 6, 2) =  SUBSTR(vFechaHoy,0,2)
                                AND SUBSTR(fecha_hora, 9, 2) =  SUBSTR(vFechaHoy,4,2);
								
								SELECT telefono
						        INTO   vExiTel 
						        FROM   bdinteg:si_telefonos
						        WHERE  numcte = vNumcte
	    		    	        AND DATE(fecha_hora) = vFechaHoy; 
						                
						        DELETE FROM bdibpi:pr_validaciondigital
					            WHERE  celular = vExiTel;
	    	    	            
	    	    	            DELETE FROM bdinteg:si_telefonos
                                WHERE numcte = vNumcte
	    	    	            AND DATE(fecha_hora) = vFechaHoy;
                                
                                DELETE FROM bdinteg:si_telefonos_actual
                                WHERE numcte = vNumcte
	    	    	            AND DATE(fecha_hora) = vFechaHoy;  
	    	    	            
	    	    	            DELETE FROM bdinteg:si_direcciones
                                WHERE numcte       = vNumcte
	    	    	            AND   fecha_insert = vFechaHoy;
	    	    	            
	    	    	            DELETE FROM bdinteg:si_direcciones_actual
                                WHERE numcte       = vNumcte
	    	    	            AND   fecha_insert = vFechaHoy;
	    	    	            
	    	    	            DELETE FROM bdinteg:si_cliente
                                WHERE numcte = vNumcte;
                                
                                DELETE FROM bdinteg:si_ctepf
                                WHERE numcte = vNumcte;
	    			            
	    			            UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso;

							ELIF vExisteMoc = 0 THEN  
							    -- LA CUENTA TIENE MOVIMIENTOS
							    UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso;
								
						        LET     vCodRet = "00004";
			                    RETURN  vCodRet;
							END IF; 	
					    ELSE 
						    -- LA CUENTA DEL CLIENTE NO ES DE UN PRODUCTO 2900 
						    LET     vCodRet = "00003";
			                RETURN  vCodRet;
						END IF;
					END IF; 
				ELSE 
				    -- EL CLIENTE NO ESTA EN LA TABLA DE CLIENTES O NO CUMPLE CON LOS PARAMETROS REQUERIDOS
				    LET     vCodRet = "00002";
			        RETURN  vCodRet;
				END IF;	
	        ELSE 
			    -- EL CLIENTE NO ESTA O NO CUEMPLE CON LOS PARAMETROS EN LA TABLA DE CONTROL 
			    LET     vCodRet = "00001";
			    RETURN  vCodRet;
			END IF;
	
	ELIF    p_tipoproc = "3" THEN 	
	
	        SELECT celular
			INTO   vTelcel
			FROM   bdibpi:pr_validaciondigital 
			WHERE  celular = ptelefono;
			
			IF  vTelcel IS NOT NULL THEN 
			
			    SELECT numcte
			    INTO   vCliTel
			    FROM   bdinteg:si_telefonos
			    WHERE  telefono   = vTelcel
                AND    tipo_tel   = "2"
                AND    status_tel = "A"
				AND DATE(fecha_hora) = vFechaHoy;
				
				IF vCliTel IS NOT NULL THEN 
				   -- SE VALIDA QUE EL CLIENTE CUMPLA CON LAS REGLAS REQUERIDAS 
	               SELECT COUNT(*)
	    	       INTO   vExiClie
	    	       FROM   bdinteg:si_ctanvl2_ctrl 
	               WHERE  (proceso <> "5" AND estatus <>"F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = vCliTel)
                   OR     (proceso <> "5" AND proceso <> "6" AND proceso <> "7" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = vCliTel)
                   OR     (estatus <> "F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = vCliTel);
				   
				    IF  vExiClie = 1 THEN		
			            SELECT numcte,  proceso,   estatus,  procesada
	    		        INTO   vNumcte, vProceso,  vEstatus, vProceda
	    	            FROM   bdinteg:si_ctanvl2_ctrl 
	    	            WHERE  (proceso <> "5" AND estatus <>"F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = vCliTel)
                        OR     (proceso <> "5" AND proceso <> "6" AND proceso <> "7" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = vCliTel)
                        OR     (estatus <> "F" AND procesada <>"S" AND fechora_fin <= vFecHoraRa AND  numcte = vCliTel);
						
						--VALIDACION DE DATOS PARA CLIENTES QUE YA EXISTEN "6"
				        IF  vProceso =  '6' AND  vEstatus = 'I' THEN 
				            SELECT a.cuenta 
	    		            INTO   vExiCta
	    		            FROM   bdicheq:sc_maechq as a,
				                   bdicheq:sc_maenoc as b
				            WHERE  a.cuenta = b.cuenta
	    		            AND    a.num_cte  = vNumcte
					        AND    a.producto = vProducto;
					
								
					        IF  vExiCta IS NOT NULL THEN
				                DELETE FROM bdicheq:sc_maechq
                                WHERE  cuenta = vExiCta
					            AND    producto = vProducto;
					           		    
					            DELETE FROM bdicheq:sc_maenoc
                                WHERE cuenta = vExiCta;
                                           
                                DELETE FROM bdicheq:sc_firmantes
                                WHERE cuenta = vExiCta;
								
								UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso;
					        ELSE 
					            SELECT cuenta 
					        	INTO   vExiCta
					        	FROM   bdicheq:sc_firmantes
					        	WHERE  numcte = vNumcte; 
					        	
					        	IF  vExiCta IS NOT NULL THEN 
					        	    DELETE FROM bdicheq:sc_maechq
                                    WHERE  cuenta = vExiCta
					                AND    producto = vProducto;
					           	    	    
					                DELETE FROM bdicheq:sc_maenoc
                                    WHERE cuenta = vExiCta;
                                               
                                    DELETE FROM bdicheq:sc_firmantes
                                    WHERE cuenta = vExiCta;
									
									UPDATE bdinteg:si_ctanvl2_ctrl
	    				            SET    procesada = 'S'
						            WHERE  numcte    = vNumcte
						            AND    proceso   = vProceso;
					        	END IF; 
					        END IF; 
				        END IF;
						
			            -- SE VALIDA QUE EL CLIENTE CUMPLA CON LAS REGLAS REQUERIDAS
			            SELECT COUNT(*)
	    		        INTO   vValExis
	    		        FROM   bdinteg:si_cliente
	    		        WHERE  numcte = vNumcte
	    		        AND    tipo_cliente = '2'
	    		        AND    fecha_insert = vFechaHoy; 
			            
                        IF  vValExis = 1 THEN 
	    	                --//En la ejecucion del SPL sp_ctanvl2_gencte
	                        IF  vProceso = '1' THEN 
	                       
	                            DELETE FROM bdinteg:si_cliente
                                WHERE numcte = vNumcte;
                                
                                DELETE FROM bdinteg:si_ctepf
                                WHERE numcte = vNumcte;
	    		        	    
	    		        	    UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso; 
	    	            
                            --//En la ejecucion del SPL sp_ctanvl2_regdomicilio			
	                        ELIF vProceso = '2' THEN 
	    	            
	    	                    DELETE FROM bdinteg:si_direcciones
                                WHERE numcte       = vNumcte
	    	            	    AND   fecha_insert = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_direcciones_actual
                                WHERE numcte       = vNumcte
	    	            	    AND   fecha_insert = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_cliente
                                WHERE numcte = vNumcte;
                                
                                DELETE FROM bdinteg:si_ctepf
                                WHERE numcte = vNumcte;
	    		        	    
	    		        	    UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso; 
	    	            
	    	                --//En la ejecucion del SPL sp_ctanvl2_regtelefonos	
	    	                ELIF vProceso = '3' THEN -- 

							    DELETE FROM bdibpi:pr_validaciondigital
								WHERE celular = vTelcel;

	    	                    DELETE FROM bdinteg:si_telefonos
                                WHERE numcte = vNumcte
	    	            	    AND DATE(fecha_hora) = vFechaHoy;
                                
                                DELETE FROM bdinteg:si_telefonos_actual
                                WHERE numcte = vNumcte
	    	            	    AND DATE(fecha_hora) = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_direcciones
                                WHERE numcte       = vNumcte
	    	            	    AND   fecha_insert = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_direcciones_actual
                                WHERE numcte       = vNumcte
	    	            	    AND   fecha_insert = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_cliente
                                WHERE numcte = vNumcte;
                                
                                DELETE FROM bdinteg:si_ctepf
                                WHERE numcte = vNumcte;
	    		        	    
	    		        	    UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso;
	    	            
	    	                --//En la ejecucion del SPL sp_ctanvl2_regcorreos
	    	                ELIF vProceso = '4' THEN  
							
	    	                    DELETE FROM bdinteg:si_correos
                                WHERE numcte = vNumcte
	    		            	AND SUBSTR(fecha_hora, 1, 4) =  SUBSTR(vFechaHoy,7,4)
                                AND SUBSTR(fecha_hora, 6, 2) =  SUBSTR(vFechaHoy,0,2)
                                AND SUBSTR(fecha_hora, 9, 2) =  SUBSTR(vFechaHoy,4,2);
								
							    DELETE FROM bdibpi:pr_validaciondigital
								WHERE celular = vTelcel;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_telefonos
                                WHERE numcte = vNumcte
	    	            	    AND DATE(fecha_hora) = vFechaHoy;
                                
                                DELETE FROM bdinteg:si_telefonos_actual
                                WHERE numcte = vNumcte
	    	            	    AND DATE(fecha_hora) = vFechaHoy;    
	    	            	    
	    	            	    DELETE FROM bdinteg:si_direcciones
                                WHERE numcte       = vNumcte
	    	            	    AND   fecha_insert = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_direcciones_actual
                                WHERE numcte       = vNumcte
	    	            	    AND   fecha_insert = vFechaHoy;
	    	            	    
	    	            	    DELETE FROM bdinteg:si_cliente
                                WHERE numcte = vNumcte;
                                
                                DELETE FROM bdinteg:si_ctepf
                                WHERE numcte = vNumcte;
	    		        	    
	    		        	    UPDATE bdinteg:si_ctanvl2_ctrl
	    				        SET    procesada = 'S'
						        WHERE  numcte    = vNumcte
						        AND    proceso   = vProceso; 
	    	            	
				        	--//En la ejecucion del SPL sp_ctanvl2_gencta	
	    	                ELIF vProceso = '5' THEN 
				        	    --SE VALIDA QUE EL CLIENTE TENGA UNA CUENTA QUE CORRESPONDA A UN PRODUCTO 2900
				        	    SELECT COUNT(*) 
	    		            	INTO   vExisCta
	    		            	FROM   bdicheq:sc_maechq
	    		            	WHERE  num_cte  = vNumcte
				        		AND    producto = vProducto;
	    	            
				                IF  vExisCta = 1 THEN 
	    	                        SELECT cuenta 
	    	            	        INTO   vCuenta
	    	            	        FROM   bdicheq:sc_maechq
	    		            	    WHERE  num_cte  = vNumcte
				        		    AND    producto = vProducto;
				        			
				        		    -- SE VALIDA QUE LA CUENTA NO TENGA MOVIMIENTOS 
				        		    SELECT COUNT(*)
				        		    INTO   vExisteMoc						   
				        		    FROM   bdicheq:sc_maechq a, 
				        		           bdicheq:sc_maenoc b
				        		    WHERE  a.cuenta = b.cuenta
				        		    AND    a.cuenta = vCuenta
				        		    AND    b.fecha_alta = vFechaHoy
				        		    AND    a.fecultdep IS NULL
				        		    AND    a.fecultret IS NULL
				        		    AND    a.sdo_actual = 0.00;
				        		   
				        		    IF  vExisteMoc = 1 THEN 
									    --LA CUENTA NO TIENE MOVIMIENTOS
									    --VALIDA SI SE GENERO UN FOLIO NUEVO.
							            SELECT COUNT(*)
							            INTO   vExiFolio
							            FROM   bdinteg:si_ctanvl2_ctrl
							            WHERE  numcte   = vNumcte
							            AND    proceso  = "7"
							            AND    DATE (fechora_fin) = vFechaHoy;
							
							            IF  vExiFolio > 0 THEN 
                                            --// SUCURSAL "5001", ESTATUS "10"
	    		                            DELETE FROM bdinteg:si_bpiusuarios
	    		    	                    WHERE  numcte       = vNumcte
	    		    	                    AND    suc_registro = vSucReg
	    		                            AND	   id_status    = vEstus
                                            AND    DATE(f_registro) = vFechaHoy;
							            END IF;
                                        
	    	                            DELETE FROM bdicheq:sc_maechq
                                        WHERE  cuenta = vCuenta
				        		        AND    producto = vProducto;
                                        
                                        DELETE FROM bdicheq:sc_maenoc
                                        WHERE cuenta = vCuenta;
                                        
                                        DELETE FROM bdicheq:sc_firmantes
                                        WHERE cuenta = vCuenta;
	    	            	            
	    	            	            DELETE FROM bdinteg:si_correos
                                         WHERE numcte = vNumcte
	    		            	        AND SUBSTR(fecha_hora, 1, 4) =  SUBSTR(vFechaHoy,7,4)
                                        AND SUBSTR(fecha_hora, 6, 2) =  SUBSTR(vFechaHoy,0,2)
                                        AND SUBSTR(fecha_hora, 9, 2) =  SUBSTR(vFechaHoy,4,2);
										
								        DELETE FROM bdibpi:pr_validaciondigital
								        WHERE celular = vTelcel;
	    	            	            
	    	            	            DELETE FROM bdinteg:si_telefonos
                                        WHERE numcte = vNumcte
	    	            	            AND DATE(fecha_hora) = vFechaHoy;
                                        
                                        DELETE FROM bdinteg:si_telefonos_actual
                                        WHERE numcte = vNumcte
	    	            	            AND DATE(fecha_hora) = vFechaHoy;  
	    	            	            
	    	            	            DELETE FROM bdinteg:si_direcciones
                                        WHERE numcte       = vNumcte
	    	            	            AND   fecha_insert = vFechaHoy;
	    	            	            
	    	            	            DELETE FROM bdinteg:si_direcciones_actual
                                        WHERE numcte       = vNumcte
	    	            	            AND   fecha_insert = vFechaHoy;
	    	            	            
	    	            	            DELETE FROM bdinteg:si_cliente
                                        WHERE numcte = vNumcte;
                                        
                                        DELETE FROM bdinteg:si_ctepf
                                        WHERE numcte = vNumcte;
	    		        	            
	    		        	            UPDATE bdinteg:si_ctanvl2_ctrl
	    				                SET    procesada = 'S'
						                WHERE  numcte    = vNumcte
						                AND    proceso   = vProceso; 
                        
				        			ELIF vExisteMoc = 0 THEN  
				        			    -- LA CUENTA TIENE MOVIMIENTOS
				        			    UPDATE bdinteg:si_ctanvl2_ctrl
	    				                SET    procesada = 'S'
						                WHERE  numcte    = vNumcte
						                AND    proceso   = vProceso;
				        				
				        		        LET     vCodRet = "00006";
			                            RETURN  vCodRet;
				        			END IF; 	
				        	    ELSE 
				        		    -- LA CUENTA DEL CLIENTE NO ES DE UN PRODUCTO 2900 
				        		    LET     vCodRet = "00005";
			                        RETURN  vCodRet;
				        		END IF;
				        	END IF; 
				        ELSE 
				            -- EL CLIENTE NO EXISTE O NO ESTA EN LA TABLA DE CLIENTES O NO CUMPLE CON LOS PARAMETROS REQUERIDOS
				            LET     vCodRet = "00004";
			                RETURN  vCodRet;
				        END IF;	
	                ELSE 
					    DELETE FROM bdibpi:pr_validaciondigital
					    WHERE  celular = vTelcel;
			                -- EL CLIENTE NO EXISTE O NO ESTA EN LA TABLA DE CLIENTES O NO CUMPLE CON LOS PARAMETROS REQUERIDOS
			            LET     vCodRet = "00003";
			            RETURN  vCodRet;
					END IF;
					
				ELSE
				    DELETE FROM bdibpi:pr_validaciondigital
					WHERE  celular = vTelcel;
			        -- EL CLIENTE NO EXISTE O NO ESTA EN LA TABLA DE CLIENTES O NO CUMPLE CON LOS PARAMETROS REQUERIDOS
			        LET     vCodRet = "00002";
			        RETURN  vCodRet;	
				END IF;
			ELSE 
			    -- EL CLIENTE NO EXISTE O NO ESTA EN LA TABLA DE CLIENTES O NO CUMPLE CON LOS PARAMETROS REQUERIDOS 
			    LET     vCodRet = "00001";
			    RETURN  vCodRet;	
		    END IF;
	END IF; 
RETURN  vCodRet;
END; 
END PROCEDURE;