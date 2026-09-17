CREATE PROCEDURE "informix".sp_valida_cuentacan(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret, 
	          BOOLEAN AS resultado;
	
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
	
	DEFINE v_Resultado BOOLEAN;

    LET v_FechaActual = TODAY;
    --LET p_cuenta = '10305923635';
    
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
	
	LET v_Resultado = 'f';
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_Resultado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/sp_extrae_cuentascan.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_Resultado;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_Resultado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT FIRST 1 chq.cuenta, cli.numcte, cli.razon_social, chq.sdo_actual, chq.sdo_cong, chq.lim_sbg_ccc, chq.imp_chq_sbg, chq.com_pendiente, chq.fec_ult_mov, chq.producto
		INTO v_Cuenta, v_Cliente, v_RazonSocial, v_SdoActual, v_SdoCongelado, v_LimSbgCCC, v_ImpChqSbg, v_ComPendiente, v_FecUltMov, v_Producto
		FROM bdinteg:si_cliente cli
		INNER JOIN bdicheq:sc_maechq chq ON cli.numcte = chq.num_cte
		WHERE chq.cuenta = pCuenta AND chq.producto IN ('1200','1600','2200','2600') AND cli.tpo_persona='02' AND chq.status_cta NOT IN('3','2','5') 
		AND chq.fec_ult_mov <= (TODAY - DAY(TODAY) UNITS DAY) - 12 UNITS MONTH;
		
		SELECT COUNT(*) INTO v_ProdNoCancelacion 
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
					SELECT imp_chq_sbg, sdo_actual 
					INTO v_SaldoSobregirado, v_SaldoActual 
					FROM bdicheq:sc_maechq 
					WHERE cuenta = v_Cuenta AND num_cte = v_Cliente --Aqui se agrego el filtro num_cte porque devolvÃ­a mas de un registro
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
							IF v_CreditosVigentes > 0 THEN
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
							
							IF NVL(v_CreditosVigentes,0) = 0 and (NVL(v_CreditosVigentes1,0) = 0 and NVL(v_CreditosVigentes2,0) = 0) THEN
								SELECT count(producto.numero_cuenta)
								INTO v_AclaracionPendiente
								FROM bdiaclaracion:acl_producto producto
								INNER JOIN bdiaclaracion:acl_aclaracion aclaracion ON producto.pky_producto = aclaracion.fky_producto
								WHERE producto.numero_cuenta = v_Cuenta AND aclaracion.fky_estatus_aclaracion = '2';
								IF NVL(v_AclaracionPendiente,0) = 0 THEN
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
										IF v_CuentaFideicomiso <= 0 THEN
											SELECT COUNT(*) 
											INTO v_Spei
											FROM bdicheq:sc_movdia 
											WHERE cuenta = v_Cuenta AND transacc = '0274';
											IF NVL(v_Spei,0) = 0 THEN
												LET v_Resultado = 't';
											ELSE 
												INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
												VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTE TIENE UN SPEI EN PROCESO', pUsuario);
											
												LET v_Resultado = 'f';
											END IF;
										ELSE 
											INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
											VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA ES DE TIPO FIDEICOMISO', pUsuario);
											LET v_Resultado = 'f';
										END IF;
									ELSE
										INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
										VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA ES DE PRUEBA', pUsuario);
		
										LET v_Resultado = 'f';
									END IF;
								ELSE 
									INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
									VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA TIENE ACLARACIONES PENDIENTES', pUsuario);
		
									LET v_Resultado = 'f';
								END IF;
							ELSE
								INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
								VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA TIENE CREDITOS VIGENTES', pUsuario);
		
								LET v_Resultado = 'f';
							END IF;
						ELSE 
							INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
							VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO ACTUAL ES MAYOR A 0', pUsuario);
		
							LET v_Resultado = 'f';
						END IF;
					ELSE
						INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
						VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO ACTUAL ES MAYOR A 0', pUsuario);
		
						LET v_Resultado = 'f';
					END IF;
				ELSE 
					INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
					VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA PRESENTA SALDO SOBREGIRADO', pUsuario);
		
					LET v_Resultado = 'f';
				END IF;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
				VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO PROMEDIO DE LA CUENTA ES MAYOR A 0', pUsuario);
		
				LET v_Resultado = 'f';
			END IF;
		ELSE
			INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
			VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL PRODUCTO NO PERMITE CANCELAR', pUsuario);
		
			LET v_Resultado = 'f';
		END IF;
		
		RETURN cCodRet, v_Resultado;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de validar si la cuenta es candidata a cancelar',
'BD: bdicheq';


CREATE PROCEDURE "informix".sp_inserta_creditoexcluir( pCuenta CHAR(20))

-- Control de Cambios
-----------------------------------------------------------------------------------
----Faviola Martinez
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET DEBUG FILE TO "sp_inserta_creditoexcluir.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
    	
 SELECT id_registro, status
	INTO vRegistro, vStatusSol
	FROM bdicnweb:"informix".sw_evc_excluidos
	WHERE  cuenta = pCuenta
	AND id_registro = (select max(id_registro) from bdicnweb:"informix".sw_evc_excluidos where cuenta = pCuenta);

	IF (SELECT COUNT(*) FROM bdicnweb:"informix".sw_evc_excluidos WHERE cuenta = pCuenta) > 1 THEN

         IF vStatusSol <> 'P' THEN
						
			delete from sw_evc_excluidos where cuenta = pCuenta
			and id_registro < vRegistro;
			
         END IF;
	END IF;
END PROCEDURE;