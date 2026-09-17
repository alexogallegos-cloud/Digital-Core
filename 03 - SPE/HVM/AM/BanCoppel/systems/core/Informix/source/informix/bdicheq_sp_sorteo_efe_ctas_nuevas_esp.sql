CREATE PROCEDURE "informix".sp_sorteo_efe_ctas_nuevas_esp (p_empresa char(3),p_especial INTEGER)
RETURNING   CHAR(5);
            

DEFINE vsqlerr           INTEGER;
DEFINE vcodret           CHAR(5);
DEFINE v_cuenta          CHAR(20); 
DEFINE v_monto           MONEY(14,2);
DEFINE v_fecha_alta      DATE;
                         
DEFINE vcomienza         SMALLINT;
DEFINE vcomienza2        SMALLINT;
DEFINE vcomienza3        SMALLINT;
DEFINE vcomienza4        SMALLINT;
DEFINE ven_transacc      SMALLINT;
DEFINE ven_transacc2     SMALLINT;
DEFINE ven_transacc3     SMALLINT;
DEFINE ven_transacc4     SMALLINT;
DEFINE vcontador1        INTEGER;
DEFINE vcontador2        INTEGER;
DEFINE vcontador3        INTEGER;
DEFINE vcontador4        INTEGER;

DEFINE v_c_cuenta        CHAR(20);
DEFINE v_c_producto      CHAR(4);
DEFINE v_c_sucursal      CHAR(4);
DEFINE v_c_fecha_alta    DATE;
DEFINE v_c_vcontador     INTEGER;
DEFINE v_c_vcomienza     SMALLINT;
DEFINE v_c_ven_transacc  SMALLINT;


DEFINE v_fecha_hoy       DATE; 
DEFINE v_dia             INT;
DEFINE v_trunca          INT;
DEFINE v_pri_dia_mes     DATE;
DEFINE v_ult_dia_mes_ant DATE;
DEFINE v_quincena        DATE;
DEFINE v_quincena_2      DATE;
DEFINE v_p_dia_mes_ant   DATE;
DEFINE v_fecha1          DATE;
DEFINE v_fecha2          DATE;


DEFINE v_sucursal        CHAR(4);
DEFINE v_valor1          SMALLINT; 
DEFINE v_valor2          SMALLINT;
DEFINE v_valor3          SMALLINT; 
DEFINE v_valor4          SMALLINT; 
DEFINE v_valor5          SMALLINT; 
DEFINE v_valor6          SMALLINT; 
DEFINE v_valor7          SMALLINT;
DEFINE v_valor8          SMALLINT; 
DEFINE v_valor9          SMALLINT;
DEFINE v_gcb             CHAR(3);
DEFINE v_czb             CHAR(3);

DEFINE v_sucursal_fin    CHAR(4);
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
DEFINE v_fecha_hoy_esp   DATE;


DEFINE vsql              CHAR(500); 
DEFINE v_mes_archivo     INT; 
DEFINE v_mes_letra       VARCHAR(15);
DEFINE v_esp_dia         CHAR(2);
DEFINE v_esp_mes         CHAR(2);
DEFINE v_esp_anio        CHAR(2);

LET vsqlerr              = 0; 
LET vcodret              = "00000";

LET v_c_vcomienza        = -1;
LET vcomienza            = -1;
LET vcomienza2           = -1;
LET vcomienza3           = -1;
LET vcomienza4           = -1;
LET v_c_ven_transacc     = 0;
LET ven_transacc         = 0;
LET ven_transacc2        = 0;
LET ven_transacc3        = 0;
LET ven_transacc4        = 0;
LET v_c_vcontador        = 0;
LET vcontador1           = 0;
LET vcontador2           = 0;
LET vcontador3           = 0;
LET vcontador4           = 0;
LET v_gcb                = 'N/A';
LET v_czb                = 'N/A';
LET v_anio_mes           = '';
LET v_saldo_pro          = 0;



BEGIN
	 ON EXCEPTION SET vsqlerr
	    SET DEBUG FILE TO "/resplogifx/conciliachq/sorteo.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	 
    -- SET DEBUG FILE TO '/informix/rsv/avance_sorteo_efectivo/sorteo.txt';
	-- SET DEBUG FILE TO '/resplogifx/conciliachq/sorteo.txt';
	-- TRACE ON;
	 	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy
	INTO   v_fecha_hoy_esp
	FROM   sc_fechas
	WHERE  empresa = '001'; 
	
    LET  v_esp_mes  = TO_CHAR(v_fecha_hoy_esp,'%m');     
    LET  v_esp_anio = TO_CHAR(v_fecha_hoy_esp,'%Y'); 
	
    --- Cuando p_especial = 1 va considerar proceso para el dia 17
	IF  p_especial = 1 THEN 
	    LET v_esp_dia = '17';
	    LET v_fecha_hoy = v_esp_mes||v_esp_dia ||v_esp_anio;
	END IF;
	
	IF  p_especial = 2 THEN 
	    LET v_esp_dia = '02';
	    LET v_fecha_hoy = v_esp_mes||v_esp_dia ||v_esp_anio;
	END IF;
		
	--OBTIENE LAS FEHAS PARA LOS REPORTES  
	SELECT pri_dia_mes, 
		   DATE(pri_dia_mes - 1  UNITS DAY), 
		   DATE(pri_dia_mes - 1 UNITS MONTH)
	  INTO v_pri_dia_mes, 
	       v_ult_dia_mes_ant, 
		   v_p_dia_mes_ant
	  FROM sc_fechas
	 WHERE empresa = '001'; 
	 
	LET v_dia      =  DAY(v_fecha_hoy);
	LET v_quincena =  DATE(v_fecha_hoy - 2  UNITS DAY);

		
	--SI EL DIA DE EJECUCION NO ES DIA 2 O 17 DEL MES NO HACE NADA Y TERMINA EXITOSO 
	IF  v_dia  NOT IN (2,17) THEN 
	    RETURN vcodret;
    END IF;  
	
			
    -- SI EXISTE LA TABLA sc_rep_ctas_nuevas DEL R1 Y R2 LA TRUNCA 
	IF  EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rep_ctas_nuevas') THEN
        TRUNCATE  TABLE "informix".sc_rep_ctas_nuevas;
    END IF;

	
		---*****************************************************  R1 - R2 ********************************************************************
		---*****************************************************  R1 - R2 ********************************************************************
		
	--SI ES DIA 17 DEL MES  PROCESA INFORMACION DEL 1 AL 15 DEL MES ACTUAL  	 
	IF v_dia = 17 THEN 
	
	    SELECT cuenta, fecha_alta 
	    FROM   sc_maenoc
	    WHERE  fecha_alta BETWEEN v_pri_dia_mes AND v_quincena
	    INTO  TEMP tmp_sc_maenoc WITH NO LOG;
	    
	    CREATE INDEX idx_tmp_sc_maenoc ON tmp_sc_maenoc(cuenta);
	
	    FOREACH WITH HOLD
	
	          -- INSERT INTO sc_ctas_nuevas (cuenta,producto,sucursal,fecha_alta) 	
			   SELECT chq.cuenta,  
                      chq.producto,
	   	              chq.sucursal,
	   	              noc.fecha_alta
			     INTO v_c_cuenta,    
				      v_c_producto, 
				      v_c_sucursal , 
				      v_c_fecha_alta
                 FROM sc_maechq     AS chq,
                      tmp_sc_maenoc AS noc
                WHERE chq.cuenta = noc.cuenta
                  AND chq.producto IN('2000','1900','1700','1400')
	              AND chq.status_cta <> '2'
	            ---- AND noc.fecha_alta  BETWEEN v_pri_dia_mes AND v_quincena 
				  
				  
			      IF (v_c_vcomienza = -1) THEN
                     LET v_c_vcomienza = 0;
                     LET ven_transacc = 1;
                     BEGIN WORK;
                 END IF;
				  
				
				 
		      INSERT INTO sc_ctas_nuevas (cuenta,    producto,    sucursal,    fecha_alta)
			         VALUES           (v_c_cuenta,v_c_producto,v_c_sucursal,v_c_fecha_alta);   
				  
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
		
		LET v_fecha1 = v_pri_dia_mes;
		LET v_fecha2 = v_quincena;
			  
    END IF; 
	
	
	--SI ES DIA 2 DEL MES  PROCESA INFORMACION DEL DIA 15 DEL MES ANTERIOR AL ULTIMO DIA DEL MES ANTERIOR 
	IF v_dia = 2 THEN 
	
	    -- SI EXISTE LA TABLA sc_rep_ctas_nuevas_sp DEL R1 Y R2 LA TRUNCA 
	   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rep_ctas_nuevas_sp') THEN
          TRUNCATE  TABLE "informix".sc_rep_ctas_nuevas_sp;
       END IF;
	
	   LET v_quincena_2 =  DATE(v_p_dia_mes_ant + 15  UNITS DAY); 
	   	   	   
	   SELECT cuenta, fecha_alta 
	   FROM   sc_maenoc
	   WHERE  fecha_alta BETWEEN v_quincena_2 AND v_ult_dia_mes_ant
	   INTO   TEMP tmp_sc_maenoc WITH NO LOG;
	
	   CREATE INDEX idx_tmp_sc_maenoc ON tmp_sc_maenoc(cuenta);
	   	   
	   FOREACH WITH HOLD
	   
	          --INSERT INTO sc_ctas_nuevas (cuenta,producto,sucursal,fecha_alta) 	
	           SELECT chq.cuenta,  
                      chq.producto,
	          	      chq.sucursal,
	          	      noc.fecha_alta
				 INTO v_c_cuenta,    
				      v_c_producto, 
				      v_c_sucursal , 
				      v_c_fecha_alta  
                FROM sc_maechq     AS chq,
                     tmp_sc_maenoc AS noc
               WHERE chq.cuenta = noc.cuenta
                 AND chq.producto IN('2000','1900','1700','1400')
	             AND chq.status_cta <> '2'
	            --- AND noc.fecha_alta  BETWEEN  v_quincena_2 AND v_ult_dia_mes_ant 
		  
		              IF (v_c_vcomienza = -1) THEN
                          LET v_c_vcomienza = 0;
                          LET ven_transacc = 1;
                          BEGIN WORK;
                      END IF;
				 
		           INSERT INTO sc_ctas_nuevas (cuenta,    producto,    sucursal,    fecha_alta)
			              VALUES           (v_c_cuenta,v_c_producto,v_c_sucursal,v_c_fecha_alta);     
				  
				      LET v_c_vcontador = v_c_vcontador + 1;
			   
			           IF (v_c_vcontador >= 5000) THEN
                          LET v_c_vcontador = 0;
                          COMMIT WORK;
                          BEGIN WORK;
                      END IF; 
  
				  
        END FOREACH; 
		
		
		IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

		LET v_fecha1 = v_quincena_2;       --APARTIR DEL DIA 16 
		LET v_fecha2 = v_ult_dia_mes_ant; -- HASTA EL ULTIMO DIA DEL MES
		  
    END IF; 
	
	
	--OBTIENE EL VALOR PARA PODER INGRESAR A LA TABLA DE MOVHIS
	SELECT valor::date 
      INTO v_fechcon_movhis
 	  FROM sc_param WHERE codparam = 'fechcon_movhis';
	

	--CICLO PARA OBTENER EL MONTO DE APERTURA 
	FOREACH WITH HOLD
	      		  
		      SELECT cuenta  , fecha_alta
		        INTO v_cuenta, v_fecha_alta
			    FROM sc_ctas_nuevas
			   WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2

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
			
			             -- SI LA CUENTA NO TIENE MONTO DE APERTURA SE DEFINIRA LA VARIABLE CON VALOR 0 
                         IF v_monto IS NULL OR v_monto = '' THEN 
					        LET v_monto = 0; 
					    END IF;
					
					
			         --ACTUALIZA EL MONTO DE APERTURA EN LA TABLA QUE VA A CONCENTRAR LAS CUENTAS  NUEVAS
		              UPDATE sc_ctas_nuevas
			             SET monto      = v_monto
			           WHERE fecha_alta = v_fecha_alta
			             AND cuenta     = v_cuenta;			  

				
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
   
    --OBTIENE LAS SUCURSALES QUE SE VAN A PROCESAR EN ESE PERIODO 
    SELECT DISTINCT(sucursal)  FROM sc_ctas_nuevas  WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2 
	  INTO TEMP tmp_sc_sucursales_p;
	
	-- CICLO PARA OBTENER CANTIDAD DE CUENTAS NUEVAS Y ASIGNARLAS AL RANGO QUE LES CORRESPONDE DEPENDIENDO DE SU SALDO DE APERTURA 
	FOREACH WITH HOLD
	
	      SELECT sucursal
		    INTO v_sucursal
			FROM tmp_sc_sucursales_p
			
			 IF (vcomienza2 = -1) THEN
                 LET vcomienza2 = 0;
                 LET ven_transacc = 1;
                 BEGIN WORK;
             END IF;

			  
          SELECT sucursal,                                                                                                            
     			 (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND (( monto = 0 ) OR  (monto IS NULL)))   AS  A,
                 (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 0.01      AND 29.99)    AS  B,
	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 30        AND 200)      AS  C,
                 (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 200.01    AND 299.99)   AS  D,
	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 300       AND 1000)     AS  E, 
	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 1000.01   AND 10000)    AS  F,
	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 10000.01  AND 100000)   AS  G,
	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 100000.01 AND 500000)   AS  H,
				 (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2  AND sucursal  = v_sucursal AND  monto BETWEEN 500000.01 AND 1000000)  AS  I
			INTO v_sucursal_fin,v_valor1,v_valor2,v_valor3,v_valor4,v_valor5,v_valor6,v_valor7,v_valor8,v_valor9
            FROM sc_ctas_nuevas
		   WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2
             AND sucursal = v_sucursal
        GROUP BY sucursal;
	   
	      --INSERTA VALORES OBTENIDOS POR SUSURSAL A LA TABLA FINAL (R1-R2)
	      INSERT INTO sc_rep_ctas_nuevas VALUES (v_gcb,v_czb,v_sucursal_fin,'',v_valor1,v_valor2,v_valor3,v_valor4,v_valor5,v_valor6,v_valor7,v_valor8,v_valor9,v_fecha_hoy);
		 
		     LET vcontador2 = vcontador2 + 1;
			   
			  IF (vcontador2 >= 300) THEN
                 LET vcontador2 = 0;
                 COMMIT WORK;
                 BEGIN WORK;
             END IF;
		 
	END FOREACH;
	
	
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	
		
    DROP TABLE tmp_sc_sucursales_p; 
  
    IF   v_dia = 17 THEN 
	     --VARIABLES PARA LA FECHA MES ARCHIVO
         LET v_mes_archivo = MONTH(v_fecha_hoy);  
	ELSE 
	     IF v_dia = 2 THEN
	     --VARIABLES PARA LA FECHA MES ARCHIVO
         LET v_mes_archivo = MONTH(v_p_dia_mes_ant);
		 END IF;
	END IF; 
	   

	
     --OBTIENE EL MES NUMERO PARA SACAR EL EQUIVALENTE MES LETRA PARA CUALQUIERA DE LOS LOS REPORTES R1 O R2 O R3
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

    IF  v_dia = 17 THEN 
	    
	    --PROCESO PARA DESCARGAR EL ARCHIVO
	    LET vsql = ''; 
	    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '|| 
                   'UNLOAD TO   /resplogifx/conciliachq/Monitoreo_Quincenal_Por_Sucursal_ctasnuevas_Q1_mes_'||v_mes_letra||'.txt'|| 
                   '  SELECT gcb,czb,suc,signo,monto1,monto2,monto3,monto4,monto5,monto6,monto7,monto8,monto9 FROM sc_rep_ctas_nuevas  ORDER BY suc ASC;   " >   /resplogifx/conciliachq/rep_ctas_nuevas_consulta.sql'; 
                
        SYSTEM vsql; 
        
        --EJECUCION DEL ARCHIVO .SQL 
        LET vsql = ''; 
        LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/rep_ctas_nuevas_consulta.sql"; 
        SYSTEM vsql; 
		
	END IF; 
	
	IF  v_dia = 2 THEN 
	    
	    --PROCESO PARA DESCARGAR EL ARCHIVO
	    LET vsql = ''; 
	    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '|| 
                   'UNLOAD TO /resplogifx/conciliachq/Monitoreo_Quincenal_Por_Sucursal_ctasnuevas_Q2_mes_'||v_mes_letra||'.txt'|| 
                   ' SELECT gcb,czb,suc,signo,monto1,monto2,monto3,monto4,monto5,monto6,monto7,monto8,monto9 FROM sc_rep_ctas_nuevas ORDER BY suc ASC;   " >  /resplogifx/conciliachq/rep_ctas_nuevas_consulta.sql'; 
                
        SYSTEM vsql; 
        
        --EJECUCION DEL ARCHIVO .SQL 
        LET vsql = ''; 
        LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/rep_ctas_nuevas_consulta.sql"; 
        SYSTEM vsql; 
		
	END IF; 

	---******************************************************** R3 ********************************************************************
	---******************************************************** R3 ********************************************************************
	--SI ES DIA 2 DE EL MES INICIA REPORTE 3
    IF v_dia = 2 THEN 
	
	   --OBTIENE ANIOMES 
	   LET v_mes  = MONTH (v_p_dia_mes_ant);
	   LET v_anio = YEAR (v_p_dia_mes_ant);
	   IF  LEN (v_mes) = 1 THEN 
	       LET  v_mes  = 0 || v_mes;
       END IF;

	   --IINICIALIZA LAS  VARIABLES PARA EL REPORTE 3 (TIENE QUE SE ACUMULADO)
	   LET v_anio_mes = v_anio || v_mes; 
	   LET v_fecha1 = v_p_dia_mes_ant;
	   LET v_fecha2 = v_ult_dia_mes_ant;

	   		
	   --CLICLO PARA OBTENER EL SALDO PROMEDIO DE LAS CUENTAS DE TODO EL MES ANTERIOR 
	   FOREACH WITH HOLD
	    
	         SELECT cuenta     ,sucursal       ,fecha_alta   
	           INTO v_cuenta_sp,v_sucursal_sp  ,v_fecha_alta_sp
			   FROM sc_ctas_nuevas
			  WHERE fecha_alta BETWEEN  v_fecha1  AND v_fecha2
			  
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

			     IF v_diacum > 0 THEN 
                    LET v_saldo_pro = (v_capvig1 /	v_diacum);
					
					--ACTUALIZA EL CAMPOS DEL SALDO PROMEDIO EN LA TABLA QUE CONCENTRA LAS CUENTAS 
					UPDATE sc_ctas_nuevas SET saldo_prom = v_saldo_pro  WHERE fecha_alta = v_fecha_alta_sp AND sucursal = v_sucursal_sp AND cuenta = v_cuenta_sp;
				END IF; 

                LET vcontador3 = vcontador3 + 1;
			   
			     IF (vcontador3 >= 5000) THEN
                    LET vcontador3 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;

		END FOREACH; 
		
		IF ven_transacc = 1 THEN
           LET ven_transacc = 0;
           COMMIT WORK;
       END IF;	
	   
	   
   
       --OBTIENE TODAS LAS SUCURSALES  DE LAS CUENTAS NUEVAS
       SELECT DISTINCT(sucursal)  FROM sc_ctas_nuevas  -----WHERE monto > 0  AND saldo_prom > 0
         INTO TEMP tmp_sc_sucursales_p;
       	
		--OBTIENE LA CANTIDAD DE CUENTAS NUEVAS  HASTA EL DIA ACTUAL POR SUCURSAL
       	FOREACH WITH HOLD
       	
       	      SELECT sucursal
       		    INTO v_sucursal
       			FROM tmp_sc_sucursales_p
       			
       			       			
       			  IF (vcomienza4 = -1) THEN
                      LET vcomienza4 = 0;
                      LET ven_transacc = 1;
                      BEGIN WORK;
                  END IF;
       
              SELECT sucursal,
                     (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  ((saldo_prom = 0 ) OR (saldo_prom is null)))   AS  A,
                     (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 0.01      AND 29.99)        AS  B,
       	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 30        AND 200)          AS  C,
                     (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 200.01    AND 299.99)       AS  D,
       	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 300       AND 1000)         AS  E, 
       	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 1000.01   AND 10000)        AS  F,
       	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 10000.01  AND 100000)       AS  G,
       	             (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 100000.01 AND 500000)       AS  H,
       			     (SELECT COUNT(*) FROM sc_ctas_nuevas WHERE sucursal  = v_sucursal AND  saldo_prom BETWEEN 500000.01 AND 1000000)      AS  I
					INTO v_sucursal_fin,v_valor1,v_valor2,v_valor3,v_valor4,v_valor5,v_valor6,v_valor7,v_valor8,v_valor9
                FROM sc_ctas_nuevas
       		   WHERE sucursal = v_sucursal
               GROUP BY sucursal;
       	   
       	         --INSERTA EN LA TABLA FINAL sc_rep_ctas_nuevas_sp LA CANTIDAD DE CUENTAS POR SUCURSAL  DONDE SU SALDO PROMEDIO ENTRA EN LOS RANGOS DEFINIDOS 
       	     INSERT INTO sc_rep_ctas_nuevas_sp VALUES (v_gcb,v_czb,v_sucursal_fin,'',v_valor1,v_valor2,v_valor3,v_valor4,v_valor5,v_valor6,v_valor7,v_valor8,v_valor9,v_fecha_hoy);
       		 
       		    LET vcontador4 = vcontador4 + 1;
       			   
       			 IF (vcontador4 >= 300) THEN
                    LET vcontador4 = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;

       	END FOREACH;
       	
       	
       	IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;	
        
		DROP TABLE tmp_sc_sucursales_p;
	 
	   --PROCESO PARA DESCARGAR EL ARCHIVO REPORTE 3
	    LET vsql = ''; 
	    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '|| 
                   'UNLOAD TO  /resplogifx/conciliachq/Monitoreo_Quincenal_Por_Sucursal_saldopromedio_acumulado_mes_'||v_mes_letra||'.txt'|| 
                   ' SELECT gcb,czb,suc,signo,monto1,monto2,monto3,monto4,monto5,monto6,monto7,monto8,monto9 '||
				   'FROM sc_rep_ctas_nuevas_sp WHERE  monto1 > 0 OR monto2 > 0  OR monto3 > 0  OR monto4 > 0 OR monto5 > 0 OR monto6 > 0 '|| 
                   ' OR monto7 > 0 OR monto8 > 0 OR monto9 > 0 ORDER BY suc ASC;   " >  /resplogifx/conciliachq/rep_ctas_nuevas_sp_consulta.sql'; 
                
        SYSTEM vsql; 
        
        --EJECUCION DEL ARCHIVO .SQL 
        LET vsql = ''; 
        LET vsql = "dbaccess bdicheq  /resplogifx/conciliachq/rep_ctas_nuevas_sp_consulta.sql"; 
        SYSTEM vsql; 
		
	END IF; 
	
	--INICIALIZA LA TABLA DE CUENTAS NUEVAS
	LET v_trunca = MONTH(v_fecha_hoy);
	IF  v_trunca = 1 AND  v_dia = 2 THEN 
        TRUNCATE TABLE sc_ctas_nuevas; 
    END IF;  

	
RETURN  vcodret;
END; 
END PROCEDURE;