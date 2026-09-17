CREATE PROCEDURE "informix".sp_validacadenanumerica(pCadena CHAR(10))
	RETURNING CHAR(5) AS CodRetorno;
	
	--Definicion de Variables
	DEFINE iSqlErr 	INTEGER;
	DEFINE cCodRet 	CHAR(5);
	DEFINE iAux		INTEGER;
	DEFINE iSuma	INTEGER;
	DEFINE i	INTEGER;
	
	--Inicializacion de Variables
	LET iSqlErr		= 0;
	LET cCodRet		= '00000';
	LET iAux		= 0;
	LET iSuma		= 0;
	LET i			= 0;
	
	--SET DEBUG FILE TO "/home/solserDB/sp_validaCadenaNumerica.out";
	--TRACE ON;
	
	BEGIN
		--Control de excepciones
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		
		--Se valida la Cadena reciba por parametro
		IF TRIM(NVL(pCadena,'')) = '' THEN
			LET cCodRet = '00001';
		ELSE
			FOR i = 1 TO LENGTH(TRIM(pCadena))
				LET iAux = ASCII(SUBSTR(TRIM(pCadena), i, 1));
				IF iAux >= 48 AND iAux <= 57 THEN
					LET iSuma = iSuma + 1;
				END IF;
			END FOR;
			
			IF iSuma <> LENGTH(TRIM(pCadena)) THEN
				LET cCodRet	= '00002';
			END IF;
		END IF;
		RETURN cCodRet;
	END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para validar si una cadena es numerica.',
'AUTOR : Manuel Ramos Figueroa',
'FECHA : 06 de Mayo 2013',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_pago_servicios_gdf(pEmpresa char(3), pSucursal char(4), pUsuario char(8), pTransCargo char(4), pTransAbono char(4),
pTransSuc char(4), pFolioSuc char(16),
pNumCtaOrigen char(12), pNumCtaDestino char(12), pCheque integer, pMonto money(14,2), pMoneda char(2), pReferencia char(40),
pNumTarjetaOrigen char(16), pNumTarjetaDestino char(16), pUsuAutoriza char(8), pMontoTotal money(14,2), pMontoFirme money(14,2), pMontoSBC money(14,2),
pMontoRem money(14,2), pDiasRet smallint, pDocto integer, pCategoria Char(2), pConvenio Char(3), cRefTelefono Char(20), cRefVerificador Char(20), cFormaPago Char(1),
cCuentaCargo CHAR (12), cTransacc_suc CHAR(4), dFechaPago DATE, pTipoPago CHAR(1))
RETURNING char(5), char(5);

       DEFINE vcodret   			char(5);
       DEFINE vcodretRev   			char(5);
	   DEFINE vcodretConv   		char(5);
       DEFINE sql_err   			integer;
       DEFINE vTrans    			char(4);
       DEFINE vFechaHoy 			date;
       DEFINE vSdoDisp  			money(14,2);
       DEFINE vMontoRet 			money(14,2);
       DEFINE vPasoCargo 			char(1);
	   Define vPasoAbono			char(1);
	   DEFINE vimpcomconvenio 		money(14,2);
	   DEFINE vIVAimpconvenio		money(14,2);
	   DEFINE vimpcomcte			money(14,2);
	   DEFINE vIVAimpcomcte			money(14,2);
	   DEFINE vImporteCompuesto		money(14,2);
	   DEFINE vIva_convenio			money(14,2);
	   DEFINE vCanal 				CHAR(2);

	   /*VARIABLES PARA CARGO CREDITO*/
	   DEFINE cod_retTc            	CHAR(5);
	   DEFINE SaldoCom            	MONEY(14,2);
	   DEFINE MtoCgo		   		MONEY(14,2);
	   DEFINE MtoCom		   		MONEY(12,2);
	   DEFINE MtoOtro				MONEY(14,2);

	    LET vPasoCargo 				= '0';
		LET vcodret 				= '000';
		LET vcodretRev 				= '000';
	    LET vcodretConv   			= '000';
	    LET vimpcomconvenio 		= 4;
	    LET vIVAimpconvenio			= 0;
	    LET vimpcomcte				= 0;
	    LET vIVAimpcomcte			= 0;
		LET vImporteCompuesto		= 0;
		LET vIva_convenio = 0;



		--SET DEBUG FILE TO '/home/informix/bibiana/sp_pago_servicios_gdf.out';
		--TRACE ON;

BEGIN
--si el sp falla checa si ya fue realizada la transaccion de Cargo y Abono, en caso de haber sido realizada una o ambas,
--se realiza la reversion de estas.
ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
		IF(pTipoPago=='D') THEN
			EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'A') INTO vcodretRev;
		ELSE
			EXECUTE PROCEDURE bdicred:"informix".reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'1') INTO vcodretRev;
		END IF;
		IF vcodretRev = '000' THEN
			LET vcodretRev = '004'; --Error no Controlado de SQL.
		END IF;
        LET vcodret = sql_err;
        RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');
       END IF;
END EXCEPTION;

/*
	SELECT iva_convenio INTO vIva_convenio FROM bdisac:"informix".sac_convenios where numcategoria = pCategoria and numconvenio = pConvenio;

	LET vIVAimpconvenio = vimpcomconvenio * (vIva_convenio/100);    	--calculo iva de convenio
	LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
*/
		SELECT id_canal INTO vCanal FROM bdinteg:"informix".si_canales WHERE descripcion_canal = 'PORTAL DE INTERNET';

        LET cRefVerificador = SUBSTRING(pReferencia FROM LENGTH(pReferencia) - 1 FOR 2);

	    EXECUTE PROCEDURE bdisac:"informix".sp_calcula_comisiones(pCategoria,
														pConvenio,
														pMonto,
														vCanal)
		INTO vcodretConv, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;

		--Validacion para checar que el sp_calcula_comisiones se ejecuto correctament y
		--despues valida el convenio , ejemplo si el pCategoria = 02 y el pConvenio = 001
		--es un pago telmex y se asignan las comisiones correspondientes.
	    if vcodretConv <> 0 THEN
			LET vcodretConv = '002'; --Error al ejecutar sp_calcula_comisiones
			RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');
		ELSE
			IF ( pCategoria IN ('08')) AND (pConvenio IN ('001')) THEN -- GDF (08,001)
			LET vImporteCompuesto = pMonto + vimpcomcte + vIVAimpcomcte;
			END IF;
		END IF;


	IF(pTipoPago=='D') THEN
		-- FLUJO PARA PAGO CON CARGO A DEBITO
		LET cTransacc_suc = pTransSuc;
		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											pSucursal,
											pUsuario,
											pTransCargo,
											pTransSuc,
											pFolioSuc,
											pNumCtaOrigen,
											pCheque,
											vImporteCompuesto,
											pMoneda,
											pReferencia,
											pNumTarjetaOrigen,
											pUsuAutoriza)
		INTO vcodret,vTrans, vFechaHoy, vSdoDisp,vMontoRet;

		IF vcodret <> '000' THEN
			EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'A') INTO vcodretRev;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '001';
			END IF;
			RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');
		ELSE
			LET vcodret = '00000';
		END IF;

	ELIF(pTipoPago=='C') THEN
		-- FLUJO PARA EL PAGO TDC
		EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(pEmpresa,pSucursal,pUsuario,pNumTarjetaOrigen,pMonto,pFolioSuc,cTransacc_suc) INTO cod_retTc, SaldoCom, MtoCgo, MtoCom, MtoOtro;
        --EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(pEmpresa,pSucursal,pUsuario,pNumTarjetaOrigen,pMonto,pFolioSuc,pTransSuc) INTO cod_retTc, SaldoCom, MtoCgo, MtoCom, MtoOtro;
		LET vSdoDisp = SaldoCom;
		LET vcodret = LPAD(TRIM(NVL(cod_retTc,'')), 5, ' ');
		IF(cod_retTc<>'000')THEN

				EXECUTE PROCEDURE bdicred:"informix".reversion(pEmpresa,
													pSucursal,
													pUsuario,
													pFolioSuc,
													'1') INTO vcodretRev;
				IF vcodretRev = '000' THEN
					LET vcodretRev = '001';
				END IF;
				RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');

		ELSE
			LET cod_retTc = '00000';
		END IF;
		LET vcodret = cod_retTc;
	ELSE
		--LA TRANSACCION DEBE ESPECIFICAR EL TIPO DE PAGO DEBITO (D) O CREDITO (C)
		LET vcodret = '00001';
	END IF;
	
	EXECUTE PROCEDURE bdisac:"informix".sp_grabapagoservicio(pSucursal,
													   pCategoria,
													   pConvenio,
													   cRefTelefono,
													   cRefVerificador,
													   cFormaPago,
													   pMonto,
													   vimpcomconvenio,
													   vIVAimpconvenio,
													   vimpcomcte,
													   vIVAimpcomcte,
													   cCuentaCargo,
													   pUsuario,
													   pFolioSuc,
													   cTransacc_suc,
													   dFechaPago)
		INTO vcodret;

		IF vcodret <> '00000' THEN
				EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
													pSucursal,
													pUsuario,
													pFolioSuc,
													'A') INTO vcodretRev;
				IF vcodretRev = '000' THEN
					LET vcodretRev = '003';
				END IF;
			RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');
		END IF;
	
	IF((vcodret='00000')OR(TRIM(vcodret)='000')) THEN
		--CONTINUA SOLO SI EL CARGO FUE CORRECTO
		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(pEmpresa,
											pSucursal,
											pUsuario,
											pTransAbono,
											pTransSuc,
											pFolioSuc,
											pNumCtaDestino,
											pDocto,
											vImporteCompuesto,
											vImporteCompuesto,
											pMontoSBC,
											pMontoRem,
											pDiasRet,
											pMoneda,
											pReferencia,
											pNumTarjetaDestino,
											pUsuAutoriza)
		INTO vcodret;

		IF vcodret <> '000' THEN
			EXECUTE PROCEDURE bdicheq:"informix".reversion(pEmpresa,
												pSucursal,
												pUsuario,
												pFolioSuc,
												'A') INTO vcodretRev;
			IF vcodretRev = '000' THEN
				LET vcodretRev = '002';
			END IF;
			RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');
		END IF;


	
	END IF;


	RETURN LPAD(TRIM(vcodret), 5, ' '), LPAD(TRIM(vcodretRev), 5, ' ');
	LET vcodret = '00000';

END;
END PROCEDURE;