CREATE PROCEDURE "informix".sp_conciliacion_tae_tapi()
RETURNING CHAR(5) AS cCodRet, 
		  CHAR(150) AS cMensajeRet;
	
	
	--Variables de retorno
	DEFINE cCodRet 						CHAR(5);
	DEFINE cMensajeRet					CHAR(150);
	--Variables de control de excepciones
	DEFINE iSqlErr						INTEGER;
	DEFINE iIsamErr				 		INTEGER;
	DEFINE cInfoErr						CHAR(100);
	--Variables generales		
	DEFINE dFecha_Ant					DATE;
	DEFINE cEmpresa						CHAR(3);
	DEFINE cUsuario						CHAR(10);
	DEFINE mTotalTelcel 				MONEY(18,2);
	DEFINE mTotalTapi					MONEY(18,2);
	--Variables para transferencia spei
    DEFINE cSucursalSPEI 				CHAR(4);
    DEFINE cFolioSucursalSPEI 			CHAR(16);
    DEFINE iBancoDestinoSPEI 			INTEGER;
    DEFINE dFechaCapturaSPEI 			DATE;
    DEFINE iTipoPagoSPEI 				INTEGER;
    DEFINE iTipoOperacionSPEI 			INTEGER;
    DEFINE cNombreOrdenSPEI 			CHAR(40);
    DEFINE cCuentaOrdenSPEI 			CHAR(20);
	DEFINE cCuentaOrden 				CHAR(20);
    DEFINE cRFCOrdenSPEI 				CHAR(18);
    DEFINE cNombreBeneficiarioSPEI 		CHAR(40);
    DEFINE cCuentaBeneficiarioSPEI 		CHAR(20);
    DEFINE cRFCBeneficiarioSPEI 		CHAR(18);
    DEFINE mImporteIVASPEI 				MONEY(18,2);
    DEFINE dReferenciaNumero 			DECIMAL(7,0);
    DEFINE cReferenciaCobranza1SPEI 	CHAR(40);
    DEFINE cConceptoPagoSPEI 			CHAR(210);
    DEFINE cClavePagoSPEI 				CHAR(10);
    DEFINE cNombreBeneficiario2SPEI 	CHAR(40);
    DEFINE cCuentaBeneficiario2SPEI 	CHAR(20);
    DEFINE cRFCBeneficiario2SPEI 		CHAR(18);
    DEFINE cTransaccionSPEI 			CHAR(4);
    DEFINE iTipoCuentaOrdenSPEI 		INTEGER;
    DEFINE iTipoCuentaBeneficiarioSPEI 	INTEGER;
    DEFINE iSerialFolioSPEI 			INTEGER;
    DEFINE cCodRetSp 					CHAR(5);
    DEFINE cMensajeError 				CHAR(100);
    DEFINE cCveRastreo 					CHAR(30);
	DEFINE cNumCte						CHAR(15);
	--Variables para procesamiento de archivo
	DEFINE cRutaArchivo					CHAR(50);
	DEFINE cNombreArchivo				CHAR(35);
	DEFINE cSystem						CHAR(500);
	DEFINE cSQL							CHAR(500);
	DEFINE cResultado					INT;
	--Variables para el retorno de Cargo_ref
	DEFINE cCodRetCgo					CHAR(5);	
	DEFINE cTrxCgo                      CHAR(4);
	DEFINE dFechaCgo  					DATE;
	DEFINE mSdoDispCgo					MONEY(14,2);
	DEFINE mMontoCgo  					MONEY(14,2);
	DEFINE rCodRet						CHAR(5);	       --- Codigo de retorno reverso


	--SET DEBUG FILE TO '/home/c90314833/sp_conciliacion_tae_tapi.out';
	--TRACE ON;
	
	--Variables de retorno
	LET cCodRet 						= '00000';
	LET cMensajeRet                     = 'Proceso finalizado con exito';
	--Variables de control de excepciones
	LET iSqlErr							= 0;
	LET iIsamErr					    = 0;
	LET cInfoErr					    = '';
	--Variables generales
	LET dFecha_Ant						= TODAY-1;
	LET cEmpresa						= '001';
	LET cUsuario						= 'informix';
	LET mTotalTelcel 					= 0.00;
	LET mTotalTapi	 					= 0.00;
	--Variables para transferencia spei
	LET cSucursalSPEI 					= '5011';
	LET iBancoDestinoSPEI 				= 40012;
	LET dFechaCapturaSPEI 				= TODAY;
	LET iTipoPagoSPEI 					= 1;
	LET iTipoOperacionSPEI 				= 0;
	LET mImporteIVASPEI 				= 0.0;
	LET dReferenciaNumero 				= 0;
	LET cReferenciaCobranza1SPEI 		= '';
	LET cClavePagoSPEI 					= '';
	LET cNombreBeneficiario2SPEI 		= '';
	LET cCuentaBeneficiario2SPEI 		= '';
	LET cRFCBeneficiario2SPEI 			= '';
	LET iTipoCuentaOrdenSPEI 			= 40;
	LET iTipoCuentaBeneficiarioSPEI 	= 40;
    LET cFolioSucursalSPEI 		        = '';
    LET cNombreOrdenSPEI 		        = '';
    LET cCuentaOrdenSPEI 		        = '';
	LET cCuentaOrden 			        = '';
    LET cRFCOrdenSPEI 			        = '';
    LET cNombreBeneficiarioSPEI         = '';
    LET cCuentaBeneficiarioSPEI         = '';
    LET cRFCBeneficiarioSPEI            = '';
    LET cConceptoPagoSPEI               = '';
    LET cTransaccionSPEI                = '';
    LET iSerialFolioSPEI                = 0 ;
    LET cCodRetSp                       = '';
    LET cMensajeError 					= '';
    LET cCveRastreo 					= '';
	LET cNumCte							= '';
	--Variables para procesamiento de archivo
	LET cRutaArchivo					= '';
	LET cNombreArchivo 					= '';
	LET cSystem							= '';
	LET cSQL							= '';
	LET cResultado						= 0;
	--Variables para el retorno de Cargo_ref
	LET cCodRetCgo						= '000';
	LET cTrxCgo                         = '';
	LET dFechaCgo                       = TODAY;
	LET mSdoDispCgo                     = 0.00;
	LET mMontoCgo                       = 0.00;
	LET rCodRet			='';                    --- Codigo de retorno reverso

	
	
	
	BEGIN
		--Manejo de excepciones
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					--Registro de error en bitacora del sistema de Sevicio al Cliente
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_conciliacion_tae_tapi");
					RETURN cCodRet,cInfoErr;
				END IF;
		END EXCEPTION;
			
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		--Realizamos la consulta del parametro que contiene 
		SELECT  {+INDEX(sc_param idx_param1 )} valor 
		INTO cNombreArchivo
		FROM bdisac:sac_param
		WHERE empresa = cEmpresa
		AND cod_param = 166;
		
		--Armado del nombre del archivo.
		LET cNombreArchivo = REPLACE(cNombreArchivo,'DD',(LPAD(DAY(dFecha_Ant::DATE), 2, '0')));
		LET cNombreArchivo = REPLACE(cNombreArchivo,'MM',(LPAD(MONTH(dFecha_Ant::DATE), 2, '0')));
		LET cNombreArchivo = REPLACE(cNombreArchivo,'YYYY',(LPAD(YEAR(dFecha_Ant ::DATE), 4, '0')));
		
		--Validacion de ejecucion previa del proceso mediante consulta a tabla de control
		IF (SELECT COUNT(*) FROM bdisac:sac_control_proceso_archivo_tapi WHERE nombre_archivo = cNombreArchivo) > 0 THEN
			LET cCodRet = "00002";
            LET cMensajeRet = 'El archivo ya fue procesado el dia de hoy';
            RETURN cCodRet, cMensajeRet;		
		END IF;			
		
		--Obtencion de la ruta del archivo.
		SELECT  {+INDEX(sc_param idx_param1 )} valor 
		INTO cRutaArchivo
		FROM bdisac:sac_param
		WHERE empresa = cEmpresa
		AND cod_param = 165;
		
		--Limpieza de tabla para carga de archivo
		BEGIN;
		TRUNCATE TABLE bdisac:sac_arch_conci_tapi;
		COMMIT;
		
		--Creacion de archivos para carga en la tabla sac_arch_conci_tapi
		LET cSQL = 'echo "FILE '''|| TRIM(cRutaArchivo) || TRIM(cNombreArchivo) ||''' DELIMITER '','' 16;" > '||TRIM(cRutaArchivo)||'cargadatos_sac_arch_conci_tapi.com';
		SYSTEM cSQL;
		
		LET cSQL = 'echo "INSERT INTO "informix".sac_arch_conci_tapi; " >> '||TRIM(cRutaArchivo)||'cargadatos_sac_arch_conci_tapi.com';
		SYSTEM cSQL;
		
		LET cSQL = ' echo "dbload -d bdisac -c '||TRIM(cRutaArchivo)||'cargadatos_sac_arch_conci_tapi.com -n 1000 -l '||TRIM(cRutaArchivo)||'dbload_sac_arch_conci_tapi.log -r" > '||TRIM(cRutaArchivo)||'dbload_sac_arch_conci_tapi.sh';
		SYSTEM cSQL;
		
		LET cSQL = ' sh '||(TRIM(cRutaArchivo))||'dbload_sac_arch_conci_tapi.sh';
		SYSTEM cSQL;
		
		--Borrado de encabezados
		DELETE FROM bdisac:sac_arch_conci_tapi WHERE operation_id = 'operation_id';
		
		--Validacion de archivo vacio.
		IF (SELECT COUNT(*) FROM sac_arch_conci_tapi) <= 0 THEN
            LET cMensajeRet = 'El archivo es vacio o no se cargo correctamente en la Tabla';
            RETURN cCodRet, cMensajeRet;		
		END IF;
		
		--Sumatoria de totales para operaciones de TELCEL
		SELECT SUM(CAST(amount as MONEY(18,2)))  
		INTO mTotalTelcel
		FROM bdisac:sac_arch_conci_tapi
		--WHERE company_code = 'MX-R-00054' OR company_code ='MX-R-00001';
		WHERE company_code IN ('MX-R-00001','MX-R-00054');
		
		--Obtencion de transaccion para SPEI
		SELECT vchrvalor INTO cTransaccionSPEI FROM bdispei:tblparametros WHERE vchrcveparametro = 'TRANSACC_CARGO';

		--Validacion de total de operaciones TELCEL en 0
		IF mTotalTelcel > 0 THEN

			--Consulta y asignacion de valores para realizar el cargo y el envio del SPEI de TELCEL.
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cCuentaOrdenSPEI FROM bdisac:sac_param WHERE cod_param = 167;
			SELECT num_cte,cuenta INTO cNumCte,cCuentaOrden FROM bdicheq:sc_maechq WHERE cuenta_clabe = cCuentaOrdenSPEI;
			SELECT razon_social,rfc INTO cNombreOrdenSPEI,cRFCOrdenSPEI FROM bdinteg:si_cliente WHERE numcte = cNumCte;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cNombreBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 158;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cCuentaBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 160;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cRFCBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 162;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cConceptoPagoSPEI FROM bdisac:sac_param WHERE cod_param = 164;		
			
			--Obtencion de Folio para operaciones de cargo y SPEI
			EXECUTE PROCEDURE bdispei:sp_obtfoliosuc(cUsuario) INTO cCodRetSp, iSerialFolioSPEI, cFolioSucursalSPEI;
			
			--Validacion de obtencion de Folio exitoso
			IF cCodRetSp = '000' THEN
				--Operacion de cargo a cuenta TELCEL
				EXECUTE PROCEDURE bdicheq:cargo_ref(cEmpresa, cSucursalSPEI, cUsuario, cTransaccionSPEI, '0000', cFolioSucursalSPEI, cCuentaOrden, 0, mTotalTelcel, '01', cCveRastreo, '', cUsuario)
				INTO cCodRetCgo, cTrxCgo, dFechaCgo, mSdoDispCgo, mMontoCgo;
				
				--Validacion de cargo fallido
				IF cCodRetCgo <> '000' THEN
					LET cCodRet = "00004";
					LET cMensajeRet = 'Error en el cargo a la cuenta concentradora de TELCEL (codRet: '|| cCodRetCgo || ')';
			
					RETURN cCodRet, cMensajeRet;
				END IF;				
			
			ELSE 
				LET cCodRet = "00005";
				LET cMensajeRet = 'Error al obtener el folio_suc para cargo a cuenta concentradora de TELCEL (codRet: '|| cCodRetSp || ')';
				RETURN cCodRet, cMensajeRet;
			END IF;

			--Operacion de SPEI a cuenta TELCEL
			EXECUTE PROCEDURE bdispei:sp_regordenpagospei_pp( cEmpresa, cUsuario, cSucursalSPEI, cFolioSucursalSPEI, iBancoDestinoSPEI, dFechaCapturaSPEI, iTipoPagoSPEI, 
															iTipoOperacionSPEI, mTotalTelcel, cNombreOrdenSPEI, cCuentaOrdenSPEI, cRFCOrdenSPEI, cNombreBeneficiarioSPEI, 
															cCuentaBeneficiarioSPEI, cRFCBeneficiarioSPEI, mImporteIVASPEI, dReferenciaNumero, cReferenciaCobranza1SPEI, 
															cConceptoPagoSPEI, cClavePagoSPEI, cNombreBeneficiario2SPEI, cCuentaBeneficiario2SPEI, cRFCBeneficiario2SPEI,
															cConceptoPagoSPEI, cTransaccionSPEI, iTipoCuentaOrdenSPEI, iTipoCuentaBeneficiarioSPEI )
			INTO cCodRetSp, cInfoErr, cCveRastreo;
			
			--Validacion de SPEI fallido
			IF cCodRetSp <> '000' THEN 
				LET cCodRet = "00006";
				LET cMensajeRet = 'Error en envio de SPEI a TELCEL (codRet: '|| TRIM(cCodRetSp) || ' - ' || TRIM(cInfoErr) ||')';
				--Proceso de reversion
				EXECUTE PROCEDURE bdicheq:reversion_web(cEmpresa,cSucursalSPEI,cUsuario,cFolioSucursalSPEI,'A') INTO rCodRet;
				RETURN cCodRet, cMensajeRet;
			END IF;
			
			--Actualizacion de referencia del movimiento de cargo
			UPDATE bdicheq:sc_movdia SET referencia = cCveRastreo
				 WHERE folio_suc = cFolioSucursalSPEI;

		ELSE 
		
		LET mTotalTelcel = 0.00;
		
		END IF;
		
		-- COMIENZA LIQUIDACION TAPI
		
		--Sumatoria de totales para otras operaciones		
		SELECT {+INDEX(sac_arch_conci_tapi idx_sac_arch_conci_tapi_company_code)} SUM(CAST(amount as MONEY(18,2)))  
		INTO mTotalTapi
		FROM bdisac:sac_arch_conci_tapi
		WHERE company_code NOT IN ('MX-R-00001','MX-R-00054');
				
		IF mTotalTapi > 0 THEN
			--Consulta y asignacion de valores para realizar el cargo y el envio del SPEI de TAPI.
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cCuentaOrdenSPEI FROM bdisac:sac_param WHERE cod_param = 168;
			SELECT num_cte,cuenta INTO cNumCte,cCuentaOrden FROM bdicheq:sc_maechq WHERE cuenta_clabe = cCuentaOrdenSPEI;
			SELECT razon_social,rfc INTO cNombreOrdenSPEI,cRFCOrdenSPEI FROM bdinteg:si_cliente WHERE numcte = cNumCte;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cNombreBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 157;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cCuentaBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 159;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cRFCBeneficiarioSPEI FROM bdisac:sac_param WHERE cod_param = 161;
			SELECT {+INDEX(sc_param idx_param1 )} valor INTO cConceptoPagoSPEI FROM bdisac:sac_param WHERE cod_param = 163;
							
			--Obtencion de Folio para operaciones de cargo y SPEI
			EXECUTE PROCEDURE bdispei:sp_obtfoliosuc(cUsuario) INTO cCodRetSp, iSerialFolioSPEI, cFolioSucursalSPEI;
		
			--Validacion de obtencion de Folio exitoso
			IF cCodRetSp = '000' THEN
				--Operacion de cargo a cuenta de TAPI
				EXECUTE PROCEDURE bdicheq:cargo_ref(cEmpresa, cSucursalSPEI, cUsuario, cTransaccionSPEI, '0000', cFolioSucursalSPEI, cCuentaOrden, 0, mTotalTapi, '01', cCveRastreo, '', cUsuario)
				INTO cCodRetCgo, cTrxCgo, dFechaCgo, mSdoDispCgo, mMontoCgo;
						
				--Validacion de cargo fallido
				IF cCodRetCgo <> '000' THEN
					LET cCodRet = "00007";
					LET cMensajeRet = 'Error en el cargo a la cuenta concentradora de TAPI (codRet: '|| cCodRetCgo || ')';
					RETURN cCodRet, cMensajeRet;
				END IF;					
			ELSE 
				LET cCodRet = "00008";
				LET cMensajeRet = 'Error al obtener el folio_suc para cargo a cuenta concentradora de TAPI (codRet: '|| cCodRetSp || ')';
				RETURN cCodRet, cMensajeRet;
			END IF;

			--Operacion de SPEI a cuenta TAPI
			EXECUTE PROCEDURE bdispei:sp_regordenpagospei_pp( cEmpresa, cUsuario, cSucursalSPEI, cFolioSucursalSPEI, iBancoDestinoSPEI, dFechaCapturaSPEI, iTipoPagoSPEI, 
															iTipoOperacionSPEI, mTotalTapi, cNombreOrdenSPEI, cCuentaOrdenSPEI, cRFCOrdenSPEI, cNombreBeneficiarioSPEI, 
															cCuentaBeneficiarioSPEI, cRFCBeneficiarioSPEI, mImporteIVASPEI, dReferenciaNumero, cReferenciaCobranza1SPEI, 
															cConceptoPagoSPEI, cClavePagoSPEI, cNombreBeneficiario2SPEI, cCuentaBeneficiario2SPEI, cRFCBeneficiario2SPEI,
															cConceptoPagoSPEI, cTransaccionSPEI, iTipoCuentaOrdenSPEI, iTipoCuentaBeneficiarioSPEI )
			INTO cCodRetSp, cInfoErr, cCveRastreo;
					
			--Validacion de SPEI fallido
			IF cCodRetSp <> '000' THEN 
				LET cCodRet = "00009";
				LET cMensajeRet = 'Error en envio de SPEI a TAPI (codRet: '|| TRIM(cCodRetSp) || ' - ' || TRIM(cInfoErr) ||')';
				--Proceso de reversion
				EXECUTE PROCEDURE bdicheq:reversion_web(cEmpresa,cSucursalSPEI,cUsuario,cFolioSucursalSPEI,'A')  INTO rCodRet;
				
				RETURN cCodRet, cMensajeRet;
			END IF;
			
			--Actualizacion de referencia del movimiento de cargo
			UPDATE bdicheq:sc_movdia SET referencia = cCveRastreo
				 WHERE folio_suc = cFolioSucursalSPEI;
		ELSE
		
		LET mTotalTapi = 0.00;
		
		END IF;
		--Insercion de registro a tabla de control 
		INSERT INTO bdisac:sac_control_proceso_archivo_tapi(monto_tot_telcel,monto_tot_tapi,fecha_proceso,nombre_archivo)
		VALUES(mTotalTelcel,mTotalTapi,TODAY,cNombreArchivo);
			
	RETURN cCodRet, cMensajeRet;

	END
END PROCEDURE;