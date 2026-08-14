CREATE PROCEDURE "informix".sp_valida_foliocar_numserie_bei(pNumCte char(9), pFolio char(25), pNumSerie char(10))
		RETURNING char(5);

	DEFINE sql_err integer;
	DEFINE cCod_ret char (5);

	LET sql_err = 0;
	LET cCod_ret = '000';


--****************************************************************************************************
--RealizÃ³: Solser
--Fecha: 05/08/2011
--Actividad: Valida que el folio de la caratula y el numero de serie concuerden con el cliente

-- DESCRIPCION: Modificación para consultar el folio en la tabla
-- AUTOR : Berenice Noriega
-- FECHA : 04 de Septiembre 2013
-- BD: bdibei
-- SOLICITO : Ismael Hernandez


-- MODIFICACION: Para consultar el folio de activación en la tabla bei_servio
-- AUTOR : Berenice Noriega
-- FECHA: 01 de Octubre 2013

--***************************************************************************************************
 
	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCod_ret = sql_err;
			RETURN cCod_ret;
		END IF;
	 END EXCEPTION;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;

	 IF NOT EXISTS(SELECT numcte FROM "informix".bei_tokensolicitud WHERE numcte = pNumCte AND ns_token = pNumSerie) THEN
		RETURN '002';
	 END IF;

	 IF NOT EXISTS(SELECT ns_token FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pNumSerie) THEN
		RETURN '002';
	 END IF;

	 IF NOT EXISTS(SELECT ns_token FROM "informix".bei_servicio WHERE num_cliente=pNumCte and folio_activa = pFolio) THEN --no valida el ns_token por que en este punto aun no tienen ese dato grabado
		RETURN '001';
	 END IF;

	 RETURN cCod_ret;

	END;

END PROCEDURE;