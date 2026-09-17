CREATE PROCEDURE "informix".sp_cap_cancelacta_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10), pTrama LVARCHAR)
	RETURNING CHAR(5) AS codret, INTEGER AS total_canceladas, INTEGER AS total_no_canceladas;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_PosPipe INT;
	DEFINE v_FechaHoy DATE;
	DEFINE v_Sucursal CHAR(4);
	DEFINE v_TipoSucursal CHAR(1);
	DEFINE v_ClavePagoProgramado CHAR(20);
	DEFINE v_Contador INTEGER;
	DEFINE v_Dec CHAR(5);
	DEFINE v_FolioCancelacion  VARCHAR(40);
	DEFINE v_Year              CHAR(4);
	DEFINE v_Month             CHAR(2);
	DEFINE v_Day               CHAR(2);
	DEFINE v_Hour              CHAR(2);
	DEFINE v_Minute            CHAR(2);
	DEFINE v_Second            CHAR(2);
	DEFINE v_PromotorPadded    CHAR(8); 
	DEFINE v_RespuestaProcesoCanc BOOLEAN;
	DEFINE v_CodRetProceso 		CHAR(5);
	
	DEFINE v_TramaRestante VARCHAR(100); 
	DEFINE v_ParCompleto   VARCHAR(40);
	DEFINE i INTEGER;
	DEFINE v_Char CHAR(1);
	DEFINE v_PosSeparador INTEGER; 
	DEFINE v_ContadorCuentasCanc INTEGER;
	DEFINE v_ContadorCuentasNoCanc INTEGER;
	DEFINE v_FechaActual DATETIME YEAR TO SECOND;
	DEFINE v_FechaNueva DATETIME YEAR TO SECOND;
	DEFINE v_Intervalo INTERVAL SECOND TO SECOND;	
	DEFINE v_PosPipe1 INTEGER;
	DEFINE v_PosPipe2 INTEGER;
	DEFINE v_Cliente CHAR(20);
	DEFINE v_Cuenta CHAR(20);
	
	LET cCodRet = '00000';
	LET v_RespuestaProcesoCanc = 'f';
	LET iSqlErr = 0;
	LET v_Cuenta = '';
	LET v_Cliente = '';
	LET v_PosPipe = 0;
	LET v_FechaHoy = TODAY;
	LET v_Sucursal = '';
	LET v_TipoSucursal = '';
	LET v_ClavePagoProgramado = '';
	LET v_Contador = 0;
	LET v_Dec = '';
	LET v_Year = YEAR(TODAY);    
	LET v_ContadorCuentasCanc = 0;
	LET v_ContadorCuentasNoCanc = 0;
	LET v_CodRetProceso = '00000';
	LET v_FechaActual = CURRENT;
	LET v_FechaNueva = CURRENT;
	LET v_Second = '';
	-- InicializaciÃ³n y limpieza
	LET v_TramaRestante = TRIM(pTrama); 
	LET i = 1;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
		RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;

		END EXCEPTION;
		DROP TABLE IF EXISTS temp_cuentas;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_cap_cancelacta_masiva.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTrama = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		CREATE TEMP TABLE temp_cuentas (
			cuenta    CHAR(20),
			cliente   CHAR(20)
		) WITH NO LOG;
	
		LET v_TramaRestante = TRIM(pTrama); 
		LET i = 1;

		WHILE LENGTH(v_TramaRestante) > 0

			SELECT INSTR(v_TramaRestante, '|') INTO v_PosPipe1 FROM systables WHERE tabid = 1;

			IF v_PosPipe1 = 0 THEN
				LET v_TramaRestante = '';
				EXIT WHILE;
			END IF;

			LET v_Cliente = SUBSTR(v_TramaRestante, 1, v_PosPipe1 - 1);

			SELECT 
				INSTR(SUBSTR(v_TramaRestante, v_PosPipe1 + 1), '|') 
			INTO 
				v_PosPipe2 
			FROM systables 
			WHERE tabid = 1;

			IF v_PosPipe2 = 0 THEN
				LET v_Cuenta = SUBSTR(v_TramaRestante, v_PosPipe1 + 1); 
				
				INSERT INTO temp_cuentas (cliente, cuenta) VALUES (TRIM(v_Cliente), TRIM(v_Cuenta));
				
				LET v_TramaRestante = '';
			ELSE
				LET v_Cuenta = SUBSTR(v_TramaRestante, v_PosPipe1 + 1, v_PosPipe2 - 1);
				INSERT INTO temp_cuentas (cliente, cuenta) VALUES (TRIM(v_Cliente), TRIM(v_Cuenta));
				LET v_TramaRestante = SUBSTR(v_TramaRestante, v_PosPipe1 + v_PosPipe2 + 1);
			END IF;
		END WHILE
		
		
		FOREACH
			SELECT * INTO v_Cuenta, v_Cliente 
			FROM temp_cuentas
			EXECUTE PROCEDURE bdicnweb:sp_valida_cuentacan(pUsuario, pIdFuncion, v_Cuenta) 
			INTO v_CodRetProceso, v_RespuestaProcesoCanc;
			
			IF v_RespuestaProcesoCanc = 't' THEN
				UPDATE bdicheq:sc_maechq 
				SET status_cta = '2', motivo = '15', fec_cancelac = v_FechaHoy 
				WHERE cuenta = v_Cuenta;
				
				UPDATE bdicheq:sc_contch 
				SET estado = 'C' 
				WHERE cuenta = v_Cuenta AND estado = 'A';
				
				SELECT sucursal 
				INTO v_Sucursal 
				FROM bdinteg:si_cliente 
				WHERE numcte = v_Cliente;
				
				SELECT tpo_sucursal 
				INTO v_TipoSucursal
				FROM bdinteg:si_sucursales 
				WHERE sucursal = v_Sucursal;
				
				FOREACH
					SELECT cve_pagoprog 
					INTO v_ClavePagoProgramado 
					FROM bdiprog:pp_pagoprog 
					WHERE num_cte=v_Cliente AND cuenta_origen = v_Cuenta AND cve_estado = '01'
					
					LET v_Contador = v_Contador + 1;
				END FOREACH;
				
				IF v_Contador>0 THEN
					LET v_Contador = 0;
					FOREACH
						SELECT DECODE(v_TipoSucursal, 'S', '01', 'N', '02', '')
						INTO v_Dec
						FROM bdinteg:si_sucursales
						WHERE sucursal = v_Sucursal
						LET v_Contador = v_Contador + 1;
					END FOREACH;
					IF v_Contador>0 THEN
						EXECUTE PROCEDURE bdiprog:sp_cancelaprogramacion ('02', v_Cliente, v_Dec, v_ClavePagoProgramado, 0, pUsuario);
						LET v_PromotorPadded = LPAD(pUsuario, 8, '0');
						LET v_FolioCancelacion = v_PromotorPadded || v_Year || v_Month || v_Day || v_Hour || v_Minute || v_Second;
					END IF;					
				END IF;
				
				LET v_FechaNueva = v_FechaActual + INTERVAL (1) SECOND TO SECOND;
				LET v_FechaActual = v_FechaNueva;
				LET v_Year = TO_CHAR(v_FechaNueva, '%Y');
				LET v_Month = TO_CHAR(v_FechaNueva, '%m');
				LET v_Day =	TO_CHAR(v_FechaNueva, '%d');
				LET v_Hour = TO_CHAR(v_FechaNueva, '%H');
				LET v_Minute = TO_CHAR(v_FechaNueva, '%M');
				LET v_Second = TO_CHAR(v_FechaNueva, '%S');
				LET v_PromotorPadded = LPAD(pUsuario, 8, '0');
				LET v_FolioCancelacion = v_PromotorPadded || v_Year || v_Month || v_Day || v_Hour || v_Minute || v_Second;
				UPDATE bdicheq:si_cliente_cancela_notifica 
				SET folio_cancelacion = v_FolioCancelacion, status = '2', fecha_cancelacion = v_FechaNueva, usuario_cancela = pUsuario 
				WHERE no_cuenta = v_Cuenta;
				
				LET v_ContadorCuentasCanc = v_ContadorCuentasCanc + 1;
			ELSE
				--ELIMINA LA REFERENCIA DE LA TABLA DE TRABAJO
				DELETE FROM bdicheq:si_cliente_cancela_notifica
				WHERE status = '' AND no_cliente = v_Cliente  AND no_cuenta = v_Cuenta;
				
				LET v_ContadorCuentasNoCanc = v_ContadorCuentasNoCanc + 1;
			END IF;
			
		END FOREACH;
		RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de realiza la cancelacion de las cuentas de forma masiva',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_conemppru(id_usuarioc CHAR(8), id_funcionc CHAR(10), p_Bandera CHAR(2), pNumCliente CHAR(20), pEsEmpresaPrueba CHAR(1), pNoCuenta CHAR(11))
	RETURNING CHAR(5) AS codret, CHAR(20) AS no_cliente, CHAR(1) AS es_empresa_prueba;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	

	DEFINE v_fecha_hora_alta DATETIME YEAR TO SECOND;
	DEFINE v_fecha_hora_modifica DATETIME YEAR TO SECOND;
	
	DEFINE vConteo INTEGER;
	DEFINE vNoCliente CHAR(20);
	DEFINE vEsEmpresaPrueba CHAR(1);LET v_fecha_hora_alta = CURRENT;
	LET v_fecha_hora_modifica = CURRENT;

	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	LET vConteo = 0;
	LET vNoCliente = '';
	LET vEsEmpresaPrueba = 'f';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/EAPT/sp_cap_conemppru.out';
		-- TRACE ON;
		
		IF p_Bandera='' OR id_usuarioc = '' OR id_funcionc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(id_usuarioc, id_funcionc) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF p_Bandera = '1' THEN
			IF pNumCliente = '' OR pNumCliente IS NULL  THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
			VALUES (pNumCliente, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
			RETURN cCodRet, pNumCliente, pEsEmpresaPrueba;
		ELIF p_Bandera = '2' THEN
			IF pNumCliente = '' OR pEsEmpresaPrueba = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			
			SELECT COUNT(*) 
			INTO vConteo 
			FROM bdicheq:si_cliente_emp_pru 
			WHERE no_cliente = pNumCliente;
			
			IF NVL(vConteo,0) = 0 THEN
				INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, no_cuenta, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
				VALUES (pNumCliente, pNoCuenta, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
			ELSE
				UPDATE bdicheq:si_cliente_emp_pru 
				SET es_empresa_prueba = pEsEmpresaPrueba, usuario_modifica = id_usuarioc, fecha_hora_modifica = v_fecha_hora_modifica
				WHERE no_cliente = pNumCliente;
			END IF;
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		ELIF p_Bandera = '3' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			SELECT COUNT(*) INTO vConteo FROM bdicheq:si_cliente_emp_pru WHERE no_cliente = pNumCliente;
			IF vConteo<=0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			ELSE
				SELECT no_cliente, es_empresa_prueba
				INTO vNoCliente, vEsEmpresaPrueba
				FROM bdicheq:si_cliente_emp_pru
				WHERE no_cliente = pNumCliente;
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			
			END IF;
		ELIF p_Bandera = '4' THEN
			IF pNumCliente = '' OR pNoCuenta='' OR pEsEmpresaPrueba='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			IF pEsEmpresaPrueba = 't' THEN
				INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, no_cuenta, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
				VALUES (pNumCliente, pNoCuenta, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
	
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento encargado de realizar la consulta, insercion y actualizacion de clientes de tipo prueba.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_notifica_ctecta_can(pNumCte CHAR(20), pNumCta CHAR(20), pFechaUltMov DATE, pSaldo MONEY)
	RETURNING CHAR(5) AS codret;
	
	DEFINE iSqlErr INTEGER;
	DEFINE v_Ejecutivo CHAR(8);
	DEFINE v_Funcion CHAR(8);
	DEFINE cCodRet CHAR(5);
	DEFINE v_CodRet CHAR(5);
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_NumCte CHAR(20);
	DEFINE v_Saldo MONEY;
	DEFINE v_FechaUltimoMov DATE;
	DEFINE v_IdPlantilla CHAR(12);
	DEFINE v_CodRetRegistraEvento CHAR(5);

	LET iSqlErr = 0;
	LET v_Ejecutivo = 'informix';
	LET v_Funcion = 'CCN001';
	LET cCodRet = '00017';
	LET v_CodRet = '00000';
	LET v_Cuenta = '';
	LET v_NumCte = '';
	LET v_Saldo = 0;
	LET v_FechaUltimoMov = CURRENT;
	LET v_IdPlantilla = '121212';
	LET v_CodRetRegistraEvento = '00000';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;

		END EXCEPTION;
		
		 --SET DEBUG FILE TO '/tmp/mfinis/sp_extrae_cuentascan.out';
		 --TRACE ON;
		
		IF pNumCte = '' OR pNumCta = '' OR pFechaUltMov IS NULL OR pSaldo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_extrae_cuentascan(v_Ejecutivo, v_Funcion) 
			INTO v_CodRet, v_Cuenta, v_NumCte, v_Saldo, v_FechaUltimoMov
			IF v_CodRet = '00000' THEN
				EXECUTE PROCEDURE bdinteg:sp_registra_evento ('1', '', v_IdPlantilla, v_NumCte, v_Cuenta, '', '', '', '', '', '', '', '', '', '', '', '', '', '', v_Saldo, 0,
				0, 0, 0, '', '') 
				INTO v_CodRetRegistraEvento;
				
				IF v_CodRetRegistraEvento = '00000' THEN
					INSERT INTO bdicheq:"informix".si_cliente_cancela_notifica(no_cliente, no_cuenta, fec_ultimo_mov, saldo, cliente_notificado, fecha_notificacion, folio_cancelacion, status, 
								fecha_cancelacion, usuario_cancela )
					VALUES(v_NumCte, v_Cuenta, v_FechaUltimoMov, v_Saldo, 't', CURRENT, '', '0', '', '');
				ELSE
					INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
					VALUES(v_CodRetRegistraEvento, CURRENT);
				END IF;
			ELSE 
				INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
				VALUES(v_CodRet, CURRENT);
			END IF;
		END FOREACH;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'FUNCIONALIDAD: Componente NotificaciÃ³n de Correo ElectrÃ³nico ',
'DESCRIPCION: Procedimiento almacenado encargado de recuperar las cuentas que se deben de notificar para el proceso de cancelacion',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_extrae_cuentascan(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret, CHAR(20) AS Cuenta, CHAR(20) AS num_cte, MONEY AS saldo, DATE AS fecha_ultimo_movimiento;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_Cliente CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_SdoActual MONEY;
	DEFINE v_SdoCongelado MONEY;
	DEFINE v_LimSbgCCC MONEY;
	DEFINE v_ImpChqSbg MONEY;
	DEFINE v_ComPendiente MONEY;
	DEFINE v_FecUltMov DATE;
	DEFINE v_Producto CHAR(4);
	DEFINE v_ProdNoCancelacion INTEGER;
	DEFINE anio_actual INTEGER;
    DEFINE anio_pasado INTEGER;
    DEFINE mes_actual INTEGER;
	DEFINE v_Anio SMALLINT;
	
	DEFINE v_capvigprom1 MONEY; 
	DEFINE v_capvigprom2 MONEY;
	DEFINE v_capvigprom3 MONEY;
	DEFINE v_capvigprom4 MONEY; 
	DEFINE v_capvigprom5 MONEY;
	DEFINE v_capvigprom6 MONEY;
	DEFINE v_capvigprom7 MONEY;
	DEFINE v_capvigprom8 MONEY;
	DEFINE v_capvigprom9 MONEY;
	DEFINE v_capvigprom10 MONEY;
	DEFINE v_capvigprom11 MONEY;
	DEFINE v_capvigprom12 MONEY;
	
	DEFINE v_SaldoProm1 MONEY; 
	DEFINE v_SaldoProm2 MONEY;
	DEFINE v_SaldoProm3 MONEY;
	DEFINE v_SaldoProm4 MONEY; 
	DEFINE v_SaldoProm5 MONEY;
	DEFINE v_SaldoProm6 MONEY;
	DEFINE v_SaldoProm7 MONEY;
	DEFINE v_SaldoProm8 MONEY;
	DEFINE v_SaldoProm9 MONEY;
	DEFINE v_SaldoProm10 MONEY;
	DEFINE v_SaldoProm11 MONEY;
	DEFINE v_SaldoProm12 MONEY;
	
	DEFINE v_CreditosVigentes INTEGER;
	DEFINE v_CreditosVigentes1 INTEGER;
	DEFINE v_CreditosVigentes2 INTEGER;
	
	DEFINE v_AclaracionPendiente INTEGER;
	
	DEFINE v_Spei INTEGER;
	
	define v_EmpresaPrueba INTEGER;
	DEFINE v_CuentaFideicomiso INTEGER;
	DEFINE v_FechaActual DATE;
	
	DEFINE v_mes_actual INTEGER;
	
	DEFINE v_mes_anio_actual INTEGER;
	DEFINE v_mes_anio_anterior INTEGER;
	
	DEFINE v_SaldoPromedioTotal MONEY;
	
	DEFINE v_SaldoSobregirado MONEY;
	DEFINE v_SaldoActual MONEY;
	
	DEFINE v_SaldoActualSegVal MONEY;
	DEFINE v_SaldoCuenta MONEY;
	DEFINE v_CodRetRegistraEvento CHAR(5);
	DEFINE v_TotalRegCan	INTEGER;
	DEFINE cStatus_Cta	CHAR(1);

    LET v_FechaActual = TODAY;    
    LET mes_actual = MONTH(v_FechaActual);	
	LET v_capvigprom1 = 0; 
	LET v_capvigprom2 = 0;
	LET v_capvigprom3 = 0;
	LET v_capvigprom4 = 0; 
	LET v_capvigprom5 = 0;
	LET v_capvigprom6 = 0;
	LET v_capvigprom7 = 0;
	LET v_capvigprom8 = 0;
	LET v_capvigprom9 = 0;
	LET v_capvigprom10 = 0;
	LET v_capvigprom11 = 0;
	LET v_capvigprom12 = 0;
	
	LET v_SaldoProm1 = 0; 
	LET v_SaldoProm2 = 0;
	LET v_SaldoProm3 = 0;
	LET v_SaldoProm4 = 0; 
	LET v_SaldoProm5 = 0;
	LET v_SaldoProm6 = 0;
	LET v_SaldoProm7 = 0;
	LET v_SaldoProm8 = 0;
	LET v_SaldoProm9 = 0;
	LET v_SaldoProm10 = 0;
	LET v_SaldoProm11 = 0;
	LET v_SaldoProm12 = 0;
	
	LET v_SaldoPromedioTotal = 0;
	
	LET v_Anio = 0;
	
	LET v_mes_anio_actual = 0;
	LET v_mes_anio_anterior = 0;

	LET v_Cuenta = '';
	LET v_Cliente  = '';
	LET v_RazonSocial = '';
	LET v_SdoActual = 0;
	LET v_SdoCongelado = 0;
	LET v_LimSbgCCC = 0;
	LET v_ImpChqSbg = 0;
	LET v_ComPendiente = 0;
	LET v_FecUltMov = CURRENT;
	LET v_Producto = '0000';
	LET v_ProdNoCancelacion = 0;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	
	LET v_SaldoSobregirado = 0;
	LET v_SaldoActual = 0;
	
	LET v_CreditosVigentes = 0;
	LET v_CreditosVigentes1 = 0;
	LET v_CreditosVigentes2 = 0;
	
	LET v_SaldoActualSegVal = 0;
	LET v_SaldoCuenta = 0;
	
	LET v_AclaracionPendiente = 0;
	LET v_EmpresaPrueba = 0;
	LET v_CuentaFideicomiso = 0;
	
	LET v_Spei = 0;
	LET v_CodRetRegistraEvento = '00000';
	LET v_TotalRegCan = 0;
	LET cStatus_Cta = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_extrae_cuentascan.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END IF;		
		
		/*EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END IF;*/
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT chq.cuenta, cli.numcte, cli.razon_social, chq.sdo_actual, chq.sdo_cong, chq.lim_sbg_ccc, chq.imp_chq_sbg, chq.com_pendiente, chq.fec_ult_mov, chq.producto, chq.status_cta
			INTO v_Cuenta, v_Cliente, v_RazonSocial, v_SdoActual, v_SdoCongelado, v_LimSbgCCC, v_ImpChqSbg, v_ComPendiente, v_FecUltMov, v_Producto, cStatus_Cta
			FROM bdinteg:si_cliente cli
			INNER JOIN bdicheq:sc_maechq chq ON cli.numcte = chq.num_cte
			WHERE chq.producto IN ('1200','1600','2200','2600') AND cli.tpo_persona='02' AND chq.status_cta NOT IN('3','2','5') 
			AND chq.fec_ult_mov <= (TODAY - DAY(TODAY) UNITS DAY) - 12 UNITS MONTH
			
			SELECT COUNT(*) 
			INTO v_ProdNoCancelacion 
			FROM bdicheq:sc_productonocancelacion 
			WHERE producto = v_Producto;
			
			IF NVL(v_ProdNoCancelacion,0) = 0 THEN
				LET v_mes_anio_actual = mes_actual - 1;
				LET v_mes_anio_anterior = 12 - v_mes_anio_actual;
				FOREACH
					SELECT
						capvigprom1, capvigprom2, capvigprom3, capvigprom4, capvigprom5, 
						capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, 
						capvigprom11, capvigprom12, anio
					INTO 
						v_capvigprom1, v_capvigprom2, v_capvigprom3, v_capvigprom4, v_capvigprom5,
						v_capvigprom6, v_capvigprom7, v_capvigprom8, v_capvigprom9, v_capvigprom10,
						v_capvigprom11, v_capvigprom12, v_Anio
					FROM 
						bdicheq:sc_sdomensualc
					WHERE
						cuenta = v_Cuenta
					AND				
						(anio = YEAR(v_FechaActual - 12 UNITS MONTH)
					OR
						anio = YEAR(v_FechaActual - 1 UNITS MONTH))
						
					IF v_Anio = YEAR(v_FechaActual - 1) THEN
						IF v_mes_anio_anterior = 1 THEN
							LET v_SaldoProm1 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 2 THEN
							LET v_SaldoProm1 = v_capvigprom11;
							LET v_SaldoProm2 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 3 THEN
							LET v_SaldoProm1 = v_capvigprom10;
							LET v_SaldoProm2 = v_capvigprom11;
							LET v_SaldoProm3 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 4 THEN
							LET v_SaldoProm1 = v_capvigprom9;
							LET v_SaldoProm2 = v_capvigprom10;
							LET v_SaldoProm3 = v_capvigprom11;
							LET v_SaldoProm4 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 5 THEN
							LET v_SaldoProm1 = v_capvigprom8;
							LET v_SaldoProm2 = v_capvigprom9;
							LET v_SaldoProm3 = v_capvigprom10;
							LET v_SaldoProm4 = v_capvigprom11;
							LET v_SaldoProm5 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 6 THEN
							LET v_SaldoProm1 = v_capvigprom7;
							LET v_SaldoProm2 = v_capvigprom8;
							LET v_SaldoProm3 = v_capvigprom9;
							LET v_SaldoProm4 = v_capvigprom10;
							LET v_SaldoProm5 = v_capvigprom11;
							LET v_SaldoProm6 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 7 THEN
							LET v_SaldoProm1 = v_capvigprom6;
							LET v_SaldoProm2 = v_capvigprom7;
							LET v_SaldoProm3 = v_capvigprom8;
							LET v_SaldoProm4 = v_capvigprom9;
							LET v_SaldoProm5 = v_capvigprom10;
							LET v_SaldoProm6 = v_capvigprom11;
							LET v_SaldoProm7 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 8 THEN
							LET v_SaldoProm1 = v_capvigprom5;
							LET v_SaldoProm2 = v_capvigprom6;
							LET v_SaldoProm3 = v_capvigprom7;
							LET v_SaldoProm4 = v_capvigprom8;
							LET v_SaldoProm5 = v_capvigprom9;
							LET v_SaldoProm6 = v_capvigprom10;
							LET v_SaldoProm7 = v_capvigprom11;
							LET v_SaldoProm8 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 9 THEN
							LET v_SaldoProm1 = v_capvigprom4;
							LET v_SaldoProm2 = v_capvigprom5;
							LET v_SaldoProm3 = v_capvigprom6;
							LET v_SaldoProm4 = v_capvigprom7;
							LET v_SaldoProm5 = v_capvigprom8;
							LET v_SaldoProm6 = v_capvigprom9;
							LET v_SaldoProm7 = v_capvigprom10;
							LET v_SaldoProm8 = v_capvigprom11;
							LET v_SaldoProm9 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 10 THEN
							LET v_SaldoProm1 = v_capvigprom3;
							LET v_SaldoProm2 = v_capvigprom4;
							LET v_SaldoProm3 = v_capvigprom5;
							LET v_SaldoProm4 = v_capvigprom6;
							LET v_SaldoProm5 = v_capvigprom7;
							LET v_SaldoProm6 = v_capvigprom8;
							LET v_SaldoProm7 = v_capvigprom9;
							LET v_SaldoProm8 = v_capvigprom10;
							LET v_SaldoProm9 = v_capvigprom11;
							LET v_SaldoProm10 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 11 THEN
							LET v_SaldoProm1 = v_capvigprom2;
							LET v_SaldoProm2 = v_capvigprom3;
							LET v_SaldoProm3 = v_capvigprom4;
							LET v_SaldoProm4 = v_capvigprom5;
							LET v_SaldoProm5 = v_capvigprom6;
							LET v_SaldoProm6 = v_capvigprom7;
							LET v_SaldoProm7 = v_capvigprom8;
							LET v_SaldoProm8 = v_capvigprom9;
							LET v_SaldoProm9 = v_capvigprom10;
							LET v_SaldoProm10 = v_capvigprom11;
							LET v_SaldoProm11 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 12 THEN
							LET v_SaldoProm1 = v_capvigprom1;
							LET v_SaldoProm2 = v_capvigprom2;
							LET v_SaldoProm3 = v_capvigprom3;
							LET v_SaldoProm4 = v_capvigprom4;
							LET v_SaldoProm5 = v_capvigprom5;
							LET v_SaldoProm6 = v_capvigprom6;
							LET v_SaldoProm7 = v_capvigprom7;
							LET v_SaldoProm8 = v_capvigprom8;
							LET v_SaldoProm9 = v_capvigprom9;
							LET v_SaldoProm10 = v_capvigprom10;
							LET v_SaldoProm11 = v_capvigprom11;
							LET v_SaldoProm12 = v_capvigprom12;
						END IF;
					ELIF v_Anio = YEAR(v_FechaActual) THEN
						IF v_mes_anio_actual = 1 THEN
							LET v_SaldoProm12 = v_capvigprom1;
						ELIF v_mes_anio_actual = 2 THEN
							LET v_SaldoProm11 = v_capvigprom1;
							LET v_SaldoProm12 = v_capvigprom2;
						ELIF v_mes_anio_actual = 3 THEN
							LET v_SaldoProm10 = v_capvigprom1;
							LET v_SaldoProm11 = v_capvigprom2;
							LET v_SaldoProm12 = v_capvigprom3;
						ELIF v_mes_anio_actual = 4 THEN
							LET v_SaldoProm9 = v_capvigprom1;
							LET v_SaldoProm10 = v_capvigprom2;
							LET v_SaldoProm11 = v_capvigprom3;
							LET v_SaldoProm12 = v_capvigprom4;
						ELIF v_mes_anio_actual = 5 THEN
							LET v_SaldoProm8 = v_capvigprom1;
							LET v_SaldoProm9 = v_capvigprom2;
							LET v_SaldoProm10 = v_capvigprom3;
							LET v_SaldoProm11 = v_capvigprom4;
							LET v_SaldoProm12 = v_capvigprom5;
						ELIF v_mes_anio_actual = 6 THEN
							LET v_SaldoProm7 = v_capvigprom1;
							LET v_SaldoProm8 = v_capvigprom2;
							LET v_SaldoProm9 = v_capvigprom3;
							LET v_SaldoProm10 = v_capvigprom4;
							LET v_SaldoProm11 = v_capvigprom5;
							LET v_SaldoProm12 = v_capvigprom6;
						ELIF v_mes_anio_actual = 7 THEN
							LET v_SaldoProm6 = v_capvigprom1;
							LET v_SaldoProm7 = v_capvigprom2;
							LET v_SaldoProm8 = v_capvigprom3;
							LET v_SaldoProm9 = v_capvigprom4;
							LET v_SaldoProm10 = v_capvigprom5;
							LET v_SaldoProm11 = v_capvigprom6;
							LET v_SaldoProm12 = v_capvigprom7;
						ELIF v_mes_anio_actual = 8 THEN
							LET v_SaldoProm5 = v_capvigprom1;
							LET v_SaldoProm6 = v_capvigprom2;
							LET v_SaldoProm7 = v_capvigprom3;
							LET v_SaldoProm8 = v_capvigprom4;
							LET v_SaldoProm9 = v_capvigprom5;
							LET v_SaldoProm10 = v_capvigprom6;
							LET v_SaldoProm11 = v_capvigprom7;
							LET v_SaldoProm12 = v_capvigprom8;
						ELIF v_mes_anio_actual = 9 THEN
							LET v_SaldoProm4 = v_capvigprom1;
							LET v_SaldoProm5 = v_capvigprom2;
							LET v_SaldoProm6 = v_capvigprom3;
							LET v_SaldoProm7 = v_capvigprom4;
							LET v_SaldoProm8 = v_capvigprom5;
							LET v_SaldoProm9 = v_capvigprom6;
							LET v_SaldoProm10 = v_capvigprom7;
							LET v_SaldoProm11 = v_capvigprom8;
							LET v_SaldoProm12 = v_capvigprom9;
						ELIF v_mes_anio_actual = 10 THEN
							LET v_SaldoProm3 = v_capvigprom1;
							LET v_SaldoProm4 = v_capvigprom2;
							LET v_SaldoProm5 = v_capvigprom3;
							LET v_SaldoProm6 = v_capvigprom4;
							LET v_SaldoProm7 = v_capvigprom5;
							LET v_SaldoProm8 = v_capvigprom6;
							LET v_SaldoProm9 = v_capvigprom7;
							LET v_SaldoProm10 = v_capvigprom8;
							LET v_SaldoProm11 = v_capvigprom9;
							LET v_SaldoProm12 = v_capvigprom10;
						ELIF v_mes_anio_actual = 11 THEN
							LET v_SaldoProm2 = v_capvigprom1;
							LET v_SaldoProm3 = v_capvigprom2;
							LET v_SaldoProm4 = v_capvigprom3;
							LET v_SaldoProm5 = v_capvigprom4;
							LET v_SaldoProm6 = v_capvigprom5;
							LET v_SaldoProm7 = v_capvigprom6;
							LET v_SaldoProm8 = v_capvigprom7;
							LET v_SaldoProm9 = v_capvigprom8;
							LET v_SaldoProm10 = v_capvigprom9;
							LET v_SaldoProm11 = v_capvigprom10;
							LET v_SaldoProm12 = v_capvigprom11;
						ELIF v_mes_anio_actual = 12 THEN
							LET v_SaldoProm1 = v_capvigprom1;
							LET v_SaldoProm2 = v_capvigprom2;
							LET v_SaldoProm3 = v_capvigprom3;
							LET v_SaldoProm4 = v_capvigprom4;
							LET v_SaldoProm5 = v_capvigprom5;
							LET v_SaldoProm6 = v_capvigprom6;
							LET v_SaldoProm7 = v_capvigprom7;
							LET v_SaldoProm8 = v_capvigprom8;
							LET v_SaldoProm9 = v_capvigprom9;
							LET v_SaldoProm10 = v_capvigprom10;
							LET v_SaldoProm11 = v_capvigprom11;
							LET v_SaldoProm12 = v_capvigprom12;
						END IF;
					END IF;
					
				END FOREACH
				LET v_SaldoPromedioTotal = v_capvigprom1 + v_capvigprom2 + v_capvigprom3 + v_capvigprom4 + v_capvigprom5 + v_capvigprom6 + v_capvigprom7 + v_capvigprom8 + v_capvigprom9 + v_capvigprom10 + v_capvigprom11 + v_capvigprom2;
				IF NVL(v_SaldoPromedioTotal,0) = 0 THEN
					FOREACH
						SELECT imp_chq_sbg, sdo_actual INTO v_SaldoSobregirado, v_SaldoActual 
						FROM bdicheq:sc_maechq WHERE cuenta = v_Cuenta AND num_cte = v_Cliente --Aqui se agrego el filtro num_cte porque devolvÃ­a mas de un registro
					END FOREACH
					IF NVL(v_SaldoSobregirado,0) = 0 THEN
						IF NVL(v_SaldoActual,0) = 0 THEN
							--Aqui va el otro calculo del saldo actual
							SELECT (cheq.sdo_actual - (cheq.sdo_retenido + cheq.sdo_cong + cheq.imp_sbg_ccc)) AS saldo_actual, bal.sdo_cta
							INTO v_SaldoActualSegVal, v_SaldoCuenta
							FROM bdicheq:sc_maechq cheq
							INNER JOIN bditransfer:tf_maecte mae ON mae.numcte_tf = cheq.num_cte
							INNER JOIN bditransfer:tf_account_balance_customer bal ON bal.cuenta = mae.cuenta_tf
							WHERE cheq.num_cte = v_Cliente  AND (mae.numcte = v_Cliente OR mae.numcte_tf = v_Cliente) AND mae.status_cta != '2' AND bal.fecha_proceso = (SELECT MAX(bal2.fecha_proceso)
						    FROM bditransfer:tf_account_balance_customer bal2
							WHERE bal2.cuenta = bal.cuenta);
							
							IF NVL(v_SaldoActualSegVal,0) = 0 AND NVL(v_SaldoCuenta,0) = 0 THEN
								SELECT COUNT(*) INTO v_CreditosVigentes FROM bdicred:sd_ctascarg WHERE num_cta = v_Cuenta AND naturaleza = naturaleza;
								IF NVL(v_CreditosVigentes,0) > 0 THEN
									SELECT count(ctascar.num_cta)
									INTO v_CreditosVigentes1
									FROM bdicred:sd_ctascarg ctascar
									INNER JOIN bdicred:sd_maecred cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
									WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
									
									SELECT count(ctascar.num_cta)
									INTO v_CreditosVigentes2
									FROM bdicred:sd_ctascarg ctascar
									INNER JOIN bdicred:sd_maecredcrd cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
									WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
								END IF;
								-- verificar regla d ecredito vig.
								IF NVL(v_CreditosVigentes,0) = 0 and (NVL(v_CreditosVigentes1,0) = 0 and NVL(v_CreditosVigentes2,0) = 0) THEN
										SELECT count(producto.numero_cuenta)
										INTO v_AclaracionPendiente
										FROM bdiaclaracion:acl_producto producto
										INNER JOIN bdiaclaracion:acl_aclaracion aclaracion ON producto.pky_producto = aclaracion.fky_producto
										WHERE producto.numero_cuenta = v_Cuenta AND aclaracion.fky_estatus_aclaracion = '2';
										IF NVL(v_AclaracionPendiente,0) = 0 THEN -- ajuste
											SELECT COUNT(*) 
											INTO v_EmpresaPrueba
											FROM bdicnweb:si_cliente_emp_pru
											WHERE no_cliente = v_Cliente;
											
											IF NVL(v_EmpresaPrueba,0) = 0 THEN
												SELECT COUNT(*) 
												INTO v_CuentaFideicomiso
												FROM bdinteg:si_ctepm 
												WHERE numcte = v_Cliente AND 
												(giro IS NULL OR giro = '' OR actividadsocial IS NULL OR actividadsocial = '' OR sufijo IS NULL OR sufijo = '' OR telefono_contacto IS NULL OR telefono_contacto = '' 
														OR tipo_poder IS NULL OR tipo_poder = '' OR tipo_admon IS NULL OR tipo_admon = '' OR tipo_org IS NULL OR tipo_org = '');
												IF NVL(v_CuentaFideicomiso,0) = 0 THEN -- ajuste
													SELECT COUNT(*) 
													INTO v_Spei
													FROM bdicheq:sc_movdia 
													WHERE cuenta = v_Cuenta AND transacc = '0274';
													IF v_Spei = 0 THEN
														SELECT COUNT(*)
														INTO v_TotalRegCan
														FROM bdicheq:"informix".si_cliente_cancela_notifica
														WHERE no_cliente = v_Cliente AND no_cuenta = v_Cuenta;
														IF NVL(v_TotalRegCan,0) = 0 THEN 
															--Aqui se ejecuta el SPL para envio de notifiaciÃ³n
															EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CTAS_INAC','COR_CAN_CTAI',v_Cliente,v_Cuenta,'','2','5426','','','','','','','','','','','',0,0,0,0,0,CURRENT,'')
															INTO v_CodRetRegistraEvento;
															IF v_CodRetRegistraEvento = '00000' THEN
																INSERT INTO bdicheq:"informix".si_cliente_cancela_notifica(no_cliente, no_cuenta, fec_ultimo_mov, saldo, cliente_notificado, fecha_notificacion, folio_cancelacion, status, fecha_cancelacion, usuario_cancela, status_ant)
																VALUES(v_Cliente, v_Cuenta, v_FecUltMov, v_SdoActual, 't', CURRENT, '', '', '', '', cStatus_Cta);
															ELSE
																INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
																VALUES(v_CodRetRegistraEvento, CURRENT);
															END IF;
														END IF;
													END IF;
												END IF;
											END IF;
										END IF;
									--END IF;
								END IF;
							END IF;							
							--Aqui termina el calculo del saldo actual
						END IF;
					END IF;
				END IF;
			END IF;
		END FOREACH
		RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'FUNCIONALIDAD:',
'DESCRIPCION: ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_com_manejo_cta_ident_1()
    RETURNING CHAR(5), VARCHAR(80);
-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Toma un cliente y analiza sus cuentas para
--                   decidir si se le cobrara la "Comision por Manejo de
--                   Cuenta", las cuentas que deben pagar son guardadas en la
--                   tabla sc_com_manejo_ctas_a_cobrar.
-- Creado por:      Joel Martinez
-- Fecha:           Septiembre - 2024
-- *****************************************************************************
    
    DEFINE vNumHilo                 SMALLINT;
    DEFINE vCodRet                  CHAR(5);
    DEFINE vErrorInfo               VARCHAR(80);
    DEFINE vIsamErr                 SMALLINT;
    DEFINE vSQLErr                  INTEGER;
    DEFINE vEmpresa                 CHAR(3);
    DEFINE vFechaInicial            DATE;
    DEFINE vFechaFinal              DATE;
    DEFINE vAnioMes                 CHAR(6);
    DEFINE vSdoPromMinGral          INTEGER;
    DEFINE vSdoPromMin2500          INTEGER;
    DEFINE vUltimoCteHiloAnterior   CHAR(20);
    DEFINE vUltimoCteHiloActual     CHAR(20);
    DEFINE vFechConMovHis           DATE;
    DEFINE vUltimoCteProcesado      CHAR(20);
    DEFINE vFechaHoraFinIniciador   DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaHoraIni            DATETIME YEAR TO FRACTION(3);
    DEFINE vStatusPrevio            VARCHAR(10);
    DEFINE vStatusIniciador         VARCHAR(10);
    DEFINE vIndice                  SMALLINT;
    DEFINE vConfStatus              VARCHAR(60);
    DEFINE vConfProductos           VARCHAR(60);
    DEFINE vCharAux                 CHAR(1);
    DEFINE vStringAux               VARCHAR(4);
    DEFINE vExisteTMP               SMALLINT;
    DEFINE vExisteTMP2              SMALLINT;
    DEFINE vExisteTMP3              SMALLINT;
    DEFINE vExisteTMP4              SMALLINT;
    DEFINE vExisteTMP5              SMALLINT;
    DEFINE vContCtasInsertadas      INTEGER;
    DEFINE vNumCte                  CHAR(20);
    DEFINE vCuenta                  CHAR(20);
    DEFINE vSucursal                CHAR(4);
    DEFINE vCantCtasProcesadas      INTEGER;
    DEFINE vCantCtasIdentificadas   INTEGER;
    DEFINE vCantCtasInversion       SMALLINT;
    DEFINE vCantCtasPagare          SMALLINT;
    DEFINE vCantMovHis              SMALLINT;
    DEFINE vCantMovHisOld           SMALLINT;
    DEFINE cCantMovCred             SMALLINT;
    DEFINE vParamMontCargo          MONEY(14,2);
    DEFINE vArchivoSQL              CHAR(50);
    DEFINE vSQL                     CHAR(350);
   
    LET vNumHilo                = 1;
    LET vCodRet                 = "00000";
    LET vEmpresa                = "001";
    LET vErrorInfo              = '';
    LET vIsamErr                = 0;
    LET vSQLErr                 = 0; 
    LET vFechaInicial           = '';
    LET vFechaFinal             = '';
    LET vAnioMes                = '';
    LET vSdoPromMinGral         = 0;
    LET vSdoPromMin2500         = 0;
    LET vUltimoCteHiloAnterior  = '';
    LET vUltimoCteHiloActual    = ''; 
    LET vFechConMovHis          = '';
    LET vUltimoCteProcesado     = '';
    LET vFechaHoraFinIniciador  = '';
    LET vFechaHoraIni           = '';
    LET vStatusPrevio           = '';
    LET vStatusIniciador        = '';
    LET vIndice                 = 0;
    LET vConfStatus             = '';
    LET vConfProductos          = '';
    LET vCharAux                = '';
    LET vStringAux              = '';
    LET vExisteTMP              = 0;
    LET vExisteTMP2             = 0;
    LET vExisteTMP3             = 0;
    LET vExisteTMP4             = 0;
    LET vExisteTMP5             = 0;
    LET vContCtasInsertadas     = 0;
    LET vNumCte                 = '';
    LET vCuenta                 = '';
    LET vSucursal               = '';
    LET vCantCtasProcesadas     = 0;
    LET vCantCtasIdentificadas  = 0; 
    LET vCantCtasInversion      = 0;
    LET vCantCtasPagare         = 0;
    LET vCantMovHis             = 0;
    LET vCantMovHisOld          = 0;
    LET cCantMovCred            = 0;
    LET vParamMontCargo         = 150.00;
    LET vArchivoSQL             = "/resplogifx/conciliachq/updatebitacora" || vNumHilo ||".sql";
    LET vSQL                    = '';

    BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_1.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo   = vErrorInfo;
            LET vNumCte     = vNumCte;
            LET vCuenta     = vCuenta;
        
            IF vExisteTMP = 1 THEN
                DROP TABLE tmp_conf_status;
                DROP TABLE tmp_conf_productos; 
            END IF;
        
            IF vExisteTMP2 = 1 THEN
                DROP TABLE tmp_ctas_total;
                DROP TABLE tmp_ctas_cte;
            END IF;
        
            IF vExisteTMP3 = 1 THEN
                DROP TABLE tmp_ctes_exentos;
            END IF;

            IF vExisteTMP4 = 1 THEN
                DROP TABLE tmp_ctes_sin_sdo_prom;
            END IF;

            IF vExisteTMP5 = 1 THEN
                DROP TABLE tmp_ctes_sin_presperban;
            END IF;
        
            IF vContCtasInsertadas > 0 THEN
                ROLLBACK;
            END IF;
        
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_1.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
    
    /**************************************************************************/
    /*                         CONSULTA DE PARAMETROS                         */
    /**************************************************************************/
    -- El periodo a procesar, sera del primero al ultimo dia del mes anterior
    SELECT DATE( pri_dia_mes - 1 UNITS MONTH ),
    DATE( pri_dia_mes - 1 UNITS DAY )
    INTO vFechaInicial, vFechaFinal
    FROM sc_fechas
    WHERE empresa = vEmpresa;
    
    -- Extrae aÃ±o y mes que se procesara
    LET vAnioMes = TO_CHAR(vFechaInicial,"%Y%m");

    -- Saldo promedio minimo general
    SELECT valor 
    INTO vSdoPromMinGral
    FROM sc_param
    WHERE codparam = "sdoprom";

    -- Saldo promedio minimo para producto 2500
    SELECT valor 
    INTO vSdoPromMin2500
    FROM sc_param
    WHERE codparam = "sdoprom_2500";
    
    -- Obtiene el ultimo cte que atendera este hilo
    SELECT valor 
    INTO vUltimoCteHiloActual
    FROM sc_param 
    WHERE codparam = "UltCteIdentComMC" || vNumHilo;

    -- Fecha de concentrado de la tabla sc_movhis_old
    SELECT TO_DATE(valor, '%m/%d/%Y')
    INTO vFechConMovHis
    FROM sc_param 
    WHERE codparam = "fechcon_movhis";
    
    -- Se obtienen los status de las cuentas a considerar
    SELECT valor
    INTO vConfStatus
    FROM sc_param
    WHERE codparam = "IdenComMCStatus";
    
    -- Se obtienen los productos de las cuentas a considerar
    SELECT valor
    INTO vConfProductos
    FROM sc_param
    WHERE codparam = "IdenComMCProductos";
    /**************************************************************************/
    /*                      [FIN] CONSULTA DE PARAMETROS                      */
    /**************************************************************************/

    /**************************************************************************/
    /*     GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES        */
    /**************************************************************************/
    CREATE TEMP TABLE tmp_conf_status (
        status CHAR(1)) WITH NO LOG;

    CREATE TEMP TABLE tmp_conf_productos (
        producto CHAR(4)) WITH NO LOG;
    
    LET vExisteTMP = 1;

    -- Ciclo que extrae los status y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfStatus )
        LET vCharAux = SUBSTR( vConfStatus, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '5', '6', '7', '8', '9' ) THEN
            INSERT INTO tmp_conf_status ( status ) 
                VALUES ( vCharAux );
        END IF;
    END FOR;
    
    -- Ciclo que extrae los productos y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfProductos )
        LET vCharAux = SUBSTR( vConfProductos, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
            LET vStringAux = vStringAux || vCharAux;
            IF LENGTH( vStringAux ) > 3 THEN
                INSERT INTO tmp_conf_productos ( producto ) 
                    VALUES ( vStringAux );    
                LET vStringAux = '';
            END IF;
        ELSE
            LET vStringAux = '';
        END IF;
    END FOR;

    /**************************************************************************/
    /*    [FIN] GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES   */
    /**************************************************************************/

    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Revisa que la ultima ejecucion del proceso iniciador haya concluido
    FOREACH 
        SELECT FIRST 1 status, fecha_hora_fin
        INTO vStatusIniciador, vFechaHoraFinIniciador
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'INICIA IDENTIFICACION'
        ORDER BY fecha_hora_fin DESC
    END FOREACH;

    IF  vStatusIniciador <> 'FINALIZADO' THEN
        -- Error, el proceso iniciador no ha finalizado
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00002";
        LET vErrorInfo = "Error: El proceso iniciador no ha finalizado";
        RETURN vCodRet, vErrorInfo;
    END IF;

    -- Revisa si hay una ejecucion previa de este hilo
    FOREACH
        SELECT FIRST 1 status, fecha_hora_ini 
        INTO vStatusPrevio, vFechaHoraIni
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND fecha_hora_ini > vFechaHoraFinIniciador
        ORDER BY fecha_hora_ini DESC
    END FOREACH;

    IF vStatusPrevio = 'FINALIZADO' THEN 
        -- Se cancela todo, el proceso ya se ha finalizado previamente
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00003";
        LET vErrorInfo = "Este hilo ya ha finalizado en una ejecucion previa";
        RETURN vCodRet, vErrorInfo;
    END IF;

    IF vStatusPrevio = 'EN PROCESO' THEN 
        -- Retoma donde se quedo la ejecucion previa inconclusa
        SELECT MAX( cliente )
        INTO vUltimoCteProcesado
        FROM sc_com_manejo_ctas_a_cobrar
        WHERE cliente <= vUltimoCteHiloActual;

    ELSE
        -- Registra el inicio de la nueva ejecucion
        LET vFechaHoraIni = CURRENT;

        INSERT INTO sc_bitacora_com_manejo_cta (aniomes, etapa, hilo, status, fecha_hora_ini)
            VALUES (vAnioMes, 'IDENTIFICACION', vNumHilo, 'EN PROCESO', vFechaHoraIni);
    END IF;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*                           PROCESO PRINCIPAL                            */
    /**************************************************************************/
    -- Se valida si ya hay clientes procesados
    IF vUltimoCteProcesado IS NULL OR vUltimoCteProcesado == '' THEN
        -- No se ha procesado ni un cliente, se inicia despues del hilo anterior
        LET vUltimoCteProcesado = vUltimoCteHiloAnterior;
    END IF;

    -- Obtiene las cuentas que procesara este hilo
    --Insert Into tmp_ctas_total_cte
    SELECT chq.num_cte, chq.cuenta, chq.producto, chq.sucursal, 
    (sdo.capvigacum / sdo.diacum) AS sdo_prom
    FROM sc_maechq AS chq
    INNER JOIN tmp_conf_status AS c_stat ON chq.status_cta = c_stat.status
    INNER JOIN tmp_conf_productos AS c_prod ON chq.producto = c_prod.producto
    INNER JOIN sc_maenoc AS noc ON chq.num_cte > vUltimoCteProcesado
    AND chq.num_cte <= vUltimoCteHiloActual AND noc.fecha_alta < vFechaInicial
    AND chq.cuenta = noc.cuenta
    LEFT JOIN sc_sdodiarioc AS sdo ON sdo.aniomes = vAnioMes AND chq.cuenta = sdo.cuenta
    WHERE chq.empresa = vEmpresa
    INTO TEMP tmp_ctas_total WITH NO LOG;

    -- Tabla temporal para guardar las cuentas de un cliente siendo evaluado
    CREATE TEMP TABLE tmp_ctas_cte (
        cuenta CHAR(20),
        sucursal CHAR(4)) WITH NO LOG;
    LET vExisteTMP2 = 1;

    CREATE INDEX idx_tmp_ctas_total ON tmp_ctas_total(num_cte) 
        USING BTREE;
    CREATE INDEX idx_tmp_ctas_total2 ON tmp_ctas_total( producto, sdo_prom ) 
        USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_total;

    DROP TABLE tmp_conf_status;
    DROP TABLE tmp_conf_productos;
    LET vExisteTMP = 0;

    -- Si es la primer ejecucion, se guarda cuantas cuentas procesa este hilo
    IF vStatusPrevio = '' THEN
        SELECT COUNT(*)
        INTO vCantCtasProcesadas
        FROM tmp_ctas_total;

        UPDATE sc_bitacora_com_manejo_cta 
        SET cuentas_procesadas = vCantCtasProcesadas
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND status = 'EN PROCESO'
        AND fecha_hora_ini = vFechaHoraIni;
    END IF;

    -- Tabla temporal que guarda los clientes que exentan por saldo promedio y prestamo personal BanCoppel
    CREATE TEMP TABLE tmp_ctes_exentos (
        num_cte CHAR(20)) WITH NO LOG;
    CREATE INDEX idx_tmp_ctes_exentos ON tmp_ctes_exentos(num_cte);
    LET vExisteTMP3 = 1;

    /* EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */
    INSERT INTO tmp_ctes_exentos (num_cte)
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto <> "2500" 
    AND sdo_prom >= vSdoPromMinGral;

    INSERT INTO tmp_ctes_exentos (num_cte)
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto = "2500" 
    AND sdo_prom >= vSdoPromMin2500;
            
    SELECT DISTINCT( num_cte )
    FROM tmp_ctas_total AS ctas
    WHERE NOT EXISTS(SELECT 1 
                    FROM tmp_ctes_exentos AS exentos 
                    WHERE ctas.num_cte = exentos.num_cte)
    INTO TEMP tmp_ctes_sin_sdo_prom WITH NO LOG;
    LET vExisteTMP4 = 1;
    CREATE INDEX idx_tmp_ctes_sin_sdo_prom ON tmp_ctes_sin_sdo_prom( num_cte );
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_sin_sdo_prom;
    /* [FIN] EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */

    DROP TABLE tmp_ctes_exentos;
    LET vExisteTMP3 = 0;

    -- Ciclo principal que procesa las cuentas
    FOREACH WITH HOLD
        SELECT num_cte
        INTO vNumCte
        FROM tmp_ctes_sin_sdo_prom
        ORDER BY num_cte ASC
        
        DELETE FROM tmp_ctas_cte;

        /*   EXENCION POR CUENTA INVERSION CRECIENTE   */
        SELECT COUNT(*)
        INTO vCantCtasInversion
        FROM sc_maechq AS chq 
        WHERE chq.num_cte = vNumCte
        AND chq.producto = "1100"
        AND chq.status_cta = '1';
                
        IF vCantCtasInversion > 0 THEN 
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF;

        /*         EXENCION POR CUENTA PAGARE          */
        SELECT COUNT(*)
        INTO vCantCtasPagare
        FROM bdinvers:sv_maeinv AS inv 
        WHERE inv.num_cte = vNumCte
        AND inv.cod_instrum = "3000"
        AND inv.status_cta = '1';

        IF vCantCtasPagare > 0 THEN
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF; 
    
        /*     EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA     */
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_total
            WHERE num_cte = vNumCte

            SELECT COUNT(*) 
            INTO vCantMovHis
            FROM sc_movhis AS mov
            WHERE mov.empresa  = vEmpresa
            AND mov.cuenta = vCuenta
            AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
            AND mov.cancelad <> 'S'
            AND mov.transacc = "0273"
            AND mov.referencia LIKE "%NNNN%";
            
           IF vCantMovHis > 0 THEN
                -- si entra aqui es porque la cuenta exento
                -- se exentan todas las ctas del cte
                DELETE FROM tmp_ctas_cte;
                EXIT FOREACH;

           END IF;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            IF vFechaInicial < vFechConMovHis THEN
                SELECT COUNT(*)
                INTO vCantMovHisOld
                FROM sc_movhis_old AS mov 
                WHERE mov.empresa  = vEmpresa
                AND mov.cuenta = vCuenta
                AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
                AND mov.cancelad <> 'S'
                AND mov.transacc = "0273"
                AND mov.referencia LIKE "%NNNN%";
                        
                IF vCantMovHisOld > 0 THEN
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    DELETE FROM tmp_ctas_cte;
                    EXIT FOREACH;
                END IF;
            END IF;
            /*  [FIN] EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            INSERT INTO tmp_ctas_cte (cuenta, sucursal )
                VALUES ( vCuenta, vSucursal );
        END FOREACH;

        /*     EXENCION POR CARGO RECURRENTE     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '1141' and monto_tot >= vParamMontCargo
            Having count(*) > 1;
            
            If vCantMovHis >= 2 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '1141' and monto_tot >= vParamMontCargo
                Having count(*) > 1;
                        
                If vCantMovHisOld >= 2 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR CARGO RECURRENTE   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL BANCOPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '0548';
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '0548';
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL BANCOPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL COPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc in('0253', '1667');
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc in('0253', '1667');
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL COPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        -- Si llega a este punto, significa que ninguna cta del cte ha exentado
        -- por lo que se guardan en la tabla sc_com_manejo_ctas_a_cobrar
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_cte
            Group By cuenta, sucursal

            IF vContCtasInsertadas = 0 THEN
                BEGIN WORK;
            END IF;

            LET vContCtasInsertadas = vContCtasInsertadas + 1;

            INSERT INTO sc_com_manejo_ctas_a_cobrar ( cliente, cuenta, sucursal )
                VALUES ( vNumCte, vCuenta, vSucursal );
                    
        END FOREACH;        

        IF vContCtasInsertadas >= 5000 THEN
            LET vContCtasInsertadas = 0;
            COMMIT WORK;
        END IF; 
        
    END FOREACH;

    -- Se valida si hay inserts pendientes de commits
    IF vContCtasInsertadas > 0 THEN
        LET vContCtasInsertadas = 0;
        COMMIT WORK;
    END IF;

    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Obtiene la cantidad de cuentas identificadas
    SELECT COUNT(*)
    INTO vCantCtasIdentificadas
    FROM sc_com_manejo_ctas_a_cobrar
    WHERE cliente <= vUltimoCteHiloActual;
     
    LET vSQL = 'echo "UPDATE sc_bitacora_com_manejo_cta' ||
                ' SET fecha_hora_fin = CURRENT,' ||
                ' status = ''FINALIZADO'',' ||
                ' cuentas_identificadas = ' || vCantCtasIdentificadas ||
                ' WHERE aniomes = ''' || vAnioMes || '''' ||
                ' AND etapa = ''IDENTIFICACION''' ||
                ' AND hilo = ' || vNumHilo ||
                ' AND status = ''EN PROCESO''' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || '''' ||
                ';" > '|| vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;

    -- Actualiza el registro de totales
    UPDATE sc_bitacora_com_manejo_cta
    SET cuentas_identificadas = 
    ( cuentas_identificadas + vCantCtasIdentificadas )::INTEGER
    WHERE aniomes = vAnioMes
    AND etapa = 'TOTALES';
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
    --DROP TABLE tmp_ctas_total;
    DROP TABLE tmp_ctas_cte;
    DROP TABLE tmp_ctes_sin_sdo_prom;
        
    RETURN vCodRet, vErrorInfo;
    END
END PROCEDURE;