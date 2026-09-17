CREATE PROCEDURE "informix".importes(
   p_empresa                VARCHAR(3) ,
   pnum_credito           VARCHAR(20),
   pajuste_de_cuota         VARCHAR(3) ,
   pcuota_con_dec           VARCHAR(3) ,
   pmonto_linea             INTEGER    )
RETURNING  VARCHAR(10), VARCHAR(80);
--   p_cod_ret            OUT VARCHAR2 ,
--   p_mensaje            OUT VARCHAR2 )

DEFINE P_COD_RET   VARCHAR(10);
DEFINE P_MENSAJE   VARCHAR(80);
DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);

DEFINE v_imp_dec   DECIMAL(18,2);
DEFINE v_imp_tot   DECIMAL(18,2);
DEFINE V_NUM_REG   INTEGER;
DEFINE V_FECHA_MIN DATE;
DEFINE V_FECHA_MAX DATE;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET = SQL_ERR;
      LET P_MENSAJE = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION

   LET p_cod_ret  = '00000';
   LET P_MENSAJE  = 'PROCESO EXITOSO';
   LET V_IMP_DEC  = 0;
   LET V_IMP_TOT  = 0;
   LET V_NUM_REG  = 1;

   SELECT COUNT(*) 
   INTO   V_NUM_REG
   FROM   SD_PAGOCAPIT
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;
			
   UPDATE SD_PAGOCAPIT
   SET    MONTO_CUOTA = PMONTO_LINEA / V_NUM_REG
   WHERE  empresa     = p_empresa
   AND    num_credito = pnum_credito;
			
   IF PCUOTA_CON_DEC = 'S' THEN
      SELECT PMONTO_LINEA - SUM(MONTO_CUOTA)
	INTO   V_IMP_TOT
	FROM   SD_PAGOCAPIT
      WHERE  empresa       = p_empresa
      AND    num_credito = pnum_credito;
				
      SELECT MAX(fecha_cuota)
      INTO   V_FECHA_MAX
      FROM   SD_PAGOCAPIT
      WHERE  empresa       = p_empresa
      AND    num_credito = pnum_credito;
		
      UPDATE SD_PAGOCAPIT
      SET    monto_cuota   = monto_cuota + V_IMP_TOT
      WHERE  empresa     = p_empresa
      AND    num_credito = pnum_credito
      AND    fecha_cuota = V_FECHA_MAX;

   ELSE
      --selecciona el importe de las fracciones de cada cuota
      SELECT sum(mod(monto_cuota,1)), SUM(MONTO_CUOTA) 
      INTO   v_imp_dec, V_IMP_TOT
      FROM   SD_PAGOCAPIT
      WHERE  empresa     = p_empresa
      AND    num_credito = pnum_credito;
			
	--Actualiza el monto 
      UPDATE SD_PAGOCAPIT
      SET    MONTO_CUOTA   = MONTO_CUOTA - MOD(MONTO_CUOTA,1)
      WHERE  empresa       = p_empresa
      AND    num_credito = pnum_credito;

      --Actualiza la ultima y primera cuota, segun sea el caso
      IF pajuste_de_cuota = 'P' THEN
         
         SELECT MIN(fecha_cuota)
         INTO   V_FECHA_MIN
         FROM   SD_PAGOCAPIT
         WHERE  empresa     = p_empresa
         AND    num_credito = pnum_credito;

         UPDATE SD_PAGOCAPIT
         SET    monto_cuota   = monto_cuota + ((PMONTO_LINEA-V_IMP_TOT) + V_IMP_DEC)
         WHERE  empresa     = p_empresa
         AND    num_credito = pnum_credito
         AND    fecha_cuota = V_FECHA_MIN;

      ELSE
         SELECT MAX(fecha_cuota)
         INTO   V_FECHA_MAX
         FROM   SD_PAGOCAPIT
         WHERE  empresa     = p_empresa
         AND    num_credito = pnum_credito;

         UPDATE SD_PAGOCAPIT
         SET    monto_cuota   = monto_cuota + ((PMONTO_LINEA-V_IMP_TOT) + V_IMP_DEC)
         WHERE  empresa     = p_empresa
         AND    num_credito = pnum_credito
         AND    fecha_cuota = V_FECHA_MAX;
      END IF;
   END IF;
   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;