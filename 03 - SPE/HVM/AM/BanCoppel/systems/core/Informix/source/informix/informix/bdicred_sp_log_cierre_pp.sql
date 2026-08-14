CREATE PROCEDURE "informix".sp_log_cierre_pp(pEmpresa    CHAR(3),
                                             pCodRet     CHAR(6),
                                             pNumCred    CHAR(20),
                                             pSecuencia  INTEGER,
                                             pFechAProc  DATE,
                                             pDescError  VARCHAR(200,1),
                                             pTasaInt    DECIMAL(9,6),
                                             pCapital    INTEGER,
                                             pDias       INTEGER,
                                             pInteres    INTEGER)

RETURNING CHAR(6), VARCHAR(125,1);

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(80);
DEFINE cCodRet                       CHAR(6);
DEFINE cMensajeRet                   VARCHAR(125,1);

LET cCodRet     = '000000';
LET cMensajeRet = 'Proceso Exitoso';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/log_cierre_pp.out";
--TRACE ON;

IF NVL(pEmpresa,'') = '' OR  NVL(pNumCred,'') = '' THEN
    LET cCodRet     = '000001';
    LET cMensajeRet = 'Error al ejecutar el proceso';
END IF;

SET ISOLATION TO DIRTY READ;

   INSERT INTO "informix".sd_valcierre (empresa, cod_ret, num_credito, secuencia, fecha_proc, desc_err, tasa_interes, capital, dias, interes)
        VALUES (pEmpresa, pCodRet, pNumCred, pSecuencia, pFechAProc, pDescError, pTasaInt, pCapital, pDias, pInteres);

   RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;