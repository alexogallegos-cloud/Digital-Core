CREATE PROCEDURE "informix".sp_cs_pago_anticipado_juan(pEmpresa					CHAR(3),
												pNumCredito					CHAR(20),
												pProducto					CHAR(4),
												pMontoOperacionEfec			DECIMAL(18,2),
												pMontoOperacionCargCuenta	DECIMAL(18,2),
												pUsuario					CHAR(8),
												pSucursal					CHAR(4),
												pFolio						CHAR(16),
												pTransaccion				CHAR(4))
RETURNING CHAR(5)		AS CodRet,
		CHAR(80)		AS Mensaje,
		CHAR(20)		AS Num_Credito,
		CHAR(20)		AS Cuenta_eje,
		CHAR(40)		AS Producto,
		CHAR(20)		AS Num_Cliente,
		CHAR(150)		AS Nom_Cliente,
		DECIMAL(18,2)	AS Pago_Efectivo,
		DECIMAL(18,2)	AS Pago_Cuenta,
		DECIMAL(18,2)	AS Monto_Operacion,
		DECIMAL(18,2)	AS Saldo_Actual,
		CHAR(60)		AS Status_Actual,
		DATE			AS fecha_prox_pago

DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(100);
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE cNumCreditocrd		CHAR(20);
DEFINE cNumCreditocrdsol	CHAR(20);
DEFINE cCredito_promo		CHAR(20);
DEFINE dtFechaProxPago		DATE;
DEFINE dtFechaApertura		DATE;
DEFINE Cuenta_eje			CHAR(20);
DEFINE Producto				CHAR(40);
DEFINE Num_Cliente			CHAR(20);
DEFINE Nom_Cliente			CHAR(80);
DEFINE Pago_Efectivo		DECIMAL(18,2);
DEFINE Pago_Cuenta			DECIMAL(18,2);
DEFINE Monto_Operacion		DECIMAL(18,2);
DEFINE Saldo_Actual			DECIMAL(18,2);
DEFINE Status_Actual		CHAR(60);
DEFINE iIntAux				INTEGER;
DEFINE cCharAux				CHAR(80);
DEFINE dDecAux				DECIMAL(18,2);
DEFINE dtDateAux			DATE;
DEFINE dPagoMinAct			DECIMAL(18,2);
DEFINE dSdoCapInsolutoPP	DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct	DECIMAL(18,2);
DEFINE cFolio				INTEGER;

define cMensaje3 char(50);
DEFINE scont INT8;

LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= "";
LET cCodRet				= "00000";
LET cMensaje			= "Se realizÃÂ³ el proceso exitosamente";
LET cNumCreditocrd		= pNumCredito;
LET cCredito_promo		= "";
LET cCredito_promo		= "";
LET dtFechaProxPago		= mdy(1, 1, 1900);
LET dtFechaApertura		= mdy(1, 1, 1900);
LET Cuenta_eje			= "";
LET Producto			= "";
LET Num_Cliente			= "";
LET Nom_Cliente			= "";
LET Pago_Efectivo		= 0;
LET Pago_Cuenta			= 0;
LET Monto_Operacion		= 0;
LET Saldo_Actual		= 0;
LET Status_Actual		= "";
LET iIntAux				= 0;
LET cCharAux			= "";
LET dDecAux				= 0;
LET dtDateAux			= DATE(1);
LET dPagoMinAct			= 0;
LET dSdoCapInsolutoPP	= 0;
LET dSdoAdeudTotalAct	= 0;
LET cNumCreditocrdsol   = pNumCredito;
LET cFolio				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr in (-255) THEN
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_cs_pago_anticipado.out";
            TRACE ON;
        else	
--		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = cErrorInfo;
			RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
		END IF;
	END EXCEPTION;



IF NVL(pEmpresa,"")= "" OR  NVL(pNumCredito,"") = "" OR NVL(pProducto,"") = "" OR NVL(pMontoOperacionEfec,"") = "" OR NVL(pMontoOperacionCargCuenta,"")  = "" OR NVL(pUsuario,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pFolio,"") = "" OR NVL(pTransaccion,"") = "" THEN

	LET cCodRet      = "00411";
     LET cMensaje  = "NO HAY ARGUMENTOS (PARAMETROS)";

		RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
END IF;

SET DEBUG FILE TO "/tmp/sp_cs_pago_anticipado.out";
TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		SELECT a.num_credito
			INTO cCredito_promo
		FROM bdicred: "informix".sd_promocion_credito a, bdicred: "informix".sd_maecredcrd b, bdicred: "informix".sd_maecredanexocrd c
		WHERE a.empresa = pempresa
			AND a.empresa = b.empresa
			AND a.empresa = c.empresa
			and a.num_sol_prestamo = cNumCreditocrd
			AND a.num_sol_prestamo = b.num_credito
			AND a.num_sol_prestamo = c.num_credito
			AND num_pro_prestamo = pproducto
			AND a.status = 2
			AND b.status_cred = 'AA';

		IF ( cCredito_promo IS NOT NULL ) THEN

				CALL "informix".sp_principal_suc_rr(pempresa,cNumCreditocrd, pproducto,pMontoOperacionEfec,pMontoOperacionCargCuenta,pUsuario,pSucursal,pFolio,pTransaccion)
				RETURNING cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual;

				--AAME INC 27 108 Se castea la variable de retorno para que cuando el codigoret sea "000" exito o "00000" los tome igual
				IF (cCodRet::INTEGER <> 0) THEN
					IF cCodRet = "00044" THEN
						LET cCodRet = "01088";
						LET cMensaje = "Cliente no tiene cuenta efectiva";
					ELIF cCodRet = "00195" THEN
						LET cCodRet = "01094";
						LET cMensaje = "Cuenta del cliente no esta activa";
					ELIF cCodRet = "00199" THEN
						LET cCodRet = "001093";
						LET cMensaje = "Cuenta del cliente bloqueada";
					ELIF cCodRet = "00194" THEN
						LET cCodRet = "001095";
						LET cMensaje = "Cuenta sin saldo";
					END IF;

					RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
				ELSE


					EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pempresa,cNumCreditocrd)
						INTO cCodRet,cMensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
					iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					dsdocapinsolutopp,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dDecAux,dDecAux,
					dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
					cCharAux,cCharAux,iIntAux,cCharAux;

					IF  pTransaccion = '623' THEN

					   LET pMontoOperacionEfec = pMontoOperacionCargCuenta;
					END IF;
					--EM 24/03/2017
					--AAME INC 27 108 Se elimina IF NOT EXITS a peticiÃ³n de Base de Datos
					SELECT count(folio_suc) INTO cFolio
					FROM bdicred: "informix".sd_pago_anticipado_cs WHERE folio_suc = pFolio;
					
					IF cFolio = 0 THEN
					  INSERT INTO bdicred: "informix".sd_pago_anticipado_cs(empresa,folio_suc,fecha_mov,producto,num_credito,tarjeta,monto_pago,saldo_actual,fechaproximopago,transaccion)
                      VALUES (pempresa,pFolio,TODAY,pproducto,cNumCreditocrd,'',pMontoOperacionEfec,dSdoAdeudTotalAct,dtFechaProxPago,pTransaccion);
					ELSE
						UPDATE bdicred: "informix".sd_pago_anticipado_cs
						SET  fecha_mov= TODAY, producto= pproducto, num_credito= cNumCreditocrd, tarjeta= '', monto_pago= pMontoOperacionEfec, saldo_actual= dSdoAdeudTotalAct, fechaproximopago= dtFechaProxPago, transaccion= pTransaccion
						WHERE folio_suc= pFolio and empresa= pempresa;
					END IF;

					LET cMensaje   = "Se realizÃÂ³ el proceso exitosamente";

				   -- DSB - TH - 16-02-2015
					LET Saldo_Actual = dSdoAdeudTotalAct;

					--UPDATE bdicred: "informix".sd_promocion_credito
					--	SET monto_actual = dSdoAdeudTotalAct, folio_suc_mov_crd = pFolio
					--WHERE empresa = pempresa and num_sol_prestamo = cNumCreditocrdsol;
				END IF;

		ELSE
			LET cCodRet = "00002";
			LET cMensaje   = "La credisoluciÃÂ³n no existe";
		END IF;
	RETURN cCodRet,cMensaje,cNumCreditocrd,Cuenta_eje,Producto,Num_Cliente,Nom_Cliente,Pago_Efectivo,Pago_Cuenta,Monto_Operacion,Saldo_Actual,Status_Actual,dtFechaProxPago;
END
END PROCEDURE
DOCUMENT

'DESCRIPCIÃ?N: PROCEDURE QUE PARA INVOCAR EL PAGO ANTICIPADO DE CREDISOLUCIONES',
'FECHA DE MODIFICACIÃ?N: 28-11-2015',
'BASE DE DATOS: BDICRED',
'MODIFICÃ?: YADIRA MORALES ZAZUETA',
'----------------------------------------------------------------------------',
'Descripcion : se agrega consulta de credito en sd_promocion_credito de credisoluciones para respaldar',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 07/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : se agrega modifica para que imprima en ticket sd_pago_anticipado_cs.saldo_actual ',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 16/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para actualizar folio suc en la tabla sd_promocion_credito cuando se hace un pago, se filtra para que inserte en sd_pago_anticipado_cs ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 08/003/2017,--EM 24/03/2017',
'BD          : bdicred';

CREATE PROCEDURE "informix".consctacte_web(pEmpresa char(3), 
                                    pNumeroTarjeta char(20))


	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- # de Cuenta
	CHAR(20); -- # de Cliente


	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		char(5);
	DEFINE vNumCuenta	char(20);
	DEFINE vNumCliente	char(20);
    DEFINE vStatus      char(1);


	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "00000";

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- CONSULTA --
	SELECT
        num_credito, numcte, status_tar
	INTO
        vNumCuenta, vNumCliente, vStatus
	FROM
		bdicred:"informix".sd_tarjeta
	WHERE
        empresa = pEmpresa AND num_tarjeta = pNumeroTarjeta;


	IF vNumCuenta IS NULL OR vNumCliente IS NULL THEN
		LET vCodRet	    = "00090";
		LET vNumCuenta  = "";
		LET vNumCliente = "";
    ELIF vStatus = "C" THEN
        LET vCodRet     = "00143";
		---LET vNumCuenta  = "";
		---LET vNumCliente = "";
    END IF


	RETURN vCodRet, vNumCuenta, vNumCliente;

END PROCEDURE
DOCUMENT
"Modificó: Julio Cesar Polanco",
"Descripción: Se modifica para que si esta cancelada la tarjeta regrese el codigo 143",
"Solicitó: Cutberto Gonzalez",
"Fecha: 15/10/2010",

"Modificó: Sonia Guzman Rodriguez",
"Descripción: Se modifica para que si esta cancelada la tarjeta regrese el numero de cuenta y el numero de cliente",
"Solicitó: Cutberto Gonzalez",
"Fecha: 03/05/2010",

"Modificó: Gustavo Sauceda",
"Descripción Se modifica el codigo de retorno a 90 para indicar que la tarjeta no esta asignada",
"Fecha: 29/03/2012";

CREATE PROCEDURE "informix".sp_cgoctefva_abontdc_web(pEmpresa char(3),
												pSucursal char(4),
												pUsuario char(8),
												pTransCargo char(4),
												pTransAbono char(4),
												pTransSuc char(4),
												pFolioSuc char(16),
												pNumCtaOrigen char(12),
												pNumCtaDestino char(12),
												pCheque integer,
												pMonto money(14,2),
												pMoneda char(2),
												pReferencia char(40),
												pNumTarjetaOrigen char(16),
												pUsuAutoriza char(8),
												pTiPago smallint)

RETURNING char(5) As codret,
		char(5) As codretRev ,
		integer As sql_err,
		char(4) As Trans,
		date As FechaHoy,
		money(14,2) As SdoDisp,
		money(14,2) As MontoRet,
		char(1) As PasoCargo,
		money(14,2) As Remanente,
		money(14,2) As IntMoratorio,
		money(14,2) As IntVencido,
		money(14,2) As CapitalVencido,
		money(14,2) As InteresVigente,
		money(14,2) As CapitalVigente,
		money(14,2) As Impuestos,
		money(14,2) As Comisiones,
		money(14,2) As SeguroCobrado;
		
--DEFINICION DE LAS VARIABLES
DEFINE cCodRet   	char(5);
DEFINE cCodRetRev   char(5);
DEFINE iSql_Err   	integer;
DEFINE cTrans    	char(4);
DEFINE dFechaHoy 	date;
DEFINE mSdoDisp  	money(14,2);
DEFINE mMontoRet 	money(14,2);
DEFINE cPasoCargo 	char(1);
DEFINE mRemanente 	money(14,2);
DEFINE mIntMoratorio money(14,2);
DEFINE mIntVencido 	money(14,2);
DEFINE mCapitalVencido money(14,2);
DEFINE mInteresVigente money(14,2);
DEFINE mCapitalVigente money(14,2);
DEFINE mImpuestos 	money(14,2);
DEFINE mComisiones 	money(14,2);
DEFINE mSeguroCobrado money(14,2);

--INICIALIZACION DE LAS VARIABLES
LET cCodRet   		= '00000';
LET cCodRetRev  	= '00000'; --CODIGO DE RETORNO CUANDO TODO SALIO BIEN
LET iSql_Err   		= 0;
LET cTrans    		= '';
LET dFechaHoy 		= DATE(1);
LET mSdoDisp  		= 0.0;
LET mMontoRet 		= 0.0;
LET cPasoCargo 		= 0.0;
LET mRemanente 		= 0.0;
LET mIntMoratorio	= 0.0;
LET mIntVencido 	= 0.0;
LET mCapitalVencido	= 0.0;
LET mInteresVigente	= 0.0;
LET mCapitalVigente	= 0.0;
LET mImpuestos 		= 0.0;
LET mComisiones 	= 0.0;
LET mSeguroCobrado	= 0.0;

--SET DEBUG FILE TO '/tmp/sp_cgoctefva_abontdc.out';
--TRACE ON; 

BEGIN

	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSql_Err
		IF iSql_Err <> 0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,pSucursal,pUsuario,pFolioSuc,'A') INTO cCodRetRev;
		END IF;
		IF cCodRetRev = '00000' THEN
			LET cCodRetRev = '00002'; --CODIGO DE RETORNO 00002 PARA SABER CUANDO SE REVERSA
		END IF;		
		LET cCodRet = iSql_Err;
		LET cCodRet = LPAD (TRIM(cCodRet),5,'0');
		RETURN cCodRet,cCodRetRev,iSql_Err,cTrans,dFechaHoy,mSdoDisp,mMontoRet,cPasoCargo,mRemanente,mIntMoratorio,mIntVencido,	mCapitalVencido,mInteresVigente,mCapitalVigente,mImpuestos,mComisiones,mSeguroCobrado;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
      ROLLBACK WORK;
      BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pUsuario,'') = '' OR NVL(pTransCargo,'') = '' OR NVL(pTransAbono,'') = '' OR NVL(pTransSuc,'') = '' OR NVL(pFolioSuc,'') = '' OR NVL(pNumCtaOrigen,'') = '' OR NVL(pNumCtaDestino,'') = '' OR NVL(pCheque,0) = 0 OR NVL(pMonto,0.0) = 0 OR NVL(pMoneda,'') = '' OR NVL(pUsuAutoriza,'') = '' OR NVL(pTiPago,'') = '' THEN

		LET cCodRet = '00001';
		LET cCodRetRev = '00001'; --CODIGO DE RETORNO 00001 PARA SABER CUANDO LOS PARAMETROS VIENEN BACIOS
		RETURN cCodRet,cCodRetRev,iSql_Err,cTrans,dFechaHoy,mSdoDisp,mMontoRet,cPasoCargo,mRemanente,mIntMoratorio,mIntVencido,mCapitalVencido,mInteresVigente,mCapitalVigente,mImpuestos,mComisiones,mSeguroCobrado;
	END IF;

--VALIDA CUENTAS DE CARGO Y ABONO
	EXECUTE PROCEDURE "informix".sp_validapagotdc_bpi(pNumCtaOrigen, pNumCtaDestino) INTO cCodRet;
	IF cCodRet <> '000' THEN      
		EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,pSucursal,pUsuario,pFolioSuc,'A') INTO cCodRetRev;
			IF cCodRetRev = '00000' THEN
				LET cCodRetRev = '00003'; --CODIGO DE RETORNO 00001 PARA SABER CUANDO SE REVERSA sp_validapagotdc_bpi 
			END IF;
		
		LET cCodRet = LPAD (TRIM(cCodRet),5,'0');
		RETURN cCodRet,cCodRetRev,iSql_Err,cTrans,dFechaHoy,mSdoDisp,mMontoRet,cPasoCargo,mRemanente,mIntMoratorio,mIntVencido,mCapitalVencido,mInteresVigente,mCapitalVigente,mImpuestos,mComisiones,mSeguroCobrado;
	END IF;

	--INC 25 170 AAME Para que actualice la descripciÃ³n solo cuando venga vacÃ­o
    IF pReferencia = '' THEN
        LET pReferencia = 'CARGO EN CUENTA PAGO TDC';
	END IF;
	
--SE EJECUTA EL CARGO A LA CUENTA
	EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
												pSucursal,
												pUsuario,
												pTransCargo,
												pTransSuc,
												pFolioSuc,
												pNumCtaOrigen,
												pCheque,
												pMonto,
												pMoneda,
												pReferencia,
												pNumTarjetaOrigen,
												pUsuAutoriza) INTO cCodRet,cTrans,dFechaHoy,mSdoDisp,mMontoRet;

--SI EXISTE ERROR SE REVERSA LA TRANSACCION
	IF cCodRet <> '000' THEN
		EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,pSucursal,pUsuario,pFolioSuc,'C') INTO cCodRetRev;
			IF cCodRetRev = '00000' THEN
				LET cCodRetRev = '00004'; --CODIGO DE RETORNO 00001 PARA SABER CUANDO SE REVERSA cargo_ref
				RETURN cCodRet,cCodRetRev,iSql_Err,cTrans,dFechaHoy,mSdoDisp,mMontoRet,cPasoCargo,mRemanente,mIntMoratorio,mIntVencido,mCapitalVencido,mInteresVigente,mCapitalVigente,mImpuestos,mComisiones,mSeguroCobrado; 
			END IF;
	END IF;
	
	--INC 25 170 AAME Se cambia la referencia cuando sea el pago por concepto de credisolucion
	IF pTransAbono ='8150' THEN
		LET pReferencia = pFolioSuc ||' '|| TRIM(pReferencia::char(12));
	ELSE
		LET pReferencia = 'SU PAGO CARGO EN CUENTA '|| TRIM(pNumCtaOrigen::char(12));
	END IF;
	
--SE EJECUTA EL ABONO A LA CUENTA
	EXECUTE PROCEDURE "informix".principal(pEmpresa,
												pNumCtaDestino,
												pTiPago,
												pMonto,
												pUsuario,
												pSucursal,
												pFolioSuc,
												pTransAbono) INTO cCodRet,
																  mRemanente,
																  mIntMoratorio,
																  mIntVencido,
																  mCapitalVencido,
																  mInteresVigente,
																  mCapitalVigente,
																  mImpuestos,
																  mComisiones,
																  mSeguroCobrado;

--SI EXISTE ERROR SE REVERSA LA TRANSACCION
	IF cCodRet <> '000' THEN
		EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,pSucursal,pUsuario,pFolioSuc,'C') INTO cCodRetRev;
			IF cCodRetRev = '00000' OR cCodRetRev <>'00000' THEN
				EXECUTE PROCEDURE "informix".reversion(pEmpresa,pSucursal,pUsuario,pFolioSuc,'A') INTO cCodRetRev;
					IF cCodRetRev = '00000' THEN
						LET cCodRetRev = '00005'; --CODIGO DE RETORNO 00004 PARA SABER CUANDO SE REVERSARON LOS DOS SP
					END IF;						  --cargo_ref y principal
			END IF	
		LET cCodRet = LPAD (TRIM(cCodRet),5,'0');
		RETURN cCodRet,cCodRetRev,iSql_Err,cTrans,dFechaHoy,mSdoDisp,mMontoRet,cPasoCargo,mRemanente,mIntMoratorio,mIntVencido,mCapitalVencido,mInteresVigente,mCapitalVigente,mImpuestos,mComisiones,mSeguroCobrado;
	ELSE	
			UPDATE "informix".sd_movdia
			SET referencia = pReferencia
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal
			AND folio_suc = pFolioSuc
			AND num_credito = pNumCtaDestino;
			
			LET cCodRet = LPAD (TRIM(cCodRet),5,'0');
	END IF;	
END;

	RETURN cCodRet,cCodRetRev,iSql_Err,cTrans,dFechaHoy,mSdoDisp,mMontoRet,cPasoCargo,mRemanente,mIntMoratorio,mIntVencido,mCapitalVencido,mInteresVigente,mCapitalVigente,mImpuestos,mComisiones,mSeguroCobrado;

END PROCEDURE
DOCUMENT
'AUTOR: 95281495 Jesus Ernesto Aguilera Inda.',
'DESCRIPCION: Realiza los cargos y abonos de pagos de tarjeta de credito con cargo a cuenta de la transaccion 622.',
'FOLIO:1615',
'FECHA:14/07/2014',
'VERSION: 20140714.10:00',
'BASE DE DATOS: bdicred';

CREATE PROCEDURE "informix".sp_valiexisttarjcctdebcred(pEmpresa CHAR(3), pRFC CHAR(13))
RETURNING CHAR(6),
		  CHAR(1);

   DEFINE cNumCte   VARCHAR(20);
   DEFINE cNumTarjeta VARCHAR(20);
   DEFINE cTipoCta    CHAR(1);
   DEFINE v_codret     CHAR(6);
   DEFINE sqlerr       INTEGER; 
   
   LET v_codret     = "000000";
   LET sqlerr       = 0;
   LET cNumCte = "0";
   LET cNumTarjeta = "0";
   LET cTipoCta = "";
   
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   BEGIN
	  ON EXCEPTION
		  SET sqlerr
		  LET v_codret = sqlerr;
		  RETURN v_codret, cTipoCta;
	  END EXCEPTION;
	   --SET DEBUG FILE TO  '/home/sysifx/Oscar/sp_valiexisttarjcctdebcred.out';
       --TRACE ON;
	 IF TRIM(pRFC) = '' OR pRFC IS NULL THEN
		LET v_codret = '000002';
		RETURN v_codret, cTipoCta;
	 END IF
	
	SELECT numcte INTO cNumCte FROM bdinteg:"informix".si_cliente WHERE rfc = pRFC AND empresa = pEmpresa;
	
	IF TRIM(cNumCte) <> '' AND cNumCte IS NOT NULL THEN
			
			SELECT LIMIT 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
			WHERE numcte = cNumCte
			AND status_tar = 'A'; -->> CrÃ©dito
			
			IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
				LET cTipoCta = "C"; 
			ELSE
				SELECT LIMIT 1 num_tarjeta INTO cNumTarjeta FROM bdicheq:"informix".sc_tarjeta 
				WHERE numcte = cNumCte
				AND status_tar = 'A'; -->> Debito
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
					LET cTipoCta = "D";
				ELSE
					LET v_codret = '000001';
				END IF
			END IF;
	ELSE
		LET v_codret = '000001';
    END IF;
    RETURN v_codret, cTipoCta;
   END;
END PROCEDURE

DOCUMENT
"Spl para saber si el cliente tiene tarjetas activas de crÃ©dito o debito ",
"obtener la fecha de fechrero por ejemplo",
"base de datos: bdicred",
"AUTOR : Oscar Marquez 98681011",
"FECHA : 25/09/2019";

CREATE PROCEDURE "informix".carga_movhis_edoctacrd(fecha_hoy DATE, pnum_producto CHAR(4))
RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;
--
DEFINE p_empresa     	CHAR(3);
DEFINE p_secuencia   	integer;
DEFINE p_fecha_mov   	DATE ;
DEFINE p_hora_mov    	DATETIME HOUR to FRACTION(3);
DEFINE p_sucursal    	CHAR(4);
DEFINE p_num_credito 	CHAR(20);
DEFINE p_plaza       	CHAR(3);
DEFINE p_transacc_suc	CHAR(4);
DEFINE p_usuario     	CHAR(8);
DEFINE p_monto       	DECIMAL(18,2);
DEFINE p_codigo_fun  	CHAR(3);
DEFINE p_codigo_ref  	INTEGER;
DEFINE p_divisa      	CHAR(2);
DEFINE p_reversado   	CHAR(1);
DEFINE p_folio_suc   	CHAR(16);
DEFINE p_num_producto	CHAR(4);
DEFINE p_nro_tarjeta 	VARCHAR(20,1);
DEFINE p_referencia  	VARCHAR(80,1);
DEFINE p_tipo_cambio 	DECIMAL(14,6);
DEFINE p_monto_dls   	DECIMAL(14,2);
DEFINE p_suc_origen  	VARCHAR(4,1);
DEFINE p_rfc_comer   	VARCHAR(20,1);
DEFINE p_referencia23	VARCHAR(23,1);
DEFINE cBanBegin        CHAR(1);
DEFINE p_descripcion    VARCHAR(100,1);
DEFINE p_naturaleza     CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret   = "000";
LET vsqlerr    = 0;
LET numcredito = "";
LET icontador  = 1;
LET cBanBegin  = 'N';
LET p_descripcion = "";
LET p_naturaleza  = "";

-- Autor: Jose de Jesus Almeida
-- Fecha: 2009/07/23
-- Modificación: Se realiza modificación con la finalidad de agregar un parámetro
--               para identificar si sera la obtencion de los datos para la generación
--               de estados de cuenta para tarjetas de crédito o para créditos otorgados
--               de forma reestructurada, la solicitud del cambio fue solicitada en el
--               anexo incluido en el RQM 10 105 (Edo.Cta Reestructura)

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
   	  IF cBanBegin= 'S' THEN
	     ROLLBACK WORK;
	  END IF;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "carga_movhis_edocta.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	-- ************************************************************
	-- Datos de MAEDCRED QUE DEBEN BORRARSE DE SD_AMORTIZA_CREDTO *
	-- ************************************************************

  set isolation to dirty read;

  select * from "informix".sd_movhiscrd 
  where fecha_mov between  fecha_hoy - 1 UNITS MONTH and fecha_hoy
    and num_credito in (select num_credito from "informix".sd_maecredcrd where num_producto = pnum_producto)
  into temp temp_movhiscrd with no log;

  create index inx1_temp_movhiscrd on temp_movhiscrd(codigo_fun, codigo_ref);
  create index inx2_temp_movhiscrd on temp_movhiscrd(fecha_mov, num_producto, reversado);
  update statistics medium for table temp_movhiscrd;

  FOREACH WITH HOLD


                SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
                       a.hora_mov,			a.sucursal,                a.num_credito,
                       a.plaza,				a.transacc_suc,			   a.usuario,
                       a.monto,             a.codigo_fun,			   a.codigo_ref,
                       a.divisa,			a.reversado,			   a.folio_suc,
                       a.num_producto,      a.nro_tarjeta,			   a.referencia,
                       a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
                       a.rfc_comer,			a.referencia23,     TRIM(b.descripcion),
                       c.naturaleza
                  INTO
                       p_empresa,           p_secuencia,               p_fecha_mov,
                       p_hora_mov,          p_sucursal,                p_num_credito,
                       p_plaza,             p_transacc_suc,            p_usuario,
                       p_monto,             p_codigo_fun,              p_codigo_ref,
                       p_divisa,            p_reversado,               p_folio_suc,
                       p_num_producto,      p_nro_tarjeta,             p_referencia,
                       p_tipo_cambio,       p_monto_dls,               p_suc_origen,
                       p_rfc_comer,         p_referencia23,            p_descripcion,
                       p_naturaleza
                 FROM temp_movhiscrd a,"informix".sd_transfun b, bdinteg:si_transacc  c
                WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
                  AND c.numero = b.transacc AND c.se_emite_edocta = "S"
                  AND fecha_mov >= case
                  WHEN date(fecha_hoy - 1 UNITS MONTH) = (select fecha_apertura from bdicred:sd_maecredcrd where a.empresa = empresa  and a.num_credito = num_credito)
                  THEN date(fecha_hoy - 1 UNITS MONTH)
                  ELSE date(fecha_hoy - 1 UNITS MONTH + 1 units day) end
                  AND fecha_mov <= fecha_hoy
                  AND a.reversado = "N"
                  AND c.se_emite_edocta = "S"
				  AND c.sistema ="06" --Se agrega el sistema 06 a la validacion
                  AND a.num_producto = pnum_producto

          BEGIN WORK;
                INSERT INTO "informix".sd_movhisedoctacrd
                     VALUES (p_empresa, p_secuencia, p_fecha_mov, p_hora_mov, p_sucursal, p_num_credito, p_plaza, p_transacc_suc, p_usuario, p_monto, p_codigo_fun, p_codigo_ref, p_divisa, p_reversado, p_folio_suc, p_num_producto, p_nro_tarjeta, p_referencia, p_tipo_cambio, p_monto_dls, p_suc_origen, p_rfc_comer, p_referencia23,p_descripcion,p_naturaleza);
          COMMIT WORK;

  END FOREACH

  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_movhisedoctacrd;

  RETURN scod_ret;
END
END PROCEDURE;