CREATE PROCEDURE "informix".sp_consultarareas(p_cempresa CHAR(3), p_iarea INTEGER, p_cdescripcion CHAR(50))

    RETURNING CHAR(5) AS codigo, INTEGER AS area, CHAR(3) AS empresa, CHAR(50) AS descripcion_area;

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
	DEFINE v_cdescripcion	CHAR(50);
	DEFINE v_iarea			INTEGER;

    LET vcCodRet = '000';
    LET viSqlErr = 0;
	--*****************************************************
	 -- Creado por Vladimir Felix Galvez    11/feb/2009				--*
	 -- Debug del Procedure											--*
     -- Modificó: Walber Castro 19/Feb/2009
     -- Descripción: Se cambio la bd.
     --SET DEBUG FILE TO "/tmp/walber/sp_consultarAreas.out"; --*
     --TRACE ON;                                                    --*
	--*****************************************************

	BEGIN

     ON EXCEPTION SET viSqlErr
        LET vcCodRet = viSqlErr;
        RETURN vcCodRet, v_iarea, p_cempresa, v_cdescripcion;
     END EXCEPTION;

        IF ( p_iarea is null OR p_iarea = '' ) AND ( p_cdescripcion = '' OR p_cdescripcion is null ) THEN

            FOREACH --SE OBTIENEN TODAS LAS AREAS DEL CATALOGO
                SELECT {+INDEX (se_areas idx_areas)} idarea, descripcion
				INTO v_iarea, v_cdescripcion
                FROM bdisitesp:se_areas
				WHERE empresa = p_cempresa

                RETURN vcCodRet, v_iarea, p_cempresa, v_cdescripcion WITH RESUME;
			END FOREACH;

        ELIF p_iarea is not null AND ( p_cdescripcion = '' OR p_cdescripcion is null ) THEN

            FOREACH --SE OBTIENE LA DESCRIPCION DE UN AREA EN ESPECIFICO
                SELECT {+INDEX (se_areas idx_areas)} idarea, descripcion
                INTO v_iarea, v_cdescripcion
                FROM bdisitesp:se_areas
                WHERE empresa = p_cempresa
                AND idarea = p_iarea

                RETURN vcCodRet, v_iarea, p_cempresa, v_cdescripcion WITH RESUME;
            END FOREACH;

        ELIF ( p_iarea is null OR p_iarea = '' ) AND ( p_cdescripcion <> '' OR NOT p_cdescripcion is null ) THEN

            FOREACH --SE OBTIENEN TODAS LAS AREAS DE ACUERDO AL CRITERIO DE BUSQUEDA DE DESCRIPCION
                SELECT {+INDEX (se_areas idx_areas)} idarea, descripcion
                INTO v_iarea, v_cdescripcion
                FROM bdisitesp:se_areas
                WHERE empresa = p_cempresa
                AND descripcion LIKE '%' || TRIM(p_cdescripcion) || '%'

                RETURN vcCodRet, v_iarea, p_cempresa, v_cdescripcion WITH RESUME;
            END FOREACH;

        ELSE
            FOREACH --SE OBTIENEN TODAS LAS AREAS DE ACUERDO AL CRITERIO DE BUSQUEDA DE DESCRIPCION
                SELECT {+INDEX (se_areas idx_areas)} idarea, descripcion
                INTO v_iarea, v_cdescripcion
                FROM bdisitesp:se_areas
                WHERE empresa = p_cempresa
                AND idarea = p_iarea
                AND descripcion LIKE '%' || TRIM(p_cdescripcion) || '%'

                RETURN vcCodRet, v_iarea, p_cempresa, v_cdescripcion WITH RESUME;
            END FOREACH;
		END IF;
	END;
END PROCEDURE;