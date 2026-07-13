CREATE PROCEDURE "informix".sp_sw_ro_buscaxnombre(pIdUsuario CHAR(8), pIdFunciON CHAR(10), pIdBusqueda INT, pIdOficio INT, 
										pTipoBusquedaPersona CHAR(1), pNombre1 CHAR(26), pNombre2 CHAR(26), pApPaterno CHAR(26), 
								pApMaterno CHAR(26), pRazonSocial CHAR(60), pFechaNacimiento DATE, pTipoCuenta CHAR(2), pIp CHAR(15), 
										pMac CHAR(12), pNumRegistro INT, pRecuperaciON INT)
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
	DEFINE dFechaNacimiento DATE;
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
	DEFINE iRegsProcHomonimos INT;
	DEFINE iIdGenerado INT;
	DEFINE iNivel INT;
	-- -- -- --
	LET cCodRet = '00000';
	LET dFechaNacimiento = pFechaNacimiento;
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
	LET iRegsProcHomonimos = 0;
	LET iNivel = 0;
	
	BEGIN
		SET ISOLATION TO DIRTY READ;
		FOREACH
			EXECUTE PROCEDURE bdinteg:sp_cnsif_buscacte(pIdUsuario, pIdFuncion, pTipoBusquedaPersona, pNombre1, 
														pNombre2, pApPaterno, pApMaterno, dFechaNacimiento,					
														pRazonSocial, pNumRegistro, pRecuperacion)
			INTO cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
					cNombre1, cNombre2, cApPaterno, cApMaterno, 
					cRazonSocial 
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		IF cCodRet <> '00000' THEN
			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pIdUsuario, pIdBusqueda, pIdOficio, pApPaterno, 
															pApMaterno, pNombre1, pNombre2,pRazonSocial,
															'', '', '', '', 
															pTipoCuenta,cTipoCliente, iStatusBusqueda, pIp,
															pMac)
			INTO cCodRetSp, iRegsProc;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
						pNombre1, pNombre2, pApPaterno, pApMaterno, 
						pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			LET cCodRet = '00000';
			LET cNivelCliente = '9';
			RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
					pNombre1, pNombre2, pApPaterno, pApMaterno, 
					pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
					cEtiqueta, iRegsProc;
		END IF;
		IF iNoRegistros > 1 THEN -- Se encontrarON homonimos
			LET cEtiqueta = 'HOMONIMO';
			LET iStatusBusqueda = 2;
			LET cNumeroCliente = '';
			LET cRfc = '';
			LET cNivelCliente = '9';
			LET cCodRet = '00000';
			LET cTipoPersona = pTipoBusquedaPersona;
			LET cTipoCliente = ''; 
			
			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pIdUsuario, pIdBusqueda, pIdOficio, pApPaterno, 
															pApMaterno, pNombre1, pNombre2, pRazonSocial, 
															cRfc, cNumeroCliente, '', '', 
															pTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
															pMac)
			INTO cCodRetSp, iRegsProc;
			
			LET iRegsProc = 0;
			RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
						pNombre1, pNombre2, pApPaterno, pApMaterno, 
						pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, iRegsProc;
			
			--SET ISOLATION TO DIRTY READ;
			--FOREACH
			--	EXECUTE PROCEDURE bdinteg:sp_cnsif_buscacte(pIdUsuario, pIdFuncion, pTipoBusquedaPersona, pNombre1, 
			--												pNombre2, pApPaterno, pApMaterno, dFechaNacimiento,
			--												pRazonSocial, pNumRegistro, pRecuperacion)
			--	INTO cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
			--			cNombre1, cNombre2, cApPaterno, cApMaterno, 
			--			cRazonSocial
			--	LET cEtiqueta = 'HOMONIMO';
			--	LET iStatusBusqueda = 2;
			--	SET ISOLATION TO DIRTY READ;
			--	SELECT tpo_persona, tipo_cliente 
			--	INTO cTipoPersona, cTipoCliente 
			--	FROM bdinteg:si_cliente 
			--	WHERE numcte = cNumeroCliente;
			--	EXECUTE PROCEDURE sp_sw_ro_bitacoraresultadoshom(pIdUsuario, pIdBusqueda, pIdOficio, cApPaterno, 
			--													cApMaterno, cNombre1, cNombre2, cRazonSocial,
			--													cRfc, cNumeroCliente, '', '',
			--													pTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
			--													pMac)
			--	INTO cCodRetSp, iRegsProc;
			--	RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
			--			pNombre1, pNombre2, pApPaterno, pApMaterno, 
			--			pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
			--			cEtiqueta, iRegsProc 
			--			WITH resume;
			--	
			--	IF iNoRegistros < pRecuperaciON THEN
			--		SET ISOLATION TO DIRTY READ;
			--		FOREACH 
			--			SELECT numcte, rfc, nombre1, nombre2, 
			--				apell_paterno, apell_materno, razon_social
			--			INTO cNumeroCliente, cRfc, cNombre1, cNombre2, 
			--				cApPaterno, cApMaterno, cRazonSocial
			--			FROM sw_ro_resulper_homonimos
			--			WHERE id_oficio = pIdOficio 
			--				AND id_busqueda = pIdBusqueda
			--			SET ISOLATION TO DIRTY READ;
			--			SELECT tpo_persona, tipo_cliente 
			--			INTO cTipoPersona, cTipoCliente 
			--			FROM bdinteg:si_cliente 
			--			WHERE numcte = cNumeroCliente;
			--			LET cCodRet = '00000';
			--			LET cNivelCliente = '9';
			--			LET cEtiqueta = 'HOMONIMO';
			--			LET iStatusBusqueda = 2;
			--			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pIdUsuario, pIdBusqueda, pIdOficio, cApPaterno, 
			--															cApMaterno, cNombre1, cNombre2, cRazonSocial, 
			--															cRfc, cNumeroCliente, '', '', 
			--															pTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
			--															pMac)
			--			INTO cCodRetSp, iRegsProc;
			--		END FOREACH;
			--	-- Eliminamos de la tabla temporal
			--		DELETE FROM sw_ro_resulper_homonimos
			--		WHERE id_oficio = pIdOficio 
			--			AND id_busqueda = pIdBusqueda;
			--	END IF;
			--END FOREACH;
		END IF;
		IF iNoRegistros = 1 THEN -- Se encontro un cliente
			SET ISOLATION TO DIRTY READ;
			FOREACH
				EXECUTE PROCEDURE bdinteg:sp_cnsif_buscacte(pIdUsuario, pIdFuncion, pTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, dFechaNacimiento,
															pRazonSocial, pNumRegistro, pRecuperacion)
				INTO cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_valida_nivelacceso_funcionalidad(pIdUsuario, pIdFuncion) INTO cCodRet, iNivel;
				IF iNivel=0 THEN
					LET cCodRet = '00076';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
				ELSE
					IF  cNivelCliente::INT < iNivel::INT THEN
						LET cCodRet = '00075';
						RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
					END IF;
				END IF;
				-- Se busca el tipo de cliente y el tipo de persona
				SET ISOLATION TO DIRTY READ;
				FOREACH
				SELECT tpo_persona, tipo_cliente 
				INTO cTipoPersona, cTipoCliente 
				FROM bdinteg:si_cliente 
				WHERE numcte = cNumeroCliente
				UNION
				SELECT '01' as tpo_persona, '1' as tipo_cliente 
				FROM bditransfer:tf_maecte 
				WHERE numcte_tf = cNumeroCliente
				END FOREACH;

				LET cEtiqueta = 'LOCALIZADO';
				LET iStatusBusqueda = 1;
				-- Se almacena la busqueda
				EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pIdUsuario, pIdBusqueda, pIdOficio,cApPaterno, 
																cApMaterno, cNombre1, cNombre2, cRazonSocial, 
																cRfc, cNumeroCliente, '', '',
																pTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
																pMac)
				INTO cCodRetSp, iIdGenerado;
				IF cCodRetSp <> '00000' THEN
					RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
							pNombre1, pNombre2, pApPaterno, pApMaterno, 
							pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, 0;
				END IF;
				-- Se almacena al cliente encontrado
				EXECUTE PROCEDURE sp_sw_ro_bitacoracteenc(pIdUsuario, pIdBusqueda, pIdOficio, iIdGenerado, 
															cNumeroCliente, cApPaterno, cApMaterno, cNombre1, 
															cNombre2, cRazonSocial, cRfc, pIp, 
															pMac)
				INTO cCodRetSp, iRegsProc;
				IF cCodRetSp <> '00000' THEN
					RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
							pNombre1, pNombre2, pApPaterno, pApMaterno, 
							pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, 0;
				END IF;
				-- Se buscan las cuentas y participaciones del cliente
				IF cTipoCliente = '1' THEN
					EXECUTE PROCEDURE sp_sw_ro_consctascteparticipacion(pIdUsuario, pIdFuncion, pIdOficio, pIdBusqueda, 
																		iRegsProc, cNumeroCliente, pRecuperacion, pIp, 
																		pMac) 
					INTO cCodRetSp;
					IF cCodRetSp <> '00000' THEN
						RETURN cCodRetSp, 'En 1 part', cRfc, cNivelCliente, 
								pNombre1, pNombre2, pApPaterno, pApMaterno, 
								pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cEtiqueta, iRegsProc;
					END IF;
				ELIF cTipoCliente = '2' THEN
					EXECUTE PROCEDURE sp_sw_ro_buscaparticipacion(pIdUsuario, pIdOficio, pIdBusqueda, iRegsProc, 
																	cNumeroCliente, pIp, pMac) 
					INTO cCodRetSp;
					IF cCodRetSp <> '00000' THEN
						RETURN cCodRetSp, 'en 2 part', cRfc, cNivelCliente,
								pNombre1, pNombre2, pApPaterno, pApMaterno, 
								pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cEtiqueta, iRegsProc;
					END IF;
				END IF;
				RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
						pNombre1, pNombre2, pApPaterno, pApMaterno, 
						pRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, iRegsProc;
			END FOREACH;
		END IF;
	END

END PROCEDURE;