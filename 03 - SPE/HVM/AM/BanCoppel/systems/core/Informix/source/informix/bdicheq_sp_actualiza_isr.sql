CREATE PROCEDURE "informix".sp_actualiza_isr( pEmpresa CHAR(3) ) 
  RETURNING CHAR(3);
         


       DEFINE vsqlerr INTEGER;
	   DEFINE vcodret CHAR(5);
	   DEFINE vCuenta CHAR(20);
	   DEFINE vfecha_ant  DATE;
	   DEFINE v_tasa_isr  MONEY (16,2);
	   DEFINE v_idreg   INTEGER;
	   DEFINE v_secuencia INTEGER;
	   DEFINE vCuenta_1 CHAR(20);
	 
	   
	   
	   LET vsqlerr = 0; 
       LET vcodret = '000'; 
	   LET vfecha_ant = "";    
       LET vCuenta = "";    	   
	  
	   
	   
	 BEGIN
	 ON EXCEPTION SET vsqlerr
	    SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/isr_error.txt";
	 	   TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	 
	 
	  SELECT fecha_ant 
        INTO vfecha_ant
        FROM sc_fechas
       WHERE empresa = pEmpresa;
	 
	 
      --SE OBTIENE LA SECUENCIA	
	  LET v_secuencia  =  year(vfecha_ant)||lpad(month(vfecha_ant),2,"0");	 
	  
	  
	  
	   SELECT num_cuenta, idreg 
	     FROM sc_encabezado2_edocta_factelect_old 
		WHERE tasaisr is null  
          AND fecha_emision = '12312017' 
		 INTO TEMP tmp_sc_encabezado2_edocta_factelect_old  with no log; 
	  
	  
	  
	  FOREACH WITH HOLD
	 
	    SELECT num_cuenta ,idreg
	      INTO vCuenta , v_idreg
	      FROM tmp_sc_encabezado2_edocta_factelect_old
	        
	   

        SELECT first 1 tasa_isr
          INTO v_tasa_isr
          FROM sc_isr  
         WHERE cuenta    = vCuenta
           AND secuencia = v_secuencia
           AND tasa_isr  > 0;
  
	         
			  IF v_tasa_isr IS NULL  THEN 
			    LET v_tasa_isr = 0;
			  END IF;

			  
			  BEGIN; 
	          UPDATE  sc_encabezado2_edocta_factelect_old
	          SET tasaisr  = v_tasa_isr
	          WHERE  num_cuenta = vCuenta
			  AND  tasaisr IS NULL
			  AND  fecha_emision = '12312017'
			  AND  idreg = v_idreg;
			  COMMIT;
			  
	   END FOREACH;
			  
	 
 RETURN vcodret;
	  
END;
END PROCEDURE;