CREATE PROCEDURE "informix".sp_primdiames_indicadores_pba()
RETURNING
	CHAR(6),
	CHAR(80)

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
    
	--SET DEBUG FILE TO '/informix/moha/sp_primdiames_indicadores.out';
	--TRACE ON;
		
	-- OBTIENE EL AÑO Y EL MES ACTUAL
	SELECT fecha_hoy, pri_hab_mes, YEAR(fecha_hoy) || LPAD(MONTH(fecha_hoy),2,"0"), YEAR(fecha_hoy - 1 units MONTH) || LPAD(MONTH(fecha_hoy - 1 units MONTH),2,"0")
	,DAY(fecha_ant)
	INTO cFecha_Hoy, cPrimDiaHabil, cAnioMes, cAnioMesAnte, iDiaHabilAnt
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	LET sDia = DAY(cFecha_Hoy);
	
	FOREACH {+INDEX(sc_sdodiarioc isdodiario)}
		SELECT i.cuenta, i.saldo_maximo_mes, DECODE(sd.diacum,0,0,(sd.capvigacum / sd.diacum))::DECIMAL(14,2) AS sdo_prom,
		capvig1,capvig2,capvig3,capvig4,capvig5,capvig6,capvig7,capvig8,capvig9,capvig10,capvig11,capvig12,
		capvig13,capvig14,capvig15,capvig16,capvig17,capvig18,capvig19,capvig20,capvig21,capvig22,capvig23,
		capvig24,capvig25,capvig26,capvig27,capvig28,capvig29,capvig30,capvig31
		INTO cCuenta, dSdoMaximoAnt, dSaldoPromedio,
		dCapvig1,dCapvig2,dCapvig3,dCapvig4,dCapvig5,dCapvig6,dCapvig7,dCapvig8,dCapvig9,dCapvig10,dCapvig11,dCapvig12,
		dCapvig13,dCapvig14,dCapvig15,dCapvig16,dCapvig17,dCapvig18,dCapvig19,dCapvig20,dCapvig21,dCapvig22,dCapvig23,
		dCapvig24,dCapvig25,dCapvig26,dCapvig27,dCapvig28,dCapvig29,dCapvig30,dCapvig31
		FROM "informix".sc_indicadores i, "informix".sc_sdodiarioc sd
		WHERE sd.aniomes = cAnioMesAnte
		AND i.anio_mes = sd.aniomes
		AND i.cuenta = sd.cuenta
				
		-- OBTIENE EL MONTO DE SALDO DEL DIA QUE VA CORRIENDO
		LET dMontoCapvig = DECODE(iDiaHabilAnt,1,dCapvig1,2,dCapvig2,3,dCapvig3,4,dCapvig4,5,dCapvig5,6,dCapvig6,7,dCapvig7,8,dCapvig8,9,dCapvig9,10,dCapvig10,11,dCapvig11,12,dCapvig12,13,dCapvig13,14,dCapvig14,15,dCapvig15,16,dCapvig16,17,dCapvig17,18,dCapvig18,19,dCapvig19,20,dCapvig20,21,dCapvig21,22,dCapvig22,23,dCapvig23,24,dCapvig24,25,dCapvig25,26,dCapvig26,27,dCapvig27,28 ,dCapvig28,29,dCapvig29,30,dCapvig30,31,dCapvig31);
		
		-- VALIDA QUE SI EL SALDO DEL DIA ES MAYOR AL SALDO MAXIMO QUE SE VA ARRASTRANDO EN EL MES PARA ACTUALIZARLO
		IF dMontoCapvig > dSdoMaximoAnt THEN
			UPDATE  "informix".sc_indicadores SET saldo_maximo_mes = dMontoCapvig 
			WHERE anio_mes = cAnioMesAnte AND cuenta = cCuenta;
			
			UPDATE  "informix".sc_indicadores SET saldo_maximo_ant = dMontoCapvig 
			WHERE anio_mes = cAnioMes AND cuenta = cCuenta;
			
		ELSE
			UPDATE  "informix".sc_indicadores SET saldo_maximo_ant = dSdoMaximoAnt 
			WHERE anio_mes = cAnioMes AND cuenta = cCuenta;			
		END IF
	
		SELECT ult_chq, ultpagoint
		INTO iUltCheque, dtFecUltPagoInt
		FROM "informix".sc_maechq
		WHERE empresa = "001"
		AND cuenta = cCuenta;
		
		-- CONSULTA LOS INDICADORES YA EXISTENTES DE LA TABLA MAESTRA COMPLEMENTARIA DE CHEQUES
		SELECT acum_sbc, acum_rem, int_acum, isr_acum
		INTO dAcumSBC, dAcumRemesa, dIntAcum, dISRAcum
		FROM "informix".sc_maenoc
		WHERE empresa = "001"
		AND cuenta = cCuenta;
		
		UPDATE "informix".sc_indicadores 
		SET saldo_promedio = dSaldoPromedio,
		ultimo_cheque = iUltCheque,
		acum_sbc = dAcumSBC, 
		acum_remesas = dAcumRemesa, 
		interes_acum = dIntAcum, 
		isr_acum = dISRAcum, 
		fec_ult_pago_int = dtFecUltPagoInt
		WHERE anio_mes = cAnioMesAnte AND cuenta = cCuenta;

	END FOREACH

	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que corre el primer dia del mes que actualiza los saldos promedios en el mes anterior',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Junio 2014';

CREATE PROCEDURE "informix".sp_obt_comprobantes_spei (pCuenta CHAR (20), pdFechaDesde DATE, pdFechaHasta DATE,pSalto INT)
RETURNING	CHAR (5) as codret, 
			CHAR (4) as tipotransacc, 
			DATE as fechaApl, 
			CHAR (20) as cuenta, 
			CHAR(100) as conceptoPago, 
			CHAR(20) AS ImporteAbono, 
			CHAR(20) AS ImporteCargo, 
			CHAR(1) AS banderaInhabil,
			CHAR (40) AS RefCveRastreo,
			CHAR(18) AS CLABE,
			INT AS TotalRenglones;

	--// ***************************************************************************
	--//sp_obt_comprobantes_spei
	--//Version:			 	1.0
	--//Objetivo:			Obtener los comprobantes SPEI.
	--//Autor:	Moises Eduardo Soriano Guerrero
	--//Fecha: 20 Agosto 2015
	--// ***************************************************************************

DEFINE v_sCodRet CHAR(5);
DEFINE intcodret        INTEGER;
DEFINE vcTipoTransacc CHAR(4);
DEFINE vdFechaAplicacion DATE;
DEFINE vcCuenta CHAR(20);
DEFINE vcReferencia CHAR(40);
DEFINE vcConceptoPago CHAR (100);
DEFINE vdImporteAux DECIMAL (14,2);
DEFINE vdImporteAbono CHAR(20);
DEFINE vdImporteCargo CHAR(20);
DEFINE vcNumCte CHAR (20);
DEFINE vcHora DATETIME HOUR TO SECOND;
DEFINE vcCtaClabe CHAR(18);
DEFINE vTotalRegistros  INT;
DEFINE vTotalRegistrosHis INT;
DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;	
DEFINE vcBanderaInhabil CHAR(1);


LET vcTipoTransacc = "";
LET vdFechaAplicacion = "";
LET vcCuenta = "";
LET vcReferencia = "";
LET vcConceptoPago ="";
LET vdImporteAux = 0;
LET vdImporteAbono = "";
LET vdImporteCargo = "";
LET vcNumCte = "";
LET v_sCodRet = '00000';
LET vcHora = "";
LET vcCtaClabe = "";
LET vTotalRegistros = 0;
LET vTotalRegistrosHis = 0;
LET vcBanderaInhabil = "0";

BEGIN
	ON EXCEPTION SET intcodret
		IF intcodret <> 0 THEN
			LET v_sCodRet  = intcodret;
			RETURN v_sCodRet, vcTipoTransacc, vdFechaAplicacion, vcCuenta, vcConceptoPago, vdImporteAbono, vdImporteCargo,vcBanderaInhabil,vcReferencia,vcCtaClabe,vTotalRegistros;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/sp_obt_comprobantes_spei.out"; 
	--TRACE ON;

	SELECT num_cte INTO vcNumCte FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta;
	IF NVL(vcNumCte,"") = "" THEN
		LET v_sCodRet= "00001";
		RETURN v_sCodRet, vcTipoTransacc, vdFechaAplicacion, vcCuenta, vcConceptoPago, vdImporteAbono, vdImporteCargo,vcBanderaInhabil,vcReferencia,vcCtaClabe,vTotalRegistros;
	END IF;
	
	SELECT  NVL(COUNT(num_serial),0)
			INTO vTotalRegistros
			FROM bdicheq:"informix".sc_movdia 
			WHERE cuenta = pCuenta 
			AND fech_alt BETWEEN pdFechaDesde AND pdFechaHasta 
			AND transacc IN ('0273','0274');

	SELECT  NVL(COUNT(num_serial),0)
			INTO vTotalRegistrosHis
			FROM bdicheq:"informix".sc_movhis
			WHERE cuenta = pCuenta 
			AND fech_alt BETWEEN pdFechaDesde AND pdFechaHasta 
			AND transacc IN ('0273','0274');
	
	LET vTotalRegistros = vTotalRegistros + vTotalRegistrosHis;
	
	FOREACH
		
		SELECT SKIP pSalto FIRST 10 transacc,fech_alt,cuenta,referencia,monto_tot,fech_hor  
			INTO vcTipoTransacc,vdFechaAplicacion,vcCuenta,vcReferencia,vdImporteAux,vcHora 
		FROM bdicheq:"informix".sc_movdia 
		WHERE cuenta = pCuenta 
		AND fech_alt BETWEEN pdFechaDesde AND pdFechaHasta 
		AND transacc IN ('0273','0274')
			UNION ALL
		SELECT transacc,fech_alt,cuenta,referencia,monto_tot,fech_hor
		FROM bdicheq:"informix".sc_movhis
		WHERE cuenta = pCuenta 
		AND fech_alt BETWEEN pdFechaDesde AND pdFechaHasta 
		AND transacc IN ('0273','0274')
		ORDER BY fech_alt
		
		LET v_FechaHoraInsert = ( YEAR(vdFechaAplicacion) || '-' || MONTH(vdFechaAplicacion) || '-' || DAY(vdFechaAplicacion) || ' ' || vcHora)::DATETIME YEAR TO FRACTION;
		IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN	
			LET vcBanderaInhabil = "1";
		END IF;
		
		SELECT cuenta_clabe 
		INTO vcCtaClabe 
		FROM bdicheq:"informix".sc_maechq 
		WHERE cuenta = vcCuenta;
		
		IF (vcTipoTransacc IS NOT NULL AND vcTipoTransacc = '0273') THEN
			LET vcConceptoPago = TRIM(vcReferencia) || ", Abono SPEI" ;
			LET vdImporteAbono = vdImporteAux;
			LET vdImporteCargo = "";
		ELSE 
			IF(vcTipoTransacc IS NOT NULL AND vcTipoTransacc = '0274') THEN
				LET vcConceptoPago = TRIM(vcReferencia) || ", Cargo SPEI" ;
				LET vdImporteCargo = vdImporteAux;
				LET vdImporteAbono = "";
			END IF;
		END IF;
		
		RETURN v_sCodRet, vcTipoTransacc, vdFechaAplicacion, vcCuenta, vcConceptoPago, vdImporteAbono, vdImporteCargo,vcBanderaInhabil,vcReferencia,vcCtaClabe,vTotalRegistros
		WITH RESUME;
	
	END FOREACH;
	
END;
END PROCEDURE;