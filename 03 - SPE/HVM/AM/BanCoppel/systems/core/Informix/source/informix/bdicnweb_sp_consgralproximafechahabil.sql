CREATE PROCEDURE "informix".sp_consgralproximafechahabil(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_habil_prox;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE dFecha CHAR(10);
		DEFINE dFechaHabilProx DATE;
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET dFecha = '';
		LET dFechaHabilProx = '';
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, dFechaHabilProx;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consgralproximafechahabil.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pFecha IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaHabilProx;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaHabilProx;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF pIdConsulta = '1' THEN
		
				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(pFecha)
				INTO cCodRetSp, dFechaHabilProx;
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:cal_fecha_pre_fh';
				ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00003';
				END IF;
			
			END IF;
			
			IF dFechaHabilProx IS NULL THEN
				LET cCodRet = '00017';
			END IF;
		
			RETURN cCodRet, dFechaHabilProx;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 27/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generaciï¿½n de Archivos de Devoluciones', 
'DESCRIPCION: SPL que se encarga de consultar el prï¿½ximo dï¿½a habil a la fecha consultada con respecto al pIdConsulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizapagocheque(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pDireccionMac CHAR(12), pIdCheque INTEGER)
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet 		 CHAR(5);
	DEFINE iSqlErr 		 INTEGER;
	DEFINE cCodRetSp 	 CHAR(5);
	DEFINE iCodRetSp 	 INTEGER;
	DEFINE cEmpresa 	 CHAR(3);
	DEFINE dFechaMasUno	 DATE;
	DEFINE cCuenta       CHAR(20);
	DEFINE iCheque       INTEGER;
	DEFINE mImporte      MONEY(16,2);
	DEFINE cFechaPresini CHAR(8);
	DEFINE iNoRegistros  INTEGER;

	LET cCodRet 	     = '00000';
	LET iSqlErr 	     = 0;
	LET cCodRetSp 	     = '';
	LET iCodRetSp 	     = 0;
	LET cEmpresa 	     = '001';
	LET dFechaMasUno 	 = '';
	LET cCuenta          = '';
	LET iCheque          = 0;
	LET mImporte         = 0.00;
	LET cFechaPresini    = '';
	LET iNoRegistros     = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizapagocheque.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pDireccionMac = '' OR pIdCheque IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		--LET dFechaMasUno = pFecha + 1 UNITS DAY;
		LET dFechaMasUno = pFecha;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} c_cuenta, c_cheque, c_importe, fecha_presini
		INTO cCuenta, iCheque, mImporte, cFechaPresini
		FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev
		WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario
		AND fecha_entrada = dFechaMasUno AND id_registro = pIdCheque;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00719'; --NO SE ENCONTRARON REGISTROS DE CHEQUE, VERIFIQUE
			RETURN cCodRet;
		END IF;

		--Se marca el cheque como pagado por camara
		UPDATE bdicheq:"informix".sc_contch
		SET estado = 'M', fecha_alta = pFecha, importe = mImporte --CCur(mImporte)
		WHERE empresa = cEmpresa AND cuenta = cCuenta AND numero = iCheque;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00283';
			RETURN cCodRet;
		END IF;

		UPDATE bditef:"informix".cce_propios_det
		SET mot_devol = '00', status = '05', fecha_proceso = pFecha
		WHERE c_cuenta = cCuenta AND c_cheque = iCheque
		AND cod_operacion = '40' AND fecha_presini = cFechaPresini;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00283';
			RETURN cCodRet;
		END IF;

		--Se ajusta monto y total operaciones
		DELETE {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev
		WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario
		AND fecha_entrada = dFechaMasUno AND id_registro = pIdCheque;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00862';
			RETURN cCodRet;
		END IF;

		RETURN cCodRet;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 12/09/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de archivo de devoluciones';

CREATE PROCEDURE "informix".sp_consultadetallechequesdev_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pBandera CHAR(1), pTipo CHAR(1), pDireccionMac CHAR(12))
	RETURNING CHAR(5) AS codret,
		INTEGER		  AS num_registros,
		CHAR(8) 	  AS fecha_prox,
		CHAR(2)		  AS num_bloque;
	
	DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
	DEFINE cCodRetSp                CHAR(5);
	DEFINE iCodRetSp                INTEGER;
	DEFINE dFechaMasUno				DATE;
	DEFINE dFechaHabilProx 			DATE;
	DEFINE cFormatFecha				CHAR(8);
	DEFINE cFormatFechaMasUno		CHAR(8);
	DEFINE cFormatFechaProx 		CHAR(8);
	DEFINE iNumBloque				INT;
	DEFINE cNumBloque				CHAR(2);
	DEFINE cNombreArchivo			CHAR(22);
	DEFINE cStatusParam             CHAR(2);
	DEFINE cBcoPresenta     		CHAR(3);
	DEFINE cNombreBanco             CHAR(40);
	DEFINE cCuenta                  CHAR(20);
	DEFINE iCheque                  INTEGER;
	DEFINE mImporte                 MONEY(16,2);
	DEFINE cMotDevol                CHAR(2);
	DEFINE cGeneradoDev     		CHAR(1); 
	DEFINE cFechaTransfer   		CHAR(8);
	DEFINE cImporte                 CHAR(15);
	DEFINE cLoteEntrada     		CHAR(7);
	DEFINE cSecEntrada              CHAR(4);   
	DEFINE cLoteSalida              CHAR(7);   
	DEFINE cSecSalida               CHAR(4); 
	DEFINE cCveTransacc     		CHAR(2); 
	DEFINE cPlazaCompensa   		CHAR(3); 
	DEFINE cNumCuenta               CHAR(13);
	DEFINE cNumCheque               CHAR(10);
	DEFINE cDigInter                CHAR(1); 
	DEFINE cDigPremar               CHAR(1); 
	DEFINE cCodSeguridad    		CHAR(3); 
	DEFINE cUbicacionFisica 		CHAR(8); 
	DEFINE cTruncamiento    		CHAR(1); 
	DEFINE cMotDevol2               CHAR(2);
	DEFINE cFechaPresini			CHAR(8);
	DEFINE cPlazaInter              CHAR(2); 
	DEFINE cRfcBen                  CHAR(13);  
	DEFINE cCurpBen                 CHAR(18);
	DEFINE cTipoCtadep              CHAR(2);
	DEFINE cCuentaDep               CHAR(20);
	DEFINE cNombreBen               CHAR(40);
	DEFINE cAlertamiento    		CHAR(2); 
	DEFINE cFolioSegur              CHAR(12);
	DEFINE cStatus					CHAR(2);
	DEFINE iHayRegistro				INTEGER;
	DEFINE cDuplicado				CHAR(1);
	DEFINE cDescMotivo 			    CHAR(35);
	DEFINE cDetDatosMotivo 			CHAR(40);
	DEFINE iCountReg  				INTEGER;
	DEFINE iTotalReg				INTEGER;
	DEFINE mMontoTotalValido        MONEY(18,2);
	DEFINE mTotalImporte			MONEY(18,2);
	DEFINE iIdRegistro     		    INTEGER;
	DEFINE iNumRegistros		    INTEGER;
	
	LET cCodRet                     = '00000';
	LET iSqlErr                     = 0;
	LET cCodRetSp                   = '';
	LET iCodRetSp                   = 0;
	LET dFechaMasUno				= '';
	LET dFechaHabilProx 			= '';
	LET cFormatFecha				= '';
	LET cFormatFechaMasUno			= '';
	LET cFormatFechaProx 			= '';
	LET iNumBloque					= 0;
	LET cNumBloque 					= '';
	LET cNombreArchivo				= '';
	LET cStatusParam              	= '';
	LET cBcoPresenta     			= '';
	LET cNombreBanco             	= '';
	LET cCuenta                  	= '';
	LET iCheque                  	= 0;
	LET mImporte                 	= 0.00;
	LET cMotDevol                	= '';
	LET cGeneradoDev     			= '';
	LET cFechaTransfer   			= '';
	LET cImporte                 	= '';
	LET cLoteEntrada     			= '';
	LET cSecEntrada             	= '';  
	LET cLoteSalida              	= '';  
	LET cSecSalida               	= '';
	LET cCveTransacc     			= '';
	LET cPlazaCompensa   			= '';
	LET cNumCuenta               	= '';
	LET cNumCheque               	= '';
	LET cDigInter                	= '';
	LET cDigPremar               	= '';
	LET cCodSeguridad    			= '';
	LET cUbicacionFisica 			= '';
	LET cTruncamiento    			= '';
	LET cMotDevol2               	= '';
	LET cFechaPresini				= '';
	LET cPlazaInter              	= '';
	LET cRfcBen                  	= '';  
	LET cCurpBen                 	= '';
	LET cTipoCtadep              	= '';
	LET cCuentaDep               	= '';
	LET cNombreBen               	= '';
	LET cAlertamiento    			= '';
	LET cFolioSegur              	= '';
	LET cStatus						= '';
	LET iHayRegistro				= 0;
	LET cDuplicado					= '';
	LET cDescMotivo 			    = '';
	LET cDetDatosMotivo 			= '';
	LET iCountReg  					= 0;
	LET iTotalReg					= 0;
	LET mMontoTotalValido        	= 0.00;
	LET mTotalImporte				= 0.00;
	LET iIdRegistro     			= 0;
	LET iNumRegistros				= 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(iNumRegistros,0), cFormatFechaProx, LPAD(TRIM(cNumBloque),2,'0');
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetallechequesdev_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pBandera = '' OR pTipo = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, NVL(iNumRegistros,0), cFormatFechaProx, LPAD(TRIM(cNumBloque),2,'0');
		END IF;
    
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, NVL(iNumRegistros,0), cFormatFechaProx, LPAD(TRIM(cNumBloque),2,'0');
		END IF;
	
		LET dFechaMasUno = pFecha;
		EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaMasUno)
		INTO cCodRetSp, dFechaHabilProx;
		
		LET cFormatFecha = SUBSTR(pFecha,7,4)||SUBSTR(pFecha,1,2)||SUBSTR(pFecha,4,2);
		LET cFormatFechaMasUno = SUBSTR(dFechaMasUno,7,4)||SUBSTR(dFechaMasUno,1,2)||SUBSTR(dFechaMasUno,4,2);
		LET cFormatFechaProx = SUBSTR(dFechaHabilProx,4,2)||SUBSTR(dFechaHabilProx,1,2)||SUBSTR(dFechaHabilProx,7,4);
		
		SELECT NVL(MAX(num_bloque::INTEGER)+1,1)
		INTO iNumBloque
		FROM bditef:"informix".cce_encabezado
		WHERE nombrearchivo[1,12] = 'DEV_'||cFormatFechaProx;
		
		LET cNumBloque = iNumBloque;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
		
			--Limpia Tabla
			DELETE {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev WHERE usuario_insert = pUsuario AND direccion_mac = pDireccionMac;
		
			--Dev. Lï¿½gicas/Fï¿½sicas
			IF pTipo = '0' OR pTipo = '1' THEN
				
				IF pTipo = '0' THEN
					LET cStatusParam = '10';
				ELIF pTipo = '1' THEN
					LET cStatusParam = '11';
				END IF;
		
				FOREACH
				
					SELECT {+INDEX (bditef:"informix".cce_propios_det idx_sw_cce_propios_det_fecha_presini_c_cuenta_cod_operacion_status)} bco_presenta, ba.descripcion, c_cuenta, c_cheque, c_importe, mot_devol, generado_dev, fecha_transfer, 
					importe, lote_entrada, sec_entrada, lote_salida, sec_salida, cve_transacc, plaza_compensa, num_cuenta, num_cheque, 
					dig_inter, dig_premar, cod_seguridad, ubicacion_fisica, truncamiento, mot_devol, fecha_presini, plaza_inter, 
					rfc_ben, curp_ben, tipo_ctadep, cuenta_dep, nombre_ben, alertamiento, folio_segur, status
					INTO cBcoPresenta, cNombreBanco, cCuenta, iCheque, mImporte, cMotDevol, cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus 			
					FROM bditef:"informix".cce_propios_det, bdinteg:"informix".si_bancos AS ba
					WHERE fecha_entrada = dFechaMasUno
					AND generado_dev = '0' AND mot_devol <> '00' 
					AND bco_presenta = ba.banco AND status = cStatusParam ORDER BY c_cuenta,c_cheque
				
					--Verifica cheque duplicado
					IF EXISTS (SELECT nombrearchivo FROM bditef:"informix".cce_detalle
						WHERE cod_operacion = '41' AND bco_receptor = TRIM(cBcoPresenta) 
						AND num_cuenta = TRIM(cCuenta) AND num_cheque = iCheque
						AND fecha_presini = cFormatFecha) THEN
						
						LET cDuplicado = '1';
						LET cGeneradoDev = '1';
						
						--Se marca como procesado
						UPDATE bditef:"informix".cce_propios_det SET generado_dev = '1'
						WHERE bco_presenta = TRIM(cBcoPresenta) AND c_cuenta = TRIM(cCuenta) 
						AND c_cheque = iCheque AND fecha_presini = cFormatFechaMasUno;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet, NVL(iNumRegistros,0), cFormatFechaProx, LPAD(TRIM(cNumBloque),2,'0');
						END IF;	
					ELSE
						LET cDuplicado = '0';
					END IF;
					
					LET iCountReg = iCountReg + 1;
					LET mMontoTotalValido = mMontoTotalValido + NVL(mImporte,0);
					
					SELECT descripcion AS datos_motivo INTO cDescMotivo
					FROM bdinteg:"informix".si_coddevcam
					WHERE codigo = cMotDevol;
					
					INSERT INTO bdicnweb:"informix".sw_cr_consultadetallechequesdev (id_registro,direccion_mac,usuario_insert,monto_total,
					bco_presenta,descripcion,c_cuenta,c_cheque,c_importe,mot_devol,generado_dev,fecha_transfer,                  
					importe,lote_entrada,sec_entrada,lote_salida,sec_salida,cve_transacc,plaza_compensa,num_cuenta,num_cheque,                     
					dig_inter,dig_premar,cod_seguridad,ubicacion_fisica,truncamiento,mot_devol2,fecha_presini,plaza_inter,                     
					rfc_ben,curp_ben,tipo_ctadep,cuenta_dep,nombre_ben,alertamiento,folio_segur,status,duplicado,fecha_entrada)
					VALUES(iCountReg, pDireccionMac, pUsuario, mMontoTotalValido,
					cBcoPresenta, cNombreBanco, cCuenta, iCheque, mImporte, TRIM(cMotDevol||' '||UPPER(cDescMotivo)), cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus, cDuplicado, dFechaMasUno);
					
				END FOREACH;
				
			--Todas
			ELIF pTipo = '2' THEN
			
				FOREACH
			
					SELECT {+INDEX (bditef:"informix".cce_propios_det idx_sw_cce_propios_det_fecha_presini_c_cuenta_cod_operacion_status)} bco_presenta, ba.descripcion, c_cuenta, c_cheque, c_importe, mot_devol, generado_dev, fecha_transfer, 
					importe, lote_entrada, sec_entrada, lote_salida, sec_salida, cve_transacc, plaza_compensa, num_cuenta, num_cheque, 
					dig_inter, dig_premar, cod_seguridad, ubicacion_fisica, truncamiento, mot_devol, fecha_presini, plaza_inter, 
					rfc_ben, curp_ben, tipo_ctadep, cuenta_dep, nombre_ben, alertamiento, folio_segur, status
					INTO cBcoPresenta, cNombreBanco, cCuenta, iCheque, mImporte, cMotDevol, cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus 			
					FROM bditef:"informix".cce_propios_det, bdinteg:"informix".si_bancos AS ba
					WHERE fecha_entrada = dFechaMasUno
					AND generado_dev = '0' AND mot_devol <> '00' 
					AND bco_presenta = ba.banco AND status IN('10','11') ORDER BY c_cuenta,c_cheque
				
					--Verifica cheque duplicado
					IF EXISTS (SELECT nombrearchivo FROM bditef:"informix".cce_detalle
						WHERE cod_operacion = '41' AND bco_receptor = TRIM(cBcoPresenta) 
						AND num_cuenta = TRIM(cCuenta) AND num_cheque = iCheque
						AND fecha_presini = cFormatFecha) THEN
						
						LET cDuplicado = '1';
						LET cGeneradoDev = '1';
					
						--Se marca como procesado
						UPDATE bditef:"informix".cce_propios_det SET generado_dev = '1'
						WHERE bco_presenta = TRIM(cBcoPresenta) AND c_cuenta = TRIM(cCuenta) 
						AND c_cheque = iCheque AND fecha_presini = cFormatFechaMasUno;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet, NVL(iNumRegistros,0), cFormatFechaProx, LPAD(TRIM(cNumBloque),2,'0');
						END IF;					
					ELSE
						LET cDuplicado = '0';
					END IF;
					
					LET iCountReg = iCountReg + 1;
					LET mMontoTotalValido = mMontoTotalValido + NVL(mImporte,0);
					
					SELECT descripcion AS datos_motivo INTO cDescMotivo
					FROM bdinteg:"informix".si_coddevcam
					WHERE codigo = cMotDevol;
					
					INSERT INTO bdicnweb:"informix".sw_cr_consultadetallechequesdev  (id_registro,direccion_mac,usuario_insert,monto_total,
					bco_presenta,descripcion,c_cuenta,c_cheque,c_importe,mot_devol,generado_dev,fecha_transfer,                  
					importe,lote_entrada,sec_entrada,lote_salida,sec_salida,cve_transacc,plaza_compensa,num_cuenta,num_cheque,                     
					dig_inter,dig_premar,cod_seguridad,ubicacion_fisica,truncamiento,mot_devol2,fecha_presini,plaza_inter,                     
					rfc_ben,curp_ben,tipo_ctadep,cuenta_dep,nombre_ben,alertamiento,folio_segur,status,duplicado,fecha_entrada)
					VALUES(iCountReg, pDireccionMac, pUsuario, mMontoTotalValido,
					cBcoPresenta, cNombreBanco, cCuenta, iCheque, mImporte, TRIM(cMotDevol||' '||UPPER(cDescMotivo)), cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus, cDuplicado, dFechaMasUno);
					
				END FOREACH;
			
			END IF;
		
		END IF;
		
		IF pBandera = '1' OR pBandera = '2' THEN

			IF pTipo = '0' OR pTipo = '1' THEN
				
				IF pTipo = '0' THEN
					LET cStatusParam = '10';
				ELIF pTipo = '1' THEN
					LET cStatusParam = '11';
				END IF;
				
				SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev )} COUNT(id_registro)
				INTO iNumRegistros
				FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 
				WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario AND status = cStatusParam AND fecha_entrada = dFechaMasUno;
		
			ELIF pTipo = '2' THEN
			
				SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev )} COUNT(id_registro)
				INTO iNumRegistros
				FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev
				WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario AND fecha_entrada = dFechaMasUno;

			END IF;

		END IF;

		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00855'; --NO HAY REGISTROS PARA EL Dï¿½A||pFecha
		END IF;

		RETURN cCodRet, NVL(iNumRegistros,0), cFormatFechaProx, LPAD(TRIM(cNumBloque),2,'0');

    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 12/09/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de archivo de devoluciones',
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de los archivos de devoluciones.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 02/02/2017',
'DESCRIPCION: Se modifica SPL para agregar datos faltantes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetallechequesdev(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pBandera CHAR(1), pTipo CHAR(1), pDireccionMac CHAR(12), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(3) AS id_banco,
		CHAR(40) AS desc_banco,
		CHAR(20) AS cuenta,
		INTEGER AS cheque,    
		MONEY(16,2) AS importe,
		CHAR(40) AS mot_devol,
		CHAR(1) AS generado_dev, 
		CHAR(8) AS fecha_transfer, 
		CHAR(15) AS importe_c, 
		CHAR(7) AS lote_entrada, 
		CHAR(4) AS sec_entrada, 
		CHAR(7) AS lote_salida, 
		CHAR(4) AS sec_salida, 
		CHAR(2) AS cve_transacc, 
		CHAR(3) AS plaza_compensa, 
		CHAR(13) AS num_cuenta, 
		CHAR(10) AS num_cheque, 
		CHAR(1) AS dig_inter, 
		CHAR(1) AS dig_premar, 
		CHAR(3) AS cod_seguridad, 
		CHAR(8) AS ubicacion_fisica, 
		CHAR(1) AS truncamiento, 
		CHAR(2) AS mot_devol2, 
		CHAR(8) AS fecha_presini, 
		CHAR(2) AS plaza_inter, 
		CHAR(13) AS rfc_ben, 
		CHAR(18) AS curp_ben, 
		CHAR(2) AS tipo_ctadep, 
		CHAR(20) AS cuenta_dep, 
		CHAR(40) AS nombre_ben, 
		CHAR(2) AS alertamiento, 
		CHAR(12) AS folio_segur, 
		CHAR(2) AS status,
		INTEGER AS total_registros,
		MONEY(18,2) AS total_importe,
		CHAR(1) AS duplicado,
		INTEGER AS id_registro;
	
	DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
	DEFINE cCodRetSp                CHAR(5);
	DEFINE iCodRetSp                INTEGER;
	DEFINE dFechaMasUno				DATE;
	DEFINE dFechaHabilProx 			DATE;
	DEFINE cFormatFecha				CHAR(8);
	DEFINE cFormatFechaMasUno		CHAR(8);
	DEFINE cFormatFechaProx 		CHAR(8);
	DEFINE iNumBloque				INT;
	DEFINE cNumBloque				CHAR(2);
	DEFINE cNombreArchivo			CHAR(22);
	DEFINE cStatusParam             CHAR(2);
	DEFINE cBcoPresenta     		CHAR(3);
	DEFINE cNombreBanco             CHAR(40);
	DEFINE cCuenta                  CHAR(20);
	DEFINE iCheque                  INTEGER;
	DEFINE mImporte                 MONEY(16,2);
	DEFINE cMotDevol                CHAR(2);
	DEFINE cGeneradoDev     		CHAR(1); 
	DEFINE cFechaTransfer   		CHAR(8);
	DEFINE cImporte                 CHAR(15);
	DEFINE cLoteEntrada     		CHAR(7);
	DEFINE cSecEntrada              CHAR(4);   
	DEFINE cLoteSalida              CHAR(7);   
	DEFINE cSecSalida               CHAR(4); 
	DEFINE cCveTransacc     		CHAR(2); 
	DEFINE cPlazaCompensa   		CHAR(3); 
	DEFINE cNumCuenta               CHAR(13);
	DEFINE cNumCheque               CHAR(10);
	DEFINE cDigInter                CHAR(1); 
	DEFINE cDigPremar               CHAR(1); 
	DEFINE cCodSeguridad    		CHAR(3); 
	DEFINE cUbicacionFisica 		CHAR(8); 
	DEFINE cTruncamiento    		CHAR(1); 
	DEFINE cMotDevol2               CHAR(2);
	DEFINE cFechaPresini			CHAR(8);
	DEFINE cPlazaInter              CHAR(2); 
	DEFINE cRfcBen                  CHAR(13);  
	DEFINE cCurpBen                 CHAR(18);
	DEFINE cTipoCtadep              CHAR(2);
	DEFINE cCuentaDep               CHAR(20);
	DEFINE cNombreBen               CHAR(40);
	DEFINE cAlertamiento    		CHAR(2); 
	DEFINE cFolioSegur              CHAR(12);
	DEFINE cStatus					CHAR(2);
	DEFINE iHayRegistro				INTEGER;
	DEFINE cDuplicado				CHAR(1);
	DEFINE cDescMotivo 			    CHAR(35);
	DEFINE cDetDatosMotivo 			CHAR(40);
	DEFINE iCountReg  				INTEGER;
	DEFINE iTotalReg				INTEGER;
	DEFINE mMontoTotalValido        MONEY(18,2);
	DEFINE mTotalImporte			MONEY(18,2);
	DEFINE iIdRegistro     		    INTEGER;
	DEFINE iNumRegistros		    INTEGER;

	LET cCodRet                     = '00000';
	LET iSqlErr                     = 0;
	LET cCodRetSp                   = '';
	LET iCodRetSp                   = 0;
	LET dFechaMasUno				= '';
	LET dFechaHabilProx 			= '';
	LET cFormatFecha				= '';
	LET cFormatFechaMasUno			= '';
	LET cFormatFechaProx 			= '';
	LET iNumBloque					= 0;
	LET cNumBloque 					= '';
	LET cNombreArchivo				= '';
	LET cStatusParam              	= '';
	LET cBcoPresenta     			= '';
	LET cNombreBanco             	= '';
	LET cCuenta                  	= '';
	LET iCheque                  	= 0;
	LET mImporte                 	= 0.00;
	LET cMotDevol                	= '';
	LET cGeneradoDev     			= '';
	LET cFechaTransfer   			= '';
	LET cImporte                 	= '';
	LET cLoteEntrada     			= '';
	LET cSecEntrada             	= '';  
	LET cLoteSalida              	= '';  
	LET cSecSalida               	= '';
	LET cCveTransacc     			= '';
	LET cPlazaCompensa   			= '';
	LET cNumCuenta               	= '';
	LET cNumCheque               	= '';
	LET cDigInter                	= '';
	LET cDigPremar               	= '';
	LET cCodSeguridad    			= '';
	LET cUbicacionFisica 			= '';
	LET cTruncamiento    			= '';
	LET cMotDevol2               	= '';
	LET cFechaPresini				= '';
	LET cPlazaInter              	= '';
	LET cRfcBen                  	= '';  
	LET cCurpBen                 	= '';
	LET cTipoCtadep              	= '';
	LET cCuentaDep               	= '';
	LET cNombreBen               	= '';
	LET cAlertamiento    			= '';
	LET cFolioSegur              	= '';
	LET cStatus						= '';
	LET iHayRegistro				= 0;
	LET cDuplicado					= '';
	LET cDescMotivo 			    = '';
	LET cDetDatosMotivo 			= '';
	LET iCountReg  					= 0;
	LET iTotalReg					= 0;
	LET mMontoTotalValido        	= 0.00;
	LET mTotalImporte				= 0.00;
	LET iIdRegistro     			= 0;
	LET iNumRegistros				= 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
			cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
			NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetallechequesdev.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pBandera = '' OR pTipo = '' OR pDireccionMac = '' OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
			cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
			NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro;
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
			cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
			NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro;
		END IF;
    
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
			cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
			NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro;
		END IF;
	
		LET dFechaMasUno = pFecha;
		EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaMasUno)
		INTO cCodRetSp, dFechaHabilProx;
		
		LET cFormatFecha = SUBSTR(pFecha,7,4)||SUBSTR(pFecha,1,2)||SUBSTR(pFecha,4,2);
		LET cFormatFechaMasUno = SUBSTR(dFechaMasUno,7,4)||SUBSTR(dFechaMasUno,1,2)||SUBSTR(dFechaMasUno,4,2);
		LET cFormatFechaProx = SUBSTR(dFechaHabilProx,4,2)||SUBSTR(dFechaHabilProx,1,2)||SUBSTR(dFechaHabilProx,7,4);
		
		SELECT NVL(MAX(num_bloque::INTEGER)+1,1)
		INTO iNumBloque
		FROM bditef:"informix".cce_encabezado
		WHERE nombrearchivo[1,12] = 'DEV_'||cFormatFechaProx;
		
		LET cNumBloque = iNumBloque;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
		
			--Dev. Lï¿½gicas/Fï¿½sicas
			IF pTipo = '0' OR pTipo = '1' THEN
				
				IF pTipo = '0' THEN
					LET cStatusParam = '10';
				ELIF pTipo = '1' THEN
					LET cStatusParam = '11';
				END IF;
				
				SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)}
 COUNT(id_registro), SUM(c_importe)
				INTO iTotalReg, mTotalImporte
				FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 
				WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario AND status = cStatusParam;
				
				FOREACH
					SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} SKIP pRegistros FIRST pRecuperacion 
					bco_presenta, descripcion, c_cuenta, c_cheque, c_importe, mot_devol, generado_dev, fecha_transfer, 
					importe, lote_entrada, sec_entrada, lote_salida, sec_salida, cve_transacc, plaza_compensa, num_cuenta, num_cheque, 
					dig_inter, dig_premar, cod_seguridad, ubicacion_fisica, truncamiento, mot_devol, fecha_presini, plaza_inter, 
					rfc_ben, curp_ben, tipo_ctadep, cuenta_dep, nombre_ben, alertamiento, folio_segur, status, duplicado, id_registro
					INTO cBcoPresenta, cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus, cDuplicado, iIdRegistro 	
					FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 
					WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario AND status = cStatusParam
					ORDER BY id_registro ASC
					
					LET iNumRegistros = iNumRegistros + 1;
					RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
					NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro WITH RESUME;
					
				END FOREACH;
				
			--Todas
			ELIF pTipo = '2' THEN
			
				SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} COUNT(id_registro), SUM(c_importe)
				INTO iTotalReg, mTotalImporte
				FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 
				WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario;
				
				FOREACH
					SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} SKIP pRegistros FIRST pRecuperacion 
					bco_presenta, descripcion, c_cuenta, c_cheque, c_importe, mot_devol, generado_dev, fecha_transfer, 
					importe, lote_entrada, sec_entrada, lote_salida, sec_salida, cve_transacc, plaza_compensa, num_cuenta, num_cheque, 
					dig_inter, dig_premar, cod_seguridad, ubicacion_fisica, truncamiento, mot_devol, fecha_presini, plaza_inter, 
					rfc_ben, curp_ben, tipo_ctadep, cuenta_dep, nombre_ben, alertamiento, folio_segur, status, duplicado, id_registro
					INTO cBcoPresenta, cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus, cDuplicado, iIdRegistro 	
					FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 
					WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario
					ORDER BY id_registro ASC
					
					LET iNumRegistros = iNumRegistros + 1;
					RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
					cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
					cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
					TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
					NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro WITH RESUME;
				END FOREACH;
			
			END IF;
			
		END IF;
	
		IF iNumRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00855'; --NO HAY REGISTROS PARA EL Dï¿½A||pFecha	
			RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
			cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
			NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro;
		ELIF iNumRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cBcoPresenta, TRIM(UPPER(cNombreBanco)), cCuenta, iCheque, mImporte, TRIM(UPPER(cDetDatosMotivo)), cGeneradoDev, cFechaTransfer,
			cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			TRIM(UPPER(cRfcBen)), TRIM(UPPER(cCurpBen)), cTipoCtadep, cCuentaDep, TRIM(UPPER(cNombreBen)), cAlertamiento, cFolioSegur, cStatus,
			NVL(iTotalReg,0), NVL(mTotalImporte,0), cDuplicado, iIdRegistro; 
		END IF;
        
    END;    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 12/09/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de archivo de devoluciones', 
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos de devoluciones',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 02/02/2017',
'DESCRIPCION: Se modifica SPL para agregar el retorno de datos faltantes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genarchivodevoluciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pTipo CHAR(1), pNombreArchivo CHAR(22), pRutaDescarga CHAR(100), pDireccionMac CHAR(12))
	RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMiBanco CHAR(3);
	DEFINE dFechaMasUno DATE;
	DEFINE dFechaHabilProx DATE;
	DEFINE cFormatFecha CHAR(8);
	DEFINE cFormatFechaMasUno CHAR(8);
	DEFINE cFormatFechaProx CHAR(8);
	DEFINE cFechaProx CHAR(8);
	DEFINE iNumBloque INTEGER;
	DEFINE cStatusParam CHAR(2);
	DEFINE iHayDatos INTEGER;
	DEFINE cBcoPresenta CHAR(3);
	DEFINE cNombreBanco CHAR(40);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cMotDevol CHAR(2);
	DEFINE cGeneradoDev CHAR(1); 
	DEFINE cFechaTransfer CHAR(8);
	DEFINE cImporte CHAR(15);
	DEFINE cLoteEntrada CHAR(7);
	DEFINE cSecEntrada CHAR(4);   
	DEFINE cLoteSalida CHAR(7);   
	DEFINE cSecSalida CHAR(4); 
	DEFINE cCveTransacc CHAR(2); 
	DEFINE cPlazaCompensa CHAR(3); 
	DEFINE cNumCuenta CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cDigInter CHAR(1); 
	DEFINE cDigPremar CHAR(1); 
	DEFINE cCodSeguridad CHAR(3); 
	DEFINE cUbicacionFisica CHAR(8); 
	DEFINE cTruncamiento CHAR(1); 
	DEFINE cMotDevol2 CHAR(2);
	DEFINE cFechaPresini CHAR(8);
	DEFINE cPlazaInter CHAR(2); 
	DEFINE cRfcBen CHAR(13);  
	DEFINE cCurpBen CHAR(18);
	DEFINE cTipoCtadep CHAR(2);
	DEFINE cCuentaDep CHAR(20);
	DEFINE cNombreBen CHAR(40);
	DEFINE cAlertamiento CHAR(2); 
	DEFINE cFolioSegur CHAR(12);
	DEFINE cStatus CHAR(2);
	DEFINE iIdRegistro INTEGER;
	DEFINE iTotalChequesDet INTEGER;
	DEFINE cSecuencia CHAR(7);
	DEFINE cPrueba CHAR(1);
	DEFINE iTotalCheques INTEGER;
	DEFINE mTotalImporte MONEY(16,2);
	DEFINE cTotalImporte CHAR(19);
	DEFINE cMonto CHAR(16);
	DEFINE cCents CHAR(2);
	DEFINE iTotalRegTruncados INTEGER;
	DEFINE iBloqueInicial INTEGER;
	DEFINE cIdPresentar CHAR(8);	
	DEFINE cTipoRegistro CHAR(2);
	DEFINE cNumSecuencia CHAR(7);
	DEFINE cNumBanco CHAR(3);
	DEFINE cSentidoTransfer CHAR(1);
	DEFINE cPlazaCecoban CHAR(2);
	DEFINE cServicioTEI CHAR(1);
	DEFINE iDiaMesTransfer SMALLINT;
	DEFINE cFechaPresenta CHAR(8);
	DEFINE cUsoFuturo1 CHAR(9);
	DEFINE cTipoArchivo CHAR(1);
	DEFINE cUsoFuturo2 CHAR(302);	
	DEFINE iSecuencia INTEGER;
	DEFINE cDigverpre CHAR(1);
	DEFINE cDigverinter CHAR(1);																	 
	DEFINE cTipo_cta_dep CHAR(2);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(18);
	DEFINE cCodAlertamiento CHAR(2);
	DEFINE cCodOper CHAR(2);
	DEFINE cFechatrasnfer CHAR(8);
	DEFINE cBancoCedente CHAR(3);
	DEFINE cBancoLibrado CHAR(3);
	DEFINE cCveTrans CHAR(2);
	DEFINE cCodSegur CHAR(3);
	DEFINE cUbicFis CHAR(8);
	DEFINE cTruncado CHAR(1);	
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cCtaDep CHAR(20);
	DEFINE cCtaDepFormat CHAR(19);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(12);
	DEFINE cUsoFuturo CHAR(120);
	DEFINE cUsoFuturoSum CHAR(300);
	DEFINE cUsoFuturoGranSum CHAR(284);
	DEFINE cTotRegs CHAR(7);
	DEFINE cTipoSumario CHAR(2);
	DEFINE cTotalRegTruncados CHAR(7);
	DEFINE cTipoGranSumario CHAR(2);
	DEFINE cSentido CHAR(1);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cNumOperaciones CHAR(7);
	DEFINE cNumBloques CHAR(2);
	DEFINE cFolio CHAR(9);
	DEFINE cFecha CHAR(8);
	DEFINE bInTransaction BOOLEAN;
	DEFINE cNoBloque CHAR(5);	
	DEFINE cImported CHAR(15);
	DEFINE cImportes CHAR(18);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMiBanco = '';
	LET dFechaMasUno = '';
	LET dFechaHabilProx = '';
	LET cFormatFecha = '';
	LET cFormatFechaMasUno = '';
	LET cFormatFechaProx = '';
	LET cFechaProx = '';
	LET iNumBloque = 0;
	LET cStatusParam = '';
	LET iHayDatos = 0;
	LET cBcoPresenta = '';
	LET cNombreBanco = '';
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cMotDevol = '';
	LET cGeneradoDev = '';
	LET cFechaTransfer = '';
	LET cImporte = '';
	LET cLoteEntrada = '';
	LET cSecEntrada = '';  
	LET cLoteSalida = '';  
	LET cSecSalida = '';
	LET cCveTransacc = '';
	LET cPlazaCompensa = '';
	LET cNumCuenta = '';
	LET cNumCheque = '';
	LET cDigInter = '';
	LET cDigPremar = '';
	LET cCodSeguridad = '';
	LET cUbicacionFisica = '';
	LET cTruncamiento = '';
	LET cMotDevol2 = '';
	LET cFechaPresini = '';
	LET cPlazaInter = '';
	LET cRfcBen = '';  
	LET cCurpBen = '';
	LET cTipoCtadep = '';
	LET cCuentaDep = '';
	LET cNombreBen = '';
	LET cAlertamiento = '';
	LET cFolioSegur = '';
	LET cStatus = '';
	LET iIdRegistro = '';
	LET iTotalChequesDet = 0;
	LET cSecuencia = '';
	LET cPrueba = '0';
	LET iTotalCheques = 0;
	LET mTotalImporte = 0.00;
	LET cTotalImporte = '';
	LET cMonto = '';
	LET cCents = '';
	LET iTotalRegTruncados = 0;
	LET iBloqueInicial = 1;
	LET cIdPresentar = '';
	LET cTipoRegistro = '';
	LET cNumSecuencia = '';
	LET cNumBanco = '';
	LET cSentidoTransfer = '';
	LET cPlazaCecoban = '';
	LET cServicioTEI = '';
	LET iDiaMesTransfer = 0;
	LET cFechaPresenta = '';
	LET cUsoFuturo1 = '';
	LET cTipoArchivo = '';
	LET cUsoFuturo2 = '';
	LET iSecuencia = 0;
	LET cDigverpre = '';
	LET cDigverinter = '';																	 
	LET cTipo_cta_dep = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cCodAlertamiento = '';
	LET cTipoRegistro = '';
	LET cCodOper = '';
	LET cFechatrasnfer = '';
	LET cBancoCedente = '';
	LET cBancoLibrado = '';
	LET cCveTrans = '';
	LET cCodSegur = '';
	LET cUbicFis = '';
	LET cTruncado = '';
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cCtaDep = '';
	LET cCtaDepFormat = '';
	LET cCtaAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET cUsoFuturoSum = '';
	LET cUsoFuturoGranSum = '';
	LET cTotRegs = '';
	LET cTipoSumario = '';
	LET cTotalRegTruncados = '';
	LET cTipoGranSumario = '';
	LET cSentido = '';
	LET cCodOperacion = '';
	LET cNumOperaciones = '';
	LET cNumBloques = '';
	LET cFolio = '';
	LET cFecha = '';
	LET bInTransaction = 'f';
	LET cNoBloque ='';
	LET cImported ='';
	LET cImportes = '';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genarchivodevoluciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pTipo = '' OR pNombreArchivo = '' OR pRutaDescarga = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
	
		LET dFechaMasUno = pFecha;
		EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaMasUno)
		INTO cCodRetSp, dFechaHabilProx;
		
		LET cFormatFecha = SUBSTR(pFecha,7,4)||SUBSTR(pFecha,1,2)||SUBSTR(pFecha,4,2);
		LET cFormatFechaMasUno = SUBSTR(dFechaMasUno,7,4)||SUBSTR(dFechaMasUno,1,2)||SUBSTR(dFechaMasUno,4,2);		
		LET cFormatFechaProx = SUBSTR(dFechaHabilProx,4,2)||SUBSTR(dFechaHabilProx,1,2)||SUBSTR(dFechaHabilProx,7,4);
		LET cFechaProx = SUBSTR(dFechaHabilProx,7,4)||SUBSTR(dFechaHabilProx,1,2)||SUBSTR(dFechaHabilProx,4,2);

		SELECT NVL(MAX(num_bloque::INTEGER)+1,1)
		INTO iNumBloque
		FROM bditef:"informix".cce_encabezado
		WHERE nombrearchivo[1,12] = 'DEV_'||cFormatFechaProx;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipo = '0' OR pTipo = '1' THEN
			IF pTipo = '0' THEN
				LET cStatusParam = '10';
			ELIF pTipo = '1' THEN
				LET cStatusParam = '11';
			END IF;
			
			SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} COUNT(id_registro) INTO iHayDatos
			FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 	
			WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario 
			AND fecha_entrada = dFechaMasUno AND status = cStatusParam AND duplicado = '0';
			
		ELIF pTipo = '2' THEN
		
			SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} COUNT(id_registro) INTO iHayDatos
			FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev 	
			WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario 
			AND fecha_entrada = dFechaMasUno AND status IN ('10','11') AND duplicado = '0';
		
		END IF;
		
		IF NVL(iHayDatos,0) > 0 THEN
		
			--** ENCABEZADO **--

			LET cTipoRegistro = '01';
			LET cNumSecuencia = LPAD(TRIM(TO_CHAR(iBloqueInicial)),7,'0');
			LET cNumBanco = cMiBanco;
			LET cSentidoTransfer = 'E';
			LET cPlazaCecoban = '01';
			LET cServicioTei = '1';
			LET iDiaMesTransfer = LPAD(DAY(dFechaHabilProx),2,'0');
			LET cNoBloque = LPAD(TRIM(TO_CHAR(iNumBloque)),5,'0');
			LET cFechaPresenta = LPAD(cFechaProx,8,'0');
			LET cUsoFuturo1 = LPAD(cUsoFuturo1,9,' ');
			LET cTipoArchivo = cPrueba;
			LET cUsoFuturo2 = LPAD(cUsoFuturo2,302,' ');
			
			--ESCRITURA DE LA CADENA DE TEXTO EN UN ARCHIVO
			SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cNumBanco||cSentidoTransfer||cPlazaCecoban||cServicioTEI||LPAD(iDiaMesTransfer, 2, '0')||
							cNoBloque||cFechaPresenta||cUsoFuturo1||cTipoArchivo||cUsoFuturo2||'" > '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
			
			--GRABA EN BASE ENCABEZADO
			EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_encabezado(TRIM(pNombreArchivo), cTipoRegistro, cNumSecuencia, cNumBanco, 
			cSentidoTransfer, cPlazaCecoban, cServicioTEI, LPAD(iDiaMesTransfer, 2, '0'),cNoBloque, 
			cFechaPresenta, cTipoArchivo, pUsuario, dFechaHabilProx) INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_encabezado';
			END IF;

			IF pTipo = '0' OR pTipo = '1' THEN
				
				IF pTipo = '0' THEN
					LET cStatusParam = '10';
				ELIF pTipo = '1' THEN
					LET cStatusParam = '11';
				END IF;
			
				--** DETALLE **--
				
				LET iTotalChequesDet = 1;
			
				FOREACH 
					SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} bco_presenta,c_cuenta,c_cheque,c_importe,importe,lote_entrada,sec_entrada,lote_salida,sec_salida,cve_transacc,plaza_compensa,
					num_cuenta,num_cheque,dig_inter,dig_premar,cod_seguridad,ubicacion_fisica,truncamiento,mot_devol2,fecha_presini,plaza_inter,                     
					rfc_ben,curp_ben,tipo_ctadep,cuenta_dep,nombre_ben,alertamiento,folio_segur,id_registro
					INTO cBcoPresenta,cCuenta,iCheque,mImporte,cImporte,cLoteEntrada,cSecEntrada,cLoteSalida,cSecSalida,cCveTransacc,cPlazaCompensa,
					cNumCuenta,cNumCheque,cDigInter,cDigPremar,cCodSeguridad,cUbicacionFisica,cTruncamiento,cMotDevol2,cFechaPresini,cPlazaInter,
					cRfcBen,cCurpBen,cTipoCtadep,cCuentaDep,cNombreBen,cAlertamiento,cFolioSegur,iIdRegistro
					FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev
					WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario 
					AND fecha_entrada = dFechaMasUno AND status = cStatusParam AND duplicado = '0' ORDER BY id_registro ASC
					
					LET cTipoRegistro = '02';
					LET cSecuencia = NVL(iBloqueInicial,0) + NVL(iTotalChequesDet,0);
					LET cNumSecuencia = LPAD(TRIM(cSecuencia),7,'0');						
					LET cCodOper = '41';
					LET cFechatrasnfer = LPAD(TO_CHAR(DATE(dFechaHabilProx),'%Y%m%d'),8,'0');
					LET cBancoCedente = LPAD(TRIM(cBcoPresenta),3,'0');
					LET cBancoLibrado = cMiBanco;
					
					LET cImported = LPAD(TRIM(cImporte),15,'0');				
					LET cLoteEntrada = LPAD(TRIM(cLoteEntrada),7,'0');
					LET cSecEntrada = LPAD(TRIM(cSecEntrada),4,'0');
					LET cLoteSalida = LPAD(TRIM(cLoteSalida),7,'0');
					LET cSecSalida = LPAD(TRIM(cSecSalida),4,'0');
					LET cCveTrans  = LPAD(TRIM(cCveTransacc),2,'0');
					LET cPlazaCompensa = LPAD(TRIM(cPlazaCompensa),3,'0');
					LET cNumCuenta = LPAD(TRIM(cNumCuenta),13,'0');				
					LET cNumCheque = LPAD(TRIM(cNumCheque),10,'0');	
					LET cDigverinter = LPAD(cDigInter,1,' ');
					LET cDigverpre = LPAD(cDigPremar,1,' ');
					LET cCodSegur = LPAD(TRIM(cCodseguridad),3,'0');
					LET cUbicFis = LPAD(TRIM(cUbicacionFisica),8,'0');
				
					LET cTruncado = LPAD(cTruncamiento,1,' ');
					IF NVL(cTruncamiento,'') = '0' THEN
						LET iTotalRegTruncados = iTotalRegTruncados + 1;
					END IF;
					
					LET cMotivoDevol = LPAD(TRIM(cMotDevol2),2,' ');
					LET cFechaInicial = LPAD(TRIM(cFechaPresini),8,'0');
					LET cPlazaIntercam = LPAD(TRIM(cPlazaInter),2,'0');
					LET cRfcCte = RPAD(TRIM(cRfcBen),13,' ');
					LET cCurpCte = RPAD(TRIM(cCurpBen),18,' ');
					LET cTipo_cta_dep = LPAD(TRIM(cTipoCtadep),2,'0'); 
					LET cCtaDep = LPAD(TRIM(cCuentaDep),20,'0');
					
					LET cNombreBen = RPAD(TRIM(cNombreBen),40,' ');
					LET cCtaAlertamiento = LPAD(TRIM(cAlertamiento),2,' ');
					LET cFolioSeguro = LPAD(cFolioSegur,12,' ');
					LET cUsoFuturo = LPAD(cUsoFuturo,120,' ');
				
					--ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
					SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cCodOper||cFechatrasnfer||cBancoCedente||cBancoLibrado||cImported||
									cLoteEntrada||cSecEntrada||cLoteSalida||cSecSalida||cCveTrans||cPlazaCompensa||
									cNumCuenta||cNumCheque||cDigverinter||cDigverpre||
									cCodSegur||cUbicFis||cTruncado||cMotivoDevol||cFechaInicial||cPlazaIntercam||cRfcCte||
									cCurpCte||cTipo_cta_dep||cCtaDep||cNombreBen||cCtaAlertamiento||
									cFolioSeguro||cUsoFuturo||'" >> '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
					
					LET iTotalCheques = iTotalCheques + 1;	
					LET mTotalImporte = mTotalImporte + mImporte;		 
					
					--GRABA EN BASE DETALLE
					EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_detalle(TRIM(pNombreArchivo),cTipoRegistro,cNumSecuencia,cCodOper,cFechatrasnfer,
					cBancoCedente,cBancoLibrado,mImporte,cLoteEntrada,cSecEntrada,cLoteSalida,cSecSalida,cCveTrans,cPlazaCompensa,
					cCuenta,iCheque,cDigverinter,cDigverpre,cCodSegur,
					cUbicFis,cTruncado,cMotivoDevol,cFechaInicial,cPlazaIntercam,cRfcCte,cCurpCte,cTipo_cta_dep,
					cCtaDep::BIGINT,cNombreBen,cCtaAlertamiento,cFolioSeguro) INTO cCodRetSp;
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_detalle';
					END IF;
				
					UPDATE bditef:"informix".cce_propios_det SET generado_dev = '1'
					WHERE bco_presenta = cBancoCedente
					AND c_cuenta = cCuenta AND c_cheque = iCheque 
					AND fecha_presini = cFormatFechaMasUno AND mot_devol = TRIM(cMotivoDevol);
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
					
					UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)}  bdicnweb:"informix".sw_cr_consultadetallechequesdev SET generado_dev = '1'
					WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario 
					AND fecha_entrada = dFechaMasUno AND status = cStatusParam AND duplicado = '0' AND id_registro = iIdRegistro;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
					
					LET iTotalChequesDet = iTotalChequesDet + 1;
					
				END FOREACH;
			
				--** SUMARIO **--
				
				LET cTipoSumario = '09';
				LET iSecuencia = NVL(iTotalCheques,0) + 2;
				LET cNumSecuencia = LPAD(TRIM(TO_CHAR(iSecuencia)),7,'0');				
				LET cCodOper = '41';
				LET cTotRegs = LPAD(TRIM(TO_CHAR(iTotalCheques)),7,'0'); 
				
				-- Formateo importe
				LET cImportes = '';
				LET cTotalImporte = TO_CHAR(mTotalImporte);
				LET cTotalImporte = SUBSTR(cTotalImporte, CHARINDEX('$', cTotalImporte) + 1);
				LET cMonto = SUBSTR(cTotalImporte, 1, CHARINDEX('.', cTotalImporte) - 1);
				LET cCents = SUBSTR(cTotalImporte, CHARINDEX('.', cTotalImporte) + 1);
				LET cImportes = LPAD(TRIM(cMonto),16,'0')||RPAD(TRIM(cCents),2,'0');
				
				LET cTotalRegTruncados = LPAD(TRIM(TO_CHAR(iTotalRegTruncados)),7,'0');
				LET cUsoFuturoSum = LPAD(cUsoFuturoSum,300,' ');

				--ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
				SYSTEM 'echo "'||cTipoSumario||cNumSecuencia||cCodOper||cTotRegs||cImportes||cTotalRegTruncados||cUsoFuturoSum||'" >> '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
				
				--GRABA EN BASE SUMARIO
				EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_sumario(TRIM(pNombreArchivo),cTipoSumario,cNumSecuencia,cCodOper,iTotalCheques,mTotalImporte,iTotalRegTruncados)INTO cCodRetSp;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_sumario';
				END IF;
				
				--** GRAN SUMARIO **--
				
				LET cTipoGranSumario = '51';
				LET cSentido = 'E';
				LET cCodOperacion = '41';
				LET cNumOperaciones =  cTotRegs;
				LET cNumBloques = '1';
				LET cNumBanco = cMiBanco;
				LET cFolio = LPAD(TRIM(TO_CHAR(iNumBloque)),9,'0');
				LET cFecha = TO_CHAR(DATE(dFechaHabilProx),'%Y%m%d');
				
				-- Formateo importe
				LET cImportes = '';
				LET cTotalImporte = TO_CHAR(mTotalImporte);
				LET cTotalImporte = SUBSTR(cTotalImporte, CHARINDEX('$', cTotalImporte) + 1);
				LET cMonto = SUBSTR(cTotalImporte, 1, CHARINDEX('.', cTotalImporte) - 1);
				LET cCents = SUBSTR(cTotalImporte, CHARINDEX('.', cTotalImporte) + 1);
				LET cImportes = LPAD(TRIM(cMonto),16,'0')||RPAD(TRIM(cCents),2,'0');
				
				LET cTotalRegTruncados = LPAD(TRIM(TO_CHAR(iTotalRegTruncados)),7,'0');
				LET cUsoFuturoGranSum = LPAD(cUsoFuturoGranSum,284,' ');
		
				--ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
				SYSTEM 'echo "'||cTipoGranSumario||cSentido||cCodOperacion||cNumOperaciones||LPAD(TRIM(cNumBloques),2,'0')||cNumBanco||cFolio||cFecha||cImportes||cTotalRegTruncados||cUsoFuturoGranSum||'" >> '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
				
				--GRABA EN BASE GRAN SUMARIO
				EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_gransumario(TRIM(pNombreArchivo),cTipoGranSumario,cSentido,cCodOperacion,iTotalCheques,cNumBloques,
				cNumBanco,iNumBloque,cFecha,mTotalImporte,iTotalRegTruncados)INTO cCodRetSp;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_gransumario';
				END IF;
			
			ELIF pTipo = '2' THEN
			
				--** DETALLE **--
				
				LET iTotalChequesDet = 1;
			
				FOREACH 
					SELECT {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} bco_presenta,c_cuenta,c_cheque,c_importe,importe,lote_entrada,sec_entrada,lote_salida,sec_salida,cve_transacc,plaza_compensa,
					num_cuenta,num_cheque,dig_inter,dig_premar,cod_seguridad,ubicacion_fisica,truncamiento,mot_devol2,fecha_presini,plaza_inter,                     
					rfc_ben,curp_ben,tipo_ctadep,cuenta_dep,nombre_ben,alertamiento,folio_segur,id_registro
					INTO cBcoPresenta,cCuenta,iCheque,mImporte,cImporte,cLoteEntrada,cSecEntrada,cLoteSalida,cSecSalida,cCveTransacc,cPlazaCompensa,
					cNumCuenta,cNumCheque,cDigInter,cDigPremar,cCodSeguridad,cUbicacionFisica,cTruncamiento,cMotDevol2,cFechaPresini,cPlazaInter,
					cRfcBen,cCurpBen,cTipoCtadep,cCuentaDep,cNombreBen,cAlertamiento,cFolioSegur,iIdRegistro
					FROM bdicnweb:"informix".sw_cr_consultadetallechequesdev
					WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario 
					AND fecha_entrada = dFechaMasUno AND status IN ('10','11') AND duplicado = '0' ORDER BY id_registro ASC
				
					LET cTipoRegistro = '02';
					LET cSecuencia = NVL(iBloqueInicial,0) + NVL(iTotalChequesDet,0);
					LET cNumSecuencia = LPAD(TRIM(cSecuencia),7,'0');						
					LET cCodOper = '41';
					LET cFechatrasnfer = LPAD(TO_CHAR(DATE(dFechaHabilProx),'%Y%m%d'),8,'0');
					LET cBancoCedente = LPAD(TRIM(cBcoPresenta),3,'0');
					LET cBancoLibrado = cMiBanco;
					
					LET cImported = LPAD(TRIM(cImporte),15,'0');				
					LET cLoteEntrada = LPAD(TRIM(cLoteEntrada),7,'0');
					LET cSecEntrada = LPAD(TRIM(cSecEntrada),4,'0');
					LET cLoteSalida = LPAD(TRIM(cLoteSalida),7,'0');
					LET cSecSalida = LPAD(TRIM(cSecSalida),4,'0');
					LET cCveTrans  = LPAD(TRIM(cCveTransacc),2,'0');
					LET cPlazaCompensa= LPAD(TRIM(cPlazaCompensa),3,'0');
					LET cNumCuenta = LPAD(TRIM(cNumCuenta),13,'0');				
					LET cNumCheque = LPAD(TRIM(cNumCheque),10,'0');	
					LET cDigverinter = LPAD(cDigInter,1,' ');
					LET cDigverpre = LPAD(cDigPremar,1,' ');
					LET cCodSegur = LPAD(TRIM(cCodseguridad),3,'0');
					LET cUbicFis = LPAD(TRIM(cUbicacionFisica),8,'0');
				
					LET cTruncado = LPAD(cTruncamiento,1,' ');
					IF NVL(cTruncamiento,'') = '0' THEN
						LET iTotalRegTruncados = iTotalRegTruncados + 1;
					END IF;
					
					LET cMotivoDevol = LPAD(TRIM(cMotDevol2),2,' ');
					LET cFechaInicial = LPAD(TRIM(cFechaPresini),8,'0');
					LET cPlazaIntercam = LPAD(TRIM(cPlazaInter),2,'0');
					LET cRfcCte = RPAD(TRIM(cRfcBen),13,' ');
					LET cCurpCte = RPAD(TRIM(cCurpBen),18,' ');
					LET cTipo_cta_dep = LPAD(TRIM(cTipoCtadep),2,'0'); 
					LET cCtaDep = LPAD(TRIM(cCuentaDep),20,'0');
					
					LET cNombreBen = RPAD(TRIM(cNombreBen),40,' ');
					LET cCtaAlertamiento = LPAD(TRIM(cAlertamiento),2,' '); 
					LET cFolioSeguro = LPAD(cFolioSegur,12,' ');
					LET cUsoFuturo = LPAD(cUsoFuturo,120,' ');
				
					--ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
					SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cCodOper||cFechatrasnfer||cBancoCedente||cBancoLibrado||cImported||
									cLoteEntrada||cSecEntrada||cLoteSalida||cSecSalida||cCveTrans||cPlazaCompensa||
									cNumCuenta||cNumCheque||cDigverinter||cDigverpre||
									cCodSegur||cUbicFis||cTruncado||cMotivoDevol||cFechaInicial||cPlazaIntercam||cRfcCte||
									cCurpCte||cTipo_cta_dep||cCtaDep||cNombreBen||cCtaAlertamiento||
									cFolioSeguro||cUsoFuturo||'" >> '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
					
					LET iTotalCheques = iTotalCheques + 1;	
					LET mTotalImporte = mTotalImporte + mImporte;
					
					--GRABA EN BASE DETALLE
					EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_detalle(TRIM(pNombreArchivo),cTipoRegistro,cNumSecuencia,cCodOper,cFechatrasnfer,
					cBancoCedente,cBancoLibrado,mImporte,cLoteEntrada,cSecEntrada,cLoteSalida,cSecSalida,cCveTrans,cPlazaCompensa,
					cCuenta,iCheque,cDigverinter,cDigverpre,cCodSegur,
					cUbicFis,cTruncado,cMotivoDevol,cFechaInicial,cPlazaIntercam,cRfcCte,cCurpCte,cTipo_cta_dep,
					cCtaDep::BIGINT,cNombreBen,cCtaAlertamiento,cFolioSeguro) INTO cCodRetSp;
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_detalle';
					END IF;
				
					UPDATE bditef:"informix".cce_propios_det SET generado_dev = '1'
					WHERE bco_presenta = cBancoCedente
					AND c_cuenta = cCuenta AND c_cheque = iCheque 
					AND fecha_presini = cFormatFechaMasUno AND mot_devol = TRIM(cMotivoDevol);
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
					
					UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cr_consultadetallechequesdev)} bdicnweb:"informix".sw_cr_consultadetallechequesdev SET generado_dev = '1'
					WHERE direccion_mac = pDireccionMac AND usuario_insert = pUsuario 
					AND fecha_entrada = dFechaMasUno AND status IN ('10','11') AND duplicado = '0' AND id_registro = iIdRegistro;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00283';
						RETURN cCodRet;
					END IF;
					
					LET iTotalChequesDet = iTotalChequesDet + 1;
					
				END FOREACH;
			
				--** SUMARIO **--
				
				LET cTipoSumario = '09';
				LET iSecuencia = NVL(iTotalCheques,0) + 2;
				LET cNumSecuencia = LPAD(TRIM(TO_CHAR(iSecuencia)),7,'0');				
				LET cCodOper = '41';
				LET cTotRegs = LPAD(TRIM(TO_CHAR(iTotalCheques)),7,'0');
				
				-- Formateo importe
				LET cImportes = ''; 
				LET cTotalImporte = TO_CHAR(mTotalImporte);
				LET cTotalImporte = SUBSTR(cTotalImporte, CHARINDEX('$', cTotalImporte) + 1);
				LET cMonto = SUBSTR(cTotalImporte, 1, CHARINDEX('.', cTotalImporte) - 1);
				LET cCents = SUBSTR(cTotalImporte, CHARINDEX('.', cTotalImporte) + 1);
				LET cImportes = LPAD(TRIM(cMonto),16,'0')||RPAD(TRIM(cCents),2,'0');
				
				LET cTotalRegTruncados = LPAD(TRIM(TO_CHAR(iTotalRegTruncados)),7,'0');
				LET cUsoFuturoSum = LPAD(cUsoFuturoSum,300,' ');

				--ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
				SYSTEM 'echo "'||cTipoSumario||cNumSecuencia||cCodOper||cTotRegs||cImportes||cTotalRegTruncados||cUsoFuturoSum||'" >> '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
				
				--GRABA EN BASE SUMARIO
				EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_sumario(TRIM(pNombreArchivo),cTipoSumario,cNumSecuencia,cCodOper,iTotalCheques,mTotalImporte,iTotalRegTruncados)INTO cCodRetSp;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_sumario';
				END IF;
				
				--** GRAN SUMARIO **--
				
				LET cTipoGranSumario = '51';
				LET cSentido = 'E';
				LET cCodOperacion = '41';
				LET cNumOperaciones =  cTotRegs;
				LET cNumBloques = '1';
				LET cNumBanco = cMiBanco;
				LET cFolio = LPAD(TRIM(TO_CHAR(iNumBloque)),9,'0');
				LET cFecha = TO_CHAR(DATE(dFechaHabilProx),'%Y%m%d');
				
				-- Formateo importe
				LET cImportes = ''; 
				LET cTotalImporte = TO_CHAR(mTotalImporte);
				LET cTotalImporte = SUBSTR(cTotalImporte, CHARINDEX('$', cTotalImporte) + 1);
				LET cMonto = SUBSTR(cTotalImporte, 1, CHARINDEX('.', cTotalImporte) - 1);
				LET cCents = SUBSTR(cTotalImporte, CHARINDEX('.', cTotalImporte) + 1);
				LET cImportes = LPAD(TRIM(cMonto),16,'0')||RPAD(TRIM(cCents),2,'0');
				
				LET cTotalRegTruncados = LPAD(TRIM(TO_CHAR(iTotalRegTruncados)),7,'0');
				LET cUsoFuturoGranSum = LPAD(cUsoFuturoGranSum,284,' ');
		
				--ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
				SYSTEM 'echo "'||cTipoGranSumario||cSentido||cCodOperacion||cNumOperaciones||LPAD(TRIM(cNumBloques),2,'0')||cNumBanco||cFolio||cFecha||cImportes||cTotalRegTruncados||cUsoFuturoGranSum||'" >> '||TRIM(pRutaDescarga)||TRIM(pNombreArchivo)||'.cce';
				
				--GRABA EN BASE GRAN SUMARIO
				EXECUTE PROCEDURE bditef:"informix".sp_cce_guardar_gransumario(TRIM(pNombreArchivo),cTipoGranSumario,cSentido,cCodOperacion,iTotalCheques,cNumBloques,
				cNumBanco,iNumBloque,cFecha,mTotalImporte,iTotalRegTruncados)INTO cCodRetSp;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_gransumario';
				END IF;
			
			END IF;
			
		ELSE
			LET cCodRet = '00856'; --NO HAY DATOS PARA GENERAR EL ARCHIVO
		END IF;

		RETURN cCodRet;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 12/09/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de archivo de devoluciones', 
'DESCRIPCION: SPL encargado de generar el archivo de devoluciones.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 02/02/2017',
'DESCRIPCION: Se modifica SPL para corregir el llenado de ceros a la izquierda del campo cuenta_dep al momento de hacer el guardado del detalle.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_lecturarchivodatosimportar(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pRutaArchivo CHAR(100),
pDireccionMac CHAR(12), pCodOperacion CHAR(5), pFechaHoy DATE)
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS bandera_det_error,
				  CHAR(1) AS muestra_msn;

	DEFINE cCodRet CHAR(5);
	DEFINE cIdCodRet CHAR(5);
	DEFINE cDescIdCodRet CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE cDescMensajeError CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cSeccion CHAR(12);
	DEFINE cCampo CHAR(2);
	DEFINE cTexto CHAR(100);
	DEFINE cEncTipoRegistro CHAR(2);
	DEFINE cEncNumSecuencia CHAR(7);
	DEFINE cEncNumBanco CHAR(3);
	DEFINE cEncSentidoTransfer CHAR(1);
	DEFINE cEncPlazaCecoban CHAR(2);
	DEFINE cEncServicioTei CHAR(1);
	DEFINE cEncDiaMesTransfer CHAR(2);
	DEFINE cEncNumBloque CHAR(5);
	DEFINE cEnpFechaPresenta CHAR(8);
	DEFINE cEncUsoFuturo1 CHAR(9);
	DEFINE cEncTipoArchivo CHAR(1);
	DEFINE cEncUsoFuturo2 CHAR(302);
	DEFINE iContEncabezado INTEGER;
	DEFINE cDetMotivo CHAR(2);
	DEFINE cDetDatosMotivo CHAR(50);
	DEFINE cDetDatosMotivoDevol CHAR(50);
	DEFINE cDetTipoRegistro CHAR(2);
	DEFINE cDetNumSecuencia CHAR(7);
	DEFINE cDetCodOperacion CHAR(2);
	DEFINE cDetFechaTrasnfer CHAR(8);
	DEFINE cDetBancoCedente CHAR(3);
	DEFINE cDetBancoLibrado CHAR(3);
	DEFINE cDetImporte CHAR(15);
	DEFINE cDetLoteEntrada CHAR(7);
	DEFINE cDetSecEntrada CHAR(4);
	DEFINE cDetLoteSalida CHAR(7);
	DEFINE cDetSecSalida CHAR(4);
	DEFINE cDetTransaccion CHAR(2);
	DEFINE cDetPlazaCompensa CHAR(3);
	DEFINE cDetNumCuenta CHAR(13);
	DEFINE cDetNumCheque CHAR(10);
	DEFINE cDetChqDigVerInter CHAR(1);
	DEFINE cDetChqDigVerPre CHAR(1);
	DEFINE cDetChqCodSeguridad CHAR(3);
	DEFINE cDetUbicFis CHAR(8);
	DEFINE cDetTruncado CHAR(1);
	DEFINE cDetMotivoDevol CHAR(2);
	DEFINE cDetFechaInicial CHAR(8);
	DEFINE cDetPlazaIntercam CHAR(2);
	DEFINE cDetRfcCte CHAR(13);
	DEFINE cDetCurpCte CHAR(18);
	DEFINE cDetTipoCuentaDep CHAR(2);
	DEFINE cDetCuentaDeposito CHAR(20);
	DEFINE cDetNombreCte CHAR(40);
	DEFINE cDetCtaAlertamiento CHAR(2);
	DEFINE cDetFolioSeguro CHAR(12);
	DEFINE cDetUsoFuturo CHAR(120);
	DEFINE cDetStatusCausa CHAR(2);
	DEFINE iContDetalle INTEGER;
	DEFINE cSumTipoRegistro CHAR(2);
	DEFINE cSumNumSecuencia CHAR(7);
	DEFINE cSumCodOperacion CHAR(2);
	DEFINE cSumTotalRegistros CHAR(7);
	DEFINE cSumImporte CHAR(18);
	DEFINE cSumTotalRegTruncImg CHAR(7);
	DEFINE cSumUsoFuturo CHAR(300);
	DEFINE iContSumario INTEGER;
	DEFINE cGranSumTipoRegistro CHAR(2);
	DEFINE cGranSumSentido CHAR(1);
	DEFINE cGranSumCodOperacion CHAR(2);
	DEFINE cGranSumNumOperaciones CHAR(7);
	DEFINE cGranSumNumBloques CHAR(2);
	DEFINE cGranSumNumBanco CHAR(3);
	DEFINE cGranSumFolio CHAR(9);
	DEFINE cGranSumFecha CHAR(8);
	DEFINE cGranSumImporteTotal CHAR(18);
	DEFINE cGranSumTotalRegTruncImg CHAR(7);
	DEFINE cGranSumUsoFuturo CHAR(284);
	DEFINE iContGranSumario INTEGER;
	DEFINE iValorImp INTEGER;
	DEFINE mValorImporte MONEY(14,2);
	DEFINE mTotalImporte MONEY(19,2);
	DEFINE mTotalImpCecoban MONEY(19,2);
	DEFINE iBandaChequeValida INTEGER;
	DEFINE cBLibrado CHAR(3);
	DEFINE cSubsCuenta CHAR(13);
	DEFINE cNCuenta CHAR(11);
	DEFINE cCuenta CHAR(14);
	DEFINE iSuma BIGINT;
	DEFINE iDigitoIntercambio INTEGER;
	DEFINE cPzaCompensa CHAR(3);
	DEFINE iDetOper INTEGER;
	DEFINE iDiv BIGINT;
	DEFINE iDigitoDiv INTEGER;
	DEFINE cMonto CHAR(12);
	DEFINE cCents CHAR(2);
	DEFINE mImporte MONEY(19,2);
	DEFINE cDescbancoLibrado CHAR(30);
	DEFINE cMotivoDevolucion CHAR(30);
	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE cprocesar CHAR(2);
	DEFINE pFechaformat CHAR(8);
	DEFINE cValidaPresentado CHAR(50);
	DEFINE iNoPresentado INTEGER;
	DEFINE cValidaProceso CHAR(30);
	DEFINE ven_transacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(250);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE cMiBanco CHAR(3);
	DEFINE cRazonSocial CHAR(30);
	DEFINE dHora DATETIME HOUR TO SECOND;
	DEFINE cFormatFechaHoy CHAR(8);
	DEFINE cDiaHoy CHAR(2);
	DEFINE cFechaHabAnt CHAR(10);
	DEFINE cFormatFechaAnt CHAR(8);
	DEFINE mMontoImg MONEY(14,2);
	DEFINE iRegDuplicado INTEGER;
	DEFINE iTotRegDet INTEGER;
    DEFINE iTotRegLeidos INTEGER;
    DEFINE iNroSecuencia INTEGER;
    DEFINE iTotImporte INTEGER;
	DEFINE iTotImagenesTruncadas INTEGER;
    DEFINE iImagenesTrucadas INTEGER;
    DEFINE iTotImporteCecoban INTEGER;
    DEFINE iTotImagenesTrucadas INTEGER;
    DEFINE iNroLinea INTEGER;
    DEFINE cTieneEncabezado CHAR(1);
    DEFINE cTieneDetalle CHAR(1);
    DEFINE cTieneSumario CHAR(1);
    DEFINE cTieneGranSumario CHAR(1);
	DEFINE cError46 CHAR(1);
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE cLecturaArchivoDatos CHAR(1);
	DEFINE iIdReg INTEGER;
	DEFINE cCta CHAR(22);
	DEFINE iNumchq INTEGER;
	DEFINE cDevol CHAR(2);
	DEFINE cMotDevol40 CHAR(2);
	DEFINE cConcatMsn CHAR(30);
	DEFINE cMotivo CHAR(50);
	DEFINE pFechaOrigen CHAR(8);
	DEFINE cMotDevol46 CHAR(2);
	DEFINE cStatus46 CHAR(2);
	DEFINE iNumCaracteres INTEGER;
	DEFINE iPosTrama INTEGER;
	DEFINE cBanDetError CHAR(1);
	DEFINE cMuestraMsn CHAR(1);
	DEFINE cLineTrim CHAR(350);
	DEFINE iLongitudCad INTEGER;

	LET iLongitudCad = 0;
	LET cLineTrim = '';
	LET cCodRet = '00000';
	LET cIdCodRet = '00000';
	LET cDescIdCodRet = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET cDescMensajeError = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cSeccion = '';
	LET cCampo = '';
	LET cTexto = '';
	LET cEncTipoRegistro = '';
	LET cEncNumSecuencia = '';
	LET cEncNumBanco = '';
	LET cEncSentidoTransfer = '';
	LET cEncPlazaCecoban = '';
	LET cEncServicioTei = '';
	LET cEncDiaMesTransfer = '';
	LET cEncNumBloque = '';
	LET cEnpFechaPresenta = '';
	LET cEncUsoFuturo1 = '';
	LET cEncTipoArchivo = '';
	LET cEncUsoFuturo2 = '';
	LET iContEncabezado = 0;
	LET cDetMotivo = '';
	LET cDetDatosMotivo = '';
	LET cDetDatosMotivoDevol = '';
	LET cDetTipoRegistro = '';
	LET cDetNumSecuencia = '';
	LET cDetCodOperacion = '';
	LET cDetFechaTrasnfer = '';
	LET cDetBancoCedente = '';
	LET cDetBancoLibrado = '';
	LET cDetImporte = '';
	LET cDetLoteEntrada = '';
	LET cDetSecEntrada = '';
	LET cDetLoteSalida = '';
	LET cDetSecSalida = '';
	LET cDetTransaccion  = '';
	LET cDetPlazaCompensa = '';
	LET cDetNumCuenta = '';
	LET cDetNumCheque = '';
	LET cDetChqDigVerInter = '';
	LET cDetChqDigVerPre = '';
	LET cDetChqCodSeguridad = '';
	LET cDetUbicFis = '';
	LET cDetTruncado = '';
	LET cDetMotivoDevol = '';
	LET cDetFechaInicial = '';
	LET cDetPlazaIntercam = '';
	LET cDetRfcCte = '';
	LET cDetCurpCte = '';
	LET cDetTipoCuentaDep = '';
	LET cDetCuentaDeposito = '';
	LET cDetNombreCte = '';
	LET cDetCtaAlertamiento = '';
	LET cDetFolioSeguro = '';
	LET cDetUsoFuturo = '';
	LET cDetStatusCausa = '';
	LET iContDetalle = 0;
	LET cSumTipoRegistro = '';
	LET cSumNumSecuencia = '';
	LET cSumCodOperacion = '';
	LET cSumTotalRegistros = '';
	LET cSumImporte = '';
	LET cSumTotalRegTruncImg = '';
	LET cSumUsoFuturo = '';
	LET iContSumario = 0;
	LET cGranSumTipoRegistro = '';
	LET cGranSumSentido = '';
	LET cGranSumCodOperacion = '';
	LET cGranSumNumOperaciones = '';
	LET cGranSumNumBloques = '';
	LET cGranSumNumBanco = '';
	LET cGranSumFolio = '';
	LET cGranSumFecha = '';
	LET cGranSumImporteTotal = '';
	LET cGranSumTotalRegTruncImg = '';
	LET cGranSumUsoFuturo = '';
	LET iContGranSumario = 0;
	LET iValorImp = 0;
	LET mValorImporte = 0.00;
	LET mTotalImporte = 0.00;
	LET mTotalImpCecoban = 0.00;
	LET iBandaChequeValida = 0;
	LET cBLibrado = '';
	LET cSubsCuenta = '';
	LET cNCuenta = '';
	LET cCuenta = '';
	LET iSuma = 0;
	LET iDigitoIntercambio = 0;
	LET cPzaCompensa = '';
	LET iDetOper = '';
	LET iDiv = 0;
	LET iDigitoDiv = 0;
	LET cMonto = '';
	LET cCents = '';
	LET mImporte = 0.00;
	LET cDescbancoLibrado = '';
	LET cMotivoDevolucion = '';
	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET cprocesar = '';
	LET pFechaformat = '';
	LET cValidaPresentado = '';
	LET iNoPresentado = 0;
	LET cValidaProceso = '';
	LET ven_transacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET cPathdbaccess = '/informix/bin/';
	LET cMiBanco = '';
	LET cRazonSocial = '';
	LET dHora = '';
	LET cFormatFechaHoy = '';
	LET cDiaHoy = '';
	LET cFechaHabAnt = '';
	LET cFormatFechaAnt = '';
	LET mMontoImg = 0.00;
	LET iRegDuplicado = 0;
	LET iTotRegDet = 0;
    LET iTotRegLeidos = 0;
    LET iNroSecuencia = 0;
    LET iTotImporte = 0;
	LET iTotImagenesTruncadas = 0;
    LET iImagenesTrucadas = 0;
    LET iTotImporteCecoban = 0;
    LET iTotImagenesTrucadas = 0;
    LET iNroLinea = 0;
	LET cTieneEncabezado = 't';
    LET cTieneDetalle = 't';
    LET cTieneSumario = 't';
    LET cTieneGranSumario = 't';
	LET cError46 = 'f';
	LET cCaracterInvalido = '';
	LET cLecturaArchivoDatos = 'f';
	LET iIdReg = 0;
	LET cCta = '';
	LET iNumchq = 0;
	LET cDevol = '';
	LET cMotDevol40 = '';
	LET cConcatMsn = '';
	LET cMotivo = '';
	LET pFechaOrigen = '';
	LET cMotDevol46 = '';
	LET cStatus46 = '';
	LET iNumCaracteres = 0;
	LET iPosTrama = 0;
	LET cBanDetError = 'f';
	LET cMuestraMsn = 'f';

	BEGIN

		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				LET cCodRet = cSqlerr;
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --
				END IF;

				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_cr_statuslecturaarchivos
				SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet)
				WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND archivo = TRIM(pNombreArchivo);

			   RETURN cCodRet,cBanDetError,cMuestraMsn;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_lecturarchivodatosimportar.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR  pNombreArchivo = '' OR pRutaArchivo = '' OR pDireccionMac = '' OR pCodOperacion = '' OR pFechaHoy IS NULL THEN
			LET cCodRet = '00003';

			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_cr_statuslecturaarchivos
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet)
			WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND archivo = TRIM(pNombreArchivo);

			RETURN cCodRet,cBanDetError,cMuestraMsn;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".sw_cr_statuslecturaarchivos
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet)
			WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND archivo = TRIM(pNombreArchivo);

			RETURN cCodRet,cBanDetError,cMuestraMsn;
		END IF;

		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_cr_statuslecturaarchivos
		WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND archivo = TRIM(pNombreArchivo);

		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdicnweb:"informix".sw_cr_statuslecturaarchivos(usuario,archivo,status,bandera_det_error,muestra_msn,error_proceso,tipo_proceso,error)
		VALUES(pUsuario,TRIM(pNombreArchivo),'I','','','','LECTURA','');

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		BEGIN WORK;
			LET ven_transacc = 1;
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'cr_cargaarchivos_tmp') THEN
				DROP TABLE bdicnweb:"informix".cr_cargaarchivos_tmp;
			END IF;

			-- SE CREAN TABLAS TEMPORALES
			CREATE TABLE bdicnweb:"informix".cr_cargaarchivos_tmp(id_serial SERIAL NOT NULL PRIMARY KEY,
																linea CHAR(400));
			-- LIMPIA TABLAS
			DELETE FROM bdicnweb:"informix".sw_cr_bitacoraerror WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac;
			DELETE FROM bdicnweb:"informix".sw_cr_procesaencabezado_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
			DELETE FROM bdicnweb:"informix".sw_cr_procesadetalle_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
			DELETE FROM bdicnweb:"informix".sw_cr_procesasumario_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;
			DELETE FROM bdicnweb:"informix".sw_cr_procesagransumario_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac;

			LET cSQL = '';
			-- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO *.SQL
			LET cSQL = 'echo "LOAD FROM ' ||TRIM(pRutaArchivo) || '/' || pNombrearchivo || ' INSERT INTO bdicnweb:"informix".cr_cargaarchivos_tmp(linea)" > '|| TRIM(pRutaArchivo) || 'Temporal.sql';
			SYSTEM cSQL;

			LET cSQL = '';
			-- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO *.SQL
			Let cSQL = TRIM(cPathdbaccess)||'dbaccess bdicnweb ' ||TRIM(pRutaArchivo)|| 'Temporal.sql'; --Se activa para desarrollo
			COMMIT WORK;
			SYSTEM cSQL;
			BEGIN WORK;

			-- BANCO PROPIETARIO
			SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';

			-- RAZÃN SOCIAL
			SELECT razon_social INTO cRazonSocial FROM bdinteg:"informix".si_empresas WHERE empresa = cEmpresa;

			-- VALOR IMPORTE PARA ENVIO DE IMAGEN A CECOBAN
			SELECT valor INTO mMontoImg FROM bditef:"informix".cce_param WHERE empresa = cEmpresa AND cod_param = '2';

			-- SE OBTIENE LA HORA
			LET dHora = CURRENT;

			-- FECHA HABIL ACTUAL
			LET cFormatFechaHoy = SUBSTR(pFechaHoy,7,4) || SUBSTR(pFechaHoy,1,2) || SUBSTR(pFechaHoy,4,2);
			LET cDiaHoy = SUBSTR(pFechaHoy,4,2);

			-- FECHA HABIL ANTERIOR
			EXECUTE PROCEDURE bditef:"informix".cal_habil_ant(pFechaHoy) INTO cIdCodRetSp, cFechaHabAnt;
			IF cIdCodRetSp = '000' THEN
				LET cFormatFechaAnt = SUBSTR(cFechaHabAnt,7,4) || SUBSTR(cFechaHabAnt,1,2) || SUBSTR(cFechaHabAnt,4,2);
			ELIF cIdCodRetSp <> '000' THEN
				ROLLBACK WORK;
				LET ven_transacc = 0;
				LET cCodRet = '666';
				RETURN cCodRet,cBanDetError,cMuestraMsn;
			END IF;

		COMMIT WORK;

		BEGIN WORK; --

			FOREACH SELECT linea INTO cRenglon FROM bdicnweb:"informix".cr_cargaarchivos_tmp ORDER BY(id_serial)

				LET iLinea = iLinea + 1;

				IF SUBSTR(cRenglon,1,2) <> '01' AND SUBSTR(cRenglon,1,2) <> '02' AND SUBSTR(cRenglon,1,2) <> '09'  AND SUBSTR(cRenglon,1,2) <> '51' THEN
					LET cDescIdCodRet = 'TIPO DE REGISTRO NO ES 01, 02, 09, 51';
					LET cSeccion = '';
					LET cCampo = '01';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

					LET cTexto = 'tipo de registro no es 01,02,09,51';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;

				-- LONGITUD DEL REGISTRO
				SELECT LENGTH(linea) - 1
				INTO iNumCaracteres
				FROM bdicnweb:"informix".cr_cargaarchivos_tmp
				WHERE id_serial = iLinea;

				-- VALIDA LA LONGITUD DE LA LINEA
				IF iNumCaracteres <> 343  THEN
					LET cDescIdCodRet = 'LA LONGITUD DE REGISTRO DIFIERE A 343';
					LET cSeccion = '';
					LET cCampo = '';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

					LET cTexto = 'la longitud de registro difiere a 343 (linea '||iLinea||')';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;

				--** ENCABEZADO **--
				IF SUBSTR(cRenglon,1,2) = "01" THEN

					LET cSeccion = 'ENCABEZADO';
					LET iContEncabezado = iContEncabezado + 1;
					LET iNroSecuencia = 1;
					LET cEncTipoRegistro = SUBSTR(cRenglon,1,2);
					LET cEncNumSecuencia = SUBSTR(cRenglon,3,7);
					LET cEncNumBanco = SUBSTR(cRenglon,10,3);
					LET cEncSentidoTransfer = SUBSTR(cRenglon,13,1);
					LET cEncPlazaCecoban = SUBSTR(cRenglon,14,2);
					LET cEncServicioTei = SUBSTR(cRenglon,16,1);
					LET cEncDiaMesTransfer = SUBSTR(cRenglon,17,2);
					LET cEncNumBloque = SUBSTR(cRenglon,19,5);
					LET cEnpFechaPresenta = SUBSTR(cRenglon,24,8);
					LET cEncUsoFuturo1 = SUBSTR(cRenglon,32,9);
					LET cEncTipoArchivo = SUBSTR(cRenglon,41,1);
					LET cEncUsoFuturo2 = SUBSTR(cRenglon,42,302);

					IF cEncNumSecuencia <> "0000001" THEN
						LET cDescIdCodRet = 'LA SECUENCIA DEL REGISTRO NO ES VÃLIDA';
						LET cCampo = '02';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo02 la sencuencia del registro no es valida';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEncNumBanco <> cMiBanco THEN
						LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO CORRESPONDE A '||TRIM(cRazonSocial);
						LET cCampo = '03';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo03 el archivo a procesar no corresponde a '||TRIM(cRazonSocial);
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEncSentidoTransfer <> "S" THEN
						LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES DE SALIDA';
						LET cCampo = '04';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo04 el archivo a procesar no es de salida';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEncPlazaCecoban <> "01" THEN
						LET cDescIdCodRet = 'VALOR DIFERENTE A 01';
						LET cCampo = '05';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo05 valor diferente a 01';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEncServicioTei <> "1" THEN
						LET cDescIdCodRet = 'REGISTRO ENCABEZADO NO ES COBRO INMEDIATO M.N.';
						LET cCampo = '06';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo06 registro encabezado no es cobro inmediato m.n.';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEncDiaMesTransfer <> cDiaHoy THEN
						LET cDescIdCodRet = 'DÃA DIFERENTE AL DE PROCESO';
						LET cCampo = '07';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo07 dia diferente al de proceso';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEnpFechaPresenta <> cFormatFechaHoy THEN
						LET cDescIdCodRet = 'LA FECHA DE PRESENTACIÃN NO ES HOY';
						LET cCampo = '09';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo09 la fecha de presentaciÃ³n no es hoy';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cEncTipoArchivo <> "0" AND cEncTipoArchivo <> "1" THEN
						LET cDescIdCodRet = 'TIPO DE ARCHIVO NO ES 0 Ã 1';
						LET cCampo = '11';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo11 tipo de archivo no es 0 o 1';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF TRIM(cEncUsoFuturo2) <> "" THEN
						LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
						LET cCampo = '12';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'encabezado: campo12 uso futuro sin blancos';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					INSERT INTO bdicnweb:"informix".sw_cr_procesaencabezado_tmp(id_encabezado,usuario,direccion_mac,tipo_registro,num_secuencia,num_banco,
					sentido_transfer,plaza_cecoban,servicio_tei,diames_transfer,num_bloque,fecha_presenta,uso_futuro1,tipo_archivo,uso_futuro2,fecha_insert)
					VALUES(iContEncabezado,pUsuario,pDireccionMac,cEncTipoRegistro,cEncNumSecuencia,cEncNumBanco,cEncSentidoTransfer,cEncPlazaCecoban,
					cEncServicioTei,cEncDiaMesTransfer,cEncNumBloque,cEnpFechaPresenta,cEncUsoFuturo1,cEncTipoArchivo,cEncUsoFuturo2,pFechaHoy);

				--** DETALLE **--
				ELIF SUBSTR(cRenglon,1,2) = "02" THEN

					LET cSeccion = 'DETALLE';
					LET iNroSecuencia = iNroSecuencia + 1;
					LET iContDetalle = iContDetalle + 1;

					-- CARACTERES INVALIDOS
					EXECUTE PROCEDURE bdicnweb:"informix".sp_validacaracter(pUsuario, pIdFuncion, cRenglon, 'L')
					INTO cIdCodRetSp, cCaracterInvalido, iPosTrama;
					IF cCaracterInvalido = 't' THEN
						LET cDescIdCodRet = 'CARACTERES INVÃLIDOS';
						LET cCampo = iPosTrama;
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'detalle: caracteres invalidos (campo '||iPosTrama||' linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					LET cDetDatosMotivoDevol = '';
					LET cDetTipoRegistro = SUBSTR(cRenglon,1,2);
					LET cDetNumSecuencia = SUBSTR(cRenglon,3,7);
					LET cDetCodOperacion = SUBSTR(cRenglon,10,2);
					LET cDetFechaTrasnfer = SUBSTR(cRenglon,12,8);
					LET cDetBancoCedente = SUBSTR(cRenglon,20,3);
					LET cDetBancoLibrado = SUBSTR(cRenglon,23,3);
					LET cDetImporte = SUBSTR(cRenglon,26,15);
					LET cDetLoteEntrada = SUBSTR(cRenglon,41,7);
					LET cDetSecEntrada = SUBSTR(cRenglon,48,4);
					LET cDetLoteSalida = SUBSTR(cRenglon,52,7);
					LET cDetSecSalida = SUBSTR(cRenglon,59,4);
					LET cDetTransaccion = SUBSTR(cRenglon,63,2);
					LET cDetPlazaCompensa = SUBSTR(cRenglon,65,3);
					LET cDetNumCuenta = SUBSTR(cRenglon,68,13);
					LET cDetNumCheque = SUBSTR(cRenglon,81,10);
					LET cDetChqDigVerInter = SUBSTR(cRenglon,91,1);
					LET cDetChqDigVerPre = SUBSTR(cRenglon,92,1);
					LET cDetChqCodSeguridad = SUBSTR(cRenglon,93,3);
					LET cDetUbicFis = SUBSTR(cRenglon,96,8);
					LET cDetTruncado = SUBSTR(cRenglon,104,1);
					LET cDetMotivoDevol = SUBSTR(cRenglon,105,2);
					LET cDetFechaInicial = SUBSTR(cRenglon,107,8);
					LET cDetPlazaIntercam = SUBSTR(cRenglon,115,2);
					LET cDetRfcCte = SUBSTR(cRenglon,117,13);
					LET cDetCurpCte = SUBSTR(cRenglon,130,18);
					LET cDetTipoCuentaDep = SUBSTR(cRenglon,148,2);
					LET cDetCuentaDeposito = SUBSTR(cRenglon,150,20);
					LET cDetNombreCte = SUBSTR(cRenglon,170,40);
					LEt cDetCtaAlertamiento = SUBSTR(cRenglon,210,2);
					LET cDetFolioSeguro = SUBSTR(cRenglon,212,12);
					LET cDetUsoFuturo = SUBSTR(cRenglon,224,120);

					LET cDetStatusCausa = '';

					IF TRIM(cDetUsoFuturo) <> "" THEN
						LET cDescIdCodRet = 'CARACTERES INVÃLIDOS';
						LET cCampo = '31';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'detalle: caracteres invalidos (campo '||cCampo||' linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					-- VALIDACIONES BASICAS
					IF ROUND(cDetNumSecuencia::INTEGER) <> iNroSecuencia THEN
						LET cDescIdCodRet = 'LA SECUENCIA DEL REGISTRO NO ES CONSECUTIVA';
						LET cCampo = '02';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'detalle: la sencuencia del registro no es consecutiva (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cDetCodOperacion <> TRIM(pCodOperacion) THEN
						LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES CÃDIGO '||TRIM(pCodOperacion);
						LET cCampo = '03';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'detalle: el archivo a procesar no es cÃ³digo '||TRIM(pCodOperacion)||' (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cDetBancoLibrado <> cMiBanco THEN
						LET cDetMotivoDevol = "06";
						LET cDetStatusCausa = "10";
					END IF;

					IF TRIM(pCodOperacion) = "46" THEN
						IF cDetFechaInicial <> cFormatFechaAnt THEN
							LET cDescIdCodRet = 'LA FECHA DE PRESENTACIÃN INICIAL NO ES HÃBIL ANTERIOR';
							LET cCampo = '22';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: fecha de presentacion inicial no es hab ant (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;
					ELSE
						IF cDetFechaInicial <> cFormatFechaHoy THEN
							LET cDescIdCodRet = 'LA FECHA PRESENTACIÃN INICIAL NO ES HOY';
							LET cCampo = '22';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: fecha de presentacion inicial no es hoy (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;
					END IF;

					IF TRIM(cDetUsoFuturo) <> "" THEN
						LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
						LET cCampo = '31';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'detalle: campo31 uso futuro sin blancos';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					LET iRegDuplicado = 0;
					IF iRegDuplicado = 0 THEN

						--LET mValorImporte = 0.00;
						LET mValorImporte = SUBSTR(cDetImporte,1,(LENGTH(cDetImporte)-2))||"."||SUBSTR(cDetImporte,(LENGTH(cDetImporte)-1),2);
						LET mTotalImporte = mTotalImporte + NVL(mValorImporte,0);
						LET mTotalImpCecoban = mTotalImpCecoban + NVL(mValorImporte,0);

						IF NVL(mValorImporte,0) > NVL(mMontoImg,0) THEN
							LET iTotImagenesTruncadas = iTotImagenesTruncadas + 1;
							LET iImagenesTrucadas = iImagenesTrucadas + 1;
						END IF;

						INSERT INTO bdicnweb:"informix".sw_cr_procesadetalle_tmp(id_detalle,usuario,direccion_mac,
						datos_nombre_archivo,datos_cod_operacion,datos_num_cuenta,datos_num_cheque,datos_motivo_devol,
						tipo_registro,num_secuencia,cod_operacion,fecha_transfer,banco_cedente,banco_librado,importe,
						lote_entrada,sec_entrada,lote_salida,sec_salida,transaccion,plaza_compensa,num_cuenta,num_cheque,
						dig_inter,dig_pre,cod_seguridad,ubic_fis,truncado,motivo_devol,fecha_inicial,plaza_intercam,
						rfc_cte,curp_cte,tipo_ctadep,cuenta_deposito,nombre_cte,cta_alertamiento,folio_seguro,uso_futuro,status_causa,fecha_insert)
						VALUES(iContDetalle,pUsuario,pDireccionMac,
						pNombreArchivo,cDetCodOperacion,cDetNumCuenta::BIGINT,cDetNumCheque::INTEGER,cDetDatosMotivoDevol,
						cDetTipoRegistro,cDetNumSecuencia,cDetCodOperacion,cDetFechaTrasnfer,cDetBancoCedente,cDetBancoLibrado,
						cDetImporte,cDetLoteEntrada,cDetSecEntrada,cDetLoteSalida,cDetSecSalida,cDetTransaccion,cDetPlazaCompensa,
						cDetNumCuenta,cDetNumCheque,cDetChqDigVerInter,cDetChqDigVerPre,cDetChqCodSeguridad,cDetUbicFis,cDetTruncado,
						cDetMotivoDevol,cDetFechaInicial,cDetPlazaIntercam,cDetRfcCte,cDetCurpCte,cDetTipoCuentaDep,
						cDetCuentaDeposito,cDetNombreCte,cDetCtaAlertamiento,cDetFolioSeguro,cDetUsoFuturo,cDetStatusCausa,pFechaHoy);

						-- STATUS FINAL
						IF cDetMotivoDevol = "00" THEN
							UPDATE bdicnweb:'informix'.sw_cr_procesadetalle_tmp SET status_causa = '01' WHERE id_detalle = iContDetalle;
						END IF;

						-- VALIDAR CÃDIGO DE SEGURIDAD, DIGITO DE PREMARCADO Y DIGITO DE INTERCAMBIO
						LET iBandaChequeValida = 0;
						LET cBLibrado = LPAD(TRIM(cDetBancoLibrado),3,'0');
						LET cSubsCuenta = cDetNumCuenta::BIGINT;
						LET cNCuenta = LPAD(TRIM(cSubsCuenta),11,'0');
						LET cCuenta = TRIM(cBLibrado) || TRIM(cNCuenta);

						-- DIGITO INTERCAMBIO
						EXECUTE PROCEDURE bdicnweb:"informix".sp_calculadigitointercambio(pUsuario, pIdFuncion, cCuenta, '10')
						INTO cIdCodRetSp, iDigitoIntercambio;

						LET iSuma = NVL(iDigitoIntercambio,0);

						IF iSuma <> cDetChqDigVerInter::INTEGER THEN
							LET iBandaChequeValida = 20;
						ELSE

							-- DIGITO PREMARCADO
							LET cPzaCompensa = LPAD(TRIM(cDetPlazaCompensa),3,'0');
							LET iDetOper = cDetTransaccion || cPzaCompensa || cBLibrado || cDetChqDigVerInter;
							LET iSuma = (cDetChqCodSeguridad::INTEGER + (iDetOper) + cDetNumCuenta::BIGINT) + cDetNumCheque::INTEGER;

							LET iDiv = CAST ((iSuma/9) AS BIGINT);
							LET iDigitoDiv = iSuma - (iDiv * 9);
							LET iDigitoDiv = 9 - iDigitoDiv;

							IF iDigitoDiv <> cDetChqDigVerPre::INTEGER THEN
								LET iBandaChequeValida = 30;
							END IF;

						END IF;

						IF iBandaChequeValida <> 0 THEN
							LET cDetMotivo = "23";
							SELECT (codigo ||" "|| descripcion) AS datos_motivo INTO cDetDatosMotivo
							FROM bdinteg:"informix".si_coddevcam
							WHERE codigo = cDetMotivo;

							UPDATE bdicnweb:'informix'.sw_cr_procesadetalle_tmp
							SET datos_motivo_devol = TRIM(cDetDatosMotivo), motivo_devol = TRIM(cDetMotivo), status_causa = '10'
							WHERE id_detalle = iContDetalle;
						END IF;

						LET iTotRegDet = iTotRegDet + 1;
						LET iTotRegLeidos = iTotRegLeidos + 1;

					END IF;

				--** SUMARIO **--
				ELIF SUBSTR(cRenglon,1,2) = "09" THEN

					LET cSeccion = 'SUMARIO';
					LET iContSumario = iContSumario + 1;
					LET cSumTipoRegistro = SUBSTR(cRenglon,1,2);
					LET cSumNumSecuencia = SUBSTR(cRenglon,3,7);
					LET cSumCodOperacion = SUBSTR(cRenglon,10,2);
					LET cSumTotalRegistros = SUBSTR(cRenglon,12,7);
					LET cSumImporte = SUBSTR(cRenglon,19,18);
					LET cSumTotalRegTruncImg = SUBSTR(cRenglon,37,7);
					LET cSumUsoFuturo = SUBSTR(cRenglon,44,300);

					IF ROUND(cSumNumSecuencia::INTEGER) <> iNroSecuencia + 1 THEN
						LET cDescIdCodRet = 'LA SECUENCIA DEL REGISTRO NO ES VÃLIDA';
						LET cCampo = '02';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'sumario: campo02 la sencuencia del registro no es valida';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cSumCodOperacion <> TRIM(pCodOperacion) THEN
						LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES CÃDIGO '||TRIM(pCodOperacion);
						LET cCampo = '03';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'sumario: campo03 el archivo a procesar no es cÃ³digo '||TRIM(pCodOperacion)||' (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF ROUND(cSumTotalRegistros::INTEGER) <> iTotRegDet THEN
						LET cDescIdCodRet = 'EL TOTAL DE REGISTROS DEL BLOQUE NO COINCIDE';
						LET cCampo = '04';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'sumario: campo04 el total de registros del bloque no coincide (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					LET mImporte = 0.00;
					LET mImporte = SUBSTR(cSumImporte,1,(LENGTH(cSumImporte)-2))||"."||SUBSTR(cSumImporte,(LENGTH(cSumImporte)-1),2);

					IF mImporte <> mTotalImporte THEN
						LET cDescIdCodRet = 'EL IMPORTE DEL BLOQUE NO COINCIDE';
						LET cCampo = '05';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'sumario: campo05 el importe del bloque no coincide (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF ROUND(cSumTotalRegTruncImg::INTEGER) <> iImagenesTrucadas THEN
						LET cDescIdCodRet = 'EL TOTAL DE IMÃGENES TRUNCADAS DEL BLOQUE NO COINCIDE';
						LET cCampo = '06';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'sumario: campo06 total imagenes truncadas del bloque no coincide (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF TRIM(cSumUsoFuturo) <> "" THEN
						LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
						LET cCampo = '07';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'sumario: campo07 uso futuro sin blancos';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					LET iTotRegDet = 0;
					LET mTotalImporte = 0.00;
					LET iImagenesTrucadas = 0;

					INSERT INTO bdicnweb:"informix".sw_cr_procesasumario_tmp(id_sumario,usuario,direccion_mac,tipo_registro,num_secuencia,cod_operacion,
					total_registros,importe,total_regtruncimg,uso_futuro,fecha_insert)
					VALUES(iContSumario,pUsuario,pDireccionMac,cSumTipoRegistro,cSumNumSecuencia,cSumCodOperacion,ROUND(cSumTotalRegistros::INTEGER),mImporte,
					ROUND(cSumTotalRegTruncImg::INTEGER),cSumUsoFuturo,pFechaHoy);

				--** GRAN SUMARIO **--
				ELIF SUBSTR(cRenglon,1,2) = "51" THEN

					LET cSeccion = 'GRAN SUMARIO';
					LET iContGranSumario = iContGranSumario + 1;

					LET cGranSumTipoRegistro = SUBSTR(cRenglon,1,2);
					LET cGranSumSentido = SUBSTR(cRenglon,3,1);
					LET cGranSumCodOperacion = SUBSTR(cRenglon,4,2);
					LET cGranSumNumOperaciones = SUBSTR(cRenglon,6,7);
					LET cGranSumNumBloques = SUBSTR(cRenglon,13,2);
					LET cGranSumNumBanco = SUBSTR(cRenglon,15,3);
					LET cGranSumFolio = SUBSTR(cRenglon,18,9);
					LET cGranSumFecha = SUBSTR(cRenglon,27,8);
					LET cGranSumImporteTotal = SUBSTR(cRenglon,35,18);
					LET cGranSumTotalRegTruncImg = SUBSTR(cRenglon,53,7);
					LET cGranSumUsoFuturo = SUBSTR(cRenglon,60,284);

					IF cGranSumSentido <> "S" THEN
						LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES DE SALIDA';
						LET cCampo = '02';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'gran sum: campo02 el archivo a procesar no es de salida';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cGranSumCodOperacion <> TRIM(pCodOperacion) THEN
						LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES CÃDIGO '||TRIM(pCodOperacion);
						LET cCampo = '03';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'gran sum: campo03 el archivo a procesar no es cÃ³digo '||TRIM(pCodOperacion)||' (linea '||iLinea||')';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cGranSumNumOperaciones::INTEGER <> iTotRegLeidos THEN
						LET cDescIdCodRet = 'EL TOTAL DE REGISTROS DEL DETALLE NO COINCIDE';
						LET cCampo = '04';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'gran sum: campo04 el total de regs del detalle no coincide';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					LET mImporte = 0.00;
					LET mImporte = SUBSTR(cGranSumImporteTotal,1,(LENGTH(cGranSumImporteTotal)-2))||"."||SUBSTR(cGranSumImporteTotal,(LENGTH(cGranSumImporteTotal)-1),2);

					IF mImporte <> mTotalImpCecoban THEN
						LET cDescIdCodRet = 'LA SUMA DE LOS IMPORTES DEL DETALLE NO COINCIDE';
						LET cCampo = '09';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'gran sum: campo09 la suma de los importes del detalle no coincide';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF cGranSumTotalRegTruncImg::INTEGER <> iTotImagenesTruncadas THEN
						LET cDescIdCodRet = 'EL TOTAL DE IMÃGENES TRUNCADAS NO COINCIDE';
						LET cCampo = '10';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'gran sum: campo10 el total de imagenes truncadas no coincide';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					IF TRIM(cGranSumUsoFuturo) <> "" THEN
						LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
						LET cCampo = '11';
						INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
						VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

						LET cTexto = 'gran sum: campo11 uso futuro sin blancos';
						INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
						VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
						dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
					END IF;

					INSERT INTO bdicnweb:"informix".sw_cr_procesagransumario_tmp(id_gransumario,usuario,direccion_mac,tipo_registro,sentido,cod_operacion,
					num_operaciones,num_bloques,num_banco,folio,fecha,importe_total,total_regtruncimg,uso_futuro,fecha_insert)
					VALUES(iContGranSumario,pUsuario,pDireccionMac,cGranSumTipoRegistro,cGranSumSentido,cGranSumCodOperacion,cGranSumNumOperaciones::INTEGER,
					cGranSumNumBloques,cGranSumNumBanco,cGranSumFolio,cGranSumFecha,mImporte,cGranSumTotalRegTruncImg::INTEGER,cGranSumUsoFuturo,pFechaHoy);

				--En otro caso
				ELIF (SUBSTR(cRenglon,1,2) <> "01" OR SUBSTR(cRenglon,1,2) <> "02" OR SUBSTR(cRenglon,1,2) <> "09" OR SUBSTR(cRenglon,1,2) <> "51") THEN

					LET cLineTrim = '';
				    LET iLongitudCad = 0;

					-- CADENA SIN ESPACIOS
					LET cLineTrim = REPLACE(cRenglon, ' ', '');
					-- LONGITUD DEL REGISTRO
					LET iLongitudCad = LENGTH(cLineTrim);


					--** ENCABEZADO **--
					IF iLongitudCad >=25 AND iLongitudCad <= 34  THEN
						LET cSeccion = 'ENCABEZADO';
						LET cTieneEncabezado = 'f';

						LET cEncTipoRegistro = SUBSTR(cRenglon,1,2);
						LET cEncNumSecuencia = SUBSTR(cRenglon,3,7);
						LET cEncNumBanco = SUBSTR(cRenglon,10,3);
						LET cEncSentidoTransfer = SUBSTR(cRenglon,13,1);
						LET cEncPlazaCecoban = SUBSTR(cRenglon,14,2);
						LET cEncServicioTei = SUBSTR(cRenglon,16,1);
						LET cEncDiaMesTransfer = SUBSTR(cRenglon,17,2);
						LET cEncNumBloque = SUBSTR(cRenglon,19,5);
						LET cEnpFechaPresenta = SUBSTR(cRenglon,24,8);
						LET cEncUsoFuturo1 = SUBSTR(cRenglon,32,9);
						LET cEncTipoArchivo = SUBSTR(cRenglon,41,1);
						LET cEncUsoFuturo2 = SUBSTR(cRenglon,42,302);

						IF cEncNumSecuencia <> "0000001" THEN
							LET cDescIdCodRet = 'LA SECUENCIA DEL REGISTRO NO ES VÃLIDA';
							LET cCampo = '02';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo02 la sencuencia del registro no es valida';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEncNumBanco <> cMiBanco THEN
							LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO CORRESPONDE A '||TRIM(cRazonSocial);
							LET cCampo = '03';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo03 el archivo a procesar no corresponde a '||TRIM(cRazonSocial);
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEncSentidoTransfer <> "S" THEN
							LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES DE SALIDA';
							LET cCampo = '04';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo04 el archivo a procesar no es de salida';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEncPlazaCecoban <> "01" THEN
							LET cDescIdCodRet = 'VALOR DIFERENTE A 01';
							LET cCampo = '05';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo05 valor diferente a 01';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEncServicioTei <> "1" THEN
							LET cDescIdCodRet = 'REGISTRO ENCABEZADO NO ES COBRO INMEDIATO M.N.';
							LET cCampo = '06';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo06 registro encabezado no es cobro inmediato m.n.';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEncDiaMesTransfer <> cDiaHoy THEN
							LET cDescIdCodRet = 'DÃA DIFERENTE AL DE PROCESO';
							LET cCampo = '07';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo07 dia diferente al de proceso';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEnpFechaPresenta <> cFormatFechaHoy THEN
							LET cDescIdCodRet = 'LA FECHA DE PRESENTACIÃN NO ES HOY';
							LET cCampo = '09';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo09 la fecha de presentaciÃ³n no es hoy';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cEncTipoArchivo <> "0" AND cEncTipoArchivo <> "1" THEN
							LET cDescIdCodRet = 'TIPO DE ARCHIVO NO ES 0 Ã 1';
							LET cCampo = '11';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo11 tipo de archivo no es 0 o 1';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF TRIM(cEncUsoFuturo2) <> "" THEN
							LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
							LET cCampo = '12';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'encabezado: campo12 uso futuro sin blancos';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						INSERT INTO bdicnweb:"informix".sw_cr_procesaencabezado_tmp(id_encabezado,usuario,direccion_mac,tipo_registro,num_secuencia,num_banco,
						sentido_transfer,plaza_cecoban,servicio_tei,diames_transfer,num_bloque,fecha_presenta,uso_futuro1,tipo_archivo,uso_futuro2,fecha_insert)
						VALUES(iContEncabezado,pUsuario,pDireccionMac,cEncTipoRegistro,cEncNumSecuencia,cEncNumBanco,cEncSentidoTransfer,cEncPlazaCecoban,
						cEncServicioTei,cEncDiaMesTransfer,cEncNumBloque,cEnpFechaPresenta,cEncUsoFuturo1,cEncTipoArchivo,cEncUsoFuturo2,pFechaHoy);

					--** DETALLE **--
					ELIF iLongitudCad >=170 AND iLongitudCad <= 215  THEN
						LET cSeccion = 'DETALLE';
						LET iNroSecuencia = iNroSecuencia + 1;
						LET cTieneDetalle = 'f';
						LET iContDetalle = iContDetalle + 1;

						-- CARACTERES INVALIDOS
						EXECUTE PROCEDURE bdicnweb:"informix".sp_validacaracter(pUsuario, pIdFuncion, cRenglon, 'L')
						INTO cIdCodRetSp, cCaracterInvalido, iPosTrama;
						IF cCaracterInvalido = 't' THEN
							LET cDescIdCodRet = 'CARACTERES INVÃLIDOS';
							LET cCampo = iPosTrama;
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: caracteres invalidos (campo '||iPosTrama||' linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						LET cDetDatosMotivoDevol = '';
						LET cDetTipoRegistro = SUBSTR(cRenglon,1,2);
						LET cDetNumSecuencia = SUBSTR(cRenglon,3,7);
						LET cDetCodOperacion = SUBSTR(cRenglon,10,2);
						LET cDetFechaTrasnfer = SUBSTR(cRenglon,12,8);
						LET cDetBancoCedente = SUBSTR(cRenglon,20,3);
						LET cDetBancoLibrado = SUBSTR(cRenglon,23,3);
						LET cDetImporte = SUBSTR(cRenglon,26,15);
						LET cDetLoteEntrada = SUBSTR(cRenglon,41,7);
						LET cDetSecEntrada = SUBSTR(cRenglon,48,4);
						LET cDetLoteSalida = SUBSTR(cRenglon,52,7);
						LET cDetSecSalida = SUBSTR(cRenglon,59,4);
						LET cDetTransaccion = SUBSTR(cRenglon,63,2);
						LET cDetPlazaCompensa = SUBSTR(cRenglon,65,3);
						LET cDetNumCuenta = SUBSTR(cRenglon,68,13);
						LET cDetNumCheque = SUBSTR(cRenglon,81,10);
						LET cDetChqDigVerInter = SUBSTR(cRenglon,91,1);
						LET cDetChqDigVerPre = SUBSTR(cRenglon,92,1);
						LET cDetChqCodSeguridad = SUBSTR(cRenglon,93,3);
						LET cDetUbicFis = SUBSTR(cRenglon,96,8);
						LET cDetTruncado = SUBSTR(cRenglon,104,1);
						LET cDetMotivoDevol = SUBSTR(cRenglon,105,2);
						LET cDetFechaInicial = SUBSTR(cRenglon,107,8);
						LET cDetPlazaIntercam = SUBSTR(cRenglon,115,2);
						LET cDetRfcCte = SUBSTR(cRenglon,117,13);
						LET cDetCurpCte = SUBSTR(cRenglon,130,18);
						LET cDetTipoCuentaDep = SUBSTR(cRenglon,148,2);
						LET cDetCuentaDeposito = SUBSTR(cRenglon,150,20);
						LET cDetNombreCte = SUBSTR(cRenglon,170,40);
						LEt cDetCtaAlertamiento = SUBSTR(cRenglon,210,2);
						LET cDetFolioSeguro = SUBSTR(cRenglon,212,12);
						LET cDetUsoFuturo = SUBSTR(cRenglon,224,120);

						LET cDetStatusCausa = '';

						IF TRIM(cDetUsoFuturo) <> "" THEN
							LET cDescIdCodRet = 'CARACTERES INVÃLIDOS';
							LET cCampo = '31';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: caracteres invalidos (campo '||cCampo||' linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						-- VALIDACIONES BASICAS
						IF ROUND(cDetNumSecuencia::INTEGER) <> iNroSecuencia THEN
							LET cDescIdCodRet = 'LA SECUENCIA DEL REGISTRO NO ES CONSECUTIVA';
							LET cCampo = '02';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: la sencuencia del registro no es consecutiva (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cDetCodOperacion <> TRIM(pCodOperacion) THEN
							LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES CÃDIGO '||TRIM(pCodOperacion);
							LET cCampo = '03';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: el archivo a procesar no es cÃ³digo '||TRIM(pCodOperacion)||' (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cDetBancoLibrado <> cMiBanco THEN
							LET cDetMotivoDevol = "06";
							LET cDetStatusCausa = "10";
						END IF;

						IF TRIM(pCodOperacion) = "46" THEN
							IF cDetFechaInicial <> cFormatFechaAnt THEN
								LET cDescIdCodRet = 'LA FECHA DE PRESENTACIÃN INICIAL NO ES HÃBIL ANTERIOR';
								LET cCampo = '22';
								INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
								VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

								LET cTexto = 'detalle: fecha de presentacion inicial no es hab ant (linea '||iLinea||')';
								INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
								VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
								dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
							END IF;
						ELSE
							IF cDetFechaInicial <> cFormatFechaHoy THEN
								LET cDescIdCodRet = 'LA FECHA PRESENTACIÃN INICIAL NO ES HOY';
								LET cCampo = '22';
								INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
								VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

								LET cTexto = 'detalle: fecha de presentacion inicial no es hoy (linea '||iLinea||')';
								INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
								VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
								dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
							END IF;
						END IF;

						IF TRIM(cDetUsoFuturo) <> "" THEN
							LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
							LET cCampo = '31';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'detalle: campo31 uso futuro sin blancos';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						LET iRegDuplicado = 0;
						IF iRegDuplicado = 0 THEN

							--LET mValorImporte = 0.00;
							LET mValorImporte = SUBSTR(cDetImporte,1,(LENGTH(cDetImporte)-2))||"."||SUBSTR(cDetImporte,(LENGTH(cDetImporte)-1),2);
							LET mTotalImporte = mTotalImporte + NVL(mValorImporte,0);
							LET mTotalImpCecoban = mTotalImpCecoban + NVL(mValorImporte,0);

							IF NVL(mValorImporte,0) > NVL(mMontoImg,0) THEN
								LET iTotImagenesTruncadas = iTotImagenesTruncadas + 1;
								LET iImagenesTrucadas = iImagenesTrucadas + 1;
							END IF;

							INSERT INTO bdicnweb:"informix".sw_cr_procesadetalle_tmp(id_detalle,usuario,direccion_mac,
							datos_nombre_archivo,datos_cod_operacion,datos_num_cuenta,datos_num_cheque,datos_motivo_devol,
							tipo_registro,num_secuencia,cod_operacion,fecha_transfer,banco_cedente,banco_librado,importe,
							lote_entrada,sec_entrada,lote_salida,sec_salida,transaccion,plaza_compensa,num_cuenta,num_cheque,
							dig_inter,dig_pre,cod_seguridad,ubic_fis,truncado,motivo_devol,fecha_inicial,plaza_intercam,
							rfc_cte,curp_cte,tipo_ctadep,cuenta_deposito,nombre_cte,cta_alertamiento,folio_seguro,uso_futuro,status_causa,fecha_insert)
							VALUES(iContDetalle,pUsuario,pDireccionMac,
							pNombreArchivo,cDetCodOperacion,cDetNumCuenta::BIGINT,cDetNumCheque::INTEGER,cDetDatosMotivoDevol,
							cDetTipoRegistro,cDetNumSecuencia,cDetCodOperacion,cDetFechaTrasnfer,cDetBancoCedente,cDetBancoLibrado,
							cDetImporte,cDetLoteEntrada,cDetSecEntrada,cDetLoteSalida,cDetSecSalida,cDetTransaccion,cDetPlazaCompensa,
							cDetNumCuenta,cDetNumCheque,cDetChqDigVerInter,cDetChqDigVerPre,cDetChqCodSeguridad,cDetUbicFis,cDetTruncado,
							cDetMotivoDevol,cDetFechaInicial,cDetPlazaIntercam,cDetRfcCte,cDetCurpCte,cDetTipoCuentaDep,
							cDetCuentaDeposito,cDetNombreCte,cDetCtaAlertamiento,cDetFolioSeguro,cDetUsoFuturo,cDetStatusCausa,pFechaHoy);

							-- STATUS FINAL
							IF cDetMotivoDevol = "00" THEN
								UPDATE bdicnweb:'informix'.sw_cr_procesadetalle_tmp SET status_causa = '01' WHERE id_detalle = iContDetalle;
							END IF;

							-- VALIDAR CÃDIGO DE SEGURIDAD, DIGITO DE PREMARCADO Y DIGITO DE INTERCAMBIO
							LET iBandaChequeValida = 0;
							LET cBLibrado = LPAD(TRIM(cDetBancoLibrado),3,'0');
							LET cSubsCuenta = cDetNumCuenta::BIGINT;
							LET cNCuenta = LPAD(TRIM(cSubsCuenta),11,'0');
							LET cCuenta = TRIM(cBLibrado) || TRIM(cNCuenta);

							-- DIGITO INTERCAMBIO
							EXECUTE PROCEDURE bdicnweb:"informix".sp_calculadigitointercambio(pUsuario, pIdFuncion, cCuenta, '10')
							INTO cIdCodRetSp, iDigitoIntercambio;

							LET iSuma = NVL(iDigitoIntercambio,0);

							IF iSuma <> cDetChqDigVerInter::INTEGER THEN
								LET iBandaChequeValida = 20;
							ELSE

								-- DIGITO PREMARCADO
								LET cPzaCompensa = LPAD(TRIM(cDetPlazaCompensa),3,'0');
								LET iDetOper = cDetTransaccion || cPzaCompensa || cBLibrado || cDetChqDigVerInter;
								LET iSuma = (cDetChqCodSeguridad::INTEGER + (iDetOper) + cDetNumCuenta::BIGINT) + cDetNumCheque::INTEGER;

								LET iDiv = CAST ((iSuma/9) AS BIGINT);
								LET iDigitoDiv = iSuma - (iDiv * 9);
								LET iDigitoDiv = 9 - iDigitoDiv;

								IF iDigitoDiv <> cDetChqDigVerPre::INTEGER THEN
									LET iBandaChequeValida = 30;
								END IF;

							END IF;

							IF iBandaChequeValida <> 0 THEN
								LET cDetMotivo = "23";
								SELECT (codigo ||" "|| descripcion) AS datos_motivo INTO cDetDatosMotivo
								FROM bdinteg:"informix".si_coddevcam
								WHERE codigo = cDetMotivo;

								UPDATE bdicnweb:"informix".sw_cr_procesadetalle_tmp
								SET datos_motivo_devol = TRIM(cDetDatosMotivo), motivo_devol = TRIM(cDetMotivo), status_causa = '10'
								WHERE id_detalle = iContDetalle;
							END IF;

							LET iTotRegDet = iTotRegDet + 1;
							LET iTotRegLeidos = iTotRegLeidos + 1;

						END IF;

					--** SUMARIO **--
					ELIF iLongitudCad >=40 AND iLongitudCad <= 46  THEN
						LET cSeccion = 'SUMARIO';
						LET cTieneSumario = 'f';

						LET cSumTipoRegistro = SUBSTR(cRenglon,1,2);
						LET cSumNumSecuencia = SUBSTR(cRenglon,3,7);
						LET cSumCodOperacion = SUBSTR(cRenglon,10,2);
						LET cSumTotalRegistros = SUBSTR(cRenglon,12,7);
						LET cSumImporte = SUBSTR(cRenglon,19,18);
						LET cSumTotalRegTruncImg = SUBSTR(cRenglon,37,7);
						LET cSumUsoFuturo = SUBSTR(cRenglon,44,300);

						IF ROUND(cSumNumSecuencia::INTEGER) <> iNroSecuencia + 1 THEN
							LET cDescIdCodRet = 'LA SECUENCIA DEL REGISTRO NO ES VÃLIDA';
							LET cCampo = '02';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'sumario: campo02 la sencuencia del registro no es valida';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cSumCodOperacion <> TRIM(pCodOperacion) THEN
							LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES CÃDIGO '||TRIM(pCodOperacion);
							LET cCampo = '03';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'sumario: campo03 el archivo a procesar no es cÃ³digo '||TRIM(pCodOperacion)||' (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF ROUND(cSumTotalRegistros::INTEGER) <> iTotRegDet THEN
							LET cDescIdCodRet = 'EL TOTAL DE REGISTROS DEL BLOQUE NO COINCIDE';
							LET cCampo = '04';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'sumario: campo04 el total de registros del bloque no coincide (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						LET mImporte = 0.00;
						LET mImporte = SUBSTR(cSumImporte,1,(LENGTH(cSumImporte)-2))||"."||SUBSTR(cSumImporte,(LENGTH(cSumImporte)-1),2);

						IF mImporte <> mTotalImporte THEN
							LET cDescIdCodRet = 'EL IMPORTE DEL BLOQUE NO COINCIDE';
							LET cCampo = '05';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'sumario: campo05 el importe del bloque no coincide (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF ROUND(cSumTotalRegTruncImg::INTEGER) <> iImagenesTrucadas THEN
							LET cDescIdCodRet = 'EL TOTAL DE IMÃGENES TRUNCADAS DEL BLOQUE NO COINCIDE';
							LET cCampo = '06';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'sumario: campo06 total imagenes truncadas del bloque no coincide (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF TRIM(cSumUsoFuturo) <> "" THEN
							LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
							LET cCampo = '07';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'sumario: campo07 uso futuro sin blancos';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						LET iTotRegDet = 0;
						LET mTotalImporte = 0.00;
						LET iImagenesTrucadas = 0;

						INSERT INTO bdicnweb:"informix".sw_cr_procesasumario_tmp(id_sumario,usuario,direccion_mac,tipo_registro,num_secuencia,cod_operacion,
						total_registros,importe,total_regtruncimg,uso_futuro,fecha_insert)
						VALUES(iContSumario,pUsuario,pDireccionMac,cSumTipoRegistro,cSumNumSecuencia,cSumCodOperacion,ROUND(cSumTotalRegistros::INTEGER),mImporte,
						ROUND(cSumTotalRegTruncImg::INTEGER),cSumUsoFuturo,pFechaHoy);

					--** GRAN SUMARIO **--
					ELIF iLongitudCad >=50 AND iLongitudCad <= 64  THEN
						LET cSeccion = 'GRAN SUMARIO';
						LET cTieneGranSumario = 'f';

						LET cGranSumTipoRegistro = SUBSTR(cRenglon,1,2);
						LET cGranSumSentido = SUBSTR(cRenglon,3,1);
						LET cGranSumCodOperacion = SUBSTR(cRenglon,4,2);
						LET cGranSumNumOperaciones = SUBSTR(cRenglon,6,7);
						LET cGranSumNumBloques = SUBSTR(cRenglon,13,2);
						LET cGranSumNumBanco = SUBSTR(cRenglon,15,3);
						LET cGranSumFolio = SUBSTR(cRenglon,18,9);
						LET cGranSumFecha = SUBSTR(cRenglon,27,8);
						LET cGranSumImporteTotal = SUBSTR(cRenglon,35,18);
						LET cGranSumTotalRegTruncImg = SUBSTR(cRenglon,53,7);
						LET cGranSumUsoFuturo = SUBSTR(cRenglon,60,284);

						IF cGranSumSentido <> "S" THEN
							LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES DE SALIDA';
							LET cCampo = '02';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'gran sum: campo02 el archivo a procesar no es de salida';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cGranSumCodOperacion <> TRIM(pCodOperacion) THEN
							LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES CÃDIGO '||TRIM(pCodOperacion);
							LET cCampo = '03';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'gran sum: campo03 el archivo a procesar no es cÃ³digo '||TRIM(pCodOperacion)||' (linea '||iLinea||')';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cGranSumNumOperaciones::INTEGER <> iTotRegLeidos THEN
							LET cDescIdCodRet = 'EL TOTAL DE REGISTROS DEL DETALLE NO COINCIDE';
							LET cCampo = '04';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'gran sum: campo04 el total de regs del detalle no coincide';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						LET mImporte = 0.00;
						LET mImporte = SUBSTR(cGranSumImporteTotal,1,(LENGTH(cGranSumImporteTotal)-2))||"."||SUBSTR(cGranSumImporteTotal,(LENGTH(cGranSumImporteTotal)-1),2);

						IF mImporte <> mTotalImpCecoban THEN
							LET cDescIdCodRet = 'LA SUMA DE LOS IMPORTES DEL DETALLE NO COINCIDE';
							LET cCampo = '09';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'gran sum: campo09 la suma de los importes del detalle no coincide';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF cGranSumTotalRegTruncImg::INTEGER <> iTotImagenesTruncadas THEN
							LET cDescIdCodRet = 'EL TOTAL DE IMÃGENES TRUNCADAS NO COINCIDE';
							LET cCampo = '10';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'gran sum: campo10 el total de imagenes truncadas no coincide';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						IF TRIM(cGranSumUsoFuturo) <> "" THEN
							LET cDescIdCodRet = 'USO FUTURO SIN BLANCOS';
							LET cCampo = '11';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'gran sum: campo11 uso futuro sin blancos';
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
						END IF;

						INSERT INTO bdicnweb:"informix".sw_cr_procesagransumario_tmp(id_gransumario,usuario,direccion_mac,tipo_registro,sentido,cod_operacion,
						num_operaciones,num_bloques,num_banco,folio,fecha,importe_total,total_regtruncimg,uso_futuro,fecha_insert)
						VALUES(iContGranSumario,pUsuario,pDireccionMac,cGranSumTipoRegistro,cGranSumSentido,cGranSumCodOperacion,cGranSumNumOperaciones::INTEGER,
						cGranSumNumBloques,cGranSumNumBanco,cGranSumFolio,cGranSumFecha,mImporte,cGranSumTotalRegTruncImg::INTEGER,cGranSumUsoFuturo,pFechaHoy);
					END IF;


				END IF;

				IF cTieneEncabezado = 'f' OR cTieneDetalle = 'f' OR cTieneSumario = 'f' OR cTieneGranSumario = 'f' THEN
					LET cDescIdCodRet = 'EL ARCHIVO DE DATOS NO TIENE EL FORMATO CORRECTO, VERIFIQUE';
					LET cSeccion = '';
					LET cCampo = '';

					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

					LET cTexto = 'el archivo de datos no tiene encabezado/detalle/sumario/gran sumario, verifique';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;

				LET cTieneEncabezado = 't';
				LET cTieneDetalle = 't';
				LET cTieneSumario = 't';
				LET cTieneGranSumario = 't';

			END FOREACH;

			IF ROUND(cGranSumNumBloques::INTEGER) <> iContEncabezado OR ROUND(cGranSumNumBloques::INTEGER) <> iContSumario OR iContSumario <> iContEncabezado OR iContGranSumario = 0 THEN
				LET cDescIdCodRet = 'EL ARCHIVO DE DATOS NO TIENE EL FORMATO CORRECTO, VERIFIQUE';
				LET cSeccion = '';
				LET cCampo = '';

				INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
				VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

				LET cTexto = 'el archivo de datos no tiene encabezado/detalle/sumario/gran sumario, verifique';
				INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
				VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
				dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
			END IF;

			IF TRIM(pCodOperacion) = "40" THEN
				FOREACH
					SELECT id_detalle,datos_num_cuenta,datos_num_cheque,motivo_devol INTO iIdReg,cCta,iNumchq,cDevol
					FROM bdicnweb:"informix".sw_cr_procesadetalle_tmp WHERE usuario = pUsuario
					AND direccion_mac = pDireccionMac AND datos_nombre_archivo = pNombreArchivo

					IF cDevol = '00' THEN
						EXECUTE PROCEDURE bditef:"informix".stat_cheque(cEmpresa,TRIM(cCta),iNumchq)
						INTO cIdCodRetsp, cMotDevol40;

						IF cIdCodRetSp = '000' THEN
							IF cMotDevol40 <> '00' THEN
								LET cDetMotivo = cMotDevol40;
								SELECT (codigo ||" "|| descripcion) AS datos_motivo INTO cDetDatosMotivo
								FROM bdinteg:"informix".si_coddevcam
								WHERE codigo = cDetMotivo;

								UPDATE bdicnweb:"informix".sw_cr_procesadetalle_tmp
								SET datos_motivo_devol = TRIM(cDetDatosMotivo), motivo_devol = TRIM(cDetMotivo), status_causa = '10'
								WHERE id_detalle = iIdReg;
							END IF;
						ELIF cIdCodRetSp <> '000' THEN
							ROLLBACK WORK; --
							LET ven_transacc = 0;
							LET cIdCodRet = '666'; --

							LET cConcatMsn = TRIM(cIdCodRetSp)||' '||cDetNumCuenta::INTEGER||' '||cDetNumCheque::INTEGER;
							LET cDescIdCodRet = 'ERROR AL VALIDAR STAT CUENTA/CHEQUE CÃDIGO DE RETORNO: '||TRIM(cConcatMsn);
							LET cSeccion = '';
							LET cCampo = '';
							INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerror(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
							VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);

							LET cTexto = 'error al validar stat cuenta/cheque codret '||TRIM(cConcatMsn);
							INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
							VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
							dhora,TRIM(pCodOperacion),'M',TRIM(cTexto),pUsuario,pFechaHoy,'02');

							UPDATE bdicnweb:"informix".sw_cr_procesadetalle_tmp
							SET datos_motivo_devol = TRIM(cIdCodRetSp)
							WHERE id_detalle = iIdReg;
						END IF;
					END IF;
				END FOREACH;
			END IF;

			IF TRIM(pCodOperacion) = "46" THEN

				FOREACH
					SELECT id_detalle,datos_num_cuenta,datos_num_cheque,datos_motivo_devol,fecha_inicial INTO iIdReg,cCta,iNumchq,cMotivo,pFechaOrigen
					FROM bdicnweb:"informix".sw_cr_procesadetalle_tmp WHERE usuario = pUsuario
					AND direccion_mac = pDireccionMac AND datos_nombre_archivo = pNombreArchivo

					LET cError46 = 'f';
					--FOREACH
						SELECT mot_devol,status INTO cMotDevol46,cStatus46
						FROM bditef:"informix".cce_propios_det
						WHERE cod_operacion = '40' AND c_cuenta = TRIM(cCta)
						AND c_cheque = iNumchq AND fecha_presini = TRIM(pFechaOrigen);

						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							UPDATE bdicnweb:"informix".sw_cr_procesadetalle_tmp
							SET datos_motivo_devol = 'ERR NO EXISTE EL REGISTRO COD 40', bandera_color = 'R'
							WHERE id_detalle = iIdReg;
							LET cError46 = 't';
						ELSE
							IF cStatus46 = '07' OR cStatus46 = '04' OR cMotDevol46 <> '00' THEN
								UPDATE bdicnweb:"informix".sw_cr_procesadetalle_tmp
								SET datos_motivo_devol = 'ERR YA DEVUELTO/ELIMINADO/REVERSADO', bandera_color = 'R'
								WHERE id_detalle = iIdReg;
								LET cError46 = 't';
							ELSE
								LET cDetMotivo = cMotivo;
								SELECT (codigo ||" "|| descripcion) AS datos_motivo INTO cDetDatosMotivo
								FROM bdinteg:"informix".si_coddevcam
								WHERE codigo = cDetMotivo;

								UPDATE bdicnweb:"informix".sw_cr_procesadetalle_tmp
								SET datos_motivo_devol = TRIM(cDetDatosMotivo), status_causa = '07'
								WHERE id_detalle = iIdReg;
							END IF;
						END IF;
					--END FOREACH;
				END FOREACH;
			END IF;

		COMMIT WORK; --

		IF cDescIdCodRet <> '' THEN
			LET cBanDetError  = 't';
		END IF;
		IF cError46 = 't' THEN
			LET cMuestraMsn = 't'; --ALGUNOS REGISTROS REVERSADOS NO PROCESARÃN SU CÃDIGO 40
		END IF;

		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;

		SET LOCK MODE TO WAIT 3;
		UPDATE bdicnweb:"informix".sw_cr_statuslecturaarchivos
		SET  status = 'T', error_proceso = 'N', bandera_det_error = TRIM(UPPER(cBanDetError)), muestra_msn = TRIM(UPPER(cMuestraMsn))
		WHERE usuario = TRIM(pUsuario) AND tipo_proceso = 'LECTURA' AND archivo = TRIM(pNombreArchivo);

		LET cLecturaArchivoDatos = 't';
		RETURN cCodRet,cBanDetError,cMuestraMsn;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos',
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n de informaciÃ³n y la carga de datos a tablas temporales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallearchcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 	CHAR(5) AS codret,
				 	CHAR(22) AS datos_nombre_archivo,
					CHAR(2) AS datos_cod_operacion,
					CHAR(22) AS datos_num_cuenta,
					INTEGER AS datos_num_cheque,
					CHAR(50) AS datos_motivo_devol,
					MONEY(14,2) AS importe;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cNumCuenta CHAR(22);
	DEFINE iNumCheque INTEGER;
	DEFINE cMotivoDev CHAR(50);
	DEFINE cImporte CHAR(15);
	DEFINE mImporte MONEY(14,2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET cCodOperacion ='';
	LET cNumCuenta = '';
	LET iNumCheque = 0;
	LET cMotivoDev = '';
	LET cImporte = '';
	LET mImporte = 0.00;
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallearchcecoban.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR	pFechaHoy IS NULL OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte; 
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
	
		FOREACH
			SELECT {+INDEX (bdicnweb:"informix".sw_cr_procesadetalle_tmp idx_sw_cr_procesadetalle_tmp )}
			SKIP pRegistros FIRST pRecuperacion datos_nombre_archivo,datos_cod_operacion,datos_num_cuenta,datos_num_cheque,
			datos_motivo_devol,importe
			INTO cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,cImporte
			FROM bdicnweb:"informix".sw_cr_procesadetalle_tmp 
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) 
			AND fecha_insert = pFechaHoy

			LET mImporte = SUBSTR(cImporte,1,(LENGTH(cImporte)-2))||"."||SUBSTR(cImporte,(LENGTH(cImporte)-1),2);
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,UPPER(TRIM(cNombreArchivo)),TRIM(cCodOperacion),TRIM(cNumCuenta),iNumCheque,UPPER(TRIM(cMotivoDev)),NVL(mImporte,0) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '10001';
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catarchivoimportar(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS cod_operacion,
			CHAR(100) AS desc_archivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodOperacion CHAR(5);
	DEFINE cDescArchivo CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodOperacion = '';
	LET cDescArchivo = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodOperacion, cDescArchivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catarchivoimportar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodOperacion, cDescArchivo;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodOperacion, cDescArchivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		FOREACH
			SELECT {+INDEX (bdicnweb:"informix".sw_cr_tipoarchivo idx_codigo_desc_archivo )}
			codigo_operacion, decripcion_archivo
			INTO cCodOperacion, cDescArchivo
			FROM bdicnweb:"informix".sw_cr_tipoarchivo
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, TRIM(cCodOperacion), UPPER(TRIM(cDescArchivo)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodOperacion, cDescArchivo;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 28/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el tipo de archivo a importar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validarchivoimportar(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pCodOperacion CHAR(5), pFecha DATE)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanco CHAR(3);
	DEFINE cArchivo CHAR(22);
	DEFINE cPrefijoArch CHAR(20);
	DEFINE cArchInvalido CHAR(1);
	DEFINE cFechaConsulta CHAR(10);
	DEFINE cDiaArch CHAR(2);
	DEFINE iCountArch INTEGER;
	
	DEFINE cProcesoDatos CHAR(1);
	DEFINE cProcesoImg CHAR(1);
	DEFINE iRecuperacion INTEGER;
    --Nuevo
    DEFINE cCmd1 CHAR(1000);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cBanco = '';
	LET cArchivo = '';
	LET cPrefijoArch = '';
	LET cArchInvalido = '';
	LET cFechaConsulta = '';
	LET cDiaArch = '';
	LET iCountArch = 0;
	
	LET cProcesoDatos = '';
	LET cProcesoImg = '';
	LET iRecuperacion = 0;
    --Nuevo
    LET cCmd1 = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validarchivoimportar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pCodOperacion = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- N?mero de banco propio
		SELECT valor INTO cBanco 
		FROM bdinteg:"informix".si_param WHERE empresa = '001' AND cod_param = '5';
		
		LET cFechaConsulta = pFecha;
		LET cDiaArch = SUBSTRING(cFechaConsulta FROM 4 FOR 2);
			
		IF TRIM(pCodOperacion) IN ('40-1','40-2','46','47') THEN
			
			LET cArchivo = SUBSTRING(TRIM(pNombreArchivo) FROM 1 FOR 14);
			
			IF TRIM(pCodOperacion) = '40-1' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.APR'||cDiaArch;			
			ELIF TRIM(pCodOperacion) = '40-2' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.APD'||cDiaArch;
			ELIF TRIM(pCodOperacion) = '46' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.ARP'||cDiaArch;			
			ELIF TRIM(pCodOperacion) = '47' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.AEP'||cDiaArch;
			END IF;		
			
			IF UPPER(cArchivo) <> UPPER(TRIM(cPrefijoArch)) THEN 
				LET cArchInvalido = 'T';
			END IF;	
		
		ELIF TRIM(pCodOperacion) = 'IMG' THEN
		
			LET cArchivo = SUBSTRING(TRIM(pNombreArchivo) FROM 1 FOR 13);
			LET cPrefijoArch = 'SAI'||TRIM(cBanco)||'A1.AI'||cDiaArch;
		
			IF UPPER(cArchivo) <> UPPER(TRIM(cPrefijoArch)) THEN 
				LET cArchInvalido = 'T';
			END IF;
			
		END IF;
		
		IF cArchInvalido = 'T' THEN 
			LET cCodRet = '00481'; 
			RETURN cCodRet;
		END IF;
		 
		-- Valida que exista el 1er archivo de presentaciÃ³n cÃ³digo 40
		IF TRIM(pCodOperacion) = '47' THEN
			--LET cDiaArch = TO_CHAR(cDiaArch::INTEGER - 1);
            LET cPrefijoArch = '''%'||'S01'||TRIM(cBanco)||'A1.APR'||cDiaArch||'%''';
            LET cCmd1 = "";
            LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT COUNT(*) ";
            LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bditef:informix.cce_archivos_ctl ";
            LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE nombrearchivo LIKE "||cPrefijoArch||" AND fecha_entrada <= '"||pFecha||"' AND procesado IN ('0','1')";
            
            PREPARE stmtId FROM TRIM(cCmd1);
            DECLARE selectQryCur CURSOR FOR stmtId;
            OPEN selectQryCur;
            FETCH selectQryCur INTO iCountArch;

			IF iCountArch = 0 THEN
				LET cCodRet = '00792'; --NO HA SIDO CARGADO UN ARCHIVO CÃDIGO 40 PARA HOY, VERIFIQUE
				RETURN cCodRet;
			END IF;
		END IF;
		
		-- Valida el archivo
		SELECT COUNT(*) INTO iCountArch
		FROM bditef:"informix".cce_archivos_ctl
        WHERE nombrearchivo = UPPER(TRIM(pNombreArchivo))
        AND fecha_entrada = pFecha
        AND procesado IN ('0','1');
		
		IF iCountArch <> 0 THEN
			LET cCodRet = '00793'; --ESTE ARCHIVO YA FUE PROCESADO PARA HOY, VERIFIQUE
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Le?n Amador',
'FECHA: 29/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n del archivo a importar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_recibedatosarchivoimagenes(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEntrada CHAR(1), pNombreArchivo CHAR(22), 
pIdRegistro CHAR(2), pBloqueArchivo CHAR(117), pNroSecuencia INTEGER, pDireccionMac CHAR(12), pFechaHoy DATE)
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cIdCodRet CHAR(5);
	DEFINE cDescIdCodRet CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE cDescMensajeError CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cSeccion CHAR(12);
	DEFINE cCampo CHAR(2);
	DEFINE cTexto CHAR(100);
	DEFINE cBloqueArchivo CHAR(117);
	DEFINE cEncTipoRegistro CHAR(2);
	DEFINE cEncNumSecuencia CHAR(7); 
	DEFINE cEncVersion CHAR(3);
	DEFINE cEncCodOperacion CHAR(2);
	DEFINE cEncBancoPresenta CHAR(3);
	DEFINE cEncSentido CHAR(1);
	DEFINE cEncMoneda CHAR(1);
	DEFINE cEncNumBloque CHAR(7);
	DEFINE cEncFechaProceso CHAR(8);
	DEFINE cEncUsoFuturo CHAR(83);
	DEFINE iContEncabezado INTEGER;
	DEFINE cDetTipoRegistro CHAR(2);
	DEFINE cDetNumSecuencia CHAR(7);
	DEFINE cDetCodOperacion CHAR(2);
	DEFINE cDetFechaProceso CHAR(8);
	DEFINE cDetBancoPresenta CHAR(3);
	DEFINE cDetMoneda CHAR(1);
	DEFINE cDetCodSeguridad CHAR(3);
	DEFINE cDetDigPremar CHAR(1);
	DEFINE cDetClaveTrans CHAR(2);
	DEFINE cDetPlazaCompensa CHAR(3);
	DEFINE cDetBancoLibrado CHAR(3);
	DEFINE cDetDigInter CHAR(1);
	DEFINE cDetNumCuenta CHAR(13);
	DEFINE cDetNumCheque CHAR(10);
	DEFINE cDetImporte CHAR(15);
	DEFINE cDetUsoFuturo CHAR(13);
	DEFINE cDetTamImgAnverso CHAR(15);
	DEFINE cDetTamImgReverso CHAR(15);
	DEFINE iContDetalle INTEGER;
	DEFINE cSumTipoRegistro CHAR(2);
	DEFINE cSumNumSecuencia CHAR(7);						
	DEFINE cSumTotalRegistros CHAR(9);						
	DEFINE cSumTotalImporte CHAR(16);
	DEFINE cSumUsoFuturo CHAR(83);
	DEFINE iContSumario INTEGER;
	DEFINE iTamImgF BIGINT;
	DEFINE cTamImgF CHAR(11);
	DEFINE iTamImgT BIGINT;
	DEFINE cTamImgT CHAR(11);
	DEFINE cCuenta CHAR(11);
	DEFINE cCheque CHAR(7);
	DEFINE cArchivo CHAR(21);
	DEFINE cCarpetaImgCecoban CHAR(17);
	DEFINE cArchivoImgF CHAR(44);
	DEFINE cArchivoImgT CHAR(44);
	DEFINE iTotImagenesCecoban INTEGER;
	DEFINE mValorImporte MONEY(14,2);
	DEFINE mTotImporteCecoban MONEY(14,2);
	DEFINE mTotalImporte MONEY(14,2);
	DEFINE bBanderaError CHAR(1);
	DEFINE cMiBanco CHAR(3);
	DEFINE cRazonSocial CHAR(30);
	DEFINE dHora DATETIME HOUR TO SECOND;
	DEFINE cFormatFechaHoy CHAR(8);
	DEFINE mMontoImg MONEY(14,2);
	DEFINE iPosInicial INTEGER;
    DEFINE iNroSecuencia INTEGER;
    DEFINE cTieneEncabezado CHAR(1);
    DEFINE cTieneDetalle CHAR(1);
    DEFINE cTieneSumario CHAR(1);
    DEFINE cTieneGranSumario CHAR(1);
	DEFINE cExtractorImagenes CHAR(1);
	DEFINE cBanDetError CHAR(1);
	
	LET cCodRet = '00000';
	LET cIdCodRet = '00000';
	LET cDescIdCodRet = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET cDescMensajeError = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cSeccion = '';
	LET cCampo = '';
	LET cTexto = '';
	LET cBloqueArchivo = '';
	LET cEncTipoRegistro = '';
	LET cEncNumSecuencia = '';
	LET cEncVersion = '';
	LET cEncCodOperacion = '';
	LET cEncBancoPresenta = '';
	LET cEncSentido = '';
	LET cEncMoneda = '';
	LET cEncNumBloque = '';
	LET cEncFechaProceso = '';
	LET cEncUsoFuturo = '';
	LET iContEncabezado = 0;
	LET cDetTipoRegistro = '';
	LET cDetNumSecuencia = '';						
	LET cDetCodOperacion = '';						
	LET cDetFechaProceso = ''; 						
	LET cDetBancoPresenta = '';
	LET cDetMoneda = '';
	LET cDetCodSeguridad = '';
	LET cDetDigPremar = '';
	LET cDetClaveTrans = '';
	LET cDetPlazaCompensa = '';
	LET cDetBancoLibrado = '';
	LET cDetDigInter = '';
	LET cDetNumCuenta = '';
	LET cDetNumCheque = '';
	LET cDetImporte = '';
	LET cDetUsoFuturo = '';
	LET cDetTamImgAnverso = '';
	LET cDetTamImgReverso = '';
	LET iContDetalle = 0;
	LET cSumTipoRegistro = '';
	LET cSumNumSecuencia = '';						
	LET cSumTotalRegistros = '';						
	LET cSumTotalImporte = '';
	LET cSumUsoFuturo = '';
	LET iContSumario = 0;
	LET iTamImgF = 0;
	LET cTamImgF = '';
	LET iTamImgT = 0;
	LET cTamImgT = '';
	LET cCuenta = '';
	LET cCheque = '';
	LET cArchivo = '';
	LET cCarpetaImgCecoban = '\tempo_imgcecoban';
	LET cArchivoImgF = '';
	LET cArchivoImgT = '';
	LET iTotImagenesCecoban = 0;
	LET mValorImporte = 0.00;
	LET mTotImporteCecoban = 0.00;
	LET mTotalImporte = 0.00;
	LET bBanderaError = 'f';
	LET cMiBanco = '';
	LET cRazonSocial = '';
	LET dHora = '';
	LET cFormatFechaHoy = '';
	LET mMontoImg = 0.00;
	LET iPosInicial = 0;
    LET iNroSecuencia = 0;
	LET cTieneEncabezado = 'f';
    LET cTieneDetalle = 'f';
    LET cTieneSumario = 'f';
    LET cTieneGranSumario = 'f';
	LET cExtractorImagenes = 'f';	
	LET cBanDetError = 'f';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cBanDetError;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_recibedatosarchivoimagenes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEntrada = '' OR pNombreArchivo = '' OR pIdRegistro = '' OR pBloqueArchivo = '' OR pNroSecuencia IS NULL
		OR pDireccionMac = '' OR pFechaHoy IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cBanDetError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cBanDetError;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
		--Limpia cuando se ejecuta por 1ra vez
		IF pIdEntrada = '1' THEN
		
			DROP TABLE IF EXISTS cr_cargaimagenes_tmp;
			
			CREATE TEMP TABLE cr_cargaimagenes_tmp (
			id_serial SERIAL NOT NULL PRIMARY KEY,
			linea CHAR(400)
			)
			WITH NO LOG;

			-- LIMPIA TABLAS
			DELETE FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
			DELETE FROM bdicnweb:"informix".sw_cr_procesaencabezadoimg_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
			DELETE FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
			DELETE FROM bdicnweb:"informix".sw_cr_procesasumarioimg_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
		END IF;
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
		-- RAZï¿½N SOCIAL
		SELECT razon_social INTO cRazonSocial FROM bdinteg:"informix".si_empresas WHERE empresa = cEmpresa;
		-- VALOR IMPORTE PARA ENVIO DE IMAGEN A CECOBAN
		SELECT valor INTO mMontoImg FROM bditef:"informix".cce_param WHERE empresa = cEmpresa AND cod_param = '2';
		
		LET cFormatFechaHoy = SUBSTR(pFechaHoy,7,4) || SUBSTR(pFechaHoy,1,2) || SUBSTR(pFechaHoy,4,2);
		LET dHora = CURRENT;
		
		--LET iLinea = iLinea + 1;
		LET iLinea = NVL(pNroSecuencia,0) + 1; --(entra con 0 en la primera ejecuciï¿½n, el conteo incrementa en 1 para las siguientes ejecuciones)
		
		IF pIdRegistro = '01' THEN
		
			IF SUBSTR(pBloqueArchivo,1,2) <> '01' THEN
				LET cDescIdCodRet = 'EL ARCHIVO DE IMAGENES NO TIENE ENCABEZADO, VERIFIQUE';
				LET cSeccion = '';
				LET cCampo = '01';
				INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
				VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
				
				LET cTexto = 'el archivo de imagenes no tiene encabezado, verifique';
				INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
				VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
				dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
			END IF;
			
			--** ENCABEZADO **--
			
				LET cSeccion = 'ENCABEZADO';
				LET cTieneEncabezado = 't';
				LET iContEncabezado = iContEncabezado + 1;

				LET cEncTipoRegistro = SUBSTR(pBloqueArchivo,1,2);
				LET cEncNumSecuencia = SUBSTR(pBloqueArchivo,3,7);
				LET cEncVersion = SUBSTR(pBloqueArchivo,10,3);
				LET cEncCodOperacion = SUBSTR(pBloqueArchivo,13,2);
				LET cEncBancoPresenta = SUBSTR(pBloqueArchivo,15,3);
				LET cEncSentido = SUBSTR(pBloqueArchivo,18,1);
				LET cEncMoneda = SUBSTR(pBloqueArchivo,19,1);
				LET cEncNumBloque = SUBSTR(pBloqueArchivo,20,7);
				LET cEncFechaProceso = SUBSTR(pBloqueArchivo,27,8);
				LET cEncUsoFuturo = SUBSTR(pBloqueArchivo,35,83); --= 118
				
				IF cEncBancoPresenta <> cMiBanco THEN
					LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO CORRESPONDE A '||TRIM(cRazonSocial);
					LET cCampo = '05';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el archivo a procesar no corresponde a '||TRIM(cRazonSocial);
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
	
				IF cEncSentido <> "S" THEN
					LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES DE SALIDA';
					LET cCampo = '06';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el archivo a procesar no es de salida';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cEncMoneda <> "1" THEN
					LET cDescIdCodRet = 'REGISTRO ENCABEZADO NO ES MONEDA NACIONAL';
					LET cCampo = '07';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'registro encabezado no es moneda nacional';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cEncFechaProceso <> cFormatFechaHoy THEN
					LET cDescIdCodRet = 'LA FECHA DE PRESENTACION DEL ARCHIVO NO CORRESPONDE A LA FECHA DE PROCESO';
					LET cCampo = '09';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'la fecha de presentacion del archivo no corresponde a la fecha de proceso';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				INSERT INTO bdicnweb:"informix".sw_cr_procesaencabezadoimg_tmp(id_encabezado,usuario,direccion_mac,tipo_registro,num_secuencia,
				version,cod_operacion,banco_presenta,sentido,moneda,num_bloque,fecha_proceso,uso_futuro,fecha_insert)
				VALUES(iContEncabezado,pUsuario,pDireccionMac,cEncTipoRegistro,cEncNumSecuencia,
				cEncVersion,cEncCodOperacion,cEncBancoPresenta,cEncSentido,cEncMoneda,cEncNumBloque,cEncFechaProceso,cEncUsoFuturo,pFechaHoy);
			
		ELIF pIdRegistro = '02' THEN
			
			--** DETALLE **--
				
				LET cSeccion = 'DETALLE';
				LET cTieneDetalle = 't';
				LET iNroSecuencia = NVL(pNroSecuencia,0) + 1; --(entra con 1 en la primera ejecuciï¿½n)
				
				SELECT NVL(MAX(id_detalle),0)+1 INTO iContDetalle FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
				WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;

				LET cDetTipoRegistro = SUBSTR(pBloqueArchivo,1,2);
				LET cDetNumSecuencia = SUBSTR(pBloqueArchivo,3,7);						
				LET cDetCodOperacion = SUBSTR(pBloqueArchivo,10,2);						
				LET cDetFechaProceso = SUBSTR(pBloqueArchivo,12,8); 						
				LET cDetBancoPresenta = SUBSTR(pBloqueArchivo,20,3);
				LET cDetMoneda = SUBSTR(pBloqueArchivo,23,1);
				LET cDetCodSeguridad = SUBSTR(pBloqueArchivo,24,3);
				LET cDetDigPremar = SUBSTR(pBloqueArchivo,27,1);
				LET cDetClaveTrans = SUBSTR(pBloqueArchivo,28,2);
				LET cDetPlazaCompensa = SUBSTR(pBloqueArchivo,30,3);
				LET cDetBancoLibrado = SUBSTR(pBloqueArchivo,33,3);
				LET cDetDigInter = SUBSTR(pBloqueArchivo,36,1);
				LET cDetNumCuenta = SUBSTR(pBloqueArchivo,37,13);
				LET cDetNumCheque = SUBSTR(pBloqueArchivo,50,10);
				LET cDetImporte = SUBSTR(pBloqueArchivo,60,15);
				LET cDetUsoFuturo = SUBSTR(pBloqueArchivo,75,13);
				LET cDetTamImgAnverso = SUBSTR(pBloqueArchivo,88,15);
				LET cDetTamImgReverso = SUBSTR(pBloqueArchivo,103,15); --= 118
				
				IF ROUND(cDetNumSecuencia::INTEGER) <> iNroSecuencia THEN
					LET cDescIdCodRet = 'EL NUMERO DE SECUENCIA EN EL REGISTRO '||iNroSecuencia||' NO CORRESPONDE, VERIFIQUE';
					LET cCampo = '02';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el nro de secuencia en el registro '||iNroSecuencia||' no corresponde, verifique';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cDetFechaProceso <> cFormatFechaHoy THEN
					LET cDescIdCodRet = 'LA FECHA DE PRESENTACION DEL ARCHIVO NO CORRESPONDE A LA FECHA DE PROCESO';
					LET cCampo = '04';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'la fecha de presentacion del archivo no corresponde a la fecha de proceso';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cDetBancoLibrado <> cMiBanco THEN
					LET cDescIdCodRet = 'EL REGISTRO A PROCESAR NO CORRESPONDE A '||TRIM(cRazonSocial);
					LET cCampo = '11';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el registro a procesar no corresponde a '||TRIM(cRazonSocial);
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
		
				LET mValorImporte = 0.00;
				LET mValorImporte = SUBSTR(cDetImporte,1,(LENGTH(cDetImporte)-2))||"."||SUBSTR(cDetImporte,(LENGTH(cDetImporte)-1),2);
			    
				LET cCuenta = cDetNumCuenta::BIGINT;
				LET cCheque = cDetNumCheque::INTEGER;
				LET cArchivo = LPAD(TRIM(cDetBancoLibrado),3,'0')||LPAD(TRIM(cCuenta),11,'0')||LPAD(TRIM(cCheque),7,'0');
				LET cArchivoImgF = TRIM(cArchivo)||'F.tif';
				LET cArchivoImgT = TRIM(cArchivo)||'T.tif';
				LET cTamImgF = cDetTamImgAnverso::BIGINT;
				LET cTamImgT = cDetTamImgReverso::BIGINT;
			
				INSERT INTO bdicnweb:"informix".sw_cr_procesadetalleimg_tmp(id_detalle,usuario,direccion_mac,
				datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,datos_importe,
				datos_archivo_imgf,datos_archivo_imgt,datos_tamanio_imgf,datos_tamanio_imgt,datos_carga_imgf,datos_carga_imgt,
				tipo_registro,num_secuencia,cod_operacion,fecha_proceso,banco_presenta,moneda,cod_seguridad,
				dig_pre,clave_transfer,plaza_compensa,banco_librado,dig_inter,num_cuenta,num_cheque,importe,
				uso_futuro,tam_img_anv,tam_img_rev,bandera_color,fecha_insert)
				VALUES(iContDetalle,pUsuario,pDireccionMac,
				pNombreArchivo,cDetNumCuenta::BIGINT,cDetNumCheque::INTEGER,mValorImporte,
				cArchivoImgF,cArchivoImgT,cTamImgF,cTamImgT,'0','0',
				cDetTipoRegistro,cDetNumSecuencia,cDetCodOperacion,cDetFechaProceso,cDetBancoPresenta,cDetMoneda,cDetCodSeguridad,
				cDetDigPremar,cDetClaveTrans,cDetPlazaCompensa,cDetBancoLibrado,cDetDigInter,cDetNumCuenta,cDetNumCheque,cDetImporte,
				cDetUsoFuturo,cDetTamImgAnverso,cDetTamImgReverso,'',pFechaHoy);
		
		ELIF pIdRegistro = '09' THEN
		
			--** SUMARIO **--
				
				LET cSeccion = 'SUMARIO';
				LET cTieneSumario = 't';
				LET iContSumario = iContSumario + 1;
				
				LET cSumTipoRegistro = SUBSTR(pBloqueArchivo,1,2);
				LET cSumNumSecuencia = SUBSTR(pBloqueArchivo,3,7);											
				LET cSumTotalRegistros = SUBSTR(pBloqueArchivo,10,9); 						
				LET cSumTotalImporte = SUBSTR(pBloqueArchivo,19,16);
				LET cSumUsoFuturo = SUBSTR(pBloqueArchivo,35,83); --= 118
				
				LET mTotalImporte = 0.00;
				LET mTotalImporte = SUBSTR(cSumTotalImporte,1,(LENGTH(cSumTotalImporte)-2))||"."||SUBSTR(cSumTotalImporte,(LENGTH(cSumTotalImporte)-1),2);
				
				SELECT SUM(datos_importe) INTO mTotImporteCecoban FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
				WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
				
				IF mTotalImporte <> mTotImporteCecoban THEN
					LET cDescIdCodRet = 'IMPORTE TOTAL DEL ARCHIVO DE IMAGENES Y EL CARGADO DIFIERE';
					LET cCampo = '04';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'importe total del archivo de imagenes y el cargado difiere';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				INSERT INTO bdicnweb:"informix".sw_cr_procesasumarioimg_tmp(id_sumario,usuario,direccion_mac,
				tipo_registro,num_secuencia,total_registros,importe,uso_futuro,fecha_insert)
				VALUES(iContSumario,pUsuario,pDireccionMac,cSumTipoRegistro,cSumNumSecuencia,cSumTotalRegistros,
				cSumTotalImporte,cSumUsoFuturo,pFechaHoy);
		
		END IF;
	
		IF EXISTS (SELECT mensaje_error FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg 
		WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy) THEN
			LET cBanDetError  = 't';
		END IF;
		
		LET cExtractorImagenes = 't';
		RETURN cCodRet,cBanDetError; 
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 07/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciï¿½n de informaciï¿½n correspondiente a las imï¿½genes y la carga de datos a tablas temporales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validacaracter(pUsuario CHAR(8), pIdFuncion CHAR(10), pCadena CHAR(500), pTipoCompara CHAR(1))
		RETURNING CHAR(5) AS codret,                       
			CHAR(1) AS caracter_invalido,
			INTEGER AS posicion_trama;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;	
	DEFINE cTamCadena CHAR(500);
	DEFINE iPos INTEGER;
	DEFINE cComparaCadena CHAR(65);
	DEFINE cCaracter CHAR(1);
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE bPositionFind boolean;
	DEFINE iPosTrama INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTamCadena = '';
	LET iPos = 0;
	LET cComparaCadena = '';
	LET cCaracter = '';
	LET cCaracterInvalido = 'f';
	LET bPositionFind = 'f';
	LET iPosTrama = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCaracterInvalido, iPosTrama;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validacaracter.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCadena = '' OR pTipoCompara = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCaracterInvalido, iPosTrama;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCaracterInvalido, iPosTrama;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- CARACTERES INVALIDOS		
		LET cTamCadena = LENGTH(pCadena) - 1;
		LET iPos = 1;
		
		IF UPPER(pTipoCompara) = 'N' THEN
			LET cComparaCadena = '0123456789';
		ELIF UPPER(pTipoCompara) = 'L' THEN
			LET cComparaCadena = ' !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\_ÃÃÃÃÃÃÂ¿Â¡';
		END IF;
		
		WHILE (iPos <= cTamCadena::INTEGER) LOOP
			
			LET cCaracter = UPPER(SUBSTR(TRIM(pCadena),iPos,1));
			
			IF INSTR(TRIM(cComparaCadena),REPLACE(cCaracter," ","*")) = 0 THEN
				LET cCaracterInvalido = 't';
				EXIT;
			END IF;
			
			LET iPos = iPos + 1;
			
		END LOOP;
		
		IF cCaracterInvalido = 't' THEN
			IF iPos >= 224 THEN
				LET iPosTrama = 31;
			ELIF 	iPos >= 212 THEN
				LET iPosTrama = 30;
			ELIF 	iPos >= 210 THEN
				LET iPosTrama = 29;
			ELIF 	iPos >= 170 THEN
				LET iPosTrama = 28;
			ELIF 	iPos >= 150 THEN
				LET iPosTrama = 27;
			ELIF 	iPos >= 148 THEN
				LET iPosTrama = 26;
			ELIF 	iPos >= 130 THEN
				LET iPosTrama = 25;
			ELIF 	iPos >= 117 THEN
				LET iPosTrama = 24;
			ELIF 	iPos >= 115 THEN
				LET iPosTrama = 23;
			ELIF 	iPos >= 107 THEN
				LET iPosTrama = 22;
			ELIF 	iPos >= 105 THEN
				LET iPosTrama = 21;
			ELIF 	iPos >= 104 THEN
				LET iPosTrama = 20;
			ELIF 	iPos >= 96 THEN
				LET iPosTrama = 19;
			ELIF 	iPos >= 93 THEN
				LET iPosTrama = 18;
			ELIF 	iPos >= 92 THEN
				LET iPosTrama = 17;
			ELIF 	iPos >= 91 THEN
				LET iPosTrama = 16;
			ELIF 	iPos >= 81 THEN
				LET iPosTrama = 15;
			ELIF 	iPos >= 68 THEN
				LET iPosTrama = 14;
			ELIF 	iPos >= 65 THEN
				LET iPosTrama = 13;
			ELIF 	iPos >= 63 THEN
				LET iPosTrama = 12;
			ELIF 	iPos >= 59 THEN
				LET iPosTrama = 11;
			ELIF 	iPos >= 52 THEN
				LET iPosTrama = 10;
			ELIF 	iPos >= 48 THEN
				LET iPosTrama = 9;
			ELIF 	iPos >= 41 THEN
				LET iPosTrama = 8;
			ELIF 	iPos >= 26 THEN
				LET iPosTrama = 7;
			ELIF 	iPos >= 23 THEN
				LET iPosTrama = 6;
			ELIF 	iPos >= 20 THEN
				LET iPosTrama = 5;
			ELIF 	iPos >= 12 THEN
				LET iPosTrama = 4;
			ELIF 	iPos >= 10 THEN
				LET iPosTrama = 3;
			ELIF 	iPos >= 3 THEN
				LET iPosTrama = 2;
			ELSE 
				LET iPosTrama = 1;
			END IF;
		END IF;
		
		RETURN cCodRet, cCaracterInvalido, iPosTrama;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 25/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n de caracteres para la carga de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conserroresarchcecoban_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_conserroresarchcecoban_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFechaHoy IS NULL THEN
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
	
		--Bitï¿½cora errores datos
		IF UPPER(pIdConsulta) = 'D' THEN
		
			SELECT COUNT(*) INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cr_bitacoraerror 
			WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
		
		--Bitï¿½cora errores imï¿½genes
		ELIF UPPER(pIdConsulta) = 'I' THEN
		
			SELECT COUNT(*) INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg 
			WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
		
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de los errores encontrados en los archivos de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaimgnula(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), 
pDireccionMac CHAR(12), pFecha DATE, pStatusImgF CHAR(1), pStatusImgT CHAR(1), pIdDetalle INTEGER)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5); 
	DEFINE cDescCodRetSp CHAR(35);
	DEFINE cFormatFecha CHAR(10);
	DEFINE cDia CHAR(2);
	DEFINE cMiBanco CHAR(3);
	DEFINE iHayDatos INTEGER;
	DEFINE cDetDatosNombreArch CHAR(22);
	DEFINE cDetDatosNumCuenta CHAR(22);
	DEFINE iDetDatosNumCheque INTEGER;
	DEFINE cDetDatosImporte MONEY (14,2);
	DEFINE cDatosArchImgF CHAR(100);
	DEFINE cDatosArchImgT CHAR(100);
	DEFINE cDatosTamImgF CHAR(15); 
	DEFINE cDatosTamImgT CHAR(15);
	DEFINE cDatosCargaImgF CHAR(1);
	DEFINE cDatosCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE cHuboError CHAR(1);
	DEFINE iContDetalle INTEGER;
	DEFINE iRecuperacion INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = ''; 
	LET cDescCodRetSp = '';
	LET cFormatFecha = '';
	LET cDia = '';
	LET cMiBanco = '';
	LET iHayDatos = 0;
	LET cDetDatosNombreArch = '';
	LET cDetDatosNumCuenta = '';
	LET iDetDatosNumCheque = 0;
	LET cDetDatosImporte = 0.00;
	LET cDatosArchImgF = '';
	LET cDatosArchImgT = '';
	LET cDatosTamImgF = ''; 
	LET cDatosTamImgT = '';
	LET cDatosCargaImgF = '';
	LET cDatosCargaImgT = '';
	LET iIdDetalle = 0;
	LET cHuboError = 'f';
	LET iContDetalle = 0;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaimgnula.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFecha IS NULL OR 
		pStatusImgF = '' OR pStatusImgT = '' OR pIdDetalle IS NULL THEN
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
		
		-- FECHA HABIL ACTUAL
		LET cFormatFecha = SUBSTR(pFecha,7,4)||'/'||SUBSTR(pFecha,1,2)||'/'||SUBSTR(pFecha,4,2);
		LET cDia = SUBSTR(pFecha,4,2);
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
		
		LET iHayDatos = 0;
		SELECT COUNT(id_detalle) INTO iHayDatos FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha AND datos_nombre_archivo = TRIM(pNombreArchivo);
		
		IF NVL(iHayDatos,0) = 0 THEN
			LET cCodRet = '00843'; --NO HAY IMï¿½GENES QUE PROCESAR, VERIFIQUE
			RETURN cCodRet;
		END IF;
	
		FOREACH
		
			SELECT datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,datos_importe,
			datos_archivo_imgf,datos_archivo_imgt,datos_tamanio_imgf,datos_tamanio_imgt
			INTO cDetDatosNombreArch,cDetDatosNumCuenta,iDetDatosNumCheque,cDetDatosImporte,
			cDatosArchImgF,cDatosArchImgT,cDatosTamImgF,cDatosTamImgT
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle
			
			IF NVL(pStatusImgF,'') <> '3' OR NVL(pStatusImgT,'') <> '3' THEN
				
				IF NVL(pStatusImgF,'') = '2' THEN
					
					-- VALIDA QUE LA IMAGEN F NO SEA NULA
					EXECUTE PROCEDURE bditef:"informix".cons_img_nula(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,'F',pFecha)
					INTO cCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:cons_img_nula';
					ELIF cCodRetSp::INTEGER = 110 THEN 
						LET cCodRet = '00003';
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 130 THEN 
						LET cCodRet = '00720';
						RETURN cCodRet;
					END IF;					
					
					IF cCodRetSp = '000' THEN
					
						UPDATE bditef:"informix".cce_propios_det SET img1_stat = '3'
						WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
						
						--Actualiza status imagen
						UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgf = '3'
						WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
						AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
					
					END IF;
				END IF;
			
				IF NVL(pStatusImgT,'') = '2' THEN
					
					-- VALIDA QUE LA IMAGEN T NO SEA NULA
					EXECUTE PROCEDURE bditef:"informix".cons_img_nula(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,'T',pFecha)
					INTO cCodRetSp;
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:cons_img_nula';
					ELIF cCodRetSp::INTEGER = 110 THEN 
						LET cCodRet = '00003';
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 130 THEN 
						LET cCodRet = '00720';
						RETURN cCodRet;
					END IF;
					
					IF cCodRetSp = '000' THEN
						
						UPDATE bditef:"informix".cce_propios_det SET img2_stat = '3'
						WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
						
						--Actualiza status imagen
						UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgt = '3'
						WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
						AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
						
					END IF;
				END IF;
			END IF;
			
			SELECT datos_carga_imgf,datos_carga_imgt
			INTO cDatosCargaImgF,cDatosCargaImgT
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
		
			IF NVL(cDatosCargaImgF,'') = '3' AND NVL(cDatosCargaImgT,'') = '3' THEN
			
				--Actualiza registros que se guardaron exitosamente
				UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET bandera_color = 'V'
				WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
				AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
			END IF;
			
		END FOREACH;
		
		IF cHuboError = 't' THEN
			LET cCodRet = '00844'; --OCURRIERON ERRORES AL IMPORTAR LAS IMAGENES, REPITA EL PROCESO MAS TARDE
			RETURN cCodRet;
		END IF;
		
		--MARCA ARCHIVO COMO PROCESADO
		SELECT NVL(MAX(id_detalle),0) INTO iContDetalle FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFecha;
	
		IF NVL(pIdDetalle,0) = NVL(iContDetalle,0) THEN
	
			INSERT INTO bditef:"informix".cce_archivos_ctl
			VALUES (
					UPPER(TRIM(pNombreArchivo)),
					pFecha,
					(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFecha),
					CURRENT,
					'IMG',
					iContDetalle,
					'','','0','03','M',
					'archivo de IMAGENES importado exitosamente',
					pUsuario,
					pFecha
					);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
				RETURN cCodRet;
			END IF;
		
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 20/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos',
'DESCRIPCION: SPL encargado de consultar que la imï¿½gen del archivo no se encuentre nula.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conserroresarchcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(12) AS seccion,
			CHAR(2) AS campo,
			CHAR(100) AS mensaje_error,
			INTEGER AS linea;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cSeccion CHAR(12);
	DEFINE cCampo CHAR(2);
	DEFINE cDescMensaje CHAR(100);
	DEFINE iLinea INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cSeccion = '';
	LET cCampo = '';
	LET cDescMensaje = '';
	LET iLinea = 0;
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_conserroresarchcecoban.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFechaHoy IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			
	
		--Bitï¿½cora errores datos
		IF UPPER(pIdConsulta) = 'D' THEN
		
			FOREACH
				SELECT {+INDEX (bdicnweb:"informix".sw_cr_bitacoraerror idx_sw_cr_bitacoraerror )} 
				SKIP pRegistros FIRST pRecuperacion seccion,campo,mensaje_error,linea
				INTO cSeccion,cCampo,cDescMensaje,iLinea
				FROM bdicnweb:"informix".sw_cr_bitacoraerror 
				WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,UPPER(TRIM(cSeccion)),TRIM(cCampo),UPPER(TRIM(cDescMensaje)),NVL(iLinea,'') WITH RESUME;
			END FOREACH; 
			
		--Bitï¿½cora errores imï¿½genes
		ELIF UPPER(pIdConsulta) = 'I' THEN
		
			FOREACH
				SELECT {+INDEX (bdicnweb:"informix".sw_cr_bitacoraerrorimg idx_sw_cr_bitacoraerrorimg )} 
				SKIP pRegistros FIRST pRecuperacion seccion,campo,mensaje_error,linea
				INTO cSeccion,cCampo,cDescMensaje,iLinea
				FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg 
				WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,UPPER(TRIM(cSeccion)),TRIM(cCampo),UPPER(TRIM(cDescMensaje)),NVL(iLinea,'') WITH RESUME;
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los errores encontrados en los archivos de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallearchimgcecoban_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallearchimgcecoban_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR	pFechaHoy IS NULL THEN
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
	
		SELECT {+INDEX (bdicnweb:"informix".sw_cr_procesadetalleimg_tmp idx_sw_cr_procesadetalleimg_tmp )}  
		COUNT(*) INTO iNumRegistros
		FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017'; 
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de registros correspondientes a los archivos de imï¿½genes de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallearchimgcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(22) AS datos_nombre_archivo,
			CHAR(22) AS datos_num_cuenta,
			INTEGER AS datos_num_cheque,
			MONEY(14,2) AS importe,
			CHAR(1) AS datos_carga_imgf,
			CHAR(1) AS datos_carga_imgt,
			INTEGER AS id_detalle;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cNumCuenta CHAR(22);
	DEFINE iNumCheque INTEGER;
	DEFINE cImporte CHAR(15);
	DEFINE mImporte MONEY(14,2);
	DEFINE cStatusCargaImgF CHAR(1);
	DEFINE cStatusCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET cNumCuenta = '';
	LET iNumCheque = 0;
	LET cImporte = '';
	LET mImporte = 0.00;
	LET cStatusCargaImgF = '';
	LET cStatusCargaImgT = '';
	LET iIdDetalle = 0;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallearchimgcecoban.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR	pFechaHoy IS NULL OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
	
		FOREACH
			SELECT {+INDEX (bdicnweb:"informix".sw_cr_procesadetalleimg_tmp idx_sw_cr_procesadetalleimg_tmp )} 
			SKIP pRegistros FIRST pRecuperacion datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,importe,
			datos_carga_imgf,datos_carga_imgt,id_detalle
			INTO cNombreArchivo,cNumCuenta,iNumCheque,cImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) 
			AND fecha_insert = pFechaHoy ORDER BY id_detalle ASC

			LET mImporte = SUBSTR(cImporte,1,(LENGTH(cImporte)-2))||"."||SUBSTR(cImporte,(LENGTH(cImporte)-1),2);
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,UPPER(TRIM(cNombreArchivo)),TRIM(cNumCuenta),iNumCheque,NVL(mImporte,0),
			cStatusCargaImgF,cStatusCargaImgT,iIdDetalle WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle; 
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '10001';
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos de imï¿½genes de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_calculadigitointercambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pModulo CHAR(2))
		RETURNING CHAR(5) AS codret,                       
			INTEGER AS digito_intercambio;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;	
	DEFINE iDigitoIntercambio INTEGER;
	DEFINE iNumModulo INTEGER;
	DEFINE xCuenta CHAR(20);
	DEFINE iMaximo INTEGER;
	DEFINE iPos INTEGER;
	DEFINE iNumero INTEGER;
	DEFINE iAux INTEGER;
	DEFINE iSuma INTEGER;
	DEFINE iRes INTEGER;
	DEFINE iDigito INTEGER;
	DEFINE cAux CHAR(11);
	DEFINE cSuma CHAR(11);
	DEFINE cNumModulo CHAR(11);
	DEFINE iTamAux INTEGER;
	DEFINE iCorteAux INTEGER;
	DEFINE iTamSum INTEGER;
	DEFINE iCorteSum INTEGER;
	DEFINE iTamNumMod INTEGER;
	DEFINE iCorteNumMod INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iDigitoIntercambio = 0;
	LET iNumModulo = 0;
	LET xCuenta = '';
	LET iMaximo = 0;
	LET iPos = 0;
	LET iNumero = 0;
	LET iAux = 0;
	LET iSuma = 0;
	LET iRes = 0;
	LET iDigito = 0;
	LET cAux = '';
	LET cSuma = '';
	LET cNumModulo = '';
	LET iTamAux = 0;
	LET iCorteAux = 0;
	LET iTamSum = 0;
	LET iCorteSum = 0;
	LET iTamNumMod = 0;
	LET iCorteNumMod = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iDigitoIntercambio;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_calculadigitointercambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pModulo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iDigitoIntercambio;   
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iDigitoIntercambio; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- DIGITO DE INTERCAMBIO
		IF pModulo = '9' THEN 
			LET iNumModulo = 9;
		ELIF pModulo = '10' THEN 
			LET iNumModulo = 10;
		--ELIF pModulo = '10b' THEN 
		ELIF pModulo = '11' THEN 
			LET iNumModulo = 11;
		ELSE
			LET iNumModulo = 0;
		END IF;
		
		IF iNumModulo = 0 THEN 
			LET iDigitoIntercambio = -1;
			RETURN cCodRet, iDigitoIntercambio;  
		END IF;

		IF pCuenta::BIGINT <= 0 THEN
			LET iDigitoIntercambio = -1;
			RETURN cCodRet, iDigitoIntercambio;  
		END IF;

		LET xCuenta = TRIM(pCuenta);
		LET iMaximo = LENGTH(TRIM(xCuenta));
		
		IF iNumModulo = 10 THEN

			LET iPos = 1;
			
			WHILE (iPos <= iMaximo) LOOP
				
				LET iNumero = SUBSTR(xCuenta,iPos,1);
				
				IF iPos IN (1, 4, 7, 10, 13, 16, 19) THEN
					LET iAux = NVL(iNumero,0) * 3;
					IF iAux >= 10 THEN
						LET cAux = iAux;
						LET iTamAux = LENGTH(cAux);
						LET iAux = SUBSTR(cAux,iTamAux,1);
					END IF;
				ELIF iPos IN (2, 5, 8, 11, 14, 17) THEN
					LET iAux = NVL(iNumero,0) * 7;
					IF iAux >= 10 THEN
						LET cAux = iAux;
						LET iTamAux = LENGTH(cAux);
						LET iAux = SUBSTR(cAux,iTamAux,1);
					END IF;
				ELIF iPos IN (3, 6, 9, 12, 15, 18) THEN
					LET iAux = NVL(iNumero,0) * 1;
					IF iAux >= 10 THEN
						LET cAux = iAux;
						LET iTamAux = LENGTH(cAux);
						LET iAux = SUBSTR(cAux,iTamAux,1);
					END IF;
				END IF;
				
				LET iSuma = NVL(iSuma,0) + NVL(iAux,0);			
				LET iPos = NVL(iPos,0) + 1;
				
			END LOOP;

			LET cSuma = iSuma;
			LET iTamSum = LENGTH(cSuma);
			LET iRes = SUBSTR(cSuma,iTamSum,1);
			
			LET cNumModulo = iNumModulo - iRes;
			LET iTamNumMod = LENGTH(cNumModulo);
			LET iDigito = SUBSTR(cNumModulo,iTamNumMod,1);
			
		ELSE
		
			LET iPos = 0;
			
			WHILE (iPos <= (iMaximo - 1)) LOOP
				
				LET iNumero = SUBSTR(xCuenta,(iMaximo - iPos),1);
				
				IF iPos IN (0, 6, 12, 18) THEN
					LET iAux = NVL(iNumero,0) * 2;
				ELIF iPos IN (1, 7, 13) THEN
					LET iAux = NVL(iNumero,0) * 3;
				ELIF iPos IN (2, 8, 14) THEN
					LET iAux = NVL(iNumero,0) * 4;
				ELIF iPos IN (3, 9, 15) THEN
					LET iAux = NVL(iNumero,0) * 5;
				ELIF iPos IN (4, 10, 16) THEN
					LET iAux = NVL(iNumero,0) * 6;
				ELIF iPos IN (5, 11, 17) THEN
					LET iAux = NVL(iNumero,0) * 7;
				END IF;
				
				LET iSuma = NVL(iSuma,0) + NVL(iAux,0);								
				LET iPos = NVL(iPos,0) + 1;
				
			END LOOP;

			LET iRes = MOD(iSuma,iNumModulo);
			
			IF NVL(iNumModulo,0) > 9 THEN
				IF NVL(iNumModulo,0) = 11 THEN
					IF NVL(iRes,0) = 0 THEN 
						LET iDigito = 0;
					ELSE
						LET iDigito = 11 - NVL(iRes,0);
					END IF;
					
					IF NVL(iDigito,0) = 10 THEN 
						LET iDigito = 0;
					END IF;
					LET iDigitoIntercambio = NVL(iDigito,0);
					RETURN cCodRet, iDigitoIntercambio; 
				ELSE
					IF NVL(iRes,0) = 1 THEN 
						LET iDigitoIntercambio = -1;
						RETURN cCodRet, iDigitoIntercambio; 
					ELSE
						IF NVL(iRes,0) = 0 THEN
							LET iDigitoIntercambio = -1;
							RETURN cCodRet, iDigitoIntercambio; 
						END IF;
					END IF;
				END IF;
			END IF;
			
			LET iDigito = NVL(iNumModulo,0) - NVL(iRes,0);
		
		END IF;
		
		LET iDigitoIntercambio = NVL(iDigito,0);
		RETURN cCodRet, iDigitoIntercambio; 
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 26/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de calcular el dÃ­gito de intercambio para la carga de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_aplicacargaarchimgcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), 
pDireccionMac CHAR(12), pFecha DATE, pStatusImgF CHAR(1), pStatusImgT CHAR(1), pIdDetalle INTEGER)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5); 
	DEFINE cDescCodRetSp CHAR(35);
	
	DEFINE cFormatFecha CHAR(10);
	DEFINE cDia CHAR(2);
	DEFINE cMiBanco CHAR(3);
	DEFINE iHayDatos INTEGER;
	DEFINE cDetDatosNombreArch CHAR(22);
	DEFINE cDetDatosNumCuenta CHAR(22);
	DEFINE iDetDatosNumCheque INTEGER;
	DEFINE cDetDatosImporte MONEY (14,2);
	DEFINE cDatosArchImgF CHAR(100);
	DEFINE cDatosArchImgT CHAR(100);
	DEFINE cDatosTamImgF CHAR(15); 
	DEFINE cDatosTamImgT CHAR(15);
	DEFINE cDatosCargaImgF CHAR(1);
	DEFINE cDatosCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE cHuboError CHAR(1);
	DEFINE iContDetalle INTEGER;
	DEFINE iRecuperacion INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = ''; 
	LET cDescCodRetSp = '';
	
	LET cFormatFecha = '';
	LET cDia = '';
	LET cMiBanco = '';
	LET iHayDatos = 0;
	LET cDetDatosNombreArch = '';
	LET cDetDatosNumCuenta = '';
	LET iDetDatosNumCheque = 0;
	LET cDetDatosImporte = 0.00;
	LET cDatosArchImgF = '';
	LET cDatosArchImgT = '';
	LET cDatosTamImgF = ''; 
	LET cDatosTamImgT = '';
	LET cDatosCargaImgF = '';
	LET cDatosCargaImgT = '';
	LET iIdDetalle = 0;
	LET cHuboError = 'f';
	LET iContDetalle = 0;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_aplicacargaarchimgcecoban.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFecha IS NULL OR 
		pStatusImgF = '' OR pStatusImgT = '' OR pIdDetalle IS NULL THEN
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
		
		-- FECHA HABIL ACTUAL
		LET cFormatFecha = SUBSTR(pFecha,7,4)||'/'||SUBSTR(pFecha,1,2)||'/'||SUBSTR(pFecha,4,2);
		LET cDia = SUBSTR(pFecha,4,2);
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
		
		LET iHayDatos = 0;
		SELECT COUNT(id_detalle) INTO iHayDatos FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha AND datos_nombre_archivo = TRIM(pNombreArchivo);
		
		IF NVL(iHayDatos,0) = 0 THEN
			LET cCodRet = '00843'; --NO HAY IMï¿½GENES QUE PROCESAR, VERIFIQUE
			RETURN cCodRet;
		END IF;
	
		FOREACH
		
			SELECT datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,datos_importe,
			datos_archivo_imgf,datos_archivo_imgt,datos_tamanio_imgf,datos_tamanio_imgt
			INTO cDetDatosNombreArch,cDetDatosNumCuenta,iDetDatosNumCheque,cDetDatosImporte,
			cDatosArchImgF,cDatosArchImgT,cDatosTamImgF,cDatosTamImgT
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle
			
			IF NVL(pStatusImgF,'') = '0' OR NVL(pStatusImgT,'') = '0' THEN
			
				IF NVL(pStatusImgF,'') <> '3' OR NVL(pStatusImgT,'') <> '3' THEN
				
					--ProcesaArchCtlZip
					IF NVL(pStatusImgF,'') <> '2' OR NVL(pStatusImgT,'') <> '2' THEN
					
						--'generar zip de la img1 (FRONTAL)
						IF NVL(pStatusImgF,'') = '0' THEN 
			
							-- INSERTA REGISTRO DE LA IMAGEN F
							EXECUTE PROCEDURE bditef:"informix".ins_img_det(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,
							'F',pFecha,'tif',cDatosTamImgF,pUsuario,pFecha)
							INTO cCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:ins_img_det';
							ELIF cCodRetSp::INTEGER = 110 THEN 
								LET cCodRet = '00003';
								RETURN cCodRet;
							END IF;
							
							IF cCodRetSp = '000' THEN
							
								UPDATE bditef:"informix".cce_propios_det SET img1_stat = '2'
								WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
								
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
								
								--Actualiza status imagen
								UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgf = '2'
								WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
								AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;		

								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
								
							END IF;
						END IF;
						
						--'generar zip de la img2 (TRASERA)
						IF NVL(pStatusImgT,'') = '0' THEN 
			
							-- INSERTA REGISTRO DE LA IMAGEN T
							EXECUTE PROCEDURE bditef:"informix".ins_img_det(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,
							'T',pFecha,'tif',cDatosTamImgT,pUsuario,pFecha)
							INTO cCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:ins_img_det';
							ELIF cCodRetSp::INTEGER = 110 THEN 
								LET cCodRet = '00003';
								RETURN cCodRet;
							END IF;
							
							IF cCodRetSp = '000' THEN
							
								UPDATE bditef:"informix".cce_propios_det SET img2_stat = '2'
								WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
								
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
								
								--Actualiza status imagen
								UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgt = '2'
								WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
								AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;		

								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
							
							END IF;
						END IF;	
					END IF;
				END IF;
			END IF;
			
		END FOREACH;
		
		IF cHuboError = 't' THEN
			LET cCodRet = '00844'; --OCURRIERON ERRORES AL IMPORTAR LAS IMAGENES, REPITA EL PROCESO MAS TARDE
			RETURN cCodRet;
		END IF;
	
		RETURN cCodRet;
		
	END;
END PROCEDURE;