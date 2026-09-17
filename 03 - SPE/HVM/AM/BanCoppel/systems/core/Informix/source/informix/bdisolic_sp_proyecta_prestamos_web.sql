CREATE PROCEDURE "informix".sp_proyecta_prestamos_web(	pMonto_Autorizado  	DECIMAL(18,6),  -- MONTO DEL CREDITO
														pPlazo 			 	INTEGER, 	     	--PLAZO EN MESES PARA PAGAR
														pCapacidad_Pres	 	DECIMAL(18,6),  	-- CAPACIDAD DE PAGO DEL CLIENTE
														pProducto 		 	CHAR(4), 	     	-- CODIGO DE PRODUCTO
														pSucursal 		 	CHAR(4),	     	-- CODIGO DE SUCURSAL
														pTipoRetorno 	 	SMALLINT,	     	-- DETERMINA COMO SE VAN A RETORNAR LOS DATOS:
                                                                                                --	0  RESUMEN
                                                                                                --	1  DETALLE
                                                                                                --	2  REIMPRESION DE CARATULA
                                                                                                --	3  CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                                                                --	4  RESUMEN CON DIFERENTE FECHA DE INICIO DE PROYECCION
														pSolicitudes 	 	SMALLINT,	     	-- PARA PAGINACION
														pNumCred			CHAR(20),	    -- NUMERO DE CREDITO
														pFecha			 	DATE,		     	-- FECHA PARA INICIAR LA PROYECCION
														pFrecuencia       	INTEGER         	--Frecuencia de pago
																								-- 0.- Mensual(prestamo)
																								-- 1.- Mensual credinomina
																								-- 2.- Quincenal credinomina
                                                   )

RETURNING   CHAR(5)         AS Codigo, 		  -- CODIGO DE RETORNO
            INTEGER         AS Periodo,       -- PERIODO ACTUAL
            DATE            AS FechaCouta,	  -- FECHA DEL PAGO
            DECIMAL(18,2)   AS SaldoInicial,  -- SALDO INICIAL
            DECIMAL(18,2)   AS Mensualidad,	  -- MENSUALIDAD
            DECIMAL(18,2)   AS Intereses,	  -- INTERESES
            DECIMAL(18,2)   AS IvaInteres,	  -- IVA DE INTERESES
            DECIMAL(18,2)   AS Capital,		  -- CAPITAL
            DECIMAL(18,2)   AS SaldoFinal,	  -- SALDO FINAL
            SMALLINT        AS DiasPeriodo,	  -- DIAS DEL PERIODO
            DATE            AS FechaAper,	  -- FECHA DE APERTURA
			CHAR(3)         AS NumMesesPago;  -- FECHA DE APERTURA

--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agregaron como parametros de entrada el producto y la sucursal,
--             el iva se toma de la sucursal, la fecha se toma de la tabla
--	       bdicred:sd_fechas, la tasa anual se toma de la tabla bdicred:sd_definicion,
--             se agrego validacion para detectar cuando el parametro
--	      de entrada pPlazo venga vacio se le asigne por default el valor 36.
--Fecha: 2009/09/15
--Version: 20090909.1800
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agregaron las formulas para obtener los valores de Plazo,
--              Monto otorgado y mensualidades.
--Fecha: 2009/09/18
--Version: 20090918.1303
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se hicieron adecuaciones a las formulas para que los resultados
--             fueran mas exactos.
--Fecha: 2009/09/21
--Version: 20090921.1508
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego parametro para definir el numero de registros que se van
--             a retornar, si se manda 1 regresa n registros y si se manda 0
--	       regresa solo un registro.
--Fecha: 2009/09/22
--Version: 20090922.0956
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego parametro de entrada para paginar los resultados.
--Fecha: 2009/09/29
--Version: 20090929.1209
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se referencia el procedimiento monthadd a la base de datos bdicred.
--Fecha: 2009/10/06
--Version: 20091006.1840
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego validacion para evitar que se de una mensualidad menor a
--              los intereses que se generan de forma mensual.
--              Se agregaron validaciones para ver si el monto y el plazo se encuentren
--              dentro de los rangos permitidos
--	        Se agrego validacion para que solo se manden 2 de 3 de los parametros
--              de plazo, mensualidad y monto otorgado
--	        Se agrego ajuste del monto de la mensualidad para el ultimo pago
--              en caso de que no sea exacta para que quede en 0 el prestamo
--Fecha: 2009/10/08'
--Version: 20091008.1238
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se cambio la forma de obtener la fecha de couta y los dias por periodo
--Fecha: 2009/10/21
--Version: 20091021.1800
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego nuevo parametro de entrada que se tomaria como la fecha
--             de inicio de la proyeccion en dado caso que el parametro
--             que define el tipo de retorno sea igual a 3
--Fecha: 2009/10/27
--Version: 20091027.1326
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se cambio que al obtener el iva del maestro de crÃÂ©dito no se dividiera entre 100
--             ya que se definio que te almacenaria ya con el calculo correspondiente
--             Se valida si el pTipoRetorno es diferente de 0 realice la comparaciÃÂ³n de rangos
--             de montos maximos y minimos permitidos en caso contrario no se realice la comparaciÃÂ³n
--             ya se que se realizarÃÂ¡ desde la calificaciÃÂ³n del crÃÂ©dito (califica_scoring2).
--Fecha: 2009/11/01
--Version: 20091101.1013
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para que se contemplen diferentes escenarios de comparaciÃÂ³n de parÃÂ¡metros
--             para el pTipoRetorno 2 (Reimpresion de la proyecciÃÂ³n)
--Fecha: 2009/11/10
--Version: 20091110.1309
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para validar que los parÃÂ¡metros de plazo y monto autorizado recibido
--              se encuentra dentro de rango permitido y que para el escenario donde se reciba el
--              monto y la mensualidad, se ejecute el sp_obtiene_aproximaciÃÂ³n enviadole en el parÃÂ¡metro de
--              plazo el plazo mÃÂ¡ximo establecido para el producto de crÃÂ©dito a proyectar, con la finalidad
--              de que esta validaciÃÂ³n se elimine dentro del sp que realiza la proyecciÃÂ³n con valor fijo.
--Fecha: 2009/12/01
--VersiÃÂ³n: 20091201.1148
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para paginar los registros correctamente.
--Fecha: 2009/12/01
--Version: 20091201.1153
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifca para que al validar el retorno del sp_obtiene_aproximaciÃÂ³n,
--              se asgine un valor controlado o en su defecto retornar el cÃÂ³digo
--              que se reciba  del sp de aproximaciÃÂ³n.
--Fecha: 2009/12/10
--VersiÃÂ³n: 20091210.1107
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica las variables para calculos de tasas money(14,2) a decimal(9,6).
--Fecha: 2010/01/27
--Version: 20100127.0830
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para que el la mensualidad de la cuota no sobrepase al monto indicado
--	 	 en el parÃÂ¡metro de entrada en la ejecuciÃÂ³n del spl
--Fecha: 2010/02/05
--Version: 20100205.1358
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para cambiar los mensajes:
--             * Se modifica el retorno "000015" que mostraria el mensaje
--             "El cÃÂ¡lculo del monto no se puede realizar con los parÃÂ¡metros actuales" por el
--             retorno "000004" para que muestre el mensaje "El monto autorizado esta fuera del rango permitido".
--             * Se modifica el retorno "000014" por el retorno "000005" era el mismo mensaje solo se reemplazo
--             para eliminar el mensaje similar.
--Fecha: 2010/02/09
--Version: 20100209.0912
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Hector Manuel Bojorquez Ruelas,JesÃÂºs Manuel Aguilar Heredia
--Descripcion: Se modifica para que se pueda utilizar en el producto Credinomina, para lo cual se le agrego un parametro de entrada mas para identificar la forma de pago del prestamo.
--Fecha: 2011/05/04
--Version: 20110405.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: JesÃÂºs Manuel Aguilar Heredia
--Descripcion: Se modifica para que  se contemple el dia de pago en la proyeccion, y no se manejen dias 15 y 30.
--Fecha: 2011/08/10
--Version: 20110810.1010
---------------------------------------------------------------------------------------------------------------
-- VARIABLES DE CONTROL DE ERRORES
DEFINE isqlerr      	INTEGER;			-- CODIGO DE ERROR
-- VARIABLES PARA RETORNO DE DATOS
DEFINE cCodRet     		CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
DEFINE cCodRet2			CHAR(6);			-- CODIGO DE RETORNO DE ERROR 2
DEFINE cCodRetTDif		CHAR(6);		    -- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE mPeriodo			INTEGER;			-- PERIODO DE PAGO
DEFINE dFechaCouta		DATE;				-- FECHA
DEFINE mSdoInicial		DECIMAL(18,6);		-- SALDO INICIAL
DEFINE mMensualidad		DECIMAL(18,6);		-- MENSUALIDAD
DEFINE mIntereses		DECIMAL(18,6);		-- INTERESES
DEFINE mIvaInt			DECIMAL(18,6);		-- IVA DE INTERESES
DEFINE mCapital			DECIMAL(18,6);		-- CAPITAL
DEFINE mSdoFinal		DECIMAL(18,6);		-- SALDO FINAL
DEFINE sDiasPeriodo		SMALLINT;			-- DIAS DEL PERIODO
DEFINE mMontoMin		DECIMAL(18,6);		-- MONTO MINIMO
DEFINE mMontoMax		DECIMAL(18,6);		-- MONTO MAXIMO
DEFINE sPlazoMin		SMALLINT;			-- PLAZO MINIMO
DEFINE sPlazoMax		SMALLINT;			-- PLAZO MAXIMO
DEFINE dFechaAper		DATE;				-- FECHA DE APERTURA

-- VARIABLES AUXILIARES
DEFINE Contador 		INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
DEFINE mTasaInt 		DECIMAL(18,6);		-- TASA DE INTERES
DEFINE mIVA				DECIMAL(18,6);    	-- IVA
DEFINE mTasa			DECIMAL(18,6);		-- TASA ANUAL ORDINARIA
DEFINE mTasa_Mora		DECIMAL(18,6);		-- TASA ANUAL MORATORIA
DEFINE dFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
DEFINE sPlazo			SMALLINT;			-- PLAZO
DEFINE mTasaMensual		DECIMAL(18,6);      -- TASA MENSUAL
DEFINE mTasaIVA			DECIMAL(18,6);		-- TASA ANUAL CON IVA
DEFINE mTasaMensualIVA	DECIMAL(18,6);		-- TASA MENSUAL CON IVA
DEFINE dFechaInicial	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dtDiaprimero 	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dFechaAnt		DATE;				-- FECHA ANTERIOR DE COUTA
DEFINE dFechaFinMes		DATE;				-- FECHA ANTERIOR DE COUTA

-- VARIABLES PARA CAPTURAR LOS VALORES DE PLAZO, PAGO MENSUAL Y MONTO APROBADO
DEFINE mMontoAut 		DECIMAL(18,6); 		-- MONTO DEL CREDITO
DEFINE mPlazo  	 		DECIMAL(18,6);		-- PLAZO EN MESES PARA PAGAR
DEFINE mCapacidadPres	DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE

DEFINE cEmpresa         CHAR(3);
DEFINE dLimites         DECIMAL(18,6);
DEFINE dDiferencia      DECIMAL(18,6);
DEFINE mMensualidadAux  DECIMAL(18,6);
DEFINE mMontoAutAux		DECIMAL(18,6);

DEFINE iTpoPago         INTEGER;
DEFINE cTipo            CHAR(15);
DEFINE iDiaPago      	INTEGER;
DEFINE mPlazoAux      	DECIMAL(18,6);
DEFINE sContinua      	INTEGER;
DEFINE inumppf			INTEGER;
DEFINE vNumCte			CHAR(9);

LET iSqlErr 		= 0;
LET cCodRet 		= "00000";
LET cCodRet2 		= "000000";
LET cCodRetTDif		= '';
LET dFechaCouta		= DATE(1);
LET mPeriodo		= 0;
LET mSdoInicial		= 0;
LET mMensualidad	= 0;
LET mIntereses		= 0;
LET mIvaInt			= 0;
LET mCapital		= 0;
LET mSdoFinal		= 0;
LET sDiasPeriodo	= 0;
LET dFechaAper		= DATE(1);

LET Contador 		= 0;
LET mTasaInt    	= 0;
LET mIVA			= 0;
LET mTasa			= 0;
LET mTasa_Mora		= 0;
LET dFechaActual	= DATE(1);
LET mTasaMensual	= 0;
LET mTasaIVA 		= 0;
LET dFechaInicial	= DATE(1);
LET dtDiaprimero   = DATE(1);
LET dFechaAnt		= DATE(1);
LET dFechaFinMes	= DATE(1);

LET mMontoAut 		= pMonto_Autorizado;
LET mPlazo  	 	= pPlazo;
LET mCapacidadPres	= pCapacidad_Pres;
LET mMontoMin		= 0;
LET mMontoMax		= 0;
LET sPlazoMin    	= 0;
LET sPlazoMax		= 0;

LET cEmpresa        = '001';
LET dLimites        = 0.05;
LET dDiferencia     = 0.20;
LET mMensualidadAux = 0;
LET mMontoAutAux		= 0;

LET iTpoPago        = 0;
LET cTipo           = '';
LET iDiaPago        = 0;
LET mPlazoAux       = 0;
LET sContinua       = 0;
LET inumppf			= 0;
LET vNumCte			= '';


BEGIN

	ON EXCEPTION  SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET  cCodRet  = iSqlErr;
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END  EXCEPTION

--SET DEBUG FILE TO "/tmp/sp_Proyecta_Prestamo_web.out";
--TRACE ON;
	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_Proyecta_Prestamo.out";
	--TRACE ON;
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- ***********************************************************************
	-- 000001 	VALORES DE ENTRADA INCORRECTOS
	-- 000002	SOLO SE PERMITE RECIBIR 2 DE LOS 3 PARAMETROS SIGUIENTES pMonto_Autorizado, pPlazo, pCapacidad_Pres
	-- 000003	LA CANTIDAD DEL PAGO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES
	-- 000004	EL MONTO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 000005	EL PLAZO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 000006	EL NUMERO DE CREDITO NO EXISTE
	-- 000007	FALTA LA NUEVA FECHA DE INICIO DE LA PROYECCION
	-- 000008	EL PARAMETRO DE FECHA NO ES NECESARIO
	-- 000009	EL CALCULO DEL MONTO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000010	EL CALCULO DE LA CAPACIDAD NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000011	EL CALCULO DE EL PLAZO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000012   NO ES POSIBLE REALIZAR UNA PROYECCION CON LAS CONDICIONES INDICADAS. (Este cÃÂ³digo de retorno llega desde el sp_obtiene_aproximacion)
	-- 000013   LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO OBTENIDOS SON INCORRECTOS
	-- 000014   EL PARAMETRO DE FRCUENCIA DE PAGO RECIBIDO NO ES VALIDO
	-- 000015 Ocurrio un Error al obtener la fecha de pago del crÃÂ©dito para credinomina.
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- *********************************** ************************************

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		--Se valida si la frecuencia recibida es correcta

    if (pFrecuencia is null or pFrecuencia = 0) then
	  SELECT nvl(frecuencia_pgo,0) INTO pFrecuencia
	  FROM "informix".ss_sol_nomina
	  WHERE num_solicitud = pNumCred;
    end if;

	SELECT tipo_pago
	INTO cTipo
	FROM  bdicred:sd_cattipopago
	WHERE valor = pFrecuencia;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00014';
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	END IF;
	-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO

	SELECT monto_min_cred, monto_max_cred, plazo_min_cred, plazo_max_cred
	  INTO mMontoMin, mMontoMax, sPlazoMin, sPlazoMax
	  FROM bdicred:"informix".sd_definicion
     WHERE num_producto = pProducto
       AND empresa      = cEmpresa;

       IF NVL(mMontoMin,0) = 0 OR NVL(mMontoMax,0) = 0 OR NVL(sPlazoMin,0)= 0 OR NVL(sPlazoMax,0) = 0 THEN
           LET cCodRet = '00013';
           RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
       END IF;

	-- SE VERIFICA QUE LOS VALORES DE ENTRADA SEAN CORRECTOS
    IF pTipoRetorno <> '2' THEN
        IF (NVL(mPlazo,0) = 0 AND NVL(mCapacidadPres,0) = 0 AND NVL(mMontoAut,0) = 0) OR NVL(pProducto,"") = "" OR NVL(pSucursal,"") = "" THEN
            LET  cCodRet  = "00001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mPlazo,0) = 0 AND NVL(mCapacidadPres,0) = 0 THEN
            LET  cCodRet  = "00001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mPlazo,0) = 0 AND NVL(mMontoAut,0) = 0 THEN
            LET  cCodRet  = "00001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mCapacidadPres,0) = 0 AND NVL(mMontoAut,0) = 0 THEN
            LET  cCodRet  = "00001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF (NVL(mPlazo,0) > 0 AND NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) > 0) THEN
            LET  cCodRet  = "00002";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF (NVL(mPlazo,0) > 0 AND NVL(mPlazo,0) < CASE WHEN pFrecuencia = 2 THEN sPlazoMin * 2 ELSE sPlazoMin END) OR (NVL(mPlazo,0) > CASE WHEN pFrecuencia = 2 THEN sPlazoMax * 2 ELSE sPlazoMax END) THEN
            LET cCodRet = "00005";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mMontoAut,0) >0 AND (NVL(mMontoAut,0) < mMontoMin OR NVL(mMontoAut,0) > mMontoMax) THEN
            LET cCodRet = "00004";
              --FMV 26-SEP-13: Monto minimo = Autorizado para continuar con la proyeccion
                    LET mMontoMin = mMontoAut;
                    LET cCodRet = "00000";

            --RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    ELSE
        IF (NVL(mPlazo,0) <> 0 AND NVL(mCapacidadPres,0) <> 0 AND NVL(mMontoAut,0) <> 0)  THEN
             LET  cCodRet  = "00001";
             RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    END IF;

	IF (pTipoRetorno = 0 AND NVL(pFecha,"") <> "") OR (pTipoRetorno = 1 AND NVL(pFecha,"") <> "") THEN
		LET  cCodRet  = "00008";
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	END IF;

	IF pTipoRetorno = 2 THEN
		SELECT a.fecha_apertura, a.plazo, a.tasa_interes, b.capital_mto_cuota, c.monto_otorgado, a.num_aper_ant AS Iva
			INTO dFechaAper, mPlazo, mTasa, mCapacidadPres, mMontoAut, mIVA
		FROM bdicred:"informix".sd_maecredcrd a
		INNER JOIN bdicred:"informix".sd_amortiza_creditocrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito AND num_pago = 1
		INNER JOIN bdicred:"informix".sd_maesdoscrd c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
		WHERE a.num_credito = pNumCred;

		IF NVL(dFechaAper,'') = '' THEN
				LET  cCodRet  = "00006";
			 RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	ELSE
		-- SE OBTIENE EL IVA DE LA SUCURSAL
		SELECT iva
		  INTO mIVA
		  FROM bdinteg:"informix".si_sucursales
		 WHERE sucursal = pSucursal
		   AND empresa = cEmpresa;


		IF NVL(pNumCred, '') = '' THEN

			-- SE OBTIENE LA TASA ANUAL
			SELECT c.valor
			INTO mTasa
			FROM bdicred:"informix".sd_definicion a
			INNER JOIN bdinteg:"informix".si_fechavalor c ON (c.tasa = a.cod_tasa_base
															AND c.fecha = (SELECT MAX(r.fecha)
																		FROM bdinteg:"informix".si_fechavalor r
																		WHERE r.tasa = a.cod_tasa_base
																		AND r.fecha = r.fecha
																		AND r.empresa = a.empresa)
															AND c.empresa = a.empresa)
			WHERE a.num_producto = pProducto
			AND a.empresa      = cEmpresa;

		ELSE	-- Se obtiene la tasa diferenciada cuando existe el numero de credito

			EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(cEmpresa, pNumCred, '') INTO cCodRetTDif, mTasa, mTasa_Mora;
			IF cCodRetTDif <> '000000' THEN
				LET cCodRet = cCodRetTDif;
				RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
			END IF;
		END IF;

	END IF;

	IF mPlazo = 0 THEN
		LET mPlazo = case when pFrecuencia = 2 then sPlazoMax * 2 else sPlazoMax end;
	END IF;

	IF pProducto = '6400' AND  pFrecuencia = 1  THEN ---Frecuencia Mensual
		LET iTpoPago = 1;
		LET mPlazo = mPlazo * 1;
		LET sDiasPeriodo = 30;
	ELIF pProducto = '6400' AND  pFrecuencia = 2 THEN	---Frecuencia Quincenal
		LET iTpoPago = 2;
--		LET mPlazo = mPlazo * 2;
		LET sDiasPeriodo = 15;
	ELSE ---Frecuencia Mensual
        IF pProducto = '6800' THEN
            select sec_credito INTO inumppf
            from bdicred:sd_linea_prestamo
            WHERE num_credito = pNumCred;

            IF inumppf >=0 THEN
                SELECT tasa_interes
                INTO mTasa
                FROM bdicred:"informix".sd_maecredcrd
                WHERE num_credito = pNumCred;
           END IF;
        END IF;
        LET iTpoPago = 0;
        LET mPlazo = mPlazo * 1;
        LET sDiasPeriodo = 30;
   END IF;

	SELECT numcte INTO vNumCte FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pNumCred AND user_insert = 'sys_cred' LIMIT 1;


	IF NVL(vNumCte,"") <> "" THEN
	
		--Toma la tasa que proporciono el ?a de cr?to para los clientes pre aprobados.
		SELECT tasa INTO mTasa FROM bdicred:"informix".sd_pre_aprobados_trx WHERE numcte = vNumCte and num_producto= pProducto;
		
	END IF;
   
		-- SE OBTIENE LA TASA ANUAL CON IVA
		LET mTasaIVA = (mTasa * (1 + mIVA))/100;  ---
		LET mTasaInt = mTasa/100;                 ---

		-- SE CALCULA LA TASA DE INTERES MENSUAL
		LET mTasaMensual = mTasaInt/12;
		LET mTasaMensualIVA = mTasaIVA/12;


	IF mCapacidadPres > 0 AND mMontoAut > 0 THEN
		-- SI ESTA FORMULA REGRESA UN VALOR NEGATIVO SIGNIFICA QUE EL MONTO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES QUE SE GENERAN
		IF (((mMontoAut*(mTasaMensualIVA)/mCapacidadPres)-1)/-1) < 0 THEN
			LET cCodRet = "00003";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END IF;

	-- SI EL PARAMETRO QUE DEFINE EL RETORNO TIENE EL VALOR DE 2 SE OBTIENE LA FECHA DE APERTURA DEL CREDITO PARA REIMPRESION
	IF pTipoRetorno = 2 THEN
		LET dFechaActual = dFechaAper;
	ELIF pTipoRetorno = 3 OR pTipoRetorno = 4 THEN -- DIFERENTE FECHA PARA INICIO DE PROYECCION
		IF NVL(pFecha,"") = "" THEN
			LET  cCodRet  = "00007";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		ELSE
			LET dFechaActual = pFecha;
		END IF;
	ELSE
		-- SE OBTIENE LA FECHA
		SELECT fecha_hoy
          INTO dFechaActual
          FROM bdicred:"informix".sd_fechas;
	END IF;

	LET dFechaCouta = dFechaActual;
--JOM	LET mPlazoAux=mPlazo/pFrecuencia;
	LET mPlazoAux=mPlazo;
	IF pTipoRetorno <> 2 THEN
		-- SI TENEMOS EL PLAZO Y EL PAGO MENSUAL PERO NOS FALTA EL MONTO AUTORIZADO
		IF NVL(mPlazo,0) > 0 AND NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) = 0 THEN
			CALL "informix".sp_obtiene_aproximacion(0,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet2, mMontoAut;
			IF cCodRet2 <> "000000" THEN
					IF cCodRet2 < 0  THEN
						LET  cCodRet  = "00009";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
		-- SI TENEMOS EL PLAZO Y EL MONTO AUTORIZADO PERO NOS FALTA EL PAGO MENSUAL
		ELIF NVL(mPlazo,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(mCapacidadPres,0) = 0 THEN
			CALL "informix".sp_obtiene_aproximacion(mMontoAut,mPlazo,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet2, mCapacidadPres;
			IF cCodRet2 <> "000000" THEN
					IF cCodRet2 < 0  THEN
						LET  cCodRet  = "00010";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELIF cCodRet2 = "000012" THEN
							LET mPlazoAux =mPlazo;
						WHILE  sContinua = 0
							LET mPlazoAux = mPlazoAux - pFrecuencia;
							CALL "informix".sp_obtiene_aproximacion(mMontoAut,mPlazoAux,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet2, mCapacidadPres;
							IF cCodRet2 <> "000000" THEN
								IF cCodRet2 < 0  THEN
									LET  cCodRet  = "00011";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								ELIF cCodRet2 = "000012" THEN
									LET sContinua =0;
								ELSE
									LET  cCodRet  = "00010";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								END IF;
							ELSE
								LET sContinua =1;
								LET mPlazo = mPlazoAux;
--JOM								LET mPlazoAux=mPlazo/pFrecuencia;
							END IF;

						END WHILE;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF

		-- SI TENEMOS EL MONTO AUTORIZADO Y EL PAGO MENSUAL PERO DESCONOCEMOS EL PLAZO
		ELIF NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(pPlazo,0) = 0 THEN

			CALL "informix".sp_obtiene_aproximacion(mMontoAut,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet2, mPlazo;
			IF cCodRet2 <> "000000" THEN
					IF cCodRet2 < 0  THEN
						LET  cCodRet  = "00011";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
--JOM			LET mPlazoAux=mPlazo/pFrecuencia;
            LET mPlazoAux=mPlazo;
		END IF;
	END IF;

	-- SE VALIDA QUE EL MONTO DEL PRESTAMO SE ENCUENTRE DENTRO DEL RANGO PERMITIDO
    IF pTipoRetorno <> 0 THEN  -- Para el resumen no es necesario debido a que se realiza desde el procedimiento de calificaciÃÂ³n de la solicitud.
        IF mMontoAut < mMontoMin OR mMontoAut > mMontoMax THEN
            LET  cCodRet  = "00004";
                 --FMV 26-SEP-13: Monto minimo = Autorizado para continuar con la proyeccion
                    LET mMontoMin = mMontoAut;
                    LET cCodRet = "00000";
            --RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    END IF;

	-- SE VALIDA QUE EL PLAZO DEL PRESTAMO SE ENCUENTRE DENTRO DEL RANGO PERMITIDO
	IF pFrecuencia = 0 THEN
		IF mPlazo < sPlazoMin OR mPlazo > sPlazoMax THEN
			LET  cCodRet  = "00005";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	ELSE
		IF (mPlazo/pFrecuencia) < sPlazoMin OR (mPlazo/pFrecuencia) > sPlazoMax THEN
			LET  cCodRet  = "00005";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END IF;

	LET mSdoInicial = mMontoAut;
	LET mMensualidad = ROUND(mCapacidadPres,0);

	-- SI EL TIPO DE RETORNO ES 0 REGRESAMOS SOLO UN REGISTRO
	IF pTipoRetorno = 0 OR pTipoRetorno = 4 THEN
		LET mPeriodo = mPlazo;
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	ELSE -- SI EL TIPO DE RETORNO ES 1 REGRESAMOS TODO EL DETALLE DEL COMPORTAMIENTO DEL PRESTAMO
		-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
		LET dFechaInicial = dFechaCouta;
		LET dFechaAnt = dFechaCouta;

		FOR Contador = 1 TO mPlazo STEP 1

			-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
			IF mSdoFinal > 0 THEN
				LET mSdoInicial = mSdoFinal;
			END IF;

			IF mSdoFinal <= 0 AND Contador > 1 THEN
				EXIT FOR;
			END IF;

			-- SE ASIGNA EL PERIODO
			LET mPeriodo = Contador;

			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************
 			IF pProducto = '6400' THEN  --Periodo de pago  credinomina
					--se obtiene la fecha de la proxima cuota.
						EXECUTE PROCEDURE "informix".sp_obtienefechapago('001',dFechaCouta,pNumCred)
							INTO cCodRet2,dFechaCouta,iDiaPago;

							IF cCodRet2::INTEGER <> 0  THEN
								LET cCodRet    = "00015";	--Ocurrio un Error al obtener la fecha de pago del crÃÂ©dito para credinomina.
								RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
							END IF;

					   IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
							LET dFechaCouta = dFechaCouta + 1;
						END IF;
						IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
							LET dFechaAnt = dFechaAnt + 1;
						END IF;
						LET sDiasPeriodo = dFechaCouta - dFechaAnt;	--se obtienen los dias del periodo
						LET dFechaAnt = dFechaCouta;
			ELSE   ---Periodo de pago Mensual prestamo

				CALL bdicred:"informix".monthadd(dFechaInicial,Contador) RETURNING dFechaCouta;
				CALL bdicred:"informix".monthadd(dFechaInicial,Contador-1) RETURNING dFechaAnt;

				IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
					LET dFechaCouta = dFechaCouta + 1;
				END IF;

				IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
					LET dFechaAnt = dFechaAnt + 1;
				END IF;

				LET sDiasPeriodo = dFechaCouta - dFechaAnt;
			END IF;

			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************

			-- SE OBTIENE LA FECHA POR PLAZO
			--LET dFechaCouta = bdicred:monthadd(dFechaCouta,Contador);

			--SE CALCULAN LOS INTERESES
			LET mIntereses = mSdoInicial * (mTasaInt/360) * sDiasPeriodo;

			-- SE CALCULA EL IVA DE LOS INTERESES
			LET mIvaInt = ROUND(mIntereses * mIVA,2);
			--LET mMontoAutAux = mMontoAut + mIntereses + mIvaInt;

			IF mMontoAut < mMensualidad THEN
				LET mMensualidad = mMontoAut + mIntereses + mIvaInt;
				LET mCapital = mMontoAut;
			ELSE
					LET mCapital = mMensualidad - (mIntereses + mIvaInt);
					LET mIntereses = mIntereses ;
					LET mIvaInt  = mIvaInt ;
					LET sDiasPeriodo= sDiasPeriodo;
			END IF;

			IF NVL(mCapital,0) < 0 AND Contador = 1  THEN
				LET cCodRet = '00012';
				RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
			END IF;

			-- SE CALCULA EL SALDO FINAL
			LET mSdoFinal = mSdoInicial - mCapital;
			LET mMontoAut = mSdoInicial - mCapital;

			-- SE UTILIZA PARA PODER PAGINAR
	        IF Contador <= pSolicitudes THEN
	            CONTINUE FOR;
	        END IF;

		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux WITH RESUME;
		END FOR;
	END IF;
END;
END PROCEDURE
