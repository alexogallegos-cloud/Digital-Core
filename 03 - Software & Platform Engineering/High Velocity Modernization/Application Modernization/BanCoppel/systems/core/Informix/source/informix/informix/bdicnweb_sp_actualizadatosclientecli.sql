CREATE PROCEDURE "informix".sp_actualizadatosclientecli(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNombre1 CHAR(26), pNombre2 CHAR(26), pApPaterno CHAR(26), pApMaterno CHAR(26), pRfc CHAR(13), pRfcAlterno CHAR(13), pTipoCliente INTEGER, pFecNacimiento DATE, 
                                                        pNombre1Ant CHAR(26), pNombre2Ant CHAR(26), pApPaternoAnt CHAR(26), pApMaternoAnt CHAR(26), pRfcAnt CHAR(13), pTipoClienteAnt INTEGER, pFecNacimientoAnt DATE)
	RETURNING CHAR(5) AS codret, SMALLINT AS etapa;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegsAfectados INTEGER;
	DEFINE iMaxSecuencia INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iEtapa SMALLINT;
	DEFINE iInTrans SMALLINT;
	DEFINE cAnioMesInicio CHAR(6);
	DEFINE cAnioMesActual CHAR(6);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cTipoPersona CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegsAfectados = 0;
	LET iMaxSecuencia = 0;
	LET cEmpresa = '001';
	LET iEtapa = 0;
	LET iInTrans = 0;
	LET cAnioMesInicio = '';
	LET cAnioMesActual = '';
	LET cCodRetSp = '';
	LET cTipoPersona = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			ROLLBACK;
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iEtapa;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET iInTrans = 1;
			COMMIT;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizadatosclientecli.out';
		--TRACE ON;
		
		IF pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iEtapa;
		END IF;
		
		-- Validación del tipo de persona
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT tpo_persona
		INTO cTipoPersona
		FROM bdinteg:si_cliente
		WHERE numcte = pNumCliente;
		
		IF cTipoPersona = '' THEN
			LET cCodRet = '00020';
			RETURN cCodRet, iEtapa;
		ELIF cTipoPersona = '02' THEN
			LET cCodRet = '00020';
			RETURN cCodRet, iEtapa;
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombre1 = '' OR pApPaterno = '' OR pRfc = '' OR pTipoCliente = '' OR pFecNacimiento = ''
			OR pNombre1Ant = '' OR pApPaternoAnt = '' OR pRfcAnt = '' OR pTipoClienteAnt = '' OR pFecNacimientoAnt = '' THEN
			
			LET cCodRet = '00003';
			RETURN cCodRet, iEtapa;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iEtapa;
		END IF;
		
		BEGIN WORK;
			LET iEtapa = 1;
			UPDATE bdinteg:si_cliente
			SET nombre1 = pNombre1,
				nombre2 = pNombre2,
				apell_paterno = pApPaterno,
				apell_materno = pApMaterno,
				rfc = pRfc,
				rfc_alterno = pRfcAlterno,
				numeric2 = pTipoCliente
			WHERE numcte = pNumCliente;
			
			LET iEtapa = 2;
			UPDATE bdinteg:si_ctepf
			SET fecha_nac = pFecNacimiento
			WHERE numcte = pNumCliente;
			
			LET iEtapa = 3;
			SELECT NVL(MAX(secuencia), 0) + 1
			INTO iMaxSecuencia
			FROM bdinteg:si_cte_bitacora
			WHERE numcte = pNumCliente;
			
			LET iEtapa = 4;
			INSERT INTO bdinteg:si_cte_bitacora(empresa, numcte, secuencia, apell_paterno_orig, apell_materno_orig, nombre1_orig, nombre2_orig, rfc_orig, fecha_nac_orig, numeric2_orig, 
							apell_paterno_nvo, apell_materno_nvo, nombre1_nvo, nombre2_nvo, rfc_nvo, fecha_nac_nvo, numeric2_nvo, user_insert, fecha_insert)
			VALUES(cEmpresa, pNumCliente, iMaxSecuencia, pApPaternoAnt, pApMaternoAnt, pNombre1Ant, pNombre2Ant, pRfcAnt, pFecNacimientoAnt, pTipoClienteAnt,
							pApPaterno, pApMaterno, pNombre1, pNombre2, pRfc, pFecNacimiento, pTipoCliente, pUsuario, CURRENT);

            --Actualizando la fecha de la bdinteg:si_cliente
            update bdinteg:si_cliente set fecha_alta=current where empresa='001' and numcte=pNumCliente;

		COMMIT;
		
		SELECT YEAR(CURRENT)||'01', YEAR(CURRENT)||TO_CHAR(MONTH(CURRENT), '&#')
		INTO cAnioMesInicio, cAnioMesActual
		FROM systables WHERE tabid = 1;
		
		-- Consulta de los datos LIDE
		EXECUTE PROCEDURE bdilide:sp_consultarecaudacioneslide(pNumCliente, pRfcAnt, cAnioMesInicio, cAnioMesActual) INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER = 1 THEN
			-- Actualización del RFC en lide
			EXECUTE PROCEDURE bdilide:sp_actualizarfclide(pNumCliente, pRfcAnt, pRfc, cAnioMesInicio, cAnioMesActual) INTO cCodRetSp;
		END IF;
		
		IF iInTrans = 1 THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iEtapa;

	END;
	
END PROCEDURE;