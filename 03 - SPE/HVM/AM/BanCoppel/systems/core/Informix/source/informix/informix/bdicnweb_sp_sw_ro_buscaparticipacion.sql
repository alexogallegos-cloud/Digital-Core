CREATE PROCEDURE "informix".sp_sw_ro_buscaparticipacion(pUsuario CHAR(8), 
											pIdOficio INT, 
											pIdBusqueda INT, 
											pIdCliente INT, 
											pNumCliente CHAR(20), 
											pIp CHAR(15), 
											pMacAddress CHAR(12))
	RETURNING CHAR(5) AS codret
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cDescPArticipaciON CHAR(30);
	DEFINE cParticipaciON CHAR(1);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cNumClienteTitular CHAR(20);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRazonSocial CHAR(60);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSistemaCuenta = '';
	LET cDescParticipaciON = '';
	LET cParticipaciON = '0';
	LET cNumCuenta =  '';
	LET cNumClienteTitular = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRazonSocial = '';
	LET cApMaterno = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
	--Busqueda como firmante en captacion
		LET cSistemaCuenta = '01';
		LET cDescParticipaciON = 'FIRMANTE CAPTACION';
		LET cParticipaciON = '2';
		-- a) Busqueda de las cuentas en la tabla de firmantes
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT cuenta 
				INTO cNumCuenta
				FROM bdicheq:sc_firmantes 
				WHERE numcte = pNumCliente
			-- b) Busqueda del numero de cliente en la tabla maestra de cheques
				SET ISOLATION TO DIRTY READ;
				SELECT num_cte 
				INTO cNumClienteTitular
				FROM bdicheq:sc_maechq 
				WHERE cuenta = cNumCuenta 
					AND num_cte <> pNumCliente;
				IF cNumClienteTitular is not NULL OR cNumClienteTitular <> '' THEN
				-- c) Busqueda de los datos del cliente titular
					SET ISOLATION TO DIRTY READ;
					SELECT apell_paterno, apell_materno, nombre1, nombre2, razon_social
					INTO cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial
					FROM bdinteg:si_cliente 
					WHERE numcte = cNumClienteTitular;
					-- Se INSERTan los valores en la tabla de participes
					INSERT INTO sw_ro_cta_participes(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta, 
													id_tipo_participe, 
													tipo_participe, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda, 
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion, 
													cDescParticipacion, 
													pUsuario, 
													pIp, 
													pMacAddress);
					-- Se guardan los datos de los titulares
					INSERT INTO sw_ro_cte_ctatitular(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta, 
													id_tipo_participe, 
													tipo_participe, 
													numcte_titular, 
													apell_paterno_titular,
													apell_materno_titular, 
													nombre1_titular, 
													nombre2_titular, 
													razon_social_titular, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda, 
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion, 
													cDescParticipacion, 
													cNumClienteTitular, 
													cApPaterno, 
													cApMaterno, 
													cNombre1, 
													cNombre2, 
													cRazonSocial, 
													pUsuario,
													pIp, 
													pMacAddress);
					-- Se almacenan los datos en la tabla de ctecta
					INSERT INTO sw_ro_ctecta(id_oficio, 
										id_busqueda, 
										id_resulcte, 
										numcte, 
										cuenta, 
										id_tipo_participe, 
										tipo_participe, 
										tipo_cuenta, 
										producto, 
										nombre_producto, 
										status_cuenta, 
										fecha_apertura, 
										sucursal,
										sdo_actual, 
										user_INSERT, 
										ip_INSERT, 
										mac_INSERT, 
										dia_corte)
								VALUES(pIdOficio, 
										pIdBusqueda, 
										pIdCliente, 
										pNumCliente, 
										cNumCuenta,
										cParticipacion,
										cDescParticipacion,
										cSistemaCuenta,
										'', 
										'', 
										'', 
										null, 
										'', 
										null, 
										pUsuario, 
										pIp,
										pMacAddress, 
										0);
										END IF;
										END FOREACH;
		--======== Busqueda como beneficiario en captacion
		LET cSistemaCuenta = '01';
		LET cDescParticipaciON = 'BENEFICIARIO CAPTACION';
		LET cParticipaciON = '3';
		-- a) Busqueda de las cuentas en la tabla de firmantes
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT cuenta 
				INTO cNumCuenta
				FROM bdicheq:sc_beneficiario 
				WHERE numcte = pNumCliente
				-- b) Busqueda del numero de cliente en la tabla maestra de cheques
				SET ISOLATION TO DIRTY READ;
				SELECT num_cte 
				INTO cNumClienteTitular
				FROM bdicheq:sc_maechq 
				WHERE cuenta = cNumCuenta AND num_cte <> pNumCliente;
				IF cNumClienteTitular is not NULL OR cNumClienteTitular <> '' THEN
				-- c) Busqueda de los datos del cliente titular
					SET ISOLATION TO DIRTY READ;
					SELECT apell_paterno, apell_materno, nombre1, nombre2, razon_social
					INTO cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial
					FROM bdinteg:si_cliente 
					WHERE numcte = cNumClienteTitular;
					-- Se INSERTan los valores en la tabla de participes
					INSERT INTO sw_ro_cta_participes(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta, 
													id_tipo_participe,
													tipo_participe, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda, 
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion, 
													cDescParticipacion, 
													pUsuario, 
													pIp, 
													pMacAddress);
					-- Se guardan los datos de los titulares
					INSERT INTO sw_ro_cte_ctatitular(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta, 
													id_tipo_participe, 
													tipo_participe, 
													numcte_titular, 
													apell_paterno_titular,
													apell_materno_titular,
													nombre1_titular, 
													nombre2_titular, 
													razon_social_titular, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda, 
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion,
													cDescParticipacion,
													cNumClienteTitular, 
													cApPaterno, 
													cApMaterno,
													cNombre1, 
													cNombre2, 
													cRazonSocial,
													pUsuario, 
													pIp, 
													pMacAddress);
					-- Se almacenan los datos en la tabla de ctecta
					INSERT INTO sw_ro_ctecta(id_oficio, 
											id_busqueda, 
											id_resulcte, 
											numcte, 
											cuenta, 
											id_tipo_participe, 
											tipo_participe, 
											tipo_cuenta, 
											producto, 
											nombre_producto, 
											status_cuenta, 
											fecha_apertura, 
											sucursal,
											sdo_actual, 
											user_INSERT, 
											ip_INSERT, 
											mac_INSERT, 
											dia_corte)
									VALUES(pIdOficio, 
											pIdBusqueda, 
											pIdCliente, 
											pNumCliente, 
											cNumCuenta, 
											cParticipacion, 
											cDescParticipacion, 
											cSistemaCuenta, 
											'', 
											'',
											'', 
											null,
											'',
											null, 
											pUsuario,
											pIp, 
											pMacAddress, 
											0);
				END IF;
		END FOREACH;
		--Busqueda como adicional en credito
		LET cSistemaCuenta = '06';
		LET cDescParticipaciON = 'ADICIONAL CREDITO';
		LET cParticipaciON = '4';
		-- a) Busqueda de las cuentas en la tabla de firmantes
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT num_credito
				INTO cNumCuenta
				FROM bdicred:sd_tarjeta 
				WHERE numcte = pNumCliente
				-- b) Busqueda del numero de cliente en las tablas maestras de credito
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT DISTINCT numcte INTO cNumClienteTitular from
					(SELECT numcte FROM bdicred:sd_maecred WHERE num_credito = cNumCuenta
					union
					SELECT numcte FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCuenta) AS tmp_cred 
					WHERE numcte <> pNumCliente
					IF cNumClienteTitular is not NULL OR cNumClienteTitular <> '' THEN
						-- c) Busqueda de los datos del cliente titular
						SET ISOLATION TO DIRTY READ;
						SELECT apell_paterno, apell_materno, nombre1, nombre2, razon_social
						INTO cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial
						FROM bdinteg:si_cliente 
						WHERE numcte = cNumClienteTitular;
						-- Se INSERTan los valores en la tabla de participes
						INSERT INTO sw_ro_cta_participes(id_oficio, 
														id_busqueda, 
														id_resulcte, 
														numcte, 
														tipo_cuenta, 
														cuenta, 
														id_tipo_participe, 
														tipo_participe, 
														user_INSERT, 
														ip_INSERT, 
														mac_INSERT)
												VALUES(pIdOficio, 
														pIdBusqueda, 
														pIdCliente, 
														pNumCliente, 									
														cSistemaCuenta, 
														cNumCuenta, 
														cParticipacion, 
														cDescParticipacion, 
														pUsuario, 
														pIp, 
														pMacAddress);
						-- Se guardan los datos de los titulares
						INSERT INTO sw_ro_cte_ctatitular(id_oficio, 
														id_busqueda, 
														id_resulcte, 
														numcte, 
														tipo_cuenta, 
														cuenta, 
														id_tipo_participe,
														tipo_participe, 
														numcte_titular, 
														apell_paterno_titular,
														apell_materno_titular, 
														nombre1_titular, 
														nombre2_titular, 
														razon_social_titular,
														user_INSERT, 
														ip_INSERT, mac_INSERT)
													VALUES(pIdOficio,
														pIdBusqueda, 
														pIdCliente, 
														pNumCliente,
														cSistemaCuenta, 									
														cNumCuenta,
														cParticipacion, 
														cDescParticipacion, 
														cNumClienteTitular, 
														cApPaterno, 
														cApMaterno, 
														cNombre1, 
														cNombre2, 
														cRazonSocial, 
														pUsuario,
														pIp, 
														pMacAddress);
						-- Se almacenan los datos en la tabla de ctecta
						INSERT INTO sw_ro_ctecta(id_oficio, 
												id_busqueda, 
												id_resulcte,
												numcte,
												cuenta, 
												id_tipo_participe, 
												tipo_participe, 
												tipo_cuenta, 
												producto,
												nombre_producto,
												status_cuenta, 
												fecha_apertura, 
												sucursal,
												sdo_actual,
												user_INSERT,
												ip_INSERT,
												mac_INSERT,
												dia_corte)
										VALUES(pIdOficio,								
											pIdBusqueda, 		
											pIdCliente, 
											pNumCliente, 
											cNumCuenta, 
											cParticipacion, 
											cDescParticipacion, 
											cSistemaCuenta,
											'', 
											'', 
											'', 
											null, 
											'', 
											null, 
											pUsuario, 
											pIp, 
											pMacAddress,
											0);
					END IF;
				END FOREACH;
			END FOREACH;
		-- Busqueda como cotitular en inversiones
		LET cSistemaCuenta = '03';
		LET cDescParticipaciON = 'COTITULAR INVERSIONES';
		LET cParticipaciON = '5';
		-- a) Busqueda de las cuentas en la tabla de firmantes
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT cuenta 
				INTO cNumCuenta
				FROM bdinvers:sv_cotitular 
				WHERE numcte = pNumCliente
				-- b) Busqueda del numero de cliente en la tabla maestra de cheques
				SET ISOLATION TO DIRTY READ;
				SELECT num_cte 
				INTO cNumClienteTitular
				FROM bdinvers:sv_maeinv 
				WHERE cuenta = cNumCuenta AND num_cte <> pNumCliente AND status_cta='4'
				AND secuencia=(SELECT MAX(secuencia) FROM bdinvers:sv_maeinv WHERE cuenta = cNumCuenta AND num_cte <> pNumCliente AND status_cta='4');
				IF cNumClienteTitular is not NULL OR cNumClienteTitular <> '' THEN
				-- c) Busqueda de los datos del cliente titular
					SET ISOLATION TO DIRTY READ;
					SELECT apell_paterno, apell_materno, nombre1, nombre2, razon_social
					INTO cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial
					FROM bdinteg:si_cliente 
					WHERE numcte = cNumClienteTitular;
					-- Se INSERTan los valores en la tabla de participes
					INSERT INTO sw_ro_cta_participes(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta, 
													id_tipo_participe, 
													tipo_participe, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda,
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion, 
													cDescParticipacion, 
													pUsuario, 
													pIp, 
													pMacAddress);
					
					-- Se guardan los datos de los titulares
					INSERT INTO sw_ro_cte_ctatitular(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta, 
													id_tipo_participe,
													tipo_participe,
													numcte_titular,
													apell_paterno_titular,
													apell_materno_titular, 
													nombre1_titular, 
													nombre2_titular, 
													razon_social_titular, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda, 
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion,
													cDescParticipacion,
													cNumClienteTitular,
													cApPaterno, 
													cApMaterno, 
													cNombre1, 
													cNombre2, 
													cRazonSocial,
													pUsuario,
													pIp,
													pMacAddress);
					-- Se almacenan los datos en la tabla de ctecta
					INSERT INTO sw_ro_ctecta(id_oficio, 
											id_busqueda, 
											id_resulcte, 
											numcte, 
											cuenta, 
											id_tipo_participe, 
											tipo_participe, 
											tipo_cuenta, 
											producto, 
											nombre_producto, 
											status_cuenta,
											fecha_apertura, 
											sucursal,
											sdo_actual, 
											user_INSERT,
											ip_INSERT, 
											mac_INSERT, 
											dia_corte)
									VALUES(pIdOficio,
											pIdBusqueda, 
											pIdCliente,
											pNumCliente, 
											cNumCuenta,
											cParticipacion, 
											cDescParticipacion,
											cSistemaCuenta, 
											'', 
											'',
											'', 
											null, 
											'', 
											null, 
											pUsuario, 
											pIp,
											pMacAddress, 
											0);
				END IF;
		END FOREACH;
		--Busqueda como BENEFICIARIO en inversiones
		LET cSistemaCuenta = '03';
		LET cDescParticipaciON = 'BENEFICIARIO INVERSIONES';
		LET cParticipaciON = '6';
		--a) Busqueda de las cuentas en la tabla de firmantes
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT cuenta 
				INTO cNumCuenta
				FROM bdinvers:sv_benefic 
				WHERE numcte = pNumCliente
				-- b) Busqueda del numero de cliente en la tabla maestra de cheques
				SET ISOLATION TO DIRTY READ;
				SELECT num_cte 
				INTO cNumClienteTitular
				FROM bdinvers:sv_maeinv 
				WHERE cuenta = cNumCuenta AND num_cte <> pNumCliente AND status_cta='4'
				AND secuencia=(SELECT MAX(secuencia) FROM bdinvers:sv_maeinv WHERE cuenta = cNumCuenta AND num_cte <> pNumCliente AND status_cta='4');
				IF cNumClienteTitular is not NULL OR cNumClienteTitular <> '' THEN
				-- c) Busqueda de los datos del cliente titular
					SET ISOLATION TO DIRTY READ;
					SELECT apell_paterno, apell_materno, nombre1, nombre2, razon_social
					INTO cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial
					FROM bdinteg:si_cliente 
					WHERE numcte = cNumClienteTitular;
					-- Se INSERTan los valores en la tabla de participes
					INSERT INTO sw_ro_cta_participes(id_oficio, 
													id_busqueda, 
													id_resulcte, 
													numcte, 
													tipo_cuenta, 
													cuenta,
													id_tipo_participe, 
													tipo_participe, 
													user_INSERT, 
													ip_INSERT,
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda, 
													pIdCliente, 
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion, 
													cDescParticipacion, 
													pUsuario, 
													pIp,
													pMacAddress);
					-- Se guardan los datos de los titulares
					INSERT INTO sw_ro_cte_ctatitular(id_oficio,
													id_busqueda, 
													id_resulcte,
													numcte, 
													tipo_cuenta,
													cuenta, 
													id_tipo_participe,
													tipo_participe, 
													numcte_titular, 
													apell_paterno_titular,
													apell_materno_titular,
													nombre1_titular, 
													nombre2_titular, 
													razon_social_titular, 
													user_INSERT, 
													ip_INSERT, 
													mac_INSERT)
											VALUES(pIdOficio, 
													pIdBusqueda,
													pIdCliente,
													pNumCliente, 
													cSistemaCuenta, 
													cNumCuenta, 
													cParticipacion, 
													cDescParticipacion, 
													cNumClienteTitular, 
													cApPaterno, 
													cApMaterno, 
													cNombre1, 
													cNombre2, 
													cRazonSocial, 
													pUsuario,
													pIp, 
													pMacAddress);
				-- Se almacenan los datos en la tabla de ctecta
					INSERT INTO sw_ro_ctecta(id_oficio, 
											id_busqueda, 
											id_resulcte,
											numcte, 
											cuenta, 
											id_tipo_participe,
											tipo_participe, 
											tipo_cuenta,
											producto, 
											nombre_producto,
											status_cuenta, 
											fecha_apertura, 
											sucursal,
											sdo_actual,
											user_INSERT,
											ip_INSERT,
											mac_INSERT, 
											dia_corte)
									VALUES(pIdOficio,
											pIdBusqueda, 
											pIdCliente, 
											pNumCliente, 
											cNumCuenta, 
											cParticipacion, 
											cDescParticipacion,
											cSistemaCuenta, 
											'', 
											'', 
											'', 
											null, 
											'', 
											null, 
											pUsuario, 
											pIp, 
											pMacAddress,
											0);
				END IF;
			END FOREACH;
		RETURN cCodRet;
	END
END PROCEDURE;