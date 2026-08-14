CREATE PROCEDURE "informix".sp_limite_cuentas(p_cliente CHAR(20))
	RETURNING   CHAR(3),
				CHAR(2);
			

    DEFINE vsqlerr   INTEGER;
    DEFINE vcodret   CHAR(5);
    DEFINE vnu_cte   CHAR(20);      ---NUMERO DE CLIENTE
    DEFINE vcatidad  INTEGER;       ---CANTIDAD MAXIMA DE APERTURA DE CUENTAS
    DEFINE vtotal    INTEGER;       ---TOTAL DE CUENTAS DEL CLIENTE
    DEFINE vres_fin  CHAR(2);       ---RESULTADO FINAL ENTRE '0' o '1'
    
		
    LET vsqlerr      = 0; 
    LET vcodret      = '000';
    LET vres_fin     = '';
    LET vnu_cte      = '';
	

    BEGIN
	ON EXCEPTION SET vsqlerr
	   SET DEBUG FILE TO "/informix/Raull/ERRRR.TXT";
		   TRACE ON;
           IF vsqlerr <> 0 THEN
              LET vcodret = vsqlerr;
           RETURN vcodret,vres_fin;
           END IF;
    END EXCEPTION;
	
    ---SET DEBUG FILE TO '/informix/Raull/ERRRR.TXT';
	---TRACE ON;
	
	SET ISOLATION TO DIRTY READ;

	---OBTIENE EL NUMERO DE CLIENTE 
	SELECT numero_cliente
	  INTO vnu_cte 
	  FROM sc_limite_cuentas   ---NUEVA TABLA 
	 WHERE numero_cliente = p_cliente
	   AND status      = 1;
	   
	   ---SI NO ESTA EN LA TABLA REALIZA EL PROCESO 
	   IF vnu_cte IS NULL OR vnu_cte = '' THEN 
	       SELECT valor
             INTO vcatidad
             FROM sc_param 
	        WHERE empresa     = '001'
              AND descripcion = 'Limite maximo de cuenta';
			
			---OBTIENE LA CANTIDA DE CUENTAS DE CAPTACION 
		   SELECT COUNT(*) 
		     INTO vtotal  
		     FROM sc_maechq 
		    WHERE num_cte 	  = p_cliente
			  AND producto    <> '1100' 
			  AND status_cta  IN ('1','3','4','5');
			  
			
			      ---VALIDA QUE LA CUENTA NO EXEDA EL LIMITE DE 6 CREDITOS 
			      IF  vtotal >= vcatidad  THEN 
				      LET vres_fin = '1';
					  LET vcodret  = '000';
				      RETURN vcodret,vres_fin;
			    ELSE 
				      LET vres_fin = '0';
					  LET vcodret = '000';
				      RETURN vcodret,vres_fin;
		      END IF;  
	 ELSE 
		  LET vres_fin = '0';
		  LET vcodret  = '000';
		  RETURN vcodret,vres_fin;
   END IF;
END; 
END PROCEDURE;