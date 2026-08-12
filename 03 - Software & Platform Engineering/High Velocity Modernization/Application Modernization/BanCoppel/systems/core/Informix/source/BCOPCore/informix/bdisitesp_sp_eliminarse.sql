CREATE PROCEDURE "informix".sp_eliminarse(
										 pNumCte 			CHAR(20),
										 pEmpresa 			CHAR(3),
										 pNumCredito		CHAR(20),
										 pSE				CHAR(1),
										 pCausa				SMALLINT,
										 pNombreEfectuo		CHAR(40),
										 pUsuario 			CHAR(8),
										 pTipoMovimiento 	INTEGER,	--1.- Cliente, 2.- Credito
										 pProsedencia		INTEGER		--1.- Individual, 2.- General
										)

	RETURNING
	CHAR(6); --cod retorno

	--Declaracion de variables
	DEFINE v_codret CHAR(6);
	DEFINE v_sqlerr INTEGER;
	DEFINE v_codretValidaUsuario CHAR(6);

    DEFINE v_fecha_hoy datetime year to second;

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

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;
	LET v_codretValidaUsuario = '';

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
	--Permitir la eliminación de situaciones especiales y causas para un cliente y/o crédito.
	--27-08-2009
	--Modifico: Armida Pazos 
	---Se modifico para que ejecute el sp_ValidarUsuarioMarca

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

    --Set debug file to '/tmp/sp_EliminarSE.out';
    --trace on;

	    --checar valores nulos en los parametros
        IF (pNumCte = "" OR pNumCte IS NULL) OR (pEmpresa = "" OR pEmpresa IS NULL) OR (pSE = "" OR pSE IS NULL)
			OR (pCausa = 0 OR pCausa IS NULL) OR (pNombreEfectuo = "" OR pNombreEfectuo IS NULL)
			OR (pUsuario = "" OR pUsuario IS NULL) OR (pTipoMovimiento = 0 OR pTipoMovimiento IS NULL)
			OR (pProsedencia = 0 OR pProsedencia IS NULL) THEN
	        LET v_codret = "999";	--Faltan parametros
	        RETURN v_codret;
	    ELSE
			--VALIDAR DERECHOS DE ACCESO
			--Estos se agregaran en otro momento
			--Tambien se debe validar que el valor del usuario como parametro de entrada no sea vacio

			--Seccion para eliminacion que afecta al cliente
			IF pProsedencia = 1 AND pTipoMovimiento = 1 THEN
				--Validar que existe el registro del cliente que sera eliminado
				IF EXISTS (SELECT {+ INDEX(se_ctessitespcte se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE empresa = pEmpresa AND numcte = pNumCte) THEN

					--Recuperar los datos que tiene actualmente la tabla para este cliente
					SELECT {+ INDEX(se_ctessitespcte se_ctessitespcte_idx2)} situacion, causa, usralta, fchalta
					INTO v_SE, v_Causa, v_UsrAlta, v_FechaAlta
					FROM bdisitesp:se_ctessitespcte
					WHERE numcte = pNumCte AND
						  empresa = pEmpresa;

						--Validar que la Situacion y causa puedan ser eliminadas
					
					
		                    IF EXISTS (SELECT {+ INDEX(se_logicaacceso idx_logicaacceso)} situacion FROM bdisitesp:se_logicaacceso WHERE situacion = v_SE AND causa = v_Causa AND empresa = pEmpresa AND idtipomov = 'E') THEN
								EXECUTE PROCEDURE bdisitesp:sp_ValidarUsuarioMarca(pEmpresa, pUsuario, pSE, pCausa, 'E' ) INTO v_codretValidaUsuario;
								If TRIM(v_codretValidaUsuario) = '000' THEN 

									--Obtener la fecha actual del servidor
			                        SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
									--Insertar los campos recuperados de la tabla original para ponerlos en la historica
									INSERT INTO bdisitesp:se_ctessitespcte_his
												(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal,
												 empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
									VALUES ('E', pNumcte, pEmpresa, pSE, pCausa, '', '', pUsuario,
											v_UsrAlta, NVL(v_FechaAlta, DATE(1)), pUsuario, v_fecha_hoy);

									--Eliminamos de la tabla la situacion y causa que se recibio como parametro de entrada
			                                --create index "informix".se_ctessitespcte_idx1 on "informix".se_ctessitespcte (numcte) using btree  in datos01 ;
									DELETE {+INDEX (se_ctessitespcte se_ctessitespcte_idx1)} FROM bdisitesp:se_ctessitespcte
									WHERE numcte = pNumCte AND
										  empresa = pEmpresa;

									RETURN v_codret;
			                    ELSE
									LET v_codret = '005';	-- Usuario sin derecho para eliminar
			                       -- LET v_codret = '002';   --La SE-Causa no puede ser eliminada
			                        RETURN v_codret;
			                    END IF;
						ELSE
								LET v_codret = '003'; --La SE-Causa no puede ser eliminida 
								RETURN v_codret;	
							END IF;
				ELSE

					LET v_codret = '001';	--No existen registros para este numero de cliente
					RETURN v_codret;
				END IF;

			ELSE	--Seccion del codigo para la eliminar Situación y Causa que marca al credito
				--Validar que exista el registro que se va a eliminar
				IF EXISTS (SELECT {+ INDEX(se_ctessitespcred se_ctessitespcred_idx2)} numcte FROM bdisitesp:se_ctessitespcred WHERE numcte = pNumCte AND numcred = pNumCredito AND
						   empresa = pEmpresa) THEN
					--Recuperar los datos que tiene actualmente la tabla para este credito
					SELECT {+ INDEX(se_ctessitespcred se_ctessitespcred_idx4)} situacion, causa, usralta, fchalta
					INTO v_SE, v_Causa, v_UsrAlta, v_FechaAlta
					FROM bdisitesp:se_ctessitespcred
					WHERE numcte = pNumCte AND
						  numcred = pNumCredito AND
						  empresa = pEmpresa;

					--Validar que la Situacion y causa puedan ser eliminadas
                    IF EXISTS (SELECT {+ INDEX(se_logicaacceso idx_logicaacceso)} situacion FROM bdisitesp:se_logicaacceso WHERE situacion = v_SE AND causa = v_Causa AND empresa = pEmpresa AND idtipomov = 'E') THEN
						
						EXECUTE PROCEDURE bdisitesp:sp_ValidarUsuarioMarca(pEmpresa, pUsuario, pSE, pCausa, 'E' ) INTO v_codretValidaUsuario;
						If TRIM(v_codretValidaUsuario) = '000' THEN 

							--Consultar la fecha actual en el servidor
	                        SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
							--Insertar los campos recuperados de la tabla original para ponerlos en la historica
							INSERT INTO bdisitesp:se_ctessitespcred_his
										(tipomovto, numcte, numcred, empresa, situacion, causa, cvesitesporigen, sucursal,
										 nombreefectuo, usralta, fchalta, usrmodifica, fchmodifica)
	                        VALUES ('E', pNumCte, pNumCredito, pEmpresa, pSE, pCausa, '', '',
									pNombreEfectuo, v_UsrAlta, NVL(v_FechaAlta, DATE(1)), pUsuario, v_fecha_hoy);

							--Eliminamos de la tabla la situacion y causa que se recibio como parametro de entrada
	                            ---create index "informix".se_ctessitespcred_idx1 on "informix".se_ctessitespcred (numcte,numcred) using btree  in datos01 ;
							DELETE {+INDEX (se_ctessitespcred se_ctessitespcred_idx1)} FROM bdisitesp:se_ctessitespcred
							WHERE numcte = pNumCte AND
								  numcred = pNumCredito AND
								  empresa = pEmpresa;

							RETURN v_codret;
						ELSE

							LET v_codret = '005';	-- usuario sin derecho para eliminar
							RETURN v_codret;
						END IF;
                    ELSE

                        LET v_codret = '002';   --La SE-Causa no puede ser eliminada
                        RETURN v_codret;
                    END IF;
				ELSE

					LET v_codret = '001';	--No existen registros para este numero de credito
					RETURN v_codret;
				END IF;
			END IF;
		END IF;
	END;
END PROCEDURE;