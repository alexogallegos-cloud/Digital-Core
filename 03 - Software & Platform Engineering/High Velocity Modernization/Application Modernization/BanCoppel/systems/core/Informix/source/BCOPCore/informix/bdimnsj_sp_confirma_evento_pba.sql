create procedure "informix".sp_confirma_evento_pba(
					pid_pos_atm char(2), pid_deb_cre char(2), pid_reverso char(1), pno_tarjeta char(16), pno_autorizacion char(12),
					pinfreceptor char(40), pimporte money(16,2), pimp_comision money(16,2), pfecha_aut datetime year to fraction(3), 
					psecuencia_ext char(16), pcajero_propio char(1)
				    )

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.

--Definición de Variables
DEFINE cCodRet			CHAR(5);
DEFINE cid_mensaje1		CHAR(10);
DEFINE cid_mensaje2		CHAR(10);
DEFINE ccajero			CHAR(20);
DEFINE vsqlerr INTEGER;
DEFINE dSecuencia		DECIMAL(12,0);
--Variables para Control de Errores
DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);

--Inicializa Variables
LET cCodRet = '00000';
LET cid_mensaje1 = '';
LET cid_mensaje2 = '';
LET ccajero = '';
LET dSecuencia = 0;
LET vsqlerr = 0;

BEGIN
	ON EXCEPTION SET vsqlerr, ISAM_ERR, ERROR_INFO
      IF vsqlerr <> 0 THEN
	  
		 INSERT INTO bdimnsj:"informix".mnsjr_bitacora_err (id_proceso,fecha_insert,sql_err,isam_err,error_info,texto) 
		 values ('SP_CONFIRMA_EVENTO',current,vsqlerr, ISAM_ERR, ERROR_INFO, "PARAMETROS DE ENTRADA =" || pid_pos_atm || "|" 
		 || pid_deb_cre  || "|" || pid_reverso || "|" || pno_tarjeta ||  "|"|| 
		 pno_autorizacion || "|" || pinfreceptor || "|" || pimporte ||  "|" || pimp_comision ||
		 "|" || pfecha_aut ||  "|" || psecuencia_ext || "|"||  pcajero_propio );
				
         return vsqlerr;
      END IF;
	END EXCEPTION;

	--	SET DEBUG FILE TO "/tmp/MNSJR/sp_confirma_evento.out";
--	TRACE ON;
--Determina el ID del mensaje a actualizar 'POS_DEBS','POS_CREDS','ATM_DEBS','ATM_CREDS','POS_DEBE','POS_CREDE','ATM_DEBE','ATM_CREDE'
	IF pid_pos_atm = '01' THEN -- ATM
		IF TRIM(pid_deb_cre) = 'D' THEN -- Debito
			LET cid_mensaje1 = 'ATM_DEBS';
			LET cid_mensaje2 = 'ATM_DEBE';			
		ELSE -- Credito	
			LET cid_mensaje1 = 'ATM_CREDS';
			LET cid_mensaje2 = 'ATM_CREDE';			
		END IF;	
	ELSE -- POS
		IF TRIM(pid_deb_cre) = 'D' THEN -- Debito
			LET cid_mensaje1 = 'POS_DEBS';
			LET cid_mensaje2 = 'POS_DEBE';			
		ELSE -- Credito	
			LET cid_mensaje1 = 'POS_CREDS';
			LET cid_mensaje2 = 'POS_CREDE';			
		END IF;	
	END IF;
	IF pcajero_propio ='V' THEN
		LET ccajero = 'CAJERO BANCOPPEL';
	ELIF pcajero_propio ='F' THEN
		LET ccajero = 'CAJERO DE OTRO BANCO';
	ELSE
		LET ccajero = 'COMPRA EN COMERCIO';	
	END IF	
	-- Localiza la última transacción pendiente - SMS
	SELECT MAX(secuencial) INTO dSecuencia FROM bdimnsj:"informix".mnsjr_trx_online 
		WHERE fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje1 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;
	IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN
		-- Valida si se trata de la transacción Original o es un reverso
		IF pid_reverso = '1' THEN
			-- Por ahora no se informarán los reversos
			RETURN cCodRet;
		END IF;	
	
		SET LOCK MODE TO WAIT 1;
		-- ACTUALIZAR DATOS DE LA ALERTA GENERADA Y CAMBIAR EL ID A NULL
		UPDATE  bdimnsj:"informix".mnsjr_trx_online 
			SET transaction_id = NULL, string6 = pinfreceptor, string9 = pno_autorizacion, string8 = psecuencia_ext, string7 = ccajero
			WHERE secuencial = dSecuencia AND
			fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje1 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;
	END IF;

	-- Localiza la última transacción pendiente - EMAIL
	SELECT MAX(secuencial) INTO dSecuencia FROM bdimnsj:"informix".mnsjr_trx_online 
		WHERE fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje2 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;
	IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN
		-- Valida si se trata de la transacción Original o es un reverso
		IF pid_reverso = '1' THEN
			-- Por ahora no se informarán los reversos
			RETURN cCodRet;
		END IF;	
		
		SET LOCK MODE TO WAIT 1;
		-- ACTUALIZAR DATOS DE LA ALERTA GENERADA Y CAMBIAR EL ID A NULL
		UPDATE  bdimnsj:"informix".mnsjr_trx_online 
			SET transaction_id = NULL, string6 = pinfreceptor, string9 = pno_autorizacion, string8 = psecuencia_ext, string7 = ccajero
			WHERE secuencial = dSecuencia AND
			fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje2 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;
	END IF;
	
END;	
RETURN 	cCodRet;
END PROCEDURE;