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