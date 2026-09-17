CREATE PROCEDURE "informix".sp_consultartipomarca(
											     pEmpresa 		CHAR (3),
											     pIdTipoMarca	INTEGER,
											     pDescripcion	CHAR(20)
											    )

	RETURNING
	CHAR(6),  --cod retorno
	INTEGER,  --IdTipoMarca
	CHAR(20); --Descripcion

	--Declaracion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;

	DEFINE v_IdTipoMarca	INTEGER;
	DEFINE v_Descripcion	CHAR(20);

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;
    LET v_IdTipoMarca = 0;
    LET v_Descripcion = '';

	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Obtener los datos del tipo de marca.

	IF pIdTipoMarca IS NULL THEN
		LET pIdTipoMarca = 0;
	END IF;
	IF pDescripcion <> "" THEN
		LET pDescripcion = UPPER(TRIM(pDescripcion));
	END IF;

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
                RETURN v_codret, v_IdTipoMarca, v_Descripcion;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_ConsultarTipoMarca.out';
	--trace on;

	    --checar valores nulos en los parametros
        IF pEmpresa = '' OR pEmpresa IS NULL THEN
	        LET v_codret = "999";	--Faltan parametros
            RETURN v_codret, v_IdTipoMarca, v_Descripcion;
	    ELSE
			--Seccion para consultar todos los datos
			IF pDescripcion = "" AND pIdTipoMarca = 0 THEN
				FOREACH
					SELECT {+INDEX (se_setipomarca idx_setipomarca)} idtipomarca, descripcion
            INTO v_IdTipoMarca, v_Descripcion 
            FROM bdisitesp:se_setipomarca 
           WHERE empresa = pEmpresa

					RETURN v_codret, v_IdTipoMarca, v_Descripcion WITH RESUME;
				END FOREACH;
			--Seccion para consultar solo por descripcion
			ELIF pDescripcion <> "" AND pIdTipoMarca = 0 THEN
				FOREACH
					SELECT {+INDEX (se_setipomarca idx_setipomarca)} idtipomarca, descripcion
            INTO v_IdTipoMarca, v_Descripcion
            FROM bdisitesp:se_setipomarca 
           WHERE empresa = pEmpresa AND
                           descripcion LIKE '%' || TRIM(pDescripcion) || '%'

					RETURN v_codret, v_IdTipoMarca, v_Descripcion WITH RESUME;
				END FOREACH;
			--Seccion para consultar por descripcion y tipo de marca
			ELIF pDescripcion <> "" AND pIdTipoMarca > 0 THEN
				FOREACH
					SELECT {+INDEX (se_setipomarca idx_setipomarca)} idtipomarca, descripcion
            INTO v_IdTipoMarca, v_Descripcion
            FROM bdisitesp:se_setipomarca
           WHERE empresa = pEmpresa AND
                           idtipomarca = pIdTipoMarca AND descripcion LIKE '%' || TRIM(pDescripcion) || '%'

					RETURN v_codret, v_IdTipoMarca, v_Descripcion WITH RESUME;
				END FOREACH;
			--Seccion para consultar por tipo de marca
			ELIF pDescripcion = "" AND pIdTipoMarca > 0 THEN
				FOREACH
					SELECT {+INDEX (se_setipomarca idx_setipomarca)} idtipomarca, descripcion
            INTO v_IdTipoMarca, v_Descripcion
            FROM bdisitesp:se_setipomarca 
           WHERE empresa = pEmpresa AND
						     idtipomarca = pIdTipoMarca

					RETURN v_codret, v_IdTipoMarca, v_Descripcion WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
	END;
END PROCEDURE;