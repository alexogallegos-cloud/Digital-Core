CREATE PROCEDURE "informix".sp_calcula_masttro(p_empresa char(3))
RETURNING   CHAR(5);

DEFINE v_c_vcomienza      SMALLINT;
DEFINE ven_transacc       SMALLINT;
DEFINE v_c_vcontador      INTEGER;
DEFINE vsqlerr            INTEGER;
DEFINE vcodret            CHAR(5);
DEFINE vsql               CHAR(500);
DEFINE v_fecha_arch       CHAR(8);
DEFINE v_fecha_hoy        DATE; 
DEFINE v_cuenta           CHAR(20);
DEFINE v_cuenta_val_mov   CHAR(20);
DEFINE v_dia              INTEGER;
DEFINE v_ult_dia          INTEGER;
DEFINE vpri_mes_ant       DATE;
DEFINE vult_mes_ant       DATE;
DEFINE v_aniomes          CHAR(6);
DEFINE v_aniomes_ant      CHAR(6);
DEFINE v_saldo_fin        money(14,2);
DEFINE v_saldo_inicio     DECIMAL(14,2);
DEFINE v_num_serial       CHAR(20);
DEFINE v_monto_tot        money(14,2);
DEFINE v_fecha_val        DATE;
DEFINE v_fecha_val_set    CHAR(8);
DEFINE v_fecha_fin        DATE;
DEFINE v_fecha_ant        DATE;
DEFINE v_descripcion      CHAR(100);
DEFINE v_transaccion      CHAR(4);
DEFINE v_transa_codigo    CHAR(3);
DEFINE v_naturaleza       CHAR(1);
DEFINE v_tipo_tran        CHAR(2);
DEFINE v_mes_no_procesa   INTEGER;
DEFINE v_valida_tabla     INTEGER;
DEFINE p_masstro          CHAR(20);
DEFINE v_masttro          CHAR(20);
DEFINE v_valida_mov       INTEGER;


	
LET vsqlerr             = 0; 
LET vcodret             = "00000";
LET v_c_vcomienza       = -1;
LET ven_transacc        = 0;
LET v_c_vcontador       = 0;
LET vsql                = '';
LET p_masstro           = 'CTASMASTTRO';

BEGIN
	 ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/masttro.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
     --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/masttro.txt';
	 --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/masttro/masttro.txt';
	 --TRACE ON;
	
	   SET ISOLATION TO DIRTY READ;
	SELECT DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY) , fecha_hoy,     to_char (fecha_hoy,'%Y%m'), DATE(fecha_hoy - 1  UNITS DAY), fecha_ant
	  INTO vpri_mes_ant                     , vult_mes_ant                     , v_fecha_hoy,   v_aniomes                 , v_fecha_fin                   , v_fecha_ant
      FROM sc_fechas
     WHERE empresa = p_empresa;
 		
	   LET v_dia            = ((to_char(v_fecha_hoy,'%d'))::INTEGER);
	   LET v_ult_dia        = ((to_char(vult_mes_ant,'%d'))::INTEGER);
       LET v_aniomes_ant    = to_char (vpri_mes_ant,'%Y%m');
	   LET v_mes_no_procesa = MONTH(v_fecha_hoy);
	
	SELECT COUNT(*) 
	  INTO v_valida_tabla
	  FROM sysmaster:systabnames 
     WHERE partnum > 0 
	   AND tabname = 'sc_ctas_masttro_deta';
	   
	   --INICIALIZA LA TABLA 	   
	   IF v_valida_tabla > 0 THEN 
	      DELETE FROM sc_ctas_masttro_deta;
	   END IF 
	
			
	FOREACH WITH HOLD
	
	         SELECT cuenta 
			   INTO v_cuenta
               FROM sc_cuentas_masttro	
			  			  
			    -- Abre la transaccion 
		        IF (v_c_vcomienza = -1) THEN
                   LET v_c_vcomienza = 0;
                   LET ven_transacc = 1;
                   BEGIN WORK;
                END IF;
			
			    IF v_dia = 1 THEN    
			         IF v_ult_dia =  31 THEN 			   
				           SELECT a.capvig30,     b.sdo_dia_ant 
				             INTO v_saldo_inicio, v_saldo_fin
					         FROM sc_sdodiarioc as a,
                                  sc_maechq     as b   
					        WHERE a.cuenta  = b.cuenta 
					          AND a.aniomes = v_aniomes_ant
				              AND b.cuenta  = v_cuenta;
									  							  
	                 ELIF v_ult_dia = 30 THEN 
					         SELECT a.capvig29,     b.sdo_dia_ant 
				               INTO v_saldo_inicio, v_saldo_fin
					           FROM sc_sdodiarioc as a,
                                    sc_maechq     as b   
					          WHERE a.cuenta  = b.cuenta 
					            AND a.aniomes = v_aniomes_ant
				                AND b.cuenta  = v_cuenta;
					  		  
	                 ELIF v_ult_dia = 29  THEN 
					         SELECT a.capvig28,    b.sdo_dia_ant 
				               INTO v_saldo_inicio, v_saldo_fin
					           FROM sc_sdodiarioc as a,
                                    sc_maechq     as b   
					          WHERE a.cuenta  = b.cuenta 
					            AND a.aniomes = v_aniomes_ant
				                AND b.cuenta  = v_cuenta;
											
	                 ELIF v_ult_dia = 28 THEN 
					         SELECT a.capvig27,     b.sdo_dia_ant 
				               INTO v_saldo_inicio, v_saldo_fin
					           FROM sc_sdodiarioc as a,
                                    sc_maechq     as b   
					          WHERE a.cuenta  = b.cuenta 
					            AND a.aniomes = v_aniomes_ant
				                AND b.cuenta  = v_cuenta;
					  
		             END IF;
								
				ELIF v_dia = 2 THEN 
				    IF v_mes_no_procesa = 1 THEN 
					    SELECT a.capvig30,     b.sdo_dia_ant
				          INTO v_saldo_inicio, v_saldo_fin
					      FROM sc_sdodiarioc as a,
                               sc_maechq     as b   
					     WHERE a.cuenta  = b.cuenta 
					       AND a.aniomes = v_aniomes_ant
				           AND b.cuenta  = v_cuenta;
					ELSE 										 
				        IF v_ult_dia =  31 THEN 
					           SELECT a.capvig31,     b.sdo_dia_ant 
				                 INTO v_saldo_inicio, v_saldo_fin
					             FROM sc_sdodiarioc as a,
                                      sc_maechq     as b   
					            WHERE a.cuenta  = b.cuenta 
					              AND a.aniomes = v_aniomes_ant
				                  AND b.cuenta  = v_cuenta;
												   
				        ELIF v_ult_dia = 30 THEN
					           SELECT a.capvig30,     b.sdo_dia_ant 
				                 INTO v_saldo_inicio, v_saldo_fin
					             FROM sc_sdodiarioc as a,
                                      sc_maechq     as b   
					            WHERE a.cuenta  = b.cuenta 
					              AND a.aniomes = v_aniomes_ant
				                  AND b.cuenta  = v_cuenta;
							  				
			            ELIF v_ult_dia = 29  THEN 
					           SELECT a.capvig29,     b.sdo_dia_ant 
				                 INTO v_saldo_inicio, v_saldo_fin
					             FROM sc_sdodiarioc as a,
                                      sc_maechq     as b   
					            WHERE a.cuenta  = b.cuenta 
					              AND a.aniomes = v_aniomes_ant
				                  AND b.cuenta  = v_cuenta;
					    		           							
	                    ELIF v_ult_dia = 28  THEN 
					            SELECT a.capvig28,     b.sdo_dia_ant 
				                  INTO v_saldo_inicio, v_saldo_fin
					              FROM sc_sdodiarioc as a,
                                       sc_maechq     as b   
					             WHERE a.cuenta  = b.cuenta 
					               AND a.aniomes = v_aniomes_ant
				                   AND b.cuenta  = v_cuenta;
					    END IF;
					END IF;
		
			    ELIF v_dia = 3 THEN 
				     SELECT a.capvig1,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

				 
				ELIF v_dia = 4 THEN 
				     SELECT a.capvig2,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 5 THEN 
				     SELECT a.capvig3,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			
						
                ELIF v_dia = 6 THEN 
				     SELECT a.capvig4,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

				ELIF  v_dia = 7 THEN 
				     SELECT a.capvig5,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

			    ELIF v_dia = 8 THEN 
				     SELECT a.capvig6,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
				       FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
				      WHERE a.cuenta  = b.cuenta 
				        AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
	  
			   
			    ELIF v_dia = 9 THEN 
				     SELECT a.capvig7,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

				  
				ELIF v_dia = 10 THEN 
				     SELECT a.capvig8,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
				       FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
				      WHERE a.cuenta  = b.cuenta 
				        AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

							  
				ELIF v_dia = 11 THEN 
				     SELECT a.capvig9,      b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

							  
				ELIF v_dia = 12 THEN 
				     SELECT a.capvig10,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 13 THEN 
				     SELECT a.capvig11,     b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;

				ELIF v_dia = 14 THEN 
				    SELECT a.capvig12,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
				      FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
				     WHERE a.cuenta  = b.cuenta 
				       AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 15 THEN 
				    SELECT a.capvig13,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
				      FROM sc_sdodiarioc as a,
                            sc_maechq    as b   
				     WHERE a.cuenta  = b.cuenta 
				       AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 16 THEN 
				    SELECT a.capvig14,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				  
				ELIF v_dia = 17 THEN 
				    SELECT a.capvig15,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 18 THEN 
				    SELECT a.capvig16,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 19 THEN 
				    SELECT a.capvig17,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 20 THEN 
				    SELECT a.capvig18,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 21 THEN 
				    SELECT a.capvig19,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 22 THEN 
				    SELECT a.capvig20,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 23 THEN 
				    SELECT a.capvig21,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
	
				 
				ELIF v_dia = 24 THEN 
				    SELECT a.capvig22,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
					   				   
					   
			    ELIF v_dia = 25 THEN 
				    SELECT a.capvig23,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
			
				ELIF v_dia = 26 THEN
				        IF v_mes_no_procesa = 12 THEN 	
				           SELECT a.capvig23,     b.sdo_dia_ant 
				             INTO v_saldo_inicio, v_saldo_fin
					         FROM sc_sdodiarioc as a,
                                  sc_maechq     as b   
					        WHERE a.cuenta  = b.cuenta 
					          AND a.aniomes = v_aniomes
				              AND b.cuenta  = v_cuenta;
					    ELSE 
			               SELECT a.capvig24,     b.sdo_dia_ant 
				             INTO v_saldo_inicio, v_saldo_fin
					         FROM sc_sdodiarioc as a,
                                  sc_maechq     as b   
					        WHERE a.cuenta  = b.cuenta 
					          AND a.aniomes = v_aniomes
				              AND b.cuenta  = v_cuenta;
					    END IF;
			
			
				ELIF v_dia = 27 THEN 
				    SELECT a.capvig25,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 28 THEN 
				    SELECT a.capvig26,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 29 THEN 
				    SELECT a.capvig27,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			

				ELIF v_dia = 30 THEN 
				    SELECT a.capvig28,     b.sdo_dia_ant 
				      INTO v_saldo_inicio, v_saldo_fin
					  FROM sc_sdodiarioc as a,
                           sc_maechq     as b   
					 WHERE a.cuenta  = b.cuenta 
					   AND a.aniomes = v_aniomes
				       AND b.cuenta  = v_cuenta;
			
				 
				ELIF v_dia = 31 THEN 
				     SELECT a.capvig29,   b.sdo_dia_ant 
				       INTO v_saldo_inicio, v_saldo_fin
					   FROM sc_sdodiarioc as a,
                            sc_maechq     as b   
					  WHERE a.cuenta  = b.cuenta 
					    AND a.aniomes = v_aniomes
				        AND b.cuenta  = v_cuenta;
			
				END IF;

				SELECT COUNT(*)
				  INTO v_valida_mov
				  FROM sc_movhis           AS a,
	                   bdinteg:si_transacc AS b 
			     WHERE a.transacc  = b.numero 
	               AND a.empresa   = p_empresa
	               AND a.cuenta    = v_cuenta
                   AND a.fech_alt  = v_fecha_ant
	               AND a.cancelad  <> 'S'
	               AND b.sistema   = '01'
	               AND b.se_emite_edocta = 'S'
	               AND b.se_contabiliza  = 'S'; 
                    
					IF v_valida_mov > 0 THEN 
				
				        FOREACH WITH HOLD
                  
				  	      SELECT a.num_serial, a.monto_tot, a.fech_alt , TRIM(a.referencia) || '/' || TRIM(b.descripcion) AS descripcion, a.transacc    ,b.naturaleza ,b.tipo_tran 
				  	        INTO v_num_serial, v_monto_tot, v_fecha_val, v_descripcion                                                  , v_transaccion ,v_naturaleza ,v_tipo_tran
				  	        FROM           sc_movhis AS a,
				  	             bdinteg:si_transacc AS b 
	                       WHERE a.transacc  = b.numero 
				  	         AND a.empresa   = p_empresa
	                         AND a.cuenta    = v_cuenta
		                     AND a.fech_alt  = v_fecha_ant
				  	         AND a.cancelad  <> 'S'
				  	         AND b.sistema   = '01'
				  	         AND b.se_emite_edocta = 'S'
				  		     AND b.se_contabiliza = 'S'
				  		     ORDER BY num_serial ASC

							 
				  	  	      IF v_transaccion = '3276' OR v_transaccion = '0207' THEN  
				  		         LET v_transa_codigo = 'INT';
				  		   
				  		     ELIF (v_transaccion = '3277' OR v_transaccion = '3278') AND v_tipo_tran = '02' THEN
				  		          LET v_transa_codigo = 'FEE';
				  		
				  		     ELIF v_tipo_tran = '01' OR v_tipo_tran = '05' THEN   
				  		          LET v_transa_codigo = 'COM';
				  		   
				  		     ELIF v_naturaleza = 'A' THEN  
				  		          LET v_transa_codigo = 'DEP';
				  		   
				  		     ELIF v_naturaleza = 'C' THEN 
				  			      LET v_transa_codigo = 'WIT';
				  		   END IF; 
	            
                           INSERT INTO sc_ctas_masttro_deta (Initial_Balance,Final_Balance,Account_Number,Transaction_Number,Transaction_Code,Net_Amount,Trade_Date,Settle_Date,Currency,Description_Comments)
                                VALUES(v_saldo_inicio,v_saldo_fin,v_cuenta,v_num_serial,v_transa_codigo,v_monto_tot,to_char(v_fecha_val,'%d/%m/%Y'),'','MXN',v_descripcion);
  
                        END FOREACH;
					ELSE 
						INSERT INTO sc_ctas_masttro_deta (Initial_Balance, Final_Balance, Account_Number , Transaction_Number, Transaction_Code, Net_Amount ,Trade_Date ,Settle_Date ,Currency ,Description_Comments)
                             VALUES                      (v_saldo_inicio,  v_saldo_fin,   v_cuenta       , ' '               , ' '             , ' '        ,' '        ,' '         ,' '      ,' ');
				    END IF;

			LET v_c_vcontador = v_c_vcontador + 1;
			--Realiza commit cada 1000 registros 
			IF (v_c_vcontador >= 50) THEN
               LET v_c_vcontador = 0;
               COMMIT WORK;
               BEGIN WORK;
            END IF; 
    END FOREACH;
   
	--Si la transaccion esta abierta realiza el commit
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	  

	  
    LET v_fecha_arch = to_char (v_fecha_ant,'%d%m%Y');
		
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
		       'UNLOAD TO /resplogifx/conciliachq/originales/masttro_'||v_fecha_arch||'.csv  delimiter ''","''   '||
		       'SELECT * FROM sc_ctas_masttro_deta" > /resplogifx/conciliachq/eje_mas.sql';
		
	SYSTEM vsql;

    --/EJECUCION DEL ARCHIVO .SQL 
    LET vsql = '';LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/eje_mas.sql"; 
    SYSTEM vsql;			
	
	
     /*		
	 --/COMPRIME EL ARCHIVO .SQL 
     LET vsql = '';
     LET vsql = '/usr/bin/gzip -9 /RESPALDOSNEW/Porta_prod_asoc'||v_fecha_arch||'.txt'; 
     SYSTEM vsql;
    */
	--PROCESO PARA CIFRAR LOS ARCHIVOS 
	LET v_masttro = TRIM(p_masstro);
	
	EXECUTE PROCEDURE bdinteg:"informix".sp_cifra_archivo_masttro(v_masttro) 
	INTO  vcodret;

	
						  
RETURN  vcodret;
END; 
END PROCEDURE;