CREATE PROCEDURE "informix".dia_habil(p_fecha_inicio   DATE,
                           p_ajuste_vencim  CHAR(1),
                           p_sucursal       CHAR(4))
       RETURNING CHAR(5), DATE;

   DEFINE GLOBAL g_empresa            CHAR(3)        DEFAULT " ";
   DEFINE v_bandera            SMALLINT;
   DEFINE v_continua           SMALLINT;
   DEFINE sql_err              SMALLINT;
   DEFINE isam_err             SMALLINT;
   DEFINE error_info           CHAR(40);
   DEFINE wbegin               CHAR(1);
   DEFINE v_codret             CHAR(5);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET v_codret = sql_err;
      SET DEBUG FILE TO "dia_habil.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      RETURN v_codret, p_fecha_inicio;
   END EXCEPTION;


   LET v_codret       = "000";
   IF p_ajuste_vencim <> "S" THEN
      IF p_ajuste_vencim <> "P" THEN
         RETURN v_codret, p_fecha_inicio;
      END IF;
   END IF ;
   IF p_ajuste_vencim IS NULL THEN
      LET p_ajuste_vencim = "P";
   END IF;
 
 
   LET v_bandera = 0;
   LET v_continua= 1;

   WHILE v_continua = 1
      IF WEEKDAY(p_fecha_inicio) = 6 OR   -- Sabado
         WEEKDAY(p_fecha_inicio) = 0 THEN -- Domingo
         LET v_bandera = 1;
      ELSE
         LET v_bandera = 0;
      END IF;

      IF v_bandera = 0 THEN
         SELECT COUNT(*) INTO v_bandera FROM bdinteg:si_feriado
         WHERE fecha = p_fecha_inicio
         AND empresa = g_empresa;

         IF v_bandera = 0 OR v_bandera IS NULL THEN
            SELECT count(*) INTO v_bandera FROM bdinteg:si_feriadsuc
            WHERE sucursal = p_sucursal
            AND   empresa  = g_empresa
            AND   fecha = p_fecha_inicio;
            IF v_bandera = 0 OR v_bandera IS NULL THEN
               EXIT WHILE;
            END IF;
         END IF;
      END IF;

      IF v_bandera = 1 THEN
         -- ajusta al v_fecha_inicio habil siguiente
         IF p_ajuste_vencim = "S" THEN
           LET p_fecha_inicio = p_fecha_inicio + 1 UNITS DAY;
         END IF;

         -- ajusta al v_fecha_inicio habil previo
         IF p_ajuste_vencim = "P" THEN
            LET p_fecha_inicio = p_fecha_inicio - 1 UNITS DAY;
         END IF ;
      END IF;
   END WHILE;
   RETURN v_codret, p_fecha_inicio;
END PROCEDURE

DOCUMENT
"spl para encontrar la fecha proxima habil o previa habil segun el  ",
"parametro recibido P=previo, S=siguiente y N=no ajusta  ",
"base de datos: bdicred",
"AUTOR : Jose Cruz Narvaez Guzman",
"FECHA : 19/abril/2001",
"Ver.  : 1.0",
"Mod   : ";

CREATE PROCEDURE "informix".sp_trasp_cart_venc_x_cred(P_EMPRESA          VARCHAR(3),
       P_NUM_CREDITO      VARCHAR(20),
       P_FECHA_HOY        DATE,
       P_EJECUTIVO        VARCHAR(8)
      ) RETURNING VARCHAR(5), VARCHAR(80);

DEFINE P_COD_RET              VARCHAR(5);
DEFINE P_MENSAJE              VARCHAR(80);

DEFINE V_EMPRESA              VARCHAR(3);
DEFINE V_NUM_CREDITO          VARCHAR(20);
DEFINE V_NUM_PRODUCTO         VARCHAR(4);
DEFINE V_SALDO_CUOTA          DECIMAL(18,2);
DEFINE V_SUCURSAL             VARCHAR(4);
DEFINE V_DIVISA               VARCHAR(4);
DEFINE V_FECHA_CUOTA          DATE;

DEFINE V_FUNCION              VARCHAR(3);
DEFINE V_FUNC_C1S             VARCHAR(3);
DEFINE V_FUNC_C7S             VARCHAR(3);
DEFINE V_FUNC_I7S             VARCHAR(3);
DEFINE V_SALDO_CUOTA7         DECIMAL(18,2);
DEFINE V_SALDO_CUOTA1         DECIMAL(18,2);

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
  LET V_FUNC_C1S      = '610';
  LET V_FUNC_C7S      = '600';
  LET V_FUNC_I7S      = '603';
  LET V_SALDO_CUOTA7  = 0;
  LET V_SALDO_CUOTA1  = 0;

      /* Paso de interés vencido (transitorio) a interés vencido traspasado */
      /* Traspaso de interés vencido (transitorio) a interés traspasado */
      /* STATUS_CUOTA:  7 a 2                                           */

      LET P_COD_RET = '00000';
      LET P_MENSAJE = 'PROCESO EXITOSO';

      UPDATE SD_MAECRED
      SET    SD_MAECRED.STATUS_CRED = 'T' || SUBSTR(SD_MAECRED.STATUS_CRED, 2, 1)
      WHERE  EXISTS (SELECT 'A'
                     FROM   SD_PAGINTER P
                     WHERE  SD_MAECRED.EMPRESA      = P.EMPRESA
                     AND    SD_MAECRED.NUM_CREDITO  = P.NUM_CREDITO
                     AND    P.FECHA_CUOTA          <= P_FECHA_HOY - nvl(SD_MAECRED.DIAS_TRASP_INT,0)
                     AND    P.EMPRESA               = P_EMPRESA
                     AND    P.NUM_CREDITO           = P_NUM_CREDITO
                     AND    P.STATUS_CUOTA          = '7');

      FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, SUM(P.MONTO_CUOTA-P.MONTO_REAL_PAG) SALDO_CUOTA
              INTO   V_EMPRESA, V_NUM_CREDITO, V_SALDO_CUOTA
              FROM   SD_PAGINTER P, SD_MAECRED M
              WHERE  P.STATUS_CUOTA = '7'
              AND    P.FECHA_CUOTA  <= TODAY-NVL(M.DIAS_TRASP_INT,0)
              AND    P.EMPRESA      = M.EMPRESA
              AND    P.NUM_CREDITO  = M.NUM_CREDITO
              AND    M.EMPRESA      = P_EMPRESA
              AND    M.NUM_CREDITO  = P_NUM_CREDITO
              GROUP BY P.EMPRESA, P.NUM_CREDITO

         UPDATE SD_MAESDOS
         SET    MTO_VENC_INT      = NVL(MTO_VENC_INT, 0) - V_SALDO_CUOTA
              , MTO_VENC_TRA_INT  = NVL(MTO_VENC_TRA_INT, 0) + V_SALDO_CUOTA
         WHERE  EMPRESA     = V_EMPRESA
         AND    NUM_CREDITO = V_NUM_CREDITO;

      END FOREACH;

      /* Aplica el movimiento contable */
      -- INT 7 A 2
      FOREACH  SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                      SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                      M.SUCURSAL, M.DIVISA
               INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO,
                      V_SALDO_CUOTA, V_SUCURSAL, V_DIVISA
               FROM   SD_MAECRED M,
                      SD_PAGINTER P
               WHERE  M.EMPRESA      = P.EMPRESA
               AND    M.NUM_CREDITO  = P.NUM_CREDITO
               AND    P.FECHA_CUOTA <= P_FECHA_HOY - nvl(M.DIAS_TRASP_INT,0)
               AND    P.STATUS_CUOTA = '7'
               AND    P.EMPRESA      = P_EMPRESA
               AND    P.NUM_CREDITO  = P_NUM_CREDITO
               GROUP BY P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO, M.SUCURSAL, M.DIVISA

         EXECUTE PROCEDURE SP_GENERA_MOVDIA
                          (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO, V_NUM_PRODUCTO,
                           V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNCION,
                           V_SALDO_CUOTA
                          ) INTO P_COD_RET, P_MENSAJE;

         IF P_COD_RET <> '00000' THEN
            EXIT FOREACH;
         END IF;

         /* Traspasa cartera asociada */
         SELECT NVL(SUM (P.SALDO_CUOTA - P.MONTO_REAL_PAG),0)
         INTO   V_SALDO_CUOTA7
         FROM   SD_PAGOCAPIT P
         WHERE  P.EMPRESA      = V_EMPRESA
         AND    P.NUM_CREDITO  = V_NUM_CREDITO
         AND    P.STATUS_CUOTA = '7';

         SELECT NVL(SUM (P.SALDO_CUOTA - P.MONTO_REAL_PAG),0)
         INTO   V_SALDO_CUOTA1
         FROM   SD_PAGOCAPIT P
         WHERE  P.EMPRESA      = V_EMPRESA
         AND    P.NUM_CREDITO  = V_NUM_CREDITO
         AND    P.STATUS_CUOTA = '1';

         /* Actualiza SD_MAESDOS por las cuotas de capital en STATUS 7 */
         UPDATE SD_MAESDOS
         SET    MONTO_VENCIDO  = MONTO_VENCIDO  - V_SALDO_CUOTA7,
                MTO_VENC_TRASP = MTO_VENC_TRASP + V_SALDO_CUOTA7
         WHERE  EMPRESA        = V_EMPRESA
         AND    NUM_CREDITO    = V_NUM_CREDITO;

         IF V_SALDO_CUOTA7 > 0 THEN

            /* Genera el movimiento diario por las cuotas de capital en status 7 */
            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                          (V_EMPRESA,  V_NUM_CREDITO, P_EJECUTIVO, V_NUM_PRODUCTO,
                           V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNC_C7S,
                           V_SALDO_CUOTA7
                          ) INTO P_COD_RET, P_MENSAJE; -- 600

            IF P_COD_RET <> '00000' THEN
               EXIT FOREACH;
            END IF;
         END IF;

         /* Actualiza status de cuotas de Pagos de Capital 7 a 2 */
         UPDATE SD_PAGOCAPIT
         SET    CUOTA_REC    = '7',
                STATUS_CUOTA = '2'
         WHERE  STATUS_CUOTA = '7'
         AND    EMPRESA     = V_EMPRESA
         AND    NUM_CREDITO = V_NUM_CREDITO;

         IF V_SALDO_CUOTA1 > 0 THEN

            /* Genera el movimiento diario por las cuotas de capital en status 1 */
            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                          (V_EMPRESA,  V_NUM_CREDITO, P_EJECUTIVO, V_NUM_PRODUCTO,
                           V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNC_C1S,
                           V_SALDO_CUOTA1
                          ) INTO P_COD_RET, P_MENSAJE; -- 610

            IF P_COD_RET <> '00000' THEN
               EXIT FOREACH;
            END IF;
         END IF;
      END FOREACH;

      IF P_COD_RET = '00000' THEN
         /* Actualiza status de cuotas de Pagos de Intereses */
         FOREACH SELECT FECHA_CUOTA
                 INTO   V_FECHA_CUOTA
                 FROM   SD_PAGINTER P0,
                        SD_MAECRED  M
                 WHERE  M.EMPRESA     = P0.EMPRESA
                 AND    M.NUM_CREDITO = P0.NUM_CREDITO
                 AND    P0.FECHA_CUOTA <= P_FECHA_HOY - NVL(M.DIAS_TRASP_INT,0)
                 AND    P0.EMPRESA      = P_EMPRESA
                 AND    P0.NUM_CREDITO  = P_NUM_CREDITO
                 AND    P0.STATUS_CUOTA = '7'

            UPDATE SD_PAGINTER
            SET    CUOTA_REC    = '7',
                   STATUS_CUOTA = '2'
            WHERE  STATUS_CUOTA = '7'
            AND    FECHA_CUOTA = V_FECHA_CUOTA
            AND    NUM_CREDITO = P_NUM_CREDITO
            AND    EMPRESA     = P_EMPRESA;

         END FOREACH;
      END IF;

      IF P_COD_RET = '00000' THEN

         /* Paso de interés vigente a interés vencido traspasado */
         /* Traspaso de interés vigente a interés traspasado */
         /* STATUS_CUOTA:  1 a 2                             */

         LET V_FUNCION = '604';

         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, SUM(P.MONTO_CUOTA-P.MONTO_REAL_PAG) SALDO_CUOTA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_SALDO_CUOTA
                 FROM   SD_PAGINTER P, SD_MAECRED M
                 WHERE  P.STATUS_CUOTA = '1'
                 AND    P.EMPRESA      = M.EMPRESA
                 AND    P.NUM_CREDITO  = M.NUM_CREDITO
                 AND    SUBSTR(M.STATUS_CRED,1,1) = 'T'
                 AND    M.EMPRESA      = P_EMPRESA
                 AND    M.NUM_CREDITO  = P_NUM_CREDITO
                 GROUP BY P.EMPRESA, P.NUM_CREDITO

            UPDATE SD_MAESDOS
            SET SDO_NO_EXIG      = SDO_NO_EXIG - V_SALDO_CUOTA
              , MTO_VENC_TRA_INT = NVL(MTO_VENC_TRA_INT, 0) + V_SALDO_CUOTA
              , SDO_EXIG_INT     = SDO_EXIG_INT + V_SALDO_CUOTA
            WHERE EMPRESA     = V_EMPRESA
            AND   NUM_CREDITO = V_NUM_CREDITO;

         END FOREACH;

         /* Aplica el movimiento contable */
         -- INT 1 A 2
         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                        (P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                        M.SUCURSAL, M.DIVISA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO,
                        V_SALDO_CUOTA, V_SUCURSAL, V_DIVISA
                 FROM   SD_MAECRED M,
                        SD_PAGINTER P
                 WHERE  M.EMPRESA      = P.EMPRESA
                 AND    M.NUM_CREDITO  = P.NUM_CREDITO
                 AND    P.STATUS_CUOTA = '1'
                 AND    P.FECHA_CUOTA  = P_FECHA_HOY
                 AND    P.EMPRESA      = P_EMPRESA
                 AND    SUBSTR(M.STATUS_CRED, 1, 1) = 'T'

            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                              V_NUM_PRODUCTO,V_SUCURSAL, V_DIVISA,
                              P_FECHA_HOY, V_FUNCION, V_SALDO_CUOTA
                             ) INTO P_COD_RET, P_MENSAJE;

            IF P_COD_RET <> '00000' THEN
               EXIT FOREACH;
            END IF;
         END FOREACH;

         IF P_COD_RET = '00000' THEN

            /* Actualiza status de cuotas de Pagos de Intereses */
            UPDATE SD_PAGINTER
            SET    CUOTA_REC    = '1',
                   STATUS_CUOTA = '2'
            WHERE  FECHA_CUOTA  = P_FECHA_HOY
            AND    EMPRESA      = P_EMPRESA
            AND    NUM_CREDITO  = P_NUM_CREDITO
            AND    STATUS_CUOTA = '1'
            AND    EXISTS (SELECT '1'
                           FROM   SD_MAECRED M
                           WHERE  M.EMPRESA     = SD_PAGINTER.EMPRESA
                           AND    M.NUM_CREDITO = SD_PAGINTER.NUM_CREDITO
                           AND    M.EMPRESA     = P_EMPRESA
                           AND    M.NUM_CREDITO = P_NUM_CREDITO
                           AND    SUBSTR(M.STATUS_CRED, 1, 1) = 'T');

         END IF;
      END IF;

      IF P_COD_RET = '00000' THEN

         /* Paso de interés vigente a interés vencido (transitorio) */
         /* Traspaso de interés vigente a interés vencido */
         /* STATUS_CUOTA:  1 a 7                          */

         LET V_FUNCION = '605';

         UPDATE SD_MAECRED
         SET    STATUS_CRED = 'B' || SUBSTR(STATUS_CRED, 2, 1)
         WHERE  EXISTS (SELECT '1'
                        FROM   SD_PAGINTER P
                        WHERE  SD_MAECRED.EMPRESA      = P.EMPRESA
                        AND    SD_MAECRED.NUM_CREDITO  = P.NUM_CREDITO
                        AND    P.FECHA_CUOTA           = P_FECHA_HOY
                        AND    P.EMPRESA               = P_EMPRESA
                        AND    P.NUM_CREDITO           = P_NUM_CREDITO
                        AND    P.STATUS_CUOTA          = '1')
         AND    SUBSTR(STATUS_CRED, 1 ,1) IN ('A', 'B');

         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO,
                        SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_SALDO_CUOTA
                 FROM   SD_PAGINTER P, SD_MAECRED M
                 WHERE  P.STATUS_CUOTA = '1'
                 AND    P.FECHA_CUOTA  = P_FECHA_HOY
                 AND    P.EMPRESA      = M.EMPRESA
                 AND    P.NUM_CREDITO  = M.NUM_CREDITO
                 AND    SUBSTR(M.STATUS_CRED, 1, 1) IN ('A', 'B')
                 AND    M.EMPRESA      = P_EMPRESA
                 AND    M.NUM_CREDITO  = P_NUM_CREDITO
                 GROUP BY P.EMPRESA, P.NUM_CREDITO

            UPDATE SD_MAESDOS
            SET    SDO_NO_EXIG  = SDO_NO_EXIG - V_SALDO_CUOTA
                 , MTO_VENC_INT = NVL(MTO_VENC_INT, 0) + V_SALDO_CUOTA
                 , SDO_EXIG_INT = SDO_EXIG_INT + V_SALDO_CUOTA
            WHERE  EMPRESA      = V_EMPRESA
            AND    NUM_CREDITO  = V_NUM_CREDITO;

         END FOREACH;

         /* Aplica el movimiento contable */
         -- INT 1 A 7
         FOREACH  SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                        (P.MONTO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                         M.SUCURSAL, M.DIVISA
                  INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO,
                         V_SALDO_CUOTA, V_SUCURSAL, V_DIVISA
                  FROM   SD_MAECRED M,
                         SD_PAGINTER P
                  WHERE  M.EMPRESA      = P.EMPRESA
                  AND    M.NUM_CREDITO  = P.NUM_CREDITO
                  AND    P.STATUS_CUOTA = '1'
                  AND    P.FECHA_CUOTA  = P_FECHA_HOY
                  AND    P.EMPRESA      = P_EMPRESA
                  AND    P.NUM_CREDITO  = P_NUM_CREDITO
                  AND    SUBSTR(M.STATUS_CRED, 1, 1) IN ('A', 'B')

            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                              V_NUM_PRODUCTO,V_SUCURSAL, V_DIVISA,
                              P_FECHA_HOY, V_FUNCION, V_SALDO_CUOTA
                             ) INTO P_COD_RET, P_MENSAJE;
            IF P_COD_RET <> '00000' THEN
               EXIT FOREACH;
            END IF;
         END FOREACH;

         IF P_COD_RET = '00000' THEN

            /* Actualiza status de cuotas de Pagos de Intereses */
            UPDATE SD_PAGINTER
            SET    CUOTA_REC    = '1',
                   STATUS_CUOTA = '7'
            WHERE  FECHA_CUOTA  = P_FECHA_HOY
            AND    EMPRESA      = P_EMPRESA
            AND    NUM_CREDITO  = P_NUM_CREDITO
            AND    STATUS_CUOTA = '1'
            AND    EXISTS (SELECT '1'
                           FROM   SD_MAECRED M
                           WHERE  M.EMPRESA     = SD_PAGINTER.EMPRESA
                           AND    M.NUM_CREDITO = SD_PAGINTER.NUM_CREDITO
                           AND    M.EMPRESA     = P_EMPRESA
                           AND    M.NUM_CREDITO = P_NUM_CREDITO
                           AND    SUBSTR(M.STATUS_CRED, 1, 1) IN ('A', 'B'));
         END IF;
      END IF;

      IF P_COD_RET = '00000' THEN

         /* Paso de capital vencido (transitorio) a capital vencido traspasado */
         /* Traspaso de capital vencido (transitorio) a capital vencido traspasado */
         /* STATUS_CUOTA:  7 a 2                                                   */

         LET V_FUNCION = '600';

         UPDATE SD_MAECRED
         SET    STATUS_CRED = 'T' || SUBSTR(STATUS_CRED, 2, 1)
         WHERE  EXISTS (SELECT '1'
                        FROM   SD_PAGOCAPIT P
                        WHERE  P.EMPRESA      = SD_MAECRED.EMPRESA
                        AND    P.NUM_CREDITO  = SD_MAECRED.NUM_CREDITO
                        AND    P.FECHA_CUOTA <= P_FECHA_HOY - nvl(SD_MAECRED.DIAS_TRASP_CAP,0)
                        AND    P.EMPRESA      = P_EMPRESA
                        AND    P.NUM_CREDITO  = P_NUM_CREDITO
                        AND    P.STATUS_CUOTA = '7');

         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO,
                        SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_SALDO_CUOTA
                 FROM   SD_PAGOCAPIT P, SD_MAECRED M
                 WHERE  P.STATUS_CUOTA = '7'
                 AND    P.FECHA_CUOTA <= P_FECHA_HOY - nvl(M.DIAS_TRASP_CAP,0)
                 AND    P.EMPRESA      = M.EMPRESA
                 AND    P.NUM_CREDITO  = M.NUM_CREDITO
                 AND    M.EMPRESA      = P_EMPRESA
                 AND    M.NUM_CREDITO  = P_NUM_CREDITO
                 GROUP BY P.EMPRESA, P.NUM_CREDITO

            UPDATE SD_MAESDOS
            SET    MONTO_VENCIDO  = MONTO_VENCIDO - V_SALDO_CUOTA
                 , MTO_VENC_TRASP = MTO_VENC_TRASP + V_SALDO_CUOTA
            WHERE  EMPRESA     = V_EMPRESA
            AND    NUM_CREDITO = V_NUM_CREDITO;
         END FOREACH;

         /* Aplica el movimiento contable */
         -- CAP 7 A 2
         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                        SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                        M.SUCURSAL, M.DIVISA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO,
                        V_SALDO_CUOTA, V_SUCURSAL, V_DIVISA
                 FROM   SD_MAECRED M,
                        SD_PAGOCAPIT P
                 WHERE  M.EMPRESA      = P.EMPRESA
                 AND    M.NUM_CREDITO  = P.NUM_CREDITO
                 AND    P.STATUS_CUOTA = '7'
                 AND    P.FECHA_CUOTA <= P_FECHA_HOY - nvl(M.DIAS_TRASP_CAP,0)
                 AND    P.EMPRESA      = P_EMPRESA
                 AND    P.NUM_CREDITO  = P_NUM_CREDITO
                 GROUP BY P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO, M.SUCURSAL, M.DIVISA


            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                              V_NUM_PRODUCTO,V_SUCURSAL, V_DIVISA,
                              P_FECHA_HOY, V_FUNCION, V_SALDO_CUOTA
                             ) INTO P_COD_RET, P_MENSAJE; -- 600
            IF P_COD_RET <> '00000' THEN
               EXIT  FOREACH;
            END IF;

            /* Traspasa cartera asociada */
            SELECT NVL(SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG),0)
            INTO   V_SALDO_CUOTA1
            FROM   SD_PAGOCAPIT P
            WHERE  P.EMPRESA      = V_EMPRESA
            AND    P.NUM_CREDITO  = V_NUM_CREDITO
            AND    P.STATUS_CUOTA = '1';

            IF V_SALDO_CUOTA1 > 0 THEN

               EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                              V_NUM_PRODUCTO, V_SUCURSAL, V_DIVISA,
                              P_FECHA_HOY, V_FUNC_C1S, V_SALDO_CUOTA1
                             ) INTO P_COD_RET, P_MENSAJE; -- 610
               IF P_COD_RET <> '00000' THEN
                  EXIT FOREACH;
               END IF;
            END IF;

            /* Traspasa cuotas de interés en Status 7 a 2 */
            SELECT NVL(SUM(P.MONTO_CUOTA - P.MONTO_REAL_PAG),0)
            INTO   V_SALDO_CUOTA7
            FROM   SD_PAGINTER P
            WHERE  P.EMPRESA      = V_EMPRESA
            AND    P.NUM_CREDITO  = V_NUM_CREDITO
            AND    P.STATUS_CUOTA = '7';

            IF V_SALDO_CUOTA7 > 0 THEN

               EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                              V_NUM_PRODUCTO, V_SUCURSAL, V_DIVISA,
                              P_FECHA_HOY, V_FUNC_I7S,V_SALDO_CUOTA7
                             ) INTO  P_COD_RET, P_MENSAJE; -- 603
               IF P_COD_RET <> '00000' THEN
                  EXIT FOREACH;
               END IF;
            END IF;

            /* Actualiza SD_MAESDOS */
            UPDATE SD_MAESDOS
            SET    MTO_VENC_INT     = NVL(MTO_VENC_INT, 0) - V_SALDO_CUOTA7,
                   MTO_VENC_TRA_INT = NVL(MTO_VENC_TRA_INT,0) + V_SALDO_CUOTA7
            WHERE  EMPRESA      = V_EMPRESA
            AND    NUM_CREDITO  = V_NUM_CREDITO;

            /* Traspasa cuotas en status 7 a 2 */
            UPDATE SD_PAGINTER
            SET    CUOTA_REC    = '7',
                   STATUS_CUOTA = '2'
            WHERE  EMPRESA      = V_EMPRESA
            AND    NUM_CREDITO  = V_NUM_CREDITO
            AND    STATUS_CUOTA = '7';

         END FOREACH;

         IF P_COD_RET = '00000' THEN

            FOREACH SELECT FECHA_CUOTA
                    INTO   V_FECHA_CUOTA
                    FROM   SD_PAGOCAPIT P0,
                           SD_MAECRED  M
                    WHERE  M.EMPRESA     = P0.EMPRESA
                    AND    M.NUM_CREDITO = P0.NUM_CREDITO
                    AND    P0.FECHA_CUOTA <= P_FECHA_HOY - M.DIAS_TRASP_CAP
                    AND    P0.EMPRESA      = P_EMPRESA
                    AND    P0.NUM_CREDITO  = P_NUM_CREDITO
                    AND    P0.STATUS_CUOTA = '7'

              /* Actualiza status de cuotas de Pagos de Capital */
              UPDATE SD_PAGOCAPIT
              SET    CUOTA_REC    = '7',
                     STATUS_CUOTA = '2'
              WHERE  STATUS_CUOTA = '7'
              AND    FECHA_CUOTA  = V_FECHA_CUOTA
              AND    NUM_CREDITO  = P_NUM_CREDITO
              AND    EMPRESA      = P_EMPRESA;

            END FOREACH;
         END IF;
      END IF;

      IF P_COD_RET = '00000' THEN

         /* Paso de capital vigente a capital vencido traspasado */
         /* Traspaso de capital vigente a capital vencido traspasado */
         /* STATUS_CUOTA:  1 a 2                                     */

         LET V_FUNCION = '601';

         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_SALDO_CUOTA
                 FROM   SD_PAGOCAPIT P, SD_MAECRED M
                 WHERE  P.STATUS_CUOTA = '1'
                 AND    P.FECHA_CUOTA  = P_FECHA_HOY
                 AND    P.EMPRESA      = M.EMPRESA
                 AND    P.NUM_CREDITO  = M.NUM_CREDITO
                 AND    SUBSTR(M.STATUS_CRED, 1, 1) = 'T'
                 AND    M.EMPRESA      = P_EMPRESA
                 AND    M.NUM_CREDITO  = P_NUM_CREDITO
                 GROUP BY P.EMPRESA, P.NUM_CREDITO

            UPDATE SD_MAESDOS
            SET    SDO_CAPITAL    = SDO_CAPITAL - V_SALDO_CUOTA
                 , MTO_VENC_TRASP = MTO_VENC_TRASP + V_SALDO_CUOTA
            WHERE  EMPRESA      = V_EMPRESA
            AND    NUM_CREDITO  = V_NUM_CREDITO;

         END FOREACH;

         /* Aplica el movimiento contable */
         -- CAP 1 A 2
         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                       (P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                       M.SUCURSAL, M.DIVISA
                INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO,
                       V_SALDO_CUOTA, V_SUCURSAL, V_DIVISA
                FROM   SD_MAECRED M,
                       SD_PAGOCAPIT P
                WHERE  M.EMPRESA      = P.EMPRESA
                AND    M.NUM_CREDITO  = P.NUM_CREDITO
                AND    P.STATUS_CUOTA = '1'
                AND    P.FECHA_CUOTA  = P_FECHA_HOY
                AND    P.EMPRESA      = P_EMPRESA
                AND    P.NUM_CREDITO  = P_NUM_CREDITO
                AND    SUBSTR(M.STATUS_CRED, 1, 1) = 'T'

            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO, V_NUM_PRODUCTO,
                              V_SUCURSAL, V_DIVISA, P_FECHA_HOY, V_FUNCION,
                              V_SALDO_CUOTA
                             ) INTO P_COD_RET, P_MENSAJE;
            IF P_COD_RET <> '00000' THEN
               EXIT FOREACH;
            END IF;
         END FOREACH;

         IF P_COD_RET = '00000' THEN

            /* Actualiza status de cuotas de Pagos de Capital */
            UPDATE SD_PAGOCAPIT
            SET    CUOTA_REC    = '1',
                   STATUS_CUOTA = '2'
            WHERE  FECHA_CUOTA  = P_FECHA_HOY
            AND    EMPRESA      = P_EMPRESA
            AND    NUM_CREDITO  = P_NUM_CREDITO
            AND    STATUS_CUOTA = '1'
            AND    EXISTS (SELECT '1'
                           FROM   SD_MAECRED M
                           WHERE  M.EMPRESA     = SD_PAGOCAPIT.EMPRESA
                           AND    M.NUM_CREDITO = SD_PAGOCAPIT.NUM_CREDITO
                           AND    M.EMPRESA     = P_EMPRESA
                           AND    M.NUM_CREDITO = P_NUM_CREDITO
                           AND    SUBSTR(M.STATUS_CRED, 1, 1) = 'T');
         END IF;
      END IF;

      IF P_COD_RET = '00000' THEN

         /* Paso de capital vigente a capital vencido traspasado */
         /* Traspaso de capital vigente a capital vencido  (transitorio) */
         /* STATUS_CUOTA:  1 a 7                                         */

         LET V_FUNCION = '602';

         UPDATE SD_MAECRED
         SET    STATUS_CRED = 'B' || SUBSTR(STATUS_CRED, 2, 1)
         WHERE  EXISTS (SELECT '1'
                        FROM   SD_PAGOCAPIT P
                        WHERE  P.EMPRESA      = SD_MAECRED.EMPRESA
                        AND    P.NUM_CREDITO  = SD_MAECRED.NUM_CREDITO
                        AND    P.FECHA_CUOTA  = P_FECHA_HOY
                        AND    P.EMPRESA      = P_EMPRESA
                        AND    P.NUM_CREDITO  = P_NUM_CREDITO
                        AND    P.STATUS_CUOTA = '1')
         AND    SUBSTR(STATUS_CRED, 1 ,1) IN ('A', 'B')
         AND    EMPRESA     = P_EMPRESA
         AND    NUM_CREDITO = P_NUM_CREDITO;

         FOREACH SELECT P.EMPRESA, P.NUM_CREDITO, SUM(P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA
                 INTO   V_EMPRESA, V_NUM_CREDITO, V_SALDO_CUOTA
                 FROM   SD_PAGOCAPIT P
                 WHERE  P.STATUS_CUOTA = '1'
                 AND    P.FECHA_CUOTA  = P_FECHA_HOY
                 AND    P.EMPRESA      = M.EMPRESA
                 AND    P.NUM_CREDITO  = M.NUM_CREDITO
                 AND    SUBSTR(M.STATUS_CRED, 1, 1) IN ('A', 'B')
                 AND    M.EMPRESA      = P_EMPRESA
                 AND    M.NUM_CREDITO  = P_NUM_CREDITO
                 GROUP BY P.EMPRESA, P.NUM_CREDITO

            UPDATE SD_MAESDOS
            SET    SDO_CAPITAL   = SDO_CAPITAL - V_SALDO_CUOTA
                 , MONTO_VENCIDO = MONTO_VENCIDO + V_SALDO_CUOTA
            WHERE  EMPRESA     = V_EMPRESA
            AND    NUM_CREDITO = V_NUM_CREDITO;

         END FOREACH;

         /* Aplica el movimiento contable */
         -- CAP 1 A 7
         FOREACH  SELECT P.EMPRESA, P.NUM_CREDITO, M.NUM_PRODUCTO,
                        (P.SALDO_CUOTA - P.MONTO_REAL_PAG) SALDO_CUOTA,
                         M.SUCURSAL, M.DIVISA
                  INTO   V_EMPRESA, V_NUM_CREDITO, V_NUM_PRODUCTO,
                         V_SALDO_CUOTA, V_SUCURSAL, V_DIVISA
                  FROM   SD_MAECRED M,
                         SD_PAGOCAPIT P
                  WHERE  M.EMPRESA      = P.EMPRESA
                  AND    M.NUM_CREDITO  = P.NUM_CREDITO
                  AND    P.STATUS_CUOTA = '1'
                  AND    P.FECHA_CUOTA  = P_FECHA_HOY
                  AND    P.EMPRESA      = P_EMPRESA
                  AND    P.NUM_CREDITO  = P_NUM_CREDITO
                  AND    SUBSTR(M.STATUS_CRED, 1, 1) IN ('A', 'B')


            EXECUTE PROCEDURE SP_GENERA_MOVDIA
                             (V_EMPRESA, V_NUM_CREDITO, P_EJECUTIVO,
                              V_NUM_PRODUCTO,V_SUCURSAL, V_DIVISA,
                              P_FECHA_HOY, V_FUNCION,V_SALDO_CUOTA
                             ) INTO P_COD_RET, P_MENSAJE;
            IF P_COD_RET <> '00000' THEN
               EXIT FOREACH;
            END IF;
         END FOREACH;

         IF P_COD_RET = '00000' THEN

            /* Actualiza status de cuotas de Pagos de Intereses */
            UPDATE SD_PAGOCAPIT
            SET    CUOTA_REC    = '1',
                   STATUS_CUOTA = '7'
            WHERE  FECHA_CUOTA  = P_FECHA_HOY
            AND    EMPRESA      = P_EMPRESA
            AND    NUM_CREDITO  = P_NUM_CREDITO
            AND    STATUS_CUOTA = '1'
            AND    EXISTS (SELECT '1'
                           FROM   SD_MAECRED M
                           WHERE  M.EMPRESA     = SD_PAGOCAPIT.EMPRESA
                           AND    M.NUM_CREDITO = SD_PAGOCAPIT.NUM_CREDITO
                           AND    M.EMPRESA     = P_EMPRESA
                           AND    M.NUM_CREDITO = P_NUM_CREDITO
                           AND    SUBSTR(M.STATUS_CRED, 1, 1) IN ('A', 'B'));
         END IF;
      END IF;
   RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;