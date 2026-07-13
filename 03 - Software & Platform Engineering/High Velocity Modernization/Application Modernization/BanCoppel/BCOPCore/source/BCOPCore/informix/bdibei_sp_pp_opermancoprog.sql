CREATE PROCEDURE "informix".sp_pp_opermancoprog(p_idoperManco INTEGER,pidUsuarioSol INTEGER,pNumCte CHAR(20),pDescripcion CHAR(30), pCvePago CHAR(2),pCveCtaOri CHAR(2), pNumCtaOri CHAR(20),pCveCtaDest CHAR(2), pNumCtaDest CHAR(20), pBancoDest CHAR(3), pRef1 CHAR(40), pRef2 CHAR(20),
								     pConvenio CHAR(5), pImporte Money(16,2), pRefCobranza CHAR(40), pImporteIva MONEY(16,2), pTipoSPEI INTEGER, pConcepto CHAR(60), pFechaInicio DATE,pCveFinal CHAR(2), pNumRepeteciones INTEGER,
								     pFechaFin DATE, pCvePrograma CHAR(2), pTipoDiaria CHAR(2), pCadaXDia INTEGER,pCadaXSemana INTEGER, pDiasSemana CHAR(7), pTipoMensual CHAR(2),pDiaXMes INTEGER,pCadaXMeses INTEGER, pCveOcurre CHAR(2),
                                     pCveDia CHAR(2), pCveCanal CHAR(2), pCveNotifica CHAR(2), pBenEmail CHAR(40), pBenCveCompania CHAR(2), pBenCelular CHAR(10), pCveNotificaEmi CHAR(2), pEmiEmail CHAR(40), pEmiCveCompania CHAR(2),
                                     pEmiCelular CHAR(10), pMensaje CHAR(100), pCveEstado CHAR(2), pUserInsert CHAR(8) )

RETURNING CHAR(5),CHAR(250);

	--**********************************************************************************************************
	-- Desc:  Se incluye que realice un registro para las operaciones mancomunadas de pagos programados
	-- AUTOR : Berenice Noriega Guevara - BanCoppel_Internet
	-- FECHA Modificacion: 24/Junio/2015
	-- FECHA DE LIBERACION: pendiente
	-- SOLICITO :BanCoppel
	
	-- Basa en el de altaprogramacion en bdiprog ultimo comentario de ese spl bdiprog:sp_altaprogramacion:
		-- Se agrega la actualización de cuentas frecuentes tipo Programadas - 
		-- Bibiana Gaxiola Verdugo
		-- Fecha: 25/04/2013
	--***********************************************************************************************************


DEFINE sql_err INTEGER;
DEFINE vcCodRet CHAR(6);
DEFINE vcCodRet1 CHAR(5);
DEFINE vcMensaje CHAR(250);
DEFINE vdFechaHoy DATE;
DEFINE vdMesInicio CHAR(2);
DEFINE vdMesFin CHAR(2);
DEFINE vdAnoInicio CHAR(4);
DEFINE vdAnoFin CHAR(4);
DEFINE vcLongDesc CHAR(30);
DEFINE v_sProducto CHAR(5);
DEFINE vcEsNumerico CHAR(1);
DEFINE viDiasLimite INTEGER;
DEFINE vdfechaActual DATE;
DEFINE viDiasDiferencia INTEGER;
DEFINE vdFechaMaximaPermitida DATE;
DEFINE vdFechaEstimada DATE;
DEFINE vdFechaEstimadaM DATE;
DEFINE vsDiaMes CHAR(2);
DEFINE vsciclo INTEGER;
DEFINE viPasoPrimerMes CHAR(1);
DEFINE vcCodFechas CHAR(5);
DEFINE vdFechaDisponible1 DATE;
DEFINE vdFechaMovil2 DATE;
DEFINE vFechaCaducidad DATE;
DEFINE vFechaMaxProg DATE;
DEFINE vCvePagoProg CHAR (10);



        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;
            RETURN vcCodRet,'';
        END EXCEPTION;

LET sql_err = 0;
LET vcCodRet = '00000';
LET vcMensaje = '';
LET vdFechaHoy = MDY('01','01','1900');
LET vdMesInicio = '';
LET vdMesFin = '';
LET vcLongDesc = '';
LET  vdAnoInicio = '';
LET  vdAnoFin = '';
LET v_sProducto = '';
LET vcEsNumerico = '';
LET viPasoPrimerMes = 'N';
LET vcCodFechas = '';
LET vdFechaMaximaPermitida		='';
LET vdFechaDisponible1	        ='';

--*********************************************************************************************************************************--
--Validaciones generales--
--*********************************************************************************************************************************--

	--valida que la clave de pago 
	IF (NVL(pCvePago,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '106';
		RETURN vcCodRet, vcMensaje;
	--se valida que exista  la clave de pago en catalogo correspondiente
	ELSE
		IF NOT EXISTS( SELECT cve_pago FROM bdiprog:pp_tppago WHERE cve_pago = pCvePago ) THEN
			-- CLAVE DE PAGO NO EXISTE.
            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '24';
            RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;
	--valida la descripcion
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
			SET ISOLATION TO DIRTY READ;
			IF EXISTS ( SELECT descripcion  FROM  bdiprog:pp_pagoprog WHERE num_cte = pNumCte and descripcion = TRIM(pDescripcion) ) THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '131';
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
	END IF;
	
	--se valida el numero de cliente
	IF (NVL(pNumCte,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '104';
		RETURN vcCodRet, vcMensaje;
		---se valida que el cliente exista
	ELSE
		IF NOT EXISTS( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte) THEN
			-- CLIENTE NO EXISTE.
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '04';
            RETURN vcCodRet,vcMensaje;
		END IF;
	END IF;
	
	--se valida la clave de la cuenta origen
	IF (NVL(pCveCtaOri,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '107';
		RETURN vcCodRet, vcMensaje;
		--se valida que la clave de la cuenta origen exista en el catalogo de clave cuenta
	ELSE
		IF NOT EXISTS(SELECT cve_cuenta FROM bdiprog:pp_tpcuenta WHERE cve_cuenta = pCveCtaOri ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '191';  
			RETURN vcCodRet,vcMensaje; 
		ELSE
			--se valida que la clave cuenta origen no sea '00'
			IF pCveCtaOri = '00' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '192';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
		END IF;
		--se valida que la cuenta origen no sea igual a la cuenta destino
		IF TRIM(pNumCtaDest) = TRIM(pNumCtaOri) THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '139';
			RETURN vcCodRet, vcMensaje;
		END IF;
		--- se valida que la clave de cuetna origen sea 01(efectiva)
		IF pCveCtaOri <> '01' THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '193';  
			RETURN vcCodRet,vcMensaje; 
		END IF;	
	  
	END IF;
	
	--se valida la cuenta origen
	IF (NVL(pNumCtaOri,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '108';
		RETURN vcCodRet, vcMensaje;
	ELSE
		--se valida que la cuenta origen exista
			SET ISOLATION TO DIRTY READ;
		IF EXISTS (SELECT empresa FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri) THEN
			--CUENTA ORIGEN NO PERTENECE AL CLIENTE PROPORCIONADO
			SET ISOLATION TO DIRTY READ;
			IF EXISTS (SELECT empresa FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte) THEN
				--CUENTA ORIGEN NO SE ENCUENTRA ACTIVA. 	
				SET ISOLATION TO DIRTY READ;

				IF EXISTS (SELECT empresa FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte and status_cta <> '2') THEN

					SELECT producto INTO v_sProducto FROM bdicheq:sc_maechq  WHERE cuenta = pNumCtaOri and num_cte = pNumCte and status_cta <> '2';
					--El PRODUCTO DE LA CUENTA ORIGEN NO ES PERMITIDO.
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
	
	--se valida la clave de cuenta destino
	IF (NVL(pCveCtaDest,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '109';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF NOT EXISTS(SELECT cve_cuenta FROM bdiprog:pp_tpcuenta WHERE cve_cuenta = pCveCtaDest  ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '194';  
			RETURN vcCodRet,vcMensaje;
		--Se valida que la clave de cuetna destino no sea 00
		ELSE
			IF pCveCtaDest = '00' THEN
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '195';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
		END IF;
	END IF;
	--se valida la cuenta destino
	IF (NVL(pNumCtaDest,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '110';
		RETURN vcCodRet, vcMensaje;
	END IF;
	--se valida el numero de banco
	IF (NVL(pBancoDest,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '111';
		RETURN vcCodRet, vcMensaje;
	ELSE
    	IF (NVL(pBancoDest,'') = '001')  THEN
	    	SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '138';
		    RETURN vcCodRet, vcMensaje;
    	ELSE
	    	IF pCvePago <> '04' THEN
		    	IF NOT EXISTS(SELECT pais FROM bdinteg:si_bancos where banco = pBancoDest)THEN
			    	SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '06';
				    RETURN vcCodRet, vcMensaje;
    			END IF;
	    	END IF;
        END IF;
	END IF;
	--se valdia el importe
	IF (NVL(pImporte,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '115';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF pCvePago = '05'  AND pTipoSPEI > 1 THEN --Si es pago minimo o total para TDCB.
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
	--se valida el concepto
	IF (NVL(pConcepto,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '117';
		RETURN vcCodRet, vcMensaje;
	END IF;
	--se valida la fecha inicio
	IF (NVL(pFechaInicio,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '118';
		RETURN vcCodRet, vcMensaje;
	END IF;
	--se valida la clave final
	IF (NVL(pCveFinal,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '119';
		RETURN vcCodRet, vcMensaje;
	ELSE
		IF NOT EXISTS ( select cve_final from bdiprog:pp_tpfinal where cve_final = pCveFinal ) THEN
			SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '35';  
			RETURN vcCodRet,vcMensaje; 
		ELSE
			IF pCveFinal = '00' THEN --Clave Final de ProgramaciÃ³n InvÃ¡lida.
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '153';
				RETURN vcCodRet,vcMensaje;
			END IF;
		END IF;
		
	END IF;
	--se valida la clave de programa
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
	--se valida la clave canal
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
	--se valida que el monto no venga menor que 0
	IF pImporteIva < 0 THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '225';
		RETURN vcCodRet, vcMensaje;
	END IF;
	IF pTipoSPEI < 0 THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje =  '101';
		RETURN vcCodRet, vcMensaje;
	END IF;
	
	--se valida la clave notifica
	IF (NVL(pCveNotifica,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '122';
		RETURN vcCodRet, vcMensaje;
	ELSE
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
	--se valdia la clave notifica del emisor
	IF (NVL(pCveNotificaEmi,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '130';
		RETURN vcCodRet, vcMensaje;
	ELSE
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
	--se valida el user insert
	IF (NVL(pUserInsert,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '124';
		RETURN vcCodRet, vcMensaje;
	END IF;
	

	--se validan los datos necesarios para la ejecucion de cada pago
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
			--TIPO MENSUAL DE PROGRAMACIÃ?N INVÃLIDA.        
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
				---CLAVE OCURRE DE PROGRAMACIÃ?N  INVÃLIDA.  
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
				---CLAVE DIA DE PROGRAMACIÃ?N INVÃLIDA.    
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
	--Se valida el convenio solo para pago de servicios.
	IF pCvePago <> '04' THEN
		LET pConvenio = '';
	END IF;
      -- Alta de Telefono 
      EXECUTE FUNCTION bdinteg:"informix".sp_registra_telefonos('001', pNumCte, pEmiCelular, 3, ' ', pEmiCveCompania::SMALLINT, pCveCanal::SMALLINT, pUserInsert) 
              INTO vcCodRet1;
      -- Alta de Correo
      EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos( '001', pNumCte, pEmiEmail, 1, pCveCanal::SMALLINT, pUserInsert) 
              INTO vcCodRet1;
			  
			  
--*********************************************************************************************************************************--
--TERMINAN VALIDACIONES--------------------------------------------------------------------------------------------------------------
--*********************************************************************************************************************************--


--*********************************************************************************************************************************--
		--Insertar en la tabla de mancomunidad ---
		INSERT INTO bdibei:"informix".bei_pp_progmanco
		(idopermanco, idusuariosol, numcte, descripcion, cvepago, cvectaori, numctaori, cvectadest, numctadest, bancodest, ref1, 		ref2, convenio, importe, refcobranza, importeiva, tipospei, concepto, fechainicio, cvefinal, numrepeteciones, fechafin, 	   cveprograma, tipodiaria, cadaxdia, cadaxsemana, diassemana, tipomensual, diaxmes, cadaxmeses, cveocurre, cvedia, cvecanal, 		 cvenotifica, benemail, bencvecompania, bencelular, cvenotificaemi, emiemail, emicvecompania, emicelular, mensaje, cveestado, 		 userinsert)
		VALUES
( p_idoperManco, pidUsuarioSol ,pNumCte,pDescripcion , pCvePago ,pCveCtaOri , pNumCtaOri ,pCveCtaDest, pNumCtaDest, pBancoDest,	pRef1, pRef2, pConvenio, pImporte, pRefCobranza, pImporteIva, pTipoSPEI , pConcepto, pFechaInicio ,pCveFinal, 	pNumRepeteciones, pFechaFin, pCvePrograma, pTipoDiaria, pCadaXDia ,pCadaXSemana, pDiasSemana, pTipoMensual,pDiaXMes ,pCadaXMeses , pCveOcurre, pCveDia, pCveCanal, pCveNotifica, pBenEmail, pBenCveCompania, pBenCelular, pCveNotificaEmi, pEmiEmail, pEmiCveCompania, pEmiCelular, pMensaje, pCveEstado, pUserInsert);
	  
--*********************************************************************************************************************************--

		RETURN vcCodRet,vcMensaje;
	
END PROCEDURE;