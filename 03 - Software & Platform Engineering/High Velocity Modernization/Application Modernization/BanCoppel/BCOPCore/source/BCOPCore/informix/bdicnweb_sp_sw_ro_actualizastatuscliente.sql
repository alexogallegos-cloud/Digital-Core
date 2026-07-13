CREATE PROCEDURE "informix".sp_sw_ro_actualizastatuscliente(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, 
												pIdBusqueda INT, 
												pIdCliente INT, 
												pIndicadores CHAR(4), 
												pIp CHAR(15), 
												pMac CHAR(12))
	RETURNING CHAR(5) AS codret,
			SMALLINT AS registros_afectados
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iRegsAfectados SMALLINT;
	DEFINE cIndRfc CHAR(1);
	DEFINE cIndEmpleo CHAR(1);
	DEFINE cIndDomicilio CHAR(1);
	DEFINE cIndNacionalidad CHAR(1);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegsAfectados = 0;
	LET cIndRfc = '';
	LET cIndEmpleo = '';
	LET cIndDomicilio = '';
	LET cIndNacionalidad = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iRegsAfectados;
			END IF;
		END EXCEPTION;
		IF pUsuario = ''OR 
			pIdFunciON = ''OR 
			pIdOficio = ''OR 
			pIdBusqueda = ''OR 
			pIdCliente = ''OR 
			pIndicadores = ''OR 
			pIp = ''OR 
			pMac = '' THEN -- VALIDO QUE TODOS LOS PARAMETROS VENGAN
				LET cCodRet = '00003';
				RETURN cCodRet, iRegsAfectados;
		END IF;
		IF LENGTH(pIndicadores) < 4 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegsAfectados;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegsAfectados;
		END IF;
		LET cIndRfc = SUBSTRING(pIndicadores FROM 1 for 1);
		LET cIndEmpleo = SUBSTRING(pIndicadores FROM 2 for 1);
		LET cIndDomicilio = SUBSTRING(pIndicadores FROM 3 for 1);
		LET cIndNacionalidad = SUBSTRING(pIndicadores FROM 4 for 1);
		UPDATE sw_ro_resulcte
		SET ind_rfc = cIndRfc,
			Ind_empleo = cIndEmpleo,
			ind_domicilio = cIndDomicilio,
			ind_nacionalidad = cIndNacionalidad,
			ind_terminado = '1'
		WHERE id_oficio = pIdOficio 
			AND id_busqueda = pIdBusqueda 
			AND id_resulcte = pIdCliente;
		LET iRegsAfectados = dbinfo('sqlca.sqlerrd2');
		IF iRegsAfectados = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, iRegsAfectados;
		END IF;
		RETURN cCodRet, iRegsAfectados;
	END
END PROCEDURE;