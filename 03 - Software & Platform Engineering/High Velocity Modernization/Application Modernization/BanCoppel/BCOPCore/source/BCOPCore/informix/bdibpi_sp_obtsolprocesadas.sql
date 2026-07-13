CREATE PROCEDURE "informix".sp_obtsolprocesadas(pRegistros smallint,pEmpresa CHAR(3))
	RETURNING CHAR(5),CHAR(10),CHAR(9),CHAR(10),CHAR(10),CHAR(1),CHAR(200),CHAR(52),CHAR(52);

--------------------------------------------------------------------------------------------
-- Realizó: Francisco Rodríguez Ibarra
-- Actividad: Obtiene las solicitudes procesadas de la tabla tkn_solprocesadas
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 14/01/2011
---------------------------------------------------------------------------------------------	
	
--Definición de variables
DEFINE sql_err      INT;
DEFINE vCodRet      CHAR(5);
DEFINE vSolicitud 	CHAR(10);
DEFINE vCliente	  	CHAR(9);
DEFINE vFecha     	CHAR(10);
DEFINE vDispositivo CHAR(10);
DEFINE vEstatusSol	CHAR(1);
DEFINE vErrorDesc	CHAR(200);
DEFINE vNombres CHAR(52);
DEFINE vApellidos CHAR(52);

--Inicializar valores a variables declaradas
LET vCodRet = '00000';
LET vSolicitud = '';
LET vCliente = '';
LET vFecha =  '01-01-1900';
LET vDispositivo = '';
LET vEstatusSol	='';
LET vErrorDesc = '';
LET vNombres ='';
LET vApellidos ='';

	BEGIN

	   ON EXCEPTION SET sql_err
	      IF sql_err <> 0 THEN
	            let vCodRet = sql_err;
	            RETURN vCodRet,'','',vFecha,'','','','','';                           
	      END IF ;
	   END EXCEPTION ;

	   FOREACH
			SELECT  SKIP pRegistros FIRST 10 solicitud,cliente,fecha,dispositivo,estatus_sol,error_desc, 
				  TRIM(si.nombre1) || ' ' ||  TRIM(si.nombre2) , TRIM (si.apell_paterno) || ' ' || TRIM(si.apell_materno)
			INTO vSolicitud,vCliente,vFecha,vDispositivo,vEstatusSol,vErrorDesc,vNombres,vApellidos
			FROM bdibpi:tkn_solprocesadas  as tk,  bdinteg:si_cliente as si
			WHERE si.empresa=TRIM(pEmpresa)
			AND si.numcte=tk.cliente
	   
			RETURN vCodRet, vSolicitud,vCliente,vFecha,vDispositivo,vEstatusSol,vErrorDesc,vNombres,vApellidos WITH RESUME;
	   END FOREACH;

	  END;

END PROCEDURE;