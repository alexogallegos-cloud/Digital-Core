CREATE PROCEDURE "informix".sp_sustituirse(
								pNumCte 		CHAR(20),
								pEmpresa 		CHAR(3),
								pNumCredito		CHAR(20),
								pSE				CHAR(1),
								pCausa			SMALLINT,
								pNombreEfectuo	CHAR(40),
								pUsuario 		CHAR(8),
								pTipoMovimiento INTEGER	--1= Cliente, 2.- Credito
								)

	RETURNING
	CHAR(6); --cod retorno

	--Definicion de variables
	DEFINE v_codret CHAR(6);
	DEFINE v_codretValidaUsuario CHAR(6);
	DEFINE v_sqlerr INTEGER;

	DEFINE v_TipoMov 		CHAR(1);
	DEFINE v_Numcte			CHAR(20);
	DEFINE v_Empresa		CHAR(3);
	DEFINE v_SE				CHAR(1);
	DEFINE v_Causa			SMALLINT;
	DEFINE v_CveSitEsp		CHAR(12);
	DEFINE v_Sucursal		CHAR(4);
	DEFINE v_EmpleadoEfe	CHAR(8);
	DEFINE v_UsrAlta		CHAR(8);
    DEFINE v_FechaAlta      datetime year to second;
	DEFINE v_UsrModifica	CHAR(8);
    DEFINE v_FechaModifica  datetime year to second;

	DEFINE v_NumCred		CHAR(20);
	DEFINE v_NomEfectuo		CHAR(40);

	DEFINE v_Alcance	CHAR(1);

    DEFINE v_fecha_hoy datetime year to second;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_codretValidaUsuario = '';
	LET v_sqlerr = 0;

    LET v_TipoMov        = "";
    LET v_Numcte         = "";
    LET v_Empresa        = "";
    LET v_SE             = "";
    LET v_Causa          = 0;
    LET v_CveSitEsp      = "";
    LET v_Sucursal       = "";
    LET v_EmpleadoEfe    = "";
    LET v_UsrAlta        = "";

    LET v_UsrModifica    = "";
    LET v_NumCred        = "";
    LET v_NomEfectuo     = "";
    LET v_Alcance        = "";

	--05-02-2009
	--Realizo:
	--Abraham Ayala
	--Realiza la sustitucion de alguna situacion especial.
	--26-08-2009
	--Modifico: Armida Pazos
	---Se modifico para que ejecute el sp_ValidarUsuarioMarca

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

--	Set debug file to '/tmp/sp_SustituirSE.out';
--	trace on;

	    --checar valores nulos en los parametros
        IF ( pNumCte = "" OR pNumCte IS NULL ) OR ( pEmpresa = "" OR pEmpresa IS NULL ) OR ( pSE = "" OR pSE IS NULL ) OR ( pCausa = 0 OR pCausa IS NULL ) OR ( pNombreEfectuo = "" OR pNombreEfectuo IS NULL ) OR ( pUsuario = "" OR pUsuario IS NULL ) OR ( pTipoMovimiento = 0 OR pTipoMovimiento IS NULL ) THEN
	        LET v_codret = "999";	--Faltan parametros
	        RETURN v_codret;
	    ELSE
			--Validar si no existe la SE y Causa
			IF NOT EXISTS (SELECT {+ INDEX(bdisitesp:se_catsitesp idx_catsitesp2)} situacion FROM bdisitesp:se_catsitesp WHERE situacion = pSE AND causa = pCausa) THEN

				LET v_codret = "001";	--No es una SE y Causa validos
				RETURN v_codret;
			ELSE
				-- Obtener alcance de marca de SE y Causa
				SELECT {+ INDEX(bdisitesp:se_catsitesp idx_catsitesp)} alcance
				INTO v_Alcance
				FROM bdisitesp:se_catsitesp
				WHERE situacion = pSE AND
					  causa = pCausa;

				--Seccion para sustitucion que afecta al cliente
				IF pTipoMovimiento = 1 THEN
					IF v_Alcance = 0 OR v_Alcance = 2 THEN
						--Validar que exista el registro del cliente
						IF NOT EXISTS (SELECT {+ INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)}numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = pNumCte AND empresa = pEmpresa) THEN

							LET v_codret = '002';	-- el cliente No esta marcado
							RETURN v_codret;
						ELSE
							--Recuperar los datos que tiene actualmente la tabla para este cliente
							SELECT situacion, causa, usralta, fchalta
							INTO v_SE, v_Causa, v_UsrAlta, v_FechaAlta
							FROM bdisitesp:se_ctessitespcte
							WHERE numcte = pNumCte AND
								  empresa = pEmpresa;

							--Validar la logica de sustitucion para la nueva SE y Causa en comparacion a la actual

								--IF EXISTS (SELECT {+ INDEX(bdisitesp:se_logicasustit idx_logicasustit)} situacion FROM bdisitesp:se_logicasustit WHERE situacion = v_SE AND causa = v_Causa AND
								--		    empresa = pEmpresa AND ((sitsiguente = pSE AND causasiguiente = pCausa) OR
								--		   (sitsiguente = 'Z' AND causasiguiente = '0')))THEN

								IF EXISTS (SELECT situacion FROM bdisitesp:se_logicaacceso WHERE situacion = pSE AND causa = pCausa AND
										    empresa = pEmpresa AND idtipomov = 'M') THEN
								
									EXECUTE PROCEDURE bdisitesp:sp_ValidarUsuarioMarca(pEmpresa, pUsuario, pSE, pCausa, 'M' ) INTO v_codretValidaUsuario;
							If TRIM(v_codretValidaUsuario) = '000' THEN

										--Consultar la fecha actual en el servidor
		                                SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
										--Insertar los campos recuperados de la tabla original para ponerlos en la historica
										INSERT INTO bdisitesp:se_ctessitespcte_his
													(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal,
													 empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
										VALUES ('S', pNumCte, pEmpresa, pSE, pCausa, '', '', pUsuario,
												v_UsrAlta, NVL(v_FechaAlta, DATE(1)), pUsuario, v_fecha_hoy);

										--Actualizar el registro para el cliente con la nueva SE y Causa
----create index "informix".se_ctessitespcte_idx1 on "informix".se_ctessitespcte (numcte) using btree
										UPDATE {+INDEX (se_ctessitespcte se_ctessitespcte_idx1)} bdisitesp:se_ctessitespcte
										SET situacion = pSE, causa = pCausa, cvesitesporigen = '', sucursal = '', tipomovto = 'S',
											empleadoefectuo = pUsuario, nombreefectuo = pNombreEfectuo, fechamovto = v_fecha_hoy,
											usrmodifica = pUsuario, fchmodifica = v_fecha_hoy
										WHERE empresa = pEmpresa AND
											  numcte = pNumCte;

										RETURN v_codret;
									ELSE

										LET v_codret = '005';	-- Usuario sin derechopara sustituir
										RETURN v_codret;
									END IF;
							ELSE
								LET v_codret = '003'; --La SE-Causa con la que desea marcar al cliente no puede sustituir a la SE-Causa actual del cliente
								RETURN v_codret;
							END IF;
						END IF;
					ELSE
						LET v_codret = '004';	-- La SE-Causa Marca al credito no al cliente
						RETURN v_codret;
					END IF;
				ELSE
					--Seccion para sustitucion que afecta al credito
					IF v_Alcance = 1 OR v_Alcance = 2 THEN
						--Validar que exista el registro del credito
						IF NOT EXISTS (SELECT {+ INDEX(bdisitesp:se_ctessitespcred se_ctessitespcred_idx2)} numcte FROM bdisitesp:se_ctessitespcred WHERE numcte = pNumCte AND numcred = pNumCredito AND
									   empresa = pEmpresa) THEN

							LET v_codret = '002';	-- el credito No esta marcado
							RETURN v_codret;
						ELSE
							--Recuperar los datos que tiene actualmente la tabla para este credito
--create index "informix".se_ctessitespcred_idx1 on "informix".se_ctessitespcred (numcte,numcred) using btree
							SELECT {+INDEX (se_ctessitespcred se_ctessitespcred_idx1)} situacion, causa, usralta, fchalta
							INTO v_SE, v_Causa, v_UsrAlta, v_FechaAlta
							FROM bdisitesp:se_ctessitespcred
							WHERE empresa = pEmpresa AND numcte = pNumCte AND numcred = pNumCredito;

							--Validar la logica de sustitucion para la nueva SE y Causa en comparacion a la actual
							IF EXISTS (SELECT {+ INDEX(bdisitesp:se_logicasustit idx_logicasustit)} situacion FROM bdisitesp:se_logicasustit WHERE empresa = pEmpresa AND situacion = v_SE AND
									   causa = v_Causa AND ((sitsiguente = pSE AND causasiguiente = pCausa) OR
									   (sitsiguente = 'Z' AND causasiguiente = '0')))THEN

								EXECUTE PROCEDURE bdisitesp:sp_ValidarUsuarioMarca(pEmpresa, pUsuario, pSE, pCausa, 'S' ) INTO v_codretValidaUsuario;
								If TRIM(v_codretValidaUsuario) = '000' THEN
									--Consultar la fecha actual en el servidor
	                                SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
									--Insertar los campos recuperados de la tabla original para ponerlos en la historica
									INSERT INTO bdisitesp:se_ctessitespcred_his
												(tipomovto, numcte, numcred, empresa, situacion, causa, cvesitesporigen, sucursal,
												 nombreefectuo, usralta, fchalta, usrmodifica, fchmodifica)
									VALUES ('S', pNumCte, pNumCredito, pEmpresa, pSE, pCausa, '', '',
	                                        pNombreEfectuo, v_UsrAlta, NVL(v_FechaAlta, DATE(1)), pUsuario, v_fecha_hoy);

									--Actualizar el registro para el credito con la nueva SE y Causa
									UPDATE bdisitesp:se_ctessitespcred
									SET situacion = pSE, causa = pCausa, cvesitesporigen = '', sucursal = '', tipomovto = 'S',
										nombreefectuo = pNombreEfectuo, usrmodifica = pUsuario, fchmodifica = v_fecha_hoy
									WHERE empresa = pEmpresa AND
										  numcte = pNumCte AND
										  numcred = pNumCredito;

									RETURN v_codret;
								ELSE

									LET v_codret = '005';	-- Usuario sin derecho para sustituir
									RETURN v_codret;
								END IF;
							ELSE
								LET v_codret = '003'; --La SE-Causa con la que desea marcar al credito no puede sustituir a la SE-Causa actual del credito
								RETURN v_codret;
							END IF;
						END IF;
					ELSE
						LET v_codret = '004';	-- La SE-Causa Marca al cliente no al credito
						RETURN v_codret;
					END IF;
				END IF;
		    END IF;
		END IF;
	END;
END PROCEDURE;