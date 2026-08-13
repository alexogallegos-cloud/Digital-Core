CREATE PROCEDURE "informix".spvalidarfaltantesarch2 (p_dFechaAsigna DATE, p_sNombreArchivo CHAR(20))

	RETURNING CHAR(5) AS Retorno, INTEGER AS Errores;

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(5);
	DEFINE v_sNumSucursal 		CHAR(4);
	DEFINE v_sNumEmpleado 		CHAR(8);
	DEFINE v_mSaldoInicial 		MONEY(12,2);
	DEFINE v_mSaldoInicialRound	MONEY(10,0);
	DEFINE v_dFechaRegistro 	DATE;
	DEFINE v_sNumAuxiliar		CHAR(12);
	DEFINE v_sNumSucValida 		CHAR(1);
	DEFINE v_sNumEmpValido 		CHAR(1);
	DEFINE v_sSaldoIniValido 	CHAR(1);
	DEFINE v_sFechaRegValida 	CHAR(1);
	DEFINE v_sNumAuxValido 		CHAR(1);
	DEFINE v_sRegistroValido 	CHAR(2);
	DEFINE v_iErrores			INTEGER;
	
	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spvalidarfaltantesarch.out"; ";
	--TRACE ON;
	-----------------------------------------------------------------------
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno, '0';
			END IF;
		END EXCEPTION;
		 
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_dFechaAsigna,'') = ''  THEN
			LET v_sValRetorno = '00001';	
			RETURN v_sValRetorno,'0';
		END IF;
		
		LET v_sValRetorno = '00000';
		FOREACH
			SELECT numsucursal, numempleado, saldoinicial, fecharegistro 
			INTO v_sNumSucursal, v_sNumEmpleado, v_mSaldoInicial, v_dFechaRegistro FROM bdirech:rec_faltantesarch WHERE nombrearchivo = p_sNombreArchivo
				
			LET v_mSaldoInicialRound = ROUND(v_mSaldoInicial);
			LET v_sNumAuxiliar = v_sNumSucursal||v_sNumEmpleado;
			SELECT COUNT(*) INTO v_sNumSucValida FROM bdinteg:si_sucursales WHERE sucursal = v_sNumSucursal; --0 Incorrecto, 1 Correcto
			SELECT COUNT(*) INTO v_sNumEmpValido FROM bdinteg:si_ejecut WHERE ejecutivo = v_sNumEmpleado; --0 Incorrecto, 1 Correcto
			SELECT COUNT(*) INTO v_sNumAuxValido FROM bdicont:co_auxiliar WHERE numero = v_sNumAuxiliar; --0 Incorrecto, 1 Correcto
			SELECT COUNT(*) INTO v_sRegistroValido FROM bdirech:rec_faltantesarch WHERE numsucursal = v_sNumSucursal AND numempleado = v_sNumEmpleado 
			AND saldoinicial = v_mSaldoInicial AND fecharegistro = v_dFechaRegistro AND nombrearchivo = p_sNombreArchivo;
			
			IF v_sRegistroValido = 1 THEN --Si es uno solo existe un registro, el archivo esta correcto.
				SELECT COUNT(*) INTO v_sRegistroValido FROM bdirech:rec_confaltante WHERE numsucursal = v_sNumSucursal AND numempleado = v_sNumEmpleado 
				AND saldoinicial = v_mSaldoInicialRound AND fecharegistro = v_dFechaRegistro;
				IF v_sRegistroValido = 0 THEN --Si es cero el faltante es correcto debido a que no existe duplicidad en la rec_confaltante
					LET v_sRegistroValido = 1; --Se hace uno para marcarlo como correcto
				ELSE --Si no es cero el faltante esta duplicado en la rec_confaltante.
					LET v_sRegistroValido = 0; --Se hace cero para marcarlo como duplicado.
				END IF
			ELSE --Existe mas de un registro, el faltante esta duplicado en el archivo.
				LET v_sRegistroValido = 0; --Se hace cero para marcarlo como duplicado.
			END IF
			
			IF v_mSaldoInicial > 0 AND v_mSaldoInicial <= 9999999999 THEN
				LET v_sSaldoIniValido = 1; --Correcto
			ELSE
				LET v_sSaldoIniValido = 0; --Incorrecto
			END IF
			
			IF v_dFechaRegistro <= p_dFechaAsigna THEN
				LET v_sFechaRegValida = 1; --Correcto
			ELSE
				LET v_sFechaRegValida = 0; --Incorrecto
			END IF
			
			UPDATE bdirech:rec_faltantesarch SET numsucvalida = v_sNumSucValida, numempvalido = v_sNumEmpValido, saldoinivalido = v_sSaldoIniValido, 
			fecharegvalida = v_sFechaRegValida, numauxvalido = v_sNumAuxValido, registrovalido = v_sRegistroValido
			WHERE numsucursal = v_sNumSucursal AND numempleado = v_sNumEmpleado AND saldoinicial = v_mSaldoInicial AND fecharegistro = v_dFechaRegistro
			AND nombrearchivo = p_sNombreArchivo;
						
        END FOREACH
    	
		SELECT COUNT(*) INTO v_iErrores FROM bdirech:rec_faltantesarch WHERE (numsucvalida = 0 OR numempvalido = 0 OR saldoinivalido = 0 OR fecharegvalida = 0 
		OR numauxvalido = 0 OR registrovalido = 0) AND nombrearchivo = p_sNombreArchivo;
			
		RETURN v_sValRetorno, v_iErrores;
	END;    	
				
END PROCEDURE 
