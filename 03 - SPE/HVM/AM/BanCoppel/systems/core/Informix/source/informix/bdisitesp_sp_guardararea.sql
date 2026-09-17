CREATE PROCEDURE "informix".sp_guardararea(p_cempresa CHAR(3), p_iarea INTEGER, p_cdescripcion CHAR(50), p_usuario CHAR(8))

    RETURNING CHAR(5);

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE v_fecha_hoy  datetime year to second;

    LET vcCodRet = '000';
    LET viSqlErr = 0;
        --*************************************************************
    --Creado por Vladimir Felix Galvez      11/feb/2009             --*
    --Debug del Procedure                                           --*
    --SET DEBUG FILE TO "/respaldos/subedepaso/sp_AltaAreas.out";           --*
    --TRACE ON;                                                     --*
	--Se modifica para que no se repita descripcion  14/05/2009 por José Almeida
    --*************************************************************

    BEGIN
        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet;
        END EXCEPTION;

        --SE VALIDA QUE LOS PARAMETROS DE ENTRADA SEAN CORRECTOS
        IF ( p_cempresa <> "" AND p_cempresa IS NOT NULL ) AND ( p_iarea <> 0 AND p_iarea IS NOT NULL ) AND ( p_cdescripcion <> "" AND p_cdescripcion IS NOT NULL ) AND ( p_usuario <> "" AND p_usuario IS NOT NULL ) THEN

           --Obtener la fecha actual del servidor
           SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = p_cempresa;

            --VALIDA QUE EXISTA EL REGISTRO PARA REALIZAR LA ACTUALIZACIÓN
            IF EXISTS(SELECT {+ INDEX(se_areas idx_areas)} empresa FROM bdisitesp:se_areas WHERE idarea = p_iarea AND empresa = trim(p_cempresa)) THEN
                -- Se valida para no guardar una descripcion existente
                IF NOT EXISTS(SELECT {+ INDEX(se_areas idx_areas)} descripcion FROM bdisitesp:se_areas WHERE descripcion = trim(p_cdescripcion) )THEN 

                    UPDATE bdisitesp:se_areas
                    SET descripcion = p_cdescripcion, usrmodifica = p_usuario, fchmodifica = v_fecha_hoy
                    WHERE idarea = p_iarea AND empresa = trim(p_cempresa);

                ELSE
                    LET vcCodRet = '002';
             END IF;
            ELSE --SE REALIZA LA INSERCIÓN DEL NUEVO REGISTRO
            IF NOT EXISTS(SELECT {+ INDEX(se_areas idx_areas)} descripcion FROM bdisitesp:se_areas WHERE descripcion = trim(p_cdescripcion) )THEN 

                INSERT INTO bdisitesp:se_areas (empresa, idarea, descripcion, usralta,fchalta, usrmodifica, fchmodifica)
                VALUES (p_cempresa, p_iarea, p_cdescripcion, p_usuario, v_fecha_hoy,'',DATE(1));

                 ELSE
                    LET vcCodRet = '002';
             END IF;
            END IF;
        ELSE
            LET vcCodRet = '999';
        END IF;

        RETURN vcCodRet;

    END;
END PROCEDURE;