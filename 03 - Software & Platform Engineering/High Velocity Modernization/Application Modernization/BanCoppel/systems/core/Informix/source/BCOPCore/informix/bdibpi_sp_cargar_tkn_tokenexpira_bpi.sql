CREATE PROCEDURE "informix".sp_cargar_tkn_tokenexpira_bpi(pFechaExpira DATE)
RETURNING CHAR(5);
----------------------------------------------------------------------------------------------------------------------------------------
-- RealizÃ³: Rene Aldana 
-- Actividad: Valida la fecha de expiracion que se ingresa como parametro los token que esten proximo a vencer y esten en status
-- 130,140,150,151,152 los inserta en la taba tkn_tokenexpira para que el cliente realice su renovaciÃ³n automatica.
-- SolicitÃ³: Alejandro Vazquez
-- Fecha de Solicitud: 02/06/2014
------------------**********************----
-- RealizÃ³: Rene Aldana 
-- Actividad: Valida que el cliente no se encuentre en status 10,20,25,80
-- SolicitÃ³: Alejandro Vazquez
-- Fecha de Solicitud: 01/23/2017
------------------**********************----
-- RealizÃ³: Gabriela aguilar
-- Actividad: Se quita la validacion encuentre en status 10,20,25,80, para que cancele todas las solicitudes de token fisico
-- SolicitÃ³: Alejandro Vazquez
-- Fecha de Solicitud: 07/05/2019
----------------------------------------------------------------------------------------------------------------------------------------


--Declaracion de variables
DEFINE vsCodRet CHAR(10);
DEFINE viSqlErr INTEGER;
DEFINE vTransaccion INTEGER;
DEFINE pMontoSinIva MONEY(12,2);
DEFINE pnumcte CHAR(9); 
DEFINE pns_token CHAR(9);
DEFINE pid_status_token SMALLINT;
DEFINE pid_status_servicio SMALLINT;
DEFINE pid_status_solicitud BOOLEAN; 
DEFINE pf_registro_solicitud date;



--  SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cargar_tkn_tokenexpira_bpi.out";
  --TRACE ON;

--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vTransaccion = 0;
LET pMontoSinIva = 0.00;
LET pnumcte =''; 
LET pns_token ='';
LET pid_status_token = 0;
LET pid_status_servicio =0;
LET pid_status_solicitud= 'f'; 

--Inicio del procedimiento

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
     
        IF pFechaExpira is not null THEN        ---Valida que la fecha de caducidad este informada
					-- Pasar los token de la campaÃ±a anterior a la tabla historica. 
			FOREACH	 Select  numcte, ns_token,id_status_token,id_status_servicio,id_status_solicitud,f_registro_solicitud  
			into pnumcte,pns_token,pid_status_token,pid_status_servicio, pid_status_solicitud,pf_registro_solicitud  
			from bdibpi:tkn_tokenexpira
						
			INSERT INTO bdibpi:tkn_tokenexpira_his
			values(pnumcte,pns_token,pid_status_token,pid_status_servicio, pid_status_solicitud,pf_registro_solicitud, current);
			 
			 END FOREACH
			 
			
			TRUNCATE TABLE "informix".tkn_tokenexpira;

			FOREACH			
			SELECT  b.num_cliente,b.ns_token,b.id_status_token,a.id_status
			into pnumcte,pns_token,pid_status_token,pid_status_servicio  
			FROM bdinteg:si_bpiusuarios a 
			INNER JOIN bdinteg:si_bpitoken  b ON a.numcte = b.num_cliente
			INNER JOIN bdibpi:tkn_nseries   c ON b.ns_token =c.ns_token 
			--AND a.id_status NOT IN ('10','20','25','80')
			AND f_caducidad = pFechaExpira
			AND b.id_status_token in ('100','110','120','130','140','150','151','152')
			
			INSERT INTO bdibpi:tkn_tokenexpira
			values(pnumcte,pns_token,pid_status_token,pid_status_servicio, 'F', current);
			END FOREACH
			
		ELSE
			LET vsCodRet = '-2';
        END IF;
		
	END IF;
		
	RETURN vsCodRet;
END
END PROCEDURE;