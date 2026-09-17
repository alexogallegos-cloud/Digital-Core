CREATE PROCEDURE "informix".sp_proyecta_creditos_web(pMonto_Autorizado  DECIMAL(18,6),  -- MONTO DEL CREDITO
											       pPlazo 			 INTEGER, 	     --PLAZO EN MESES PARA PAGAR
                                                   pCapacidad_Pres	 DECIMAL(18,6),  -- CAPACIDAD DE PAGO DEL CLIENTE
                                                   pProducto 		 CHAR(4), 	     -- CODIGO DE pProducto
                                                   pSucursal 		 CHAR(4),	     -- CODIGO DE SUCURSAL
                                                   pTipoRetorno 	 SMALLINT,	     -- DETERMINA COMO SE VAN A RETORNAR LOS DATOS:
                                                                                                --	0  RESUMEN
                                                                                                --	1   DETALLE
                                                                                                --	2  REIMPRESION DE CARATULA
                                                                                                --	3  CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                                                                --	4  RESUMEN CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                   pSolicitudes 	 SMALLINT,	     -- PARA PAGINACION
                                                 --  pNumCred			 CHAR(20),	     -- NUMERO DE CREDITO
                                                   pFecha			 DATE,		     -- FECHA PARA INICIAR LA PROYECCION
												   pFrecuencia       INTEGER,         --Frecuencia de pago
																						--0.- Mensual(prestamo)
																						--1.- Mensual credinomina
																						--2.- Quincenal credinomina
												   pDiaPago       INTEGER
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
			CHAR(3)         AS NumMesesPago;	  -- FECHA DE APERTURA

--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agregaron como parametros de entrada el pProducto y la sucursal,
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
--Descripcion: Se cambio que al obtener el iva del maestro de crÃ©dito no se dividiera entre 100
--             ya que se definio que te almacenaria ya con el calculo correspondiente
--             Se valida si el pTipoRetorno es diferente de 0 realice la comparaciÃ³n de rangos
--             de montos maximos y minimos permitidos en caso contrario no se realice la comparaciÃ³n
--             ya se que se realizarÃ¡ desde la calificaciÃ³n del crÃ©dito (califica_scoring2).
--Fecha: 2009/11/01
--Version: 20091101.1013
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para que se contemplen diferentes escenarios de comparaciÃ³n de parÃ¡metros
--             para el pTipoRetorno 2 (Reimpresion de la proyecciÃ³n)
--Fecha: 2009/11/10
--Version: 20091110.1309
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para validar que los parÃ¡metros de plazo y monto autorizado recibido
--              se encuentra dentro de rango permitido y que para el escenario donde se reciba el
--              monto y la mensualidad, se ejecute el sp_obtiene_aproximaciÃ³n enviadole en el parÃ¡metro de
--              plazo el plazo mÃ¡ximo establecido para el pProducto de crÃ©dito a proyectar, con la finalidad
--              de que esta validaciÃ³n se elimine dentro del sp que realiza la proyecciÃ³n con valor fijo.
--Fecha: 2009/12/01
--VersiÃ³n: 20091201.1148
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para paginar los registros correctamente.
--Fecha: 2009/12/01
--Version: 20091201.1153
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifca para que al validar el retorno del sp_obtiene_aproximaciÃ³n,
--              se asgine un valor controlado o en su defecto retornar el cÃ³digo
--              que se reciba  del sp de aproximaciÃ³n.
--Fecha: 2009/12/10
--VersiÃ³n: 20091210.1107
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica las variables para calculos de tasas money(14,2) a decimal(9,6).
--Fecha: 2010/01/27
--Version: 20100127.0830
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para que el la mensualidad de la cuota no sobrepase al monto indicado
--	 	 en el parÃ¡metro de entrada en la ejecuciÃ³n del spl
--Fecha: 2010/02/05
--Version: 20100205.1358
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para cambiar los mensajes:
--             * Se modifica el retorno "00015" que mostraria el mensaje
--             "El cÃ¡lculo del monto no se puede realizar con los parÃ¡metros actuales" por el
--             retorno "00004" para que muestre el mensaje "El monto autorizado esta fuera del rango permitido".
--             * Se modifica el retorno "00014" por el retorno "00005" era el mismo mensaje solo se reemplazo
--             para eliminar el mensaje similar.
--Fecha: 2010/02/09
--Version: 20100209.0912
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Hector Manuel Bojorquez Ruelas,JesÃºs Manuel Aguilar Heredia
--Descripcion: Se modifica para que se pueda utilizar en el pProducto Credinomina, para lo cual se le agrego un parametro de entrada mas para identificar la forma de pago del prestamo.
--Fecha: 2011/05/04
--Version: 20110405.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: JesÃºs Manuel Aguilar Heredia
--Descripcion: Se modifica para que  se contemple el dia de pago en la proyeccion, y no se manejen dias 15 y 30.
--Fecha: 2011/08/10
--Version: 20110810.1010
---------------------------------------------------------------------------------------------------------------
-- VARIABLES DE CONTROL DE ERRORES
DEFINE isqlerr      	INTEGER;			-- CODIGO DE ERROR
-- VARIABLES PARA RETORNO DE DATOS
DEFINE cCodRet     		CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
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
DEFINE mTasa			DECIMAL(18,6);		-- TASA ANUAL
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
DEFINE mPlazo  	 		DECIMAL(18,6);		--PLAZO EN MESES PARA PAGAR
DEFINE mCapacidadPres	DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE

DEFINE cEmpresa         CHAR(3);
DEFINE dLimites         DECIMAL(18,6);
DEFINE dDiferencia      DECIMAL(18,6);
DEFINE mMensualidadAux  DECIMAL(18,6);
DEFINE mMontoAutAux		DECIMAL(18,6);

DEFINE iTpoPago        INTEGER;
DEFINE cTipo            CHAR(15);
DEFINE iDiaPago      	INTEGER;
DEFINE mPlazoAux      	DECIMAL(18,6);
DEFINE sContinua      	INTEGER;
---6011
DEFINE cod_ret            char(5);
DEFINE vcod_tasa_base     char(8);
DEFINE vtipoplazo         char(1);
DEFINE vtipodia           char(1);
DEFINE proyeccio1         char(20);
DEFINE v_dia              char(2);
DEFINE v_mes              char(2);
DEFINE v_anio             char(4);
DEFINE vfactor_sobretasa  char(1);
DEFINE wtp_calculo        char(2);
DEFINE wcod_tipcred       char(2);
DEFINE vcat               char(6);
DEFINE vCodTasaMora       char(8);
DEFINE vFactor            char(1);
DEFINE wfecha_venc        date;
DEFINE wfecha_alta        date;
DEFINE vfecha             date;
DEFINE vfecha_hoy         date;
DEFINE vfecha_hoyAnt      date;
DEFINE wfecha_cambio      date;
DEFINE wfecha_cambi1      date;
DEFINE vfecha_primer      date;
DEFINE v_fecha_vencim     date;
DEFINE wtasa_interes      decimal(9,6);
DEFINE vSobreTasa         decimal(9,6);
DEFINE vtasa_periodo      decimal(10,6);
DEFINE vtasa_diario       decimal(10,6);
DEFINE v_tasa_interes     decimal(9,6);
DEFINE wfactor            decimal(10,6);

DEFINE wmonto_iva         decimal(14,2);
DEFINE wadicional         decimal(14,2);
DEFINE wadicionals        decimal(14,2);
DEFINE wcomisions         decimal(14,2);
DEFINE wtasaprop          decimal(9,6);
DEFINE vTasaMora          decimal(9,6);
DEFINE vmontopago         decimal(14,2);
DEFINE sqlerr             integer;
DEFINE proyeccion         integer;
DEFINE wmesespro          integer;
DEFINE cuotafantasma      integer;
DEFINE nomeses1           integer;
DEFINE nomeses2           integer;
DEFINE vAnio              integer;
DEFINE vDia               integer;
DEFINE vMes               integer;
DEFINE vper               integer;
DEFINE vdia1              integer;
DEFINE cicloseguro        smallint;
DEFINE v_dias_cal_int     CHAR(10);
DEFINE wplazo_fin         smallint;
DEFINE wplazo_linea       smallint;
DEFINE vmaxmeses          smallint;
DEFINE wplazo_v           smallint;
DEFINE wplazo_1           smallint;
DEFINE v_dias             smallint;
DEFINE cicloadicionales   smallint;
DEFINE ciclo              smallint;
DEFINE pagopropuestocal   money(14,2);
DEFINE capital            money(14,2);
DEFINE capital1           money(14,2);
DEFINE valorfinal         money(14,2);
DEFINE valorfinalAnt      money(14,2);
DEFINE interes            money(14,2);
DEFINE iva                money(14,2);
DEFINE vmonto_int_par     money(14,2);
DEFINE vinteres_total     money(14,2);
DEFINE wmonto_linea       money(14,2);
DEFINE vCapital          money(14,2);
DEFINE vInteres           money(14,2);
DEFINE vIva               money(14,2);
DEFINE vIvaMas            money(14,2);
DEFINE vMesPro            money(14,2);
DEFINE vValorFin          money(14,2);
DEFINE vabono_fijo        money(14,2);
DEFINE vProyecInt         money(14,2);
DEFINE vValorPre          MONEY(14,2);
DEFINE BanderaCas         CHAR(1);
 --  DEFINE cMontoMaxPlazoMax  MONEY(18,2);
 --  DEFINE cFechaMaxPlazoMax  MONEY(18,2);


LET nomeses1 = 0;
LET wtasaprop = 0;
LET wmesespro = 0;

LET cod_ret          = "000";
LET wtasa_interes    = 0;
LET wplazo_v         = 0;
LET vfecha_hoy       = "";
LET v_fecha_vencim   = "";
LET v_dias_cal_int   = '0';
LET vmonto_int_par   = 0;
LET sqlerr           = 0;
LET capital          = 0;
LET capital1         = 0;
LET interes          = 0;
LET iva              = 0;
LET valorfinal       = 0;
LET vfecha           = "";
LET proyeccion       = 0;
LET v_tasa_interes   = 0;
LET vAnio            = 0;
LET vMes             = 0;
LET vDia             = 0;
LET vcat             = '';
LET vTasaMora        = 0;
LET vCodTasaMora     = '';
LET vFactor          = '';
LET vSobreTasa       = 0;
LET vProyecInt       = 0;
LET valorfinalAnt    = 0;
LET BanderaCas       = '0';
--  LET cMontoMaxPlazoMax= 0;

--6011
LET iSqlErr 		= 0;
LET cCodRet 		= "00000";
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

LET iTpoPago       = 0;
LET cTipo             = '';
LET iDiaPago       = 0;
LET mPlazoAux       = 0;
LET sContinua       = 0;



BEGIN

	ON EXCEPTION  SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET  cCodRet  = iSqlErr;
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END  EXCEPTION

--  SET DEBUG FILE TO "/tmp/sp_Proyecta_creditos.out";
--  TRACE ON;
	--SET DEBUG FILE TO "/informix/jesus/sp_Proyecta_Prestamo.out";
	--TRACE ON;
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- ***********************************************************************
	-- 00001 	VALORES DE ENTRADA INCORRECTOS
	-- 00002	SOLO SE PERMITE RECIBIR 2 DE LOS 3 PARAMETROS SIGUIENTES pMonto_Autorizado, pPlazo, pCapacidad_Pres
	-- 00003	LA CANTIDAD DEL PAGO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES
	-- 00004	EL MONTO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 00005	EL PLAZO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 00006	EL NUMERO DE CREDITO NO EXISTE
	-- 00007	FALTA LA NUEVA FECHA DE INICIO DE LA PROYECCION
	-- 00008	EL PARAMETRO DE FECHA NO ES NECESARIO
	-- 00009	EL CALCULO DEL MONTO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 00010	EL CALCULO DE LA CAPACIDAD NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 00011	EL CALCULO DE EL PLAZO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 00012   NO ES POSIBLE REALIZAR UNA PROYECCIÃN CON LAS CONDICIONES INDICADAS. (Este cÃ³digo de retorno llega desde el sp_obtiene_aproximacion_creditos)
	-- 00013   LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO OBTENIDOS SON INCORRECTOS
	-- 00014   EL PARAMETRO DE FRCUENCIA DE PAGO RECIBIDO NO ES VALIDO
	-- 00015 Ocurrio un Error al obtener la fecha de pago del crÃ©dito para credinomina.
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- *********************************** ************************************

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		--Se valida si la frecuencia recibida es correcta

IF pProducto = '6011' THEN



	IF pCapacidad_Pres < 10 THEN
      LET cCodret = '00003';
      RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
    END IF;

-- SE OBTIENE EL I.V.A
    SELECT valor
    INTO vIva
    FROM "informix".sd_param
    WHERE empresa = '001'
      AND cod_param='12';

-- SE LE INCREMENTA 1 AL I.V.A
   LET vIvaMas = vIva + 1;

    SELECT cod_tasa_mora,fact_sobret_mora,sobretasa_mora
    INTO   vCodTasaMora, vFactor, vSobreTasa
    FROM   bdicred:"informix".sd_definicion  --FMV 1-AGO-12 Se cambia a la tabla sd_definicion no afecta, Rees no usa mora
    WHERE  num_producto = pProducto;

    SELECT valor  INTO vTasaMora FROM bdinteg:"informix".si_fechavalor
    WHERE empresa = '001'
      AND tasa = vCodTasaMora
      AND fecha = (SELECT MAX(fecha)
                    FROM bdinteg:"informix".si_fechavalor
                   WHERE tasa = vCodTasaMora);

     IF   vFactor = '+' then
        LET vTasaMora = vTasaMora + vSobreTasa;
     ELIF vFactor = '-' then
        LET vTasaMora = vTasaMora - vSobreTasa;
     ELIF vFactor = '*' then
        LET vTasaMora = vTasaMora * vSobreTasa;
     ELIF vFactor = '/' then
        LET vTasaMora = vTasaMora / vSobreTasa;
     ELSE
        LET vTasaMora = vTasaMora;
     END IF;


       IF pMonto_Autorizado = 0  or pCapacidad_Pres = 0 or trim(pProducto) = "" THEN
          LET cCodret = "110";
          RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux ;
       END IF


       select cod_tasa_base,factor_sobretasa,sobretasa,plazo_max_cred,periodo_plazo
       into vcod_tasa_base,vfactor_sobretasa,vsobretasa,vmaxmeses,vtipoplazo
       from bdicred:"informix".sd_definicion where num_producto = pProducto;
       SELECT valor  INTO wtasa_interes FROM bdinteg:"informix".si_fechavalor
        WHERE tasa = vcod_tasa_base
          AND fecha = (SELECT MAX(fecha)
                         FROM bdinteg:"informix".si_fechavalor
                        WHERE tasa = vcod_tasa_base);
       LET v_tasa_interes = wtasa_interes * vsobretasa;
       IF vfactor_sobretasa = '+' then
          LET v_tasa_interes = wtasa_interes + vsobretasa;
       ELIF vfactor_sobretasa = '-' then
            LET v_tasa_interes = wtasa_interes - vsobretasa;
       ELIF vfactor_sobretasa = '*' then
            LET v_tasa_interes = wtasa_interes * vsobretasa;
       ELIF vfactor_sobretasa = '/' then
            LET v_tasa_interes = wtasa_interes / vsobretasa;
       END IF;

     SELECT valor
        INTO v_dias_cal_int
        FROM bdicred:"informix".sd_param       ----FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       WHERE empresa = '001'
         AND cod_param = "24";






      LET proyeccion = proyeccion + 1;

      SELECT fecha_hoy,pri_dia_mes
        INTO vfecha_hoy,vfecha_primer
        FROM bdicred:"informix".sd_fechas
       WHERE empresa = '001';

      if day(vfecha_hoy) > 2 and day(vfecha_hoy) < 17 then
         LET vfecha_primer = Mdy(month(vfecha_hoy),02,year(vfecha_hoy));
         LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
      else
         LET vfecha_primer = Mdy(month(vfecha_hoy),17,year(vfecha_hoy)) ;
         IF day(vfecha_hoy) > 2 THEN
            LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
         END IF;
      end if
      LET wplazo_linea = vmaxmeses;
      LET vtipodia = "N";
      LET v_fecha_vencim = vfecha_primer + (wplazo_linea - 1) units month;
      LET wplazo_fin =1;
      LET wplazo_v = 0;
      if vtipoplazo = "C" then
         LET wplazo_fin = 4;
      else
         if vtipoplazo = "A" then
            LET wplazo_fin = 12;
         else
            if vtipoplazo = "S" then
               LET wplazo_fin = 6;
            end if
         end if
      end if
      LET wmonto_linea = pMonto_Autorizado;
      LET vtasa_periodo = (v_tasa_interes/12)/100;
      LET ciclo = 0;
      LET vinteres_total =0 ;
      LET wfecha_alta = vfecha_primer ;
      LET wcomisions = 0;
      LET wadicionals = 0;
      LET cuotafantasma = 0;
      LET wplazo_1 = vmaxmeses;
      LET nomeses2 = 0;
      if pCapacidad_Pres > 0 then
         LET nomeses1 = vmaxmeses;
         LET wplazo_1 = vmaxmeses;
      end if
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
   LET vtasa_diario = round((v_tasa_interes/v_dias_cal_int)/100,8);

  -- LET vtasa_diario = vtasa_diario * (1 + .15);

   LET vdia1 = (wfecha_alta - vfecha_hoy);
   LET vabono_fijo = pCapacidad_Pres;
   LET vtasa_periodo = vtasa_periodo * vIvaMas;
   LET wmonto_linea = wmonto_linea;
   LET ciclo = 0;
   LET wadicional = wmonto_linea;
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vValorPre = 0;

   LET vdia1 = vdia1;

  while ciclo < wplazo_linea
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          --LET vdia1 = wfecha_cambi1 - wfecha_cambio + 1;
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       ELSE
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       END IF;

   --    LET vmonto_int_par = round(wadicional * vtasa_diario * vdia1,2);

       LET vmonto_int_par = round(wadicional * vtasa_diario, 2);
       LET vmonto_int_par = round(vmonto_int_par * vdia1, 2);
       LET wmonto_iva = round(vmonto_int_par  * vIva ,2);
    --   LET vmonto_int_par = vmonto_int_par - wmonto_iva ;
       LET capital = pCapacidad_Pres - vmonto_int_par - wmonto_iva ;

       IF capital < 0 THEN -- No Cubre el Interes
          LET valorfinalAnt=valorfinal;
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses+3));
            IF pCapacidad_Pres < ROUND(wmonto_linea*vtasa_periodo,2) THEN
               LET valorfinal=valorfinal+valorfinalAnt;

            END IF;
          LET wadicional = wmonto_linea - valorfinal;
           IF wadicional<0 THEN
              LET cod_ret = '002';
             RETURN cCodRet, ciclo, wfecha_alta, wmonto_linea, vmontopago, vmonto_int_par, wmonto_iva, capital, wmonto_linea, vdia1, wfecha_alta, ciclo;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET capital = 0;
          LET BanderaCas='2';
--          LET cod_ret = "002";
--          return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
       END IF;
       LET capital = capital;
       LET vmonto_int_par = vmonto_int_par;
       LET wmonto_iva = wmonto_iva;
       LET pCapacidad_Pres = pCapacidad_Pres;

       --IF vmonto_int_par = 0 THEN
       IF vmonto_int_par < 0 THEN   --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
          EXIT WHILE;
       END IF;

       if capital > wadicional then
          LET capital = wadicional;
       end if
       IF ciclo <> 0 THEN
           LET wfecha_cambio = wfecha_cambi1;
           LET wfecha_cambi1 = wfecha_cambi1 + 1 UNITS MONTH;
           LET wadicional = wadicional - capital;
       END IF;

       IF valorfinal>0 AND ciclo>=vmaxmeses and ((BanderaCas= '1' ) or pCapacidad_Pres > ROUND(wmonto_linea*vtasa_periodo,2)) THEN --and wadicional<=0
          EXIT WHILE;
       END IF;

       IF wadicional > 0 and ciclo = vmaxmeses THEN
          LET valorfinalAnt=valorfinal;
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses));
            IF pCapacidad_Pres < ROUND(wmonto_linea*vtasa_periodo,2) and BanderaCas='2' THEN
               LET valorfinal=valorfinal+valorfinalAnt;

            END IF;
          LET wadicional = wmonto_linea - valorfinal;
          LET capital = 0;
           IF wadicional<0 THEN
              EXIT WHILE;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET BanderaCas= '1';
       END IF;



       if wadicional <= 0 then
          LET wadicional = 0;
          EXIT WHILE;
       end if;
   end while



   LET pMonto_Autorizado = pMonto_Autorizado;
   LET vfecha_hoyAnt = vfecha_hoy;
  -- LET valorfinal = pMonto_Autorizado - wmonto_linea;
   LET valorfinal = valorfinal;
   LET wmonto_linea = wmonto_linea-valorfinal;
   LET wplazo_linea = vmaxmeses;
   LET ciclo = 0;
   LET vabono_fijo = pCapacidad_Pres;
   LET BanderaCas='1';
   LET valorfinal = pMonto_Autorizado -wmonto_linea;
   while ciclo < wplazo_linea and wmonto_linea <> 0
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          --LET vdia1 = wfecha_alta - vfecha_hoy + 1;
          LET vdia1 = wfecha_alta - vfecha_hoy;
       ELSE
          LET vdia1 = wfecha_alta - vfecha_hoy;
       END IF;
       --LET vmonto_int_par = round(wmonto_linea * vtasa_diario * vdia1,2);

       LET vmonto_int_par = round(wmonto_linea * vtasa_diario ,2);
       LET vmonto_int_par = round(vmonto_int_par *  vdia1,2);
       LET wmonto_iva = round(vmonto_int_par * vIva,2);

       --LET vmonto_int_par = vmonto_int_par - wmonto_iva ;
       IF vmonto_int_par < 0 THEN
       --IF vmonto_int_par = 0 THEN     --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
          EXIT WHILE;
       END IF;

       LET capital = pCapacidad_Pres - vmonto_int_par - wmonto_iva ;

       if capital > wmonto_linea then
          LET capital = wmonto_linea;
       end if
        LET vmontopago = capital + vmonto_int_par + wmonto_iva;


		LET  Contador = Contador+1;
		IF Contador > pSolicitudes THEN
	           RETURN cCodRet, ciclo, wfecha_alta, valorfinal, vmontopago, vmonto_int_par, wmonto_iva, capital, wmonto_linea, vdia1, wfecha_alta, ciclo WITH RESUME;
     	END IF;


      LET vfecha_hoy = wfecha_alta;
      LET wfecha_alta = wfecha_alta + 1 UNITS MONTH;
	let wmonto_linea = wmonto_linea - capital;



      if wmonto_linea <= 0 then
          LET wmonto_linea = 0;
      end if;
  end while
ELSE


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
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
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

	LET pSucursal =pSucursal;
		-- SE OBTIENE EL IVA DE LA SUCURSAL
		SELECT iva
		  INTO mIVA
		  FROM bdinteg:"informix".si_sucursales
		 WHERE sucursal = pSucursal
		   AND empresa = "001";


		IF mIVA = 0 THEN
			LET mIVA = 0.16;
		END IF


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


	LET mPlazo = mPlazo;
	LET pFrecuencia = pFrecuencia;
	LET sPlazoMax = sPlazoMax;


	IF NVL(mPlazo,0) = 0 THEN
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
		LET iTpoPago = 0;
		LET mPlazo = mPlazo * 1;

		LET sDiasPeriodo = 30;
	END IF;


		-- SE OBTIENE LA TASA ANUAL CON IVA
		LET mTasaIVA = (mTasa * (1 + mIVA))/100;  ---
		LET mTasaInt = mTasa/100;                 ---

		-- SE CALCULA LA TASA DE INTERES MENSUAL
		LET mTasaMensual = mTasaInt/mPlazo;
		LET mTasaMensualIVA = mTasaIVA/mPlazo;



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
			CALL "informix".sp_obtiene_aproximacion_creditos(0,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mMontoAut;
			IF cCodRet <> "00000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "00009";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
		-- SI TENEMOS EL PLAZO Y EL MONTO AUTORIZADO PERO NOS FALTA EL PAGO MENSUAL
		ELIF NVL(mPlazo,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(mCapacidadPres,0) = 0 THEN
			CALL "informix".sp_obtiene_aproximacion_creditos(mMontoAut,mPlazo,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mCapacidadPres;
			IF cCodRet <> "00000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "00010";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELIF cCodRet = "00012" THEN
							LET mPlazoAux =mPlazo;
						WHILE  sContinua = 0
							LET mPlazoAux = mPlazoAux - pFrecuencia;
							CALL "informix".sp_obtiene_aproximacion_creditos(mMontoAut,mPlazoAux,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mCapacidadPres;
							IF cCodRet <> "00000" THEN
								IF cCodRet < 0  THEN
									LET  cCodRet  = "00011";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								ELIF cCodRet = "00012" THEN
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


			CALL "informix".sp_obtiene_aproximacion_creditos(mMontoAut,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mPlazo;
			IF cCodRet <> "00000" THEN
					IF cCodRet < 0  THEN
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
    IF pTipoRetorno <> 0 THEN  -- Para el resumen no es necesario debido a que se realiza desde el procedimiento de calificaciÃ³n de la solicitud.
        IF mMontoAut < mMontoMin OR mMontoAut > mMontoMax THEN
            LET  cCodRet  = "00004";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
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
						EXECUTE PROCEDURE "informix".sp_obtienefechapago_creditos('001',dFechaCouta,pFrecuencia,pDiaPago)
							INTO cCodRet,dFechaCouta,iDiaPago;


							IF cCodRet::INTEGER <> 0  THEN
								LET cCodRet    = "00015";	--Ocurrio un Error al obtener la fecha de pago del crÃ©dito para credinomina.
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
END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Simula el comportamiento de un prestamo durante el plazo seleccionado',
'Fecha: 2009/09/09',
'Version: 20090909.1750';

create procedure "informix".sp_consulta_sdo_apoyo(pNumCredito CHAR(20),pNumCte CHAR(20))
       returning CHAR(5),DECIMAL(14,2),char(40);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

	DEFINE sqlerr           INTEGER; 
   
	DEFINE vcodret     		CHAR(5);
	DEFINE saldoApoyo		DECIMAL(14,2);
	DEFINE vMensaje     	CHAR(40);

	
	
	DEFINE vNumProd     	CHAR(4);
	DEFINE vNumCte			CHAR(20);
	DEFINE auxApoyo			INTEGER;
	DEFINE sdo_interes		DECIMAL(14,2);
	DEFINE sdo_iva			DECIMAL(14,2);
	
	DEFINE v_num_credito	CHAR(20);
	DEFINE v_producto		CHAR(20);
	
   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************   
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret,saldoApoyo,vMensaje;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;

--	SET DEBUG FILE TO "/ifxsif01/Israel/saldo_apoyo/sp_consulta_sdo_apoyo.out";
--	TRACE ON;

		LET vcodret 		= '00000';
		LET saldoApoyo		= 0;
		LET vMensaje 		= 'PROCESO EXITOSO';

		LET vNumProd		= '';
		LET vNumCte			= '';
		LET auxApoyo		= 0;
		LET sdo_interes		= 0;
		LET sdo_iva			= 0;
	   
		LET v_num_credito	= '';
		LET v_producto		= '';
	   
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************		   

		IF pNumCredito <> '' THEN
		
			SELECT num_producto,numcte
				INTO vNumProd,vNumCte
			FROM bdicred:Sd_maecred WHERE num_credito = pNumCredito;
			
			IF vNumProd IS NULL THEN	
				SELECT num_producto,numcte
					INTO vNumProd,vNumCte
				FROM bdicred:Sd_maecredcrd WHERE num_credito = pNumCredito;
				
				IF vNumProd IS NULL THEN
					LET vcodret = '00001';
					LET vMensaje = 'CREDITO NO EXISTE'; 
					RETURN vcodret,saldoApoyo,vMensaje;
				END IF;
			END IF;
			
			SELECT COUNT (*) 
				INTO auxApoyo		
			FROM
				(SELECT a.num_credito
				FROM bdicred:Sd_maecred a
					join bdicred:sd_programa_apoyo2020 b on (a.num_credito = b.num_credito)
				WHERE numcte = vNumCte AND b.bandera  = 'A'
				UNION ALL
				SELECT a.num_credito
				FROM bdicred:Sd_maecredcrd a
					join bdicred:sd_programa_apoyo2020crd b on (a.num_credito = b.num_credito)
				WHERE numcte = vNumCte AND b.bandera  = 'A');
			
				IF auxApoyo = 0 THEN
					LET vcodret = '00002';
					LET vMensaje = 'CREDITO NO ESTA EN PROGRAMA DE APOYO'; 
					RETURN vcodret,saldoApoyo,vMensaje;
				END IF;
			
			IF vNumProd IN ('6001','8100') THEN
			
				SELECT SUM(monto)
				INTO sdo_interes
				FROM BDICRED:sd_maeretenido 
				WHERE num_credito = pNumCredito 
				AND estatus = "R" 
				AND transacc = '8369';

				SELECT SUM(monto) sdo_iva
				INTO sdo_iva
				FROM BDICRED:sd_maeretenido 
				WHERE num_credito = pNumCredito
				AND estatus = "R" 
				AND transacc = '8370';
				
				LET sdo_interes = nvl(sdo_interes,0);
					LET sdo_iva = nvl(sdo_iva,0);
				
			ELIF vNumProd IN ('6300','7600','7700','6800') THEN
				
				LET sdo_interes = 0;
				LET sdo_iva = 0;

			ELSE
				LET vcodret = '00003';
				LET vMensaje = 'PRODUCTO NO ESTA EN PROGRAMA DE APOYO'; 
				RETURN vcodret,saldoApoyo,vMensaje;		
			END IF;
			
			LET saldoApoyo = sdo_interes + sdo_iva;
				
			RETURN vcodret,saldoApoyo,vMensaje;
			
		ELIF pNumCte <> ''  THEN 

			SELECT COUNT (*) 
				INTO auxApoyo		
			FROM
				(SELECT a.num_credito
				FROM bdicred:Sd_maecred a
					join bdicred:sd_programa_apoyo2020 b on (a.num_credito = b.num_credito)
				WHERE numcte = pNumCte AND b.bandera  = 'A'
				UNION ALL
				SELECT a.num_credito
				FROM bdicred:Sd_maecredcrd a
					join bdicred:sd_programa_apoyo2020crd b on (a.num_credito = b.num_credito)
				WHERE numcte = pNumCte AND b.bandera  = 'A');
			
				IF auxApoyo = 0 THEN
					LET vcodret = '00004';
					LET vMensaje = 'CLIENTE NO ESTA EN PROGRAMA DE APOYO'; 
					RETURN vcodret,saldoApoyo,vMensaje;
				END IF;
				
			FOREACH 
			
				SELECT a.num_credito,a.num_producto
					INTO v_num_credito,v_producto
				FROM bdicred:Sd_maecred a
					join bdicred:sd_programa_apoyo2020 b on (a.num_credito = b.num_credito)
				WHERE numcte = pNumCte AND b.bandera  = 'A'
				UNION ALL
				SELECT a.num_credito,a.num_producto
				FROM bdicred:Sd_maecredcrd a
					join bdicred:sd_programa_apoyo2020crd b on (a.num_credito = b.num_credito)
				WHERE numcte = pNumCte AND b.bandera  = 'A'
					
				IF v_producto IN ('6001','8100') THEN
				
					SELECT SUM(monto)
					INTO sdo_interes
					FROM BDICRED:sd_maeretenido 
					WHERE num_credito = v_num_credito 
					AND estatus = "R" 
					AND transacc = '8369';

					SELECT SUM(monto) sdo_iva
					INTO sdo_iva
					FROM BDICRED:sd_maeretenido 
					WHERE num_credito = v_num_credito
					AND estatus = "R" 
					AND transacc = '8370';
					
					LET sdo_interes = nvl(sdo_interes,0);
					LET sdo_iva = nvl(sdo_iva,0);
					
				ELIF v_producto IN ('6300','7600','7700','6800') THEN
					
					LET sdo_interes = 0;
					LET sdo_iva = 0;
					
				END IF;
				
				LET saldoApoyo = saldoApoyo + sdo_interes + sdo_iva;	
				
			END FOREACH;
			
		ELSE
		
			LET vcodret = '00005';
			LET vMensaje = 'PARAMETROS DE ENTRADA IVALIDOS'; 
			RETURN vcodret,saldoApoyo,vMensaje;	
		
		END IF; 
		
	  RETURN vcodret,saldoApoyo,vMensaje;	
		  
	END;
END PROCEDURE
DOCUMENT
'PROCESO PARA OBTENER SALDO DE PROGRAMA DE APOYO DE TDC, POR EL MOMENTO NO SE TIENE PARA PP',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : JUL/2020',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa CHAR(3), pNumCredito CHAR(20))
RETURNING  
    CHAR(6) AS codigo_retorno,
    CHAR(80) AS mensaje_retorno,
    CHAR(20) AS numero_credito,
    CHAR(2) AS codigo_tipcred,
    DATE AS fecha_origen,
    DATE AS fecha_prox_pago,
    DECIMAL(18,2) AS pago_minimo,
    DATE AS fecha_ult_pago,
    INTEGER AS plazo,
    INTEGER AS pagos_realizados,
    DECIMAL(18,2) AS linea_otorgada,
    DECIMAL(9,6) AS tasa_interes,
    DECIMAL(9,6) AS tasa_moratorios,
    DECIMAL(14,2) AS monto_sbc,
    DECIMAL(18,2) AS cap_vig,
    DECIMAL(18,2) AS cap_trans,
    DECIMAL(18,2) AS cap_vdo_exig,
    DECIMAL(18,2) AS cap_vdo_no_exig,
    DECIMAL(18,2) AS sdo_act_total_cap,
    DECIMAL(18,2) AS int_vig,
    DECIMAL(18,2) AS int_vdo,
    DECIMAL(18,2) AS int_moratorios,
    DECIMAL(18,2) AS int_mes,
    DECIMAL(18,2) AS sdo_act_total_int,
    DECIMAL(18,2) AS iva_int_vig,
    DECIMAL(18,2) AS iva_int_vdo,
    DECIMAL(18,2) AS iva_int_moratorios,
    DECIMAL(18,2) AS iva_int_mes,
    DECIMAL(18,2) AS sdo_act_total_iva,
    DECIMAL(18,2) AS com_pend,
    DECIMAL(18,2) AS iva_com,
    DECIMAL(18,2) AS sdo_retenido,
    DECIMAL(18,2) AS total_liquidacion,
    DECIMAL(18,2) AS int_devengado,
    DECIMAL(18,2) AS iva_int_devengado,
    DECIMAL(18,2) AS linea_disponible,
    DECIMAL(18,2) AS pagos_vdos,
    CHAR(60) AS desc_status_cred,
    INTEGER AS id_bloqueo_cred,
    CHAR(60) AS bloqueo_cta,
    CHAR(3) AS id_causa_bloqueo_cred,
    CHAR(50) AS causa_bloqueo_cta,
    CHAR(1) AS id_sit_esp_cte,
    INTEGER AS id_causa_esp_cte,
    CHAR(75) AS sit_esp_cte,
    CHAR(1) AS id_sit_esp_cred,
    INTEGER AS id_causa_esp_cred,
    CHAR(75) AS sit_esp_cred;
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 12/10/2009                                                                                     --
    -- Autor: Roque Enrique Solis CampaÃÂÃÂÃÂÃÂ±a                                                                    --
    --Modificacion: Se agregaron las consultas para saldos de prestamos personales                           --
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 20/10/2009                                                                                     --
    -- Autor: Roque Enrique Solis CampaÃÂÃÂÃÂÃÂ±a                                                                    --
    --Modificacion: Se agrego el calculo de la comision para prestamo personal                               --
    --            se sumo al monto total de liquidacion la comision y el iva de comision                     --
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 22/12/2009                                                                                     --
    -- Autor: Paul ivan quintero varela                                                                      --
    -- Modificacion: Se modifica para contemplar el calculo del iva de interes real                          --
    --               o iva de interes devengado                                                              --
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    -- Fecha: 30/11/2011                                                                                     --
    -- Autor: Diego Guera Atienzo                                                                            --
    -- Modificacion: Se modifica mÃÂÃÂÃÂÃÂ©todo para calcular el IVA moratorio en prÃÂÃÂÃÂÃÂ©stamos personales y             --
    --				 reestructuras                                                                           --
    -----------------------------------------------------------------------------------------------------------

    DEFINE nrows INTEGER;
    DEFINE iSqlErr INTEGER;
    DEFINE iIsamErr INTEGER;
    DEFINE cErrorInfo CHAR(80);
    DEFINE cCodRet CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
    DEFINE cEmpresa CHAR(3);
    DEFINE cNumCte CHAR(20);
    DEFINE cNumCredito CHAR(20);
	DEFINE cNumCreditoAux CHAR(20);
    DEFINE cCodTipCred CHAR(2);
    DEFINE cNumTarjeta CHAR(20);
    DEFINE cDescStatusCred CHAR(60);    
    DEFINE cSucursal CHAR(4);
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dMontoFinanciado DECIMAL(18,2);
    DEFINE dIvaSuc DECIMAL(5,3);    
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);    
    DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMoratorio_d DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dtIvaFechaPag DATE;
    DEFINE dtFechaCuota DATE;
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
    DEFINE dFactorComision DECIMAL(18,2);
    DEFINE dtMesiversario DATE;
    DEFINE dtFechaHoy DATE;
    DEFINE cTipCred CHAR(2);
    DEFINE cind_comision CHAR(1);
    DEFINE ctran_comision CHAR(4);
    DEFINE vRetCs_acum DECIMAL(18,2);    
    DEFINE vvcodigo_retorno CHAR(6);
    DEFINE vvmensaje_retorno CHAR(80);
    DEFINE vRespaldo smallint;

    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cErrorInfo = '';
    LET cCodRet = '';
    LET cMensajeRet = '';    
    LET cEmpresa = '';
    LET cNumCte = '';
    LET cNumCredito = '';
	LET cNumCreditoAux = '';
    LET cCodTipCred = '';
    LET cNumTarjeta = '';
    LET cDescStatusCred = '';    
    LET cSucursal = '';
    LET iIdUnidadProd = 0;
    LET cCodCaract2 = '';
    LET dMontoFinanciado = 0;
    LET dIvaSuc = 0;    
    LET dtFechaOrigen = DATE(1);
    LET dtFechaProxPago = DATE(1);
    LET dPagoMinimo = 0;
    LET dtFechaUltPago = DATE(1);
    LET iPlazo = 0;
    LET iPagosRealizados = 0;
    LET dLineaOtorgada = 0;    
    LET dTasaInteres = 0;
    LET dTasaMoratorios = 0;
    LET dMontoSBC = 0;    
    LET dCapVig = 0;
    LET dCapTrans = 0;
    LET dCapVdoExig = 0;
    LET dCapVdoNoExig = 0;
    LET dSdoActCap = 0;    
    LET dIntVig = 0;
    LET dIntVdo = 0;
    LET dIntMoratorio = 0;
    LET dIntMoratorio_d = 0;
    LET dIntMes = 0;
    LET dSdoActInt = 0;    
    LET dIvaIntVig = 0;
    LET dIvaIntVdo = 0;
    LET dIvaIntMoratorio = 0;
    LET dIvaIntMes = 0;
    LET dSdoActIvaInt = 0;    
    LET dComPend = 0;
    LET dIvaCom = 0;
    LET dSdoRetenido = 0;
    LET dSdoTotalLiq = 0;    
    LET dtIvaFechaPag = DATE(1);
    LET dtFechaCuota = DATE(1);
    LET dIntDevengado = 0;
    LET dIvaIntDevengado = 0;
    LET dLineaDisponible = 0;
    LET dPagosVdos = 0;    
    LET cDescBloqueoCta = '';
    LET cDescCausaBloqueoCta = '';
    LET cSitCte = '';
    LET cCausaCte = 0;
    LET cDescSitEspCte = '';
    LET cSitCred = '';
    LET cCausaCred = 0;
    LET cDescSitEspCred = '';
    LET dFactorComision = 0;
    LET dtMesiversario = DATE(1);
    LET dtFechaHoy = DATE(1);
    LET cTipCred = '';
    LET cind_comision = '';
    LET ctran_comision = '';
    LET vRetCs_acum = 0;
    LET vvcodigo_retorno  = '';
    LET vvmensaje_retorno = '';
    LET vRespaldo = 0;

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensajeRet = 'Ocurrio error al consultar los saldos'||' - '||cErrorInfo;
            RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)), NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0), NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0), NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0), NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0), NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
	
    --SET DEBUG FILE TO '/resplogifx/archivoscartera/sp_consulta_saldos_general.out';
    --TRACE ON;
	
    LET cCodRet = '000000';
    LET cMensajeRet  = 'Se realizo la consulta correctamente.';
	
	LET pEmpresa = NVL(TRIM(pEmpresa),'');	
	LET pNumCredito = NVL(TRIM(pNumCredito),'');
	
    IF pEmpresa = '' THEN
        LET pEmpresa = NULL;
        LET cEmpresa= '';
	ELSE
		LET cEmpresa= TRIM(pEmpresa);	
    END IF;
    
    IF pNumCredito = '' THEN
        LET pNumCredito = NULL;
        LET cNumCredito= '';
	ELSE
		LET cNumCredito = TRIM(pNumCredito);
    END IF;

    IF pEmpresa IS NULL AND pNumCredito IS NULL THEN
        LET cCodRet = '000001';
        LET cMensajeRet = 'No hay informacion para realizar la consulta';
	ELSE
        SELECT fecha_hoy 
		INTO dtFechaHoy 
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = pEmpresa;  
		
		IF  pNumCredito matches '68*' then --RQM 10 1155
			Select fecha_proceso  INTO dtFechaHoy --Fecha proceso credito
			FROM bdicred:"informix".sd_maecredanexocrd 
			WHERE empresa = pEmpresa
			AND num_credito = pNumCredito;
		END IF;
		
        SELECT b.cod_prod 
		INTO cTipCred 
		FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tipprod b 
		WHERE a.num_credito = cNumCredito AND a.empresa = pEmpresa AND a.empresa = b.empresa AND a.num_producto=b.abrevia_prod;

        IF cTipCred IS NULL THEN
            SELECT b.cod_prod 
            INTO cTipCred 
            FROM bdicred:"informix".sd_maecred_old a, bdicred:"informix".sd_tipprod b 
            WHERE a.num_credito = cNumCredito AND a.empresa = pEmpresa AND a.empresa = b.empresa AND a.num_producto=b.abrevia_prod;
            IF cTipCred IS NOT NULL THEN
                LET vRespaldo = 1;
            END IF;
        END IF;

        IF cTipCred IS NULL THEN
            SELECT b.cod_prod 
			INTO cTipCred 
			FROM bdicred:"informix".sd_maecredcrd a, bdicred:"informix".sd_tipprod b 
			WHERE a.num_credito = cNumCredito AND a.empresa=pEmpresa AND a.empresa=b.empresa AND a.num_producto=b.abrevia_prod; 
            IF cTipCred IS NULL THEN
                LET cCodRet = '000002';
                LET cMensajeRet= 'No hay informacion para realizar la consulta';
            END IF;		
        END IF;
		
		IF cCodRet = '000000' THEN
            IF cTipCred = 'T' THEN
                IF SUBSTR(cNumCredito,1,2) = "78" THEN		
                    IF vRespaldo = 0 THEN
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred,'', e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito  = cNumCredito AND a.empresa = cEmpresa;
                     ELSE
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred,'', e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred_old a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito  = cNumCredito AND a.empresa = cEmpresa;
                     END IF;
                ELSE
                    IF vRespaldo = 0 THEN
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred, d.num_tarjeta, e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tarjeta d, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND d.num_credito = a.num_credito AND d.status_tar = d.status_tar AND d.tipo_tarjeta = 'T' and d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE a.empresa = empresa AND a.num_credito = num_credito AND tipo_tarjeta = 'T') AND d.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
                    ELSE
                        SELECT a.numcte, a.sucursal, a.plazo, a.fecha_apertura, NVL(a.tasa_interes,0), (NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)), a.id_unidad_prod, a.cod_caract_2, c.cod_tipcred, d.num_tarjeta, e.descripcion 
                        INTO cNumCte, cSucursal, iPlazo, dtFechaOrigen, dTasaInteres, dTasaMoratorios, iIdUnidadProd, cCodCaract2, cCodTipCred, cNumTarjeta, cDescStatusCred 
                        FROM bdicred:"informix".sd_maecred_old a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tarjeta d, bdicred:"informix".sd_tipocartera e 
                        WHERE c.num_producto = a.num_producto AND c.empresa = a.empresa AND d.num_credito = a.num_credito AND d.status_tar = d.status_tar AND d.tipo_tarjeta = 'T' and d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta WHERE a.empresa = empresa AND a.num_credito = num_credito AND tipo_tarjeta = 'T') AND d.empresa = a.empresa AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
                    END IF;
                END IF
                
                IF DBINFO("sqlca.sqlerrd2")  = 0 THEN
                    LET cCodRet = '000003';
                    LET cMensajeRet = 'El numero de credito no existe';
				ELSE
                    IF vRespaldo = 0 THEN                    
                        SELECT prox_fecha_pago, fecha_ult_pago 
                        INTO dtFechaProxPago, dtFechaUltPago 
                        FROM bdicred:"informix".sd_maecredanexo 
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;

                        SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0), NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)), 0 
                        INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible, iPagosRealizados
                        FROM bdicred:"informix".sd_maesdos
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;
                    ELSE
                        SELECT prox_fecha_pago, fecha_ult_pago 
                        INTO dtFechaProxPago, dtFechaUltPago 
                        FROM bdicred:"informix".sd_maecredanexo_old 
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;

                        SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0), NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), (NVL(monto_otorgado,0) - NVL(sdo_cap_insoluto,0) - NVL(sdo_retenido,0)), 0 
                        INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible, iPagosRealizados
                        FROM bdicred:"informix".sd_maesdos_old
                        WHERE num_credito = cNumCredito AND empresa = cEmpresa;
                    END IF;
					
					
                    SELECT SUM(NVL(monto,0))
					INTO dMontoSBC
					FROM bdicheq:"informix".sc_docret
					WHERE empresa= cEmpresa AND cuenta = cNumTarjeta AND siglas = 'SD' AND cancelado = 'T';
					
                    SELECT iva
					INTO dIvaSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal AND empresa  = cEmpresa;
                    
                    EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa,cNumCredito)
					INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
                    
                    IF vvcodigo_retorno <> '000000' THEN
                        LET cCodRet = '000007';
                        LET cMensajeRet= 'Error en calculo de pago minimo.';
					ELSE
                        SELECT NVL(SUM(NVL(interes_debe,0)),0),NVL(SUM(NVL(iva_debe,0)),0),0
						INTO dIntMes,dIvaIntMes,dIvaIntVig
						FROM bdicred:"informix".sd_amortiza_credito
						WHERE empresa = cEmpresa AND num_credito = cNumCredito AND capital_status = 1; 
                        
                        LET dSdoActInt = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
                        LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);
                        
                        {
                            SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0), NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dcmonto_pag,0), 0)),0)
							INTO dComPend, dIvaCom
							FROM bdicred:"informix".sd_detcomi dc, bdicred:"informix".sd_tpcomis tc
							WHERE dc.empresa = cEmpresa AND dc.num_credito = cNumCredito AND dc.estado_com  = 'A' AND dc.empresa = tc.empresa AND dc.cod_comis = tc.cod_comis AND tc.comi_o_seg IN ('1','4');
                        }
                        
                        LET dComPend = 0;
                        LET dIvaCom  = 0;
                        
                        SELECT num_credito
						INTO cNumCreditoAux
						FROM bdicred:"informix".sd_promocion_credito
						WHERE empresa = cEmpresa and num_credito = cNumCredito AND status = 0 GROUP BY num_credito;
						
                        IF DBINFO("sqlca.sqlerrd2") = 1 THEN
                            SELECT sum(NVL(monto_int_iva,0))
							INTO vRetCs_acum
							FROM bdicred:"informix".sd_promocion_credito
							WHERE empresa = cEmpresa AND num_credito = cNumCredito  AND status = 0;
                        END IF;
                        
                        LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) - NVL(vRetCs_acum,0);
                        
                        IF ( dSdoTotalLiq < 0 ) THEN
                            LET dSdoTotalLiq = 0;
                        END IF;
                        
                        SELECT descripcion
						INTO cDescBloqueoCta
						FROM bdicred:"informix".sd_bloqueoscuenta
						WHERE clave = iIdUnidadProd;        
						
                        SELECT causa_bloq
						INTO cDescCausaBloqueoCta
						FROM bdicred:"informix".sd_causa_bloqueo
						WHERE empresa = pEmpresa AND cod_causa = cCodCaract2;
                        
                        LET cSitCte = '';
                        LET cCausaCte = '';
                        LET cDescSitEspCte = '';        
                        LET cSitCred ='';
                        LET cCausaCred ='';
                        LET cDescSitEspCred = '';
                    END IF;
                END IF;
				
            ELIF cTipCred  in ('P','R') THEN
        	
                SELECT a.numcte, a.sucursal,a.plazo,a.fecha_apertura,NVL(a.tasa_interes,0),(NVL(a.tasa_moratorios,0) - NVL(a.tasa_interes,0)),c.cod_tipcred,e.descripcion,c.ind_comision,c.tran_comision INTO cNumCte,cSucursal,iPlazo,dtFechaOrigen,dTasaInteres,dTasaMoratorios,cCodTipCred,cDescStatusCred,cind_comision,ctran_comision FROM bdicred:"informix".sd_maecredcrd a, bdicred:"informix".sd_definicion c, bdicred:"informix".sd_tipocartera e  WHERE c.num_producto = a.num_producto  AND c.empresa      = a.empresa  AND e.status_cred = a.status_cred AND a.num_credito = cNumCredito AND a.empresa = cEmpresa;
        		
                IF DBINFO("sqlca.sqlerrd2")  = 0 THEN
                    LET cCodRet = '000004';
                    LET cMensajeRet = 'El numero de credito no existe';
				ELSE
                    IF cTipCred='R' THEN
                        LET dTasaMoratorios=0;
                    END IF;
                    
                    SELECT prox_fecha_pago, fecha_ult_pago
					INTO dtFechaProxPago, dtFechaUltPago
					FROM bdicred:"informix".sd_maecredanexocrd
					WHERE num_credito = cNumCredito AND empresa = cEmpresa;
					
                    SELECT NVL(sdo_intereses,0), NVL(sdo_retenido,0), 0, NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0), NVL(monto_vencido,0), NVL(mto_venc_trasp,0), NVL(monto_financiado,0),NVL(monto_otorgado,0), NVL(cap_tras_no_venci,0), 0
					INTO dIntDevengado, dSdoRetenido, dIntVig, dCapVig, dSdoActCap, dCapTrans, dCapVdoExig, dMontoFinanciado, dLineaOtorgada, dCapVdoNoExig, dLineaDisponible
					FROM bdicred:"informix".sd_maesdoscrd
					WHERE num_credito = cNumCredito AND empresa = cEmpresa;
                            
                    IF dIntDevengado IS NULL THEN
                        LET dIntDevengado = 0;
                    END IF;
                    
                    SELECT a.iva_fecha_pago, a.fecha_cuota
					INTO dtIvaFechaPag,dtFechaCuota
					FROM bdicred:"informix".sd_amortiza_creditocrd a
					WHERE a.empresa = cEmpresa AND a.num_credito = cNumCredito AND a.capital_status = "3";
                    
                    SELECT iva
					INTO dIvaSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal AND empresa  = cEmpresa;
			
                    EXECUTE PROCEDURE bdicred:"informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInteres,dIvaSuc,dtFechaHoy, dtIvaFechaPag,dtFechaOrigen,dtFechaCuota,dIntDevengado)
					INTO cCodRet,dIvaIntDevengado,cMensajeRet;
                    
                    IF cCodRet <> "000000" THEN
                        LET cCodRet = '000005';
                        LET cMensajeRet = 'Ocurrio un error al realizar calculo';
					ELSE
                        SELECT COUNT(num_credito)
						INTO iPagosRealizados
						FROM bdicred:"informix".sd_amortiza_creditocrd
						WHERE empresa = pEmpresa AND num_credito = cNumCredito AND capital_status = '5';        
                    
                        EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa,cNumCredito)
						INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
                        
                        LET dSdoActInt = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
                        LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);        
                        
                        IF vvcodigo_retorno <> '000000' THEN
                            LET cCodRet= '000008';
                            LET cMensajeRet= 'Error en calculo de pago minimo.';
						ELSE
                            {
                                SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0), NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
								INTO dComPend, dIvaCom
								FROM bdicred:"informix".sd_detcomi dc, bdicred:"informix".sd_tpcomis tc
								WHERE dc.empresa = cEmpresa AND dc.num_credito = cNumCredito AND dc.estado_com  = 'A' AND dc.empresa = tc.empresa AND dc.cod_comis = tc.cod_comis AND tc.comi_o_seg IN ('1','4'); 
                            }
                            
                            LET dComPend = 0;
                            LET dIvaCom  = 0;
                            
                            EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaOrigen, 1)
							INTO dtMesiversario;
                            
                            IF dtFechaHoy < dtMesiversario and cTipCred = 'P' and cind_comision = '1' THEN
                            
                                SELECT apli_factor/100
								INTO dFactorComision
								FROM bdicred:"informix".sd_tpcomis
								WHERE cod_comis=ctran_comision;
								
                                IF dFactorComision IS NULL THEN
                                    LET cCodRet = '000006';
                                    LET cMensajeRet = 'No se encontro el factor de la comision';
								ELSE
                                    IF dSdoActCap<=0 THEN
                                        LET dComPend = dSdoActCap * dFactorComision;
                                    ELSE
                                        LET dComPend = dLineaOtorgada * dFactorComision;
                                    END IF;        
                                    LET dIvaCom = dComPend * dIvaSuc;
                                END IF;                      
                            END IF;
                            IF cCodRet = '000000' THEN
                                LET dSdoTotalLiq = NVL(dSdoActCap,0) + NVL(dIntVdo,0) + NVL(dIvaIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0) + NVL(dSdoRetenido,0) + NVL(dComPend,0) + NVL(dIvaCom,0) + NVL(dIntDevengado,0) + NVL(dIvaIntDevengado,0) + NVL(dIntVig,0) + NVL(dIvaIntVig,0);
                                
                                IF ( dSdoTotalLiq < 0 ) THEN
                                    LET dSdoTotalLiq = 0;
                                END IF;
                                
                                LET cSitCte = '';
                                LET cCausaCte = '';
                                LET cDescSitEspCte = '';        
                                LET cSitCred ='';
                                LET cCausaCred ='';
                                LET cDescSitEspCred = '';
							END IF;
                        END IF;        
                    END IF;
                END IF;        
            END IF;
		END IF;
    END IF;    

   RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)), NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0), NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0), NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0), NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0), NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''); 

END
END PROCEDURE

DOCUMENT
'Se realiza procedimiento para obtener los saldos ',
'generales del credito',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 22/06/2009',
'FECHA MODIFICACION: 26/12/2018',
'Modificacion : Coppel',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_depura_sd_indicador_cred_hist(pFecha DATE)
--execute procedure sp_depura_sd_indicador_cred_hist(mdy('04','25','2013'));
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);    -- mensaje

DEFINE cCodRet      	CHAR(6); 
DEFINE cMensaje     	CHAR(150); 
DEFINE vNumCred     	VARCHAR(20,1);
DEFINE vNumCredAux  	VARCHAR(20,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE Error_Info   	VARCHAR(80);
--DEFINE pFecha 	DATE;
DEFINE vFecha 			DATE;
DEFINE dFechaAProcesar 	DATE;
DEFINE vnum_credito 	CHAR(20);
DEFINE vfecha_corte 	DATE;
DEFINE cFechaDepura 	CHAR(10);
DEFINE iDepura			INTEGER;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso					CHAR(1);
DEFINE iCuentasaDepurar					INTEGER;
DEFINE iCount_restantes					INTEGER;
DEFINE iCount_sd_indicador_cred_hist	INTEGER;

DEFINE cProceso			CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE P_MENSAJE    	VARCHAR(150);
DEFINE v_sql        CHAR(1200);
DEFINE v_sql1       CHAR(500);
DEFINE v_sql2       CHAR(500);
DEFINE vRuta		CHAR(50);
DEFINE dFechaIni	DATE;
DEFINE dFechaFin	DATE;
DEFINE dFechaEmision DATE;
DEFINE cReinicio	CHAR(02);
DEFINE vNumCredito	CHAR(20);
DEFINE vFechaDelete	DATE;

LET vFechaDelete	= '';
LET vNumCredito		= '';
LET v_sql       	= "";
LET v_sql1      	= "";
LET v_sql2      	= "";
LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
--LET pFecha 	= DATE(1);
LET vFecha 			= DATE(1);
LET dFechaAProcesar = DATE(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasaDepurar				= 0;
LET iCount_restantes				= 0;
LET iCount_sd_indicador_cred_hist	= 0;
LET cProceso		= '0004';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= '';
LET vRuta      		= '/RESPALDOSNEW/'; --"/resplogifx/archivoscartera/";
LET dFechaIni	= DATE(1);
LET dFechaFin	= DATE(1);
LET dFechaEmision = DATE(1);
LET cReinicio 		= '';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	';		
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;
            RETURN cCodRet,cMensaje;
		END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/Ulises/depura/sp_depura_tablas.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
	-- ULTIMA FECHA DEPURACION CUENTAS CANCELADAS  FORMATO --> 12/31/2018
    SELECT valor
	INTO vFecha
	FROM bdicred:sd_param
	WHERE cod_param = '117';

    IF vFecha = '' OR vFecha IS NULL THEN
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '117', 'ULTIMA FECHA DEPURACION DE TABLAS', '12/31/2018', user, TODAY);
			
		LET vFecha = mdy('12','31','2018');
	END IF;	
	
	IF pFecha = date(1) THEN
		LET pFecha = MDY(MONTH(today),20,YEAR(today));
	ELSE
		LET pFecha = MDY(MONTH(pFecha),20,YEAR(pFecha));
		IF  pFecha > MDY(MONTH(vFecha),20,YEAR(vFecha)) THEN
		   LET P_MENSAJE  = 'Excediste fecha a depurar';
		   LET P_COD_RET = '000001';
		   CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, P_COD_RET, P_MENSAJE, '02') RETURNING P_COD_RET;
		   RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;
	
	-- PARAMETRO DE HORAS A PROCESAR CUENTAS CANCELADAS      VALOR --> 5	
	SELECT valor::SMALLINT
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '118';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO "informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '118', 'PARAMETRO DE HORAS A PROCESAR DEPURACION SD_INDICADOR_CRED_HIST', '5', user, TODAY);
		
		LET sHorasProceso = '5';
	END IF;
	
	--Se obtiene la ruta para descargar archivos.
/*	SELECT valor::CHAR INTO vRuta
	FROM bdicred:sd_param 
	where cod_param = '033';
*/		
	SELECT valor
      INTO cReinicio
      FROM bdicred:"informix".sd_param
     WHERE empresa = '001' AND cod_param = '119';
	 
	 -- Si no existe el parametro 063 insertar informacion.
 
	 IF cReinicio IS NULL THEN
		LET cReinicio = '0';
		BEGIN WORK;
		INSERT INTO bdicred:"informix".sd_param(empresa,cod_param,descripcion,valor,user_insert,fecha_insert)
		VALUES ('001','119','Control reinicio descarga de tablas',cReinicio,USER,today);
		COMMIT WORK;
	
	ELIF cReinicio = '' THEN
		LET cReinicio = '0';
		BEGIN WORK;
		UPDATE bdicred:"informix".sd_param SET valor = cReinicio
		WHERE cod_param = '119';
		COMMIT WORK;
	END IF;
	
	-- Se Obtiene rango de fecha por mes
	LET dFechaIni = MDY(MONTH(pFecha),1,YEAR(pFecha));
	LET dFechaFin = (dFechaIni + 1 UNITS MONTH) - 1 UNITS DAY;

	If cReinicio = '0' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicio de descargas de tablas operativas', '02') RETURNING P_COD_RET;
		-- Descargar de informaciÃ³n sd_indicador_cred_hist
		LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';

        LET v_sql1 = ' echo "UNLOAD TO '|| trim(vRuta) ||'sd_indicador_cred_hist_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from sd_indicador_cred_hist where empresa = "001" AND fecha >= '''||dFechaIni||''' and fecha <= '''||dFechaFin||'''; " > '|| trim(vRuta) ||'queryIndicadorCred.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| trim(vRuta) ||"queryIndicadorCred.sql";
        system v_sql;
		
		LET cReinicio = '1';
		BEGIN WORK;
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='119';
		COMMIT WORK;
		
		LET v_sql = '';
		LET v_sql = "gzip " || trim(vRuta) ||'sd_indicador_cred_hist_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
		SYSTEM v_sql;
		
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_indicador_cred_hist', '02') RETURNING P_COD_RET;
	end if;

--RETURN cCodRet,P_MENSAJE;	
		
	-- INICIA LA DEPURACION DE TABLAS OPERATIVAS
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia depuracion de tablas operativas', '02') RETURNING P_COD_RET;
	
	FOREACH WITH HOLD
		select num_credito, fecha INTO vNumCredito, vFechaDelete from bdicred:sd_indicador_cred_hist where empresa = '001' and fecha >= dFechaIni and fecha <= dFechaFin
		
		LET iCuentasaDepurar = iCuentasaDepurar + 1;
		
		BEGIN WORK;
			delete from bdicred:sd_indicador_cred_hist where empresa = '001' and fecha = vFechaDelete and num_credito = vNumCredito;
			--delete from bdicred:sd_encabezado_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
        COMMIT WORK;
	END FOREACH;
		
		 SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			LET cTerminaProceso = '1';
			--EXIT FOREACH;
		END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina depuracion de tablas operativas', '02') RETURNING P_COD_RET;
	
	LET cReinicio = '0';
		
	update bdicred:"informix".sd_param
	set valor = cReinicio
	where empresa = '001' AND cod_param='119';
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_indicador_cred_hist;
	
	--CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	LET cMensaje = 'TOTAL Cuentas depuradas : ' ||iCuentasaDepurar;
	CALL "informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

	LET P_MENSAJE = 'El proceso DEPURA TABLA sd_indicador_cred_hist termino exitosamente. Cuentas procesadas ' || iCuentasaDepurar;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;