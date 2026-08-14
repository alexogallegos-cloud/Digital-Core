CREATE PROCEDURE "informix".sp_validaintegridadccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchOrigen CHAR(3), pIntegridad CHAR(1), 
	pConsecutivo INTEGER, pNumTarjeta CHAR(16), pTipoTransaccion325 CHAR(15), pMonto325 CHAR(13), pIdComercio325 CHAR(9), 
	pNomComercio325 CHAR(30), pReferencia23_325 CHAR(23), pSecuencia325 CHAR(6), pDivisa325 CHAR(3), pRfc325 CHAR(16))
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cIntegridad CHAR(1);
		DEFINE cErrorActividad CHAR(250);
		DEFINE cIntegridadError CHAR(20);
		DEFINE cSistema CHAR(1);
		DEFINE cMontoCB325 CHAR(13);
		DEFINE cEsNoNumTarjeta CHAR(1);
		DEFINE cEsNoIdComercio325 CHAR(1);
		DEFINE cEsNoSecuencia325 CHAR(1);
		DEFINE cEsNoDivisa325 CHAR(1);
		DEFINE cEsNoMonto325 CHAR(1);
		DEFINE cEsNoRef23_325 CHAR(1);
		DEFINE cEsNoMontoCB325 CHAR(1);
		DEFINE cMonto325 MONEY (18,2);
		DEFINE cMontoCashBack325 MONEY (18,2);
		DEFINE cBine CHAR(6);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cIntegridad = '';
		LET cErrorActividad = ''; 	
		LET cIntegridadError = '';
		LET cSistema = '';
		LET cMontoCB325 = '';
		LET cEsNoNumTarjeta = '';
		LET cEsNoIdComercio325 = '';
		LET cEsNoSecuencia325 = '';
		LET cEsNoDivisa325 = '';
		LET cEsNoMonto325 = '';
		LET cEsNoRef23_325 = '';
		LET cEsNoMontoCB325 = '';
		LET cMonto325 = 0.00;
		LET cMontoCashBack325 = 0.00;
		LET cBine = '';
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_validaintegridadccl.out';
            --TRACE ON;
            
			-- VALIDACION DE PARAMETROS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pArchOrigen = '' OR pNumTarjeta = '' OR pMonto325 = '' OR pNomComercio325 = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;

			-- LECTURA DEL CAMPO SISTEMA
			SELECT FIRST 1 sistema INTO cSistema
			FROM bditarjeta:"informix".td_archivo_origen
			WHERE archivo_origen = pArchOrigen;

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;

			-- RECUPERA EL VALOR DEL MONTO CASHBACK DEL REGISTRO EN CUESTION
			SELECT montocashback325 INTO cMontoCB325 
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE archivo_origen = pArchOrigen AND consecutivo = pConsecutivo;
			
			IF ((pArchOrigen = 'MCD') OR (pArchOrigen = 'MCC')) THEN	
	   
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;					
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pIdComercio325) INTO cEsNoIdComercio325;
				IF cEsNoIdComercio325 = 'F' THEN
					LET cCodRet = '00598'; --LA CLAVE DE COMERCIO DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pSecuencia325) INTO cEsNoSecuencia325 ;
				IF cEsNoSecuencia325 = 'F' THEN
					LET cCodRet = '00599'; --NÃMERO DE SECUENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
					IF LENGTH(pSecuencia325) != 6 THEN
						LET cCodRet = '00600'; --EL NÃMERO DE SECUENCIA DEBE SER DE 6 POSICIONES, VERIFIQUE
						RETURN cCodRet;
				ELSE
					IF pSecuencia325 = '000000' THEN
						LET cCodRet = '00728'; --NÃMERO DE SECUENCIA DEBE SER DIFERENTE DE 000000, VERIFIQUE
						RETURN cCodRet;
					END IF;
					END IF;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pDivisa325) INTO cEsNoDivisa325 ;
				IF cEsNoDivisa325 = 'F' THEN
					LET cCodRet = '00601'; --NÃMERO DE DIVISA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE

					IF LENGTH(TRIM(pDivisa325)) != 3 THEN
						LET cCodRet = '00602'; --EL NÃMERO DE DIVISA DEBE SER DE 3 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pDivisa325 = '000' THEN
							LET cCodRet = '00603'; --EL NÃMERO DE DIVISA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;

				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;

				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'MCD') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF ((pArchOrigen = 'MCC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;

				IF ((pTipoTransaccion325 NOT IN ('01','02','05','06','07','21')) AND (NOT((pArchOrigen = 'VID') AND (pTipoTransaccion325 = '20')))) THEN -- VIC CON PSTIPOTRANSACCION325 = 20 ES PARA MONEYGRAM
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;
				
			ELIF ((pArchOrigen = 'VID') OR (pArchOrigen = 'VIC')) THEN  

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pIdComercio325) INTO cEsNoIdComercio325;
				IF cEsNoIdComercio325 = 'F' THEN
					LET cCodRet = '00598'; --LA CLAVE DE COMERCIO DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pSecuencia325) INTO cEsNoSecuencia325 ;
				IF cEsNoSecuencia325 = 'F' THEN
					LET cCodRet = '00599'; --NÃMERO DE SECUENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
					IF LENGTH(pSecuencia325) != 6 THEN
						LET cCodRet = '00600'; --EL NÃMERO DE SECUENCIA DEBE SER DE 6 POSICIONES, VERIFIQUE
						RETURN cCodRet;
				ELSE 
					IF pSecuencia325 = '000000' THEN
						LET cCodRet = '00728'; --NÃMERO DE SECUENCIA DEBE SER DIFERENTE DE 000000, VERIFIQUE
						RETURN cCodRet;
					END IF;
					END IF;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pDivisa325) INTO cEsNoDivisa325 ;
				IF cEsNoDivisa325 = 'F' THEN
					LET cCodRet = '00601'; --NÃMERO DE DIVISA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE

					IF LENGTH(TRIM(pDivisa325)) != 3 THEN
						LET cCodRet = '00602'; --EL NÃMERO DE DIVISA DEBE SER DE 3 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pDivisa325 = '000' THEN
							LET cCodRet = '00603'; --EL NÃMERO DE DIVISA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;

				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'VID') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF ((pArchOrigen = 'VIC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C' ))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;	
				
				IF ((pTipoTransaccion325 NOT IN ('01','02','05','06','07','21')) AND (NOT((pArchOrigen = 'VID') AND (pTipoTransaccion325 = '20')))) THEN -- VIC CON PSTIPOTRANSACCION325 = 20 ES PARA MONEYGRAM
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;

				IF LENGTH(TRIM(pIdComercio325)) < 9 THEN
					LET cCodRet = '00608'; --LA CLAVE DE COMERCIO DEBE SER DE 9 POSICIONES, VERIFIQUE
					RETURN cCodRet;
				END IF; 
				
				
			-- VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS E-GLOBAL VENTAS NACIONALES Y ARCHIVOS COPPEL INTERREDES (BCPLVND, BCPLVNC, BCPLTCD Y BCPLTCC)
			ELIF ((pArchOrigen = 'VND') OR (pArchOrigen = 'VNC') OR (pArchOrigen = 'TCD') OR (pArchOrigen = 'TCC')) THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pIdComercio325) INTO cEsNoIdComercio325;
				IF cEsNoIdComercio325 = 'F' THEN
					LET cCodRet = '00598'; --LA CLAVE DE COMERCIO DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pSecuencia325) INTO cEsNoSecuencia325 ;
				IF cEsNoSecuencia325 = 'F' THEN
					LET cCodRet = '00599'; --NÃMERO DE SECUENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
					IF LENGTH(pSecuencia325) != 6 THEN
						LET cCodRet = '00600'; --EL NÃMERO DE SECUENCIA DEBE SER DE 6 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					END IF;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pReferencia23_325) INTO cEsNoRef23_325;
				IF cEsNoRef23_325 = 'F' THEN
					LET cCodRet = '00609'; --NÃMERO DE REFERENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet; 
				END IF;

				IF (TRIM(NVL(cMontoCB325,'')) = '') THEN
					LET cCodRet = '00610'; --NO SE ENCONTRO EL VALOR DEL MONTO CASHBACK DEL REGISTRO EN CUESTION
					RETURN cCodRet;
				ELSE
				
					EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(cMontoCB325) INTO cEsNoMontoCB325;
					IF cEsNoMontoCB325 = 'F' THEN
						LET cCodRet = '00611'; --EL MONTO CASHBACK DEBE SER NÃMERICO
						RETURN cCodRet;
					ELSE
						LET cMontoCashBack325 = ((REPLACE(cMontoCB325,'.',''))::MONEY/100); 
						IF (cMonto325 + cMontoCashBack325 = 0) THEN
							LET cCodRet = '00612'; --EL MONTO CASHBACK DEBE SER DIFERENTE DE CERO
							RETURN cCodRet; 
						END IF; 		
					END IF;		
				
				END IF;

				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF (((pArchOrigen = 'VND') OR (pArchOrigen = 'TCD')) AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF (((pArchOrigen = 'VNC') OR (pArchOrigen = 'TCC')) AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;

				IF (pTipoTransaccion325 NOT IN ('01','02','20','21')) THEN
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;
				
				IF LENGTH(TRIM(pIdComercio325)) < 9 THEN
					LET cCodRet = '00608'; --LA CLAVE DE COMERCIO DEBE SER DE 9 POSICIONES, VERIFIQUE
					RETURN cCodRet;
				END IF;
				
				IF ((LENGTH(TRIM(pRfc325)) < 12) OR (LENGTH(TRIM(pRfc325)) > 13)) THEN
					LET cCodRet = '00722'; --LA CLAVE RFC DEBE SER DE 12 Ã 13 POSICIONES
					RETURN cCodRet;
				END IF;
				
			--VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS E-GLOBAL CAJEROS AUTOMATICOS (BCPL_ATMD Y BCPL_ATMC)	
			ELIF ((pArchOrigen = 'TMD') OR (pArchOrigen = 'TMC')) THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;

				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'TMD') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF ((pArchOrigen = 'TMC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
	
			--VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS E-GLOBAL PAGOS INTERBANCARIOS (BCPLPNC)
			ELIF ((pArchOrigen = 'PNC')) THEN	

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'PNC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				
				IF (pTipoTransaccion325 != '20') THEN
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;
	
			--VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS COPPEL CORRESPONSALES (BCPLCCD Y BCPLCCP)
			ELIF ((pArchOrigen = 'CCD') OR (pArchOrigen = 'CCP') OR (pArchOrigen = 'TPD')) THEN

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
			--VALIDACION DE INTEGRIDAD DE REGISTROS; ARCHIVOS PROSA (BCPL_ATMOL Y BCPL_ATMPL)
			ELIF ((pArchOrigen = 'TMO') OR (pArchOrigen = 'TMP')) THEN
	
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;				
				
			ELSE
				LET cCodRet = '00594'; --EL NOMBRE DEL ARCHIVO ORIGEN NO CORRESPONDE A LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
				RETURN cCodRet;
			END IF;
			
			
			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_compvalidaintegridad (pUsuario, pArchOrigen, pIntegridad, 
			pConsecutivo, pNumTarjeta, pTipoTransaccion325, pMonto325, pIdComercio325, pNomComercio325, pReferencia23_325, 
			pSecuencia325, pDivisa325, pRfc325)				
			INTO cCodRetSp, cIntegridad, cErrorActividad, cIntegridadError;
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_compvalidaintegridad';
			END IF;
		
			IF cCodRetSp::INTEGER = 0 AND cIntegridad = 'V' THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/08/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: Consulta de Movimientos Pendientes de Aplicar', 
'DESCRIPCION: SPL que se encarga de actualizar el registro con error de integridad.',
'Complementa la integridad de los campos necesarios para la conciliacion',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 23/11/2015',
'DESCRIPCION: Se aplicÃ³ el cambio a la validaciÃ³n del cMontoCB325 y a las posiciones del rfc, ya que anteriormente solo validaba que el RFC fuera a 13 posiciones.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 02/02/2016',
'DESCRIPCION: Se agrega la validaciÃ³n para ver si el numero de secuencia sea diferente a 000000.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoarchivotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                        CHAR(50) AS nom_archivo;
                        
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNomArchivo CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE bInTrans BOOLEAN;
	DEFINE cFechaArchivoOUT CHAR(10);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNomArchivo = '';
	LET iNoRegistros = 0;
	LET bInTrans = 'f';
	LET cFechaArchivoOUT = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||'_';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomArchivo;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bInTrans = 't';
		END EXCEPTION WITH RESUME;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoarchivotef.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomArchivo;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNomArchivo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomArchivo;
		END IF;

		BEGIN WORK;
		IF NOT bInTrans THEN
			COMMIT WORK;
		END IF;

		-- Se elimina el archivo out
		-- SYSTEM "[ -f "||TRIM(pRuta)||TRIM(cFechaArchivoOUT)||"buscar.bus"||" ] && rm -rf "||TRIM(pRuta)||TRIM(cFechaArchivoOUT)||"buscar.bus";

		SET ISOLATION TO DIRTY READ;
		IF pRegistros = 0 THEN

			FOREACH EXECUTE PROCEDURE bditef:'informix'.sp_buscararchivos_tef(pRuta)
					INTO cCodRetSp, cNomArchivo

				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bditef:sp_buscararchivos_tef';
				ELIF cCodRetSp::INTEGER = 1     THEN
					IF bInTrans THEN
						BEGIN WORK;
					END IF;

					LET cCodRet = '00003';
					RETURN cCodRet, cNomArchivo;
				END IF;

				LET iNoRegistros = iNoRegistros + 1;
				IF iNoRegistros <= pRecuperacion THEN
					RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;
				END IF;

			END FOREACH;

		ELSE 

			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion linea
					INTO cNomArchivo
					FROM bditef:"informix".tef_busca_archivos

				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;

			END FOREACH;

		END IF;

		IF bInTrans THEN
			BEGIN WORK;
		END IF;

		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00560';
			ELSE
				LET cCodRet = '1001';
			END IF;

			RETURN cCodRet, cNomArchivo;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 07/07/2015',
'DESCRIPCION: SPL que realiza la consulta de archivos a tratar de acuerdo a la ruta proporcionada.',
'FUNCIONALIDAD: EnvÃ­o/RecepciÃ³n Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bditef';

CREATE PROCEDURE "informix".sp_con_consultactesfusionados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechIni DATE, pFechFin DATE)
			RETURNING CHAR(5) AS codret,
					INTEGER AS num_registros;
					
		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
		DEFINE cCodRetSp CHAR(5);
		DEFINE iCodRetSp INTEGER;
		DEFINE iNoRegistros INTEGER;
	
		LET cCodRet = '00000';
		LET iSqlErr = 0;
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET iNoRegistros = 0;	
	
		BEGIN	
				ON EXCEPTION SET iSqlErr
						LET cCodRet = iSqlErr;
						RETURN cCodRet, iNoRegistros;
				END EXCEPTION;
			
				--SET DEBUG FILE TO '/tmp/mfinis/sp_con_consultactesfusionados_totales.out';
				--TRACE ON;
		
				IF pUsuario = '' OR pIdFuncion = '' OR  pFechIni IS NULL OR pFechFin IS NULL THEN
						LET cCodRet = '00003';
						RETURN cCodRet, iNoRegistros;
				END IF;
		
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
						RETURN cCodRet, iNoRegistros;
				END IF;
				
				SET ISOLATION TO DIRTY READ;
				
						EXECUTE PROCEDURE bdinteg:"informix".sp_ctes_fusionados2_totales(pFechIni, pFechFin)
						INTO cCodRetSp, iNoRegistros;
		
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctes_fusionados2_totales';		
						END IF;
			
				IF iNoRegistros = 0 THEN
						LET cCodRet = '00017';				
				END IF;			
					RETURN cCodRet, iNoRegistros;		
		END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 12/11/2015',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: Reporte Procesos Sucursal',
'DESCRIPCION: SPL que consulta total de clientes fusionados',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_consultaverificasms(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechIni DATE, pFechFin DATE , pRegistros INTEGER, pRecuperacion INTEGER)
			RETURNING CHAR(5) AS codret,
			CHAR(10) AS Fecha,
			INTEGER AS Validos,
			INTEGER AS No_Validos,
			INTEGER AS Total,
			INTEGER AS total_validos,
			INTEGER AS total_novalidos,
			INTEGER AS resultado_total;	
		
		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
		DEFINE cCodRetSp CHAR(5);
		DEFINE iCodRetSp INTEGER;
		DEFINE cFecha CHAR(10);
		DEFINE iValidos INTEGER;
		DEFINE iNoValidos INTEGER;
		DEFINE iTotal INTEGER;
		DEFINE iTotalValidos INTEGER;
		DEFINE iTotalNoValidos INTEGER;
		DEFINE iResultadoTotal INTEGER;
		DEFINE iNoRegistros INTEGER;
	
		LET cCodRet = '00000';
		LET iSqlErr = 0;
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET cFecha = '';
		LET iValidos = 0;
		LET iNoValidos = 0;
		LET iTotal = 0;
		LET iTotalValidos = 0;
		LET iTotalNoValidos = 0;
		LET iResultadoTotal = 0;
		LET iNoRegistros = 0;	
	
		BEGIN	
				ON EXCEPTION SET iSqlErr
						LET cCodRet = iSqlErr;
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END EXCEPTION;
			
				--SET DEBUG FILE TO '/tmp/mfinis/sp_con_consultaverificasms.out';
				--TRACE ON;
		
				IF pUsuario = '' OR pIdFuncion = '' OR  pFechIni IS NULL OR pFechFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
						LET cCodRet = '00003';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
				
				-- VALIDACION DE LA PAGINACION
				IF pRegistros < 0 OR pRecuperacion < 0 THEN
						LET cCodRet = '00098';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
		
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
				-- OBTIENE SUMA TOTALES
				FOREACH
						EXECUTE PROCEDURE bdinteg:"informix".sp_verifica_sms(pFechIni, pFechFin)
						INTO cCodRetSp, cFecha, iValidos, iNoValidos, iTotal
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_verifica_sms';		
						END IF;
			
						LET iTotalValidos = iTotalValidos + iValidos;
						LET iTotalNoValidos = iTotalNoValidos + iNoValidos;
						LET iResultadoTotal = iResultadoTotal + iTotal;	
				END FOREACH
				--OBTIENE DETALLES DE LA CONSULTA
				FOREACH
						EXECUTE PROCEDURE bdinteg:"informix".sp_verifica_sms2(pFechIni, pFechFin, pRegistros, pRecuperacion)
						INTO cCodRetSp, cFecha, iValidos, iNoValidos, iTotal
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_verifica_sms2';		
						END IF;									
		
						LET iNoRegistros = iNoRegistros + 1;
		
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal WITH RESUME;
		
				END FOREACH
		
				IF iNoRegistros = 0 AND pRegistros = 0 THEN			
						LET cCodRet = '00017';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				ELIF iNoRegistros = 0 AND pRegistros > 0 THEN 
						LET cCodRet = '1001';		
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;	
		END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 12/11/2015',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: Reporte Procesos Sucursal',
'DESCRIPCION: SPL que consulta la verificaciÃ³n de sms del Reporte Procesos Sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizacedulas( pFechaConcil DATE, pCtaContable CHAR(14), pObservaciones CHAR(255) )
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_actualizacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualizacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pCtaContable is null OR pCtaContable = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_cedulacontable
     WHERE fecha_concil = pFechaConcil
       AND cta_contable = pCtaContable
       AND editable = '0';
       
    IF iExiste > 0 THEN
        UPDATE bdicheq:sc_cedulacontable
           SET observaciones = pObservaciones
         WHERE fecha_concil = pFechaConcil
           AND cta_contable = pCtaContable;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1;
    END IF;
    
    RETURN cCodRet1;
     
    END;
    
END PROCEDURE;