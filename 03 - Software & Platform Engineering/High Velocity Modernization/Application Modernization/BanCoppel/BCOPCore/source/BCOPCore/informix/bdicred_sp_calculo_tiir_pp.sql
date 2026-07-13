CREATE PROCEDURE "informix".sp_calculo_tiir_pp(
montoDisposicion DECIMAL(18,2),
pago_mensual DECIMAL(18,2),
numeroPeriodos INTEGER,
numeroPagosPeriodos INTEGER,
comision  DECIMAL(18,2)
)

RETURNING CHAR(6)  AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno,
		   DECIMAL(18,2) AS cat;

---DECLARACIONES
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);

DEFINE vCATMin          DECIMAL(18,2);
DEFINE vCAT            DECIMAL(21,10);
DEFINE vCATFin            DECIMAL(21,10);
DEFINE vCATMax          DECIMAL(21,10);
DEFINE vPrecision       DECIMAL(18,2);
DEFINE vPrecisionAux    DECIMAL(18,2);
DEFINE vPrecisionAux2    DECIMAL(18,2);
DEFINE vCiclado         INTEGER;
DEFINE iNumPago         INTEGER;

DEFINE vPagoSum         DECIMAL(18,2);
DEFINE vPlazo           DECIMAL(18,2);
DEFINE vCATx            DECIMAL(21,10);
DEFINE vCATy            DECIMAL(32,10);
DEFINE vCATz            DECIMAL(21,10);
DEFINE vCatFinal            DECIMAL(21,1);
DEFINE vPagoCosto       DECIMAL(18,2);
DEFINE pago_mensualAux       DECIMAL(18,2);
DEFINE iContador      	INTEGER;
DEFINE iNumPagos      	INTEGER;
DEFINE iBanPrecision      	INTEGER;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó el cálculo correctamente";

LET vCATMin = 0;
LET vCAT = 10;
LET vCATFin = 1;
LET vCATMax =5000;
LET vPrecision = 1;
LET vPrecisionAux = 1;
LET vPrecisionAux2 = 1;
LET vCiclado = 1;
LET iNumPago = 0;

LET vPagoSum = 0;
LET vPlazo = 0;
LET vCATx = 0;
LET vCATy = 0;
LET vCATz = 0;
LET vPagoCosto = 0;
LET pago_mensualAux = 0;
LET iContador = 1;
LET iNumPagos = 1;
LET vCatFinal =0;
LET iBanPrecision =0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCAT,0);
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_calculo_tiir_pp.out';
--TRACE ON;

LET pago_mensualAux = pago_mensual;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

WHILE (ABS(vPrecision) * 1000) > 1
	LET vPagoSum = 0;
	--LET vPlazo = 1;

	--LET pago_mensualAux = pago_mensual *12 ;
	WHILE iContador <=   numeroPeriodos

		IF iContador  = 0 THEN
			LET pago_mensualAux = (montoDisposicion * -1) + comision;
		ELSE
			LET pago_mensualAux = pago_mensual;
		END IF;

		LET vCATx = 1 + (vCAT/100);
		LET vCATy = iNumPagos ;
		LET vCATz = pow(vCATx, vCATy);

		LET vPagoCosto = pago_mensualAux / vCATz;

		LET vPagoSum = vPagoSum + vPagoCosto;
		LET iContador = iContador +1;
		LET iNumPagos = iNumPagos +1 ;
	END WHILE


		LET vPrecision = (montoDisposicion -comision)  - vPagoSum  ;
		 IF vPrecision < 0 THEN
			LET vCATMin = vCAT;
			LET vCAT = (vCATMax + vCAT) / 2;
		 ELIF vPrecision > 0 THEN
			LET vCATMax = vCAT;
			LET vCAT = (vCATMin + vCAT) / 2;
		 END IF;

     IF  vCiclado > 100 THEN
		LET vPrecisionAux2 = vPrecision;
		LET vPrecision = 0;
		LET iBanPrecision =1;
	 ELSE
		LET vPrecisionAux = vPrecision;

	 END IF;


LET iContador =1;
LET iNumPagos = 1 ;
LET vCiclado = vCiclado + 1;

END WHILE


IF  (vPrecisionAux2 <> vPrecisionAux) AND iBanPrecision =1 THEN
	LET vCAT =0;
END IF

LET vCATFin = vCAT;

LET vCatFinal = ( pow(1+ (vCAT/100),numeroPagosPeriodos) - 1 ) * 100;


RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCatFinal,0);

END
END PROCEDURE;