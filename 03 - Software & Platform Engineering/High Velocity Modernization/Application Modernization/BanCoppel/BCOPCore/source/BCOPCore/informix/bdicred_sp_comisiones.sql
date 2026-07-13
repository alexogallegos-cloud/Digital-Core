CREATE PROCEDURE "informix".sp_comisiones(P_EMPRESA     VARCHAR(3)
      ,P_NUM_CREDITO VARCHAR(20)
      ) RETURNING VARCHAR(5), VARCHAR(80), DECIMAL(18,2);

DEFINE P_COD_RET  VARCHAR(5);
DEFINE P_MENSAJE  VARCHAR(80);

DEFINE V_SUCURSAL      VARCHAR(4);
DEFINE V_NUM_PRODUCTO  VARCHAR(4);
DEFINE V_DIVISA        VARCHAR(2);
DEFINE V_COD_COMIS     VARCHAR(4);
DEFINE V_MONTO_COM     DECIMAL(18,2);
DEFINE V_EVENTO        VARCHAR(2);
DEFINE V_SE_PRORRATEA  VARCHAR(2);
DEFINE V_FECHA_VENC_SEG DATE;
DEFINE V_MONTO_POLIZA  DECIMAL(18,2);
DEFINE V_MONTO_MENSUAL DECIMAL(18,2);

DEFINE V_FUN_COM       VARCHAR(3);
DEFINE V_FUN_SEG       VARCHAR(3);
DEFINE V_FECHA_HOY     DATE;
DEFINE V_MONTO_TOTAL   DECIMAL(18,2);
DEFINE V_MONTO_TOTALH  DECIMAL(18,2);
DEFINE V_PRIM_FEC_SEG  DATE;
DEFINE V_FECHA_ALTA    DATE;
DEFINE V_FECHA_CUOTA   DATE;
DEFINE V_MONTO_OTORGADO DECIMAL(18,2);
DEFINE V_APLI_FACTOR   DECIMAL(18,2);
DEFINE V_FORM_APLICA   VARCHAR(2);
DEFINE V_PLAZO         INTEGER;

DEFINE V_CON_CUOTASEG  INTEGER;
DEFINE V_FOLIO         VARCHAR(20);

define a date;
define b date;
define c varchar(20);
define d varchar(3);

DEFINE SQL_ERR    INTEGER;
DEFINE ISAM_ERR   INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE AX_TRAN    CHAR(4);
DEFINE AX_TRANAHOCOM  CHAR(4);
DEFINE AX_PASO    CHAR(20);
DEFINE AX_TPPROD  SMALLINT;
DEFINE AX_PROD    CHAR(4);
DEFINE AX_CUENTA  CHAR(20);
DEFINE AX_EDOCOM  CHAR(1);

BEGIN
  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET  = SQL_ERR;
     LET P_MENSAJE  = ERROR_INFO;
     RETURN P_COD_RET, P_MENSAJE, V_MONTO_TOTAL;
  END EXCEPTION;



  LET P_COD_RET = '00000';
  LET P_MENSAJE = 'PROCESO EXITOSO';
  LET V_FUN_COM = '039';
  LET V_FUN_SEG = '041';
  LET V_MONTO_TOTAL = 0;
  LET V_MONTO_TOTALH = 0;
  LET AX_PASO ="000000000";
  LET V_CON_CUOTASEG = 0;

  SELECT TRIM(valor) INTO AX_TRANAHOCOM FROM sd_param
   WHERE empresa = P_EMPRESA  
     AND cod_param = "76";

  SELECT USER || SUBSTR(current hour to fraction    ,1,2 ) ||
                 SUBSTR(current hour to fraction    ,4,2 ) ||
                 SUBSTR(current hour to fraction    ,7,2 ) ||
                 SUBSTR(P_NUM_CREDITO,8 ,2),
         FECHA_HOY
  INTO   V_FOLIO, V_FECHA_HOY
  FROM   SD_FECHAS
  WHERE  EMPRESA = P_EMPRESA;

  -- *************************************************************************
  -- *             COBRA LAS COMISIONES NORMALES (NO SEGUROS)                *
  -- *************************************************************************
  FOREACH SELECT TRIM(MAE.SUCURSAL), TRIM(MAE.NUM_PRODUCTO), TRIM(MAE.DIVISA)
                ,TRIM(DCOM.COD_COMIS), DCOM.MONTO_COM, NVL(TCOM.EVENTO,'01')
                ,TRIM(TCOM.FORM_APLICA)
                ,NVL(DCOM.APLI_FACTOR,0)
                ,TRIM(SE_PRORRATEA), MSD.MONTO_OTORGADO
		,NVL(TCOM.CODREF_IMP,0)
		,TCOM.CODFUN_IMP,
		 DCOM.ESTADO_COM
          INTO   V_SUCURSAL, V_NUM_PRODUCTO, V_DIVISA
                ,V_COD_COMIS, V_MONTO_COM, V_EVENTO,V_FORM_APLICA,V_APLI_FACTOR
                ,V_SE_PRORRATEA, V_MONTO_OTORGADO, AX_TPPROD, AX_TRAN, AX_EDOCOM
          FROM SD_MAECRED MAE, SD_MAESDOS MSD, SD_DETCOMI DCOM, SD_TPCOMIS TCOM
          WHERE TCOM.COMI_O_SEG IN ('1','3')
          AND   TCOM.COD_COMIS = DCOM.COD_COMIS
          AND   TCOM.EMPRESA = DCOM.EMPRESA
          AND   DCOM.ESTADO_COM IN ("1","2")
          AND   DCOM.NUM_CREDITO = MAE.NUM_CREDITO
          AND   DCOM.EMPRESA = MAE.EMPRESA
          AND   MSD.NUM_CREDITO = MAE.NUM_CREDITO
          AND   MSD.EMPRESA = MAE.EMPRESA
          AND   MAE.NUM_CREDITO = P_NUM_CREDITO
          AND   MAE.EMPRESA = P_EMPRESA

    IF V_FORM_APLICA = '2' THEN
      LET V_MONTO_COM = V_MONTO_OTORGADO * (V_APLI_FACTOR/100);
    END IF;

    --EJECUTA EL MOVIMIENTO CONTABLE
    IF AX_EDOCOM = "1" THEN
    	EXECUTE PROCEDURE GENMOV(P_EMPRESA,  P_NUM_CREDITO, V_NUM_PRODUCTO, 
			         V_COD_COMIS,V_FUN_COM, V_FECHA_HOY,V_MONTO_COM,
			         V_FOLIO ,V_SUCURSAL, V_DIVISA, '0000')
           INTO P_COD_RET, P_MENSAJE;

    	--SE APLICO CORRECTAMENTE EL PASE CONTABLE
    	IF P_COD_RET = '00000' THEN
      		LET V_MONTO_TOTAL = V_MONTO_TOTAL + V_MONTO_COM;
         	UPDATE SD_DETCOMI
         	   SET ESTADO_COM = 'A'
            	       ,MONTO_PAG  = V_MONTO_COM
            	       ,fecha_pago = v_fecha_hoy
            	       ,monto_com  = v_monto_com
		       ,num_solicitud = "COBRA EN CREDITO"
      		 WHERE COD_COMIS = V_COD_COMIS
      		   AND NUM_CREDITO = P_NUM_CREDITO
      		   AND EMPRESA = P_EMPRESA;
    	ELSE
      		RETURN P_COD_RET, P_MENSAJE,0;
    	END IF;
    ELSE
      	LET V_MONTO_TOTALH = V_MONTO_TOTALH + V_MONTO_COM;
        UPDATE SD_DETCOMI
           SET ESTADO_COM = 'A'
               ,MONTO_PAG  = V_MONTO_COM
               ,fecha_pago = v_fecha_hoy
               ,monto_com  = v_monto_com
	       ,num_solicitud = "COBRA EN AHORROS"
      	 WHERE COD_COMIS = V_COD_COMIS
      	   AND NUM_CREDITO = P_NUM_CREDITO
      	   AND EMPRESA = P_EMPRESA;
    END IF  

    IF AX_TPPROD > 0 THEN
      FOREACH SELECT producto, cuenta
	        INTO AX_PROD, AX_CUENTA
	        FROM bdicheq:sc_maechq
	       WHERE num_cte = SUBSTR(P_NUM_CREDITO,1,9)

	 IF AX_TPPROD = 3 THEN 
		LET AX_PASO = AX_CUENTA;
	 END IF

	 IF SUBSTR(AX_PROD,1,1) = AX_TPPROD THEN
		EXIT FOREACH;
	 END IF
	 LET AX_CUENTA = " ";

     END FOREACH
     IF AX_CUENTA = " " THEN
	LET AX_CUENTA = AX_PASO;
     END IF
     LET AX_TRAN = "0" || TRIM(AX_TRAN);
     EXECUTE PROCEDURE BDICHEQ:ABONO_REF(P_EMPRESA,V_SUCURSAL, 
				         SUBSTR(V_FOLIO,1,8), AX_TRAN,'0000',
					 V_FOLIO, AX_CUENTA,0,V_MONTO_COM,
				         V_MONTO_COM,0,0,0, "01"," ")
                 INTO P_COD_RET;
     IF P_COD_RET <> "000" THEN
       LET P_MENSAJE = "ABONO_REF COMISIONES";
       RETURN P_COD_RET, P_MENSAJE,0;
     END IF
     LET P_COD_RET = "00000";
   END IF     	

  END FOREACH;


  -- **********************************************************************
  -- *   VERIFICA LA EXISTENCIA DE COMISIONES QUE NO ESTAN EN CATALOGO    *
  -- **********************************************************************

  FOREACH SELECT cod_comis, monto_com, apli_factor, estado_com,
		 monto_otorgado, num_producto, sucursal, divisa
	    INTO V_COD_COMIS, V_MONTO_COM,V_APLI_FACTOR, AX_EDOCOM,
		 V_MONTO_OTORGADO, V_NUM_PRODUCTO, V_SUCURSAL, V_DIVISA
	    FROM sd_detcomihipot x, sd_maesdos a, sd_maecred b     
	   WHERE x.num_credito =  P_NUM_CREDITO
	     AND a.num_credito = x.num_credito
	     AND b.num_credito = a.num_credito

    IF V_APLI_FACTOR > 0 THEN
	LET V_MONTO_COM = V_MONTO_OTORGADO * (V_APLI_FACTOR/100);
    END IF

    --EJECUTA EL MOVIMIENTO CONTABLE
    IF AX_EDOCOM = "1" THEN
        EXECUTE PROCEDURE GENMOV(P_EMPRESA,  P_NUM_CREDITO, V_NUM_PRODUCTO,
                                 8000,V_FUN_COM, V_FECHA_HOY,V_MONTO_COM,
                                 V_FOLIO ,V_SUCURSAL, V_DIVISA, '0000')
           INTO P_COD_RET, P_MENSAJE;

        --SE APLICO CORRECTAMENTE EL PASE CONTABLE
        IF P_COD_RET = '00000' THEN
                LET V_MONTO_TOTAL = V_MONTO_TOTAL + V_MONTO_COM;
                UPDATE SD_DETCOMIHIPOT
                   SET ESTADO_COM = 'A'
                       ,MONTO_PAG  = V_MONTO_COM
                       ,fecha_pago = v_fecha_hoy
                       ,monto_com  = v_monto_com
                       ,num_solicitud = "COBRA EN CREDITO"
                 WHERE COD_COMIS = V_COD_COMIS
                   AND NUM_CREDITO = P_NUM_CREDITO
                   AND EMPRESA = P_EMPRESA;
        ELSE
                RETURN P_COD_RET, P_MENSAJE,0;
        END IF;
    ELSE
        LET V_MONTO_TOTALH = V_MONTO_TOTALH + V_MONTO_COM;
        UPDATE SD_DETCOMIHIPOT
           SET ESTADO_COM = 'A'
               ,MONTO_PAG  = V_MONTO_COM
               ,fecha_pago = v_fecha_hoy
               ,monto_com  = v_monto_com
               ,num_solicitud = "COBRA EN AHORROS"
         WHERE COD_COMIS = V_COD_COMIS
           AND NUM_CREDITO = P_NUM_CREDITO
           AND EMPRESA = P_EMPRESA;
    END IF

  END FOREACH

  
  -- **********************************************************************
  -- *               GENERA CARGO A AHORROS POR COMISIONES                *
  -- **********************************************************************
  IF V_MONTO_TOTALH > 0 THEN
	SELECT a.sucursal, cuenta, b.divisa
	  INTO V_SUCURSAL, AX_CUENTA, V_DIVISA
	  FROM bdicheq:sc_maechq a, bdicheq:sc_producto b, sd_maecred g
	 WHERE g.empresa = P_EMPRESA
	   AND g.num_credito = P_NUM_CREDITO
	   AND a.num_cte = g.numcte
	   AND a.producto = "300"
	   AND b.empresa = a.empresa
	   AND b.producto = a.producto;
	IF AX_CUENTA IS NULL  THEN
		LET P_MENSAJE ="No Existe Cta de Ahorros Cgo Com";
		LET P_COD_RET ="110";
                RETURN P_COD_RET, P_MENSAJE,0;
	END IF
	EXECUTE PROCEDURE bdicheq:cargo_ref(P_EMPRESA,
                                    V_SUCURSAL,
                                    SUBSTR(V_FOLIO,1,8),
                                    AX_TRANAHOCOM,
                                    "0000",
                                    V_FOLIO,
                                    AX_CUENTA,
                                    0,
                                    V_MONTO_TOTALH,
                                    V_DIVISA,
                                    "Cierre Prestamo")
	   INTO P_COD_RET, V_COD_COMIS, a, V_MONTO_COM, V_MONTO_COM; 

	IF P_COD_RET <> "000" THEN
		LET P_MENSAJE ="Cargo Ahorros por Comisiones";
                RETURN P_COD_RET, P_MENSAJE,0;
	END IF
	LET P_COD_RET = "00000";
  END IF



  -- **********************************************************************
  -- *                        COBRA LOS SEGUROS				  *
  -- **********************************************************************

  FOREACH SELECT MAE.SUCURSAL, MAE.NUM_PRODUCTO, MAE.DIVISA
                ,SCR.COD_COMIS, SCR.FECHA_VENC_SEG, NVL(SCR.MONTO_POLIZA,0)
                ,NVL(SCR.MONTO_MENSUAL,0)
                ,NVL(TCOM.SE_PRORRATEA,'2')
                ,SCR.PLAZO
          INTO   V_SUCURSAL, V_NUM_PRODUCTO, V_DIVISA
                ,V_COD_COMIS,V_FECHA_VENC_SEG,V_MONTO_POLIZA,V_MONTO_MENSUAL
                ,V_SE_PRORRATEA
                ,V_PLAZO
          FROM SD_MAECRED MAE, SD_ESCROW SCR, SD_TPCOMIS TCOM
          WHERE TCOM.COMI_O_SEG = '2'
          AND   TCOM.EMPRESA = SCR.EMPRESA
          AND   TCOM.COD_COMIS = SCR.COD_COMIS
          AND   SCR.FECHA_VENC_SEG = (SELECT MAX(B.FECHA_VENC_SEG)
                                      FROM SD_ESCROW B
                                      WHERE B.COD_COMIS = SCR.COD_COMIS
                                      AND B.NUM_CREDITO = P_NUM_CREDITO
                                      AND EMPRESA = P_EMPRESA)
          AND   SCR.NUM_CREDITO = MAE.NUM_CREDITO
          AND   SCR.EMPRESA = MAE.EMPRESA
          AND   MAE.NUM_CREDITO = P_NUM_CREDITO
          AND   MAE.EMPRESA = P_EMPRESA

    EXECUTE PROCEDURE GENMOV(P_EMPRESA,  P_NUM_CREDITO, V_NUM_PRODUCTO, 
			     V_COD_COMIS ,V_FUN_SEG,  V_FECHA_HOY,   
			     V_MONTO_POLIZA + (V_MONTO_MENSUAL*2), V_FOLIO
                            ,V_SUCURSAL, V_DIVISA,      '0000'
                            ) INTO P_COD_RET, P_MENSAJE;

    --SE APLICO CORRECTAMENTE EL PASE CONTABLE
    IF P_COD_RET = '00000' THEN
      LET V_MONTO_TOTAL = V_MONTO_TOTAL + V_MONTO_POLIZA+(V_MONTO_MENSUAL*2);

      INSERT INTO SD_DETCOMI
             (empresa,cod_comis,num_credito,fecha_alta,fecha_pago
             ,monto_com,monto_pag,apli_factor,estado_com
             ,num_solicitud,user_insert,fecha_insert)
      VALUES (P_EMPRESA,V_COD_COMIS, P_NUM_CREDITO, V_FECHA_HOY, V_FECHA_HOY
             ,V_MONTO_POLIZA+(V_MONTO_MENSUAL*2), V_MONTO_POLIZA, NULL, 'A'
             ,NULL,USER,TODAY);

      UPDATE SD_ESCROW
      SET    SALDO = NVL(SALDO,0) + V_MONTO_POLIZA+(V_MONTO_MENSUAL*2)
      WHERE  COD_COMIS = V_COD_COMIS
      AND    NUM_cREDITO = P_NUM_CREDITO
      AND    EMPRESA = P_EMPRESA;

    END IF;

    IF V_PLAZO > 1 THEN
	IF V_COD_COMIS ="0103" THEN
	      LET V_FECHA_VENC_SEG = V_FECHA_HOY + 180;
	      LET V_CON_CUOTASEG = 1;
	      LET V_PLAZO = 6;
	ELSE
	      LET V_FECHA_VENC_SEG = V_FECHA_HOY + 360;
	      LET V_CON_CUOTASEG = 1;
	      LET V_PLAZO = 11;
	END IF

      --SE GENERA EL PLAN DE SEGURO PARALELO AL PLAN DE CAPITAL
      FOREACH SELECT FECHA_CUOTA
              INTO V_FECHA_CUOTA
              FROM SD_PAGINTER a
              WHERE a.FECHA_CUOTA > V_FECHA_HOY
--              AND a.FECHA_CUOTA <= V_FECHA_VENC_SEG
              AND a.NUM_CREDITO = P_NUM_CREDITO
              AND a.EMPRESA = P_EMPRESA

        INSERT INTO SD_DETCOMI
              (empresa,cod_comis,num_credito,fecha_alta,fecha_pago
              ,monto_com,monto_pag,apli_factor,estado_com
              ,num_solicitud,user_insert,fecha_insert)
        VALUES(P_EMPRESA, V_COD_COMIS, P_NUM_CREDITO,V_FECHA_CUOTA,NULL
              ,V_MONTO_MENSUAL,0,NULL,'P',NULL,USER,TODAY);

        IF V_CON_CUOTASEG = V_PLAZO THEN
          UPDATE SD_ESCROW 
          SET FECHA_VENC_SEG = V_FECHA_CUOTA
          WHERE COD_COMIS = V_COD_COMIS
          AND NUM_CREDITO = P_NUM_CREDITO
          AND EMPRESA = P_EMPRESA;
          EXIT FOREACH;
        ELSE
          LET V_CON_CUOTASEG = V_CON_CUOTASEG + 1;
        END IF;

      END FOREACH;
      
      SELECT MIN(FECHA_ALTA)
      INTO V_PRIM_FEC_SEG
      FROM SD_DETCOMI
      WHERE  ESTADO_COM = 'P'
      AND FECHA_ALTA > V_FECHA_HOY
      AND COD_COMIS = V_COD_COMIS
      AND NUM_CREDITO = P_NUM_CREDITO
      AND EMPRESA = P_EMPRESA;

      --SE COBRAN LAS DOS PRIMERAS CUOTAS PARA LA RESERVA
      {FOREACH SELECT FECHA_ALTA
              INTO V_FECHA_ALTA
              FROM SD_DETCOMI A
              WHERE ESTADO_COM = 'P'
              AND FECHA_ALTA <= (SELECT MIN(FECHA_ALTA)
                                 FROM SD_DETCOMI B
                                 WHERE  B.ESTADO_COM = 'P'
                                 AND B.COD_COMIS = A.COD_COMIS
                                 AND B.NUM_CREDITO = A.NUM_CREDITO
                                 AND B.EMPRESA = A.EMPRESA
                                 AND B.FECHA_ALTA > V_PRIM_FEC_SEG)
              AND COD_COMIS = V_COD_COMIS
              AND NUM_CREDITO = P_NUM_CREDITO
              AND EMPRESA = P_EMPRESA
              ORDER BY FECHA_ALTA

        --GENERA EL MOVIMIENTO CONTABLE DE LA CUOTA DE SEGURO
        EXECUTE PROCEDURE GENMOV(P_EMPRESA,  P_NUM_CREDITO, V_NUM_PRODUCTO,  V_COD_COMIS
                                ,V_FUN_SEG,  V_FECHA_HOY,   V_MONTO_MENSUAL, V_FOLIO
                                ,V_SUCURSAL, V_DIVISA,      '0000'
                                ) INTO P_COD_RET, P_MENSAJE;

        --SE ACTUALIZAN LAS CUOTA DE COMISIONES PARA EL SEGURO
        IF P_COD_RET = '00000' THEN
          {UPDATE SD_DETCOMI
          SET FECHA_PAGO = V_FECHA_HOY
             ,MONTO_PAG = V_MONTO_MENSUAL
             ,ESTADO_COM = 'A'
          WHERE FECHA_ALTA = TODAY
          AND COD_COMIS = V_COD_COMIS
          AND NUM_CREDITO = P_NUM_CREDITO
          AND EMPRESA = P_EMPRESA;

          UPDATE SD_ESCROW
          SET    SALDO = NVL(SALDO,0) + V_MONTO_MENSUAL
          WHERE  COD_COMIS = V_COD_COMIS
          AND    NUM_cREDITO = P_NUM_CREDITO
          AND    EMPRESA = P_EMPRESA;
        ELSE
          RETURN P_COD_RET, P_MENSAJE, 0;
        END IF;

        --SE ACUMULA LA CUOTA DE SEGURO PARA SER DESCONTADA DE LA MINISTRACION
        LET V_MONTO_TOTAL = V_MONTO_TOTAL + V_MONTO_MENSUAL;
      END FOREACH;}
    END IF;
  END FOREACH;
 
  IF V_MONTO_TOTAL IS NULL THEN
	LET V_MONTO_TOTAL = 0;
  END IF

  RETURN P_COD_RET, P_MENSAJE, V_MONTO_TOTAL;
END;
END PROCEDURE;