CREATE PROCEDURE "informix".sp_guardainfotercerosctamec2(pUsuario CHAR(8), pNumCte CHAR(20), pCuenta CHAR(20), pTipoRec CHAR(1), 
		pSecuencia SMALLINT, pTipoPer CHAR(2), pNumPer CHAR(2), pNombre CHAR(40), pNacion CHAR(40), pRfc CHAR(13), pFirma CHAR(25), pDomicilio CHAR(200))
    RETURNING CHAR(5) AS cCodigoRetorno;
	
	-- VARIABLES --
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(3);
	
	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = "";

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardainfotercerosctamec2.out';
		--TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pNumCte, '') = '' OR NVL(pCuenta, '') = '' OR NVL(pTipoRec, '') = ''
		OR NVL(pSecuencia, '') = '' OR NVL(pNombre, '') = '' OR NVL(pNacion, '') = '' OR NVL(pRfc, '') = '' OR NVL(pFirma, '') = ''
		OR NVL(pDomicilio, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_regisrecterc(pUsuario, pNumCte, pCuenta, pTipoRec, pSecuencia, pTipoPer, pNumPer, pNombre, 
			pNacion, pRfc, pFirma, pDomicilio)
		INTO cCodRetSp;

		IF cCodRetSp = '200' THEN 
			LET cCodRet = '00009';	--EL NUMERO DE CUENTA NO EXISTE 
			RETURN cCodRet;
		ELIF cCodRetSp = '260' THEN
			LET cCodRet = '00022';	--EL NUMERO DE CLIENTE NO EXISTE
			RETURN cCodRet;
		ELIF cCodRetSp <> '000' THEN 
			LET cCodRet = cCodRetSp;	
			RETURN cCodRet;
		ELSE
			RETURN cCodRet;
		END IF;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'DESCRIPCION: sp clon sin validaciÃ³n de ejecutivo sp_guardainfotercerosctamec',
'FECHA: 12/09/2022',
'BASE DE DATOS: bdicnweb';

CREATE PROCEDURE "informix".sp_insertabitacoracomisiontc2(pUsuario CHAR(8), pNumCte CHAR(20),pCuenta CHAR(20),pComision CHAR(4),pTasaRend DECIMAL(11,6),pSdoPromMM MONEY(18,2),pMonMinAper MONEY(18,2),pComCgoNoSmm MONEY(18,2),pComCboAclaNP MONEY(18,2),pComChqGirCob MONEY(18,2),pComInaCta MONEY(18,2),pServTranSpei MONEY(18,2),pServTranTef MONEY(18,2),pServAnualidad MONEY(18,2),pServReenvToken MONEY(18,2),pServReepToken MONEY(18,2),pDispCtaBcoppel MONEY(18,2),pDispCtaOtrobco MONEY(18,2),pDispLinea MONEY(18,2))		
	RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(100);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cMensajeRet = '001';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertabitacoracomisiontc2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pNumCte = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_guardabittascomi_pm (pNumCte,pCuenta,pComision ,pTasaRend ,pSdoPromMM,pMonMinAper,pComCgoNoSmm,pComCboAclaNP,pComChqGirCob,pComInaCta ,pServTranSpei,pServTranTef,pServAnualidad,pServReenvToken,pServReepToken,pDispCtaBcoppel,pDispCtaOtrobco,pDispLinea,pUsuario)
		INTO cCodRetSp, cMensajeRet;
			LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_guardabittascomi_pm";
			ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';			
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;		
		END;		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;				
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'DESCRIPCION: sp clon sin validaciÃ³n de ejecutivo sp_insertabitacoracomisiontc',
'FECHA: 12/09/2022',
'BASE DE DATOS: bdicnweb';

CREATE PROCEDURE "informix".sp_insertactualizacomisiontc2(pNumCte CHAR(20),pCuenta CHAR(20), pTasaRend DECIMAL(9,2), pSdoPromMM MONEY(18,2), pMonMinAper MONEY(18,2), pComCgoNoSmm MONEY(18,2), pComCboAclaNP MONEY(18,2), pComChqGirCob MONEY(18,2), pComInaCta MONEY(18,2), pServTranSpei MONEY(18,2), pServTranTef MONEY(18,2), pServAnualidad MONEY(18,2), pServReenvToken MONEY(18,2), pServReepToken MONEY(18,2), pDispCtaBcoppel MONEY(18,2), pDispCtaOtrobco MONEY(18,2), pDispLinea MONEY(18,2))	
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR (100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertactualizacomisiontc2.out';
		--TRACE ON;
		
		IF pNumCte = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;	
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_guardatascomi_pm (pNumCte,pCuenta, pTasaRend, pSdoPromMM, pMonMinAper, pComCgoNoSmm, pComCboAclaNP, pComChqGirCob, pComInaCta, pServTranSpei, pServTranTef, pServAnualidad, pServReenvToken, pServReepToken, pDispCtaBcoppel, pDispCtaOtrobco, pDispLinea)
		INTO cCodRetSp, cMensajeRet;
			LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_guardatascomi_pm";
			ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';			
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;		
		END;		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;				
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'DESCRIPCION: sp clon sin validaciÃ³n de ejecutivo sp_insertactualizacomisiontc',
'FECHA: 12/09/2022',
'BASE DE DATOS: bdicnweb';

CREATE PROCEDURE "informix".sp_insertadoctopendienteimgdigitalizacion2(pUsuario CHAR(8), pCliente CHAR(20), pCuenta CHAR(20),  pProducto CHAR(4), pCodDocto CHAR(4), pProdNombre CHAR(40),
			pSecuencia INTEGER, pCtlArchivoLocal CHAR(25), pCtlArchivoLocalRuta CHAR(150), pCtlImgEnviada CHAR(1), pCtlProcesado CHAR(1), pCtlLigado CHAR(1), 
			pMacaddressLocal CHAR(17), pDescrip2 CHAR(30), pFechaAlta DATE)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertadoctopendienteimgdigitalizacion2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pCliente = '' OR pCuenta = '' OR pProducto = '' OR pCodDocto = '' OR  pProdNombre = '' OR pCtlImgEnviada = '' 
			OR pCtlProcesado = '' OR pCtlLigado = '' OR pMacaddressLocal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdidigital:"informix".sp_diginsertadoctopendienteimagen(cEmpresa, pCliente, pCuenta , pProducto, pCodDocto, pProdNombre, pSecuencia, pCtlArchivoLocal,
			pCtlArchivoLocalRuta, pCtlImgEnviada, pCtlProcesado, pCtlLigado, pMacaddressLocal, pDescrip2, pUsuario, pFechaAlta)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 000006 THEN
			LET cCodRet = '00386';	--PARAMETRO COD_DOCTO NO VALIDO
		ELIF iCodRetSp = 000011 THEN
			LET cCodRet = '00387';	--PARAMETRO CTL_IMG_ENVIADA NO VALIDO
		ELIF iCodRetSp = 000013 THEN
			LET cCodRet = '00384';	--PARAMETRO CTL_PROCESADO NO VALIDO
		ELIF iCodRetSp = 000015 THEN
			LET cCodRet = '00385';	--PARAMETRO CTL_LIGADO NO VALIDO
		END IF;
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 14/09/2022',
'DESCRIPCION: Se clona procedimiento almacenado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insertaimgpreviodigitalizacion2(pUsuario CHAR(8), pCliente CHAR(20), pCodDocto CHAR(4), pImgFormato CHAR(3))
		RETURNING CHAR(5) AS codret,
				  SMALLINT AS Secuencia;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE sSecuencia SMALLINT;
	DEFINE cQuery CHAR(1500);
	DEFINE cSvrRemoto CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET sSecuencia = 0;
	LET cQuery = '';
	LET cSvrRemoto = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sSecuencia;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertaimgpreviodigitalizacion2.out';
		--TRACE ON;		
		
		IF pUsuario = '' OR pCliente  = '' OR pCodDocto = '' OR pImgFormato = '' OR pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT	valor
		INTO cSvrRemoto
		FROM BDIDIGITAL:dg_params 
		WHERE empresa = cEmpresa 
		AND cod_param = '5';
		
		LET cQuery = "EXECUTE PROCEDURE" || " "||TRIM(cSvrRemoto)||"'informix'.inserta_img_previo_soc2('"||cEmpresa|| "','" ||TRIM(pCliente)||"','" ||pCodDocto|| "','" ||TRIM(pImgFormato)|| "','" ||pUsuario||"');";

		PREPARE countQry FROM TRIM(cQuery);
		DECLARE countcur CURSOR FOR countQry;
		OPEN countcur;
		FETCH countcur INTO cCodRetSp, sSecuencia;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
			ELIF iCodRetSp = 110 THEN
				LET cCodRet = '00003';
			END IF;
			RETURN cCodRet, sSecuencia;
		CLOSE countcur;
		FREE countcur;
		FREE countQry;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 07/08/2014',
'DESCRIPCION:  Se clono SP sp_insertaimgpreviodigitalizacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insertaregexpedientedigitalizacion2(pUsuario CHAR(8), pCliente CHAR(20), pCuenta CHAR(20), pProducto CHAR(4), pCodigoDocumento CHAR(4), pSecuencia SMALLINT, 
		pProductonombre CHAR(40), pDescrip2 CHAR(30))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertaregexpedientedigitalizacion2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pCliente = '' OR pCuenta = '' OR pProducto = '' OR pCodigoDocumento = '' OR pSecuencia = '' OR pProductonombre  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".inserta_reg_expediente(cEmpresa, pCliente, pCuenta, pProducto, pCodigoDocumento, pSecuencia, pProductonombre, pDescrip2, pUsuario)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003';
		END IF;
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/02/2023',
'DESCRIPCION:   inserta registro en dg_expediente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_consultainfocaratula(pNumProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS num_producto,
			CHAR(100) AS rango_promedio,
			CHAR(100) AS tasas_cete,
			CHAR(100) AS gat_nominal,
			CHAR(100) AS gat_real;
		
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cNumProducto     CHAR(4);
	DEFINE cRangoPromedio   CHAR(100);
	DEFINE cTasasCete       CHAR(100);
	DEFINE cGatNominal  	CHAR(100);
	DEFINE cGatReal  		CHAR(100);
	
	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET cNumProducto    = '';
	LET cRangoPromedio  = '';
	LET cTasasCete      = '';
	LET cGatNominal  	= '';
	LET cGatReal  		= '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, cRangoPromedio, cTasasCete, cGatNominal, cGatReal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_consultainfocaratula.out';
		--TRACE ON;
		
		IF pNumProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumProducto, cRangoPromedio, cTasasCete, cGatNominal, cGatReal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT num_producto, rango_promedio, tasas_cete, gat_nominal, gat_real 
		INTO cNumProducto, cRangoPromedio, cTasasCete, cGatNominal, cGatReal
		FROM "informix".sw_infocaratula WHERE num_producto = pNumProducto;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cNumProducto, cRangoPromedio, cTasasCete, cGatNominal, cGatReal;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'DESCRIPCION: sp clon sin validaciÃ³n de ejecutivo sp_sw_consultainfocatarula',
'FECHA: 12/09/2022',
'BASE DE DATOS: bdicnweb';

CREATE PROCEDURE "informix".sp_consfechadianteriorsac(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(10)  AS fecha_anterior,
				CHAR(10) AS fecha_actual;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechaAnterior DATE;
	DEFINE dFechaAcutal DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaAnterior = NULL;
	LET dFechaAcutal = NULL;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaAnterior, dFechaAcutal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/yoselin/sp_consfechadianteriorsac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaAnterior, dFechaAcutal;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaAnterior, dFechaAcutal;
		END IF;
		
		SELECT fecha_ant, fecha_hoy
		INTO dFechaAnterior, dFechaAcutal
		FROM bdinteg:si_fechas;
		
		IF dFechaAnterior = '' AND dFechaAcutal = '' THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFechaAnterior, dFechaAcutal;
		END IF;
		
		RETURN cCodRet, TO_CHAR(dFechaAnterior, "%d/%m/%Y") , TO_CHAR(dFechaAcutal, "%d/%m/%Y");
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/04/2014',
'DESCRIPCION: Consulta la fecha actual y anterior en bdinteg',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_borrado_errores_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND)
		RETURNING CHAR(5) AS codret
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfini/Eder/CashManagement/sp_borrado_errores_dotacion_masiva.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        DELETE FROM bdicnweb:"informix".tmp_arch_dot_suc_err 
		WHERE usuario_carga=pUsuario AND fecha_carga=pFecha;
           
        IF DBINFO('sqlca.sqlerrd2') = 0  THEN
            LET cCodRet = '00017';
		END IF;   
		
		RETURN cCodRet;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder Solis Lopez',
'FECHA: 27/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de borrar registros de error en carga de archivo de DotaciÃÂ³n masiva de sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_carga_archivo_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pRutaArchivo CHAR(40),pNombrearchivo CHAR(50))
RETURNING CHAR(5) AS codret,
			DATETIME YEAR TO SECOND AS Fecha,
			SMALLINT AS Errores,
			INTEGER AS totRegistrosOk,
			INTEGER AS totRegistrosNok,
			SMALLINT AS Err_suc_rep,
			SMALLINT AS Err_enc;

DEFINE vsqlerr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cSQL CHAR(4000);
DEFINE cSQL2 CHAR(4000);
DEFINE iTamReg INTEGER;
DEFINE banderaRegOK SMALLINT;
DEFINE bandera SMALLINT;
DEFINE cEstatusValidaciones CHAR(3);
DEFINE cTotRegistrosOk INTEGER;
DEFINE cTotRegistrosNok INTEGER;

DEFINE cIdRegistro INTEGER;
DEFINE cMinReg INTEGER;
DEFINE cCadena CHAR(8000);
DEFINE cCampo CHAR(50);
DEFINE iCampo INTEGER;
DEFINE iNoRegistros INTEGER;

DEFINE cErrores CHAR(8000);
DEFINE cCamposOk CHAR(8000);

DEFINE fechaSolicitud DATE;
DEFINE fechaAplicacion DATE; 
DEFINE c_ccSucursal CHAR(4);
DEFINE nombreSucursal CHAR(40);
DEFINE plaza CHAR(50);
DEFINE tipoOperacion CHAR(20);
DEFINE billete1000 SMALLINT;
DEFINE billete500 SMALLINT;
DEFINE billete200 SMALLINT;
DEFINE billete100 SMALLINT;
DEFINE billete50 SMALLINT;
DEFINE billete20 SMALLINT;
DEFINE totalBilletes SMALLINT;
DEFINE moneda100 SMALLINT;
DEFINE moneda50 SMALLINT;
DEFINE moneda20 SMALLINT;
DEFINE moneda10 SMALLINT;
DEFINE moneda5 SMALLINT;
DEFINE moneda2 SMALLINT;
DEFINE moneda1 SMALLINT;
DEFINE moneda50c SMALLINT;
DEFINE totalMonedas SMALLINT;
DEFINE totalImporte DECIMAL(18,2);

DEFINE ccSucursal_tmp INTEGER;
DEFINE nombreCampoActual CHAR(30);
DEFINE iTotCampos INTEGER;
DEFINE cContErrores INTEGER;
DEFINE cContErroresGlob INTEGER;
DEFINE cErr_suc_rep INTEGER;
DEFINE cErr_enc INTEGER;

DEFINE dtcurr DATETIME YEAR TO SECOND;

DEFINE valFechaAplicacion1 DATE;
DEFINE validRegistro1 INTEGER;

DEFINE valFechaAplicacion2 DATE;
DEFINE validRegistro2 INTEGER;

DEFINE valdiffFechas INTEGER;
DEFINE ctotalMonedas INTEGER;
DEFINE ctotalImporte DECIMAL(18,2);
DEFINE ctotalBilletes INTEGER;

--NUEVOS
	DEFINE cImporte1000 INTEGER;
	DEFINE cImporte500 INTEGER;
	DEFINE cImporte200 INTEGER;
	DEFINE cImporte100 INTEGER;
	DEFINE cImporte50 INTEGER;
	DEFINE cImporte20 INTEGER;
	DEFINE cImporteTotalBilletes INTEGER;
	
	DEFINE cImporteM100 INTEGER;
	DEFINE cImporteM50 INTEGER;
	DEFINE cImporteM20 INTEGER;
	DEFINE cImporteM10 INTEGER;
	DEFINE cImporteM5 INTEGER;
	DEFINE cImporteM2 INTEGER;
	DEFINE cImporteM1 INTEGER;
	DEFINE cImporteM50c DECIMAL(16,2);
	DEFINE cImporteTotalMonedas DECIMAL(16,2);


LET vsqlerr = 0;
LET cCodRet = '00000';
LET cSQL ='';
LET cSQL2 ='';
LET cErrores='';
LET cCamposOk='';
LET iTamReg=0;
LET banderaRegOK=1;
LET bandera=0;
LET cEstatusValidaciones='';

LET cIdRegistro=0;
LET cMinReg=0;
LET cCadena='';
LET cCampo='';
LET iCampo=0;
LET iNoRegistros=1;
LET cTotRegistrosOk =0;
LET cTotRegistrosNok =0;

LET fechaSolicitud =NULL;
LET fechaAplicacion =NULL;
LET c_ccSucursal ='';
LET nombreSucursal ='';
LET plaza ='';
LET tipoOperacion ='';
LET billete1000=0;
LET billete500=0;
LET billete200=0;
LET billete100=0;
LET billete50=0;
LET billete20=0;
LET totalBilletes=0;
LET moneda100=0;
LET moneda50=0;
LET moneda20=0;
LET moneda10=0;
LET moneda5=0;
LET moneda2=0;
LET moneda1=0;
LET moneda50c=0;
LET totalMonedas=0;
LET totalImporte=0;

LET ccSucursal_tmp =0;
LET nombreCampoActual ='';
LET iTotCampos=0;
LET cContErrores=0;
LET cContErroresGlob=0;
LET cErr_suc_rep=0;
LET cErr_enc = 0;

LET valFechaAplicacion1 ='';
LET validRegistro1 =0;
LET valFechaAplicacion2 ='';
LET validRegistro2 =0;

LET dtcurr = CURRENT;

LET valdiffFechas=0;

LET ctotalMonedas=0;
LET ctotalImporte=0;
LET ctotalBilletes =0;

-- NUEVOS
	LET cImporte1000 = 0;
	LET cImporte500 = 0;
	LET cImporte200 = 0;
	LET cImporte100 = 0;
	LET cImporte50 = 0;
	LET cImporte20 = 0;
	
	LET cImporteTotalBilletes = 0;
	
	LET cImporteM100 = 0;
	LET cImporteM50 = 0;
	LET cImporteM20 = 0;
	LET cImporteM10 = 0;
	LET cImporteM5 = 0;
	LET cImporteM2 = 0;
	LET cImporteM1 = 0;
	LET cImporteM50c = 0;
	
	LET cImporteTotalMonedas = 0;
	

BEGIN

-- CONTROL DE ERRORES

	ON EXCEPTION IN (-668,-535,-255)	
		COMMIT WORK;
	END EXCEPTION WITH RESUME;	

	
	ON EXCEPTION SET vsqlerr
		LET cCodRet = vsqlerr;
		IF (vsqlerr=-668) THEN
			LET cCodRet='00002';
			LET dtcurr='';
		END IF;
        RETURN cCodRet,dtcurr,bandera,cTotRegistrosOk,cTotRegistrosNok,cErr_suc_rep,cErr_enc;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_carga_archivo_dotacion_masiva.out';
	--TRACE ON;
	
	IF pUsuario = '' OR pIdFuncion = '' OR pNombrearchivo='' OR pRutaArchivo='' THEN
		LET cCodRet = '00003';
		RETURN cCodRet,dtcurr,bandera,cTotRegistrosOk,cTotRegistrosNok,cErr_suc_rep,cErr_enc;
	END IF;
	
-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
	INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet,dtcurr,bandera,cTotRegistrosOk,cTotRegistrosNok,cErr_suc_rep,cErr_enc;
	END IF;

	DELETE FROM bdicnweb:"informix".tmp_arch_dot_suc WHERE usuario_carga=pUsuario;
	DELETE FROM bdicnweb:"informix".tmp_arch_dot_suc_err WHERE usuario_carga=pUsuario;
	DELETE FROM bdicnweb:"informix".tmp_arch_dot_suc_det WHERE usuario_carga=pUsuario;
	
--MODIFICACION DE ARCHIVO
	
	LET cSQL = "sed 's/^/"||TRIM(pUsuario)||","||dtcurr||","||TRIM(pNombrearchivo)||",/' "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||" > "||TRIM(pRutaArchivo)||'N'||TRIM(pNombrearchivo);
	SYSTEM cSQL;	

-- CARGA DE ARCHIVO
LET cSQL = '';
LET cSQL = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||'N'||TRIM(pNombrearchivo)||" DELIMITER "||'","'||" INSERT INTO bdicnweb:tmp_arch_dot_suc(";
LET cSQL = TRIM(cSQL)||"usuario_carga,fecha_carga,nombre_archivo,cadena)' | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1";
	
SYSTEM TRIM(cSQL);


-- SE ELIMINA EL ARCHIVO MODIFICADO
LET cSQL = '';
LET cSQL = '/usr/bin/rm -rf '||TRIM(pRutaArchivo)||'N'||TRIM(pNombrearchivo);
SYSTEM TRIM(cSQL);


	SELECT min(idRegistro)+1
	INTO cMinReg
	FROM bdicnweb:"informix".tmp_arch_dot_suc
	WHERE TRIM(usuario_carga)=pUsuario and TRIM(fecha_carga)=dtcurr;

	LET cSQL = 'SELECT SKIP '||iNoRegistros||' (idRegistro-'||cMinReg||'),TRIM(REPLACE(REPLACE(cadena,''||'',''|.|''),''||'',''|.|'')),LENGTH(TRIM(cadena)) - LENGTH( TRIM(REPLACE ( TRIM(cadena), "|", "")) ) FROM bdicnweb:"informix".tmp_arch_dot_suc WHERE TRIM(usuario_carga)='''||pUsuario||''' and TRIM(fecha_carga)='''||dtcurr||'''';
	PREPARE stmtId FROM TRIM(cSQL);
	DECLARE selectQryCur CURSOR FOR stmtId;
	OPEN selectQryCur;
	FETCH selectQryCur 
	INTO cIdRegistro,cCadena,iTotCampos;
	
	WHILE(SQLCODE == 0)	
		LET cContErrores=0;
		LET iNoRegistros = iNoRegistros + 1;
		
		IF iTotCampos!=22 THEN
			INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
																	values (cIdRegistro+1,'','Campos incompletos en el registro.',pUsuario,dtcurr);
			LET cContErrores=cContErrores+1;
			LET cErr_enc = cErr_enc+1;
		END IF;
		
		LET iTamReg = LENGTH(TRIM(cCadena));
		LET cCadena= SUBSTR(TRIM(cCadena), 0, (iTamReg - 1));
		
		LET iCampo=0;
		
		LET cSQL2 = 'execute function regex_split('''||TRIM(cCadena)||"', '\|')";
		PREPARE stmtId2 FROM TRIM(cSQL2);
		DECLARE selectQryCur2 CURSOR FOR stmtId2;
		OPEN selectQryCur2;
		FETCH selectQryCur2 
		INTO cCampo;
		
		WHILE(SQLCODE == 0)	
			ON EXCEPTION IN (-1205,-1204,-1277,-1263)	
				LET banderaRegOK = 0;
				LET cErrores = TRIM(cErrores)||'; Registro ['||cIdRegistro+1||','||iCampo||'] '||TRIM(nombreCampoActual)||': '||REPLACE(cCampo,'.','');
				INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
													values (cIdRegistro+1,TRIM(nombreCampoActual),'Formato no valido: '||REPLACE(cCampo,'.',''),pUsuario,dtcurr);
				LET cContErrores=cContErrores+1;
			END EXCEPTION WITH RESUME;	
			ON EXCEPTION IN (-1213)	
				LET banderaRegOK = 0;
				LET cErrores = TRIM(cErrores)||'; Registro ['||cIdRegistro+1||','||iCampo||'] '||TRIM(nombreCampoActual)||': '||REPLACE(cCampo,'.','');
				INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
													values (cIdRegistro+1,TRIM(nombreCampoActual),'El CC Sucursal no es un dato numérico: '||REPLACE(cCampo,'.',''),pUsuario,dtcurr);
				LET cContErrores=cContErrores+1;
			END EXCEPTION WITH RESUME;	
			ON EXCEPTION IN (-746)	
				LET banderaRegOK = 0;
				LET cErrores = TRIM(cErrores)||'; Registro ['||cIdRegistro+1||','||iCampo||'] '||TRIM(nombreCampoActual)||': '||REPLACE(cCampo,'.','');
				INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
															values (cIdRegistro+1,TRIM(nombreCampoActual),'El CC Sucursal no cumple con la longitud correcta (4 dígitos): '||REPLACE(cCampo,'.',''),pUsuario,dtcurr);
				LET cContErrores=cContErrores+1;
			END EXCEPTION WITH RESUME;	
			
			LET iCampo=iCampo+1;
			LET banderaRegOK=1;
			
			IF iCampo=1 THEN
				LET nombreCampoActual = 'Fecha de Solicitud';
				LET fechaSolicitud=TO_DATE(TRIM(cCampo), '%Y-%m-%d');
			ELIF iCampo=2 THEN
				LET nombreCampoActual = 'Fecha de Aplicacion';
				LET fechaAplicacion=TO_DATE(TRIM(cCampo), '%Y-%m-%d');
			ELIF iCampo=3 THEN	
				LET nombreCampoActual = 'CC Sucursal';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				LET c_ccSucursal = TRIM(cCampo);
				IF LENGTH(cCampo)!=4 THEN
					RAISE EXCEPTION -746,0;
				END IF;
			ELIF iCampo=4 THEN	
				LET nombreCampoActual = 'Nombre de la Sucursal';
				IF (LENGTH(TRIM(cCampo))>40 OR cCampo='.' ) THEN
					RAISE EXCEPTION -746,0;
				END IF;
				LET nombreSucursal=TRIM(cCampo);
			ELIF iCampo=5 THEN	
				LET nombreCampoActual = 'Plaza';
				IF LENGTH(TRIM(cCampo))>50 OR cCampo='.' THEN
					RAISE EXCEPTION -746,0;
				END IF;
				LET plaza=TRIM(cCampo);
			ELIF iCampo=6 THEN	
				LET nombreCampoActual = 'Tipo de Operacion';
				IF LENGTH(TRIM(cCampo))>20 OR cCampo='.' THEN
					RAISE EXCEPTION -746,0;
				END IF;
				LET tipoOperacion=TRIM(cCampo);	
			ELIF iCampo=7 THEN	
				LET nombreCampoActual = 'Billete $1000';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET billete1000 = ccSucursal_tmp;
			ELIF iCampo=8 THEN	
				LET nombreCampoActual = 'Billete $500';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET billete500 = ccSucursal_tmp;
			ELIF iCampo=9 THEN	
				LET nombreCampoActual = 'Billete $200';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET billete200 = ccSucursal_tmp;
			ELIF iCampo=10 THEN	
				LET nombreCampoActual = 'Billete $100';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET billete100 = ccSucursal_tmp;
			ELIF iCampo=11 THEN	
				LET nombreCampoActual = 'Billete $50';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET billete50 = ccSucursal_tmp;
			ELIF iCampo=12 THEN	
				LET nombreCampoActual = 'Billete $20';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET billete20 = ccSucursal_tmp;
			ELIF iCampo=13 THEN	
				LET nombreCampoActual = 'Total Billetes';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET totalBilletes = ccSucursal_tmp;
			ELIF iCampo=14 THEN	
				LET nombreCampoActual = 'Moneda $100';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda100 = ccSucursal_tmp;
			ELIF iCampo=15 THEN	
				LET nombreCampoActual = 'Moneda $50';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda50 = 0; --ccSucursal_tmp;
			ELIF iCampo=16 THEN	
				LET nombreCampoActual = 'moneda20';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda20 = 0; --ccSucursal_tmp;
			ELIF iCampo=17 THEN	
				LET nombreCampoActual = 'Moneda $10';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda10 = ccSucursal_tmp;
			ELIF iCampo=18 THEN	
				LET nombreCampoActual = 'Moneda $5';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda5 = ccSucursal_tmp;
			ELIF iCampo=19 THEN	
				LET nombreCampoActual = 'Moneda $2';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda2 = ccSucursal_tmp;
			ELIF iCampo=20 THEN	
				LET nombreCampoActual = 'Moneda $1';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda1 = ccSucursal_tmp;
			ELIF iCampo=21 THEN	
				LET nombreCampoActual = 'Moneda $0.50';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET moneda50c = ccSucursal_tmp;
			ELIF iCampo=22 THEN	
				LET nombreCampoActual = 'Total Monedas';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET totalMonedas = ccSucursal_tmp;
			ELIF iCampo=23 THEN	
				LET nombreCampoActual = 'Total en Importe';
				LET ccSucursal_tmp=TO_NUMBER(cCampo);
				IF  ccSucursal_tmp<0 THEN
					RAISE EXCEPTION -1213,0;
				END IF;
				LET totalImporte = ccSucursal_tmp;

			END IF;

				LET cImporte1000 = billete1000 * 1000;
				LET cImporte500 = billete500 * 500;
				LET cImporte200 = billete200 * 200;
				LET cImporte100 = billete100 * 100;
				LET cImporte50 = billete50 * 50;
				LET cImporte20 = billete20 * 20;
				LET ctotalBilletes = cImporte1000 + cImporte500 + cImporte200 + cImporte100 + cImporte50 + cImporte20;
				
				
				LET cImporteM100 = moneda100 * 100;
				LET cImporteM50 = moneda50 * 50;
				LET cImporteM20 = moneda20 * 20;
				LET cImporteM10 = moneda10 * 10;
				LET cImporteM5 = moneda5 * 5;
				LET cImporteM2 = moneda2 * 2;
				LET cImporteM1 = moneda1 * 1;
				LET cImporteM50c = moneda50c * 0.5;
				
				LET ctotalMonedas = cImporteM100 + cImporteM50 + cImporteM20 + cImporteM10 + cImporteM5 + cImporteM2 + cImporteM1 + cImporteM50c;
				
				LET ctotalImporte = ctotalBilletes + ctotalMonedas;

						
			FETCH selectQryCur2 
			INTO cCampo;
			
		END WHILE;
		
		CLOSE selectQryCur2;
		FREE selectQryCur2;
		FREE stmtId2;
		
		--VALIDACION DE FECHAS
		IF fechasolicitud=fechaaplicacion THEN
			INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
				values (cIdRegistro+1,'Fecha de Aplicacion','La Fecha de Aplicación debe ser diferente a la Fecha de Solicitud',pUsuario,dtcurr);
			LET cContErrores = cContErrores+1;
		END IF;
		
		IF fechasolicitud>=fechaaplicacion THEN
			INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
				values (cIdRegistro+1,'Fecha de Aplicacion','La Fecha de Aplicación debe ser posterior a la Fecha de Solicitud',pUsuario,dtcurr);
			LET cContErrores = cContErrores+1;
		END IF;
		
		--INSERTAMOS REGISTRO POR CAMPOS
		IF(cContErrores=0) THEN
			LET cEstatusValidaciones='ok';
		ELSE 
			LET cEstatusValidaciones='nok';
		END IF;
		INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_det (estatusValidaciones,fechasolicitud,fechaaplicacion,ccsucursal,nombresucursal,plaza,tipooperacion,billete1000,billete500,billete200,billete100,billete50,billete20,ctotalBilletes,moneda100,moneda50,moneda20,moneda10,moneda5,moneda2,moneda1,moneda50c,ctotalMonedas,ctotalImporte,usuario_carga,fecha_carga,nombre_archivo) 
						values (cEstatusValidaciones,fechasolicitud,fechaaplicacion,c_ccSucursal,nombresucursal,plaza,tipooperacion,billete1000,billete500,billete200,billete100,billete50,billete20,totalbilletes,moneda100,moneda50,moneda20,moneda10,moneda5,moneda2,moneda1,moneda50c,totalmonedas,totalimporte,pUsuario,dtcurr,pNombrearchivo);
		
				
		LET cContErroresGlob = cContErroresGlob+cContErrores;
		LET cContErrores=0;
		FETCH selectQryCur INTO cIdRegistro,cCadena,iTotCampos;
	END WHILE;
		
	CLOSE selectQryCur;
	FREE selectQryCur;
	FREE stmtId;
	
	SELECT min(idRegistro)
	INTO cMinReg
	FROM bdicnweb:"informix".tmp_arch_dot_suc_det
	where 	
		TRIM(usuario_carga)=pUsuario and 
		TRIM(fecha_carga)=dtcurr;
	
	--VALIDACION DE SUCURSALES EXISTENTES
	FOREACH
		select a.ccsucursal,a.idregistro
		INTO c_ccSucursal,cIdRegistro
		from bdicnweb:"informix".tmp_arch_dot_suc_det a
		LEFT JOIN bdinteg:"informix".si_sucursales suc on a.ccsucursal=suc.sucursal
		where 	
			TRIM(a.usuario_carga)=pUsuario and 
			TRIM(a.fecha_carga)=dtcurr AND 
			suc.sucursal is null
		ORDER BY a.idregistro
		
		INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
															values (cIdRegistro+1-cMinReg,'CC Sucursal','La Sucursal '||TRIM(c_ccSucursal)||' no existe',pUsuario,dtcurr);
		UPDATE bdicnweb:"informix".tmp_arch_dot_suc_det
		SET estatusValidaciones='nok'
		WHERE TRIM(usuario_carga)=pUsuario and 
				TRIM(fecha_carga)=dtcurr AND 
				idregistro=cIdRegistro;
		
		LET cContErroresGlob=cContErroresGlob+1;
	END FOREACH;
	
	--VALIDACION DE SUCURSALES REPETIDAS >4
	FOREACH
		select count(a.ccsucursal) total,a.ccsucursal,a.idRegistro
		INTO cContErrores,c_ccSucursal,cIdRegistro
		from bdicnweb:"informix".tmp_arch_dot_suc_det a
		inner join 
		(	
			select ccsucursal,idRegistro
			from
			(
				select row_number() over(partition by ccsucursal order by idRegistro) as row_num, ccsucursal,idRegistro
				from bdicnweb:"informix".tmp_arch_dot_suc_det 
				where 	
				TRIM(usuario_carga)=pUsuario
				and TRIM(fecha_carga)=dtcurr
			)
			--where row_num=1
		) b on a.ccsucursal=b.ccsucursal
			where 	
			TRIM(a.usuario_carga)=pUsuario
			and TRIM(a.fecha_carga)=dtcurr 
		group by a.ccsucursal,a.idRegistro
		having count(a.ccsucursal)>4
		ORDER BY a.idregistro
		
		INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
															values (cIdRegistro+1-cMinReg,'CC Sucursal','Registros duplicados mayor a 4 registros por Sucursal.',pUsuario,dtcurr);
		
		UPDATE bdicnweb:"informix".tmp_arch_dot_suc_det
		SET estatusValidaciones='nok'
		WHERE TRIM(usuario_carga)=pUsuario and 
				TRIM(fecha_carga)=dtcurr AND 
				ccsucursal=c_ccSucursal;
		
		LET cErr_suc_rep= cErr_suc_rep+1;
		LET cContErroresGlob=cContErroresGlob+1;
	END FOREACH;
	
	--VALIDACION DE SUCURSALES REPETIDAS <4
	
	FOREACH
		select count(a.ccsucursal) total,a.ccsucursal,b.idRegistro
		INTO cContErrores,c_ccSucursal,cIdRegistro
		from bdicnweb:"informix".tmp_arch_dot_suc_det a
		inner join 
		(
			select ccsucursal,idRegistro
			from
			(
				select row_number() over(partition by ccsucursal order by idRegistro) as row_num, ccsucursal,idRegistro
				from bdicnweb:"informix".tmp_arch_dot_suc_det 
				where 	
				TRIM(usuario_carga)=pUsuario
				and TRIM(fecha_carga)=dtcurr
			)
			where row_num=1
		) b on a.ccsucursal=b.ccsucursal
		where 	
			TRIM(a.usuario_carga)=pUsuario and 
			TRIM(a.fecha_carga)=dtcurr 
		group by a.ccsucursal,b.idRegistro
		having count(a.ccsucursal)>1 and count(a.ccsucursal)<=4
		ORDER BY b.idregistro
		
		LET valFechaAplicacion2='';
		
		FOREACH
			select a.fechaAplicacion,row_number() over(partition by ccsucursal order by idRegistro) as row_num,idRegistro
			INTO valFechaAplicacion2,validRegistro2,cIdRegistro
			from bdicnweb:"informix".tmp_arch_dot_suc_det a
			where TRIM(a.usuario_carga)=pUsuario and 
				TRIM(a.fecha_carga)=dtcurr AND a.ccsucursal=c_ccSucursal
			
			LET cSQL2 = 'select fechaAplicacion,b.fechaPrim,abs(fechaAplicacion-b.fechaPrim),idRegistro from ( ';
			LET cSQL2 = TRIM(cSQL2)||' select fechaAplicacion,row_number() over(partition by ccsucursal order by idRegistro) as row_num,idRegistro ';
			LET cSQL2 = TRIM(cSQL2)||' from bdicnweb:"informix".tmp_arch_dot_suc_det ';
			LET cSQL2 = TRIM(cSQL2)||' where ';
			LET cSQL2 = TRIM(cSQL2)||' TRIM(usuario_carga)='''||pUsuario||''' AND ';
			LET cSQL2 = TRIM(cSQL2)||' TRIM(fecha_carga)='''||dtcurr||''' AND ';
			LET cSQL2 = TRIM(cSQL2)||' ccsucursal='''||c_ccSucursal||'''';
			LET cSQL2 = TRIM(cSQL2)||' ) a , ( ';
			LET cSQL2 = TRIM(cSQL2)||' select fechaAplicacion fechaPrim ';
			LET cSQL2 = TRIM(cSQL2)||' from bdicnweb:"informix".tmp_arch_dot_suc_det ';
			LET cSQL2 = TRIM(cSQL2)||' where ';
			LET cSQL2 = TRIM(cSQL2)||' TRIM(usuario_carga)='''||pUsuario||''' AND ';
			LET cSQL2 = TRIM(cSQL2)||' TRIM(fecha_carga)='''||dtcurr||''' AND ';
			LET cSQL2 = TRIM(cSQL2)||' ccsucursal='''||c_ccSucursal||''' AND ';
			LET cSQL2 = TRIM(cSQL2)||' idRegistro='||cIdRegistro||'';
			LET cSQL2 = TRIM(cSQL2)||' )b ';
			LET cSQL2 = TRIM(cSQL2)||' where row_num!='||validRegistro2;
				
			PREPARE stmtId3 FROM TRIM(cSQL2);
			DECLARE selectQryCur3 CURSOR FOR stmtId3;
			OPEN selectQryCur3;
			FETCH selectQryCur3 
			INTO valFechaAplicacion1,valFechaAplicacion2,valdiffFechas,validRegistro1;
			
				
			IF valdiffFechas>4 THEN
				INSERT INTO bdicnweb:"informix".tmp_arch_dot_suc_err (noRegistro,campo,descripcion,usuario_carga,fecha_carga) 
										values (cIdRegistro+1-cMinReg,'CC Sucursal','Registros duplicados por Sucursal.',pUsuario,dtcurr);
				
				UPDATE bdicnweb:"informix".tmp_arch_dot_suc_det
				SET estatusValidaciones='nok'
				WHERE TRIM(usuario_carga)=pUsuario and 
						TRIM(fecha_carga)=dtcurr AND 
						idregistro=cIdRegistro;
				
				LET cErr_suc_rep= cErr_suc_rep+1;
				LET cContErroresGlob=cContErroresGlob+1;
			END IF;
			CLOSE selectQryCur3;
			FREE selectQryCur3;
			FREE stmtId3;	
		
			
		END FOREACH;
			
		
	END FOREACH;
	
	IF cContErroresGlob!=0 THEN
		LET bandera=1;
	END IF;
	
	select count(1)
	into cTotRegistrosOk
	from bdicnweb:"informix".tmp_arch_dot_suc_det
	WHERE TRIM(usuario_carga)=pUsuario and 
		TRIM(fecha_carga)=dtcurr AND 
		estatusValidaciones='ok';
	
	select count(1)
	into cTotRegistrosNok
	from bdicnweb:"informix".tmp_arch_dot_suc_det
	WHERE TRIM(usuario_carga)=pUsuario and 
		TRIM(fecha_carga)=dtcurr AND 
		estatusValidaciones='nok';
		
	IF cErr_suc_rep>0 THEN
		LET cErr_suc_rep=1;
	END IF;
	
	IF cErr_enc>0 THEN
		LET cErr_enc=1;
	END IF;
	
	IF cErr_enc>0 THEN
		LET cErr_enc=1;
	END IF;

END

RETURN cCodRet,dtcurr,bandera,cTotRegistrosOk,cTotRegistrosNok,cErr_suc_rep,cErr_enc;
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 26/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de cargar archivo de DotaciÃ³n masiva de sucursales y realizar validaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_actsolicitudes(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pFolio CHAR(8))
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoOperacion CHAR(25);
	DEFINE cDescActualiza CHAR(20);
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTipoOperacion = '';
	LET cDescActualiza = '';
	LET iRecuperacion = 0;	
	LET cStatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_actsolicitudes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pFolio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--REVERSO
		UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '08' 
		WHERE sucursal = pSucursal AND folio_oper = pFolio;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00283';
			RETURN cCodRet;
		END IF;
			
		UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1' 
		WHERE sucursal = pSucursal AND folio_oper = pFolio;
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00283';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 15/06/2023',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: ENVIO SOLICITUD DOTACION',
'DESCRIPCION: Procedimiento almacenado encargado de realizar la actualización de información en ss_operaciones, ss_mae_entradasalida';

CREATE PROCEDURE "informix".sp_con_carga_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE AS fechaSolicitud,
				DATE AS fechaAplicacion,
				CHAR(4) AS ccSucursal,
				CHAR(40) AS nombreSucursal,
				CHAR(50) AS plaza,
				CHAR(20) AS tipoOperacion,
				SMALLINT AS billete1000,
				SMALLINT AS billete500,
				SMALLINT AS billete200,
				SMALLINT AS billete100,
				SMALLINT AS billete50,
				SMALLINT AS billete20,
				INTEGER AS totalBilletes,
				SMALLINT AS moneda100,
				SMALLINT AS moneda50,
				SMALLINT AS moneda20,
				SMALLINT AS moneda10,
				SMALLINT AS moneda5,
				SMALLINT AS moneda2,
				SMALLINT AS moneda1,
				SMALLINT AS moneda50c,
				INTEGER AS totalMonedas,
				MONEY AS totalImporte
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cfechaSolicitud DATE;
	DEFINE cfechaAplicacion DATE;
	DEFINE cccSucursal CHAR(4);
    DEFINE cnombreSucursal CHAR(40);
	DEFINE cplaza CHAR(50);
	DEFINE ctipoOperacion CHAR(20);
	DEFINE cbillete1000 SMALLINT;
	DEFINE cbillete500 SMALLINT;
	DEFINE cbillete200 SMALLINT;
	DEFINE cbillete100 SMALLINT;
	DEFINE cbillete50 SMALLINT;
	DEFINE cbillete20 SMALLINT;
    DEFINE ctotalBilletes INTEGER;
	DEFINE cmoneda100 SMALLINT;
	DEFINE cmoneda50 SMALLINT;
	DEFINE cmoneda20 SMALLINT;
	DEFINE cmoneda10 SMALLINT;
	DEFINE cmoneda5 SMALLINT;
	DEFINE cmoneda2 SMALLINT;
	DEFINE cmoneda1 SMALLINT;
	DEFINE cmoneda50c SMALLINT;
	DEFINE ctotalMonedas INTEGER;
	DEFINE ctotalImporte MONEY;
	
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cImporte1000 INTEGER;
	DEFINE cImporte500 INTEGER;
	DEFINE cImporte200 INTEGER;
	DEFINE cImporte100 INTEGER;
	DEFINE cImporte50 INTEGER;
	DEFINE cImporte20 INTEGER;
	DEFINE cImporteTotalBilletes INTEGER;
	
	DEFINE cImporteM100 INTEGER;
	DEFINE cImporteM50 INTEGER;
	DEFINE cImporteM20 INTEGER;
	DEFINE cImporteM10 INTEGER;
	DEFINE cImporteM5 INTEGER;
	DEFINE cImporteM2 INTEGER;
	DEFINE cImporteM1 INTEGER;
	DEFINE cImporteM50c DECIMAL(16,2);
	DEFINE cImporteTotalMonedas DECIMAL(16,2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	LET cfechaSolicitud='';
	LET cfechaAplicacion='';
	LET cccSucursal='';
	LET cnombreSucursal='';
	LET cplaza='';
	LET ctipoOperacion='';
	LET cbillete1000=0;
	LET cbillete500=0;
	LET cbillete200=0;
	LET cbillete100=0;
	LET cbillete50=0;
	LET cbillete20=0;
	LET ctotalBilletes=0;
	LET cmoneda100=0;
	LET cmoneda50=0;
	LET cmoneda20=0;
	LET cmoneda10=0;
	LET cmoneda5=0;
	LET cmoneda2=0;
	LET cmoneda1=0;
	LET cmoneda50c=0;
	LET ctotalMonedas=0;
	LET ctotalImporte=0;
	
	LET iNoRegistros=0;
	
	
	LET cImporte1000 = 0;
	LET cImporte500 = 0;
	LET cImporte200 = 0;
	LET cImporte100 = 0;
	LET cImporte50 = 0;
	LET cImporte20 = 0;
	
	LET cImporteTotalBilletes = 0;
	
	LET cImporteM100 = 0;
	LET cImporteM50 = 0;
	LET cImporteM20 = 0;
	LET cImporteM10 = 0;
	LET cImporteM5 = 0;
	LET cImporteM2 = 0;
	LET cImporteM1 = 0;
	LET cImporteM50c = 0;
	
	LET cImporteTotalMonedas = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_carga_dotacion_masiva.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte;
		END IF;
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte;
        END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        FOREACH 
            SELECT SKIP pRegistros FIRST pRecuperacion 
				fechasolicitud,fechaaplicacion,ccsucursal,nombresucursal,plaza,tipooperacion,billete1000,billete500,billete200,billete100,billete50,billete20,totalbilletes,moneda100,moneda50,moneda20,moneda10,moneda5,moneda2,moneda1,moneda50c,totalmonedas,totalimporte
            INTO cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte
			FROM bdicnweb:"informix".tmp_arch_dot_suc_det 
			WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
				AND estatusValidaciones='ok'
            
            LET iNoRegistros = iNoRegistros + 1;
			
			LET cImporte1000 = cbillete1000 * 1000;
			LET cImporte500 = cbillete500 * 500;
			LET cImporte200 = cbillete200 * 200;
			LET cImporte100 = cbillete100 * 100;
			LET cImporte50 = cbillete50 * 50;
			LET cImporte20 = cbillete20 * 20;
			LET ctotalBilletes = cImporte1000 + cImporte500 + cImporte200 + cImporte100 + cImporte50 + cImporte20;
			
			
			LET cImporteM100 = cmoneda100 * 100;
			LET cImporteM50 = cmoneda50 * 50;
			LET cImporteM20 = cmoneda20 * 20;
			LET cImporteM10 = cmoneda10 * 10;
			LET cImporteM5 = cmoneda5 * 5;
			LET cImporteM2 = cmoneda2 * 2;
			LET cImporteM1 = cmoneda1 * 1;
			LET cImporteM50c = cmoneda50c * 0.5;
			
			LET ctotalMonedas = cImporteM100 + cImporteM50 + cImporteM20 + cImporteM10 + cImporteM5 + cImporteM2 + cImporteM1 + cImporteM50c;
			
			LET ctotalImporte = ctotalBilletes + ctotalMonedas;
			
						
            RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte WITH RESUME;

        END FOREACH;
        
        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte;
		END IF;   
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 30/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de recuperar registros de archivo cargado de DotaciÃ³n masiva de sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_carga_dotacion_masiva_cifras(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND)
		RETURNING CHAR(5) AS codret,
				INTEGER AS tot_billete1000,
				INTEGER AS tot_billete500,
				INTEGER AS tot_billete200,
				INTEGER AS tot_billete100,
				INTEGER AS tot_billete50,
				INTEGER AS tot_billete20,
				INTEGER AS tot_Billetes,
				INTEGER AS tot_moneda100,
				INTEGER AS tot_moneda50,
				INTEGER AS tot_moneda20,
				INTEGER AS tot_moneda10,
				INTEGER AS tot_moneda5,
				INTEGER AS tot_moneda2,
				INTEGER AS tot_moneda1,
				INTEGER AS tot_moneda50c,
				INTEGER AS tot_Monedas,
				MONEY 	 AS tot_Importe,
				MONEY AS sum_billete1000,
				MONEY AS sum_billete500,
				MONEY AS sum_billete200,
				MONEY AS sum_billete100,
				MONEY AS sum_billete50,
				MONEY AS sum_billete20,
				MONEY AS sum_Billetes,
				MONEY AS sum_moneda100,
				MONEY AS sum_moneda50,
				MONEY AS sum_moneda20,
				MONEY AS sum_moneda10,
				MONEY AS sum_moneda5,
				MONEY AS sum_moneda2,
				MONEY AS sum_moneda1,
				MONEY AS sum_moneda50c,
				MONEY AS sum_Monedas,
				MONEY AS sum_Importe
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cbillete1000 INTEGER;
	DEFINE cbillete500 INTEGER;
	DEFINE cbillete200 INTEGER;
	DEFINE cbillete100 INTEGER;
	DEFINE cbillete50 INTEGER;
	DEFINE cbillete20 INTEGER;
    DEFINE ctotalBilletes INTEGER;
	DEFINE cmoneda100 INTEGER;
	DEFINE cmoneda50 INTEGER;
	DEFINE cmoneda20 INTEGER;
	DEFINE cmoneda10 INTEGER;
	DEFINE cmoneda5 INTEGER;
	DEFINE cmoneda2 INTEGER;
	DEFINE cmoneda1 INTEGER;
	DEFINE cmoneda50c INTEGER;
	DEFINE ctotalMonedas INTEGER;
	DEFINE ctotalImporte MONEY;
	
	DEFINE sum_billete1000 MONEY;
	DEFINE sum_billete500 MONEY;
	DEFINE sum_billete200 MONEY;
	DEFINE sum_billete100 MONEY;
	DEFINE sum_billete50 MONEY;
	DEFINE sum_billete20 MONEY;
    DEFINE sum_totalBilletes MONEY;
	DEFINE sum_moneda100 MONEY;
	DEFINE sum_moneda50 MONEY;
	DEFINE sum_moneda20 MONEY;
	DEFINE sum_moneda10 MONEY;
	DEFINE sum_moneda5 MONEY;
	DEFINE sum_moneda2 MONEY;
	DEFINE sum_moneda1 MONEY;
	DEFINE sum_moneda50c MONEY;
	DEFINE sum_totalMonedas MONEY;
	DEFINE sum_totalImporte MONEY;
	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	LET cbillete1000=0;
	LET cbillete500=0;
	LET cbillete200=0;
	LET cbillete100=0;
	LET cbillete50=0;
	LET cbillete20=0;
	LET ctotalBilletes=0;
	LET cmoneda100=0;
	LET cmoneda50=0;
	LET cmoneda20=0;
	LET cmoneda10=0;
	LET cmoneda5=0;
	LET cmoneda2=0;
	LET cmoneda1=0;
	LET cmoneda50c=0;
	LET ctotalMonedas=0;
	LET ctotalImporte=0;
	
	LET sum_billete1000=0;
	LET sum_billete500=0;
	LET sum_billete200=0;
	LET sum_billete100=0;
	LET sum_billete50=0;
	LET sum_billete20=0;
	LET sum_totalBilletes=0;
	LET sum_moneda100=0;
	LET sum_moneda50=0;
	LET sum_moneda20=0;
	LET sum_moneda10=0;
	LET sum_moneda5=0;
	LET sum_moneda2=0;
	LET sum_moneda1=0;
	LET sum_moneda50c=0;
	LET sum_totalMonedas=0;
	LET sum_totalImporte=0;
	
	LET iNoRegistros=0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte,
			sum_billete1000,sum_billete500,sum_billete200,sum_billete100,sum_billete50,sum_billete20,sum_totalbilletes,sum_moneda100,sum_moneda50,sum_moneda20,sum_moneda10,sum_moneda5,sum_moneda2,sum_moneda1,sum_moneda50c,sum_totalmonedas,sum_totalimporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_carga_dotacion_masiva_cifras.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte,
			sum_billete1000,sum_billete500,sum_billete200,sum_billete100,sum_billete50,sum_billete20,sum_totalbilletes,sum_moneda100,sum_moneda50,sum_moneda20,sum_moneda10,sum_moneda5,sum_moneda2,sum_moneda1,sum_moneda50c,sum_totalmonedas,sum_totalimporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,
			cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte,
			sum_billete1000,sum_billete500,sum_billete200,sum_billete100,sum_billete50,sum_billete20,sum_totalbilletes,
			sum_moneda100,sum_moneda50,sum_moneda20,sum_moneda10,sum_moneda5,sum_moneda2,sum_moneda1,sum_moneda50c,sum_totalmonedas,sum_totalimporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
         
		SELECT 
			sum(billete1000),sum(billete500),sum(billete200),sum(billete100),sum(billete50),sum(billete20),sum(totalbilletes),
			sum(moneda100),sum(moneda50),sum(moneda20),sum(moneda10),sum(moneda5),sum(moneda2),sum(moneda1),sum(moneda50c),sum(totalmonedas),sum(totalimporte),
			
			sum(billete1000)*1000,sum(billete500)*500,sum(billete200)*200,sum(billete100)*100,sum(billete50)*50,sum(billete20)*20,
			sum(moneda100)*100,sum(moneda50)*50,sum(moneda20)*20,sum(moneda10)*10,sum(moneda5)*5,sum(moneda2)*2,sum(moneda1),sum(moneda50c)*(.50)
		INTO cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,
			cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte,
			sum_billete1000,sum_billete500,sum_billete200,sum_billete100,sum_billete50,sum_billete20,
			sum_moneda100,sum_moneda50,sum_moneda20,sum_moneda10,sum_moneda5,sum_moneda2,sum_moneda1,sum_moneda50c
		FROM bdicnweb:"informix".tmp_arch_dot_suc_det 
		WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
			AND estatusValidaciones='ok'
		GROUP BY usuario_carga,fecha_carga;
		
		select 
			((sum(billete1000)*1000)+(sum(billete500)*500)+(sum(billete200)*200)+(sum(billete100)*100)+(sum(billete50)*50)+(sum(billete20)*20)),
			((sum(moneda100)*100)+(sum(moneda50)*50)+(sum(moneda20)*20)+(sum(moneda10)*10)+(sum(moneda5)*5)+(sum(moneda2)*2)+(sum(moneda1))+(sum(moneda50c)*(.50))),
			((sum(billete1000)*1000)+(sum(billete500)*500)+(sum(billete200)*200)+(sum(billete100)*100)+(sum(billete50)*50)+(sum(billete20)*20))+
			((sum(moneda100)*100)+(sum(moneda50)*50)+(sum(moneda20)*20)+(sum(moneda10)*10)+(sum(moneda5)*5)+(sum(moneda2)*2)+(sum(moneda1))+(sum(moneda50c)*(.50)))
		INTO sum_totalBilletes,sum_totalMonedas,sum_totalimporte
		FROM bdicnweb:"informix".tmp_arch_dot_suc_det 
		WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
			AND estatusValidaciones='ok'
		GROUP BY usuario_carga,fecha_carga;
        
        IF DBINFO('sqlca.sqlerrd2') = 0  THEN
            LET cCodRet = '00017';
		END IF;   
		
		LET ctotalBilletes = cbillete1000 + cbillete500 + cbillete200 + cbillete100 + cbillete50 + cbillete20;
		LET ctotalMonedas = cmoneda100 + cmoneda50 + cmoneda20 + cmoneda10 + cmoneda5 + cmoneda2 + cmoneda1 + cmoneda50c;
		LET ctotalImporte = ctotalBilletes + ctotalMonedas;
		
		RETURN cCodRet,cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,
			cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte,
			sum_billete1000,sum_billete500,sum_billete200,sum_billete100,sum_billete50,sum_billete20,sum_totalbilletes,
			sum_moneda100,sum_moneda50,sum_moneda20,sum_moneda10,sum_moneda5,sum_moneda2,sum_moneda1,sum_moneda50c,sum_totalmonedas,sum_totalimporte;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 30/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de recuperar registros de archivo cargado de DotaciÃ³n masiva de sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_enviar_dotacion_masiva_etv(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE AS fechaSolicitud,
				DATE AS fechaAplicacion,
				CHAR(4) AS ccSucursal,
				CHAR(40) AS nombreSucursal,
				CHAR(50) AS plaza,
				CHAR(20) AS tipoOperacion,
				SMALLINT AS billete1000,
				SMALLINT AS billete500,
				SMALLINT AS billete200,
				SMALLINT AS billete100,
				SMALLINT AS billete50,
				SMALLINT AS billete20,
				SMALLINT AS totalBilletes,
				SMALLINT AS moneda100,
				SMALLINT AS moneda50,
				SMALLINT AS moneda20,
				SMALLINT AS moneda10,
				SMALLINT AS moneda5,
				SMALLINT AS moneda2,
				SMALLINT AS moneda1,
				SMALLINT AS moneda50c,
				SMALLINT AS totalMonedas,
				MONEY 	AS totalImporte,
				char(25) AS id_solicitud,
				CHAR(521) AS trama,
				CHAR(8) AS folioOper;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cfechaSolicitud DATE;
	DEFINE cfechaAplicacion DATE;
	DEFINE cccSucursal CHAR(4);
    DEFINE cnombreSucursal CHAR(40);
	DEFINE cplaza CHAR(50);
	DEFINE ctipoOperacion CHAR(20);
	DEFINE cbillete1000 SMALLINT;
	DEFINE cbillete500 SMALLINT;
	DEFINE cbillete200 SMALLINT;
	DEFINE cbillete100 SMALLINT;
	DEFINE cbillete50 SMALLINT;
	DEFINE cbillete20 SMALLINT;
    DEFINE ctotalBilletes SMALLINT;
	DEFINE cmoneda100 SMALLINT;
	DEFINE cmoneda50 SMALLINT;
	DEFINE cmoneda20 SMALLINT;
	DEFINE cmoneda10 SMALLINT;
	DEFINE cmoneda5 SMALLINT;
	DEFINE cmoneda2 SMALLINT;
	DEFINE cmoneda1 SMALLINT;
	DEFINE cmoneda50c SMALLINT;
	DEFINE ctotalMonedas SMALLINT;
	DEFINE ctotalImporte MONEY;
	DEFINE cid_solicitud char(25);
	DEFINE ctrama CHAR(521);
	DEFINE cFolioOper CHAR(8);
	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	LET cfechaSolicitud='';
	LET cfechaAplicacion='';
	LET cccSucursal='';
	LET cnombreSucursal='';
	LET cplaza='';
	LET ctipoOperacion='';
	LET cbillete1000=0;
	LET cbillete500=0;
	LET cbillete200=0;
	LET cbillete100=0;
	LET cbillete50=0;
	LET cbillete20=0;
	LET ctotalBilletes=0;
	LET cmoneda100=0;
	LET cmoneda50=0;
	LET cmoneda20=0;
	LET cmoneda10=0;
	LET cmoneda5=0;
	LET cmoneda2=0;
	LET cmoneda1=0;
	LET cmoneda50c=0;
	LET ctotalMonedas=0;
	LET ctotalImporte=0;
	LET cid_solicitud='';
	LET ctrama='';
	LET cFolioOper = '';
	
	LET iNoRegistros=0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama, cFolioOper;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_con_enviar_dotacion_masiva_etv.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama,cFolioOper;
		END IF;
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama,cFolioOper WITH RESUME;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama,cFolioOper;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        FOREACH 
            SELECT SKIP pRegistros FIRST pRecuperacion
				fecha_solicitud,fecha_aplicacion,cc_sucursal,nombre_sucursal,plaza,tipo_operacion,
				billete_1000,billete_500,billete_200,billete_100,billete_50,billete_20,total_billetes,
				moneda_100,moneda_50,moneda_20,moneda_10,moneda_5,moneda_2,moneda_1,moneda_0_50,total_monedas,total_importe,id_servicio,trama, folio
            INTO cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,cbillete200,cbillete100,
			cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte,
			cid_solicitud,ctrama, cFolioOper
			FROM bdicnweb:"informix".arch_dotacion_sucursal 
			WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
				AND estatus_inicial='En proceso'
				AND estatus_final is NULL
				AND folio is not null
				AND trama is not null
						
			 LET iNoRegistros = iNoRegistros + 1;
			 
            RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama,cFolioOper WITH RESUME;

        END FOREACH;

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama,cFolioOper WITH RESUME;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,cbillete1000,cbillete500,
			cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,
			cmoneda50c,ctotalmonedas,ctotalimporte,cid_solicitud,ctrama,cFolioOper WITH RESUME;
		END IF;   
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 03/02/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de recuperar registros de DotaciÃ³n masiva para enviar a webservice de ETV.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 16/06/2023',
'DESCRIPCION: Se realiza ajuste a SP para agregar nuevo cambo de reporto folio';

CREATE PROCEDURE "informix".sp_envio_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND,pETV INTEGER)
RETURNING CHAR(5) AS codret;

DEFINE vsqlerr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cCodRetSpl CHAR(5);
DEFINE cSQL CHAR(4000);

DEFINE cContErrores INTEGER;

DEFINE cDivisa CHAR(2);
DEFINE ctransaccion CHAR(4);
DEFINE cIdRegistro INTEGER;
DEFINE cfechaSolicitud DATE;
DEFINE cfechaAplicacion DATE; 
DEFINE cccSucursal CHAR(4);
DEFINE cnombreSucursal CHAR(40);
DEFINE cplaza CHAR(50);
DEFINE ctipoOperacion CHAR(20);
DEFINE cbillete1000 SMALLINT;
DEFINE cbillete500 SMALLINT;
DEFINE cbillete200 SMALLINT;
DEFINE cbillete100 SMALLINT;
DEFINE cbillete50 SMALLINT;
DEFINE cbillete20 SMALLINT;
DEFINE ctotalBilletes INTEGER;
DEFINE cmoneda100 SMALLINT;
DEFINE cmoneda50 SMALLINT;
DEFINE cmoneda20 SMALLINT;
DEFINE cmoneda10 SMALLINT;
DEFINE cmoneda5 SMALLINT;
DEFINE cmoneda2 SMALLINT;
DEFINE cmoneda1 SMALLINT;
DEFINE cmoneda50c SMALLINT;
DEFINE ctotalMonedas INTEGER;
DEFINE ctotalImporte DECIMAL(18,2);

DEFINE cfolio_sucursal char(16);

DEFINE cfolioOper char(8);
DEFINE cid_servicio CHAR(25);
DEFINE ctrama CHAR(521);

DEFINE dHoraHoy DATETIME HOUR TO SECOND;
DEFINE cEnvioOk SMALLINT;
--NUEVOS
	DEFINE cImporte1000 INTEGER;
	DEFINE cImporte500 INTEGER;
	DEFINE cImporte200 INTEGER;
	DEFINE cImporte100 INTEGER;
	DEFINE cImporte50 INTEGER;
	DEFINE cImporte20 INTEGER;
	DEFINE cImporteTotalBilletes INTEGER;
	
	DEFINE cImporteM100 INTEGER;
	DEFINE cImporteM50 INTEGER;
	DEFINE cImporteM20 INTEGER;
	DEFINE cImporteM10 INTEGER;
	DEFINE cImporteM5 INTEGER;
	DEFINE cImporteM2 INTEGER;
	DEFINE cImporteM1 INTEGER;
	DEFINE cImporteM50c DECIMAL(16,2);
	DEFINE cImporteTotalMonedas DECIMAL(16,2);
	
	DEFINE cFolio CHAR(8);

LET vsqlerr = 0;
LET cCodRet = '00000';
LET cCodRetSpl = '00000';
LET cSQL ='';

LET cContErrores=0;

LET cDivisa='01';
LET ctransaccion='0001';
LET cIdRegistro=0;
LET cfechaSolicitud =NULL;
LET cfechaAplicacion =NULL;
LET cccSucursal ='';
LET cnombreSucursal ='';
LET cplaza ='';
LET ctipoOperacion ='';
LET cbillete1000=0;
LET cbillete500=0;
LET cbillete200=0;
LET cbillete100=0;
LET cbillete50=0;
LET cbillete20=0;
LET ctotalBilletes=0;
LET cmoneda100=0;
LET cmoneda50=0;
LET cmoneda20=0;
LET cmoneda10=0;
LET cmoneda5=0;
LET cmoneda2=0;
LET cmoneda1=0;
LET cmoneda50c=0;
LET ctotalMonedas=0;
LET ctotalImporte=0;
LET cfolio_sucursal='';

LET cfolioOper ='';
LET cid_servicio ='';
LET ctrama ='';
LET dHoraHoy = CURRENT;	
LET cEnvioOk=0;
-- NUEVOS
	LET cImporte1000 = 0;
	LET cImporte500 = 0;
	LET cImporte200 = 0;
	LET cImporte100 = 0;
	LET cImporte50 = 0;
	LET cImporte20 = 0;
	
	LET cImporteTotalBilletes = 0;
	
	LET cImporteM100 = 0;
	LET cImporteM50 = 0;
	LET cImporteM20 = 0;
	LET cImporteM10 = 0;
	LET cImporteM5 = 0;
	LET cImporteM2 = 0;
	LET cImporteM1 = 0;
	LET cImporteM50c = 0;
	
	LET cImporteTotalMonedas = 0;
	
	LET cFolio = '';

BEGIN

-- CONTROL DE ERRORES

	ON EXCEPTION IN (-668,-535,-255)	
		COMMIT WORK;
	END EXCEPTION WITH RESUME;	
	
	ON EXCEPTION SET vsqlerr
		LET cCodRet = vsqlerr;
          RETURN cCodRet;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_envio_dotacion_masiva.out';
	--TRACE ON;
	
	IF pUsuario = '' OR pIdFuncion = '' OR pFecha='' OR pETV='' THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
	
-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
	INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	--VALIDACION DE ETV
	IF(pETV=1) THEN
	
		LET cfolio_sucursal = pUsuario||TO_CHAR(dHoraHoy, '%H%M%S%F"');
		
		INSERT INTO bdicnweb:"informix".arch_dotacion_sucursal(fecha_solicitud,
			fecha_aplicacion,cc_sucursal,
			nombre_sucursal,plaza,tipo_operacion,billete_1000,billete_500,billete_200,billete_100,billete_50,billete_20,
			total_billetes,moneda_100,moneda_50,moneda_20,moneda_10,moneda_5,moneda_2,moneda_1,moneda_0_50,total_monedas,
			total_importe,usuario_carga,fecha_carga,nombre_archivo,estatus_inicial
		)
		select
			fechasolicitud,fechaaplicacion,ccsucursal,nombresucursal,plaza,tipooperacion,billete1000,billete500,billete200,billete100,billete50,billete20,totalbilletes,
			moneda100,moneda50,moneda20,moneda10,moneda5,moneda2,moneda1,moneda50c,totalmonedas,totalimporte,usuario_carga,fecha_carga,nombre_archivo,'En proceso'
		from bdicnweb:"informix".tmp_arch_dot_suc_det 
		WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
			AND estatusValidaciones='ok';
		
		--Borrado de tabla temporal
		delete from bdicnweb:"informix".tmp_arch_dot_suc_det 
		WHERE usuario_carga=pUsuario AND fecha_carga=pFecha;
		
		FOREACH
			SELECT id, folio, 
				fecha_solicitud,fecha_aplicacion,cc_sucursal,nombre_sucursal,plaza,tipo_operacion,
				billete_1000,billete_500,billete_200,billete_100,billete_50,billete_20,total_billetes,
				moneda_100,moneda_50,moneda_20,moneda_10,moneda_5,moneda_2,moneda_1,moneda_0_50,total_monedas,total_importe
            INTO cIdRegistro,cFolio,cfechasolicitud,cfechaaplicacion,cccsucursal,cnombresucursal,cplaza,ctipooperacion,
			cbillete1000,cbillete500,cbillete200,cbillete100,cbillete50,cbillete20,ctotalbilletes,
			cmoneda100,cmoneda50,cmoneda20,cmoneda10,cmoneda5,cmoneda2,cmoneda1,cmoneda50c,ctotalmonedas,ctotalimporte
			FROM bdicnweb:"informix".arch_dotacion_sucursal 
			WHERE usuario_carga=pUsuario AND fecha_carga=pFecha

			IF NVL(cFolio,'') = '' THEN 
				LET cImporte1000 = cbillete1000 * 1000;
				LET cImporte500 = cbillete500 * 500;
				LET cImporte200 = cbillete200 * 200;
				LET cImporte100 = cbillete100 * 100;
				LET cImporte50 = cbillete50 * 50;
				LET cImporte20 = cbillete20 * 20;
				LET ctotalBilletes = cImporte1000 + cImporte500 + cImporte200 + cImporte100 + cImporte50 + cImporte20;
				
				
				LET cImporteM100 = cmoneda100 * 100;
				--LET cImporteM50 = cmoneda50 * 50;
				--LET cImporteM20 = cmoneda20 * 20;
				LET cImporteM10 = cmoneda10 * 10;
				LET cImporteM5 = cmoneda5 * 5;
				LET cImporteM2 = cmoneda2 * 2;
				LET cImporteM1 = cmoneda1 * 1;
				LET cImporteM50c = cmoneda50c * 0.5;
				
				LET ctotalMonedas = cImporteM100 + cImporteM50 + cImporteM20 + cImporteM10 + cImporteM5 + cImporteM2 + cImporteM1 + cImporteM50c;
				
				LET ctotalImporte = ctotalBilletes + ctotalMonedas;
				
				EXECUTE PROCEDURE bdisuc:"informix".sp_soldocta_ws('001',cccsucursal,
																		pUsuario,
																		cfolio_sucursal,
																		ctransaccion,
																		cDivisa,
																		ctotalimporte,
																		cfechasolicitud,
																		'1000',
																		'500',
																		'200',
																		'100',
																		'50',
																		'20',
																		'',
																		'100',--monedas
																		'10',
																		'5',
																		'2',
																		'1',
																		'.50',
																		'.20',
																		'.10',
																		cbillete1000,
																		cbillete500,
																		cbillete200,
																		cbillete100,
																		cbillete50,
																		cbillete20,
																		0,
																		cmoneda100,
																		cmoneda10,	
																		cmoneda5,
																		cmoneda2,
																		cmoneda1,
																		cmoneda50c,
																		0, -- .20
																		0, -- .10
																		'1')
				INTO cCodRetSpl,cfolioOper,cid_servicio,ctrama;
				
				
					
				IF cCodRetSpl::INTEGER <> 0 THEN
					LET cContErrores=cContErrores+1;
					UPDATE bdicnweb:"informix".arch_dotacion_sucursal 
					SET 
						error_envio=cCodRetSpl,
						estatus_final='Con error'
					WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
						AND id=cIdRegistro;
				ELSE
					LET cEnvioOk=1;
					UPDATE bdicnweb:"informix".arch_dotacion_sucursal 
					SET folio=cfolioOper,
						id_servicio=cid_servicio,
						trama=ctrama
					WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
						AND id=cIdRegistro;
				END IF;
			ELSE
				--DOTACION
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '01' 
				WHERE sucursal = cccsucursal AND folio_oper = cFolio;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
					
				UPDATE bdisuc:"informix".ss_operaciones SET reversado = '0' 
				WHERE sucursal = cccsucursal AND folio_oper = cFolio;
					
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			END IF;
		END FOREACH;
			
	ELSE
		LET cCodRet = '00001';
	END IF;
	IF cEnvioOk=1 THEN
		LET cCodRet = '00000';
	END IF;
 
END

	IF DBINFO('sqlca.sqlerrd2') = 0  THEN
		LET cCodRet = '00017';
	END IF;  

RETURN cCodRet;
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 27/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de realizar llamado a procedimiento del core bancario para dotaciÃ³n de sucursales mediante archivo de dotacion masiva.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 16/06/2023',
'DESCRIPCION: Se realiza modificacion a SP para recuperar el error que retorna el SP sp_soldocta_ws y actualizar la inf de la solicitu cuando se tiene un error.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 20/06/2023',
'DESCRIPCION: Se realiza modificacion a SP para realizar actualizaciÃ³n de estatus y reverso cuando ya existe una solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_envios_dotacion_masiva_genrep(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND,pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado,
	CHAR(100) AS reporte_generado2;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE cNombreArchivo2 CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cBanDetError CHAR(1);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE nomFecha CHAR(19);
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET cNombreArchivo2 = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cBanDetError = 'f';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			
            RETURN cCodRet, cNombreArchivo, cNombreArchivo2;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;      

		--SET DEBUG FILE TO '/tmp/mfinis/sp_envios_dotacion_masiva_genrep.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRutaDescarga='' THEN
			LET cCodRet = '00003';		
	       RETURN cCodRet, cNombreArchivo, cNombreArchivo2;
    	END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cNombreArchivo, cNombreArchivo2;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
 				
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	Terminadas
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'Sucursal','Caja General','Fecha','Estatus','Folio Operacion','Monto','Usuario' FROM systables WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ( ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT cc_sucursal||'',plaza,fecha_solicitud||'',estatus_final,folio,total_importe||'',usuario_carga||'' FROM bdicnweb:'informix'.arch_dotacion_sucursal WHERE usuario_carga='"||pUsuario||"' AND fecha_carga='"||pFecha||"' AND estatus_final='Terminado' ORDER BY id)"; 
		
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- SE DEFINE NOMBRE DEL REPORTE A GENERAR		
		LET nomFecha = TO_CHAR(dFechaHoy, '%Y%m%d')||"_"||TO_CHAR(dHoraHoy, '%H%M');
		LET cNombreArchivo = 'DOTACIONES_MASIVAS_PROCESADAS_'||TRIM(nomFecha)||'.xls';
		
        --LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo);

		BEGIN WORK;
		    LET ven_transacc = 1;

			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			LET cSql = '';
			--RUTA PRUEBAS
			--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			--RUTA PRODUCTIVA
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			--Borrado de consulta
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			-- Se modifica el archivo para agregar el salto de lÃ­nea
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			-- Eliminamos el caracter delimitador al final de la lÃ­nea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			-- Se modifica el archivo para agregar el salto de lÃ­nea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

					   
			LET cBanDetError = 't';

		COMMIT WORK;
		
		--GENERACION DE REPORTE	NO PROCESADAS POR ERRORES
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'Sucursal','Caja General','Fecha','Estatus','Folio Operacion','Monto','Usuario' FROM systables WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ( ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT cc_sucursal||'',plaza,fecha_aplicacion||'',estatus_final,' ',total_importe||'',usuario_carga||'' FROM bdicnweb:'informix'.arch_dotacion_sucursal WHERE usuario_carga='"||pUsuario||"' AND fecha_carga='"||pFecha||"' AND estatus_final='Con error' ORDER BY id)"; 
		
		-- SE DEFINE NOMBRE DEL REPORTE A GENERAR		
		LET nomFecha = TO_CHAR(dFechaHoy, '%Y%m%d')||"_"||TO_CHAR(dHoraHoy, '%H%M');
		LET cNombreArchivo2 = 'DOTACIONES_MASIVAS_NO_PROCESADAS_'||TRIM(nomFecha)||'.xls';
		
       -- LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)|| '/'||TRIM(cNombreArchivo2);

		BEGIN WORK;
		    LET ven_transacc = 1;

			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			LET cSql = '';
			--RUTA PRUEBAS
			--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			--RUTA PRODUCTIVA
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			--Borrado de consulta
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)|| '/'||'query.sql';
			SYSTEM TRIM(cSql);

			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			-- Se modifica el archivo para agregar el salto de lÃ­nea
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			-- Eliminamos el caracter delimitador al final de la lÃ­nea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			-- Se modifica el archivo para agregar el salto de lÃ­nea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

					   
			LET cBanDetError = 't';
			
			
			--LET cSql = '/usr/bin/zip '||TRIM(pRutaDescarga)||'/DOTACIONES_MASIVAS_'||TRIM(nomFecha)||' '||TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo)||' '||TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo2);
			--SYSTEM TRIM(cSql);
			
			
			-- Eliminamos el archivo xls
			--LET cSql = "rm -rf "||TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo);
			--SYSTEM TRIM(cSql);
			-- Eliminamos el archivo xls
			--LET cSql = "rm -rf "||TRIM(pRutaDescarga)||'/'||TRIM(cNombreArchivo2);
			
			--LET cNombreArchivo='DOTACIONES_MASIVAS_'||TRIM(nomFecha)||'.zip';
			
			SYSTEM TRIM(cSql);
		COMMIT WORK;

	   LET ven_transacc = 0;
	   IF bInTransaction = 't' THEN
			   BEGIN WORK;
	   END IF;
	
                             
	    END IF;
		RETURN cCodRet, cNombreArchivo, cNombreArchivo2;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 02/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de generar reportes Excel de registros enviados para DotaciÃ³n masiva de sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_errores_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATETIME YEAR TO SECOND,pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				SMALLINT AS NoRegistro,
				CHAR(50) AS Campo,
				CHAR(100) AS Descripcion
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNoRegistro SMALLINT;
	DEFINE cCampo CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNoRegistro=0;
	LET cCampo='';
	LET cDescripcion='';
	LET iNoRegistros=0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNoRegistro,cCampo,cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfini/Eder/CashManagement/sp_errores_dotacion_masiva.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNoRegistro,cCampo,cDescripcion;
		END IF;
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNoRegistro,cCampo,cDescripcion;
        END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNoRegistro,cCampo,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        FOREACH 
            SELECT SKIP pRegistros FIRST pRecuperacion 
				noRegistro,Campo,Descripcion
            INTO cNoRegistro,cCampo,cDescripcion
			FROM bdicnweb:"informix".tmp_arch_dot_suc_err 
			WHERE usuario_carga=pUsuario AND fecha_carga=pFecha
            
            LET iNoRegistros = iNoRegistros + 1;
						
            RETURN cCodRet,cNoRegistro,TRIM(cCampo),TRIM(cDescripcion) WITH RESUME;

        END FOREACH;
        
        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet,cNoRegistro,cCampo,cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNoRegistro,cCampo,cDescripcion;
		END IF;   
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 27/01/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de recuperar registros de error en carga de archivo de DotaciÃ³n masiva de sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_respuesta_ws_dotacion_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10),pId_solicitud char(25),pEstatus char(60))
		RETURNING CHAR(5) AS codret
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/Eder/CashManagement/sp_respuesta_ws_dotacion_masiva.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''	OR pId_solicitud='' OR pEstatus='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        UPDATE bdicnweb:"informix".arch_dotacion_sucursal 
		SET 
			estatus_final='Terminado'
		WHERE id_servicio=pId_solicitud;
           
        IF DBINFO('sqlca.sqlerrd2') = 0  THEN
            LET cCodRet = '00017';
		END IF;   
		
		RETURN cCodRet;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Eder SolÃ­s LÃ³pez',
'FECHA: 03/02/2023',
'MODULO: Cash Management',
'FUNCIONALIDAD: Cash Management',
'DESCRIPCION: SP encargado de actualizar registros de DotaciÃ³n masiva de sucursales con respuesta de web service de ETV.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsi_detalle(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS codret,
				CHAR(10) AS fecha,
				CHAR(10) AS hora,
				CHAR(16) AS tarjeta,
				CHAR(16) AS folio, 
				CHAR(3) AS codfun,
				CHAR(100) AS descripcion,
				CHAR(40) AS infreceptor,
				CHAR(40) AS referencia,
				DECIMAL(18,2) AS monto,
				INTEGER AS plazo,
				CHAR(5) AS plazopago,
				CHAR(60) AS status,
				DECIMAL(18,2) AS saldoliq,
				DECIMAL(18,2) AS saldopag,
				INTEGER AS llave;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(10);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cCodFun CHAR(3);
	DEFINE cDescripcion CHAR(100);
	DEFINE cInfReceptor CHAR(40);
	DEFINE cReferencia CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE cStatus CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE cPlazoA CHAR(5);
	DEFINE cNumPago CHAR(5);
	DEFINE iLlave INTEGER;
    DEFINE iPlazo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET dSdoTotalLiq  =0;    
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cHora ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cCodFun ='';
	LET cDescripcion ='';
	LET cInfReceptor ='';
	LET cReferencia ='';
	LET dMontoOtorgado  =0;
	LET cStatus ='';
	LET iNoRegistros =0;
	LET cPlazoA='';
	LET cNumPago='';
	LET iLlave =0;
    LET iPlazo = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END EXCEPTION;

		--SET DEBUG FILE TO '/RESPALDOSNEW/sp_msi_consultamsi_detalle.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH SELECT 
				SKIP pRegistros FIRST pRecuperacion  
				     TO_CHAR(fecha,'%d/%m/%Y'), hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,cplazo,status,saldoliq,saldopag,llave
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave
				FROM
				"informix".sw_msi_consultagrid where llave = pNumCred and id = 'D' and usuario = pUsuario ORDER BY fecha,referencia
				
				LET iNoRegistros = iNoRegistros +1;
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01276';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,'','','',iPlazo,cPlazoA,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2022',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'AUTOR: Veronica Sanchez',
'FECHA: 10/02/2023',
'DESCRIPCION: Se realiza ajuste a SPL para aplicar formato en campo fecha',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_registracancelacion (pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pFoliomvto CHAR(16),pPromo INTEGER,pCanal CHAR(1),pSucursal CHAR(4))
	RETURNING 	CHAR(5) AS codret;
	


	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRetSP 		CHAR(6);
	DEFINE cMsjResp			CHAR(80);
	
	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cCodRetSP 			= '000000';
	LET cMsjResp			= '';
 
	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_registracancelacion.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' OR pFoliomvto ='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		EXECUTE PROCEDURE bdicred:"informix".sp_msi_cancela_msi_credito('001', pFoliomvto, pNumCred, pCanal, pSucursal, pUsuario)
		INTO cCodRetSP,cMsjResp;
				
		IF cCodRetSP ='000000' THEN
			LET cCodRet = '00000';
		ELSE
			LET cCodRet = '01280'; --CREDITO MSI NO VALIDO PARA CANCELARSE
		END IF;
		
		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2021',
'FUNCIONALIDAD: CANCELA MSI',
'DESCRIPCION: SPL que realiza el registro de una cancelacion para MSI',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 16/06/2023',
'DESCRIPCION: Se realiza ajuste a SP para modificar los parametros de entrada del SPL sp_msi_cancela_msi_credito';

CREATE PROCEDURE "informix".sp_msi_genrepmsigrid(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(300), pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cBanDetError CHAR(1);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	
	DEFINE cAux CHAR(100);
    DEFINE cAux2 CHAR(100);
    DEFINE i INTEGER;
 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cBanDetError = 'f';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';
	
	LET cAux ='';
    LET cAux2 = '';
    LET i =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;      

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_genrepmsigrid.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pNumCred ='' THEN
			LET cCodRet = '00003';				
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN		     
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		
		 -- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_msi_numcred_tmp WHERE usuario = pUsuario;
		
		FOR i = 1 TO LENGTH(TRIM(pNumCred)) 
		
			IF SUBSTR(TRIM(pNumCred), i, 1) = ',' THEN
            INSERT INTO "informix".sw_msi_numcred_tmp VALUES(cAux,pUsuario);
            LET cAux ='';
			ELSE
			LET cAux2 =  SUBSTR(TRIM(pNumCred), i, 1);
            LET cAux = TRIM(cAux)||TRIM(cAux2);
			END IF 
			
			IF i = LENGTH(TRIM(pNumCred)) THEN 
             INSERT INTO "informix".sw_msi_numcred_tmp VALUES(cAux,pUsuario);
			END IF;
		END FOR;
  
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_msi_consultagrid WHERE usuario = pUsuario;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';					
		END IF;
		
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'FECHA','HORA','TARJETA','FOLIO','TRANSACCION','DESCRIPCION','CONCEPTO','REFERENCIA','MONTO','PLAZO','NO. DE PAGO/PLAZO','ESTATUS','SALDO PENDIENTE','SALDO A PAGAR' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ( ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(fecha),2,0)||'/'||LPAD(MONTH(fecha),2,0)||'/'||YEAR(fecha),hora::CHAR(10),''''||tarjeta::CHAR(16),folio::CHAR(16),''''||cod_fun::CHAR(3),descripcion::CHAR(60),infreceptor::CHAR(40),referencia::CHAR(40),montootorgado::CHAR(20),plazo::CHAR(11),CASE WHEN cplazo= '' THEN ' ' ELSE ''''||cplazo END ,status::CHAR(60),saldoliq::CHAR(20),saldopag::CHAR(20) FROM ""informix"".sw_msi_consultagrid WHERE llave in (select num_cred from  ""informix"".sw_msi_numcred_tmp where usuario ='"||pUsuario||"') and usuario ='"||pUsuario||"' ORDER BY llave,id,fecha)"; 
		
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		LET cFechaHoraArchivo = TO_CHAR(dFechaHoy, '%d%m%Y')||"_"||TO_CHAR(dHoraHoy, '%H%M%S');
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'REP_DET_MOVTOS_'||TRIM(cFechaHoraArchivo)||'.xls';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
 
						LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'repmsisoc.sql';
             
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'repmsisoc.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        --RUTA PRUEBAS
						--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'repmsisoc.sql';
						--RUTA PRODUCTIVA
						LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'repmsisoc.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'repmsisoc.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de lÃ­nea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
	
                             
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2022',
'DESCRIPCION: SPL que genera el reporte para la funcionalidad de MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultanumsolicitudcoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumSolicitud CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_cte,
		CHAR(20) AS num_solicitud,
		CHAR(104) AS nombre,
		CHAR(4) AS 	sucursal,
		DATE AS 	fecha_solicitud,
		DATE AS 	fecha_cambio_solicitud,
		CHAR(2) AS 	status_solicitud,
		CHAR(3) AS 	causa_solicitud,
		CHAR(1) AS bandera,
		CHAR(1) AS estatus;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNumCte CHAR(20);
	DEFINE cNoCte CHAR(20);
	DEFINE cNumSolicitud  CHAR(20);
	DEFINE cNoSolicitud  CHAR(20);
	DEFINE cNombre	CHAR(90);	
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaSolicitud DATE; 
	DEFINE dFechaCambioSolicitud DATE;
	DEFINE cStatusSolicitud	CHAR(2);
	DEFINE cCausaSolicitud CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE vNumProducto CHAR(4);
	DEFINE vFechaSolictudUltima CHAR(25);
	DEFINE vNumSolicitud CHAR(20);
	DEFINE cBandera CHAR(1);
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cNumCte = '';
	LET cNumSolicitud = '';
	LET cNombre = '';
	LET cSucursal = '';
	LET dFechaSolicitud = '';
	LET dFechaCambioSolicitud = '';
	LET cStatusSolicitud = '';
	LET cCausaSolicitud = '';
	LET iNoRegistros = 0;
	LET vNumProducto = '6001';
	LET vFechaSolictudUltima = '';
	LET vNumSolicitud = '';
	LET cBandera = '';
	LET cStatus = '';
	LET cNoCte = '';
	LET cNoSolicitud = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/roman/ambientacion/TDC_INFINITE/Spl/sp_cre_consultanumsolicitudcoppel.out';
        --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		END IF;
						
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF pNumCte <> '' AND pNumSolicitud = '' THEN 
		
			SELECT LIMIT 1 MAX (fecha_insert)
			INTO vFechaSolictudUltima
			FROM bdisolic:"informix".ss_solicitudes
			WHERE numcte = pNumCte
			AND num_producto = vNumProducto;
			
			IF vFechaSolictudUltima <> '' OR vFechaSolictudUltima IS NOT NULL THEN 			
				SELECT LIMIT 1 num_solicitud 
				INTO vNumSolicitud
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = pNumCte
				AND fecha_insert = vFechaSolictudUltima::DATE
				AND num_producto = vNumProducto;				
				LET pNumSolicitud = vNumSolicitud;				
			ELSE			
				LET pNumSolicitud = '';
			END IF;
		ELIF (pNumCte = '' AND pNumSolicitud <> '') THEN
				
				IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pNumSolicitud) > 0 THEN
					SELECT num_solicitud, numcte
					INTO cNoSolicitud, cNoCte
					FROM bdisolic:"informix".ss_solicitudes
					WHERE num_solicitud = pNumSolicitud;
					
					LET pNumSolicitud = cNoSolicitud;
					
				ELSE
					LET cNoSolicitud = '';
					LET cNoCte = '';
				END IF;
				
				IF cNoSolicitud = '' THEN
					LET cCodRet = '00017';
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				END IF;
		
		END IF;		
		
		EXECUTE PROCEDURE "informix".sp_cre_consultaestatuscoppel(pUsuario, pIdFuncion, pNumSolicitud, pNumCte)
		INTO cCodRet, cStatus; 
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cre_consultaestatuscoppel';
			ELIF cCodRetSp::INTEGER = 17 THEN
				LET cCodRet = '00017';
			END IF;
					
		IF (SELECT COUNT (s.num_solicitud) FROM  bdisolic:"informix".ss_solicitudes s INNER JOIN bdisolic:"informix".ss_autorizacion a ON  s.num_solicitud = a.num_solicitud
		WHERE num_producto = vNumProducto	AND s.num_solicitud = pNumSolicitud AND a.status_solicitud = 'CN' AND a.causa_solicitud = 'CR') > 0 THEN
				
										
				IF (SELECT COUNT (z.num_solicitud) FROM  bdisolic:"informix".ss_solicitudes z INNER JOIN bdisolic:"informix".ss_autorizacion k ON  z.num_solicitud = k.num_solicitud 	WHERE num_producto = vNumProducto	AND z.num_solicitud = pNumSolicitud)> 0 THEN-- AND k.causa_solicitud = 'RGC' AND k.status_solicitud = 'RT') > 0 THEN
									
					SELECT solic.numcte, solic.num_solicitud
					, TRIM(clit.nombre1) || ' ' || TRIM(clit.nombre2) || ' ' || TRIM(clit.apell_paterno) || ' ' || TRIM(clit.apell_materno) AS nombre
					, solic.sucursal, solic.fecha_insert, aut.fecha_insert, aut.status_solicitud, aut.causa_solicitud, '1' AS bandera
						INTO cNumCte, cNumSolicitud, cNombre, cSucursal, dFechaSolicitud, dFechaCambioSolicitud, cStatusSolicitud, cCausaSolicitud, cBandera
					FROM bdisolic:"informix".ss_solicitudes solic
						INNER JOIN bdisolic:"informix".ss_autorizacion aut ON  solic.num_solicitud = aut.num_solicitud AND solic.status_solicitud = aut.status_solicitud
						INNER JOIN bdinteg:"informix".si_cliente clit ON  solic.numcte = clit.numcte
					WHERE num_producto = '6001'
						AND solic.num_solicitud = pNumSolicitud
						AND aut.status_solicitud = 'CN'
						AND aut.causa_solicitud = 'CR';
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				ELSE

					IF (pNumCte = '') THEN
						LET pNumCte = cNoCte;
					END IF;
									
					SELECT numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) AS nombre, '0' AS bandera
						INTO cNumCte, cNombre, cBandera
					FROM  bdinteg:"informix".si_cliente 
					WHERE  numcte = pNumCte;
										
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				END IF;
			ELSE 
				IF (SELECT COUNT (j.num_solicitud) FROM  bdisolic:"informix".ss_solicitudes j INNER JOIN bdisolic:"informix".ss_autorizacion o ON  j.num_solicitud = o.num_solicitud	WHERE num_producto = vNumProducto	AND j.num_solicitud = pNumSolicitud) > 0 THEN --AND o.status_solicitud = 'RT' AND o.causa_solicitud = 'RGC'
					
					SELECT solic.numcte, solic.num_solicitud
				, TRIM(clit.nombre1) || ' ' || TRIM(clit.nombre2) || ' ' || TRIM(clit.apell_paterno) || ' ' || TRIM(clit.apell_materno) AS nombre
				, solic.sucursal, solic.fecha_insert, aut.fecha_insert, aut.status_solicitud, aut.causa_solicitud, '1' AS bandera
					INTO cNumCte, cNumSolicitud, cNombre, cSucursal, dFechaSolicitud, dFechaCambioSolicitud, cStatusSolicitud, cCausaSolicitud, cBandera
				FROM bdisolic:"informix".ss_solicitudes solic
					INNER JOIN bdisolic:"informix".ss_autorizacion aut ON  solic.num_solicitud = aut.num_solicitud AND solic.status_solicitud = aut.status_solicitud
					INNER JOIN bdinteg:"informix".si_cliente clit ON  solic.numcte = clit.numcte
				WHERE num_producto = '6001'
					AND solic.num_solicitud = pNumSolicitud;
					--AND aut.status_solicitud = 'RT'
					--AND aut.causa_solicitud = 'RGC';
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
				ELSE
					LET iNoRegistros = 0;
				END IF;		
			END IF;				
			
			IF (iNoRegistros > 0) OR (pNumCte <> '') THEN
				IF (pNumCte <> '') THEN
					SELECT DISTINCT si.numcte, TRIM(si.nombre1) || ' ' || TRIM(si.nombre2) || ' ' || TRIM(si.apell_paterno) || ' ' || TRIM(si.apell_materno) AS nombre, '1' AS bandera
						INTO cNumCte, cNombre, cBandera
					FROM bdinteg:"informix".si_cliente si 
					WHERE si.numcte = pNumCte;
				ELSE
					SELECT DISTINCT s.numcte, TRIM(si.nombre1) || ' ' || TRIM(si.nombre2) || ' ' || TRIM(si.apell_paterno) || ' ' || TRIM(si.apell_materno) AS nombre, '1' AS bandera
						INTO cNumCte, cNombre, cBandera
						FROM bdisolic:"informix".ss_solicitudes s
							INNER JOIN bdinteg:"informix".si_cliente si ON  s.numcte = si.numcte
							AND s.num_solicitud = pNumSolicitud;
				END IF;	
				RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
			
			ELSE 
					IF (pNumCte = '') THEN
						LET pNumCte = cNoCte;
					END IF;
					
					SELECT DISTINCT si.numcte, TRIM(si.nombre1) || ' ' || TRIM(si.nombre2) || ' ' || TRIM(si.apell_paterno) || ' ' || TRIM(si.apell_materno) AS nombre, '0' AS bandera
					INTO cNumCte, cNombre, cBandera
					FROM bdinteg:"informix".si_cliente si 
					WHERE si.numcte = pNumCte;
					RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;
		
			END IF;		
			
		RETURN cCodRet, cNumCte,cNumSolicitud,cNombre,cSucursal,dFechaSolicitud,dFechaCambioSolicitud,cStatusSolicitud,cCausaSolicitud, cBandera, cStatus;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 27/04/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CREDITO GRUPO COPPEL',
'DESCRIPCION:SPL que realiza la bÃºsqueda por nÃºmero de solicitud o nÃºmero de cliente que cuentas con estatus RT o CN y motivo de cancelaciÃ³n RGC y CR..',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_consultamanttogat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER		 AS plazo_inicio,
		INTEGER      AS plazo_fin,
		DECIMAL(9,6) AS tasa,
		DECIMAL(9,6) AS gat_nomina,
		DECIMAL(9,6) AS gat_real,
		DATE         AS fecha_publicacion,
		CHAR (2)     AS periodo,
		MONEY (14,2) AS rango_min,
		MONEY (14,2) AS rango_max,
		CHAR(4) 	 AS num_producto,
		CHAR(30)	 AS desc_producto,
		INTEGER 	 AS ROWID; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		     CHAR(5);
	DEFINE iSqlErr 		     INTEGER;
	DEFINE iPlazoInicio      INTEGER;
	DEFINE iPlazoFin 	     INTEGER;
	DEFINE dTasa 		     DECIMAL(9,6);
	DEFINE dGatNomina 	     DECIMAL(9,6);
	DEFINE dGatReal 	     DECIMAL(9,6);
	DEFINE dFechaPublicacion DATE;
	DEFINE iNoRegistros      INTEGER;
	DEFINE iRegistros        INTEGER;
	DEFINE iRecuperacion     INTEGER;
	DEFINE iRowID			 INTEGER;

	DEFINE iPeriodo			 CHAR(2);
	DEFINE iRangoMin		 MONEY (14,2) ;
	DEFINE iRangoMax		 MONEY (14,2) ;
	DEFINE cNumProducto      CHAR(4);
	DEFINE cProductoDesc 	 CHAR(30);

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET iPlazoInicio 	=0;
	LET iPlazoFin 	 	=0;
	LET dTasa 		 	=0.00;
	LET dGatNomina 	 	=0.00;
	LET dGatReal 	 	=0.00;
	LET dFechaPublicacion = '';
	LET iNoRegistros	= 0;
	LET iRegistros 		= 0;
	LET iRecuperacion	= 0;
	LET iRowID	= 0;

	LET iPeriodo		=0;
	LET iRangoMin		=0;
	LET iRangoMax		=0;
	LET cNumProducto 	= '';
	LET cProductoDesc	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultamanttogat.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--pagare,
		IF pBandera = '1' THEN
			FOREACH
				SELECT plazo_inicio, plazo_fin, tasa, gat_nomina, gat_real, periodo, rowid
				INTO 	iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal,iPeriodo, iRowID
				FROM bdinvers:"informix".sv_gat
				ORDER BY 1 ASC

			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
			END FOREACH;
		
		--1100 inversiï¿½n creciente
		ELIF pBandera = '2'  THEN

			FOREACH
				SELECT gat.fecha_publicacion, tipo.num_producto, tipo.desc_producto,  gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
				INTO dFechaPublicacion, cNumProducto, cProductoDesc, dTasa, dGatNomina, dGatReal, iPeriodo , iRowID  
				FROM bdicheq:"informix".sc_gat gat INNER JOIN bdicnweb:"informix".sw_cap_tipoproductogat tipo
				ON gat.producto = tipo.num_producto
				WHERE gat.producto = pProducto
				ORDER BY 1, 8 ASC


			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
			END FOREACH;

	
		ELIF pBandera = '3' THEN
			IF pProducto = "2500" OR pProducto = "2000" OR pProducto = "1900" OR pProducto = "1400" OR pProducto = "2400" OR pProducto = "1800" THEN  
				FOREACH
					SELECT gat.fecha_publicacion, gat.producto, gat.rango_min , gat.rango_max  ,gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
					INTO dFechaPublicacion, cNumProducto, iRangoMin, iRangoMax, dTasa, dGatNomina, dGatReal, iPeriodo, iRowID 
					FROM bdicheq:"informix".sc_gat gat
					WHERE gat.producto = pProducto
					ORDER BY 1, 8 ASC

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
				END FOREACH;
			END IF;

		ELIF pBandera = '4' THEN
			IF pProducto = "2900" OR pProducto = "1300" THEN  
				FOREACH
					SELECT gat.fecha_publicacion, gat.producto, gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
					INTO dFechaPublicacion, cNumProducto, dTasa, dGatNomina, dGatReal, iPeriodo, iRowID
					FROM bdicheq:"informix".sc_gat gat
					WHERE gat.producto = pProducto
					ORDER BY 1, 7 ASC 

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
				END FOREACH;
			END IF;
		END IF;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angï¿½lica Hï¿½rnandez Pï¿½rez',
'FECHA: 09/08/2016',
'MODULO: Dï¿½BITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que realiza la consulta los registros para producto pagare, inversiï¿½n creciente y cuenta ejecutiva jï¿½venes',
'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'DESCRIPCION: Se agregaron nuevas banderas para mostrar los registros de Cuenta Efectiva Digital (2000), Cuenta Efectiva Cheques (1900), Cuenta BÃ¡sica general (1400), Cuenta Clic (2900), Cuenta Platino (2400), Cuenta Efectiva Plus (1800) y Cuenta Efectiva GC (1300)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_calculagat(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) 		AS codret;

/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);

/*======================================
|     INICIALIZACIÃN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

    BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_calculagat.out';
		--TRACE ON;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;

        EXECUTE PROCEDURE bdicheq:"informix".sp_calculagat() INTO cCodRet;
        

        IF cCodRet = '-1202' THEN
            LET cCodRet = '00454'; --Probable divisiÃ³n entre 0 en periodos
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que llama al SP calculagat para calcular automaticamente la GAT para las cuentas de captacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insermedianainflacion(pUsuario CHAR(8), 
													pIdFuncion CHAR(10), 
													pIdConsulta INTEGER, 
													pMedInflacion DECIMAL(9,6), 
													pFechaPublicacion DATETIME YEAR TO FRACTION(3))

RETURNING   CHAR(5)    					 AS codret,
  			DECIMAL(9,6) 				 AS med_inflacion,
    		DATETIME YEAR TO FRACTION(3) AS fecha_publicacion;


/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE dMedianInflacion DECIMAL(9,6);
	DEFINE dfechaPubli 		DATETIME YEAR TO FRACTION(3);
	DEFINE iregistros 		INTEGER;


/*======================================
|     INICIALIZACIÃN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

	LET dMedianInflacion = 0.0;
	LET dfechaPubli = "";
	LET iregistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_insermedianainflacion.out';
		--TRACE ON;

		IF  pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;

		IF pIdConsulta = '2' THEN
			IF pMedInflacion IS NULL OR pFechaPublicacion IS NULL OR pMedInflacion = '' OR pFechaPublicacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dMedianInflacion, dfechaPubli;
			END IF;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,dMedianInflacion, dfechaPubli;
			END IF;

		/* CONSULTAMOS LA TODAS LAS MEDIANAS DE INFLACIÃN */
		IF pIdConsulta = '1' THEN 
			FOREACH
				SELECT med_inflacion, fecha_publicacion
				INTO dMedianInflacion, dfechaPubli
				FROM bdicheq:sc_medianainflacion 
				ORDER BY 2 DESC
				
				LET iregistros = iregistros + 1;
				RETURN cCodRet,dMedianInflacion, dfechaPubli WITH RESUME;
			END FOREACH;

		/* INSERCIÃN DE UNA NUEVA MEDIANA DE INFLACIÃN*/
		ELIF pIdConsulta = '2' THEN 
			INSERT INTO bdicheq:sc_medianainflacion(med_inflacion, fecha_publicacion) VALUES (pMedInflacion, pFechaPublicacion);
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;	

		IF iregistros = 0 THEN
			LET cCodRet = "00017";
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;
	END;
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 27/06/2023',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MEDIANA INFLACIÃN ',
'DESCRIPCION: SP ENCARGADO DE REALIZAR CONSULTAR TODAS LAS MEDIANAS DE INFLACIÃN EXISTENTES EN LA TABLA bdicheq:sc_medianainflacion (IdConsulta = 1) Ã REALIZAR LA INSERCIÃN DE UNA NUEVA MEDIANA DE INFLACIÃN (IdConsulta = 2)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_grabarcambiostatusolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud1 CHAR(20), pNumSolicitud2 CHAR(20), pNumCliente CHAR(20), pEjecutivoAnaliza CHAR(10), pEjecutivoAutoriza CHAR(10), pStatusInicial CHAR(2), pStatusFinal CHAR(2), pMontoAnterior  DECIMAL(18,2), pMontoNuevo DECIMAL(18,2), pCausa CHAR(3), pComentario CHAR(500), pTipoMovto CHAR(1), pTipoBusqueda CHAR(1), pBanderaMotor CHAR(1))

        RETURNING CHAR(5) AS codret, CHAR(80) AS DESCRIPCION, CHAR(1) AS BANDERAMOTORMC;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;
        DEFINE cMensaje CHAR(80);
        DEFINE cEmpresa CHAR(3);
	DEFINE cBanderaMotorMC CHAR(1);
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET cMensaje = '';
        LET cEmpresa = '001';
	LET cBanderaMotorMC = '0';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cMensaje, cBanderaMotorMC;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_grabarcambiostatusolicitudmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud1 = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,  cMensaje, cBanderaMotorMC;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,  cMensaje, cBanderaMotorMC;
                END IF;
                
                EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_grabacambiostatus (cEmpresa, pNumSolicitud1, pNumSolicitud2, pNumCliente, pEjecutivoAnaliza, pEjecutivoAutoriza, 
                            pStatusInicial, pStatusFinal, pMontoAnterior, pMontoNuevo, pCausa, UPPER(pComentario), pTipoMovto, pTipoBusqueda, pBanderaMotor) INTO cCodRetSp, cMensaje, cBanderaMotorMC;

                IF cCodRetSp::INTEGER < 0 THEN
                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂON DEL SP bdisolic:sp_mc_grabacambiostatus';
                ELIF cCodRetSp::INTEGER = 1 THEN
                        LET cCodRet = '00003';
                ELIF cCodRetSp::INTEGER = 2 THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
                        LET cCodRet = '00219';
                ELIF cCodRetSp::INTEGER = 3 THEN -- ERROR AL PROCESAR LA SOLICITUD
                        LET cCodRet = '00236';
                END IF;
                
                RETURN cCodRet, cMensaje, cBanderaMotorMC;
        
        END;
                                                
END PROCEDURE

;