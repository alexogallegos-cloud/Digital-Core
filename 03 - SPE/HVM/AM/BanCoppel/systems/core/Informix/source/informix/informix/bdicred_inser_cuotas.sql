CREATE PROCEDURE "informix".inser_cuotas(
   p_empresa                VARCHAR(3) ,
   pnum_credito           VARCHAR(20),
   pfecha_cuota             DATE       ,
   pmonto_cuota             INTEGER    ,
   pfecha_vencim            DATE       ,
   pajuste_venc_int         VARCHAR(3) ,
   P_AJUSTA_CUOTA           VARCHAR(2) )
RETURNING VARCHAR(10), VARCHAR(80);

DEFINE p_cod_ret   VARCHAR(10);
DEFINE p_mensaje   VARCHAR(80);
DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);

DEFINE vfecha_cuota DATE;
DEFINE v_ya_existe  INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET = SQL_ERR;
      LET P_MENSAJE = ISAM_ERR;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
 
   LET p_cod_ret    = '00000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_ya_existe  = 0;
   LET vfecha_cuota = pfecha_cuota;
   IF P_AJUSTA_CUOTA = 'S' THEN
      EXECUTE PROCEDURE fecha_habil(vfecha_cuota,pfecha_vencim,pajuste_venc_int
                                   ) INTO VFECHA_CUOTA;
   END IF;

   -- YA EXISTE INSERTADA UNA CUOTA CON LA FECHA DE VENCIMIENTO DEL CREDITO,
   -- SE SALE.
   SELECT COUNT(*)
   INTO   v_ya_existe
   FROM   sd_paginter
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito
   AND    fecha_cuota = vfecha_cuota;

   IF v_ya_existe > 0 THEN
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   INSERT INTO sd_paginter (
               EMPRESA                ,
               NUM_CREDITO            ,
               FECHA_CUOTA            ,
               CUOTA_REC              ,
               MONTO_CUOTA            ,
               MONTO_REAL_PAG         ,
               FECHA_PAG              ,
               FACTOR_MORATORIO       ,
               MONTO_MORATORIO        ,
               FECHA_MORATORIO        ,
               DIAS_MORATORIO         ,
               STATUS_MORATORIO       ,
               BONIFI_INT_MORA        ,
               PORC_PAGO              ,
               STATUS_CUOTA           )
   VALUES (    p_empresa,
               pnum_credito,
               vfecha_cuota,
               '1',
               pmonto_cuota,
               0,
               NULL,
               0,
               0,
               NULL,
               0,
               '1',
               'N',
               0,
               '1');

   RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;