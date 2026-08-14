CREATE PROCEDURE "informix".sp_obtiene_aproximacion( pMonto 	     DECIMAL(18,6), 	-- MONTO DEL PRESTAMO
                                          pPlazo 	     DECIMAL(18,6),	-- PLAZO 
                                          pMensualidad	 DECIMAL(18,6), -- MENSUALIDAD
                                          pTasaAnual	 DECIMAL(18,6),	-- TASA ANUAL
                                          pTasaAnualIva	 DECIMAL(18,6),	-- TASA ANUAL CON IVA
                                          pFechaApert	 DATE,          -- FECHA DE APERTURA
                                          pIvaSuc	     DECIMAL(18,6),	-- IVA QUE SE MANEJA EN LA SUCURSAL
                                          pIntervalo	 DECIMAL(18,6),	-- CANTIDAD PARA DELIMITAR EL LIMITE SUPERIOR Y EL LIMITE INFERIOR
                                          pDiferencia	 DECIMAL(18,6),	-- CANTIDAD MAXIMA PARA DIFERENCIA DE ULTIMA MENSUALIDAD
										  pTpoPago       INTEGER,        --VALIDA EL TIPO DE PRODUCTO, SI ES PRESTAMO O CREDINOMINA.   
										  pNumCred		 CHAR(20)   -- NUMERO DE CREDITO
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
--              cambiÃÂ³ la forma de obtener la fecha de couta y los dias por periodo, tambiÃÂ¨n se agrego
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
-- ModificÃÂ³: Viridiana Osobampo Aguilar
-- DescripciÃÂ³n: Se eliminan validaciones de rango de valores permitidos para monto y plazo, de modo
--              que se realice la aproximaciÃÂ³n con los datos de parÃÂ¡metros que reciba el spl.
-- Fecha: 2009/12/01
-- VersiÃÂ³n: 20091201.1206

------------------------------------------------------------------------------------------------------------
-- ModificÃÂ³: Viridiana Osobampo Aguilar
-- DescripciÃÂ³n: Se modifica para cuando una mensualidad no alcance a cubrir parte de capital, se 
--              realice una nueva aproximaciÃÂ³n buscando un nuevo monto para el pago mensual.
-- Fecha: 2009/12/10
-- VersiÃÂ³n: 20091210.0935
-------------------------------------------------------------------------------------------------------------			
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica las variables para calculos de tasas money(14,2) a decimal(9,6).
--             Se modifica el calculo de fechas para dias inhabiles.  
--Fecha: 2010/01/27
--Version: 20090127.0845
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Para el cÃÂ¡lculo de la mensualidad, retornar el ÃÂºltimo valor correcto calculado.
--Fecha: 2010/02/04
--Version: 20100204.1600
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para que el la mensualidad de la cuota no sobrepase al monto indicado
--	 	 en el parÃÂ¡metro de entrada en la ejecuciÃÂ³n del spl
--Fecha: 2010/02/05
--Version: 20100205.1342
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Hector Manuel Bojorquez Ruelas, JesÃÂºs Manuel Aguilar Heredia
--Descripcion: Se modifica para que se pueda utilizar en el producto Credinomina, para lo cual se le agrego un parametro de entrada mas para identificar la forma de pago del prestamo.
--Fecha: 2011/05/04
--Version: 20110504.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: JesÃÂºs Manuel Aguilar Heredia
--Descripcion: Se modifica para que  se contemple el dia de pago en la proyeccion, y no se manejen dias 15 y 30, para lo cual se le agrego un parametro para el numero de credito.
--que se usara para determinar las fechas de cuota del credito.
--Fecha: 2011/08/10
--Version: 20110810.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: JesÃÂºs Manuel Aguilar Heredia
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

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- VALIDAMOS QUE LOS DATOS DE ENTRADA SON CORRECTOS
    IF pTasaAnual < 0  OR pTasaAnualIva < 0 OR NVL(pFechaApert,"") = "" THEN
		LET cCodRet = "000010";
		RETURN cCodRet, mImporte;
	END IF;

   IF NVL(pMonto,0) > 0 AND NVL(pMensualidad,0) > 0 THEN
       LET pPlazo = 0;
   END IF;
	
	LET sDiaIni = DAY(dFechaAnt);

	LET mTasaMensIva = pTasaAnualIva / 12;

	IF pTpoPago = 1 OR pTpoPago = 0 THEN  ---Pago mensual
        	IF mTasaMensIva=0 THEN 
            		LET mMensualidad = ROUND((pMonto/sPlazo),0); --(ROUND((pMonto * 30.5 ) / (30 * (1 - POW((1),-sPlazo))), 0));
        	ELSE
		LET mMensualidad = ROUND((pMonto * 30.5 * mTasaMensIva) / (30 * (1 - POW((1 + mTasaMensIva),-sPlazo))), 0);
        	END IF
	ELIF pTpoPago = 2 THEN    ---Pago Quincenal
        	IF mTasaMensIva=0 THEN 
            		LET mMensualidad = ROUND((pMonto/sPlazo),0); --(ROUND((pMonto * 15.25 )  / (15 * (1 - POW((1),-sPlazo))), 0));
        	ELSE
		LET mMensualidad = (ROUND((pMonto * 15.25 * (mTasaMensIva / 2) )  / (15 * (1 - POW((1 + (mTasaMensIva / 2) ),-sPlazo))), 0));
        	END IF
	END IF;	
	
	-- SE OBTIENE EL LIMITE INFERIOR
	LET mLimiteInf = ROUND(mMensualidad * (1 - pIntervalo), 0);
	
	-- SE OBTIENE EL LIMITE SUPERIOR
	
	LET mLimiteSup = ROUND(mMensualidad * (1 + pIntervalo), 0);	
		
    IF ( (pMonto/sPlazo - mMensualidad = 0) and (mTasaMensIva=0) ) THEN
        RETURN cCodRet, mMensualidad;
    END IF;
		
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
            -- valida vs capacidad inicial
                select nvl(capacidad_pres,0), nvl(case when pTpoPago = 1 then plazo_max_cred::integer when pTpoPago = 2 then plazo_max_cred::integer * 2 else 0 end,0)
                into vcapaini, vplazmax
                from bdisolic:ss_solicitudes a,
                     bdicred:sd_definicion b
                where a.empresa = '001' 
                and a.empresa = b.empresa
                and a.num_producto = b.num_producto
                and num_solicitud = pNumCred;

               
               --                if ( mMensualidad > vcapaini and pPlazo = vplazmax) then 	
				if ( mMensualidad > vcapaini and pPlazo = vplazmax) and vcapaini > 0 then 		--IPCB 6400		29/05/2017
					let mMensualidad = vcapaini; 
				end if;

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
						EXECUTE PROCEDURE "informix".sp_obtienefechapago('001',dFechaCouta,pNumCred)
							INTO cCodRet,dFechaCouta,iDiaPago;	
						IF cCodRet::INTEGER <> 0  THEN	
							LET cCodRet    = "000008";	--Ocurrio un Error al obtener la fecha de pago del crÃÂ©dito para credinomina.
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
				LET mInteres = ROUND(((pMensualidad - mCapital) / (1 + pIvaSuc)),2);
				
				-- SE OBTIENE EL IVA DEL INTERES
				LET mIva = ROUND((mInteres * pIvaSuc),2);  --JMAH
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
								-- Valida si la en vuelta anterior se salda el prÃÂ©stamo  --con la mensualidad calculada y guarda el valor.  								                                              
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

/*  if (pPlazo > 0 AND pMonto > 0 ) then

     EXECUTE PROCEDURE "informix".sp_obtiene_aproximacion(0, pPlazo,mImporte, pTasaAnual,pTasaAnualIva,
                                                                 pFechaApert,pIvaSuc,pIntervalo,pDiferencia,pTpoPago)
        INTO cCodRet,mMomtoAuxc;

        if (cCodRet <> "000000") then
              RETURN cCodRet, mMomtoAuxc;
        end if;

        if ( pMonto < mMomtoAuxc ) then
            let condicion = 1;

            while condicion = 1

               let mImporte = mImporte - 1;

                EXECUTE PROCEDURE "informix".sp_obtiene_aproximacion(0, pPlazo,mImporte, pTasaAnual,pTasaAnualIva,
                                                          pFechaApert,pIvaSuc,pIntervalo,pDiferencia,pTpoPago)
                INTO cCodRet,mMomtoAuxc;

                if (cCodRet <> "000000") then
					  RETURN cCodRet, mMomtoAuxc;
                end if;

                if ( pMonto >= mMomtoAuxc ) then
                    let condicion = 0;
                    if ( pMonto <> mMomtoAuxc ) then 
                       let mImporte = mImporte + 1;
                    end if;
                else
                   let mImporte = mImporte - 1;
                   if (mImporte <= 0) then
                       let condicion = 0;
                       LET cCodRet = '000012';
                   end if;
                end if;
            end while;
        end if;
    end if;*/

	RETURN cCodRet, mImporte;
END;
END PROCEDURE

