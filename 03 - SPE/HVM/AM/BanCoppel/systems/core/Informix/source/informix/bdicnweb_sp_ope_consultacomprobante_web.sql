CREATE PROCEDURE "informix".sp_ope_consultacomprobante_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER, pFolioSuc CHAR(16), pHuella CHAR(1), cParam1 CHAR(50), cParam2 CHAR(100), 
													cParam3 CHAR(150))
    RETURNING CHAR(5)	AS codret,
	CHAR(3) AS numconvenio,
	CHAR(40) AS nomconvenio,
	CHAR(2) AS numcategoria,
	CHAR(20) AS num_cte,
	DATE AS fech_oper,
	CHAR(4) AS sucursal,
	CHAR(16) AS folio_suc,
	CHAR(40) AS referencia1,
	INTEGER AS totRegistros,
    CHAR(1) AS formaPago,
    MONEY AS importePago,
    CHAR(10) AS fechaInsert,
    CHAR(8) AS usuario,
    CHAR(16) AS folioSuc,
	CHAR(15) AS origen, 
    CHAR(20) AS numCuenta,
    CHAR(16) AS numTarjeta,
    CHAR(40) AS nomSucursal,
    CHAR(40) AS nombre1Ben,
    CHAR(40) AS nombre2Ben,
    CHAR(40) AS apPaternoBen,
    CHAR(40) AS apMaternoBen,
    CHAR(20) AS numCteBen,
    CHAR(20) AS numcliente,
	CHAR(10) AS telefono, 
    CHAR(942) AS cadenaTran,
    CHAR(3) AS plaza,
    CHAR(40) AS nomPlaza,
	VARCHAR(250) AS dirCompleta,
	CHAR(100) AS nomCliente,
	CHAR(50) AS retorno1,
	CHAR(100) AS retorno2,
	CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalReg INTEGER;
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNumcategoria CHAR(2);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE cReferencia1 CHAR(40);
	DEFINE iTotRegistros INTEGER;
    DEFINE cFormaPago CHAR(1);
    DEFINE mImportePago MONEY;
    DEFINE cFechaInsert CHAR(10);
    DEFINE cUsuario CHAR(8);
    DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(10); 
    DEFINE cNombre1Ben CHAR(40);
    DEFINE cNombre2Ben CHAR(40);
    DEFINE cApPaternoBen CHAR(40);
    DEFINE cApMaternoBen CHAR(40);
    DEFINE cNumCteBen CHAR(20);
    DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
    DEFINE cCadenaTran CHAR(942);
    DEFINE cNomSucursal CHAR(40);
    DEFINE cPlaza CHAR(3);
    DEFINE cNomPlaza CHAR(40);
    DEFINE cNumcuenta CHAR(20);
    DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cNomCliente CHAR(100);
	DEFINE cRetorno1 CHAR(50);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);

	LET cCodRet			= '00000';
	LET iSqlErr			= 0;
	LET iTotalReg = 0;
	
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNumcategoria = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET cReferencia1 = '';
	LET iTotRegistros = 0;
	
    LET cFormaPago = '';
    LET mImportePago = 0;
    LET cFechaInsert = '';
    LET cUsuario = '';
    LET cFolioSuc = '';
	LET cOrigen = ''; 
    LET cNombre1Ben = '';
    LET cNombre2Ben = '';
    LET cApPaternoBen = '';
    LET cApMaternoBen = '';
    LET cNumCteBen = '';
    LET cNumcliente = '';
	LET cTelefono = ''; 
    LET cCadenaTran = '';
    LET cNomSucursal = '';
    LET cPlaza = '';
    LET cNomPlaza = '';
    LET cNumcuenta = '';
    LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cNomCliente = '';
	LET cRetorno1 = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc,  cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacomprobante.out';
		--TRACE ON;

		IF pBandera = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc,  cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Realiza la consulta para el llenado del combo
		IF pBandera = '1' THEN 
		FOREACH 
		
			EXECUTE PROCEDURE bdicnweb:"informix".sp_tk_consultaremesadoras(pUsuario, pIdFuncion) 
			INTO cCodRet, cNumconvenio, cNomconvenio, cNumcategoria
							
			LET iTotalReg = iTotalReg + 1;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3 WITH RESUME;
			
		END FOREACH;

		IF iTotalReg = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc,  cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;
		
		--Reliza la consulta para obtener datos para el llenado del grid
		ELIF pBandera = '2' THEN
			FOREACH 
			EXECUTE PROCEDURE sp_ope_consmovimientos_web(pUsuario, pIdFuncion, pRemesadora, pFechaInicio, pFechaFin, pCveRemesa, pNumCliente, pRegistros, pRecuperacion) 
			INTO cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
				
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3 WITH RESUME;
		END FOREACH;
		
		ELIF pBandera = '4' THEN -- Formato Abono Ventanilla 

			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketAbonoVent_web(pUsuario, pIdFuncion, pCveRemesa, pHuella, pNumCliente) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		
		ELIF pBandera = '5' THEN -- Formato Efectivo Ventanilla

			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketEfectivoVent_web(pUsuario, pIdFuncion, pCveRemesa, pHuella) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cOrigen, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cNumcuenta, cNumTarjeta, cRetorno2, cRetorno3;

			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
			
		ELIF pBandera = '6' THEN -- Formato Abono APP 
		
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketAbonoApp_web(pUsuario, pIdFuncion, pCveRemesa, pFolioSuc, pHuella, pNumCliente) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: FG',
'FECHA: 29/07/2024',
'MODULO: Ticket Digital',
'FUNCIONALIDAD: Ticket Digital - Consulta Comprobante',
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos para la funcionalidad consulta comprobante de ticket digital';

CREATE PROCEDURE "informix".sp_ope_reversodetallechequecodigo40(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(50))
		RETURNING CHAR(5) AS codret;

		DEFINE cCodRet 			CHAR(5);
		DEFINE iSqlErr 			INTEGER;
		DEFINE dFechaHoy 		DATE;
		DEFINE cFechaAlta 		CHAR(10);
		DEFINE cNumCuenta 		CHAR(20);
		DEFINE cNumCheque 		CHAR(20);
		DEFINE icodSeguridad 	INTEGER;
		
		LET cCodRet 		= '00000';
		LET iSqlErr 		= 0;
		LET dFechaHoy 		= '';
		LET cFechaAlta 		= '';
		LET cNumCheque 		= '';
		LET cNumCuenta 		= '';
		LET icodSeguridad 	= 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reversodetallechequecodigo40.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN				
				RETURN cCodRet;
			END IF;

            
            SELECT fecha_hoy, TO_CHAR(fecha_hoy, "%Y%m%d") 
			INTO dFechaHoy, cFechaAlta
			FROM bdicheq:'informix'.sc_fechas
			WHERE empresa = '001';

			FOREACH 
				SELECT numcuenta, numcheque, cce.codseguridad 
				INTO cNumCuenta, cNumCheque, icodSeguridad
				FROM bditef:cce_cheques_det  cce 
				INNER JOIN bdicnweb:sw_cc_consultadetallecheque40 sw
				ON cce.numcheque = sw.num_cheque 
				AND cce.codseguridad = sw.chq_cod_seguridad
				AND cce.numcuenta = sw.cuenta_referencia
				WHERE fechapresenta = dFechaHoy
				AND cce.presentado = '1'
				AND sw.ejecutivo = pUsuario


				--Revertimos el codigo de presentado
				UPDATE bditef:cce_cheques_det SET presentado = "0" 
				WHERE fechapresenta = dFechaHoy
				AND numcuenta = cNumCuenta
				AND numcheque = cNumCheque
				AND codseguridad = icodSeguridad;
			
			END FOREACH;

			IF cFechaAlta <> '' OR cFechaAlta IS NOT NULL THEN 

				IF EXISTS (SELECT 1 FROM bditef:cce_gransumario where fecha = cFechaAlta AND nombrearchivo = pNombreArchivo) THEN 
					DELETE FROM bditef:cce_gransumario where fecha = cFechaAlta AND nombrearchivo = pNombreArchivo;
				END IF;

				IF pNombreArchivo IS NOT NULL OR pNombreArchivo <> '' THEN
					DELETE FROM bditef:cce_sumario where nombrearchivo = TRIM(pNombreArchivo);

					DELETE FROM bditef:cce_encabezado WHERE fecha_alta = dFechaHoy AND nombrearchivo = TRIM(pNombreArchivo);

				END IF

				IF EXISTS (SELECT 1 FROM bditef:cce_detalle where fecha_presini = cFechaAlta AND nombrearchivo = TRIM(pNombreArchivo)) THEN
					DELETE FROM bditef:cce_detalle where fecha_presini = cFechaAlta AND nombrearchivo = TRIM(pNombreArchivo);
				END IF;

			END IF;

            RETURN cCodRet;

		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 26/07/2024',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL encargado de realizar el Reverso a la funcionalidad del codigo 40 en caso de un error inesperado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(18))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros,
			INTEGER AS doc_incompletos,
			MONEY(16,2) AS monto_total_invalido,
			INTEGER AS total_validos,
			MONEY(16,2) AS monto_total_valido,
			INTEGER AS noImagenesDesc;

		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
		DEFINE iSqlErr INTEGER;
		DEFINE dFechaHoy DATE;
		DEFINE dMontoImagen DECIMAL(16,2);
		DEFINE cEmpresa CHAR(3);
		DEFINE cCveBanco CHAR(3);
		DEFINE cDescBanco CHAR(40);
		DEFINE cCtaReferencia CHAR(40);
		DEFINE iNumCheque INTEGER;
		DEFINE mImporte MONEY(14,2);
		DEFINE cCuentaDeposito CHAR(20);
		DEFINE cSucursal CHAR(44);
		DEFINE cNoTransaccion CHAR(4);
		DEFINE cChqCompensacion CHAR(3);
		DEFINE cChqTransaccion CHAR(2);
		DEFINE cChqCodSeguridad CHAR(3);
		DEFINE cChqDigVerPre CHAR(1);
		DEFINE cChqDigVerInter CHAR(1);
		DEFINE iTamImgChqAnverso INTEGER;
		DEFINE iTamImgChqReverso INTEGER;
		DEFINE cIsImagenCheque CHAR(1);
		DEFINE cTipoCuentaDep CHAR(2);
		DEFINE cCampoCliente CHAR(20);
		DEFINE cCampoCuenta CHAR(20);
		DEFINE cTablaClientes CHAR(30);
		DEFINE cNoCliente CHAR(20);
		DEFINE cNombreCte CHAR(60);
		DEFINE cRfcCte CHAR(13);
		DEFINE cCurpCte CHAR(20);
		DEFINE cChequeProcesado CHAR(1);
		DEFINE iIdNoCheque INTEGER;
		DEFINE bIsChequeDuplicado BOOLEAN;
		
		DEFINE iNoRegistros INTEGER;
		DEFINE iNoImagenes INTEGER;
		DEFINE iNoChequesValidos INTEGER;
		DEFINE iNoDocsIncompletos INTEGER;
		DEFINE mMontoTotalValido MONEY(16,2);
		DEFINE mMontoTotalInvalido MONEY(16,2);
		DEFINE cStatusProceso CHAR(1);
		
		DEFINE bImagenF BLOB;
		DEFINE bImagenT BLOB;
		DEFINE cImagenFormatoT CHAR(3);
		DEFINE cImagenFormatoF CHAR(3);
		
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET iSqlErr = 0;
		LET dFechaHoy = NULL;
		LET dMontoImagen = 0;
		LET cEmpresa = '001';
		LET cCveBanco = '';
		LET cDescBanco = '';
		LET cCtaReferencia = '';
		LET iNumCheque = 0;
		LET mImporte = 0;
		LET cCuentaDeposito = '';
		LET cSucursal = '';
		LET cNoTransaccion = '';
		LET cChqCompensacion = '';
		LET cChqTransaccion = '';
		LET cChqCodSeguridad = '';
		LET cChqDigVerPre = '';
		LET cChqDigVerInter = '';
		LET iTamImgChqAnverso = 0;
		LET iTamImgChqReverso = 0;
		LET cIsImagenCheque = '';
		LET cTipoCuentaDep = '';
		LET cCampoCliente = '';
		LET cCampoCuenta = '';
		LET cTablaClientes = '';
		LET cNoCliente = '';
		LET cNombreCte = '';
		LET cRfcCte = '';
		LET cCurpCte = '';
		LET cChequeProcesado = '';
		LET iNoRegistros = 0;
		LET iNoImagenes = 0;
		LET iNoChequesValidos = 0;
		LET iNoDocsIncompletos = 0;
		LET mMontoTotalValido = 0.0;
		LET mMontoTotalInvalido = 0.0;
		LET cStatusProceso = '';
		LET iIdNoCheque = 0;
		LET bIsChequeDuplicado = 'f';
		LET bImagenF = NULL;
		LET bImagenT = NULL;
		LET cImagenFormatoT = '';
		LET cImagenFormatoF = '';
		
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultadetallechequecodigo40_totales.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN				
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;
			
			--Consulta fecha
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdicheq:'informix'.sc_fechas
			WHERE empresa = cEmpresa;
			
			
			IF dFechaHoy IS NULL THEN
				LET cCodRet = '00533'; --EL PARÃ¯Â¿Â½METRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA				
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;			
			
			-- VALOR IMPORTE PARA ENVIO DE IMAGEN A CECOBAN
			SELECT valor::DECIMAL(16,2)
			INTO dMontoImagen
			FROM bditef:'informix'.cce_param 
			WHERE empresa = '001' AND cod_param = '2'; 
		
			IF dMontoImagen IS NULL THEN
				LET cCodRet = '00530'; --EL IMPORTE MÃ¯Â¿Â½XIMO DE CECOBAN NO EXISTE				
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;	
			
			-- LIMPIAMOS TABLA
			DELETE FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40 
			WHERE ejecutivo = pUsuario AND direccion_mac = pDireccionMac;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			
			LET iNoImagenes = 0;
			-- SE CONSULTAN LOS CHEQUES PARA ENVIAR (CODIGO 40)
			FOREACH SELECT cod_ret::integer, cve_banco, desc_banco, cuenta_referencia AS cuenta_referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, transaccion
					INTO iCodRetSp, cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cNoTransaccion
					FROM TABLE(PROCEDURE bdicheq:'informix'.sp_cce_consultar_cheques40(cEmpresa, dFechaHoy)) 
						AS sc_cce_presentada(cod_ret, cve_banco, desc_banco, cuenta_referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, transaccion)
					
					-- VALIDACIÃ¯Â¿Â½N DE LOS CODIGOS DE RETORNO
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultar_cheques40';
					ELIF iCodRetSp = 1 THEN
						LET cCodRet = '00003';
						RETURN cCodRet, 0, 0, 0, 0, 0, 0;
					END IF;
					
					LET cChequeProcesado = '0';
					LET cIsImagenCheque = '2';
					
					-- SE CONSULTA EL DETALLE DE L0S CHEQUES
					FOREACH SELECT cod_ret::INTEGER AS codret, compensacion, transaccion, cod_seguridad, digverpre, digverinter
							INTO iCodRetSp, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter
							FROM TABLE (PROCEDURE bditef:'informix'.sp_cce_consultar_detallecheques(cEmpresa, cCveBanco, cCtaReferencia, iNumCheque))
							AS detalle_cheque(cod_ret, compensacion, transaccion, cod_seguridad, digverpre, digverinter)
							
							-- VALIDACIÃ¯Â¿Â½N DE CODIGO DE RETORNO
							
							LET cChequeProcesado = '1';
							LET cIsImagenCheque = '2';
							
							
							LET iTamImgChqAnverso = NULL;
							LET iTamImgChqReverso = NULL;
							LET bImagenF= NULL;
							LET cImagenFormatoF = NULL;
							LET bImagenT = NULL;
							LET cImagenFormatoT = NULL;
							
							-- VALIDACIÃ¯Â¿Â½N DEL MONTO DEL CHEQUE
							IF mImporte > dMontoImagen THEN
								--LET iNoImagenes = iNoImagenes + 2;
								-- SE CONSULTA EL TAMAÃ¯Â¿Â½O DEL ANVERSO DEL CHEQUE
								SELECT FIRST 1 imagen_tam, imagen, imagen_formato
								INTO iTamImgChqAnverso, bImagenF ,cImagenFormatoF
								FROM (
								SELECT imagen_tam, imagen, imagen_formato
								FROM bditef:'informix'.cce_cheques_img
								WHERE empresa = cEmpresa
									AND cvebanco = cCveBanco
									AND numcuenta = cCtaReferencia
									AND numcheque = iNumCheque
									--AND fechapresenta = TO_DATE("05-01-2023", "%m-%d-%Y")
									AND fechapresenta = dFechaHoy
									AND lado_ft in ('F','A')
									ORDER BY imagen_tam ASC);
									
								IF iTamImgChqAnverso IS NOT NULL THEN
									-- SE CONSULTA EL TAMAÃ¯Â¿Â½O DEL REVERSO DEL CHEQUE
									SELECT FIRST 1 imagen_tam, imagen, imagen_formato
									INTO iTamImgChqReverso, bImagenT, cImagenFormatoT
									FROM (
								    SELECT imagen_tam, imagen, imagen_formato
								    FROM bditef:'informix'.cce_cheques_img
									WHERE empresa = cEmpresa
										AND cvebanco = cCveBanco
										AND numcuenta = cCtaReferencia
										AND numcheque = iNumCheque
										--AND fechapresenta = TO_DATE("05-01-2023", "%m-%d-%Y")
										AND fechapresenta = dFechaHoy
										AND lado_ft in ('T','B')
										ORDER BY imagen_tam ASC);
									
									
									LET cIsImagenCheque = '1';
								ELSE
									LET cIsImagenCheque = '0';
								END IF;
	
							END IF;
							
							-- CONSULTAR EL NOMBRE Y EL RFC (MAPEO)
							SELECT tipo_cta_dep, campo_cliente, campo_cuenta, tabla_clientes
							INTO cTipoCuentaDep, cCampoCliente, cCampoCuenta, cTablaClientes
							FROM bditef:'informix'.cce_mapeo_cecoban
							WHERE empresa = cEmpresa
								AND transacc = cNoTransaccion;
								
							IF cTipoCuentaDep IS NULL THEN -- ERROR DE QUE NO SE ENCONTRO EL MAPEO CECOBAN
								RETURN cCodRet, 0, 0, 0, 0, 0, 0;
							END IF;
							
							SELECT FIRST 1 num_cte
							INTO cNoCliente
							FROM bdicheq:sc_maechq WHERE cuenta = TRIM(cCuentaDeposito);
							/*
							---- CONSULTA PREPARADA
							PREPARE noClienteStmt FROM 'SELECT '||TRIM(cCampoCliente)||' FROM '||TRIM(cTablaClientes)||' WHERE '||TRIM(cCampoCuenta)||" = '"||TRIM(cCuentaDeposito)||"';";
							DECLARE noClienteCur CURSOR FOR noClienteStmt;
							OPEN noClienteCur;
							FETCH noClienteCur INTO cNoCliente;
							CLOSE noClienteCur;*/
							
							SELECT cod_ret::integer, nombre, rfc, curp
							INTO iCodRetSp, cNombreCte, cRfcCte, cCurpCte
							FROM TABLE (PROCEDURE bditef:'informix'.consnomcte(cEmpresa, cNoCliente))
								AS tmp_nombre_cte(cod_ret, nombre, rfc, curp);
								
							LET cStatusProceso = 'P';
							
							IF  cIsImagenCheque = '0' THEN
								LET cStatusProceso = 'F';
							END IF;

							
							INSERT INTO bdicnweb:'informix'.sw_cc_consultadetallecheque40(banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, 
										chq_procesado, chq_compensacion, chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter,
										transaccion, nombre_cte, rfc_cte, curp_cte, tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque, ejecutivo, 
										direccion_mac, id_status_proceso, imagenf,imagent,imagen_formatof,imagen_formatot)
							VALUES(cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cChequeProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad,
									cChqDigVerPre, cChqDigVerInter, cNoTransaccion, cNombreCte, cRfcCte, cCurpCte, cTipoCuentaDep, cIsImagenCheque, iTamImgChqAnverso, iTamImgChqReverso, pUsuario, 
									pDireccionMac, cStatusProceso, bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT);
					END FOREACH;
					
					/*FREE noClienteCur;
					FREE noClienteStmt;*/
					
					IF cChequeProcesado = '0' THEN
						LET cStatusProceso = 'C';
						INSERT INTO bdicnweb:'informix'.sw_cc_consultadetallecheque40(banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, 
										chq_procesado, chq_compensacion, chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter,
										transaccion, nombre_cte, rfc_cte, curp_cte, tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque, 
										ejecutivo, direccion_mac, id_status_proceso, imagenf,imagent,imagen_formatof,imagen_formatot)
						VALUES(cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cChequeProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad,
								cChqDigVerPre, cChqDigVerInter, cNoTransaccion, cNombreCte, cRfcCte, cCurpCte, cTipoCuentaDep, cIsImagenCheque, iTamImgChqAnverso, iTamImgChqReverso, pUsuario, 
								pDireccionMac, cStatusProceso, bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT);
					END IF;
		
			END FOREACH;
			
			-- VALIDACION DE CHEQUE DUPLICADO
			FOREACH SELECT id_consultadetallecheque40
					INTO iIdNoCheque
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					AND chq_procesado = '1'
					AND ind_img_cheque IN ('1', '2')
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_chequeduplicado(pUsuario, pIdFuncion, iIdNoCheque, dFechaHoy, '40') INTO cCodRetSp, bIsChequeDuplicado;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:"informix".sp_ope_chequeduplicado';
				END IF;
				
				IF iCodRetSp = 0 THEN
					UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cc_consultadetallecheque40)} bdicnweb:'informix'.sw_cc_consultadetallecheque40
					SET ind_duplicado = DECODE(bIsChequeDuplicado, 'f', '0', 't', '1')
					WHERE id_consultadetallecheque40 = iIdNoCheque;
				END IF;
			END FOREACH
			
			
			
			-- NUMERO TOTAL DE REGISTROS
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac;
				
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;
			
			-- NUMERO TOTAL DE IMAGENES
			--SELECT SUM(ind_img_cheque::integer)
			SELECT COUNT(ind_img_cheque)
			INTO iNoImagenes
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND ind_img_cheque = '1';			
			LET iNoImagenes = iNoImagenes * 2;	
				
			-- CHEQUES VALIDOS
			SELECT COUNT(*)
			INTO iNoChequesValidos
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND chq_procesado = '1';
				
			LET iNoDocsIncompletos = iNoRegistros - iNoChequesValidos;
			
			-- MONTO TOTAL VALIDO
			SELECT SUM(importe)
			INTO mMontoTotalValido
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND chq_procesado = '1';
			
			-- MONTO TOTAL INVALIDO
			SELECT SUM(importe)
			INTO mMontoTotalInvalido
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND chq_procesado = '0';
			
			RETURN cCodRet, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes;
			
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 11/01/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de obtener el nÃ¯Â¿Â½mero total de registros correspondientes a los cheques de cÃ¯Â¿Â½digo 40.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_chequeduplicado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdCheque INTEGER, pFecha DATE, pCodigo CHAR(2))
		RETURNING CHAR(5) AS codret,
				BOOLEAN AS esta_duplicado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bIsChequeDuplicado BOOLEAN;
	DEFINE iChequeDuplicado SMALLINT;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCveBanco CHAR(3);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE iNumCheque INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bIsChequeDuplicado = 'f';
	LET iChequeDuplicado = 0;
	LET cEmpresa = '001';
	LET cCveBanco = '';
	LET cCuentaReferencia = '';
	LET iNumCheque = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, bIsChequeDuplicado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_chequeduplicado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdCheque IS NULL OR pFecha IS NULL OR pCodigo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
		
		IF pCodigo NOT IN ('40', '41', '46', '47') THEN
			LET cCodRet = '00003'; -- PARAMETRO INCORRECTO (CAMBIAR)
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
		
		-- BUSCAMOS EL ID
		IF EXISTS (SELECT 1 FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40 WHERE id_consultadetallecheque40 = pIdCheque) THEN
		
			SELECT banco, cuenta_referencia, num_cheque
			INTO cCveBanco, cCuentaReferencia,iNumCheque
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE id_consultadetallecheque40 = pIdCheque;
			
			-- SE BUSCA QUE NO EXISTA EL CHEQUE EN CCE_DETALLE
			SELECT COUNT(nombrearchivo)
			INTO iChequeDuplicado
			FROM bditef:'informix'.cce_detalle
			WHERE cod_operacion = pCodigo
				AND bco_receptor = cCveBanco
				AND num_cuenta = cCuentaReferencia
				AND num_cheque = iNumCheque
				AND fecha_presini = TO_CHAR(pFecha, '%Y%m%d');
				
			IF iChequeDuplicado = 0 THEN
				RETURN cCodRet, bIsChequeDuplicado;
			ELSE 
				-- SE MARCA COMO DUPLICADO
				UPDATE bditef:'informix'.cce_cheques_det
				SET presentado = '1'
				WHERE empresa = cEmpresa
					AND cvebanco = cCveBanco
					AND numcuenta = cCuentaReferencia
					AND numcheque = iNumCheque
					AND fechapresenta = pFecha;
				
				LET bIsChequeDuplicado = 't';
				RETURN cCodRet, bIsChequeDuplicado;
			END IF;
		
		ELSE
			LET cCodRet = '00002'; --EL REGISTRO QUE DESEA CONSULTAR NO EXISTE
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 15/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: Realiza la consulta para verificar si el cheque esta duplicado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_generarchivopresentado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoBloque INTEGER, pRutaDescarga CHAR(50), pDireccionMac CHAR(15))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS totalRegTruncados,
			  CHAR(50) AS nombreArchivo;

				
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE iExistenImgsDigitalizadas INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iChequeDuplicado SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE iBloqueInicial SMALLINT;
	DEFINE bIsChequeDuplicado BOOLEAN;
	DEFINE cTipoRegistro CHAR(2);
	DEFINE iNumeroSecuenca INTEGER;
	DEFINE cNumeroBanco CHAR(3);
	DEFINE cSentidoTransfer CHAR(1);
	DEFINE cPlazaCecoban CHAR(2);
	DEFINE cServicioTEI CHAR(1);
	DEFINE iDiaMesTransfer SMALLINT;
	DEFINE cFechaPresenta CHAR(8);
	DEFINE cUsoFuturo1 CHAR(1);
	DEFINE cTipoArchivo CHAR(1);
	DEFINE cUsoFuturo2 CHAR(1);
	DEFINE cCveBanco CHAR(3);
	DEFINE iNumCheque INTEGER;	
	DEFINE iIdConsultaDetalleCheque40 INTEGER;
	DEFINE cBanco CHAR(3);
	DEFINE cDescBanco CHAR (40);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE cNumCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cSucursalOperadora CHAR(44);
	DEFINE cChqProcesado CHAR(1);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cChqTransaccion CHAR(2);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cTransaccion CHAR(4);
	DEFINE cNombreCte CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cIndImgCheque CHAR(1);
	DEFINE iTamAnvImgCheque INTEGER;
	DEFINE iTamRevImgCheque INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cDireccionMac CHAR(15);
	DEFINE cIndDuplicado CHAR(1);
	DEFINE cIdStatusProceso CHAR(1);
	DEFINE iTotalChqProcesar INTEGER;
	DEFINE cNumSecuencia CHAR(7);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cFechatrasnfer CHAR(8);
	DEFINE cBancoCedente CHAR(3);
	DEFINE cBancoLibrado CHAR(3);
	DEFINE cImporte CHAR(16);
	DEFINE cMonto CHAR(13);
	DEFINE cCents CHAR(2);
	DEFINE cLoteEntrada CHAR(7);
	DEFINE cSecEntrada CHAR(4);
	DEFINE cLoteSAlida CHAR(7);
	DEFINE cSecSalida CHAR(4);
	DEFINE cUbicFis CHAR(8);
	DEFINE iTotalRegTruncados INTEGER;
	DEFINE cTruncado CHAR(1);
	DEFINE mMontoImagen DECIMAL(14,2);
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cTranSBCcheque CHAR(4);
	DEFINE cCodRetTrasacc CHAR(3);
	DEFINE cCodAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(1);
	DEFINE cUsoFuturo CHAR(1);
	DEFINE iTotalCheques INTEGER;
	DEFINE mTotalImporte DECIMAL(20,2);
	DEFINE cTipoSumario CHAR(2);
	DEFINE cTotalRegs CHAR(7);
	DEFINE cTotalRegTruncados CHAR(7);
	DEFINE cTipoGranSumario CHAR(2);
	DEFINE cSentido CHAR(1);
	DEFINE cNumOperaciones CHAR(7);
	DEFINE cNumBloques CHAR(2);
	DEFINE cFolio CHAR(9);
	DEFINE cFecha CHAR(8);
	DEFINE cImported CHAR(15);
	DEFINE cImportes CHAR(18);
	DEFINE cMontos CHAR(16);
	DEFINE cCodExc CHAR(5);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET iExistenImgsDigitalizadas = 0;
	LET iNoRegistros = 0;
	LET iChequeDuplicado = 0;
	LET dFechaHoy = NULL;
	LET iBloqueInicial = 1;
	LET bIsChequeDuplicado = 'f';	
	LET iIdConsultaDetalleCheque40 =0;
	LET cCveBanco = '';
	LET iNumCheque = 0;
	LET cBanco = '';
	LET cDescBanco = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = 0;
	LET mImporte = 0.0;
	LET cCuentaDeposito = '';
	LET cSucursalOperadora = '';
	LET cChqProcesado = '';
	LET cChqCompensacion = '';
	LET cChqTransaccion = '';
	LET cChqCodSeguridad = '';
	LET cChqDigVerPre = '';
	LET cChqDigVerInter = '';
	LET cTransaccion = '';
	LET cNombreCte = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cTipoCuentaDep = '';
	LET cIndImgCheque = '';
	LET iTamAnvImgCheque = 0;
	LET iTamRevImgCheque = 0;
	LET cEjecutivo = '';
	LET cDireccionMac = '';
	LET cIndDuplicado = '';
	LET cIdStatusProceso = '';
	LET iTotalChqProcesar = 0;
	LET cNumSecuencia = '';
	LET cCodOperacion = '';
	LET cFechatrasnfer = '';
	LET cBancoCedente = '';
	LET cBancoLibrado = '';
	LET cImporte = '';
	LET cMonto ='';
	LET cCents = '';
	LET cLoteEntrada ='';
	LET cSecEntrada = '';
	LET cLoteSAlida = '';
	LET cSecSalida = '';
	LET cUbicFis = '';
	LET iTotalRegTruncados = 0;
	LET cTruncado = '';
	LEt mMontoImagen = 0.0;
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cCtaAlertamiento = '';
	LET cTranSBCcheque = '';
	LET cCodRetTrasacc = '';
	LET cCodAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET iTotalCheques = 0;	
	LET mTotalImporte = 0.0;
	LET cTipoSumario = '';
	LET cTotalRegs = '';
	LET cTotalRegTruncados = '';
	LET cTipoGranSumario = '';
	LET cSentido = '';
	LET cNumOperaciones = '';
	LET cNumBloques = '';
	LET cFolio = '';
	LET cFecha = '';
	LET cImported = '';
	LET cImportes = '';
	LET cMontos = '';
	LET cCodExc = '00000';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF (iSqlErr=-268) THEN
				--BEGIN WORK;
				EXECUTE PROCEDURE "informix".sp_ope_reversodetallechequecodigo40(pUsuario, pIdFuncion, cNombreArchivo)
				INTO cCodExc;
				COMMIT;
			END IF
			RETURN cCodRet,iTotalRegTruncados,'';
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_generarchivopresentado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoBloque IS NULL OR pRutaDescarga = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalRegTruncados,'';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalRegTruncados,'';
		END IF;
		
		
		-- LA FECHA SE OBTIENE SE TABLA
		SELECT fecha_hoy INTO dFechaHoy from bdicheq:sc_fechas where empresa = '001';
		LET cNombreArchivo = 'PRE_'||TO_CHAR(DATE(dFechaHoy), '%d%m%Y')||'_MN_'||LPAD(pNoBloque, 2, '0');
		
		
		
		-- SE VALIDA QUE EXISTAN IMAGENES DIGITALIZADAS
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(ind_img_cheque)
		INTO iExistenImgsDigitalizadas
		FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND ind_img_cheque = '2';
			
		IF iExistenImgsDigitalizadas = 0 THEN
			-- MANDASR MENSAJE DE QUE NO EXISTEN REGISTROS COMPLETOS
			LET iExistenImgsDigitalizadas = 0;
			SELECT COUNT(ind_img_cheque)
			INTO iExistenImgsDigitalizadas
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND ind_img_cheque = '1';
			
			IF iExistenImgsDigitalizadas = 0 THEN
				LET cCodRet = '00780';
				RETURN cCodRet,iTotalRegTruncados,'';
			END IF;
		
		END IF;
		
		-- VALIDACIÃN DEL NUMERO DE REGISTROS
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac;
			
		IF iNoRegistros = 1 THEN -- SI SOLO ES UN REGISTRO, SE VALIDA QUE NO ESTE DUPLICADO
		
			SELECT banco, cuenta_referencia, num_cheque
			INTO cCveBanco, cCuentaReferencia,iNumCheque
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac;
				
			-- SE BUSCA QUE NO EXISTA EL CHEQUE EN CCE_DETALLE
			SELECT COUNT(*)
			INTO iChequeDuplicado
			FROM bditef:'informix'.cce_detalle
			WHERE cod_operacion = '40'
				AND bco_receptor = cCveBanco
				AND num_cuenta = cCuentaReferencia
				AND num_cheque = iNumCheque
				AND fecha_presini = TO_CHAR(dFechaHoy, '%Y%m%d');
			
			IF iChequeDuplicado <> 0 THEN
				-- SE MARCA EL CHEQUE COMO PROCESADO
				UPDATE bditef:'informix'.cce_cheques_det
				SET presentado = '1'
				WHERE empresa = cEmpresa
					AND cvebanco = cCveBanco
					AND numcuenta = cCuentaReferencia
					AND numcheque = iNumCheque
					AND fecha_presenta = dFechaHoy;
					
				-- SE AJUSTA EL MONTO TOTAL DE OPERACIONES
				-- (rEVISAR SI SE HACE EN VISTA EL AJUSTE)
				
				LET cCodRet = '99999';
				RETURN cCodRet,iTotalRegTruncados,''; --ERROR DE CHEQUE DUPLICADO
			END IF;
				
		END IF;
				
		--==============================
		-- PROCESAMIENTO GRABAR ENCABEZADO
		--==============================
		LET cTipoRegistro = '01';
		LET iNumeroSecuenca = iBloqueInicial;
		
		SELECT LPAD(valor::INTEGER, 3, '0')
		INTO cNumeroBanco
		FROM bdinteg:'informix'.si_param
		WHERE empresa = cEmpresa
			AND cod_param = '5';
		
		LET cSentidoTransfer = 'E';
		LET cPlazaCecoban = '01';
		LET cServicioTEI = '1';
		LET iDiaMesTransfer = DAY(dFechaHoy);
		LET cFechaPresenta = TO_CHAR(dFechaHoy, '%Y%m%d');
		LET cUsoFuturo1 = ' ';
		LET cTipoArchivo = '0'; -- 0 = Archivo real, 1 = Archivo de prueba
		LET cUsoFuturo2 = ' ';
		
		-- ESCRITURA DE LA CADENA DE TEXTO EN UN ARCHIVO
		SYSTEM 'echo "'||cTipoRegistro||LPAD(iNumeroSecuenca, 7, '0')||LPAD(cNumeroBanco,3,'0')||cSentidoTransfer||cPlazaCecoban||
		cServicioTEI||LPAD(iDiaMesTransfer, 2, '0')||LPAD(pNoBloque, 5, '0')||cFechaPresenta||LPAD(cUsoFuturo1,9,' ')||cTipoArchivo||
		LPAD(cUsoFuturo2,302,' ')||'" > '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
		
		-- GRABADO EN BASE DEL ENCABEZADO

        INSERT INTO bditef:cce_encabezado (nombrearchivo, tipo_registro, num_secuencia, num_banco, sentido, plaza_cce, servicio_tei, dia_transferencia, num_bloque, fecha_presenta, tipo_archivo, procesado, usuario_alta, fecha_alta) 
        VALUES (cNombreArchivo, cTipoRegistro, LPAD(iNumeroSecuenca, 7, '0'), 
		cNumeroBanco, cSentidoTransfer, cPlazaCecoban, cServicioTEI, LPAD(iDiaMesTransfer, 2, '0'), LPAD(pNoBloque, 5, '0'),
		cFechaPresenta, cTipoArchivo, "1", pUsuario, dFechaHoy);

		--==============================
		-- PROCESAMIENTO DEL DETALLE
		--==============================		
		SELECT  valor INTO cBancoCedente FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param ='5';
		SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';	
		LET iTotalChqProcesar = 1;
		FOREACH SELECT id_consultadetallecheque40, banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, chq_procesado, chq_compensacion,
				chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, transaccion, nombre_cte, rfc_cte,curp_cte,tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque,
				tam_rev_img_cheque, ejecutivo,direccion_mac,ind_duplicado,id_status_proceso 
				INTO iIdConsultaDetalleCheque40,cBanco,cDescBanco,cCuentaReferencia, cNumCheque,mImporte,cCuentaDeposito,cSucursalOperadora,cChqProcesado,cChqCompensacion,
				cChqTransaccion,cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,
				cEjecutivo,cDireccionMac,cIndDuplicado,cIdStatusProceso
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				--AND chq_procesado = '1'
				
				IF cIdStatusProceso = 'P' OR cIdStatusProceso = 'R'  THEN
					
				 SELECT COUNT(cNombreArchivo)
					INTO iChequeDuplicado
					FROM bditef:'informix'.cce_detalle
					WHERE cod_operacion = '40'
							AND bco_receptor = cBanco
							AND num_cuenta = cCuentaReferencia
							AND num_cheque = cNumCheque
							AND fecha_presini = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');
									
									
					IF iChequeDuplicado > 0 THEN
							LET cIndDuplicado= '1';
					END IF;
					
					IF cIndDuplicado = '1' THEN
						
						UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cc_consultadetallecheque40)}
						bdicnweb:'informix'.sw_cc_consultadetallecheque40
						SET (ind_img_cheque,ind_duplicado)=('3','1')
						WHERE id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
						
					ELSE			
						LET cTipoRegistro='02';
						LET cCodOperacion = '40';
						LET cNumSecuencia = LPAD(TO_CHAR(iBloqueInicial + iTotalChqProcesar),7,'0');											
						LET cFechatrasnfer = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');						
						LET cBancoCedente = LPAD(TRIM(cBancoCedente),3,'0');
						LET cBancoLibrado = LPAD(TRIM(cBanco),3,'0');
						
						-- formateo importe
						LET cImported = '';
						LET cImported = TO_CHAR(mImporte);
						LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
						LET cMonto = LPAD(TRIM(cMonto),13,'0');
						LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
						LET cImported = TRIM(cMonto || LPAD(TRIM(cCents),2,'0'));
						
						
						LET cLoteEntrada ='0000000';
						LET cSecEntrada = '0000';
						LET cLoteSAlida = '0000000';
						LET cSecSalida = '0000';
						LET cUbicFis = '00000000';											
						
						IF mImporte > mMontoImagen THEN
							LET cTruncado = '0';
							LET iTotalRegTruncados = iTotalRegTruncados + 1;
						ELSE
							LET cTruncado = '1';
						END IF;
						
						LET cMotivoDevol = '00'; -- fase de presentacion
						LET cFechaInicial = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');
						LET cPlazaIntercam = '01'; -- mexico df
						
						IF cRfcCte IS NULL OR  TRIM(cRfcCte) = '' THEN
							LET cRfcCte = 'RFC NO DISP';
						ELSE	
							LET cRfcCte = TRIM(cRfcCte);
						END IF;
						
						IF TRIM(cCurpCte) = '' OR cCurpCte IS NULL THEN
							LET cCurpCte = ' ';
						ELSE
							LET cCurpCte = TRIM(cCurpCte);
						END IF;
						
						LET cCtaAlertamiento = '00';
						
						SELECT numero INTO cTranSBCcheque FROM bdinteg:si_transacc where empresa= cEmpresa and abreviatura = 'DEPLOCALREGCC';
						
						IF cTransaccion <> 	cTranSBCcheque THEN
							LET cCtaAlertamiento = '99';
						ELSE
							EXECUTE PROCEDURE bditef:cta_alertamiento(cEmpresa, cCuentaDeposito) INTO cCodRetTrasacc, cCodAlertamiento;
							
							IF cCodRetTrasacc = '000' THEN
								LET cCtaAlertamiento = cCodAlertamiento;
							END IF;
							
						END IF;
						
						LET cFolioSeguro = ' ';
						LET cUsoFuturo = ' ';
						
						
						-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
						SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cCodOperacion||cFechatrasnfer||cBancoCedente||cBancoLibrado||cImported||
										cLoteEntrada||cSecEntrada||cLoteSAlida||cSecSalida||LPAD(cChqTransaccion,2,'0')||LPAD(TRIM(NVL(cChqCompensacion,'')),3,'0')||
										LPAD(TRIM(NVL(cCuentaReferencia,'')),13,'0')||LPAD(TRIM(NVL(cNumCheque,'')),10,'0')||LPAD(cChqDigVerInter,1,'0')||LPAD(cChqDigVerPre,1,'0')||
										LPAD(TRIM(NVL(cChqCodSeguridad,'')),3,'0')||cUbicFis||cTruncado||cMotivoDevol||cFechaInicial||cPlazaIntercam||LPAD(cRfcCte,13,' ')||
										LPAD(cCurpCte,18,' ')||LPAD(cTipoCuentaDep,2,'0')||LPAD(TRIM(NVL(cCuentaDeposito,'')),20,'0')||LPAD(cNombreCte,40,' ')||cCtaAlertamiento||
										LPAD(cFolioSeguro,12,' ')||LPAD(cUsoFuturo,120,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
										
						
					
						LET iTotalCheques = iTotalCheques + 1;	
						LET mTotalImporte = mTotalImporte + mImporte;

						
						-- GRABADO EN BASE DEL DETALLE
						EXECUTE PROCEDURE bditef:sp_cce_guardar_detalle(cNombreArchivo,cTipoRegistro,cNumSecuencia,cCodOperacion,cFechatrasnfer,
						cBancoCedente,cBancoLibrado,mImporte,cLoteEntrada,cSecEntrada,cLoteSAlida,cSecSalida,LPAD(cChqTransaccion,2,'0'),LPAD(cChqCompensacion,3,'0'),
						LPAD(cCuentaReferencia,13,'0'),LPAD(cNumCheque,10,'0'),LPAD(cChqDigVerInter,1,'0'),LPAD(cChqDigVerPre,1,'0'),LPAD(cChqCodSeguridad,3,'0'),
						cUbicFis,cTruncado,cMotivoDevol,cFechaInicial,cPlazaIntercam,cRfcCte,cCurpCte,LPAD(cTipoCuentaDep,2,'0'),
						cCuentaDeposito,cNombreCte,cCtaAlertamiento,cFolioSeguro) INTO cCodRetSp;
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_detalle';
						END IF;
						
						UPDATE bditef:cce_cheques_det 
						SET presentado = '1'
						WHERE empresa = cEmpresa AND
						cvebanco = cBanco AND
						numcheque = cNumCheque AND
						numcuenta = cCuentaReferencia AND
						fechapresenta = dFechaHoy; --TO_CHAR(DATE(dFechaHoy), 'MM/dd/YYYY');
						
						UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cc_consultadetallecheque40)}
						bdicnweb:'informix'.sw_cc_consultadetallecheque40
						SET chq_procesado='2'
						WHERE id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
						
						LET iTotalChqProcesar = iTotalChqProcesar + 1;
					END IF;
				END IF;
					LET cIndDuplicado= '0';
		END FOREACH;
		
		
		--==============================
		-- PROCESAMIENTO CCE SUMARIO
		--==============================
		LET cTipoSumario = '09';
		LET cNumSecuencia = LPAD(TO_CHAR(iTotalCheques + 2),7,'0');
		LET cCodOperacion = '40';
                                 --12 presentacion de consulta interbancaria - 46 Reverso presentacion
		LET cTotalRegs = LPAD(TO_CHAR(iTotalCheques),7,'0');
		
		LET cImportes = '';                 
		LET cImportes = TO_CHAR(mTotalImporte);
		LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
		LET cMontos = LPAD(TRIM(cMontos),16,'0');
		LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
		LET cImportes = TRIM(cMontos || LPAD(cCents,2,'0'));
		
		LET cTotalRegTruncados = TO_CHAR(iTotalRegTruncados);	
		LET cTotalRegTruncados = LPAD(TRIM(NVL(cTotalRegTruncados,'')),7,'0');
		LET cUsoFuturo = ' ';
		
		-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
		SYSTEM 'echo "'||cTipoSumario||cNumSecuencia||cCodOperacion||cTotalRegs||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,300,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
		
		EXECUTE PROCEDURE bditef:sp_cce_guardar_sumario(cNombreArchivo,cTipoSumario,cNumSecuencia,cCodOperacion,cTotalRegs,mTotalImporte,cTotalRegTruncados)INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_sumario';
		END IF;
		
		--==============================
		-- PROCESAMIENTO CCE GRAN  SUMARIO
		--==============================
		LET cTipoGranSumario = '51';
		LET cSentido = 'E';
		LET cCodOperacion = '40';
		LET cNumOperaciones =  LPAD(TRIM(NVL(TO_CHAR(iTotalCheques),'')),7,'0');
		LET cNumBloques = '01';
		
		LET cFolio = LPAD(pNoBloque,9,'0');
		LET cFecha = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');
		
		LET cImportes = '';                 
		LET cImportes = TO_CHAR(mTotalImporte);
		LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
		LET cMontos = LPAD(TRIM(cMontos),16,'0');
		LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
		LET cImportes = TRIM(cMontos || LPAD(cCents,2,'0'));
		LET cUsoFuturo=' ';
		
		-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
		SYSTEM 'echo "'||cTipoGranSumario||cSentido||cCodOperacion||cNumOperaciones||cNumBloques||cBancoCedente||cFolio||cFecha||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,284,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
		

		EXECUTE PROCEDURE bditef:sp_cce_guardar_gransumario(cNombreArchivo,cTipoGranSumario,cSentido,cCodOperacion,cNumOperaciones,cNumBloques,
		cBancoCedente,cFolio,cFecha,mTotalImporte,cTotalRegTruncados)INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_gransumario';
		END IF;
		
		RETURN cCodRet,iTotalRegTruncados,TRIM(cNombreArchivo)||'.cce';
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 18/02/2016',
'MODULO: Camara de Compensacion Electonica Presentada',
'FUNCIONALIDAD: Generacion de Archivo',
'DESCRIPCION: realiza la generacion del archivo Cod 40 a presentar',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 26/07/2024',
'DESCRIPCION: Se aÃ±ade el procedimiento almacenado de Reverso cuando el proceso del archivo llegue a fallar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consultatotalregtransacciontarjeta(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10),cNUMEROTARJETA CHAR(16),	cSECUENCIA CHAR(7),cREFERENCIA CHAR(12),
																cPOS_ATM CHAR(2),dPERIODOI DATE, dPERIODOF DATE)
							
			returning   CHAR(5)         AS  Cod_Retorno,	        
						INTEGER         AS  Num_registros;	   	

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
	

--VARIABLES DE PAGINACION
DEFINE iCont            INT;
DEFINE iMes int;
DEFINE iDia int;
DEFINE iAnio int;
DEFINE iMesF int;
DEFINE iDiaF int;
DEFINE iAnioF int;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	

--VARIABLES DE PAGINACION 
LET iCont       = 0;

LET iMes =0;
LET iDia =0;
LET iAnio =0;

LET iMesF =0;
LET iDiaF =0;
LET iAnioF =0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,iexiste;

		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/ifxsif01/emm/sp_cnsif_consultatotalregtransacciontarjeta.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMEROTARJETA  = '' OR 
		cPOS_ATM     = ''   OR
		dPERIODOI    = ''   OR 
		dPERIODOF 	 = ''	THEN 
		LET cCodRet = "00064";
		RETURN cCodRet,iexiste;
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMEROTARJETA,'25','3')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,iexiste;
	END IF;
	-- TERMINA VALIDACION		
	
	SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} NVL(COUNT(numtarjeta),0)	INTO iexiste FROM intercard:movimiento WHERE numtarjeta = cNUMEROTARJETA ;
	IF iexiste  = 0 THEN 
		SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)} NVL(COUNT(numtarjeta),0)	INTO iexiste FROM intercard:movimientohistorico WHERE numtarjeta = cNUMEROTARJETA ;
		IF iexiste  = 0 THEN
						LET cCodRet = "00065";
						RETURN cCodRet,iexiste;					
		END IF;
	END IF;
	
	
	LET iMes  = MONTH(dPERIODOI);
    LET iDia  = DAY(dPERIODOI);
    LET iAnio = YEAR(dPERIODOI);
	
	LET iMesF  = MONTH(dPERIODOF);
    LET iDiaF  = DAY(dPERIODOF);
    LET iAnioF = YEAR(dPERIODOF);

	IF (cSECUENCIA = '' AND cREFERENCIA = '') THEN
        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)} LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
			ORDER BY CONT DESC
				
        END FOREACH;              
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;

	ELIF (cSECUENCIA != '' AND cREFERENCIA = '') THEN
        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)} LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
			ORDER BY CONT DESC
				
        END FOREACH;
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;
		
	ELIF (cSECUENCIA = '' AND cREFERENCIA != '') THEN	

        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)}  LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND referencia = cREFERENCIA
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND referencia = cREFERENCIA
			ORDER BY CONT DESC
				
        END FOREACH;
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;

	ELIF (cSECUENCIA != '' AND cREFERENCIA != '') THEN	
        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)} LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
				AND referencia = cREFERENCIA
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
				AND referencia = cREFERENCIA
				
        END FOREACH;
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;
	END IF		
	
END
END PROCEDURE
DOCUMENT
"AutOR : OSCAR FLORES CONDE	",
"FUNCIONAMIENTO:Obtiene el numero de registros con la informaciÃ³n de los Movimientos de Tarjeta POS/ATM. ",
"El SP obtendrÃ¡ la informaciÃ³n de la Base de Datos central de Informix, enviando como parÃ¡metro el  No. de Tarjeta o Secuencia/Referencia.",
"FECHA : 25-11-2013",
"BD    : bdicnweb",
"VER   : 1.0",
'AUTOR: KARLOS GOMEZ D',
'FECHA: 23/08/2024',
'DESCRIPCION: Se eliminaron las consultas a las tablas inexistentes intercard:movimientohistorico_2014, intercard:movimientohistorico_2013, e intercard:movimientohistorico_2012.',
"VER   : 2.0"
;

CREATE PROCEDURE "informix".sp_cnsif_consdetallemovimientos_totales_pba4(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pFechaInicial DATE, pFechaFinal DATE, pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2), pEjecucion CHAR(1), pClaveMov CHAR(50))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE iContReg INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	DEFINE cClaveMov CHAR(50);
	DEFINE iPid INTEGER;
	DEFINE cTmpTable CHAR(5000);
	
	DEFINE iCont INTEGER;
	
	LET iPid = DBINFO('sessionid');
	LET cTmpTable = '';
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET iContReg = 0;
	LET iNumRegistros = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	LET cClaveMov = 'ArchivosMov_'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	
	LET iCont = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				IF pEjecucion = '1' OR pEjecucion = '3' THEN
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				END IF;
				
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-668, -535, -255)
		END EXCEPTION WITH RESUME;
		
		
		--SET EXPLAIN FILE TO "sqexplain.bdicnweb.sp_cnsif_consdetallemovimientos_totales.out";
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
			
		SET DEBUG FILE TO '/controlcambios/P-BD-20240904-01/sp_cnsif_consdetallemovimientos_totales.out';
		TRACE ON;
		
		IF pEjecucion = '1' OR pEjecucion = '3' THEN
			-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
			INSERT INTO bdicnweb:"informix".sw_cons_statusproceso(usuario,status,num_registros,clave_mov,error_proceso,error)
			VALUES(pUsuario,'I',0,pClaveMov,'',cCodRet);  
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pEjecucion = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;	
				
		-- CONSULTA TOTALES
		IF pEjecucion = '1' THEN
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_consultatotalmovtosdiarioscta_2(pUsuario,pIdFuncion,pNumCuenta,pFechaInicial,pFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte)
			INTO cCodRetSp,iNumRegistros;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultatotalmovtosdiarioscta_2';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
			
			RETURN cCodRet, iNumRegistros;
		
		-- TOTALES PARA MASIVO
		ELIF pEjecucion = '2' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
			INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				RETURN cCodRet, iNumRegistros;
			END IF;
				
{-OPTIMIZACION STK202404+}
			SELECT COUNT(*)		
			  INTO iNumRegistros
			  FROM bdicnweb:"informix".sw_cons_movimientos		
			 WHERE sis_cuenta = pSistemaCuenta
			   AND clave_mov = pClaveMov;
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNumRegistros;
			END IF;
{-OPTIMIZACION STK202404+}
			
			RETURN cCodRet, iNumRegistros;
			
		-- TOTALES PARA NO MASIVOS
		ELIF pEjecucion = '3' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
				INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
				cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
					RETURN cCodRet, iNumRegistros;
				END IF;
				
{-OPTIMIZACION STK202404}
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cons_movimientos
			WHERE sis_cuenta = pSistemaCuenta
              AND clave_mov = pClaveMov; 			
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
{ -OPTIMIZACION STK202404}
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
						
			RETURN cCodRet, iNumRegistros;
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACION/CREDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros que regresara la busqueda por sistema de cuenta ingresado (CAPTACION/CREDITO/INVERSIONES).',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 06/11/2017',
'DESCRIPCION: Se modifica SPL para agregar como filtro el sistema cuenta cuando se hace la limpieza de la tabla sw_cons_movimientos.',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION :  Se agregan variables cFechaInicial  y  cFechaFinal, para tratar la fecha como MM/DD/YYYY ',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION :  Se cambian variables cFechaInicial  y  cFechaFinal a Date ',
'AUTOR: Rodolfo Conde Flores',
'FECHA 08/01/2018',
'DESCRIPCION MODIFICACION: Se implementa el llamado de un spl que retorna el numero total de registros antes de inicar el llenado de la tabla principal.',
'Se crea la estructura de nuevas tablas espejo para evitar el bloqueo de la tabla principal.',
'AUTOR: Martha Salgado',
'FECHA 11/01/2018',
'DESCRIPCION MODIFICACION: Se validan valores null cuando pEjecucion = 2.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creacion de tabla temporal por tabla fisica para almacenamiento de informacion de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creacion de tabla temporal por tabla fisica para almacenamiento de informacion de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina el campo usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Martha Salgado',
'FECHA 18/01/2019',
'DESCRIPCION MODIFICACION: Se elimina tabla sw_cons_tempo_movimientos y se agrega variable iCont.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 25/01/2019',
'DESCRIPCION MODIFICACION: Se modifica implementacion de ejecuciÃ³n COMMIT sobre SPL sp_cnsif_consultamovtosdiarioscta3_2.',
'BD: bdicnweb',
'OPTIMIZACION STK202404',
'Modificado: Softtek / A.Canseco 04,07.2024',
'OPTIMIZACION STK202404';

CREATE PROCEDURE "informix".sp_cnsif_consdetallemovimientos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pFechaInicial DATE, pFechaFinal DATE, pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2), pEjecucion CHAR(1), pClaveMov CHAR(50))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE iContReg INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	DEFINE cClaveMov CHAR(50);
	DEFINE iPid INTEGER;
	DEFINE cTmpTable CHAR(5000);
	--DEFINE iCont  INT;
	
	DEFINE iCont INTEGER;
    DEFINE sCommit SMALLINT;
	
	LET iPid = DBINFO('sessionid');
	LET cTmpTable = '';
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET iContReg = 0;
	LET iNumRegistros = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	LET cClaveMov = 'ArchivosMov_'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	--LET iCont = 0;
	
	LET iCont = 0;
    LET sCommit = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				--IF sCommit = -1 THEN
				--	ROLLBACK WORK;
				--END IF;
								
				IF ven_transacc = 1 THEN
					--ROLLBACK WORK;		
				END IF;
				
				
				LET cCodRet = iSqlErr;
				IF pEjecucion = '1' OR pEjecucion = '3' THEN
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				END IF;
				
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consdetallemovimientos_totales.out';
		--TRACE ON;
		
		IF pEjecucion = '1' OR pEjecucion = '3' THEN
			-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
			INSERT INTO bdicnweb:"informix".sw_cons_statusproceso(usuario,status,num_registros,clave_mov,error_proceso,error)
			VALUES(pUsuario,'I',0,pClaveMov,'',cCodRet);  
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pEjecucion = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;	
				
		-- CONSULTA TOTALES
		IF pEjecucion = '1' THEN
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_consultatotalmovtosdiarioscta_2(pUsuario,pIdFuncion,pNumCuenta,pFechaInicial,pFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte)
			INTO cCodRetSp,iNumRegistros;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultatotalmovtosdiarioscta_2';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
			
			RETURN cCodRet, iNumRegistros;
		
		-- TOTALES PARA MASIVO
		ELIF pEjecucion = '2' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
			FOREACH
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
				INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
				cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, iNumRegistros;
				END IF;
				
			END FOREACH;
						
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cons_movimientos		
			WHERE sis_cuenta = pSistemaCuenta AND clave_mov = pClaveMov; 
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			RETURN cCodRet, iNumRegistros;
			
		-- TOTALES PARA NO MASIVOS
		ELIF pEjecucion = '3' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
			FOREACH
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
				INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
				cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
					RETURN cCodRet, iNumRegistros;
				END IF;
				
			END FOREACH;
									
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cons_movimientos 
			WHERE sis_cuenta = pSistemaCuenta AND clave_mov = pClaveMov; 			
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
						
			RETURN cCodRet, iNumRegistros;
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÃN/CRÃDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros que regresarÃ¡ la bÃºsqueda por sistema de cuenta ingresado (CAPTACION/CREDITO/INVERSIONES).',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 06/11/2017',
'DESCRIPCION: Se modifica SPL para agregar como filtro el sistema cuenta cuando se hace la limpieza de la tabla sw_cons_movimientos.',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION :  Se agregan variables cFechaInicial  y  cFechaFinal, para tratar la fecha como MM/DD/YYYY ',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION :  Se cambian variables cFechaInicial  y  cFechaFinal a Date ',
'AUTOR: Rodolfo Conde Flores',
'FECHA 08/01/2018',
'DESCRIPCION MODIFICACION: Se implementa el llamado de un spl que retorna el numero total de registros antes de inicar el llenado de la tabla principal.',
'Se crea la estructura de nuevas tablas espejo para evitar el bloqueo de la tabla principal.',
'AUTOR: Martha Salgado',
'FECHA 11/01/2018',
'DESCRIPCION MODIFICACION: Se validan valores null cuando pEjecucion = 2.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creaciÃ³n de tabla temporal por tabla fÃ­sica para almacenamiento de informaciÃ³n de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creaciÃ³n de tabla temporal por tabla fÃ­sica para almacenamiento de informaciÃ³n de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina el campo usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Martha Salgado',
'FECHA 18/01/2019',
'DESCRIPCION MODIFICACION: Se elimina tabla sw_cons_tempo_movimientos y se agrega variable iCont.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 25/01/2019',
'DESCRIPCION MODIFICACION: Se modifica implementaciÃ³n de ejecuciÃ³n COMMIT sobre SPL sp_cnsif_consultamovtosdiarioscta3_2.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consctedetalle_3(cID_USUARIOC char(8),cID_FUNCIONC char(10),cnumcte char(20),cTPERSONA CHAR(6))
    RETURNING 	CHAR(5)  AS Cod_Retorno,  
				CHAR(20) AS Numero_Cliente, 
				CHAR(15) AS Nacionalidad, 
				CHAR(100) AS E_Mail, 
				CHAR(8)  AS Ejecutivo,  
				CHAR(1)  AS Cve_Domiciliacion,   
				CHAR(30) AS Desc_Domiciliacion, 
				CHAR(1)  AS Cve_BPI,  
				CHAR(30) AS Desc_BPI, 
				CHAR(1)  AS Cve_Pagos, 
				CHAR(30) AS Desc_Pagos,  
				CHAR(20) AS Estado_Civil,  
				CHAR(2)  AS Cve_Lugar_Nacimiento,  
				CHAR(18) AS FM3, 
				CHAR(20) AS CURP, 
				CHAR(30) AS Escolaridad, 
				CHAR(60) AS Profesion,
                CHAR(20) AS Cliente_Co, 
				CHAR(60) AS Puesto_PPES, 
				CHAR(45) AS Actividad_Especial, 
				CHAR(20) AS Familiar_PPES, 
				CHAR(60) AS Razon_Social, 
				CHAR(60) AS Sufijo,  
				CHAR(30) AS Pagina_Internet, 
				CHAR(40) AS Giro, 
				CHAR(45) AS Actividad_Social, 
				CHAR(48) AS Nombre_Titular, 
				CHAR(25) AS SAT_FEA, 
				CHAR(15) AS Telefono_Contacto,  
				CHAR(30) AS Escritura_Constitutiva, 
				CHAR(30) AS Nombre_Notario_CT, 
				CHAR(5)  AS Numero_Notario_CT,  
				CHAR(30) AS Ciudad_Notario_CT, 
				DATE     AS Fecha_Inscripcion_CT,
                DATE     AS Fecha_Contit_CT, 
				CHAR(30) AS Escritura_Poderes, 
				CHAR(30) AS Nombre_Notario_PD, 
				CHAR(5)  AS Numero_Notario_PD,  
				CHAR(30) AS Ciudad_Notario_PD, 
				DATE     AS Fecha_Inscripcion_PD, 
				CHAR(50) AS Nombre_Sociedad,  
				CHAR(4)  AS Sucursal, 
				DATE     AS Fecha_Alta,
				CHAR(30) AS Desc_Lugar_Nacimiento,
				CHAR(50) AS Desc_ActividadEco, 
				CHAR(50) AS Desc_subActividadEco;

				
	--Variables en comun
	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE cNumeroCliente	CHAR(20);
	DEFINE cNacionalidad 	CHAR(15);
	DEFINE cCdomiciliacion	CHAR(1);
	DEFINE cDDomiliciacion	CHAR(30);
	DEFINE cCBPI			CHAR(1);
	DEFINE cDBPI			CHAR(30);
	DEFINE cCpagos			CHAR(1);
	DEFINE cDpagos			CHAR(30);
	DEFINE cTpo_persona 	CHAR(2);
	DEFINE cActividadEc		CHAR(50);
	DEFINE cSubActividadEc	CHAR(50);

	--VARIABLES CORREO ELECTRONICO
	DEFINE vcodret1         CHAR(3);
	DEFINE vtipocorreo      SMALLINT;
	DEFINE vstatuscorreo    CHAR(1);
	
	--Variables persona fisica 
	DEFINE cEstado_civil  	CHAR(20);
	DEFINE clugar_nac 		CHAR(2);
	DEFINE cNo_fm3 			CHAR(18);
	DEFINE cCurp			CHAR(20);
	DEFINE cEscolaridad 	CHAR(30);
	DEFINE cProfesion 		CHAR(60);
	DEFINE cEmail			CHAR(100);
	DEFINE cClienteCop		CHAR(20);
	DEFINE cEjecutivo		CHAR(8);
	DEFINE cPuesto_ppes		CHAR(2);
	DEFINE CDPuesto_ppes    CHAR(60);
	DEFINE cActividad_esp	CHAR(45);
	DEFINE cFamiliar_ppes	CHAR(20);


    --Variables persona moral
	DEFINE crazon_social		CHAR(120);
	DEFINE csufijo				CHAR(60);
	DEFINE cpagina_internet		CHAR(30);
	DEFINE cgiro				CHAR(40);
	DEFINE cDActividad_social 	CHAR(45);
	DEFINE cnombre_titular		CHAR(48);
	DEFINE csat_fea				CHAR(25);
	DEFINE ctelefono_contacto 	CHAR(15);
	DEFINE cemailpm				CHAR(100);
	DEFINE cescritura_constitutiva CHAR(30);
	DEFINE cnombre_notarioct	CHAR(30);
	DEFINE cnumero_notarioct	CHAR(5);
	DEFINE cciudad_notarioct	CHAR(30);
	DEFINE cfecha_inscrip		DATE;
	DEFINE cfecha_constitct		DATE;
	DEFINE cescritura_poderes	CHAR(30);
	DEFINE cnombre_notariopd	CHAR(30);
	DEFINE cnumero_notariopd	CHAR(5);
	DEFINE cciudad_notariopd	CHAR(30);
	DEFINE cfecha_inscrippd		DATE;
	DEFINE cnombre_sociedad		CHAR(50);	
	DEFINE cSucursal			CHAR(4);
	DEFINE dFecha_alta			DATE;
	DEFINE cEjecutivo_alta		CHAR(8);
	DEFINE iTpo_cliente			INT;
	DEFINE cNumCtePrincipal 	CHAR(20);
	DEFINE cDescLugarNacimiento CHAR(30);
	--Variables persona fisica 
	LET cEstado_civil = "";  	
	LET clugar_nac 	= "";
	LET cNo_fm3 		= "";
	LET cCurp			= "";
	LET cEscolaridad 	= "";
	LET cProfesion 		= "";
	LET cEmail			= "";
	LET cClienteCop		= "";
	LET cEjecutivo		= "";
	LET cPuesto_ppes	= "";
	LET cDPuesto_ppes	= "";
	LET cActividad_esp	= "";
	LET cFamiliar_ppes	= "";

    --Variables persona moral
	LET crazon_social		= "";
	LET csufijo				= "";
	LET cpagina_internet	= "";
	LET cgiro				= "";
	LET cDActividad_social 	= "";
	LET cnombre_titular		= "";
	LET csat_fea			= "";
	LET ctelefono_contacto 	= "";
	LET cemailpm			= "";
	LET cescritura_constitutiva = "";
	LET cnombre_notarioct	= "";
	LET cnumero_notarioct	= "";
	LET cciudad_notarioct	= "";
	LET cfecha_inscrip		= "";
	LET cfecha_constitct	= "";
	LET cescritura_poderes	= "";
	LET cnombre_notariopd	= "";
	LET cnumero_notariopd	= "";
	LET cciudad_notariopd	= "";
	LET cfecha_inscrippd	= "";
	LET cnombre_sociedad	= "";	
	LET cSucursal			= "";
	LET cEjecutivo_alta		= "";
	LET dFecha_alta			= "";
	
	--Variables en comun
	LET iexiste 		= 0;
	LET cCodRet 		= "00000";
	LET iSql_err 		= 0;
	LET cNumeroCliente	= "";
	LET cNacionalidad 	= "";
	LET cCdomiciliacion	= "";
	LET cDDomiliciacion	= "";
	LET cCBPI			= "";
	LET cDBPI			= "";
	LET cCpagos			= "";
	LET cDpagos			= "";
	LET cTpo_persona    = "";
	LET cActividadEc 	= "";
	LET cSubActividadEc	= "";

	--VARIABLES CORREO ELECTRONICO
	LET vcodret1       = "";
	LET vtipocorreo    = 0;
	LET vstatuscorreo  = "";
	LET iTpo_cliente=0;
	LET cNumCtePrincipal = "";
	LET cDescLugarNacimiento="";
	
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;

            END IF;
        END EXCEPTION;
			--SET DEBUG FILE TO "/tmp/mfinis/Antonio/sp_cnsif_consctedetalle3.out";
			--TRACE ON;	

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

		IF 	cID_USUARIOC ='' 	OR 
			cID_FUNCIONC = '' 	OR 
			cNumcte = '' 		OR 
			cTPERSONA = '' 		THEN
			LET cCodRet = "00054";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
		END IF;		
		IF  cTPERSONA <>'MORAL' AND cTPERSONA <>'FISICA' THEN
			LET cCodRet = "00052";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
		END IF;
		
		--VALIDACION
		EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cnumcte,'11','2')
		INTO
		cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN  cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
					cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
					cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
					cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;
		END IF;
	-- TERMINA VALIDACION		
	
--TRANSFER
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

		FOREACH
		SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste  FROM bdinteg:si_cliente where numcte = cnumcte
		UNION
		SELECT NVL(COUNT(numcte_tf),0)  FROM bditransfer:tf_maecte where numcte_tf = cnumcte
		ORDER BY 1 DESC
		END FOREACH;		
--TRANSFER			
		IF iexiste = 0 THEN
			LET cCodRet = "00055";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
		END IF;
		SELECT NVL(COUNT(num_cte),0) INTO iexiste FROM bdidomi:dom_autorizaciones WHERE num_cte = cnumcte  and cve_estatus = '01';
		IF iexiste = 0 THEN
			LET cCdomiciliacion = "0";
			LET cDDomiliciacion = "Domiciliacion";
			LET iexiste  = 0;
		ELIF iexiste >=  1 THEN 
			LET cCdomiciliacion = "1";
			LET cDDomiliciacion = "Domiciliacion";
			LET iexiste  = 0;
		END IF	
		select NVL(COUNT(numcliente),0) INTO iexiste FROM  bdibpi:bpi_usuario WHERE numcliente = cnumcte AND st_portal='activo';
		IF iexiste = 0 THEN 
			LET cCBPI = '0';
			LET cDBPI = "Banca por internet";
			LET iexiste = 0;
		ELIF iexiste >=  1 THEN 
			LET cCBPI = '1';
			LET cDBPI = "Banca por internet";
			LET iexiste = 0;
		END IF
		SELECT  NVL(COUNT(num_cte),0) INTO iexiste FROM  bdiprog:pp_pagoprog WHERE num_cte = cnumcte;
		IF iexiste = 0 THEN 
			LET cCpagos ='0';
			LET cDpagos = "Pagos programados";
			LET iexiste = 0;
		ELIF iexiste >=  1 THEN 
			LET cCpagos ='1';
			LET cDpagos = "Pagos programados";
			LET iexiste = 0;
		END IF 
		--VERIFICA EXISTENCIA EN ctppes
		SELECT NVL(COUNT(numcte),0) INTO iexiste FROM bdinteg:"informix".si_cteppes WHERE numcte = cnumcte;
		IF iexiste > 0 AND cTPERSONA ='FISICA' THEN 
			SELECT LIMIT 1 puesto_ppes
			INTO cPuesto_ppes
			FROM bdinteg:"informix".si_cteppes			
			WHERE numcte = cnumcte
			AND numeroregistro = (SELECT max(numeroregistro) FROM bdinteg:"informix".si_cteppes WHERE numcte = cnumcte);
			
		    SELECT descripcion 
			INTO cDPuesto_ppes
			FROM bdinteg:"informix".si_puestosppes
			WHERE puesto_ppes = cPuesto_ppes;
			
			LET iexiste = 0;
		END IF
		SELECT tpo_persona INTO cTpo_persona FROM bdinteg:si_cliente where numcte =  cnumcte;
		IF cTPERSONA ='FISICA' THEN -- si el tipo de cliente es persona fisica	
			IF cTpo_persona = '01' THEN 
				SELECT LIMIT 1 CL.numcte,NA.descripcion,CF.estado_civil,CF.lugar_nac,CF.no_fm3,CF.curp,ES.descripcion,NVL(PRO.descripcion, ''),
					   CL.ejecutivo,AE.descripcion, PA.descripcion,CL.numcte_ref,EDO.NOMBRE
						
				INTO cNumeroCliente, cNacionalidad,	cEstado_civil,clugar_nac,cNo_fm3, cCurp, cEscolaridad,cProfesion, 
					 cEjecutivo_alta,cActividad_esp,cFamiliar_ppes,cClienteCop,cDescLugarNacimiento
						
				FROM bdinteg:si_cliente CL 
				LEFT JOIN bdinteg:si_ctepf CF
				ON CL.numcte = CF.numcte
				LEFT JOIN bdinteg:si_nacion NA
				ON NA.nacion = CF.nacionalidad
				LEFT JOIN bdinteg:si_escolaridad ES
				ON ES.escolaridad = CF.escolaridad
				LEFT JOIN bdinteg:si_profesion PRO
				ON PRO.profesion = CF.profesion --> ProfesiÃ³n
				LEFT JOIN bdinteg:si_ingresos PR 
				ON PR.numcte = CL.numcte
				LEFT JOIN bdinteg:si_actsubact PRD 
				ON PRD.id_act = PR.claveopcionpuesto and PRD.id_subact = 0
				LEFT JOIN bdinteg:si_actesp AE
				ON  AE.codigo = CL.actividad_esp
				LEFT JOIN bdinteg:si_parentesco PA
				ON PA.parentesco = CL.familiar_ppes
				LEFT JOIN bdinteg:si_estados EDO 
				ON EDO.ESTADO=CF.lugar_nac
				
				WHERE CL.numcte = cnumcte; 
				IF cEstado_civil ='D' THEN
					LET cEstado_civil ='DIVORCIADO';
				END IF;
				IF cEstado_civil ='C' THEN
					LET cEstado_civil ='CASADO';
				END IF;
				IF cEstado_civil ='S' THEN
					LET cEstado_civil ='SOLTERO';
				END IF;
				IF cEstado_civil ='V' THEN
					LET cEstado_civil ='VIUDO';
				END IF;
				IF cEstado_civil ='U' THEN
					LET cEstado_civil ='UNION LIBRE';
				END IF;
                --BUSCA CORREO ELECTRONICO
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos('001',cnumcte,1,'0')
					INTO
					vcodret1,cEmail,vtipocorreo,vstatuscorreo
				END FOREACH;

				--BUSCA LA ACTIVIDAD ECONOMICA.
				
				SELECT LIMIT 1 NVL(descrip, '') 
				INTO cActividadEc
				FROM bdinteg:si_ingresos si
				INNER JOIN bdinteg:si_actsubact act 
				ON si.claveopcionpuesto = act.id_act 
				AND id_subact in ('0','99')
				WHERE sec_ingreso = (SELECT MAX(sec_ingreso) FROM  bdinteg:si_ingresos WHERE numcte = TRIM(cnumcte))
				AND numcte = cnumcte;

				--BUSCA LA SUB ACTIVIDAD ECONOMICA.     
				SELECT LIMIT 1 NVL(descrip, '') 
				INTO cSubActividadEc
				FROM bdinteg:si_ingresos si
				INNER JOIN bdinteg:si_actsubact act 
				ON si.claveopcionpuesto = act.id_act 
				AND id_subact = clavesubopcionpuesto
				WHERE sec_ingreso = (SELECT MAX(sec_ingreso) FROM  bdinteg:si_ingresos WHERE numcte = TRIM(cnumcte))
				AND numcte = cnumcte;
				
                --SELECT LIMIT 1 nvl(co_numcte,'') INTO cClienteCop FROM bdisolic:ss_solicitudes WHERE numcte =cnumcte AND empresa='001' AND co_numcte is not null;

                RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc with resume;
			ELIF cTpo_persona <> '01' THEN 
				LET cCodRet = "00052";
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
			END IF		
		ELIF  cTPERSONA='MORAL' THEN -- si el cliente es de tipo moral 
			IF cTpo_persona ='02' THEN 
				SELECT {+INDEX (bdinteg:"informix".si_ctepm 461_1018)} CL.numcte,CL.razon_social,SU.descripcion, PM.nacionalidad,PM.pagina_internet,AC.nombre,SA.descripcion,
				PM.sat_fea,PM.telefono_contacto,PM.escritura_constitutiva,PM.nombre_notarioct,PM.numero_notarioct,PM.ciudad_notarioct,
				PM.fecha_inscrip, PM.fecha_constitct,PM.escritura_poderes,PM.nombre_notariopd,PM.numero_notariopd,PM.ciudad_notariopd,
				PM.fecha_inscrippd,PM.nombre_sociedad,PM.sucursal,CL.ejecutivo,CL.fecha_alta
				INTO
				cNumeroCliente,crazon_social,csufijo,cNacionalidad,cpagina_internet,cgiro,cDActividad_social,csat_fea,ctelefono_contacto,cescritura_constitutiva,
					cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip, cfecha_constitct,cescritura_poderes,cnombre_notariopd,cnumero_notariopd,
					cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,cEjecutivo_alta,dFecha_alta
				FROM bdinteg:si_cliente CL
				LEFT JOIN bdinteg:si_ctepm PM
				ON PM.numcte = CL.numcte
				LEFT JOIN bdinteg:si_sufijos SU
				ON SU.codigo=PM.sufijo
				LEFT JOIN bdinteg:si_actecon AC
				ON AC.actividad = SUBSTRING(PM.giro FROM 1 FOR 3)
				LEFT JOIN bdinteg:si_actividadsocial SA
				ON SA.codigo = PM.actividadsocial
				WHERE  PM.numcte = cnumcte;

                IF LENGTH(cNacionalidad)=1 THEN
                    LET cNacionalidad='00'||TRIM(cNacionalidad);
                ELIF LENGTH(cNacionalidad)=2 THEN
                    LET cNacionalidad='0'||TRIM(cNacionalidad);
                ELIF LENGTH(cNacionalidad)=3 THEN
                    LET cNacionalidad=TRIM(cNacionalidad);
                ELSE
                    LET cNacionalidad='025';
                END IF;
                				
                SELECT descripcion INTO cNacionalidad FROM bdinteg:si_nacion
                WHERE nacion=cNacionalidad;
				
				SELECT nombreapoderado
				INTO cnombre_titular
				FROM bdinteg:si_apoderado
				WHERE empresa = '001' 
				AND numcte = cnumcte
				AND secuencia = 1;
				
				SELECT correo_elec
				INTO cEmail
				FROM bdinteg:si_correos
				WHERE numcte = cnumcte 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cnumcte);

								
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc with resume;
			ELIF cTpo_persona <> '02' THEN 
				LET cCodRet = "00052";
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
			END IF			
		END IF
		IF 	cTpo_persona IS NULL THEN 
			RETURN 
			cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
            cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
            cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
            cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;
		END IF
    END
END PROCEDURE
DOCUMENT		
"AUTOR : JosÃ© Antonio Ramirez Franco",
"FUNCIONAMIENTO:SP Clon de sp_cnsif_consctedetalle se encarga de Realizar la busqueda de los datos del cliente dependiendo si es persona fisica o moral, evaluar el numero de cliente y dependiendo del tipo cliente",
"haga la busqueda ya sea persona fisica o moral y regrese los valores correspondientes",
"FECHA : 23-10-2023",
"MODIFICO : JosÃ© Antonio Ramirez Franco",
"DESCRIPCION: Se agrega ID de subactividad economica al momento de consultar la actividad economica",
"FECHA : 20-08-2024",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_consproductoscap(pIdProducto INT)
    RETURNING CHAR(5)  AS codret,
			  INT AS idProducto, 
			  CHAR(200) AS tasaintvariable, 
			  CHAR(10) AS gatNominal, 
			  CHAR(10) AS gatReal, 
			  CHAR(200) AS comisionRel1, 
			  CHAR(200) AS comisionRel2, 
			  CHAR(200) AS mediosDisposicion, 
			  CHAR(200) AS lugEfectRetiros;

    --DECLARACÃON DE VARIABLES
    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdProducto INT;
	DEFINE cTasaintvariable CHAR(200);
	DEFINE cGatNominal CHAR(10);
	DEFINE cGatReal CHAR(10);
	DEFINE cComisionRel1 CHAR(200);
	DEFINE cComisionRel2 CHAR(200);
	DEFINE cMediosDisposicion CHAR(200);
	DEFINE cLugEfectRetiros CHAR(200);
	
    --INICIALIZACIÃN
    LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdProducto = 0;
	LET cTasaintvariable = ''; 	
	LET cGatNominal = '';
	LET cGatReal = '';
	LET cComisionRel1 = '';
	LET cComisionRel2 = '';
	LET cMediosDisposicion = '';
	LET cLugEfectRetiros = '';
	
    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consproductoscap.out';
		--TRACE ON;
		
		IF pIdProducto = 0 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT id_prod, tasa_interes_variable, gat_nominal, gat_real, comision_relevante1, comision_relevante2, medios_disposicion, lugares_efectuar_retiros
		INTO iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros
		FROM bdicnweb:"informix".sw_cons_productoscaptacion
		WHERE id_prod = pIdProducto;

		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
		END IF;
		
		RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 15/08/2024',
'DESCRIPCION: SPL encargado de realizar la consulta para obtener los valores de los productos de captaciÃ³n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_generaportadactamec(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCta CHAR(20))
    RETURNING CHAR(5) 	AS      codret,                 --Codigo de retorno
		CHAR(4)         AS      codProducto,            --CODIGO DEL PRODUCTO
		CHAR(40)        AS      nomProducto,            --NOMBRE DEL PRODUCTO
		CHAR(254)       AS      razonSoc,               --RAZON SOCIAL
		CHAR(20)        AS      numCliente,             --NUMERO DEL CLIENTE
		CHAR(20)        AS      numCuenta,              --NUMERO DE LA CUENTA
		CHAR(18)        AS      clabe,                  --NUMERO CLABE
		CHAR(1)         AS      claveRegimen,           --CLAVE DEL REGIMEN DE FIRMAS
		CHAR(20)        AS      regimenFirmas,          --REGIMEN DE FIRMAS
		CHAR(20)        AS      especiManejo,           --ESPECIFICACIONES DE MANEJO, COMBINACION
		CHAR(13)        AS      rfc,                    --RFC
		DATE            AS      fechaOperacion,     --FECHA DE LA OPERACION
		CHAR(104)       AS      nombreFirmante,         --NOMBRE DE EL FIRMANTE
		CHAR(1)         AS      tipoFirma,              --TIPO DE FIRMA
		CHAR(4)         AS      sucursal,               --NUMERO DE SUCURSAL
		CHAR(40)        AS      nomsuc,                 --NOMBRE DE SUCURSAL
		CHAR(60)        AS      reca,                   --DESCRIPCION DEL RECA
		CHAR(10)        AS      hora_operacion, 
		CHAR(20)        AS      folio_operacion, 
		CHAR(3)         AS      codigo_empresa,
		CHAR(20)        AS      cuenta_ligada;
                
                
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE  cCodProducto            CHAR(4);        --CODIGO DEL PRODUCTO   
	DEFINE  cNomProducto            CHAR(40);       --NOMBRE DEL PRODUCTO   
	DEFINE  cRazonSoc               CHAR(254);      --RAZON SOCIAL  
	DEFINE  cNumCliente             CHAR(20);       --NUMERO DEL CLIENTE    
	DEFINE  cNumCuenta              CHAR(20);       --NUMERO DE LA CUENTA   
	DEFINE  cClabe                  CHAR(18);       --NUMERO CLABE  
	DEFINE  cClaveRegimen           CHAR(1);        --CLAVE DEL REGIMEN DE FIRMAS   
	DEFINE  cRegimenFirmas          CHAR(20);       --REGIMEN DE FIRMAS     
	DEFINE  cEspeciManejo           CHAR(20);       --ESPECIFICACIONES DE MANEJO, COMBINACION       
	DEFINE  cRfc                    CHAR(13);       --RFC   
	DEFINE  dFechaOperacion     DATE;               --FECHA DE LA OPERACION 
	DEFINE  cNombreFirmante         CHAR(104);      --NOMBRE DE EL FIRMANTE 
	DEFINE  cTipoFirma              CHAR(1);        --TIPO DE FIRMA 
	DEFINE  cSucursal               CHAR(4);        --NUMERO DE SUCURSAL    
	DEFINE  cNomsuc                 CHAR(40);       --NOMBRE DE SUCURSAL    
	DEFINE  cReca                   CHAR(60);       --RECA
	DEFINE cHoraOperacion           CHAR(10);       --HORA DE GENERACIï¿½N DE LA CONSULTA
	DEFINE cFolioOperacion          CHAR(20);       --NUMERO DE CUENTA + PREFIJO P
	DEFINE cCodigoEmpresa           CHAR(3);
	DEFINE cCuentaLigada            CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET     cCodProducto    = "";
	LET     cNomProducto    = "";
	LET     cRazonSoc       = "";
	LET     cNumCliente     = "";
	LET     cNumCuenta      = "";
	LET     cClabe          = "";
	LET     cClaveRegimen   = "";
	LET     cRegimenFirmas  = "";
	LET     cEspeciManejo   = "";
	LET     cRfc            = "";
	LET     dFechaOperacion = "";
	LET     cNombreFirmante = "";
	LET     cTipoFirma      = "";
	LET     cSucursal       = "";
	LET     cNomsuc         = "";
	LET     cReca           = "";
	LET     cHoraOperacion  = "";
	LET     cFolioOperacion = "";
	LET     cCodigoEmpresa  = "";
	LET     cCuentaLigada   = "";

		--, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada
        
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_generaportadactamec.out';
		--TRACE ON;
                
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		ELIF pNumCta = '' AND pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		END IF;
        
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCta, '01', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		END IF;
                
		-- SE BUSCAN LOS DATOS DE HORA DE OPERACION, FOLIO DE OPERACION, CODIGO DE LA EMPRESA Y CUENTA LIGADA
		LET cHoraOperacion = SUBSTR(TO_CHAR(CURRENT, '%r'), 0, 8);
		LET cFolioOperacion = 'P'||TRIM(pNumCta);
				
        FOREACH 
			EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_generarptportada2('001', pNumCte, pNumCta)
            INTO cCodRetSp, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca

			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp = 110 THEN --VERIFICA QUE HAYA ALMENOS UN PARAMETRO DE BUSQUEDA
				LET cCodRet = '00003';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 310 THEN --SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO.
				LET cCodRet = '00335';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 104 THEN --NO EXISTE EL CLIENTE
				LET cCodRet = '00022';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 200 THEN --NO EXISTE EL NUMERO DE CUENTA
				LET cCodRet = '00009';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 210 THEN --NO EXISTE EL PRODUCTO
				LET cCodRet = '00016';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 250 THEN --NO EXISTE EL NUMERO DE CUENTA
				LET cCodRet = '00009';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 260 THEN --NO EXISTE EL NUMERO DE CUENTA EN TABLA MAENOC
				LET cCodRet = '00303';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 270 THEN --NO EXISTE EL TIPO DE REGIMEN
				LET cCodRet = '00332';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 300 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
				LET cCodRet = '00017';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			END IF;
                        
			SELECT codigo, cuenta
			INTO cCodigoEmpresa, cCuentaLigada
			FROM bdicheq:"informix".sc_nominaempresas
			WHERE numcte = cNumCliente;
			--WHERE cuenta = cNumCuenta;
						
            RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada WITH RESUME;
                        
        END FOREACH;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 29/08/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: REIMPRESION DOCUMENTOS',
'DESCRIPCION: Spl que genera la portada',
'BD: bdicnweb',
'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 15/08/2024',
'DESCRIPCION: Ajuste a SP para cambiar longitud del campo razon social 104 1 254';

CREATE PROCEDURE "informix".sp_generaportadactamec2(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCta CHAR(20))
                RETURNING CHAR(5)       AS      codret,                 --Codigo de retorno
                                                CHAR(4)         AS      codProducto,            --CODIGO DEL PRODUCTO
                                                CHAR(40)        AS      nomProducto,            --NOMBRE DEL PRODUCTO
                                                CHAR(254)       AS      razonSoc,               --RAZON SOCIAL
                                                CHAR(20)        AS      numCliente,             --NUMERO DEL CLIENTE
                                                CHAR(20)        AS      numCuenta,              --NUMERO DE LA CUENTA
                                                CHAR(18)        AS      clabe,                  --NUMERO CLABE
                                                CHAR(1)         AS      claveRegimen,           --CLAVE DEL REGIMEN DE FIRMAS
                                                CHAR(20)        AS      regimenFirmas,          --REGIMEN DE FIRMAS
                                                CHAR(20)        AS      especiManejo,           --ESPECIFICACIONES DE MANEJO, COMBINACION
                                                CHAR(13)        AS      rfc,                    --RFC
                                                DATE            AS      fechaOperacion,     --FECHA DE LA OPERACION
                                                CHAR(104)       AS      nombreFirmante,         --NOMBRE DE EL FIRMANTE
                                                CHAR(1)         AS      tipoFirma,              --TIPO DE FIRMA
                                                CHAR(4)         AS      sucursal,               --NUMERO DE SUCURSAL
                                                CHAR(40)        AS      nomsuc,                 --NOMBRE DE SUCURSAL
                                                CHAR(60)        AS      reca,                   --DESCRIPCION DEL RECA
												CHAR(10)        AS      hora_operacion, 
												CHAR(20)        AS      folio_operacion, 
												CHAR(3)         AS      codigo_empresa,
												CHAR(20)        AS      cuenta_ligada;
                
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(3);
        DEFINE iCodRetSp INTEGER;
        DEFINE  cCodProducto            CHAR(4);        --CODIGO DEL PRODUCTO   
        DEFINE  cNomProducto            CHAR(40);       --NOMBRE DEL PRODUCTO   
        DEFINE  cRazonSoc               CHAR(254);      --RAZON SOCIAL  
        DEFINE  cNumCliente             CHAR(20);       --NUMERO DEL CLIENTE    
        DEFINE  cNumCuenta              CHAR(20);       --NUMERO DE LA CUENTA   
        DEFINE  cClabe                  CHAR(18);       --NUMERO CLABE  
        DEFINE  cClaveRegimen           CHAR(1);        --CLAVE DEL REGIMEN DE FIRMAS   
        DEFINE  cRegimenFirmas          CHAR(20);       --REGIMEN DE FIRMAS     
        DEFINE  cEspeciManejo           CHAR(20);       --ESPECIFICACIONES DE MANEJO, COMBINACION       
        DEFINE  cRfc                    CHAR(13);       --RFC   
        DEFINE  dFechaOperacion     DATE;               --FECHA DE LA OPERACION 
        DEFINE  cNombreFirmante         CHAR(104);      --NOMBRE DE EL FIRMANTE 
        DEFINE  cTipoFirma              CHAR(1);        --TIPO DE FIRMA 
        DEFINE  cSucursal               CHAR(4);        --NUMERO DE SUCURSAL    
        DEFINE  cNomsuc                 CHAR(40);       --NOMBRE DE SUCURSAL    
        DEFINE  cReca                   CHAR(60);       --RECA
		DEFINE cHoraOperacion           CHAR(10);       --HORA DE GENERACIÃN DE LA CONSULTA
		DEFINE cFolioOperacion          CHAR(20);       --NUMERO DE CUENTA + PREFIJO P
		DEFINE cCodigoEmpresa           CHAR(3);
		DEFINE cCuentaLigada            CHAR(20);
		
		

        
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET     cCodProducto    = "";
        LET     cNomProducto    = "";
        LET     cRazonSoc       = "";
        LET     cNumCliente     = "";
        LET     cNumCuenta      = "";
        LET     cClabe          = "";
        LET     cClaveRegimen   = "";
        LET     cRegimenFirmas  = "";
        LET     cEspeciManejo   = "";
        LET     cRfc            = "";
        LET     dFechaOperacion = "";
        LET     cNombreFirmante = "";
        LET     cTipoFirma      = "";
        LET     cSucursal       = "";
        LET     cNomsuc         = "";
        LET     cReca           = "";
		LET     cHoraOperacion  = "";
		LET     cFolioOperacion = "";
		LET     cCodigoEmpresa  = "";
		LET     cCuentaLigada   = "";
                
				
		--, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                END EXCEPTION;
                
           --     SET DEBUG FILE TO '/informix/vamilan/sp_generaportadactamec2.out';
             --   TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = ''  THEN
                        LET cCodRet = '00003';
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                ELIF pNumCta = '' AND pNumCte = '' THEN
                        LET cCodRet = '00003';
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                END IF;
        
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCta, '01', '1') INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                END IF;
                
				-- SE BUSCAN LOS DATOS DE HORA DE OPERACION, FOLIO DE OPERACION, CODIGO DE LA EMPRESA Y CUENTA LIGADA
				LET cHoraOperacion = SUBSTR(TO_CHAR(CURRENT, '%r'), 0, 8);
				LET cFolioOperacion = 'P'||TRIM(pNumCta);
				
                FOREACH EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_generarptportadaproducto2_1('001', pNumCte, pNumCta)
                        INTO cCodRetSp, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca

                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp = 110 THEN --VERIFICA QUE HAYA ALMENOS UN PARAMETRO DE BUSQUEDA
                                LET cCodRet = '00003';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 310 THEN --SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO.
                                LET cCodRet = '00335';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 104 THEN --NO EXISTE EL CLIENTE
                                LET cCodRet = '00022';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 200 THEN --NO EXISTE EL NUMERO DE CUENTA
                                LET cCodRet = '00009';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 210 THEN --NO EXISTE EL PRODUCTO
                                LET cCodRet = '00016';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 250 THEN --NO EXISTE EL NUMERO DE CUENTA
                                LET cCodRet = '00009';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 260 THEN --NO EXISTE EL NUMERO DE CUENTA EN TABLA MAENOC
                                LET cCodRet = '00303';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 270 THEN --NO EXISTE EL TIPO DE REGIMEN
                                LET cCodRet = '00332';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 300 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
                                LET cCodRet = '00017';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        END IF;
                        
						SELECT codigo, cuenta
						INTO cCodigoEmpresa, cCuentaLigada
						FROM bdicheq:"informix".sc_nominaempresas
						WHERE numcte = cNumCliente;
						--WHERE cuenta = cNumCuenta;
						
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada WITH RESUME;
                        
                END FOREACH;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 03/07/2014',
'DESCRIPCION: Sp que genera la portada',
'AUTOR: Oscar Flores Conde',
'FECHA: 17/12/2014',
'DESCRIPCION: Se agrega el dato de salida del RECA (Registro de Contratos de AdhesiÃ³n)',
'AUTOR: Oscar Flores Conde',
'FECHA: 21/01/2016',
'DESCRIPCION: Se agregan los parametros de salida hora de operacion, folio de operacion, codigo de la empresa y cuenta ligada',
'BD: bdicnweb',
'AUTOR MODIFICACION: Uriel CaamaÃ±o Mejia',
'BD: bdicnweb',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos';

CREATE PROCEDURE "informix".sp_generareportemedianainflacion(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) 		AS codret,
		  CHAR(4) 		AS producto,
		  CHAR(30)		AS desc_producto,
		  DECIMAL(9,6) 	AS tasa,
		  DECIMAL (9,6) AS med_inflacion,
		  CHAR(2) 		AS periodo,
		  DECIMAL(9,6)  AS gat_nominal,
		  DECIMAL(9,6)  AS gat_real;

/*=====================================
|     DEFINICIÓN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);

	DEFINE cProducto       	CHAR(5);
	DEFINE cDescProducto   	CHAR(30);
    DEFINE dTasa           	DECIMAL (9,6);
    DEFINE dMedInflacion   	DECIMAL(9,6);
    DEFINE cPeriodo        	CHAR (2);
    DEFINE dGatNominal      DECIMAL (9,6);
    DEFINE dGatReal         DECIMAL (9,6);
	DEFINE dFecha 			DATE;
	DEFINE iTotalReg		INTEGER;

/*======================================
|     INICIALIZACIÓN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

	LET cProducto       = '';
	LET cDescProducto	= '';
    LET dTasa           = 0.0;
    LET dMedInflacion   = 0.0;
    LET cPeriodo         = '';
    LET dGatNominal      = 0.0;
    LET dGatReal         = 0.0;	
	LET dFecha			 = '';
	LET iTotalReg		 = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_generareportemedianainflacion.out';
		--TRACE ON;

		IF  pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
		END IF;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
			END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF EXISTS (SELECT med_inflacion FROM bdicheq:sc_medianainflacion) THEN

			DELETE FROM sw_reportemediainflacion_tmp WHERE usuario = pUsuario;

			SELECT (med.med_inflacion)  
			INTO dMedInflacion 
			FROM bdicheq:sc_medianainflacion med 
			WHERE med.fecha_publicacion = (SELECT MAX(fecha_publicacion) FROM bdicheq:sc_medianainflacion);

			FOREACH
				--Generamos la lista de producto pagare,
				SELECT tasa, periodo, gat_nomina, gat_real, fecha_publicacion
				INTO dTasa, cPeriodo, dGatNominal, dGatReal, dFecha
				FROM bdinvers:"informix".sv_gat
				ORDER BY fecha_publicacion DESC

				INSERT INTO sw_reportemediainflacion_tmp(producto,desc_producto, tasa, med_inflacion, periodo, gat_nominal, gat_real, fecha ,usuario)
				VALUES ('3000', "PAGARÉ", dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal, dFecha, pUsuario);

				LET iTotalReg = iTotalReg + 1;

			END FOREACH;

			FOREACH
			--Generamos los registros de los demas productos
				SELECT producto, desc_producto,tasa, periodo, gat_nominal, gat_real, fecha_publicacion
				INTO cProducto, cDescProducto, dTasa, cPeriodo, dGatNominal, dGatReal, dFecha
				FROM bdicheq:"informix".sc_gat sc 
				INNER JOIN bdicnweb:"informix".sw_cap_tipoproductogat cat
				ON sc.producto = cat.num_producto
				ORDER BY sc.producto

				INSERT INTO sw_reportemediainflacion_tmp(producto,desc_producto, tasa, med_inflacion, periodo, gat_nominal, gat_real, fecha, usuario)
				VALUES (cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal, dFecha, pUsuario);

				LET iTotalReg = iTotalReg + 1;
			END FOREACH;

			IF iTotalReg > 0 THEN
				FOREACH
					SELECT producto, desc_producto, tasa, med_inflacion, periodo, gat_nominal, gat_real
					INTO cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal
					FROM sw_reportemediainflacion_tmp
					WHERE usuario = pUsuario
					ORDER BY producto, tasa

					RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal WITH RESUME;
				END FOREACH;
	
			ELSE
				LET cCodRet = '00017'; --No existe información 
				RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
			END IF;
		ELSE
			LET cCodRet = '00001'; --No existe mediana Inflacion
			RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
		END IF;
	END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÉ ANTONIO RAMÍREZ FRANCO',
'FECHA: 30/06/2023',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MEDIANA INFLACIÓN ',
'DESCRIPCION: SP ENCARGADO DE REALIZAR CONSULTAR TODOS LOS PRODUCTOS CON SUS GATS NOMINALES Y REALES DE LAS TABLAS. bdicheq:sc_gat y bdinvers:"informix".sv_gat',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_genera_archivo_img_presentado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoBloque INTEGER, pRutaDescarga CHAR(50), pDireccionMac CHAR(15), totalRegTrunc INTEGER)
                RETURNING CHAR(5) AS codret,
                          CHAR(50) AS nombreArchivoImg;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cNombreArchivo CHAR(30);
        DEFINE iTotalCheques INTEGER;
        DEFINE mTotalImporte DECIMAL(20,2);
        DEFINE cArchivoAI CHAR(30);
        DEFINE cBanco CHAR(3);
        DEFINE cMiBanco CHAR(3);
        DEFINE pFechaHoy DATE;
        DEFINE iDayFecha INTEGER;
        DEFINE iNumBloqueImg INTEGER;
        DEFINE cNumBloqueImg CHAR(7);
        DEFINE cCadenaImgEncabezado CHAR(250);
        DEFINE cTipoRegistro CHAR(2);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cVersion CHAR(3);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cSentido CHAR(1);
        DEFINE cMoneda CHAR(1);
        DEFINE cFechaProceso CHAR(8);
        DEFINE cUsoFuturo CHAR(1);
        DEFINE cCadenaImgDetalle CHAR(5000);
        DEFINE mMontoImagen DECIMAL(14,2);
        DEFINE iContIntercambio INTEGER;
        DEFINE cCodigoSeguridad CHAR(3);
        DEFINE cImported CHAR(15);
        DEFINE cImportes CHAR(16);
        DEFINE cMonto CHAR(12);
        DEFINE cMontos CHAR(13);
        DEFINE cCents CHAR(2);
        DEFINE bImagenF BLOB;
        DEFINE bImagenT BLOB;
        DEFINE cImagenFormatoT CHAR(3);
        DEFINE cImagenFormatoF CHAR(3);
        DEFINE iTotalChq INTEGER;
        DEFINE cTotalRegistros CHAR(9);
        DEFINE cCadenaImgSumario CHAR(100);
        DEFINE iExistenImgsDigitalizadas INTEGER;
        DEFINE iIdConsultaDetalleCheque40 INTEGER;
        DEFINE cDescBanco CHAR (40);
        DEFINE cCuentaReferencia CHAR(20);
        DEFINE cNumCheque INTEGER;
        DEFINE mImporte DECIMAL(14,2);
        DEFINE cCuentaDeposito CHAR(20);
        DEFINE cSucursalOperadora CHAR(44);
        DEFINE cChqProcesado CHAR(1);
        DEFINE cChqCompensacion CHAR(3);
        DEFINE cChqTransaccion CHAR(2);
        DEFINE cChqCodSeguridad CHAR(3);
        DEFINE cChqDigVerPre CHAR(1);
        DEFINE cChqDigVerInter CHAR(1);
        DEFINE cTransaccion CHAR(4);
        DEFINE cNombreCte CHAR(60);
        DEFINE cRfcCte CHAR(13);
        DEFINE cCurpCte CHAR(20);
        DEFINE cTipoCuentaDep CHAR(2);
        DEFINE cIndImgCheque CHAR(1);
        DEFINE iTamAnvImgCheque INTEGER;
        DEFINE iTamRevImgCheque INTEGER;
        DEFINE cEjecutivo CHAR(8);
        DEFINE cDireccionMac CHAR(15);
        DEFINE cIndDuplicado CHAR(1);
        DEFINE cIdStatusProceso CHAR(1);
        DEFINE cRowId INTEGER;
        DEFINE cSQL CHAR(1000);
        DEFINE cSumario CHAR(117);
        DEFINE cEncabezado CHAR(117);
        DEFINE cCommand CHAR(500);
        DEFINE cRutaArchivo CHAR(500);
        DEFINE cRutaJava CHAR(500);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET cNombreArchivo = '';
        LET iTotalCheques = 0;
        LET mTotalImporte = 0.0;
        LET iContIntercambio = 0;
        LET cArchivoAI = '';
        LET cBanco = '';
        LET cMiBanco = '';
        LET pFechaHoy = NULL;
        LET iDayFecha = 0;
        LET cNombreArchivo = '';
        LET iNumBloqueImg = 0;
        LET cCadenaImgEncabezado = '';
        LET cTipoRegistro = '';
        LET cNumSecuencia = '';
        LET cVersion = '';
        LET cCodOperacion = '';
        LET cSentido= '';
        LET cMoneda = '';
        LET cFechaProceso = '';
        LET cUsoFuturo = '';
        LET cCadenaImgDetalle = '';
        LET mMontoImagen = 0.0;
        LET iContIntercambio = 0;
        LET cCodigoSeguridad = '';
        LET cMonto = '';
        LET cCents = '';
        LET bImagenF = null;
        LET bImagenT = null;
        LET cImagenFormatoT = '';
        LET cImagenFormatoF = '';
        LET iTotalChq = 0;
        LET mTotalImporte = 0.0;
        LET cTotalRegistros = '';
        LET cCadenaImgSumario = '';
        LET iExistenImgsDigitalizadas = 0;
        LET iIdConsultaDetalleCheque40 = 0;
        LET cDescBanco = '';
        LET cCuentaReferencia = '';
        LET cNumCheque = 0;
        LET mImporte = 0.0;
        LET cCuentaDeposito = '';
        LET cSucursalOperadora ='';
        LET cChqProcesado = '';
        LET cChqCompensacion = '';
        LET cChqTransaccion = '';
        LET cChqCodSeguridad = '';
        LET cChqDigVerPre = '';
        LET cChqDigVerInter = '';
        LET cTransaccion = '';
        LET cNombreCte = '';
        LET cRfcCte = '';
        LET cCurpCte = '';
        LET cTipoCuentaDep = '';
        LET cIndImgCheque = '';
        LET iTamAnvImgCheque = 0;
        LET iTamRevImgCheque = 0;
        LET cEjecutivo = '';
        LET cDireccionMac = '';
        LET cIndDuplicado = '';
        LET cIdStatusProceso = '';
        LET cRowId = 0;
        LET cSQL = '';
        LET cImported = '';
        LET cImportes = '';
        LET cMontos = '';
        LET cNumBloqueImg = '';
        LET cSumario = '';
        LET cEncabezado = '';
        LET cCommand = '';
        LET cRutaArchivo = '/home/intersoc/';
        LET cRutaJava = '/usr/java8'; --Parametrizar produccion

        BEGIN

                ON EXCEPTION SET iSqlErr
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet,'';
                END EXCEPTION;
                
                ON EXCEPTION IN (-668, -535, -255)
                END EXCEPTION WITH RESUME;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genera_archivo_img_presentado.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pNoBloque IS NULL OR pRutaDescarga = '' OR pDireccionMac = '' OR totalRegTrunc IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,'';
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,'';
                END IF;

               
                -- SE VALIDA QUE EXISTAN IMAGENES DIGITALIZADAS
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                SELECT COUNT(ind_img_cheque)
				INTO iExistenImgsDigitalizadas
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					AND ind_img_cheque = '2';

				IF iExistenImgsDigitalizadas = 0 THEN
					-- MANDASR MENSAJE DE QUE NO EXISTEN REGISTROS COMPLETOS
					LET iExistenImgsDigitalizadas = 0;
					SELECT COUNT(ind_img_cheque)
					INTO iExistenImgsDigitalizadas
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
						AND direccion_mac = pDireccionMac
						AND ind_img_cheque = '1';

					IF iExistenImgsDigitalizadas = 0 THEN
						LET cCodRet = '00780';
						 RETURN cCodRet,TRIM(cArchivoAI);
					END IF;

				END IF;



                SELECT  valor INTO cBanco FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param ='5';
                SELECT fecha_hoy INTO pFechaHoy from bdicheq:sc_fechas where empresa = '001';
                LET iDayFecha = DAY(pFechaHoy);
                LET iContIntercambio = 1;
                LET cNombreArchivo = 'PRE_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y');
                LET cMiBanco = LPAD(cBanco,3,'0');

                SELECT count(nombrearchivo) INTO iNumBloqueImg FROM bditef:cce_gransumario WHERE nombrearchivo[1,12] =cNombreArchivo AND total_reg_ti <> '0';

                LET iNumBloqueImg = iNumBloqueImg;

                LET cArchivoAI ="EAI"||cMiBanco||"A1.AI"||LPAD(TO_CHAR(iDayFecha),2,'0')||LPAD(TO_CHAR(iNumBloqueImg),3,'0');



                IF totalRegTrunc > 0 THEN
                        --=========================
                        -- AI ENCABEZADO IMAGENES
                        --=========================
                        LET cCadenaImgEncabezado = '';

                        LET cTipoRegistro = '01';
                        LET cNumSecuencia = '0000001';
                        LET cVersion = '051';
                        LET cCodOperacion = '40';

                        LET cSentido= 'E';
                        LET cMoneda = '1';
                        LET cNumBloqueImg = LPAD(iNumBloqueImg,7,'0');
                        LET cUsoFuturo = ' ';


                        LET cFechaProceso = TO_CHAR(DATE(pFechaHoy), '%Y%m%d');

                        LET cEncabezado = cTipoRegistro||cNumSecuencia||cVersion||cCodOperacion||cMiBanco||cSentido||cMoneda||cNumBloqueImg||cFechaProceso||LPAD(cUsoFuturo,83,' ');

                        --=========================
                        -- AI DETALLE IMAGENES
                        --=========================

                        LET cCadenaImgDetalle = '';

                        SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';
                        LET iTotalChq = 0;
                        LET mTotalImporte = 0.0;

                        DELETE FROM bdicnweb:"informix".ccep_procesdetalleimg_tmp;
                        
                        BEGIN WORK;

                        FOREACH SELECT id_consultadetallecheque40, banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora,
                                chq_procesado, chq_compensacion,chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, transaccion, nombre_cte, rfc_cte,
                                curp_cte,tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque,tam_rev_img_cheque, ejecutivo,direccion_mac,ind_duplicado,id_status_proceso,
                                imagenf,imagent,imagen_formatof,imagen_formatot
                                INTO iIdConsultaDetalleCheque40,cBanco,cDescBanco,cCuentaReferencia, cNumCheque,mImporte,cCuentaDeposito,cSucursalOperadora,cChqProcesado,
                                cChqCompensacion,cChqTransaccion,cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,
                                cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,cEjecutivo,cDireccionMac,cIndDuplicado,cIdStatusProceso,
                                bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT
                                FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
                                WHERE ejecutivo = pUsuario
                                AND direccion_mac = pDireccionMac
                                AND imagenf IS NOT NULL
                                AND imagent IS NOT NULL


                                IF mImporte > mMontoImagen AND cIndImgCheque = '1'  THEN
                                        IF iTamAnvImgCheque IS NOT NULL AND iTamRevImgCheque IS NOT NULL THEN
                                                LET iContIntercambio = iContIntercambio + 1;
                                                LET cTipoRegistro = '02';
                                                LET cNumSecuencia = LPAD(TO_CHAR(iContIntercambio),7,'0');
                                                LET cCodOperacion = '40';
                                                LET cCodigoSeguridad = LPAD(TRIM(cChqCodSeguridad),3,'0');
                                                --TRACE cCodigoSeguridad;
                                                --TRACE cImported;
                                                LET cImported = '';
                                                LET cImported = TO_CHAR(mImporte);
                                                LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
                                                LET cMonto = LPAD(TRIM(cMonto),12,'0');
                                                LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
                                                LET cCents = LPAD(TRIM(cCents),2,'0');
                                                LET cImported = TRIM(cMonto || cCents);
                                                
                                                --TRACE cImported;
                                                LET cUsoFuturo = '_';


                                                INSERT INTO bdicnweb:"informix".ccep_procesdetalleimg_tmp
                                                (tipoRegistro,numSecuencia,codOperacion,fechaProceso,bancoPropio,moneda,codigoSeguridad,
                                                chqDigVerPre,chqTransaccion,chqCompensacion,cBanco,chqDigInter,
                                                cuentaReferencia,numCheque,importeStr,usoFuturo,tamAnvImgCheque,
                                                tamRevImgCheque,imagenF,imagenT
                                                )VALUES
                                                (cTipoRegistro,cNumSecuencia,cCodOperacion,cFechaProceso,cMiBanco,cMoneda,cCodigoSeguridad,
                                                cChqDigVerPre,LPAD(cChqTransaccion,2,'0'),LPAD(cChqCompensacion,3,'0'),LPAD(cBanco,3,'0'),cChqDigVerInter,
                                                LPAD(cCuentaReferencia,13,'0'),LPAD(cNumCheque,10,'0'),cImported,LPAD(cUsoFuturo,13,'_'),LPAD(TO_CHAR(iTamAnvImgCheque),15,'0'),
                                                LPAD(TO_CHAR(iTamRevImgCheque),15,'0'),bImagenF,bImagenT);


                                                LET iTotalChq = iTotalChq + 1;
                                                LET mTotalImporte = mTotalImporte + mImporte;

                                        END IF;
                                END IF;
                        END FOREACH;
                        COMMIT;

                        
                        --=========================
                        -- AI SUMARIO IMAGENES
                        --=========================
                        LET cTipoRegistro = '09';
                        LET cNumSecuencia = LPAD(TO_CHAR(iContIntercambio + 1),7,'0');
                        LET cTotalRegistros = LPAD(TO_CHAR(iTotalChq ),9,'0');
                        LET cImportes = '';
                        LET cImportes = TO_CHAR(mTotalImporte);
                        LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
                        LET cMontos = LPAD(TRIM(cMontos),13,'0');
                        LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
                        LET cCents = LPAD(TRIM(cCents),2,'0');
                        LET cImportes = '0'||cMontos || cCents;
                  
                        LET cUsoFuturo = ' ';


                        LET cSumario = cTipoRegistro||cNumSecuencia||cTotalRegistros||cImportes||LPAD(cUsoFuturo,83,' ');
                        
                        SET ISOLATION TO DIRTY READ;
                        SET LOCK MODE TO WAIT 3;
						
                        LET cCommand = TRIM(cRutaJava)||"/bin/java -jar "||TRIM(cRutaArchivo)||"GeneraArchivoCCEAI.jar '"||TRIM(cArchivoAI)||"' '"|| cSumario ||"' '"|| cEncabezado||"' '"|| TRIM(pRutaDescarga)||"'";
        
                        SYSTEM(TRIM(cCommand));

                END IF;		
                RETURN cCodRet,TRIM(cArchivoAI);
        END;

END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 18/02/2016',
'MODULO: Camara de Compensacion Electonica Presentada',
'FUNCIONALIDAD: Generacion de Archivo',
'DESCRIPCION: realiza la generacion del archivo de intercambio Codigo 40 a presentar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasguardarespuestawu2(
pUsuario                CHAR(8), 
pIdFuncion              CHAR(10), 
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    CHAR(25),
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10) 
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   CHAR(5);
DEFINE iSqlErr   INTEGER;
DEFINE cCodRetSp CHAR(3);
DEFINE iCodRetSp INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(30);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasguardarespuestawu2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search_web(cEmpresa,pUsuario,pMarca,pForeignRsRefNumRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,pEmisorNombre1,
		pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,pEmisorTel,pBenefNameType,pBenefNombre1,
		pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,
		pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,
		pNumCoincidencias,pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,current,pUsuario,current, '')
		INTO cCodRetSp ,cError_Desc;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_sac_wu_guardarespuesta_search_web";
		ELIF iCodRetSp = 27 THEN
			LET cCodRet = '00976'; -- USUARIO NO TIENE ID. ASIGNADO
		ELIF iCodRetSp = 26 THEN
			LET cCodRet = '00025'; -- NO EXISTE USUARIO, 			 	EL USUARIO NO EXISTE
		ELIF iCodRetSp = 23 THEN
			LET cCodRet = '00978'; -- SE TIENE QUE REVERSAR PRIMERO ANTES DE INTENTAR EL PAGO NUEVAMENTE	
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00977'; -- NO EXISTE MARCA EN SAC PARAM	
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00770'; -- ERROR EN EL PROCESO, 				PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 05/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Consulta Remesas WU',
'DESCRIPCION: Guarda respuesta de transaccion en bdisac:sac_wu_search',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 06/08/2024',
'DESCRIPCION: SP clon de sp_remesasguardarespuestawu que se encarda de Guarda respuesta de la transaccion en bdisac:sac_wu_search, llamando al SP sp_sac_wu_guardarespuesta_search_web',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_reenviosreptotales(pUsuario CHAR(8), pIdFuncion CHAR(10), pModo SMALLINT, pTipoSolicitud CHAR(1), 
pNumSolicitud CHAR(20), pNumCte CHAR(20),pEstatus CHAR(2), pFechaIni DATE, pFechaFin DATE)
			RETURNING
			CHAR(5) AS codigo_ret,
			INTEGER AS num_registros;
		
	DEFINE iFolio     INTEGER;
	DEFINE iSqlErr    INTEGER;
	DEFINE cCodRet    CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cRetorno01 CHAR(20); --tiposol / numanalista
	DEFINE cRetorno02 CHAR(104); --producto /  nomanalista
	DEFINE cRetorno03 CHAR(25); --numsolic / perfilusuario
	DEFINE cRetorno04 CHAR(20); --numcte / errorcve01
	DEFINE cRetorno05 CHAR(4); --numsuc / errorcve02 
	DEFINE cRetorno06 CHAR(104); --nomcte / errorcve03
	DEFINE cRetorno07 CHAR(10); --fechasol / errorcve04
	DEFINE cRetorno08 CHAR(12); --hora / errorcve05
	DEFINE cRetorno09 CHAR(4); --estatus / errorcve06
	DEFINE cRetorno10 CHAR(4); --reenvio_exit SI o NO / errorcve07
	DEFINE cRetorno11 CHAR(10); --fecha_reenvio / errorcve08
	DEFINE cRetorno12 CHAR(4); --estatus fin / errorcve09
	DEFINE cRetorno13 CHAR(80); --motivo_reenvio/ totalbc
	DEFINE cRetorno14 CHAR(104); --nombre_analista / totalcc
	DEFINE cRetorno15 CHAR(10); -- totalglobal	
	DEFINE vCont	SMALLINT; -- Contador de solicitudes

	LET iFolio = 0;
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET cRetorno01 = ''; --tiposol / numanalista
	LET cRetorno02 = ''; --producto /  nomanalista
	LET cRetorno03 = ''; --numsolic / perfilusuario
	LET cRetorno04 = ''; --numcte / errorcve01
	LET cRetorno05 = ''; --numsuc / errorcve02 
	LET cRetorno06 = ''; --nomcte / errorcve03
	LET cRetorno07 = ''; --fechasol / errorcve04
	LET cRetorno08 = ''; --hora / errorcve05
	LET cRetorno09 = ''; --estatus / errorcve06
	LET cRetorno10 = ''; --reenvio_exit SI o NO / errorcve07
	LET cRetorno11 = ''; --fecha_reenvio / errorcve08
	LET cRetorno12 = '' ; --estatus fin / errorcve09
	LET cRetorno13 = ''; --motivo_reenvio/ totalbc
	LET cRetorno14 = ''; --nombre_analista / totalcc
	LET cRetorno15 = ''; -- totalglobal	
	LET vCont	= 0; -- Contador de solicitudes
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_reenviosreptotales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		--LIMPIA TABLA
		DELETE FROM bdicnweb:"informix".sw_mon_buro_reenviosrep WHERE usuario_inserta = pUsuario;
		
		--REALIZA CONSULTA Y LLENA TABLA 
		FOREACH 
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_reenviosrep(pModo, pTipoSolicitud, pNumSolicitud, pNumCte, pEstatus, pFechaIni, pFechaFin)
			INTO cCodRetSp, cRetorno01, cRetorno02, cRetorno03, cRetorno04, cRetorno05, cRetorno06, cRetorno07, cRetorno08, cRetorno09, cRetorno10, cRetorno11, 
			cRetorno12, cRetorno13, cRetorno14, cRetorno15
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_mon_buro_reenviosrep";
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00017';
			END IF;
			
			IF(cCodRet = '00000') THEN
				--SET LOCK MODE TO WAIT 3;
				INSERT INTO bdicnweb:"informix".sw_mon_buro_reenviosrep(retorno_01,retorno_02,retorno_03,retorno_04,retorno_05,retorno_06,retorno_07,retorno_08,retorno_09,retorno_10,retorno_11,retorno_12,retorno_13,retorno_14,retorno_15,usuario_inserta,fecha_insert)
				VALUES(cRetorno01, cRetorno02, cRetorno03, cRetorno04, cRetorno05, cRetorno06, cRetorno07, cRetorno08, cRetorno09, cRetorno10, cRetorno11, cRetorno12, cRetorno13, cRetorno14, cRetorno15, pUsuario, CURRENT);
				
				LET vCont = vCont + 1;
				
				IF vCont = 3500 THEN EXIT FOREACH; END IF;
			END IF;
		END FOREACH;
		
		--REALIZA CONSULTA DE TOTAL DE REGISTROS
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:"informix".sw_mon_buro_reenviosrep
		WHERE usuario_inserta = pUsuario;
		
		IF iNoRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;			
		END IF;
		
		RETURN cCodRet, iNoRegistros; 
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 25/11/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE SOLICITUDES EN BC Y CC',
'DESCRIPCION:SPL que ejecuta sp productivo e inserta los datos en tabla auxiliar para obtener los totales del Reporte de Solicitudes en BC y CC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_hojafirmactamec_complementoinfo(pCuenta CHAR(20))

RETURNING CHAR(5)   AS cCodRet,
		  CHAR(100) AS cMensaje,
		  CHAR(20)  AS numcliente,
		  CHAR(50)   AS tipofirma;
		  


--****************************************************************************************************
-- Objetivo:Spl que obtiene informaciÃ³n de clientes y tipo se firma
-- Autor: Nadia Ordaz
-- FECHA : 24/07/2024
-- SOLICITO : Ismael Hernandez
-- BD: bdicnweb
--***************************************************************************************************

--DEFINICIONES
	DEFINE iSql_Err                     INTEGER;
	DEFINE cCodRet         			    CHAR(5);
	DEFINE cMensaje                     CHAR(50);
	
	DEFINE numcliente         			CHAR(20);
	DEFINE tipofirma                    CHAR(50);
            
--INICIALIZACIONES			  
    LET iSql_Err           	= 0;
    LET cCodRet           	= '00000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
	
    LET numcliente          = '';
    LET tipofirma           = '';
	
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
    END EXCEPTION;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/hojafirmaCtaMEC.out";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(pCuenta,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
	END IF;

	FOREACH cur for							
		SELECT numcte, tipo_firma
		INTO numcliente, tipofirma
		FROM bdicheq:"informix".sc_firmantes
		WHERE empresa = '001'
			AND cuenta = pCuenta
		ORDER BY secuencia ASC
		
		RETURN cCodRet, cMensaje, numcliente, tipofirma WITH RESUME;
		
	END FOREACH;	
END;

END PROCEDURE;