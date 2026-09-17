CREATE PROCEDURE "informix".sp_genrep_cons_bts_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10)  AS cFecha,
                  CHAR(12)  AS cHora,
                  CHAR(16)  AS cFolio,
                  CHAR(8)   AS cUsuario,
                  CHAR(4)   AS cSucursal,
                  CHAR(17)  AS cImporte,
                  CHAR(4)   AS cTransaccion,
                  CHAR(20)  AS cClave_de_Confirmacion,
                  CHAR(104) AS cBeneficiario,
                  CHAR(25)  AS cIdentificacion,
                  CHAR(25)  AS cFolio_Identificacion,
                  CHAR(45)  AS cForma_de_Pago,
                  CHAR(20)  AS cCuenta,
                  CHAR(4)   AS cTransSuc,
                  INTEGER   AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE dFecha        		CHAR(10);
	DEFINE cHora         		CHAR(12);
	DEFINE cFolio        		CHAR(16);
	DEFINE cUsuario      		CHAR(8);
	DEFINE cSucursal     		CHAR(4);
	DEFINE cImporte      		CHAR(17);
	DEFINE cTransaccion  		CHAR(4);
	DEFINE cCveConfirm   		CHAR(20);
	DEFINE cBeneficiario   		CHAR(104);
	DEFINE cIdentificacion 		CHAR(25);
	DEFINE cFolioIdentificacion CHAR(25);
	DEFINE cFormaPago    		CHAR(45);
	DEFINE cCuenta       		CHAR(20);
	DEFINE cTransacSuc   		CHAR(4);
	DEFINE iTotalRows  	 		INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET dFecha          	 = "";
	LET cHora           	 = "";
	LET cFolio          	 = "";
	LET cUsuario        	 = "";
	LET cSucursal       	 = "";
	LET cImporte        	 = "";
	LET cTransaccion    	 = "";
	LET cCveConfirm     	 = "";
	LET cBeneficiario   	 = "";
	LET cIdentificacion 	 = "";
	LET cFolioIdentificacion = "";
	LET cFormaPago      	 = "";
	LET cCuenta         	 = "";
	LET cTransacSuc     	 = "";
	LET iTotalRows   		 = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_bts_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_bts_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_bts_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, UPPER(cBeneficiario), UPPER(cIdentificacion), cFolioIdentificacion, UPPER(cFormaPago), cCuenta, cTransacSuc, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cCveConfirm, cBeneficiario, cIdentificacion, cFolioIdentificacion, cFormaPago, cCuenta, cTransacSuc, iTotalRows;			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE REMESAS BTS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_chq_dev_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
				  CHAR(16) AS cFolio,
				  CHAR(10) AS cFecha,
				  CHAR(20) AS cCuenta,
				  CHAR(17) AS cMonto,
				  CHAR(12) AS cHora,
				  CHAR(8)  AS cUsuario,
				  CHAR(4)  AS cTransaccion,
				  CHAR(17) AS cSaldo,
				  CHAR(4)  AS cSucursal,
				  CHAR(4)  AS cBanco,
				  CHAR(20) AS cCuentaBanco,
				  CHAR(11) AS cCheque,
				  CHAR(16) AS cTarjeta,
				  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE dFechaAlt     CHAR(10);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cHora         CHAR(12);
	DEFINE cUsuario      CHAR(8);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR(4);
	DEFINE cBanco        CHAR(4);
	DEFINE cCtaBanco     CHAR(20);
	DEFINE cCheque       CHAR(11);
	DEFINE cTarjeta      CHAR(16);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = "";
	LET cFolio        = "";
	LET dFechaAlt     = "";
	LET cCuenta       = "";
	LET cMonto        = "";
	LET cHora         = "";
	LET cUsuario      = "";
	LET cTransaccion  = "";
	LET cSaldo        = "";
	LET cSucursal     = "";
	LET cBanco        = "";
	LET cCtaBanco     = "";
	LET cCheque       = "";
	LET cTarjeta      = "";
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_chq_dev_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_chq_dev_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows

			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_chq_dev_aud";
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, dFechaAlt, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CHEQUES DEVUELTOS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_chq_propios_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
                  CHAR(16) AS cFolio,
                  CHAR(10) AS cFecha,
                  CHAR(20) AS cCuenta,
                  CHAR(17) AS cMonto,
                  CHAR(12) AS cHora,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cSaldo,
                  CHAR(4)  AS cSucursal,
                  CHAR(11) AS cCheque,
                  CHAR(4)  AS cTransSuc,
                  CHAR(16) AS cTarjeta,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE cFecha        CHAR(10);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cHora         CHAR(12);
	DEFINE cUsuario      CHAR(8);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR (4);
	DEFINE cCheque       CHAR(11);
	DEFINE cTrans_Suc    CHAR(4);
	DEFINE cTarjeta      CHAR(16);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = '';
	LET cFolio        = '';
	LET cFecha        = '';
	LET cCuenta       = '';
	LET cMonto        = '';
	LET cHora         = '';
	LET cUsuario      = '';
	LET cTransaccion  = '';
	LET cSaldo        = '';
	LET cSucursal     = '';
	LET cCheque       = '';
	LET cTrans_Suc    = '';
	LET cTarjeta      = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;				   
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_chq_propios_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_chq_propios_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_chq_propios_aud";
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cCheque, cTrans_Suc, cTarjeta, iTotalRows;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CHEQUES PROPIOS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_chq_sbc_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
                  CHAR(16) AS cFolio,
                  CHAR(10) AS cFecha,
                  CHAR(20) AS cCuenta,
                  CHAR(17) AS cMonto,
                  CHAR(12) AS cHora,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cSaldo,
                  CHAR(4)  AS cSucursal,
                  CHAR(3)  AS cBanco,
                  CHAR(20) AS cCuentaBanco,
                  CHAR(11) AS cCheque,
                  CHAR(16) AS cTarjeta,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE cFecha        CHAR(10);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cHora         CHAR(12);
	DEFINE cUsuario      CHAR(8);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR(4);
	DEFINE cBanco        CHAR(4);
	DEFINE cCtaBanco     CHAR(20);
	DEFINE cCheque       CHAR(11);
	DEFINE cTarjeta      CHAR(16);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = '';
	LET cFolio        = '';
	LET cFecha        = '';
	LET cCuenta       = '';
	LET cMonto        = '';
	LET cHora         = '';
	LET cUsuario      = '';
	LET cTransaccion  = '';
	LET cSaldo        = '';
	LET cSucursal     = '';
	LET cBanco        = '';
	LET cCtaBanco     = '';
	LET cCheque       = '';
	LET cTarjeta      = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_chq_sbc_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_chq_sbc_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_chq_sbc_aud";
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, cFecha, cCuenta, cMonto, cHora, cUsuario, cTransaccion, cSaldo, cSucursal, cBanco, cCtaBanco, cCheque, cTarjeta, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CHEQUES SBC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_conc_efect_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cSucursal,
                  CHAR(17) AS cImporte,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cFolioPapeleta,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha        CHAR(10);
	DEFINE cHora         CHAR(12);
	DEFINE cFolio        CHAR(16);
	DEFINE cUsuario      CHAR(8);
	DEFINE cSucursal     CHAR(4);
	DEFINE cImporte      CHAR(17);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cFolioPap     CHAR(10);
	DEFINE iTotalRows    INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha        = '';
	LET cHora         = '';
	LET cFolio        = '';
	LET cUsuario      = '';
	LET cSucursal     = '';
	LET cImporte      = '';
	LET cTransaccion  = '';
	LET cFolioPap     = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_conc_efect_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		FOREACH		
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_conc_efect_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_conc_efect_aud";			
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap,iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE CONCENTRACION DE EFECTIVO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_dota_efect_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cSucursal,
                  CHAR(17) AS cImporte,
                  CHAR(4)  AS cTransaccion,
                  CHAR(17) AS cFolioPapeleta,
                  CHAR(4)  AS cTransSuc,
                  INTEGER  AS iTotRows;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha        CHAR(10);
	DEFINE cHora         CHAR(12);
	DEFINE cFolio        CHAR(16);
	DEFINE cUsuario      CHAR(8);
	DEFINE cSucursal     CHAR(4);
	DEFINE cImporte      CHAR(17);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cFolioPap   	 CHAR(8);
	DEFINE cTransacSuc   CHAR(4);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha        = '';
	LET cHora         = '';
	LET cFolio        = '';
	LET cUsuario      = '';
	LET cSucursal     = '';
	LET cImporte      = '';
	LET cTransaccion  = '';
	LET cFolioPap     = '';
	LET cTransacSuc   = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_dota_efect_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH		
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_dota_efect_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_dota_efect_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte, cTransaccion, cFolioPap, cTransacSuc, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE DOTACION DE EFECTIVO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_orden_pago_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(4)  AS cSucursal,
                  CHAR(14) AS cImporte,
                  CHAR(4)  AS cTransaccion,
                  CHAR(20) AS cNoOrden,
                  CHAR(105)AS cBeneficiario,
                  CHAR(2)  AS cIdentificacion,
                  CHAR(25) AS cFolioIdentificacion,
                  CHAR(15) AS cFormaPago,
                  CHAR(12) AS cCuenta,
                  CHAR(4)  AS cTransSuc,
                  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cFecha 	 	   CHAR(10);
	DEFINE cHora 	 	   CHAR(12);
	DEFINE cFolio 	 	   CHAR(16);
	DEFINE cUsuario  	   CHAR(8);
	DEFINE cSucursal 	   CHAR(4);
	DEFINE cImporte 	   CHAR(14);
	DEFINE cTransaccion    CHAR(4);
	DEFINE cNumOrden 	   CHAR(20);
	DEFINE cBeneficiario   CHAR(105);
	DEFINE cIdentificacion CHAR(2);
	DEFINE cFolioIdent 	   CHAR(25);
	DEFINE cFormaPago 	   CHAR(15);
	DEFINE cCuenta 		   CHAR(12);
	DEFINE cTransacSuc 	   CHAR(4);	
	DEFINE iTotalRows  	   INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha 			= "";
	LET cHora 			= "";
	LET cFolio 			= "";
	LET cUsuario		= "";
	LET cSucursal 		= "";
	LET cImporte 		= "";
	LET cTransaccion 	= "";
	LET cNumOrden 		= "";
	LET cBeneficiario 	= "";
	LET cIdentificacion = "";
	LET cFolioIdent 	= "";
	LET cFormaPago 		= "";
	LET cCuenta 		= "";
	LET cTransacSuc 	= "";
	LET iTotalRows   	= 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_orden_pago_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_orden_pago_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_orden_pago_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, UPPER(cBeneficiario), UPPER(cIdentificacion), cFolioIdent, UPPER(cFormaPago), cCuenta,cTransacSuc, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cHora, cFolio, cUsuario, cSucursal, cImporte,cTransaccion, cNumOrden, cBeneficiario, cIdentificacion, cFolioIdent, cFormaPago, cCuenta,cTransacSuc, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE ORDEN DE PAGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_reversos_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cNoCliente,
                  CHAR(16) AS cFolio,
                  CHAR(8)  AS cUsuario,
                  CHAR(10) AS cFecha,
                  CHAR(12) AS cHora,
                  CHAR(20) AS cCuenta,
                  CHAR(18) AS cMonto,
                  CHAR(4)  AS cTransaccion,
                  CHAR(18) AS cSaldo,
                  CHAR(4)  AS cSucursal,
                  CHAR(4)  AS cTransSuc,
                  CHAR(40) AS cReferencia,
                  CHAR(20) AS cTarjeta,
                  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cCliente 	 CHAR(20);
	DEFINE cFolio 		 CHAR(16);
	DEFINE cUsuario 	 CHAR(8);
	DEFINE cFecha 		 CHAR(10);
	DEFINE cHora 		 CHAR(12);
	DEFINE cCuenta 		 CHAR(20);
	DEFINE cMonto 		 CHAR(18);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo 		 CHAR(18);
	DEFINE cSucursal 	 CHAR(4);
	DEFINE cTransSuc 	 CHAR(4);
	DEFINE cReferencia 	 CHAR(40);
	DEFINE cTarjeta 	 CHAR(20);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente 	  = "";
	LET cFolio 		  = "";
	LET cUsuario 	  = "";
	LET cFecha 		  = "";
	LET cHora 		  = "";
	LET cCuenta 	  = "";
	LET cMonto 		  = "";
	LET cTransaccion  = "";
	LET cSaldo        = "";
	LET cSucursal     = "";
	LET cTransSuc     = "";
	LET cReferencia   = "";
	LET cTarjeta 	  = "";
	LET iTotalRows 	  = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_reversos_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_reversos_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_reversos_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, cUsuario, cFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransSuc, cReferencia, cTarjeta, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE REVERSOS',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_sobrantes_caja_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pFechaRep CHAR(10), pImporte CHAR(21), pFechaEliminacion CHAR(10), pNumTransaccion CHAR(4), pOperador CHAR(8), pLinea INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS cFecha,
				  CHAR(8)  AS cUsuario,
				  CHAR(45) AS cNombre,
				  CHAR(21) AS cImporte,
				  CHAR(10) AS cFechaEliminacion,
				  CHAR(4)  AS cTransaccion,
				  CHAR(4)  AS cSucursal,
				  CHAR(16) AS cSaldo,
				  CHAR(4)  AS cTransSuc,
				  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha        CHAR(10);
	DEFINE cUsuario      CHAR(8);
	DEFINE cNombreUsu    CHAR(45);
	DEFINE cImporte      CHAR(21);
	DEFINE cImporte2     CHAR(21);
	DEFINE cFechaElimina CHAR(10);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSucursal     CHAR(4);
	DEFINE cTransSuc     CHAR(4);	
	DEFINE iTotalRows  	 INTEGER;
	DEFINE cVacio        CHAR(4);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;		
	LET cFecha        = '';
	LET cUsuario      = '';
	LET cNombreUsu    = '';
	LET cImporte      = '';
	LET cImporte2     = '';
	LET cFechaElimina = '';
	LET cTransaccion  = '';
	LET cSucursal     = '';
	LET cTransSuc     = '';
	LET iTotalRows    = 0;
	LET cVacio     	  = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_sobrantes_caja_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH				
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_sobrantes_caja_aud(pTipo, pCodigo, cEmpresa, pSucursal, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion, pFechaRep , pImporte , pFechaEliminacion , pNumTransaccion , pOperador, pLinea)
			INTO cCodRetSp, cFecha, cUsuario, cNombreUsu, cImporte, cFechaElimina, cTransaccion, cSucursal, cImporte2, cTransSuc, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_sobrantes_caja_aud";		
			ELIF iCodRetSp = 1 OR iCodRetSp = 3 OR iCodRetSp = 4 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '01012'; --SOBREPASA EL AÑO DE CONSULTA O ESTA CONSULTANDO LA FECHA HOY, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
			ELIF iCodRetSp = 5 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cUsuario, cNombreUsu, cImporte, REPLACE(TRIM(cFechaElimina),'-','/'), LPAD(TRIM(cTransaccion),4,'0'), cSucursal, cImporte2, LPAD(TRIM(cTransSuc),4,'0'), iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE SOBRANTES EN CAJA',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_spei_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cCliente,
                  CHAR(16) AS cFolio,
                  CHAR(10) AS cFecha,
                  CHAR(20) AS cCuenta,
                  CHAR(17) AS cMonto,
                  CHAR(12) AS cHora,
                  CHAR(4)  AS cSucursal,
                  CHAR(17) AS cSaldo,
                  CHAR(4)  AS cTransaccion,
                  CHAR(40) AS cReferencia,
                  CHAR(4)  AS cTransSuc,
                  INTEGER  AS iTotRows;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cCliente      CHAR(20);
	DEFINE cFolio        CHAR(16);
	DEFINE dFecha        CHAR(10);
	DEFINE cHora         CHAR(12);
	DEFINE cCuenta       CHAR(20);
	DEFINE cMonto        CHAR(17);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSaldo        CHAR(17);
	DEFINE cSucursal     CHAR(4);
	DEFINE cTransacSuc   CHAR(4);
	DEFINE cReferencia   CHAR(40);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cCliente      = "";
	LET cFolio        = "";
	LET dFecha        = "";
	LET cHora         = "";
	LET cCuenta       = "";
	LET cMonto        = "";
	LET cTransaccion  = "";
	LET cSaldo        = "";
	LET cSucursal     = "";
	LET cTransacSuc   = "";
	LET cReferencia   = "";
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_spei_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni  = '' OR pFechaFin  = '' OR pSucursal  = '' OR pCodigo  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_spei_aud(pTipo, pFechaIni, pFechaFin, cEmpresa, pSucursal, pCodigo, pUsuario, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_spei_aud";		
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCliente, cFolio, dFecha, cHora, cCuenta, cMonto, cTransaccion, cSaldo, cSucursal, cTransacSuc, cReferencia, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA GENERACION DEL REPORTE CONSULTA DE SPEI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_param_conexion_postgres(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS cNumIp,
				  CHAR(100) AS cPuerto,
				  CHAR(100) AS cNomUsuario,
				  CHAR(100) AS cPassword,
				  CHAR(100) AS cNomBd,
				  CHAR(100) AS cTiempo,
				  CHAR(100) AS cLimite;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;	
	DEFINE cNumIp      CHAR(100);
	DEFINE cPuerto     CHAR(100);
	DEFINE cNomUsuario CHAR(100);
	DEFINE cPassword   CHAR(100);
	DEFINE cNomBd      CHAR(100);
	DEFINE cTiempo     CHAR(100);
	DEFINE cLimite     CHAR(100);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;		
	LET cNumIp      = '';
	LET cPuerto     = '';
	LET cNomUsuario = '';
	LET cPassword   = '';
	LET cNomBd      = '';
	LET cTiempo     = '';
	LET cLimite     = '';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_param_conexion_postgres.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_obtiene_conexion_param(cEmpresa)
		INTO cCodRetSp, cNumIp, cPuerto, cNomUsuario, cPassword, cNomBd, cTiempo, cLimite;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_obtiene_conexion_param";		
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), TRIM(cTiempo), TRIM(cLimite);
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÑO MEJIA',
'FECHA: 06/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: ESTE PROCEDIMIENTO OBTIENE LOS DATOS PARA LA CONEXION A LA BASE DE DATOS DE POSTGRES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validasucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_sucursal;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreSucursal CHAR(45);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreSucursal = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreSucursal;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validasucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_sucursal(cEmpresa, pSucursal)
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_valida_sucursal';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
		ELIF cCodRetSp::INTEGER = 3 THEN
			LET cCodRet = '00161'; --EL NÚMERO DE SUCURSAL ES INCORRECTO
		ELIF cCodRetSp::INTEGER = 0 THEN
			
			SELECT nombre 
			INTO cNombreSucursal 
			FROM bdinteg:"informix".si_sucursales 
			WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		END IF;
		
		RETURN cCodRet,NVL(UPPER(cNombreSucursal),'');
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 11/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: Spl encargado de validar que la sucursal exista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_catalogostatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
		CHAR(2) AS status,
		CHAR(40) AS descripcion;
    
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cStatus CHAR(2);
	DEFINE cDescripcion CHAR(40);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cStatus = null;
	LET cDescripcion = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cDescripcion;
		END EXCEPTION;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_catalogostatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT status_solicitud, descripcion
			INTO cStatus, cDescripcion			
			FROM bdisolic:"informix".ss_status_sol ORDER BY status_solicitud
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cStatus, UPPER(cDescripcion) WITH RESUME; 
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cStatus, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo status.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_consultaperfilusuario(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret,
		SMALLINT AS tipo_perfil,
		CHAR(10) AS desc_perfil;
    
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iTipoPerfil SMALLINT;
	DEFINE cDescPerfil CHAR(10);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET iTipoPerfil = null;
	LET cDescPerfil = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END EXCEPTION;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_consultaperfilusuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END IF;

		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_valida_perfil_usuario(cEmpresa,pUsuario)
		INTO cCodRetSp, cDescCodRetSp, iTipoPerfil;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_valida_perfil_usuario';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTipoPerfil, cDescPerfil;
		END IF;
		
		IF iTipoPerfil = 0 THEN
			LET cDescPerfil = 'CRÉDITO';
		ELIF iTipoPerfil = 1 THEN
			LET cDescPerfil = 'AUDITORÍA';
		END IF;
		
		RETURN cCodRet, iTipoPerfil, cDescPerfil; 
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el perfil del usuario que está ingresando a la funcionalidad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_detallestatussol(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
pSucursal CHAR(4), pStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(4) AS sucursal,       
		CHAR(40) AS nom_sucursal,     
		CHAR(104) AS nom_cliente,    
		CHAR(2) AS status_solicitud,      
		MONEY(14,2) AS monto_solicitud,  
		MONEY(14,2) AS monto_otorgado,  
		DATE AS fecha_alta,         
		DATE AS fecha_cambio_status,         
		DECIMAL(10,2) AS eficiencia_pago,
		SMALLINT AS meses_historial, 
		SMALLINT AS scoring_1,     
		SMALLINT AS scoring_2,     
		SMALLINT AS total_scoring,     
		CHAR(10) AS causa_rechazo;	
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNum_solicitud CHAR(20);
	DEFINE cSucursal CHAR(4); 
	DEFINE cNom_sucursal CHAR(40);  
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2);  
	DEFINE dFecha_alta DATE;
	DEFINE dFecha_cambio_status DATE;
	DEFINE dEficiencia_pago DECIMAL(10,2);
	DEFINE iMeses_historial SMALLINT;
	DEFINE iScoring_1 SMALLINT;
	DEFINE iScoring_2 SMALLINT;
	DEFINE iTotal_scoring SMALLINT;
	DEFINE cCausa_rechazo CHAR(10);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNum_solicitud = '';
	LET cSucursal = ''; 
	LET cNom_sucursal = ''; 
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_alta = '';
	LET dFecha_cambio_status = '';
	LET dEficiencia_pago = 0.00; 
	LET iMeses_historial = 0;
	LET iScoring_1 = 0;
	LET iScoring_2 = 0;
	LET iTotal_scoring = 0;
	LET cCausa_rechazo = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END EXCEPTION;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_detallestatussol.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pSucursal  = '' OR pStatus  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;

		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".status_sol2(cEmpresa,pSucursal,pFechaFin,pFechaInicio,pStatus,pRegistros,pRecuperacion)			
			INTO cCodRetSp, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:status_sol2';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNum_solicitud, cSucursal, UPPER(cNom_sucursal), UPPER(cNom_cliente), UPPER(cStatus_solicitud), 
			NVL(mMonto_solicitud,0), NVL(mMonto_otorgado,0), dFecha_alta, dFecha_cambio_status,  
			NVL(dEficiencia_pago,0), NVL(iMeses_historial,0), NVL(iScoring_1,0), NVL(iScoring_2,0), NVL(iTotal_scoring,0), UPPER(cCausa_rechazo) WITH RESUME;	
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo;
		END IF;	
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el detalle del status de la solicitud.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_detallestatussolaud(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10), 
pSucursal CHAR(4), pStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(20) AS num_solicitud,
		CHAR(20) AS num_cliente,
		DATE AS fecha_alta, 
		CHAR(104) AS nom_cliente,    
		CHAR(2) AS status_solicitud,      
		MONEY(14,2) AS monto_solicitud,  
		MONEY(14,2) AS monto_otorgado,
		DATE AS fecha_cambio_status,
		CHAR(45) AS nom_promotor,
		CHAR(13) AS tel_particular,
		CHAR(13) AS tel_celular,
		CHAR(13) AS tel_oficina,
		CHAR(4) AS sucursal;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFecha_alta DATE;
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2); 
	DEFINE dFecha_cambio_status DATE;
	DEFINE cNom_promotor CHAR(45);
	DEFINE cTelefono_particular CHAR(13);
	DEFINE cTelefono_celular CHAR(13);
	DEFINE cTelefono_oficina CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE iRecuperacion INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
    LET cNum_solicitud = '';
	LET cNum_cliente = '';
	LET dFecha_alta = '';
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_cambio_status = '';
	LET cNom_promotor = '';
	LET cTelefono_particular = '';
	LET cTelefono_celular = '';
	LET cTelefono_oficina = '';
	LET cSucursal = '';
	LET iRecuperacion = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END EXCEPTION;
  
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cre_detallestatussolaud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pSucursal  = '' OR pStatus  = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;

		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".sp_status_sol_aud2(cEmpresa,pSucursal,pFechaFin,pFechaInicio,pStatus,pRegistros,pRecuperacion)			
			INTO cCodRetSp, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicred:sp_status_sol_aud2';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, UPPER(cNom_cliente), UPPER(cStatus_solicitud), NVL(mMonto_solicitud,0), NVL(mMonto_otorgado,0),
			dFecha_cambio_status, UPPER(cNom_promotor), cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNum_solicitud, cNum_cliente, dFecha_alta, cNom_cliente, cStatus_solicitud, mMonto_solicitud, mMonto_otorgado,
			dFecha_cambio_status, cNom_promotor, cTelefono_particular, cTelefono_celular, cTelefono_oficina, cSucursal;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 04/08/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: EXPEDIENTE DE CRÉDITO',
'DESCRIPCION: SPL encargado de consultar el detalle de los datos del reporte de solicitudes para el area de auditoria.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genrep_cons_faltantes_caja_aud(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo INTEGER, pFechaIni CHAR(10), pFechaFin CHAR(10), pSucursal CHAR(4), pCodigo CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS fecha,
				  CHAR(8)  AS usuario,
				  CHAR(21) AS importe,
				  CHAR(45) AS nombre,
				  CHAR(4)  AS transaccion,
				  CHAR(4)  AS sucursal,
				  CHAR(10) AS fecha_eliminacion,
				  CHAR(21) AS saldo,
				  CHAR(10) AS fecha_asignacion,
				  INTEGER  AS total_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
    DEFINE iRecuperacion INTEGER;	
	DEFINE cFecha 		 CHAR(10);
	DEFINE cUsuario		 CHAR(8);
	DEFINE cImporte		 CHAR(21);
	DEFINE cNombre		 CHAR(45);
	DEFINE cTransaccion  CHAR(4);
	DEFINE cSucursal	 CHAR(4);
	DEFINE cFechaElimina CHAR(10);
	DEFINE cSaldo	     CHAR(21);
	DEFINE cFechaAsigna  CHAR(10);
	DEFINE iTotalRows  	 INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;	
	LET cFecha        = '';
	LET cUsuario      = '';
	LET cImporte      = '';
	LET cNombre		  = '';
	LET cTransaccion  = '';
	LET cSucursal	  = '';
	LET cFechaElimina = '';
	LET cSaldo	      = '';
	LET cFechaAsigna  = '';
	LET iTotalRows    = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;		
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genrep_cons_faltantes_caja_aud.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo IS NULL OR pFechaIni = '' OR pFechaFin = '' OR pSucursal = '' OR pCodigo = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
		IF pTipo = 1 THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_faltantes_caja_aud(pTipo, pCodigo, cEmpresa, pSucursal, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL bdinteg:sp_cons_faltantes_caja_aud";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '01012'; --SOBREPASA EL AÑO DE CONSULTA O ESTA CONSULTANDO LA FECHA HOY, VERIFIQUE 
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 0 THEN
				LET pTipo = 2;
			END IF;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH		
			EXECUTE PROCEDURE bdinteg:"informix".sp_cons_faltantes_caja_aud(pTipo, pCodigo, cEmpresa, pSucursal, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SPL bdinteg:sp_cons_faltantes_caja_aud";
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '01012'; --SOBREPASA EL AÑO DE CONSULTA O ESTA CONSULTANDO LA FECHA HOY, VERIFIQUE 
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
				RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cFecha, cUsuario, cImporte, UPPER(cNombre), cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cFecha, cUsuario, cImporte, cNombre, cTransaccion, cSucursal, cFechaElimina, cSaldo, cFechaAsigna, iTotalRows;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 11/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE TRANSACCIONES',
'DESCRIPCION: SPL encargado de obtener los datos del reporte de faltante en caja.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consctecuenta(pIdUsuario char(8), pIdFuncion char(10), pNumCliente char(20), pNumCuenta char(20), pSistemaCuenta char(2))
	RETURNING CHAR(5)     AS Cod_Retorno,
				CHAR(1)     AS Producto,
				CHAR(2)     AS Sistema_Cuenta,
				CHAR(20)    AS Numero_Cuenta,
				CHAR(4)     AS Cve_Producto,
				CHAR(40)    AS Nombre_Producto,
				DATE        AS Fecha_Apertura,
				CHAR(60)    AS Status_Cuenta,
				DATE        AS Fecha_Status,
				CHAR(4)     AS Clave_Sucursal,
				CHAR(8)     AS Ejecutivo,
				MONEY(14,2) AS Saldo_Actual,
                CHAR(20)    AS Numero_Tarjeta,
				CHAR(15)    AS Status_Tarjeta,
				CHAR(18)    AS Cuenta_CLABE,
				DATE        AS Fecha_Apertura_Inversion,
                SMALLINT    AS Dia_Corte,
				DATE		AS Fecha_cancelacion;

	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCodRetSp		CHAR(5);
	DEFINE iSql_err 		INT;
	--SISTEMA DE CUENTA 01 VARIABLES
	DEFINE cIProducto_chequera	CHAR(1);
	DEFINE cScuenta				CHAR(2);
	DEFINE cNo_cuenta			CHAR(20);
	DEFINE cNo_tarjeta			CHAR(20);
	DEFINE cClave_producto		CHAR(4);
	DEFINE cNombre_producto		CHAR(40);
	DEFINE cCuenta_clabe		CHAR(18);
	DEFINE dFecha_apertura		DATE;
	DEFINE cStatus_tarjeta		CHAR(15);
	DEFINE cStatus_cuenta		CHAR(60);
	DEFINE dFecha_status		DATE;
	DEFINE cClave_sucursal		CHAR(4);
	DEFINE cEjecutivo 			CHAR(8);
	DEFINE mSaldo_actual		MONEY(14,2);
	DEFINE dFecha_aperturaO_inv DATE;
	DEFINE dFecha_max			DATE;
	DEFINE dFecha_min			DATE;
	DEFINE cNumero_cuenta 		CHAR(20);
	DEFINE dFecha 				DATE;
	DEFINE iCont                INTEGER;
	DEFINE iMaxSec              INTEGER;
	DEFINE cCtaInv              CHAR(20);
	DEFINE cDiaCorte            SMALLINT;
	DEFINE dFecha_cancelacion	DATE;
	DEFINE iEncontrada			SMALLINT;	
	DEFINE iRegistros			INTEGER;
	DEFINE iRecuperacion		INTEGER;
	DEFINE cCodStatusCta        CHAR(2);

	--inicializando variables
	LET  iexiste = 0;
	LET cCodRet = "00000";
	LET cCodRetSp = "00000";
	LET iSql_err = 0 ;
	--SISTEMA DE CUENTA 01 VARIABLES
	LET cIProducto_chequera	 = "";
	LET cScuenta		 = "";
	LET cNo_cuenta		 = "";
	LET cNo_tarjeta			 = "";
	LET cClave_producto		 = "";
	LET cNombre_producto		 = "";
	LET cCuenta_clabe		 = "";
	LET dFecha_apertura		 = "";
	LET cStatus_tarjeta		 = "";
	LET cStatus_cuenta		 = "";
	LET dFecha_status		 = "";
	LET cClave_sucursal		 = "";
	LET cEjecutivo 			 = "";
	LET mSaldo_actual		= 0;
	LET dFecha_aperturaO_inv = "";
	LET dFecha_max			="";
	LET dFecha_min			="";
	LET cNumero_cuenta 	= "" ;
	LET iCont=0;
	LET iMaxSec=0;
	LET cCtaInv='';
	LET cDiaCorte           =0;
	LET dFecha_cancelacion = "";
	LET iEncontrada = 0;	
	LET iRegistros = 0;
	LET iRecuperacion = 1000;	
	LET cCodStatusCta = "";
				
	BEGIN
	
		ON EXCEPTION SET iSql_err
			LET cCodRet = iSql_err;
			RETURN 
				cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
				cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_consctecuenta_mfinis.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pNumCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN 
				cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
				cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion;
		END IF;
		
	
		--VALIDACION
		EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(pIdUsuario,pIdFuncion, pNumCliente, pSistemaCuenta, '2')
		INTO cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN 
			cCodRet,cIProducto_chequera,cScuenta,cNo_cuenta,cNo_tarjeta,cClave_producto,cNombre_producto,cCuenta_clabe,dFecha_apertura,
			cStatus_tarjeta,cStatus_cuenta,dFecha_status,cClave_sucursal,cEjecutivo,mSaldo_actual,dFecha_aperturaO_inv,cDiaCorte,dFecha_cancelacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		WHILE cCodRetSp = '00000'
			FOREACH EXECUTE PROCEDURE bdinteg:sp_cnsif_consprodcte(pIdUsuario, pIdFuncion, pNumCliente, pSistemaCuenta, iRegistros, iRecuperacion)
				INTO cCodRetSp,cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
					cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
					cDiaCorte, dFecha_cancelacion, cCodStatusCta
				
				IF cCodRetSp =  '1001' THEN
					LET cCodRet = '00017';
					LET cCodRetSp = '99999';
					RETURN cCodRet, cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
									cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
									cDiaCorte, dFecha_cancelacion;
					EXIT FOREACH;
				ELIF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
									cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
									cDiaCorte, dFecha_cancelacion;
				END IF;
				
				IF TRIM(cNo_cuenta) = TRIM(pNumCuenta) THEN
					RETURN cCodRet, cIProducto_chequera,cScuenta,cNo_cuenta,cClave_producto,cNombre_producto,dFecha_apertura,cStatus_cuenta,dFecha_status,
									cClave_sucursal,cEjecutivo,mSaldo_actual,cNo_tarjeta,cStatus_tarjeta,cCuenta_clabe,dFecha_aperturaO_inv,
									cDiaCorte, dFecha_cancelacion;
					LET cCodRetSp = '99999';
					EXIT FOREACH;
				END IF
				
			END FOREACH;
			
			LET iRegistros = iRegistros + iRecuperacion;
			
		END WHILE;
	
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde", 
"FECHA: 16/07/2013",
"DESCRIPCION: Procedimiento que busca solo una cuenta de un cliente dado, internamente ejecuta el ss sp_cnsif_consprodcte";

CREATE PROCEDURE "informix".sp_cnsif_consarchivosgenerados(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(45) AS nombre_archivo,
		CHAR(10) AS fecha,
		CHAR(5) AS hora;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE dFecha DATE;
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE dFechaHoy DATE;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cNombreArchivo = '';
	LET dFecha = '';
	LET cFecha = '';
	LET cHora = '';
	LET dFechaHoy = CURRENT;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consarchivosgenerados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT nombre_archivo,fecha,NVL(TO_CHAR(hora,'%H:%M'), '') AS cHoraConv
			INTO cNombreArchivo,dFecha,cHora
			FROM bdicnweb:"informix".sw_cons_archivosgenerados
			WHERE usuario = pUsuario AND sis_cuenta = pSistemaCuenta AND fecha = dFechaHoy
			ORDER BY cHoraConv ASC
			
			LET cFecha = LPAD(DAY(dFecha),2,0)||'/'||LPAD(MONTH(dFecha),2,0)||'/'||YEAR(dFecha);
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombreArchivo,cFecha,cHora WITH RESUME;
		END FOREACH;				
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombreArchivo,cFecha,cHora;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 25/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos generados a partir de la consulta de movimientos (CAPTACION/CREDITO/INVERSIONES).',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se modifica el tratado del campo hora de la tabla bdinteg:sw_cons_archivosgenerados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consarchivosgenerados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE dFecha DATE;
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE dFechaHoy DATE;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cNombreArchivo = '';
	LET dFecha = '';
	LET cFecha = '';
	LET cHora = '';
	LET dFechaHoy = CURRENT;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consarchivosgenerados_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM (SELECT DISTINCT nombre_archivo,fecha,hora
			  FROM bdicnweb:"informix".sw_cons_archivosgenerados
			  WHERE usuario = pUsuario AND sis_cuenta = pSistemaCuenta AND fecha = dFechaHoy
			  ORDER BY hora ASC);						
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNumRegistros;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 25/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el número total de archivos generados a partir de la consulta de movimientos (CAPTACION/CREDITO/INVERSIONES).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_depuramovimientostemp(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
    DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET bInTransaction='f';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00114';
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_depuramovimientostemp.out';
		--TRACE ON;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;	
		
		BEGIN;
		TRUNCATE TABLE bdicnweb:"informix".sw_cons_movimientos;
		COMMIT;
		
		BEGIN;
		TRUNCATE TABLE bdicnweb:"informix".sw_cons_tempo_movimientos;
		COMMIT;
				
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_depuramovimientostempo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 08/01/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÃN/CRÃDITO/INVERSIONES',
'DESCRIPCION: Depura registros de movimientos de tablas temporales sw_cons_movimientos sw_cons_tempo_movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se cambia DELETE por TRUNCATE para realizar la depuraciÃ³n de las tablas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_verificastatusmovimientos(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveMov CHAR(50))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_verificastatusmovimientos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_cons_statusproceso 
		WHERE usuario = pUsuario AND clave_mov = pClaveMov;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES', 
'DESCRIPCION: SPL encargado de verificar el status de la consulta para la recuperación de los registros correspondientes a los movimientos de CAPTACIÓN, CRÉDITO e INVERSIONES.',
'AUTOR: L. Montserrat León Amador',
'FECHA 08/01/2018',
'DESCRIPCION: Se modifica spl para filtrar la consulta por un nuevo parámetro de entrada (clave movimiento), la cual es generada en el proceso principal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizascparam(pUsuario CHAR(8), pIdFuncion CHAR(10),  pCodParam CHAR(100), pValor CHAR(100))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/vamilan/sp_ope_actualizascparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodParam = '' OR pValor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			
		UPDATE bdicheq:"informix".sc_param SET valor = TRIM(pValor) WHERE codparam = TRIM(pCodParam);

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/01/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: LÍMITE DE DEPÓSITOS INTERESTADOS',
'DESCRIPCION: Spl encargado de actualizar el campo valor en la tabla bdicheq:sc_param cuando codparam sea igual a LimDepositoInterEdo.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_insertconssucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),
pSucursal CHAR(4), pMonto MONEY(18,2), pNumTransacciones INT, pPlazo INT)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS sucursal,
		MONEY(18,2) AS monto,
		INT AS num_transacciones,
		INT AS plazo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE mMonto MONEY(18,2);
	DEFINE iNumTransacciones INT;
	DEFINE iPlazo INT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET mMonto = 0.00;
	LET iNumTransacciones = 0;
	LET iPlazo = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
			END IF;
		END EXCEPTION;
		
	--	SET DEBUG FILE TO '/informix/vamilan/sp_ope_insertconssucursal.out';
	--	TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
		END IF;
		
		IF pTipoOperacion IN ('1','2') THEN 
			IF pMonto IS NULL OR pNumTransacciones IS NULL OR pPlazo IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--Inserta
		IF pTipoOperacion = '1' THEN 
			
			INSERT INTO bdicheq:"informix".sc_limitedeposito(sucursal,monto,num_transaccion,plazo,fecha_alta,usuario) 
			VALUES(pSucursal,pMonto,pNumTransacciones,pPlazo,DATE(CURRENT),pUsuario);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;	
		
		--Actualiza
		ELIF pTipoOperacion = '2' THEN
			
			UPDATE bdicheq:"informix".sc_limitedeposito 
			SET monto = pMonto, num_transaccion = pNumTransacciones, plazo = pPlazo 
			WHERE sucursal = pSucursal;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			END IF;
		
		--Consulta
		ELIF pTipoOperacion = '3' THEN
		
			SELECT sucursal, monto, num_transaccion, plazo 
			INTO cSucursal, mMonto, iNumTransacciones, iPlazo
			FROM bdicheq:"informix".sc_limitedeposito 
			WHERE sucursal = pSucursal;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
			END IF;	
		
		END IF;
		
		RETURN cCodRet, cSucursal, mMonto, iNumTransacciones, iPlazo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/01/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: LÍMITE DE DEPÓSITOS INTERESTADOS',
'DESCRIPCION: Spl encargado de insertar, actualizar y consultar el detalle del límite de depósito de la sucursal consultada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validasucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/vamilan/sp_ope_validasucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT sucursal 
		INTO cSucursal 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '01031'; --LA SUCURSAL NO EXISTE EN EL CATÁLOGO GENERAL DE SUCURSALES, VERIFIQUE
		ELSE 
			LET cCodRet = '00000';
		END IF;	
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 03/01/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: LÍMITE DE DEPÓSITOS INTERESTADOS',
'DESCRIPCION: Spl encargado de validar si la sucursal existe.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_actualizascparam(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodParam CHAR(100), pValor CHAR(100))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_actualizascparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodParam = '' OR pValor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			
		UPDATE bdicheq:"informix".sc_param SET valor = TRIM(pValor) WHERE codparam = TRIM(pCodParam);

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de actualizar el campo valor en la tabla bdicheq:sc_param.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_catestatusexencioncte(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		INT AS id_exencion,
		CHAR(35) AS desc_exencion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdExencion INT;
	DEFINE cDescExencion CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdExencion = 0;
	LET cDescExencion = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdExencion, cDescExencion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_catestatusexencioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdExencion, cDescExencion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdExencion, cDescExencion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_exencion, desc_exencion
			INTO iIdExencion, cDescExencion
			FROM bdicheq:"informix".sc_exencioncte
			ORDER BY desc_exencion DESC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdExencion, UPPER(TRIM(cDescExencion)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdExencion, cDescExencion;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: EXENCIÓN DEL LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo estatus de la exención del cliente recuperado de la tabla bdicheq:sc_exencioncte.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_catperiodicidad(pUsuario CHAR(8), pIdFuncion CHAR(10))
    RETURNING CHAR(5) AS codRet,
		INT AS id_periodicidad,
		CHAR(35) AS desc_periodicidad;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdPeriodicidad INT;
	DEFINE cDescPeriodicidad CHAR(35);
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdPeriodicidad = 0;
	LET cDescPeriodicidad = '';
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_catperiodicidad.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_periodicidad, desc_periodicidad 
			INTO iIdPeriodicidad, cDescPeriodicidad
			FROM bdicheq:"informix".sc_periodicidad
			ORDER BY desc_periodicidad ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iIdPeriodicidad, UPPER(TRIM(cDescPeriodicidad)) WITH RESUME;		
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdPeriodicidad, cDescPeriodicidad;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo periodicidad recuperado de la tabla bdicheq:sc_periodicidad.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_insertconsexencioncte(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1), pCliente CHAR(20), pStatus INT)
    RETURNING CHAR(5) AS codRet,
		INT AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iStatus INT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iStatus = NULL;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iStatus;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_insertconsexencioncte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iStatus;
		END IF;
		
		IF pTipoOperacion IN ('1','2') THEN 
			IF pStatus IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iStatus;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--Inserta
		IF pTipoOperacion = '1' THEN 
			
			INSERT INTO bdicheq:"informix".sc_retirocliente_exento(cliente,status,usuario,fecha_alta) 
			VALUES(pCliente,pStatus,pUsuario,DATE(CURRENT));

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;	
		
		--Actualiza
		ELIF pTipoOperacion = '2' THEN
			
			UPDATE bdicheq:"informix".sc_retirocliente_exento 
			SET status = pStatus, usuario = pUsuario, fecha_alta = DATE(CURRENT) 
			WHERE cliente = pCliente;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			END IF;
		
		--Consulta
		ELIF pTipoOperacion = '3' THEN
		
			SELECT status
			INTO iStatus
			FROM bdicheq:"informix".sc_retirocliente_exento 
			WHERE cliente = pCliente;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00050'; --EL NUMERO DE CLIENTE NO EXISTE
			END IF;	
		
		END IF;
		
		RETURN cCodRet, iStatus;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: EXENCIÓN DEL LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de insertar, actualizar y consultar la exención del cliente consultado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_insertconssucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),
pSucursal CHAR(4), pMonto MONEY(18,2), pPeriodicidad INT, pPlazo INT)
    RETURNING CHAR(5) AS codRet,
		CHAR(4) AS sucursal,
		MONEY(18,2) AS monto,
		INT AS periodicidad,
		INT AS plazo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE mMonto MONEY(18,2);
	DEFINE iPeriodicidad INT;
	DEFINE iPlazo INT;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET mMonto = 0.00;
	LET iPeriodicidad = 0;
	LET iPlazo = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_insertconssucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
		END IF;
		
		IF pTipoOperacion IN ('1','2') THEN 
			IF pMonto IS NULL OR pPeriodicidad IS NULL OR pPlazo IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
			END IF;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--Inserta
		IF pTipoOperacion = '1' THEN 
			
			INSERT INTO bdicheq:"informix".sc_limiteretiro(sucursal,monto,periodicidad,plazo,fecha_alta,usuario) 
			VALUES(pSucursal,pMonto,pPeriodicidad,pPlazo,DATE(CURRENT),pUsuario);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF;	
		
		--Actualiza
		ELIF pTipoOperacion = '2' THEN
			
			UPDATE bdicheq:"informix".sc_limiteretiro 
			SET monto = pMonto, periodicidad = pPeriodicidad, plazo = pPlazo 
			WHERE sucursal = pSucursal;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00283'; --ERROR AL ACTUALIZAR EL REGISTRO
			END IF;
		
		--Consulta
		ELIF pTipoOperacion = '3' THEN
		
			SELECT sucursal, monto, periodicidad, plazo 
			INTO cSucursal, mMonto, iPeriodicidad, iPlazo
			FROM bdicheq:"informix".sc_limiteretiro 
			WHERE sucursal = pSucursal;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
			END IF;	
		
		END IF;
		
		RETURN cCodRet, cSucursal, mMonto, iPeriodicidad, iPlazo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de insertar, actualizar y consultar el detalle del límite de retiro de la sucursal consultada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_validasucursal(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_validasucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		SELECT sucursal 
		INTO cSucursal 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '01031'; --LA SUCURSAL NO EXISTE EN EL CATÁLOGO GENERAL DE SUCURSALES, VERIFIQUE
		ELSE 
			LET cCodRet = '00000';
		END IF;	
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/01/2017',
'MODULO: DÉBITO',
'FUNCIONALIDAD: LÍMITE DE RETIROS EN EFECTIVO',
'DESCRIPCION: Spl encargado de validar si la sucursal existe.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_verificastatusremconsgralremesascte(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			--LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_verificastatusremconsgralremesascte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_cons_statusprocesorem 
		WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Uriel Caamaño Mejia',
'FECHA 21/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA GENERAL REMESAS POR CLIENTE', 
'DESCRIPCION: SPL encargado de verificar el status de la consulta para la recuperación de los registros correspondientes a la CONSULTA REMESAS POR CLIENTE',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consgralremesascte_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pFechaIni DATE, pFechaFin DATE)
				RETURNING CHAR(5) AS codRet,
                INTEGER AS num_registros;               
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cDescCodRet CHAR(80);
        DEFINE cEmpresa CHAR(3);
        
        DEFINE cNumConvenio CHAR(3);
        DEFINE cNomConvenio CHAR(40);
        DEFINE iPagadasBts INTEGER;
        DEFINE iPagadasWu INTEGER;
        DEFINE iPagadasOv INTEGER;
        DEFINE iPagadasVg INTEGER;
        DEFINE iPagadasApp INTEGER;
        DEFINE mMontoPagBts CHAR(20);
        DEFINE mMontoPagWu CHAR(20);
        DEFINE mMontoPagOv CHAR(20);
        DEFINE mMontoPagVg CHAR(20);
        DEFINE mMontoPagApp CHAR(20);
        DEFINE cStatusCte CHAR(10);
        DEFINE dFechaStatus CHAR(25);
        DEFINE dFechaUltBts CHAR(25);
        DEFINE dFechaUltWu CHAR(25);
        DEFINE dFechaUltOv CHAR(25);
        DEFINE dFechaUltVg CHAR(25);
        DEFINE dFechaUltApp CHAR(25);
        
        DEFINE cNom_convenio CHAR(40);
        DEFINE iTotal_pagadas INTEGER;
        DEFINE cMonto_pagado CHAR(20);
        DEFINE cFecha_ult CHAR(25);
        DEFINE iRecuperacion INTEGER;
        DEFINE iNumRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cDescCodRet = '';
        LET cEmpresa = '001';
        
        LET cNumConvenio = '';
        LET cNomConvenio = '';
        LET iPagadasBts = 0;
        LET iPagadasWu = 0;
        LET iPagadasOv = 0;
        LET iPagadasVg = 0;
        LET iPagadasApp = 0;
        LET mMontoPagBts = '';
        LET mMontoPagWu = '';
        LET mMontoPagOv = '';
        LET mMontoPagVg = '';
        LET mMontoPagApp = '';
        LET cStatusCte = '';
        LET dFechaStatus = '';
        LET dFechaUltBts = '';
        LET dFechaUltWu = '';
        LET dFechaUltOv = '';
        LET dFechaUltVg = '';
        LET dFechaUltApp = '';
        
        LET cNom_convenio = '';
        LET iTotal_pagadas = 0;
        LET cMonto_pagado = '';
        LET cFecha_ult = '';
        LET iRecuperacion = 0;
        LET iNumRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr; 								
								UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
								SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
								RETURN cCodRet, iNumRegistros;						
                        END IF;					
						
                END EXCEPTION;
				
				ON EXCEPTION IN (-958)
				END EXCEPTION WITH RESUME;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consgralremesascte_totales.out';
                --TRACE ON;
                
				DELETE FROM bdicnweb:"informix".sw_cons_statusprocesorem WHERE usuario = pUsuario;
				
				-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3; 
				
				INSERT INTO bdicnweb:"informix".sw_cons_statusprocesorem(usuario,status,num_registros,error_proceso,error)
				VALUES(pUsuario,'I',0,'',cCodRet);  
				
                IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pFechaIni IS NULL OR pFechaFin IS NULL THEN
                        LET cCodRet = '00003';						
						UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
                        RETURN cCodRet,iNumRegistros;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN                        
						UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
						SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario = pUsuario;
						RETURN cCodRet, iNumRegistros;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 6;
                
                -- LIMPIA TABLAS
                DELETE FROM bdicnweb:"informix".sac_general_rem WHERE usuario_insert = pUsuario; 
                                
                --Compañía
                INSERT INTO bdicnweb:"informix".sac_general_rem (numconvenio,nomconvenio,total_pagadas,monto_pagado,
                fecha_ult,numcte,usuario_insert)
                SELECT numconvenio,nomconvenio,0,'','',pNumCliente,pUsuario
                FROM bdisac:"informix".sac_convenios
                WHERE numconvenio IN ('004','006','007','008','009') AND numcategoria = '07'
                ORDER BY numconvenio ASC;

                --No.Remesas Pagadas
                SELECT COUNT(*) INTO iPagadasBts 
                FROM bdisac:"informix".sac_bts_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND opcode = '1100'
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasWu 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) NOT IN ('708','972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasOv 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('708')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasVg 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT COUNT(*) INTO iPagadasApp 
                FROM bdisac:"informix".sac_app_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND r_code = '0000' AND r_code_d = 'P000'
                AND DATE(fecha) BETWEEN pFechaIni AND pFechaFin;
                
                --Monto Pagado
                SELECT SUM(qr.destination_am::MONEY(18,2)) AS monto_pag INTO mMontoPagBts 
                FROM bdisac:"informix".sac_bts_payi AS pa, bdisac:"informix".sac_bts_qryi AS qr
                WHERE pa.numcte = TRIM(pNumCliente) AND pa.txn_status = 'A' AND pa.opcode = '1100'
                AND DATE(pa.fecha_insert) BETWEEN pFechaIni AND pFechaFin
                AND pa.confirmation_nm = qr.confirmation_nm
                AND qr.txn_status = 'A' AND qr.opcode = '1000'
                AND qr.fecha_insert IN (SELECT MAX(fecha_insert)
                                                                FROM bdisac:"informix".sac_bts_qryi
                                                                WHERE pa.confirmation_nm = confirmation_nm
                                                                AND txn_status = 'A' AND opcode = '1000');

                SELECT SUM(monto_destino::MONEY(18,2)) AS monto_pag INTO mMontoPagWu 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) NOT IN ('708','972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;

                SELECT SUM(monto_destino::MONEY(18,2)) AS monto_pag INTO mMontoPagOv 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('708')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;

                SELECT SUM(monto_destino::MONEY(18,2)) AS monto_pag INTO mMontoPagVg 
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT SUM(r_destinamount::MONEY(18,2)) AS monto_pag  INTO mMontoPagApp 
                FROM bdisac:"informix".sac_app_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND r_code = '0000' AND r_code_d = 'P000'
                AND DATE(fecha) BETWEEN pFechaIni AND pFechaFin;
                
                --Fecha Última Remesa Pagada
                SELECT MAX(process_dt) INTO dFechaUltBts
                FROM bdisac:"informix".sac_bts_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND opcode = '1100'
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT MAX(fecha_hora_rp) INTO dFechaUltWu
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) NOT IN ('708','972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT MAX(fecha_hora_rp) INTO dFechaUltOv
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('708')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;

                SELECT MAX(fecha_hora_rp) INTO dFechaUltVg
                FROM bdisac:"informix".sac_wu_pay 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND conf_pago = 'P' AND retcode = '00000' AND SUBSTR(mtcn,1,3) IN ('972','973')
                AND DATE(fecha_insert) BETWEEN pFechaIni AND pFechaFin;
                
                SELECT MAX(r_processdate) INTO dFechaUltApp
                FROM bdisac:"informix".sac_app_payi 
                WHERE numcte = TRIM(pNumCliente) AND txn_status = 'A' AND r_code = '0000' AND r_code_d = 'P000'
                AND DATE(fecha) BETWEEN pFechaIni AND pFechaFin;
                                
                --ACTUALIZA TABLA PRINCIPAL
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasBts, monto_pagado = mMontoPagBts, fecha_ult = dFechaUltBts
                WHERE numconvenio = '004' AND numcte = pNumCliente AND usuario_insert = pUsuario;
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasWu, monto_pagado = mMontoPagWu, fecha_ult = dFechaUltWu
                WHERE numconvenio = '006' AND numcte = pNumCliente AND usuario_insert = pUsuario;               
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasOv, monto_pagado = mMontoPagOv, fecha_ult = dFechaUltOv
                WHERE numconvenio = '007' AND numcte = pNumCliente AND usuario_insert = pUsuario;
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasVg, monto_pagado = mMontoPagVg, fecha_ult = dFechaUltVg
                WHERE numconvenio = '008' AND numcte = pNumCliente AND usuario_insert = pUsuario;
                
                UPDATE bdicnweb:"informix".sac_general_rem 
                SET total_pagadas = iPagadasApp, monto_pagado = mMontoPagApp, fecha_ult = dFechaUltApp
                WHERE numconvenio = '009' AND numcte = pNumCliente AND usuario_insert = pUsuario;
								
                SELECT COUNT(*)
                INTO iNumRegistros
                FROM bdicnweb:"informix".sac_general_rem
                WHERE numcte = TRIM(pNumCliente) AND usuario_insert = pUsuario;							
				
				IF NVL(iNumRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
					SET status = 'E', error_proceso = 'S', num_registros = iNumRegistros, error = TRIM(cCodRet) WHERE usuario = pUsuario;
					RETURN cCodRet, iNumRegistros;						
                END IF;
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_cons_statusprocesorem
				SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = pUsuario;
				
				RETURN cCodRet, iNumRegistros;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 16/06/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CONSULTA GENERAL DE REMESAS POR CLIENTE',
'DESCRIPCION: SPL encargado de consultar el número total de remesas por cliente.',
'BD: bdicnweb',
'AUTOR: L. Uriel Caamaño Mejia',
'FECHA 21/12/2017',
'DESCRIPCION: Preparacion para el hilo.';

CREATE PROCEDURE "informix".sp_rem_consparametrostransaccionapp(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumRem CHAR(12), pFecha DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(16) AS folio_suc,
		CHAR(4) AS id_sucursal,
		CHAR(40) AS desc_sucursal;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	
	DEFINE cFolio_suc				CHAR(16);
	DEFINE cId_sucursal				CHAR(4);
	DEFINE cDesc_sucursal 			CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cFecha = '';
	LET dHora = '';
	
	LET cFolio_suc					= '';
	LET cId_sucursal				= '';
	LET cDesc_sucursal 				= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consparametrostransaccionapp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNumRem = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
		
			IF pFecha = (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
			
				SELECT folio_suc, id_sucursal
				INTO cFolio_suc, cId_sucursal
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = '07'
				AND numconvenio = '009'
				AND referencia1 = pNumRem
				AND	flag_confirmacion_central = '1'
				AND	fecha_insert IN (SELECT MAX(fecha_insert) 
										   FROM bdisac:"informix".sac_movimientos 
										   WHERE numcategoria = '07'
										   AND numconvenio = '009'
										   AND referencia1 = pNumRem
										   AND flag_confirmacion_central = '1'); 
			
			ELIF pFecha < (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
			
				SELECT folio_suc, id_sucursal
				INTO cFolio_suc, cId_sucursal
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = '07'
				AND numconvenio = '009'
				AND referencia1 = pNumRem
				AND	flag_confirmacion_central = '1'
				AND	ROWID IN (SELECT MAX(ROWID) 
										   FROM bdisac:"informix".sac_movimientoshistorial 
										   WHERE numcategoria = '07'
										   AND numconvenio = '009'
										   AND referencia1 = pNumRem
										   AND flag_confirmacion_central = '1'); 
										   
				IF NVL(cFolio_suc,'') = '' THEN
						
					SELECT folio_suc, id_sucursal
					INTO cFolio_suc, cId_sucursal
					--FROM bdisac:"c92357113".sac_movimientoshistorial_old
					FROM bdisac:sac_movimientoshistorial_old
					WHERE numcategoria = '07'
					AND numconvenio = '009'
					AND referencia1 = pNumRem
					AND	flag_confirmacion_central = '1'
					AND	ROWID IN (SELECT MAX(ROWID) 
											   --FROM bdisac:"c92357113".sac_movimientoshistorial_old 
											   FROM bdisac:sac_movimientoshistorial_old 
											   WHERE numcategoria = '07'
											   AND numconvenio = '009'
											   AND referencia1 = pNumRem
											   AND flag_confirmacion_central = '1');
						
				END IF;
			
			ELIF pFecha > (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
				LET cCodRet = '00975'; --LA FECHA DE PAGO ES INVÁLIDA
				RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
			END IF;
				
			IF NVL(cFolio_suc,'') = '' THEN
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR 
				RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
			END IF; 
			
			IF NVL(cId_sucursal,'') <> '' THEN
				SELECT nombre 
				INTO cDesc_sucursal
				FROM bdinteg:"informix".si_sucursales 
				WHERE sucursal = cId_sucursal;
			END IF;
			
		END IF;
		
		RETURN cCodRet, cFolio_suc, cId_sucursal, cDesc_sucursal;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 12/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS APPRIZA',
'DESCRIPCION: SPL encargado de consultar el valor de diferentes parámetros, dependiendo del id de consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consparametrostransaccionbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11))
    RETURNING CHAR(5) AS codRet,
		CHAR(64) AS trama,
		CHAR(100) AS id_transaccion,
		CHAR(80) AS nombre_usuario,
		DATE AS fecha_sistema,
		CHAR(4) AS sucursal,
		CHAR(8) AS hora;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	
	DEFINE cNombreUsuario CHAR(80);
	DEFINE dFechaSistema DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cTerminal CHAR(15);
	DEFINE cFormatFechaSistema CHAR(8);
	DEFINE cHora CHAR(8);
	DEFINE cFormatHora CHAR(6);
	DEFINE cTramaBts CHAR(64);
	DEFINE cIdTransaccionBts CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cFecha = '';
	LET dHora = '';
	
	LET cNombreUsuario = '';
	LET dFechaSistema = '';
	LET cSucursal = '';
	LET cTerminal = '';
	LET cFormatFechaSistema = '';
	LET cHora = '';
	LET cFormatHora = '';
	LET cTramaBts = '';
	LET cIdTransaccionBts = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cTramaBts, cIdTransaccionBts, cNombreUsuario, dFechaSistema, cSucursal, cHora;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consparametrostransaccionbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTramaBts, cIdTransaccionBts, cNombreUsuario, dFechaSistema, cSucursal, cHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTramaBts, cIdTransaccionBts, cNombreUsuario, dFechaSistema, cSucursal, cHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consinfobtssif(pUsuario)
		INTO cCodRetSp,cNombreUsuario,dFechaSistema,cSucursal;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_consinfobtssif';
		END IF;

		SELECT TO_CHAR(CURRENT::DATETIME HOUR TO MINUTE, '%I:%M:%S'), TO_CHAR(CURRENT::DATETIME HOUR TO MINUTE, '%I%M%S')
		INTO cHora, cFormatHora
		FROM bdinteg:"informix".si_fechas;
		
		LET cTerminal = TRIM(cSucursal)||TRIM(pUsuario);
		LET cFormatFechaSistema = SUBSTR(dFechaSistema,7,4) || SUBSTR(dFechaSistema,1,2) || SUBSTR(dFechaSistema,4,2);
		LET cTramaBts = TRIM(cSucursal)||TRIM(pNumBts)||RPAD(TRIM(UPPER(SUBSTR(cNombreUsuario,1,20))),20,' ')||RPAD(TRIM(cTerminal),15,' ')||TRIM(cFormatFechaSistema)||TRIM(cFormatHora);
		
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneparametro(407004)
		INTO cCodRetSp,cIdTransaccionBts;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_obtieneparametro';
		ELIF cCodRetSp::INTEGER = 504 THEN
			LET cCodRet = '00954'; --POR EL MOMENTO EL SERVICIO DE BTS NO ESTA OPERANDO, INTÉNTELO MÁS TARDE
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF NVL(cIdTransaccionBts,'') = '' THEN
				LET cCodRet = '00955'; --NO SE PUDO OBTENER PARÁMETRO DE TRANSACCIÓN
			END IF;
		END IF;
		
		RETURN cCodRet, TRIM(cTramaBts), TRIM(cIdTransaccionBts), TRIM(UPPER(cNombreUsuario)), dFechaSistema, TRIM(cSucursal), TRIM(cHora);
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 19/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de consultar la trama y el id de la transacción de InterACT.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consremcambiobts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11), pTransStatusDt DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(15) AS cSucursal, 
		CHAR(15) AS cTerminal, 
		CHAR(3) AS cR_Type_Cd, 
		CHAR(20) AS cR_Identif_Nm, 
		CHAR(50) AS cR_Nom_Calle, 
		CHAR(5) AS cR_Num_Ext, 
		CHAR(5) AS cR_Num_Int, 
		CHAR(10) AS cR_Depto, 
		CHAR(80) AS cR_Colonia,
		CHAR(5) AS cR_Cp, 
		CHAR(50) AS cR_Mncpo_Deleg, 
		CHAR(50) AS cR_Ciudad, 
		CHAR(50) AS cR_Estado, 
		CHAR(3) AS cR_Issuer_Country_Cd, 
		CHAR(15) AS cR_Telefono, 
		CHAR(1) AS cTipo_Pago,
		CHAR(8) AS cR_Fecha_Nac,
		CHAR(50) AS cR_Nacionalidad, 
		CHAR(20) AS cR_pais_nac,
		CHAR(20) AS cFolio_SucPayi;
	
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INT;
	DEFINE cCodRetSp 			CHAR(6);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cDescCodRet 			CHAR(80);
	DEFINE cEmpresa 			CHAR(3);
	
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_pais_nac			CHAR(20);
	DEFINE cFolio_SucPayi       CHAR(20);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cDescCodRet 			= '';
	LET cEmpresa 				= '001';
	
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_pais_nac			    = '';
	LET cFolio_SucPayi          = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
				cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
				cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consremcambiobts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' OR pTransStatusDt IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
			cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
			cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
			cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
			cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consremcambiost(pNumBts,pTransStatusDt)
		INTO cCodRetSp, cSucursal, cTerminal, cR_Type_Cd, cR_Identif_Nm, cR_Nom_Calle, cR_Num_Ext, cR_Num_Int, 
		cR_Depto, cR_Colonia, cR_Cp, cR_Mncpo_Deleg, cR_Ciudad, cR_Estado, cR_Issuer_Country_Cd, cR_Telefono, 
		cTipo_Pago, cR_Fecha_Nac, cR_Nacionalidad, cR_pais_nac, cFolio_SucPayi;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_consremcambiost';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '00971'; --FECHA REAL DEL PAGO INVALIDA, VERIFIQUE  
		ELIF cCodRetSp::INTEGER = 3 THEN
			LET cCodRet = '00964'; --NO HAY DATOS ADICIONALES DEL BENEFICIARIO  
		ELIF cCodRetSp::INTEGER = 4 THEN
			LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR     
		ELIF cCodRetSp::INTEGER = 5 THEN
			LET cCodRet = '00968'; --NO PUEDE ENVIAR MENSAJE, SUPERA EL MÁXIMO DE SOLICITUDES
		ELIF cCodRetSp::INTEGER = 6 THEN
			LET cCodRet = '00966'; --REMESA PAGADA DESDE SIF, NO PUEDE REVERSARSE
		END IF;
		
		RETURN cCodRet, cSucursal, cTerminal, UPPER(cR_Type_Cd), cR_Identif_Nm, UPPER(cR_Nom_Calle), cR_Num_Ext, cR_Num_Int, 
		cR_Depto, UPPER(cR_Colonia), cR_Cp, UPPER(cR_Mncpo_Deleg), UPPER(cR_Ciudad), UPPER(cR_Estado), cR_Issuer_Country_Cd, cR_Telefono, 
		UPPER(cTipo_Pago), cR_Fecha_Nac, UPPER(cR_Nacionalidad), UPPER(cR_pais_nac), cFolio_SucPayi;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 21/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de obtener informacion del registro de una remesa pagada cuando se consulta desde plataforma.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consultapaises(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER  AS num_pais,       
		CHAR(3)  AS cod_pais,       
		CHAR(50) AS pais,    
		CHAR(1)  AS flag_banco;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	DEFINE cNumPais  	INTEGER;
	DEFINE cCodPais  	CHAR(3);
	DEFINE cPais     	CHAR(50);
	DEFINE cFlagBanco	CHAR(1);
	DEFINE iNoRegistros INTEGER;
    
	LET cCodRet     = '00000';
	LET iSqlErr     = 0;
	
	LET cNumPais 	= 0; 	
	LET cCodPais  	='';
	LET cPais     	='';
    LET cFlagBanco	='';
	LET iNoRegistros = 0;
    
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultapaises.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END IF;
		 
		 -- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN 	cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
		END IF;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion num_pais,cod_pais,pais,flag_banco  
				INTO cNumPais,cCodPais,cPais,cFlagBanco
				FROM bdisac:sac_app_paises
					
			LET iNoRegistros = iNoRegistros +1;
			RETURN cCodRet,cNumPais,cCodPais,cPais,cFlagBanco  WITH RESUME;
		END FOREACH
		
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
                        
		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00017';
			ELIF pRegistros > 0 THEN
				LET cCodRet = '1001';
			END IF;
		
			RETURN 	cCodRet,cNumPais,cCodPais,cPais,cFlagBanco;
	    
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 16/05/2016',
'MODULO: REMESAS',
'FUNCIONALIDAD: Cambio de Estatus Appriza',
'DESCRIPCION: SP que consulta el catalogo de Paises',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consultaparametros(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pOpCode CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(255) AS valor;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSubTransaccion CHAR(5);
	DEFINE cOpCode CHAR(50);
	DEFINE cStatecode CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cSubTransaccion = '';
	LET cOpCode = '';
	LET cStatecode = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,'';
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultaparametros.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,'';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,'';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--cSubTransaccion
		IF pIdConsulta = '1' THEN
		
			SELECT trans_servicio 
			INTO cSubTransaccion
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '1';
		
			RETURN cCodRet,NVL(cSubTransaccion,'');
			
		--cOpCode
		ELIF pIdConsulta = '2' THEN
		
			IF pOpCode = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,'';
			END IF;
		
			SELECT opcode_sd
			INTO cOpCode
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE opcode = pOpCode 
			AND agent_trans_type_code = 'QRYI';
		
			RETURN cCodRet,NVL(cOpCode,'');
			
		--cStatecode
		ELIF pIdConsulta = '3' THEN
		
			SELECT c.state_cd
			INTO cStatecode
			FROM bdisac:"informix".sac_param AS a,
			bdinteg:"informix".si_sucursales AS b,
			bdisac:"informix".sac_app_catestados AS c
			WHERE a.cod_param = '87112'
			AND b.sucursal = a.valor
			AND c.cve_estado = b.estado;

			RETURN cCodRet,NVL(cStatecode,'');
		
		--cSubTransaccion APPRIZA
		ELIF pIdConsulta = '4' THEN
		
			SELECT trans_servicio 
			INTO cSubTransaccion
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '3';
		
			RETURN cCodRet,NVL(cSubTransaccion,'');
		
		--cSubTransaccion APPRIZA (Pago)
		ELIF pIdConsulta = '5' THEN
		
			SELECT trans_servicio 
			INTO cSubTransaccion
			FROM bdisac:"informix".sac_intrfz_serv
			WHERE numcategoria = '07'
			AND numconvenio = '009'
			AND num_trama = '2';
		
			RETURN cCodRet,NVL(cSubTransaccion,'');
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 05/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CONSULTA DE REMESAS APPRIZA',
'DESCRIPCION: SPL encargado de consultar el valor de los parámetros.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_estadosac(pUsuario CHAR(8), pIdFuncion CHAR(10),pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(3)     AS cod_pais,       
		CHAR(2)  	AS cve_estado,       
		CHAR(40) 	AS nombre_estado,    
		CHAR(3)  	AS state_cd;
	
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cCodPais		 CHAR(3);     
	DEFINE cCveEstado    CHAR(2);
	DEFINE cNombreEstado CHAR(40);
	DEFINE cStateCd      CHAR(3);
	
	
	LET cCodRet     = '00000';
	LET iSqlErr     = 0;
	LET iNoRegistros = 0;
    
	LET cCodPais	 ='';	 
	LET cCveEstado   =''; 
	LET cNombreEstado=''; 
	LET cStateCd     =''; 
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_estadosac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		END IF;
		 
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		END IF;
		
		SELECT edo.cod_pais, edo.cve_estado,edo.nombre_estado,edo.state_cd 
		INTO cCodPais,cCveEstado,cNombreEstado,cStateCd
		FROM bdinteg:si_sucursales suc
		INNER JOIN bdisac:sac_app_catestados  edo ON suc.estado=edo.cve_estado
		WHERE sucursal=pSucursal;
					
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
			
		RETURN cCodRet,cCodPais,cCveEstado,cNombreEstado,cStateCd;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 18/05/2016',
'MODULO: REMESAS',
'FUNCIONALIDAD: Cambio de Estatus Appriza',
'DESCRIPCION: SP que consulta el catalogo de estados de sac',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_guardarespuestapayibts(pUsuario CHAR(8), 
														pIdFuncion CHAR(10),
														pSucursal CHAR (4), 
														pTxn_Status CHAR(1), 
														pConfirmation_nm CHAR (11), 
														pBank_Ref_Num CHAR(20), 
														pUser_name CHAR(20), 
														pTerminal CHAR(15), 
														pAgent_Dt CHAR(8), 
														pAgent_Tm CHAR(6), 
														pR_First_Name CHAR(40), 
														pR_Middle_Name CHAR(40), 
														pR_Last_Name CHAR(40), 
														pR_Mother_M_Name CHAR(40),
														pR_Type_Cd CHAR(3), 
														pR_Issuer_Cd CHAR(3), 
														pR_Issuer_State_Cd CHAR(3), 
														pR_Issuer_Country_Cd CHAR(3), 
														pR_Identif_Type CHAR(5),
														pR_Identif_Nm CHAR(20), 
														pR_Expiration_Dt CHAR(8),
														pR_Fecha_Nac CHAR(8),
														pR_Nacionalidad CHAR(50),
														pR_pais_nac CHAR(20),	
														pR_Nom_Calle CHAR(50),
														pR_Num_Ext CHAR(5),
														pR_Num_Int CHAR(5),
														pR_Depto CHAR(10),
														pR_Colonia CHAR(80),
														pR_Cp CHAR(5),
														pR_Mncpo_Delg CHAR(50),
														pR_Ciudad CHAR(50),
														pR_Estado CHAR(50),
														pR_Telefono CHAR(15),
														pTipo_Pago CHAR(1),
														pOpCode CHAR(4), 
														pProcess_Msg CHAR(255), 	
														pError_Param_Full_Name CHAR(255), 
														pTrans_Status_Cd CHAR(3), 
														pTrans_Status_Dt CHAR(8),
														pProcess_Dt CHAR(8), 
														pProcess_Tm CHAR(6))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_guardarespuestapayibts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pTxn_Status = '' OR pConfirmation_nm = '' OR 
		pBank_Ref_Num = '' OR pUser_name = '' OR pTerminal = '' OR pAgent_Dt = '' OR pAgent_Tm = '' OR 
		pR_First_Name = '' OR pR_Last_Name = '' OR pR_Type_Cd = '' OR pR_Issuer_Cd = '' OR pR_Issuer_State_Cd = '' OR 
		pR_Issuer_Country_Cd = '' OR pR_Identif_Nm = '' OR pR_Expiration_Dt = '' OR pR_pais_nac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdisac:"informix".sp_guardarespuestapayi(pSucursal,pTxn_Status,pConfirmation_nm, 
		pBank_Ref_Num,pUser_name,pTerminal,pAgent_Dt,pAgent_Tm,pR_First_Name,pR_Middle_Name, 
		pR_Last_Name,pR_Mother_M_Name,pR_Type_Cd,pR_Issuer_Cd,pR_Issuer_State_Cd,pR_Issuer_Country_Cd, 
		pR_Identif_Type,pR_Identif_Nm,pR_Expiration_Dt,pR_Fecha_Nac,pR_Nacionalidad,pR_pais_nac,	
		pR_Nom_Calle,pR_Num_Ext,pR_Num_Int,pR_Depto,pR_Colonia,pR_Cp,pR_Mncpo_Delg,pR_Ciudad,
		pR_Estado,pR_Telefono,pTipo_Pago,pOpCode,pProcess_Msg,pError_Param_Full_Name, 
	    pTrans_Status_Cd,pTrans_Status_Dt,pProcess_Dt,pProcess_Tm,pUsuario) 
		INTO cCodRetSp;		
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_guardarespuestapayi';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER > 1 THEN
			LET cCodRet = '00970'; --ERROR AL GUARDAR CONSULTA DE INTERACT, VERIFIQUE
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 25/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de guardar los datos de envío y recepción del mensaje PAYI de BTS.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_guardarespuestarevibts(pUsuario CHAR(8), 
														pIdFuncion CHAR(10),
														pSucursal CHAR (4), 
														pTxn_Status CHAR(1), 
														pConfirmation_nm CHAR (11), 
														pProcess_Reason_Cd CHAR(3), 
														pBank_Ref_Num CHAR(20), 
														pRev_Bank_Ref_Nm CHAR(20), 
														pUser_name CHAR(20), 
														pSup_User_Name CHAR(20), 
														pTerminal CHAR(15), 
														pAgent_Dt CHAR(8), 
														pAgent_Tm CHAR(6), 
														pOpCode CHAR(4), 
														pProcess_Msg CHAR(255), 
														pError_Param_Full_Name CHAR(255), 
														pTrans_Status_Cd CHAR(3), 
														pTrans_Status_Dt CHAR(8),
														pProcess_Dt CHAR(8), 
														pProcess_Tm CHAR(6), 
														pService_Cd CHAR(3), 
														pPaymet_Type_Cd CHAR(3), 
														pOrig_Country_Cd CHAR(3), 
														pOrig_Currency_Cd CHAR(3), 
														pDest_Country_Cd CHAR(3), 
														pDest_Currency_Cd CHAR(3), 
														pOrig_Am CHAR(20), 
														pDestination_Am CHAR(20), 
														pExch_Rate_Fx CHAR(21), 
														pR_First_Name CHAR(40), 
														pR_Middle_Name CHAR(40), 
														pR_Last_Name CHAR(40), 
														pR_Mother_M_Name CHAR(40))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_guardarespuestarevibts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pTxn_Status = '' OR pConfirmation_nm = '' OR 
		pProcess_Reason_Cd = '' OR pBank_Ref_Num = '' OR pRev_Bank_Ref_Nm = '' OR pUser_name = '' OR pTerminal = '' OR 
		pAgent_Dt = '' OR pAgent_Tm = '' OR pSup_User_Name = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdisac:"informix".sp_guardarespuestarevi(pSucursal,pTxn_Status,pConfirmation_nm,
		pProcess_Reason_Cd,pBank_Ref_Num,pRev_Bank_Ref_Nm,pUser_name,pSup_User_Name,pTerminal, 
		pAgent_Dt,pAgent_Tm,pOpCode,pProcess_Msg,pError_Param_Full_Name,pTrans_Status_Cd,pTrans_Status_Dt,
		pProcess_Dt,pProcess_Tm,pService_Cd,pPaymet_Type_Cd,pOrig_Country_Cd,pOrig_Currency_Cd,pDest_Country_Cd, 
		pDest_Currency_Cd,pOrig_Am,pDestination_Am,pExch_Rate_Fx,pR_First_Name,pR_Middle_Name,pR_Last_Name, 
		pR_Mother_M_Name,pUsuario) 
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_guardarespuestarevi';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER > 1 THEN
			LET cCodRet = '00970'; --ERROR AL GUARDAR CONSULTA DE INTERACT, VERIFIQUE
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de guardar los datos de envío y recepción del mensaje REVI de BTS.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_mensajes(pUsuario CHAR(8), pIdFuncion CHAR(10),pAgentTransTypeCode CHAR(4), pOpCode CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(4)     AS agent_trans_type_code,       
		CHAR(4)  	AS opcode,       
		CHAR(50) 	AS opcode_sd,    
		CHAR(255)  	AS opcode_ds;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cAgentTransTypeCode   CHAR(4);
	DEFINE cOpcode               CHAR(4);
	DEFINE cOpcodesd             CHAR(50);
	DEFINE cOpcodeds             CHAR(255);
    DEFINE iNoRegistros 		 INTEGER;
	
	LET cCodRet     = '00000';
	LET iSqlErr     = 0;
	LET cAgentTransTypeCode='';
	LET cOpcode            ='';
	LET cOpcodesd          ='';
	LET cOpcodeds          ='';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_mensajes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pAgentTransTypeCode ='' OR  pOpCode=''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		END IF;
		 
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		END IF;
		
		SELECT agent_trans_type_code,opcode,opcode_sd, opcode_ds 
		INTO cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds
		FROM bdisac:"informix".sac_app_cat_mensajes
		WHERE agent_trans_type_code=pAgentTransTypeCode
		AND opcode=pOpCode;
				
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
			
		RETURN cCodRet,cAgentTransTypeCode,cOpcode,cOpcodesd,cOpcodeds;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 17/05/2016',
'MODULO: REMESAS',
'FUNCIONALIDAD: Cambio de Estatus Appriza',
'DESCRIPCION: SP que consulta el catalogo de mensjes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_obtieneinfoidentificacionbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pCodTipoIdent CHAR(3))
    RETURNING CHAR(5) AS codRet,
		CHAR(3) AS cod_tipo_identificacion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodigo CHAR(3);
	DEFINE cTipoIdentificacion CHAR(3);
	DEFINE cCodTipoIdentificacion CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cCodigo = '';
	LET cTipoIdentificacion = '';
	LET cCodTipoIdentificacion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cCodTipoIdentificacion;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_obtieneinfoidentificacionbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodTipoIdentificacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodTipoIdentificacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_bts_obtieneinfoidentificacion('1','')
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_bts_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cCodigo;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;			
			END FOREACH;
			
		ELIF pIdConsulta = '2' THEN
		
			IF pCodTipoIdent = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodTipoIdentificacion;
			END IF;
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_bts_obtieneinfoidentificacion('2',pCodTipoIdent)
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_bts_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cTipoIdentificacion;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;				
			END FOREACH;
		
		ELIF pIdConsulta = '3' THEN
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_app_obtieneinfoidentificacion('1','')
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cCodigo;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;			
			END FOREACH;
		
		ELIF pIdConsulta = '4' THEN
		
			IF pCodTipoIdent = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodTipoIdentificacion;
			END IF;
		
			FOREACH
				EXECUTE PROCEDURE bdisac:"informix".sp_app_obtieneinfoidentificacion('2',pCodTipoIdent)
				INTO cCodRetSp,cDescCodRet,cTipoIdentificacion,cCodigo
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_obtieneinfoidentificacion';
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017';
				END IF;
			
				LET cCodTipoIdentificacion = cTipoIdentificacion;
				RETURN cCodRet, TRIM(UPPER(cCodTipoIdentificacion)) WITH RESUME;				
			END FOREACH;
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de obtener los códigos y tipos de identificación válidos para BTS.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_parametrostransrevpagbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdParametro INTEGER, pNumBts CHAR(11))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS id_transaccion,
		CHAR(20) AS agent_user;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cAgentUser CHAR(20);
	DEFINE cIdTransaccionBts CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';	
	LET cAgentUser = '';
	LET cIdTransaccionBts = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cIdTransaccionBts, cAgentUser;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_parametrostransrevpagbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdTransaccionBts, cAgentUser;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdTransaccionBts, cAgentUser;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT FIRST 1 user_name 
		INTO cAgentUser
		FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = pNumBts;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneparametro(pIdParametro)
		INTO cCodRetSp,cIdTransaccionBts;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_obtieneparametro';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 504 THEN
			LET cCodRet = '00954'; --POR EL MOMENTO EL SERVICIO DE BTS NO ESTA OPERANDO, INTÉNTELO MÁS TARDE
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF NVL(cIdTransaccionBts,'') = '' THEN
				LET cCodRet = '00955'; --NO SE PUDO OBTENER PARÁMETRO DE TRANSACCIÓN
			END IF;
		END IF;
		
		RETURN cCodRet, TRIM(cIdTransaccionBts), TRIM(NVL(UPPER(cAgentUser),''));		
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de consultar el nombre de AgentUser y el id de la transacción de InterACT.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_queryorder(pUsuario 				CHAR(8),   
											pIdFuncion 				CHAR(10),  
											pTxn_status				CHAR(1),   
											pUnirefnum				CHAR(16),  
											pCode_Company			CHAR(3),   
											pChanneldid				CHAR(3),   
											pLocationunit			CHAR(15),  
											pNnumber				CHAR(15),  
											pTypecode_Branch		CHAR(3),
											pCountrycode_Branch		CHAR(3),   
											pStatecode_Branch		CHAR(3),   
											pTerminalid				CHAR(15),  
											pProcessdate_Qry		CHAR(8),   
											pProcesstime_Qry		CHAR(6),   
											pCode_Operacion			CHAR(5),   
											pCode					CHAR(4),   
											pMessage				CHAR(255), 
											pCode_d					CHAR(4),   
											pMessage_d				CHAR(255), 
											pProcessDate			CHAR(8),   
											pProcessTime			CHAR(6),   
											pRule					CHAR(3),   
											pValue					CHAR(3),   
											pGlobalTrackingNumber	CHAR(20),  
											pOrderStatusCode		CHAR(3),   
											pOrderStatusDate		CHAR(8),   
											pOrderStatusTime		CHAR(6),   
											pUniqueReferenceNumber	CHAR(16),  
											pCodesalecom			CHAR(3),   
											pCountryCode			CHAR(3),   
											pStateCodeSale			CHAR(3),   
											pSaleDate				CHAR(8),   
											pSaleTime				CHAR(6),   
											pCountryCode_o			CHAR(3),   
											pCurrencyCode			CHAR(3),   
											pServiceCode			CHAR(3),   
											pCountryCode_d			CHAR(3),   
											pCurrencyCode_d			CHAR(3),   
											pDeliveryMethodCode		CHAR(3),   
											pPayNetworkCode			CHAR(3),   
											pPaySubNetworkCode		CHAR(15),  
											pBranchNumber			CHAR(15),  
											pAccountTypeCode		CHAR(3),   
											pAccountNumber			CHAR(30),  
											pOriginAmount			CHAR(20),  
											pDestinationAmount		CHAR(20),  
											pRetailExchangeRate		CHAR(21),  
											pWholesaleExchangeRate	CHAR(21),  
											pDestinExchangeRate 	CHAR(21),  
											pServiceFeeAmount		CHAR(20),  
											pDiscountAmount			CHAR(20),  
											pTypeCode				CHAR(3),   
											pAccountNumber_c		CHAR(30),  
											pBicCode				CHAR(11),  
											pReferenceNumber		CHAR(30),  
											pCustomerNumber			CHAR(20),  
											pFirstName				CHAR(40),  
											pMiddleName				CHAR(40),  
											pLastName				CHAR(40),  
											pMotherMaidenName		CHAR(40),  
											pAddress				CHAR(80),  
											pCity					CHAR(40),  
											pCountryCode_a			CHAR(3),   
											pStateCode				CHAR(3),   
											pZipCode				CHAR(10),  
											pTypeCode_i				CHAR(3),   
											pNumber					CHAR(20),  
											pExpirationDate			CHAR(8),   
											pIssuerCountryCode		CHAR(3),   
											pIssuerStateCode		CHAR(3),   
											pDateOfBirth			CHAR(8),   
											pCustomerNumber_b		CHAR(20),  
											pFirstName_b			CHAR(40),  
											pMiddleName_b			CHAR(40),  
											pLastName_b				CHAR(40),  
											pMotherMaidenName_b		CHAR(40),  
											pFirstName_f			CHAR(40),  
											pMiddleName_f			CHAR(40),  
											pLastName_f				CHAR(40),  
											pMotherMaidenName_f		CHAR(40),  
											pAddress_b				CHAR(80),  
											pCity_b					CHAR(40),  
											pCountryCode_b			CHAR(3),   
											pStateCode_b			CHAR(3),   
											pZipCode_b				CHAR(10),  
											pEmail					CHAR(100), 
											pHomePhoneNumber		CHAR(15),  
											pWorkPhoneNumber		CHAR(15),  
											pNumber_cl				CHAR(15),  
											pReceiveEmail			CHAR(3),   
											pReceiveSMS				CHAR(3),   
											pTypeCode_ib			CHAR(3),   
											pNumber_ib				CHAR(20),  
											pExpirationDate_ib		CHAR(8),   
											pIssuerCountryCode_ib	CHAR(3),   
											pIssuerStateCode_ib		CHAR(3),   
											pReasonTypeCode			CHAR(3),   
											pReasonForTransfer		CHAR(40),  
											pSourceOfFunds			CHAR(40),  
											pSecurityPhrase			CHAR(40),  
											pFreeMessage			CHAR(255)) 
    RETURNING CHAR(5) AS codRet,
		CHAR(255) AS desc_CodRet,
		CHAR(255) AS mensaje_D;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(255);
	DEFINE cMensajeD CHAR(255);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cMensajeD = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cDescCodRet,cMensajeD;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_queryorder.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTxn_status = '' OR pUnirefnum = '' OR pCode_Company = '' OR 
		pChanneldid = '' OR pLocationunit = '' OR pNnumber = '' OR pTypecode_Branch = '' OR pCountrycode_Branch = '' OR 
		pStatecode_Branch = '' OR pTerminalid = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cDescCodRet,cMensajeD;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDescCodRet,cMensajeD;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		
		EXECUTE PROCEDURE bdisac:"informix".sp_app_queryorder(pTxn_status,pUnirefnum,pCode_Company,pChanneldid,
		pLocationunit,pNnumber,pTypecode_Branch,pCountrycode_Branch,pStatecode_Branch,pTerminalid,pProcessdate_Qry,		
		pProcesstime_Qry,pCode_Operacion,pCode,pMessage,pCode_d,pMessage_d,pProcessDate,pProcessTime,pRule,					
		pValue,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,pUniqueReferenceNumber,	
		pCodesalecom,pCountryCode,pStateCodeSale,pSaleDate,pSaleTime,pCountryCode_o,pCurrencyCode,pServiceCode,			
		pCountryCode_d,pCurrencyCode_d,pDeliveryMethodCode,pPayNetworkCode,pPaySubNetworkCode,pBranchNumber,			
		pAccountTypeCode,pAccountNumber,pOriginAmount,pDestinationAmount,pRetailExchangeRate,pWholesaleExchangeRate,	
		pDestinExchangeRate,pServiceFeeAmount,pDiscountAmount,pTypeCode,pAccountNumber_c,pBicCode,pReferenceNumber,		
		pCustomerNumber,pFirstName,pMiddleName,pLastName,pMotherMaidenName,pAddress,pCity,pCountryCode_a,pStateCode,				
		pZipCode,pTypeCode_i,pNumber,pExpirationDate,pIssuerCountryCode,pIssuerStateCode,pDateOfBirth,pCustomerNumber_b,		
		pFirstName_b,pMiddleName_b,pLastName_b,pMotherMaidenName_b,pFirstName_f,pMiddleName_f,pLastName_f,pMotherMaidenName_f,		
		pAddress_b,pCity_b,pCountryCode_b,pStateCode_b,pZipCode_b,pEmail,pHomePhoneNumber,pWorkPhoneNumber,pNumber_cl,				
		pReceiveEmail,pReceiveSMS,pTypeCode_ib,pNumber_ib,pExpirationDate_ib,pIssuerCountryCode_ib,pIssuerStateCode_ib,		
		pReasonTypeCode,pReasonForTransfer,pSourceOfFunds,pSecurityPhrase,pFreeMessage,pUsuario) 
		INTO cCodRetSp,cDescCodRet,cMensajeD;		
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_queryorder';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet,cDescCodRet,cMensajeD;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 04/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de generar trama para pago de remesas Appriza Pay.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_submitpayment(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	pterminalid			CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pcustomernumber		CHAR(20),
	pfirstname			CHAR(40),
	pmiddlename			CHAR(40),
	plastname			CHAR(40),
	pmommaidenname	 	CHAR(40),
	padress				CHAR(80),
	pcity				CHAR(40),
	pcountrycodeadr		CHAR(3),
	pstatecodeadr		CHAR(3),
	pzipcode			CHAR(10),
	pemail				CHAR(100),
	phomephonenum		CHAR(15),
	pnumbercel			CHAR(15),
	preceiveemail		CHAR(3),
	preceivesms			CHAR(3),
	ptypecodeci			CHAR(3),
	pnumberci			CHAR(20),
	pexpirationdate		CHAR(8),
	pissuercc			CHAR(3),
	pdateofbirth		CHAR(8),
	pcontrycode			CHAR(5),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_rule				CHAR(3),
	pr_value			CHAR(3),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_codesalecom		CHAR(3),
	pr_countrycode		CHAR(3),
	pr_statecodesale	CHAR(3),
	pr_saledate			CHAR(8),
	pr_saletime			CHAR(6),
	pr_countrycode_o	CHAR(3),
	pr_currencycode		CHAR(3),
	pr_servicecode		CHAR(3),
	pr_countrycode_d	CHAR(3),
	pr_currencycod_d	CHAR(3),
	pr_delimethodcod	CHAR(3),
	pr_playnwcode		CHAR(3),
	pr_paysubnwcode		CHAR(15),
	pr_branchnumber		CHAR(15),
	pr_accounttcod		CHAR(3),
	pr_accountnumber	CHAR(30),
	pr_originamount		CHAR(20),
	pr_destinamount		CHAR(20),
	pr_rexchangerate	CHAR(21),
	pr_wholesalerate	CHAR(21),
	pr_deexhangerate	CHAR(21),
	pr_servfeeamount	CHAR(20),
	pr_discountamoun	CHAR(20),
	pr_typecode			CHAR(3),
	pr_accountnum		CHAR(30),
	pr_biccode			CHAR(11),
	pr_refnumber		CHAR(30),
	pr_customernum		CHAR(20),
	pr_firstname		CHAR(40),
	pr_middlename		CHAR(40),
	pr_lastname			CHAR(40),
	pr_mommaidenname 	CHAR(40),
	pr_address			CHAR(80),
	pr_city				CHAR(40),
	pr_countrycode_a	CHAR(3),
	pr_statecode		CHAR(3),
	pr_zipcode			CHAR(10),
	pr_typecode_i		CHAR(3),
	pr_number			CHAR(20),
	pr_expirdate		CHAR(8),
	pr_isscontrycode	CHAR(3),
	pr_issstatecode		CHAR(3),
	pr_dateofbirth		CHAR(8),
	pr_customernum_b 	CHAR(20),
	pr_firstname_b		CHAR(40),
	pr_middlename_b		CHAR(40),
	pr_lastname_b		CHAR(40),
	pr_mommaidenna_b 	CHAR(40),
	pr_firstname_f		CHAR(40),
	pr_middlename_f		CHAR(40),
	pr_lastname_f		CHAR(40),
	pr_mommaidenna_f 	CHAR(40),
	pr_address_b		CHAR(80),
	pr_city_b			CHAR(40),
	pr_countrycode_b	CHAR(3),
	pr_statecode_b		CHAR(3),
	pr_zipcode_b		CHAR(10),
	pr_email			CHAR(100),
	pr_homephonenum 	CHAR(15),
	pr_workphonenum		CHAR(15),
	pr_number_cl		CHAR(15),
	pr_receiveemail		CHAR(3),
	pr_receivesms		CHAR(3),
	pr_typecode_ib		CHAR(3),
	pr_number_ib		CHAR(20),
	pr_expirdate_ib		CHAR(8),
	pr_issconcode_ib	CHAR(3),
	pr_issstacode_ib	CHAR(3),
	pr_reastypecode		CHAR(3),
	pr_refortransfer	CHAR(40),
	pr_sourceoffunds	CHAR(40),
	pr_securphrase		CHAR(40),
	pr_feemessage		CHAR(255)
	)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   	CHAR(5);
DEFINE iSqlErr   	INTEGER;
DEFINE cCodRetSp 	CHAR(5);
DEFINE iCodRetSp 	INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(255);
DEFINE cError_Desc_Detail CHAR (255);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';
LET cError_Desc_Detail='';
BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_submitpayment.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR NVL(pnnumber, '') = ''  OR NVL(prefnum, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_app_submitpayment(ptxn_status,punirefnum,prefnum,pcode,pchanneldid,plocationunit,pnnumber,ptypecode,pcountrycode,pstatecode,pterminalid,pprocessdate,pprocesstime,pcustomernumber,pfirstname,pmiddlename,plastname,
		pmommaidenname,padress,pcity,pcountrycodeadr,pstatecodeadr,pzipcode,pemail,phomephonenum,pnumbercel,preceiveemail,preceivesms,ptypecodeci,pnumberci,pexpirationdate,pissuercc,pdateofbirth,pcontrycode,pr_operacion,pr_code,pr_message,pr_code_d,
		pr_message_d,pr_processdate,pr_processtime,pr_rule,pr_value,pr_globtracknum,pr_ordstatuscode,pr_ordstatusdate,pr_ordstatustime,pr_uniquerefnum,pr_codesalecom,pr_countrycode,pr_statecodesale,pr_saledate,pr_saletime,pr_countrycode_o,
		pr_currencycode,pr_servicecode,pr_countrycode_d,pr_currencycod_d,pr_delimethodcod,pr_playnwcode,pr_paysubnwcode,pr_branchnumber,pr_accounttcod,pr_accountnumber,pr_originamount,pr_destinamount,pr_rexchangerate,pr_wholesalerate,
		pr_deexhangerate,pr_servfeeamount,pr_discountamoun,pr_typecode,pr_accountnum,pr_biccode,pr_refnumber,pr_customernum,pr_firstname,pr_middlename,pr_lastname,pr_mommaidenname,pr_address,pr_city,pr_countrycode_a,pr_statecode,
		pr_zipcode,pr_typecode_i,pr_number,pr_expirdate,pr_isscontrycode,pr_issstatecode,pr_dateofbirth,pr_customernum_b,pr_firstname_b,pr_middlename_b,pr_lastname_b,pr_mommaidenna_b,pr_firstname_f,pr_middlename_f,pr_lastname_f,
		pr_mommaidenna_f,pr_address_b,pr_city_b,pr_countrycode_b,pr_statecode_b,pr_zipcode_b,pr_email,pr_homephonenum,pr_workphonenum,pr_number_cl,pr_receiveemail,pr_receivesms,pr_typecode_ib,pr_number_ib,pr_expirdate_ib,pr_issconcode_ib,
		pr_issstacode_ib,pr_reastypecode,pr_refortransfer,pr_sourceoffunds,pr_securphrase,pr_feemessage,pUsuario,CURRENT)
		INTO cCodRetSp ,cError_Desc,cError_Desc_Detail;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_app_submitpayment";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
				
		RETURN cCodRet; 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 17/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Cambio de Estatus Remesas Appriza',
'DESCRIPCION: Guarda respuesta de transaccion al realizar el PAGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_submitpayreversal(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pprocretypecode		CHAR(3),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),	
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	terminalid				CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6)
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   	CHAR(5);
DEFINE iSqlErr   	INTEGER;
DEFINE cCodRetSp 	CHAR(5);
DEFINE iCodRetSp 	INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(255);
DEFINE cError_Desc_Detail CHAR (255);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';
LET cError_Desc_Detail='';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_submitpayreversal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(prefnum, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_app_submitpayreversal(ptxn_status,punirefnum,prefnum,pprocretypecode,pcode,pchanneldid,plocationunit,pnnumber,ptypecode,pcountrycode,pstatecode,terminalid,pprocessdate,pprocesstime,
		pr_operacion,pr_code,pr_message,pr_code_d,pr_message_d,pr_processdate,pr_processtime,pr_uniquerefnum,pr_globtracknum,pr_ordstatuscode,pr_ordstatusdate,pr_ordstatustime,pUsuario,current)
		INTO cCodRetSp ,cError_Desc,cError_Desc_Detail;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_app_submitpayreversal";
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 16/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Cambio de Estatus Remesas Appriza',
'DESCRIPCION: Guarda respuesta de transaccion al realizar el reverso',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaprocesosappriza(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumRem CHAR(12))
    RETURNING CHAR(5) AS codRet;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaprocesosappriza.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Valida dígito
		IF pIdConsulta = '1' THEN
		
			IF pNumRem = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF LENGTH(pNumRem) < 12 THEN
				LET cCodRet = '00974'; --EL NÚMERO DE CONFIRMACIÓN DEBE SER DE 12 DÍGITOS
				RETURN cCodRet;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_app_valdigito(pNumRem)
			INTO cCodRetSp;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_app_valdigito';
			ELIF cCodRetSp::INTEGER <> 0 THEN
				LET cCodRet = '00953'; --NÚMERO DE CONFIRMACIÓN INVÁLIDO, FAVOR DE VALIDAR
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 04/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CONSULTA DE REMESAS APPRIZA',
'DESCRIPCION: SPL encargado de validar los datos de entrada vs los parámetros de consulta establecidos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaprocesosbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumBts CHAR(12))
    RETURNING CHAR(5) AS codRet,
		CHAR(10) AS fecha_servidor,
		CHAR(25) AS hora_servidor;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cFecha = '';
	LET dHora = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFecha, dHora;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaprocesosbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, dHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, dHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		--Valida fecha/hr del sistema
		IF pIdConsulta = '1' THEN
		
			EXECUTE PROCEDURE bdinteg:"informix".sp_obtenfechahrasistema()
			INTO cCodRetSp,cFecha,dHora;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdinteg:sp_obtenfechahrasistema';
			END IF;
			
			IF TO_CHAR(dHora, '%H%M%S') > (SELECT valor FROM bdisac:"informix".sac_param WHERE cod_param = '87011') THEN
				LET cCodRet = '00951'; --HORARIO EXCEDE AL MÁXIMO PARAMETRIZADO
			END IF;
			
		--Valida número de confirmación BTS
		ELIF pIdConsulta = '2' THEN
		
			IF pNumBts = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, dHora;
			ELIF LENGTH(pNumBts) < 11 THEN
				LET cCodRet = '00952'; --NÚMERO DE CONFIRMACIÓN NO VÁLIDO
				RETURN cCodRet, cFecha, dHora;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_validabts(pNumBts)
			INTO cCodRetSp,cDescCodRet;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validabts';
			ELIF cCodRetSp::INTEGER <> 0 THEN
				LET cCodRet = '00953'; --NÚMERO DE CONFIRMACIÓN INVÁLIDO, FAVOR DE VALIDAR
			END IF;
		
		--Valida número de confirmación APPRIZA
		ELIF pIdConsulta = '3' THEN
		
			IF pNumBts = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, dHora;
			ELIF LENGTH(pNumBts) < 12 THEN
				LET cCodRet = '00979'; --EL NÚMERO DE CONFIRMACIÓN DEBE SER DE 12 DÍGITOS
				RETURN cCodRet, cFecha, dHora;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_validabts(pNumBts)
			INTO cCodRetSp,cDescCodRet;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validabts';
			ELIF cCodRetSp::INTEGER <> 0 THEN
				LET cCodRet = '00953'; --NÚMERO DE CONFIRMACIÓN INVÁLIDO, FAVOR DE VALIDAR
			END IF;
			
		END IF;
		
		RETURN cCodRet, cFecha, dHora;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 19/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de validar los datos de entrada vs los parámetros de consulta establecidos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaremesabts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumBts CHAR(11), pFolioSucursal CHAR(16), pFechaRealPago DATE)
    RETURNING CHAR(5) AS codRet,
		CHAR(15) AS Sucursal,
		CHAR(15) AS Terminal,
		CHAR(3)  AS R_Type_Cd,
		CHAR(20) AS R_Identif_Nm,
		CHAR(50) AS Nom_Calle,
		CHAR(5)  AS Num_Ext,
		CHAR(5)  AS Num_Int,
		CHAR(10) AS Depto,
		CHAR(80) AS Colonia,
		CHAR(5)  AS Cp,
		CHAR(50) AS Mncpo_Deleg,
		CHAR(50) AS Ciudad,
		CHAR(50) AS Estado,
		CHAR(3)  AS Issuer_Country_Cd,
		CHAR(15) AS Telefono,
		CHAR(1)  AS Tipo_Pago,
		CHAR(8)  AS Fecha_Nac,
		CHAR(50) AS Nacionalidad,
		CHAR(20) AS Pais_Nac,
		CHAR(20) AS Folio_Sucursal,
		CHAR(21) AS R_Issuer_Cd,
		CHAR(22) AS R_Expiration_Dt;
	
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr 				INT;
	DEFINE cCodRetSp 			CHAR(6);
	DEFINE iCodRetSp 			INTEGER;
	DEFINE cDescCodRet 			CHAR(80);
	DEFINE cEmpresa 			CHAR(3);
	
	DEFINE cSucursal            CHAR(15);
	DEFINE cTerminal            CHAR(15);
	DEFINE cR_Type_Cd           CHAR(3);
	DEFINE cR_Identif_Nm        CHAR(20);
	DEFINE cR_Nom_Calle         CHAR(50);
	DEFINE cR_Num_Ext           CHAR(5);
	DEFINE cR_Num_Int           CHAR(5);
	DEFINE cR_Depto             CHAR(10);
	DEFINE cR_Colonia           CHAR(80);
	DEFINE cR_Cp                CHAR(5);
	DEFINE cR_Mncpo_Deleg       CHAR(50);
	DEFINE cR_Ciudad            CHAR(50);
	DEFINE cR_Estado            CHAR(50);
	DEFINE cR_Issuer_Country_Cd CHAR(3);
	DEFINE cR_Telefono          CHAR(15);
	DEFINE cTipo_Pago           CHAR(1);
	DEFINE cR_Fecha_Nac         CHAR(8);
	DEFINE cR_Nacionalidad      CHAR(50);
	DEFINE cR_Pais_Nac			CHAR(20);
	DEFINE cFolio_Sucursal      CHAR(20);
	DEFINE cR_Issuer_Cd         CHAR(21);
	DEFINE cR_Expiration_Dt     CHAR(22);
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cCodRetSp 				= '';
	LET iCodRetSp 				= 0;
	LET cDescCodRet 			= '';
	LET cEmpresa 				= '001';
	
	LET cSucursal               = '';
	LET cTerminal               = '';
	LET cR_Type_Cd              = '';
	LET cR_Identif_Nm           = '';
	LET cR_Nom_Calle            = '';
	LET cR_Num_Ext              = '';
	LET cR_Num_Int              = '';
	LET cR_Depto                = '';
	LET cR_Colonia              = '';
	LET cR_Cp                   = '';
	LET cR_Mncpo_Deleg          = '';
	LET cR_Ciudad               = '';
	LET cR_Estado               = '';
	LET cR_Issuer_Country_Cd    = '';
	LET cR_Telefono             = '';
	LET cTipo_Pago              = '';
	LET cR_Fecha_Nac            = '';
	LET cR_Nacionalidad         = '';
	LET cR_Pais_Nac				= '';
	LET cFolio_Sucursal			= '';
	LET cR_Issuer_Cd            = '';
	LET cR_Expiration_Dt		= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
				cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
				cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
				cR_Issuer_Cd,cR_Expiration_Dt;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaremesabts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumBts = '' OR pFolioSucursal = '' OR pFechaRealPago IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
			cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
			cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
			cR_Issuer_Cd,cR_Expiration_Dt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
			cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
			cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
			cR_Issuer_Cd,cR_Expiration_Dt;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_validarembtsensac(pNumBts,pFolioSucursal,pFechaRealPago)
		INTO cCodRetSp,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
		cR_Depto,cR_Colonia,cR_Cp,cR_Mncpo_Deleg,cR_Ciudad,cR_Estado,cR_Issuer_Country_Cd,
		cR_Telefono,cTipo_Pago,cR_Fecha_Nac,cR_Nacionalidad,cR_Pais_Nac,cFolio_Sucursal,		
		cR_Issuer_Cd,cR_Expiration_Dt;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisac:sp_validarembtsensac';
		ELIF cCodRetSp::INTEGER > 0 THEN
			IF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 4 THEN
				LET cCodRet = '00971'; --FECHA REAL DEL PAGO INVALIDA, VERIFIQUE
			ELSE
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			END IF;
		ELIF cCodRetSp::INTEGER = 0 THEN
			IF cFolio_Sucursal <> '' AND (pFolioSucursal = cFolio_Sucursal) THEN
				LET cCodRet = '00000';
			ELSE
				LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			END IF;
		END IF;
		
		RETURN cCodRet,cSucursal,cTerminal,cR_Type_Cd,cR_Identif_Nm,cR_Nom_Calle,cR_Num_Ext,cR_Num_Int,          
		cR_Depto,UPPER(cR_Colonia),cR_Cp,UPPER(cR_Mncpo_Deleg),UPPER(cR_Ciudad),UPPER(cR_Estado),UPPER(cR_Issuer_Country_Cd),
		cR_Telefono,UPPER(cTipo_Pago),cR_Fecha_Nac,UPPER(cR_Nacionalidad),UPPER(cR_Pais_Nac),cFolio_Sucursal,		
		UPPER(cR_Issuer_Cd),cR_Expiration_Dt;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/04/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de validar que exista la remesa que se desea pagar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesamensajeserrorwu(pUsuario CHAR(8), pIdFuncion CHAR(10), pCode CHAR(6), pDescripcion CHAR(255))
		RETURNING CHAR(5) AS codret,
		CHAR(6)     AS codError,       
		CHAR(255)   AS traduccion;
	
	DEFINE cCodRet      CHAR(5);
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodError    CHAR(6);  
	DEFINE cTraduccion  CHAR(255);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet         = '00000';
	LET iSqlErr         = 0;
	LET cCodError       = '';  
	LET cTraduccion     = '';
	LET iNoRegistros    = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodError,cTraduccion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesamensajeserrorwu.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCode = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCodError,cTraduccion;
		END IF;
		 
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCodError,cTraduccion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		IF EXISTS(SELECT coderror FROM intercard:"informix".wswesternunionerrores WHERE coderror = pCode) THEN
				
			SELECT coderror,NVL(traduccion,'') INTO cCodError,cTraduccion
			FROM intercard:"informix".wswesternunionerrores WHERE coderror=pCode;
							
			RETURN cCodRet,cCodError,cTraduccion;
		
		ELSE
						
			INSERT INTO intercard:"informix".wswesternunionerrores(coderror,traduccion) VALUES(pCode,pDescripcion);
	
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282'; --ERROR AL GUARDAR EL REGISTRO
			END IF; 
				
			RETURN cCodRet,pCode,pDescripcion;

				
		END IF;
			
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 06/06/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: Consulta de Remesas WU',
'DESCRIPCION: SPL que consulta o inserta en el catálogo de mensajes',
'AUTOR: L. Montserrat León Amador',
'FECHA: 21/08/2017',
'DESCRIPCION: Se modifica spl para corregir validación de parámetros de entrada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasguardarespuestawu(pUsuario CHAR(8), pIdFuncion CHAR(10), 
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
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasguardarespuestawu.out';
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
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search(cEmpresa,pUsuario,pMarca,pForeignRsRefNumRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,pEmisorNombre1,
		pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,pEmisorTel,pBenefNameType,pBenefNombre1,
		pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,
		pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,
		pNumCoincidencias,pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,current,pUsuario,current)--pFechaHoraRp
		INTO cCodRetSp ,cError_Desc;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_sac_wu_guardarespuesta_search";
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
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_actlimiteremesa_edo_suc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pIdRemesadora SMALLINT, pValor CHAR(4), 
pPesos MONEY(16,2), pUsd MONEY(16,2), pStatus SMALLINT)
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE cMarca CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET cMarca = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_actlimiteremesa_edo_suc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdRemesadora IS NULL OR pValor = '' OR 
		pPesos IS NULL OR pUsd IS NULL OR pStatus IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pIdRemesadora = 1 THEN
			LET cAbreviatura = 'APP_DIA_';
			LET cMarca = 'APP';
		ELIF pIdRemesadora = 2 THEN
			LET cAbreviatura = 'BTS_DIA_';
			LET cMarca = 'BTS';
		ELIF pIdRemesadora = 3 THEN
			LET cAbreviatura = 'WU_DIA_';
			LET cMarca = 'WU';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Actualiza Estado
		IF pIdEjecucion = '1' THEN
		
			UPDATE bdisac:"informix".sac_limite_edo SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura) AND estado = TRIM(pValor);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
				
		--Actualiza Sucursal 
		ELIF pIdEjecucion = '2' THEN
		
			UPDATE bdisac:"informix".sac_limite_suc SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura) AND sucursal = TRIM(pValor);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		--Guarda Sucursal 
		ELIF pIdEjecucion = '3' THEN
			
			INSERT INTO bdisac:"informix".sac_limite_suc (abreviatura,sucursal,pesos,usd,marca,status,descripcion,fecha_insert) 
			VALUES(TRIM(cAbreviatura),TRIM(pValor),pPesos,pUsd,TRIM(cMarca),pStatus,'Limite por operaciones',CURRENT YEAR TO FRACTION(3));
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
			
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de guardar/actualizar el valor del límite en UDS y PESOS y el status, dependiendo del tipo de remesadora y estado o sucursal seleccionados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogoestado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_estado,
			CHAR(30) AS desc_estado;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdEstado CHAR(2);
	DEFINE cDescEstado CHAR(30);
	DEFINE cMarca CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdEstado = 0;
	LET cDescEstado = '';
	LET cMarca = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdEstado, cDescEstado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogoestado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
		
		IF pIdConsulta = '1' THEN
			LET cMarca = 'APP';
		ELIF pIdConsulta = '2' THEN
			LET cMarca = 'BTS';
		ELIF pIdConsulta = '3' THEN
			LET cMarca = 'WU';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT a.estado, b.nombre
			INTO cIdEstado, cDescEstado
			FROM bdisac:"informix".sac_limite_edo AS a, bdinteg:"informix".si_estados As b 
			WHERE a.estado = b.estado AND a.marca = TRIM(cMarca) ORDER BY a.estado ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdEstado, TRIM(UPPER(cDescEstado)) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdEstado, cDescEstado;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo estado, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogoremesadora(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			SMALLINT AS id_remesadora,
			CHAR(100) AS desc_remesadora;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdRemesadora SMALLINT;
	DEFINE cDescRemesadora CHAR(100);
	DEFINE cGpoRemesadora CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdRemesadora = 0;
	LET cDescRemesadora = '';
	LET cGpoRemesadora = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogoremesadora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
			LET cGpoRemesadora = 'A';
		ELIF pIdConsulta = '3' THEN
			LET cGpoRemesadora = 'C';
		END IF;
		
		IF pIdConsulta = '1' OR pIdConsulta = '3' THEN
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora = TRIM(cGpoRemesadora)
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
		
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora IN ('A','B')
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
			
		ELIF pIdConsulta = '4' THEN
		
			FOREACH
				
				SELECT id_remesadora, desc_remesadora
				INTO cIdRemesadora, cDescRemesadora
				FROM bdicnweb:"informix".sw_rem_remesadora
				WHERE grupo_remesadora IN ('A','B','C')
				ORDER BY desc_remesadora ASC
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cIdRemesadora, TRIM(UPPER(cDescRemesadora)) WITH RESUME;
				
			END FOREACH;
			
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdRemesadora, cDescRemesadora;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar el detalle del catálogo remesadora dependiendo del tipo de límite seleccionado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_catalogostatus(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			SMALLINT AS id_status,
			CHAR(12) AS desc_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(2);
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = 0;
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_catalogostatus.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT id_status,desc_status 
			INTO cIdStatus, cDescStatus
			FROM bdicnweb:"informix".sw_rem_statuslimite
			ORDER BY id_status ASC
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cIdStatus, TRIM(UPPER(cDescStatus)) WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 18/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar los status disponibles del límite de remesas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consactlimiteremesa_monto_acum(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), 
pTipoMonto CHAR(1), pIdRemesadora SMALLINT, pPesos MONEY(16,2), pUsd MONEY(16,2), pStatus SMALLINT)
		RETURNING CHAR(5) AS codret,
			MONEY(16,2) AS usd,
			MONEY(16,2) AS pesos,
			SMALLINT AS status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE mUsd MONEY(16,2);
	DEFINE mPesos MONEY(16,2);
	DEFINE sStatus SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET mUsd = 0.00;
	LET mPesos = 0.00;
	LET sStatus = NULL;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consactlimiteremesa_monto_acum.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pTipoMonto = '' OR pIdRemesadora IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, mUsd, mPesos, sStatus;
		END IF;
		
		IF pTipoMonto = 'D' THEN
		
			IF pIdRemesadora = 1 THEN
				LET cAbreviatura = 'APP_DIA_';
			ELIF pIdRemesadora = 2 THEN
				LET cAbreviatura = 'BTS_DIA_';
			ELIF pIdRemesadora = 3 THEN
				LET cAbreviatura = 'WU_DIA_';
			ELIF pIdRemesadora = 4 THEN
				LET cAbreviatura = 'APP_DIA_AUT_';
			ELIF pIdRemesadora = 5 THEN
				LET cAbreviatura = 'BTS_DIA_AUT_';
			END IF;
		
		ELIF pTipoMonto = 'M' THEN
		
			IF pIdRemesadora = 1 THEN
				LET cAbreviatura = 'APP_MES_';
			ELIF pIdRemesadora = 2 THEN
				LET cAbreviatura = 'BTS_MES_';
			ELIF pIdRemesadora = 3 THEN
				LET cAbreviatura = 'WU_MES_';
			ELIF pIdRemesadora = 4 THEN
				LET cAbreviatura = 'APP_MES_AUT_';
			ELIF pIdRemesadora = 5 THEN
				LET cAbreviatura = 'BTS_MES_AUT_';
			END IF;
			
		ELIF pTipoMonto = 'A' THEN
		
			IF pIdRemesadora = 6 THEN
				LET cAbreviatura = 'TODAS_';
			END IF;
			
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Consulta
		IF pIdEjecucion = '1' THEN 
		
			SELECT usd, pesos, status 
			INTO mUsd, mPesos, sStatus
			FROM bdisac:"informix".sac_limite_monto
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
		--Actualiza
		ELIF pIdEjecucion = '2' THEN 
		
			IF pPesos IS NULL OR pUsd IS NULL OR pStatus IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, mUsd, mPesos, sStatus;
			END IF;
		
			UPDATE bdisac:"informix".sac_limite_monto SET pesos = pPesos, usd = pUsd, status = pStatus--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, mUsd, mPesos, sStatus;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar/actualizar el valor del límite en UDS y PESOS y el status, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_consactlimiteremesa_numtrans(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pIdRemesadora SMALLINT, pNoTransacciones SMALLINT)
		RETURNING CHAR(5) AS codret,
			SMALLINT AS no_transacciones;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cAbreviatura CHAR(20);
	DEFINE sNoTransacciones SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cAbreviatura = '';
	LET sNoTransacciones = NULL;
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sNoTransacciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consactlimiteremesa_numtrans.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdRemesadora IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sNoTransacciones;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sNoTransacciones;
		END IF;
		
		IF pIdRemesadora = 1 THEN
			LET cAbreviatura = 'APP_MES_';
		ELIF pIdRemesadora = 2 THEN
			LET cAbreviatura = 'BTS_MES_';
		ELIF pIdRemesadora = 3 THEN
			LET cAbreviatura = 'WU_MES_';
		ELIF pIdRemesadora = 4 THEN
			LET cAbreviatura = 'APP_MES_AUT_';
		ELIF pIdRemesadora = 5 THEN
			LET cAbreviatura = 'BTS_MES_AUT_';
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Consulta
		IF pIdEjecucion = '1' THEN 
		
			SELECT operaciones
			INTO sNoTransacciones
			FROM bdisac:"informix".sac_limite_monto
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017';
			END IF;
				
		--Actualiza
		ELIF pIdEjecucion = '2' THEN 
		
			IF pNoTransacciones IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, sNoTransacciones;
			END IF;
		
			UPDATE bdisac:"informix".sac_limite_monto SET operaciones = pNoTransacciones--, fecha_insert =  CURRENT YEAR TO FRACTION(3)
			WHERE abreviatura = TRIM(cAbreviatura);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
			END IF;
			
		END IF;
		
		RETURN cCodRet, sNoTransacciones;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 19/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MODIFICACIÓN DE LÍMITE DE REMESAS',
'DESCRIPCION: SPL encargado de consultar/actualizar el número de transacciones, dependiendo del tipo de remesadora seleccionada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_generarepremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1),
pIdLimite SMALLINT, pFechaInicio DATE, pFechaFin DATE, pClaveId CHAR(100), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS limite,
		DATE AS fecha_env,
		CHAR(40) AS nombre1_ord,
		CHAR(40) AS nombre2_ord,
		CHAR(40) AS appaterno_ord,
		CHAR(40) AS apmaterno_ord,
		CHAR(80) AS direccion_ord,
		CHAR(80) AS colonia_ord,
		CHAR(40) AS ciudad_ord,
		CHAR(3) AS estado_ord,
		CHAR(3) AS pais_ord,
		CHAR(3) AS tipoid_ord,
		CHAR(20) AS numeroid_ord,
		CHAR(3) AS ciudadid_ord,
		CHAR(3) AS paisid_ord,
		CHAR(3) AS moneda_ord,
		CHAR(20) AS monto_origen,
		CHAR(20) AS monto_pesos,
		CHAR(40) AS nombre1_ben,
		CHAR(40) AS nombre2_ben,
		CHAR(40) AS appaterno_ben,
		CHAR(40) AS apmaterno_ben,
		CHAR(8) AS fechanacimiento_ben,
		CHAR(80) AS direccion_ben,
		CHAR(80) AS colonia_ben,
		CHAR(40) AS ciudad_ben,
		CHAR(40) AS estado_ben,
		CHAR(15) AS telefono_ben,
		CHAR(3) AS tipoid_ben,
		CHAR(20) AS numeroid_ben,
		CHAR(4) AS numeroid_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFechaEnv DATE;
	DEFINE cNombre1Ord CHAR(40);
	DEFINE cNombre2Ord CHAR(40);
	DEFINE cApPaternoOrd CHAR(40);
	DEFINE cApMaternoOrd CHAR(40);
	DEFINE cDireccionOrd CHAR(80);		
	DEFINE cColoniaOrd CHAR(80);    	
	DEFINE cCiudadOrd CHAR(40);			
	DEFINE cEstadoOrd CHAR(3);	
	DEFINE cPaisOrd CHAR(3);	
	DEFINE cTipoIdOrd CHAR(3);	
	DEFINE cNumeroIdOrd CHAR(20);	
	DEFINE cCiudadIdOrd CHAR(3);	
	DEFINE cPaisIdOrd CHAR(3);	
	DEFINE cMonedaOrd CHAR(3);	
	DEFINE cMontoOrigen CHAR(20);		
	DEFINE cMontoPesos CHAR(20);		
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cFechaNacimientoBen CHAR(8);
	DEFINE cDireccionBen CHAR(80);		
	DEFINE cColoniaBen CHAR(80);    	
	DEFINE cCiudadBen CHAR(40);	    	
	DEFINE cEstadoBen CHAR(40);     	
	DEFINE cTelefonoBen CHAR(15);	
	DEFINE cTipoIdBen CHAR(3);      	
	DEFINE cNumeroIdBen CHAR(20);   	
	DEFINE cNumeroIdSuc CHAR(4);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cClaveId CHAR(100);
	DEFINE cLimite CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFechaEnv = '';
	LET cNombre1Ord = '';
	LET cNombre2Ord = '';
	LET cApPaternoOrd = '';
	LET cApMaternoOrd = '';
	LET cDireccionOrd = '';
	LET cColoniaOrd = '';
	LET cCiudadOrd = '';
	LET cEstadoOrd = '';
	LET cPaisOrd = '';
	LET cTipoIdOrd = '';
	LET cNumeroIdOrd = '';
	LET cCiudadIdOrd = '';
	LET cPaisIdOrd = '';
	LET cMonedaOrd = '';
	LET cMontoOrigen = '';
	LET cMontoPesos = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cFechaNacimientoBen = '';
	LET cDireccionBen = '';
	LET cColoniaBen = '';
	LET cCiudadBen = '';
	LET cEstadoBen = '';
	LET cTelefonoBen = '';
	LET cTipoIdBen = '';
	LET cNumeroIdBen = '';
	LET cNumeroIdSuc = '';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cClaveId = 'REMNOPAGADAS'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cLimite = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
				cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
				cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_generarepremesasnopagadas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdLimite IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pClaveId = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		IF pIdLimite = 8 THEN
			LET pIdLimite = NULL;
		END IF;
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion limite,fecha_env,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,
			tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,
			fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc
			INTO cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc				
			FROM bdicnweb:"informix".sw_detalleremesasnopagadas
			WHERE id_limite = (CASE WHEN pIdLimite IS NULL THEN id_limite ELSE pIdLimite END)
			AND fecha_env BETWEEN pFechaInicio AND pFechaFin
			AND usuario_insert = pUsuario AND clave_id = TRIM(pClaveId)
			ORDER BY limite,fecha_env ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc WITH RESUME;
			
		END FOREACH;		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			
			RETURN cCodRet,cLimite,dFechaEnv,cNombre1Ord,cNombre2Ord,cApPaternoOrd,cApMaternoOrd,cDireccionOrd,cColoniaOrd,cCiudadOrd,cEstadoOrd,cPaisOrd,
			cTipoIdOrd,cNumeroIdOrd,cCiudadIdOrd,cPaisIdOrd,cMonedaOrd,cMontoOrigen,cMontoPesos,cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,
			cFechaNacimientoBen,cDireccionBen,cColoniaBen,cCiudadBen,cEstadoBen,cTelefonoBen,cTipoIdBen,cNumeroIdBen,cNumeroIdSuc;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de consultar el detalle de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_verificastatusremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS num_registros,
			  CHAR(100) AS clave_id,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iNumRegistros INTEGER;
	DEFINE cClaveId CHAR(100);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iNumRegistros = 0;
	LET cClaveId = '';
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_verificastatusremesasnopagadas.out';
		--TRACE ON;
		
		--VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		SELECT status,num_registros,clave_id,error_proceso,error
		INTO cStatus,iNumRegistros,cClaveId,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_statusprocesoremnopag WHERE usuario_insert = TRIM(pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I',0,'','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cClaveId,cErrorProceso,cError;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/01/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de verificar el status del proceso de consulta de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallefacturacionos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCte CHAR(9), 
pFechaInicio CHAR(10), pFechaFin CHAR(10), pTipoFecha SMALLINT, pTipoConsulta SMALLINT)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;	
	
	DEFINE cCodRet 		  CHAR(5);
	DEFINE iSqlErr 		  INTEGER;
	DEFINE cCodRetSp 	  CHAR(6);
	DEFINE cDesCodRetSp   CHAR(50);
	DEFINE cEmpresa 	  CHAR(3);
	DEFINE cSucursal      CHAR (4);
	DEFINE iTotalEnviadas INTEGER;
	DEFINE iImpresas      INTEGER;
	DEFINE dImpresasPor   DECIMAL(5,2);
	DEFINE iNoImpresas    INTEGER;
	DEFINE dNoImpresasPor DECIMAL(5,2);
	DEFINE iStatusA       INTEGER;
	DEFINE dStatusAPor    DECIMAL(5,2);
	DEFINE iStatusR       INTEGER;
	DEFINE dStatusRPor    DECIMAL(5,2);
	DEFINE iStatusD       INTEGER;
	DEFINE dStatusDPor    DECIMAL(5,2);
	DEFINE iStatusS       INTEGER;
	DEFINE dStatusSPor    DECIMAL(5,2);
	DEFINE iBancoppel     INTEGER;
	DEFINE iCoppel        INTEGER;
	DEFINE iMixta         INTEGER;
	DEFINE iTotal         INTEGER;
	DEFINE iNumRegistros  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet 		  = '00000';
	LET iSqlErr           = 0;
	LET cCodRetSp 		  = '';
	LET cDesCodRetSp 	  = '';
	LET cEmpresa 		  = '001';
	LET cSucursal         = '';
	LET iTotalEnviadas    = 0;
	LET iImpresas         = 0;
	LET dImpresasPor      = 0;
	LET iNoImpresas       = 0;
	LET dNoImpresasPor    = 0;
	LET iStatusA          = 0;
	LET dStatusAPor       = 0;
	LET iStatusR          = 0;
	LET dStatusRPor       = 0;
	LET iStatusD          = 0;
	LET dStatusDPor       = 0;
	LET iStatusS          = 0;
	LET dStatusSPor       = 0;
	LET iBancoppel        = 0;
	LET iCoppel           = 0;
	LET iMixta            = 0;
	LET iTotal            = 0;
	LET iNumRegistros     = 0;
	LET iRecuperacion	  = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallefacturacionos_totales.out';
		--TRACE ON;

		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_statusproceso_os WHERE usuario = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_statusproceso_os(usuario,status,num_registros,error_proceso,error)
		VALUES(pUsuario,'I',0,'',TRIM(cCodRet)); 
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pTipoFecha IS NULL OR pTipoConsulta IS NULL THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_facturacion_os WHERE usuario_insert = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			EXECUTE PROCEDURE bdisolic:"informix".sp_consultarfacturacionos2(cEmpresa,pSucursal,pNumCte,pFechaInicio,pFechaFin,pTipoFecha,pTipoConsulta,0,0)
			INTO cCodRetSp, cSucursal, iTotalEnviadas, iImpresas, dImpresasPor, iNoImpresas, dNoImpresasPor, iStatusA, dStatusAPor, 
			iStatusR, dStatusRPor, iStatusD, dStatusDPor, iStatusS, dStatusSPor, iBancoppel, iCoppel, iMixta, iTotal
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_consultarfacturacionos2';
			ELIF cCodRetSp::INTEGER = 1 OR cCodRetSp::INTEGER = 4 THEN 
				LET cCodRet = '00044'; --EL TIPO DE BUSQUEDA ES INCORRECTO
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 2 OR cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 5 THEN 
				LET cCodRet = '00154'; --LA FECHA INICIAL ES MAYOR A LA FECHA FINAL
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			ELIF cCodRetSp::INTEGER = 6 THEN 
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_statusproceso_os
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
				RETURN cCodRet, NVL(iNumRegistros,0);
			END IF;
				
			LET iRecuperacion = iRecuperacion + 1;
			INSERT INTO bdicnweb:"informix".sw_facturacion_os(sucursal,total_enviadas,impresas_n,impresas_p,no_impresas_n,no_impresas_p,
			statusA_n,statusA_p,statusR_n,statusR_p,statusD_n,statusD_p,statusS_n,statusS_p,bancoppel,coppel,mixta,total,usuario_insert)
			VALUES(cSucursal,iTotalEnviadas,iImpresas,dImpresasPor,iNoImpresas,dNoImpresasPor,iStatusA,dStatusAPor,iStatusR,dStatusRPor, 
			iStatusD,dStatusDPor,iStatusS,dStatusSPor,iBancoppel,iCoppel,iMixta,iTotal,pUsuario);
		END FOREACH;
		
		SELECT COUNT(*) 
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_facturacion_os 
		WHERE usuario_insert = pUsuario;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			UPDATE bdicnweb:"informix".sw_statusproceso_os
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			RETURN cCodRet, NVL(iNumRegistros,0);
		END IF;
		
		UPDATE bdicnweb:"informix".sw_statusproceso_os
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario = TRIM(pUsuario);  
		RETURN cCodRet, NVL(iNumRegistros,0);
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 20/09/2017',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: FACTURACIÓN DE ÓRDENES DE SUPERVISIÓN',
'DESCRIPCION: Spl encargado de consultar el número total de facturaciones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catcalles_consecutivo(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		INTEGER AS secuencia;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iSecuencia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iSecuencia=0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iSecuencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catcalles_consecutivo.out';
		--TRACE ON;
		
		IF pUsuario = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		INSERT INTO sw_cli_calles_consecutivo(us_insert,fecha_insert) VALUES(pUsuario, CURRENT);
		
		SELECT MAX(id_serial) INTO iSecuencia FROM sw_cli_calles_consecutivo;
		
		RETURN cCodRet, iSecuencia;
	
	END;
	
END PROCEDURE;