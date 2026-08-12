CREATE PROCEDURE "informix".sp_guardarorigen(p_sEmpresa CHAR(3), p_iClaveSE char(12), p_sDescripcion CHAR(20), p_usuario char(8),p_iOpcion INTEGER)
        RETURNING CHAR(5) AS sValRetorno;

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE v_fecha_hoy  datetime year to second;

    LET vcCodRet = '000';
    LET viSqlErr = 0;

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 07/02/2009
	-- SET DEBUG FILE TO "/tmp/sp_guardarorigen.out";
	-- TRACE ON;
    -- permite guardar o modificar un registro de la tabla se_sitesporigen segun el parametro p_iOpcion recivido
    -- 4 para alta y 2 para modificacion
	--------------------------------------------------------------------------

	--------------------------------------------------------------------------
	-- Modificado por Bernardo Carlos Baez Gonzalez 07/02/2009
	-- Se modifica para adecuar a la nueva estructura de la tabla se_sitesporigen
	--Se modifica para que no repita descripciones 14/05/2009 por José Almeida
	--------------------------------------------------------------------------

	BEGIN
        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet;
        END EXCEPTION;

        IF ( p_sEmpresa <> '' AND p_sEmpresa IS NOT NULL ) AND ( p_iClaveSE <> '' AND p_iClaveSE IS NOT NULL ) AND ( p_sDescripcion <> '' AND p_sDescripcion IS NOT NULL ) AND ( p_iOpcion = 2 OR p_iOpcion = 4 ) AND ( p_usuario <> "" AND p_usuario IS NOT NULL ) THEN

            --Obtener la fecha actual del servidor
            SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = p_sEmpresa;

			IF p_iOpcion = 4 THEN --ALTA
                --VALIDA QUE EL REGISTRO NO EXISTA PARA HACER LA INSERCIÓN
                             IF NOT EXISTS (select {+ INDEX(bdisitesp:se_sitesporigen idx_sitesporigen)} descripcion from bdisitesp:se_sitesporigen WHERE empresa = p_sEmpresa AND cvesitesporigen = p_iClaveSE) then
                        IF NOT EXISTS (select {+ INDEX(bdisitesp:se_sitesporigen idx_sitesporigen)}descripcion from bdisitesp:se_sitesporigen WHERE descripcion = p_sDescripcion)   THEN
                    INSERT INTO bdisitesp:se_sitesporigen (cvesitesporigen, empresa, descripcion, usralta, fchalta, usrmodifica, fchmodifica)
                    VALUES (p_iClaveSE, p_sEmpresa, p_sDescripcion, p_usuario, v_fecha_hoy, '', DATE(1));
                ELSE
                    LET vcCodRet = '002';
                END IF;
                END IF;
                END IF;
			IF p_iOpcion = 2 THEN --MODIFICACION
                --VALIDA QUE EL REGISTRO EXISTA PARA HACER LA ACTUALIZACIÓN
                IF EXISTS (SELECT {+ INDEX(bdisitesp:se_sitesporigen idx_sitesporigen)} descripcion FROM bdisitesp:se_sitesporigen WHERE empresa = p_sEmpresa AND cvesitesporigen = p_iClaveSE) then
                IF NOT EXISTS (select {+ INDEX(bdisitesp:se_sitesporigen idx_sitesporigen)} descripcion from bdisitesp:se_sitesporigen WHERE descripcion = p_sDescripcion)   THEN
--create index "informix".idx_sitesporigen on "informix".se_sitesporigen (cvesitesporigen,descripcion) using btree
				UPDATE {+INDEX (se_sitesporigen idx_sitesporigen)} bdisitesp:se_sitesporigen
                        SET descripcion = p_sDescripcion, usrmodifica = p_usuario, fchmodifica = v_fecha_hoy
						WHERE empresa = p_sEmpresa AND cvesitesporigen = p_iClaveSE;
                ELSE
                    LET vcCodRet = '002';
                    END IF;
                END IF;
            END IF;
        ELSE
            LET vcCodRet = '999';
		END IF;

        RETURN vcCodRet;
    END;
END PROCEDURE;