CREATE PROCEDURE  "informix".sp_cancelaserviciobasico_bpi()
  RETURNING    CHAR(5);
	
	
------------------------------------
--Cancela el servicio de Banca por Internet para el proceso de cambio de servicio y guarda registros en la si_cambiostct los cambios de status
--Elaboro : Gabriela Aguilar
--FECHA : 13/Julio/2020
--Ver.  : 1.0
--BD    : bdinteg
------------------------------------
 	
  	
    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE cod_ret char(5);
	DEFINE pnumcte      CHAR(10);
	DEFINE pid_status  SMALLINT;
	DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
DEFINE vcuantos1 INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;  
	LET pnumcte = '';
	LET pid_status = 0;
	LET cod_ret = "00000";
LET vcontador = -1;
LET vcuantos = 0;
LET vcomienza   = -1;	
LET vregistros = 1000;
 
 --SET DEBUG FILE TO "/informix/gaby/sp_cancelaserviciobasico_bpi.out";
  --TRACE ON;


	Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

BEGIN

    

    	
	FOREACH WITH HOLD	
			
			Select numcte, id_status
			into pnumcte, pid_status
			from bdinteg:si_bpiusuarios  where  id_status not in ('30','99') and servicio='1'
			
		
			IF vcomienza = -1 THEN
				BEGIN WORK;
				LET vcontador = 1;
				LET vcomienza = 0;
			END IF;
		

       
				UPDATE 
				bdinteg:si_bpiusuarios 
				SET id_status = '99', servicio='2', f_status = current 
				WHERE numcte = pnumcte and id_status=pid_status ;
			

        
			IF (vcontador = vregistros) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;
			ELSE
				LET vcontador = vcontador + 1 ;						
			END IF;	

        CONTINUE FOREACH;			

				
	END FOREACH;

		
		IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
			END IF;		
	
   

    RETURN cod_ret;

END
END PROCEDURE;