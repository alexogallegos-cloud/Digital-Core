CREATE PROCEDURE "informix".sp_procesar_indicadores()
RETURNING CHAR(6), CHAR(80)
    
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);
	
	DEFINE dCapvig1			DECIMAL(14,2);
	DEFINE dCapvig2			DECIMAL(14,2);
	DEFINE dCapvig3			DECIMAL(14,2);
	DEFINE dCapvig4			DECIMAL(14,2);
	DEFINE dCapvig5			DECIMAL(14,2);
	DEFINE dCapvig6			DECIMAL(14,2);
	DEFINE dCapvig7			DECIMAL(14,2);
	DEFINE dCapvig8			DECIMAL(14,2);
	DEFINE dCapvig9			DECIMAL(14,2);
	DEFINE dCapvig10		DECIMAL(14,2);
	DEFINE dCapvig11		DECIMAL(14,2);
	DEFINE dCapvig12		DECIMAL(14,2);
	DEFINE dCapvig13		DECIMAL(14,2);
	DEFINE dCapvig14		DECIMAL(14,2);
	DEFINE dCapvig15		DECIMAL(14,2);
	DEFINE dCapvig16		DECIMAL(14,2);
	DEFINE dCapvig17		DECIMAL(14,2);
	DEFINE dCapvig18		DECIMAL(14,2);
	DEFINE dCapvig19		DECIMAL(14,2);
	DEFINE dCapvig20		DECIMAL(14,2);
	DEFINE dCapvig21		DECIMAL(14,2);
	DEFINE dCapvig22		DECIMAL(14,2);
	DEFINE dCapvig23		DECIMAL(14,2);
	DEFINE dCapvig24		DECIMAL(14,2);
	DEFINE dCapvig25		DECIMAL(14,2);
	DEFINE dCapvig26		DECIMAL(14,2);
	DEFINE dCapvig27		DECIMAL(14,2);
	DEFINE dCapvig28		DECIMAL(14,2);
	DEFINE dCapvig29		DECIMAL(14,2);
	DEFINE dCapvig30		DECIMAL(14,2);
	DEFINE dCapvig31		DECIMAL(14,2);
	DEFINE cFecha_Hoy		DATE;
	DEFINE cPrimDiaHabil	DATE;
	DEFINE cAnioMes			CHAR(6);
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE cCuenta			CHAR(20);
	DEFINE dSdoMaximoMes	DECIMAL(14,2);
	DEFINE dSdoMaximoAnt	DECIMAL(14,2);
	DEFINE sDia				SMALLINT;
	DEFINE dMontoCapvig		DECIMAL(14,2);
	DEFINE iDiaHabilAnt		SMALLINT;
	DEFINE dSaldoPromedio	DECIMAL(14,2);
	DEFINE iUltCheque		INTEGER;
	DEFINE dtFecUltPagoInt	DATE;
	DEFINE dAcumSBC			DECIMAL(14,2);
	DEFINE dAcumRemesa		DECIMAL(14,2);
	DEFINE dIntAcum			DECIMAL(14,2);
	DEFINE dISRAcum			DECIMAL(14,2);
	
	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";
	
	LET dCapvig1			= 0.0;
	LET dCapvig2			= 0.0;
	LET dCapvig3			= 0.0;
	LET dCapvig4			= 0.0;
	LET dCapvig5			= 0.0;
	LET dCapvig6			= 0.0;
	LET dCapvig7			= 0.0;
	LET dCapvig8			= 0.0;
	LET dCapvig9			= 0.0;
	LET dCapvig10			= 0.0;
	LET dCapvig11			= 0.0;
	LET dCapvig12			= 0.0;
	LET dCapvig13			= 0.0;
	LET dCapvig14			= 0.0;
	LET dCapvig15			= 0.0;
	LET dCapvig16			= 0.0;
	LET dCapvig17			= 0.0;
	LET dCapvig18			= 0.0;
	LET dCapvig19			= 0.0;
	LET dCapvig20			= 0.0;
	LET dCapvig21			= 0.0;
	LET dCapvig22			= 0.0;
	LET dCapvig23			= 0.0;
	LET dCapvig24			= 0.0;
	LET dCapvig25			= 0.0;
	LET dCapvig26			= 0.0;
	LET dCapvig27			= 0.0;
	LET dCapvig28			= 0.0;
	LET dCapvig29			= 0.0;
	LET dCapvig30			= 0.0;
	LET dCapvig31			= 0.0;
	LET cFecha_Hoy			= DATE(1);
	LET cPrimDiaHabil		= DATE(1);
	LET cAnioMes			= "";
	LET cAnioMesAnte		= "";
	LET cCuenta				= "";
	LET dSdoMaximoMes		= 0.0;
	LET dSdoMaximoAnt		= 0.0;
	LET sDia				= 0;
	LET dMontoCapvig		= 0;
	LET iDiaHabilAnt		= 0;
	LET dSaldoPromedio		= 0.0;
	LET iUltCheque			= 0;
	LET dtFecUltPagoInt		= DATE(1);
	LET dAcumSBC			= 0.0;
	LET dAcumRemesa			= 0.0;
	LET dIntAcum			= 0.0;
	LET dISRAcum			= 0.0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
		END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--- SET DEBUG FILE TO '/informix/moha/sp_procesar_indicadores.out';
	--- TRACE ON;
		
    /* ###################################################################################################################################################################################################
	-- // OBTIENE EL AÑO Y EL MES ACTUAL
	SELECT fecha_hoy, 
	       pri_hab_mes, 
		   YEAR(fecha_hoy) || LPAD(MONTH(fecha_hoy),2,"0"),
           --- YEAR(fecha_hoy - 1 units MONTH) || LPAD(MONTH(fecha_hoy - 1 units MONTH),2,"0"),
		   DAY(fecha_ant)
	  INTO cFecha_Hoy, 
	       cPrimDiaHabil, 
	  	   cAnioMes, 
		   --- cAnioMesAnte, 
		   iDiaHabilAnt
	  FROM "informix".sc_fechas
	 WHERE empresa = "001";
    
	LET sDia = DAY(cFecha_Hoy);
	
	-- // VALIDA SI NO ES EL PRIMER DIA HABIL DEL MES
	IF cFecha_Hoy <> cPrimDiaHabil THEN
		FOREACH   ---{+INDEX(sc_sdodiarioc isdodiario)}
			SELECT i.cuenta, i.saldo_maximo_mes,
                   capvig1,capvig2,capvig3,capvig4,capvig5,capvig6,capvig7,capvig8,capvig9,capvig10,capvig11,capvig12,
                   capvig13,capvig14,capvig15,capvig16,capvig17,capvig18,capvig19,capvig20,capvig21,capvig22,capvig23,
                   capvig24,capvig25,capvig26,capvig27,capvig28,capvig29,capvig30,capvig31
			  INTO cCuenta, dSdoMaximoMes,
                   dCapvig1,dCapvig2,dCapvig3,dCapvig4,dCapvig5,dCapvig6,dCapvig7,dCapvig8,dCapvig9,dCapvig10,dCapvig11,dCapvig12,
                   dCapvig13,dCapvig14,dCapvig15,dCapvig16,dCapvig17,dCapvig18,dCapvig19,dCapvig20,dCapvig21,dCapvig22,dCapvig23,
                   dCapvig24,dCapvig25,dCapvig26,dCapvig27,dCapvig28,dCapvig29,dCapvig30,dCapvig31
			  FROM "informix".sc_indicadores i, 
                   "informix".sc_sdodiarioc sd
			 WHERE sd.cuenta = i.cuenta
			   AND sd.aniomes = cAnioMes
			   AND i.anio_mes = sd.aniomes
            
			-- // OBTIENE EL MONTO DE SALDO DEL DIA QUE VA CORRIENDO
			LET dMontoCapvig = DECODE(iDiaHabilAnt,1,dCapvig1,2,dCapvig2,3,dCapvig3,4,dCapvig4,5,dCapvig5,6,dCapvig6,7,dCapvig7,8,dCapvig8,9,dCapvig9,10,dCapvig10,
                                                  11,dCapvig11,12,dCapvig12,13,dCapvig13,14,dCapvig14,15,dCapvig15,16,dCapvig16,17,dCapvig17,18,dCapvig18,19,dCapvig19,20,dCapvig20,
                                                  21,dCapvig21,22,dCapvig22,23,dCapvig23,24,dCapvig24,25,dCapvig25,26,dCapvig26,27,dCapvig27,28,dCapvig28,29,dCapvig29,30,dCapvig30,31,dCapvig31);
			
			-- // VALIDA QUE SI EL SALDO DEL DIA ES MAYOR AL SALDO MAXIMO QUE SE VA ARRASTRANDO EN EL MES PARA ACTUALIZARLO
			IF dMontoCapvig > dSdoMaximoMes THEN
				UPDATE "informix".sc_indicadores 
                   SET saldo_maximo_mes = dMontoCapvig 
				 WHERE anio_mes = cAnioMes 
                   AND cuenta = cCuenta;
			END IF
		END FOREACH
	END IF
    ################################################################################################################################################################################################### */
    
	RETURN cCodRet, cDescRet;
	
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso diario para actualizar los saldos promedios y saldos maximos en el mes ademas de actualizar otros campos',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Junio 2014';

CREATE PROCEDURE "informix".sp_validahorariopitdc(pSucursal char(4))

 RETURNING
 CHAR(5), CHAR(5), CHAR(5);

--DEFINICION DE VARIABLES
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet1     CHAR (5);
	DEFINE cCodRet2     CHAR (5);
	DEFINE cCodRet3     CHAR (5);
    DEFINE cHoraActual  CHAR (5);
    DEFINE cHoraAParam  CHAR (5);

--INICIALIZACION DE VARIABLES
    LET iSqlErr      = 0;
    LET cCodRet1     = "00000";
	LET cCodRet2     = "00000";
	LET cCodRet3     = "00003";
    LET cHoraActual  = "";
	LET cHoraAParam  = "";

    -- SET DEBUG FILE TO "/tmp/sp_ValidaHorarioPITDC.out";
    -- TRACE ON;

 BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
			RETURN cCodret1, cCodret2, cCodret3;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
		
    SELECT (CURRENT HOUR TO MINUTE), NVL(valor,'')
    INTO cHoraActual, cHoraAParam
    FROM bdicheq:sc_param
    WHERE codparam = "HORAPITDC";
		
	IF cHoraActual = "" OR cHoraActual IS NULL OR cHoraAParam = "" OR cHoraAParam IS NULL THEN
	    LET cCodRet2 = "00001";
	ELSE
	    IF CAST(SUBSTR(cHoraActual,1,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN
			IF pSucursal not in ('5011','5003') THEN
				LET cCodRet2 = "00002";  --Esta fuera del horario
			ELSE
				LET cCodRet3 = "00000"; -- BPI Y BEX despues de las 23:00
			END IF;
		ELSE
			IF CAST(SUBSTR(cHoraActual,1,2)  AS INTEGER) = CAST(SUBSTR(cHoraAParam,1,2) AS INTEGER) THEN	    					
				IF CAST(SUBSTR(cHoraActual,4,2) AS INTEGER) > CAST(SUBSTR(cHoraAParam,4,2) AS INTEGER) THEN
					IF pSucursal not in ('5011','5003') THEN
						LET cCodRet2 = "00002";  --Esta fuera del horario
					ELSE
						LET cCodRet3 = "00000"; -- BPI Y BEX despues de las 22:00	
					END IF;
				END IF;
			END IF;	
		END IF;	
	END IF;

    RETURN cCodret1, cCodret2, cCodret3;

 END;
END PROCEDURE
DOCUMENT
    'AUTOR : Jaime Gonzalez',
    'DESCRIPCION: Se encarga de validar si es un horario permitido para las operaciones de PITDC',
    'EJECUTADO O LLAMADO POR: abono_ref',
    'BD    : bdicheq';

CREATE PROCEDURE "informix".sp_validacteportnom_bpi( pEmpresa CHAR(3), pNumCte CHAR(20), pCuenta CHAR(20) ) 
RETURNING CHAR(5), CHAR(100);
    
    DEFINE intSqlErr    INTEGER;
    DEFINE intIsamErr   INTEGER;
    DEFINE chrDescErr   CHAR(100);
    DEFINE chrCodRet1   CHAR(5);
    DEFINE chrCodRet2   CHAR(5);
    DEFINE chrCodRet3   CHAR(100);
    DEFINE intExisteCte SMALLINT;
    DEFINE intExisteCta SMALLINT;
    DEFINE iActivo      SMALLINT;

    LET intSqlErr    = 0;
    LET intIsamErr   = 0;
    LET chrDescErr   = '';
    LET chrCodRet1   = '000';
    LET chrCodRet2   = '';
    LET chrCodRet3   = 'CLIENTE / CUENTA VALIDOS';
    LET intExisteCte = 0;
    LET intExisteCta = 0;
    LET iActivo      = 0;

    BEGIN
    
    ON EXCEPTION SET intSqlErr, intIsamErr, chrDescErr
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validacteportnom_bpi.err";
        --- TRACE ON;
        IF intSqlErr <> 0 THEN
            LET chrCodRet1 = intSqlErr;
            LET chrCodRet2 = intIsamErr;
            LET chrCodRet3 = chrDescErr;
            RETURN chrCodRet1, TRIM(chrCodRet3);
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validacteportnom_bpi.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' OR pEmpresa = ' ' ) OR
       ( pNumCte  is null OR pNumCte  = '' OR pNumCte  = ' ' ) OR
       ( pCuenta  is null OR pCuenta  = '' OR pCuenta  = ' ' ) THEN
        LET chrCodRet1 = '110';
        LET chrCodRet3 = 'PARAMETROS DE ENTRADA INCORRECTOS';
        RETURN chrCodRet1, TRIM(chrCodRet3);
    END IF;
    
    SELECT activo
      INTO iActivo
      FROM sc_producportab
     WHERE producto = '2900';
     
    IF iActivo = 0 THEN
        LET chrCodRet1 = '014';
        LET chrCodRet3 = 'PRODUCTO NO PERMITE PORTABILIDAD';
        RETURN chrCodRet1, TRIM(chrCodRet3);
    END IF;
    
    SELECT COUNT(*)
      INTO intExisteCte
      FROM bdinteg:si_cliente
     WHERE numcte = pNumCte
       AND tipo_cliente = '1';
       
    IF intExisteCte > 0 THEN
        IF LENGTH(pCuenta) = 11 THEN
            SELECT COUNT(*)
              INTO intExisteCta
              FROM sc_maechq
             WHERE cuenta = pCuenta
               AND num_cte = pNumCte
               AND status_cta IN('1','3','4','5');
        ELIF LENGTH(pCuenta) = 16 THEN
            SELECT COUNT(*)
              INTO intExisteCta
              FROM sc_tarjeta trj,
                   sc_maechq mae
             WHERE trj.num_tarjeta = pCuenta
               AND mae.num_cte = pNumCte
               AND mae.cuenta = trj.cuenta
               AND mae.num_cte = trj.numcte
               AND mae.status_cta IN('1','3','4','5');
        ELIF LENGTH(pCuenta) = 18 THEN
            SELECT COUNT(*)
              INTO intExisteCta
              FROM sc_maechq
             WHERE cuenta_clabe = pCuenta
               AND num_cte = pNumCte
               AND status_cta IN('1','3','4','5');
        ELSE
            LET chrCodRet1 = '100';
            LET chrCodRet3 = 'CUENTA NO EXISTE';
            RETURN chrCodRet1, TRIM(chrCodRet3);
        END IF;
        
        IF intExisteCta = 0 THEN
            LET chrCodRet1 = '200';
            LET chrCodRet3 = 'CUENTA NO EXISTE / CANCELADA';
            RETURN chrCodRet1, TRIM(chrCodRet3);
        END IF;
    ELSE
        LET chrCodRet1 = '104';
        LET chrCodRet3 = 'CLIENTE NO EXISTE / TIPO DE CLIENTE INVALIDO';
        RETURN chrCodRet1, TRIM(chrCodRet3);
    END IF;
    
    RETURN chrCodRet1, TRIM(chrCodRet3);
    
    END;
    
END PROCEDURE;