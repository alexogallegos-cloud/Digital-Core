CREATE PROCEDURE "informix".actgaran( P_EMPRESA       LIKE BDICRED:SD_MAECRED.EMPRESA
                          , P_CREDITO_NVO   LIKE BDICRED:SD_MAECRED.NUM_CREDITO
                          , P_CREDITO_OLD   LIKE BDICRED:SD_MAECRED.NUM_CREDITO
                          )
RETURNING VARCHAR(10), VARCHAR(80);
--, P_ERROR         OUT  VARCHAR2
--, P_MENSAJE       OUT  VARCHAR2

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(200);
DEFINE P_ERROR     VARCHAR(10);
DEFINE P_MENSAJE   VARCHAR(80);
DEFINE v_credito   VARCHAR(20);
DEFINE v_aval      VARCHAR(20);
DEFINE v_aval2     VARCHAR(20);
DEFINE v_aval3     VARCHAR(20);
DEFINE v_secuencia INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_ERROR   = SQL_ERR;
      LET P_MENSAJE = ERROR_INFO;
      RETURN P_ERROR, P_MENSAJE;
   END EXCEPTION;




   LET P_ERROR   = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

    SELECT COUNT(*) INTO v_secuencia
      FROM sg_aval
     WHERE num_credito = P_CREDITO_NVO;

    IF v_secuencia > 0 THEN
	DELETE FROM sg_maegaran
	 WHERE empresa = P_EMPRESA
	   AND num_credito = P_CREDITO_NVO;


	DELETE FROM sg_aval
	 WHERE empresa = P_EMPRESA
	   AND num_credito = P_CREDITO_NVO;

    END IF


    FOREACH SELECT num_solicitud, desc1, desc2, desc3
              INTO v_credito, v_aval, v_aval2, v_aval3
	      FROM bdisolic:ss_bienes_deudas
	     WHERE num_solicitud = P_CREDITO_NVO
	       AND cod_concepto = "063"
	       AND ( desc1 <> ""
		OR  desc2 <> ""
		OR  desc3 <> "")

	SELECT COUNT(*) INTO v_secuencia
	  FROM sg_aval
	 WHERE num_credito = P_CREDITO_NVO;

	INSERT INTO sg_maegaran
		(empresa, num_credito, id_garan, cod_garan, grupo_garan,
		 divisa, val_garantot, statusgar)
	VALUES
	 	(P_EMPRESA, P_CREDITO_NVO, v_secuencia, "0001", "0007",
		 "01", 0, "V");

	INSERT INTO sg_aval
		(empresa, num_credito, id_garan, apellido_p)
	VALUES
		(P_EMPRESA, P_CREDITO_NVO, v_secuencia, v_aval);


	LET v_secuencia = v_secuencia +1;

        INSERT INTO sg_maegaran
                (empresa, num_credito, id_garan, cod_garan, grupo_garan,
                 divisa, val_garantot, statusgar)
        VALUES
                (P_EMPRESA, P_CREDITO_NVO, v_secuencia, "0001", "0007",
                 "01", 0, "V");

        INSERT INTO sg_aval
                (empresa, num_credito, id_garan, apellido_p)
        VALUES
                (P_EMPRESA, P_CREDITO_NVO, v_secuencia, v_aval2);

	LET v_secuencia = v_secuencia + 1;
        INSERT INTO sg_maegaran
                (empresa, num_credito, id_garan, cod_garan, grupo_garan,
                 divisa, val_garantot, statusgar)
        VALUES
                (P_EMPRESA, P_CREDITO_NVO, v_secuencia, "0001", "0007",
                 "01", 0, "V");

        INSERT INTO sg_aval
                (empresa, num_credito, id_garan, apellido_p)
        VALUES
                (P_EMPRESA, P_CREDITO_NVO, v_secuencia, v_aval3);


    END FOREACH


{   INSERT INTO SG_MAEGARAN(EMPRESA        ,NUM_CREDITO
                          ,ID_GARAN       ,COD_GARAN
                          ,GRUPO_GARAN    ,DIVISA
                          ,VAL_GARANTOT   ,STATUSGAR
                          ,USER_INSERT    ,FECHA_INSERT
                          )
                   SELECT  EMPRESA        ,P_CREDITO_NVO
                          ,ID_GARAN       ,COD_GARAN
                          ,GRUPO_GARAN    ,DIVISA
                          ,VAL_GARANTOT   ,STATUSGAR
                          ,USER_INSERT    ,FECHA_INSERT
                    FROM   SG_MAEGARAN
                    WHERE  NUM_CREDITO = P_CREDITO_OLD
                    AND    EMPRESA     = P_EMPRESA;

   UPDATE SG_FINAN
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   UPDATE SG_PREND
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   UPDATE SG_COMER
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   UPDATE SG_AVAL
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   UPDATE SG_FIDUC
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   UPDATE SG_HIPOT
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   UPDATE SG_SEGUR
      SET NUM_CREDITO = P_CREDITO_NVO
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;

   DELETE FROM SG_MAEGARAN
    WHERE NUM_CREDITO = P_CREDITO_OLD
      AND EMPRESA     = P_EMPRESA;}

   RETURN P_ERROR, P_MENSAJE;

END;
END PROCEDURE;