CREATE PROCEDURE "informix".sp_revision_de_tasas(P_EMPRESA          VARCHAR(3),
       P_FECHA_HOY        DATE,
       P_PROX_FECHA       DATE,
       P_EJECUTIVO        VARCHAR(8),
       P_ANT_POST         VARCHAR(1)
      )RETURNING VARCHAR(6), VARCHAR(80);

DEFINE  P_COD_RET   VARCHAR(6);
DEFINE  P_MENSAJE   VARCHAR(80);
DEFINE  V_TRABAJO   VARCHAR(1);
DEFINE  V_TRABAJO2  INTEGER;

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;

     UPDATE SD_CONTPROC
     SET    STATUS_PROC = 'C',
            HORA_FIN    = CURRENT,
            COD_RET     = P_COD_RET,
            MENSAJE     = P_MENSAJE
     WHERE  EMPRESA     = P_EMPRESA
     AND    PROCESO     = 'act tasas'
     AND    FECHA       = P_FECHA_HOY;

     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;


  LET V_TRABAJO2 = 0;
  LET P_COD_RET  = '00000';
  LET P_MENSAJE  = 'PROCESO EXITOSO';

  /* VERIFICA QUE LA VALIDACION DE TASAS HAYA SIDO EXITOSA */
  SELECT COUNT(PROCESO)
  INTO   V_TRABAJO2
  FROM   SD_CONTPROC
  WHERE  EMPRESA = P_EMPRESA
  AND    FECHA BETWEEN P_FECHA_HOY AND P_PROX_FECHA
  AND    PROCESO = 'valid tasa'
  AND    STATUS_PROC = 'C';

  IF V_TRABAJO2 = 0 THEN
    /* ***********  TRASPASO A HISTORICO DE REVTASA  ********** */
    /* Verifica que no se haya ejecutado el traspaso a histórico de Revtasa */
    SELECT NVL(MAX(STATUS_PROC), 'N')
    INTO   V_TRABAJO
    FROM   SD_CONTPROC
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'hist tasa'
    AND    FECHA       = P_FECHA_HOY;

    IF V_TRABAJO = 'N' THEN
      BEGIN WORK;
        /* Se graba inicio de proceso en SD_CONTPROC */
        INSERT INTO SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                                 HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
        VALUES (P_EMPRESA, 'hist tasa', P_FECHA_HOY, 'I', P_EJECUTIVO, CURRENT, NULL,
                NULL, NULL);

      COMMIT WORK;

      /* Traspasa tasas al histórico de Revisión de tasas (SD_REVTASA_HIST) */
      EXECUTE PROCEDURE SP_TRANS_HIST_REVTASA(P_EMPRESA, P_FECHA_HOY)
                                         INTO P_COD_RET, P_MENSAJE;

    ELIF V_TRABAJO = 'C' THEN
      BEGIN WORK;
        UPDATE SD_CONTPROC
        SET    STATUS_PROC = 'I',
               HORA_INICIO = CURRENT,
               EJECUTIVO   = P_EJECUTIVO,
               HORA_FIN    = NULL,
               COD_RET     = NULL,
               MENSAJE     = NULL
        WHERE  EMPRESA     = P_EMPRESA
        AND    PROCESO     = 'hist tasa'
        AND    FECHA       = P_FECHA_HOY;

        DELETE FROM SD_REVTASA_HIST
        WHERE  EMPRESA        = P_EMPRESA
        AND    FECHA_FIN_TASA = P_FECHA_HOY - 1;
      COMMIT WORK;

      /* Traspasa tasas al histórico de Revisión de tasas (SD_REVTASA_HIST) */
      EXECUTE PROCEDURE SP_TRANS_HIST_REVTASA(P_EMPRESA, P_FECHA_HOY)
                                         INTO P_COD_RET, P_MENSAJE;

    ELIF V_TRABAJO = 'I' THEN
         LET P_COD_RET = '911';
         SELECT DESCRIPCION
         INTO   P_MENSAJE
         FROM   SI_CODRET
         WHERE  SISTEMA = '06'
         AND    CODIGO_RETORNO = P_COD_RET;
    END IF;

    IF P_COD_RET = '00000' THEN

      LET P_MENSAJE = 'PROCESO EXITOSO';
      UPDATE SD_CONTPROC
      SET    STATUS_PROC = 'F',
             HORA_FIN    = CURRENT,
             COD_RET     = P_COD_RET,
             MENSAJE     = P_MENSAJE
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'hist tasa'
      AND    FECHA       = P_FECHA_HOY;

    ELIF P_COD_RET <> '911' THEN

      /* Se graba código de error en SD_CONTPROC */
      UPDATE SD_CONTPROC
      SET    STATUS_PROC = 'C',
             HORA_FIN    = CURRENT,
             COD_RET     = P_COD_RET,
             MENSAJE     = P_MENSAJE
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'hist tasa'
      AND    FECHA       = P_FECHA_HOY;
    END IF;

    /* ***********  CALCULO DE TASAS  ********** */
    IF P_COD_RET = '00000' THEN

      /* Verifica que no se haya ejecutado el cálculo de nuevas tasas */
      SELECT NVL(MAX(STATUS_PROC), 'N')
      INTO   V_TRABAJO
      FROM   SD_CONTPROC
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'calc tasas'
      AND    FECHA       = P_FECHA_HOY;

      IF V_TRABAJO = 'N' THEN

        BEGIN WORK;
          /* Se graba inicio de proceso en SD_CONTPROC */
          INSERT INTO SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                                   HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
          VALUES (P_EMPRESA, 'calc tasas', P_FECHA_HOY, 'I', P_EJECUTIVO, CURRENT, NULL,
                  NULL, NULL);
        COMMIT WORK;

        /* Calcula nuevas tasas (intereses y moratorios) para los créditos */
        EXECUTE PROCEDURE SP_CALCULA_TASAS (P_EMPRESA, P_FECHA_HOY)
                                      INTO  P_COD_RET, P_MENSAJE;

      ELIF V_TRABAJO = 'C' THEN

        BEGIN WORK;
          UPDATE SD_CONTPROC
          SET    STATUS_PROC = 'I',
                 HORA_INICIO = CURRENT,
                 EJECUTIVO   = P_EJECUTIVO,
                 HORA_FIN    = NULL,
                 COD_RET     = NULL,
                 MENSAJE     = NULL
          WHERE  EMPRESA     = P_EMPRESA
          AND    PROCESO     = 'calc tasas'
          AND    FECHA       = P_FECHA_HOY;

        COMMIT WORK;

        /* Calcula nuevas tasas (intereses y moratorios) para los créditos */
        EXECUTE PROCEDURE SP_CALCULA_TASAS (P_EMPRESA, P_FECHA_HOY)
                                      INTO  P_COD_RET, P_MENSAJE;

      ELIF V_TRABAJO = 'I' THEN
        LET P_COD_RET = '912';
        SELECT DESCRIPCION
        INTO   P_MENSAJE
        FROM   SI_CODRET
        WHERE  SISTEMA = '06'
        AND    CODIGO_RETORNO = P_COD_RET;
      END IF;

      IF P_COD_RET = '00000' THEN
        BEGIN WORK;
          UPDATE SD_CONTPROC
          SET    STATUS_PROC = 'F',
                 HORA_FIN    = CURRENT,
                 COD_RET     = P_COD_RET,
                 MENSAJE     = P_MENSAJE
          WHERE  EMPRESA     = P_EMPRESA
          AND    PROCESO     = 'calc tasas'
          AND    FECHA       = P_FECHA_HOY;
        COMMIT WORK;
      ELIF P_COD_RET <> '912' THEN
        BEGIN WORK;
          UPDATE SD_CONTPROC
          SET    STATUS_PROC = 'C',
                 HORA_FIN    = CURRENT,
                 COD_RET     = P_COD_RET
          WHERE  EMPRESA     = P_EMPRESA
          AND    PROCESO     = 'calc tasas'
          AND    FECHA       = P_FECHA_HOY;

        COMMIT WORK;
      END IF;
    END IF;

    /* ***********  ACTUALIZA FECHAS DE PROXIMA REVISION  ********** */

    IF P_COD_RET = '00000' THEN
      /* Verifica que no se haya ejecutado la actualización de revisión de tasas */
      SELECT NVL(MAX(STATUS_PROC), 'N')
      INTO   V_TRABAJO
      FROM   SD_CONTPROC
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'act tasas'
      AND    FECHA       = P_FECHA_HOY;

      IF V_TRABAJO = 'N' THEN
        BEGIN WORK;
          /* Se graba inicio de proceso en SD_CONTPROC */
          INSERT INTO SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                                   HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
          VALUES (P_EMPRESA, 'act tasas', P_FECHA_HOY, 'I', P_EJECUTIVO, CURRENT,
                  NULL, NULL, NULL);
        COMMIT WORK;

        /* Actualiza fecha de próxima revisión de tasas (SD_REVTASA) */
        EXECUTE PROCEDURE SP_ACTUALIZA_REVTASA (P_EMPRESA, P_FECHA_HOY, P_ANT_POST)
                                          INTO  P_COD_RET, P_MENSAJE;

      ELIF V_TRABAJO = 'C' THEN
        BEGIN WORK;
          UPDATE SD_CONTPROC
          SET    STATUS_PROC = 'I',
                 HORA_INICIO = CURRENT,
                 EJECUTIVO   = P_EJECUTIVO,
                 HORA_FIN    = NULL,
                 COD_RET     = NULL,
                 MENSAJE     = NULL
          WHERE  EMPRESA     = P_EMPRESA
          AND    PROCESO     = 'act tasas'
          AND    FECHA       = P_FECHA_HOY;
        COMMIT WORK;

        /* Actualiza fecha de próxima revisión de tasas (SD_REVTASA) */
        EXECUTE PROCEDURE SP_ACTUALIZA_REVTASA (P_EMPRESA, P_FECHA_HOY, P_ANT_POST)
                                          INTO  P_COD_RET, P_MENSAJE;

      ELIF V_TRABAJO = 'I' THEN
            LET P_COD_RET = '913';
            SELECT DESCRIPCION
            INTO   P_MENSAJE
            FROM   SI_CODRET
            WHERE  SISTEMA = '06'
            AND    CODIGO_RETORNO = P_COD_RET;
      END IF;

      IF P_COD_RET = '00000' THEN
        BEGIN WORK;
            UPDATE SD_CONTPROC
            SET    STATUS_PROC = 'F',
                   HORA_FIN    = CURRENT,
                   COD_RET     = P_COD_RET,
                   MENSAJE     = P_MENSAJE
            WHERE  EMPRESA     = P_EMPRESA
            AND    PROCESO     = 'act tasas'
            AND    FECHA       = P_FECHA_HOY;
        COMMIT WORK;

      ELIF P_COD_RET <> '913' THEN
        BEGIN WORK;
            UPDATE SD_CONTPROC
            SET    STATUS_PROC = 'C',
                   HORA_FIN    = CURRENT,
                   COD_RET     = P_COD_RET,
                   MENSAJE     = P_MENSAJE
            WHERE  EMPRESA     = P_EMPRESA
            AND    PROCESO     = 'act tasas'
            AND    FECHA       = P_FECHA_HOY;
        COMMIT WORK;
      END IF;
    END IF;

    IF P_COD_RET = '00000' THEN
      LET P_MENSAJE = 'PROCESO EXITOSO';
    END IF;

  ELSE  /* VALIDACION DE TASAS INCORRECTA */
    BEGIN WORK;
      SELECT CODIGO_RETORNO, DESCRIPCION
      INTO   P_COD_RET, P_MENSAJE
      FROM   SI_CODRET
      WHERE  SISTEMA = '06'
      AND    CODIGO_RETORNO = '914';

      UPDATE SD_CONTPROC
      SET    STATUS_PROC = 'C',
             HORA_FIN    = CURRENT,
             COD_RET     = P_COD_RET,
             MENSAJE     = P_MENSAJE
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'act tasas'
      AND    FECHA       = P_FECHA_HOY;
    COMMIT WORK;
  END IF;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;