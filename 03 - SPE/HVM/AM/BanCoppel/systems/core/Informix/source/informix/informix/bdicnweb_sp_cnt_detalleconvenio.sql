CREATE PROCEDURE "informix".sp_cnt_detalleconvenio(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(5))
    RETURNING CHAR(5) AS codRet,
		CHAR(2) AS numcategoria, 
		CHAR(3)  AS numconvenio, 
		CHAR(40) AS nomconvenio, 
		DATE AS fechaapertura, 
		DATE AS fechaclausura, 
		DATE AS fechaalta,
		CHAR(1) AS statusconvenio, 
		CHAR(1) AS tipo_referencia, 
		CHAR(40) AS nomlegalempresa, 
		CHAR(13) AS rfcempresa, 
		CHAR(40) AS nomcomercialempresa,
		CHAR(80) AS direccionempresa, 
		CHAR(30) AS estado, 
		CHAR(30) AS ciudad, 
		CHAR(5)  AS codpostal, 
		CHAR(10) AS numtelcorporativo, 
		CHAR(10) AS numfaxcorporativo,
		CHAR(40) AS nomcontacto1, 
		CHAR(10) AS numtelcontacto1, 
		CHAR(7) AS numextcontacto1, 
		CHAR(40) AS emailcontacto1, 
		CHAR(40) AS nomcontacto2,
		CHAR(10) AS numtelcontacto2, 
		CHAR(7) AS numextcontacto2, 
		CHAR(40) AS emailcontacto2, 
		CHAR(40) AS nomcontacto3, 
		CHAR(10) AS numtelcontacto3,
		CHAR(7) AS numextcontacto3, 
		CHAR(40) AS emailcontacto3, 
		CHAR(18) AS numcuentaclabe, 
		CHAR(1) AS tipopago, 
		INTEGER AS frecuenciapago,
		CHAR(1) AS flgarchnotificacion, 
		INTEGER AS frecnotificacion, 
		CHAR(1) AS flgporccomtrans_conv, 
		DECIMAL(16,2) AS porc_com_trans_conv, 
		CHAR(1) AS flgporccomtotal_conv,
		DECIMAL(16,2) AS porc_com_total_conv, 
		CHAR(1) AS flgimpcomtrans_conv, 
		MONEY(16,2) AS imp_com_trans_conv, 
		CHAR(1) AS flgimpcomtotal_conv, 
		MONEY(16,2)AS imp_com_total_conv,
		CHAR(1) AS flgivaincluido_conv, 
		INTEGER  AS iva_convenio, 
		CHAR(1) AS flgporccomtrans_cte, 
		DECIMAL(16,2)  AS porc_com_trans_cte, 
		CHAR(1) AS flgimpcomtrans_cte,
		MONEY(16,2)AS imp_com_trans_cte, 
		CHAR(1) AS flg_ref1, 
		INTEGER AS longitud_ref1, 
		CHAR(1) AS flgcalculodv_ref1, 
		CHAR(30)  AS nomrutinadv_ref1, 
		CHAR(1) AS flg_ref2,
		INTEGER AS longitud_ref2, 
		CHAR(1) AS flgcalculodv_ref2, 
		CHAR(30) AS nomrutinadv_ref2, 
		CHAR(1) AS flgreporte, 
		CHAR(30) AS nomreporte,
		CHAR(20) AS desc_tipo_referencia,
		CHAR(20) AS desc_statusconvenio,
		CHAR(10) AS desc_tipopago,
		CHAR(2) AS desc_flgarchnotificacion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	DEFINE cNumcategoria        		CHAR(2);
    DEFINE cNumconvenio         		CHAR(3);
    DEFINE cNomconvenio         		CHAR(40);
    DEFINE dFechaapertura       		DATE;
    DEFINE dFechaclausura       		DATE;
    DEFINE dFecha_alta          		DATE;
    DEFINE cStatusconvenio      		CHAR(1);
    DEFINE cTipo_Referencia     		CHAR(1);
    DEFINE cNomlegalempresa     		CHAR(40);
    DEFINE cRfcempresa          		CHAR(13);
    DEFINE cNomcomercialempresa 		CHAR(40);
    DEFINE cDireccionempresa    		CHAR(80);
    DEFINE cEstado              		CHAR(30);
    DEFINE cCiudad              		CHAR(30);
    DEFINE cCodpostal           		CHAR(5);
    DEFINE cNumtelcorporativo   		CHAR(10);
    DEFINE cNumfaxcorporativo   		CHAR(10);
    DEFINE cNomcontacto1        		CHAR(40);
    DEFINE cNumtelcontacto1     		CHAR(10);
    DEFINE cNumextcontacto1     		CHAR(7);
    DEFINE cEmailcontacto1      		CHAR(40);
    DEFINE cNomcontacto2        		CHAR(40);
    DEFINE cNumtelcontacto2     		CHAR(10);
    DEFINE cNumextcontacto2     		CHAR(7);
    DEFINE cEmailcontacto2      		CHAR(40);
    DEFINE cNomcontacto3        		CHAR(40);
    DEFINE cNumtelcontacto3     		CHAR(10);
    DEFINE cNumextcontacto3     		CHAR(7);
    DEFINE cEmailcontacto3      		CHAR(40);
    DEFINE cNumcuentaclabe      		CHAR(18);
    DEFINE cTipopago            		CHAR(1);
    DEFINE iFrecuenciapago      		INTEGER;
    DEFINE cFlgarchnotificacion 		CHAR(1);
    DEFINE iFrecnotificacion    		INTEGER;
    DEFINE cFlgporccomtrans_conv 		CHAR(1);
    DEFINE dePorc_com_trans_conv 		DECIMAL(16,2);
    DEFINE cFlgporccomtotal_conv 		CHAR(1);
    DEFINE dePorc_com_total_conv 		DECIMAL(16,2);
    DEFINE cFlgimpcomtrans_conv  		CHAR(1);
    DEFINE mImp_com_trans_conv   		MONEY(16,2);
    DEFINE cFlgimpcomtotal_conv  		CHAR(1);
    DEFINE mImp_com_total_conv   		MONEY(16,2);
    DEFINE cFlgivaincluido_conv  		CHAR(1);
    DEFINE iIva_Convenio         		INTEGER;
    DEFINE cFlgPorcComTransCte   		CHAR(1);
    DEFINE dePorc_com_trans_cte  		DECIMAL(16,2);
    DEFINE cFlgImpComTransCte    		CHAR(1);
    DEFINE mImp_com_trans_cte    		MONEY(16,2);
    DEFINE cFlg_Ref1             		CHAR(1);
    DEFINE iLongitudRef1         		INTEGER;
    DEFINE cFlgcalculodv_ref1    		CHAR(1);
    DEFINE cNomrutinadv_ref1     		CHAR(30);
    DEFINE cFlg_Ref2             		CHAR(1);
    DEFINE iLongitudRef2         		INTEGER;
    DEFINE cFlgcalculodv_ref2    		CHAR(1);
    DEFINE cNomrutinadv_ref2     		CHAR(30);
    DEFINE cFlgreporte           		CHAR(1);
    DEFINE cNomreporte           		CHAR(30);
	DEFINE cDesc_Tipo_Referencia		CHAR(20);
	DEFINE cDesc_Statusconvenio			CHAR(20);
	DEFINE cDesc_Tipopago 				CHAR(10);
	DEFINE cDesc_Flgarchnotificacion 	CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	
	LET cNumcategoria        	 		= '';
    LET cNumconvenio         	 		= '';
    LET cNomconvenio         	 		= '';
    LET dFechaapertura       	 		= '';
    LET dFechaclausura       	 		= '';
    LET dFecha_alta          	 		= '';
    LET cStatusconvenio      	 		= '';
    LET cTipo_Referencia     	 		= '';
    LET cNomlegalempresa     	 		= '';
    LET cRfcempresa          	 		= '';
    LET cNomcomercialempresa 	 		= '';
    LET cDireccionempresa    	 		= '';
    LET cEstado              	 		= '';
    LET cCiudad              	 		= '';
    LET cCodpostal           	 		= '';
    LET cNumtelcorporativo   	 		= '';
    LET cNumfaxcorporativo   	 		= '';
    LET cNomcontacto1        	 		= '';
    LET cNumtelcontacto1     	 		= '';
    LET cNumextcontacto1     	 		= '';
    LET cEmailcontacto1      	 		= '';
    LET cNomcontacto2        	 		= '';
    LET cNumtelcontacto2     	 		= '';
    LET cNumextcontacto2     	 		= '';
    LET cEmailcontacto2      	 		= '';
    LET cNomcontacto3        	 		= '';
    LET cNumtelcontacto3     	 		= '';
    LET cNumextcontacto3     	 		= '';
    LET cEmailcontacto3      	 		= '';
    LET cNumcuentaclabe      	 		= '';
    LET cTipopago            	 		= '';
    LET iFrecuenciapago      	 		= 0;
    LET cFlgarchnotificacion 	 		= '';
    LET iFrecnotificacion    	 		= 0;
    LET cFlgporccomtrans_conv	 		= '';
    LET dePorc_com_trans_conv	 		= 0.00;
    LET cFlgporccomtotal_conv	 		= '';
    LET dePorc_com_total_conv	 		= 0.00;
    LET cFlgimpcomtrans_conv 	 		= '';
    LET mImp_com_trans_conv 	 		= 0.00;
    LET cFlgimpcomtotal_conv 	 		= '';
    LET mImp_com_total_conv 	 		= 0.00;
    LET cFlgivaincluido_conv 	 		= '';
    LET iIva_Convenio        	 		= 0;
    LET cFlgPorcComTransCte  	 		= '';
    LET dePorc_com_trans_cte 	 		= 0.00;
    LET cFlgImpComTransCte   	 		= '';
    LET mImp_com_trans_cte  	 		= 0.00;
    LET cFlg_Ref1            	 		= '';
    LET iLongitudRef1        	 		= 0;
    LET cFlgcalculodv_ref1   	 		= '';
    LET cNomrutinadv_ref1    	 		= '';
    LET cFlg_Ref2            	 		= '';
    LET iLongitudRef2        	 		= 0;
    LET cFlgcalculodv_ref2   	 		= '';
    LET cNomrutinadv_ref2    	 		= '';
    LET cFlgreporte          	 		= '';
    LET cNomreporte          	 		= '';
	LET cDesc_Tipo_Referencia			= '';
	LET cDesc_Statusconvenio			= '';
	LET cDesc_Tipopago 					= '';
	LET cDesc_Flgarchnotificacion		= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
                cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
                cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
                cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
                iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte,
				cDesc_Tipo_Referencia, cDesc_Statusconvenio, cDesc_Tipopago, cDesc_Flgarchnotificacion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_detalleconvenio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConvenio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
			cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
			cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
			cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
			cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
			iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte,
			cDesc_Tipo_Referencia, cDesc_Statusconvenio, cDesc_Tipopago, cDesc_Flgarchnotificacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
			cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
			cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
			cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
			cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
			iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte,
			cDesc_Tipo_Referencia, cDesc_Statusconvenio, cDesc_Tipopago, cDesc_Flgarchnotificacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sacconsultascentral(pConvenio)
		INTO cCodRetSp, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
		cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
		cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
		cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
		cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
		iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdisac:"informix".sp_sacconsultascentral';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '01123'; --NO EXISTE INFORMACIÓN PARA EL CONVENIO SELECCIONADO
			RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
			cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
			cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
			cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
			cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
			iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte,
			cDesc_Tipo_Referencia, cDesc_Statusconvenio, cDesc_Tipopago, cDesc_Flgarchnotificacion;
		END IF;
				
		SELECT descripcion INTO cDesc_Tipo_Referencia FROM bdisac:"informix".sac_tiporeferencia WHERE tipo_referencia = cTipo_Referencia;
		SELECT descripcion INTO cDesc_Statusconvenio FROM bdisac:"informix".sac_statusconvenio WHERE status = cStatusconvenio;
		
		IF NVL(cTipopago,'') = 'N' THEN
			LET cDesc_Tipopago = 'NETO';
		ELSE
			LET cDesc_Tipopago = 'BRUTO';
		END IF;
		
		IF NVL(cFlgarchnotificacion,'') = '1' THEN
			LET cDesc_Flgarchnotificacion = 'SI';
		ELSE
			LET cDesc_Flgarchnotificacion = 'NO';
		END IF;
				
		RETURN cCodRet, cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, dFecha_alta, cStatusconvenio, cTipo_Referencia, cNomlegalempresa, cRfcempresa, cNomcomercialempresa,
		cDireccionempresa, cEstado, cCiudad, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1, cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2,
		cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3, cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago,
		cFlgarchnotificacion, iFrecnotificacion, cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
		cFlgimpcomtotal_conv, mImp_com_total_conv, cFlgivaincluido_conv, iIva_Convenio, cFlgPorcComTransCte, dePorc_com_trans_cte, cFlgImpComTransCte, mImp_com_trans_cte, cFlg_Ref1,
		iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2, cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte,
		cDesc_Tipo_Referencia, cDesc_Statusconvenio, cDesc_Tipopago, cDesc_Flgarchnotificacion;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/05/2019',
'MODULO: CONTRALORÍA',
'FUNCIONALIDAD: CONSULTA DE CONVENIOS SAC',
'DESCRIPCION: Spl encargado de consultar el detalle del convenio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_genreportesfaltdescemp(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,
pEjecutivo CHAR(8), pSucursal CHAR(4), pZona CHAR(3), pRegional CHAR(3), pIdAsignado SMALLINT, pEstatus SMALLINT, pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_archivo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	--DEFINE dFecha DATE;
	--DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);	
	DEFINE iRegistros INTEGER;
	DEFINE iCountRep INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	--
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cNumSucursal CHAR(4);
	DEFINE sIdFaltante SMALLINT;
	DEFINE cNombre CHAR(45);
	DEFINE dFechaRegistro DATE;
	DEFINE mSaldoActual MONEY(10,0);
	DEFINE cEstatus CHAR(10);
	DEFINE cOperador CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaInformix = '/informix/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dHoy = '';
	--LET dFecha = '';
	--LET cFecha = '';
	LET dHora = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET iRegistros = 0;
	LET iCountRep = 0;
    LET iRecuperacion = 0;
	LET iNumRegistros = 0;
	--
	LET cNumEmpleado = '';
	LET cNumSucursal = '';
	LET sIdFaltante = 0;
	LET cNombre = '';
	LET dFechaRegistro = '';
	LET mSaldoActual = 0.00;
	LET cEstatus = '';
	LET cOperador = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_genreportesfaltdescemp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRutaDescarga = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;	
		
		-- SE ASIGNAN VALORES PARA LA GENERACIÓN DEL REPORTE
		LET cNombreReporte = 'REPORTEFALTANTESDESCUENTOSEMPLEADOS.xls';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA PRINCIPAL
		DELETE FROM "informix".sw_cnt_detallerepfaltdescemp WHERE usuario_insert = pUsuario;
		
		FOREACH 
		
			EXECUTE PROCEDURE bdirech:"informix".spconsultarfaltante_reporte(pEjecutivo, pSucursal, pZona, pRegional, pIdAsignado, pFechaInicio, pFechaFin, pEstatus)
			INTO cNumEmpleado,cNumSucursal,sIdFaltante,cNombre,dFechaRegistro,mSaldoActual,cEstatus,cOperador
			
			IF cNumEmpleado::INTEGER < 0 THEN 
				RAISE EXCEPTION cNumEmpleado::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdirech:"informix".spconsultarfaltante_reporte';
			ELSE
				
				LET iRegistros = iRegistros + 1;
				INSERT INTO "informix".sw_cnt_detallerepfaltdescemp(num_empleado,num_sucursal,id_faltante,nombre,fecha_registro,saldo_actual,estatus,operador,usuario_insert,fecha_insert)
				VALUES(cNumEmpleado,cNumSucursal,sIdFaltante,cNombre,dFechaRegistro,mSaldoActual,cEstatus,cOperador,pUsuario,dFechaHoy);
				
			END IF;
			
		END FOREACH;
		
		LET cCmd1 ="";
		LET cCmd1 = "SELECT 'NO. EMPLEADO','NO. SUCURSAL','ID FALTANTE','NOMBRE','FECHA REGISTRO','SALDO ACTUAL','ESTATUS','OPERADOR'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT num_empleado,num_sucursal,id_faltante::CHAR(6),nombre,NVL(TO_CHAR(fecha_registro, '%d/%m/%Y'), ''),saldo_actual::CHAR(10),UPPER(estatus),UPPER(operador)";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cnt_detallerepfaltdescemp";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"'";	
		LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
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
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
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
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, cNombreReporte;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 09/04/2019',
'MODULO: CONTRALORÍA',
'FUNCIONALIDAD: CONSULTA DE FALTANTES Y DESCUENTOS DE EMPLEADOS',
'DESCRIPCION: Spl encargado de generar los reportes de la consulta de faltantes y descuentos de empleados en formato xls.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnt_verificastatusgenreportesolcred(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(100) AS nombre_reporte,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cNombreReporte CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cNombreReporte = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cNombreReporte,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnt_verificastatusgenreportesolcred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cNombreReporte,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cNombreReporte,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,nombre_reporte,error_proceso,error
		INTO cStatus,cNombreReporte,cErrorProceso,cError
		FROM "informix".sw_ctrlgenrepdetallesolcred WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cNombreReporte,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 25/04/2019',
'MODULO: CONTRALORÍA',
'FUNCIONALIDAD: REPORTE DE SOLICITUDES DE CRÉDITO',
'DESCRIPCION: SPL encargado de verificar el status de la generación del reporte de solicitudes de crédito en formato txt.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_genarch_aumlimcred_mc(pIdUsuario CHAR(8), pIdFuncion CHAR(10),pTipoReporte CHAR(1),pNombreReporte CHAR(50),pRutaDescarga CHAR(150),pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60))
        RETURNING CHAR(5) AS codret;

        DEFINE cCodRet 				CHAR(5);
        DEFINE iSqlErr 				INT;
        DEFINE cCmd1 				CHAR(8000);
		DEFINE cCmd2 				CHAR(8000);
		DEFINE cArchDescarga		CHAR(200);
		DEFINE iNoRegistros         INT;
		DEFINE cCodRetSp		    CHAR(5);
		DEFINE cRutaInformix CHAR(100);
		DEFINE cUsrBin CHAR(100);
		DEFINE cNameReport CHAR(60);
		DEFINE ven_transacc SMALLINT;
		DEFINE bInTransaction BOOLEAN;
		DEFINE cSql CHAR(8000);
		DEFINE cNombreReporteHist CHAR(100);
		DEFINE dFechaHoy DATE;
		DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCmd1 = '';
		LET cCmd2 = '';
		LET cArchDescarga = '';
		LET cCodRetSp = '00000';
		LET cRutaInformix = '/ifxsif01/bin/';
		LET cUsrBin = '/usr/bin/';
		LET cNameReport = '';
		LET ven_transacc = 0;
		LET bInTransaction = 'f';
		LET cSql = '';
		LET cNombreReporteHist = '';
		LET dFechaHoy = '';
		LET dHoraHoy = '';
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					IF ven_transacc = 1 THEN
						ROLLBACK WORK; 
					END IF;
					RETURN cCodRet;
			END EXCEPTION;
			
			ON EXCEPTION IN (-668, -535, -255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
			END EXCEPTION WITH RESUME;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_genarch_aumlimcred_mc.out';
			--TRACE ON;
		
			IF pIdUsuario = '' OR pIdFuncion = '' OR pTipoReporte = '' OR pNombreReporte = '' OR pRutaDescarga = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			BEGIN WORK;					

			LET cArchDescarga = TRIM(TRIM(pRutaDescarga)||TRIM(pNombreReporte));
			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;
			
			IF pTipoReporte = '1' THEN -- DETALLE
				LET cCmd1 ="";
				LET cCmd1 ="SELECT 'FECHA ORIGEN','NO. SOLICITUD','NO. CLIENTE','ORIGEN','MANUAL / AUTOMATICO','FECHA INGRESO AC','HORA INGRESO AC','APELLIDO PATERNO','APELLIDO MATERNO','NOMBRE','LINEA ACTUAL','LINEA SUGERIDA','% INCREMENTO','ESTATUS','FECHA ATENCION','HORA ATENCION','ASIGNADO A (ANALISTA MC)','ASIGNADO A (2O NIVEL)','ASIGNADO A (3ER NIVEL)','ASIGNADO A (4TO NIVEL)','MOTIVO CANCELACION / RECHAZO' FROM systables WHERE tabid = 1";	
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT ";
				LET cCmd1 =""||TRIM(cCmd1)||" TO_CHAR(fecha_origen,'%d/%m/%Y'), ''''||numero_solicitud, numero_cliente, origen, UPPER(tipoincremento), fechaingresoac::CHAR(20), horaingresoac::CHAR(20),";
				LET cCmd1 =""||TRIM(cCmd1)||" apellido_paterno, apellido_materno, nombre, TO_CHAR(lincredactual::MONEY(18,2)) , TO_CHAR(lincredsugerida::MONEY(18,2)) , incremento||'%', status, fechaatencion::CHAR(20),";
				LET cCmd1 =""||TRIM(cCmd1)||" horaatencion::CHAR(20), analistacac, analista2nivel, analista3nivel, analista4nivel, motivo";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_incremento_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
			ELIF pTipoReporte = '2' THEN -- STATUS
				LET cCmd1 ="";
				LET cCmd1 ="SELECT 'ESTATUS','CASOS TOTALES','% DEL TOTAL' FROM systables WHERE tabid = 1";	
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT ";
				LET cCmd1 =""||TRIM(cCmd1)||" descripcion, total_status::CHAR(11), porcentaje|| '%'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_status_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT FIRST 1";
				LET cCmd1 =""||TRIM(cCmd1)||" 'TOTAL:', total_general::CHAR(11), (CASE WHEN total_status = 0 THEN '0.00%' ELSE '100.00%' END )";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_status_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
			ELIF pTipoReporte = '3' THEN -- STATUS CENTRAL
				LET cCmd1 ="";
				LET cCmd1 ="SELECT 'ORIGEN','CASOS MC','% DEL TOTAL','CASOS AUTOMATICOS','%  DEL TOTAL' FROM systables WHERE tabid = 1";	
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT ";
				LET cCmd1 =""||TRIM(cCmd1)||" descripcion, totalregcasoscac::CHAR(11), porcentajecasoscac|| '%', totalregcasosauto::CHAR(11), porcentajecasosauto|| '%'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_statuscentral_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT FIRST 1";
				LET cCmd1 =""||TRIM(cCmd1)||" 'TOTAL:', totcac::CHAR(11), porcac|| '%', totauto::CHAR(11), porauto|| '%'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_statuscentral_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
			ELIF pTipoReporte = '4' THEN --MC
				LET cCmd1 ="";
				LET cCmd1 ="SELECT 'ORIGEN','CASOS CENTRAL','% DEL TOTAL','CASOS SUCURSAL','%  DEL TOTAL' FROM systables WHERE tabid = 1";	
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT ";
				LET cCmd1 =""||TRIM(cCmd1)||" descripcion, totalregcentral::CHAR(11), porcentajecentral|| '%', totalregsucursal::CHAR(11), porcentajesucursal|| '%'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_mesac_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT FIRST 1";
				LET cCmd1 =""||TRIM(cCmd1)||" 'TOTAL:', totalcentral::CHAR(11), totporcentral|| '%', totalsucursal::CHAR(11), totporsucursal|| '%'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_mesac_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
			ELIF pTipoReporte = '5' THEN -- PERFIL
				LET cCmd1 ="";
				LET cCmd1 ="SELECT 'NO. EMPLEADO','NOMBRE','PERFIL DE PUESTO','ATENDIDAS','%','CANCELADAS','%','RECHAZADAS','%','AUTORIZADAS','%'  FROM systables WHERE tabid = 1";	
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT ";
				LET cCmd1 =""||TRIM(cCmd1)||" numempleado, nombre, perfil_puesto, atendidas::CHAR(11), porcatendidas|| '%', canceladas::CHAR(11), porccanceladas|| '%', rechazadas::CHAR(11), porcrechazadas|| '%', autorizadas::CHAR(11), porcautorizadas|| '%' ";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_perfil_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
				LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ";
				LET cCmd1 =""||TRIM(cCmd1)||" (SELECT FIRST 1";
				LET cCmd1 =""||TRIM(cCmd1)||" 'TOTAL:', ' ', ' ', totalatendidas::CHAR(11), totalporcatendidas|| '%', totalcanceladas::CHAR(11), totalporccanceladas|| '%', totalrechazadas::CHAR(11), totalporcrechazadas|| '%', totalautorizadas::CHAR(11), totalporcautorizadas|| '%' ";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_aumlim_perfil_mc";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert ='"||pIdUsuario||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND report_name = '"||TRIM(pNombreReporte)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ) ";
			END IF;
			
			--TRACE 'SQL: '||TRIM(cCmd1);
			
			LET cCmd2 = '';
			LET cCmd2 = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cArchDescarga)||' DELIMITER '','' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'queryAumLimMC.sql';
			SYSTEM TRIM(cCmd2);				
		
			LET cCmd1 = '';
			LET cCmd1 = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'queryAumLimMC.sql';
			SYSTEM TRIM(cCmd1); 
						
			LET cCmd1 = '';
			LET cCmd1 = TRIM(cUsrBin)||"rm -rf "||TRIM(pRutaDescarga)||'queryAumLimMC.sql';
			SYSTEM TRIM(cCmd1);		
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			-- DEPURACION TABLAS DE TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1) 			
			DELETE bdicnweb:"informix".sw_cons_aumlim_incremento_mc WHERE usuario_insert = pIdUsuario AND fechahora_insert < dFechaHoy;
			DELETE bdicnweb:"informix".sw_cons_aumlim_status_mc WHERE usuario_insert = pIdUsuario AND fechahora_insert < dFechaHoy;
			DELETE bdicnweb:"informix".sw_cons_aumlim_statuscentral_mc WHERE usuario_insert = pIdUsuario AND fechahora_insert < dFechaHoy;
			DELETE bdicnweb:"informix".sw_cons_aumlim_mesac_mc WHERE usuario_insert = pIdUsuario AND fechahora_insert < dFechaHoy;
			DELETE bdicnweb:"informix".sw_cons_aumlim_perfil_mc WHERE usuario_insert = pIdUsuario AND fechahora_insert < dFechaHoy;
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)			
			FOREACH
			
				SELECT nombre_reporte
				INTO cNombreReporteHist
				FROM bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc 
				WHERE usuario_insert = pIdUsuario 
				AND fecha_reporte < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
				SYSTEM TRIM(cSql);
				
				DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc WHERE nombre_reporte = TRIM(cNombreReporteHist);
				
			END FOREACH;

			COMMIT WORK;			
		
			LET ven_transacc = 0;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
					
			-- SE REGISTRA EN BITÃCORA	
			INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
			VALUES(TRIM(pNombreReporte),dFechaHoy,dHoraHoy,pIdUsuario);		
			
			/*
			-- NOTIFICACIÃN VÃA CORREO ELECTRÃNICO
			LET cStr7 = 'GENERACIÃN DEL ARCHIVO CSV';
			LET cStr9 = 'INCREMENTO DE LÃNEAS DE CRÃDITO ';
			LET dHoy = CURRENT;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1', 
			TRIM(pIdPlantilla),
			TRIM(pIdPlantilla), 
			pUsuario, 
			'',
			'', 
			'1', 
			'',
			'',
			'',
			'',
			'',
			TRIM(pTituloPlantilla),
			TRIM(cStr7),
			'',
			TRIM(cStr9),
			pUsuario,
			'',
			'',
			'0',
			'0',
			'0',
			'0',
			'0',
			dHoy,
			dHoy) INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÃN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
			END IF;
			*/
		
			RETURN cCodRet;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl encargado de generar archivo csv de reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_genreportes_aumlimcred_mc(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoReporte CHAR(1), pRutaDescarga CHAR(100), 
pFechainicial DATE, pFechaFinal DATE, pStatus CHAR(2), pOrigen CHAR(1), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60))
    RETURNING CHAR(5) AS codret,
                CHAR(45) AS reporte_generado;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE cNombreArchivo CHAR(50);
        DEFINE iNumRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cNombreArchivo = '';
        LET iNumRegistros = 0;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNombreArchivo;
                END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_genreportes_aumlimcred_mc.out';
        --TRACE ON;
		
		-- VALIDACION REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoReporte = '' OR pRutaDescarga = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNombreArchivo;
		END IF;
		-- 1 = DETALLE DE INCREMENTOS
		IF pTipoReporte = '1' THEN 
			IF pStatus = '' OR pOrigen = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNombreArchivo;
			END IF;
		END IF;
		-- 2 = ESTATUS
		IF pTipoReporte = '2' THEN 
			IF pOrigen = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNombreArchivo;
			END IF;
		END IF;
		
        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		IF pTipoReporte = '1' THEN -- DETALLE
		
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consultagralautaumlincred_rep(pUsuario, pIdFuncion, pFechainicial, pFechaFinal, pStatus, pOrigen) INTO cCodRetSp, iNumRegistros, cNombreArchivo;
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultagralautaumlincred_rep';
				ELIF iCodRetSp > 0 THEN
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cNombreArchivo;
				END IF;

		ELIF pTipoReporte = '2'  THEN -- STATUS
		
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consultagralstatusaumlincred_rep(pUsuario, pIdFuncion, pFechainicial, pFechaFinal, pOrigen) INTO cCodRetSp, iNumRegistros, cNombreArchivo;
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultagralstatusaumlincred_rep';
				ELIF iCodRetSp > 0 THEN
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cNombreArchivo;
				END IF;
				
		ELIF pTipoReporte = '3'  THEN -- STATUS CENTRAL
		
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consultarevisioncentralaumlincred_rep(pUsuario, pIdFuncion, pFechainicial, pFechaFinal) INTO cCodRetSp, iNumRegistros, cNombreArchivo;
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultarevisioncentralaumlincred_rep';
				ELIF iCodRetSp > 0 THEN
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cNombreArchivo;
				END IF;
				
		ELIF pTipoReporte = '4'  THEN -- MC
		
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consultarevisioncacaumlincred_rep(pUsuario, pIdFuncion, pFechainicial, pFechaFinal) INTO cCodRetSp, iNumRegistros, cNombreArchivo;
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultarevisioncacaumlincred_rep';
				ELIF iCodRetSp > 0 THEN
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cNombreArchivo;
				END IF;
				
		ELIF pTipoReporte = '5'  THEN --PERFIL
		
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consultaperfilusuarioaumlincred_rep(pUsuario, pIdFuncion, pFechainicial, pFechaFinal) INTO cCodRetSp, iNumRegistros, cNombreArchivo;
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consultaperfilusuarioaumlincred_rep';
				ELIF iCodRetSp > 0 THEN
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, cNombreArchivo;
				END IF;
				
		END IF;
		
		 --SP QUE GENERA ARCHIVO
		LET cCodRetSp = '';
		EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_genarch_aumlimcred_mc(pUsuario, pIdFuncion,pTipoReporte,cNombreArchivo, pRutaDescarga, pIdPlantilla, pTituloPlantilla) INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cnsif_genarch_aumlimcred_mc';
		ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				RETURN cCodRet, cNombreArchivo;
		END IF;

        RETURN cCodRet, cNombreArchivo;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl encargado de generar archivo csv de reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesaumlim_mc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesaumlim_mc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte
			FROM bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 31/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl encargado de consultar los archivo csv generados de reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesaumlim_mc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesaumlim_mc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 31/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl encargado de consultar total de archivo csv generados de reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultagralautaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE, pStatus CHAR(2), pOrigen CHAR(1))
	RETURNING 
		CHAR(5) 	AS codret,
        INT         AS iTotalReg,
        CHAR(50)    AS cNombreReporte;
								  
        DEFINE cCodRet 				CHAR(5);
        DEFINE iSqlErr 				INTEGER;
        DEFINE cCodRetSp 			CHAR(6);
        DEFINE iCodRetSp 			INTEGER;
        DEFINE iRecuperacion 		INTEGER;
        DEFINE cMensajeRetorno  	CHAR(80);
        DEFINE dFechaOrigen     	DATE;
        DEFINE cNumeroSolicitud 	CHAR(20);
        DEFINE cOrigen          	CHAR(1);
        DEFINE cNumeroCliente   	CHAR(20);
        DEFINE cApellidoPaterno 	CHAR(26);
        DEFINE cApellidoMaterno 	CHAR(26);
        DEFINE cNombre          	CHAR(53);
        DEFINE dLincredActual   	DECIMAL(18,2);
        DEFINE dLincredSugerida 	DECIMAL(18,2);
        DEFINE dIncremento      	DECIMAL(18,2);
        DEFINE Status           	CHAR(2);
        DEFINE AnalistaCac      	CHAR(45);
        DEFINE Analista2nivel   	CHAR(45);
        DEFINE Analista3nivel   	CHAR(45);
        DEFINE Analista4nivel   	CHAR(45);
        DEFINE motivo           	CHAR(106);
        DEFINE dFechaIngresoAC  	DATE;
        DEFINE dHoraIngresoAC 		DATETIME HOUR TO FRACTION(3);
        DEFINE dFechaAtencion 		DATE;
        DEFINE dHoraAtencion 		DATETIME HOUR TO FRACTION(3);
        DEFINE cTipoIncremento 			CHAR(10);
		DEFINE cNombreReporte 		CHAR(50);
		
        LET cCodRet 				= '00000';
        LET iSqlErr 				= 0;
        LET cCodRetSp 				= '';
        LET iCodRetSp 				= 0;
        LET iRecuperacion 			= 0;
        LET cMensajeRetorno  		= '';
        LET dFechaOrigen     		= '';
        LET cNumeroSolicitud 		= '';
        LET cOrigen          		= '';
        LET cNumeroCliente   		= '';
        LET cApellidoPaterno 		= '';
        LET cApellidoMaterno 		= '';
        LET cNombre          		= '';
        LET dLincredActual       	= 0;
        LET dLincredSugerida 		= 0;
        LET dIncremento      		= 0;
        LET Status                  = '';  
        LET AnalistaCac      		= '';
        LET Analista2nivel   		= '';
        LET Analista3nivel   		= '';
        LET Analista4nivel   		= '';
        LET motivo           		= '';
        LET dFechaIngresoAC  		= '';
        LET dHoraIngresoAC   		= '';
        LET dFechaAtencion   		= '';
        LET dHoraAtencion    		= '';
		LET cTipoIncremento   		= '';
		LET cNombreReporte			= '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iRecuperacion, cNombreReporte;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultagralautaumlincred_rep.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' OR pStatus = '' OR pOrigen = ''THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iRecuperacion, cNombreReporte;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iRecuperacion, cNombreReporte;
                END IF;
				
				LET cNombreReporte = 'DET_INCREMENTO_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
                FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consulta_gral_aumlincred_aut3(pFechainicial, pFechaFinal, pStatus, pUsuario, pOrigen)
                        INTO cCodRetSp, cMensajeRetorno, dFechaOrigen, cNumeroSolicitud, cOrigen, cNumeroCliente, cApellidoPaterno, cApellidoMaterno, 
                        cNombre, dLincredActual, dLincredSugerida, dIncremento, Status, AnalistaCac, Analista2nivel, Analista3nivel, Analista4nivel, 
                        motivo,dFechaIngresoAC, dHoraIngresoAC, dFechaAtencion,dHoraAtencion, cTipoIncremento
                        
                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consulta_gral_aumlincred_aut3';
                        ELIF iCodRetSp = 000001 THEN
                                LET cCodRet = '00003';
                               RETURN cCodRet, iRecuperacion, cNombreReporte;
                        ELIF iCodRetSp = 000002 THEN
                                LET cCodRet = '00154';
                                RETURN cCodRet, iRecuperacion, cNombreReporte;
                        ELIF iCodRetSp = 000003 THEN
                                LET cCodRet = '00017';
                                RETURN cCodRet, iRecuperacion, cNombreReporte;
                        ELSE
                            LET iRecuperacion = iRecuperacion + 1;
							INSERT INTO bdicnweb:"informix".sw_cons_aumlim_incremento_mc(usuario_insert, report_name, fechahora_insert, fecha_origen, numero_solicitud, origen, numero_cliente, apellido_paterno, apellido_materno, nombre, lincredactual, lincredsugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechaingresoac, horaingresoac, fechaatencion, horaatencion, tipoincremento) 
							VALUES(pUsuario, cNombreReporte, CURRENT, dFechaOrigen, cNumeroSolicitud, cOrigen, cNumeroCliente, cApellidoPaterno, cApellidoMaterno, cNombre, dLincredActual, dLincredSugerida, dIncremento, Status, AnalistaCac, Analista2nivel, Analista3nivel, Analista4nivel, motivo, dFechaIngresoAC, dHoraIngresoAC, dFechaAtencion, dHoraAtencion, cTipoIncremento);

                        END IF;
						
                END FOREACH;
				
				RETURN cCodRet, iRecuperacion, cNombreReporte;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÍNEAS DE CRÉDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Detalle Incremento en reportes de incremento de líneas de crédito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultagralstatusaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE, pOrigen CHAR(2))
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE iTieneCausa INTEGER;
	DEFINE cDescripcion CHAR(100);
	DEFINE iTotalStatus INTEGER;
	DEFINE dPorcentaje DECIMAL(18,2);
	DEFINE iTotalGeneral INTEGER;
	DEFINE cNombreReporte CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET cMensajeRetorno = '';
	LET iTieneCausa 	= 0;
	LET cDescripcion 	= '';
	LET iTotalStatus 	= 0;
	LET dPorcentaje 	= '';
	LET iTotalGeneral 	= 0;
	LET cNombreReporte	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultagralstatusaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		LET cNombreReporte = 'STATUS_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';                
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DROP TABLE tme_consultaincrementos;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_rep_gral_status3(pFechainicial, pFechaFinal, pOrigen)
			INTO cCodRetSp, cMensajeRetorno, iTieneCausa, cDescripcion, iTotalStatus, dPorcentaje, iTotalGeneral
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_rep_gral_status2';
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388';
			ELIF iCodRetSp = 000003 THEN
				LET cCodRet = '00003';
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO bdicnweb:"informix".sw_cons_aumlim_status_mc(usuario_insert, report_name, fechahora_insert, tiene_causa, descripcion, total_status, porcentaje, total_general) 
				VALUES(pUsuario, cNombreReporte, CURRENT, iTieneCausa, cDescripcion, iTotalStatus, dPorcentaje, iTotalGeneral);
				
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÍNEAS DE CRÉDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Estatus en reportes de incremento de líneas de crédito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaperfilusuarioaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE)
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cMensajeRetorno       CHAR(80);
	DEFINE cNumempleado          CHAR(8);
	DEFINE cNombre               CHAR(45);
	DEFINE cPerfilPuesto         CHAR (25);
	DEFINE iAtendidas            INTEGER;
	DEFINE iPorcAtendidas        DECIMAL(18,2);
	DEFINE iCanceladas           INTEGER;
	DEFINE iPorcCanceladas       DECIMAL(18,2);
	DEFINE iRechazadas           INTEGER;
	DEFINE iPorcRechazadas       DECIMAL(18,2);
	DEFINE iAutorizadas          INTEGER;
	DEFINE iPorcAutorizadas      DECIMAL(18,2);
	DEFINE iTotalAtendidas       INTEGER;
	DEFINE iTotalPorcAtendidas   DECIMAL(18,2);
	DEFINE iTotalCanceladas      INTEGER;
	DEFINE iTotalPorcCanceladas  DECIMAL(18,2);
	DEFINE iTotalRechazadas      INTEGER;
	DEFINE iTotalPorcRechazadas  DECIMAL(18,2);
	DEFINE iTotalAutorizadas     INTEGER;
	DEFINE iTotalPorcAutorizadas DECIMAL(18,2);
	DEFINE cNombreReporte        CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET cMensajeRetorno       = '';
	LET cNumempleado          = '';
	LET cNombre               = '';
	LET cPerfilPuesto         = '';
	LET iAtendidas            = 0;
	LET iPorcAtendidas        = 0;
	LET iCanceladas           = 0;
	LET iPorcCanceladas       = 0;
	LET iRechazadas           = 0;
	LET iPorcRechazadas       = 0;
	LET iAutorizadas          = 0;
	LET iPorcAutorizadas      = 0;
	LET iTotalAtendidas       = 0;
	LET iTotalPorcAtendidas   = 0;
	LET iTotalCanceladas      = 0;
	LET iTotalPorcCanceladas  = 0;
	LET iTotalRechazadas      = 0;
	LET iTotalPorcRechazadas  = 0;
	LET iTotalAutorizadas     = 0;
	LET iTotalPorcAutorizadas = 0;
	LET cNombreReporte	      = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaperfilusuarioaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		
		LET cNombreReporte = 'PERFIL_USUARIO_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_perfil_usuario3(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, cNumempleado, cNombre, cPerfilPuesto, iAtendidas, iPorcAtendidas, iCanceladas, iPorcCanceladas, 
				iRechazadas, iPorcRechazadas, iAutorizadas, iPorcAutorizadas, iTotalAtendidas, iTotalPorcAtendidas, 
				iTotalCanceladas, iTotalPorcCanceladas, iTotalRechazadas, iTotalPorcRechazadas, iTotalAutorizadas, 
				iTotalPorcAutorizadas 
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_perfil_usuario3';
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELIF iCodRetSp = 000003 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO informix.sw_cons_aumlim_perfil_mc(usuario_insert, report_name, fechahora_insert, numempleado, nombre, perfil_puesto, atendidas, porcatendidas, canceladas,
				porccanceladas, rechazadas, porcrechazadas, autorizadas, porcautorizadas, totalatendidas, totalporcatendidas, totalcanceladas, totalporccanceladas,
				totalrechazadas, totalporcrechazadas, totalautorizadas, totalporcautorizadas) 
				VALUES(pUsuario, cNombreReporte, CURRENT, cNumempleado, cNombre, cPerfilPuesto, iAtendidas, iPorcAtendidas, iCanceladas, iPorcCanceladas, 
				iRechazadas, iPorcRechazadas, iAutorizadas, iPorcAutorizadas, iTotalAtendidas, iTotalPorcAtendidas, 
				iTotalCanceladas, iTotalPorcCanceladas, iTotalRechazadas, iTotalPorcRechazadas, iTotalAutorizadas, 
				iTotalPorcAutorizadas);
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Perfil Usuario en reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarevisioncacaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE)
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cMensajeRetorno		CHAR(80);
	DEFINE dTieneCausa			INTEGER;
	DEFINE cDescripcion			CHAR(100);
	DEFINE iTotalRegCentral		INTEGER;
	DEFINE dPorcentajeCentral	DECIMAL(18,2);
	DEFINE iTotalCentral		INTEGER;
	DEFINE dTotPorCentral		DECIMAL(18,2);
	DEFINE iTotalRegSucursal	INTEGER;
	DEFINE dPorcentajeSucursal	DECIMAL(18,2);
	DEFINE iTotalSucursal		INTEGER;
	DEFINE dTotPorSucursal		DECIMAL(18,2);
	DEFINE cNombreReporte       CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRecuperacion = 0;
	LET cMensajeRetorno 	= '';
	LET dTieneCausa         = 0;
	LET cDescripcion        = '';
	LET iTotalRegCentral    = 0;
	LET dPorcentajeCentral  = 0;
	LET iTotalCentral       = 0;
	LET dTotPorCentral      = 0;
	LET iTotalRegSucursal   = 0;
	LET dPorcentajeSucursal = 0;
	LET iTotalSucursal      = 0;
	LET dTotPorSucursal     = 0;
	LET cNombreReporte	    = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarevisioncacaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechainicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		LET cNombreReporte = 'MC_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
                
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DROP TABLE tme_consultaincrementos;

		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_revisioncac3(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, dTieneCausa, cDescripcion, iTotalRegCentral, dPorcentajeCentral, iTotalCentral, 
			dTotPorCentral, iTotalRegSucursal, dPorcentajeSucursal, iTotalSucursal, dTotPorSucursal
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_revisioncac3';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARÃMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO bdicnweb:"informix".sw_cons_aumlim_mesac_mc(usuario_insert, report_name, fechahora_insert, tiene_causa, descripcion, totalregcentral, porcentajecentral, totalcentral, totporcentral, totalregsucursal, porcentajesucursal, totalsucursal, totporsucursal) 
				VALUES(pUsuario, cNombreReporte, CURRENT, dTieneCausa, cDescripcion, iTotalRegCentral, dPorcentajeCentral, iTotalCentral, dTotPorCentral, iTotalRegSucursal, dPorcentajeSucursal, iTotalSucursal, dTotPorSucursal);
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Mesa de Control Central en reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarevisioncentralaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechainicial DATE, pFechaFinal DATE)
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cMensajeRetorno      CHAR(80);
	DEFINE iTieneCausa          INTEGER;
	DEFINE cDescripcion         CHAR(100);
	DEFINE iTotalRegCasosCac    INTEGER;
	DEFINE dPorcentajeCasosCac  DECIMAL(18,2);
	DEFINE iTotCAC              INTEGER;
	DEFINE dPorCAC              DECIMAL(18,2);
	DEFINE iTotalRegCasosAuto   INTEGER;
	DEFINE dDorcentajeCasosAuto DECIMAL(18,2);
	DEFINE iTotAUTO             INTEGER;
	DEFINE dPorAUTO             DECIMAL(18,2);
	DEFINE cNombreReporte       CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET cMensajeRetorno      = '';
	LET iTieneCausa          = 0;
	LET cDescripcion         = '';
	LET iTotalRegCasosCac    = 0;
	LET dPorcentajeCasosCac  = 0;
	LET iTotCAC              = 0;
	LET dPorCAC              = 0;
	LET iTotalRegCasosAuto   = 0;
	LET dDorcentajeCasosAuto = 0;
	LET iTotAUTO             = 0;
	LET dPorAUTO             = 0;
	LET cNombreReporte	     = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarevisioncentralaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		LET cNombreReporte = 'STATUS_CENTRAL_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
                
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DROP TABLE tme_consultaincrementos;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_revisioncentral3(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, iTieneCausa, cDescripcion, iTotalRegCasosCac, dPorcentajeCasosCac, iTotCAC, 
				dPorCAC, iTotalRegCasosAuto, dDorcentajeCasosAuto, iTotAUTO, dPorAUTO
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_revisioncentral';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO bdicnweb:"informix".sw_cons_aumlim_statuscentral_mc(usuario_insert, report_name, fechahora_insert, tiene_causa, descripcion, totalregcasoscac, porcentajecasoscac, totcac, porcac, totalregcasosauto, porcentajecasosauto, totauto, porauto) 
				VALUES(pUsuario, cNombreReporte, CURRENT, iTieneCausa, cDescripcion, iTotalRegCasosCac, dPorcentajeCasosCac, iTotCAC, dPorCAC, iTotalRegCasosAuto, dDorcentajeCasosAuto, iTotAUTO, dPorAUTO);
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÍNEAS DE CRÉDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Status Central en reportes de incremento de líneas de crédito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportessolicitudessupmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), 
pNumCliente CHAR(20), pNumSolicitud CHAR(20), pFechaInicio DATE, pFechaFin DATE, pStatus CHAR(2), pProducto CHAR(4),
pRutaDescarga CHAR(100), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	--DEFINE dFecha DATE;
	--DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);	
	DEFINE iRegistros INTEGER;
	DEFINE iCountRep INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	--
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(130);
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaCambioStatus DATE;
	DEFINE cStatus CHAR(2);
	DEFINE cRespuestaOs CHAR(8);
	DEFINE cTotss_solsuperv_paso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dHoy = '';
	--LET dFecha = '';
	--LET cFecha = '';
	LET dHora = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET iRegistros = 0;
	LET iCountRep = 0;
    LET iRecuperacion = 0;
	LET iNumRegistros = 0;
	--
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET dFechaSolicitud = '';
	LET dFechaCambioStatus = '';
	LET cStatus = '';
	LET cRespuestaOs = '';
	LET cTotss_solsuperv_paso = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/gpe/sp_genreportessolicitudessupmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pRutaDescarga = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- SE ASIGNAN VALORES PARA LA GENERACIÃ?N DEL REPORTE
		LET cNombreReporte = 'SOLICITUDES_SUPERVISION_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y_%H%M%S')||'.txt';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
			LET ven_transacc = 1;
			DELETE FROM bdicnweb:"informix".sw_consdetallereportesolsupmc WHERE usuario_insert = pUsuario;
		COMMIT;
		
		LET ven_transacc = 0;
		
		SELECT COUNT(*) 
		INTO cTotss_solsuperv_paso
		FROM bdisolic:"informix".ss_solsuperv_paso;
		
			IF cTotss_solsuperv_paso > 0 THEN
				DELETE FROM bdisolic:"informix".ss_solsuperv_paso;
			END IF;
		
		IF TRIM(pIdConsulta) = '1' THEN
			
			FOREACH 
			
				EXECUTE PROCEDURE bdisolic:"informix".sp_busca_sol_supervision(cEmpresa, pUsuario, pNumSolicitud, pNumCliente, pFechaInicio, pFechaFin, pStatus, pProducto)
				INTO cCodRetSp, cDesCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bdisolic:"informix".sp_busca_sol_supervision';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00787';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00788';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00789';
					RETURN cCodRet;
				ELSE
					
					LET iRegistros = iRegistros + 1;
					INSERT INTO bdicnweb:"informix".sw_consdetallereportesolsupmc(num_solicitud, num_cliente, nombre_cliente, fecha_solicitud, fecha_cambio_status, status, respuesta_os, usuario_insert, fecha_insert)
					VALUES(cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs, pUsuario, dFechaHoy);
					
				END IF;
				
			END FOREACH;
		
		ELIF TRIM(pIdConsulta) = '2' THEN
			
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_supervision_mc_totales(cEmpresa, pNumSolicitud, pNumCliente, pFechaInicio, pFechaFin, pStatus, pProducto)
			INTO cCodRetSp, iNumRegistros;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bdicred:"informix".sp_consulta_supervision_mc_totales';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00021';
				RETURN cCodRet;
			ELSE
				
				FOREACH
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_supervision_mc(cEmpresa, pNumSolicitud, pNumCliente, pFechaInicio, pFechaFin, 
					pStatus, pProducto, 0, iNumRegistros)
					INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bdicred:"informix".sp_consulta_supervision_mc';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003';
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 2 THEN
						LET cCodRet = '00021';
						RETURN cCodRet;
					ELSE 
						
						LET iRegistros = iRegistros + 1;
						INSERT INTO bdicnweb:"informix".sw_consdetallereportesolsupmc(num_solicitud, num_cliente, nombre_cliente, fecha_solicitud, fecha_cambio_status, status, respuesta_os, usuario_insert, fecha_insert)
						VALUES(cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs, pUsuario, dFechaHoy);
						
					END IF;
					
				END FOREACH;
				
			END IF;
			
		END IF;
		
		--SELECT COUNT(*) INTO iTotalRegistros FROM bdicnweb:"informix".sw_consdetallereportesolsupmc WHERE usuario_insert = pUsuario;
		
		LET cCmd1 ="";
		--LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(pFechaInicio, '%d/%m/%Y'), ''), NVL(TO_CHAR(pFechaFin, '%d/%m/%Y'), ''), pDescProducto, NVL(TO_CHAR(dFechaHoy, '%d/%m/%Y'), ''),";
		LET cCmd1 = "SELECT 'NO. SOLICITUD','NO. CLIENTE','NOMBRE CLIENTE','FECHA SOLICITUD','FECHA CAMBIO ESTATUS','ESTATUS','RESPUESTA OS CAMBIOS'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT num_solicitud, num_cliente, nombre_cliente, NVL(TO_CHAR(fecha_solicitud, '%d/%m/%Y'), ''), NVL(TO_CHAR(fecha_cambio_status, '%d/%m/%Y'), ''), status, respuesta_os";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_consdetallereportesolsupmc";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"'";	
		LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
			
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
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
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT nombre_reporte
				INTO cNombreReporteHist
				FROM bdicnweb:"informix".sw_ctrlgenreportesolsupmc 
				WHERE usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte) 
				AND fecha_reporte < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
				SYSTEM TRIM(cSql);
				
				LET cNombreReporteHist = TRIM(cNombreReporteHist);
				DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesolsupmc WHERE nombre_reporte = TRIM(cNombreReporteHist);
				
			END FOREACH;
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE REGISTRA EN BITÃCORA				
		LET iCountRep = iCountRep + 1;
		LET cNombreReporte = TRIM(cNombreReporte);
		DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesolsupmc WHERE nombre_reporte = TRIM(cNombreReporte);
		INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesolsupmc(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
		VALUES(TRIM(cNombreReporte),dFechaHoy,dHoraHoy,pUsuario);		
		
		/*
		-- NOTIFICACIÃ?N VÃA CORREO ELECTRÃ?NICO
		LET cStr7 = 'GENERACIÃ?N DEL ARCHIVO TXT';
		LET cStr9 = 'SOLICITUDES EN SUPERVISIÃ?N';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		TRIM(pIdPlantilla),
		TRIM(pIdPlantilla), 
		pUsuario, 
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		TRIM(pTituloPlantilla),
		TRIM(cStr7),
		'',
		TRIM(cStr9),
		'',
		'',
		'',
		'0',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		dHoy) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÃ?N DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
		END IF;
		*/
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 28/03/2019',
'MODULO: CRÃ?DITO',
'FUNCIONALIDAD: SOLICITUDES DE CRÃ?DITO EN SUPERVISIÃ?N MESA DE CONTROL',
'DESCRIPCION: SPL encargado de generar los reportes en formato txt y notificar vÃ­a correo electrÃ³nico al usuario que lo generÃ³.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultas_cac_central_total(pEmpresa          CHAR(3),
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3),
													 pProducto         CHAR(4))
RETURNING
          CHAR(6),          -- Codigo de Retorno
          INTEGER           -- Total de Registros

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);
DEFINE iTotReg                 INTEGER;
DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);

DEFINE sol_pBanCac				CHAR(20);
DEFINE sol_pCac_Opt3_1			CHAR(20);
DEFINE sol_sucursal				CHAR(20);
DEFINE sol_pProducto			CHAR(20);
DEFINE sol_status				CHAR(20);
DEFINE sol_causa				CHAR(20);
DEFINE sol_InfoBuro				CHAR(20);
DEFINE sol_InfoBuro2			CHAR(20);
DEFINE sol_resum				CHAR(20);
DEFINE sol_conteo				INTEGER;
DEFINE count_InfoBuro			INTEGER;
DEFINE count_InfoBuro2			INTEGER;
LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;
LET cNombreCte                 = '';
LET cRFC                       = '';
LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;
LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';
LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';
LET cFecha                     = '';
LET cCausa					   = '10';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iTotReg                    = 0;


LET sol_pBanCac				= '';
LET sol_pCac_Opt3_1			= '';
LET sol_sucursal			= '';
LET sol_pProducto			= '';
LET sol_status				= '';
LET sol_causa				= '';
LET sol_InfoBuro			= '';
LET sol_InfoBuro2			= '';
LET sol_resum				= '';
LET sol_conteo 				= 0;
LET count_InfoBuro			= 0;
LET count_InfoBuro2			= 0;



-- ** HISTORIAL DE CAMBIOS ** --
--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.
-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la seleccion principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreon
--07/06/ 2010
--Comentarios: se agrego la causa del status y los filtros para los criterios del cac y mc.
--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validacion de eficiencia, meses de historia y puntuacion scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,iTotReg;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!
----SET DEBUG FILE TO '/home/sysifx/Viridiana/sp_consultas_CAC_central.out';
----TRACE ON;
-- SET DEBUG FILE TO '/informix/Israel/sp_consultas_cac_central_total_itd.out';
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizo la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

IF NVL(pNumSol,"")  <> "" THEN 

		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- Numero de Solicitud
				sol.numcte,                -- Numero Cte
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.num_producto,
				aut.revision_cac,
				sol.sucursal,
				aut.causa_solicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud AND aut.empresa= sol.empresa  AND aut.status_solicitud= sol.status_solicitud)
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa AND esp.num_solicitud= sol.num_solicitud 
				AND esp.numcte=sol.numcte and sol.status_solicitud= esp.status_nvo)
		 WHERE sol.num_solicitud=  pNumSol 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud NOT IN ("PC","AN")
---		   AND sol.fecha_insert between pFechaInicial and pFechaFinal
		INTO temp paso1; 
				   
--			SELECT count (*) INTO v_conteo FROM paso1

			
			IF pBanCac <> 'N' THEN
				---- Si es diferente de N solo se dejan RT
				FOREACH
					SELECT num_solicitud
					INTO sol_pBanCac
					FROM paso1
					WHERE status_solicitud <> 'RT'		

					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pBanCac;
					COMMIT;
				END FOREACH;
				
			END IF;
		
			IF pCac_Opt3_1 = 1 THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pCac_Opt3_1
					FROM paso1
					WHERE revision_cac = 0
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pCac_Opt3_1;
					COMMIT;
				END FOREACH;
			END IF;
	
			IF pSucursal IS NOT NULL THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_sucursal
					FROM paso1
					WHERE sucursal <> pSucursal
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_sucursal;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pProducto <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pProducto
					FROM paso1
					WHERE num_producto <> pProducto
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pProducto;
					COMMIT;
				END FOREACH;
			END IF;				

			IF pStatus <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_status
					FROM paso1
					WHERE status_solicitud <> pStatus
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_status;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pCausa <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_causa
					FROM paso1
					WHERE causa_solicitud <> pCausa
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_causa;
					COMMIT;
				END FOREACH;
			END IF;	

			SELECT count (a.num_solicitud)
			INTO count_InfoBuro  
			FROM paso1 a
			join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
			LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
			WHERE status_solicitud in ('BC','CC');
			
			IF count_InfoBuro > 0 THEN
				FOREACH WITH HOLD
					SELECT a.num_solicitud
						INTO sol_InfoBuro  
						FROM paso1 a
						join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
						LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
						WHERE status_solicitud in ('BC','CC')
					
					BEGIN;
						DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro;
					COMMIT;
				
				END FOREACH;
			END IF;
			
				
				SELECT count (a.num_solicitud)
				INTO count_InfoBuro2  
				FROM paso1 a
				join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
				LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
				WHERE status_solicitud in ('BC','CC');
				
				IF count_InfoBuro2 > 0 THEN 
			
					FOREACH WITH HOLD
						SELECT a.num_solicitud
							INTO sol_InfoBuro2  
							FROM paso1 a
							join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
							LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
							WHERE status_solicitud in ('BC','CC')
						
						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro2;
						COMMIT;
					
					END FOREACH;
				END IF;
				
			   SELECT count (a.num_solicitud)
				  INTO sol_conteo
				  FROM paso1 a 
				  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
				 WHERE ef.situacion_pago IS NULL AND ef.meses_historia IS NULL AND a.num_producto <> '6011';
			
				IF sol_conteo > 0 THEN 
					FOREACH WITH HOLD			
						SELECT a.num_solicitud
						  INTO sol_resum
						  FROM paso1 a 
						  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
						 WHERE ef.situacion_pago  AND ef.meses_historia AND a.num_producto <> '6011'

						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_resum;
						COMMIT;
						  
					END FOREACH;
				END IF;
				
		Select count (*) INTO iTotReg FROM paso1;

	RETURN cCodRet,iTotReg;
				
ELSE
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- Numero de Solicitud
				sol.numcte,                -- Numero Cte
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.num_producto,
				aut.revision_cac,
				sol.sucursal,
				aut.causa_solicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud AND aut.empresa= sol.empresa  AND aut.status_solicitud= sol.status_solicitud)
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa AND esp.num_solicitud= sol.num_solicitud 
				AND esp.numcte=sol.numcte and sol.status_solicitud= esp.status_nvo)
		 WHERE sol.empresa= pEmpresa
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND sol.fecha_insert between pFechaInicial and pFechaFinal
		INTO temp paso1 ;
				   
--			SELECT count (*) INTO v_conteo FROM paso1

			
			IF pBanCac <> 'N' THEN
				---- Si es diferente de N solo se dejan RT
				FOREACH
					SELECT num_solicitud
					INTO sol_pBanCac
					FROM paso1
					WHERE status_solicitud <> 'RT'		

					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pBanCac;
					COMMIT;
				END FOREACH;
				
			END IF;
		
			IF pCac_Opt3_1 = 1 THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pCac_Opt3_1
					FROM paso1
					WHERE revision_cac = 0
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pCac_Opt3_1;
					COMMIT;
				END FOREACH;
			END IF;
	
			IF pSucursal IS NOT NULL THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_sucursal
					FROM paso1
					WHERE sucursal <> pSucursal
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_sucursal;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pProducto <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pProducto
					FROM paso1
					WHERE num_producto <> pProducto
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pProducto;
					COMMIT;
				END FOREACH;
			END IF;				

			IF pStatus <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_status
					FROM paso1
					WHERE status_solicitud <> pStatus
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_status;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pCausa <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_causa
					FROM paso1
					WHERE causa_solicitud <> pCausa
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_causa;
					COMMIT;
				END FOREACH;
			END IF;	
			
			SELECT count (a.num_solicitud)
			INTO count_InfoBuro  
			FROM paso1 a
			join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
			LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
			WHERE status_solicitud in ('BC','CC');
			
			IF count_InfoBuro > 0 THEN
				FOREACH WITH HOLD
					SELECT a.num_solicitud
						INTO sol_InfoBuro  
						FROM paso1 a
						join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
						LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
						WHERE status_solicitud in ('BC','CC')
					
					BEGIN;
						DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro;
					COMMIT;
				
				END FOREACH;
			END IF;
			
				
				SELECT count (a.num_solicitud)
				INTO count_InfoBuro2  
				FROM paso1 a
				join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
				LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
				WHERE status_solicitud in ('BC','CC');
				
				IF count_InfoBuro2 > 0 THEN 
			
					FOREACH WITH HOLD
						SELECT a.num_solicitud
							INTO sol_InfoBuro2  
							FROM paso1 a
							join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
							LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
							WHERE status_solicitud in ('BC','CC')
						
						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro2;
						COMMIT;
					
					END FOREACH;
				END IF;
				
			   SELECT count (a.num_solicitud)
				  INTO sol_conteo
				  FROM paso1 a 
				  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
				 WHERE ef.situacion_pago IS NULL AND ef.meses_historia IS NULL AND a.num_producto <> '6011';
			
				IF sol_conteo > 0 THEN 
					FOREACH WITH HOLD			
						SELECT a.num_solicitud
						  INTO sol_resum
						  FROM paso1 a 
						  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
						 WHERE ef.situacion_pago  AND ef.meses_historia AND a.num_producto <> '6011'

						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_resum;
						COMMIT;
						  
					END FOREACH;
				END IF;
				
		Select count (*) INTO iTotReg FROM paso1;

	RETURN cCodRet,iTotReg;
			
END IF

END

END PROCEDURE;