CREATE PROCEDURE "informix".sp_obtienefechapago_creditos(pEmpresa CHAR(3),pFecha DATE,pFrecuencia Integer, pDiaPago   Integer )
RETURNING 	CHAR(6)   AS CodRetorno,  	-- Codigo de retorno
            DATE AS Fecha_PrimerPago,
			INTEGER AS Dia_pago; 	  --fecha del primer pago
		  
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
-- Variables de control de errores
DEFINE isqlerr      	INTEGER;
-- Variables para valores de retorno
DEFINE cCodRet     		CHAR(6); 	      -- Código de retorno de error
DEFINE dtDiaFecha       DATE;
DEFINE dtDiaprimero     DATE;  
DEFINE dtDiaPago        DATE;  
DEFINE dtDiaPagoAux        DATE;  
DEFINE iDiastranscurridos         INTEGER;  
DEFINE iDiasmenos    INTEGER;  
DEFINE  cMes 			CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE dDiaprimero		DATE;
DEFINE dDiaUltimo		DATE;
-- ****************************************************************************
-- *           ASIGNACION DE VALORES POR DEFAULT A VARIABLES                  *
-- ****************************************************************************
LET isqlerr     		= 0;

LET cCodRet     		= "000000";
LET dtDiaFecha          = DATE(1);
LET dtDiaprimero        = DATE(1);
LET dtDiaPago           = DATE(1);
LET dtDiaPagoAux           = pFecha;
LET iDiastranscurridos  = 0;
LET iDiasmenos       = 0; 
LET dDiaprimero			= '';
LET dDiaUltimo			= '';
LET cMes = '';
LET cAnio = '';

BEGIN
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

ON EXCEPTION SET iSqlErr
      LET cCodRet= iSqlErr;
	  
	  
	  RETURN cCodRet,'',0;
END EXCEPTION;

--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_obtienefechapago.out';
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
 
	IF NVL(pEmpresa,'') = '' OR  NVL(pFecha,"")=""   THEN
		LET cCodRet     = "00001";  --Faltan parametros de entrada
		RETURN cCodRet,'',0;
	END IF;	

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	

	  
	  IF NVL(pDiaPago,0) =0 OR NVL(pFrecuencia,0) = 0 THEN
		LET cCodRet     = "00002";  --Error al obtener el dia de pago 
		RETURN cCodRet,'',0;
	  END IF;

	  IF pFrecuencia = 1 THEN	
		IF DAY(pDiaPago) IN (29,30,31) THEN
			IF  MONTH(pFecha) = 2 AND DAY(pFecha) NOT IN (28,29) THEN	
				LET cMes = MONTH(pFecha);
				LET cAnio= YEAR (pFecha);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;
				
				LET iDiastranscurridos =  dtDiaPago - pFecha;	
				IF iDiastranscurridos <= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET cMes = MONTH(dtDiaPago);
					LET cAnio= YEAR (dtDiaPago);
					EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
					INTO cCodRet , dDiaprimero, dDiaUltimo; 
					LET dtDiaPago = dDiaUltimo;					
				END IF;		
				
			ELIF DAY(pDiaPago) = 31 THEN				
				LET cMes = MONTH(pFecha);
				LET cAnio= YEAR (pFecha);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;			
				
				LET iDiastranscurridos =  dtDiaPago - pFecha;	
				IF iDiastranscurridos <= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET cMes = MONTH(dtDiaPago);
					LET cAnio= YEAR (dtDiaPago);
					EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
					INTO cCodRet , dDiaprimero, dDiaUltimo; 
					LET dtDiaPago = dDiaUltimo;					
				END IF;			
			ELSE 		
				CALL bdicred:"informix".monthadd(pFecha,1) RETURNING dtDiaPagoAux;			
				IF  MONTH(pFecha) = 2 THEN
					LET dtDiaPago = MONTH(dtDiaPagoAux)||"-"||DAY(pDiaPago)||"-"||YEAR(dtDiaPagoAux);	
					
				ELSE 		
					LET dtDiaPago = MONTH(pFecha)||"-"||DAY(pDiaPago)||"-"||YEAR(pFecha);					
				END IF;											
			END IF;
		ELSE
			LET dtDiaPago = MONTH(pFecha)||"-"||DAY(pDiaPago)||"-"||YEAR(pFecha);
		END IF;	
		LET iDiastranscurridos =  dtDiaPago - pFecha;	
		IF iDiastranscurridos < 0  THEN
			LET iDiastranscurridos =  iDiastranscurridos * -1;
			IF iDiastranscurridos >= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET iDiastranscurridos =  dtDiaPago - pFecha;	
			END IF;
		 END IF;
		IF iDiastranscurridos <= 8 THEN
			CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;				
		END IF;
	END IF
	IF pFrecuencia = 2 THEN			  
		  IF  MONTH(pFecha) = 2 THEN
				IF DAY(pDiaPago) = 29  THEN
					LET iDiasmenos =1;
				ELIF DAY(pDiaPago) = 30 THEN
					LET iDiasmenos =2;
				ELIF DAY(pDiaPago) = 31 THEN
					LET iDiasmenos =3;	
				ELSE
					LET iDiasmenos =0;
				END IF;
		 ELSE
				LET iDiasmenos =0;
		 END IF;		
	
		 LET dtDiaPago = MONTH(pFecha)||"-"||DAY(pDiaPago-iDiasmenos)||"-"||YEAR(pFecha);
		 LET iDiastranscurridos =  dtDiaPago - pFecha;	
		
		 IF iDiastranscurridos < 0  THEN
			LET iDiastranscurridos =  iDiastranscurridos * -1;
			IF iDiastranscurridos >= 8 THEN
					CALL bdicred:"informix".monthadd(dtDiaPago,1) RETURNING dtDiaPago;	
					LET iDiastranscurridos =  dtDiaPago - pFecha;	
			END IF;
		 END IF;
		
		 IF iDiastranscurridos <= 8 THEN --- para que se pague esa misma quincena
			IF DAY(dtDiaPago) <= 14  AND MONTH(dtDiaPago) <> 2 THEN 
				LET dtDiaPago = dtDiaPago + 15 UNITS DAY;	
			ELIF DAY(dtDiaPago) <= 13  AND MONTH(dtDiaPago) = 2 THEN 
				LET dtDiaPago = dtDiaPago + 15 UNITS DAY;				
			ELSE
				LET cMes = MONTH(dtDiaPago);
				LET cAnio= YEAR (dtDiaPago);
				EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
				INTO cCodRet , dDiaprimero, dDiaUltimo; 
				LET dtDiaPago = dDiaUltimo;
			END IF;
			
		 END IF;	       		
	END IF		
	RETURN cCodRet,dtDiaPago,pDiaPago;	
END;

END PROCEDURE
DOCUMENT
'Descripcion: procedimiento que obtiene la fecha de primer pago, dependiendo el dia de pago, la frecuencia de pago del credito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 10/agosto/2011',
'BD    : BDISOLIC',
'Version: 20110810.1021',
'Descripcion: Se modifica procedimiento para obtener la proxima fecha de pago, de acuerdo a la fecha de pago proporcionada',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 18/agosto/2011',
'BD    : BDISOLIC',
'Version: 20110818.1021';

CREATE PROCEDURE "informix".sp_obtiene_aproximacion_creditos( pMonto 	     DECIMAL(18,6), 	-- MONTO DEL PRESTAMO
                                          pPlazo 	     DECIMAL(18,6),	-- PLAZO 
                                          pMensualidad	 DECIMAL(18,6), -- MENSUALIDAD
                                          pTasaAnual	 DECIMAL(18,6),	-- TASA ANUAL
                                          pTasaAnualIva	 DECIMAL(18,6),	-- TASA ANUAL CON IVA
                                          pFechaApert	 DATE,          -- FECHA DE APERTURA
                                          pIvaSuc	     DECIMAL(18,6),	-- IVA QUE SE MANEJA EN LA SUCURSAL
                                          pIntervalo	 DECIMAL(18,6),	-- CANTIDAD PARA DELIMITAR EL LIMITE SUPERIOR Y EL LIMITE INFERIOR
                                          pDiferencia	 DECIMAL(18,6),	-- CANTIDAD MAXIMA PARA DIFERENCIA DE ULTIMA MENSUALIDAD
										  pTpoPago       INTEGER ,       --VALIDA EL TIPO DE PRODUCTO, SI ES PRESTAMO O CREDINOMINA.   
										  pDiaPago       INTEGER 
										--  pNumCred		 CHAR(20)   -- NUMERO DE CREDITO
                                         ) 

RETURNING 	
        CHAR(6) AS Codigo, 	-- CODIGO DE RETORNO
		INTEGER AS Importe;	-- IMPORTE QUE SE GENERA YA SEA MONTO, PLAZO O MENSUALIDAD

------------------------------------------------------------------------------------------------------------
                -- CONTROL DE CAMBIOS
------------------------------------------------------------------------------------------------------------
-- Modifico: Jose Luis Pulido Zepeda
-- Descripcion: Se cambio la forma de calcular la mensualidad inicial, tambien se agrego parametro 
--              para definir los limites superior e inferior de la mensualidad a buscar, ademas se 
--              cambió la forma de obtener la fecha de couta y los dias por periodo, tambièn se agrego
--   	        parametro de entrada para manejar la diferencia entre la mensualidad final y la anterior.
-- Fecha: 2009/10/21
-- Version: 20091021.1800
------------------------------------------------------------------------------------------------------------
-- Modifico: Jose Luis Pulido Zepeda
-- Descripcion: Se cambio que en ves de retornar el error '000010' se envie la ultima mensualidad que 
--              dejo en cero el credito.
-- Fecha: 2009/11/03
-- Version: 20091103.1045
------------------------------------------------------------------------------------------------------------
-- Modifico: Jose Luis Pulido Zepeda
-- Descripcion: Se agrego nueva variable para almacenar el valor d el amensualidad, para el caso cuando 
--              se han sobrepasado los limites y se tiene que regresar la ultima mensulidad que dejo en 
--              cero el credito.
-- Fecha: 2009/11/04
-- Version: 20091104.1120
------------------------------------------------------------------------------------------------------------
-- Modifico: Jose Luis Pulido Zepeda
-- Descripcion: SE CAMBIO EL VALOR DE RETORNO A INTEGER.
-- Fecha: 2009/11/12
-- Version: 20091112.1111
------------------------------------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo Aguilar
-- Descripción: Se eliminan validaciones de rango de valores permitidos para monto y plazo, de modo
--              que se realice la aproximación con los datos de parámetros que reciba el spl.
-- Fecha: 2009/12/01
-- Versión: 20091201.1206

------------------------------------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo Aguilar
-- Descripción: Se modifica para cuando una mensualidad no alcance a cubrir parte de capital, se 
--              realice una nueva aproximación buscando un nuevo monto para el pago mensual.
-- Fecha: 2009/12/10
-- Versión: 20091210.0935
-------------------------------------------------------------------------------------------------------------			
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica las variables para calculos de tasas money(14,2) a decimal(9,6).
--             Se modifica el calculo de fechas para dias inhabiles.  
--Fecha: 2010/01/27
--Version: 20090127.0845
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Para el cálculo de la mensualidad, retornar el último valor correcto calculado.
--Fecha: 2010/02/04
--Version: 20100204.1600
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para que el la mensualidad de la cuota no sobrepase al monto indicado
--	 	 en el parámetro de entrada en la ejecución del spl
--Fecha: 2010/02/05
--Version: 20100205.1342
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Hector Manuel Bojorquez Ruelas, Jesús Manuel Aguilar Heredia
--Descripcion: Se modifica para que se pueda utilizar en el producto Credinomina, para lo cual se le agrego un parametro de entrada mas para identificar la forma de pago del prestamo.
--Fecha: 2011/05/04
--Version: 20110504.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jesús Manuel Aguilar Heredia
--Descripcion: Se modifica para que  se contemple el dia de pago en la proyeccion, y no se manejen dias 15 y 30, para lo cual se le agrego un parametro para el numero de credito.
--que se usara para determinar las fechas de cuota del credito.
--Fecha: 2011/08/10
--Version: 20110810.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jesús Manuel Aguilar Heredia
--Descripcion: Se modifica para que  se redonde a 2 decimales en todos los calculos que se hacen de cantidades a pagar, para evitar problemas presentados en la proyeccion
--Fecha: 2011/09/22
--Version: 20110922.1010
---------------------------------------------------------------------------------------------------------------
DEFINE cCodRet		CHAR(6);	    -- CODIGO DE RETORNO
DEFINE iSqlErr		INTEGER;	    -- CODIGO DE ERROR
DEFINE mImporte		DECIMAL(18,6);	-- IMPORTE CALCULADO
DEFINE mTasaPeriodo	DECIMAL(18,6);	-- TASA DEL PERIODO
DEFINE mIntComp		DECIMAL(18,6);	-- INTERES COMPUESTO
DEFINE mMensualidad	DECIMAL(18,6);	-- MES
DEFINE mMensualidad2 DECIMAL(18,6);	-- MES
DEFINE mCapital		DECIMAL(18,6);	-- CAPITAL
DEFINE mInteres		DECIMAL(18,6);	-- INTERES
DEFINE mIva		    DECIMAL(18,6);	-- IVA
DEFINE mSaldoFin	DECIMAL(18,6);	-- SALDO FINAL
DEFINE mSaldoIni	DECIMAL(18,6);	-- SALDO INICIAL
DEFINE mSaldoTot	DECIMAL(18,6);	-- SALDO TOTAL
DEFINE sPlazo		INTEGER;	    -- PLAZO
DEFINE dFechaAnt	DATE;		    -- FECHA ANTERIOR
DEFINE sDias		SMALLINT;	    -- DIAS DEL PERIODO
DEFINE mTasaMensIva	DECIMAL(18,6);	-- TASA MENSUAL CON IVA
DEFINE mTasaAcumAnt DECIMAL(18,6);	-- TASA ACUMULADA
DEFINE sContador	SMALLINT;	    -- CONTADOR
DEFINE mSaldoAux	DECIMAL(18,6);	-- SALDO AUXILIAR
DEFINE sDiaIni		SMALLINT;	    -- DIA INICIAL
DEFINE sDia		    SMALLINT;	    -- DIA DEL CORTE
DEFINE sContinua	SMALLINT;	    -- BANDERA PARA SABER SI CONTINUA ENTRANDO AL WHILE 1 = NO ENTRA 0 = ENTRA
DEFINE mLimiteInf	DECIMAL(18,6);	-- LIMITE INFERIOR PARA LA MENSUALIDAD
DEFINE mLimiteSup	DECIMAL(18,6);	-- LIMITE SUPERIOR PARA LA MENSUALIDAD
DEFINE mCentro		DECIMAL(18,6);	-- MENSUALIDAD INTERMEDIA PARA BUSQUEDA BINARIA
DEFINE mMonto		DECIMAL(18,6);	-- MONTO DEL PRESTAMO
DEFINE mMensaux		DECIMAL(18,6);	-- GUARDA LA MENSUALIDAD CORRECTA ANTES D ELA ULTIMA COUTA EN LA QUE LA MENSUALIDAD CAMBIA
DEFINE mMensaux2	DECIMAL(18,6);	-- GUARDA LA MENSUALIDAD ANTERIOR QUE DEJO EN CERO EL SALDO POR SI LA ULTIMA MENSUALIDAD NO ES LA CORRECTA        
DEFINE dUltimaMens      DECIMAL(18,6);    
DEFINE cValidaMens      CHAR(1);
DEFINE mMontoAux	DECIMAL(18,6);
DEFINE mMensualidadAux          DECIMAL(18,6);
DEFINE condicion INTEGER;
DEFINE mMomtoAuxc DECIMAL(18,6);
DEFINE dFechaInicial	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dtDiaprimero	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dFechaCouta		DATE;	
DEFINE dfechafinmes    DATE;
DEFINE iDiaPago    INTEGER;

define vcapaini DECIMAL(18,6);
define vplazmax DECIMAL(18,6);



LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET mImporte		= 0;
LET mTasaPeriodo	= 0;
LET mIntComp		= 0;
LET mMensualidad	= pMensualidad;
LET mCapital		= 0;
LET mInteres		= 0;
LET mIva			= 0;
LET mSaldoFin		= 0;
LET mSaldoIni		= 0;
LET mSaldoTot		= 0;
LET sPlazo          = pPlazo;
LET dFechaAnt		= pFechaApert;
LET sDias			= 0;
LET mTasaMensIva	= 0;
LET mTasaAcumAnt	= 1;
LET sContador		= 0;
LET mSaldoAux		= 0;
LET sDia			= 0;
LET sContinua		= 0;
LET mLimiteInf		= 0;
LET mLimiteSup		= 0;
LET mCentro			= 0;
LET mMonto			= PMonto;
LET mMensaux		= 0;
LET mMensaux2		= 0;   
LET dUltimaMens         = 0;
LET cValidaMens         = "0";
LET mMontoAux		= 0;
LET mMensualidadAux = 0;
LET dFechaInicial	= pFechaApert;
LET dtDiaprimero	= pFechaApert;
LET dFechaCouta		= pFechaApert;

LET condicion = 0;
LET mMomtoAuxc = 0;

LET dfechafinmes    = DATE(1);
LET iDiaPago       = 0; 

let vcapaini = 0;
let vplazmax = 0;


BEGIN

	ON EXCEPTION  SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET  cCodRet  = iSqlErr;
			RETURN cCodRet, mImporte;
		END IF;
	END  EXCEPTION
	
--	SET DEBUG FILE TO "/pisa/cas/proyecta_cas.out";
--	TRACE ON;

	-- VALIDAMOS QUE LOS DATOS DE ENTRADA SON CORRECTOS
    IF pTasaAnual = 0  OR pTasaAnualIva = 0 OR NVL(pFechaApert,"") = "" THEN
		LET cCodRet = "000010";
		RETURN cCodRet, mImporte;
	END IF;

   IF NVL(pMonto,0) > 0 AND NVL(pMensualidad,0) > 0 THEN
       LET pPlazo = 0;
   END IF;
	
	LET sDiaIni = DAY(dFechaAnt);

	LET mTasaMensIva = pTasaAnualIva / 12;

	IF pTpoPago = 1 OR pTpoPago = 0 THEN  ---Pago mensual
		LET mMensualidad = ROUND((pMonto * 30.5 * mTasaMensIva) / (30 * (1 - POW((1 + mTasaMensIva),-sPlazo))), 0);
	ELIF pTpoPago = 2 THEN    ---Pago Quincenal
		LET mMensualidad = (ROUND((pMonto * 15.25 * (mTasaMensIva / 2) )  / (15 * (1 - POW((1 + (mTasaMensIva / 2) ),-sPlazo))), 0));
	END IF;	
	
	-- SE OBTIENE EL LIMITE INFERIOR
	LET mLimiteInf = ROUND(mMensualidad * (1 - pIntervalo), 0);
	
	-- SE OBTIENE EL LIMITE SUPERIOR
	
	LET mLimiteSup = ROUND(mMensualidad * (1 + pIntervalo), 0);	
		
	WHILE sContinua = 0 -- SE UTILIZA PARA EL CALCULO DE LA MENSUALIDAD
		LET dFechaAnt		= pFechaApert;
		LET dFechaCouta		=pFechaApert;
		LET dFechaAnt	= pFechaApert;
		--LET cValidaMens = '0';
		IF pMensualidad > 0 AND pMonto > 0 THEN -- PARA CALCULO DE PLAZO
			LET mMensualidad = pMensualidad;
			LET mSaldoIni = pMonto;
		END IF;
	
		IF pPlazo > 0 AND pMonto > 0 THEN -- PARA CALCULO DE MENSUALIDAD
                    
		
			-- SE TOMA EL MONTO DEL PRESTAMO COMO EL SALDO INICIAL
			LET mSaldoIni = pMonto;
			
			-- SE CALCULA EL NUEVO VALOR PROMEDIO QUE SE TOMA PARA BUSCAR LA MENSUALIDAD
			IF mLimiteInf <= mLimiteSup THEN
				LET mMensualidad =TRUNC((mLimiteInf + mLimiteSup) / 2,0);			 
     			LET mCentro = mMensualidad;	
				
			ELSE
                                --IF mSaldoFin >0 THEN
                                   IF cValidaMens  = '1' THEN
                                       LET mMensualidad = dUltimaMens; 
                                   ELSE
                                        LET cCodRet = '000012';
                                    END IF;
                                --END IF;
					 --LET cCodRet = '000011';			
				RETURN cCodRet, mMensualidad;
                --RETURN cCodRet, mImporte;
			END IF;	
			
		END IF;
		LET dFechaInicial = dFechaCouta;
		FOR sContador = 1 TO sPlazo STEP 1
		
			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************

				IF pTpoPago IN(1,2) THEN   --Pago  credinomina				
						--se obtiene la fecha de la proxima cuota.
						EXECUTE PROCEDURE "informix".sp_obtienefechapago_creditos('001',dFechaCouta,pTpoPago,pDiaPago)
							INTO cCodRet,dFechaCouta,iDiaPago;	
						IF cCodRet::INTEGER <> 0  THEN	
							LET cCodRet    = "000008";	--Ocurrio un Error al obtener la fecha de pago del crédito para credinomina.
							RETURN cCodRet, mImporte;
						END IF;							
					   IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
							LET dFechaCouta = dFechaCouta + 1;
						END IF;						
						IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
							LET dFechaAnt = dFechaAnt + 1;
						END IF;
						LET dFechaAnt =dFechaAnt;
						LET sDias = dFechaCouta - dFechaAnt;	--se obtienen los dias del periodo
						LET dFechaAnt = dFechaCouta;								
				ELIF pTpoPago = 0 THEN   --Pago Mensual prestamo
					-- SE OBTIENE LA SIGUIENTE FECHA DE COUTA Y LA FECHA DE COUTA ANTERIOR

					CALL bdicred:"informix".monthadd(dFechaInicial,sContador) RETURNING dFechaCouta;
					CALL bdicred:"informix".monthadd(dFechaInicial,sContador-1) RETURNING dFechaAnt;

					IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
						LET dFechaCouta = dFechaCouta + 1;
					END IF;

					IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
						LET dFechaAnt = dFechaAnt + 1;
					END IF;
					
					LET sDias = dFechaCouta - dFechaAnt;
				END IF;
		
			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************
			
			IF pPlazo > 0 AND pMensualidad > 0 THEN -- CALCULO DEL MONTO DEL PRESTAMO EN BASE AL PLAZO Y LA MENSUALIDAD
	
				-- SE OBTIENE LA TASA MENSUAL CON IVA
				LET mTasaMensIva = ROUND(((pTasaAnualIva / 360) * sDias) * 100,4);
			-- CUANDO TERMINE EL CICLO FOR YA NO VOLVERA A CUMPLIRSE LA CONDICION DEL WHILE
				LET sContinua = 1;
		
				-- SE OBTIENE EL INTERES COMPUESTO
				LET mIntComp = ROUND(mTasaAcumAnt * (1 + (mTasaMensIva / 100)),6);
			
				-- SE ACUMULA EL INTERES COMPUESTO OBTENIDO
				LET mTasaAcumAnt = mIntComp;
				
				-- SE OBTIENE EL CAPITAL
				LET mCapital = ROUND(pMensualidad / mIntComp,2);
				
				-- SE OBTIENE EL INTERES
				LET mInteres = ROUND(((pMensualidad - mCapital) / (1 + pIvaSuc)+0.003),2);
				
				-- SE OBTIENE EL IVA DEL INTERES
				LET mIva = ROUND((mInteres * pIvaSuc)+0.003,2);  --JMAH
				LET mCapital = ROUND(pMensualidad - mInteres -mIva,2);
				-- SE OBTIENE EL SALDO FINAL
				LET mSaldoFin = mSaldoIni + mCapital;
				
				-- SE ACUMULA EL SALDO
				LET mSaldoTot = mSaldoTot + mSaldoFin;
				
				LET mSaldoAux = mSaldoIni;
				
				-- EL SALDO FINAL SE CONVIERTE EN EL SALDO INICIAL DEL PROXIMO MES
				LET mSaldoIni = mSaldoFin;
				
				-- SE ASIGNA A LA VARIABLE DE RETORNO EL MONTO TOTAL DEL PRESTAMO
				LET mImporte = mSaldoFin;
				
				IF NVL(mCapital,0) < 0 THEN
					LET cCodRet = '000012';
					RETURN cCodRet, mMensaux2;
				END IF;
				
			ELIF pPlazo > 0 AND pMonto > 0 THEN -- CALCULO DE LA MENSUALIDAD EN BASE AL PLAZO Y AL MONTO DEL PRESTAMO
			
				-- SE OBTIENE EL INTERES
				LET mInteres = ROUND(mSaldoIni * (pTasaAnual / 360) * sDias,2);
				
				-- SE OBTIENE EL IVA DEL INTERES
				LET mIva = ROUND(mInteres * pIvaSuc,2);
				
				-- SE VALIDA SI EL MONTO DE LA MENSUALIDAD ALCANZA A PAGAR LOS INTERES DEL PRIMER MES
				IF mSaldoIni + mInteres + mIva > mMensualidad AND sContador = 1 THEN
					LET mMensualidad = mMensualidad ;			
				ELIF mSaldoIni + mInteres + mIva < mMensualidad AND sContador > 1 THEN -- AJUSTAR LA MENSUALIDAD EN EL ULTIMO PAGO
					LET mMensaux = mMensualidad;
					LET mMensualidad = mSaldoIni + mInteres + mIva;
				END IF;
								
				
				-- SE OBTIENE EL CAPITAL
				LET mCapital = ROUND(mMensualidad - (mInteres + mIva),2);
				LET mInteres = mInteres;
				LET mIva  = mIva ;
				-- SE OBTIENE EL SALDO FINAL
				LET mSaldoFin = mSaldoIni - mCapital;
				
				LET mSaldoAux = mSaldoIni;
				LET mSaldoIni = mSaldoFin;			
						
				IF NVL(mCapital,0) < 0  THEN --AND sContador > 1
                                    LET sContinua = 0;  
                                    LET mLimiteInf = mCentro + 1;
                                    EXIT FOR;				
				ELIF sContador = sPlazo AND mSaldoFin > 0 THEN
                                    LET sContinua = 0;
                                    LET mLimiteInf = mCentro + 1;
                                    EXIT FOR;
				ELIF sContador < sPlazo AND mSaldoFin = 0 THEN
                                    LET sContinua = 0;
                                    LET mLimiteSup = mCentro - 1;
                                    EXIT FOR;
				ELIF sContador = sPlazo AND mSaldoFin = 0 THEN
								 
                                  IF (mCentro - mMensualidad) / mMensualidad > pDiferencia Then									
										LET sContinua = 0;
                                        LET mLimiteSup = mCentro - 1;									
                                    ELSE
                                        LET sContinua = 1;
                                  END IF;
                                        LET mMensaux2 = mMensaux;			
								-- Valida si la en vuelta anterior se salda el préstamo  --con la mensualidad calculada y guarda el valor.  								                                              
									LET dUltimaMens = mMensaux2;
									LET cValidaMens = '1';
								
				END IF;
				
				-- SE ASIGNA A LA VARIABLE DE RETORNO LA MENSUALIDAD CALCULADA
				LET mImporte = mMensaux;
			ELIF pMensualidad > 0 AND pMonto > 0 THEN -- CALCULO DEL PLAZO EN BASE A LA MENSUALIDAD Y AL MONTO DEL PRESTAMO
			
				-- CUANDO TERMINE EL CICLO FOR YA NO VOLVERA A CUMPLIRSE LA CONDICION DEL WHILE
				LET sContinua = 1;
			
				-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
				IF mSaldoFin > 0 THEN
					LET mSaldoIni = mSaldoFin;
				END IF;
			
				--SE CALCULAN LOS INTERESES
				LET mInteres = ROUND(mSaldoIni * (pTasaAnual/360) * sDias,2);
				
				-- SE OBTIENE EL IVA DEL INTERES
				LET mIva = ROUND(mInteres * pIvaSuc,2);
				LET mMontoAux = mMonto + mInteres + mIva;
				
				IF mMontoAux < mMensualidad THEN
					LET mMensualidadAux = mMonto + mInteres + mIva;
					IF mMensualidadAux > pMensualidad THEN
                        LET mMensualidad = pMensualidad;
					ELSE
						LET mMensualidad = mMensualidadAux;
					END IF;
					LET mCapital = ROUND(mMonto,2);
					LET mSaldoFin = mMensualidad - mCapital - mInteres - mIva;
				
					-- SE ASIGNA A LA VARIABLE DE RETORNO EL PLAZO OBTENIDO
					LET mImporte = sContador;
					
					EXIT FOR;
				ELSE
					--SE CALCULA EL CAPITAL
					LET mCapital = ROUND(pMensualidad - mInteres - mIva,2);
				END IF;
				
				IF NVL(mCapital,0) < 0 THEN
					LET cCodRet = '000012';
					RETURN cCodRet, mMensaux2;
				END IF;
				-- SE CALCULA EL SALDO FINAL
				LET mSaldoFin = mSaldoIni - mCapital;
				LET mMonto = mSaldoIni - mCapital;			
			END IF;
			
		END FOR;
	END WHILE;

	RETURN cCodRet, mImporte;
END;
END PROCEDURE

DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Se calcula la mensualidad, el monto o el plazo de un prestamos segun los parametros que se envien',
'Fecha: 2009/10/16',
'Version: 20091016.0853';

CREATE PROCEDURE "informix".encabezado2_edocta_sif(pEmpresa CHAR(3),pTarjeta CHAR(20),pFechaEmision char(10))

RETURNING CHAR(5),          DATE ,    			CHAR(20),    		DECIMAL(14,2),
		                    DECIMAL(14,2),	    DECIMAL(14,2),	    DATE,
		                    DATE,				DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
					        DECIMAL(14,2),	    DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		CHAR(560),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),		DECIMAL(14,2),
                            DECIMAL(14,2),      DATE,			    DATE,
                            CHAR(255),          DECIMAL(14,2),      DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),      DECIMAL(14,2),
                            DECIMAL(14,2),      DECIMAL(14,2),       DECIMAL(14,2),
                            DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err   SMALLINT;
DEFINE sCodRet   CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 			CHAR(20);

DEFINE v_sdo_pagar 						DECIMAL(14,2);
DEFINE v_sdo_debe 						DECIMAL(14,2);
DEFINE v_sdo_disponible 			DECIMAL(14,2);
DEFINE v_pago_antes_de 				DATE;
DEFINE v_fecha_corte 					DATE;
DEFINE v_usted_debia 					DECIMAL(14,2);
DEFINE v_menos_abonos 				DECIMAL(14,2);
DEFINE v_menos_o_abonos 			DECIMAL(14,2);
DEFINE v_mas_compras 					DECIMAL(14,2);
DEFINE v_mas_o_cargos 				DECIMAL(14,2);
DEFINE v_mas_disp_efectivo 		DECIMAL(14,2);
DEFINE v_mas_intereses 				DECIMAL(14,2);
DEFINE v_mas_iva 							DECIMAL(14,2);
DEFINE v_usted_debe 					DECIMAL(14,2);
DEFINE v_mas_rendimientos 		DECIMAL(14,2);
DEFINE v_mensajes 						CHAR(560);
DEFINE v_capital_tc 					DECIMAL(14,2);
DEFINE v_interes_tc 					DECIMAL(14,2);
DEFINE v_iva_interes_tc 			DECIMAL(14,2);
DEFINE v_capital_ven_tc 			DECIMAL(14,2);
DEFINE v_interes_ven_tc 			DECIMAL(14,2);
DEFINE v_iva_interes_ven_tc 	DECIMAL(14,2);
DEFINE v_moratorios_tc 				DECIMAL(14,2);
DEFINE v_iva_moratorios_tc 		DECIMAL(14,2);
DEFINE v_interes_pago_total_tc DECIMAL(14,2);
DEFINE v_limite_tc 						DECIMAL(14,2);
DEFINE v_periodo_tc_ini 			DATE;
DEFINE v_periodo_tc_fin 			DATE;
DEFINE v_dias_periodo_tc 			CHAR(255);
DEFINE v_sus_comisiones				DECIMAL(14,2);
DEFINE pNumCredito                  CHAR(20);
--INICIO-----LHM 
DEFINE v_comisiones_iva      DECIMAL(14,2);
DEFINE v_intereses_iva       DECIMAL(14,2);
DEFINE v_intereses_pag       DECIMAL(14,2);
DEFINE v_saldos_menos_pag    DECIMAL(14,2);
DEFINE v_compras_disp        DECIMAL(14,2);
--FIN--------LHM
DEFINE v_cat                 DECIMAL(14,2);
DEFINE v_tasa_anual          DECIMAL(14,2);   
DEFINE v_tasa_mora           DECIMAL(14,2);


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';

LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";

LET v_sdo_pagar 				= 0;
LET v_sdo_debe 					= 0;
LET v_sdo_disponible 		= 0;
LET v_pago_antes_de 		= " ";
LET v_fecha_corte 			= " ";
LET v_usted_debia 			= 0;
LET v_menos_abonos 			= 0;
LET v_menos_o_abonos 		= 0;
LET v_mas_compras 			= 0;
LET v_mas_o_cargos 			= 0;
LET v_mas_disp_efectivo = 0;
LET v_mas_intereses 		= 0;
LET v_mas_iva 					= 0;
LET v_usted_debe 				= 0;
LET v_mas_rendimientos 	= 0;
LET v_mensajes 					= "";
LET v_capital_tc 				= 0;
LET v_interes_tc 				= 0;
LET v_iva_interes_tc 		= 0;
LET v_capital_ven_tc 		= 0;
LET v_interes_ven_tc 		= 0;
LET v_iva_interes_ven_tc = 0;
LET v_moratorios_tc 		= 0;
LET v_iva_moratorios_tc = 0;
LET v_interes_pago_total_tc = 0;
LET v_limite_tc 				= 0;
LET v_periodo_tc_ini 		= " ";
LET v_periodo_tc_fin 		= " ";
LET v_dias_periodo_tc 	= "";
LET v_sus_comisiones		= 0;
--INICIO-----LHM 
LET v_comisiones_iva     = 0;
LET v_intereses_iva      = 0;
LET v_intereses_pag      = 0;
LET v_saldos_menos_pag   = 0;
LET v_compras_disp       = 0;
LET v_cat                = 0;
LET v_tasa_anual         = 0;   
LET v_tasa_mora          = 0;
LET pNumCredito          = "";



--SET DEBUG FILE TO "encabezado2_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0),      NVL(v_cat,0),                       NVL(v_tasa_anual,0),
                NVL(v_tasa_mora,0);
     END EXCEPTION ;




		SELECT num_credito INTO pNumCredito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T';


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = pNumCredito and fecha_corte = pFechaEmision)
		THEN
			 SELECT		a.fecha_emision,		   a.num_credito,			a.sdo_pagar,
						a.sdo_debe,			       a.sdo_disponible,		a.pago_antes_de,
						a.fecha_corte,		       a.usted_debia,			a.menos_abonos,
						a.menos_o_abonos,		   a.mas_compras,			a.mas_o_cargos,
						a.mas_disp_efectivo,	   a.mas_intereses,			a.mas_iva,
						a.usted_debe,			   a.mas_rendimientos,		a.mensajes,
						a.capital_tc,			   a.interes_tc,			a.iva_interes_tc,
						a.capital_ven_tc,		   a.interes_ven_tc,		a.iva_interes_ven_tc,
						a.moratorios_tc,		   a.iva_moratorios_tc,	    a.interes_pago_total_tc,
						a.limite_tc,			   a.periodo_tc_ini,		a.periodo_tc_fin,
						a.dias_periodo_tc,	       a.sus_comisiones,        a.comisiones_iva,
						a.intereses_iva,           a.intereses_pag,         a.saldo_menos_pag,
						a.compras_disp,            b.cat,                   b.tasa_anual,
						b.tasa_mora
			 INTO		v_fecha_emision,	   v_num_credito,			v_sdo_pagar,
						v_sdo_debe,			   v_sdo_disponible,		v_pago_antes_de,
						v_fecha_corte,		   v_usted_debia,			v_menos_abonos,
						v_menos_o_abonos,	   v_mas_compras,			v_mas_o_cargos,
						v_mas_disp_efectivo,   v_mas_intereses,			v_mas_iva,
						v_usted_debe,		   v_mas_rendimientos,		v_mensajes,
						v_capital_tc,		   v_interes_tc,			v_iva_interes_tc,
						v_capital_ven_tc,	   v_interes_ven_tc,		v_iva_interes_ven_tc,
						v_moratorios_tc,	   v_iva_moratorios_tc,	    v_interes_pago_total_tc,
						v_limite_tc,		   v_periodo_tc_ini,		v_periodo_tc_fin,
						v_dias_periodo_tc,	   v_sus_comisiones,        v_comisiones_iva,
						v_intereses_iva,       v_intereses_pag,         v_saldos_menos_pag,
						v_compras_disp,        v_cat,                   v_tasa_anual,
						v_tasa_mora
			 FROM sd_encabezado2_edocta a, sd_pie_edocta b
			 WHERE a.fecha_emision = b.fecha_emision
			   AND a.fecha_emision = pFechaEmision 
			   AND a.num_credito = b.num_credito
			   AND a.num_credito = pNumCredito;

			IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
			  RETURN sCodRet, 
						nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
						NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
						nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
						NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
						NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
						NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
						NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
						NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
						NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
						NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
						NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
						NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
						NVL(v_compras_disp,0),      NVL(v_cat,0),                       NVL(v_tasa_anual,0),
						NVL(v_tasa_mora,0);
			END IF
		ELSE
			SELECT		a.fecha_emision,		   a.num_credito,			a.sdo_pagar,
						a.sdo_debe,			       a.sdo_disponible,		a.pago_antes_de,
						a.fecha_corte,		       a.usted_debia,			a.menos_abonos,
						a.menos_o_abonos,		   a.mas_compras,			a.mas_o_cargos,
						a.mas_disp_efectivo,	   a.mas_intereses,			a.mas_iva,
						a.usted_debe,			   a.mas_rendimientos,		a.mensajes,
						a.capital_tc,			   a.interes_tc,			a.iva_interes_tc,
						a.capital_ven_tc,		   a.interes_ven_tc,		a.iva_interes_ven_tc,
						a.moratorios_tc,		   a.iva_moratorios_tc,	    a.interes_pago_total_tc,
						a.limite_tc,			   a.periodo_tc_ini,		a.periodo_tc_fin,
						a.dias_periodo_tc,	       a.sus_comisiones,        a.comisiones_iva,
						a.intereses_iva,           a.intereses_pag,         a.saldo_menos_pag,
						a.compras_disp,            b.cat,                   b.tasa_anual,
						b.tasa_mora
			 INTO		v_fecha_emision,	   v_num_credito,			v_sdo_pagar,
						v_sdo_debe,			   v_sdo_disponible,		v_pago_antes_de,
						v_fecha_corte,		   v_usted_debia,			v_menos_abonos,
						v_menos_o_abonos,	   v_mas_compras,			v_mas_o_cargos,
						v_mas_disp_efectivo,   v_mas_intereses,			v_mas_iva,
						v_usted_debe,		   v_mas_rendimientos,		v_mensajes,
						v_capital_tc,		   v_interes_tc,			v_iva_interes_tc,
						v_capital_ven_tc,	   v_interes_ven_tc,		v_iva_interes_ven_tc,
						v_moratorios_tc,	   v_iva_moratorios_tc,	    v_interes_pago_total_tc,
						v_limite_tc,		   v_periodo_tc_ini,		v_periodo_tc_fin,
						v_dias_periodo_tc,	   v_sus_comisiones,        v_comisiones_iva,
						v_intereses_iva,       v_intereses_pag,         v_saldos_menos_pag,
						v_compras_disp,        v_cat,                   v_tasa_anual,
						v_tasa_mora
			 FROM bdicred@pld_tcp:sd_encabezado2_edocta a, bdicred@pld_tcp:sd_pie_edocta b
			 WHERE a.fecha_emision = b.fecha_emision
			   AND a.fecha_emision = pFechaEmision 
			   AND a.num_credito = b.num_credito
			   AND a.num_credito = pNumCredito;

			IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
			  RETURN sCodRet, 
						nvl(v_fecha_emision,date(1)),NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
						NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
						nvl(v_fecha_corte,date(1)),				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
						NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
						NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
						NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
						NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
						NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
						NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
						NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
						NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
						NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
						NVL(v_compras_disp,0),      NVL(v_cat,0),                       NVL(v_tasa_anual,0),
						NVL(v_tasa_mora,0);
			END IF
	END IF;	
  RETURN sCodRet, 
				v_fecha_emision,			NVL(v_num_credito,""),				NVL(v_sdo_pagar,0),
				NVL(v_sdo_debe,0),			NVL(v_sdo_disponible,0),			NVL(v_pago_antes_de,0),
				v_fecha_corte,				NVL(v_usted_debia,0),				NVL(v_menos_abonos,0),
				NVL(v_menos_o_abonos,0),	NVL(v_mas_compras,0),				NVL(v_mas_o_cargos,0),
				NVL(v_mas_disp_efectivo,0),	NVL(v_mas_intereses,0),             NVL(v_mas_iva,0),
				NVL(v_usted_debe,0),		NVL(v_mas_rendimientos,0),          NVL(v_mensajes,""),
				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),				NVL(v_iva_interes_tc,0),
				NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),			NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),         NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),			NVL(v_periodo_tc_ini,DATE(1)),		NVL(v_periodo_tc_fin,DATE(1)),
				NVL(v_dias_periodo_tc,""),	NVL(v_sus_comisiones,0),            NVL(v_comisiones_iva,0),
                NVL(v_intereses_iva,0),     NVL(v_intereses_pag,0),             NVL(v_saldos_menos_pag,0),
                NVL(v_compras_disp,0),      NVL(v_cat,0),                       NVL(v_tasa_anual,0),
                NVL(v_tasa_mora,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".pie_edocta_sif(pEmpresa CHAR(3),pTarjeta CHAR(20),pFechaEmision char(10))
       RETURNING CHAR(5),DATE ,DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),CHAR(3),DECIMAL(14,2),DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);
DEFINE v_fecha_emision 	    DATE ;
DEFINE v_num_credito 	    CHAR(20);
DEFINE v_tasa_mensual 	    DECIMAL(14,2);
DEFINE v_tasa_anual 	    DECIMAL(14,2);
DEFINE v_cat 			    DECIMAL(14,2);
DEFINE v_saldo_promedio     DECIMAL(14,2);
DEFINE v_dias_periodo 	    CHAR(3);
DEFINE v_tasa_mora 		    DECIMAL(14,2);
DEFINE v_tasa_mensual_mora 	DECIMAL(14,2);
DEFINE pNumCredito          CHAR(20);


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';
LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";
LET v_tasa_mensual 			= 0;
LET v_tasa_anual 			= 0;
LET v_cat 					= 0;
LET v_saldo_promedio 		= 0;
LET v_dias_periodo 			= "";
LET v_tasa_mora 			= 0;
LET v_tasa_mensual_mora     = 0;
LET pNumCredito         = "";

--SET DEBUG FILE TO "pie_edocta.out";
--TRACE ON;

BEGIN
  	  ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
     END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------

		SELECT num_credito INTO pNumCredito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T';
	
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = pNumCredito and fecha_corte = pFechaEmision)
		THEN
			SELECT 	fecha_emision, num_credito, tasa_mensual, tasa_anual, cat, saldo_promedio,
					dias_periodo, tasa_mora, tasa_mensual_mora 
			  INTO 	v_fecha_emision, v_num_credito,	v_tasa_mensual, v_tasa_anual, v_cat, v_saldo_promedio,
					v_dias_periodo,	v_tasa_mora, v_tasa_mensual_mora
			  FROM  sd_pie_edocta
			 WHERE fecha_emision = pFechaEmision 
			   AND num_credito = pNumCredito;

			IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
			  RETURN sCodRet, 
						NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
						NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
						NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
			END IF
		ELSE
			SELECT 	fecha_emision, num_credito, tasa_mensual, tasa_anual, cat, saldo_promedio,
					dias_periodo, tasa_mora, tasa_mensual_mora 
			  INTO 	v_fecha_emision, v_num_credito,	v_tasa_mensual, v_tasa_anual, v_cat, v_saldo_promedio,
					v_dias_periodo,	v_tasa_mora, v_tasa_mensual_mora
			  FROM  bdicred@pld_tcp:sd_pie_edocta
			 WHERE fecha_emision = pFechaEmision 
			   AND num_credito = pNumCredito;

			IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
			  RETURN sCodRet, 
						NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
						NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
						NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
			END IF
	END IF;	
  RETURN sCodRet, 
				v_fecha_emision,         NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	 NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	 NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".detalle_edocta_sif(pEmpresa CHAR(3),pTarjeta CHAR(20),pFechaEmision char(10))
RETURNING CHAR(5),DATE ,CHAR(20),SMALLINT,SMALLINT,CHAR(9),CHAR(255),DECIMAL(14,2),DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err          SMALLINT;
DEFINE sCodRet          CHAR(5);
DEFINE v_fecha_emision 	DATE ;
DEFINE v_num_credito 	CHAR(20);
DEFINE v_secuencia 		SMALLINT;
DEFINE v_nlinea 		SMALLINT;
DEFINE v_fecha_mov 		CHAR(9);
DEFINE v_concepto 		CHAR(255);
DEFINE v_cargos 		DECIMAL(14,2);
DEFINE v_abonos 		DECIMAL(14,2);
DEFINE pNumCredito      CHAR(20);
DEFINE v_Registros      SMALLINT;
DEFINE pNumRegistros    INTEGER;
--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err             = 0;
LET sCodRet             = '000';
LET v_fecha_emision 	= " ";
LET v_num_credito 		= "";
LET pNumCredito         = "";
LET v_secuencia 		= 0;
LET v_nlinea 			= 0;
LET v_fecha_mov 		= "";
LET v_concepto 			= "";
LET v_cargos 			= "";
LET v_abonos 			= "";
LET pNumRegistros       = 0;
LET v_Registros    	    = 0;

--SET DEBUG FILE TO "detalle_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
					nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"");
		END EXCEPTION ;

		SELECT num_credito INTO pNumCredito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T';

  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = pNumCredito and fecha_corte = pFechaEmision)
		THEN	
			FOREACH 
				SELECT	fecha_emision,			num_credito,				secuencia,
								nlinea,							fecha_mov,					concepto,
								cargos,							abonos
				INTO		v_fecha_emision,			v_num_credito,				v_secuencia,
								v_nlinea,							v_fecha_mov,					v_concepto,
								v_cargos,							v_abonos
				 FROM sd_detalle_edocta
				 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
				 ORDER BY secuencia,nlinea


				LET v_Registros = v_Registros + 1;
				IF v_Registros <= pNumRegistros THEN
						CONTINUE FOREACH;
				END IF
				
				IF v_num_credito IS NULL THEN
						LET sCodRet = "185";
				  RETURN sCodRet, 
							nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
							NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
							NVL(v_cargos,""),NVL(v_abonos,"");
				END IF

			  RETURN sCodRet, 
							v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
							NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
							NVL(v_cargos,""),NVL(v_abonos,"")
			 WITH RESUME;
			
			END FOREACH
		ELSE
			FOREACH 
				SELECT	fecha_emision,			num_credito,				secuencia,
								nlinea,							fecha_mov,					concepto,
								cargos,							abonos
				INTO		v_fecha_emision,			v_num_credito,				v_secuencia,
								v_nlinea,							v_fecha_mov,					v_concepto,
								v_cargos,							v_abonos
				 FROM bdicred@pld_tcp:sd_detalle_edocta
				 --FROM sd_detalle_edocta
				 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
				 ORDER BY secuencia,nlinea


				LET v_Registros = v_Registros + 1;
				IF v_Registros <= pNumRegistros THEN
						CONTINUE FOREACH;
				END IF
				
				IF v_num_credito IS NULL THEN
						LET sCodRet = "185";
				  RETURN sCodRet, 
							nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
							NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
							NVL(v_cargos,""),NVL(v_abonos,"");
				END IF

			  RETURN sCodRet, 
							v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
							NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
							NVL(v_cargos,""),NVL(v_abonos,"")
			 WITH RESUME;
			
			END FOREACH
	END IF;	
END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".mensajes_edocta_sif(
					   pEmpresa CHAR(3),
			           pNumTarjeta CHAR(20),
			           pEmision CHAR(8),
			           pNumRegistros CHAR(1))
RETURNING CHAR(5), DATE ,CHAR(20),SMALLINT,	SMALLINT,CHAR(255),	CHAR(255);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);

DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			CHAR(255);
DEFINE v_mensajes 			CHAR(255);
DEFINE v_credito_tar        CHAR(20);
DEFINE v_Registros          SMALLINT;
DEFINE v_edocta             SMALLINT;


LET sql_err          = 0;
LET sCodRet          = '000';
LET v_fecha_emision  = " ";
LET v_num_credito 	 = "";
LET v_secuencia 	 = 0;
LET v_nlinea 		 = 0;
LET v_si_paga 		 = "";
LET v_mensajes 		 = "";
LET v_Registros    	 = 0;
LET v_credito_tar    = 0;
LET v_edocta         = 0;

--SET DEBUG FILE TO "mensajes_edocta.out";
--TRACE ON;



BEGIN

    ON EXCEPTION SET sql_err
    LET sCodRet = sql_err;
    RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
    END EXCEPTION ;


    LET v_fecha_emision = MDY(SUBSTR(pEmision,1,2),SUBSTR(pEmision,3,2),SUBSTR(pEmision,5,4));
	
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where fecha_corte = v_fecha_emision)
		THEN
			SELECT num_credito INTO v_credito_tar FROM bdicred:sd_encabezado_edocta
			 WHERE fecha_emision = v_fecha_emision AND num_tarjeta = pNumTarjeta;
			
	
		   IF v_fecha_emision <= MDY('02','20','2010') THEN

				FOREACH 
					SELECT 	fecha_emision,	num_credito, secuencia,
							nlinea,	si_paga, mensajes
					INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
							v_nlinea, v_si_paga, v_mensajes
					FROM sd_mensajes_edocta
					WHERE fecha_emision = v_fecha_emision AND num_credito = v_credito_tar
					ORDER BY secuencia,nlinea


					LET v_Registros = v_Registros + 1;

					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";

					RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
					END IF

					RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
					WITH RESUME;

				END FOREACH

		   ELSE

				FOREACH 


					SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
					FROM sd_mensajes_edocta a
					left outer join bdicred:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
					WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					UNION ALL
					select fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
					INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
					FROM sd_mensajes_edocta a
					WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					order by 2,3,4


					LET v_Registros = v_Registros + 1;

					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";

					RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
					END IF

					RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
					WITH RESUME;

				END FOREACH

		   END IF;
		ELSE
			SELECT num_credito INTO v_credito_tar FROM bdicred@pld_tcp:sd_encabezado_edocta
			 WHERE fecha_emision = v_fecha_emision AND num_tarjeta = pNumTarjeta;
			
	
		   IF v_fecha_emision <= MDY('02','20','2010') THEN

				FOREACH 
					SELECT 	fecha_emision,	num_credito, secuencia,
							nlinea,	si_paga, mensajes
					INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
							v_nlinea, v_si_paga, v_mensajes
					FROM bdicred@pld_tcp:sd_mensajes_edocta
					WHERE fecha_emision = v_fecha_emision AND num_credito = v_credito_tar
					ORDER BY secuencia,nlinea


					LET v_Registros = v_Registros + 1;

					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";

					RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
					END IF

					RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
					WITH RESUME;

				END FOREACH

		   ELSE

				FOREACH 


					SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
					FROM bdicred@pld_tcp:sd_mensajes_edocta a
					left outer join bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
					WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					UNION ALL
					select fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
					INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
					FROM bdicred@pld_tcp:sd_mensajes_edocta a
					WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					order by 2,3,4


					LET v_Registros = v_Registros + 1;

					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";

					RETURN sCodRet, v_fecha_emision, v_num_credito, v_secuencia, v_nlinea, v_si_paga,	v_mensajes;
					END IF

					RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
					WITH RESUME;

				END FOREACH

		   END IF;
	END IF;	   
END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".aclaraciones_edocta_sif(
                                pEmpresa CHAR(3),
                                pTarjeta CHAR(20),
                                pFechaEmision char(10))

RETURNING CHAR(5), DATE , CHAR(20),SMALLINT,SMALLINT,CHAR(10),CHAR(12),CHAR(12),CHAR(255), DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err             SMALLINT;
DEFINE sCodRet             CHAR(5);
DEFINE v_fecha_emision 	   DATE ;
DEFINE v_num_credito 	   CHAR(20);
DEFINE v_secuencia 		   SMALLINT;
DEFINE v_nlinea 		   SMALLINT;
DEFINE v_fecha_aclara 	   CHAR(10);
DEFINE v_descripcion 	   CHAR(255);
DEFINE v_importe 	       DECIMAL(14,2);
DEFINE v_Registros         SMALLINT;
DEFINE v_folio             CHAR(12);
DEFINE v_fecha_mov         CHAR(10);
DEFINE pNumRegistros       SMALLINT;
DEFINE pNumCredito         CHAR(20);


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';
LET v_fecha_emision = " ";
LET v_num_credito 	= "";
LET v_secuencia 	= 0;
LET v_nlinea 		= 0;
LET v_fecha_aclara 	= "";
LET v_descripcion 	= "";
LET v_importe 		= 0;
LET v_Registros    	= 0;
LET v_folio         = "";
LET v_fecha_mov     = "";
LET pNumRegistros   = 0;
LET pNumCredito     = "";

--SET DEBUG FILE TO "aclaraciones_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet,NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
						NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
                        NVL(v_fecha_mov,""), NVL(v_descripcion,""),
						NVL(v_importe,0);
		END EXCEPTION ;


		SELECT num_credito INTO pNumCredito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T';


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = pNumCredito and fecha_corte = pFechaEmision)
		THEN
			FOREACH
				SELECT	fecha_emision, num_credito,	secuencia,
						nlinea,	fecha_aclara, folio, fecha_movimiento,
						descripcion, importe
				INTO	v_fecha_emision, v_num_credito,	v_secuencia,
						v_nlinea, v_fecha_aclara, v_folio, v_fecha_mov,
						v_descripcion, v_importe

				 FROM sd_aclaraciones_edocta
				 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
				 ORDER BY secuencia,nlinea


				LET v_Registros = v_Registros + 1;
				IF v_Registros <= pNumRegistros THEN
						CONTINUE FOREACH;
				END IF

				IF v_num_credito IS NULL THEN
					LET sCodRet = "185";
			  RETURN sCodRet,  	NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0);
				END IF

			  RETURN sCodRet,
								v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0) WITH RESUME;

			END FOREACH
		ELSE
			FOREACH
				SELECT	fecha_emision, num_credito,	secuencia,
						nlinea,	fecha_aclara, folio, fecha_movimiento,
						descripcion, importe
				INTO	v_fecha_emision, v_num_credito,	v_secuencia,
						v_nlinea, v_fecha_aclara, v_folio, v_fecha_mov,
						v_descripcion, v_importe

				 --FROM sd_aclaraciones_edocta
				 FROM bdicred@pld_tcp:sd_aclaraciones_edocta
				 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
				 ORDER BY secuencia,nlinea


				LET v_Registros = v_Registros + 1;
				IF v_Registros <= pNumRegistros THEN
						CONTINUE FOREACH;
				END IF

				IF v_num_credito IS NULL THEN
					LET sCodRet = "185";
			  RETURN sCodRet,  	NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0);
				END IF

			  RETURN sCodRet,
								v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0) WITH RESUME;

			END FOREACH
		END IF;	
END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".mensajes_edocta_sif2(pEmpresa CHAR(3),pNumTarjeta CHAR(20),pEmision CHAR(8),pNumRegistros CHAR(1))
RETURNING CHAR(5), DATE ,CHAR(20),SMALLINT,	SMALLINT,CHAR(255),	CHAR(255);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);
DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);
DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			CHAR(255);
DEFINE v_mensajes 			CHAR(255);
DEFINE v_credito_tar        CHAR(20);
DEFINE v_Registros          SMALLINT;
DEFINE v_edocta             SMALLINT;

LET sql_err          = 0;
LET sCodRet          = '000';
LET v_fecha_emision  = " ";
LET v_num_credito 	 = "";
LET v_secuencia 	 = 0;
LET v_nlinea 		 = 0;
LET v_si_paga 		 = "";
LET v_mensajes 		 = "";
LET v_Registros    	 = 0;
LET v_credito_tar    = 0;
LET v_edocta         = 0;

--SET DEBUG FILE TO "/pisa/leo/mensajes_edocta.out";
--TRACE ON;

BEGIN
    ON EXCEPTION SET sql_err
    LET sCodRet = sql_err;
    RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
    END EXCEPTION ;

    LET v_fecha_emision = MDY(SUBSTR(pEmision,1,2),SUBSTR(pEmision,3,2),SUBSTR(pEmision,5,4));
    
		SELECT num_credito 
          INTO v_credito_tar
		  FROM sd_tarjeta
		 WHERE empresa = pEmpresa 
           AND num_tarjeta = pNumTarjeta 
           AND tipo_tarjeta = 'T';
		   
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = v_credito_tar and fecha_corte = v_fecha_emision)
		THEN  
		   IF v_fecha_emision <= MDY('02','20','2010') THEN

				FOREACH 
					SELECT 	fecha_emision,	num_credito, secuencia,
							nlinea,	si_paga, mensajes
					  INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
							v_nlinea, v_si_paga, v_mensajes
					  FROM sd_mensajes_edocta
					 WHERE fecha_emision = v_fecha_emision AND num_credito = v_credito_tar
				  ORDER BY secuencia,nlinea

					LET v_Registros = v_Registros + 1;
					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";
						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
					END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;

				END FOREACH

		   ELSE
				IF EXISTS(SELECT * FROM sd_encabezado_edocta where fecha_emision = v_fecha_emision and num_tarjeta = pNumTarjeta) THEN

					FOREACH 

						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM sd_mensajes_edocta a
			   LEFT OUTER JOIN sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM sd_mensajes_edocta a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 ELSE

					FOREACH 
						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM bdicred:sd_mensajes_edocta_hist a
			   LEFT OUTER JOIN sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM bdicred:sd_mensajes_edocta_hist a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 END IF;
		   END IF;
		ELSE
			IF v_fecha_emision <= MDY('02','20','2010') THEN

				FOREACH 
					SELECT 	fecha_emision,	num_credito, secuencia,
							nlinea,	si_paga, mensajes
					  INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
							v_nlinea, v_si_paga, v_mensajes
					  FROM bdicred@pld_tcp:sd_mensajes_edocta
					 WHERE fecha_emision = v_fecha_emision AND num_credito = v_credito_tar
				  ORDER BY secuencia,nlinea

					LET v_Registros = v_Registros + 1;
					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";
						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
					END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;

				END FOREACH

		   ELSE
				IF EXISTS(SELECT * FROM bdicred@pld_tcp:sd_encabezado_edocta where fecha_emision = v_fecha_emision and num_tarjeta = pNumTarjeta) THEN

					FOREACH 

						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM bdicred@pld_tcp:sd_mensajes_edocta a
			   LEFT OUTER JOIN bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM bdicred@pld_tcp:sd_mensajes_edocta a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 ELSE

					FOREACH 
						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM bdicred:sd_mensajes_edocta_hist a
			   LEFT OUTER JOIN bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM bdicred:sd_mensajes_edocta_hist a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 END IF;
		   END IF;
	END IF;
END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130321.1130',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 21 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_calcularvencidodiarioestadocuenta(pempresa CHAR(3), pfechainicial DATE, pfechafinal DATE, pnumcredito CHAR(12),pUsuario CHAR(8))
RETURNING CHAR (5), DATE, MONEY (16,2);


--VARIABLES
DEFINE vcodret             CHAR(6);
DEFINE v_dFecha            DATE;
DEFINE v_mCapitalVencido   MONEY (16,2);
DEFINE vsqlerr             INTEGER;
DEFINE v_mAbono            MONEY (16,2);
DEFINE v_mCargo            MONEY (16,2);
DEFINE v_cNumCredito       CHAR(12);


--SET DEBUG FILE TO '/respaldosbd/sp_CalcularVencidoDiarioEstadoCuenta.out';
--TRACE ON;

--VALIDA PARÁMETROS
IF  pEmpresa = '' OR  pEmpresa IS NULL OR pFechaInicial = '' OR pFechaInicial IS NULL OR pFechaFinal = '' OR pFechaFinal IS NULL OR pNumCredito = '' OR pNumCredito IS NULL THEN
      LET vcodret = '001';   --Paràmetros inválidos
      RETURN vcodret, v_dFecha, v_mCapitalVencido;
END IF;

BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, v_dFecha, v_mCapitalVencido;

        END IF;
    END EXCEPTION;

    -- Inicializa Variables
    LET vcodret = '000000';
    --LET v_dFecha = '01-01-1900';
    LET v_mCapitalVencido = 0;
    lET v_mAbono = 0;
    lET v_cNumCredito = '';
    LET v_dFecha = pFechaInicial -1 UNITS DAY ;
    LET  v_mCargo = 0;
	
    --IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmpsd_movhiscredito') THEN
         --DROP TABLE tmpsd_movhiscredito;
    --END IF;

    --CREATE TABLE tmpsd_movhiscredito (fecha_mov DATE, naturaleza CHAR(1), monto MONEY);
	
	DELETE FROM bdicred:tmpsd_movhiscredito WHERE usuario = pUsuario;
		
		INSERT INTO tmpsd_movhiscredito (fecha_mov, monto, naturaleza, num_credito, usuario)
		SELECT a.fecha_mov, a.monto, b.naturaleza, a.num_credito, pUsuario
	    FROM sd_movhis a , sd_afectavencidosimulador b
	    WHERE a.empresa = pEmpresa
	    AND a.num_credito = pNumCredito
	    AND a.codigo_fun IN (SELECT b.codigo_fun FROM sd_afectavencidosimulador)
	    AND a.codigo_ref IN (SELECT b.codigo_ref FROM sd_afectavencidosimulador)
	    AND a.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
	    AND a.reversado <> 'S';

    FOREACH

        SELECT  num_credito
        INTO  v_cNumCredito
        FROM  bdicred@pld_tcp:sd_detalle_edocta
        WHERE num_credito = pNumCredito
        AND fecha_emision  =  pFechaFinal

        WHILE v_dFecha <= pFechaFinal

            IF  v_dFecha = pFechaInicial -1 UNITS DAY  THEN   --Para obtener el capital vencido del mes inmediato anterior

                --IF EXISTS (SELECT  capital_ven_tc  FROM sd_encabezado2_edocta WHERE num_credito = pNumCredito AND fecha_emision  =  pFechaInicial - 1 UNITS DAY) THEN
                    SELECT  NVL(capital_ven_tc,0)
                    INTO  v_mCapitalVencido
                    FROM  bdicred@pld_tcp:sd_encabezado2_edocta
                    WHERE num_credito = pNumCredito
                    AND fecha_emision  =  pFechaInicial - 1 UNITS DAY;

                    IF v_mCapitalVencido = "" OR v_mCapitalVencido IS NULL THEN
                        LET v_mCapitalVencido = 0.00;
                    END IF
                --ELSE
                --    LET vcodret = '002';   --No existe estado de cuenta para esa fecha
                --    RETURN vcodret, v_dFecha, v_mCapitalVencido;
                --END IF;

            ELSE      --Para obtener el capital vencido de los dias del periodo

                SELECT NVL(SUM(abono), 0), NVL(SUM(cargo),0)
                INTO v_mAbono, v_mCargo
                FROM TABLE(MULTISET(
                    SELECT
                    CASE WHEN naturaleza = 'C' THEN monto END AS cargo,
                    CASE WHEN naturaleza = 'A' THEN monto END AS abono
                    FROM bdicred:tmpsd_movhiscredito
                    WHERE fecha_mov = v_dFecha
		    AND usuario= pUsuario));

            END IF;

            LET v_mCapitalVencido = v_mCapitalVencido - v_mAbono  + v_mCargo ;
            RETURN vcodret, v_dFecha, v_mCapitalVencido

            WITH RESUME;

            LET v_dFecha =  v_dFecha + 1 UNITS DAY;

        END WHILE;
    END FOREACH;

    --IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmpsd_movhiscredito') THEN
        --DROP TABLE tmpsd_movhiscredito;
    --END IF;

END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez.',
'DESCRIPCION: Se encarga de obtener el capital vencido en un periodo determinado para un número de crédito',
'EJECUTADO O LLAMADO POR:',
'simtdc.exe',
'FECHA : Septiembre de 2009',
'VERSION: 20090910',
'BD    : bdicred',
'FECHA MODIFICACIÓN: 25/03/2010',
'MODIFICACIÓN: Se modifica, para cuando el cliente no tenga registro en el mes inmediato anterior, el',
'              capital vencido tome valor de 0.00, y continue el proceso. Ya que anteriormente terminaba ',
'AUTOR MODIFICACIÓN: Cristian Valentina Aguilar',
'FECHA MODIFICACION: 12/04/2010',
'MODIFICACION: Se le comenta la variable inicializada  v_dFecha devido a que marcaba un error',
'AUTOR MODIFICACION: Jose Angel Rodriguez Rodriguez',
'FECHA MODIFICACION: 20/04/2010',
'MODIFICACION: Se le agrego parametro al sp y se comenta la variable donde preguntaba si existia la tabla temporal y se le quita donde crea esta misma,',
'              tambien se le agrega un delete para borrar los registros del cliente que esten en dada sucursal y se borran por medio',
'              de la consulta donde se le agrega el usuario de la sucurusal',
'AUTOR MODIFICACION: Jose Angel Rodriguez Rodriguez';

CREATE PROCEDURE "informix".sp_parametroscredito_pba (pEmpresa CHAR(3), pNumEmpleado CHAR(8))

RETURNING
        CHAR( 5) AS RETORNO,            -- CODIGO DE RETORNO
        CHAR( 2) AS LONGITUDCLIENTE,    -- LONGITUD DEL CLIENTE
        CHAR( 2) AS CODMONNAC,          -- CODIGO DE LA MONEDA NACIONAL
       CHAR(100) AS CODPATHREP,         -- VALOR PATH DEL REPORTE
        CHAR(45) AS NOMUSUARIO,         -- NOMBRE DEL USUARIO
        CHAR(30) AS NOMEMPRESA,         -- NOMBRE DE LA EMPRESA   
            DATE AS FECHAHOY,           -- FECHA HOY
        CHAR( 2) AS SISTEMA,            -- CODIGO DEL SISTEMA
        CHAR(11) AS LONGITUDCTA,        -- LONGITUD DE LA CUENTA
            DATE AS FECHAANT,           -- FECHA ANTERIOR
            DATE AS PROXFECHA,          -- FECHA PROXIMA
            DATE AS PRIDIAMES,          -- PRIMER DIA DEL MES
            DATE AS PRIMHABMES,         -- PRIMER DIA HABIL MES
            DATE AS ULTDIAMES,          -- ULTIMO DIA DEL MES
            DATE AS ULTHABMES;          -- ULTIMO DIA HABIL DEL MES
    
  --DECLARACION DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE cLongitudCliente     CHAR(2);
    DEFINE cCodMonNac           CHAR(2);
    DEFINE cPathRep             CHAR(100);
    DEFINE cNombreUsuario       CHAR(45);
    DEFINE cNombreEmpresa       CHAR(30);
    DEFINE dFecha_Hoy           DATE;
    DEFINE cSistema             CHAR(2);
    DEFINE cLongCta             CHAR(11);
    DEFINE dFecha_ant           DATE;
    DEFINE dProx_fecha          DATE;
    DEFINE dPri_dia_mes         DATE;
    DEFINE dPri_hab_mes         DATE;
    DEFINE dUlt_dia_mes         DATE;
    DEFINE dUlt_hab_mes         DATE;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
  --INICIALIZAR VARIABLES
    LET cCodRet 		  	= '00000';
    LET cLongitudCliente	= '';
    LET cCodMonNac			= '';
    LET cPathRep			= '';
    LET cNombreUsuario		= '';
    LET cNombreEmpresa 		= '';
    LET dFecha_Hoy 			= DATE(1);
    LET cSistema 			= '';
    LET cLongCta			= '';
    LET dFecha_ant			= DATE(1);
    LET dProx_fecha 		= DATE(1);
    LET dPri_dia_mes		= DATE(1);
    LET dPri_hab_mes		= DATE(1);
    LET dUlt_dia_mes		= DATE(1);
    LET dUlt_hab_mes		= DATE(1);
    
    --SET DEBUG FILE TO "/home/sysifx/vlv/sp_parametroscredito.out";
	--TRACE ON;
    
BEGIN
	  --CREA EL CONTROL DE ERRORES
        ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN TRIM(cCodRet), TRIM(NVL(cLongitudCliente, '')), TRIM(NVL(cCodMonNac, '')), TRIM(NVL(cPathRep, '')), 
					   TRIM(NVL(cNombreUsuario, '')), TRIM(NVL(cNombreEmpresa, '')), NVL(dFecha_Hoy, DATE(1)), 
					   TRIM(NVL(cSistema, '')), cLongCta, NVL(dFecha_ant, DATE(1)), NVL(dProx_fecha, DATE(1)), 
					   NVL(dPri_dia_mes, DATE(1)), NVL(dPri_hab_mes, DATE(1)), NVL(dUlt_dia_mes, DATE(1)), NVL(dUlt_hab_mes, DATE(1));
			END IF;
		END EXCEPTION;        
	
	IF pEmpresa = '' AND pNumEmpleado = '' THEN
		LET cCodRet = '00001'; -- FALTAN PARAMETROS PARA SU EJECUCION.
		RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
			   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, 
			   dUlt_hab_mes;
	END IF
	
    -- OBTENGO EL VALOR LONGITUD DEL NUMERO DE CLIENTE		
	SELECT TRIM(valor)
	INTO cLongitudCliente 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 
	
	IF cLongitudCliente IS NULL THEN
		LET cLongitudCliente = '';
	END IF
	
    -- OBTENGO EL VALOR CODIGO DE LA MONEDA NACIONAL
	SELECT TRIM(valor)
	INTO cCodMonNac 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('codigo mn');
	
	IF cCodMonNac IS NULL THEN
	   LET cCodMonNac = '';
	END IF
	
    -- OBTENGO EL VALOR PATH DE REPORTES
	SELECT NVL(TRIM(valor), '')
    INTO cPathRep
	FROM bdicred:"informix".sd_param 
	WHERE empresa = pEmpresa AND cod_param = '50';
	
	IF cPathRep IS NULL THEN
  	   LET cPathRep = '';
	END IF
	
	-- OBTENGO EL NOMBRE DEL USUARIO O EJECUTIVO
	SELECT NVL(nombre, '')
	INTO cNombreUsuario
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	
	IF cNombreUsuario IS NULL THEN
	   LET cNombreUsuario = '';
	END IF
	
    -- OBTENGO EL NOMBRE DE LA EMPRESA
	SELECT NVL(razon_social, '')
	INTO cNombreEmpresa
	FROM bdinteg:"informix".si_empresas 
	WHERE empresa = pEmpresa;
	
	IF cNombreEmpresa IS NULL THEN
		LET cNombreEmpresa = '';
	END IF
    
	-- OBTIENE EL VALOR DE LA LONGITUD DE LA CUENTA.
	SELECT TRIM(NVL(valor, ''))
	INTO cLongCta
	FROM bdicred:"informix".sd_param 
	WHERE cod_param = '8';
	
	IF cLongCta IS NULL THEN
		LET cLongCta = '';
	END IF
	
    -- OBTENGO FECHA DE CREDITO PARA LA CAPTURA DE PARAMETROS
	SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes  
	INTO dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes
	FROM bdicred:"informix".sd_fechas;
	
	IF dFecha_Hoy IS NULL THEN
		LET dFecha_Hoy   = DATE(1);
		LET dFecha_ant   = DATE(1);
		LET dProx_fecha  = DATE(1);
		LET dPri_dia_mes = DATE(1);
		LET dPri_hab_mes = DATE(1);
		LET dUlt_dia_mes = DATE(1);
		LET dUlt_hab_mes = DATE(1);
	END IF
	
    -- OBTENGO CODIGO DEL SISTEMA
	SELECT TRIM(NVL(sistema, ''))
	INTO cSistema
	FROM bdinteg:"informix".si_sistema 
	WHERE siglas = 'SD';
	
	IF cSistema IS NULL THEN
		LET cSistema = '';
	END IF
	
	RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
		   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes,
		   dUlt_hab_mes;	
END
END PROCEDURE
DOCUMENT
'CREACION     : VALENTIN LÓPEZ VALENZUELA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL FUNCIONAMIENTO DEL MODULO DE CREDITO CON REGLAS DE PROGRAMACION',
'FECHA    	  : NOVIEMBRE 2010',
'BASE DE DATOS: BDICRED',
'VERSION  	  : 20111130.1529';

CREATE PROCEDURE "informix".sp_carga_ctes_dirty_behavior(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;


DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaAumLinCrd  DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);


--SET DEBUG FILE TO "sp_carga_ctes_dirty_behavior.out";
--TRACE ON;

LET vproceso        = '0502';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaAumLinCrd FROM bdicred:"informix".sd_fechas_aumlincred  WHERE empresa = pEmpresa;
    IF dFechaAumLinCrd IS NULL OR dFechaAumLinCrd = date(1) OR dFechaAumLinCrd = date(0) THEN
        LET dFechaAumLinCrd = dFechaHoy;
    END IF

    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = 102;
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET cNomArchivo = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchEjecSql = 'Carga_Ctes_Dirty_Incr_lcr.sql';
    
    -- Realiza carga de archivo.
    LET cSQL = '';
    LET cSQL = ' echo " CREATE TEMP TABLE cred_tmp_behavior (num_credito CHAR(20), score CHAR(4)); '
            || ' LOAD FROM ' || TRIM(cRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO cred_tmp_behavior; '
            || ' INSERT INTO bdicred:sd_clientes_dirty_behavior ( fecha_reporte, num_credito,  score ) '
            || ' SELECT ''' || dFechaAumLinCrd || ''', num_credito, score FROM cred_tmp_behavior;  ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;