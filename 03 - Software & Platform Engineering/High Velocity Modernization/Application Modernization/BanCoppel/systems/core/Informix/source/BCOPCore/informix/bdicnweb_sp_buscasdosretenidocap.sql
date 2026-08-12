CREATE PROCEDURE "informix".sp_buscasdosretenidocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
				DATE AS fecha_compra,
				CHAR(16) AS folio_operacion,
				MONEY(17,2) AS importe,
				CHAR(40) AS referencia,
				CHAR(12) AS dias_restantes;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	
	DEFINE dFechaCompra DATE;
	DEFINE cFolioOperacion CHAR(16);
	DEFINE mImporte MONEY(17,2);
	DEFINE cReferencia CHAR(40);
	DEFINE cDiasRestantes CHAR(12);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET dFechaCompra = NULL;
	LET cFolioOperacion = '';
	LET mImporte = NULL;
	LET cReferencia = '';
	LET cDiasRestantes = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET iRecuperacion = 0;
	LET iRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_buscasdosretenidocap';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '01', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdicheq:sp_buscasdosretenido(cEmpresa, pCuenta) INTO cCodRetSp, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes
		
			IF cCodRetSp::INTEGER = 3 THEN -- La cuenta no existe
				LET cCodRet = '00009';
				RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
			ELIF cCodRetSp::INTEGER = 4 THEN -- No hay datos
				LET cCodRet = '00017';
				RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
			ELIF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:sp_buscasdosretenido';
			ELSE
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
				END IF;
			END IF;
			
			LET iRegistros = iRegistros + 1;
		
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes;
		END IF;
	
	END

END PROCEDURE 
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/01/2014',
'DESCRIPCION: Realiza la consulta para los saldos retenidos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_buscatotalsdosretenidocap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret,
				INTEGER AS totales;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	
	DEFINE dFechaCompra DATE;
	DEFINE cFolioOperacion CHAR(16);
	DEFINE mImporte MONEY(17,2);
	DEFINE cReferencia CHAR(40);
	DEFINE cDiasRestantes CHAR(12);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET dFechaCompra = NULL;
	LET cFolioOperacion = '';
	LET mImporte = NULL;
	LET cReferencia = '';
	LET cDiasRestantes = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_buscatotalsdosretenidocap';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '01', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdicheq:sp_buscasdosretenido(cEmpresa, pCuenta) INTO cCodRetSp, dFechaCompra, cFolioOperacion, mImporte, cReferencia, cDiasRestantes
		
			IF cCodRetSp::INTEGER = 3 THEN -- La cuenta no existe
				LET cCodRet = '00009';
				RETURN cCodRet, iNoRegistros;
			ELIF cCodRetSp::INTEGER = 4 THEN -- No hay datos
				LET cCodRet = '00017';
				RETURN cCodRet, iNoRegistros;
			ELIF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicheq:sp_buscasdosretenido';
			ELSE
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF
	
		RETURN cCodRet, iNoRegistros;
	END

END PROCEDURE 
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/01/2014',
'DESCRIPCION: Realiza la consulta del total de registros para los saldos retenidos',
'BD: bdicnweb';

CREATE PROCEDURE  "informix".sp_consopcodebts(pUsuario  CHAR(8), pIdFuncion CHAR(10), pOpcode CHAR(4))
        RETURNING CHAR(5) AS codigoRetorno,
			CHAR(80) AS mensaje;

			DEFINE  iSqlErr         INTEGER;
			DEFINE  cCodRet         CHAR(5);
			DEFINE  cMensaje        CHAR(80);

			LET  iSqlErr = 0;
			LET  cCodRet = '00000';
			LET  cMensaje = '';
			
        BEGIN
			ON EXCEPTION SET iSqlErr
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, cMensaje;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_consopcodebts.out';
			--TRACE ON;
			
			IF pIdFuncion = '' OR pUsuario = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cMensaje;
			END IF;
			
			--Valida los permisos del Usuario
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cMensaje;
			END IF;

			SET ISOLATION TO DIRTY READ;
			IF pOpcode = '1000' THEN
				SELECT UPPER(opcode_sd) INTO cMensaje FROM bdisac:sac_bts_catmensajes where opcode = pOpcode AND agent_trans_type_code = 'QRYI';
				RETURN cCodRet, cMensaje;
			ELSE
				SELECT UPPER(opcode_ds) INTO cMensaje FROM bdisac:sac_bts_catmensajes where opcode = pOpcode AND agent_trans_type_code = 'QRYI';
				RETURN cCodRet, cMensaje;
			END IF;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2014',
'DESCRIPCION: Consulta la descripciiÃ³n del codigo de operaciÃ³n retornado por la transacciÃ³n de bts',
'BD: bdicnweb';

CREATE PROCEDURE  "informix".sp_constatuscodebts(pUsuario  CHAR(8), pIdFuncion CHAR(10), pDansStatusCode CHAR(3))
        RETURNING CHAR(5) AS codigoRetorno,
			CHAR(80) AS mensaje;

			DEFINE  iSqlErr         INTEGER;
			DEFINE  cCodRet         CHAR(5);
			DEFINE  cMensaje        CHAR(80);

			LET  iSqlErr = 0;
			LET  cCodRet = '00000';
			LET  cMensaje = '';
			
        BEGIN
			ON EXCEPTION SET iSqlErr
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, cMensaje;
			END EXCEPTION;
			
			IF pIdFuncion = '' OR pUsuario = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cMensaje;
			END IF;
			
			----Valida los permisos del Usuario
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cMensaje;
			END IF;

			SET ISOLATION TO DIRTY READ;
			SELECT UPPER(dans_status_code_sd) INTO cMensaje FROM bdisac:sac_bts_catstatusremesas where dans_status_code = pDansStatusCode;
			RETURN cCodRet, cMensaje;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2014',
'DESCRIPCION: Consulta la descripcion del estatus del mensaje de la remesa bts',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultactadebitocredito(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuentaClienteTarjeta CHAR(20), pTipoBusqueda SMALLINT, pSistemaCuenta CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret, 
					CHAR(13) AS num_cuenta, 
					CHAR(2) AS sistema_cuenta,
					CHAR(20) AS num_cliente, 
					CHAR(16) AS num_tarjeta, 
					CHAR(4) AS producto,
					CHAR(40) AS desc_producto, 
					CHAR(26) AS nombre1, 
					CHAR(26) AS nombre2, 
					CHAR(26) AS apellido_paterno, 
					CHAR(26) AS apellido_materno, 
					CHAR(30) AS status;
					
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCuenta CHAR(13);
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cNumProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApellidoPaterno CHAR(26);
	DEFINE cApellidoMaterno CHAR(26);
	DEFINE cStatus CHAR(30);
	DEFINE cCuenta CHAR(20);
	DEFINE cTarjeta CHAR(20);
	DEFINE cCliente CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cNumCuenta = '';
	LET cSistemaCuenta = '';
	LET cNumCliente = '';
	LET cNumTarjeta = '';
	LET cNumProducto = '';
	LET cDescProducto = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApellidoPaterno = '';
	LET cApellidoMaterno = '';
	LET cStatus = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET cCliente = '';
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	LET iRecuperacion = 0;
	LET iRegistros = 0;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
					cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultactadebitocredito.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuentaClienteTarjeta = '' OR pTipoBusqueda IS NULL OR pSistemaCuenta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
					cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
		END IF;
		
		-- VALIDACION DE LOS DATOS DE LA PAGINACIÃN
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
					cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
		END IF;
		
		IF pTipoBusqueda NOT IN (1, 2, 3) THEN
			LET cCodRet = '00049';
			RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
					cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
		END IF;
		
		IF pSistemaCuenta NOT IN ('01', '06', '00') THEN
			LET cCodRet = '00048';
			RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
					cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuentaClienteTarjeta, pSistemaCuenta, pTipoBusqueda) INTO cCodRet;
		IF cCodRet::INTEGER <> 0 THEN
			RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
					cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
		END IF;
		
		IF pTipoBusqueda = 1 THEN
			LET cCuenta = pCuentaClienteTarjeta;
		ELIF pTipoBusqueda = 2 THEN
			LET cCliente = pCuentaClienteTarjeta;
		ELIF pTipoBusqueda = 3 THEN
			LET cTarjeta = pCuentaClienteTarjeta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF pSistemaCuenta = '01' THEN -- Captacion
			LET cSistemaCuenta = '01';
			
			FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentadebito(cCuenta, cCliente, cTarjeta, cEmpresa, pTipoBusqueda) 
					INTO cCodRetSp, cNumCuenta, cNumCliente, cNumTarjeta, cDescProducto, 
								cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus
					
					IF cCodRetSp::INTEGER = 1 THEN -- EL CLIENTE NO TIENE CUENTAS
						LET cCodRet = '00024';
						RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
								cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
					ELIF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN EJECUCION DE SP bdinteg:sp_consultactadebitocreditoconsultacuentacredito';
					END IF;
					
					-- Consulta del numero de producto
					SET ISOLATION TO DIRTY READ;
					SELECT producto
					INTO cNumProducto
					FROM bdicheq:sc_producto
					WHERE nombre = TRIM(cDescProducto);
					
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus WITH RESUME;
							LET iRecuperacion = iRecuperacion + 1;
						ELSE
							EXIT FOREACH;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
					
			END FOREACH;
			
			IF pRegistros = 0 AND iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
			ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
			END IF;
		
		ELIF pSistemaCuenta = '06' THEN -- Credito
			LET cSistemaCuenta = '06';
			
			FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentacredito(cCuenta, cCliente, cTarjeta, cEmpresa, pTipoBusqueda) 
					INTO cCodRetSp, cNumCuenta, cNumCliente, cNumTarjeta, cDescProducto, 
								cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus
					
					IF cCodRetSp::INTEGER = 1 THEN -- EL CLIENTE NO TIENE CUENTAS
						LET cCodRet = '00024';
						RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
								cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
					ELIF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN EJECUCION DE SP bdinteg:sp_consultactadebitocreditoconsultacuentacredito';
					END IF;
					
					SET ISOLATION TO DIRTY READ;
					SELECT num_producto
					INTO cNumProducto
					FROM bdicred:sd_definicion
					WHERE nombre_prod = TRIM(cDescProducto);
					
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus WITH RESUME;
							LET iRecuperacion = iRecuperacion + 1;
						ELSE
							EXIT FOREACH;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
					
			END FOREACH;
			
			IF pRegistros = 0 AND iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
			ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
			END IF;
		
		ELIF pSistemaCuenta = '00' THEN -- Credito
			LET cSistemaCuenta = '01';
			FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentadebito(cCuenta, cCliente, cTarjeta, cEmpresa, pTipoBusqueda) 
					INTO cCodRetSp, cNumCuenta, cNumCliente, cNumTarjeta, cDescProducto, 
								cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus
					
					IF cCodRetSp::INTEGER = 1 THEN -- EL CLIENTE NO TIENE CUENTAS
						EXIT FOREACH;
					ELIF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN EJECUCION DE SP bdinteg:sp_consultactadebitocreditoconsultacuentacredito';
					END IF;
					
					-- Consulta del numero de producto
					SET ISOLATION TO DIRTY READ;
					SELECT producto
					INTO cNumProducto
					FROM bdicheq:sc_producto
					WHERE nombre = TRIM(cDescProducto);
					
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus WITH RESUME;
							LET iRecuperacion = iRecuperacion + 1;
							LET iNoRegistros = iNoRegistros + 1;
						ELSE
							EXIT FOREACH;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
					
			END FOREACH;
			
			LET cSistemaCuenta = '06';
			FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultacuentacredito(cCuenta, cCliente, cTarjeta, cEmpresa, pTipoBusqueda) 
					INTO cCodRetSp, cNumCuenta, cNumCliente, cNumTarjeta, cDescProducto, 
								cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus
					
					IF cCodRetSp::INTEGER = 1 THEN -- EL CLIENTE NO TIENE CUENTAS
						EXIT FOREACH;
					ELIF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN EJECUCION DE SP bdinteg:sp_consultactadebitocreditoconsultacuentacredito';
					END IF;
					
					SET ISOLATION TO DIRTY READ;
					SELECT num_producto
					INTO cNumProducto
					FROM bdicred:sd_definicion
					WHERE nombre_prod = TRIM(cDescProducto);
					
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
									cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus WITH RESUME;
							LET iRecuperacion = iRecuperacion + 1;
							LET iNoRegistros = iNoRegistros + 1;
						ELSE
							EXIT FOREACH;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
					
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
						cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cNumCuenta, cSistemaCuenta, cNumCliente, cNumTarjeta, cNumProducto, cDescProducto, 
						cNombre1, cNombre2, cApellidoPaterno, cApellidoMaterno, cStatus;
			END IF;		
		
		END IF
	
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/01/2014',
'DESCIPCION: Consulta las cuentas de debito y credito relacionadas a un cliente para sus historicos, los tipos de busqueda son:',
'1 = Cuenta; 2 = Cliente; 3 = Numero de tarjeta',
'BD: dbicnweb';

CREATE PROCEDURE "informix".sp_consultadetalleenviodinya(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumeroControl CHAR(12))
	RETURNING CHAR(5) AS codret,
			CHAR(12) AS num_control,
			DATE AS fecha_envio,
			CHAR(8) AS hora_envio,
			CHAR(4) AS sucursal_origen,
			CHAR(26) AS nombre1_remitente,
			CHAR(26) AS nombre2_remitente,
			CHAR(26) AS apaterno_remitente,
			CHAR(26) AS amaterno_remitente,
			CHAR(20) AS telefono_remitente,
			MONEY(16,2) AS importe_eviado,
			CHAR(16) AS folio_sucursal_envio,
			DATE AS fecha_pago,
			CHAR(8) AS hora_pago,
			CHAR(8) AS sucursal_cobro_pago,
			CHAR(26) AS nombre1_beneficiario,
			CHAR(26) AS nombre2_beneficiario,
			CHAR(26) AS apaterno_beneficiario,
			CHAR(26) AS amaterno_beneficiario,
			CHAR(20) AS telefono_beneficiario,
			CHAR(20) AS estatus,
			CHAR(2) AS identificacion, 
			CHAR(25) AS num_identificacion,
			CHAR(3) AS num_convenio,
			CHAR(16) AS folio_sucursal_pago;
		
		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
		DEFINE cCodRetSp CHAR(5);
		DEFINE cNumControl CHAR(12);
		DEFINE dFechaEnvio DATE;
		DEFINE cHoraEnvio CHAR(8);
		DEFINE cSucursalOrigen CHAR(4);
		DEFINE cNombre1Remitente CHAR(26);
		DEFINE cNombre2Remitente CHAR(26);
		DEFINE cApellidoPaternoRemitente CHAR(26);
		DEFINE cApellidoMaternoRemitente CHAR(26);
		DEFINE cTelefonoRemitente CHAR(20);
		DEFINE mImporteEnviado MONEY(16,2);
		DEFINE cFolioSucursalEnvio CHAR(16);
		DEFINE dFechaPago DATE;
		DEFINE cHoraPago CHAR(8);
		DEFINE cSucursalCobroPago CHAR(8);
		DEFINE cNombre1Beneficiario CHAR(26);
		DEFINE cNombre2Beneficiario CHAR(26);
		DEFINE cApellidoPaternoBeneficiario CHAR(26);
		DEFINE cApellidoMaternoBeneficiario CHAR(26);
		DEFINE cTelefonoBeneficiario CHAR(20);
		DEFINE cEstatus CHAR(20);
		DEFINE cIdentificacion CHAR(2);
		DEFINE cNumIdentificacion CHAR(25);
		DEFINE cNumConvenio CHAR(3);
		DEFINE cSucursalPago CHAR(16);
		
		LET cCodRet = '00000';
		LET iSqlErr = 0;
		LET cCodRetSp = '';
		LET cNumControl = '';
		LET dFechaEnvio = NULL;
		LET cHoraEnvio = '';
		LET cSucursalOrigen = '';
		LET cNombre1Remitente = '';
		LET cNombre2Remitente = '';
		LET cApellidoPaternoRemitente = '';
		LET cApellidoMaternoRemitente = '';
		LET cTelefonoRemitente = '';
		LET mImporteEnviado= NULL;
		LET cFolioSucursalEnvio = '';
		LET dFechaPago = NULL;
		LET cHoraPago = '';
		LET cSucursalCobroPago = '';
		LET cNombre1Beneficiario = '';
		LET cNombre2Beneficiario = '';
		LET cApellidoPaternoBeneficiario = '';
		LET cApellidoMaternoBeneficiario = '';
		LET cTelefonoBeneficiario = '';
		LET cEstatus = '';
		LET cIdentificacion = '';
		LET cNumIdentificacion = '';
		LET cNumConvenio = '';
		LET cSucursalPago = '';
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumControl, dFechaEnvio, cHoraEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, 
					cApellidoPaternoRemitente, cApellidoMaternoRemitente, cTelefonoRemitente, mImporteEnviado, cFolioSucursalEnvio, 
					dFechaPago, cHoraPago, cSucursalCobroPago, cNombre1Beneficiario, cNombre2Beneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cTelefonoBeneficiario, cEstatus, cIdentificacion, cNumIdentificacion, cNumConvenio, 
					cSucursalPago;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetalleenviodinya.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pNumeroControl = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumControl, dFechaEnvio, cHoraEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, 
					cApellidoPaternoRemitente, cApellidoMaternoRemitente, cTelefonoRemitente, mImporteEnviado, cFolioSucursalEnvio, 
					dFechaPago, cHoraPago, cSucursalCobroPago, cNombre1Beneficiario, cNombre2Beneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cTelefonoBeneficiario, cEstatus, cIdentificacion, cNumIdentificacion, cNumConvenio, 
					cSucursalPago;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumControl, dFechaEnvio, cHoraEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, 
					cApellidoPaternoRemitente, cApellidoMaternoRemitente, cTelefonoRemitente, mImporteEnviado, cFolioSucursalEnvio, 
					dFechaPago, cHoraPago, cSucursalCobroPago, cNombre1Beneficiario, cNombre2Beneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cTelefonoBeneficiario, cEstatus, cIdentificacion, cNumIdentificacion, cNumConvenio, 
					cSucursalPago;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			EXECUTE PROCEDURE bdisac:"informix".sp_dinya_obtenerdetalleenvio(pNumeroControl)
				INTO cCodRetSp, cNumControl, dFechaEnvio, cHoraEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, 
					cApellidoPaternoRemitente, cApellidoMaternoRemitente, cTelefonoRemitente, mImporteEnviado, cFolioSucursalEnvio, 
					dFechaPago, cHoraPago, cSucursalCobroPago, cNombre1Beneficiario, cNombre2Beneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cTelefonoBeneficiario, cEstatus, cIdentificacion, cNumIdentificacion, cNumConvenio, 
					cSucursalPago;
					
			IF cNumControl = '' AND dFechaEnvio IS NULL THEN
				LET cCodRet = '00017';
			END IF;
			
			RETURN cCodRet, cNumControl, dFechaEnvio, cHoraEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, 
					cApellidoPaternoRemitente, cApellidoMaternoRemitente, cTelefonoRemitente, mImporteEnviado, cFolioSucursalEnvio, 
					dFechaPago, cHoraPago, cSucursalCobroPago, cNombre1Beneficiario, cNombre2Beneficiario, cApellidoPaternoBeneficiario, 
					cApellidoMaternoBeneficiario, cTelefonoBeneficiario, cEstatus, cIdentificacion, cNumIdentificacion, cNumConvenio, 
					cSucursalPago;
		
		END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2014',
'DESCRIPCION: Consulta los movimientos a detalle de DineroYa',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfbts(pUsuario  CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(80) AS mensaje,
			DATE AS fecha,
			CHAR(15) AS sucursal,
			CHAR(6) AS hora;

	DEFINE  iSqlErr		INTEGER;
	DEFINE  cCodRet		CHAR(5);
	DEFINE  cCodRetSp	CHAR(6);
	DEFINE  cMensaje	CHAR(80);
	DEFINE  dFecha		DATE;
	DEFINE  cSucursal	CHAR(5);
	DEFINE  cHora       CHAR(10);

	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cMensaje = '';
	LET cSucursal = '';
	LET dFecha = '';
	LET cHora = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensaje, dFecha, cSucursal, cHora;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfbts.out';
		--TRACE ON;
		
		IF 	pIdFuncion = '' OR pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensaje, dFecha, cSucursal, cHora;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensaje, dFecha, cSucursal, cHora;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisac:sp_consinfobtssif(pUsuario) INTO cCodRetSp, cMensaje, dFecha, cSucursal;
		
		SELECT TRIM(CURRENT::DATETIME HOUR TO SECOND||'')
		INTO cHora
		FROM bdinteg:si_fechas;
		LET cHora = REPLACE(cHora, ':', '');
		
		RETURN cCodRet, cMensaje, dFecha, cSucursal, cHora;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Fernando Martin Esparza Brenis',
'FECHA: 11/02/2013',
'DESCRIPCION: Consulta de datos para la transacciÃ³n de bts',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfocteretieneisrcap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCliente CHAR(20), pCuenta CHAR(20), pAnio SMALLINT, pTipo SMALLINT)
		RETURNING CHAR(5) AS codret,
                  CHAR(2) AS tipopersona,
                  CHAR(104) AS nombre,
                  CHAR(20) AS cuenta,
                  CHAR(13) AS rfc,
                  CHAR(20) AS curp,
                  DECIMAL(16,2) AS interesnomtotal,
                  DECIMAL(16,2) AS interesreal,
                  DECIMAL(16,2) AS perdida,
                  DECIMAL(16,2) AS interesnomexento,
                  DECIMAL(16,2) AS reteninteres,
                  CHAR(60) AS razonsocialretenedor,
                  CHAR(13) AS rfcretenedor,
                  CHAR(104) AS nombrereplegal,
                  CHAR(13) AS replegalisr,
                  CHAR(20) AS curpreplegal;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje CHAR(60);
	DEFINE cTipoPersona CHAR(2);
	DEFINE cNombre CHAR(104);
	DEFINE cCuenta CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE cCurp CHAR(20);
	DEFINE dInteresNomTotal DECIMAL(16, 2);
	DEFINE dInteresReal DECIMAL(16, 2);
	DEFINE dPerdida DECIMAL(16, 2);
	DEFINE dInteresNomExento DECIMAL(16, 2);
	DEFINE dRetenInteres DECIMAL(16, 2);
	DEFINE cRazonSocialRetenedor CHAR(60);
	DEFINE cRfcRetenedor CHAR(13);
	DEFINE cNombreRepLegal CHAR(104);
	DEFINE cRepLegalIsr CHAR(13);
	DEFINE cCurpRepLegal CHAR(20);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cMensaje = '';
	LET cTipoPersona = '';
	LET cNombre = '';
	LET cCuenta = '';
	LET cRfc = '';
	LET cCurp = '';
	LET dInteresNomTotal = NULL;
	LET dInteresReal = NULL;
	LET dPerdida = NULL;
	LET dInteresNomExento = NULL;
	LET dRetenInteres = NULL;
	LET cRazonSocialRetenedor = '';
	LET cRfcRetenedor = '';
	LET cNombreRepLegal = '';
	LET cRepLegalIsr = '';
	LET cCurpRepLegal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipoPersona, cNombre, cCuenta, cRfc, cCurp, dInteresNomTotal, dInteresReal, dPerdida, dInteresNomExento, 
			       dRetenInteres, cRazonSocialRetenedor, cRfcRetenedor, cNombreRepLegal, cRepLegalIsr, cCurpRepLegal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfocteretieneisrcap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR (pAnio IS NULL OR pAnio = 0)  OR pTipo IS NULL OR pCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipoPersona, cNombre, cCuenta, cRfc, cCurp, dInteresNomTotal, dInteresReal, dPerdida, dInteresNomExento, 
			       dRetenInteres, cRazonSocialRetenedor, cRfcRetenedor, cNombreRepLegal, cRepLegalIsr, cCurpRepLegal;
		END IF;
		
		IF pTipo NOT IN (1,2) THEN
			LET cCodRet = '00049';
			RETURN cCodRet, cTipoPersona, cNombre, cCuenta, cRfc, cCurp, dInteresNomTotal, dInteresReal, dPerdida, dInteresNomExento, 
			       dRetenInteres, cRazonSocialRetenedor, cRfcRetenedor, cNombreRepLegal, cRepLegalIsr, cCurpRepLegal;
		END IF
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		IF pTipo = 1 THEN
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		ELIF pTipo = 2 THEN
			IF pCuenta = '' THEN
				LET cCodRet = '00003';
			ELSE
				--EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '01', '1') INTO cCodRet;
				EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
			END IF;
		END IF;
		
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipoPersona, cNombre, cCuenta, cRfc, cCurp, dInteresNomTotal, dInteresReal, dPerdida, dInteresNomExento, 
			       dRetenInteres, cRazonSocialRetenedor, cRfcRetenedor, cNombreRepLegal, cRepLegalIsr, cCurpRepLegal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdicheq:"informix".sp_consultainfocteretieneisr (pCliente, pCuenta, pAnio, pTipo)
					INTO cCodRetSp, cMensaje, cTipoPersona, cNombre, cCuenta, cRfc, cCurp, dInteresNomTotal, dInteresReal, dPerdida, dInteresNomExento, 
						dRetenInteres, cRazonSocialRetenedor, cRfcRetenedor, cNombreRepLegal, cRepLegalIsr, cCurpRepLegal
		
			IF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 5 THEN -- EL CLIENTE NO TIENEN CUENTAS RETENIDAS PARA EL AÃO RECIBIDO
				LET cCodRet = '00233';
			ELIF cCodRetSp::INTEGER = 4 THEN -- El cliente no existe
				LET cCodRet = '00022';
			ELIF cCodRetSp::INTEGER = 3 THEN -- No existe informaciÃ³n para el representante legal
				LET cCodRet = '00234'; -- NO EXISTE INFORMACIÃN DE LA EMPRESA RETENEDORA
			ELIF cCodRetSp::INTEGER < 0 THEN -- No existe informaciÃ³n para el representante legal
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN EL AEJECUCION DEL SP bdicheq:sp_consultainfocteretieneisr';
			END IF;
			
			RETURN cCodRet, cTipoPersona, cNombre, cCuenta, cRfc, cCurp, dInteresNomTotal, dInteresReal, dPerdida, dInteresNomExento, 
			   dRetenInteres, cRazonSocialRetenedor, cRfcRetenedor, cNombreRepLegal, cRepLegalIsr, cCurpRepLegal WITH RESUME;
		
		END FOREACH;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 20/01/2014',
'DESCRIPCION: Procedimiento que consulta la informacion del cliente fisico o moral que cuente con retenciÃ³n del ISR',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarmvtosnipcte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumTarjeta CHAR(16), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		DATE AS fecha, 
		CHAR(9) AS hora, 
		CHAR(4) AS sucursal, 
		CHAR(8) AS empleado, 
		CHAR(45) AS nombre;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha DATE;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iCodRetorno INTEGER;
	
	-- VARIABLES DEL SP
	DEFINE cCodRetSp CHAR(5);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(9);
	DEFINE cSucursal CHAR(4);
	DEFINE cEmpleado CHAR(8);
	DEFINE cNombreEmpleado CHAR(45);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFecha = NULL;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iCodRetorno = 0;

	-- VARIABLES DEL SP
	LET cCodRetSp = '';
	LET cFecha = '';
	LET cHora = '';
	LET cSucursal = '';
	LET cEmpleado = '';
	LET cNombreEmpleado = '';
	LET cEmpresa = '001';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarmvtosnipcte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumTarjeta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
		END IF;
		
		-- VALIDACIÃN DEL PARAMETRO DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".spconsultarmvtosnip(cEmpresa, pNumTarjeta) 
			INTO cCodRetSp, cFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado
			
			LET iCodRetorno = cCodRetSp::INTEGER;
			
			IF iCodRetorno < 0 THEN
				RAISE EXCEPTION iCodRetorno, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:spconsultarmvtosnip';
			ELIF iCodRetorno = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
			ELIF iCodRetorno = 0 THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						LET dFecha = MDY(substr(cFecha, 4, 2), substr(cFecha, 1, 2), substr(cFecha, 7, 4));
						
						RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
					END IF;
				END IF;
				
				LET iRegistros = iRegistros + 1;
			END IF;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, dFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 14/02/2014',
'DESCRIPCION: Consulta los movimientos que se han realizado en el nip de las tarjetas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultartotalmvtosnipcte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumTarjeta CHAR(16))
	RETURNING CHAR(5) AS codret,
		INTEGER AS total_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	
	-- VARIABLES DEL SP
	DEFINE cCodRetSp CHAR(5);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(9);
	DEFINE cSucursal CHAR(4);
	DEFINE cEmpleado CHAR(8);
	DEFINE cNombreEmpleado CHAR(45);
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegistros = 0;

	-- VARIABLES DEL SP
	LET cCodRetSp = '';
	LET cFecha = '';
	LET cHora = '';
	LET cSucursal = '';
	LET cEmpleado = '';
	LET cNombreEmpleado = '';
	LET cEmpresa = '001';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultartotalmvtosnipcte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumTarjeta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".spconsultarmvtosnip(cEmpresa, pNumTarjeta) 
			INTO cCodRetSp, cFecha, cHora, cSucursal, cEmpleado, cNombreEmpleado
			
			LET iRegistros = iRegistros + 1;
			
		END FOREACH;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iRegistros;
		ELSE
			RETURN cCodRet, iRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 14/02/2014',
'DESCRIPCION: Consulta el total de los movimientos que se han realizado en el nip de las tarjetas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatotalenviospagodinya(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(3),
					pImporte1 CHAR(16), pImporte2 CHAR (16), pSucursalOrigen CHAR(4), pNombre1Remitente CHAR(26),
					pNombre2Remitente CHAR(26), pApellido1Remitente CHAR(26), pApellido2Remitente CHAR(26), pFechaEnvio1 DATE,
					pFechaEnvio2 DATE, pNombre1Beneficiario CHAR(26), pNombre2Beneneficiario CHAR(26), 
					pApellido1Beneneficiario CHAR(26), pApellido2Beneneficiario CHAR(26))
	RETURNING CHAR(5) AS codret,
				INTEGER AS total_registros;
				
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	-- VARIABLES DEL SP PRODUCTIVO
	DEFINE cNoControl CHAR(12);
	DEFINE dFechaEnvio DATE;
	DEFINE cSucursalOrigen CHAR(4);
	DEFINE cNombre1Remitente CHAR(26);
	DEFINE cNombre2Remitente CHAR(26);
	DEFINE cApellido1Remitente CHAR(26);
	DEFINE cApellido2Remitente CHAR(26);
	DEFINE mImporteEnviado MONEY (16,2);
	DEFINE cStatus CHAR(20);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	-- VARIABLES DEL SP PRODUCTIVO
	LET cNoControl = '';
	LET dFechaEnvio = NULL;
	LET cSucursalOrigen = '';
	LET cNombre1Remitente = '';
	LET cNombre2Remitente = '';
	LET cApellido1Remitente = '';
	LET cApellido2Remitente = '';
	LET mImporteEnviado = NULL;
	LET cStatus = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotalenviospagodinya.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_dinya_obtenerenviospagos(pConvenio, pImporte1, pImporte2, pSucursalOrigen,
													pNombre1Remitente, pNombre2Remitente, pApellido1Remitente, pApellido2Remitente,
													pFechaEnvio1, pFechaEnvio2,
													pNombre1Beneficiario, pNombre2Beneneficiario, pApellido1Beneneficiario, pApellido2Beneneficiario)
			INTO cCodRetSp, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP PRODUCTIVO sp_dinya_obtenerenviospagos';
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
				
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/02/2014',
'DESCRIPCION: Consulta el total de los envios de ordenes de pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtieneparametrobts(pUsuario CHAR(8), pIdFuncion CHAR(10), pParametro INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_parametro;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValorParametro CHAR(100);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cValorParametro = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorParametro;
		END EXCEPTION;
        
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtieneparametrobts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParametro;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorParametro;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneparametro(pParametro) INTO cCodRetSp, cValorParametro;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisac:sp_obtieneparametro';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet, cValorParametro;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2014',
'DESCRIPCION: Consulta parametros en la base bdisac',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validareferenciabts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumeroBTS CHAR(11))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje CHAR(80);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cMensaje = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validareferenciabts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumeroBTS = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisac:"informix".sp_validabts(pNumeroBTS) INTO cCodRetSp, cMensaje;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisac:sp_validabts';
		ELIF cCodRetSp::INTEGER = 1 THEN -- DIGITO VERIFICADOR INVALIDO
			LET cCodRet = '00240';
		ELIF cCodRetSp::INTEGER = 2 THEN -- REFERENCIA DIFERENTE A 11 DIGITOS
			LET cCodRet = '00241';
		ELIF cCodRetSp::INTEGER = 3 THEN -- EL NUMERO DE REFERENCIA CONTIENE UNA LETRA
			LET cCodRet = '00242';
		END IF;
	
		RETURN cCodRet;
	
	END;
		
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde', 
'FECHA: 10/02/2014', 
'DESCRIPCION: Valida si el digito verificador capturado en la consulta de pagos de remesas BTS es correcto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_encabezadoreportesemanalsac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(5))
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(100) AS encabezado1,
	CHAR(100) AS encabezado2,
	CHAR(100) AS encabezado3,
	CHAR(100) AS encabezado4;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEncabezado1 CHAR(100);
	DEFINE cEncabezado2 CHAR(100);
	DEFINE cEncabezado3 CHAR(100);
	DEFINE cEncabezado4 CHAR(100);
	DEFINE cValor1 CHAR(5);
	DEFINE cValor2 CHAR(5);
	DEFINE cValor3 CHAR(5);
	DEFINE cValor4 CHAR(5);
	DEFINE iNumRows  INTEGER;
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cDireccionEmpresa CHAR(100);

	LET cCodRet = '00000';
	LET cEncabezado1 = '';
	LET iSqlErr = 0;
	LET cEncabezado1 = '';
	LET cEncabezado2 = '';
	LET cEncabezado3 = '';
	LET cEncabezado4 = '';
	LET cValor1  = '';
	LET cValor2  = '';
	LET cValor3  = '';
	LET cValor4  = '';
	LET iNumRows = 0;
	LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);	LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);	LET cDireccionEmpresa = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_encabezadoreportesemanalsac_TEMP.out';
		--TRACE ON;
		
		IF 	pUsuario = '' OR pIdFuncion = '' OR pConvenio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF	cCodRet <> '00000' THEN
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF;
		
		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		IF iNumRows <> 0 THEN
			SELECT nomconvenio, departamento, ciudad, 		estado, 		direccionempresa
			INTO cEncabezado1, 	cEncabezado2, cEncabezado3, cEncabezado4, cDireccionEmpresa
			FROM bdisac:sac_convenios
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;

			SELECT nombreciudad 
			INTO cEncabezado3
			FROM bdinteg:si_catciudades
			WHERE numerociudad = cEncabezado3;
			
			SELECT nombre 
			INTO cEncabezado4
			FROM bdinteg:si_estados
			WHERE estado = cEncabezado4;
			RETURN cCodRet, cEncabezado1, cEncabezado2, TRIM(cDireccionEmpresa)||', '||(cEncabezado3), cEncabezado4;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF ;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando',
'DescripciÃ³n: SP para los encabezados de los Reportes semanales',
'Fecha: 12/12/2013',
'DB: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteconciliacionconveniosucursal(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno,
	CHAR(4) AS idsucursal,
	INTEGER AS numpagos, 
	CHAR(40) AS nomconvenio, 
	MONEY(16,2) AS importepago, 
	MONEY(16,2) AS importecomisionconvenio,
	MONEY(16,2) AS ivacomisionconvenio, 
	MONEY(16,2) AS importecomisioncte,
	MONEY(16,2) AS iva_comisioncte,
	INTEGER AS flagconfirmacioncentral,
	INTEGER AS flagconfirmacionsucursal;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cIdSucursal CHAR(5);
	DEFINE cNumPagos INTEGER; 
	DEFINE cNomconvenio CHAR(40); 
	DEFINE mImportePago MONEY(16,2); 
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cIdSucursal = '';
	LET cNumPagos = 0;
	LET cNomconvenio = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio = 0;
	LET mImporteComisionCte = 0;
	LET mIvaComisionCte = 0;
	LET iFlagConfirmacionCentral = 0;
	LET iFlagConfirmacionSucursal = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodret = iSqlErr;
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporteconciliacionconveniosucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_sacreporteconciliacionconveniosucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal

			IF 	NVL(cIdSucursal, '') = '' AND 
				NVL(cNumPagos, '') = '' AND 
				NVL(cNomconvenio, '')  = '' AND 
				NVL(mImportePago, '') = ''  AND 
				NVL(mImporteComisionConvenio, '') = '' AND
				NVL(mIvaComisionConvenio, '') = '' AND 
				NVL(mImporteComisionCte, '') = '' AND 
				NVL(mIvaComisionCte,'') = '' AND 
				NVL(iFlagConfirmacionCentral,'') = '' AND 
				NVL(iFlagConfirmacionSucursal,'') = '' THEN
				
				LET cCodRet = '00017';
				RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
			ELSE
				IF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte,
					iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
				ELSE
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio,
							mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		 IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR:Esparza Brenis Fernando Martin",
"FECHA: 12/12/2013",
"DESCRIPCION: SP para el reporte de conciliaciÃ³n por convenios",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_reporteremesasnoconciliadassac( pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaInicio DATE, pFechaFin DATE,pConvenio CHAR(5),pTipo CHAR(1), 
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING
	CHAR(5)         AS RetCodigoRet,
	DATE            AS RetFecha,
	INTEGER         AS RetServicios,
	INTEGER         AS RetCheques,
	INTEGER         AS RetWUCaja,
	INTEGER         AS RetAbonoCuenta,
	CHAR(16)    	AS RetDiferencia;
		
	--DEFINICION DE VARIABLES
	DEFINE iSqlError			INTEGER;
	DEFINE cCodRet				CHAR(5);
	DEFINE cCodRetsp			CHAR(5);
	DEFINE dFechaIni			DATE;
	DEFINE iCantidadPagosServ	INTEGER;
	DEFINE iCantidadPagos		INTEGER;
	DEFINE iCantidadPagosREVI   INTEGER;
	DEFINE RetAbonoCuenta		INTEGER;
	DEFINE cDiferencia			CHAR(16);
	DEFINE iRegistros			INTEGER;
	DEFINE iRecuperacion		INTEGER;
	DEFINE iNoRegs				INTEGER;
	DEFINE iNumDias SMALLINT;
	DEFINE iDiasParametrizados SMALLINT;
	
	--INICIALIZAMOS LAS VARIABLES
	LET iSqlError = 0;
	LET cCodRet = '00000';
	LET cCodRetsp = '';
	LET dFechaIni = CURRENT;
	LET iCantidadPagosServ = 0;
	LET iCantidadPagos = 0;
	LET iCantidadPagosREVI  = 0;
	LET RetAbonoCuenta = 0;
	LET cDiferencia ="Sin Diferencia";
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET iNumDias = 0;
	LET iDiasParametrizados = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlError
		IF iSqlError <> 0 THEN
			LET cCodRet = iSqlError;
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
		END IF;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion  = '' OR  pFechaInicio  = '' OR  pFechaFin  = '' OR  pConvenio  = '' OR  pTipo  = '' OR  pRegistros  = '' OR  pRecuperacion = '' THEN
			LET cCodRet = '00003'; --Parametros vacios
			RETURN cCodRet,'','','','','','';
		END IF;
		
		--SET DEBUG FILE TO "/tmp/mfinis/bdicnweb/sp_reporteremesasnoconciliadassac.out";
		--TRACE ON;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
		END IF;
		
		LET iNumDias = pFechaFin - pFechaInicio;
		
		-- Conulta de dias parametrizados
		SELECT valor
		INTO iDiasParametrizados
		FROM bdisac:sac_param WHERE cod_param = 87019;
		
		IF iNumDias >= iDiasParametrizados THEN
			LET cCodRet = '00232';
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia;
		ELSE	
			IF pTipo = 'P' THEN -- If tipo o algo asÃ­
				-- Este es un elif
				IF pConvenio = '07004' THEN
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadasbts(pFechaInicio, pFechaFin, pUsuario)
						INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, iCantidadPagosREVI, RetAbonoCuenta, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','','';
						END IF;
					END FOREACH;
				ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN	
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadaswu(pFechaInicio, pFechaFin, pUsuario, pConvenio)
						INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, iCantidadPagosREVI, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','','';
						END IF;
					END FOREACH;			
				END IF; -- Del IF pConvenio ... (108)
			ELIF pTipo = 'R' THEN
				IF pConvenio = '07004' THEN
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadasbtsrev(pFechaInicio, pFechaFin, pUsuario)
						INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, iCantidadPagosREVI, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','',''; 
						END IF;
					END FOREACH;
				ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadaswurev(pFechaInicio, pFechaFin, pUsuario, pConvenio)
					INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','','';
						END IF;
					END FOREACH;
				END IF;
				IF iNoRegs = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
				ELIF iNoRegs = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet,'','','','','','';
				END IF;
			END IF; -- else del tipo o algo asÃ­
		END IF;			
	END; 
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'DescripciÃ³n: SP para los Reportes de las remesas no conciliadas de SAC',
'Fecha: 2013/12/12',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_buscaxrfc2(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pIdBusqueda INT, 
										pRfc CHAR(15), pRegistros INT, pRecuperaciON INT, pIp CHAR(15), 
										pMac CHAR(12))
	RETURNING CHAR(5)  AS codret,
			  CHAR(20) AS numerocliente,
			  CHAR(13) AS rfc,
			  CHAR(1)  AS nivelcliente,
			  CHAR(26) AS nombre1,
			  CHAR(26) AS nombre2,
			  CHAR(26) AS ap_paterno,
			  CHAR(26) AS ap_materno,
			  CHAR(60) AS razon_social,
			  CHAR(2)  AS tipo_persona,
			  CHAR(1)  AS tipo_cliente,
			  INT      AS status_busqueda,
			  CHAR(20) AS desc_status_busqueda,
			  INT      AS id_encontrado
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cNumCte CHAR(20);
	DEFINE cNumCta CHAR(20);
	DEFINE cNumTar CHAR(20);
	-- Variables de retorno
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE cNivelCliente CHAR(1);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRazonSocial CHAR(60);
	DEFINE iNoRegistros INT;
	DEFINE cEtiqueta CHAR(20);
	DEFINE iStatusBusqueda SMALLINT;
	DEFINE cTipoPersona CHAR(2);
	DEFINE cTipoCliente CHAR(1);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iRegsProc INT;
	DEFINE iIdGenerado INT;
	-- -- -- --
	DEFINE cDescTipoCliente CHAR(40);
	DEFINE dFechaNacimiento DATE;
	DEFINE cSexo CHAR(1);
	DEFINE cDescTipoPersona CHAR(20);
	DEFINE dFechaAlta DATE;
	DEFINE cCveSucursalAltaCte CHAR(4);
	DEFINE cPlazaAlta CHAR(3);
	DEFINE cCveSitEspecial CHAR(5);
	DEFINE cDescSitEspecial CHAR(75);
	DEFINE iSecuencia INT;
	DEFINE cCalle CHAR(40);
	DEFINE cNoExt CHAR(10);
	DEFINE cNoINT CHAR(10);
	DEFINE cDepto CHAR(6);
	DEFINE cColonia CHAR(60);
	DEFINE cDelMun CHAR(60);
	DEFINE cCiudad CHAR(60);
	DEFINE cEstado CHAR(30);
	DEFINE cPais CHAR(20);
	DEFINE cCodPostal CHAR(5);
	DEFINE cTelParticular CHAR(13);
	DEFINE cTelCelular CHAR(13);
	DEFINE cTelOficina CHAR(13);
	DEFINE cExt CHAR(5);
	DEFINE iNivelCliente INT;
	DEFINE iNivel INT;
	DEFINE cDescNivelCliente CHAR(60);
	DEFINE cTipoCuenta CHAR(2);
	DEFINE cTipoBusquedaPersona CHAR(1);
	DEFINE cNoCteRfcAlterno CHAR(20);
	DEFINE cNoCteRfc CHAR(20);
	DEFINE inRfcAlterno SMALLINT;
	DEFINE cBrfc		CHAR(13);
	DEFINE iCuentac		INT;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cNumeroCliente = '';
	LET cRfc = '';
	LET cNivelCliente = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRazonSocial = '';
	LET iNoRegistros = 0;
	LET cEtiqueta = 'NO LOCALIZADO';
	LET iStatusBusqueda = 0; -- 0. No encontrado, 1. Encontrado, 2. Homonimo
	LET cTipoPersona = '';
	LET cTipoCliente = '';
	LET cCodRetSp = '';
	LET iRegsProc = 0;
	LET iIdGenerado = 0;
	LET cNumCte = '';
	LET cNumCta = '';
	LET cNumTar = '';
	LET cNoCteRfcAlterno = '';
	LET cNoCteRfc = '';
	LET cDescTipoCliente = '';
	LET dFechaNacimiento = NULL;
	LET cSexo = '';
	LET cDescTipoPersona = '';
	LET dFechaAlta = NULL;
	LET cCveSucursalAltaCte = '';
	LET cPlazaAlta = '';
	LET cCveSitEspecial = '';
	LET cDescSitEspecial = '';
	LET iSecuencia = 0;
	LET cCalle = '';
	LET cNoExt = '';
	LET cNoINT = '';
	LET cDepto = '';
	LET cColonia = '';
	LET cDelMun = '';
	LET cCiudad = '';
	LET cEstado = '';
	LET cPais = '';
	LET cCodPostal = '';
	LET cTelParticular = '';
	LET cTelCelular = '';
	LET cTelOficina = '';
	LET cExt = '';
	LET iNivelCliente = 0;
	LET iNivel = 0;
	LET cDescNivelCliente = '';
	LET cTipoCuenta = '';
	LET inRfcAlterno = 0;
	LET cBrfc='';
	LET iCuentac=0;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente,
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
		END EXCEPTION;
		-- Se busca al cliente primero por el rfc alterno
		LET iCuentac=LENGTH(pRfc);
		IF iCuentac=10 THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} first 2 rfc_alterno
				INTO cBrfc
				FROM bdinteg:si_cliente
				WHERE rfc_alterno [1,10] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			IF iNoRegistros = 0 THEN
				LET inRfcAlterno = 0;
				SET ISOLATION TO DIRTY READ;
				FOREACH
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} first 2 rfc
					INTO cBrfc
					FROM bdinteg:si_cliente
					WHERE rfc [1,10] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			ELSE
				LET inRfcAlterno = 1;
			END IF;
		ELSE
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} first 2 rfc_alterno
				INTO cBrfc
				FROM bdinteg:si_cliente
				WHERE rfc_alterno [1,13] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			IF iNoRegistros = 0 THEN
				LET inRfcAlterno = 0;
				SET ISOLATION TO DIRTY READ;
				FOREACH
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} first 2 rfc
					INTO cBrfc
					FROM bdinteg:si_cliente
					WHERE rfc [1,13] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			ELSE
				LET inRfcAlterno = 1;
			END IF;
		END IF;

		IF iNoRegistros = 0 THEN
			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio,cApPaterno, 
															cApMaterno, cNombre1, cNombre2, cRazonSocial, 
															pRfc, cNumCte, cNumCta, cNumTar, 
															cTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
															pMac)
			INTO cCodRetSp, iRegsProc;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumCte, pRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			LET cCodRet = '00000';
			LET cNivelCliente = '9';
			RETURN cCodRet, cNumCte, pRfc, cNivelCliente, 
					cNombre1, cNombre2, cApPaterno, cApMaterno, 
					cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
					cEtiqueta, 0;
		ELIF iNoRegistros > 1 THEN
			LET iNivelCliente = 9; -- Falta buscar el nivel del cliente
			LET iStatusBusqueda = 2;
			LET cNivelCliente = iNivelCliente;
			LET cEtiqueta = 'HOMONIMO';
			LET iNoRegistros = 0;
			IF inRfcAlterno = 1 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, cApPaterno, 
																	cApMaterno, cNombre1, cNombre2, cRazonSocial, 
																	pRfc, cNumeroCliente, cNumCta, cNumTar, 
																	cTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
																	pMac)
					INTO cCodRetSp, iRegsProc;
					IF cCodRetSp <> '00000' THEN
						RETURN cCodRetSp, cNumCte, pRfc, cNivelCliente, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cEtiqueta, 0;
					END IF;

					RETURN cCodRet, cNumeroCliente, pRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, 0;
			ELIF inRfcAlterno = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio,cApPaterno, 
																	cApMaterno, cNombre1, cNombre2, cRazonSocial, 
																	pRfc, cNumeroCliente, cNumCta, cNumTar, 
																	cTipoCuenta,cTipoCliente, iStatusBusqueda, pIp, 
																	pMac)
					INTO cCodRetSp, iRegsProc;
					IF cCodRetSp <> '00000' THEN
						RETURN cCodRetSp, cNumCte, pRfc, cNivelCliente, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cEtiqueta, 0;
					END IF;
					RETURN cCodRet, cNumeroCliente, pRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, 0;
			END IF;
		ELIF iNoRegistros = 1 THEN
			IF inRfcAlterno = 1 THEN
				IF iCuentac=10 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} numcte, rfc_alterno, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente 
					WHERE rfc_alterno [1,10] = pRfc;
				ELSE
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} numcte, rfc_alterno, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente 
					WHERE rfc_alterno [1,13] = pRfc;
				END IF;
			ELIF inRfcAlterno = 0 THEN
				IF iCuentac=10 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} numcte, rfc, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente WHERE rfc [1,10] = pRfc;
				ELSE
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} numcte, rfc, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente WHERE rfc [1,13] = pRfc;
				END IF;
			END IF;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_valida_nivelacceso_funcionalidad(pUsuario, pIdFunciON) INTO cCodRet, iNivel;
			IF iNivel=0 THEN
				LET cCodRet = '00076';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
			ELSE
				SELECT NVL(nivel,0) INTO iNivelCliente FROM bdinteg:"informix".si_cliente_nivel WHERE numcte=cNumeroCliente;
				IF  iNivelCliente < iNivel THEN
					LET cCodRet = '00075';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
				END IF;
			END IF;
			
			LET iNivelCliente = 9; -- Falta buscar el nivel del cliente
			LET iStatusBusqueda = 1;
			LET cNivelCliente = iNivelCliente;
			LET cEtiqueta = 'LOCALIZADO';
			-- Se almacena la busqueda
			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, cApPaterno, 
															cApMaterno, cNombre1, cNombre2, cRazonSocial, 
															cRfc, cNumeroCliente, cNumCta, cNumTar, 
															cTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
															pMac)
			INTO cCodRetSp, iIdGenerado;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			-- Se almacena al cliente encontrado
			EXECUTE PROCEDURE sp_sw_ro_bitacoracteenc(pUsuario, pIdBusqueda, pIdOficio, iIdGenerado, 
														cNumeroCliente, cApPaterno, cApMaterno, cNombre1, 
														cNombre2, cRazonSocial, cRfc, pIp, 
														pMac)
			INTO cCodRetSp, iRegsProc;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			-- Se buscan las cuentas y participaciones del cliente
			IF cTipoCliente = '1' THEN
				EXECUTE PROCEDURE sp_sw_ro_consctascteparticipacion(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, 
																	iRegsProc, cNumeroCliente, 10, pIp, 
																	pMac) 
				INTO cCodRetSp;
				IF cCodRetSp <> '00000' THEN
					RETURN cCodRetSp, 'En 1 part', cRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, iRegsProc;
				END IF;
			ELIF cTipoCliente = '2' THEN
				EXECUTE PROCEDURE sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, iRegsProc, 
																cNumeroCliente, pIp, pMac) 
				INTO cCodRetSp;
				IF cCodRetSp <> '00000' THEN
					RETURN cCodRetSp, 'en 2 part', cRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, iRegsProc;
				END IF;
			END IF;
			RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
					cNombre1, cNombre2, cApPaterno, cApMaterno, 
					cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
					cEtiqueta, iRegsProc;
		END IF;
	END
END PROCEDURE;