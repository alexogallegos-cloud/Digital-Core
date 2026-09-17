CREATE PROCEDURE "informix".sp_recupera_saldo_inv(pcel CHAR(10))
	RETURNING CHAR(5) as codret, CHAR(160) as saldo_inv;

	DEFINE vcodret CHAR(5);
	DEFINE vtermctainver CHAR(4); 
    DEFINE vsqlerr, vcantI, vcantP INTEGER;
	DEFINE vcadenaI CHAR(500);
	DEFINE vcadenaP CHAR(500);
	DEFINE vcuenta CHAR(20);
	DEFINE vtermcta CHAR(4);
	DEFINE vsdodisp DECIMAL(18,2);
	DEFINE vdivisor CHAR(3);

	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRet CHAR(5);
	DEFINE cCliente CHAR(20);
	DEFINE cSecuencia CHAR(6);
	DEFINE cNombreCliente CHAR(104);
	DEFINE cTpPersona CHAR(2);
	DEFINE cDescTpPersona CHAR(20);
	DEFINE cCalle CHAR(35);
	DEFINE cColonia CHAR(35);
	DEFINE cDelegacion CHAR(35);
	DEFINE cPoblacion CHAR(20);
	DEFINE cCodPostal CHAR(5);
	DEFINE cTelefono CHAR(14);
	DEFINE cInstrumento CHAR(4);
	DEFINE cDescInstrumento CHAR(40);
	DEFINE cMoneda CHAR(12);
	DEFINE cDescMoneda CHAR(30);
	DEFINE cPlaza CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombreSucursal CHAR(40);
	DEFINE dTasaBruta DECIMAL(9,6);
	DEFINE dTasaISR DECIMAL(9,6);
	DEFINE dTasaNeta DECIMAL(9,6);
	DEFINE mIntereses MONEY(14,2);
	DEFINE mImptoISR MONEY(14,2);
	DEFINE mRendNeto MONEY(14,2);
	DEFINE mCapital MONEY(14,2);
	DEFINE cPlazo CHAR(6);
	DEFINE dFecApertura DATE;
	DEFINE dFecVencimiento DATE;
	DEFINE cEnvio CHAR(1);
	DEFINE cDescEnvio CHAR(10);
	DEFINE cCtaCheques CHAR(20);
	DEFINE cPromotor CHAR(5);
	DEFINE cNombrePromotor CHAR(45);
	DEFINE cOpcionRet CHAR(2);
	DEFINE cDesOpcRet CHAR(40);
	DEFINE cStatusCta CHAR(1);
	DEFINE cDescStatusCta CHAR(25);
	DEFINE cCuenta CHAR(20);
	DEFINE cSs CHAR(13);
	
    LET vcodret    = '00000';
    LET vtermctainver   = "";
	LET vcadenaI	   = '';
	LET vcadenaP	   = '';
	LET vcuenta = '';
	LET vtermcta   = "";
	LET vsdodisp   =  "0.00";
	LET vdivisor = '';
	
	LET cCodRet = '';
	LET cEmpresa = '001';
	LET cCliente = '';
	LET cSecuencia = '';
	LET cNombreCliente = '';
	LET cTpPersona = '';
	LET cDescTpPersona = '';
	LET cCalle = '';
	LET cColonia = '';
	LET cDelegacion = '';
	LET cPoblacion = '';
	LET cCodPostal = '';
	LET cTelefono = '';
	LET cInstrumento = '';
	LET cDescInstrumento = '';
	LET cMoneda = '';
	LET cDescMoneda = '';
	LET cPlaza = '';
	LET cSucursal = '';
	LET cNombreSucursal = '';
	LET dTasaBruta = NULL;
	LET dTasaISR = NULL;
	LET dTasaNeta = NULL;
	LET mIntereses = NULL;
	LET mImptoISR = NULL;
	LET mRendNeto = NULL;
	LET mCapital = NULL;
	LET cPlazo = '';
	LET dFecApertura = NULL;
	LET dFecVencimiento = NULL;
	LET cEnvio = '';
	LET cDescEnvio = '';
	LET cCtaCheques = '';
	LET cPromotor = '';
	LET cNombrePromotor = '';
	LET cOpcionRet = '';
	LET cDesOpcRet = '';
	LET cStatusCta = '';
	LET cDescStatusCta = '';
	LET cCuenta = '';
	LET cSs = '';

    BEGIN
    
		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF LENGTH(pcel) <> 10 THEN
			LET vcodret = "00001";
			RETURN vcodret,'NUMERO TELEFONICO INVALIDO, VERIFIQUE.';
		END IF;

		/* ESTATUS CUENTA
				1 = 'CUENTA ACTIVA';
				2 = 'CUENTA CANCELADA';
				3 = 'CUENTA BLOQUEADA';
				4 = 'CUENTA REINVERTIDA';
		*/

		--===================================================================================VALIDA NUMCTE=====================
		--BUSCA PAGARÃS (3000)
		SELECT COUNT(DISTINCT(a.numcte)) INTO vcantP 
			FROM bdinteg:"informix".si_telefonos_actual a, bdinvers:"informix".sv_maeinv b	
			WHERE telefono=pcel AND a.numcte=b.num_cte AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3');

		--BUSCA INVERSION Y EFECTIVA PLUS (1100 y 1800)
		SELECT COUNT(DISTINCT(a.numcte)) INTO vcantI 
			FROM bdinteg:"informix".si_telefonos_actual a, bdicheq:"informix".sc_maechq b	
			WHERE telefono=pcel AND a.numcte=b.num_cte 
			AND producto IN('1100','1800') 
			AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3');


		IF vcantI > 1 OR vcantP > 1 THEN 
	        LET vcodret = "00002";
    	    RETURN vcodret,'';
	    ELIF vcantI < 1 AND vcantP < 1 THEN 
	        LET vcodret = "00000";
	        RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UNA CUENTA DE AHORRO.';
	    END IF;
	--===================================================================================BUSCA CUENTAS Y SALDOS


		--BUSCA PAGARÃS (3000)
		SELECT COUNT(DISTINCT(B.cuenta)) INTO vcantP 
			FROM bdinteg:"informix".si_telefonos_actual a, bdinvers:"informix".sv_maeinv b	
			WHERE telefono=pcel AND a.numcte=b.num_cte AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3');

		--BUSCA INVERSION Y EFECTIVA PLUS (1100 y 1800)
		SELECT COUNT(DISTINCT(B.cuenta)) INTO vcantI 
			FROM bdinteg:"informix".si_telefonos_actual a, bdicheq:"informix".sc_maechq b	
			WHERE telefono=pcel AND a.numcte=b.num_cte 
			AND producto IN('1100','1800') 
			AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3');

		

		IF vcantI + vcantP = 1 THEN 
			LET vcadenaI	= 'EL SALDO DE SU INVERSION BANCOPPEL, TERM.';
		ELIF vcantI + vcantP > 1 THEN 
			LET vcadenaI	= 'EL SALDO DE SUS INVERSIONES BANCOPPEL, TERM.';
		END IF;


	--PROCESA INVERSIONES Y EFECTIVA PLUS
		--RQM 09 704. Se agrega el campo de saldo inmovilizado en el calculo de saldo disponible.DHG
		FOREACH SELECT  SUBSTR(cuenta,8,4) as term_cuenta, SUM(sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc)) as saldo
			INTO vtermcta,vsdodisp
			FROM bdinteg:"informix".si_telefonos_actual a, bdicheq:"informix".sc_maechq b	
			WHERE telefono=pcel AND a.numcte=b.num_cte
			AND producto IN('1100','1800') 
			AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3') GROUP BY term_cuenta

			LET vcadenaI = TRIM(vcadenaI) || " ***" || vtermcta || ": " || TO_CHAR(vsdodisp, "$<<<,<<<,<<<,<<&.&&") || ", ";

		END FOREACH;


	--PROCESA PAGARÃS

		FOREACH SELECT  DISTINCT(cuenta) INTO vcuenta
				FROM bdinteg:"informix".si_telefonos_actual a, bdinvers:"informix".sv_maeinv b	
					WHERE telefono=pcel AND a.numcte=b.num_cte AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3') GROUP BY cuenta

				EXECUTE PROCEDURE bdinvers:"informix".cons_sdo(cEmpresa, TRIM(vcuenta))
					INTO cCodRet, cCliente, cSecuencia, cNombreCliente, cTpPersona, cDescTpPersona, cCalle, cColonia, cDelegacion, cPoblacion, cCodPostal,
						cTelefono, cInstrumento, cDescInstrumento, cMoneda, cDescMoneda, cPlaza, cSucursal, cNombreSucursal, dTasaBruta, dTasaISR, 
						dTasaNeta, mIntereses, mImptoISR, mRendNeto, mCapital, cPlazo, dFecApertura, dFecVencimiento, cEnvio, cDescEnvio, cCtaCheques, 
						cPromotor, cNombrePromotor, cOpcionRet, cDesOpcRet, cStatusCta, cCuenta, cSs;

				LET vtermctainver = SUBSTR(TRIM(vcuenta),8,11);
				LET vcadenaI = TRIM(vcadenaI) || " ***" || vtermctainver || " SALDO: " || TO_CHAR(mCapital, "$<<<,<<<,<<<,<<&.&&") || ", ";

		END FOREACH;

		RETURN vcodret, TRIM(SUBSTR(vcadenaI,1,LEN(vcadenaI) - 1));

	END;
END PROCEDURE
