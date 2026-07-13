CREATE PROCEDURE "informix".sp_cap_vencido_cap_traspasado(P_EMPRESA        VARCHAR(3),
       P_FECHA_HOY      DATE,
       P_EJECUTIVO      VARCHAR(8)
      )RETURNING VARCHAR(6), VARCHAR(80);

DEFINE  P_COD_RET             VARCHAR(6);
DEFINE  P_MENSAJE             VARCHAR(80);
DEFINE  V_EMPRESA             VARCHAR(3);
DEFINE  V_NUM_CREDITO         VARCHAR(20); 
DEFINE  V_NUM_PRODUCTO        LIKE SD_MAECRED.NUM_PRODUCTO;
DEFINE  V_SALDO_CUOTA         DECIMAL(18,2);
DEFINE  V_SUCURSAL            LIKE SD_MAECRED.SUCURSAL;
DEFINE  V_DIVISA              LIKE SD_MAECRED.DIVISA;

DEFINE  V_FECHA_CUOTA          DATE;
DEFINE  V_MONTO_VENCIDO       DECIMAL(18,2);
DEFINE  V_MTO_VENC_TRASP      DECIMAL(18,2);
DEFINE  V_NVO_MONTO_VENCIDO   DECIMAL(18,2);
DEFINE  V_NVO_MTO_VENC_TRASP  DECIMAL(18,2);

DEFINE  V_FUNCION        VARCHAR(3);
DEFINE  V_FUNCION_1S     VARCHAR(3);
DEFINE  V_FUNCION_I7S    VARCHAR(3);
DEFINE  V_SALDO_CUOTA1   DECIMAL(18,2);
DEFINE  V_SALDO_CUOTA_I7 DECIMAL(18,2);

DEFINE  SQL_ERR        INTEGER;
DEFINE  ISAM_ERR       INTEGER;
DEFINE  ERROR_INFO     VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;

  LET V_FUNCION        = '600';
  LET V_FUNCION_1S     = '610';
  LET V_FUNCION_I7S    = '603';
  LET V_SALDO_CUOTA1   = 0;
  LET V_SALDO_CUOTA_I7 = 0;
  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';

  /* Traspaso de capital vencido (transitorio) a capital vencido traspasado */
  /* STATUS_CUOTA:  7 a 2                                                   */
     UPDATE SD_MAECRED 
     SET    SD_MAECRED.STATUS_CRED = SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) || 'T'
     WHERE  EXISTS (SELECT '1'
                     FROM   SD_PAGOCAPIT P
                     WHERE  SD_MAECRED.EMPRESA      = P.EMPRESA
                     AND    SD_MAECRED.NUM_CREDITO  = P.NUM_CREDITO
                     AND    P.FECHA_CUOTA <= P_FECHA_HOY - nvl(SD_MAECRED.DIAS_TRASP_CAP,0)
                     AND    P.EMPRESA      = P_EMPRESA
                     AND    P.STATUS_CUOTA = '7')
	AND SUBSTR(SD_MAECRED.STATUS_CRED, 1, 1) = "B";

     SELECT P.EMPRESA,
            P.NUM_CREDITO,
            SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA
     FROM   SD_PAGOCAPIT P
     WHERE  P.STATUS_CUOTA = '7'
     AND    EXISTS (SELECT '1'
                    FROM   SD_PAGOCAPIT P1,
                           SD_MAECRED  M
                    WHERE  M.EMPRESA     = P1.EMPRESA
                    AND    M.NUM_CREDITO = P1.NUM_CREDITO
                    AND    P.EMPRESA     = P1.EMPRESA
                    AND    P.NUM_CREDITO = P1.NUM_CREDITO
                    AND    P1.FECHA_CUOTA <=
                           P_FECHA_HOY - nvl(M.DIAS_TRASP_CAP,0)
                    AND    P1.EMPRESA      = P_EMPRESA
                    AND    P1.STATUS_CUOTA = '7')
     GROUP BY P.EMPRESA, P.NUM_CREDITO
     INTO TEMP VALORES;

     FOREACH SELECT EMPRESA, NUM_CREDITO, MONTO_VENCIDO, MTO_VENC_TRASP
             INTO   V_EMPRESA, V_NUM_CREDITO, V_MONTO_VENCIDO, V_MTO_VENC_TRASP
             FROM   SD_MAESDOS S
             WHERE  EXISTS (SELECT '1'
                            FROM   SD_PAGOCAPIT P2
                            WHERE  S.EMPRESA       = P2.EMPRESA
                            AND    S.NUM_CREDITO   = P2.NUM_CREDITO
                            AND    P2.STATUS_CUOTA = '7'
                            AND    EXISTS (SELECT '1'
                                           FROM   SD_PAGOCAPIT P3, SD_MAECRED  M1
                                           WHERE  M1.EMPRESA     = P3.EMPRESA
                                           AND    M1.NUM_CREDITO = P3.NUM_CREDITO
                                           AND    P2.EMPRESA     = P3.EMPRESA
                                           AND    P2.NUM_CREDITO = P3.NUM_CREDITO
                                           AND    P3.FECHA_CUOTA <=
                                                  P_FECHA_HOY - nvl(M1.DIAS_TRASP_CAP,0)
                                           AND    P3.EMPRESA      = P_EMPRESA
                                           AND    P3.STATUS_CUOTA = '7'))

       SELECT V_MONTO_VENCIDO  - SALDO_CUOTA
             ,V_MTO_VENC_TRASP + SALDO_CUOTA
       INTO   V_NVO_MONTO_VENCIDO, V_NVO_MTO_VENC_TRASP
       FROM   VALORES
       WHERE  EMPRESA     = V_EMPRESA
       AND    NUM_CREDITO = V_NUM_CREDITO;

       UPDATE SD_MAESDOS 
           SET MONTO_VENCIDO  = V_NVO_MONTO_VENCIDO
              ,MTO_VENC_TRASP = V_NVO_MTO_VENC_TRASP
       WHERE  NUM_CREDITO = V_NUM_CREDITO
       AND EMPRESA = V_EMPRESA;
     END FOREACH;
     DROP TABLE VALORES;

    /* Aplica el movimiento contable */
    FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                   SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                   M.SUCURSAL, M.DIVISA
            INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO, V_SALDO_CUOTA
                  ,V_SUCURSAL, V_DIVISA
            FROM   SD_MAECRED M, SD_PAGOCAPIT P
            WHERE  M.EMPRESA      = P.EMPRESA
            AND    M.NUM_CREDITO  = P.NUM_CREDITO
            AND    P.STATUS_CUOTA = '7'
            AND    EXISTS (SELECT '1'
                           FROM   SD_PAGOCAPIT P0, SD_MAECRED  M1
                           WHERE  M1.EMPRESA     = P0.EMPRESA
                           AND    M1.NUM_CREDITO = P0.NUM_CREDITO
                           AND    P.EMPRESA      = P0.EMPRESA
                           AND    P.NUM_CREDITO  = P0.NUM_CREDITO
                           AND    P0.FECHA_CUOTA <= 
                                  P_FECHA_HOY - nvl(M1.DIAS_TRASP_CAP,0)
                           AND    P0.EMPRESA      = P_EMPRESA
                           AND    P0.STATUS_CUOTA = '7')
            GROUP BY P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO, M.SUCURSAL, M.DIVISA

      EXECUTE PROCEDURE SP_GENERA_MOVDIA(V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO, V_NUM_PRODUCTO,
                                         V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNCION,
                                         V_SALDO_CUOTA
                                        )INTO P_COD_RET, P_MENSAJE; -- 600

      IF P_COD_RET <> '00000' THEN
           RETURN P_COD_RET, P_MENSAJE;
      END IF;
{
      /* Traspasa cartera asociada */
      SELECT NVL(SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG),0)
      INTO   V_SALDO_CUOTA1
      FROM   SD_PAGOCAPIT P
      WHERE  P.EMPRESA      = V_EMPRESA
      AND    P.NUM_CREDITO  = V_NUM_CREDITO
      AND    P.STATUS_CUOTA = '1';

      IF V_SALDO_CUOTA1 > 0 THEN
        EXECUTE PROCEDURE SP_GENERA_MOVDIA(V_EMPRESA,V_NUM_CREDITO,P_EJECUTIVO,V_NUM_PRODUCTO,
                                           V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNCION_1S,
                                           V_SALDO_CUOTA1
                                          )INTO P_COD_RET, P_MENSAJE; -- 610
        IF P_COD_RET <> '00000' THEN
           RETURN P_COD_RET, P_MENSAJE;
        END IF;
      END IF;

      /* Traspasa cuotas de interés en Status 7 a 2 */
      SELECT NVL(SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG),0)
      INTO   V_SALDO_CUOTA_I7
      FROM   SD_PAGINTER P
      WHERE  P.EMPRESA      = V_EMPRESA
      AND    P.NUM_CREDITO  = V_NUM_CREDITO
      AND    P.STATUS_CUOTA = '7';

      IF V_SALDO_CUOTA_I7 > 0 THEN

        EXECUTE PROCEDURE SP_GENERA_MOVDIA (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                                            V_NUM_PRODUCTO, V_SUCURSAL, V_DIVISA,
                                            P_FECHA_HOY, V_FUNCION_I7S, V_SALDO_CUOTA_I7
                                           ) INTO P_COD_RET, P_MENSAJE; -- 603
        IF P_COD_RET <> '00000' THEN
           RETURN P_COD_RET, P_MENSAJE;
        END IF;
      END IF;

      /* Actualiza SD_MAESDOS */
      UPDATE SD_MAESDOS
      SET    SD_MAESDOS.MTO_VENC_INT     = NVL(SD_MAESDOS.MTO_VENC_INT, 0) - V_SALDO_CUOTA_I7,
             SD_MAESDOS.MTO_VENC_TRA_INT = NVL(SD_MAESDOS.MTO_VENC_TRA_INT,0) + V_SALDO_CUOTA_I7
      WHERE  SD_MAESDOS.EMPRESA      = V_EMPRESA
      AND    SD_MAESDOS.NUM_CREDITO  = V_NUM_CREDITO;

      /* Traspasa cuotas en status 7 a 2 */
      UPDATE SD_PAGINTER
      SET    SD_PAGINTER.CUOTA_REC    = '7',
             SD_PAGINTER.STATUS_CUOTA = '2'
      WHERE  SD_PAGINTER.EMPRESA      = V_EMPRESA
      AND    SD_PAGINTER.NUM_CREDITO  = V_NUM_CREDITO
      AND    SD_PAGINTER.STATUS_CUOTA = '7';
}

    END FOREACH;

   IF P_COD_RET = '00000' THEN
    /* Actualiza status de cuotas de Pagos de Capital 7 a 2 */
    FOREACH SELECT EMPRESA, NUM_CREDITO, FECHA_CUOTA
            INTO   V_EMPRESA, V_NUM_CREDITO, V_FECHA_CUOTA
            FROM   SD_PAGOCAPIT P
            WHERE  P.STATUS_CUOTA = '7'
            AND    EXISTS (SELECT '1'
                           FROM   SD_PAGOCAPIT P0, SD_MAECRED  M
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

      UPDATE SD_PAGOCAPIT 
         SET CUOTA_REC    = '7',
             STATUS_CUOTA = '2'
      WHERE FECHA_CUOTA = V_FECHA_CUOTA
      AND NUM_CREDITO = V_NUM_CREDITO
      AND EMPRESA = V_EMPRESA;
    END FOREACH;
  END IF;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;