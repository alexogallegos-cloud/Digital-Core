CREATE PROCEDURE "informix".sp_indicadores_sorteo (p_empresa char(3))
RETURNING   CHAR(5);
            

DEFINE vsqlerr           INTEGER;
DEFINE vcodret           CHAR(5);
DEFINE v_cuenta          CHAR(20); 
DEFINE v_monto           MONEY(14,2);
DEFINE v_fecha_alta      DATE;                    
DEFINE vcomienza         SMALLINT;
DEFINE vcomienza3        SMALLINT;
DEFINE ven_transacc      SMALLINT;
DEFINE vcontador1        INTEGER;
DEFINE vcontador3        INTEGER;
DEFINE v_c_cuenta        CHAR(20);
DEFINE v_c_producto      CHAR(4);
DEFINE v_c_sucursal      CHAR(4);
DEFINE v_c_fecha_alta    DATE;
DEFINE v_c_vcontador     INTEGER;
DEFINE v_c_vcomienza     SMALLINT;
DEFINE v_fecha_hoy       DATE; 
DEFINE v_dia             INT;
DEFINE v_ult_dia_mes_ant DATE;
DEFINE v_p_dia_mes_ant   DATE;
DEFINE v_ultimo_mes_penultimo DATE;
DEFINE v_valor1          VARCHAR(10); 
DEFINE v_valor2          VARCHAR(10);
DEFINE v_valor3          VARCHAR(10); 
DEFINE v_valor4          VARCHAR(10); 
DEFINE v_valor5          VARCHAR(10); 
DEFINE v_valor6          VARCHAR(10); 
DEFINE v_valor7          VARCHAR(10);
DEFINE v_valor8          VARCHAR(10); 
DEFINE v_valor9          VARCHAR(10);
DEFINE v_valor10         VARCHAR(10);
DEFINE v_cuenta_sp       CHAR(20); 
DEFINE v_sucursal_sp     CHAR(4);
DEFINE v_capvig1         DECIMAL(14,2);
DEFINE v_diacum          SMALLINT;
DEFINE v_mes             CHAR(2);
DEFINE v_anio            CHAR(4);
DEFINE v_anio_mes        CHAR(6);
DEFINE v_saldo_pro       MONEY(14,2);
DEFINE v_fechcon_movhis  DATE;
DEFINE v_fecha_alta_sp   DATE;
DEFINE v_tipo            VARCHAR(20);
DEFINE v_p_dia_penultimo_mes  DATE;
DEFINE vsql              CHAR(500); 
DEFINE v_mes_archivo     INT; 
DEFINE v_mes_letra       VARCHAR(15);

LET vsqlerr              = 0; 
LET vcodret              = "00000";
LET v_c_vcomienza        = -1;
LET vcomienza            = -1;
LET vcomienza3           = -1;
LET ven_transacc         = 0;
LET v_c_vcontador        = 0;
LET vcontador1           = 0;
LET vcontador3           = 0;
LET v_anio_mes           = '';
LET v_saldo_pro          = 0;



BEGIN
	ON EXCEPTION SET vsqlerr
	   SET DEBUG FILE TO "/resplogifx/conciliachq/indicadores_sorteo.err";
		    TRACE ON;
           IF vsqlerr <> 0 THEN
              LET vcodret = vsqlerr;
		   IF ven_transacc = 1 THEN
                 ROLLBACK WORK;
              END IF;
           RETURN vcodret;
           END IF;
    END EXCEPTION;
	 
    ---SET DEBUG FILE TO '/informix/rsv/101083/indicadores_sorteo.txt';
	-- SET DEBUG FILE TO '/resplogifx/conciliachq/indicadores_sorteo.txt';
	---TRACE ON;
	 
	
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3 ; 
	
	--OBTIENE LAS FEHAS PARA LOS REPORTES 
	SELECT fecha_hoy,  
	       DAY(fecha_hoy), 
	       DATE(pri_dia_mes - 1 UNITS MONTH),
		   DATE(pri_dia_mes - 1 UNITS DAY),
		   DATE(pri_dia_mes - 2 UNITS MONTH)
	  INTO v_fecha_hoy, 
	       v_dia, 
	       v_p_dia_mes_ant,
		   v_ult_dia_mes_ant,
	       v_p_dia_penultimo_mes   
	  FROM sc_fechas
	 WHERE empresa = p_empresa; 
	 
	

	IF  v_dia  NOT IN (3) THEN 
	    RETURN vcodret;
    END IF;  
			

	IF  EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_ctas_nuevas_ind') THEN
        TRUNCATE  TABLE "informix".sc_ctas_nuevas_ind;
    END IF;
	
    IF  EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rep_ctas_nuevas_ind') THEN
        TRUNCATE  TABLE "informix".sc_rep_ctas_nuevas_ind;
    END IF;
	

	--SOLO EL DIA 3 DE CADA MES SE REAZLIZA LA EJECUCION DEL PROCESO  
	IF v_dia = 3 THEN 
	    FOREACH WITH HOLD
	           -- SE EXTRAEN LAS CUENTAS NUEVAS EN UN RANGO DE LOS 2 MESES ANTERIORES A LA FECHA DE EJECUCION 
			  SELECT chq.cuenta,  
                     chq.producto,
	   	             chq.sucursal,
	   	             noc.fecha_alta
			    INTO v_c_cuenta,    
				     v_c_producto, 
				     v_c_sucursal , 
				     v_c_fecha_alta
                FROM sc_maechq AS chq,
                     sc_maenoc AS noc
               WHERE chq.cuenta = noc.cuenta
                 AND chq.producto IN('2000','1900','1700','1400')
	             AND chq.status_cta <> '2'
	             AND noc.fecha_alta  BETWEEN v_p_dia_penultimo_mes AND v_ult_dia_mes_ant 
				  
			      IF (v_c_vcomienza = -1) THEN
                     LET v_c_vcomienza = 0;
                     LET ven_transacc = 1;
                     BEGIN WORK;
                 END IF;
				  
		      INSERT INTO sc_ctas_nuevas_ind (cuenta,    producto,    sucursal,    fecha_alta)
			         VALUES                  (v_c_cuenta,v_c_producto,v_c_sucursal,v_c_fecha_alta);   
				  
				 LET v_c_vcontador = v_c_vcontador + 1;
			   
			     IF (v_c_vcontador >= 5000) THEN
                    LET v_c_vcontador = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF; 
				  				  
        END FOREACH; 
		
		
		 IF ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
					  
    END IF; 
	
	
	--OBTIENE EL VALOR PARA PODER INGRESAR A LA TABLA DE MOVHIS
	SELECT valor::date 
      INTO v_fechcon_movhis
 	  FROM sc_param WHERE codparam = 'fechcon_movhis';
	

	--CICLO PARA OBTENER EL MONTO DE APERTURA DE UN T-1 DE LAS CUENTAS OBTENIDAS PREVIAMENTE 
	FOREACH WITH HOLD
	      		  
		      SELECT cuenta  , fecha_alta
		        INTO v_cuenta, v_fecha_alta
			    FROM sc_ctas_nuevas_ind
			   WHERE fecha_alta BETWEEN  v_p_dia_mes_ant  AND v_ult_dia_mes_ant

			      IF (vcomienza = -1) THEN
                     LET vcomienza = 0;
                     LET ven_transacc = 1;
                     BEGIN WORK;
                 END IF;
			 
			  	  IF v_fecha_alta >= v_fechcon_movhis  THEN   
			         SELECT monto_tot
			           INTO v_monto
			           FROM sc_movhis
			          WHERE empresa  = p_empresa
			            AND cuenta   = v_cuenta
			        	AND fech_alt =  v_fecha_alta
			        	AND num_serial IN(SELECT MIN(num_serial) FROM sc_movhis WHERE empresa = p_empresa AND cuenta = v_cuenta AND fech_alt = v_fecha_alta);
						
			    ELSE    	
				
			         SELECT monto_tot
					   INTO v_monto
					   FROM sc_movhis_old
					  WHERE empresa  = p_empresa
					    AND cuenta   = v_cuenta
					    AND fech_alt =  v_fecha_alta
					    AND num_serial IN(SELECT MIN(num_serial) FROM sc_movhis_old WHERE empresa = p_empresa AND cuenta = v_cuenta AND fech_alt = v_fecha_alta);
			  END IF; 
			

			
			        IF (v_monto >= 0) THEN 
			         --ACTUALIZA EL MONTO DE APERTURA EN LA TABLA QUE VA A CONCENTRAR LAS CUENTAS  NUEVAS
		              UPDATE sc_ctas_nuevas_ind
			             SET monto      = v_monto
			           WHERE fecha_alta = v_fecha_alta
			             AND cuenta     = v_cuenta;	
                    END IF;						 

			           
                LET vcontador1 = vcontador1 + 1;
			           
			    IF (vcontador1 >= 5000) THEN
                    LET vcontador1 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;
                    
			    LET v_cuenta = '';
			    LET v_monto  = 0;

    END FOREACH;

    IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
	
	--SE EXTRAE EL MES PARA EL NOMBRE DEL ARCHIVO
    LET v_mes_archivo = MONTH(v_p_dia_mes_ant);

    IF  v_mes_archivo = 1 THEN  LET v_mes_letra = 'ENERO'; 
	    ELIF v_mes_archivo = 2 THEN  LET v_mes_letra = 'FEBRERO'; 
	    ELIF v_mes_archivo = 3 THEN  LET v_mes_letra = 'MARZO'; 
        ELIF v_mes_archivo = 4 THEN  LET v_mes_letra = 'ABRIL'; 
	    ELIF v_mes_archivo = 5 THEN  LET v_mes_letra = 'MAYO'; 
	    ELIF v_mes_archivo = 6 THEN  LET v_mes_letra = 'JUNIO'; 
	    ELIF v_mes_archivo = 7 THEN  LET v_mes_letra = 'JULIO'; 
	    ELIF v_mes_archivo = 8 THEN  LET v_mes_letra = 'AGOSTO'; 
	    ELIF v_mes_archivo = 9 THEN  LET v_mes_letra = 'SEPTIEMBRE'; 
	    ELIF v_mes_archivo = 10 THEN  LET v_mes_letra = 'OCTUBRE'; 
	    ELIF v_mes_archivo = 11 THEN  LET v_mes_letra = 'NOVIEMBRE'; 
	    ELIF v_mes_archivo = 12 THEN  LET v_mes_letra = 'DICIEMBRE';
	END IF;		
	
	LET v_tipo = 'Monto de Apertura';
    
	--SE OBTIENEN LOS RANGOS DE LAS CUENTAS 
	BEGIN;                                                         
    SELECT (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE (( monto = 0 ) OR  (monto IS NULL)) AND  fecha_alta >= v_p_dia_mes_ant ) AS  A,   
           (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 0.01   AND 34.99)      AS  B,
	       (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 35     AND 199.99)     AS  C,
           (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 200    AND 299.99)     AS  D,
	       (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 300    AND 999.99)     AS  E, 
	       (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 1000   AND 9999.99)    AS  F,
	       (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 10000  AND 99999.99)   AS  G,
	       (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 100000 AND 499999.99)  AS  H,
		   (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto BETWEEN 500000 AND 1000000.00) AS  I,
		   (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  monto >= 0)                          AS  J																				
	   INTO v_valor1,v_valor2,v_valor3,v_valor4,v_valor5,v_valor6,v_valor7,v_valor8,v_valor9,v_valor10
       FROM sc_ctas_nuevas_ind
	  GROUP BY 1,2,3,4,5,6,7,8,9,10;
	COMMIT;
	--INSERTA LA INFORMACION A LA TABLA FINAL QUE SE UTILIZARA PARA EL REPORTE. 
	BEGIN; 
	INSERT INTO sc_rep_ctas_nuevas_ind VALUES (v_mes_letra,
											   v_tipo   ,
											   v_valor1 ,
											   v_valor2 ,
											   v_valor3 ,
											   v_valor4 ,
											   v_valor5 ,
											   v_valor6 ,
											   v_valor7 ,
											   v_valor8 ,
											   v_valor9 ,
											   v_valor10,
											   v_fecha_hoy);
	COMMIT;	 
	    
	
	---******************************************************** R-SALDO PROMEDIO ********************************************************************
	---******************************************************** R-SALDO PROMEDIO ********************************************************************
	
	--SI ES DIA 3 DE EL MES INICIA REPORTE 3
    IF v_dia = 3 THEN 
	
	   --OBTIENE ANIOMES 
	   LET v_mes  = MONTH (v_p_dia_mes_ant);
	   LET v_anio = YEAR (v_p_dia_mes_ant);
	   IF  LEN (v_mes) = 1 THEN 
	       LET  v_mes  = 0 || v_mes;
       END IF;

	   --OPTIENE EL ANIOMES
	   LET v_anio_mes = v_anio || v_mes; 
        
	   LET v_ultimo_mes_penultimo  =  DATE(v_p_dia_mes_ant - 1 UNITS DAY);
	   	   		
	   --CLICLO PARA OBTENER EL SALDO PROMEDIO DE LAS CUENTAS 
	   FOREACH WITH HOLD
	    
	         SELECT cuenta     ,sucursal       ,fecha_alta   
	           INTO v_cuenta_sp,v_sucursal_sp  ,v_fecha_alta_sp
			   FROM sc_ctas_nuevas_ind
			  WHERE fecha_alta BETWEEN  v_p_dia_penultimo_mes  AND v_ultimo_mes_penultimo
			  
			    IF  (vcomienza3 = -1) THEN
                    LET vcomienza3 = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

			 SELECT capvigacum, diacum  
               INTO v_capvig1,  v_diacum      
		       FROM sc_sdodiarioc
			  WHERE cuenta  = v_cuenta_sp
			    AND aniomes = v_anio_mes
			    AND sucursal = v_sucursal_sp;

			    IF  v_diacum > 0 THEN 
                    LET v_saldo_pro = (v_capvig1 /	v_diacum);
					
					--ACTUALIZA EL CAMPOS DEL SALDO PROMEDIO EN LA TABLA QUE CONCENTRA LAS CUENTAS 
					UPDATE sc_ctas_nuevas_ind SET saldo_prom = v_saldo_pro  
					 WHERE fecha_alta = v_fecha_alta_sp 
					   AND sucursal = v_sucursal_sp 
					   AND cuenta = v_cuenta_sp;
				END IF; 

                LET vcontador3 = vcontador3 + 1;
			   
			    IF  (vcontador3 >= 5000) THEN
                    LET vcontador3 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;

		END FOREACH; 
		
		IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;	
		
        --SE EXTRAE EL MES PARA EL NOMBRE DEL ARCHIVO
	    LET v_mes_archivo = MONTH(v_p_dia_mes_ant);

        IF  v_mes_archivo = 1 THEN  LET v_mes_letra = 'ENERO'; 
	        ELIF v_mes_archivo = 2 THEN  LET v_mes_letra = 'FEBRERO'; 
	        ELIF v_mes_archivo = 3 THEN  LET v_mes_letra = 'MARZO'; 
            ELIF v_mes_archivo = 4 THEN  LET v_mes_letra = 'ABRIL'; 
	        ELIF v_mes_archivo = 5 THEN  LET v_mes_letra = 'MAYO'; 
	        ELIF v_mes_archivo = 6 THEN  LET v_mes_letra = 'JUNIO'; 
	        ELIF v_mes_archivo = 7 THEN  LET v_mes_letra = 'JULIO'; 
	        ELIF v_mes_archivo = 8 THEN  LET v_mes_letra = 'AGOSTO'; 
	        ELIF v_mes_archivo = 9 THEN  LET v_mes_letra = 'SEPTIEMBRE'; 
	        ELIF v_mes_archivo = 10 THEN  LET v_mes_letra = 'OCTUBRE'; 
	        ELIF v_mes_archivo = 11 THEN  LET v_mes_letra = 'NOVIEMBRE'; 
	        ELIF v_mes_archivo = 12 THEN  LET v_mes_letra = 'DICIEMBRE';
	    END IF;		
		
	   
	    LET v_tipo = 'Saldo Promedio';
        --SE OBTIENEN LOS RANGOS DE LAS CUENTAS 
	    BEGIN;
            SELECT (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom = 0 )                          AS  A,   
                   (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 0.01   AND 34.99)      AS  B,
	               (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 35     AND 199.99)     AS  C,
                   (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 200    AND 299.99)     AS  D,
	               (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 300    AND 999.99)     AS  E, 
	               (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 1000   AND 9999.99)    AS  F,
	               (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 10000  AND 99999.99)   AS  G,
	               (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 100000 AND 499999.99)  AS  H,
		           (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom BETWEEN 500000 AND 1000000.00) AS  I,
		           (SELECT COUNT(*) FROM sc_ctas_nuevas_ind WHERE  saldo_prom >= 0)                          AS  J																						            	
	               INTO v_valor1,v_valor2,v_valor3,v_valor4,v_valor5,v_valor6,v_valor7,v_valor8,v_valor9,v_valor10
              FROM sc_ctas_nuevas_ind
	         GROUP BY 1,2,3,4,5,6,7,8,9,10;
	    COMMIT;
		 
	    --INSERTA LA INFORMACION A LA TABLA FINAL QUE SE UTILIZARA PARA EL REPORTE. 	 
		BEGIN; 
	        INSERT INTO sc_rep_ctas_nuevas_ind VALUES (v_mes_letra,
		    									       v_tipo,
		    									       v_valor1 ,
		    									       v_valor2 ,
		    									       v_valor3 ,
		    									       v_valor4 ,
		    									       v_valor5 ,
		    									       v_valor6 ,
		    									       v_valor7 ,
		    									       v_valor8 ,
		    									       v_valor9 ,
		    									       v_valor10,
		    									       v_fecha_hoy);
	    COMMIT;	 
	    
        --PROCESO PARA DESCARGAR DEL REPORTE
	    LET vsql = ''; 
	    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '|| 
                   'UNLOAD TO   /resplogifx/conciliachq/Monitoreo_Mensual_IndicadoresCaptacion_SEF_mes_'||v_mes_letra||'.txt'|| 
                   '  SELECT mes,tipo,monto1,monto2,monto3,monto4,monto5,monto6,monto7,monto8,monto9 FROM sc_rep_ctas_nuevas_ind;   " >   /resplogifx/conciliachq/rep_ctas_nuevas_consulta_ind.sql'; 
                
        SYSTEM vsql; 
        
        --EJECUCION DEL ARCHIVO .SQL 
        LET vsql = ''; 
        LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/rep_ctas_nuevas_consulta_ind.sql"; 
        SYSTEM vsql; 
	    			
	END IF;   
	   
		
RETURN  vcodret;
END; 
END PROCEDURE;