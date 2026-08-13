CREATE PROCEDURE "informix".sp_carga_fal_fac_elect()
RETURNING   CHAR(5);


DEFINE vsqlerr        INTEGER;
DEFINE vcodret        CHAR(5);
DEFINE v_cuenta       CHAR(20);
DEFINE v_total        INTEGER;



DEFINE vcontador1     INTEGER;
DEFINE vcontador2     INTEGER;
DEFINE v_aniomes      CHAR(6);      

LET vsqlerr = 0; 
LET vcodret = "000";
LET v_cuenta = ""; 
LET vcontador1 = -1;
LET vcontador2 = 0;



BEGIN
	    ON EXCEPTION SET vsqlerr
	       SET DEBUG FILE TO "/resplogifx/conciliachq/fal.err";
	    	   TRACE ON;
               IF vsqlerr <> 0 THEN
                  LET vcodret = vsqlerr;
               RETURN vcodret;
               END IF;
        END EXCEPTION;
				   
        --SET DEBUG FILE TO '/resplogifx/conciliachq/fal.txt';
	    --TRACE ON;
	   	    
	    SET ISOLATION TO DIRTY READ;

		
		FOREACH WITH HOLD
		
                 SELECT cuenta,  aniomes  
                   INTO v_cuenta,v_aniomes 
                   FROM sc_maehis
                  WHERE fechafin = '01012018'
				  
				     IF vcontador1 = -1 THEN
				        LET vcontador1 = 0;
				        BEGIN WORK;
			        END IF;
					 
					 IF v_aniomes = '201712' THEN 
				        SELECT COUNT(1) 
				          INTO v_total
				          FROM sc_maehis_factelect
				         WHERE empresa = '001'
				           AND aniomes = '201712'
				           AND cuenta  =  v_cuenta;
					 
					        IF v_total = 0  THEN 
						       INSERT  INTO informix.sc_maehis_factelect
					           SELECT  empresa, 
						               aniomes,  
							    	   cuenta,     
							    	   fechaini,    
							    	   fechafin,     
							           sdo_mes_ant, 
							           totretiros,  
							           totdepositos, 
							           sdo_actual
					   	         FROM  sc_maehis
						        WHERE  empresa  = '001'
						          AND  cuenta   = v_cuenta
						          AND  aniomes  = '201712';	

					        END IF; 
							
				            LET vcontador1 = vcontador1 + 1;
			                LET vcontador2 = vcontador2 + 1;
					       
					        IF vcontador2 >= 1000 THEN
				               LET vcontador2 = 0;
				               COMMIT WORK;
				               BEGIN WORK;
				            END IF;
					 END IF;
					 
				     COMMIT WORK;
			         BEGIN WORK;
	     END FOREACH;	
		 
		 IF vcontador1 > -1 THEN		
		   COMMIT WORK;
		 END IF;
		
RETURN  vcodret;
END; 
END PROCEDURE;