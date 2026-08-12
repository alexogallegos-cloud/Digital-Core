CREATE PROCEDURE "informix".sp_actualiza_revtasa(P_EMPRESA          VARCHAR(3),
       P_FECHA_HOY        DATE,
       P_ANT_POST         VARCHAR(2)
      ) RETURNING VARCHAR(6), VARCHAR(80);

DEFINE  P_COD_RET   VARCHAR(6);
DEFINE  P_MENSAJE   VARCHAR(80);
DEFINE  V_NUM_REGS  INTEGER;
DEFINE  V_LASTDAY   INTEGER;
DEFINE  V_NADA      INTEGER;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     ROLLBACK WORK;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;
  ON EXCEPTION IN (-255)
     LET V_NADA = 0;
  END EXCEPTION WITH RESUME;

  LET V_NADA = 0;
  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  --SE OBTIENE EL ULTIMO DIA DEL SIGUIENTE MES A LA FECHA DE HOY
  SELECT DAY(MDY(DECODE(MONTH(P_FECHA_HOY),11,1,12,2,MONTH(P_FECHA_HOY)+2)
            ,1
            ,DECODE(MONTH(P_FECHA_HOY),11,YEAR(P_FECHA_HOY)+1,12,YEAR(P_FECHA_HOY)+1,YEAR(P_FECHA_HOY))
            ) -1)
  INTO V_LASTDAY
  FROM SD_FECHAS;

--  BEGIN WORK;
    --CONSERVA DATOS DE LOS CREDITOS A REVISAR 
--    INSERT INTO SD_CREDITOS_REVTASA (EMPRESA, NUM_CREDITO)
--    SELECT EMPRESA,NUM_CREDITO
--    FROM   SD_REVTASA
--    WHERE  EMPRESA        = P_EMPRESA
--    AND    FECHA_PROX_REV = P_FECHA_HOY;
--  COMMIT WORK;

  IF P_ANT_POST = 'A' THEN    /* Toma día hábil anterior */
    BEGIN WORK;
      /* Actualiza REVTASA para Período en Días, verificando que no sea Sábado o Domingo */
      UPDATE SD_REVTASA
      SET    SD_REVTASA.FECHA_PROX_REV =
            (SELECT DECODE(WEEKDAY(P_FECHA_HOY + M.DIA_PARA_REVISAR),
                             '0', (P_FECHA_HOY + M.DIA_PARA_REVISAR) - 2,
                             '6', (P_FECHA_HOY + M.DIA_PARA_REVISAR) - 1,
                                  (P_FECHA_HOY + M.DIA_PARA_REVISAR))
             FROM   SD_MAECRED M
             WHERE  M.REV_TASA_VAR_PER = '1'
             AND    M.TASA_FIJA_O_VAR  = '2'
             AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
             AND    M.BANDERA_MINISTRA = 'M'
             AND    M.EMPRESA     = SD_REVTASA.EMPRESA
             AND    M.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
      WHERE EXISTS (SELECT '1'
                    FROM   SD_MAECRED M1
                    WHERE  M1.REV_TASA_VAR_PER = '1'
                    AND    M1.TASA_FIJA_O_VAR  = '2'
                    AND    SUBSTR(M1.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                    AND    M1.BANDERA_MINISTRA = 'M'
                    AND    M1.EMPRESA     = SD_REVTASA.EMPRESA
                    AND    M1.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
      AND   SD_REVTASA.FECHA_PROX_REV = P_FECHA_HOY
      AND   SD_REVTASA.EMPRESA        = P_EMPRESA;
    COMMIT WORK;

    BEGIN WORK;
      /* ****** Actualiza REVTASA  para  Día fijo por período ****** */
      /* ****** para dia_para_revisar entre 1 y 28, o 55 o 99 ****** */
      UPDATE SD_REVTASA
      SET    SD_REVTASA.FECHA_PROX_REV =
            (SELECT  CASE
                     WHEN 28 > (M.DIA_PARA_REVISAR) THEN
                       DECODE(WEEKDAY(MDY(DECODE(MONTH(P_FECHA_HOY)
                                                ,12,1,MONTH(P_FECHA_HOY)+1)
                                         ,M.DIA_PARA_REVISAR
                                         ,DECODE(MONTH(P_FECHA_HOY)
                                                ,12,YEAR(P_FECHA_HOY)+1
                                                ,YEAR(P_FECHA_HOY))))
                              ,0,MDY(DECODE(MONTH(P_FECHA_HOY)
                                           ,12,1,MONTH(P_FECHA_HOY)+1)
                                    ,M.DIA_PARA_REVISAR
                                    ,DECODE(MONTH(P_FECHA_HOY)
                                           ,12,YEAR(P_FECHA_HOY)+1
                                           ,YEAR(P_FECHA_HOY)))-2
                              ,6,MDY(DECODE(MONTH(P_FECHA_HOY)
                                           ,12,1,MONTH(P_FECHA_HOY)+1)
                                    ,M.DIA_PARA_REVISAR
                                    ,DECODE(MONTH(P_FECHA_HOY)
                                           ,12,YEAR(P_FECHA_HOY)+1
                                           ,YEAR(P_FECHA_HOY)))-1
                              ,MDY(DECODE(MONTH(P_FECHA_HOY)
                                         ,12,1,MONTH(P_FECHA_HOY)+1)
                                  ,M.DIA_PARA_REVISAR
                                  ,DECODE(MONTH(P_FECHA_HOY)
                                         ,12,YEAR(P_FECHA_HOY)+1
                                         ,YEAR(P_FECHA_HOY)))
                              )
                     WHEN (M.DIA_PARA_REVISAR) = 55 THEN
                       DECODE(WEEKDAY(MDY(MONTH(M.FECHA_APERTURA)
                                         ,DAY(M.FECHA_APERTURA)
                                         ,YEAR(P_FECHA_HOY)+1))
                              ,0,MDY(MONTH(M.FECHA_APERTURA)
                                    ,DAY(M.FECHA_APERTURA)
                                    ,YEAR(P_FECHA_HOY)+1)-2
                              ,6,MDY(MONTH(M.FECHA_APERTURA)
                                    ,DAY(M.FECHA_APERTURA)
                                    ,YEAR(P_FECHA_HOY)+1)-1
                              ,MDY(MONTH(M.FECHA_APERTURA)
                                    ,DAY(M.FECHA_APERTURA)
                                    ,YEAR(P_FECHA_HOY)+1)
                              )
                     ELSE
                       DECODE(WEEKDAY(MDY(DECODE(MONTH(P_FECHA_HOY)
                                                ,12,1,MONTH(P_FECHA_HOY)+1)
                                          ,V_LASTDAY
                                          ,DECODE(MONTH(P_FECHA_HOY)
                                                 ,12,YEAR(P_FECHA_HOY)+1
                                                 ,YEAR(P_FECHA_HOY))))
                             ,0,MDY(DECODE(MONTH(P_FECHA_HOY)
                                          ,12,1,MONTH(P_FECHA_HOY)+1)
                                   ,V_LASTDAY
                                   ,DECODE(MONTH(P_FECHA_HOY)
                                          ,12,YEAR(P_FECHA_HOY)+1
                                          ,YEAR(P_FECHA_HOY)))-2
                             ,6,MDY(DECODE(MONTH(P_FECHA_HOY)
                                          ,12,1,MONTH(P_FECHA_HOY)+1)
                                   ,V_LASTDAY
                                   ,DECODE(MONTH(P_FECHA_HOY)
                                          ,12,YEAR(P_FECHA_HOY)+1
                                          ,YEAR(P_FECHA_HOY)))-1
                             ,MDY(DECODE(MONTH(P_FECHA_HOY)
                                        ,12,1,MONTH(P_FECHA_HOY)+1)
                                 ,V_LASTDAY
                                 ,DECODE(MONTH(P_FECHA_HOY)
                                        ,12,YEAR(P_FECHA_HOY)+1
                                        ,YEAR(P_FECHA_HOY)))
                            )
                   END FECHA_PROX_REV
              FROM   SD_MAECRED M
              WHERE  M.REV_TASA_VAR_PER = '2'
              AND    M.TASA_FIJA_O_VAR  = '2'
              AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
              AND    M.BANDERA_MINISTRA = 'M'
              AND   (M.DIA_PARA_REVISAR BETWEEN 1 AND 28
                     OR
                     M.DIA_PARA_REVISAR IN (55,99))
              AND    M.EMPRESA = SD_REVTASA.EMPRESA
              AND    M.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
      WHERE EXISTS (SELECT '1'
                    FROM   SD_MAECRED M1
                    WHERE  M1.REV_TASA_VAR_PER = '2'
                    AND    M1.TASA_FIJA_O_VAR  = '2'
                    AND    SUBSTR(M1.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                    AND    M1.BANDERA_MINISTRA = 'M'
                    AND   (M1.DIA_PARA_REVISAR BETWEEN 1 AND 28
                           OR
                           M1.DIA_PARA_REVISAR IN (55,99))
                    AND    M1.EMPRESA     = SD_REVTASA.EMPRESA
                    AND    M1.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
      AND   SD_REVTASA.FECHA_PROX_REV = P_FECHA_HOY
      AND   SD_REVTASA.EMPRESA        = P_EMPRESA;
    COMMIT WORK;

    BEGIN WORK;
         /* ****** Actualiza REVTASA  para  Día  fijo  por  período ****** */
         /* ****** para dia_para_revisar = 88 (fin de amortizacion) ****** */
         /* Se toma la fecha de la siguiente amortización de pago de interes, esto es */
         /* la mínima sd_paginter.fecha_cuota que sea mayor a la fecha de hoy, en     */
         /* caso de ya no haya más amortizaciones (sea la última cuota), no se actua- */
         /* liza la fecha de próxima revisión de tasas.                               */
         UPDATE SD_REVTASA
         SET    SD_REVTASA.FECHA_PROX_REV =
                    (SELECT DECODE(WEEKDAY(MIN(PI.FECHA_CUOTA)                                          )
                                  ,0,MIN(PI.FECHA_CUOTA)-2
                                  ,6,MIN(PI.FECHA_CUOTA)-1
                                  ,MIN(PI.FECHA_CUOTA)
                                  ) FECHA_PROX_REV
                     FROM   SD_MAECRED M, SD_PAGINTER PI
                     WHERE  PI.FECHA_CUOTA > P_FECHA_HOY
                     AND    PI.EMPRESA     = M.EMPRESA
                     AND    PI.NUM_CREDITO = M.NUM_CREDITO
                     AND    M.REV_TASA_VAR_PER = '2'
                     AND    M.TASA_FIJA_O_VAR  = '2'
                     AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                     AND    M.BANDERA_MINISTRA = 'M'
                     AND    M.DIA_PARA_REVISAR = 88
                     AND    M.EMPRESA          = SD_REVTASA.EMPRESA
                     AND    M.NUM_CREDITO      = SD_REVTASA.NUM_CREDITO
                     AND    EXISTS (SELECT '1'
                                    FROM   SD_PAGINTER PR
                                    WHERE  PR.EMPRESA     = M.EMPRESA
                                    AND    PR.NUM_CREDITO = M.NUM_CREDITO
                                    AND    PR.EMPRESA     = P_EMPRESA
                                    AND    PR.FECHA_CUOTA > P_FECHA_HOY )
                     )
         WHERE EXISTS (SELECT '1'
                       FROM   SD_MAECRED M1
                       WHERE  M1.REV_TASA_VAR_PER = '2'
                       AND    M1.TASA_FIJA_O_VAR  = '2'
                       AND    SUBSTR(M1.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                       AND    M1.BANDERA_MINISTRA = 'M'
                       AND    M1.DIA_PARA_REVISAR = 88
                       AND    EXISTS (SELECT '1'
                                      FROM   SD_PAGINTER PA
                                      WHERE  M1.EMPRESA      = PA.EMPRESA
                                      AND    M1.NUM_CREDITO  = PA.NUM_CREDITO
                                      AND    PA.EMPRESA      = P_EMPRESA
                                      AND    PA.FECHA_CUOTA  > P_FECHA_HOY )
                       AND    M1.EMPRESA     = SD_REVTASA.EMPRESA
                       AND    M1.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
         AND   SD_REVTASA.FECHA_PROX_REV = P_FECHA_HOY
         AND   SD_REVTASA.EMPRESA        = P_EMPRESA;
    COMMIT WORK;
    
         LET V_NUM_REGS = 1;
         /* Verifica que no sea Feriado */
         WHILE V_NUM_REGS <> 0
         BEGIN WORK;
            UPDATE SD_REVTASA 
            SET    FECHA_PROX_REV = DECODE(WEEKDAY(SD_REVTASA.FECHA_PROX_REV - 1),
                                           '0', SD_REVTASA.FECHA_PROX_REV - 3,
                                           '6', SD_REVTASA.FECHA_PROX_REV - 2, SD_REVTASA.FECHA_PROX_REV - 1)
            WHERE  EXISTS (SELECT '1'
                           FROM   SI_FERIADO F
                           WHERE  SD_REVTASA.EMPRESA        = F.EMPRESA
                           AND    SD_REVTASA.FECHA_PROX_REV = F.FECHA)
            AND    EXISTS (SELECT '1'
                           FROM   SD_CREDITOS_REVTASA CR
                           WHERE  SD_REVTASA.EMPRESA     = CR.EMPRESA
                           AND    SD_REVTASA.NUM_CREDITO = CR.NUM_CREDITO);

            LET V_NUM_REGS = dbinfo("sqlca.sqlerrd2");
         COMMIT WORK;
         END WHILE;

  ELSE  /* Toma siguiente dia hábil */
    BEGIN WORK;
         /* Actualiza REVTASA para Período en Días, verificando que no sea Sábado o Domingo */
         UPDATE SD_REVTASA 
         SET    SD_REVTASA.FECHA_PROX_REV =
            (SELECT DECODE(WEEKDAY(P_FECHA_HOY + M.DIA_PARA_REVISAR),
                             '0', (P_FECHA_HOY + M.DIA_PARA_REVISAR) + 1,
                             '6', (P_FECHA_HOY + M.DIA_PARA_REVISAR) + 2,
                                  (P_FECHA_HOY + M.DIA_PARA_REVISAR))
             FROM   SD_MAECRED M
             WHERE  M.REV_TASA_VAR_PER = '1'
             AND    M.TASA_FIJA_O_VAR  = '2'
             AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
             AND    M.BANDERA_MINISTRA = 'M'
             AND    M.EMPRESA     = SD_REVTASA.EMPRESA
             AND    M.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
         WHERE EXISTS (SELECT '1'
                       FROM   SD_MAECRED M1
                       WHERE  M1.REV_TASA_VAR_PER = '1'
                       AND    M1.TASA_FIJA_O_VAR  = '2'
                       AND    SUBSTR(M1.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                       AND    M1.BANDERA_MINISTRA = 'M'
                       AND    M1.EMPRESA     = SD_REVTASA.EMPRESA
                       AND    M1.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
         AND   SD_REVTASA.FECHA_PROX_REV = P_FECHA_HOY
         AND   SD_REVTASA.EMPRESA        = P_EMPRESA;

    COMMIT WORK;

    BEGIN WORK;
         /* ****** Actualiza REVTASA  para  Día fijo por período ****** */
         /* ****** para dia_para_revisar entre 1 y 28, o 55 o 99 ****** */
      UPDATE SD_REVTASA
      SET    SD_REVTASA.FECHA_PROX_REV =
            (SELECT  CASE
                     WHEN 28 > (M.DIA_PARA_REVISAR) THEN
                       DECODE(WEEKDAY(MDY(DECODE(MONTH(P_FECHA_HOY)
                                                ,12,1,MONTH(P_FECHA_HOY)+1)
                                         ,M.DIA_PARA_REVISAR
                                         ,DECODE(MONTH(P_FECHA_HOY)
                                                ,12,YEAR(P_FECHA_HOY)+1
                                                ,YEAR(P_FECHA_HOY))))
                              ,0,MDY(DECODE(MONTH(P_FECHA_HOY)
                                            ,12,1,MONTH(P_FECHA_HOY)+1)
                                     ,M.DIA_PARA_REVISAR
                                     ,DECODE(MONTH(P_FECHA_HOY)
                                            ,12,YEAR(P_FECHA_HOY)+1
                                            ,YEAR(P_FECHA_HOY)))+1
                              ,6,MDY(DECODE(MONTH(P_FECHA_HOY)
                                           ,12,1,MONTH(P_FECHA_HOY)+1)
                                    ,M.DIA_PARA_REVISAR
                                    ,DECODE(MONTH(P_FECHA_HOY)
                                           ,12,YEAR(P_FECHA_HOY)+1
                                           ,YEAR(P_FECHA_HOY)))+2
                              ,MDY(DECODE(MONTH(P_FECHA_HOY)
                                           ,12,1,MONTH(P_FECHA_HOY)+1)
                                  ,M.DIA_PARA_REVISAR
                                  ,DECODE(MONTH(P_FECHA_HOY)
                                         ,12,YEAR(P_FECHA_HOY)+1
                                         ,YEAR(P_FECHA_HOY)))
                              )
                     WHEN (M.DIA_PARA_REVISAR) = 55 THEN
                       DECODE(WEEKDAY(MDY(MONTH(M.FECHA_APERTURA)
                                         ,DAY(M.FECHA_APERTURA)
                                         ,YEAR(P_FECHA_HOY)+1))
                              ,0,MDY(MONTH(M.FECHA_APERTURA)
                                    ,DAY(M.FECHA_APERTURA)
                                    ,YEAR(P_FECHA_HOY)+1)+1
                              ,6,MDY(MONTH(M.FECHA_APERTURA)
                                    ,DAY(M.FECHA_APERTURA)
                                    ,YEAR(P_FECHA_HOY)+1)+2
                              ,MDY(MONTH(M.FECHA_APERTURA)
                                    ,DAY(M.FECHA_APERTURA)
                                    ,YEAR(P_FECHA_HOY)+1)
                              )
                     ELSE
                       DECODE(WEEKDAY(MDY(DECODE(MONTH(P_FECHA_HOY)
                                                ,12,1,MONTH(P_FECHA_HOY)+1)
                                          ,V_LASTDAY
                                          ,DECODE(MONTH(P_FECHA_HOY)
                                                 ,12,YEAR(P_FECHA_HOY)+1
                                                 ,YEAR(P_FECHA_HOY))))
                             ,0,MDY(DECODE(MONTH(P_FECHA_HOY)
                                          ,12,1,MONTH(P_FECHA_HOY)+1)
                                   ,V_LASTDAY
                                   ,DECODE(MONTH(P_FECHA_HOY)
                                          ,12,YEAR(P_FECHA_HOY)+1
                                          ,YEAR(P_FECHA_HOY)))+1
                             ,6,MDY(DECODE(MONTH(P_FECHA_HOY)
                                          ,12,1,MONTH(P_FECHA_HOY)+1)
                                   ,V_LASTDAY
                                   ,DECODE(MONTH(P_FECHA_HOY)
                                          ,12,YEAR(P_FECHA_HOY)+1
                                          ,YEAR(P_FECHA_HOY)))+2
                             ,MDY(DECODE(MONTH(P_FECHA_HOY)
                                        ,12,1,MONTH(P_FECHA_HOY)+1)
                                 ,V_LASTDAY
                                 ,DECODE(MONTH(P_FECHA_HOY)
                                        ,12,YEAR(P_FECHA_HOY)+1
                                        ,YEAR(P_FECHA_HOY)))
                            )
                   END FECHA_PROX_REV
              FROM   SD_MAECRED M
              WHERE  M.REV_TASA_VAR_PER = '2'
              AND    M.TASA_FIJA_O_VAR  = '2'
              AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
              AND    M.BANDERA_MINISTRA = 'M'
              AND   (M.DIA_PARA_REVISAR BETWEEN 1 AND 28
                     OR
                     M.DIA_PARA_REVISAR IN (55,99))
              AND    M.EMPRESA = SD_REVTASA.EMPRESA
              AND    M.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
      WHERE EXISTS (SELECT '1'
                    FROM   SD_MAECRED M1
                    WHERE  M1.REV_TASA_VAR_PER = '2'
                    AND    M1.TASA_FIJA_O_VAR  = '2'
                    AND    SUBSTR(M1.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                    AND    M1.BANDERA_MINISTRA = 'M'
                    AND   (M1.DIA_PARA_REVISAR BETWEEN 1 AND 28
                           OR
                           M1.DIA_PARA_REVISAR IN (55,99))
                    AND    M1.EMPRESA     = SD_REVTASA.EMPRESA
                    AND    M1.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
      AND   SD_REVTASA.FECHA_PROX_REV = P_FECHA_HOY
      AND   SD_REVTASA.EMPRESA        = P_EMPRESA;
    COMMIT WORK;

    BEGIN WORK;
         /* ****** Actualiza REVTASA  para  Día  fijo  por  período ****** */
         /* ****** para dia_para_revisar = 88 (fin de amortizacion) ****** */
         UPDATE SD_REVTASA
         SET    SD_REVTASA.FECHA_PROX_REV =
                    (SELECT DECODE(WEEKDAY(MIN(PI.FECHA_CUOTA))
                                  ,0,MIN(PI.FECHA_CUOTA)+1
                                  ,6,MIN(PI.FECHA_CUOTA)+2
                                  ,MIN(PI.FECHA_CUOTA)
                                  ) FECHA_PROX_REV
                     FROM   SD_MAECRED M, SD_PAGINTER PI
                     WHERE  PI.FECHA_CUOTA > P_FECHA_HOY
                     AND    PI.EMPRESA     = M.EMPRESA
                     AND    PI.NUM_CREDITO = M.NUM_CREDITO
                     AND    M.REV_TASA_VAR_PER = '2'
                     AND    M.TASA_FIJA_O_VAR  = '2'
                     AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                     AND    M.BANDERA_MINISTRA = 'M'
                     AND    M.DIA_PARA_REVISAR = 88
                     AND    M.EMPRESA          = SD_REVTASA.EMPRESA
                     AND    M.NUM_CREDITO      = SD_REVTASA.NUM_CREDITO
                     AND    EXISTS (SELECT '1'
                                    FROM   SD_PAGINTER PR
                                    WHERE  PR.EMPRESA     = M.EMPRESA
                                    AND    PR.NUM_CREDITO = M.NUM_CREDITO
                                    AND    PR.EMPRESA     = P_EMPRESA
                                    AND    PR.FECHA_CUOTA > P_FECHA_HOY )
                     )
         WHERE EXISTS (SELECT '1'
                       FROM   SD_MAECRED M1
                       WHERE  M1.REV_TASA_VAR_PER = '2'
                       AND    M1.TASA_FIJA_O_VAR  = '2'
                       AND    SUBSTR(M1.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                       AND    M1.BANDERA_MINISTRA = 'M'
                       AND    M1.DIA_PARA_REVISAR = 88
                       AND    EXISTS (SELECT '1'
                                      FROM   SD_PAGINTER PA
                                      WHERE  M1.EMPRESA      = PA.EMPRESA
                                      AND    M1.NUM_CREDITO  = PA.NUM_CREDITO
                                      AND    PA.EMPRESA      = P_EMPRESA
                                      AND    PA.FECHA_CUOTA  > P_FECHA_HOY )
                       AND    M1.EMPRESA     = SD_REVTASA.EMPRESA
                       AND    M1.NUM_CREDITO = SD_REVTASA.NUM_CREDITO)
         AND   SD_REVTASA.FECHA_PROX_REV = P_FECHA_HOY
         AND   SD_REVTASA.EMPRESA        = P_EMPRESA;
    COMMIT WORK;

         LET V_NUM_REGS = 1;
         WHILE V_NUM_REGS <> 0
         BEGIN WORK;
            UPDATE SD_REVTASA 
            SET    FECHA_PROX_REV = DECODE(WEEKDAY(SD_REVTASA.FECHA_PROX_REV + 1),
                                           '0', SD_REVTASA.FECHA_PROX_REV + 3,
                                           '6', SD_REVTASA.FECHA_PROX_REV + 2,
                                                SD_REVTASA.FECHA_PROX_REV + 1)
            WHERE EXISTS (SELECT '1'
                          FROM   SI_FERIADO F
                          WHERE  SD_REVTASA.EMPRESA        = F.EMPRESA
                          AND    SD_REVTASA.FECHA_PROX_REV = F.FECHA)
            AND   EXISTS (SELECT '1'
                          FROM   SD_CREDITOS_REVTASA CR
                          WHERE  SD_REVTASA.EMPRESA     = CR.EMPRESA
                          AND    SD_REVTASA.NUM_CREDITO = CR.NUM_CREDITO);

            LET V_NUM_REGS = dbinfo("sqlca.sqlerrd2");

         COMMIT WORK;
         END WHILE;
  END IF;

--  BEGIN WORK;
--    DELETE FROM SD_CREDITOS_REVTASA;
--  COMMIT WORK;
  RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;