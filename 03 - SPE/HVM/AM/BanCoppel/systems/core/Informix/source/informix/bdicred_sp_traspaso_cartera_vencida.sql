CREATE PROCEDURE "informix".sp_traspaso_cartera_vencida(P_EMPRESA          VARCHAR(3),
       P_FECHA_HOY        DATE,
       P_EJECUTIVO        VARCHAR(8)
      )RETURNING VARCHAR(5),VARCHAR(80);

DEFINE P_COD_RET  VARCHAR(5);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE V_TRABAJO  VARCHAR(1);

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
     AND    PROCESO     = 'trasp cart venc'
     AND    FECHA       = P_FECHA_HOY;

     ROLLBACK WORK;
     RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;


  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';

  SELECT NVL(MAX(STATUS_PROC), 'N')
  INTO   V_TRABAJO
  FROM   SD_CONTPROC
  WHERE  EMPRESA     = P_EMPRESA
  AND    PROCESO     = 'trasp cart venc'
  AND    FECHA       = P_FECHA_HOY;

  IF V_TRABAJO = 'N' THEN
    BEGIN WORK;  
       INSERT INTO SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                                  HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
         VALUES (P_EMPRESA, 'trasp cart venc', P_FECHA_HOY, 'I', P_EJECUTIVO, CURRENT, NULL,
                 NULL, NULL);
    COMMIT WORK;
    /* Paso de interés vencido (transitorio) a interés vencido traspasado */
    EXECUTE PROCEDURE SP_INT_VENCIDO_INT_TRASPASADO (P_EMPRESA, P_FECHA_HOY, P_EJECUTIVO)
                                               INTO  P_COD_RET, P_MENSAJE;

      IF P_COD_RET = '00000' THEN
        /* Paso de interés vigente a interés vencido traspasado */
        EXECUTE PROCEDURE SP_INT_VIGENTE_INT_TRASPASADO (P_EMPRESA, P_FECHA_HOY, P_EJECUTIVO)
                                                   INTO  P_COD_RET, P_MENSAJE;
      END IF;

      IF P_COD_RET = '00000' THEN
        /* Paso de interés vigente a interés vencido (transitorio) */
        EXECUTE PROCEDURE SP_INT_VIGENTE_INT_VENCIDO (P_EMPRESA, P_FECHA_HOY, P_EJECUTIVO)
                                                INTO  P_COD_RET, P_MENSAJE;
      END IF;

      IF P_COD_RET = '00000' THEN
        /* Paso de capital vencido (transitorio) a capital vencido traspasado */
        EXECUTE PROCEDURE SP_CAP_VENCIDO_CAP_TRASPASADO(P_EMPRESA, P_FECHA_HOY, P_EJECUTIVO)
                                                   INTO P_COD_RET, P_MENSAJE;
      END IF;

      IF P_COD_RET = '00000' THEN
        /* Paso de capital vigente a capital vencido traspasado */
        EXECUTE PROCEDURE SP_CAP_VIGENTE_CAP_TRASPASADO(P_EMPRESA, P_FECHA_HOY, P_EJECUTIVO)
                                                   INTO P_COD_RET, P_MENSAJE;
      END IF;

      IF P_COD_RET = '00000' THEN
        /* Paso de capital vigente a capital vencido traspasado */
        EXECUTE PROCEDURE SP_CAP_VIGENTE_CAP_VENCIDO(P_EMPRESA, P_FECHA_HOY, P_EJECUTIVO)
                                                INTO P_COD_RET, P_MENSAJE;
      END IF;

      IF P_COD_RET = '00000' THEN
        BEGIN WORK;
          UPDATE SD_CONTPROC
          SET    STATUS_PROC = 'F',
                 HORA_FIN    = CURRENT,
                 COD_RET     = P_COD_RET,
                 MENSAJE     = P_MENSAJE
          WHERE  EMPRESA     = P_EMPRESA
          AND    PROCESO     = 'trasp cart venc'
          AND    FECHA       = P_FECHA_HOY;
        COMMIT WORK;
      ELSE
        BEGIN WORK;
          UPDATE SD_CONTPROC
          SET    STATUS_PROC = 'C',
                 HORA_FIN    = CURRENT,
                 COD_RET     = P_COD_RET,
                 MENSAJE     = P_MENSAJE
          WHERE  EMPRESA     = P_EMPRESA
          AND    PROCESO     = 'trasp cart venc'
          AND    FECHA       = P_FECHA_HOY;
        COMMIT WORK;
      END IF;
  ELIF V_TRABAJO = 'F' THEN  /* El proceso ya corrió */
         LET P_COD_RET = '00003';
         LET P_MENSAJE = 'EL PROCESO YA FUE EJECUTADO';
  ELIF V_TRABAJO = 'I' THEN  /* El proceso está en ejecución */
         LET P_COD_RET = '00002';
         LET P_MENSAJE = 'EL PROCESO ESTA EN EJECUCION';
  ELSE  /* El proceso ya corrió y terminó con error */
         LET P_COD_RET = '00003';
         LET P_MENSAJE = 'EL PROCESO YA FUE EJECUTADO Y TERMINO CON ERROR';
  END IF;
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;