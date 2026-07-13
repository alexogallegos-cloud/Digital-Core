CREATE PROCEDURE "informix".sp_consultarsecausa(pEmpresa CHAR(3), pSituacion CHAR(1), pCausa INTEGER, pFlagSoloSituaciones CHAR(1))

    RETURNING CHAR(5), CHAR(1), INTEGER, CHAR(75), CHAR(1), CHAR(1), CHAR(1), CHAR(5);

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE v_situacion CHAR(1);
    DEFINE v_cdescripcion   CHAR(75);
    DEFINE v_causa          INTEGER;
    DEFINE v_alcance        CHAR(1);
    DEFINE v_despliegue     CHAR(1);
    DEFINE v_vigente        CHAR(1);
    DEFINE v_cvecc          CHAR(5);

    LET vcCodRet = '000';
    LET viSqlErr = 0;
    LET v_situacion = '';
    LET v_cdescripcion = '';
    LET v_causa = 0;
    LET v_alcance    = '';
    LET v_despliegue = '';
    LET v_vigente    = '';
    LET v_cvecc      = '';
    --*****************************************************
     -- Creado por Walber Castro 19/Feb/2009
    --*****************************************************

    BEGIN

     ON EXCEPTION SET viSqlErr
        LET vcCodRet = viSqlErr;
        RETURN vcCodRet, v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc;
     END EXCEPTION;

     --SET DEBUG FILE TO "/respaldos/subedepaso/sp_consultarSECausa.out"; --*
     --TRACE ON;                                                    --*


     IF pSituacion is not null AND pSituacion <> ''  THEN
        IF pCausa is not null AND pCausa > 0 THEN
            FOREACH   --SE OBTIENEN LOS DATOS DE UNA SITUACION Y CAUSA EN ESPECIFICO
                SELECT {+INDEX (se_catsitesp  idx_catsitesp)} situacion, causa, descripcion, alcance, despliegue, vigente, cveccasociada
                INTO v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc
                FROM bdisitesp:se_catsitesp
                WHERE empresa = pEmpresa
                AND situacion = pSituacion
                AND causa = pCausa
                ORDER BY situacion, causa

                RETURN vcCodRet, v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc WITH RESUME;
            END FOREACH;
        ELSE
            FOREACH   --SE OBTIENEN LOS DATOS DE UNA SITUACION EN ESPECIFICO
                SELECT {+INDEX (se_catsitesp  idx_catsitesp)} situacion, causa, descripcion, alcance, despliegue, vigente, cveccasociada
                INTO v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc
                FROM bdisitesp:se_catsitesp
                WHERE empresa = pEmpresa
                AND situacion = pSituacion
                ORDER BY situacion, causa

                RETURN vcCodRet, v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc WITH RESUME;
            END FOREACH;
        END IF;
     ELSE
        IF pFlagSoloSituaciones is not null AND pFlagSoloSituaciones <> '' THEN
            FOREACH   --SE OBTIENEN TODAS LAS SITUACIONES ESPECIALES SOLAMENTE LA SITUACION
                SELECT {+INDEX (se_catsitesp idx_catsitesp2)} DISTINCT situacion
                INTO v_situacion
                FROM bdisitesp:se_catsitesp
                WHERE empresa = pEmpresa
                ORDER BY situacion

                RETURN vcCodRet, v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc WITH RESUME;
            END FOREACH;
        ELSE
            FOREACH   --SE OBTIENEN TODOS LOS DATOS DE LAS SITUACIONES ESPECIALES
                SELECT {+INDEX (se_catsitesp  idx_catsitesp)} situacion, causa, descripcion, alcance, despliegue, vigente, cveccasociada
                INTO v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc
                FROM bdisitesp:se_catsitesp
                WHERE empresa = pEmpresa
                ORDER BY situacion, causa

                RETURN vcCodRet, v_situacion, v_causa, v_cdescripcion, v_alcance, v_despliegue, v_vigente, v_cvecc WITH RESUME;
            END FOREACH;
        END IF;
     END IF;
    END;
END PROCEDURE;