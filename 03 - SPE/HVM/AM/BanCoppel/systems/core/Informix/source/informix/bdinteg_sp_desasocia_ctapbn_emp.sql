CREATE PROCEDURE "informix".sp_desasocia_ctapbn_emp( pEmpresa CHAR(3), prfc CHAR(15), pnumcte CHAR(10), pnumcta CHAR(30) )
RETURNING CHAR(6), CHAR(60), CHAR(1);

	/*Definicion de variables del proceso y manejo de errores*/
		DEFINE error_info 		CHAR(60);
		DEFINE vcodret    		CHAR(6);
		DEFINE vsqlerr    		INTEGER;
		DEFINE isam_err   		SMALLINT;
		DEFINE vstscta			CHAR(1);
		DEFINE vbcta			INT;
		--SET DEBUG FILE TO "/informix/ifg/sp_desasocia_ctapbn_emp.out";
		--TRACE ON;

		LET vcodret       	= '00000';
		LET error_info    	= 'Iniciando ejecucion';
		LET isam_err      	= 0;
		LET vsqlerr       	= 0;
		LET vstscta			= '';
		LET vbcta			= 0;




		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		/*Incia SP*/
		BEGIN
			--//Excepciones
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0 THEN
					 LET vcodret = vsqlerr;
					 LET isam_err = isam_err;
					 LET error_info = error_info;
					 RETURN vcodret, error_info, vstscta;
				END IF;
			END EXCEPTION;
			
			--// Valida la informacion de entrada
		   IF pEmpresa       = "" OR
			  prfc      = "" OR
			  pnumcte      = "" OR
			  pnumcta       = "" THEN
						  LET vcodret = "00001";
						  LET error_info = 'ERROR PARAMETROS VACIOS'; 
						
			ELSE
						  SELECT COUNT(*) INTO vbcta FROM bdinteg:si_ctepf WHERE numcte =  pnumcte;
						  SELECT status_cta INTO vstscta FROM bdicheq:sc_maechq WHERE num_cte =  pnumcte AND cuenta = pnumcta;
						  IF (vbcta != 0) AND (vstscta = 1) THEN	
								UPDATE bdinteg:si_ctepf SET numeric1 = '', 
															numeric2 = '' 
											WHERE numcte =  pnumcte;
											
								UPDATE bdinteg:si_altamasivaempnet_det SET cod_empresa = '' 															
											WHERE cod_empresa =  pEmpresa
											  AND numcte = pnumcte
											  AND cuenta = pnumcta;				
												
								LET vcodret = '00000';
								LET error_info = 'PROCESO EJECUTADO EXITOSAMENTE';
						  ELSE 
								
								LET vcodret = "00002";
								LET error_info = 'NO SE ENCONTRARON DATOS';
						  END IF;
		   END IF;
	 RETURN vcodret,error_info,vstscta;
	    
    END;
    
END PROCEDURE;