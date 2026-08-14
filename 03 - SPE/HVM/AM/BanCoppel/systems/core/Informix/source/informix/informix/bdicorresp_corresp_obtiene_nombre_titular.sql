CREATE PROCEDURE "informix".corresp_obtiene_nombre_titular( pc_costos CHAR(4),      --- SUCURSAL
                                                           pusuario CHAR(8),       --- USUARIO
                                                           pnum_tarjeta CHAR(16),  --- TARJETA
										                   pcuenta CHAR(20))       --- CUENTA
                                        
RETURNING CHAR(3),  --- CODIGO DE RETORNO
          CHAR(53); --- NOMBRE CORTO DEL CLIENTE

          DEFINE sql_err          INTEGER;
          DEFINE isam_err         INTEGER;
          DEFINE vcodret1         CHAR(3);
          DEFINE vcodret2         CHAR(5);
	      DEFINE vNum_cte         CHAR(9);    --- numero de cliente 
	      DEFINE cNombreCortoCgo  CHAR(53);     ---- nombre cliente
          DEFINE vNum_cte_ta	  CHAR(9);    --- numero de cliente 
	      DEFINE vNum_cte_cred    CHAR(9);    --- numero de cliente 
	      DEFINE vproceso         CHAR(1);
							
          LET sql_err  = 0;
          LET isam_err = 0;
          LET vcodret1 = '000';
          LET vcodret2 = '000';
  	      LET cNombreCortoCgo = ''; 
	      LET vNum_cte =  '';
	      LET vproceso = '0';
	

     -- SET DEBUG FILE TO "/informix/ids_10UC11/raul/error.txt";
     -- TRACE ON;
    
    BEGIN
    ON EXCEPTION SET sql_err, isam_err
         SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_dep.err";
         TRACE ON;
        IF sql_err <> 0 THEN
             LET vcodret1 = sql_err;
             LET vcodret2 = isam_err;
			 IF vproceso = '1' THEN
                LET vcodret1 = '000';
             ELSE
                LET vcodret1 = '999';
             END IF; 
             RETURN vcodret1, cNombreCortoCgo; 
        END IF;
    END EXCEPTION;
   
   
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    
    -- 
    IF (pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario  is null OR pusuario  = '' OR LENGTH(pusuario) <> 8)  OR 
	   ((pcuenta  is null OR pcuenta   = '' OR LENGTH(pcuenta)  <> 11) AND (pnum_tarjeta is null OR pnum_tarjeta = '' OR LENGTH(pnum_tarjeta) <> 16))  THEN
		LET vcodret1 = '110';
        RETURN vcodret1,cNombreCortoCgo;
    END IF;
		
		
	  -- 
	IF pnum_tarjeta is null OR pnum_tarjeta = '' THEN
        SELECT num_cte
		  INTO vNum_cte 
		  FROM bdicheq:sc_maechq
		 WHERE empresa = '001'
		   AND cuenta = pcuenta 
		   AND status_cta IN ('1','4','5'); 
		   
		   
		   IF   vNum_cte is null OR vNum_cte = '' THEN 
		        LET vcodret1 = '100';
			    RETURN vcodret1,cNombreCortoCgo;
		   ELSE
		      -- 
	           SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
	             INTO cNombreCortoCgo
	             FROM bdinteg:"informix".si_cliente
	            WHERE empresa = '001'
                  AND numcte =  vNum_cte; 
			 
			      LET vcodret1 = '000';
			      LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, " ");
			      RETURN vcodret1,cNombreCortoCgo;
	      END IF; 
    END IF; 
	
	

	-- 
	 
    IF pcuenta is null OR pcuenta = '' THEN 
       SELECT numcte
		 INTO vNum_cte_ta
	     FROM bdicheq:sc_tarjeta
        WHERE empresa = '001'
          AND num_tarjeta = pnum_tarjeta
          AND status_tar = 'A';	


          IF vNum_cte_ta is null OR vNum_cte_ta = '' THEN 
			 SELECT numcte
               INTO vNum_cte_cred	
		       FROM bdicred:sd_tarjeta
		      WHERE empresa = '001' 
			    AND num_tarjeta = pnum_tarjeta
                AND status_tar = 'A';
        ELSE 
		 
		  -- 
           	 SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
           	   INTO cNombreCortoCgo
           	   FROM bdinteg:"informix".si_cliente
           	  WHERE empresa = '001'
                AND numcte =  vNum_cte_ta;

			    LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, " ");
		        LET vcodret1 = '000';
			    RETURN vcodret1,cNombreCortoCgo;
	   END IF; 
		 
   				
     	   IF vNum_cte_cred is null OR vNum_cte_cred = '' THEN 
              LET vcodret1 = '100';
              RETURN vcodret1,cNombreCortoCgo;
   		        
         ELSE 
   	        -- 
              SELECT TRIM(nombre1)||' '||TRIM(apell_paterno)
                INTO cNombreCortoCgo
                FROM bdinteg:"informix".si_cliente
               WHERE empresa = '001'
                 AND numcte =  vNum_cte_cred;
   	          
   	             LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, " ");
                 LET vcodret1 = '000';
                 RETURN vcodret1,cNombreCortoCgo;
	   END IF; 

END IF; 
	   
	   
	   SELECT TRIM(nombre1)||' '||TRIM(apell_paterno) 
	     INTO cNombreCortoCgo
         FROM bdicheq:sc_maechq  AS mae
   INNER JOIN bdicheq:sc_tarjeta AS tar
           ON mae.cuenta = tar.cuenta AND  mae.num_cte = tar.numcte
   INNER JOIN bdinteg:"informix".si_cliente AS si
           ON mae.num_cte    = si.numcte 
          AND mae.status_cta IN ('1','4','5')
          AND tar.status_tar  = 'A'
          AND tar.num_tarjeta = pnum_tarjeta 
          AND mae.cuenta      =  pcuenta; 
		
		  LET cNombreCortoCgo = RPAD(cNombreCortoCgo, 53, " ");
		  
		  
		  IF  cNombreCortoCgo is null OR cNombreCortoCgo = '' THEN 
		      LET vcodret1 = '100';
			  RETURN vcodret1,cNombreCortoCgo;
		ELSE 
		      LET vcodret1 = '000';
			  IF  vcodret1 = '000' THEN  
                  LET vproceso = '1';
		      END IF 
			  RETURN vcodret1,cNombreCortoCgo;
	  END IF; 
   
   END;  
END PROCEDURE;