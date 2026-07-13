CREATE PROCEDURE "informix".sp_nominaplantilla_bpi(
  pNumCliente VARCHAR(9),
  pNombre VARCHAR(10),
  pNombreNuevo VARCHAR(10),
  pClave INTEGER,
  pOperacion VARCHAR(1))
RETURNING CHAR (5), INTEGER;
	-- Creador: Solser
	-- Objetivo: Gestionar plantillas para DispersiÃ³n de Nomina
	-- Fecha: 13/12/2021
	
	DEFINE sql_err int;
	DEFINE vCodRet CHAR (5);
	--variables para registro en nuevas tablas
    DEFINE vCvePlantilla INTEGER; 


	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet, vCvePlantilla ;
		  END IF ;
		END EXCEPTION ;
		
		LET vCodRet = '00000';
     
        LET vCvePlantilla    = 0; 
		
		SET LOCK MODE TO WAIT 5;
        
        IF (pOperacion == '3' AND pClave <> 0 ) THEN --Eliminar
       			DELETE FROM bdicheq:sc_nominaplantillaempleados_bpi  where num_cte = pNumCliente and cve_plantilla = pClave ; 
				DELETE FROM bdicheq:sc_nominaplantilla_bpi  where num_cte = pNumCliente and cve_plantilla = pClave ; 
                let vCvePlantilla = pClave;
        ELSE
               
              
                IF (pOperacion == '2') THEN --Es EdiciÃ³n
                  		SELECT NVL(cve_plantilla,0) into vCvePlantilla from bdicheq:sc_nominaplantilla_bpi where num_cte = pNumCliente and nombre = pNombreNuevo; 
                        IF vCvePlantilla <> 0 THEN
                            DELETE FROM bdicheq:sc_nominaplantillaempleados_bpi  where num_cte = pNumCliente and cve_plantilla = vCvePlantilla ; 
                            DELETE FROM bdicheq:sc_nominaplantilla_bpi  where num_cte = pNumCliente and cve_plantilla = vCvePlantilla ; 
                        ELSE
                        	DELETE FROM bdicheq:sc_nominaplantillaempleados_bpi  where num_cte = pNumCliente and cve_plantilla = pClave ; 
                        
                        END IF;	
                        IF (LENGTH(TRIM(NVL(pNombreNuevo,''))) > 0) THEN
                      		UPDATE  bdicheq:sc_nominaplantilla_bpi SET nombre =  pNombreNuevo where num_cte = pNumCliente and cve_plantilla = pClave ;
                      	END IF;	
                        LET vCvePlantilla =  pClave;
                ELIF (pOperacion == '1')    THEN --Alta 
                  		SELECT NVL(cve_plantilla,0) into vCvePlantilla from bdicheq:sc_nominaplantilla_bpi where num_cte = pNumCliente and nombre = pNombre; 
                        IF  vCvePlantilla <> 0 THEN 
                          
                            DELETE FROM bdicheq:sc_nominaplantillaempleados_bpi  where num_cte = pNumCliente and cve_plantilla = vCvePlantilla ;
                        ELSE
                          
                            SELECT NVL(MAX(cve_plantilla), 0) +1 into vCvePlantilla from bdicheq:sc_nominaplantilla_bpi  where num_cte = pNumCliente; 
                            INSERT INTO bdicheq:sc_nominaplantilla_bpi (num_cte, cve_plantilla, nombre) VALUES 	(pNumCliente,vCvePlantilla , pNombre);	

                        END IF;	 
    

				END IF;	 
			 
        END IF;
        
             
     
         
		RETURN vCodRet, vCvePlantilla;
	END;
END PROCEDURE
DOCUMENT
'AUTOR.........: Solser',
'FECHA.........: 13-12-2021',
'MODIFICACION..: Creacion modulo Plantillas dispersion de nomina.',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDICheq';

CREATE PROCEDURE "informix".sp_nominaplantillaempleados_bpi(pNumCliente CHAR(9), pCvePlantilla INTEGER, pNumEmpleado CHAR(30), pImporte MONEY)
	returning char(5) ;

	--DeclaraciÃ³n de variables
	DEFINE vCodRet char(5);
	DEFINE sql_err INTEGER;

  


	--Inicializar variables
	LET vCodRet  = "00000";


	--****************************************************************************************************
	-- DESCRIPCION: Guardar empleados asociadops a una plantila de nomina
	-- AUTOR: Solser
	-- BD: bdicheq
	-- SOLICITO: BanCoppel
	-- Fecha: Diciembre 2021
	--***************************************************************************************************

	BEGIN
	   	ON EXCEPTION SET sql_err
	    	IF sql_err <> 0 THEN
	        	let vCodRet = sql_err;
                RETURN vCodRet;
	      	END IF ;
	   	END EXCEPTION ;


	    IF(LENGTH(TRIM(NVL(pNumCliente,''))) = 0 OR LENGTH(TRIM(NVL(pCvePlantilla,''))) = 0) THEN
	        LET vCodRet="00001";
             RETURN vCodRet;
	    END IF;
     

	   	SET LOCK MODE TO WAIT 4;
           

 	
		INSERT INTO bdicheq:sc_nominaplantillaempleados_bpi
			(num_cte, cve_plantilla, num_empleado, importe)
		VALUES 	(pNumCliente, pCvePlantilla, pNumEmpleado, pImporte);
            

	 	RETURN vCodRet;

	END
END PROCEDURE;