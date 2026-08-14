CREATE PROCEDURE "informix".conscedcred(pEmpresa like bdinteg:si_cliente.EMPRESA,
                             pNumCte  like bdinteg:si_cliente.NUMCTE,
                             pNumCred varchar(20))

RETURNING CHAR(20),CHAR(6),CHAR(80);

 DEFINE pCredito  char(20);
 DEFINE pCodRet char(6);
 DEFINE pMensaje char(80);
 DEFINE lContador integer;





   LET pCredito = ' ';
   LET lContador = 0;
   LET pCodRet = '000';
   LET pMensaje = ' ';

      FOREACH SELECT num_credito
              INTO   PCredito
              FROM   sd_maecred
             WHERE  empresa = pEmpresa
               AND    numcte  = pNumCte
               AND    status_cred <> 'FF'

              LET    pCodRet = '00000';
              LET    pMensaje = 'Paso de Creditos';
          RETURN pCredito,pCodRet,pMensaje
          WITH RESUME;
          LET lContador = lContador + 1;
      END FOREACH;
   LET pCredito = ' ';
   LET lContador = 0;
   LET pCodRet = '000';
   LET pMensaje = ' ';

--     RETURN pCredito,pCodRet,pMensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".ministracion(P_EMPRESA      VARCHAR(3)
       ,P_NUM_CREDITO  VARCHAR(20)
       ,P_TIPO_PAGO    VARCHAR(1)  --0)ABONO A CTA, 1)CHEQUE
       ,P_FECHA_MINIS  DATE
       ,P_MONTO        DECIMAL(14,2)
       ,P_COMIAHORRO   CHAR(1)
       ) RETURNING VARCHAR(5), VARCHAR(80), DECIMAL(18,2);

DEFINE P_COD_RET         VARCHAR(5);
DEFINE P_MENSAJE         VARCHAR(80);
DEFINE P_VALMINISTRA     DECIMAL(18,2);

DEFINE VV_SUCURSAL       VARCHAR(4);
DEFINE VV_USUARIO        VARCHAR(8);
DEFINE VV_FOLIO          VARCHAR(16);
DEFINE VV_DIVISA         VARCHAR(2);
DEFINE VV_REFERENCIA     VARCHAR(20);
DEFINE VV_CTA            VARCHAR(20);
DEFINE V_NUMCTE          VARCHAR(20);
DEFINE V_MONTO_APLICAR   DECIMAL(18,2);
DEFINE V_MONTO_CUOTA     DECIMAL(18,2);
DEFINE V_SALDO_CUOTA     DECIMAL(18,2);
DEFINE V_MONTO_ACTUALIZA DECIMAL(18,2);
DEFINE V_NUM_CONFIRMA    INTEGER;
DEFINE V_FECHA_HOY       DATE;
DEFINE V_FECHA_VENCIM    DATE;
DEFINE V_FECHA_PROGRAMADA DATE;
DEFINE V_NUM_MINISTRA    INTEGER;
DEFINE V_ULTIMA_MINIS    INTEGER;
DEFINE V_PRODUCTO        VARCHAR(244);
DEFINE V_PRODUCTOS       VARCHAR(244);
DEFINE V_PROD_ULTMIN     VARCHAR(244);
DEFINE V_FECHA_ULTMIN    DATE;
DEFINE V_FECHA_PRIMIN    DATE;
DEFINE V_CADENA          VARCHAR(244);
DEFINE V_NUMREG_ALT      INTEGER;
DEFINE V_APERTURA        VARCHAR(2);
DEFINE V_FECHA_REGISTRO  DATE;
DEFINE V_MONTO           DECIMAL(18,2);
DEFINE V_MONTO_REMANENTE DECIMAL(18,2);
DEFINE V_FECHA_CUOTA     DATE;
DEFINE V_DIF_SALDO       DECIMAL(18,2);
DEFINE V_MANEJA_LINEA    VARCHAR(2);
DEFINE V_FECHA_PMIN      DATE;
DEFINE V_COMISION        DECIMAL(18,2);

DEFINE V_FECHA_APER      DATE;
DEFINE V_DIA_CUOTA       INTEGER;
DEFINE V_DIAS_INT        INTEGER;
DEFINE V_MES             INTEGER;
DEFINE V_INT_INI         DECIMAL(18,2);
DEFINE V_TASA_INT        DECIMAL(18,6);
DEFINE V_STASA_INT       DECIMAL(18,6);
DEFINE V_FACTOR_ST       VARCHAR(2);
DEFINE V_MONTO_INI       DECIMAL(18,2);
DEFINE V_DIAS_ANUALES    INTEGER;
DEFINE V_TP_SOL          VARCHAR(2);
DEFINE V_CTAAHO          VARCHAR(20);
DEFINE V_TRANAHO         VARCHAR(5);
DEFINE V_FCGOAHO         DATE;
DEFINE V_MTO1CGO         MONEY(14,2);
DEFINE V_MTO2CGO         MONEY(14,2);
DEFINE V_MTOCOMP         MONEY(14,2);
DEFINE v_tpcred          CHAR(2);
DEFINE v_rees            CHAR(4);
DEFINE v_prodcons        CHAR(4);
DEFINE v_prodrees        CHAR(4);

DEFINE   SQL_ERR     INTEGER;
DEFINE   ISAM_ERR    INTEGER;
DEFINE   ERROR_INFO  VARCHAR(80);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO;
     LET P_VALMINISTRA = 0;
     RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
  END EXCEPTION;



  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  LET P_VALMINISTRA = 0;
  LET V_NUM_CONFIRMA = 0;
  LET V_NUMREG_ALT = 0;
  LET V_FACTOR_ST = '';
  LET P_COMIAHORRO = "0";
  LET V_COMISION = 0;

  SELECT COUNT(*), MAX(FECHA_PROGRAMADA)
  INTO   V_NUM_MINISTRA, V_FECHA_PROGRAMADA
  FROM SD_DETMINIS
  WHERE EMPRESA   = P_EMPRESA
  AND NUM_CREDITO = P_NUM_CREDITO;

  IF V_NUM_MINISTRA = 0 THEN
     --++++++++++++++++++++++++++++
     --NO HAY REGISTROS EN DETMINIS
     --POR LO TANTO SE REALIZA EN UN SOLO MOVIMIENTO EN LA APERTURA
     --++++++++++++++++++++++++++++
     INSERT INTO SD_DETMINIS
	(EMPRESA, NUM_CREDITO, FECHA_PROGRAMADA, FECHA_OTORGA, MONTO_OTORGADO,
         STATUS_MINISTRA, OBSER1, CAMPO1, CAMPO2)
     VALUES
        (P_EMPRESA, P_NUM_CREDITO, P_FECHA_MINIS, P_FECHA_MINIS, P_MONTO,
         'A',NULL,NULL,NULL);

     LET V_NUMREG_ALT = DBINFO("SQLCA.SQLERRD2");
  END IF;

  FOREACH C_MINIS FOR SELECT MONTO_OTORGADO, FECHA_PROGRAMADA
                      INTO   V_MONTO, V_FECHA_REGISTRO
                      FROM   SD_DETMINIS
                      WHERE  STATUS_MINISTRA = 'A'
                      AND    FECHA_PROGRAMADA <= P_FECHA_MINIS
                      AND    EMPRESA = P_EMPRESA
                      AND    NUM_CREDITO = P_NUM_CREDITO

    --OBTIENE LA FECHA DE HOY
    --OBTIENE EL FOLIO DE LA OPERACION
    SELECT FECHA_HOY, USER
           || REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
    INTO   V_FECHA_HOY, VV_FOLIO
    FROM   SD_FECHAS;

    --***************************************
    --EN LA PRIMER MINISTRACION SE DESCUENTAN LAS COMISIONES QUE TENGA ASOCIADAS
    --Y SE COBRAN LOS SEGUROS
    SELECT MIN(FECHA_PROGRAMADA)
    INTO V_FECHA_PMIN
    FROM SD_DETMINIS
    WHERE NUM_CREDITO = P_NUM_cREDITO
    AND EMPRESA = P_EMPRESA;

    SELECT cod_tipcred INTO v_tpcred
      FROM sd_maecred a, sd_definicion b
     WHERE b.num_producto = a.num_producto
       AND a.num_credito = P_NUM_CREDITO;

    IF v_tpcred = "01" OR v_tpcred ="04" THEN
    	SELECT VALOR INTO V_DIAS_ANUALES FROM SD_PARAM
     	 WHERE COD_PARAM = '75'
       	   AND EMPRESA = P_EMPRESA;
    ELSE
    	SELECT VALOR INTO V_DIAS_ANUALES FROM SD_PARAM
     	 WHERE COD_PARAM = '24'
           AND EMPRESA = P_EMPRESA;
    END IF

    --*********************************************
    --genera la informacion para crear los planes de pago

    SELECT TRIM(NUM_PRODUCTO), SUCURSAL, DIVISA
    INTO   V_PRODUCTO, VV_SUCURSAL, VV_DIVISA
    FROM   SD_MAECRED
    WHERE  NUM_CREDITO = P_NUM_CREDITO
    AND    EMPRESA = P_EMPRESA;

    SELECT NVL(MANEJA_LINEA,'N') MANEJA_LINEA
    INTO V_MANEJA_LINEA
    FROM SD_DEFINICION
    WHERE EMPRESA = P_EMPRESA
    AND NUM_PRODUCTO = V_PRODUCTO;

    IF V_MANEJA_LINEA = '' THEN
       LET V_MANEJA_LINEA = 'N';
    END IF;

    SELECT TP_GEN_PLANPAGO, NVL(cod_linea,' ')
    INTO   V_APERTURA, v_rees
    FROM   BDISOLIC:SS_SOLICITUDES a, BDISOLIC:SS_ANEXOSOL b
    WHERE  a.NUM_SOLICITUD = P_NUM_CREDITO
    AND    a.EMPRESA = P_EMPRESA
    AND    b.num_solicitud = a.num_solicitud;

    -- VERIFICA SI ES LA PRIMERA MINISTRACION Y SE TIENE QUE GENERAR
    --   EL PLAN DE PAGOS
    IF V_APERTURA = '2' AND V_FECHA_REGISTRO = V_FECHA_PMIN
    AND V_MANEJA_LINEA = 'N' THEN
       EXECUTE PROCEDURE BDICRED:SP_PLAN_PAGOS(P_EMPRESA, P_NUM_CREDITO)
                                          INTO P_COD_RET, P_MENSAJE;
    END IF;

    IF P_FECHA_MINIS = V_FECHA_PMIN THEN
      --se genera una comision por los interes inicales del credito
      SELECT FECHA_APERTURA, DIA_CUOTA, TASA_INTERES, S.MONTO_OTORGADO
           , M.SOBRETASA, M.FACTOR_SOBRETASA
      INTO V_FECHA_APER, V_DIA_CUOTA, V_TASA_INT, V_MONTO_INI, V_STASA_INT,
           V_FACTOR_ST
      FROM SD_MAECRED M, SD_MAESDOS S, SD_DEFINICION D
      WHERE D.NUM_PRODUCTO = M.NUM_PRODUCTO
      AND D.EMPRESA = M.EMPRESA
      AND S.NUM_CREDITO = M.NUM_CREDITO
      AND S.EMPRESA = M.EMPRESA
      AND M.NUM_cREDITO = P_NUM_CREDITO
      AND M.EMPRESA = P_EMPRESA;

      LET V_MES = MONTH(V_FECHA_APER)+1;

      IF V_DIA_CUOTA = 50 THEN
        LET V_DIAS_INT = 0;
      ELIF V_DIA_CUOTA = 99 THEN
        IF V_MES > 12 THEN
          LET V_DIAS_INT = (MDY(1,1,YEAR(V_FECHA_APER)+1)-1) - V_FECHA_APER;
        ELSE
          LET V_DIAS_INT = (MDY(V_MES,1,YEAR(V_FECHA_APER))-1) - V_FECHA_APER;
        END IF;
      ELSE
        IF DAY(V_FECHA_APER) > V_DIA_CUOTA THEN
          IF V_MES > 12 THEN
            LET V_DIAS_INT = MDY(1, V_DIA_CUOTA, YEAR(V_FECHA_APER)+1) -
                             V_FECHA_APER;
          ELSE
            LET V_DIAS_INT = MDY(V_MES, V_DIA_CUOTA, YEAR(V_FECHA_APER)) -
                V_FECHA_APER;
          END IF;
        ELSE
          LET V_DIAS_INT = MDY(MONTH(V_FECHA_APER), V_DIA_CUOTA,
                           YEAR(V_FECHA_APER)) - V_FECHA_APER;
        END IF;
      END IF;

      --CALCULA LOS INTERES PREVIOS
      LET V_INT_INI = V_MONTO * (V_DIAS_INT * ((V_TASA_INT/100)/V_DIAS_ANUALES));
      --***********************************************
      -- DETERMINA PRODUCTOS QUE NO COBRAN INT. POR ADELANTADO
      SELECT valor INTO v_prodcons
	FROM sd_param
       WHERE cod_param ="53"
	 AND empresa = P_EMPRESA;

      SELECT valor INTO v_prodrees
	FROM sd_param
       WHERE cod_param ="78"
	 AND empresa = P_EMPRESA;

      --GENERA EL REGISTRO EN TPCOMIS PARA SU CONTABILIDAD
      IF V_PRODUCTO <> v_prodcons AND V_PRODUCTO <>  v_prodrees THEN
         INSERT INTO SD_DETCOMI
            (EMPRESA,COD_COMIS,NUM_CREDITO,FECHA_ALTA,FECHA_PAGO,MONTO_COM,
             MONTO_PAG
            ,APLI_FACTOR,ESTADO_COM,NUM_SOLICITUD,USER_INSERT,FECHA_INSERT)
         VALUES(P_EMPRESA,'0004',P_NUM_CREDITO,V_FECHA_HOY,'',V_INT_INI,0
            ,0,'1','',USER,TODAY);

      END IF


      --SE GENERAN Y COBRAN LAS COMISIONES
      EXECUTE PROCEDURE BDICRED:SP_COMISIONES (P_EMPRESA, P_NUM_CREDITO)
              INTO P_COD_RET, P_MENSAJE, V_COMISION;

      IF P_COD_RET = '00000' THEN
        IF V_MONTO < V_COMISION THEN
           LET P_COD_RET = '00001';
           LET P_MENSAJE ='El Monto de las Deducciones es Mayor al Desembolso';
           RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
        END IF;
      ELSE
        RETURN P_COD_RET, P_MENSAJE, 0;
      END IF;
    END IF;


    -- ***********************************************************************
    -- *   Pregunta si la comisiones se debitan de ahorros                   *
    -- ***********************************************************************
    IF P_COMIAHORRO = "1" THEN
	SELECT TRIM(valor) INTO V_TRANAHO
	  FROM sd_param
	 WHERE cod_param = "71"
	   AND empresa = P_EMPRESA;

	IF V_TRANAHO IS NULL THEN
	   LET P_COD_RET = "0033";
	   LET P_MENSAJE = "Tran. de Cargo Gastos Cierre No Existe (PARAM 71)";
           RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
	END IF

	SELECT cuenta INTO V_CTAAHO
	  FROM bdicheq:sc_maechq a, sd_maecred b
	 WHERE num_cte = numcte
	   AND producto = "300"
	   AND a.empresa = b.empresa
	   AND b.empresa = P_EMPRESA
	   AND num_credito = P_NUM_CREDITO;

	IF V_CTAAHO IS NULL THEN
	   LET P_COD_RET = "0034";
	   LET P_MENSAJE = "Cuenta Cargo Gastos Cierre No Existe (MAECHQ)";
           RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
	END IF

	EXECUTE PROCEDURE bdicheq:cargo_ref
			(P_EMPRESA, VV_SUCURSAL, USER, V_TRANAHO, "0000",
			 VV_FOLIO, V_CTAAHO, "0", V_COMISION, VV_DIVISA,
			 "gastos de cierre")
	 INTO P_COD_RET, V_TRANAHO, V_FCGOAHO, V_MTO1CGO, V_MTO2CGO;

	IF P_COD_RET <> "000" THEN
	   SELECT NVL(descripcion,'Error en Cargo a Ahorros') INTO P_MENSAJE
	     FROM bdinteg:si_codret
	    WHERE codigo_retorno = P_COD_RET
	      AND sistema = "02";
           RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
	END IF
	LET V_COMISION = 0;
    END IF

    --***************************************
    -- GENERA EL MOVIMIENTO CONTABLE CORRESPONDIENTE
{    IF P_COD_RET = '00000' THEN


      EXECUTE PROCEDURE GENERA_MOV_DIA_MINIS(P_EMPRESA, P_NUM_CREDITO, V_MONTO, VV_FOLIO,
				             P_TIPO_PAGO)
         INTO P_COD_RET, P_MENSAJE;
      IF P_COD_RET <> '00000' THEN
         RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
      END IF;
    END IF;}

    --****************************************
    --SE GENERA LA ORDEN PARA BANCOS O CHEQUES SEGUN CORRESPONDA
    SELECT A.SUCURSAL, USER
          ,A.DIVISA,A.NUM_CREDITO,A.NUMCTE,A.FECHA_VENCIM
    INTO   VV_SUCURSAL, VV_USUARIO, VV_DIVISA,VV_REFERENCIA, V_NUMCTE,V_FECHA_VENCIM
    FROM   SD_MAECRED A
    WHERE  A.EMPRESA = P_EMPRESA
    AND    A.NUM_CREDITO = P_NUM_CREDITO;

    SELECT TRIM(TIPO_SOLICITUD)
    INTO   V_TP_SOL
    FROM   BDISOLIC:SS_SOLICITUDES
    WHERE  NUM_SOLICITUD = P_NUM_CREDITO
    AND    EMPRESA = P_EMPRESA;

    LET P_VALMINISTRA = (V_MONTO - V_COMISION);

    IF V_TP_SOL <> 'R' THEN
      IF P_TIPO_PAGO = '1' THEN
        SELECT NVL(B.NUM_CTA,0)
        INTO   VV_CTA
        FROM   SD_CTASCARG B
        WHERE  B.EMPRESA = P_EMPRESA
        AND    B.NUM_CREDITO = P_NUM_CREDITO
	AND    B.NATURALEZA = "A";

       --ABONO A CUENTA
       EXECUTE PROCEDURE BDICHEQ:ABONO_REF(P_EMPRESA,VV_SUCURSAL, VV_USUARIO,'0213','0000',VV_FOLIO
                                          ,VV_CTA,0,(V_MONTO-V_COMISION),(V_MONTO-V_COMISION),0,0,0,VV_DIVISA,VV_REFERENCIA
                                          ) INTO P_COD_RET;

         IF P_COD_RET <> '000' THEN
           LET P_MENSAJE = 'Error en el abono a cheques';
           RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
         ELSE
           LET P_COD_RET = '00000';
         END IF;
	 -- Genera Movimiento de Credito de acuerdo a la forma de pago
         EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_NUM_CREDITO
                                 , V_PRODUCTO        , 3
                                 , "002"             , V_FECHA_HOY
                                 , V_MONTO           , VV_FOLIO
                                 , VV_SUCURSAL       ,VV_DIVISA
                                 , "0000"
                                 ) INTO P_COD_RET, P_MENSAJE;
	 IF P_COD_RET <> '00000' THEN
         	RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
         END IF;
      ELSE  --POR CHEQUE

	-- **************************************************************
	-- Acumula Complementos de Ahorro para generacion de cheque AXEL
	-- **************************************************************
	SELECT cuenta, monto INTO V_CTAAHO, V_MTOCOMP
	  FROM bdisolic:ss_complementos
	 WHERE num_empresa = P_EMPRESA
	   AND num_solicitud = P_NUM_CREDITO;
	IF V_CTAAHO IS NULL THEN
		LET V_MTOCOMP = 0;
	ELSE
       		SELECT TRIM(valor) INTO V_TRANAHO
          	  FROM sd_param
         	 WHERE cod_param = "77"
           	   AND empresa = P_EMPRESA;
	END IF

	-- Realiza Cargo a Ahorros por Complmeto
	IF V_MTOCOMP > 0 THEN
          EXECUTE PROCEDURE bdicheq:cargo_ref
                        (P_EMPRESA, VV_SUCURSAL, USER, V_TRANAHO, "0000",
                         VV_FOLIO, V_CTAAHO, "0", V_MTOCOMP, VV_DIVISA,
                         "gastos de cierre")
             INTO P_COD_RET, V_TRANAHO, V_FCGOAHO, V_MTO1CGO, V_MTO2CGO;
          IF P_COD_RET <> '000' THEN
	      LET P_MENSAJE = "Cargo a Ahorros por Complemento";
              RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
          END IF;
	END IF


        EXECUTE PROCEDURE
	   BDIBANCO:SBSP_GRABA_SOLCRD(P_EMPRESA,V_NUMCTE
                                   ,VV_USUARIO,((V_MONTO+V_MTOCOMP)-V_COMISION),
			            VV_REFERENCIA)
                                    INTO P_COD_RET, P_MENSAJE, V_NUM_CONFIRMA;

        IF P_COD_RET <> '00000' THEN
          RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
        END IF;
	 -- Genera Movimiento de Credito de acuerdo a la forma de pago
         EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_NUM_CREDITO
                                 , V_PRODUCTO        , 2
                                 , "002"             , V_FECHA_HOY
                                 , V_MONTO           , VV_FOLIO
                                 , VV_SUCURSAL        ,VV_DIVISA
                                 , "0000"
                                 ) INTO P_COD_RET, P_MENSAJE;
	 IF P_COD_RET <> '00000' THEN
         	RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
         END IF;
      END IF;
    ELSE
         -- Genera Movimiento de Credito para Renovaciones
         EXECUTE PROCEDURE GENMOV( P_EMPRESA         , P_NUM_CREDITO
                                 , V_PRODUCTO        , 2
                                 , "002"             , V_FECHA_HOY
                                 , V_MONTO           , VV_FOLIO
                                 , VV_SUCURSAL        ,VV_DIVISA
                                 , "0000"
                                 ) INTO P_COD_RET, P_MENSAJE;
         IF P_COD_RET <> '00000' THEN
                RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
         END IF;

    END IF;

    --*********************************
    --ACTUALIZA DETMINIS

    UPDATE SD_DETMINIS
    SET    FECHA_OTORGA     = V_FECHA_HOY
          ,MONTO_OTORGADO   = V_MONTO
          ,STATUS_MINISTRA  = 'M'
          ,CAMPO1           = V_NUM_CONFIRMA
    WHERE  STATUS_MINISTRA  = 'A'
    AND    FECHA_PROGRAMADA = V_FECHA_REGISTRO
    AND    NUM_CREDITO      = P_NUM_CREDITO
    AND    EMPRESA          = P_EMPRESA;

    -- Actualizara SDMAECRED, SD_MAESDOS, SD_MAECONTRATO, SD_PAGOCAPIT
    IF P_COD_RET = '00000' THEN
       -- Actualiza SD_MAECRED
       UPDATE SD_MAECRED
       SET    BANDERA_MINISTRA = 'M'
       WHERE  EMPRESA          = P_EMPRESA
       AND    NUM_CREDITO      = P_NUM_CREDITO;

       -- Actualiza SD_MAESDOS
       UPDATE SD_MAESDOS
       SET    SDO_CAPITAL      = SDO_CAPITAL      + V_MONTO ,
              SDO_CAP_INSOLUTO = SDO_CAP_INSOLUTO + V_MONTO ,
              MTO_MINISTRA_CAP = MTO_MINISTRA_CAP + V_MONTO
       WHERE  EMPRESA          = P_EMPRESA
       AND    NUM_CREDITO      = P_NUM_CREDITO;

       -- Actualiza SD_MAECONTRATO
       UPDATE SD_MAECONTRATO
       SET    MONTO_EJERCIDO   = MONTO_EJERCIDO + V_MONTO
       WHERE  EMPRESA          = P_EMPRESA
       AND    NUM_CONTRATO     = P_NUM_CREDITO;

       -- SE VERIFICA SI SE DEBE ACTUALIZAR EL PAGOCAPIT
       SELECT TRIM(VALOR)
       INTO   V_PROD_ULTMIN
       FROM   SD_PARAM
       WHERE  COD_PARAM = '53'
       AND    EMPRESA = P_EMPRESA;

       SELECT TRIM(NUM_PRODUCTO)
       INTO   V_PRODUCTO
       FROM   SD_MAECRED
       WHERE  NUM_CREDITO = P_NUM_CREDITO
       AND    EMPRESA = P_EMPRESA;

       SELECT MAX(FECHA_PROGRAMADA), MIN(FECHA_PROGRAMADA)
       INTO   V_FECHA_ULTMIN, V_FECHA_PRIMIN
       FROM   SD_DETMINIS
       WHERE  EMPRESA = P_EMPRESA
       AND    NUM_CREDITO = P_NUM_CREDITO;

       SELECT NVL(MANEJA_LINEA,'N') MANEJA_LINEA
       INTO V_MANEJA_LINEA
       FROM SD_DEFINICION
       WHERE EMPRESA = P_EMPRESA
       AND NUM_PRODUCTO = V_PRODUCTO;

       IF V_MANEJA_LINEA = '' THEN
          LET V_MANEJA_LINEA = 'N';
       END IF;

       -- VERIFICA SI ES LA PRIMERA MINISTRACION Y SE TIENE QUE GENERAR EL PLAN DE PAGOS
--       IF V_APERTURA = '2' AND V_FECHA_REGISTRO = V_FECHA_PRIMIN AND V_MANEJA_LINEA = 'N' THEN
--          EXECUTE PROCEDURE BDICRED:SP_PLAN_PAGOS(P_EMPRESA, P_NUM_CREDITO)
--                                             INTO P_COD_RET, P_MENSAJE;
--       END IF;

       LET V_CADENA = REPLACE(',' || V_PROD_ULTMIN || ',' , ',' || V_PRODUCTO || ',',',9XZ,');
       IF V_FECHA_ULTMIN <= P_FECHA_MINIS AND
          V_CADENA <> (',' || V_PROD_ULTMIN || ',') AND V_MANEJA_LINEA = 'N' THEN

          --DISPARA LOS PAGOS NIVELADOS
          EXECUTE PROCEDURE BDICRED:PAGOS_NIVELADOS(P_EMPRESA, P_NUM_CREDITO, V_FECHA_REGISTRO
                                                   )INTO P_COD_RET, P_MENSAJE;
       END IF;
    END IF;

    --Actualiza el campo de saldo_cuota de pagocapit
    LET V_MONTO_REMANENTE = V_MONTO;
    FOREACH SELECT FECHA_CUOTA, (MONTO_CUOTA-SALDO_CUOTA) DIF_SALDO
            INTO V_FECHA_CUOTA, V_DIF_SALDO
            FROM SD_PAGOCAPIT
            WHERE STATUS_CUOTA = '1'
            AND   SALDO_CUOTA < MONTO_CUOTA
            AND   NUM_CREDITO = P_NUM_CREDITO
            AND   EMPRESA = P_EMPRESA
            ORDER BY FECHA_CUOTA

       LET V_MONTO_REMANENTE = V_MONTO_REMANENTE - V_DIF_SALDO;
       IF V_MONTO_REMANENTE > 0 THEN
          UPDATE SD_PAGOCAPIT
          SET    SALDO_CUOTA = SALDO_CUOTA + V_DIF_SALDO
                ,BANDERA_MINISTRA = 'M'
          WHERE  FECHA_CUOTA = V_FECHA_CUOTA
          AND    NUM_CREDITO = P_NUM_CREDITO
         AND    EMPRESA = P_EMPRESA;
       ELSE
          UPDATE SD_PAGOCAPIT
          SET    SALDO_CUOTA = SALDO_CUOTA + V_MONTO_REMANENTE + V_DIF_SALDO
                ,BANDERA_MINISTRA = 'M'
          WHERE  FECHA_CUOTA = V_FECHA_CUOTA
          AND    NUM_CREDITO = P_NUM_CREDITO
         AND    EMPRESA = P_EMPRESA;
         EXIT FOREACH;
       END IF;
    END FOREACH;
  END FOREACH;
  RETURN P_COD_RET, P_MENSAJE, P_VALMINISTRA;
END;
END PROCEDURE;