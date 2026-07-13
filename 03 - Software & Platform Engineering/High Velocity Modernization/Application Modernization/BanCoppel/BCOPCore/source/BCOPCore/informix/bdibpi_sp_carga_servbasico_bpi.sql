CREATE PROCEDURE "informix".sp_carga_servbasico_bpi(aid_status char(2), vfecha_msj1 DATE ,  vfecha_msj2 DATE,  vfecha_msj3 DATE, vfecha_msj4 DATE)
RETURNING CHAR(5);
----------------------------------------------------------------------------------------------------------------------------------------
-- Realiza: Gabriela Aguilar Mendoza
-- Actividad: Busca los usuarios con servicio basico y los pasa la tabla de control bpi_serviciobasico
-- el cliente no se encuentre en status 80,99
-- Para los estatus del cliente  ... se cancela el servicio.
-- Solicita: Alejandro Vazquez
-- Fecha de Solicitud: 08/04/2020
----------------------------------------------------------------------------------------------------------------------------------------


--Declaracion de variables
DEFINE vsCodRet CHAR(10);
DEFINE viSqlErr INTEGER;
DEFINE pnumcte CHAR(9); 
DEFINE pid_status SMALLINT;
DEFINE pid_control  SMALLINT;
DEFINE pf_Actualiza  DATE;
DEFINE pid_Entendimiento SMALLINT;
DEFINE pf_entendimiento  DATE;
DEFINE vfecha_hoy  DATE;
DEFINE pf_ultimo_acceso DATE;
DEFINE pmescontrolmsj DATE;
DEFINE paniocontrolmsj DATE;
DEFINE pmesultimo_acceso DATE;
DEFINE panioultimo_acceso DATE;
DEFINE pfolio_contrato  CHAR(20);
DEFINE cNstoken CHAR(9);
DEFINE vnstoken CHAR(9);
DEFINE pEmpresa CHAR(3) ;
DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
DEFINE vcuantos1 INTEGER;


--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET pnumcte =''; 
LET pid_status =0;
LET pid_control = 0;
LET pf_Actualiza ='';
LET pid_Entendimiento= 0; 
LET pf_entendimiento='';
LET vfecha_hoy = '';
LET pmescontrolmsj ='';
LET paniocontrolmsj ='';
LET pmesultimo_acceso ='';
LET panioultimo_acceso ='';
LET pf_ultimo_acceso='';
LET pEmpresa='001';
LET vcontador = -1;
LET vcuantos = 0;
LET vcomienza   = -1;	
LET vregistros = 1000;

--Inicio del procedimiento


 --SET DEBUG FILE TO "/informix/gaby/bpi_Bd/bpi/spl/sp_carga_servbasico_bpi.out";
  --TRACE ON;


	Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
	
        IF viSqlErr <> 0 THEN
            LET vsCodRet = viSqlErr;
          	
            RETURN vsCodRet;
			
        END IF;
		
    END EXCEPTION;
	
    IF vsCodRet = '00000' THEN
	
				
			--obtener la fecha de  hoy
         SELECT  {+INDEX(bdicheq:"informix".sc_fechas idx_fechas1)} fecha_hoy
          INTO  vfecha_hoy
          FROM BDICHEQ:sc_fechas
       	 WHERE empresa = pEmpresa;
		 
		   LET pmescontrolmsj = MONTH(vfecha_hoy);
		   LET paniocontrolmsj = YEAR(vfecha_hoy);  
	
           
			
	 
		FOREACH WITH HOLD	
			
			Select 
			numcte, id_status, f_ultimo_acceso, folio_contrato
			into pnumcte,pid_status, pf_ultimo_acceso, pfolio_contrato
			from bdinteg:si_bpiusuarios  where  id_status=aid_status and servicio='1'
			
			LET pmesultimo_acceso = MONTH(pf_ultimo_acceso);
		    LET panioultimo_acceso = YEAR(pf_ultimo_acceso); 
			
			SELECT COUNT (*) INTO cNstoken 	FROM bdinteg:"informix".si_bpitoken;					
					LET vnstoken = 'TEMP0' ||  TRIM(SUBSTRING(cNstoken+1 FROM 3 FOR 6));
				
				 
				 
			IF vcomienza = -1 THEN
				BEGIN WORK;
				LET vcontador = 1;
				LET vcomienza = 0;
			END IF;	

						
				INSERT INTO bdinteg:"informix".si_bpitoken(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro,tipo_token)
				 VALUES(pEmpresa, pnumcte, vnstoken, '5003', pfolio_contrato, '140', CURRENT, CURRENT,'2');	
														 
			 
			IF (vcontador = vregistros) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;
			ELSE
				LET vcontador = vcontador + 1 ;						
			END IF;			
						
						
						
						
			IF (pf_ultimo_acceso is not NULL) then
			
					 
				IF vcomienza = -1 THEN
					BEGIN WORK;
					LET vcontador = 1;
					LET vcomienza = 0;
				END IF;	
		
						
				--Mismo mes	
				if(pmesultimo_acceso==pmescontrolmsj) and  (panioultimo_acceso==paniocontrolmsj) then
					INSERT INTO informix.bpi_serviciobasico(numcte, id_status, f_ultimo_acceso, id_control, id_entendimiento, f_entendimiento, f_controlmsj) 
					VALUES(pnumcte, pid_status, pf_ultimo_acceso, 1, 0, '', vfecha_msj1);
			

				--Mismo aÃ±o
				elif (pmesultimo_acceso<pmescontrolmsj) and  (panioultimo_acceso==paniocontrolmsj)  then
					INSERT INTO informix.bpi_serviciobasico(numcte, id_status, f_ultimo_acceso, id_control, id_entendimiento, f_entendimiento, f_controlmsj) 
					VALUES(pnumcte, pid_status, pf_ultimo_acceso, 1, 0, '', vfecha_msj2);
				
				--AÃ±os anteriores
				elif (panioultimo_acceso<paniocontrolmsj)  then
					INSERT INTO informix.bpi_serviciobasico(numcte, id_status, f_ultimo_acceso, id_control, id_entendimiento, f_entendimiento, f_controlmsj) 
					VALUES(pnumcte, pid_status, pf_ultimo_acceso, 1, 0, '', vfecha_msj3);
				end if;
				
			else
				INSERT INTO informix.bpi_serviciobasico(numcte, id_status, f_ultimo_acceso, id_control, id_entendimiento, f_entendimiento, f_controlmsj) 
				VALUES(pnumcte, pid_status, pf_ultimo_acceso, 1, 0, '', vfecha_msj4);
			
			end if;
			
						 
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
		
	 END IF;
		
	RETURN vsCodRet;
END
END PROCEDURE;