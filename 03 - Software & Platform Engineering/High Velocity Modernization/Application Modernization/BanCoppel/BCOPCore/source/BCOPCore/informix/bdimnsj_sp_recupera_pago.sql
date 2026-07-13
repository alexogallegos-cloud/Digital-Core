CREATE PROCEDURE "informix".sp_recupera_pago(pcel CHAR(10))
	RETURNING CHAR(5) as codret, CHAR(160) as saldo;

    DEFINE vcodret CHAR(5);
	DEFINE vtermcdto CHAR(4);
    DEFINE vsqlerr, vcant INTEGER;
	DEFINE vCredito	CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE vcadena CHAR(500);

	DEFINE cCodRetSp CHAR (5);
	DEFINE dPagoMinimo DECIMAL(18,2);
	DEFINE dSdoActCap DECIMAL(18,2);
	DEFINE dPagoNoIntereses DECIMAL(14,2);

	DEFINE vSaldoGenNull INTEGER;
	DEFINE vSaldoGenOK INTEGER;

    LET vcodret    = '00000';
	LET vtermcdto   ='';
	LET vCredito   = '';
	LET cEmpresa 	= '001';
	LET vcadena	   = '';

	LET vSaldoGenNull = 0;
	LET vSaldoGenOK = 0;
	LET cCodRetSp='00000';
	
	LET dPagoMinimo = NULL;
	LET dSdoActCap = NULL;
	LET dPagoNoIntereses = NULL;
    
    BEGIN

		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF LENGTH(pcel) <> 10 THEN
			LET vcodret = "00001";
			RETURN vcodret,'NUMERO TELEFONICO INVALIDO, VERIFIQUE.';
		END IF;

		SELECT COUNT(DISTINCT(b.numcte))  INTO vcant 
			FROM bdinteg:si_telefonos_actual a, bdicred:sd_maecred b	
			WHERE telefono=pcel 
			AND b.num_producto IN('6001','6011','6600','6400','6900','6500','7000','7200','7500','7300','7400','7600','6300','8100','7700') --se omite '7800' (Anticipo de nÃ³nima)
			AND a.numcte=b.numcte  AND tipo_tel='2' AND status_tel='A' AND status_cred NOT IN ('FF','FC','CV');		


		--SI HAY MAS DE UN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
		IF vcant > 1 THEN 
	        LET vcodret = "00002";
	        RETURN vcodret,'';

	    --SI NO HAY NINGUN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
	    ELIF vcant < 1 THEN 
	        LET vcodret = "00000";
	        RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UNA CUENTA DE CREDITO.';
	    END IF;


		FOREACH SELECT DISTINCT(b.num_credito)  INTO vCredito
			FROM bdinteg:si_telefonos_actual a, bdicred:sd_maecred b	
			WHERE telefono=pcel 
			AND b.num_producto IN('6001','6011','6600','6400','6900','6500','7000','7200','7500','7300','7400','7600','6300','8100','7700') --se omite '7800' (Anticipo de nÃ³nima)
			AND a.numcte=b.numcte  AND tipo_tel='2' AND status_tel='A' AND status_cred NOT IN ('FF','FC','CV')

			LET vtermcdto = SUBSTR(vCredito,9,4);

			SELECT codret, sdoafavor, pagominimohoy, pagonogenerarintereses INTO cCodRetSp, dSdoActCap, dPagoMinimo, dPagoNoIntereses
			FROM TABLE(PROCEDURE bdicnweb:sp_consultasaldoscredito ('sys_soc','SKI002',vCredito))
			                AS consssdogen(codret, saldoultimocorte, suscompras, sdoretenido, susdisposiciones, suscomisiones, iva, intmoratorio, ivaintmoratorio, suspagos, sdoafavor, pagominimohoy, 
			                                        saldodisponible, fechalimitepago, pagonogenerarintereses, saldodiferido, saldovencido);

			/*SELECT codigo_retorno, sdo_act_total_cap, pago_minimo, total_liquidacion INTO cCodRetSp, dSdoActCap, dPagoMinimo, dPagoNoIntereses 
				FROM TABLE(PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa, vCredito)) 
					AS conssdogen(codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados
								, linea_otorgada, tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo
								, int_moratorios, int_mes, sdo_act_total_int, iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido
								, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred
								, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, id_causa_esp_cred, sit_esp_cred);*/

			IF cCodRetSp <> '00000' THEN
				LET vSaldoGenNull = vSaldoGenNull + 1;
				CONTINUE FOREACH;
			ELSE
				IF dPagoMinimo < 0 THEN
					LET dPagoMinimo = 0;
				END IF

				LET vSaldoGenOK = vSaldoGenOK + 1;
				LET vcadena = TRIM(vcadena) || " ***" || vtermcdto || " SALDO: " || TO_CHAR(dSdoActCap, "$<<<,<<<,<<<,<<&.&&") || " PAGO MIN:" || TO_CHAR(dPagoMinimo, "$<<<,<<<,<<<,<<&.&&") || " PAGO NO GEN INTS: " || TO_CHAR(dPagoNoIntereses, "$<<<,<<<,<<<,<<&.&&") || ", ";
			END IF

		END FOREACH;


		IF vSaldoGenNull = vcant  THEN
			RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UNA CUENTA DE CREDITO.';
		ELSE
			IF vSaldoGenOK = 1 THEN
				RETURN vcodret, 'SU CREDITO BANCOPPEL, TERM.' || SUBSTR(SUBSTR(vcadena,1,LEN(vcadena) - 1),1,160);
			ELSE
				RETURN vcodret, 'SUS CREDITOS BANCOPPEL, TERM.' || SUBSTR(SUBSTR(vcadena,1,LEN(vcadena) - 1),1,160);
			END IF;
		END IF

	END;
END PROCEDURE;