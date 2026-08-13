CREATE PROCEDURE "informix".sp_sw_ro_bloqueactacap(pIdUsuario CHAR(8), 
										pIdFuncion CHAR(8), 
										pIdOficio INT, 
										pIdBusqueda INT, 
										pIdCliente INT,
										pNumCliente CHAR(20), 
										pCuenta CHAR(20), 
										pMonto money(14,2),
										pFechaBloqueo CHAR(10), 
										pCodBloqueo CHAR(2), 
										pOpcBloq INT, 
										pAreaSolic CHAR(2), 
										pTipoBloq CHAR(2), 
										pTipoBloqueo INT, 
										pIp CHAR(16), 
										pMac CHAR(12), 
										pOficios CHAR(1))
	RETURNING CHAR(5) AS codret,
		CHAR(16) AS folio_operacion
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodArea CHAR(2);
	DEFINE cCodTipoBloq CHAR(2);
	DEFINE cCodRet CHAR(5);
	DEFINE cClave CHAR(5);
	DEFINE cDescRet CHAR(10);
	DEFINE iSqlErr INT;
	DEFINE cCodRetMask CHAR(5);
	DEFINE cFolioMask CHAR(10);
	DEFINE iLenCodRet INT;
	DEFINE iLenFolio INT;
	DEFINE cSistemaCta CHAR(2);
	DEFINE cDescripcionMotivo CHAR(35);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iRegsAfectados INT;
	DEFINE pFechaBloqueo1 date;
	
	LET cEmpresa = '001';
	LET cSistemaCta = '01';
	LET cCodArea = '';
	LET cCodTipoBloq = '';
	LET cCodRet = '00000';
	LET cClave = '';
	LET cDescRet = '0000000000000000';
	LET iSqlErr = 0;
	LET cCodRetMask = '00000';
	LET iLenCodRet = 0;
	LET iLenFolio = 0;
	LET cFolioMask = '0000000000000000';
	LET cDescripcionMotivo = '';
	LET cCodRetSp = '';
	LET iRegsAfectados = 0;
	LET pFechaBloqueo1 = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cDescRet;
			END IF;
		END EXCEPTION;


		IF pIdUsuario = ''OR 
				pIdFuncion = '' 
				or pNumCliente = '' 
				or pCuenta = '' 
				or pIdOficio = '' 
				or pIdBusqueda = ''
				or pIdCliente = '' 
				or pOficios = '' 
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cDescRet;
		END IF;
		--VALIDACION DE ACCESO A ALA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(pIdUsuario, pIdFuncion, pNumCliente, cSistemaCta,'2')
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescRet;
		END IF;
		-- COCDIGO DE AREA DE BLOQUEO
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		SELECT codigo 
		INTO cCodArea
		FROM bdicheq:sc_areabloqueo 
		WHERE clave = pAreaSolic;	
		--CODIGO TIPO DE BLOQUEO(MOTIVO)
		
		SELECT codigo, descripcion
		INTO cCodTipoBloq, cDescripcionMotivo
		FROM bdicheq:sc_tipobloqueo
		WHERE clave = pTipoBloq;
		
		if pFechaBloqueo <> '' then
			let pFechaBloqueo1 = EXTEND(MDY(SUBSTR(pFechaBloqueo,1,2),SUBSTR(pFechaBloqueo,4,2),SUBSTR(pFechaBloqueo,7,4)), YEAR TO SECOND);
		end if;
		--EJECUCION DE PROCEDIMEINTOS
		EXECUTE PROCEDURE bdicheq:bloqueo_cta(cEmpresa, 
								pCuenta, 
								pMonto, 
								pCodBloqueo, 
								pOpcBloq, 
								pFechaBloqueo1, 
								pIdUsuario, 
								cClave,
								pAreaSolic, 
								cCodArea,
								pTipoBloq, 
								cCodTipoBloq)
			INTO cCodRet, cDescRet;
		--LLENADO DE LA RESPUESTA A 5 CEROS
		LET iLenCodRet = LENGTH(cCodRet);
		LET cCodRet = SUBSTR(cCodRetMask, 0, (5-iLenCodRet)) || cCodRet;
		IF cCodRet = '00000' THEN
			--GENERAMOS FOLIO
			INSERT INTO sw_ro_foliador(folio_operacion) VALUES(0);
			LET cDescRet = dbinfo('bigserial');
			LET iLenFolio = LENGTH(cDescRet);
			LET cDescRet = SUBSTR(cFolioMask, 0, (LENGTH(cFolioMask) - iLenFolio)) || cDescRet;
			IF pOficios = '1' THEN
				EXECUTE PROCEDURE sp_sw_ro_guardabloqueoctas(pIdUsuario, 
															pIdFuncion, 
															pIdOficio, 
															pIdBusqueda, 
															pIdCliente, 
															pTipoBloqueo,
															pNumCliente, 
															cSistemaCta, 
															pCuenta, 
															pMonto, 
															cCodTipoBloq,
															cDescripcionMotivo, 
															cDescRet, 
															pIp, 
															pMac) 
				INTO cCodRetSp, iRegsAfectados;
				IF cCodRet <> '00000'OR iRegsAfectados > 1 THEN
					RETURN cCodRetSp, iRegsAfectados;
				END IF;
			END IF;
			RETURN cCodRet, cDescRet;
		END IF;
		--VALIDACION DEL CODIGO RETORNO
		IF cCodRet = '00110' THEN
			--FALTAN PARAMETROS DE ENTRADA
			LET cCodRet = '00003';
			RETURN cCodRet, cDescRet;
		END IF;
		IF cCodRet = '00162' THEN
			--SALDO INSUFICIENTE PARA CONGELAR
			LET cCodRet = '00101';
			RETURN cCodRet, cDescRet;
		END IF;
		IF cCodRet = '00163' THEN
			--SALDO A DESBLOQUEAR
			LET cCodRet = '00102';
			RETURN cCodRet, cDescRet;
		END IF;
		IF cCodRet = '00100' THEN
			--LA CUENTA NO EXISTE
			LET cCodRet = '00009';
			RETURN cCodRet, cDescRet;
		END IF;
		IF cCodRet = '00302' THEN
			--VERIFICA SI AL CUENTA ESTA ACTIVA Y NO ESTA BLOQUEADA
			LET cCodRet = '00103';
			RETURN cCodRet, cDescRet;
		END IF;
		IF cCodRet = '00200' THEN
			--VERIFICA QUE LA CUENTA NO ESTE CANCELADA
			LET cCodRet = '00104';
			RETURN cCodRet, cDescRet;
		END IF;
		IF cCodRet = '00303' THEN
			--VERIFICA QUE LA CUENTA NO HAYA SIDO BLOQUEADA PREVIAMENTE
			LET cCodRet = '00173';
			RETURN cCodRet, cDescRet;
		END IF;
	END
END PROCEDURE;