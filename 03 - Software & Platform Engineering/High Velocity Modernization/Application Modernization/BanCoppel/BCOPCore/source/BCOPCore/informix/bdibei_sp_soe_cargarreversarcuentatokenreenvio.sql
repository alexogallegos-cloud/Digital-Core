CREATE PROCEDURE "informix".sp_soe_cargarreversarcuentatokenreenvio(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pSistema CHAR(5), pNumCte CHAR(20), 
												pSucursal CHAR(4), pSecDomicilio SMALLINT, pFolioSuc CHAR (16), pCuenta CHAR(12), pMonto DECIMAL(14,2), 
												pCantToken SMALLINT, pTransac CHAR(4), pTransacIva CHAR(4), pStatusToken SMALLINT, pIdsUsuarios CHAR(255))
                RETURNING CHAR(5) AS codret,
                                  CHAR(10) AS numSolicitud;


        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
		
		DEFINE pTransac CHAR(4);
		DEFINE pTransacIva CHAR(4);

        DEFINE cMensajeErr CHAR(255);
        DEFINE cDivisa CHAR(2);
        DEFINE cNumTarjeta CHAR(20);
        DEFINE cTrans CHAR(4);
        DEFINE dFecha DATE;
        DEFINE mSaldo MONEY(14,2);
        DEFINE iTransaccion INTEGER;
        DEFINE iCargo INTEGER;
        DEFINE cNumSolicitud CHAR(10);
        DEFINE mIva MONEY(16,2);
        DEFINE cFolio CHAR(12);
        DEFINE iSolicitud INTEGER;
        DEFINE cSolicitud CHAR(10);
        DEFINE iIdUsuario INTEGER;
        DEFINE iIdTipoUsuario SMALLINT;
        DEFINE iIdStatusUsuario SMALLINT;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
		
		LET pTransac = '3298'; --Se actualiza la nueva transacción por COMISION CONTRATACION-REPOSICION TOKEN
		LET pTransacIva = '0260'; --se actualiza el número de transacción por IVA DE COMISIONES

        LET cMensajeErr = '';
        LET cDivisa  = '';
        LET cNumTarjeta  = '';
        LET cTrans   = '';
        LET dFecha = CURRENT;
        LET mSaldo = 0;
        LET iTransaccion = 0;
        LET iCargo = 0;
        LET cNumSolicitud = '';
        LET mIva = 0;
        LET cFolio = '';
        LET iSolicitud = 0;
        LET cSolicitud = '';
        LET iIdUsuario = 0;
        LET iIdTipoUsuario = 0;
        LET iIdStatusUsuario = 0;
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        IF iTransaccion = 1 THEN
                                ROLLBACK WORK;
                                BEGIN WORK;
                        ELSE
                                ROLLBACK WORK;
                        END IF;
                        RETURN cCodRet, cNumSolicitud;
                END EXCEPTION;
                
                ON EXCEPTION IN (-535)
                        LET iTransaccion = 1;
                END EXCEPTION WITH RESUME;
                
                ON EXCEPTION IN (-255)
                        LET iTransaccion = 0;
                END EXCEPTION WITH RESUME;
                BEGIN WORK;
                
                --SET DEBUG FILE TO '/tmp/viri/sp_soe_cargarreversarcuentatokenreenvio.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR  pNumCte = '' OR pSucursal = '' OR  pSecDomicilio = 0 OR pSecDomicilio = '' OR 
                        pFolioSuc = '' OR pCantToken = 0 OR pCantToken = '' OR pTransac = '' OR pStatusToken = '' OR pIdsUsuarios = '' THEN
                        LET cCodRet = '00003';
                        IF iTransaccion = 1 THEN
                                ROLLBACK WORK;
                                BEGIN WORK;
                        ELSE
                                ROLLBACK WORK;
                        END IF;
                        RETURN cCodRet, cNumSolicitud;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNumSolicitud;
                END IF;
                
                IF iCargo = 1 THEN
                        IF pSistema::INTEGER = 1 THEN
                                EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal, pUsuario, pFolioSuc, 'M')
                                INTO cCodRetSp;
                                
                                LET iCodRetSp = cCodRetSp::INTEGER;
                                IF iCodRetSp < 0 THEN
                                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP reversion';
                                ELIF iCodRetSp = 999 THEN
                                        LET cCodRet = '00275'; --ESTATUS INVALIDO PARA REALIZAR LA CONSULTA
                                        --RETURN cCodRet, cNumSolicitud;
                                ELIF iCodRetSp = 413 THEN
                                        LET cCodRet = '00101'; --SALDO INSUFICIENTE
                                        --RETURN cCodRet, cNumSolicitud;
                                END IF;
								
								RETURN cCodRet, cNumSolicitud;
                        ELSE
                                EXECUTE PROCEDURE bdicred:"informix".reversion(cEmpresa, pSucursal, pUsuario, pFolioSuc, 'M')
                                INTO cCodRetSp;
                                
                                LET iCodRetSp = cCodRetSp::INTEGER;
                                IF iCodRetSp < 0 THEN
                                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP reversion';
                                ELIF iCodRetSp = 431 THEN
                                        LET cCodRet = '00407'; --PAGO NO ES EL ULTIMO REVERSA EN ORDEN
                                        RETURN cCodRet, cNumSolicitud;
                                END IF;
                        END IF;
                END IF;
                
                SET LOCK MODE TO WAIT 3;
                
                IF iTransaccion = 1 THEN 
                        ROLLBACK WORK;
                        BEGIN WORK;
                ELSE
                        ROLLBACK WORK;
                END IF;
                
                IF pTipo = 1 OR pTipo = 2 THEN
                        IF pMonto <> 0 THEN --(SE COBRA CARGO)
                                EXECUTE PROCEDURE bdibpi:"informix".sp_cons_tar_divisa( cEmpresa, pSistema, pCuenta)
                                INTO cCodRetSp, cNumTarjeta, cDivisa;

                                LET iCodRetSp = cCodRetSp::INTEGER;
                                IF iCodRetSp <> 0 THEN
                                        IF iTransaccion = 1 THEN
                                                ROLLBACK WORK;
                                                BEGIN WORK;
                                        ELSE
                                                ROLLBACK WORK;
                                        END IF;
                                        IF iCodRetSp < 0 THEN
                                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cons_tar_divisa';
                                        ELIF iCodRetSp = 001 THEN
                                                LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
                                                RETURN cCodRet, cNumSolicitud;
                                        END IF;
                                END IF;
                                --LET pMonto = pCantToken * pMonto;
								SELECT valor INTO mIva FROM bdinteg:"informix".si_param WHERE cod_param = '47';
								LET pMonto = pMonto / (1+mIva); --Se quita el IVA al monto
								
                                IF pSistema::INTEGER = 1 THEN
                                        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa, pSucursal, pUsuario, pTransac, '0000', pFolioSuc, pCuenta, 0, pMonto, cDivisa, 'ComisiÃ³n por Token', cNumTarjeta, pCuenta)
                                        INTO iCodRetSp, cTrans, dFecha, mSaldo, pMonto;
                                        
                                        LET iCodRetSp = cCodRetSp::INTEGER;
                                        IF iCodRetSp <> 0 THEN
                                                IF iTransaccion = 1 THEN
                                                        ROLLBACK WORK;
                                                        BEGIN WORK;
                                                ELSE
                                                        ROLLBACK WORK;
                                                END IF;
                                                IF iCodRetSp < 0 THEN
                                                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP cargo_ref';
                                                ELIF iCodRetSp = 962 OR iCodRetSp = 404 OR iCodRetSp = 200 THEN
                                                        LET cCodRet = '00378';  --PRODUCTO O TRANSACCIÃ?N INVÃLIDA
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 550 THEN
                                                        LET cCodRet = '00405';  --EL NÃ?MERO DE TRANSACCIÃ?N NO CONTIENE UN TIPO DE TRANSACCIÃ?N
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 777 THEN
                                                        LET cCodRet = '00406';  --LIMITE AUTORIZADO EN TARJETAS ADICIONALES
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 035 THEN
                                                        LET cCodRet = '00404';  --'IMPORTE DE LA TRANSACCIÃ?N EXCEDE EL LÃMITE DIARIO PERMITIDO PARA EL CANAL
                                                        --RETURN cCodRet, cNumSolicitud;
                                                END IF;
												
												RETURN cCodRet, cNumSolicitud;
                                        ELSE
                                                LET iCargo = 1;
                                                --SELECT valor INTO mIva FROM bdinteg:"informix".si_param WHERE cod_param = '47';
                                                --LET pMonto = pMonto * mIva;
												LET mIva = pMonto * mIva;
                                                EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa, pSucursal, pUsuario, pTransacIva, 0000, pFolioSuc, pCuenta, 0, mIva, cDivisa, 'ComisiÃ³n por Token', cNumTarjeta, pCuenta)
                                                INTO cCodRetSp, cTrans, dFecha, mSaldo, pMonto;
                                                
                                                LET iCodRetSp = cCodRetSp::INTEGER;
                                                IF iCodRetSp <> 0 THEN
                                                        IF iTransaccion = 1 THEN
                                                                ROLLBACK WORK;
                                                                BEGIN WORK;
                                                        ELSE
                                                                ROLLBACK WORK;
                                                        END IF;
                                                        IF iCodRetSp < 0 THEN
																RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP cargo_ref';
                                                        ELIF iCodRetSp = 962 OR iCodRetSp = 404 OR iCodRetSp = 200 THEN
                                                                LET cCodRet = '00378';  --PRODUCTO O TRANSACCIÃ?N INVÃLIDA
                                                                --RETURN cCodRet, cNumSolicitud;
                                                        ELIF iCodRetSp = 550 THEN
                                                                LET cCodRet = '00405';  --EL NÃ?MERO DE TRANSACCIÃ?N NO CONTIENE UN TIPO DE TRANSACCIÃ?N
                                                                --RETURN cCodRet, cNumSolicitud;
                                                        ELIF iCodRetSp = 777 THEN
                                                                LET cCodRet = '00406';  --LIMITE AUTORIZADO EN TARJETAS ADICIONALES
                                                                --RETURN cCodRet, cNumSolicitud;
                                                        ELIF iCodRetSp = 035 THEN
                                                                LET cCodRet = '00404';  --'IMPORTE DE LA TRANSACCIÃ?N EXCEDE EL LÃMITE DIARIO PERMITIDO PARA EL CANAL
                                                                --RETURN cCodRet, cNumSolicitud;
                                                        END IF;
                                                        
                                                        EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal, pUsuario, pFolioSuc, 'M')
                                                        INTO cCodRetSp;
                                        
                                                        LET iCodRetSp = cCodRetSp::INTEGER;
                                                        IF iCodRetSp < 0 THEN
                                                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP reversion';
                                                        ELIF iCodRetSp = 999 THEN
                                                                LET cCodRet = '00275'; --ESTATUS INVALIDO PARA REALIZAR LA CONSULTA
                                                                --RETURN cCodRet, cNumSolicitud;
                                                        ELIF iCodRetSp = 413 THEN
                                                                LET cCodRet = '00101'; --SALDO INSUFICIENTE
                                                                --RETURN cCodRet, cNumSolicitud;
                                                        END IF;
													
														RETURN cCodRet, cNumSolicitud;	
                                                END IF;
                                        END IF;
                                ELIF pSistema::INTEGER = 6 THEN
                                        EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(cEmpresa, pSucursal, pUsuario, cNumTarjeta, pMonto,pFolioSuc, pTransac)
                                        INTO cCodRetSp, mSaldo, mSaldo, mIva, mIva;
                                        
                                        LET iCodRetSp = cCodRetSp::INTEGER;
                                        IF iCodRetSp <> 0 THEN
                                                IF iTransaccion = 1 THEN
                                                        ROLLBACK WORK;
                                                        BEGIN WORK;
                                                ELSE
                                                        ROLLBACK WORK;
                                                END IF;
                                                IF iCodRetSp < 0 THEN
                                                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP cargoref_tc_ofi';
                                                ELIF iCodRetSp = 008 THEN
                                                        LET cCodRet = '00046'; --EL NUMERO DE CREDITO NO EXISTE
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 206 THEN
                                                        LET cCodRet = '00401'; --EL CRÃ?DITO NO PERTENECE A UNA TARJETA DE CRÃ?DITO
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 207 THEN
                                                        LET cCodRet = '00018'; --CRÃ?DITO BLOQUEADO MANUALMENTE FAVOR DE VERIFICAR
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 199 THEN
                                                        LET cCodRet = '00402'; --BLOQUEO POR PRODUCTO
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 208 THEN
                                                        LET cCodRet = '00023'; --EL CLIENTE NO TIENE TARJETAS ASIGNADAS
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 005 THEN
                                                        LET cCodRet = '00403'; --EL SALDO ES MENOR AL MONTO DE MOVIMIENTO
                                                        --RETURN cCodRet, cNumSolicitud;
                                                ELIF iCodRetSp = 035 THEN
                                                        LET cCodRet = '00404'; --IMPORTE DE LA TRANSACCIÃ?N EXCEDE EL LÃMITE DIARIO PERMITIDO PARA EL CANAL
                                                        --RETURN cCodRet, cNumSolicitud;
                                                END IF;
												
												RETURN cCodRet, cNumSolicitud;
                                        ELSE
                                                LET iCargo = 1;
                                        END IF;
                                END IF;
                        ELSE--(NO SE COBRA CARGO)
                                LET pFolioSuc = 'SINCOMIS' || SUBSTR(pFolioSuc, 9, 8);
                        END IF;
                        IF pStatusToken = 0 THEN
                                LET pStatusToken = 100;
                                SELECT MAX(solicitud::INTEGER) INTO iSolicitud FROM bdibei:"informix".bei_solicitudtoken;
                                
                                LET iSolicitud = iSolicitud + 1;
                                LET cSolicitud = LPAD(iSolicitud, 10, 0);
                                LET cNumSolicitud = cSolicitud;
                                
								--Se pone la secuencia del domicilio forzado para que se inserte el correcto.
								SELECT secuencia INTO pSecDomicilio FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte AND tipo_dir ='1';
								
                                INSERT INTO bdibei:"informix".bei_solicitudtoken
                                (solicitud, numcte, id_status, unidades, sucursal, f_solicitud, f_atencion, sec_domicilio, usr_solicita, usr_atiende, folio_suc)
                                VALUES
                                (cSolicitud, pNumCte, pStatusToken, pCantToken, pSucursal, CURRENT, CURRENT, pSecDomicilio, pUsuario, cEmpresa, pFolioSuc);
                                

								-- ActualizaciÃ³n de estatus
								FOREACH
										SELECT id_usuario, id_tipo_usuario, id_status
										INTO iIdUsuario, iIdTipoUsuario, iIdStatusUsuario
										FROM bdibei:"informix".bei_usuario
										WHERE num_cliente = pNumCte 
											AND id_usuario IN (SELECT id_usuario FROM TABLE (PROCEDURE bdicnweb:"informix".sp_split_cadena(pIdsUsuarios, '|')) t(id_usuario))


										IF iIdTipoUsuario = 1 THEN

												UPDATE bdibei:"informix".bei_usuario 
												SET id_status = '27'
												WHERE num_cliente = pNumCte AND id_usuario = iIdUsuario;
												
												IF (SELECT id_status
														FROM bdibpi:"informix".tkn_nseries
														WHERE ns_token = 
																(SELECT a.ns_token
																FROM bdibei:"informix".bei_servicio a
																WHERE a.num_cliente = pNumCte
																		AND a.id_usuario = iIdUsuario)) = 199 AND iIdStatusUsuario < 30 THEN
														
														LET cCodRet = 'YA SE HA GENERADO LA REPOSICIÃ?N DEL TOKEN. ESPERAR EL ENVÃO DEL NUEVO DISPOSITIVO'; 
														RETURN cCodRet, cNumSolicitud;

												END IF;
												
												
												UPDATE bdibei:"informix".bei_servicio
												SET id_status = '27',
														ns_token = ''
												WHERE num_cliente = pNumCte
														AND id_usuario = iIdUsuario;
										
										ELIF iIdTipoUsuario = 2 THEN
										
												UPDATE bdibei:"informix".bei_usuario 
												SET id_status = '26'
												WHERE num_cliente = pNumCte AND id_usuario = iIdUsuario;
										
										END IF;
										
								END FOREACH;
                                                                
                                IF iTransaccion = 1 THEN
                                        COMMIT;
                                        BEGIN WORK;
                                ELSE
                                        COMMIT WORK;
                                END IF;
                        END IF;
                ELSE
                        LET cCodRet = '00381'; --PARAMETRO TIPO NO VALIDO
                        RETURN cCodRet, cNumSolicitud;
                END IF;
                RETURN cCodRet, cNumSolicitud;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 10/11/2014',
'DESCRIPCION: Procedimiento que obtiene el siguiente numero de solicitud de un cliente en SOE',
'BD: bdibei',
'AUTOR: Oscar Flores Conde',
'FECHA: 10/11/2014',
'DESCRIPCION: Se agregan actualizaciones a la tabla bei_usuario y bei_servicio',
'AUTOR: Oscar Flores Conde',
'FECHA: 09/01/2015',
'DESCRIPCION: Se agrega como entrada el numero de serie de token para que solo esos se cancelen';

CREATE PROCEDURE "informix".sp_soe_cargarreversarcuentatoken(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pSistema CHAR(1),
								pNumCte CHAR(20), pSucursal CHAR(4), pSecDomicilio SMALLINT, pFolioSuc CHAR (16), pCuenta CHAR(12), pMonto DECIMAL(14,2),
								pCantToken SMALLINT, pTransac CHAR(4), pTransacIva CHAR(4), pStatusToken SMALLINT)
		RETURNING CHAR(5) AS codret,
				  CHAR(10) AS numSolicitud;


	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);

	DEFINE pTransac CHAR(4);
	DEFINE pTransacIva CHAR(4);
	
	DEFINE cMensajeErr CHAR(255);
	DEFINE cDivisa CHAR(2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cTrans CHAR(4);
	DEFINE dFecha DATE;
	DEFINE mSaldo MONEY(14,2);
	DEFINE iTransaccion INTEGER;
	DEFINE iCargo INTEGER;
	DEFINE cNumSolicitud CHAR(10);
	DEFINE mIva MONEY(16,2);
	DEFINE cFolio CHAR(12);
	DEFINE iSolicitud INTEGER;
	DEFINE cSolicitud CHAR(10);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	LET pTransac = '3298'; --Se actualiza a la nueva transacción por COMISION CONTRATACION-REPOSICION TOKEN
	LET pTransacIva = '0260'; --se actualiza el número de transacción por IVA DE COMISIONES

	LET cMensajeErr = '';
	LET cDivisa  = '';
	LET cNumTarjeta  = '';
	LET cTrans   = '';
	LET dFecha = CURRENT;
	LET mSaldo = 0;
	LET iTransaccion = 0;
	LET iCargo = 0;
	LET cNumSolicitud = '';
	LET mIva = 0;
	LET cFolio = '';
	LET iSolicitud = 0;
	LET	cSolicitud = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF iTransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet, cNumSolicitud;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET iTransaccion = 1;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-255)
			LET iTransaccion = 0;
		END EXCEPTION WITH RESUME;
		BEGIN WORK;
		
		--SET DEBUG FILE TO '/tmp/viri/sp_soe_cargarreversarcuentatoken.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR  pNumCte = '' OR pSucursal = '' OR  pSecDomicilio = 0 OR pSecDomicilio = '' OR 
			pFolioSuc = '' OR pCantToken = 0 OR pCantToken = '' OR pTransac = '' OR pStatusToken = '' THEN
			LET cCodRet = '00003';
			IF iTransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet, cNumSolicitud;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSolicitud;
		END IF;
		
		IF iCargo = 1 THEN
			IF pSistema = 1 THEN
				EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal, pUsuario, pFolioSuc, 'M')
				INTO cCodRetSp;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP reversion';
				ELIF iCodRetSp = 999 THEN
					LET cCodRet = '00275'; --ESTATUS INVALIDO PARA REALIZAR LA CONSULTA
					RETURN cCodRet, cNumSolicitud;
				ELIF iCodRetSp = 413 THEN
					LET cCodRet = '00101'; --SALDO INSUFICIENTE
					RETURN cCodRet, cNumSolicitud;
				END IF;
			ELSE
				EXECUTE PROCEDURE bdicred:"informix".reversion(cEmpresa, pSucursal, pUsuario, pFolioSuc, 'M')
				INTO cCodRetSp;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP reversion';
				ELIF iCodRetSp = 431 THEN
					LET cCodRet = '00407'; --PAGO NO ES EL ULTIMO REVERSA EN ORDEN
					RETURN cCodRet, cNumSolicitud;
				END IF;
			END IF;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		
		IF iTransaccion = 1 THEN 
			ROLLBACK WORK;
			BEGIN WORK;
		ELSE
			ROLLBACK WORK;
		END IF;
		
		IF pTipo = 1 OR pTipo = 2 THEN
			IF pMonto <> 0 THEN --(SE COBRA CARGO)
				EXECUTE PROCEDURE bdibpi:"informix".sp_cons_tar_divisa( cEmpresa, pSistema, pCuenta)
				INTO cCodRetSp, cNumTarjeta, cDivisa;

				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp <> 0 THEN
					IF iTransaccion = 1 THEN
						ROLLBACK WORK;
						BEGIN WORK;
					ELSE
						ROLLBACK WORK;
					END IF;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cons_tar_divisa';
					ELIF iCodRetSp = 001 THEN
						LET cCodRet = '00003'; --FALTA ALGUN PARAMETRO DE ENTRADA
						RETURN cCodRet, cNumSolicitud;
					END IF;
				END IF;
				--LET pMonto = pCantToken * pMonto;
				SELECT valor INTO mIva FROM bdinteg:"informix".si_param WHERE cod_param = '47';
				LET pMonto = pMonto / (1+mIva); --Se quita el IVA al monto
								
				IF pSistema = 1 THEN
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa, pSucursal, pUsuario, pTransac, '0000', pFolioSuc, pCuenta, 0, pMonto, cDivisa, 'ComisiÃ³n por Token', cNumTarjeta, pCuenta)
					INTO iCodRetSp, cTrans, dFecha, mSaldo, pMonto;
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp <> 0 THEN
						IF iTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP cargo_ref';
						ELIF iCodRetSp = 004 THEN
							LET cCodRet = ''; 		--Valida fecha de proceso de la cuenta
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 999 THEN
							LET cCodRet = ''; 
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 962 OR iCodRetSp = 404 OR iCodRetSp = 200 THEN
							LET cCodRet = '00378'; 	--PRODUCTO O TRANSACCIÃ?N INVÃLIDA
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 549 THEN
							LET cCodRet = ''; 		--PEDOS CON FECHAS if (vfechoy < vfechacalendario) then
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 550 THEN
							LET cCodRet = '00405'; 	--EL NÃ?MERO DE TRANSACCIÃ?N NO CONTIENE UN TIPO DE TRANSACCIÃ?N
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 777 THEN
							LET cCodRet = '00406'; 	--LIMITE AUTORIZADO EN TARJETAS ADICIONALES
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 035 THEN
							LET cCodRet = '00404';  --'IMPORTE DE LA TRANSACCIÃ?N EXCEDE EL LÃMITE DIARIO PERMITIDO PARA EL CANAL
							RETURN cCodRet, cNumSolicitud;
						END IF;
					ELSE
						LET iCargo = 1;
						--SELECT valor INTO mIva FROM bdinteg:"informix".si_param WHERE cod_param = '47';
						--LET pMonto = pMonto * mIva;  --debe actualizar el valor del IVA.
						LET mIva = pMonto * mIva;
						EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa, pSucursal, pUsuario, pTransacIva, 0000, pFolioSuc, pCuenta, 0, mIva, cDivisa, 'ComisiÃ³n por Token', cNumTarjeta, pCuenta)
						INTO cCodRetSp, cTrans, dFecha, mSaldo, pMonto;
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp <> 0 THEN
							IF iTransaccion = 1 THEN
								ROLLBACK WORK;
								BEGIN WORK;
							ELSE
								ROLLBACK WORK;
							END IF;
							IF iCodRetSp < 0 THEN
								RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP cargo_ref';
							ELIF iCodRetSp = 004 THEN
								LET cCodRet = ''; 		--Valida fecha de proceso de la cuenta
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 999 THEN
								LET cCodRet = ''; 
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 962 OR iCodRetSp = 404 OR iCodRetSp = 200 THEN
								LET cCodRet = '00378'; 	--PRODUCTO O TRANSACCIÃ?N INVÃLIDA
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 549 THEN
								LET cCodRet = ''; 		--PEDOS CON FECHAS if (vfechoy < vfechacalendario) then
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 550 THEN
								LET cCodRet = '00405'; 	--EL NÃ?MERO DE TRANSACCIÃ?N NO CONTIENE UN TIPO DE TRANSACCIÃ?N
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 777 THEN
								LET cCodRet = '00406'; 	--LIMITE AUTORIZADO EN TARJETAS ADICIONALES
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 035 THEN
								LET cCodRet = '00404';  --'IMPORTE DE LA TRANSACCIÃ?N EXCEDE EL LÃMITE DIARIO PERMITIDO PARA EL CANAL
								RETURN cCodRet, cNumSolicitud;
							END IF;
							
							EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, pSucursal, pUsuario, pFolioSuc, 'M')
							INTO cCodRetSp;
					
							LET iCodRetSp = cCodRetSp::INTEGER;
							IF iCodRetSp < 0 THEN
								RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP reversion';
							ELIF iCodRetSp = 999 THEN
								LET cCodRet = '00275'; --ESTATUS INVALIDO PARA REALIZAR LA CONSULTA
								RETURN cCodRet, cNumSolicitud;
							ELIF iCodRetSp = 413 THEN
								LET cCodRet = '00101'; --SALDO INSUFICIENTE
								RETURN cCodRet, cNumSolicitud;
							END IF;
						END IF;
					END IF;
				ELIF pSistema = 6 THEN
					EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(cEmpresa, pSucursal, pUsuario, cNumTarjeta, pMonto,pFolioSuc, pTransac)
					INTO cCodRetSp, mSaldo, mSaldo, mIva, mIva;
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp <> 0 THEN
						IF iTransaccion = 1 THEN
							ROLLBACK WORK;
							BEGIN WORK;
						ELSE
							ROLLBACK WORK;
						END IF;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP cargoref_tc_ofi';
						ELIF iCodRetSp = 008 THEN
							LET cCodRet = '00046'; --EL NUMERO DE CREDITO NO EXISTE
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 206 THEN
							LET cCodRet = '00401'; --EL CRÃ?DITO NO PERTENECE A UNA TARJETA DE CRÃ?DITO
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 207 THEN
							LET cCodRet = '00018'; --CRÃ?DITO BLOQUEADO MANUALMENTE FAVOR DE VERIFICAR
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 199 THEN
							LET cCodRet = '00402'; --BLOQUEO POR PRODUCTO
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 208 THEN
							LET cCodRet = '00023'; --EL CLIENTE NO TIENE TARJETAS ASIGNADAS
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 005 THEN
							LET cCodRet = '00403'; --EL SALDO ES MENOR AL MONTO DE MOVIMIENTO
							RETURN cCodRet, cNumSolicitud;
						ELIF iCodRetSp = 035 THEN
							LET cCodRet = '00404'; --IMPORTE DE LA TRANSACCIÃ?N EXCEDE EL LÃMITE DIARIO PERMITIDO PARA EL CANAL
							RETURN cCodRet, cNumSolicitud;
						END IF;
					ELSE
						LET iCargo = 1;
					END IF;
				END IF;
			ELSE--(NO SE COBRA CARGO)
				LET pFolioSuc = 'SINCOMIS' || SUBSTR(pFolioSuc, 9, 8);
			END IF;
			IF pStatusToken = 0 THEN
				LET pStatusToken = 100;
				SELECT MAX(solicitud::INTEGER) INTO iSolicitud FROM bdibei:"informix".bei_solicitudtoken;
				
				LET iSolicitud = iSolicitud + 1;
				LET cSolicitud = LPAD(iSolicitud, 10, 0);
				LET cNumSolicitud = cSolicitud;
				
				--Se pone la secuencia del domicilio forzado para que se inserte el correcto.
				SELECT secuencia INTO pSecDomicilio FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte AND tipo_dir ='1';
				
				INSERT INTO bdibei:"informix".bei_solicitudtoken
				(solicitud, numcte, id_status, unidades, sucursal, f_solicitud, f_atencion, sec_domicilio, usr_solicita, usr_atiende, folio_suc)
				VALUES
				(cSolicitud, pNumCte, pStatusToken, pCantToken, pSucursal, CURRENT, CURRENT, pSecDomicilio, pUsuario, cEmpresa, pFolioSuc);
				IF iTransaccion = 1 THEN
					COMMIT;
					BEGIN WORK;
				ELSE
					COMMIT WORK;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '00381'; --PARAMETRO TIPO NO VALIDO
			RETURN cCodRet, cNumSolicitud;
		END IF;
		RETURN cCodRet, cNumSolicitud;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 10/11/2014',
'DESCRIPCION: Procedimiento que obtiene el siguiente numero de solicitud de un cliente en SOE',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_cons_archivobatch_bei(pIdEvaluacion INTEGER)
returning CHAR(5), INTEGER, char(10), char(17), char(10), INTEGER,MONEY, char(10),char(20),INTEGER,INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Consulta los archivos de dispersión en proceso batch
-- AUTOR : SOLSER 
-- FECHA : 08/MARZO/2016
-- BD: bdibei
-- SOLICITO : BanCoppel - Cordinacion Internet - G3
-- FECHA DE LIBERACIÓN: 
--***************************************************************************************************

    DEFINE cod_ret      char(5);
    DEFINE sql_err      integer ;
	DEFINE iId_evaluacion   	INTEGER;
    DEFINE vConcepto        	char(10);
    DEFINE vArchivo             char(17);
    DEFINE vhora_alta           char(10);
	DEFINE iCant_empleados  	INTEGER;
	DEFINE mImporte         	MONEY;
	DEFINE vFecha_aplicacion	char(10);
	DEFINE vCta_origen      	char(20);
    DEFINE iNumCtasO            INTEGER;
    DEFINE iNumCtasB            INTEGER;

    LET cod_ret     = "00000";
    LET iId_evaluacion = 0;
    LET vFecha_aplicacion  = '';
    LET vCta_origen ='';
    LET iCant_empleados=0;
    LET vConcepto='';
    LET mImporte=0;
    LET vArchivo = '';
    LET vhora_alta='';
    LET iNumCtasO = 0;
    LET iNumCtasB = 0;
	 
 BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        let cod_ret = sql_err;
        RETURN cod_ret, NVL(iId_evaluacion,0),NVL(vConcepto,''), NVL(vArchivo,''),NVL(vhora_alta,''),NVL(iCant_empleados,0), NVL(mImporte,0), NVL(vFecha_aplicacion,''),NVL(vCta_origen,''),NVL(iNumCtasB,0),NVL(iNumCtasO,0);
      END IF ;
   END EXCEPTION ;


	IF NVL(pIdEvaluacion,0) == 0 THEN
        LET cod_ret = '001'; 
        RETURN cod_ret, NVL(iId_evaluacion,0),NVL(vConcepto,''), NVL(vArchivo,''),NVL(vhora_alta,''),NVL(iCant_empleados,0), NVL(mImporte,0), NVL(vFecha_aplicacion,''),NVL(vCta_origen,''),NVL(iNumCtasB,0),NVL(iNumCtasO,0);
	END IF;

    SET LOCK MODE TO WAIT 4;


   SELECT   id_evaluacion,TO_CHAR(fecha_aplicacion,'%d/%m/%Y'),cta_origen,cant_empleados,concepto,importe,nom_tem_archivo,TO_CHAR(fecha_alta,'%H:%M'), numctasb, numctaso
    INTO    iId_evaluacion, vFecha_aplicacion, vCta_origen ,iCant_empleados,vConcepto,  mImporte, vArchivo,vhora_alta,iNumCtasB,iNumCtasO
    FROM    bdibei:"informix".bei_archivos_eval
   WHERE    id_evaluacion = pIdEvaluacion;

    IF  NVL(vArchivo,'') == '' THEN
      LET cod_ret = '002'; 
    END IF;

    RETURN cod_ret, NVL(iId_evaluacion,0),NVL(vConcepto,''), NVL(vArchivo,''),NVL(vhora_alta,''),NVL(iCant_empleados,0), NVL(mImporte,0), NVL(vFecha_aplicacion,''),NVL(vCta_origen,''),NVL(iNumCtasB,0),NVL(iNumCtasO,0);

END
END PROCEDURE;