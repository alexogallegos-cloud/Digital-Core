CREATE PROCEDURE "informix".sp_consultasaldopagare(pUsuario char(8), pIdFuncion char(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret, 
		CHAR(20) AS cliente, 
		CHAR(6) AS secuencia, 
		CHAR(104) AS nombre_cliente, 
		CHAR(2) AS tipo_persona, 
		CHAR(20) AS desc_tipo_persona, 
		CHAR(35) AS calle, 
		CHAR(35) AS colonia, 
		CHAR(35) AS delegacion, 
		CHAR(20) AS poblacion, 
		CHAR(5) AS codigo_postal, 
		CHAR(14) AS telefono, 
		CHAR(4) AS instrumento, 
		CHAR(40) AS desc_instrumento, 
		CHAR(12) AS moneda, 
		CHAR(30) AS desc_moneda, 
		CHAR(3) AS plaza, 
		CHAR(4) AS sucursal, 
		CHAR(40) AS nombre_sucursal, 
		DECIMAL(9,6) AS tasa_bruta, 
		DECIMAL(9,6) AS tasa_isr, 
		DECIMAL(9,6) AS tasa_neta, 
		MONEY(14,2) AS intereses, 
		MONEY(14,2) AS impuesto_isr, 
		MONEY(14,2) AS rend_neto, 
		MONEY(14,2) AS capital, 
		CHAR(6) AS plazo, 
		DATE AS fecha_apertura, 
		DATE AS fecha_vencimiento, 
		CHAR(1) AS envio, 
		CHAR(10) AS desc_envio, 
		CHAR(20) AS cuenta_cheques, 
		CHAR(5) AS promotor, 
		CHAR(45) AS nombre_promotor, 
		CHAR(2) AS opcion_ret, 
		CHAR(40) AS desc_opcion_ret, 
		CHAR(1) AS status_cta,
		CHAR(25) AS desc_status_cta,
		CHAR(20) AS cuenta, 
		CHAR(13) AS ss;
		
	
	DEFINE iSqlErr INTEGER;
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
	
	LET iSqlErr = 0;
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
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cSecuencia, cNombreCliente, cTpPersona, cDescTpPersona, cCalle, cColonia, cDelegacion, cPoblacion, cCodPostal,
				cTelefono, cInstrumento, cDescInstrumento, cMoneda, cDescMoneda, cPlaza, cSucursal, cNombreSucursal, dTasaBruta, dTasaISR, 
				dTasaNeta, mIntereses, mImptoISR, mRendNeto, mCapital, cPlazo, dFecApertura, dFecVencimiento, cEnvio, cDescEnvio, cCtaCheques, 
				cPromotor, cNombrePromotor, cOpcionRet, cDesOpcRet, cStatusCta, cDescStatusCta, cCuenta, cSs;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultasaldopagare.out';
		--TRACE ON;
		
		IF pUsuario = '' or pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cSecuencia, cNombreCliente, cTpPersona, cDescTpPersona, cCalle, cColonia, cDelegacion, cPoblacion, cCodPostal,
				cTelefono, cInstrumento, cDescInstrumento, cMoneda, cDescMoneda, cPlaza, cSucursal, cNombreSucursal, dTasaBruta, dTasaISR, 
				dTasaNeta, mIntereses, mImptoISR, mRendNeto, mCapital, cPlazo, dFecApertura, dFecVencimiento, cEnvio, cDescEnvio, cCtaCheques, 
				cPromotor, cNombrePromotor, cOpcionRet, cDesOpcRet, cStatusCta, cDescStatusCta, cCuenta, cSs;
		END IF;
		
		--EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '03', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cSecuencia, cNombreCliente, cTpPersona, cDescTpPersona, cCalle, cColonia, cDelegacion, cPoblacion, cCodPostal,
				cTelefono, cInstrumento, cDescInstrumento, cMoneda, cDescMoneda, cPlaza, cSucursal, cNombreSucursal, dTasaBruta, dTasaISR, 
				dTasaNeta, mIntereses, mImptoISR, mRendNeto, mCapital, cPlazo, dFecApertura, dFecVencimiento, cEnvio, cDescEnvio, cCtaCheques, 
				cPromotor, cNombrePromotor, cOpcionRet, cDesOpcRet, cStatusCta, cDescStatusCta, cCuenta, cSs;
		END IF;
		
		
		EXECUTE PROCEDURE bdinvers:"informix".cons_sdo(cEmpresa, pCuenta)
			INTO cCodRet, cCliente, cSecuencia, cNombreCliente, cTpPersona, cDescTpPersona, cCalle, cColonia, cDelegacion, cPoblacion, cCodPostal,
				cTelefono, cInstrumento, cDescInstrumento, cMoneda, cDescMoneda, cPlaza, cSucursal, cNombreSucursal, dTasaBruta, dTasaISR, 
				dTasaNeta, mIntereses, mImptoISR, mRendNeto, mCapital, cPlazo, dFecApertura, dFecVencimiento, cEnvio, cDescEnvio, cCtaCheques, 
				cPromotor, cNombrePromotor, cOpcionRet, cDesOpcRet, cStatusCta, cCuenta, cSs;
		
		IF cStatusCta = '1' THEN
			LET cDescStatusCta = 'CUENTA ACTIVA';
		ELIF cStatusCta = '2' THEN
			LET cDescStatusCta = 'CUENTA CANCELADA';
		ELIF cStatusCta = '3' THEN
			LET cDescStatusCta = 'CUENTA BLOQUEADA';
		ELIF cStatusCta = '4' THEN
			LET cDescStatusCta = 'CUENTA REINVERTIDA';
		END IF;
		
		IF cCodRet = '000' THEN
			LET cCodRet = '00000';
		ELIF cCodRet = '100' THEN
			-- La cuenta no existe
			LET cCodRet = '00009';
		ELIF cCodRet = '105' THEN
			-- El nombre del instrumento no existe
			LET cCodRet = '00099';
		ELIF cCodRet = '104' THEN
			-- Se desconoce el tipo de persona
			LET cCodRet = '00020';
		END IF;
		
		RETURN cCodRet, cCliente, cSecuencia, cNombreCliente, cTpPersona, cDescTpPersona, cCalle, cColonia, cDelegacion, cPoblacion, cCodPostal,
				cTelefono, cInstrumento, cDescInstrumento, cMoneda, cDescMoneda, cPlaza, cSucursal, cNombreSucursal, dTasaBruta, dTasaISR, 
				dTasaNeta, mIntereses, mImptoISR, mRendNeto, mCapital, cPlazo, dFecApertura, dFecVencimiento, cEnvio, cDescEnvio, cCtaCheques, 
				cPromotor, cNombrePromotor, cOpcionRet, cDesOpcRet, cStatusCta, cDescStatusCta, cCuenta, cSs;
		
	END;
	
END PROCEDURE;