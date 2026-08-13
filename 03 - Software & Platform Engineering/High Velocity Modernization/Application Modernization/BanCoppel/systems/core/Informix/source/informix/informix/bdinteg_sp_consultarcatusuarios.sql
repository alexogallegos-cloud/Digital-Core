CREATE PROCEDURE "informix".sp_consultarcatusuarios(p_sEmpresa CHAR(3), p_sSistema CHAR(2), p_sUsuario CHAR(10))
RETURNING CHAR(5) AS CodigoRetorno, CHAR(2) AS NumSistema, CHAR(10) AS Usuario, CHAR(20) AS Descripcion, CHAR(8) AS UsuarioInsert,
DATE AS FechaInsert;

        DEFINE iSqlErr                  INTEGER;
        DEFINE v_sCodRet                CHAR(5);

    DEFINE v_sSistema           CHAR(2);
    DEFINE v_sUsuario           CHAR(10);
    DEFINE v_sDescripcion       CHAR(20);
    DEFINE v_sUserInsert        CHAR(8);
    DEFINE v_dFechaInsert       DATE;

    BEGIN
        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET v_sCodRet = iSqlErr;
                        RETURN v_sCodRet, '', '', '', '', '';
                END IF;
        END EXCEPTION;

	   --set debug file to "/tmp/sp_consultarcatusuarios.out";
	    --trace on;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

        IF NVL(p_sEmpresa, '') = '' THEN
                LET v_sCodRet = '00001';
                RETURN v_sCodRet, '', '', '', '', '';
        END IF;

        IF NVL(p_sSistema, '') = '' THEN
                LET p_sSistema = NULL;
        END IF;

        IF NVL(p_sUsuario, '') = '' THEN
                LET p_sUsuario = NULL;
        END IF;

        FOREACH
        SELECT sistema, usuario, descripcion, usuario_insert, fecha_insert
        INTO v_sSistema, v_sUsuario, v_sDescripcion, v_sUserInsert, v_dFechaInsert
        FROM bdinteg:si_usuarios
        WHERE empresa = p_sEmpresa AND sistema = NVL(p_sSistema,sistema) AND usuario = NVL(p_sUsuario,usuario)

                LET v_sCodRet = '00000';
                RETURN v_sCodRet, v_sSistema, v_sUsuario, v_sDescripcion, v_sUserInsert, v_dFechaInsert WITH RESUME;
        END FOREACH;
    END
END PROCEDURE;