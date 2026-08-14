CREATE PROCEDURE "informix".sp_consulta_param_bei(pParam char(4))
	RETURNING char(5), char (50), char(100);

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE EL PARAMETRO QUE SE INDIQUE
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio León
	--***************************************************************************************************

	--DECLARACION DE VARIABLES
	DEFINE vCodRet CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vValor CHAR(50);
	DEFINE vDescripcion VARCHAR(100);
	
	--INICIALIZAR VALORES A VARIABLES;
	LET vCodRet='00000';
	LET vValor='';
	LET vDescripcion='';
	

	BEGIN


		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet, '','';
			END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

		IF(pParam IS NOT NULL OR pParam<>'') THEN
			SELECT valor,descripcion INTO vValor , vDescripcion  FROM bdibpi:"informix".enet_parametros WHERE id_param=pParam;
			IF(vValor IS NULL OR vValor='')THEN 
				LET vCodRet = '00002';
			END IF;
		ELSE
			LET vCodRet = '00001';
		END IF;
		
		RETURN vCodRet,vValor,vDescripcion;
	END;
END PROCEDURE;