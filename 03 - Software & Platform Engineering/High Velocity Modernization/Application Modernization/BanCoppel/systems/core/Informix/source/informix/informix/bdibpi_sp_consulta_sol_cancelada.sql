CREATE PROCEDURE "informix".sp_consulta_sol_cancelada(pRegistros SMALLINT)
	RETURNING CHAR(5),CHAR(10),CHAR(9),CHAR(9),SMALLINT;
	
	--Realizo: Francisco Rodríguez Ibarrra
	--Solicito: Mauricio Leon
	--Actividad: Consulta las solicitudes con estatus 199 y tipo diferente de 5.
	-- Fecha: 24-08-2011
	-- Se modifica para que solo busque las solicitudes canceladas, con tipo distintos de 5 y que el token sea distinto de vacío o null
	-- Bibiana Gaxiola Verdugo
	-- 23/06/2015
	--
	--Se agrega validación para token digital, retorna el tipo de solicitud
	--Gabriela Aguilar
	--06/12/2018
	
	
	
	
	--DEFINICION DE VARIABLES
	DEFINE vCodRet 		CHAR(5);
	DEFINE sql_err 		INTEGER;
	DEFINE vSolicitud 	CHAR(10);
	DEFINE vNumCte 		CHAR(9);
	DEFINE vNsToken 	CHAR(9);
	DEFINE vtipo		SMALLINT;
	DEFINE iCont		INTEGER;
	
	--Asignacion de valores a variables
	LET vCodRet='00000';
	LET vSolicitud='';
	LET vNumCte='';
	LET vNsToken='';
	LET vtipo=0;
	LET iCont=0;

	
	
	--set debug file to "/informix/gaby/ArchivosOut/sp_consulta_sol_cancelada.out";
	--trace on;
    
	
	BEGIN


		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet,'','','','';
			END IF ;
		END EXCEPTION ;
	   
		SET LOCK MODE TO WAIT 10;
		Set isolation to dirty read;
		
		FOREACH
			SELECT SKIP pRegistros FIRST 10 s.solicitud,s.numcte,s.ns_token, s.tipo INTO vSolicitud,vNumCte,vNsToken, vtipo
			FROM bdibpi:"informix".bpi_tokensolicitud AS s 
			WHERE s.id_status = 199 AND s.tipo <> 5
			AND s.ns_token <> '' and s.ns_token is not null
			
			LET iCont=1;
			
			RETURN vCodRet,vSolicitud,vNumCte,vNsToken,vtipo WITH RESUME;
		END FOREACH;
		
		IF(iCont = 0 AND pRegistros=0) THEN
			LET vCodRet='00001';			RETURN vCodRet,'','','','';
		END IF;
	END
END PROCEDURE;