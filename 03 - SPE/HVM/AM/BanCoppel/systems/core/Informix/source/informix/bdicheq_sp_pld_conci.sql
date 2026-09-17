CREATE PROCEDURE "informix".sp_pld_conci( pEmpresa char(3))

RETURNING   CHAR(5);

			
DEFINE vsqlerr        INTEGER;
DEFINE vcodret        CHAR(5); 
DEFINE v_monto        MONEY(14,2);
DEFINE v_numero       INT;
DEFINE v_transaccion  CHAR(4);
DEFINE vc_monto       MONEY(14,2);
DEFINE vc_numero      INT;
DEFINE vc_transaccion CHAR(4);
DEFINE vtra_numero    CHAR(4);
DEFINE v_num_fecha    INT; 
DEFINE v_fecha_rango1 DATE; 
DEFINE v_fecha_rango2 DATE; 
DEFINE v_fecha_trime  INT; 
DEFINE v_mes_ante     INT;
DEFINE v_anio_ante    INT; 
DEFINE vfecha_p1      DATE;
DEFINE vsql           CHAR(500);
DEFINE v_anio_fin     INTEGER; 
DEFINE v_mes_fin      CHAR(2); 
DEFINE v_dia_fin      CHAR(2);
DEFINE v_f_fin        VARCHAR(8); 
DEFINE v_mes_ant      CHAR(2); 
DEFINE v_dolar        MONEY(14,2);
DEFINE v_limite       DECIMAL(18,2);
DEFINE v_valor_lim    DECIMAL(18,2);
DEFINE v_p_comora     DECIMAL(18,2);


		
DEFINE vfecha_ant      DATE;
DEFINE vfecha_hoy      DATE;
			

LET vsqlerr = 0; 
LET vcodret = "000";
LET vsql    = '';


BEGIN
	   ON EXCEPTION SET vsqlerr
	      SET DEBUG FILE TO "/resplogifx/conciliachq/pld.err";
	   	   TRACE ON;
              IF vsqlerr <> 0 THEN
                 LET vcodret = vsqlerr;
              RETURN vcodret;
              END IF;
       END EXCEPTION;
	   
         --SET DEBUG FILE TO '/resplogifx/conciliachq/pld_error.txt';
	    -- TRACE ON;
	   
	   SET ISOLATION TO DIRTY READ;
	   
       --OBTIENE FECHAS
       SELECT fecha_ant,  fecha_hoy  , WEEKDAY(fecha_hoy)
         INTO vfecha_ant, vfecha_hoy , v_num_fecha
         FROM bdicheq:sc_fechas
        WHERE empresa = '001';
		
		--LÃ­mite de monto en dÃ³lares (7500)
	   -- SELECT mnyvalornumerico
	     -- INTO v_limite
         -- FROM bdiauditor:tblpldparamdetalle
        -- WHERE chrproceso = 'relevantes' 
          -- AND chrproducto = 'extraccionrele' 
          -- AND chrclave ='limite_dolares';
		  
		  LET v_limite = 7500;
		
		
		----Tipo de cambio del dÃ³lar del dÃ­a anterior del movimiento a revisar.
	     --	-- SELECT precio   
        --  -- INTO v_dolar		
		--  -- FROM bdiauditor:tipo_cambio
		-- -- WHERE fecha_tc = (vfecha_ant - 1);
		
		 
		SELECT first 1 precio_compra
		  INTO v_p_comora
	      FROM bdinteg:si_tpcambio
         WHERE divisa = "02";
		  
		 
		  --OBTIENE EL LIMITE EN MONEDA NACIONAL
		 LET v_valor_lim = v_limite * v_p_comora;
	    
       
	   SELECT numero 
	     FROM bdinteg:si_transacc
        WHERE numero in('0202','0223','0282','0325')
	     INTO TEMP tmp_transacciones with no log;  
	     
	     
	   SELECT UNIQUE(transacc)  
	     FROM bdicred:sd_transfun  
        WHERE((codigo_fun = 901 AND codigo_ref = 1)
           OR(codigo_fun = 033 AND codigo_ref = 901)
           OR(codigo_fun = 002 AND codigo_ref = 50))
	     INTO TEMP tmp_transacciones_cred with no log;  
	     
	     	  
	   SELECT numero 
	     FROM tmp_transacciones
	    UNION ALL
	   SELECT transacc 
	     FROM tmp_transacciones_cred
	     INTO TEMP tmp_transacciones_total;
	     
	     
	 
      FOREACH WITH HOLD
               
               SELECT numero
	             INTO vtra_numero
	             FROM tmp_transacciones_total
	  	      		  
	  	           IF vtra_numero IN ('0202','0223','0282','0325') THEN 
	  	            
	                      --OBTIENE VALORES  DE  BDICHEQ
                          SELECT SUM(mo.monto_tot)  AS MONTO,
                                 COUNT(mo.transacc) AS NUMERO, 
                          	     mo.transacc        AS TRANSACCION 
	                        INTO v_monto,
                                 v_numero,
                                 v_transaccion    
                            FROM bdicheq:sc_movhis mo, bdinteg:si_sucursales suc
                           WHERE mo.fech_alt = vfecha_ant
						     AND mo.sucursal = suc.sucursal
							 AND suc.tpo_sucursal = "S"
                             AND mo.transacc  = vtra_numero
                             AND mo.monto_tot >= v_valor_lim
	                         AND mo.cancelad <> 'S'
                             AND mo.empresa ='001'
                           GROUP BY mo.transacc;
						   
						  IF v_monto > 0 THEN 
	  	    	        
	  	    	          INSERT INTO informix.tblpldconci VALUES(vfecha_ant,vtra_numero,v_numero,v_monto);
	  	    	       
	  	    	             LET vtra_numero = '';
	  	    	             LET v_numero    = 0;
	  	    	             LET v_monto     = 0.0;
							 
						  END IF; 
                   
	                ELSE 
                   
	  		                  IF vtra_numero = 6695 THEN 	       
                                 
                                      --OBTIENE VALORES DE DBICRED
                                      SELECT SUM(sd.monto)          AS MONTO,
                                             COUNT(sd.transacc_suc) AS NUMERO, 
                                      	     sd.transacc_suc        AS TRANSACCION 
	                                    INTO vc_monto,
                                             vc_numero,
                                             vc_transaccion    
										FROM bdicred:sd_movhis sd, bdinteg:si_sucursales suc
                                       WHERE sd.fecha_mov = vfecha_ant
									     AND sd.sucursal = suc.sucursal
										 AND suc.tpo_sucursal = "S"
                                         AND ((sd.codigo_fun = "901" AND sd.codigo_ref = "1")
										  OR (sd.codigo_fun = "033"  AND sd.codigo_ref = "901"))
                                         AND sd.reversado = 'N'
										 AND sd.empresa ='001'
									     AND sd.monto >= v_valor_lim
								       GROUP BY sd.transacc_suc;
									   
									  IF vc_monto > 0 THEN 
	 
	  			                      INSERT INTO informix.tblpldconci VALUES(vfecha_ant,vtra_numero,vc_numero,vc_monto);
	  			                    
	  			                         LET vtra_numero  = '';
	  		                             LET vc_numero    = 0;
	  		                             LET vc_monto     = 0.0;
										 
									  END IF;   
										 
										 
	  			   	          
	  		                   ELSE 
	  		                  
	  		                  
	  		                        --OBTIENE VALORES DE DBICRED
                                       SELECT SUM(sd.monto)          AS MONTO,
                                              COUNT(sd.transacc_suc) AS NUMERO, 
                                      	      sd.transacc_suc        AS TRANSACCION  
	                                     INTO vc_monto,
                                              vc_numero,
                                              vc_transaccion    
                                         FROM bdicred:sd_movhis sd, bdinteg:si_sucursales suc
                                        WHERE sd.fecha_mov = vfecha_ant
										  AND sd.sucursal = suc.sucursal
										  AND suc.tpo_sucursal = "S"
                                          AND sd.codigo_fun = 002 
	  			                	      AND sd.codigo_ref = 50
                                          AND sd.reversado = 'N'
										  AND sd.empresa ='001'
                                          AND sd.monto >= v_valor_lim
							   	     GROUP BY sd.transacc_suc;
									 
									   IF vc_monto > 0 THEN 
	  			                
	  			                       INSERT INTO informix.tblpldconci VALUES(vfecha_ant,vtra_numero,vc_numero,vc_monto);
	  			                    
	  			                          LET vtra_numero  = '';
	  		                              LET vc_numero    = 0;
	  		                              LET vc_monto     = 0.0;
										  
									   END IF;
	                            END IF; 	
                   
                    END IF; 	
      
       END FOREACH;		
	   
	   
	   --ELIMINA LAS TABLAS TEMPORALES 
       DROP TABLE tmp_transacciones;
       DROP TABLE tmp_transacciones_cred;
       DROP TABLE tmp_transacciones_total; 
	   
	   
	   ---PROCESO PARA LA DESCARGA DE INFORMACION SEMANAL ANTERIOR 
	   
	   LET v_num_fecha = 4;      ----PARA QUE NO DESCARGUE NADA DE INFO
	 
	   IF v_num_fecha = 2 THEN 
	      LET v_fecha_rango1 = DATE(vfecha_hoy - 7);
          LET v_fecha_rango2 = vfecha_ant; 
		 
		  
		  
		  -- SE OBTIENE LA FECHA PARA ASIGNARSELA AL NOMBRE DEL ARCHIVO	
		  LET v_anio_fin = YEAR (vfecha_hoy);
		  LET v_mes_fin  = MONTH(vfecha_hoy);
		  LET v_dia_fin  = DAY  (vfecha_hoy); 
		  
		  IF  LEN (v_mes_fin) = 1 THEN 
		      LET  v_mes_fin  = 0 || v_mes_fin; 
	      END IF;
		  
		  IF  LEN (v_dia_fin) = 1 THEN 
		      LET  v_dia_fin  = 0 || v_dia_fin; 
	      END IF; 
		
		
		  LET v_f_fin = v_dia_fin || v_mes_fin || v_anio_fin ;
		  
		  
		  LET vsql = '';
		  LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
					 'UNLOAD TO /resplogifx/conciliachq/615_REP_SEM_OP_REL_PRO_'||v_f_fin||'.txt'||
					 ' SELECT * FROM informix.tblpldconci WHERE fecha >=  '''|| v_fecha_rango1 ||''' '|| 
					 'AND fecha <= '''|| v_fecha_rango2 ||''' " > /resplogifx/conciliachq/consulta_semanal.sql';
							
		  SYSTEM vsql; 
          
		  --/EJECUCION DEL ARCHIVO .SQL 
		  LET vsql = '';
		  LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/consulta_semanal.sql";
		  SYSTEM vsql;

	     
		----  LET v_fecha_rango1 = DATE(vfecha_hoy - 1 UNITS MONTH);       -----PARA  TEST 
		  
		  		  
		  ---PROCESO PARA LA DESCARGA DE INFORMACION MENSUAL ANTERIOR  
		  
		  IF MONTH(v_fecha_rango1)  <>  MONTH(vfecha_hoy) THEN 
		     LET v_f_fin = v_mes_fin || v_anio_fin;
			 LET v_mes_ante = MONTH(v_fecha_rango1); 
		     LET v_anio_ante = YEAR (v_fecha_rango1);
			 
			 
		  		  
		     LET vsql = '';   
			 LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
					    'UNLOAD TO /resplogifx/conciliachq/615_REP_MEN_OP_REL_PRO_'||v_f_fin||'.txt'||
				    	' SELECT * FROM informix.tblpldconci WHERE MONTH(fecha) = '''||v_mes_ante||''' AND YEAR(fecha) = '''||v_anio_ante||''' " > /resplogifx/conciliachq/consulta_mensual.sql';	
		     SYSTEM vsql; 
			 
			 --/EJECUCION DEL ARCHIVO .SQL 
		     LET vsql = '';
		     LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/consulta_mensual.sql";
		     SYSTEM vsql;
			 
			 
			 ---PROCESO PARA LA DESCARGA DE INFORMACION TRIMESTRAL
			 
			 
			 LET v_fecha_trime =  MONTH(vfecha_hoy);
		----	 LET v_fecha_trime = 4; -----PARA  TEST 
			 
			 IF v_fecha_trime = 4 THEN  
			 
			    LET vsql = '';   
			    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
						   'UNLOAD TO /resplogifx/conciliachq/615_REP_TIM_OP_REL_PRO_'||v_f_fin||'.txt'||
					       ' SELECT * FROM informix.tblpldconci WHERE MONTH(fecha)IN(1,2,3) AND YEAR(fecha) = '''||v_anio_ante||''' " > /resplogifx/conciliachq/consulta_trimestral.sql';
						   
			    SYSTEM vsql; 
			   
			    --/EJECUCION DEL ARCHIVO .SQL 
		        LET vsql = '';
		        LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/consulta_trimestral.sql";
		        SYSTEM vsql;			   
		   
			 END IF; 	

             IF v_fecha_trime = 7 THEN  
			 
			    LET vsql = '';   
			    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
						   'UNLOAD TO /resplogifx/conciliachq/615_REP_TIM_OP_REL_PRO_'||v_f_fin||'.txt'||
					       ' SELECT * FROM informix.tblpldconci WHERE MONTH(fecha)IN(4,5,6) AND YEAR(fecha) = '''||v_anio_ante||''' " > /resplogifx/conciliachq/consulta_trimestral.sql';
						   
			    SYSTEM vsql; 
			   
			    --/EJECUCION DEL ARCHIVO .SQL 
		        LET vsql = '';
		        LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/consulta_trimestral.sql";
		        SYSTEM vsql;			   
		   
			 END IF;	


             IF v_fecha_trime = 10 THEN  
			 
			    LET vsql = '';   
			    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
						   'UNLOAD TO /resplogifx/conciliachq/615_REP_TIM_OP_REL_PRO_'||v_f_fin||'.txt'||
					       ' SELECT * FROM informix.tblpldconci WHERE MONTH(fecha)IN(7,8,9) AND YEAR(fecha) = '''||v_anio_ante||''' " > /resplogifx/conciliachq/consulta_trimestral.sql';
						   
			    SYSTEM vsql; 
			   
			    --/EJECUCION DEL ARCHIVO .SQL 
		        LET vsql = '';
		        LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/consulta_trimestral.sql";
		        SYSTEM vsql;			   
		   
			 END IF;
 
             IF v_fecha_trime = 1 THEN  
			 
			    LET vsql = '';   
			    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
						   'UNLOAD TO /resplogifx/conciliachq/615_REP_TIM_OP_REL_PRO_'||v_f_fin||'.txt'||
					       ' SELECT * FROM informix.tblpldconci WHERE MONTH(fecha)IN(10,11,12) AND YEAR(fecha) = '''||v_anio_ante||''' " > /resplogifx/conciliachq/consulta_trimestral.sql';
						   
			    SYSTEM vsql; 
			   
			    --/EJECUCION DEL ARCHIVO .SQL 
		        LET vsql = '';
		        LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/consulta_trimestral.sql";
		        SYSTEM vsql;			   
		   
			  END IF; 
			 

					 
		  END IF; 

		  
       END IF; 


RETURN  vcodret;
END; 
END PROCEDURE;