CREATE PROCEDURE "informix".sp_guardarlogicasustitucion(
													   pEmpresa 			CHAR (3),
													   pSituacion			CHAR(1),
													   pCausa				INTEGER,
													   pSituacionSiguiente	CHAR(1),
													   pCausaSiguiente		INTEGER,
													   pUsuario				CHAR(8),
													   pTipoMovimiento		INTEGER --1.- Alta, 2.- Eliminacion
													  )

	RETURNING
	CHAR(6);  --cod retorno

	--Declaracion de variables
	DEFINE v_codret 	CHAR(6);
	DEFINE v_sqlerr 	INTEGER;

    DEFINE v_fecha_hoy  datetime year to second;

	DEFINE v_Situacion	CHAR(1);
	DEFINE v_Causa		INTEGER;
	DEFINE v_UsrAlta	CHAR(8);
    DEFINE v_FchAlta    datetime year to second;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

    --IF pCausa IS NULL THEN
    --    LET pCausa = 0;
    --END IF;
    --IF pTipoMovimiento IS NULL THEN
    --    LET pTipoMovimiento = 0;
    --END IF;
    --IF pCausaSiguiente IS NULL THEN
    --    LET pCausaSiguiente = 0;
    --END IF;

	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Guardar las altas y realizar eliminaciones en el catalogo de logica de sustitucion.

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_GuardarLogicaSustitucion.out';
	--trace on;

	    --checar valores nulos en los parametros
        IF ( pEmpresa = "" OR pEmpresa IS NULL ) OR ( pSituacion = "" OR pSituacion IS NULL ) OR ( pCausa = 0 OR pCausa IS NULL ) OR ( pTipoMovimiento = 0 OR pTipoMovimiento IS NULL ) OR ( pSituacionSiguiente = "" OR pSituacionSiguiente IS NULL ) OR ( pCausaSiguiente = 0 OR pCausaSiguiente IS NULL ) OR ( pUsuario = "" OR pUsuario IS NULL ) THEN
            LET v_codret = "999";   --Faltan parametros
	        RETURN v_codret;
	    ELSE
			--Seccion de codigo para realizar una alta en la logica de sustitucion
			IF pTipoMovimiento = 1 THEN
				IF NOT EXISTS (SELECT {+ INDEX(se_logicasustit idx_logicasustit)} situacion FROM bdisitesp:se_logicasustit WHERE empresa = pEmpresa AND situacion = pSituacion AND
									  causa = pCausa AND sitsiguente = pSituacionSiguiente AND causasiguiente = pCausaSiguiente) THEN
					--Obtener la fecha actual del servidor
                    SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
					--Seccion de codigo para dar de alta la situacion y causa que podra sustituir a una Situacion y Causa.
					INSERT INTO bdisitesp:se_logicasustit (situacion, causa, empresa, sitsiguente, causasiguiente,
														   usralta, fchalta, usrmodifica, fchmodifica)
					VALUES (pSituacion, pCausa, pEmpresa, pSituacionSiguiente, pCausaSiguiente, pUsuario, v_fecha_hoy, "", DATE(1));

					RETURN v_codret;
				ELSE
                    LET v_codret = "001";   --Ya existe el registro
					RETURN v_codret;
				END IF;
			--Seccion de codigo para realizar una eliminacion en la logica de sustitucion
			ELSE
				--Consultamos si ya existe un registro para la Situacion y Causa que vamos a modificar
				IF EXISTS (SELECT {+ INDEX(se_logicasustit idx_logicasustit)} situacion FROM bdisitesp:se_logicasustit WHERE empresa = pEmpresa AND situacion = pSituacion AND
								  causa = pCausa AND sitsiguente = pSituacionSiguiente AND causasiguiente = pCausaSiguiente) THEN
					--Eliminamos la Situacion y Causa que puede sustituir a la Situacion y Causa recibida en los parametros
                                 ---create index "informix".idx_logicasustit on "informix".se_logicasustit (situacion,causa,secuencia,empresa) using btree 
					DELETE {+INDEX (se_logicasustit idx_logicasustit)} FROM bdisitesp:se_logicasustit
					WHERE empresa = pEmpresa AND
						  situacion = pSituacion AND
						  causa = pCausa AND
						  sitsiguente = pSituacionSiguiente AND
						  causasiguiente = pCausaSiguiente;

					RETURN v_codret;
				ELSE
                    LET v_codret = "002";   --No existe el registro
					RETURN v_codret;
				END IF;
			END IF;
		END IF;
	END;
END PROCEDURE;