CREATE PROCEDURE "informix".sp_guardaracciondes(
											    pEmpresa 			CHAR (3),
											    pSituacion			CHAR(1),
											    pCausa				INTEGER,
											    pIdMarca			INTEGER,
											    pIdAccion			INTEGER,
											    pInstruccion		CHAR(1), --0.- Desactivada,  1.- Activada
											    pUsuario			CHAR(8)
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
	DEFINE v_FchAlta	DATE;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

    --IF pCausa IS NULL THEN
    --    LET pCausa = 0;
    --END IF;
    --IF pIdMarca IS NULL THEN
    --    LET pIdMarca = 0;
    --END IF;
    --IF pIdAccion IS NULL THEN
    --    LET pIdAccion = 0;
    --END IF;

	--*******************************************
	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Guardar las altas y modificaciones efectuadas.
	--*******************************************
    --20-04-2009
	--Realizo:
    --Walber Castro
    --Se suprime el filtro de tipo de marca para que sea modificable
    --asi como actualizar los campos de usuario modifico y fecha modificacion
    --solo cuando se haya cambiado algo.
    --*******************************************


	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

    --SET debug FILE TO '/respaldos/subedepaso/sp_GuardarAccionDesS.out';
    --trace ON;

	    --checar valores nulos en los parametros
        IF ( pEmpresa = "" OR pEmpresa IS NULL ) OR ( pSituacion = "" OR pSituacion IS NULL ) OR ( pCausa = 0 OR pCausa IS NULL ) OR ( pIdMarca = 0 OR pIdMarca IS NULL ) OR ( pIdAccion = 0 OR pIdAccion IS NULL ) OR ( pInstruccion = "" OR pInstruccion IS NULL ) OR ( pUsuario = "" OR pUsuario IS NULL ) THEN
            LET v_codret = "999";   --Faltan parametros
	        RETURN v_codret;
        ELSE
            --Obtener la fecha actual del servidor
            SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
			--Validamos si el registro existe

			IF EXISTS (SELECT situacion FROM bdisitesp:se_situacionaccion WHERE empresa = pEmpresa AND situacion = pSituacion AND
                                  causa = pCausa AND idaccion = pIdAccion) THEN

                IF EXISTS (SELECT situacion FROM bdisitesp:se_situacionaccion WHERE empresa = pEmpresa AND situacion = pSituacion AND
                                  causa = pCausa AND idaccion = pIdAccion AND (instruccion <> pInstruccion OR idtipomarca <> pIdMarca )) THEN
                        --Si existe actualizamos el registro con los nuevos datos
                    UPDATE bdisitesp:se_situacionaccion
                    SET instruccion = pInstruccion,
                        usrmodifica = pUsuario,
                        fchmodifica = v_fecha_hoy,
                        idtipomarca = pIdMarca
                    WHERE empresa = pEmpresa AND
                          situacion = pSituacion AND
                          causa = pCausa AND
                          idaccion = pIdAccion;

                END IF;

			ELSE	--Si no existe el registro
				--Insertamos el nuevo registro
				INSERT INTO bdisitesp:se_situacionaccion (
							situacion, causa, idaccion, empresa, idtipomarca,
							instruccion, usralta, fchalta, usrmodifica, fchmodifica)
				VALUES (pSituacion, pCausa, pIdAccion, pEmpresa, pIdMarca,
						pInstruccion, pUsuario, v_fecha_hoy, '', DATE(1));

			END IF;
            RETURN v_codret;
		END IF;
	END;
END PROCEDURE;