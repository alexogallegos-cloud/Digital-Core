CREATE PROCEDURE "informix".sp_valida_tasas_del_dia(P_EMPRESA          VARCHAR(3),
       P_FECHA_HOY        DATE,
       P_EJECUTIVO        VARCHAR(8)
      ) RETURNING VARCHAR(6), VARCHAR(80);
      
DEFINE  P_COD_RET  VARCHAR(10);
DEFINE  P_MENSAJE  VARCHAR(80);
DEFINE  V_COD_TASA_BASE LIKE SD_MAECRED.COD_TASA_BASE;
DEFINE  V_CONT     INTEGER;
DEFINE  V_TABLAS   CHAR(1000);
DEFINE  V_TRABAJO  VARCHAR(1);
DEFINE  V_TASA     LIKE SD_MAECRED.COD_TASA_BASE;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);

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
     AND    PROCESO     = 'valid tasa'
     AND    FECHA       = P_FECHA_HOY;

     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;

  LET V_CONT = 0;
  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';

  SELECT NVL(MAX(STATUS_PROC), 'N')
  INTO   V_TRABAJO
  FROM   SD_CONTPROC
  WHERE  EMPRESA     = P_EMPRESA
  AND    PROCESO     = 'valid tasa'
  AND    FECHA       = P_FECHA_HOY;

  IF V_TRABAJO = 'N' THEN
    INSERT INTO SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                             HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
    VALUES (P_EMPRESA, 'valid tasa', P_FECHA_HOY, 'I', P_EJECUTIVO, CURRENT, NULL,
            NULL, NULL);
  ELSE
    UPDATE SD_CONTPROC
    SET    STATUS_PROC = 'I',
           HORA_INICIO = CURRENT,
           EJECUTIVO   = P_EJECUTIVO,
           HORA_FIN    = NULL,
           COD_RET     = NULL,
           MENSAJE     = NULL
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'valid tasa'
    AND    FECHA       = P_FECHA_HOY;

    DELETE FROM SD_LOG_REVTASA
    WHERE  EMPRESA = P_EMPRESA
    AND    FECHA   = P_FECHA_HOY;
  END IF;

  FOREACH V_REG FOR SELECT DISTINCT M.COD_TASA_BASE  TASA
                    INTO   V_TASA
                    FROM   SD_MAECRED M,
                           SD_REVTASA R
                    WHERE  M.EMPRESA         = R.EMPRESA
                    AND    M.NUM_CREDITO     = R.NUM_CREDITO
                    AND    NOT EXISTS (SELECT '1'
                                       FROM   SI_TIPTASA T,
                                              SI_FECHAVALOR F
                                       WHERE  M.EMPRESA       = T.EMPRESA
                                       AND    M.COD_TASA_BASE = T.TASA
                                       AND    T.RANGOFECHA    = 'F'
                                       AND    T.TASA          = F.TASA
                                       AND    T.EMPRESA       = F.EMPRESA
                                       AND    F.FECHA         = P_FECHA_HOY
                                       AND    F.EMPRESA       = P_EMPRESA)
                    AND    M.TASA_FIJA_O_VAR  = '2'
                    AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                    AND    M.BANDERA_MINISTRA = 'M'
                    AND    R.FECHA_PROX_REV   = P_FECHA_HOY
                    AND    R.EMPRESA          = P_EMPRESA

    LET V_CONT = V_CONT + 1;
    IF V_CONT = 1 THEN
      LET V_TABLAS = V_TASA;
    ELSE
      LET V_TABLAS = V_TABLAS || ', ' || V_TASA;
    END IF;
    
    INSERT INTO SD_LOG_REVTASA (EMPRESA, FECHA, TASA, COMENTARIO)
    VALUES (P_EMPRESA, P_FECHA_HOY, V_TASA, 'NO EXISTE SU VALOR EN SI_FECHAVALOR');
  END FOREACH;

  FOREACH V_REG FOR SELECT DISTINCT M.COD_TASA_MORA TASA
                    INTO   V_TASA
                    FROM   SD_MAECRED M,
                           SD_REVTASA R
                    WHERE  M.EMPRESA         = R.EMPRESA
                    AND    M.NUM_CREDITO     = R.NUM_CREDITO
                    AND    NOT EXISTS (SELECT '1'
                                       FROM   SI_TIPTASA T,
                                              SI_FECHAVALOR F
                                       WHERE  M.EMPRESA       = T.EMPRESA
                                       AND    M.COD_TASA_MORA = T.TASA
                                       AND    T.RANGOFECHA    = 'F'
                                       AND    T.TASA          = F.TASA
                                       AND    F.FECHA         = P_FECHA_HOY
                                       AND    F.EMPRESA       = P_EMPRESA)
                    AND    M.TASA_FIJA_O_VAR  = '2'
                    AND    SUBSTR(M.STATUS_CRED, 1, 1) NOT IN ('C', 'F', 'O')
                    AND    M.BANDERA_MINISTRA = 'M'
                    AND    M.COD_TASA_MORA   <> 'ORDI'
                    AND    R.FECHA_PROX_REV   = P_FECHA_HOY
                    AND    R.EMPRESA          = P_EMPRESA

    LET V_CONT = V_CONT + 1;
    IF V_CONT = 1 THEN
      LET V_TABLAS = V_TASA;
    ELSE
      LET V_TABLAS = V_TABLAS || ', ' || V_TASA;
    END IF;

    BEGIN
      ON EXCEPTION IN (-268)
        LET V_CONT = V_CONT;
      END EXCEPTION WITH RESUME;
    
      INSERT INTO SD_LOG_REVTASA (EMPRESA, FECHA, TASA, COMENTARIO)
      VALUES (P_EMPRESA, P_FECHA_HOY, V_TASA, 'NO EXISTE SU VALOR EN SI_FECHAVALOR');
    END;
  END FOREACH;

  IF V_CONT > 0 THEN
    LET P_COD_RET = '910';
    SELECT TRIM(DESCRIPCION) || ' ' || TRIM(V_TABLAS)
    INTO   P_MENSAJE
    FROM   BDINTEG:SI_CODRET
    WHERE  CODIGO_RETORNO = P_COD_RET
    AND    SISTEMA = '06';

    UPDATE SD_CONTPROC
    SET    STATUS_PROC = 'C',
           HORA_FIN    = CURRENT,
           COD_RET     = P_COD_RET,
           MENSAJE     = P_MENSAJE
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'valid tasa'
    AND    FECHA       = P_FECHA_HOY;
  ELSE
    UPDATE SD_CONTPROC
    SET    STATUS_PROC = 'F',
           HORA_FIN    = CURRENT,
           COD_RET     = P_COD_RET,
           MENSAJE     = P_MENSAJE
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'valid tasa'
    AND    FECHA       = P_FECHA_HOY;
  END IF;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;