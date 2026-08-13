CREATE PROCEDURE "informix".sp_cambincompleta_solicitarchqra( pempresa char(3),   --Empresa             
                                   pcuenta  char(20),   -- Cuenta                                       
                                   pconsec  integer,    -- Cosecutivo de la chequera                    
                                   pusuario char(8)                                                     
								   )                                    
       returning    char(5),	-- vcodret                                                              
					char(20), 	-- direccion                                    
					integer;   	-- num. chequera                                
                                                                                                        
	-- Realizo   : Javier Humberto Calderon Zazueta                                                 
    -- Actividad : Cambiar estados a incompletos tanto a chequeras como sus cheques y                   
	--			   realizar la solicitud de una nueva chequera para la cuenta           
    -- Solicitó  : Mauricio Leon Ibarra                                                                 
    -- Fecha     : 25/03/2010   
	--	
	-- Modificó  : Berenice Noriega
	-- Fecha	 : 13/02/2013
	-- Actividad : valida si el producto es de empresa para mandar el sp  
	--			   con el parametro correspondiente.
 
	-- Modificado por: 	   Berenice Noriega
	-- Fecha:			   Diciembre - 2013
	-- Modificación:	   Validar si es producto 2700 parametro 30 en el catalogo
	-- 						si lo es manda el parametro correspondiente para la chequera.
 
                                                                                                        
   -- // Definicion de variables                                                                        
   DEFINE vcodret         char(5);                                                                      
   DEFINE vsqlerr         integer;                                                                      
   DEFINE vDireccion	  char(20);                                                                     
   DEFINE vNumChequera    integer;       
   DEFINE vproducto  	  CHAR(4); 
   DEFINE vproductoe_parm CHAR(4);	  
   DEFINE vproductoe_parm2 CHAR(4);	   
   
                                                                                                        
                                                                                                        
   LET vcodret      = '';                                                                               
   LET vsqlerr      = 0;                                                                                
   LET vDireccion   = '';                                                                               
   LET vNumChequera = 0;     
   LET vproducto   = "0000";
   LET vproductoe_parm = "0000";   
   LET vproductoe_parm2 = "0000";   


    --*********************************************
	--SET debug FILE TO "/home/informix/BereniceOut/sp_cambincompleta_solicitarchqra.out";
	--Trace ON;
	--*********************************************                                                                             
   
BEGIN                                                                                                   
    ON EXCEPTION SET vsqlerr                                                                            
       IF vsqlerr <> 0 THEN                                                                             
          LET vcodret = vsqlerr;                                                                        
          RETURN vcodret, vDireccion, vNumChequera;                                                     
       END IF;                                                                                          
    END EXCEPTION;                                                                                      

	--- Actualizacion de Status de Chequera a incompleta                                            
	UPDATE bdicntchq:sq_maechqra                                                                    
	SET status= 'I'                                                                                 
	WHERE empresa = pempresa                                                                        
	AND cuenta = pcuenta                                                                            
	AND consec = pconsec                                                                            
	AND status = 'N';                                                                               
                                                                                                                                                            
	--- Actualizacion de Status de Cheques a incompletos                                            
	UPDATE bdicheq:sc_contch                                                                        
	SET estado= 'I'                                                                                 
	WHERE empresa = pempresa                                                                        
	AND cuenta = pcuenta                                                                            
	AND consec = pconsec                                                                            
	AND estado = 'E';                                     
	                                                                                                
	SELECT desc_tipo_dir                                                                            
	INTO vDireccion                                                                                 
	FROM bdicheq:sc_maechq AS m                                                                     
	INNER JOIN bdinteg:si_cat_tipo_direcciones AS tdr ON m.direcc_envio = tdr.tipo_dir              
	WHERE empresa = pempresa AND cuenta = pcuenta;                                                  
	 
	---------------------------------------------------------------------------------------------------------
	--Se trae el producto de la cuenta
    SELECT producto
    INTO  vproducto
    FROM bdicheq:"informix".sc_maechq
    WHERE empresa = pempresa
    AND cuenta = pcuenta;
	
	--Va por el producto correspondiente a empresas
    SELECT valor INTO vproductoe_parm
     FROM sq_param
    WHERE cod_param = 25;
	
	--Va por el otro producto de empresas de cheques
	SELECT valor INTO vproductoe_parm2
     FROM sq_param
    WHERE cod_param = 30;
	
	--compara si el producto de la cuenta es un producto de empresa
	IF (vproducto = vproductoe_parm) OR  (vproducto = vproductoe_parm2) THEN
		EXECUTE PROCEDURE sp_altachequeras(pempresa, pcuenta, 3, '03', pusuario) INTO vcodret;          
																										
		IF (vcodret = '000') THEN                                                                       
			EXECUTE PROCEDURE sp_obtener_num_chequera(pempresa, pcuenta) INTO vcodret, vNumChequera;
		ELSE                                                                                            
			RETURN vcodret, vDireccion, vNumChequera;                                               
		END IF; 
	
	else 
		EXECUTE PROCEDURE sp_altachequeras(pempresa, pcuenta, 3, '01', pusuario) INTO vcodret;          
																										
		IF (vcodret = '000') THEN                                                                       
			EXECUTE PROCEDURE sp_obtener_num_chequera(pempresa, pcuenta) INTO vcodret, vNumChequera;
		ELSE                                                                                            
			RETURN vcodret, vDireccion, vNumChequera;                                               
		END IF; 
		
	END IF
	 
	---------------------------------------------------------------------------------------------------------
	                                                                                        
	                                                                                                                                                                                                
	LET vcodret = '000';                                                                            
	RETURN vcodret, vDireccion, vNumChequera;                                                       
                                                                                                        
END                                                                                                     
END PROCEDURE;