CREATE PROCEDURE "informix".sp_int_vigente_int_traspasado(P_EMPRESA        VARCHAR(3),
       P_FECHA_HOY      DATE,
       P_EJECUTIVO      VARCHAR(8)
      ) RETURNING VARCHAR(6), VARCHAR(80);

DEFINE P_COD_RET  VARCHAR(6);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE V_FUNCION           VARCHAR(3);

DEFINE V_EMPRESA           VARCHAR(3);
DEFINE V_NUM_CREDITO       VARCHAR(20);
DEFINE V_NUM_PRODUCTO      LIKE SD_MAECRED.NUM_PRODUCTO;
DEFINE V_SALDO_CUOTA       DECIMAL(18,2);
DEFINE V_SUCURSAL          LIKE SD_MAECRED.SUCURSAL;
DEFINE V_DIVISA            LIKE SD_MAECRED.DIVISA;

DEFINE V_SDO_NO_EXIG       DECIMAL(18,2);
DEFINE V_MTO_VENC_TRA_INT  DECIMAL(18,2);
DEFINE V_SDO_EXIG_INT      DECIMAL(18,2);
DEFINE V_NVO_SDO_NO_EXIG       DECIMAL(18,2);
DEFINE V_NVO_MTO_VENC_TRA_INT  DECIMAL(18,2);
DEFINE V_NVO_SDO_EXIG_INT      DECIMAL(18,2);

DEFINE  SQL_ERR            INTEGER;
DEFINE  ISAM_ERR           INTEGER;
DEFINE  ERROR_INFO         VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;

  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  LET V_FUNCION = '604';

  /* Traspaso de interés vigente a interés traspasado */
  /* STATUS_CUOTA:  1 a 2                             */
  SELECT P.EMPRESA,
         P.NUM_CREDITO,
         SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA
  FROM   SD_PAGINTER P
  WHERE  P.STATUS_CUOTA = '1'
  AND    P.FECHA_CUOTA  <= P_FECHA_HOY
  AND    P.EMPRESA      = P_EMPRESA
  AND    EXISTS (SELECT '1'
                 FROM   SD_MAECRED M
                 WHERE  M.EMPRESA     = P.EMPRESA
                 AND    M.NUM_CREDITO = P.NUM_CREDITO
                 AND    SUBSTR(M.STATUS_CRED, 2, 1) = 'T')
  GROUP BY P.EMPRESA, P.NUM_CREDITO
  INTO TEMP VALORES;

  FOREACH SELECT EMPRESA, NUM_CREDITO, SDO_NO_EXIG, MTO_VENC_TRA_INT, SDO_EXIG_INT
          INTO   V_EMPRESA, V_NUM_CREDITO, V_SDO_NO_EXIG, V_MTO_VENC_TRA_INT, V_SDO_EXIG_INT
          FROM   SD_MAESDOS S
          WHERE  EXISTS (SELECT '1'
                         FROM   SD_PAGINTER P1
                         WHERE  S.EMPRESA       = P1.EMPRESA
                         AND    S.NUM_CREDITO   = P1.NUM_CREDITO
                         AND    P1.FECHA_CUOTA  <= P_FECHA_HOY
                         AND    P1.EMPRESA      = P_EMPRESA
                         AND    P1.STATUS_CUOTA = '1'
                         AND    EXISTS (SELECT '1'
                                        FROM   SD_MAECRED  M1
                                        WHERE  M1.EMPRESA     = P1.EMPRESA
                                        AND    M1.NUM_CREDITO = P1.NUM_CREDITO
                                        AND    SUBSTR(M1.STATUS_CRED, 2, 1) = 'T'))
    SELECT V_SDO_NO_EXIG       - SALDO_CUOTA
         , V_MTO_VENC_TRA_INT  + SALDO_CUOTA
         , V_SDO_EXIG_INT      + SALDO_CUOTA
    INTO   V_NVO_SDO_NO_EXIG, V_NVO_MTO_VENC_TRA_INT, V_NVO_SDO_EXIG_INT
    FROM   VALORES
    WHERE  EMPRESA     = V_EMPRESA
    AND    NUM_CREDITO = V_NUM_CREDITO;

    UPDATE SD_MAESDOS 
       SET SDO_NO_EXIG       = V_NVO_SDO_NO_EXIG
         , MTO_VENC_TRA_INT  = V_NVO_MTO_VENC_TRA_INT
         , SDO_EXIG_INT      = V_NVO_SDO_EXIG_INT
    WHERE NUM_CREDITO = V_NUM_CREDITO
    AND EMPRESA = V_EMPRESA;
  END FOREACH;
  DROP TABLE VALORES;

  /* Aplica el movimiento contable */
  FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                (P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                 M.SUCURSAL, M.DIVISA
          INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO, V_SALDO_CUOTA
               , V_SUCURSAL, V_DIVISA
          FROM   SD_MAECRED M, SD_PAGINTER P
          WHERE  M.EMPRESA      = P.EMPRESA
          AND    M.NUM_CREDITO  = P.NUM_CREDITO
          AND    P.STATUS_CUOTA = '1'
          AND    P.FECHA_CUOTA <= P_FECHA_HOY
          AND    P.EMPRESA      = P_EMPRESA
          AND    SUBSTR(M.STATUS_CRED, 2, 1) = 'T'

    EXECUTE PROCEDURE SP_GENERA_MOVDIA (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO, V_NUM_PRODUCTO,
                                        V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNCION, V_SALDO_CUOTA
                                       ) INTO P_COD_RET, P_MENSAJE;

    IF P_COD_RET <> '00000' THEN
      RETURN P_COD_RET, P_MENSAJE;
    END IF;
  END FOREACH;

  IF P_COD_RET = '00000' THEN
    /* Actualiza status de cuotas de Pagos de Intereses */
    UPDATE SD_PAGINTER 
    SET    CUOTA_REC    = '1',
           STATUS_CUOTA = '2'
    WHERE  FECHA_CUOTA  <= P_FECHA_HOY
    AND    EMPRESA      = P_EMPRESA
    AND    STATUS_CUOTA = '1'
    AND    EXISTS (SELECT '1'
                   FROM   SD_MAECRED M
                   WHERE  M.EMPRESA     = SD_PAGINTER.EMPRESA
                   AND    M.NUM_CREDITO = SD_PAGINTER.NUM_CREDITO
                   AND    SUBSTR(M.STATUS_CRED, 2, 1) = 'T');
  END IF;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;