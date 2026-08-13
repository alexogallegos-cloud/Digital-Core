CREATE PROCEDURE "informix".sp_query_cron_exp1(vfechacarga DATE)
	 RETURNING CHAR(5);
	    
		/*Definicion de variables del proceso y manejo de errores*/
		--DEFINE error_info 		CHAR(60);
		DEFINE vcodret    		CHAR(5);
		DEFINE error_info 		CHAR(60);
		DEFINE vsqlerr    		INTEGER;
		DEFINE isam_err   		SMALLINT;
		
		/*Inicializando variables de manejo de errores*/
		LET vcodret       	= '00000';
		LET error_info    	= 'Iniciando ejecucion';
		LET isam_err      	= 0;
		LET vsqlerr       	= 0;
		
		--SET DEBUG FILE TO "/informix/ifg/sp_status_ctas_act.out"; --Se genera log en un archivo .out
	    --TRACE ON;
		
		/*Inicializando variables de manejo de errores*/

		LET vcodret       	= '00000';
		
		BEGIN
			/*Excepciones*/
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0 THEN
					 LET vcodret = vsqlerr;
					 LET isam_err = isam_err;
					 LET error_info = error_info;
					 RETURN vcodret;
				END IF;
			END EXCEPTION;
			
						
			/*EJECUTA QUERY*/
			
			
			set lock mode to wait 3;
				set isolation to dirty read;
				update tblpago 
				set chrestatusenvio='N'
				where chrestatusenvio='E'
				and vchrclaverastreo in (SELECT referencia from  bdicheq:sc_movdia
				where current hour to fraction-fech_hor>'00:05:00.000');
			
			
			RETURN vcodret;
			
		END;
END PROCEDURE;