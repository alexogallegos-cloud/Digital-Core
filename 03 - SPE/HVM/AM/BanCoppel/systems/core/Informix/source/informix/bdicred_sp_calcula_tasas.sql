CREATE PROCEDURE "informix".sp_calcula_tasas(P_EMPRESA          VARCHAR(3),
       P_FECHA_HOY        DATE
      )RETURNING VARCHAR(6), VARCHAR(80);

DEFINE P_COD_RET  VARCHAR(6);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     ROLLBACK WORK;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;

  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';

  BEGIN WORK;
    /* ****** Calcula Tasa de Interes de créditos vigentes (no saldados ni vencidos)****** */
    UPDATE SD_MAECRED
    SET    TASA_INTERES = (
        SELECT /*+ ORDERED */
               DECODE(SD_MAECRED.FACTOR_SOBRETASA,
                      '+', F.VALOR + SD_MAECRED.SOBRETASA,
                      '-', F.VALOR - SD_MAECRED.SOBRETASA,
                      '*', F.VALOR * SD_MAECRED.SOBRETASA,
                           F.VALOR / SD_MAECRED.SOBRETASA)
        FROM   SD_REVTASA R,
               SI_TIPTASA T,
               SI_FECHAVALOR F
        WHERE  SD_MAECRED.EMPRESA          = R.EMPRESA
        AND    SD_MAECRED.NUM_CREDITO      = R.NUM_CREDITO
        AND    SD_MAECRED.EMPRESA          = T.EMPRESA
        AND    SD_MAECRED.COD_TASA_BASE    = T.TASA
        AND    T.EMPRESA                   = F.EMPRESA
        AND    T.TASA                      = F.TASA
        AND    T.RANGOFECHA                = 'F'
        AND    F.FECHA                     = P_FECHA_HOY
        AND    SD_MAECRED.TASA_FIJA_O_VAR  = '2'
        AND    SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
        AND    SD_MAECRED.BANDERA_MINISTRA = 'M'
        AND   (SD_MAECRED.REV_TASA_VAR_PER = '1'
               OR
               SD_MAECRED.DIA_PARA_REVISAR BETWEEN 1 AND 28
               OR
               SD_MAECRED.DIA_PARA_REVISAR IN (55,99)
               OR
               (SD_MAECRED.DIA_PARA_REVISAR = 88
                AND
                EXISTS (SELECT '1'
                        FROM   SD_PAGINTER P
                        WHERE  SD_MAECRED.EMPRESA     = P.EMPRESA
                        AND    SD_MAECRED.NUM_CREDITO = P.NUM_CREDITO
                        AND    P.FECHA_CUOTA          > P_FECHA_HOY  )))
        AND    R.FECHA_PROX_REV            = P_FECHA_HOY
        AND    R.EMPRESA                   = P_EMPRESA
        AND    SD_MAECRED.EMPRESA          = R.EMPRESA
        AND    SD_MAECRED.NUM_CREDITO      = R.NUM_CREDITO)
      WHERE EXISTS (SELECT '1'
                    FROM   SD_REVTASA R1
                    WHERE  SD_MAECRED.EMPRESA     = R1.EMPRESA
                    AND    SD_MAECRED.NUM_CREDITO = R1.NUM_CREDITO
                    AND    R1.FECHA_PROX_REV      = P_FECHA_HOY
                    AND    R1.EMPRESA             = P_EMPRESA)
      AND   SD_MAECRED.TASA_FIJA_O_VAR  = '2'
      AND   SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
      AND   SD_MAECRED.BANDERA_MINISTRA = 'M'
      AND   (SD_MAECRED.REV_TASA_VAR_PER = '1'
             OR
             SD_MAECRED.DIA_PARA_REVISAR BETWEEN 1 AND 28
             OR
             SD_MAECRED.DIA_PARA_REVISAR IN (55,99)
             OR
             (SD_MAECRED.DIA_PARA_REVISAR = 88
              AND
              EXISTS (SELECT '1'
                      FROM   SD_PAGINTER P
                      WHERE  SD_MAECRED.EMPRESA     = P.EMPRESA
                      AND    SD_MAECRED.NUM_CREDITO = P.NUM_CREDITO
                      AND    P.FECHA_CUOTA          > P_FECHA_HOY  )));

  COMMIT WORK;

  BEGIN WORK;
      /* ****** Calcula Tasa de Moratorios Libre para créditos no saldados ****** */
      UPDATE SD_MAECRED 
      SET    TASA_MORATORIOS = (
        SELECT /*+ ORDERED */
               DECODE(SD_MAECRED.FACT_SOBRET_MORA,
                      '+', F.VALOR + SD_MAECRED.SOBRETASA_MORA,
                      '-', F.VALOR - SD_MAECRED.SOBRETASA_MORA,
                      '*', F.VALOR * SD_MAECRED.SOBRETASA_MORA,
                           F.VALOR / SD_MAECRED.SOBRETASA_MORA)
        FROM   SD_REVTASA R,
               SI_TIPTASA T,
               SI_FECHAVALOR F
        WHERE  SD_MAECRED.EMPRESA         = R.EMPRESA
        AND    SD_MAECRED.NUM_CREDITO     = R.NUM_CREDITO
        AND    SD_MAECRED.EMPRESA         = T.EMPRESA
        AND    SD_MAECRED.COD_TASA_MORA   = T.TASA
        AND    T.EMPRESA         = F.EMPRESA
        AND    T.TASA            = F.TASA
        AND    T.RANGOFECHA      = 'F'
        AND    F.FECHA           = P_FECHA_HOY
        AND    SD_MAECRED.TASA_FIJA_O_VAR = '2'
        AND    SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
        AND    SD_MAECRED.BANDERA_MINISTRA = 'M'
        AND    SD_MAECRED.COD_TASA_MORA   <> 'ORDI'
        AND   (SD_MAECRED.REV_TASA_VAR_PER = '1'
               OR
               SD_MAECRED.DIA_PARA_REVISAR BETWEEN 1 AND 28
               OR
               SD_MAECRED.DIA_PARA_REVISAR IN (55,99)
               OR
               (SD_MAECRED.DIA_PARA_REVISAR = 88
                AND
                EXISTS (SELECT '1'
                        FROM   SD_PAGINTER P
                        WHERE  SD_MAECRED.EMPRESA     = P.EMPRESA
                        AND    SD_MAECRED.NUM_CREDITO = P.NUM_CREDITO
                        AND    P.FECHA_CUOTA  > P_FECHA_HOY  )))
        AND    R.FECHA_PROX_REV   = P_FECHA_HOY
        AND    R.EMPRESA          = P_EMPRESA
        AND    SD_MAECRED.EMPRESA         = R.EMPRESA
        AND    SD_MAECRED.NUM_CREDITO     = R.NUM_CREDITO)
      WHERE EXISTS (SELECT '1'
                    FROM   SD_REVTASA R1
                    WHERE  SD_MAECRED.EMPRESA         = R1.EMPRESA
                    AND    SD_MAECRED.NUM_CREDITO     = R1.NUM_CREDITO
                    AND    R1.FECHA_PROX_REV  = P_FECHA_HOY
                    AND    R1.EMPRESA         = P_EMPRESA)
      AND   SD_MAECRED.TASA_FIJA_O_VAR  = '2'
      AND   SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
      AND   SD_MAECRED.BANDERA_MINISTRA = 'M'
      AND   (SD_MAECRED.REV_TASA_VAR_PER = '1'
             OR
             SD_MAECRED.DIA_PARA_REVISAR BETWEEN 1 AND 28
             OR
             SD_MAECRED.DIA_PARA_REVISAR IN (55,99)
             OR
             (SD_MAECRED.DIA_PARA_REVISAR = 88
              AND
              EXISTS (SELECT '1'
                      FROM   SD_PAGINTER P
                      WHERE  SD_MAECRED.EMPRESA     = P.EMPRESA
                      AND    SD_MAECRED.NUM_CREDITO = P.NUM_CREDITO
                      AND    P.FECHA_CUOTA  > P_FECHA_HOY  )))
      AND   SD_MAECRED.COD_TASA_MORA    <> 'ORDI';

  COMMIT WORK;  

  BEGIN WORK;
      /* ****** Calcula tasa de moratorios ordinaria para créditos no saldados ****** */
      UPDATE SD_MAECRED 
      SET    TASA_MORATORIOS = (
        SELECT /*+ ORDERED */
               DECODE(SD_MAECRED.FACT_SOBRET_MORA,
                      '+', SD_MAECRED.TASA_INTERES + SD_MAECRED.SOBRETASA_MORA,
                      '-', SD_MAECRED.TASA_INTERES - SD_MAECRED.SOBRETASA_MORA,
                      '*', SD_MAECRED.TASA_INTERES * SD_MAECRED.SOBRETASA_MORA,
                           SD_MAECRED.TASA_INTERES / SD_MAECRED.SOBRETASA_MORA)
        FROM   SD_REVTASA R
        WHERE  SD_MAECRED.EMPRESA          = R.EMPRESA
        AND    SD_MAECRED.NUM_CREDITO      = R.NUM_CREDITO
        AND    SD_MAECRED.TASA_FIJA_O_VAR  = '2'
        AND    SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
        AND    SD_MAECRED.BANDERA_MINISTRA = 'M'
        AND    SD_MAECRED.COD_TASA_MORA    = 'ORDI'
        AND   (SD_MAECRED.REV_TASA_VAR_PER = '1'
               OR
               SD_MAECRED.DIA_PARA_REVISAR BETWEEN 1 AND 28
               OR
               SD_MAECRED.DIA_PARA_REVISAR IN (55,99)
               OR
               (SD_MAECRED.DIA_PARA_REVISAR = 88
                AND
                EXISTS (SELECT '1'
                        FROM   SD_PAGINTER P
                        WHERE  SD_MAECRED.EMPRESA     = P.EMPRESA
                        AND    SD_MAECRED.NUM_CREDITO = P.NUM_CREDITO
                        AND    P.FECHA_CUOTA  > P_FECHA_HOY  )))
        AND    R.FECHA_PROX_REV   = P_FECHA_HOY
        AND    R.EMPRESA          = P_EMPRESA
        AND    SD_MAECRED.EMPRESA         = R.EMPRESA
        AND    SD_MAECRED.NUM_CREDITO     = R.NUM_CREDITO)
      WHERE EXISTS (SELECT '1'
                    FROM   SD_REVTASA R1
                    WHERE  SD_MAECRED.EMPRESA         = R1.EMPRESA
                    AND    SD_MAECRED.NUM_CREDITO     = R1.NUM_CREDITO
                    AND    R1.FECHA_PROX_REV  = P_FECHA_HOY
                    AND    R1.EMPRESA         = P_EMPRESA)
      AND   SD_MAECRED.TASA_FIJA_O_VAR  = '2'
      AND   SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
      AND   SD_MAECRED.BANDERA_MINISTRA = 'M'
      AND   (SD_MAECRED.REV_TASA_VAR_PER = '1'
             OR
             SD_MAECRED.DIA_PARA_REVISAR BETWEEN 1 AND 28
             OR
             SD_MAECRED.DIA_PARA_REVISAR IN (55,99)
             OR
             (SD_MAECRED.DIA_PARA_REVISAR = 88
              AND
              EXISTS (SELECT '1'
                      FROM   SD_PAGINTER P
                      WHERE  SD_MAECRED.EMPRESA     = P.EMPRESA
                      AND    SD_MAECRED.NUM_CREDITO = P.NUM_CREDITO
                      AND    P.FECHA_CUOTA  > P_FECHA_HOY  )))
      AND   SD_MAECRED.COD_TASA_MORA    = 'ORDI';

  COMMIT WORK;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;