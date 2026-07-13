CREATE PROCEDURE "informix".sp_depura_sd_movhis_5()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6);
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;
DEFINE vFechaD      DATE;

DEFINE vCont        INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET fFecha       = DATE(1);
LET vFechaD      = DATE(1);
LET vCont        = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            ROLLBACK WORK;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

    -- Obtener Ãºltimo procesado
    SELECT num_credito
      INTO vNumCredAux
      FROM informix.sd_param_movhis_dep
     WHERE proceso = 5;

    IF vNumCredAux IS NULL THEN
        LET vNumCredAux = "";
        INSERT INTO informix.sd_param_movhis_dep VALUES (5,'');
    END IF;

    -- Fecha corte
    SELECT fecha_insert
      INTO fFecha
      FROM bdicred:sd_param
     WHERE empresa = '001'
       AND cod_param = '800';
	   
	LET fFecha = mdy(01,01,2024);

BEGIN WORK;
    FOREACH WITH HOLD

        SELECT num_credito, fecha_mov
          INTO vNumCred, vFechaD
          FROM bdicred:"informix".sd_movhis
         WHERE empresa = '001'
           AND fecha_mov < fFecha
         ORDER BY fecha_mov ASC


        INSERT INTO bdicred:sd_movhis_depura
        SELECT *
          FROM bdicred:sd_movhis
         WHERE empresa = '001'
           AND fecha_mov = vFechaD
           AND num_credito = vNumCred;

        DELETE FROM bdicred:sd_movhis
         WHERE empresa = '001'
           AND fecha_mov = vFechaD
           AND num_credito = vNumCred;

        LET vCont = vCont + 1;

        -- ð¥ COMMIT CADA 100 REGISTROS
        IF vCont >= 1000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vCont = 0;
        END IF;

    END FOREACH;

    COMMIT WORK;

    RETURN cCodRet;

END;

END PROCEDURE;