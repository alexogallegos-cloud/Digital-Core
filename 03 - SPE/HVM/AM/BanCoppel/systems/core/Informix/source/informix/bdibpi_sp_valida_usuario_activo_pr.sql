CREATE PROCEDURE "informix".sp_valida_usuario_activo_pr(pImei CHAR(17), pMac CHAR(17))
											  
-- DESCRIPCIÓN 	: Obtiene el id_usuario y el número de celular para el sistema PagoRayo.
-- AUTOR		: EDGAR MANUEL ALARCON GONZALEZ
-- FECHA 		: 03/05/2017
-- BD    		: BDIBPI

-- Retornos
	RETURNING
		CHAR(5) AS codRetorno,
		INTEGER AS idUsuario,
		CHAR(10) AS numCel;

	-- Declarar variables 
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INTEGER;
	
	DEFINE cIdUsuario			INTEGER;
	DEFINE cNumCelular			CHAR(10);
	
	-- Asignación
	LET cCodRet = "00000";
	LET iSql_err = 0;
	LET cIdUsuario = 0;
	LET cNumCelular = '';
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				let cCodRet = iSql_err;
				RETURN cCodRet, cIdUsuario, cNumCelular;
			END IF;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/respaldosbd/Keevyn/sp_valida_usuario_activo_pr.out";
		--TRACE ON;
	
		SELECT id_usuario, celular INTO cIdUsuario, cNumCelular
		FROM bdibpi:"informix".pr_registro_app WHERE imei = pImei AND mac = pMac and estatus_servicio = 'A';
		
		
		IF cIdUsuario == 0 OR NVL(cIdUsuario,'') == '' OR NVL(TRIM(cNumCelular),'') == '' THEN
			LET cIdUsuario = 0;
			LET cNumCelular = '';
			LET cCodRet = '00001'; -- NO SE ENCONTRO REGISTRO CORRECTO
		END IF;
		
		RETURN cCodRet, cIdUsuario, cNumCelular;
		
	END;
	
END PROCEDURE;