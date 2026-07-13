CREATE PROCEDURE "informix".sp_guardartipomarca(
											   pEmpresa 	CHAR (3),
											   pIdTipoMarca	INTEGER,
											   pDescripcion	CHAR(20),
											   pUsuario		CHAR(8)
											   )

	RETURNING CHAR(6);  --cod retorno

	--Definicion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;

    DEFINE v_fecha_hoy      datetime year to second;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

	IF pIdTipoMarca IS NULL THEN
		LET pIdTipoMarca = 0;
	END IF;
	IF pDescripcion <> "" THEN
		LET pDescripcion = UPPER(TRIM(pDescripcion));
	END IF;

	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Obtener los datos del tipo de marca

	--14-05-2009
	--Modifico:
	--Bernardo Báez
	--Se modifica para permitir guardar descripción existente para otro registro.

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_GuardarTipoMarca.out';
	--trace on;

	    --checar que los parametros de entrada esten completos
	    IF pEmpresa = "" OR pIdTipoMarca = 0 OR pDescripcion = "" OR pUsuario = "" THEN

	        LET v_codret = "999";	--Faltan parametros
	        RETURN v_codret;
	    ELSE
			--Obtener la fecha actual del servidor
            SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
			--Validar si el Id de tipo de marca ya existe en la tabla
			IF EXISTS(SELECT {+ INDEX(bdisitesp:se_setipomarca idx_setipomarca)} idtipomarca FROM bdisitesp:se_setipomarca WHERE idtipomarca = pIdTipoMarca AND empresa = pEmpresa) THEN
                --Validamos que la descipcion no exista para otro registro
                IF NOT EXISTS(SELECT {+ INDEX(bdisitesp:se_setipomarca idx_setipomarca)} descripcion FROM bdisitesp:se_setipomarca WHERE descripcion = pDescripcion AND empresa = pEmpresa) THEN
                    --Actualizar la informacion de la tabla con la modificacion
                    UPDATE bdisitesp:se_setipomarca
                    SET descripcion = pDescripcion, usrmodifica = pUsuario, fchmodifica = v_fecha_hoy
                    WHERE idtipomarca = pIdTipoMarca AND empresa = pEmpresa;

                    RETURN v_codret;
                ELSE
                    LET v_codret = "001"; --Ya existe un registro con la descripcion recibida
                    RETURN v_codret;
                END IF;
			ELSE
                --Validamos que la descipcion no exista para otro registro
                IF NOT EXISTS(SELECT {+ INDEX(bdisitesp:se_setipomarca idx_setipomarca)} descripcion FROM bdisitesp:se_setipomarca WHERE descripcion = pDescripcion AND empresa = pEmpresa) THEN
                    --Insertar el nuevo id tipo de marca en la tabla
                    INSERT INTO bdisitesp:se_setipomarca (empresa, descripcion, usralta,  fchalta, usrmodifica, fchmodifica)
                    VALUES (pEmpresa, pDescripcion, pUsuario, v_fecha_hoy, '', DATE(1));

                    RETURN v_codret;
                ELSE
                    LET v_codret = "001"; --Ya existe un registro con la descripcion recibida
                    RETURN v_codret;
                END IF;
			END IF
		END IF
	END;
END PROCEDURE;