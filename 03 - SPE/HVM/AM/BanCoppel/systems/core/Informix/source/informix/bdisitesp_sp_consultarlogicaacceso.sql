CREATE PROCEDURE "informix".sp_consultarlogicaacceso(p_cempresa CHAR(3), p_se CHAR(1), p_causa INTEGER, p_carea CHAR(20))

    RETURNING CHAR(5) AS codigo, INTEGER AS perfil, CHAR(20) AS descripcion_perfil, INTEGER AS Marcacion, INTEGER AS Eliminacion, INTEGER AS Sustitucion;

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE v_cperfil            CHAR(20);
    DEFINE v_iperfil            INTEGER;
    DEFINE v_imarcaje           INTEGER;
	DEFINE v_ieliminacion		INTEGER;
	DEFINE v_isustitucion		INTEGER;

    LET vcCodRet = '000';
    LET v_iperfil = 0;
    LET v_cperfil = '';
    LET v_imarcaje = 0;
    LET v_ieliminacion = 0;
    LET v_isustitucion = 0;
    --*****************************************************
     -- Creado por Vladimir Felix Galvez    06/feb/2009         --*
     -- Debug del Procedure                             --*
     --SET DEBUG FILE TO "/tmp/walber/sp_consultarLogicaAcceso.out";--*
     --TRACE ON;                                       --*
    --*****************************************************

    BEGIN
        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet, v_iperfil, v_cperfil, v_imarcaje, v_ieliminacion, v_isustitucion;
        END EXCEPTION;

        IF ( p_cempresa IS NULL OR p_cempresa = '' ) AND ( p_se = '' OR p_se IS NULL ) AND ( p_causa IS NULL OR p_causa = 0 ) AND ( p_carea IS NULL OR p_carea = '' ) THEN
            LET vcCodRet = '999';
            RETURN vcCodRet, v_iperfil, v_cperfil, v_imarcaje, v_ieliminacion, v_isustitucion;
        ELSE
            IF EXISTS (SELECT {+INDEX (se_perfiles idx_perfiles)} * FROM bdisitesp:se_perfiles
                    WHERE empresa = p_cempresa) THEN
                --SE OBTIENEN TODOS LOS PERFILES CON SUS RESPECTIVOS MARCAJES POR SITUACION Y CAUSA, Y SE INSERTAN EN UNA TABLA TEMPORAL
                SELECT a.idperfil, NVL(a.descripcion,'') as descripcion,  NVL(b.idtipomov,'') as idtipomov,
                CASE WHEN b.idtipomov = 'M' THEN
                1
                ELSE 0
                END AS Marcacion,
                case WHEN b.idtipomov = 'E' THEN
                1
                ELSE 0
                END AS Eliminacion,
                CASE WHEN b.idtipomov = 'S' THEN
                1
                ELSE 0
                END AS Sustitucion
                FROM bdisitesp:se_perfiles a LEFT OUTER JOIN bdisitesp:se_logicaacceso  b
                ON (  a.idperfil = b.idperfil and a.empresa = b.empresa AND b.idtipomov in ('M','E','S') AND b.idarea = p_carea AND b.situacion = p_se AND b.causa = p_causa)
                WHERE a.empresa = TRIM(p_cempresa)
                INTO TEMP tmp_tabla;

                --SE BARRE LA TABLA TEMPORAL PARA REGRESAR TODOS LOS REGISTROS DE LA CONSULTA ANTERIOR
                FOREACH
                    SELECT idperfil, descripcion, SUM (Marcacion) AS Marcacion, SUM(Eliminacion) AS Eliminacion, SUM(Sustitucion) AS Sustitucion
                    INTO v_iperfil, v_cperfil, v_imarcaje, v_ieliminacion, v_isustitucion
                    FROM bdisitesp:tmp_tabla
                    GROUP BY idperfil, descripcion
                    ORDER BY idperfil

                    RETURN vcCodRet, v_iperfil, v_cperfil, v_imarcaje, v_ieliminacion, v_isustitucion WITH RESUME;

                END FOREACH;

                DROP TABLE bdisitesp:tmp_tabla;

            END IF;
         END IF;
    END;
END PROCEDURE;