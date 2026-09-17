CREATE PROCEDURE "informix".sp_guardarperfil(
										    pEmpresa 			CHAR (3),
										    pClavePerfil 		INTEGER,
										    pDescripcionPerfil 	CHAR(50),
										    pUsuario			CHAR(8),
										    pIdTipoMov			INTEGER,		--1.- Alta, 2.- Modificacion
										    pIdArea				CHAR(2)
										   )

	RETURNING
	CHAR(5); --cod retorno

	--Definicion de variables
	DEFINE v_codret CHAR(5);
	DEFINE v_sqlerr INTEGER;

    DEFINE v_fecha_hoy datetime year to second;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

	IF pClavePerfil IS NULL THEN
		LET pClavePerfil = 0;
	END IF;
	IF pDescripcionPerfil IS NULL THEN
		LET pDescripcionPerfil = '';
	ELSE
		LET pDescripcionPerfil = UPPER(TRIM(pDescripcionPerfil));
	END IF;
	IF pIdArea IS NULL THEN
		LET pIdArea = '';
	ELSE
		LET pIdArea = UPPER(TRIM(pIdArea));
	END IF;

	--************************************
	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Dar de alta uno o varios tipos de marcas.
	--***********************************

	--************************************
	--14-05-2009
	--Modifico:
	--Bernardo Baez
	--Se modifica para permitir guardar descripción existente para otro registro.
	--***********************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret=v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_GuardarPerfil.out';
	--trace on;

	    --checar valores nulos en los parametros
	    IF pEmpresa = "" OR pClavePerfil = 0 OR pDescripcionPerfil = '' OR pUsuario = '' OR pIdTipoMov = 0 THEN
	        LET v_codret = '999';	--Faltan valores
			RETURN v_codret;
	    ELSE
			IF pIdTipoMov = 1 THEN	--Alta
				--Validamos que el registro no exista
				IF NOT EXISTS (SELECT {+ INDEX(se_perfiles idx_perfiles)} idperfil FROM bdisitesp:se_perfiles WHERE idperfil = pClavePerfil AND empresa = pEmpresa) THEN
                    --Validamos que la descipcion no exista para otro registro
                    IF NOT EXISTS (SELECT {+ INDEX(se_perfiles idx_perfiles3)} descripcion FROM bdisitesp:se_perfiles WHERE descripcion = pDescripcionPerfil AND empresa = pEmpresa) THEN
                        --Obtener la fecha actual del servidor
                        SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
                        --Insertamos el registro
                        INSERT INTO bdisitesp:se_perfiles (idperfil,
                                empresa, descripcion, usralta, fchalta, usrmodifica,
                                fchmodifica, situacion, causa, idtipomov, idarea)
                        VALUES (pClavePerfil, pEmpresa, pDescripcionPerfil, pUsuario, v_fecha_hoy, '', DATE(1), '', 0, pIdTipoMov, '');

                        RETURN v_codret;
                    ELSE
                        LET v_codret = '002';	--Ya existe un registro con la descripcion recibida
                        RETURN v_codret;
                    END IF;
				ELSE
					LET v_codret = '001';	--Ya existe el registro que desea ingresar
					RETURN v_codret;
				END IF;

			ELSE	--Modificacion
				--Validar que exista el registro
				IF EXISTS (SELECT {+ INDEX(se_perfiles idx_perfiles)} idperfil FROM bdisitesp:se_perfiles WHERE idperfil = pClavePerfil AND empresa = pEmpresa) THEN
                    --Validamos que la descipcion no exista para otro registro
                    IF NOT EXISTS (SELECT {+ INDEX(se_perfiles idx_perfiles3)} descripcion FROM bdisitesp:se_perfiles WHERE descripcion = pDescripcionPerfil AND empresa = pEmpresa) THEN
                        --Obtener la fecha actual del servidor
                        SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
                        --Actualizamos el registro en caso de que exista
--create index "informix".idx_perfiles on "informix".se_perfiles (idperfil,empresa) using btree  in datos01 ;
                        UPDATE {+INDEX (se_perfiles idx_perfiles)} bdisitesp:se_perfiles
                        SET descripcion = pDescripcionPerfil,
                            usrmodifica = pUsuario,
                            fchmodifica = v_fecha_hoy,
                            idtipomov = pIdTipoMov
                        WHERE idperfil = pClavePerfil AND
                              empresa = pEmpresa;

                        RETURN v_codret;
                    ELSE
                        LET v_codret = '002';	--Ya existe un registro con la descripcion recibida
                        RETURN v_codret;
                    END IF;
				ELSE
					LET v_codret = '001';	--No existe el registro que desea actualizar
					RETURN v_codret;
				END IF;
			END IF;
		END IF;
	END;
END PROCEDURE;