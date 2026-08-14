CREATE PROCEDURE "informix".sp_ftc_ipsftp(v_periodo CHAR(04))
       RETURNING CHAR (5), CHAR(100);

--MANEJO DE ERRORES
DEFINE iSqlErr                    INTEGER;
DEFINE cVarDataErr                CHAR(300);

--VARIABLE DE VALIDACION
DEFINE cCodRet                    CHAR(05);
DEFINE v_vlr_prm                  VARCHAR(100);

ON EXCEPTION SET iSqlErr

    SET DEBUG FILE TO "/fatca/sp_ftc_ipsftp.err";

    LET cVarDataErr = cVarDataErr ||
                          'ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
    LET cCodret='-1';

    RETURN cCodret, cVarDataErr;

END EXCEPTION;

--SET DEBUG FILE TO "sp_ftc_ipsftp.out";
--TRACE ON;

LET cVarDataErr = '';
LET v_vlr_prm = '';

--- VALIDACIÓN: IP CANAL SFTP --- 
SET ISOLATION TO DIRTY READ;

IF NOT EXISTS (SELECT a.valor
                 FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
                WHERE a.cve_param = b.cve_param
                  AND a.cve_param = 4
                  AND a.valor_param = '3') THEN

   LET cCodret = '00001';
   LET cVarDataErr = 'ERROR NO EXISTE IP PARA SFTP';
ELSE
   SELECT a.valor
     INTO v_vlr_prm
     FROM bdilide:sl_ftc_prm AS a, bdilide:sl_ftc_cat AS b
    WHERE a.cve_param = b.cve_param
      AND a.cve_param = 4
      AND a.valor_param = '3';

   LET cCodret = '00000';
   LET cVarDataErr = 'IP SFTP: '||v_vlr_prm;
END IF;

RETURN cCodRet, cVarDataErr;
END PROCEDURE;