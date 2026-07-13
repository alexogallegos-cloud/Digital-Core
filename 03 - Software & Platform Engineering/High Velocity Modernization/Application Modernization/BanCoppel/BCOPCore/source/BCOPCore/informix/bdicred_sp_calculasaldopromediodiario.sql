CREATE PROCEDURE "informix".sp_calculasaldopromediodiario(
														pSaldoDiario 	CHAR(16),
														pConcepto 		CHAR(255),
														pCompras 		CHAR(16),
														pAbonos 		CHAR(16),
														pMesAPoner 		SMALLINT,
														pMesIngresado 	SMALLINT,
														pDiaActual 		SMALLINT,
														pEsIvaIntereses CHAR(1),
														pSaldoDiarioAnterior  CHAR(16))																				
RETURNING	CHAR(5) AS codRet,
			CHAR(16) AS cSaldoPromedioDiario,
			CHAR(16) AS cSaldoDiarioAnterior;

--------------------------------------------------------
-- DEFINICION DE VARIABLES 
--------------------------------------------------------
DEFINE sql_err   				SMALLINT;
DEFINE sCodRet   				CHAR(5);

DEFINE cSaldoPromedioDiario		CHAR(16);
DEFINE cUstedDebe 				CHAR(12);
DEFINE cUstedDebia 				CHAR(12);
DEFINE cIvaInteresesPeriodo 	CHAR(30);
DEFINE cInteresesPeriodo  		CHAR(25);
DEFINE cSaldoDiarioAnterior		CHAR(16);
DEFINE dDeterminaQueMontoPoner	DECIMAL(14,2);
DEFINE dMonto					DECIMAL(14,2);


--------------------------------------------------------
--	INICIALIZACION DE VARIABLES
--------------------------------------------------------
LET sql_err   				= 0;
LET sCodRet   				= '000';

LET cSaldoPromedioDiario    = '';
LET cUstedDebe              = 'USTED DEBE';
LET cUstedDebia             = 'USTED DEBIA';
LET cIvaInteresesPeriodo 		= "IVA DE INTERESES DEL PERIODO";
LET cInteresesPeriodo			= "INTERESES DEL PERIODO";
LET cSaldoDiarioAnterior    = pSaldoDiarioAnterior;
LET dDeterminaQueMontoPoner = 0;
LET dMonto                  = 0;

--SET DEBUG FILE TO "/home/sysifx/moises/bdicred/sp_calculaSaldoPromedioDiario.out";
--TRACE ON;

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

BEGIN

	ON EXCEPTION SET sql_err
      LET sCodRet = CAST(sql_err AS CHAR(5));
      RETURN sCodRet, NVL(cSaldoPromedioDiario,''),NVL(cSaldoDiarioAnterior,'');
	END EXCEPTION ;

	
	IF ((TRIM(pConcepto) = cUstedDebe) AND (pMesAPoner  = pMesIngresado) AND (pDiaActual >= 20) AND (pEsIvaIntereses = '0')) THEN --Se deberÃ  validar concepto usted debe
		LET cSaldoPromedioDiario = "";
	
	ELIF TRIM(pConcepto) = cUstedDebia THEN --Si no se deberÃ  validar el concepto usted debia
		LET cSaldoPromedioDiario  = pSaldoDiario;
		LET cSaldoDiarioAnterior = pSaldoDiario;
	ELSE--Si no, es algun otro dia, se calcularÃ  que monto poner
		
		IF pCompras = '' AND pAbonos <> '' THEN --Realizar los casteos en pAbonos y pCompras necesarios para los calculos
			LET dDeterminaQueMontoPoner = (CAST(pAbonos AS DECIMAL(14,2))* -1);
		ELIF pCompras <> "" AND pAbonos = '' THEN
			LET dDeterminaQueMontoPoner = CAST(pCompras AS DECIMAL(14,2));
		ELSE
			LET dDeterminaQueMontoPoner = 0;
		END IF;
		LET dmonto = (CAST(cSaldoDiarioAnterior AS DECIMAL(14,2)) + dDeterminaQueMontoPoner);
		LET cSaldoPromedioDiario = CAST(dmonto AS CHAR(16));
		LET cSaldoDiarioAnterior = cSaldoPromedioDiario;
	END IF; 
	
	--Verificar si se necesita validacion para ultimo registro, concepto usted debe
	IF TRIM(pConcepto) = cUstedDebe THEN
		LET cSaldoPromedioDiario = "";
	END IF;
	
  RETURN sCodRet, NVL(cSaldoPromedioDiario,''),NVL(cSaldoDiarioAnterior,'');

END;
END PROCEDURE DOCUMENT 'Version 1.00.000',
'DESCRIPCION: se crea sp para realizar calculo del saldo promedio diario.',
'AUTOR :Felipe De Jesus Urias Rocha',
'FECHA : 13/01/2017',
'BD: bdicred',
'MODIFICACION: Se agrega usuario informix en create de procedimiento',
'FECHA: 30/03/17',
'MODIFICO: Moises Soriano';

CREATE PROCEDURE "informix".sp_calculasaldosobreinteres(pEmpresa CHAR(3),
														pFechaInicialVencido DATE,
														pFechaFinalVencido DATE,
														pNumCredito CHAR(12),
														pSaldoPromedioDiario CHAR(16),
														pFechaActualMov CHAR(9),
														pFechaAnteriorMov CHAR(9),
														pFechaPosteriorMov CHAR(9),
														pConcepto CHAR(255),
														pConceptoAnt CHAR(255),
														pCargo CHAR(16),
														pAbono CHAR(16),
														pTasaAnualPie CHAR(8),
														pSaldoSobCalcInt CHAR(16),
														pUsuario CHAR(8))
														
														
RETURNING	CHAR(5) AS codRet,
			CHAR(16) AS cSaldoSobreCalculoInteres,
			DECIMAL(14,2) AS dInteresDiario,
			CHAR(16) AS cSaldoSobreCalculoInteresAnt;

--------------------------------------------------------
-- DEFINICION DE VARIABLES 
--------------------------------------------------------
DEFINE sql_err   							SMALLINT;
DEFINE cCodRet   							CHAR(5);

DEFINE cCodRet2								CHAR(5);
DEFINE cCodRet3  							CHAR(5);
DEFINE dFechaRetVencido        				DATE;
--DEFINE mCapitalVencido		   				MONEY(16,2);
DEFINE dCapitalVencido						DECIMAL(16,2);
DEFINE cSaldoSobreCalculoInteres			CHAR(16);
DEFINE cSaldoSobreCalculoInteresAnt			CHAR(16);
DEFINE cSaldoSobCalculoInteresFinal			CHAR(16);

DEFINE dInteresDiario						DECIMAL(14,2);
DEFINE cUstedDebia							CHAR(12);
DEFINE dFechaBase							DATE;
DEFINE cDia                                 CHAR(2);
DEFINE cMesT                                CHAR(3);
DEFINE cMes                                 CHAR(2);
DEFINE cAn                                  CHAR(2);
DEFINE dResta                               DECIMAL(16,2);

DEFINE cfechaAuxiliar                       CHAR(10);
DEFINE cAnioCompleto                         CHAR(4);
DEFINE cFechaFinalAux                       CHAR(10);
DEFINE cFechaHoy							CHAR(2);
DEFINE cFechaAnterior						CHAR(2);

DEFINE cIvaInteresesPeriodo 			CHAR(30); --Constante para comparar conceptos
DEFINE cInteresesPeriodo  				CHAR(25); --Constante para comparar conceptos
DEFINE cSaldoSobreCalculoInteresFinal CHAR(16);

--------------------------------------------------------
--	INICIALIZACION DE VARIABLES
--------------------------------------------------------
LET sql_err   							= 0;
LET cCodRet   							= '00000';

LET cCodRet2 							= '';
LET cCodRet3 							= '';
LET dFechaRetVencido 					= '';
--LET mCapitalVencido 					= 0.00;
LET dCapitalVencido						 	= 0;
LET cSaldoSobreCalculoInteres 			= '';
LET cSaldoSobreCalculoInteresAnt	 	= '';
LET cSaldoSobCalculoInteresFinal 		= '';
LET dResta								= 0;

LET dInteresDiario 						= 0;
LET cUstedDebia 						= 'USTED DEBIA';
LET dFechaBase                          = DATE(1);
LET cDia                                = '';
LET cMesT                               = '';
LET cMes                                = '';
LET cAn                                 = '';
LET cfechaAuxiliar                      = '';
LET cAnioCompleto                       = '';
LET cFechaFinalAux                      = '';

LET cFechaHoy                 			= '';
LET cFechaAnterior 			  			= '';
LET cIvaInteresesPeriodo 	 			= "IVA DE INTERESES DEL PERIODO";
LET cInteresesPeriodo		  			= "INTERESES DEL PERIODO";

--SET DEBUG FILE TO "/informix/mesg/sps/sp_calculaSaldoSobreInteres.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
		LET cCodRet = CAST(sql_err AS CHAR(5));
		RETURN cCodRet, NVL(cSaldoSobCalculoInteresFinal,''), NVL(dInteresDiario,0),cSaldoSobreCalculoInteresAnt;
	END EXCEPTION ;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		LET cDia  = SUBSTRING(pFechaActualMov FROM 1 FOR 2);
		LET cMesT = SUBSTRING(pFechaActualMov FROM 4 FOR 3);
		LET cAn   = SUBSTRING(pFechaActualMov FROM 8 FOR 2);
		
		LET cMes  = DECODE(cMesT,'ENE','01','FEB','02','MAR','03','ABR','04','MAY','05','JUN','06','JUL','07','AGO','08','SEP','09','OCT','10','NOV','11','DIC','12');
        
		LET cfechaAuxiliar = cMes ||'-'|| cDia ||'-' || cAn;
		
		LET cAnioCompleto = YEAR(cfechaAuxiliar);

		LET cFechaFinalAux = cAniocompleto || '-' || cMes || '-' || cDia;

		LET dFechaBase = TO_DATE(cFechaFinalAux,"%Y-%m-%d");
	
		
	FOREACH

		EXECUTE PROCEDURE bdicred:"informix".sp_CalcularVencidoDiarioEstadoCuenta_tdc(pEmpresa, pFechaInicialVencido, pFechaFinalVencido, pNumCredito, pUsuario, dFechaBase)
		INTO cCodRet2, dFechaRetVencido, dCapitalVencido
		
		IF TRIM(pConcepto) = cUstedDebia THEN
			EXIT FOREACH;
		END IF;
	
	END FOREACH;
		
		
		IF TRIM(pConcepto) = cUstedDebia THEN
			IF pSaldoPromedioDiario <= 0 THEN
				LET cSaldoSobreCalculoInteres = '0';
			ELSE
				
				LET  dResta = (CAST(pSaldoPromedioDiario AS DECIMAL(16,2)) - dCapitalVencido);	
				LET cSaldoSobreCalculoInteres = CAST(dResta AS CHAR(16));

			END IF;
		
		ELIF TRIM(pConcepto) <> cUstedDebia THEN

			LET cFechaHoy      = SUBSTR(pFechaActualMov, 1, 2);
			LET cFechaAnterior = SUBSTR(pFechaAnteriorMov, 1, 2);
				
			IF pFechaActualMov <> pFechaPosteriorMov THEN	
			
				IF (TRIM(pConcepto) = TRIM(cInteresesPeriodo)) AND (TRIM(pConceptoAnt) = TRIM(cIvaInteresesPeriodo)) THEN
					 IF (cFechaAnterior = cFechaHoy) THEN
						LET cSaldoSobreCalculoInteres = pSaldoPromedioDiario;
					 END IF;
				ELSE
					IF (dCapitalVencido <= 0) THEN
						IF ((pCargo <> "" OR pAbono <> "") AND (TRIM(pConcepto) <> cIvaInteresesPeriodo)) THEN
							IF (TRIM(pConcepto) <> cInteresesPeriodo) THEN
								LET cSaldoSobreCalculoInteres = pSaldoPromedioDiario;
							END IF;
						END IF;
					ELSE
						LET cSaldoSobreCalculoInteres = pSaldoSobCalcInt;
					END IF;
				
				END IF;
				
				LET dInteresDiario = cSaldoSobreCalculoInteres::DECIMAL *((pTasaAnualPie::DECIMAL/100)/360);
			ELSE
				IF NVL(cSaldoSobreCalculoInteres,"") = "" AND pSaldoSobCalcInt <> "" THEN
					LET cSaldoSobreCalculoInteresAnt = pSaldoSobCalcInt;
				END IF;	
			END IF;
		END IF;
	
	RETURN cCodRet, cSaldoSobreCalculoInteres, NVL(dInteresDiario,0),cSaldoSobreCalculoInteresAnt;


END;
END PROCEDURE DOCUMENT  'Version 1.00.000',
'DESCRIPCION: el sp se creo para sacar las columnas 6 y 7. para el aplicativo simtdc',
'AUTOR :Felipe De Jesus Urias Rocha',
'FECHA : 16/01/2017',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_detalle_edocta_simtdc ( pNumCredito      CHAR(20),
													  pFechaEmision    DATE,
													  pInicioSkip	   INTEGER,
													  pLimiteRegistros INTEGER)
RETURNING CHAR(5)   AS cCodRet,
		  DATE      AS dFechaEmision,
		  CHAR(20)  AS cNumCredito,
		  SMALLINT  AS sSecuencia,
		  SMALLINT  AS sNlinea,
		  CHAR(9)   AS cFechaMov,
		  CHAR(255) AS cConcepto,
		  CHAR(16)  AS cCargos,
		  CHAR(16)  AS cAbonos,
		  CHAR(9)   AS cFechaMovAnt,
		  CHAR(9)   AS cSigFechaMov,
		  CHAR(255) AS cConceptoAnt;


--------------------------------------------------------
--	DEFINICION DE VARIABLES
--------------------------------------------------------
DEFINE sSql_err       SMALLINT;
DEFINE cCodRet        CHAR(5);
DEFINE dFechaEmision  DATE;
DEFINE cNumCredito 	  CHAR(20);
DEFINE sSecuencia 	  SMALLINT;
DEFINE sNlinea 		  SMALLINT;
DEFINE cFechaMov 	  CHAR(9);
DEFINE cConcepto 	  CHAR(255);
DEFINE cCargos 		  CHAR(16);
DEFINE cAbonos 		  CHAR(16);
DEFINE cSigFechaMov   CHAR(9);
DEFINE cFechaMovAnt   CHAR(9);
DEFINE cConceptoAnt   CHAR(255);

--------------------------------------------------------
--	INICIALIZACION DE VARIABLES
--------------------------------------------------------
LET sSql_err      = 0;
LET cCodRet       = "000000";
--LET dFechaEmision = "01-01-1900";
LET dFechaEmision = DATE(1);
LET cNumCredito   = "";
LET sSecuencia    = 0;
LET sNlinea       = 0;
LET cFechaMov     = "";
LET cConcepto     = "";
LET cCargos       = "";
LET cAbonos       = "";
LET cSigFechaMov  = "";
LET cFechaMovAnt  = "";
LET cConceptoAnt  = "";

BEGIN
 ON EXCEPTION SET sSql_err
	IF sSql_err != 0 THEN
		LET cCodRet = sSql_err;
		RETURN cCodRet,NVL(dFechaEmision,date(1)), NVL(cNumCredito,""), NVL(sSecuencia,0),NVL(sNlinea,0), NVL(cFechaMov,""), NVL(cConcepto,""),NVL(cCargos,""),NVL(cAbonos,""),NVL(cFechaMovAnt,""),NVL(cSigFechaMov,""),NVL(cConceptoAnt,"");
	END IF;
 END EXCEPTION;
	  
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
    --SET DEBUG FILE TO "/informix/mesg/sps/sp_detalle_edocta_simtdc.out";
	--TRACE ON;	

	IF (NVL(pNumCredito,"") = "" OR NVL(pFechaEmision,date(1)) = "01/01/1900" OR NVL(pInicioSkip,-1) < 0 OR NVL(pLimiteRegistros,-1) < 0) THEN
		LET cCodRet = "00001";		RETURN cCodRet,NVL(dFechaEmision,date(1)), NVL(cNumCredito,""), NVL(sSecuencia,0),NVL(sNlinea,0), NVL(cFechaMov,""), NVL(cConcepto,""),NVL(cCargos,""),NVL(cAbonos,""),NVL(cFechaMovAnt,""),NVL(cSigFechaMov,""),NVL(cConceptoAnt,"");
	END IF;

	FOREACH 
		SELECT SKIP pInicioSkip LIMIT pLimiteRegistros	fecha_emision,num_credito,secuencia,nlinea,fecha_mov,concepto,cargos,abonos
		INTO dFechaEmision,cNumCredito,sSecuencia,sNlinea,cFechaMov,cConcepto,cCargos,cAbonos
		FROM bdicred:"informix".sd_detalle_edocta
		WHERE fecha_emision = pFechaEmision 
		AND num_credito = pNumCredito
		AND nlinea = 1
		ORDER BY secuencia, nlinea
		 
		SELECT fecha_mov
		INTO cSigFechaMov
		FROM bdicred:"informix".sd_detalle_edocta 
		WHERE fecha_emision = pFechaEmision
		AND num_credito = pNumCredito
		AND nlinea = 1
		AND secuencia = sSecuencia + 1;
		
		SELECT fecha_mov,concepto
		INTO cFechaMovAnt,cConceptoAnt
		FROM bdicred:"informix".sd_detalle_edocta 
		WHERE fecha_emision = pFechaEmision
		AND num_credito = pNumCredito
		AND nlinea = 1
		AND secuencia = sSecuencia - 1;
		
		RETURN cCodRet,NVL(dFechaEmision,date(1)), NVL(cNumCredito,""), NVL(sSecuencia,0),NVL(sNlinea,0), NVL(cFechaMov,""), NVL(cConcepto,""),NVL(cCargos,""),NVL(cAbonos,""),NVL(cFechaMovAnt,""),NVL(cSigFechaMov,""),NVL(cConceptoAnt,"") WITH RESUME;
	END FOREACH

	IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		LET cCodRet = "00185";
		RETURN cCodRet,NVL(dFechaEmision,date(1)), NVL(cNumCredito,""), NVL(sSecuencia,0),NVL(sNlinea,0), NVL(cFechaMov,""), NVL(cConcepto,""),NVL(cCargos,""),NVL(cAbonos,""),NVL(cFechaMovAnt,""),NVL(cSigFechaMov,""),NVL(cConceptoAnt,"");
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para consultar el detalle del estado de cuenta del cliente.',
'REALIZO: Jairo Valdez Gonzalez',
'SOLICITA: Ivan Castillo',
'FECHA: 10/01/2017',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_consultmovspres_bpi(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro INTEGER)
RETURNING CHAR(6)            AS codigo_retorno,
          DATE               AS fecha_movto,
		  VARCHAR(100,1)     AS concepto,
		  DECIMAL(18,2)      AS monto_cargo,
		  DECIMAL(18,2)      AS monto_abono;
		  
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE cCodRet         CHAR(6); 
DEFINE cMensajeRet     CHAR(80);

DEFINE iSerial         INTEGER;
DEFINE dtFechaMov      DATE;
DEFINE vRefTotal       VARCHAR(100,1);
DEFINE vDescripcion    VARCHAR(100,1);
DEFINE vNaturaleza     CHAR(1);
DEFINE dMonto          DECIMAL(18,2);
DEFINE vReferencia23   VARCHAR(50,1);
DEFINE vRfcComer       VARCHAR(50,1);
DEFINE cTransaccion    CHAR(4);
DEFINE dMontoCargo     DECIMAL(18,2);
DEFINE dMontoAbono     DECIMAL(18,2);
DEFINE cNumProducto    CHAR(4);
DEFINE cTpSolicitud    CHAR(1);

LET cCodRet            = "000000";
LET cMensajeRet        = "Se realizo la consulta correctamente";

LET iSerial            = 0;
LET dtFechaMov         = DATE(1);
LET vRefTotal          = "";
LET vDescripcion       = "";
LET vNaturaleza        = "";
LET dMonto             = 0;
LET vReferencia23      = "";
LET vRfcComer          = "";
LET cTransaccion       = "";
LET dMontoCargo        = 0;
LET dMontoAbono        = 0;
LET cNumProducto       = "";
LET cTpSolicitud       = "";


 -- *****************************************************************************************************        
   -- Obejtivo:            Consulta de Movimietos de los productos de ('6400', '7600','7700','6300','6400','7800' )
   -- Creado por:			Paul Quintero
   -- Solicitado por: 		Alejandro Vazquez   
   -- Fecha: 				06/04/2017
   -- *****************************************************************************************************



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO '/informix/paulq/pruebas/sp_consultmovspres_bpi.out';
-- TRACE ON;


FOREACH WITH HOLD
	SELECT a.num_producto, b.cod_prod
	INTO cNumProducto, cTpSolicitud
	  FROM "informix".sd_maecred a, "informix".sd_tipprod b 
	 WHERE a.num_credito = pNumCredito
	   AND a.empresa = pEmpresa
	   AND b.abrevia_prod = a.num_producto 
	   AND b.empresa = a.empresa
UNION
		SELECT a.num_producto, b.cod_prod
		  FROM "informix".sd_maecredcrd a, "informix".sd_tipprod b
		 WHERE a.num_credito = pNumCredito
		   AND a.empresa = pEmpresa
		   AND b.abrevia_prod = a.num_producto 
		   AND b.empresa = a.empresa
END FOREACH;

IF TRIM(NVL(cTpSolicitud,'')) = '' THEN
	   LET cCodRet = "000001"; --No existe el crèdito indicado.
	   RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);		 
END IF;


IF TRIM(NVL(cTpSolicitud,'')) = 'T' THEN

	FOREACH WITH HOLD
		(SELECT SKIP pRegistro FIRST 10
					secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = '' THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion, naturaleza, 
					monto, a.referencia23, a.rfc_comer, b.numero
				 INTO iSerial, dtFechaMov, vRefTotal, vDescripcion, vNaturaleza,
					  dMonto, vReferencia23, vRfcComer, cTransaccion
				 FROM "informix".sd_movdia a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.sistema = "06"
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal
		 UNION
				SELECT secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = ''
					THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion,
					naturaleza, monto, a.referencia23, a.rfc_comer, b.numero
				 FROM "informix".sd_movhis a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal)
		 ORDER BY fecha_mov,secuencia
		 
		 IF TRIM(NVL(vNaturaleza,'')) = "C" THEN 
			LET dMontoCargo = NVL(dMonto,0);
		 ELSE 
			LET dMontoAbono = NVL(dMonto,0);
		 END IF;	 
		 
		 RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0) WITH RESUME;
		 
		 LET dMontoCargo = 0;
		 LET dMontoAbono = 0; 
		 LET dMonto = 0;
		 
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET cCodRet = "000003"; --No hay registros con el filtro de consulta indicado.
	   RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);		 
	END IF;


ELSE

	FOREACH WITH HOLD
		(SELECT SKIP pRegistro FIRST 10
					secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = '' THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion, naturaleza, 
					monto, a.referencia23, a.rfc_comer, b.numero
				 INTO iSerial, dtFechaMov, vRefTotal, vDescripcion, vNaturaleza,
					  dMonto, vReferencia23, vRfcComer, cTransaccion
				 FROM "informix".sd_movdiacrd a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.sistema = "06"
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal
		 UNION
				SELECT secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = ''
					THEN c.transacc ELSE TRIM(a.referencia) END CASE, c.descripcion,
					naturaleza, monto, a.referencia23, a.rfc_comer, b.numero
				 FROM "informix".sd_movhiscrd a, bdinteg:"informix".si_transacc b, "informix".sd_transfun c
				 WHERE a.empresa = pEmpresa
				 AND a.num_credito = pNumCredito
				 AND c.empresa = a.empresa
			 AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				 AND b.empresa = c.empresa
				 AND b.numero = c.transacc
				 AND b.se_emite_edocta = "S"
				 AND a.reversado = "N"
				 AND fecha_mov >= pFechaInicial
				 AND fecha_mov <= pFechaFinal)
		 ORDER BY fecha_mov,secuencia
		 
		 IF TRIM(NVL(vNaturaleza,'')) = "C" THEN 
			LET dMontoCargo = NVL(dMonto,0);
		 ELSE 
			LET dMontoAbono = NVL(dMonto,0);
		 END IF;	 
		 
		 RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0) WITH RESUME;
		 
		 LET dMontoCargo = 0;
		 LET dMontoAbono = 0; 
		 LET dMonto = 0;
		 
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET cCodRet = "000003"; --No hay registros con el filtro de consulta indicado.
	   RETURN TRIM(NVL(cCodRet,'')), NVL(dtFechaMov,DATE(1)), TRIM(NVL(vDescripcion,'')), NVL(dMontoCargo,0), NVL(dMontoAbono,0);		 
	END IF;
	
END IF;

END
END PROCEDURE;