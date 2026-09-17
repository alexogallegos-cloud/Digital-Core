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