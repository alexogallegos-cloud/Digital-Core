CREATE PROCEDURE "informix".sp_consulta_comision_cargo_bei(pNumero char(4))

returning CHAR(5),money(16,2);

 	--****************************************************************************************************
	-- DESCRIPCION:  Obtiene la comision de cargo para dispersion en linea
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--****************************************************************************************************
 

	--Definicion de variables	
	DEFINE sql_err INTEGER;
	DEFINE vCodRet char(5);
	DEFINE vValor money(16,2);
	DEFINE vNumero CHAR(4);
	
	--Asignacion de valores a variables
	LET vCodRet='00000';
	BEGIN	
	
		ON EXCEPTION SET sql_err
	      IF sql_err <> 0 THEN
	         let vCodRet = sql_err;
	         RETURN vCodRet,vValor;
	      END IF;
	    END EXCEPTION;	
		
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		select numero,monto_fijo into vNumero,vValor from bdinteg:"informix".si_transacc where numero=pNumero;
		
		IF(vNumero is null or vNumero='') THEN
			LET vCodRet='00001';
		END IF;
		
		
		RETURN vCodRet,vValor;
	END;
END PROCEDURE
;