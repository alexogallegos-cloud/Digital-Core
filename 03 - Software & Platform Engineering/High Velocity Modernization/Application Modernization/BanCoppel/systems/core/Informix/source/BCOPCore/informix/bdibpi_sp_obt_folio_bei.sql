CREATE PROCEDURE "informix".sp_obt_folio_bei()
	RETURNING char(5),integer;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE EL FOLIO PARA LA DISPERSION
-- AUTOR : Francisco Rodríguez Ibarra
-- FECHA : 26/08/2011
-- BD: bibpi
-- SOLICITO :Mauricio León
--***************************************************************************************************
	
--DECLARACION DE VARIABLES
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vValor INTEGER;
	
	
	--INICIALIZAR VALORES A VARIABLES;
	LET vCodRet='00000';
	LET vValor=0;

	
	Set isolation to dirty read;

	BEGIN


		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet, '';
			END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		select folio into vValor from bdibpi:"informix".bpi_parametros_contenido;
		
		RETURN vCodRet,vValor;
	END;
END PROCEDURE
;