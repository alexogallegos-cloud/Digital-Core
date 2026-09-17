CREATE PROCEDURE "informix".sp_marcarse(pNumCte 		 CHAR(20),
							 pEmpresa 		 CHAR(3),
							 pNumCredito	 CHAR(20),
							 pSE			 CHAR(1),
							 pCausa			 SMALLINT,
							 pNombreEfectuo	 CHAR(40),
							 pUsuario 		 CHAR(8),
							 pTipoMovimiento INTEGER)	--1= Cliente, 2.- Credito

	RETURNING
	CHAR(6); --cod retorno

	--Declaracion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;
	DEFINE v_codretValidaUsuario CHAR(6);

	DEFINE v_Alcance 		CHAR(1);
    DEFINE v_fecha_hoy      datetime year to second;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;
	LET v_codretValidaUsuario = 0;


	--********************************************************************
	--05-02-2009
	--Realizo:
	--Abraham Ayala
	--Marcar los clientes y/o creditos para asignarles una situacion especial.
	--27-08-2009
	--Modifico: Armida Pazos 
	---Se modifico para que ejecute el sp_ValidarUsuarioMarca
	--*******************************************************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr <> 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_MarcarSE.out';
	--trace on;

		--Seccion para marcaje que afecta al cliente
		IF pTipoMovimiento = 1 THEN
            IF (pNumCte = '' OR pNumCte IS NULL) OR (pEmpresa = '' OR pEmpresa IS NULL) OR (pSE = '' OR pSE IS NULL)
				OR (pCausa = 0 OR pCausa IS NULL) OR (pNombreEfectuo = '' OR pNombreEfectuo IS NULL)
				OR (pUsuario = '' OR pUsuario IS NULL) OR (pTipoMovimiento = 0 OR pTipoMovimiento IS NULL) THEN

                LET v_codret = '999';   --Faltan parametros
		        RETURN v_codret;
		    ELSE
				--VALIDAR DERECHOS DE ACCESO
				--Estos se agregaran en otro momento
				--Tambien se debe validar que el valor del usuario como parametro de entrada no sea vacio

				--Obtener la fecha actual del servidor
                SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
				--Verificar que la Situacion y Causa sean validas
				IF NOT EXISTS (SELECT {+ INDEX(se_catsitesp idx_catsitesp)} situacion FROM bdisitesp:se_catsitesp WHERE situacion = pSE AND causa = pCausa) THEN
					LET v_codret = "001";	--No es una SE y Causa Validos
					RETURN v_codret;
				ELSE
					-- Obtener el alcance de la Situacion y Causa
					SELECT {+ INDEX(se_catsitesp idx_catsitesp2)}alcance
					INTO v_Alcance
					FROM bdisitesp:se_catsitesp
					WHERE situacion = pSE AND
						  causa = pCausa;
						  
					--Validar que el alcance de la Situacion y causa aplique para el cliente
					IF v_Alcance = 0 OR v_Alcance = 2 THEN
					
						--Validar que el cliente no este marcado con una Situacion y causa
						IF EXISTS (SELECT {+ INDEX(se_ctessitespcte se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = pNumCte AND empresa = pEmpresa) THEN
							LET v_codret = '002';	-- el cliente ya esta marcado
							RETURN v_codret;
						ELSE
						
							EXECUTE PROCEDURE bdisitesp:sp_ValidarUsuarioMarca(pEmpresa, pUsuario, pSE, pCausa, 'M' ) INTO v_codretValidaUsuario;
							If TRIM(v_codretValidaUsuario) = '000' THEN
							--Insertar en la tabla el registro del cliente ya marcado con Situacion y Causa					
							
								INSERT INTO bdisitesp:se_ctessitespcte
											(empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo,
											fechamovto, usralta, fchalta, usrmodifica, fchmodifica)
								   VALUES (pEmpresa, pNumCte, pSE, pCausa, '', '', 'M', pUsuario, pNombreEfectuo, v_fecha_hoy, pUsuario, v_fecha_hoy, '', DATE(1));
									--Insertar en la tabla Historica el registro del cliente ya marcado con Situacion y Causa
								INSERT INTO bdisitesp:se_ctessitespcte_his
												(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal,
												 empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
								VALUES ('M', pNumCte, pEmpresa, pSE, pCausa, '', '', pUsuario, pUsuario, v_fecha_hoy, '', DATE(1));

								RETURN v_codret;
							ELSE
								LET v_codret = '005';	-- Usuario sin derecho para el marcaje
								
								RETURN v_codret;
							END IF;
						END IF;
					ELSE
						LET v_codret = '003';	-- La SE-Causa Marca al credito no al cliente
						RETURN v_codret;
					END IF;

				END IF;
			END IF;
		ELSE
			--Seccion para marcacion que afecta al credito
			IF pNumCte = '' OR pNumCte IS NULL OR pEmpresa = '' OR pEmpresa IS NULL OR pSE = '' OR pSE IS NULL OR pCausa <= 0
				OR pCausa IS NULL OR pNombreEfectuo = '' OR pNombreEfectuo IS NULL OR pUsuario = '' OR pUsuario IS NULL
				OR pTipoMovimiento <= 0 OR pTipoMovimiento IS NULL THEN

				LET v_codret = '999';	--Faltan parametros
		        RETURN v_codret;
		    ELSE

				--VALIDAR DERECHOS DE ACCESO
				--Estos se agregaran en otro momento
				--Tambien se debe validar que el valor del usuario como parametro de entrada no sea vacio

				--Obtener la fecha actual del servidor
                SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
				--Verificar que la Situacion y Causa sean validas
				IF NOT EXISTS (SELECT {+ INDEX(se_catsitesp idx_catsitesp)} situacion FROM bdisitesp:se_catsitesp WHERE situacion = pSE AND causa = pCausa) THEN

					LET v_codret = "001";	--No es una SE y Causa Validos
					RETURN v_codret;
				ELSE
					-- Obtener el alcance de la Situacion y Causa
					SELECT {+ INDEX(se_catsitesp idx_catsitesp2)} alcance
					INTO v_Alcance
					FROM bdisitesp:se_catsitesp
					WHERE situacion = pSE AND
						  causa = pCausa;
					--Validar que el alcance de la Situacion y causa aplique para el credito
					IF v_Alcance = 1 OR v_Alcance = 2 THEN
						IF EXISTS (SELECT {+ INDEX(se_ctessitespcred se_ctessitespcred_idx1)} numcred FROM bdisitesp:se_ctessitespcred WHERE numcte = pNumCte AND numcred = pNumCredito AND
								   empresa = pEmpresa) THEN

							LET v_codret = '002';	-- el credito ya esta marcado
							RETURN v_codret;
						ELSE
							--Insertar en la tabla el registro del credito ya marcado con Situacion y Causa
							EXECUTE PROCEDURE bdisitesp:sp_ValidarUsuarioMarca(pEmpresa, pUsuario, pSE, pCausa, 'M' ) INTO v_codretValidaUsuario;
							If TRIM(v_codretValidaUsuario) = '000' THEN					
								INSERT INTO bdisitesp:se_ctessitespcred
											(numcte, empresa, numcred, situacion, causa, cvesitesporigen, sucursal, tipomovto, nombreefectuo,
											usralta, fchalta, usrmodifica, fchmodifica)
	                            VALUES (pNumCte, pEmpresa, pNumCredito, pSE, pCausa, '', '', 'M', pNombreEfectuo, pUsuario, v_fecha_hoy, '', DATE(1));
								--Insertar en la tabla Historica el registro del cliente ya marcado con Situacion y Causa
								INSERT INTO bdisitesp:se_ctessitespcred_his
											(tipomovto, numcte, numcred, empresa, situacion, causa, cvesitesporigen, sucursal,
											 nombreefectuo, usralta, fchalta, usrmodifica, fchmodifica)
								VALUES ('M', pNumCte, pNumCredito, pEmpresa, pSE, pCausa, '', '', pNombreEfectuo, pUsuario,
										v_fecha_hoy, '', DATE(1));

								RETURN v_codret;
							ELSE
								LET v_codret = '005';	-- Usuario sin derechopara el marcaje
								RETURN v_codret;
							END IF;
						END IF;
					ELSE
						LET v_codret = '003';	-- La SE-Causa Marca al cliente no al credito
						RETURN v_codret;
						
					
					END IF;									
				END IF
			END IF;
		END IF;
	END;
END PROCEDURE;