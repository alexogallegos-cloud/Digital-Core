CREATE PROCEDURE "informix".sp_obtenersigfolio(p_cempresa CHAR(3), p_modulo CHAR(1) )

    RETURNING CHAR(5),INTEGER;

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE folio INTEGER;

    LET vcCodRet = '000';
    LET viSqlErr = 0;

    --**************************************************************
    --Creado por Walber Castro      18/feb/2009                  --*
    --Debug del Procedure                                        --*
    --El parametro p_modulo indica de que modulo se desea obtener--*
    --el siguiente folio, los valores serían:                    --*
    --1 - Areas                                                  --*
    --2 - Marcas                                                 --*
    --3 - Origenes                                               --*
    --4 - Perfiles                                               --*
    --5 - Tipo Accion                                            --*
    --**************************************************************

    BEGIN

        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet, folio;
        END EXCEPTION;

        LET folio = 0;

        IF ( p_cempresa <> "" AND NOT p_cempresa IS NULL ) OR ( p_modulo <> "" AND NOT p_modulo IS NULL ) THEN

            IF p_modulo = 1 THEN --AREAS
                --OBTIENE EL PROXIMO FOLIO DEL CATALOGO DE AREAS
                SELECT {+ INDEX(se_areas idx_areas)} NVL(MAX(idarea::INTEGER),0) + 1
				INTO folio
				FROM bdisitesp:se_areas
                WHERE empresa = trim(p_cempresa);

            ELIF p_modulo = 2 THEN --Id Tipo de Marca
                --OBTIENE EL PROXIMO FOLIO DEL CATALOGO DE MARCAS
                SELECT {+ INDEX(se_setipomarca idx_setipomarca)} NVL(MAX(idtipomarca::INTEGER), 0) + 1
				INTO folio
				FROM bdisitesp:se_setipomarca
                WHERE empresa = trim(p_cempresa);

            ELIF p_modulo = 3 THEN --ORIGENES
                --OBTIENE EL PROXIMO FOLIO DEL CATALOGO DE ORIGENES
                SELECT {+ INDEX(se_sitesporigen idx_sitesporigen)} NVL(MAX(cvesitesporigen::INTEGER), 0) + 1
				INTO folio
                FROM bdisitesp:se_sitesporigen
                WHERE empresa = trim(p_cempresa);

			ELIF p_modulo = 4 THEN
				--OBTIENE EL PROXIMO FOLIO DEL CATALOGO DE PERFILES
                SELECT {+ INDEX(se_perfiles idx_perfiles)} NVL(MAX(idperfil::INTEGER), 0) + 1
				INTO folio
                FROM bdisitesp:se_perfiles
                WHERE empresa = trim(p_cempresa);

			ELIF p_modulo = 5 THEN
				--OBTIENE EL PROXIMO FOLIO DEL CATALOGO TIPO DE ACCION
                SELECT {+ INDEX(se_seaccdesenc idx_seaccdesenc)} NVL(MAX(idaccion::INTEGER), 0) + 1
				INTO folio
                FROM bdisitesp:se_seaccdesenc
                WHERE empresa = trim(p_cempresa);
			END IF;
        ELSE
            LET vcCodRet = '999';
        END IF;

        RETURN vcCodRet, folio;

    END;
END PROCEDURE;