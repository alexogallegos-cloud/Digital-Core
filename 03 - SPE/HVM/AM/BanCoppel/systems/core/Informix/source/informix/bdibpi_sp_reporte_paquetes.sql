CREATE PROCEDURE "informix".sp_reporte_paquetes(pNumGuia DATE,pRegistros SMALLINT)
RETURNING CHAR(5),CHAR(30),CHAR(10),CHAR(9);
--**************************
--sp_reporte_paquetes
--Objetivo: Obtiene los datos de la fecha asignada,. es decir, saca un reporte de los paquetes asignadas en un fecha especificada de envio
--autor:Francisco Rodriguez Ibarra
--Fecha: 05 Enero 2010
--**************************
--DECLARACION DE VARIABLES
DEFINE vsCodRet  	 CHAR(5);
DEFINE vSqlErr 		 INTEGER;
DEFINE vNumGuia 	 CHAR(30);
DEFINE vNumSolicitud CHAR(10);
DEFINE vNumCliente 	 CHAR(9);


--Asignacion de Valores
LET vsCodRet = '00000';
LET vSqlErr = 0;
LET vNumGuia='';
LET vNumSolicitud='';
LET vNumCliente='';

	BEGIN
		ON EXCEPTION SET vSqlErr
		      IF vSqlErr <> 0 THEN
		            let vsCodRet = vSqlErr;
		            RETURN vsCodRet , vNumGuia , vNumSolicitud , vNumCliente;
		      END IF;
			END EXCEPTION;

		FOREACH
		
			SELECT SKIP pRegistros LIMIT 10 num_guia , solicitud , numcte 	
			INTO vNumGuia , vNumSolicitud , vNumCliente
			FROM tkn_envios
			WHERE DATE(f_envio)=pNumGuia
			
			RETURN vsCodRet , vNumGuia , vNumSolicitud , vNumCliente WITH RESUME;
			
		END FOREACH;
		
		IF (vNumGuia=='') THEN
			LET vsCodRet = '00100';			RETURN vsCodRet , vNumGuia , vNumSolicitud , vNumCliente;
		END IF
	
	END;
	
END PROCEDURE

	
;