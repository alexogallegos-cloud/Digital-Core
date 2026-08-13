CREATE PROCEDURE "informix".renivela_ax(P_EMPRESA       VARCHAR(3)
                ,P_NUM_PRODUCTO  VARCHAR(4)
                ,P_PLAZO         INTEGER
                ,P_MONTO         DECIMAL(18,2)
                ,P_TASA          DECIMAL(18,6)
		,P_CREDITO       CHAR(20)
		,P_CUOTAP        MONEY(14,2)
                )
       RETURNING CHAR(5), DECIMAL(21,2), DECIMAL(21,2), DECIMAL(21,2),
		 CHAR(10), CHAR(10), DECIMAL(21,2);

DEFINE P_COD_RET         VARCHAR(5);
DEFINE P_MENSAJE         VARCHAR(80);
DEFINE I                 INTEGER;
DEFINE P_CUOTA           DECIMAL(21,6);
DEFINE P_MONTO_CAPITAL   DECIMAL(21,6);
DEFINE P_MONTO_INTERES   DECIMAL(21,6);

DEFINE V_COD_TASA        VARCHAR(10);
DEFINE V_RANGOFECHA      VARCHAR(1);
DEFINE V_TASA_FECHA      DECIMAL(21,2);
DEFINE V_TASA_RANGO      DECIMAL(21,2);

DEFINE V_TASA            DECIMAL(21,6);
DEFINE V_FACTOR          DECIMAL(21,8);
DEFINE V_ELEVADO         DECIMAL(21,6);
DEFINE V_MTO_PERIODO     DECIMAL(21,6);
DEFINE V_PERIODO         INTEGER;
DEFINE V_PER_TASA        DECIMAL(9,6);
DEFINE V_MODULO          INTEGER;
DEFINE V_CAPACUM         DECIMAL(21,6);
DEFINE V_INTACUM         DECIMAL(21,6);
DEFINE ax_fechac         CHAR(10);
DEFINE ax_fechav         CHAR(10);
DEFINE V_MONUCUO	 DECIMAL(21,6);
DEFINE ax_fecha          DATE;
DEFINE ax_ultima         DATE;

BEGIN


  LET V_COD_TASA   = NULL;
  LET V_RANGOFECHA = NULL;
  LET V_TASA_FECHA = NULL;
  LET V_TASA_RANGO = NULL;
  LET V_MODULO     = 0;
  LET P_CUOTA      = P_MONTO;
  LET P_MONTO_INTERES = 0;
  LET P_MONTO_CAPITAL = 0;
  LET V_CAPACUM = 0;
  LET V_INTACUM = 0;
  LET ax_fechac = " ";
  LET ax_fechav = " ";
  LET V_MONUCUO = 0;
  LET P_COD_RET    = '00000';
  LET P_MENSAJE    = 'PROCESO EXITOSO';


  SELECT DEF.COD_TASA_BASE, (360/PCAP.EQUIVALENCIA_DIAS), MOD(360,PCAP.EQUIVALENCIA_DIAS) MODULO
       , TTAS.RANGOFECHA, FVLO.VALOR TASA_FECHA, TVLO.VALOR TASA_RANGO
  INTO   V_COD_TASA, V_PERIODO, V_MODULO, V_RANGOFECHA, V_TASA_FECHA, V_TASA_RANGO
  FROM   SD_DEFINICION          DEF
        ,BDINTEG:SI_TIPTASA    TTAS
        ,SD_CODPCAP             PCAP
        ,OUTER BDINTEG:SI_FECHAVALOR FVLO
        ,OUTER BDINTEG:SI_TASAVLOR   TVLO
  WHERE  PCAP.PERIOD_PAGO_CAP = DEF.PERIOD_PAGO_CAP
  AND    PCAP.EMPRESA = DEF.EMPRESA
  AND    FVLO.TASA = DEF.COD_TASA_BASE
  AND    FVLO.EMPRESA = DEF.EMPRESA
  AND    FVLO.FECHA = (SELECT MAX(FECHA)
                       FROM   BDINTEG:SI_FECHAVALOR A
                       WHERE  A.EMPRESA = DEF.EMPRESA
                       AND    A.TASA = DEF.COD_TASA_BASE
                      )
  AND    TVLO.TASA = DEF.COD_TASA_BASE
  AND    TVLO.EMPRESA = DEF.EMPRESA
  AND    TVLO.RANGOMAX <= P_MONTO
  AND    TVLO.RANGOMIN >= P_MONTO
  AND    TTAS.TASA = DEF.COD_TASA_BASE
  AND    TTAS.EMPRESA = DEF.EMPRESA
  AND    DEF.NUM_PRODUCTO = P_NUM_PRODUCTO
  AND    DEF.EMPRESA = P_EMPRESA;

  IF V_MODULO > 0 THEN
     LET V_PER_TASA = V_PERIODO + 1;
  ELSE
     LET V_PER_TASA = V_PERIODO;
  END IF;

{
  IF V_RANGOFECHA IS NULL THEN
     LET P_COD_RET = '00010';
     LET P_MENSAJE = 'ERROR EN LA DEFINICION DEL PRODUCTO';
     RETURN P_COD_RET,0,0,0, ax_fechac, ax_fechav, 0;
  END IF;

  IF V_RANGOFECHA = 'R' AND V_TASA_RANGO IS NULL THEN
     LET P_COD_RET = '00020';
     LET P_MENSAJE = 'ERROR: TASA NO DEFINIDA EN EN RANGO';
     RETURN P_COD_RET,0,0,0,ax_fechac, ax_fechav, 0;
  END IF;

  IF V_RANGOFECHA = 'F' AND V_TASA_FECHA IS NULL THEN
     LET P_COD_RET = '00030';
     LET P_MENSAJE = 'ERROR: TASA NO DEFINIDA PARA EL PRODUCTO';
     RETURN P_COD_RET,0,0,0,ax_fechac, ax_fechav, 0;
  END IF;

  IF V_RANGOFECHA = 'R' THEN
    LET V_TASA = V_TASA_RANGO;
  ELSE
    LET V_TASA = V_TASA_FECHA;
  END IF;}

  IF P_TASA > 0 THEN
    LET V_TASA = P_TASA;
  END IF;

  LET V_FACTOR      = ROUND(((V_TASA/100)/V_PER_TASA)+1,8);
  LET V_ELEVADO     = ROUND(POW(V_FACTOR, P_PLAZO),8);
  LET V_MTO_PERIODO = ROUND(((V_ELEVADO * P_MONTO) * (V_FACTOR - 1)) / (V_ELEVADO - 1),2);

  IF P_CUOTAP > 0 THEN
     	LET V_MTO_PERIODO = P_CUOTAP;
  ELSE
     	LET V_MTO_PERIODO = TRUNC(V_MTO_PERIODO);
  END IF

  UPDATE sd_pagocapit SET monto_cuota = 0 
   WHERE num_credito = P_CREDITO;

  UPDATE sd_paginter SET monto_cuota = 0 
   WHERE num_credito = P_CREDITO;

  SELECT MAX(fecha_cuota) INTO ax_ultima
    FROM sd_pagocapit
   WHERE num_credito = P_CREDITO;

  FOREACH SELECT fecha_cuota INTO ax_fecha
	    FROM sd_pagocapit
	   WHERE num_credito = P_CREDITO
	   ORDER BY 1
    LET P_MONTO_INTERES = ROUND(P_CUOTA * (V_FACTOR - 1),2);
    LET V_INTACUM = V_INTACUM + P_MONTO_INTERES;
    LET P_MONTO_CAPITAL = V_MTO_PERIODO - P_MONTO_INTERES;
    LET P_CUOTA = P_CUOTA - P_MONTO_CAPITAL;
    IF P_CUOTA < 0 THEN
	LET P_CUOTA = 0;
	LET P_MONTO_CAPITAL = 0;
    END IF

    IF ax_ultima = ax_fecha THEN
    	SELECT monto_otorgado - (SELECT SUM(monto_cuota)
                                   FROM sd_pagocapit b
                                  WHERE b.num_credito = a.num_credito)
	 INTO P_MONTO_CAPITAL
         FROM sd_maesdos a
          WHERE a.num_credito = P_CREDITO;

       SELECT MIN(fecha_cuota) INTO ax_fecha
	 FROM sd_pagocapit
	WHERE num_credito = P_CREDITO
	  AND monto_cuota = 0;

	IF ax_fecha IS NULL THEN
		LET ax_fecha = ax_ultima;
	END IF

       LET P_CUOTA = 0;
       LET V_MONUCUO = P_MONTO_CAPITAL + P_MONTO_INTERES;
    END IF;
    LET V_CAPACUM = V_CAPACUM + P_MONTO_CAPITAL;
    UPDATE sd_pagocapit SET monto_cuota = P_MONTO_CAPITAL,
			    saldo_cuota = P_MONTO_CAPITAL
     WHERE num_credito = P_CREDITO
       AND fecha_cuota = ax_fecha;

    UPDATE sd_paginter SET monto_cuota = P_MONTO_INTERES
     WHERE num_credito = P_CREDITO
       AND fecha_cuota = ax_fecha;

  END FOREACH


       RETURN P_COD_RET, V_CAPACUM, V_INTACUM, V_MTO_PERIODO,
              ax_fechac, ax_fechav, V_MONUCUO;

END;
END PROCEDURE;