CREATE PROCEDURE "informix".ins_cuotas(
   p_empresa                VARCHAR(3)  ,
   pnum_credito           VARCHAR(20) ,
   pfecha_cuota             DATE        ,
   pmonto_cuota             INTEGER     ,
   pfecha_vencim            DATE        ,
   pajuste_vencim           VARCHAR(3)  ,
   PTIPO_AJUSTE             VARCHAR(2)  )
RETURNING VARCHAR(10), VARCHAR(80);

--   p_cod_ret            OUT VARCHAR2 ,
--   p_mensaje            OUT VARCHAR2 )

DEFINE   v_ya_existe  INTEGER;
DEFINE   vfecha_cuota date;
DEFINE   P_COD_RET   VARCHAR(10);
DEFINE   P_MENSAJE   VARCHAR(80);

BEGIN


   LET vfecha_cuota = pfecha_cuota;
   LET p_cod_ret = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET v_ya_existe = 0;
   
   IF pajuste_vencim = 'S' THEN
      EXECUTE PROCEDURE fecha_habil(vfecha_cuota,pfecha_vencim,pTIPO_AJUSTE) into vfecha_cuota;
   END IF;
			
   -- YA EXISTE INSERTADA UNA CUOTA CON LA FECHA DE VENCIMIENTO DEL CREDITO,
   -- SE SALE.
   SELECT COUNT(*)
   INTO   v_ya_existe
   FROM   SD_PAGOCAPIT
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito
   AND    fecha_cuota = pfecha_cuota;

   IF v_ya_existe > 0 THEN
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   INSERT INTO SD_PAGOCAPIT (
          EMPRESA                ,
          NUM_CREDITO            ,
          FECHA_CUOTA            ,
          CUOTA_REC              ,
          MONTO_CUOTA            ,
          SALDO_CUOTA            ,
          IMP_CAPITALIZADO       ,
          FACTOR_AJUSTE          ,
          MONTO_REAL_PAG         ,
          FECHA_PAGO             ,
          FACTOR_MORATORIO       ,
          MONTO_MORATORIO        ,
          FECHA_MORATORIO        ,
          DIAS_MORATORIOS        ,
          STATUS_MORATORIO       ,
          NUM_PAGARES            ,   --BONIFI_INT_MORA 
          PORC_PAGO              ,
          BANDERA_MINISTRA       ,   --MONTO_MINISTRADO 
          STATUS_CUOTA           )
   VALUES (
          p_empresa,
          pnum_credito,
          vfecha_cuota,
          '1',
          pmonto_cuota,
          0,
          0,
          0,
          0,
          NULL,
          0,
          0,
          NULL,
          0,
          '1',
          0,    --'N',
          0,
          'P',  --0,
          '1');
  RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;