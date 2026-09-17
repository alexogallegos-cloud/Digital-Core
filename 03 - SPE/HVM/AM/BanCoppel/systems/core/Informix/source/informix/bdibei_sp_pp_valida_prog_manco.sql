CREATE PROCEDURE "informix".sp_pp_valida_prog_manco(pNumCte CHAR(20),pDescripcion CHAR(30), pCvePago CHAR(2),pCveCtaOri CHAR(2), pNumCtaOri CHAR(20),pCveCtaDest CHAR(2), pNumCtaDest CHAR(20), pBancoDest CHAR(3), pImporte Money(16,2), 
									pImporteIva MONEY(16,2), pTipoSPEI INTEGER, pConcepto CHAR(60), pFechaInicio DATE,pCveFinal CHAR(2), pNumRepeteciones INTEGER,
								     pFechaFin DATE, pCvePrograma CHAR(2), pTipoDiaria CHAR(2), pCadaXDia INTEGER,pCadaXSemana INTEGER, pDiasSemana CHAR(7), pTipoMensual CHAR(2),pDiaXMes INTEGER,pCadaXMeses INTEGER, pCveOcurre CHAR(2),
                                     pCveDia CHAR(2), pCveCanal CHAR(2), pCveNotifica CHAR(2), pBenEmail CHAR(40), pBenCveCompania CHAR(2), pBenCelular CHAR(10), pCveNotificaEmi CHAR(2), pEmiEmail CHAR(40), pEmiCveCompania CHAR(2),
                                     pEmiCelular CHAR(10), pMensaje CHAR(100), pUserInsert CHAR(8))

RETURNING CHAR(5),CHAR(250);

DEFINE sql_err INTEGER;
DEFINE vcCodRet CHAR(5);
DEFINE vcMensaje CHAR(250);
DEFINE vcLongDesc CHAR(30);
DEFINE v_sProducto CHAR(5);
DEFINE vcEsNumerico CHAR(1);
DEFINE vdfechaActual DATE;
DEFINE viDiasLimite INTEGER;
DEFINE vdFechaMaximaPermitida DATE;
DEFINE viDiasDiferencia INTEGER;
DEFINE vsDiaMes CHAR(2);
DEFINE vsciclo INTEGER;
DEFINE vdFechaEstimadaM DATE;
DEFINE viPasoPrimerMes CHAR(1);
DEFINE vcCodFechas CHAR(5);
DEFINE vdFechaDisponible1 DATE;
DEFINE vdFechaMovil2 DATE;
DEFINE vdFechaEstimada DATE;

ON EXCEPTION SET sql_err
    LET vcCodRet = sql_err;
    RETURN vcCodRet,'';
END EXCEPTION;

LET vcCodRet = '00000';
LET vcMensaje = '';
LET vcLongDesc = '';
LET v_sProducto = '';
LET vcEsNumerico = '';
LET vdfechaActual = sysdate;
LET viDiasLimite = 0;
LET vdFechaMaximaPermitida = sysdate;
LET viDiasDiferencia = 0;
LET vsDiaMes = '';
LET vsciclo = 0;
LET vdFechaEstimadaM = sysdate;
LET viPasoPrimerMes = '';
LET vcCodFechas = '';
LET vdFechaDisponible1 = sysdate;
LET vdFechaMovil2 = sysdate;
LET vdFechaEstimada = sysdate;


--*********************************************************************************************************************************--
-- Validaciones generales antes de guardar informacion de una programacion con mancomunidad y generar las operaciones pendientes--
--*********************************************************************************************************************************--

	-- Se valida que la clave de pago no este vacia
	IF (NVL(pCvePago,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '106';
		RETURN vcCodRet, vcMensaje;
	ELSE
        -- Se valida que exista  la clave de pago en catalogo correspondiente
		IF NOT EXISTS( SELECT cve_pago FROM bdiprog:pp_tppago WHERE cve_pago = pCvePago ) THEN
			-- CLAVE DE PAGO NO EXISTE.
            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '24';
            RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;

    -- Se valida que la descripcion no este vacia
	IF (NVL(pDescripcion,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '105';
		RETURN vcCodRet, vcMensaje;
	ELSE
		--Se valida que la longitud sea menor de 20 caracteres
		LET vcLongDesc = LENGTH(pDescripcion);
		IF vcLongDesc > 20 THEN
			SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '218';
			RETURN vcCodRet, vcMensaje;
		ELSE
            --Se valida que la descripcion no se repita
			SET ISOLATION TO DIRTY READ;
			IF EXISTS ( SELECT descripcion  FROM  bdiprog:pp_pagoprog WHERE num_cte = pNumCte and descripcion = TRIM(pDescripcion) ) THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '131';
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
	END IF;

    -- Se valida que el numero de cliente no este vacio
	IF (NVL(pNumCte,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '104';
		RETURN vcCodRet, vcMensaje;
	ELSE
		--- Se valida que el cliente exista
		IF NOT EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte) THEN
			-- CLIENTE NO EXISTE.
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '04';
            RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;

    -- Se valida que la clave de la cuenta origen no este vacia
	IF (NVL(pCveCtaOri,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '107';
		RETURN vcCodRet, vcMensaje;
	ELSE
		-- Se valida que la clave de la cuenta origen exista en el catalogo de clave cuenta
		IF NOT EXISTS(SELECT cve_cuenta FROM bdiprog:pp_tpcuenta WHERE cve_cuenta = pCveCtaOri ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '191';  
			RETURN vcCodRet,vcMensaje; 
		ELSE
			-- Se valida que la clave cuenta origen no sea '00'
			IF pCveCtaOri = '00' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '192';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
		END IF;
		-- Se valida que la cuenta origen no sea igual a la cuenta destino
		IF TRIM(pNumCtaDest) = TRIM(pNumCtaOri) THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '139';
			RETURN vcCodRet, vcMensaje;
		END IF;
		--- Se valida que la clave de cuenta origen sea 01(efectiva)
		IF pCveCtaOri <> '01' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '193';  
			RETURN vcCodRet,vcMensaje; 
		END IF;	
	END IF;

    -- Se valida la cuenta origen
	IF (NVL(pNumCtaOri,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '108';
		RETURN vcCodRet, vcMensaje;
	ELSE
		-- Se valida que la cuenta origen exista
        SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT empresa FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri) THEN
			-- CUENTA ORIGEN NO PERTENECE AL CLIENTE PROPORCIONADO
			SET ISOLATION TO DIRTY READ;
			IF EXISTS (SELECT empresa FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte) THEN
				-- CUENTA ORIGEN NO SE ENCUENTRA ACTIVA. 	
				SET ISOLATION TO DIRTY READ;
				IF EXISTS (SELECT empresa FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte and status_cta <> '2') THEN
					SELECT producto INTO v_sProducto FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte and status_cta <> '2';
					-- El PRODUCTO DE LA CUENTA ORIGEN NO ES PERMITIDO.
					SET ISOLATION TO DIRTY READ;
					IF EXISTS( SELECT user_insert FROM bdiprog:pp_producperm WHERE cve_pago = pCvePago AND permite_prog = 'S' AND producto = v_sProducto) THEN
					ELSE
						SELECT cod_ret,desc_mensaje INTO vcCodRet,vcMensaje  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '33';
						RETURN vcCodRet,vcMensaje; 
					END IF;
				ELSE
					SELECT cod_ret,desc_mensaje INTO vcCodRet,vcMensaje   FROM bdiprog:pp_mensajes WHERE cve_mensaje = '186';
					RETURN vcCodRet,vcMensaje; 
				END IF;
			ELSE
				SELECT cod_ret,desc_mensaje INTO vcCodRet,vcMensaje   FROM bdiprog:pp_mensajes WHERE cve_mensaje = '187';
				RETURN vcCodRet,vcMensaje; 
			END IF;
		ELSE
			SELECT cod_ret,desc_mensaje INTO vcCodRet,vcMensaje   FROM bdiprog:pp_mensajes WHERE cve_mensaje = '185';
			RETURN vcCodRet,vcMensaje; 
		END IF;
	END IF;

    -- Se valida que la clave de cuenta destino no este vacia
	IF (NVL(pCveCtaDest,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '109';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF NOT EXISTS(SELECT cve_cuenta FROM bdiprog:pp_tpcuenta WHERE cve_cuenta = pCveCtaDest  ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '194';  
			RETURN vcCodRet,vcMensaje;
		ELSE
            -- Se valida que la clave de cuetna destino no sea 00
			IF pCveCtaDest = '00' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '195';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
		END IF;
	END IF;

	-- Se valida que la cuenta destino no este vacia
	IF (NVL(pNumCtaDest,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '110';
		RETURN vcCodRet, vcMensaje;
	END IF;
	-- Se valida que el numero de banco no este vacio
	IF (NVL(pBancoDest,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '111';
		RETURN vcCodRet, vcMensaje;
	ELSE
        -- Se valida que la clave de banco sea correcta para spei
    	IF (NVL(pBancoDest,'') = '001')  THEN
	    	SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '138';
		    RETURN vcCodRet, vcMensaje;
    	ELSE
            -- Se valida que la clave de banco exista
	    	IF pCvePago <> '04' THEN
		    	IF NOT EXISTS(SELECT pais FROM bdinteg:si_bancos where banco = pBancoDest)THEN
			    	SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '06';
				    RETURN vcCodRet, vcMensaje;
    			END IF;
	    	END IF;
        END IF;
	END IF;

    -- Se valida que el importe no este vacio
	IF (NVL(pImporte,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '115';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF pCvePago = '05'  AND pTipoSPEI > 1 THEN 
            -- Si es pago minimo o total para TDCB.
			IF pTipoSPEI = 2 AND pImporte > 0 THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '226';
				RETURN vcCodRet,vcMensaje;
			ELIF pTipoSPEI = 3 AND ((pImporte < 10) OR (pImporte >100)) THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '226';
				RETURN vcCodRet,vcMensaje;
			END IF;
		ELSE
			IF NOT pImporte >= 1 THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '226';
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
	END IF;

	-- Se valida que el concepto no este vacio
	IF (NVL(pConcepto,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '117';
		RETURN vcCodRet, vcMensaje;
	END IF;
	-- Se valida que la fecha inicio no este vacia
	IF (NVL(pFechaInicio,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '118';
		RETURN vcCodRet, vcMensaje;
	END IF;
	-- Se valida que la clave final no este vacia
	IF (NVL(pCveFinal,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '119';
		RETURN vcCodRet, vcMensaje;
	ELSE
        -- Se valida que la clave final exista
		IF NOT EXISTS ( select cve_final from bdiprog:pp_tpfinal where cve_final = pCveFinal ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '35';  
			RETURN vcCodRet,vcMensaje; 
		ELSE
			IF pCveFinal = '00' THEN 
                --Clave Final de Programacion Invalida.
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '153';
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
	END IF;

	-- Se valida que la clave de programa no este vaia
	IF (NVL(pCvePrograma,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '120';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF NOT EXISTS( SELECT cve_programa FROM bdiprog:pp_tpprograma WHERE cve_programa = pCvePrograma ) THEN
			-- CLAVE DE PROGRAMA NO EXISTE.
            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '25';
            RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;
	-- Se valida que la clave canal no este vacia
	IF (NVL(pCveCanal,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '121';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF NOT EXISTS(SELECT cve_canal  FROM bdiprog:pp_tpcanal  WHERE cve_canal = pCveCanal  ) THEN
			-- CANAL INCORRECTO.
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '18';
			RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;
	-- Se valida que el monto no venga menor que 0
	IF pImporteIva < 0 THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '225';
		RETURN vcCodRet, vcMensaje;
	END IF;
	IF pTipoSPEI < 0 THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje =  '101';
		RETURN vcCodRet, vcMensaje;
	END IF;

	-- Se valida que la clave notifica no este vacia
	IF (NVL(pCveNotifica,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '122';
		RETURN vcCodRet, vcMensaje;
	ELSE
        -- Se valida que la clave notifica exista
		IF NOT EXISTS (select cve_notifica from bdiprog:pp_tpnotifica where cve_notifica  = pCveNotifica  ) THEN
		  SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '48';  
		  RETURN vcCodRet,vcMensaje;
		END IF;
		IF pCveNotifica = '00' THEN
			LET pBenCveCompania = '00';
			LET pBenEmail = '';
			LET pBenCelular = '';
		END IF;
		IF pCveNotifica <> '00' or pCveNotificaEmi <> '00' THEN
			IF (NVL(pMensaje,'') = '')  THEN
				SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '123';
				RETURN vcCodRet, vcMensaje;
			END IF;
		ELSE
			LET pMensaje = '';
		END IF;
		
		IF  pCveNotifica = '01' or pCveNotifica = '03'  THEN -- 
			IF NVL(pBenEmail,'') = '' THEN
				--NO SE RECIBIO EMAIL DE BENEFICIARIO.
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '42';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
			IF  pCveNotifica = '01'  THEN
				LET pBenCveCompania = '00';
				LET pBenCelular = '';
			END IF;
		END IF;
		--VIA SMS.          -- 03 PARA LOS DOS; SMS/EMAIL.
		IF   pCveNotifica = '02' or pCveNotifica = '03'  THEN 
			IF NVL(pBenCveCompania,'') <> '' THEN
				IF NOT EXISTS(SELECT cve_compania FROM  bdiprog:pp_companias WHERE cve_compania = pBenCveCompania ) THEN
					--CLAVE DE COMPANIA DE BENEFICIARIO NO EXISTE.
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '46';  
					RETURN vcCodRet,vcMensaje; 
				END IF;									
		
				IF pBenCveCompania <> '00' THEN
					IF  NVL(pBenCelular,'') = '' THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '154';  
						RETURN vcCodRet,vcMensaje;
					END IF;
				
					IF LENGTH (pBenCelular) <> 10 THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '155';  
						RETURN vcCodRet,vcMensaje;				
					END IF;
				
					EXECUTE FUNCTION bdiprog:sp_EsNumerico(pBenCelular) INTO vcEsNumerico;
					
					IF vcEsNumerico = 'F' THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '156';  
						RETURN vcCodRet,vcMensaje;
					END IF;
				ELSE
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '163';  
					RETURN vcCodRet,vcMensaje;
				END IF;
			ELSE
				--CLAVE DE COMPANIA DE BENEFICIARIO ES NULO O ES ESPACIO EN BLANCO.
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '39';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
		
			IF pCveNotifica = '02' THEN
				LET pBenEmail = '';
			END IF;
		END IF;
	END IF;

    -- Se valida que la clave notifica del emisor no este vacia
	IF (NVL(pCveNotificaEmi,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '130';
		RETURN vcCodRet, vcMensaje;
	ELSE
        -- Valida que la clave notificacion del emisor exista
		IF NOT EXISTS (select cve_notifica from bdiprog:pp_tpnotifica where cve_notifica  = pCveNotificaEmi  ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '49';  
			RETURN vcCodRet,vcMensaje;
		END IF;

		IF pCveNotificaEmi = '00' THEN
			LET pEmiCveCompania = '00';
			LET pEmiEmail = '';
			LET pEmiCelular = '';
		END IF;
		
		IF pCveNotifica <> '00' or pCveNotificaEmi <> '00' THEN
			IF (NVL(pMensaje,'') = '')  THEN
				SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '123';
				RETURN vcCodRet, vcMensaje;
			END IF;
		ELSE
			LET pMensaje = '';
		END IF;
		IF pCveNotificaEmi = '01' OR pCveNotificaEmi = '03' THEN
			IF NVL(pEmiEmail,'') = '' THEN
				--NO SE RECIBIO EMAIL DEL EMISOR.
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '47';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
		
			IF pCveNotificaEmi = '01' THEN
				LET pEmiCveCompania = '00';
				LET pEmiCelular = '';
			END IF;
		END IF;

		IF pCveNotificaEmi = '02' OR pCveNotificaEmi = '03' THEN
			IF NVL(pEmiCveCompania,'') <> '' THEN
				IF NOT EXISTS( SELECT cve_compania FROM bdiprog:pp_companias WHERE cve_compania = pEmiCveCompania) THEN
					--CLAVE DE COMPANIA DEL EMISOR NO EXISTE.
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '52';  
					RETURN vcCodRet,vcMensaje; 
				END IF;
		
				IF pEmiCveCompania <> '00' THEN
					IF  NVL(pEmiCelular,'') = '' THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '157';  
						RETURN vcCodRet,vcMensaje;				 
					END IF;
				 
					IF LENGTH (pEmiCelular) <> 10 THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '158';  
						RETURN vcCodRet,vcMensaje;				 
					END IF;
				 
					EXECUTE FUNCTION bdiprog:sp_EsNumerico(pEmiCelular) INTO vcEsNumerico;
					
					IF vcEsNumerico = 'F' THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '159';  
						RETURN vcCodRet,vcMensaje;
					END IF;
				ELSE
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '162';  
					RETURN vcCodRet,vcMensaje;
				END IF;
			ELSE
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '50';  
				RETURN vcCodRet,vcMensaje;
			END IF;
			IF pCveNotificaEmi = '02' THEN
				LET pEmiEmail = '';
			END IF;
		END IF;
	END IF;
    -- Se valida que el user insert no este vacio
	IF (NVL(pUserInsert,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '124';
		RETURN vcCodRet, vcMensaje;
	END IF;

    -- Se validan los datos necesarios para la ejecucion de cada pago
	IF (pCvePago <> '04') THEN
		IF pCveFinal = '01' THEN
	
			LET pFechaFin = '';
		
			IF NVL(pNumRepeteciones,'') = '' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '173';
				RETURN vcCodRet,vcMensaje;
			END IF; 
		
			IF pNumRepeteciones < 1 THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '174';
				RETURN vcCodRet,vcMensaje;
			END IF;	
		END IF;	
	
		IF pCveFinal = '02' THEN
			SELECT fecha_hoy INTO vdfechaActual FROM bdinteg:si_fechas;
			LET pNumRepeteciones = '';
			IF NVL(pFechaFin,'') = '' THEN
				---FECHA FINAL ES NULO O ESPACIO EN BLANCO 
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '128';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		
			IF  pFechaInicio > pFechaFin THEN
				--FECHA INICIO ES MAYOR A LA FECHA DE FINAL.   
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '62';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF
	END IF;

    ---Tipo DIARIO
	IF pCvePrograma = '01' THEN
		--se valida que tipo diaria no venga vacio
		IF NVL(pTipoDiaria,'') = '' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '172';  
			RETURN vcCodRet,vcMensaje;
		END IF;
		--se valida que el tipo diara sea correcta
		IF NOT EXISTS ( select tipo_diaria from bdiprog:pp_tpdiaria where tipo_diaria = pTipoDiaria ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '37';  
			RETURN vcCodRet,vcMensaje;
		END IF;
		---se valida que tipo diaria no se 00
		IF pTipoDiaria = '00' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '160';  
			RETURN vcCodRet,vcMensaje;
		END IF;
		IF pTipoDiaria = '01' THEN
			--ENTONCES SE TOMA EL VALOR DE pCadaXDias.
			IF  NVL(pCadaXDia,'') = '' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '175';  
				RETURN vcCodRet,vcMensaje;
			END IF;
			IF pCadaXDia < 1 THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '176';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
		IF pTipoDiaria = '02' THEN
			LET pCadaXDia = 0;
		END IF;
	END IF;
	--SEMANAL
	IF pCvePrograma = '02' THEN
		----Se valida que los dias de la semana no vengan en blanco
		IF NVL(pDiasSemana,'') = '' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '165';  
			RETURN vcCodRet,vcMensaje;
		END IF;
		--se valida que el los dias no sean difernete de 7
		IF  length (pDiasSemana) <> 7 THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '166';  
			RETURN vcCodRet,vcMensaje;
		END IF;		  
		--se valida que no vengan caracteres diferente de 0 o 1
		IF (substr(pDiasSemana,1,1) = '0' or substr(pDiasSemana,1,1) = '1') and  (substr(pDiasSemana,2,1) = '0' or substr(pDiasSemana,2,1) = '1') and (substr(pDiasSemana,3,1) = '0' or substr(pDiasSemana,3,1) = '1') and 
			(substr(pDiasSemana,4,1) = '0' or substr(pDiasSemana,4,1) = '1') and  (substr(pDiasSemana,5,1) = '0' or substr(pDiasSemana,5,1) = '1') and (substr(pDiasSemana,6,1) = '0' or substr(pDiasSemana,6,1) = '1') and (substr(pDiasSemana,7,1) = '0' or substr(pDiasSemana,7,1) = '1') THEN
			---se valida 
			IF pDiasSemana = '0000000' THEN
				--DIAS DE SEMANA INVALIDO DADO QUE CONTIENE CEROS SOLAMENTE.    
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '170';  
				RETURN vcCodRet,vcMensaje;
			END IF;
			IF NVL(pCadaXSemana,'') =  '' THEN
				--CADA X SEMANAS ES NULO O ESPACIO EN BLANCO.
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '168';  
				RETURN vcCodRet,vcMensaje;
			END IF; 
			IF  pCadaXSemana < 1 THEN
				--CADA X SEMANAS DEBE SER MAYOR QUE CERO. 
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '169';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		ELSE
			---DIAS DE SEMANA DEBEN SER SOLO CEROS Y UNOS. 
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '167';  
			RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;		

	--MENSUAL
	IF pCvePrograma = '03' THEN
		IF NVL(pTipoMensual,'') = '' THEN
			--TIPO MENSUAL ES NULO O ESPACIO EN BLANCO. 
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '171';  
			RETURN vcCodRet,vcMensaje;					
		END IF;		
		
		IF NOT EXISTS( select tipo_mensual from bdiprog:pp_tpmensual where tipo_mensual = pTipoMensual ) THEN
			--TIPO MENSUAL NO EXISTE.       
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '57';  
			RETURN vcCodRet,vcMensaje;
		END IF;			

		IF pTipoMensual = '00' THEN
			--TIPO MENSUAL DE PROGRAMACIÃ?N INVÃ?LIDA.        
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '164';  
			RETURN vcCodRet,vcMensaje;
		END IF;
			
		IF NVL(pCadaXMeses,'') = '' THEN
			---CADA X MES ES NULO O ESPACIO EN BLANCO.    
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '179';  
			RETURN vcCodRet,vcMensaje;
		END IF;						
			
		IF  pCadaXMeses < 1 THEN
			---CADA X MES NO ES MAYOR QUE CERO.   
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '180';  
			RETURN vcCodRet,vcMensaje;
		END IF;					
		IF pTipoMensual = '01' THEN
			IF NVL(pDiaXMes,'') = '' THEN
			--EL DIA X DEL MES ES NULO O ESPACIO EN BLANCO.     
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '177';  
				RETURN vcCodRet,vcMensaje;
			END IF;
				
			IF pDiaXMes < 1 or pDiaXMes > 31 THEN
				---EL DIA X DEL MES DEBE SER UN VALOR QUE COMPRENDA EL RANGO ENTRE 1 Y 31.  
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '178';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;		
		IF pTipoMensual = '02' THEN
			IF NVL(pCveOcurre,'') = '' THEN
				--CLAVE OCURRE ES NULO O ESPACIO EN BLANCO.     
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '181';  
				RETURN vcCodRet,vcMensaje;
			END IF;
			IF NOT EXISTS ( select cve_ocurre from bdiprog:pp_tpocurre where cve_ocurre = pCveOcurre ) THEN
				---CLAVE OCURRE NO EXISTE.  
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '59';  
				RETURN vcCodRet,vcMensaje;
			END IF;
				
			IF pCveOcurre = '00' THEN
				---CLAVE OCURRE DE PROGRAMACIÃ?N  INVÃ?LIDA.  
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '182';  
				RETURN vcCodRet,vcMensaje;
			END IF;
			IF NVL(pCveDia,'') = '' THEN
				--CLAVE DIA ES NULO O ESPACIO EN BLANCO.    
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '183';  
				RETURN vcCodRet,vcMensaje;
			END IF;
					
			IF NOT EXISTS ( select cve_dia from bdiprog:pp_diassemana  where cve_dia = pCveDia ) THEN
				--CLAVE DIA NO EXISTE.           
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '60';  
				RETURN vcCodRet,vcMensaje;
			END IF;

			IF pCveDia = '00' THEN
				---CLAVE DIA DE PROGRAMACIÃ?N INVÃ?LIDA.    
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '184';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
	END IF;	
	
	IF pCvePrograma = '04' THEN -- PAGO UNICO.
	
		IF pCveFinal <> '02' THEN -- DEBE SER CLAVE FINAL POR FECHA.
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '69';
			RETURN vcCodRet,vcMensaje;			
		END IF;
		IF NVL(pFechaFin,'') = '' THEN
			--FECHA FIN  ES NULO O ESPACIO EN BLANCO. 
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '181';  
			RETURN vcCodRet,vcMensaje;
		END IF;
		IF pFechaInicio <> pFechaFin THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '63';
			RETURN vcCodRet,vcMensaje;			
		END IF;
	END IF;
	
	--DIAS LIMITES
	--se valida que la fecha actual del sistema no sea menor a la fecha de programacion 
	    SET ISOLATION TO DIRTY READ;
	    IF pCvePago = '07' THEN
            	SELECT fecha_hoy INTO vdfechaActual FROM bdinteg:si_fechas;
            	IF NOT ((pFechaInicio = vdfechaActual) or (pFechaInicio > vdfechaActual)) THEN  ---RGH---
		-- FECHA INICIAL ES MENOR O IGUAL A LA FECHA ACTUAL.
            	SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '26';
            	RETURN vcCodRet,vcMensaje;
            	END IF;
	    ELSE
            	SELECT fecha_hoy INTO vdfechaActual FROM bdinteg:si_fechas;
            	IF NOT (pFechaInicio > vdfechaActual) THEN
            	-- FECHA INICIAL ES MENOR O IGUAL A LA FECHA ACTUAL.
            	SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '26';
            	RETURN vcCodRet,vcMensaje;
            	END IF;
    	END IF;

	IF (pCvePago <> '04') THEN
		--se obtiene el valor del total del los dias permitidos
		SELECT valor INTO viDiasLimite FROM bdiprog:pp_parametros   WHERE cve_param = '02';
		---se valida que el dato sea correcto
		IF NVL(viDiasLimite,'') = '' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '132';  
			RETURN vcCodRet,vcMensaje; 
		END IF;		
		
		--se calcula la fecha maxima permitida
		LET vdFechaMaximaPermitida = vdfechaActual + viDiasLimite;
		
		IF pCveFinal = '02' THEN --PAGO POR RANGO DE FECHAS
			LET viDiasDiferencia = pFechaFin - vdfechaActual;
			IF viDiasDiferencia > viDiasLimite  THEN
				--PROGRAMACION EXCEDE EL MAXIMO PERMITIDO
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
			IF NOT pFechaFin <= vdFechaMaximaPermitida THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
		
		--Valida dias limites para pago unico de TDCB y TDCOB.
		IF (pCvePago= '05' OR pCvePago = '06') AND (pCvePrograma = '04') THEN 
			IF pCveFinal = '02' THEN
				IF pFechaFin > vdFechaMaximaPermitida THEN
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
					RETURN vcCodRet,vcMensaje;
				END IF;
			ELSE
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '69';
				RETURN vcCodRet,vcMensaje;	
			END IF
		END IF;
		
		IF pCvePrograma = '03' THEN -- MENSUAL
			IF pCveFinal = '01' THEN
				IF pTipoMensual = '01' THEN
					LET vsDiaMes = DAY(pFechaInicio);
					LET vsciclo = 1;
					LET vdFechaEstimadaM = pFechaInicio;
					WHILE pNumRepeteciones > vsciclo
						IF viPasoPrimerMes = 'S' THEN
						LET vdFechaEstimadaM = month (vdFechaEstimadaM) || '/01/' || year(vdFechaEstimadaM);
						END IF;
						EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaEstimadaM),month(vdFechaEstimadaM),pDiaXMes) INTO vcCodFechas,vdFechaDisponible1;
						IF vdFechaDisponible1 >= vdFechaEstimadaM  THEN
							LET vsciclo = vsciclo + 1;
						END IF;
						LET viPasoPrimerMes = 'S';
						IF pNumRepeteciones = vsciclo THEN
						ELSE
							IF vsDiaMes > 28 THEN
								LET vdFechaMovil2 = month (vdFechaEstimadaM) || '/01/' || year(vdFechaEstimadaM);
								LET vdFechaEstimadaM  = vdFechaMovil2 + pCadaXMeses UNITS MONTH;
								EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaEstimadaM), month (vdFechaEstimadaM) ,vsDiaMes) INTO vcCodFechas,vdFechaDisponible1;
								IF vcCodFechas = '00000' THEN
									IF DAY(vdFechaDisponible1) = 1 THEN
										LET vdFechaEstimadaM = vdFechaDisponible1 -1;
									ELSE
										LET vdFechaEstimadaM = vdFechaDisponible1;
									END IF;
								END IF;
							ELSE
								LET vdFechaEstimadaM  = vdFechaEstimadaM + pCadaXMeses UNITS MONTH;
							END IF;
						END IF;
					END WHILE
					IF vdFechaMaximaPermitida < vdFechaDisponible1 THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
						RETURN vcCodRet,vcMensaje; 
					END IF;
				END IF;
			END IF;
		END IF;
		IF pCveFinal = '01' THEN
			IF pCvePrograma = '01' THEN 
				IF pTipoDiaria = '01' THEN
					LET vdFechaEstimada = pFechaInicio + ( ( pNumRepeteciones -1) * pCadaXDia);
					IF vdFechaMaximaPermitida < vdFechaEstimada THEN
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
						RETURN vcCodRet,vcMensaje; 
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

    IF (pCvePago = '04') THEN
		SET ISOLATION TO DIRTY READ;
		SELECT valor INTO viDiasLimite FROM bdiprog:pp_parametros   WHERE cve_param = '03';
		
		IF NVL(viDiasLimite,'') = '' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '132';  
			RETURN vcCodRet,vcMensaje; 
		END IF;
		LET vdFechaMaximaPermitida = vdfechaActual + viDiasLimite;
		
	     IF pCvePrograma = '04' THEN 
		IF pCveFinal = '02' THEN
			IF pFechaFin > vdFechaMaximaPermitida THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		ELSE
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '69';
			RETURN vcCodRet,vcMensaje;	
		END IF;
             ELSE
			IF pCvePrograma <> '04' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '228';  
				RETURN vcCodRet,vcMensaje;
			END IF;
	     END IF;
	END IF;
    RETURN vcCodRet,vcMensaje;
END PROCEDURE;