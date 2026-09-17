CREATE PROCEDURE "informix".sp_int_vencido_int_traspasado(P_EMPRESA        VARCHAR(3),
       P_FECHA_HOY      DATE,
       P_EJECUTIVO      VARCHAR(8)
      )RETURNING VARCHAR(6), VARCHAR(80);

DEFINE  P_COD_RET  VARCHAR(6);
DEFINE  P_MENSAJE  VARCHAR(80);

DEFINE  V_FUNCION       VARCHAR(3);
DEFINE  V_FUNCION7S     VARCHAR(3);
DEFINE  V_FUNCION1S     VARCHAR(3);
DEFINE  V_SALDO_CUOTA7  DECIMAL(18,2);
DEFINE  V_SALDO_CUOTA1  DECIMAL(18,2);

DEFINE  V1_EMPRESA          VARCHAR(3);
DEFINE  V1_NUM_CREDITO      VARCHAR(20);
DEFINE  V1_MTO_VENC         DECIMAL(18,2);
DEFINE  V1_MTO_VENC_TRA     DECIMAL(18,2);
DEFINE  V_NVO_MTO_VENC      DECIMAL(18,2);
DEFINE  V_NVO_MTO_VENC_TRA  DECIMAL(18,2);

DEFINE  V1_NUM_PRODUCTO    LIKE SD_MAECRED.NUM_PRODUCTO;
DEFINE  V1_SALDO_CUOTA     DECIMAL(18,2);
DEFINE  V1_FECHA_CUOTA     DATE;
DEFINE  V1_SUCURSAL        LIKE SD_MAECRED.SUCURSAL;
DEFINE  V1_DIVISA          LIKE SD_MAECRED.DIVISA;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;

  LET V_FUNCION       = '603';
  LET V_FUNCION7S     = '600';
  LET V_FUNCION1S     = '610';
  LET V_SALDO_CUOTA7  = 0;
  LET V_SALDO_CUOTA1  = 0;


  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';

  /* Traspaso de interés vencido (transitorio) a interés traspasado */
  /* STATUS_CUOTA:  7 a 2                                           */
      UPDATE SD_MAECRED
      SET    SD_MAECRED.STATUS_CRED = SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) || 'T'
      WHERE  EXISTS (SELECT '1'
                     FROM   SD_PAGINTER P
                     WHERE  SD_MAECRED.EMPRESA      = P.EMPRESA
                     AND    SD_MAECRED.NUM_CREDITO  = P.NUM_CREDITO
                     AND    P.FECHA_CUOTA <=
                            P_FECHA_HOY - nvl(SD_MAECRED.DIAS_TRASP_INT,0)
                     AND    P.EMPRESA      = P_EMPRESA
                     AND    P.STATUS_CUOTA = '7')
	AND SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) = "B";

      --SE CREA UNA TABLA TEMPORAL PARA CARGAR LOS REGISTROS QUE SERÁN ACTUALIZADOS
      SELECT P.EMPRESA, P.NUM_CREDITO, SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO
      FROM   SD_PAGINTER P
      WHERE  P.STATUS_CUOTA = '7'
      AND    EXISTS (SELECT '1'
                     FROM   SD_PAGINTER P1,
                            SD_MAECRED  M
                     WHERE  M.EMPRESA     = P1.EMPRESA
                     AND    M.NUM_CREDITO = P1.NUM_CREDITO
                     AND    P.EMPRESA     = P1.EMPRESA
                     AND    P.NUM_CREDITO = P1.NUM_CREDITO
                     AND    P1.FECHA_CUOTA <=
                            P_FECHA_HOY - nvl(M.DIAS_TRASP_INT,0)
                     AND    P1.EMPRESA      = P_EMPRESA
                     AND    P1.STATUS_CUOTA = '7')
      GROUP BY P.EMPRESA, P.NUM_CREDITO
      INTO TEMP VALORES;

      FOREACH SELECT SDO1.EMPRESA, SDO1.NUM_CREDITO
                    ,NVL(SDO1.MTO_VENC_INT,0), NVL(SDO1.MTO_VENC_TRA_INT,0)
              INTO   V1_EMPRESA, V1_NUM_CREDITO,V1_MTO_VENC,V1_MTO_VENC_TRA
              FROM   SD_MAESDOS SDO1
              WHERE  EXISTS (SELECT '1'
                             FROM   SD_PAGINTER P2
                             WHERE  SDO1.EMPRESA     = P2.EMPRESA
                             AND    SDO1.NUM_CREDITO = P2.NUM_CREDITO
                             AND    P2.STATUS_CUOTA  = '7'
                             AND    EXISTS (SELECT '1'
                                            FROM   SD_PAGINTER P3,
                                                   SD_MAECRED  M1
                                            WHERE  M1.EMPRESA     = P3.EMPRESA
                                            AND    M1.NUM_CREDITO = P3.NUM_CREDITO
                                            AND    P2.EMPRESA     = P3.EMPRESA
                                            AND    P2.NUM_CREDITO = P3.NUM_CREDITO
                                            AND    P3.FECHA_CUOTA <=
                                            P_FECHA_HOY - nvl(M1.DIAS_TRASP_INT,0)
                                            AND    P3.EMPRESA      = P_EMPRESA
                                            AND    P3.STATUS_CUOTA = '7'))
        SELECT V1_MTO_VENC     - VAL.SALDO
              ,V1_MTO_VENC_TRA + VAL.SALDO
        INTO   V_NVO_MTO_VENC
              ,V_NVO_MTO_VENC_TRA
        FROM   VALORES VAL
        WHERE  VAL.EMPRESA     = V1_EMPRESA
        AND    VAL.NUM_CREDITO = V1_NUM_CREDITO;

        UPDATE SD_MAESDOS SET MTO_VENC_INT     = V_NVO_MTO_VENC
                            , MTO_VENC_TRA_INT = V_NVO_MTO_VENC_TRA
        WHERE NUM_CREDITO = V1_NUM_CREDITO
        AND EMPRESA = V1_EMPRESA;
      END FOREACH;
      DROP TABLE VALORES;

      /* Aplica el movimiento contable y traspasa la cartera asociada */
      FOREACH  SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                      SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                      M.SUCURSAL, M.DIVISA
               INTO   V1_EMPRESA, V1_NUM_CREDITO, V1_NUM_PRODUCTO
                     ,V1_SALDO_CUOTA, V1_SUCURSAL, V1_DIVISA
               FROM   SD_MAECRED M,
                      SD_PAGINTER P
               WHERE  M.EMPRESA      = P.EMPRESA
               AND    M.NUM_CREDITO  = P.NUM_CREDITO
               AND    P.STATUS_CUOTA = '7'
               AND    EXISTS (SELECT '1'
                              FROM   SD_PAGINTER P0,
                                     SD_MAECRED  M1
                              WHERE  M1.EMPRESA     = P0.EMPRESA
                              AND    M1.NUM_CREDITO = P0.NUM_CREDITO
                              AND    P.EMPRESA      = P0.EMPRESA
                              AND    P.NUM_CREDITO  = P0.NUM_CREDITO
                              AND    P0.FECHA_CUOTA <= P_FECHA_HOY - nvl(M1.DIAS_TRASP_INT,0)
                              AND    P0.EMPRESA      = P_EMPRESA
                              AND    P0.STATUS_CUOTA = '7')
               GROUP BY P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO, M.SUCURSAL, M.DIVISA

        EXECUTE PROCEDURE SP_GENERA_MOVDIA (V1_EMPRESA, V1_NUM_CREDITO, P_EJECUTIVO,
                                            V1_NUM_PRODUCTO, V1_SUCURSAL, V1_DIVISA,
                                            P_FECHA_HOY, V_FUNCION, V1_SALDO_CUOTA
                                           )INTO  P_COD_RET, P_MENSAJE;   -- 603

        IF P_COD_RET <> '00000' THEN
           RETURN P_COD_RET, P_MENSAJE;
        END IF;

{
         /* Traspasa cartera asociada */
         SELECT NVL(SUM (P.SALDO_CUOTA - P.MONTO_REAL_PAG),0)
         INTO   V_SALDO_CUOTA7
         FROM   SD_PAGOCAPIT P
         WHERE  P.EMPRESA      = V1_EMPRESA
         AND    P.NUM_CREDITO  = V1_NUM_CREDITO
         AND    P.STATUS_CUOTA = '7';

         SELECT NVL(SUM (P.SALDO_CUOTA - P.MONTO_REAL_PAG),0)
         INTO   V_SALDO_CUOTA1
         FROM   SD_PAGOCAPIT P
         WHERE  P.EMPRESA      = V1_EMPRESA
         AND    P.NUM_CREDITO  = V1_NUM_CREDITO
         AND    P.STATUS_CUOTA = '1';

         /* Actualiza SD_MAESDOS por las cuotas de capital en STATUS 7 */
         UPDATE SD_MAESDOS
         SET    SD_MAESDOS.MONTO_VENCIDO  = SD_MAESDOS.MONTO_VENCIDO  - V_SALDO_CUOTA7,
                SD_MAESDOS.MTO_VENC_TRASP = SD_MAESDOS.MTO_VENC_TRASP + V_SALDO_CUOTA7
         WHERE  SD_MAESDOS.EMPRESA        = V1_EMPRESA
         AND    SD_MAESDOS.NUM_CREDITO    = V1_NUM_CREDITO;

         IF V_SALDO_CUOTA7 > 0 THEN
            /* Genera el movimiento diario por las cuotas de capital en status 7 */
            EXECUTE PROCEDURE SP_GENERA_MOVDIA (V1_EMPRESA, V1_NUM_CREDITO, P_EJECUTIVO,
                                                V1_NUM_PRODUCTO, V1_SUCURSAL, V1_DIVISA,
                                                P_FECHA_HOY, V_FUNCION7S, V_SALDO_CUOTA7
                                               ) INTO P_COD_RET, P_MENSAJE; -- 600
           IF P_COD_RET <> '00000' THEN
             RETURN P_COD_RET, P_MENSAJE;
           END IF;
         END IF;

         /* Actualiza status de cuotas de Pagos de Capital 7 a 2 */
         UPDATE SD_PAGOCAPIT
         SET    CUOTA_REC    = '7',
                STATUS_CUOTA = '2'
         WHERE  STATUS_CUOTA = '7'
         AND    EMPRESA     = V1_EMPRESA
         AND    NUM_CREDITO = V1_NUM_CREDITO;

         IF V_SALDO_CUOTA1 > 0 THEN
           /* Genera el movimiento diario por las cuotas de capital en status 1 */
           EXECUTE PROCEDURE SP_GENERA_MOVDIA (V1_EMPRESA,  V1_NUM_CREDITO, P_EJECUTIVO,
                                               V1_NUM_PRODUCTO, V1_SUCURSAL, V1_DIVISA,
                                               P_FECHA_HOY, V_FUNCION1S, V_SALDO_CUOTA1
                                              )INTO P_COD_RET, P_MENSAJE; -- 610
           IF P_COD_RET <> '00000' THEN
             RETURN P_COD_RET, P_MENSAJE;
           END IF;
         END IF;
}

      END FOREACH;

    IF P_COD_RET = '00000' THEN
         /* Actualiza status de cuotas de Pagos de Intereses 7 a 2 */
-- INICIO bloque anulado mmd/22/mar/05, se cambio por lo que esta a continuacion
--       FOREACH SELECT M.EMPRESA, M.NUM_CREDITO, P0.FECHA_CUOTA
--               INTO   V1_EMPRESA, V1_NUM_CREDITO, V1_FECHA_CUOTA
--               FROM   SD_PAGINTER P0,
--                      SD_MAECRED  M
--               WHERE  M.EMPRESA     = P0.EMPRESA
--               AND    M.NUM_CREDITO = P0.NUM_CREDITO
--               AND    P0.FECHA_CUOTA <= P_FECHA_HOY - NVL(M.DIAS_TRASP_INT,0)
--               AND    P0.EMPRESA      = P_EMPRESA
--               AND    P0.STATUS_CUOTA = '7'
-- FIN bloque anulado mmd/22/mar/05

         FOREACH SELECT EMPRESA, NUM_CREDITO, FECHA_CUOTA
                 INTO   V1_EMPRESA, V1_NUM_CREDITO, V1_FECHA_CUOTA
                 FROM   SD_PAGINTER P
                 WHERE  P.STATUS_CUOTA = '7'
                 AND    EXISTS (SELECT '1'
                           FROM   SD_PAGINTER P0, SD_MAECRED  M
                           WHERE  M.EMPRESA     = P0.EMPRESA
                           AND    M.NUM_CREDITO = P0.NUM_CREDITO
                           AND    P.EMPRESA     = P0.EMPRESA
                           AND    P.NUM_CREDITO = P0.NUM_CREDITO
                           AND    P0.FECHA_CUOTA <= P_FECHA_HOY
                                                 - NVL(M.DIAS_TRASP_CAP,0)
                           AND    P0.EMPRESA      = P_EMPRESA
                           AND    P0.STATUS_CUOTA = '7')
-- modif 23/03/05 mmd: Se agrego la siguiente instruccion para evitar cuotas
-- vencidas transitorias intercaladas en las cuotas vencidas traspasadas
                 ORDER BY EMPRESA, NUM_CREDITO, FECHA_CUOTA DESC

           UPDATE SD_PAGINTER
           SET    CUOTA_REC    = '7',
                  STATUS_CUOTA = '2'
           WHERE  STATUS_CUOTA = '7'
           AND    FECHA_CUOTA = V1_FECHA_CUOTA
           AND    EMPRESA     = V1_EMPRESA
           AND    NUM_CREDITO = V1_NUM_CREDITO;
         END FOREACH;
    ELSE
      RETURN P_COD_RET, P_MENSAJE;
    END IF;
    RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;