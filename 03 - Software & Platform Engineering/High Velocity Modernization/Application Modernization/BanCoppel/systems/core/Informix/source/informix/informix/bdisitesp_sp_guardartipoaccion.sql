CREATE PROCEDURE "informix".sp_guardartipoaccion(
												pEmpresa 		CHAR(3),
												pIdAccion		INTEGER,
												pDescripcion	CHAR(40),
												pUsuario		CHAR(8)
											   )

	RETURNING CHAR(5); --cod retorno

	--Declaracion de variables
	DEFINE v_codret 		CHAR(5);
	DEFINE v_sqlerr 		INTEGER;

	DEFINE v_IdAccion		INTEGER;
	DEFINE v_Descripcion	CHAR(40);

    DEFINE v_fecha_hoy datetime year to second;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

    --IF pIdAccion IS NULL THEN
    --    LET pIdAccion = 0;
    --END IF;
    --IF pDescripcion IS NULL THEN
    --    LET pDescripcion = '';
    --ELSE
    --   LET pDescripcion = UPPER(TRIM(pDescripcion));
    --END IF;

	--***********************************
	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Obtener las posibles tipos de acciones.


	--13-05-2009
	--Modifico:
	--Abraham Ayala
	--Evitar que se guarden dos claves con la misma descripcion. 
	--***********************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_GuardarTipoAccion.out';
	--trace on;

	    --checar valores nulos en los parametros
        IF ( pEmpresa = "" OR pEmpresa IS NULL ) OR ( pDescripcion = '' OR pDescripcion IS NULL ) OR ( pIdAccion = 0 OR pIdAccion IS NULL ) OR ( pUsuario = '' OR pUsuario IS NULL ) THEN
			LET v_codret = '999';	--Faltan parametros
	        RETURN v_codret;
		ELSE
			--Obtener la fecha actual del servidor
            SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
			--Validamos si el registro existe
			IF EXISTS (SELECT {+ INDEX(bdisitesp:se_seaccdesenc idx_seaccdesenc)} idaccion FROM bdisitesp:se_seaccdesenc WHERE idaccion = pIdAccion) THEN
				--Si el registro existe lo actualizamos
				UPDATE bdisitesp:se_seaccdesenc
				SET descaccion = pDescripcion,
					usrmodifica = pUsuario,
					fchmodifica = v_fecha_hoy
				WHERE idaccion = pIdAccion AND
					  empresa = pEmpresa;
			ELSE
				IF NOT EXISTS (SELECT {+ INDEX(bdisitesp:se_seaccdesenc idx_seaccdesenc)} idaccion FROM bdisitesp:se_seaccdesenc WHERE descaccion = pDescripcion) THEN
					--Si el registro no existe insertamos uno nuevo
	                INSERT INTO bdisitesp:se_seaccdesenc (idaccion, empresa, descaccion, usralta, fchalta, usrmodifica, fchmodifica)
	                VALUES (pIdAccion, pEmpresa,pDescripcion, pUsuario, v_fecha_hoy, '', DATE(1));
				ELSE
					LET v_codret = '001';
					RETURN v_codret;
				END IF;
			END IF;

			RETURN v_codret;
		END IF;
	END;
END PROCEDURE;