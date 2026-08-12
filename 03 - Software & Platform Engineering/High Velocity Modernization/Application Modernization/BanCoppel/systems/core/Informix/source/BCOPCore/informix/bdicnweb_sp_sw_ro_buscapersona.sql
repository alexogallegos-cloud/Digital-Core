CREATE PROCEDURE "informix".sp_sw_ro_buscapersona(pId_UsuarioC CHAR(8), 
													pId_FuncionC CHAR(10), 
													pTipoBusqueda SMALLINT, 
													pIdOficio INT, 
													pNombre1 CHAR(60), 
													pNombre2 CHAR(26), 
													pApPaterno CHAR(26), 
													pApMaterno CHAR(26), 
													pFechaNacimiento DATE,
													pPagina SMALLINT, 
													pRegistros SMALLINT, 
													pIp CHAR(15), 
													pMacAddress CHAR(12))

RETURNING CHAR(5) AS codRet, 
        CHAR(20) AS numeroCliente, 
        CHAR(15) AS rfc,
        CHAR(26) AS nombre1, 
        CHAR(26) AS nombre2, 
        CHAR(26) AS apPaterno, 
        CHAR(26) AS apMaterno, 
        CHAR(60) AS razonSocial,
        CHAR(20) AS noCuenta,
        CHAR(20) AS noTarjeta,
        CHAR(2) AS tipoPersona, 
        CHAR(1) AS tipoCliente, 
        INT AS status, 
        CHAR(20) AS descStatusBusqueda,
        CHAR(1) AS ind_omitido,
        CHAR(1) AS ind_bloqueocta,
        CHAR(1) AS ind_terminado,
        INT AS id_busqueda,
        INT AS id_resulcte,
        CHAR(2) AS tipoCuenta,
        CHAR(1) AS ind_rfc,
        CHAR(1) AS ind_dir_empleo,
        CHAR(1) AS ind_domicilio,
        CHAR(1) AS ind_nacionalidad
-- DefiniciÃ³n de variables
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(5);
        DEFINE cNumeroCliente CHAR(20);
        DEFINE cNumeroCuenta CHAR(20);
        DEFINE cNumeroTarjeta CHAR(20);
        DEFINE cRfc CHAR(13);
        DEFINE iIdNumConsulta INT;
        DEFINE cNombre1 CHAR(26);
        DEFINE cNombre2 CHAR(26);
        DEFINE cApPaterno CHAR(26);
        DEFINE cApMaterno CHAR(26);
        DEFINE cRazonSocial CHAR(60);
        DEFINE iSqlErr INT;
        DEFINE iNoRows INT;
        DEFINE iExiste INT;
        DEFINE cCriterio CHAR(60);
        DEFINE iIdBusqueda INT;
        DEFINE cTipoBusquedaPersona CHAR(1);
        DEFINE cTipoPersona CHAR(2);
        DEFINE cTipoCliente CHAR(1);
        DEFINE cIdEncontrado INT;
        DEFINE iStatusBusqueda INT;
        DEFINE cDescStatusBusqueda CHAR(20);
        DEFINE iRegsProc INT;
        DEFINE cOmitido CHAR(1);
        DEFINE cBloqueado CHAR(1);
        DEFINE cTerminado CHAR(1);
        DEFINE cTipoCuenta CHAR(2);
        DEFINE cIndRfc CHAR(1);
        DEFINE cIndEmpleo CHAR(1);
        DEFINE cIndDomicilio CHAR(1);
        DEFINE cIndNacionalidad CHAR(1);
        -- ETIQUETAS
        DEFINE cHomonimo CHAR(15);
        DEFINE cEncontrado CHAR(15);
        DEFINE cNoEncontrado CHAR(15);
        DEFINE cBrfc            CHAR(13);
        DEFINE iCuentac         INT;

        --InicializaciÃ³n de variables
        LET cCodRet     = '00000';
        LET cCodRetSp = '00000';
        LET cNumeroCliente = '';
        LET cRfc = '';
        LET iIdNumConsulta = 0;
        LET cNombre1 = '';
        LET cNombre2 = '';
        LET cApPaterno = '';
        LET cApMaterno = '';
        LET cRazonSocial = '';
        LET iSqlErr = 0;
        LET cHomonimo = 'HOMONIMO';
        LET cEncontrado = 'LOCALIZADO';
        LET cNoEncontrado = 'NO LOCALIZADO';
        LET iExiste = 0;
        LET cCriterio = '';
        LET iIdBusqueda = 0;
        LET cTipoPersona = '';
        LET cTipoCliente = '';
        LET iStatusBusqueda = 0;
        LET cDescStatusBusqueda = '';
        LET cIdEncontrado = 0;
        LET iRegsProc = 0;
        LET cNumeroCuenta = '';
        LET cNumeroTarjeta = '';
        LET cOmitido = '0';
        LET cBloqueado = '0';
        LET cTerminado = '0';
        LET cTipoCuenta = '';
        LET cIndRfc = '0';
        LET cIndEmpleo = '0';
        LET cIndDomicilio = '0';
        LET cIndNacionalidad = '0';
        LET cBrfc='';
        LET iCuentac=0;
		LET cTipoBusquedaPersona = '';
        
        BEGIN
			-- Validaciones
			ON EXCEPTION SET iSqlErr
					IF iSqlErr <> 0 THEN
							LET cCodRet = iSqlErr;
							RETURN cCodRet, cNumeroCliente, cRfc, 
											cNombre1, cNombre2, cApPaterno, 
											cApMaterno, cRazonSocial, cNumeroCuenta, 
											cNumeroTarjeta, cTipoPersona, cTipoCliente, 
											iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
											cBloqueado, cTerminado, cIdEncontrado, 
											0, cTipoCuenta, cIndRfc, 
											cIndEmpleo, cIndDomicilio, cIndNacionalidad;
					END IF;
			END EXCEPTION;

			--SET DEBUG FILE TO "/tmp/mfinis/sp_sw_ro_buscapersona.out";
			--TRACE ON;

			-- ValidaciÃ³n del numero de oficio
			IF pIdOficio = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cNumeroCliente, cRfc, 
									cNombre1, cNombre2, cApPaterno, 
									cApMaterno, cRazonSocial, cNumeroCuenta, 
									cNumeroTarjeta, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
									cBloqueado, cTerminado, cIdEncontrado,
									0, cTipoCuenta, cIndRfc, 
									cIndEmpleo, cIndDomicilio, cIndNacionalidad;
			END IF;
			-- Busqueda del numero de oficio
			SET ISOLATION TO DIRTY READ;
			SELECT COUNT(id_oficio) 
			INTO iExiste 
			FROM sw_ro_maeoficios 
			WHERE id_oficio = pIdOficio;
			IF iExiste = 0 THEN
					LET cCodRet = '00001';
					RETURN cCodRet, cNumeroCliente, cRfc, 
							cNombre1, cNombre2, cApPaterno, 
							cApMaterno, cRazonSocial, cNumeroCuenta, 
							cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido,
							cBloqueado, cTerminado, cIdEncontrado,
							0, cTipoCuenta, cIndRfc, 
							cIndEmpleo, cIndDomicilio, cIndNacionalidad;
			END IF;
			IF pTipoBusqueda NOT IN (1,2,3,4,5,6) THEN
					LET cCodRet = '00087';
					RETURN cCodRet, cNumeroCliente, cRfc, 
							cNombre1, cNombre2, cApPaterno, 
							cApMaterno, cRazonSocial, cNumeroCuenta, 
							cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
							cBloqueado, cTerminado, cIdEncontrado,
							0, cTipoCuenta, cIndRfc,
							cIndEmpleo, cIndDomicilio, cIndNacionalidad;
			ELSE
					-- Se INSERTa el criterio de busqueda en la tabla sw_ro_buscaper
					-- Criterio de busqueda por Nombre
					IF pTipoBusqueda = 1 THEN
							IF pPagina = 0 THEN
									EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																															pApMaterno, pNombre1, pNombre2, 
																															'', '', '', 
																															'', '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO cCodRetSp, iIdBusqueda;
							ELSE
									EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno,
																															pApMaterno, pNombre1, pNombre2,
																															'', '', '', 
																															'', '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO iIdBusqueda;
							END IF;
							-- Se realiza la consulta de la persona
							LET cTipoBusquedaPersona = '1';
							SET ISOLATION TO DIRTY READ;
							FOREACH 
									EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda, 
																													pIdOficio, cTipoBusquedaPersona, pNombre1, 
																													pNombre2, pApPaterno, pApMaterno, 
																													'', pFechaNacimiento, cTipoCuenta, pIp, 
																													pMacAddress, pPagina, pRegistros)
									
									INTO cCodRet, cNumeroCliente, cRfc, 
											iIdNumConsulta, cNombre1, cNombre2, 
											cApPaterno, cApMaterno, cRazonSocial, 
											cTipoPersona, cTipoCliente, iStatusBusqueda, 
											cDescStatusBusqueda, cIdEncontrado
									RETURN cCodRet, cNumeroCliente, cRfc, 
											cNombre1, cNombre2, cApPaterno, 
											cApMaterno, cRazonSocial, cNumeroCuenta, 
											cNumeroTarjeta, cTipoPersona, cTipoCliente, 
											iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
											cBloqueado, cTerminado, iIdBusqueda, 
											cIdEncontrado, cTipoCuenta, cIndRfc, 
											cIndEmpleo, cIndDomicilio, cIndNacionalidad
											WITH resume;
							END FOREACH;
					END IF;
					-- Criterio de busqueda por RazÃ³n Social
					IF pTipoBusqueda = 2 THEN
							LET cCriterio = pNombre1;
							LET pNombre1 = '';
							IF pPagina = 0 THEN
									EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																															pApMaterno, pNombre1, pNombre2, 
																															cCriterio, '', '', 
																															'', '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO cCodRetSp, iIdBusqueda;
							ELSE
									EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																																	pApMaterno, pNombre1, pNombre2, 
																																	cCriterio, '', '', 
																																	'', '', pId_UsuarioC, 
																																	pIp, pMacAddress)
									INTO iIdBusqueda;
							END IF;
							-- Se realiza la consulta de la persona
							LET cTipoBusquedaPersona = '2';
							FOREACH 
									EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda,
																													pIdOficio, cTipoBusquedaPersona, pNombre1, 
																													pNombre2, pApPaterno, pApMaterno, 
																													cCriterio, '', cTipoCuenta, pIp, 
																													pMacAddress, pPagina, pRegistros)
									
									INTO cCodRet, cNumeroCliente, cRfc, 
											iIdNumConsulta, cNombre1, cNombre2, 
											cApPaterno, cApMaterno, cRazonSocial, 
											cTipoPersona, cTipoCliente, iStatusBusqueda, 
											cDescStatusBusqueda, cIdEncontrado
									RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
							END FOREACH;
					END IF;
					-- Busqueda por RFC
					IF pTipoBusqueda = 3 THEN
							
							LET cCriterio = TRIM(pNombre1);
							LET iCuentac=LENGTH(cCriterio);
							LET pNombre1 = '';
							IF pPagina = 0 THEN
									EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																															pApMaterno, pNombre1, pNombre2, 
																															'', cCriterio, '', 
																															'', '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO cCodRetSp, iIdBusqueda;
							ELSE
									EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																															pApMaterno, pNombre1, pNombre2, 
																															'', cCriterio, '',
																															'', '', pId_UsuarioC,
																															pIp, pMacAddress)
									INTO iIdBusqueda;
							END IF;
							SET ISOLATION TO DIRTY READ;
							IF iCuentac=10 THEN
									SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} FIRST 1 rfc
									INTO cBrfc
									FROM bdinteg:si_cliente WHERE rfc [1,10] = cCriterio;
									LET iRegsProc = dbinfo("sqlca.sqlerrd2");
									IF iRegsProc = 0 THEN
											SET ISOLATION TO DIRTY READ;
											SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} FIRST 1 rfc_alterno
											INTO cBrfc
											FROM bdinteg:si_cliente WHERE rfc_alterno [1,10] = cCriterio;
											LET iRegsProc = dbinfo("sqlca.sqlerrd2");
									END IF;
							ELSE
				FOREACH
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} FIRST 1 rfc
						INTO cBrfc
					FROM bdinteg:si_cliente WHERE rfc [1,13] = cCriterio--'GMVI780622TW1'
					UNION
					SELECT rfc
					FROM bditransfer:tf_maecte WHERE rfc [1,13] = cCriterio--'GMVI780622TW1'
				END FOREACH;    

									LET iRegsProc = dbinfo("sqlca.sqlerrd2");
									IF iRegsProc = 0 THEN
											SET ISOLATION TO DIRTY READ;
											SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} FIRST 1 rfc_alterno
											INTO cBrfc
											FROM bdinteg:si_cliente WHERE rfc_alterno [1,13] = cCriterio;
											LET iRegsProc = dbinfo("sqlca.sqlerrd2");
									END IF;
							END IF;
							IF iRegsProc = 0 THEN
									LET cRfc = cCriterio;
									LET cDescStatusBusqueda = 'NO LOCALIZADO';
									LET cRazonSocial = '';
									-- Registro del resultado obtenido
									EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																																	'', '', '', '', 
																																	'', cRfc, 
																																	cNumeroCliente, '', '', '',
																																	cTipoCliente, iStatusBusqueda, pIp, pMacAddress)
																																	INTO cCodRetSp, iRegsProc;                                      
									RETURN cCodRet, cNumeroCliente, cRfc, 
													cNombre1, cNombre2, cApPaterno, 
													cApMaterno, cRazonSocial, cNumeroCuenta, 
													cNumeroTarjeta, cTipoPersona, cTipoCliente, 
													iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
													cBloqueado, cTerminado, iIdBusqueda, 
													cIdEncontrado, cTipoCuenta, cIndRfc, 
													cIndEmpleo, cIndDomicilio, cIndNacionalidad;
							ELSE
									LET iRegsProc = 0;
									FOREACH 
											EXECUTE PROCEDURE sp_sw_ro_buscaxrfc2(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																															cCriterio, pPagina, pRegistros, pIp, 
																															pMacAddress)
											INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
															cNombre1, cNombre2, cApPaterno, cApMaterno, 
															cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda,
															cDescStatusBusqueda, cIdEncontrado
											RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
									END FOREACH;
							END IF;
					END IF;
					-- Busqueda por numero de cliente
					IF pTipoBusqueda = 4 THEN
							LET cCriterio = pNombre1;
							LET pNombre1 = '';
							IF pPagina = 0 THEN
									EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
							pNombre1, pNombre2, '', '', 
																															cCriterio, '', '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO cCodRetSp, iIdBusqueda;
							ELSE
									EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																															pNombre1, pNombre2, '', '', 
																															cCriterio, '', '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO iIdBusqueda;
							END IF;
							SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT SUBSTRING(tpo_persona FROM 2) AS tpo_persona, apell_paterno, apell_materno, nombre1, 
														nombre2, razon_social
				INTO cTipoBusquedaPersona, pApPaterno, pApMaterno, pNombre1, 
						pNombre2, cRazonSocial
				FROM bdinteg:si_cliente 
				WHERE numcte = cCriterio
				UNION
				SELECT '1' AS tpo_persona, apell_paterno, apell_materno, nombre1, 
														nombre2, '' as razon_social
				FROM bditransfer:tf_maecte
				WHERE numcte_tf = cCriterio
			END FOREACH;    

							IF cTipoBusquedaPersona is null THEN
									LET cDescStatusBusqueda = 'NO LOCALIZADO';
									LET cNumeroCliente = cCriterio;
									LET cRazonSocial = '';
							-- Registro del resultado obtenido
									EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, '', 
																																	'', '', '', '', 
																																	'', cNumeroCliente, '', '', 
																																	'', cTipoCliente, iStatusBusqueda, pIp,
																																	pMacAddress)
									INTO cCodRetSp, iRegsProc;
									RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
													cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
													cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
													iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
													cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
													cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
							ELSE
									SET ISOLATION TO DIRTY READ;
									FOREACH 
											EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																																	1, cCriterio, pRegistros, pIp, 
																																	pMacAddress)
											INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
															cNombre1, cNombre2, cApPaterno, cApMaterno, 
															cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
															cDescStatusBusqueda, cIdEncontrado
											RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
															cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
															cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
															iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado,
															cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
															cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
															WITH resume;
									END FOREACH;
							END IF;
					END IF;
					-- Busqueda por numero de cuenta
					IF pTipoBusqueda = 5 THEN
							LET cCriterio = pNombre1;
							LET pNombre1 = '';
							IF pPagina = 0 THEN
									EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																															pNombre1, pNombre2, '', '', 
																															'', cCriterio, '', pId_UsuarioC,
																															pIp, pMacAddress)
									INTO cCodRetSp, iIdBusqueda;
							ELSE
									EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																															pNombre1, pNombre2, '', '', 
																															'', cCriterio, '', pId_UsuarioC, 
																															pIp, pMacAddress)
									INTO iIdBusqueda;
							END IF;
							SET ISOLATION TO DIRTY READ;
							FOREACH 
									EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(1, cCriterio)
									INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno, 
													pNombre1, pNombre2, cRazonSocial, cTipoCuenta
									IF cTipoBusquedaPersona is null THEN
											LET cDescStatusBusqueda = 'NO LOCALIZADO';
											LET cRazonSocial = '';
											-- Registro del resultado obtenido
											EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																																			'', '', '', '', 
																																			'', '', '', cCriterio, 
																																			'', '', cTipoCliente, iStatusBusqueda, 
																																			pIp, pMacAddress)
											INTO cCodRetSp, iRegsProc;
											RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
															cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
															cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
															iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
															cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
															cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
															WITH resume;
									ELSE
											SET ISOLATION TO DIRTY READ;
											FOREACH 
													EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																																			2, cCriterio, pRegistros, pIp, 
																																			pMacAddress)
													INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
																	cNombre1, cNombre2, cApPaterno, cApMaterno, 
																	cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
																	cDescStatusBusqueda, cIdEncontrado
													-- Se actualiza el numero de cuenta
													UPDATE sw_ro_resulper
													SET cuenta = cCriterio
													WHERE id_busqueda = iIdBusqueda 
																	AND id_oficio = pIdOficio;
													RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
																	cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
																	cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
																	iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
																	cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
																	cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
																	WITH resume;
											END FOREACH;
									END IF;
							END FOREACH;
					END IF;
					-- Busqueda por numero de cuenta
					IF pTipoBusqueda = 6 THEN
							LET cCriterio = pNombre1;
							LET pNombre1 = '';
							IF pPagina = 0 THEN
									EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																															pNombre1, pNombre2, '', '', 
																															'', '', cCriterio, pId_UsuarioC,
																															pIp, pMacAddress)
									INTO cCodRetSp, iIdBusqueda;
							ELSE
									EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																																	pNombre1, pNombre2, '', '', 
																																	'', '', cCriterio, pId_UsuarioC, 
																																	pIp, pMacAddress)
									INTO iIdBusqueda;
							END IF;
							SET ISOLATION TO DIRTY READ;
							FOREACH 
									EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(2, cCriterio)
									INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno,
													pNombre1, pNombre2, cRazonSocial, cTipoCuenta
									IF cTipoBusquedaPersona is null THEN
											LET cDescStatusBusqueda = 'NO LOCALIZADO';
											LET cRazonSocial = '';
											-- Registro del resultado obtenido
											EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio,'',
																																			'', '', '', '',
																																			'', '', '', cCriterio,
																																			'',     cTipoCliente, iStatusBusqueda, pIp, 
																																			pMacAddress)
											INTO cCodRetSp, iRegsProc;
											RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
															cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
															cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
															iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
															cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta,
															cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad  
															WITH resume;
									ELSE
											SET ISOLATION TO DIRTY READ;
											FOREACH 
													EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																																			3, cCriterio, pRegistros, pIp, 
																																			pMacAddress)
													INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
																	cNombre1, cNombre2, cApPaterno, cApMaterno, 
																	cRazonSocial, cTipoPersona, cTipoCliente, 
																	iStatusBusqueda, cDescStatusBusqueda, cIdEncontrado
													-- Se actualiza el numero de cuenta
													UPDATE sw_ro_resulper
													SET num_tarjeta = cCriterio
													WHERE id_busqueda = iIdBusqueda AND id_oficio = pIdOficio;
													RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
													cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
													cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
													iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
													cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
													cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
													WITH resume;
											END FOREACH;
									END IF;
							END FOREACH;
					END IF;
			END IF;
        END
END PROCEDURE;