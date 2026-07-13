CREATE PROCEDURE "informix".genera_mov_dia_minis(P_EMPRESA           VARCHAR(3) ,
                                       P_NUM_CREDITO       VARCHAR(20),
		                           P_MONTO             INTEGER,
                                       P_FOLIO             VARCHAR(16)
                                      ) RETURNING VARCHAR(10), VARCHAR(80);


DEFINE P_COD_RET VARCHAR(10);
DEFINE P_MENSAJE VARCHAR(80);

DEFINE V_FECHA_HOY       DATE;
DEFINE V_FOLIO_SUC       VARCHAR(16);
DEFINE V_SUCURSAL        LIKE SD_MAECRED.SUCURSAL;
DEFINE V_DIVISA          LIKE SD_MAECRED.DIVISA;
DEFINE V_NUM_PRODUCTO    LIKE SD_MAECRED.NUM_PRODUCTO;
DEFINE V_TRANSACC_SUC    VARCHAR(4); --:= '0000';
DEFINE V_MONTO_MOV       INTEGER;
DEFINE V_CODIGO_FUN_DES  LIKE SD_TRANSFUN.CODIGO_FUN;  --:='002';
DEFINE V_CODIGO_FUN_COM  LIKE SD_TRANSFUN.CODIGO_FUN;  --:='039';
DEFINE V_EXIST_REF       INTEGER;

DEFINE V_CODIGO_INS    LIKE SD_FUENTES_X_CRED.CODIGO_INS;
DEFINE V_PORCENT_PART  LIKE SD_FUENTES_X_CRED.PORCENT_PART;
DEFINE V_CODIGO_REF    LIKE SD_TRANSFUN.CODIGO_REF;
DEFINE V_CANTIDAD      INTEGER;

DEFINE V_COD_COMIS     LIKE SD_DETCOMI.COD_COMIS;
DEFINE V_MONTO_COM     LIKE SD_DETCOMI.MONTO_COM;

BEGIN
   LET  P_COD_RET         = '00000';
   LET  P_MENSAJE         = 'PROCESO EXITOSO';
   LET  V_FOLIO_SUC       = P_FOLIO;
   LET  V_TRANSACC_SUC    = '0000';
   LET  V_CODIGO_FUN_DES  = '002';
   LET  V_CODIGO_FUN_COM  = '039';


   --OBTIENE LA FECHA DEL SISTEMA
   SELECT FECHA_HOY
   INTO   V_FECHA_HOY
   FROM   SD_FECHAS
   WHERE  EMPRESA = P_EMPRESA;

   --SELECCIONA EL NUMERO DE PRODUCTO, EL FOLIO_SUC, LA SUCURSAL, LA DIVISA
   SELECT NUM_PRODUCTO, SUCURSAL, DIVISA
   INTO   V_NUM_PRODUCTO, V_SUCURSAL, V_DIVISA
   FROM   SD_MAECRED
   WHERE  EMPRESA     = P_EMPRESA
   AND    NUM_CREDITO = P_NUM_CREDITO;

   --EJECUTA LA GENERACION DEL MOVIMIENTO PARA EL IMPORTE DEL DESEMBOLSO
   FOREACH I FOR SELECT FTE.CODIGO_INS, FTE.PORCENT_PART, MIN(TRA.CODIGO_REF) CODIGO_REF, COUNT(TRA.CODIGO_REF) CANTIDAD
                 INTO   V_CODIGO_INS
                      , V_PORCENT_PART
                      , V_CODIGO_REF
                      , V_CANTIDAD
                 FROM   SD_FUENTES_X_CRED FTE
                       ,SD_TRANSFUN       TRA
                 WHERE  TRA.CODIGO_INS  = FTE.CODIGO_INS
                 AND    TRA.EMPRESA     = FTE.EMPRESA
                 AND    TRA.CODIGO_FUN  = V_CODIGO_FUN_DES
                 AND    FTE.EMPRESA     = P_EMPRESA
                 AND    FTE.NUM_CREDITO = P_NUM_CREDITO
                 GROUP BY FTE.CODIGO_INS, FTE.PORCENT_PART


      IF V_CANTIDAD > 1 THEN
         LET P_COD_RET = '00001';
         LET P_MENSAJE = 'El Cred NO Tiene un Cod Funcion bien definido';

         DELETE FROM SD_MOVDIA
         WHERE NUM_CREDITO = P_NUM_CREDITO
         AND   FECHA_MOV   = V_FECHA_HOY
         AND   FOLIO_SUC   = V_FOLIO_SUC;

         RETURN P_COD_RET, P_MENSAJE;

      ELSE
         LET V_MONTO_MOV = P_MONTO * (V_PORCENT_PART / 100);
         EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_NUM_CREDITO
                                 , V_NUM_PRODUCTO    , V_CODIGO_REF
                                 , V_CODIGO_FUN_DES  , V_FECHA_HOY
                                 , V_MONTO_MOV       , V_FOLIO_SUC
                                 , V_SUCURSAL        , V_DIVISA
                                 , V_TRANSACC_SUC
                                 ) INTO P_COD_RET, P_MENSAJE;
      END IF;
   END FOREACH;
{
   IF P_COD_RET = '00000' THEN
      --GENERA EL MOVIMEINTO CONTABLE DE LAS DEDUCCIONES, EN CASO DE SER NECESARIO
      FOREACH I FOR SELECT COD_COMIS
                         , MONTO_COM
                    INTO   V_COD_COMIS
                         , V_MONTO_COM
                    FROM   SD_DETCOMI
                    WHERE  ESTADO_COM  = 'P'
                    AND    EMPRESA     = P_EMPRESA
                    AND    NUM_CREDITO = P_NUM_CREDITO

         BEGIN
         ON EXCEPTION
             LET P_COD_RET = '00120';
             LET P_MENSAJE = 'La Com para el Cred NO tiene un Cod Ref VALIDO';

             DELETE FROM SD_MOVDIA
             WHERE NUM_CREDITO = P_NUM_CREDITO
             AND   FECHA_MOV   = V_FECHA_HOY
             AND   FOLIO_SUC   = V_FOLIO_SUC;

             RETURN P_COD_RET, P_MENSAJE;
         END EXCEPTION;

            SELECT  COUNT(*)
            INTO    V_EXIST_REF
            FROM    SD_TRANSFUN
            WHERE   EMPRESA    = P_EMPRESA
            AND     CODIGO_REF = V_COD_COMIS
            AND     CODIGO_FUN = V_CODIGO_FUN_COM;

            IF V_EXIST_REF IS NULL THEN
               LET P_COD_RET = '00110';
               LET P_MENSAJE = 'La Com para el Cred NO Tiene un Cod Ref VALIDO';

               DELETE FROM SD_MOVDIA
               WHERE NUM_CREDITO = P_NUM_CREDITO
               AND   FECHA_MOV   = V_FECHA_HOY
               AND   FOLIO_SUC   = V_FOLIO_SUC;

               RETURN P_COD_RET, P_MENSAJE;
            END IF;

            IF V_EXIST_REF <> 1 THEN
               LET P_COD_RET = '00100';
               LET P_MENSAJE = 'La Com. del Cred NO tiene un Cod Referencia VALIDO';

               DELETE FROM SD_MOVDIA
               WHERE NUM_CREDITO = P_NUM_CREDITO
               AND   FECHA_MOV   = V_FECHA_HOY
               AND   FOLIO_SUC   = V_FOLIO_SUC;

               RETURN P_COD_RET, P_MENSAJE;
            ELSE
               EXECUTE PROCEDURE GENMOV( P_EMPRESA	    , P_NUM_CREDITO
                                      , V_NUM_PRODUCTO    , V_COD_COMIS
                                      , V_CODIGO_FUN_COM  , V_FECHA_HOY
                                      , V_MONTO_COM       , V_FOLIO_SUC
                                      , V_SUCURSAL        , V_DIVISA
                                      , V_TRANSACC_SUC
                                      )INTO P_COD_RET, P_MENSAJE;

               --ACTUALIZA EL DETALLE DE LAS COMISIONES
               IF P_COD_RET = '00000' THEN
                  UPDATE SD_DETCOMI
                  SET    FECHA_PAGO = V_FECHA_HOY
                        ,ESTADO_COM = 'A'
                  WHERE  COD_COMIS   = V_COD_COMIS
                  AND    NUM_CREDITO = P_NUM_CREDITO
                  AND    EMPRESA     = P_EMPRESA;
               END IF;
            END IF;
         END;
      END FOREACH;
   END IF;
}

   IF P_COD_RET <> '00000' THEN
      DELETE FROM SD_MOVDIA
      WHERE NUM_CREDITO = P_NUM_CREDITO
      AND   FECHA_MOV   = V_FECHA_HOY
      AND   FOLIO_SUC   = V_FOLIO_SUC;
   END IF;

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;