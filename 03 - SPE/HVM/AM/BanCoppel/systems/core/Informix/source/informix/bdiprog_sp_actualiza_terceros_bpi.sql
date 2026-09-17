CREATE PROCEDURE "informix".sp_actualiza_terceros_bpi(pNumCte char(20), pCuenta char (20), pCveBanco char(3), pClaveCuenta char (2),
        pAlias char(20), pNombreTitular char(60), pRfc char(13),pCelular char (10), pCompaniaCel char (2), pCorreoE char (40), pCveCaducidad CHAR(1))
returning char(5), char(60);

--Declara variables
DEFINE v_sCveEstado char (2);
DEFINE vCodRet char(5);
DEFINE vMensajeRet char(60);
DEFINE vSqlErr integer;
DEFINE vFechaCaducidad DATE;
DEFINE vValTD varchar(20);
DEFINE vValTemp char(20);	

--Asignacion de variables
LET v_sCveEstado = '';
LET vCodRet = '';
LET vMensajeRet = '';
LET vFechaCaducidad = '';
LET vValTD = "";	
LET vValTemp = "";	

-- SET DEBUG FILE TO '/ifxsif01/JuanRivera/traces/sp_actualiza_terceros_bpi_qa.out';
-- TRACE ON;

  BEGIN
        ON EXCEPTION SET vSqlErr
            IF vSqlErr != 0 THEN
                LET vCodRet = vSqlErr;
		LET vMensajeRet = 'Error Interno';
                RETURN vCodRet, vMensajeRet;
            END IF;
        END EXCEPTION;
-- Valida cuentas dadas de alta por la App canal 18
-- 16/12/2025 subido a QA
		IF NOT EXISTS(SELECT cuenta FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = pCuenta AND cve_estado ='01')THEN
			FOREACH
		
			SELECT cuenta
			INTO vValTD
			FROM bdiprog:pp_ctasterceros
			WHERE num_cte = pNumCte
			AND canal_alta='18'
			AND cve_cuenta ='01'
			AND cve_estado ='01'
				
				--SELECT num_tarjeta into vValTemp FROM bdicheq:sc_tarjeta where num_tarjeta = vValTD and cuenta = pCtaDestino;
				IF (LEN(vValTD) = 16) THEN
				SELECT num_tarjeta INTO vValTemp from bdicheq:sc_tarjeta where num_tarjeta = vValTD and cuenta = pCuenta;
				
					IF NVL(vValTemp,'') <> "" THEN 
						LET pCuenta = vValTemp;
						EXIT FOREACH;
					END IF;
					
				ELIF (LEN(vValTD) = 18) THEN
				SELECT cuenta_clabe INTO vValTemp from bdicheq:sc_maechq where cuenta_clabe = vValTD and cuenta = pCuenta;
				
					IF NVL(vValTemp,'') <> "" THEN 
						LET pCuenta = vValTemp;
						EXIT FOREACH;
					END IF;
					
				END IF;
				
				-- IF NVL(vValTemp,'') <> "" THEN
				
					-- LET pCuenta = vValTemp;
					
				-- END IF;
			 
		END FOREACH;
		END IF;
--Se verifica que exista el cliente tenga relacion con los datos proporcionados

		IF EXISTS(SELECT cve_estado FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = pCuenta AND
			cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta)THEN

--Se toma el valor del estado para comparar y poder hacer la actualizacion

				SELECT cve_estado INTO v_sCveEstado FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = pCuenta AND
					cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;

					IF v_sCveEstado = '01' THEN
						IF pCveCaducidad IS NOT NULL THEN

							IF (pCveCaducidad = '1') THEN -- Caducidad 48 horas (2 días)
								LET vFechaCaducidad = TODAY + 2 UNITS DAY;

								UPDATE bdiprog:pp_ctasterceros SET nombre = pNombreTitular, descrip_cta = pAlias, rfc =  pRfc, no_celular = pCelular,
								cve_compania = pCompaniaCel, direc_correo = pCorreoE, cve_caducidad = pCveCaducidad, fecha_caducidad = vFechaCaducidad, fecha_movtos = today
								WHERE num_cte = pNumCte and cuenta = pCuenta and cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;

							ELIF (pCveCaducidad = '2') THEN -- Caducidad 6 meses
								LET vFechaCaducidad = TODAY + 6 UNITS MONTH;

								UPDATE bdiprog:pp_ctasterceros SET nombre = pNombreTitular, descrip_cta = pAlias, rfc =  pRfc, no_celular = pCelular,
								cve_compania = pCompaniaCel, direc_correo = pCorreoE, cve_caducidad = pCveCaducidad, fecha_caducidad = vFechaCaducidad, fecha_movtos = today
								WHERE num_cte = pNumCte and cuenta = pCuenta and cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;

							ELIF (pCveCaducidad = '3') THEN -- Caducidad indefinida - 1 año
								LET vFechaCaducidad = TODAY + 1 UNITS YEAR;

								UPDATE bdiprog:pp_ctasterceros SET nombre = pNombreTitular, descrip_cta = pAlias, rfc =  pRfc, no_celular = pCelular,
								cve_compania = pCompaniaCel, direc_correo = pCorreoE, cve_caducidad = pCveCaducidad, fecha_caducidad = vFechaCaducidad, fecha_movtos = today
								WHERE num_cte = pNumCte and cuenta = pCuenta and cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;

							ELIF (pCveCaducidad = '4') THEN -- Caducidad Programada
								--LET vFechaCaducidad = TODAY + 1 UNITS YEAR;
								UPDATE bdiprog:pp_ctasterceros SET nombre=pNombreTitular, descrip_cta=pAlias, rfc=pRfc, no_celular=pCelular, cve_compania=pCompaniaCel, direc_correo=pCorreoE
								WHERE num_cte = pNumCte and cuenta = pCuenta and cve_banco = pCveBanco AND cve_cuenta = pClaveCuenta;

							ELSE
								LET vCodRet = '00007';
								LET vMensajeRet = 'Caducidad inválida';
								RETURN vCodRet, vMensajeRet;
							END IF;
						ELSE
							LET vCodRet = '00008';
							LET vMensajeRet = 'Clave de caducidad nula';
							RETURN vCodRet, vMensajeRet;
						END IF;

						SELECT cod_ret,desc_mensaje INTO vCodRet, vMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';
					ELSE
						SELECT cod_ret,desc_mensaje INTO vCodRet, vMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '10';
					END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO vCodRet, vMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '09';
		END IF ;

		RETURN vCodRet, vMensajeRet;

	END;
END PROCEDURE;