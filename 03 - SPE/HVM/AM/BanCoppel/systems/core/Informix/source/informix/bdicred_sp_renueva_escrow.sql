CREATE PROCEDURE "informix".sp_renueva_escrow(P_EMPRESA   VARCHAR(3))
       RETURNING VARCHAR(5), VARCHAR(80);

DEFINE P_COD_RET  VARCHAR(5);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE V_FECHA_HOY    DATE;
DEFINE V_NVAFECHA     DATE;
DEFINE V_FECHA_CUOTA  DATE;
DEFINE V_PLAZO        INTEGER;
DEFINE V_SALDO        DECIMAL(18,2);

DEFINE V_NUM_CREDITO     VARCHAR(20);
DEFINE V_FECHA_VENC_SEG  DATE;
DEFINE V_COD_COMIS       VARCHAR(4);
DEFINE V_MONTO_POLIZA    DECIMAL(18,2);
DEFINE V_MONTO_MENSUAL   DECIMAL(18,2);

DEFINE V_TRABAJO0  VARCHAR(1);
DEFINE V_TRABAJO   VARCHAR(1);

DEFINE V_MES     INTEGER;
DEFINE V_DIA     INTEGER;
DEFINE V_ANIO    INTEGER;
DEFINE V_NUMREG  INTEGER;

DEFINE  SQL_ERR    INTEGER;
DEFINE  ISAM_ERR   INTEGER;
DEFINE  ERROR_INFO VARCHAR(80);

DEFINE ax_hoy      DATE;
DEFINE ax_ultimo   DATE;
DEFINE V_CURRENT   DATETIME HOUR TO FRACTION;



BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
    LET P_COD_RET = SQL_ERR;
    LET P_MENSAJE = ERROR_INFO;
    UPDATE SD_CONTPROC
    SET    STATUS_PROC = 'F',  --'C',
           HORA_FIN    = V_CURRENT,
           COD_RET     = P_COD_RET,
           MENSAJE     = P_MENSAJE
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'escrow'
    AND    FECHA       = V_FECHA_HOY;

    RETURN P_COD_RET, P_MENSAJE;
  END EXCEPTION;


  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  LET V_PLAZO   = 1;
  LET V_SALDO   = 0;
  LET V_NUMREG  = 0;
  LET V_FECHA_HOY = TODAY;



  SELECT CURRENT + 5 UNITS MINUTE
    INTO V_CURRENT
    FROM DUAL;


  SELECT FECHA_HOY INTO V_FECHA_HOY FROM SD_FECHAS WHERE EMPRESA = P_EMPRESA;

-------------------------------------------

    SELECT NVL(MAX(STATUS_PROC), 'N')
    INTO   V_TRABAJO
    FROM   SD_CONTPROC
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'escrow'
    AND    FECHA       = V_FECHA_HOY;

    IF V_TRABAJO = 'N' THEN

      INSERT INTO
      SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                   HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
           VALUES (P_EMPRESA, 'escrow', V_FECHA_HOY, 'F', USER,
                   V_CURRENT, V_CURRENT, P_COD_RET, P_MENSAJE);

	RETURN P_COD_RET, P_MENSAJE;

    ELIF V_TRABAJO = 'F' THEN
      LET P_COD_RET = '00000';
      LET P_MENSAJE = 'Ya se ejecuto el proceso';

    ELIF V_TRABAJO = 'I' THEN
      LET P_COD_RET = '00000951';
      LET P_MENSAJE = 'Ya se ejecuto el proceso';

    ELIF V_TRABAJO = 'C' THEN
      UPDATE SD_CONTPROC
      SET    STATUS_PROC = 'F',
             HORA_INICIO = V_CURRENT
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'escrow'
      AND    FECHA       = V_FECHA_HOY;

    END IF;
    
    RETURN P_COD_RET, P_MENSAJE;


-------------------------------------------



  SELECT NVL(MAX(STATUS_PROC), 'N')
  INTO   V_TRABAJO0
  FROM   SD_CONTPROC
  WHERE  EMPRESA     = P_EMPRESA
  AND    PROCESO     = 'provision mora'
  AND    FECHA       = V_FECHA_HOY;



  IF V_TRABAJO0 = 'F' THEN

    SELECT NVL(MAX(STATUS_PROC), 'N')
    INTO   V_TRABAJO
    FROM   SD_CONTPROC
    WHERE  EMPRESA     = P_EMPRESA
    AND    PROCESO     = 'escrow'
    AND    FECHA       = V_FECHA_HOY;

    IF V_TRABAJO = 'N' THEN

      INSERT INTO
      SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                   HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
           VALUES (P_EMPRESA, 'escrow', V_FECHA_HOY, 'I', USER,
                   V_CURRENT, NULL, NULL, NULL);

    ELIF V_TRABAJO = 'F' THEN
      LET P_COD_RET = '950';
      LET P_MENSAJE = 'Ya se ejecuto el proceso';

    ELIF V_TRABAJO = 'I' THEN
      LET P_COD_RET = '951';
      LET P_MENSAJE = 'El proceso se esta ejecutando';

    ELIF V_TRABAJO = 'C' THEN
      UPDATE SD_CONTPROC
      SET    STATUS_PROC = 'I',
             HORA_INICIO = V_CURRENT
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'escrow'
      AND    FECHA       = V_FECHA_HOY;

    END IF;

      FOREACH SELECT NUM_CREDITO, FECHA_VENC_SEG, COD_COMIS
                    ,MONTO_POLIZA, MONTO_MENSUAL, PLAZO, SALDO
                INTO V_NUM_CREDITO, V_FECHA_VENC_SEG, V_COD_COMIS
                    ,V_MONTO_POLIZA, V_MONTO_MENSUAL, V_PLAZO, V_SALDO
                FROM SD_ESCROW SCR
               WHERE PLAZO > 1
                 AND SCR.FECHA_VENC_SEG = V_FECHA_HOY
                 AND SCR.EMPRESA = P_EMPRESA
                 AND NOT EXISTS (SELECT '1' FROM SD_DETCOMI
                              WHERE FECHA_ALTA > V_FECHA_HOY
                                AND COD_COMIS = SCR.COD_COMIS
                                AND NUM_CREDITO = SCR.NUM_CREDITO
                                AND EMPRESA = SCR.EMPRESA)

		CONTINUE FOREACH;

        IF V_SALDO < 0 THEN
          LET V_MONTO_POLIZA = V_MONTO_POLIZA + V_SALDO;
          LET V_MONTO_MENSUAL = V_MONTO_POLIZA / V_PLAZO;
        END IF;

        LET V_MES  = MONTH(V_FECHA_VENC_SEG) + V_PLAZO;
        LET V_DIA  = DAY(V_FECHA_VENC_SEG);
        LET V_ANIO = YEAR(V_FECHA_VENC_SEG);

        IF V_MES > 12 THEN
          LET V_ANIO = V_ANIO + 1;
          LET V_MES  = V_MES - 12;
        END IF;

        IF V_MES = 2 AND V_DIA = 29 THEN
          LET V_NVAFECHA = MDY(2,28,V_ANIO);

        ELSE
          LET V_NVAFECHA = MDY(V_MES,V_DIA,V_ANIO);
        END IF;

        --ACTUALIZA EL MAESTRO DE ESCROW
        UPDATE SD_ESCROW
           SET FECHA_VENC_SEG = V_NVAFECHA
              ,TEXTO          = 'GENERADO AUTOMATICAMENTE'
              ,MONTO_POLIZA   = V_MONTO_POLIZA
              ,MONTO_MENSUAL  = V_MONTO_MENSUAL
         WHERE COD_COMIS = V_COD_COMIS
           AND NUM_CREDITO = V_NUM_CREDITO
           AND EMPRESA = P_EMPRESA;

        --INSERTA LOS NUEVOS PLANES DE SEGURO EN SD_DETCOMIS
        --CON LOS ULTIMOS DATOS CONOCIDOS Y ACORDE A LOS PLANES DE CAPITAL
        FOREACH SELECT FECHA_CUOTA
                  INTO V_FECHA_CUOTA
                  FROM SD_PAGINTER
                 WHERE FECHA_CUOTA > V_FECHA_HOY
                   AND FECHA_CUOTA < V_NVAFECHA
                   AND NUM_CREDITO = V_NUM_CREDITO
                   AND EMPRESA = P_EMPRESA

          INSERT INTO SD_DETCOMI
                (empresa, cod_comis, num_credito, fecha_alta, fecha_pago
                ,monto_com, monto_pag, apli_factor, estado_com, num_solicitud
                ,user_insert,fecha_insert)
          VALUES(P_EMPRESA,V_COD_COMIS, V_NUM_CREDITO, V_FECHA_CUOTA, NULL
                ,V_MONTO_MENSUAL, 0, 0, 'P',NULL
                ,USER,TODAY);
          LET V_NUMREG = V_NUMREG + 1;
        END FOREACH;

        IF V_NUMREG < V_PLAZO AND V_NUMREG > 0 THEN
          SELECT MIN(FECHA_CUOTA)
            INTO V_FECHA_CUOTA
            FROM SD_PAGINTER
           WHERE FECHA_CUOTA > V_FECHA_CUOTA
             AND NUM_CREDITO = V_NUM_CREDITO
             AND EMPRESA = P_EMPRESA;

          IF V_FECHA_CUOTA IS NOT NULL  OR V_FECHA_CUOTA <> '' THEN
            INSERT INTO SD_DETCOMI
                (empresa, cod_comis, num_credito, fecha_alta, fecha_pago
                ,monto_com, monto_pag, apli_factor, estado_com, num_solicitud
                ,user_insert,fecha_insert)
            VALUES(P_EMPRESA,V_COD_COMIS, V_NUM_CREDITO, V_FECHA_CUOTA, NULL
                ,V_MONTO_MENSUAL, 0, 0, 'P',NULL
                ,USER,TODAY);
          END IF;
        END IF;
      END FOREACH;

     -- ********************************************************************
     -- *     Realiza pase de movimientos para edos de cta INSTA CASH      *
     -- ********************************************************************
     SELECT fecha_hoy, ult_hab_mes
       INTO ax_hoy, ax_ultimo
       FROM sd_fechas;

     --IF ax_hoy = ax_ultimo THEN

--        IF P_COD_RET <> "00000" THEN
--	    LET P_MENSAJE ="Pase Movimientos Edo Cta INSTA";
--	END IF
 --    END IF

    IF P_COD_RET = '00000' THEN
      UPDATE SD_CONTPROC
      SET    STATUS_PROC = 'F',
             HORA_FIN    = V_CURRENT,
             COD_RET     = P_COD_RET,
             MENSAJE     = P_MENSAJE
      WHERE  EMPRESA     = P_EMPRESA
      AND    PROCESO     = 'escrow'
      AND    FECHA       = V_FECHA_HOY;
    END IF;
  ELSE
     /* Es necesario realizar el traspaso a cartera vencida antes de la provisión */
     LET P_COD_RET = '959';
     LET P_MENSAJE = 'Es necesario realizar la provisión de moratorios';

     INSERT INTO SD_CONTPROC (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
                              HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
     VALUES (P_EMPRESA, 'escrow', V_FECHA_HOY, 'C', USER, V_CURRENT,
             TODAY, P_COD_RET, P_MENSAJE);
  END IF;

  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;