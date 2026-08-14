CREATE PROCEDURE "informix".sp_cargar_tkn_tokenexpira_bei(pFechaExpira DATE)
RETURNING CHAR(5);
----------------------------------------------------------------------------------------------------------------------------------------------
-- Realiza: Gabrieal Aguilar
-- Actividad: Segun la fecha, identifica los usararios que tengan token que esten proximo a vencer y esten en status validos para insertalos
-- en la taba  bdibei:bei_tokenexpira para camapaÃ±a de renovacin de token.
-- Solicita: Alejandro Vazquez
-- Fecha de Solicitud: 06/06/2019
-----------------------------------------------------------------------------------------------------------------------------------------------


--Declaracion de variables

DEFINE vsCodRet CHAR(10);
DEFINE viSqlErr INTEGER;
DEFINE pid_usuario INTEGER; 
DEFINE pnum_cliente CHAR(9); 
DEFINE pns_token CHAR(9); 
DEFINE pid_status_token INTEGER; 
DEFINE pnombre CHAR(150);
DEFINE pid_tipo_usuario INTEGER;
DEFINE pid_status INTEGER;
--DEFINE pid_status_solicitud CHAR(1):
--DEFINE pid_token_vencido CHAR(1):
--DEFINE pf_registro_solicitud DATE;
--DEFINE psolicitud CHAR(10); 




	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_cargar_tkn_tokenexpira_bei.out";
	--TRACE ON;

--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET pid_usuario = 0; 
LET pnum_cliente=''; 
LET pns_token =''; 
LET pid_status_token =0; 
LET pnombre ='';
LET pid_tipo_usuario =0;
LET pid_status =0;
--LET pid_status_solicitud CHAR(1):
--LET pid_token_vencido CHAR(1):
--LET pf_registro_solicitud DATE;
--LET psolicitud CHAR(10); 


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
				TRUNCATE TABLE "informix".bei_tokenexpira;
				
				FOREACH			
				SELECT b.id_usuario, b.num_cliente, b.ns_token,b.id_status_token, d.nombre, e.id_tipo_usuario, e.id_status
				into pid_usuario, pnum_cliente, pns_token,pid_status_token, pnombre, pid_tipo_usuario, pid_status
				from bdibei:bei_token  b 
				INNER JOIN bdibpi:tkn_nseries   c ON b.ns_token =c.ns_token 
				inner join bdibei:bei_datos_usuario d on b.id_usuario=d.id_usuario
				inner join bdibei:bei_usuario e on b.id_usuario=e.id_usuario
				AND e.id_status NOT IN ('10','20','25','80')
				AND f_caducidad = pFechaExpira
				AND b.id_status_token in ('100','110','120','130','140','150','151','152')
				
				INSERT INTO bei_tokenexpira
				values(pnum_cliente,pid_usuario,pid_tipo_usuario,pns_token,pnombre, pid_status_token,  pid_status, '0', '0', NULL, ' ');
				END FOREACH
			
		ELSE
			LET vsCodRet = '-2';
        END IF;
		
	END IF;
		
	RETURN vsCodRet;
END
END PROCEDURE;