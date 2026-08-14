CREATE PROCEDURE "informix".spei_calculointeres_pba()
	RETURNING 	CHAR(3);  --CODIGO RETORNO


DEFINE cSqlerr		INTEGER;
DEFINE cCodret  	CHAR(5);
DEFINE cTsaPond 	DECIMAL(9,6);
DEFINE vFechOpe		DATE;
DEFINE vFechCal		DATE;
DEFINE vFechaHoy	DATE;
DEFINE vClavRas 	CHAR(30);
DEFINE vImporte		DECIMAL(19,2);
DEFINE vDifmins 	INTEGER;
DEFINE vDifsegs 	INTEGER;
DEFINE vMontoPgo 	DECIMAL(19,2);
DEFINE vClavRasPgo 	CHAR(30);
DEFINE vSucursal	CHAR(4);
DEFINE vTransSuc 	CHAR(4);
DEFINE vTransCen 	CHAR(4);
DEFINE vFolioTran 	CHAR(30);
DEFINE vCuenta		CHAR(11);
DEFINE vReferencia 	CHAR(20);
DEFINE vEmpresa		CHAR(3);
DEFINE vUsuario		CHAR(10);
DEFINE vSerial_folio INTEGER;
DEFINE vCtaBenef	CHAR(20);
DEFINE vDivisa		CHAR(2);


--VALORES INICIALES
LET cSqlerr 	= 0;
LET cCodret 	= '000';
LET cTsaPond	= 0;
LET vClavRas	= '';
LET vImporte	= 0.00;
LET vDifmins	= 0;
LET vMontoPgo	= 0.00;
LET vClavRasPgo	= '';
LET vSucursal	= '9250';
LET vTransSuc	= '0000';
LET vTransCen	= '0332';
LET vEmpresa	= '001';
LET vUsuario	= 'informix';
LET vSerial_folio = 0;
LET vFolioTran	= '';
LET vCuenta		= '';
LET vCtaBenef	= '';
LET	vDivisa		= '01';


	BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/RESPALDOSNEW/spei_calculointeres.out";
		--TRACE ON;
  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- OBTIENE LA FECHA DE CHEQUES
		SELECT fecha_hoy
			INTO vFechaHoy
			FROM bdicheq:"informix".sc_fechas
			WHERE empresa = '001';

		-- OBTIENE EL VALOR DE LA TASA
        SELECT COUNT(valor)
			INTO cTsaPond
			FROM bdinteg:"informix".si_fechavalor 
			WHERE empresa = '001' AND tasa='FONDEOPB';


		IF cTsaPond = 0  THEN
			LET cTsaPond =0;
		ELSE
			SELECT valor
			INTO cTsaPond
			FROM bdinteg:"informix".si_fechavalor 
			WHERE empresa = '001' AND tasa='FONDEOPB';
        END IF;

       DELETE FROM bdispei:"informix".tblpago_interespei where fecha_operacion=vFechaHoy;

		FOREACH

			SELECT  dtfechavalor, dtfechacaptura, vchrclaverastreo, mnyimporte, 
            fn_Datediffminute(extend(hora_liq, year to second),extend(hora_cap, year to second),LENGTH(TRIM(vchrcuentaord))),
			fn_Datediffsecond(extend(hora_liq, year to second),extend(hora_cap, year to second),LENGTH(TRIM(vchrcuentaord))),
            vchrcuentabenef
			INTO vFechOpe, vFechCal, vClavRas, vImporte, vDifmins, vDifsegs, vCtaBenef
			FROM bdispei:"informix".tblhistpago 
			WHERE dtfechavalor = vFechaHoy 
			AND chrsentidopago='R' 
			AND chrestatusenvio IN ('L','C') 
			AND intcvetipopago=1
			AND hora_liq IS NOT NULL
			AND hora_cap IS NOT NULL
            AND chrtopologia = 'V' 
			--AND fn_Datediffminute(extend(hora_liq, year to second),extend(hora_cap, year to second),LENGTH(TRIM(vchrcuentabenef))) > 0
			IF vDifsegs > 0 THEN
                            
               IF vDifmins > 0 THEN

					-- CALCULO DEL MONTO A PAGAR 
					LET vMontoPgo= ROUND((((cTsaPond * vImporte) * vDifmins ) / 518400),2);

					IF vMontoPgo > 0 THEN 

						-- GENERA FOLIO PARA ABONO
						CALL sp_obtfoliosuc(vUsuario) 
						RETURNING cCodret, vSerial_folio, vFolioTran;

						LET vCtaBenef = TRIM(vCtaBenef);

						-- VERIFICA EL TIPO DE CUENTA BENEFICIARIA PARA OBTENER LA CUENTA DE CHEQUES
						-- CUENTA CLAVE
						IF LENGTH(vCtaBenef) = 18 THEN
							LET vCuenta = SUBSTR(vCtaBenef, 7, 11);
							-- TDD
						ELIF LENGTH(vCtaBenef) = 16 THEN
							SELECT NVL(cuenta, ' ')
								INTO vCuenta
								FROM bdicheq:sc_tarjeta
								WHERE empresa = vEmpresa
								AND num_tarjeta = vCtaBenef;
							-- MOVIL
						ELIF LENGTH(vCtaBenef) = 10 THEN
							SELECT cuenta
								INTO vCuenta
								FROM bdicheq:"informix".sc_cuenta_telefono
								WHERE telefono = vCtaBenef;
    
							IF vCuenta is null OR vCuenta = '' THEN
								SELECT cuenta_tf
									INTO vCuenta
									FROM bditransfer:"informix".tf_maecte
									WHERE telefono = vCtaBenef
									AND status_cta = '1';
							END IF;
						END IF;
	

						-- GENERA EL ABONO
						execute procedure bdicheq:"informix".abono_ref(vEmpresa, vSucursal, vUsuario, vTransCen, vTransSuc, vFolioTran, vCuenta, 0, vMontoPgo, vMontoPgo,0,0,0,vDivisa, vClavRas,'','')
						INTO cCodret;
						IF  cCodret <> '000' then 
							LET cCodret='100';	
						END IF;
					END IF;
				END IF;
				-- INSERTA EN LA BITACORA LA OPERACION CON ATRASO A PARTIR DE SEGUNDO 31 O 6
				INSERT INTO bdispei:"informix".tblpago_interespei 
					(fecha_operacion, fecha_calendario, clave_rastreo, monto_orden, valor_tasa, segundos_retraso, monto_pago, clave_rastreo_pago, fecha_proceso)
					VALUES (vFechOpe, vFechCal, vClavRas, vImporte, cTsaPond, vDifsegs, vMontoPgo, vClavRas, vFechaHoy);

			END IF;
		END FOREACH;
	END;

    RETURN cCodret;

END PROCEDURE
  ;