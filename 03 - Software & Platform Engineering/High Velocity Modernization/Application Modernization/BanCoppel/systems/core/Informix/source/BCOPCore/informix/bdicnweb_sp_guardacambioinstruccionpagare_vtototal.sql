CREATE PROCEDURE "informix".sp_guardacambioinstruccionpagare_vtototal(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pFechaApertura DATE, pFechaVencimientoAnterior DATE,
	pFechaVencimientoActual DATE, pPlazoDiasAnt INT, pTasaInteresNeta DECIMAL(9,6), pTasaIsr DECIMAL(9,6), pTasaInteresBruto DECIMAL(9,6), pCapital MONEY(14,2), pInteresBrutoActual MONEY(14,2), 
	pInteresIsrActual MONEY(14,2), pInteresNetoActual MONEY(14,2), pIp CHAR(15), pMacAddress CHAR(12))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_afectados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iPlazoDiasAct INTEGER;
	DEFINE mInteresBrutoNuevo MONEY(14,2);
	DEFINE mInteresIsrNuevo MONEY(14,2);
	DEFINE mInteresNetoNuevo MONEY(14,2);
	DEFINE mInteresBrutoDiferencia MONEY(14,2);
	DEFINE mInteresIsrDiferencia MONEY(14,2);
	DEFINE mInteresNetoDiferencia MONEY(14,2);
	DEFINE dFecha DATETIME YEAR TO FRACTION;
	DEFINE iRegistro INTEGER;
	DEFINE iNoRows INTEGER;
	DEFINE pPagare CHAR(15);
    DEFINE pSucursal CHAR(5);
    DEFINE pTranxAbono CHAR(5);
    DEFINE pTranxCargo CHAR(5);


	LET cCodRet = '';
	LET iSqlErr = 0;
	LET iPlazoDiasAct = 0;
	LET mInteresBrutoNuevo = NULL;
	LET mInteresIsrNuevo = NULL;
	LET mInteresNetoNuevo = NULL;
	LET mInteresBrutoDiferencia = NULL;
	LET mInteresIsrDiferencia = NULL;
	LET mInteresNetoDiferencia = NULL;
	LET dFecha = CURRENT;
	LET iRegistro = 0;
	LET iNoRows = 0;
    LET pPagare = '';
    LET pSucursal = '';
    LET pTranxAbono = '';
    LET pTranxCargo = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRows;
		END EXCEPTION;
            
		--SET DEBUG FILE TO '/tmp/sp_guardacambioinstruccionpagare_vtototalOUT.sql';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pFechaApertura = '' OR pFechaVencimientoAnterior = '' OR pFechaVencimientoActual = '' OR pPlazoDiasAnt = '' 
			OR pTasaInteresNeta = '' OR pTasaIsr = '' OR pTasaInteresBruto = '' OR pCapital = '' OR pInteresBrutoActual = '' 
			OR pInteresIsrActual = '' OR pInteresNetoActual = '' OR pIp = '' OR pMacAddress = '' THEN
			
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRows;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRows;
		END IF;
	
		-- RealizaciÃ³n de calculos
		-- Recalculo del plazo a dias
		SELECT DATE(pFechaVencimientoActual) - DATE(pFechaApertura)
		INTO iPlazoDiasAct
		FROM systables WHERE tabid = 1;
		
        SELECT valor INTO pTranxCargo 
         FROM bdinteg:"informix".si_param WHERE cod_param=175;

        SELECT valor INTO pTranxAbono
         FROM bdinteg:"informix".si_param WHERE cod_param=176;
        

		-- Recalculo del interes bruto
		LET mInteresBrutoNuevo = pCapital * iPlazoDiasAct * pTasaInteresBruto / 36000;
		
		-- Recalculo ISR 
		LET mInteresIsrNuevo = pCapital * iPlazoDiasAct * pTasaIsr / 36000;
		
		-- Recalculo del interes neto
		LET mInteresNetoNuevo = mInteresBrutoNuevo - mInteresIsrNuevo;
		
		-- Recalculo Interes Bruto diferencia
		LET mInteresBrutoDiferencia = pInteresBrutoActual - mInteresBrutoNuevo;
		
		-- Recalculo diferencia ISR
		LET mInteresIsrDiferencia = pInteresIsrActual - mInteresIsrNuevo;
		
		-- Recalculo de la diferencia neto
		LET mInteresNetoDiferencia = pInteresNetoActual - mInteresNetoNuevo;
		
		SELECT id_registro
		INTO iRegistro
		FROM bdicnweb:sw_tr_cambioinstruccion
		WHERE cuenta = pCuenta;
		
/*
    LET cTransaccionCargo = '0252'; -- De manera temporal, solo para fines de prueba
	LET cTransaccionAbono = '0242'; -- De manera temporal, solo para fines de prueba
*/

		IF iRegistro IS NULL THEN -- Se va a insertar el registro

            --select first 1 cuenta, sucursal INTO pPagare, pSucursal
            --from bdinvers:informix.sv_maeinv where cta_cheques=pCuenta;
            
            --int_isr_diferencia
            --INSERT INTO bdicheq:informix.sc_movinver(empresa, tipo_mov, sucursal, cuenta, monto, divisa, procesado, fecha_alta, transacc, referencia, usuario, codigo_retorno, fecha_apli, fecha_proceso)
            --  VALUES('001', 'A', pSucursal, pCuenta, mInteresIsrDiferencia, '01', 'N', CURRENT, pTranxAbono, pPagare, 'informix', '000  ', pFechaVencimientoActual, NULL);

            --int_bruto_diferencia
            --INSERT INTO bdicheq:informix.sc_movinver(empresa, tipo_mov, sucursal, cuenta, monto, divisa, procesado, fecha_alta, transacc, referencia, usuario, codigo_retorno, fecha_apli, fecha_proceso)
            --  VALUES('001', 'C', pSucursal, pCuenta, mInteresBrutoDiferencia, '01', 'N', CURRENT, pTranxCargo, pPagare, 'informix', '000  ', pFechaVencimientoActual, NULL);
            

			INSERT INTO bdicnweb:sw_tr_cambioinstruccion(cuenta, fecha_proceso, fecha_apertura, fecha_vto_original, fecha_vto_ant, plazo_dias_original, plazo_dias_recalculo, 
					tasa_int_neta, tasa_isr, tasa_int_bruto, capital_original, int_bruto_original, int_bruto_recalculo, int_isr_original, int_isr_recalculo, 
					int_neto_original, int_neto_recalculo, int_bruto_diferencia, int_isr_diferencia, int_neto_diferencia, user_insert, fecha_insert, ip_insert, mac_insert)
			VALUES (pCuenta, current, pFechaApertura, pFechaVencimientoAnterior, pFechaVencimientoActual, pPlazoDiasAnt, iPlazoDiasAct, 
					pTasaInteresNeta, pTasaIsr, pTasaInteresBruto, pCapital, pInteresBrutoActual, mInteresBrutoNuevo, pInteresIsrActual, mInteresIsrNuevo,
					pInteresNetoActual, mInteresNetoNuevo, mInteresBrutoDiferencia, mInteresIsrDiferencia, mInteresNetoDiferencia, pUsuario, CURRENT, pIp, pMacAddress);
			
            LET iNoRows = DBINFO('sqlca.sqlerrd2');
			
			RETURN cCodRet, iNoRows;
		ELSE -- ActualizaciÃ³n del registo
			UPDATE bdicnweb:sw_tr_cambioinstruccion
			SET plazo_dias_recalculo = iPlazoDiasAct,
				fecha_vto_ant = pFechaVencimientoActual,
				int_bruto_recalculo = mInteresBrutoNuevo,
				int_isr_recalculo = mInteresIsrNuevo,
				int_neto_recalculo = mInteresNetoNuevo,
				int_bruto_diferencia = mInteresBrutoDiferencia,
				int_isr_diferencia = mInteresIsrDiferencia,
				int_neto_diferencia = mInteresNetoDiferencia,
				user_update = pUsuario,
				fecha_update = current,
				ip_update = pIp,
				mac_update = pMacAddress
			WHERE id_registro = iRegistro AND cuenta = pCuenta;
			LET iNoRows = DBINFO('sqlca.sqlerrd2');
			
			RETURN cCodRet, iNoRows;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 19/09/2013",
"DESCRIPCION: xx";

CREATE PROCEDURE "informix".sp_consultacatnumnomconveniosac(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1))
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(2) AS numcategoria,
	CHAR(3) AS numconvenio,
	CHAR(40) AS nomconvenio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE isqlerr INTEGER;
	DEFINE cNumCategoria CHAR(2);
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE iNumRows INTEGER;
	
	LET cCodRet = '00000';
	LET isqlerr = 0;
	LET cNumCategoria = '';
	LET cNumConvenio = '';
	LET cNomconvenio = '';
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatnumnomconveniosac.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
			END IF;

			IF pTipo = 'F' THEN
					SELECT COUNT(*)
					INTO iNumRows
					FROM bdisac:sac_convenios;
				IF iNumRows = 0 THEN
					LET cCodRet = '00017';
					RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
				ELSE
					FOREACH
						SELECT numcategoria, numconvenio, nomconvenio 
						INTO cNumCategoria, cNumConvenio, cNomconvenio
						FROM bdisac:sac_convenios
						RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio WITH RESUME;
					END FOREACH;
				END IF;
			END IF;
			
			IF  pTipo = 'E' THEN
				SELECT COUNT(flgreporte)
				INTO iNumRows
				FROM bdisac:sac_convenios
				WHERE flgreporte = '1';
				IF iNumRows = 0 THEN
					LET cCodRet = '00017';
					RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio;
				ELSE
					FOREACH
						SELECT numcategoria, numconvenio, nomconvenio 
						INTO cNumCategoria, cNumConvenio, cNomconvenio
						FROM bdisac:sac_convenios WHERE flgreporte = '1'
						RETURN  cCodRet, cNumCategoria, cNumConvenio, cNomconvenio WITH RESUME;
					END FOREACH;
				END IF;
			END IF;
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Esparza Brenis Fernando Martin';

CREATE PROCEDURE "informix".sp_consultaciudadessepomex(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEstado CHAR(2), pIdCiudad CHAR(3), pNombreCiudad CHAR(60))
	RETURNING CHAR(5) AS codret,
		INTEGER AS id_ciudad_coppel,
		CHAR(60) AS desc_ciudad,
		CHAR(100) AS municipio;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdCiudadCoppel INTEGER;
	DEFINE cDescCiudad CHAR(60);
	DEFINE cMunicipio CHAR(100);
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET iIdCiudadCoppel = 0;
	LET cDescCiudad = '';
	LET cMunicipio = '';
	LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdCiudadCoppel, cDescCiudad, cMunicipio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaciudadessepomex.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEstado = '' OR pIdCiudad = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdCiudadCoppel, cDescCiudad, cMunicipio;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdCiudadCoppel, cDescCiudad, cMunicipio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT FIRST 1 ciudad_coppel
		INTO iIdCiudadCoppel
		FROM bdinteg:si_ciudades
		WHERE estado = pIdEstado AND ciudad = pIdCiudad;
		
		SELECT d_ciudad
		INTO cDescCiudad
		FROM bdinteg:si_ciudades
		WHERE nombre = pNombreCiudad AND ciudad = pIdCiudad AND ciudad_coppel = iIdCiudadCoppel;
		
		SELECT {+INDEX (bdinteg:si_catsepomex sicatsepomex)} FIRST 1 
			CASE WHEN d_mnpio IS NOT NULL AND d_mnpio <> '' THEN d_mnpio ELSE d_ciudad END AS municipio
		INTO cMunicipio
		FROM bdinteg:si_catsepomex
		WHERE c_estado = pIdEstado AND UPPER(TRIM(d_ciudad)) = UPPER(TRIM(pNombreCiudad));
		
		LET iExiste = DBINFO('sqlca.sqlerrd2');
		
		IF iExiste <> 0 THEN
			RETURN cCodRet, iIdCiudadCoppel, cDescCiudad, cMunicipio;
		ElSE
			SELECT {+INDEX (bdinteg:si_catsepomex sicatsepomex)} FIRST 1 
				CASE WHEN d_mnpio IS NOT NULL AND d_mnpio <> '' THEN d_mnpio ELSE d_ciudad END AS municipio
			INTO cMunicipio
			FROM bdinteg:si_catsepomex
			WHERE c_estado = pIdEstado AND UPPER(TRIM(d_mnpio)) = UPPER(TRIM(pNombreCiudad));
			
			LET iExiste = DBINFO('sqlca.sqlerrd2');
			IF iExiste <> 0 THEN
				RETURN cCodRet, iIdCiudadCoppel, cDescCiudad, cMunicipio;
			ELSE
				LET cCodRet = '00218';
				RETURN cCodRet, iIdCiudadCoppel, cDescCiudad, cMunicipio;
			END IF;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'DESCRIPCION: Procedimiento que obtiene la informacion de las ciudades del catalogo de sepomex', 
'FECHA: 31/10/2013',
'AUTOR: Oscar Flores Conde',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaperiodosemanaltelmex(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) AS codigoretorno,
    INTEGER AS keyx,
    DATE AS fec_iniperiodo,
    DATE AS fec_finperiodo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE ikeyx INTEGER;
	DEFINE dfechaIniperiodo DATE;
	DEFINE dFechaFinPeriodo DATE;
	DEFINE iNumRows INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET ikeyx = 0;
	LET dfechaIniperiodo = NULL;
	LET dFechaFinPeriodo = NULL;
	LET iNumRows = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaperiodosemanaltelmex.out';
		--TRACE ON;
		
		IF 	pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF	cCodRet <> '00000' THEN
			RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo;
		END IF;
			
		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_liquidacionestelmex;
		IF iNumRows < 1 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, 0, '', '';
		ELSE
			FOREACH
				SELECT keyx, fec_iniperiodo, fec_finperiodo
				INTO ikeyx, dfechaIniperiodo, dFechaFinPeriodo
				FROM bdisac:sac_liquidacionestelmex
				RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin';

CREATE PROCEDURE "informix".sp_consultarctesporasignarcli(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), pNumCliente CHAR(20), pTipoCuenta CHAR(1), pTipoCampo CHAR(1), 
	pTipoDireccion CHAR(1), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(20) AS num_ciente,
			CHAR(107) AS nombre_cliente,
			DATE AS fecha_nacimiento,
			CHAR(30) AS estado,
			CHAR(60) AS ciudad,
			CHAR(30) AS calle,
			CHAR(5) AS codigo_postal,
			CHAR(10) AS tipo_domicilio,
			CHAR(4) AS sucursal,
			CHAR(27) AS municipio,
			INTEGER AS num_colonia,
			CHAR(32) AS zona,
			CHAR(80) AS observaciones;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegistros INTEGER;
	-- VARIBLES DE RETORNADAS POR EL PROCEDIMIENTO INTERNO
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(107);
	DEFINE dFechaNacimiento DATE;
	DEFINE cEstado CHAR(30);
	DEFINE cCiudad CHAR(60);
	DEFINE cCalle CHAR(30);
	DEFINE cCodigoPostal CHAR(5);
	DEFINE cTipoDomicilio CHAR(10);
	DEFINE cSucursal CHAR(4);
	DEFINE cMunicipio CHAR(27);
	DEFINE iNumColonia INTEGER;
	DEFINE cZona CHAR(32);
	DEFINE cObservaciones CHAR(80);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegistros = 0;
	-- VARIBLES DE RETORNADAS POR EL PROCEDIMIENTO INTERNO
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET dFechaNacimiento = NULL;
	LET cEstado = '';
	LET cCiudad = '';
	LET cCalle = '';
	LET cCodigoPostal = '';
	LET cTipoDomicilio = '';
	LET cSucursal = '';
	LET cMunicipio = '';
	LET iNumColonia = 0;
	LET cZona = '';
	LET cObservaciones = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr	
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarctesporasignarcli.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		IF pTipoConsulta NOT IN ('1', '2') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		IF pTipoConsulta = '1' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
						cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
			END IF;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultarctesporasignar(pTipoConsulta, pNumCliente, pTipoCuenta, pTipoCampo, pTipoDireccion, pFechaInicio, pFechaFin)
				INTO cCodRetSp, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
						cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones
			
			IF cCodRetSp::INTEGER = 0 THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
								cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones WITH RESUME;
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
				END IF;
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
								cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
			END IF;
			LET iRegistros = iRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
							cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		ELIF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
							cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
	END;
			
END PROCEDURE;