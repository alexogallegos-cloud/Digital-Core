CREATE PROCEDURE "informix".sp_confirma_evento (
					pid_pos_atm char(2), pid_deb_cre char(2), pid_reverso char(1), pno_tarjeta char(16), pno_autorizacion char(12),
					pinfreceptor char(40), pimporte money(16,2), pimp_comision money(16,2), pfecha_aut datetime year to fraction(3), 
					psecuencia_ext char(16), pcajero_propio char(1)
				    )

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.

--DefiniciÃÂÃÂ³n de Variables
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
DEFINE bandera CHAR(100);
--SYNDEIN
DEFINE stmt				LVARCHAR(2000);
DEFINE vTablaNotif		varchar (50);
DEFINE pfecha_aut_aux	varchar (10);
DEFINE pimporte_aux		varchar (20);
--SYNDEIN

--Inicializa Variables
LET cCodRet = '00000';
LET cid_mensaje1 = '';
LET cid_mensaje2 = '';
LET ccajero = '';
LET dSecuencia = 0;
LET vsqlerr = 0;
LET bandera='';


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

  --SET DEBUG FILE TO "/informix/JDSOTEST/sp_confirma_evento.out";
  --TRACE ON;
  
  RETURN cCodRet;

    SELECT valor INTO bandera  FROM mnsj_param WHERE cod_param='5';
	
	IF TRIM(bandera) = '0' THEN
		RETURN cCodRet;
	END IF;
  
--Determina el ID del mensaje a actualizar 'POS_DEBS','POS_CREDS','ATM_DEBS','ATM_CREDS','POS_DEBE','POS_CREDE','ATM_DEBE','ATM_CREDE'

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
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
--SYNDEIN
	IF (pno_tarjeta IS NULL) THEN
		LET pno_tarjeta = '';
    END IF;
	IF (pno_autorizacion IS NULL) THEN
		LET pno_autorizacion = '';
    END IF;
	IF (pinfreceptor IS NULL) THEN
		LET pinfreceptor = '';
    END IF;
	IF (pimporte IS NULL) THEN
		LET pimporte = 0.00;
    END IF;
	IF (pimp_comision IS NULL) THEN
		LET pimp_comision = 0.00;
    END IF;
	IF (psecuencia_ext IS NULL) THEN
		LET psecuencia_ext = '';
    END IF;
	IF (pcajero_propio IS NULL) THEN
		LET pcajero_propio = '';
    END IF;	
	LET pfecha_aut_aux = SUBSTR (pfecha_aut, 1, 10);
	LET pimporte_aux = SUBSTR(pimporte, 2 , 50);
        SELECT nombre_tabla
                INTO vTablaNotif
                FROM notif_cfg
                WHERE id_mensaje = cid_mensaje1;
                --AND tipo_mensaje = 1
                --AND tipo_proceso = 1;

        IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN
                SELECT nombre_tabla
                INTO vTablaNotif
                FROM notif_cfg
                WHERE id_mensaje = 'DEFAULT'
                AND tipo_mensaje = 2
                AND tipo_proceso = 1;
                --IF (pTipoproc = '1') THEN
                --        LET vTablaNotif = 'intercard:notif_online_default'; 
                --ELSE
                --        LET vTablaNotif = 'intercard:notif_batch_default'; 
                --END IF;
        END IF;
		
	--LET stmt = "SELECT MAX(secuencial) FROM " || vTablaNotif || " WHERE fecha_hora_registro::DATE = '" || pfecha_aut_aux || "'::DATE AND id_mensaje = '" || cid_mensaje1 ||"' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux ||" ;";
	LET stmt = "SELECT MAX(secuencial) FROM " || vTablaNotif || " WHERE fecha_hora_registro between '" || pfecha_aut_aux || " 00:00:00' AND '" || pfecha_aut_aux || " 23:59:59' AND id_mensaje = '" || cid_mensaje1 ||"' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux ||" ;";
    PREPARE p FROM stmt;
    DECLARE C CURSOR FOR p;
    OPEN C;

        FETCH C INTO dSecuencia;
        IF sqlcode != 0 THEN
			CLOSE C;
			FREE C;
			FREE p;
            return sqlcode;
        END IF;

	/*SELECT MAX(secuencial) INTO dSecuencia FROM bdimnsj:"informix".mnsjr_trx_online 
			WHERE fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje1 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;*/
--SYNDEIN
	IF (dSecuencia IS NULL) THEN
                LET dSecuencia = 0;
    END IF;
	IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN
		-- Valida si se trata de la transacciÃÂÃÂ³n Original o es un reverso
		IF pid_reverso = '1' THEN
			-- Por ahora no se informarÃÂÃÂ¡n los reversos
			RETURN cCodRet;
		END IF;	
	
		
		-- ACTUALIZAR DATOS DE LA ALERTA GENERADA Y CAMBIAR EL ID A NULL
		--SYNDEIN
		--LET stmt ="UPDATE  " || vTablaNotif || " SET transaction_id = NULL, string6 = '" || pinfreceptor || "', string9 = '" || pno_autorizacion || "', string8 = '" || psecuencia_ext || "', string7 = '" || ccajero ||"' WHERE secuencial = '" || dSecuencia || "' AND fecha_hora_registro::DATE = '" || pfecha_aut_aux || "'::DATE AND id_mensaje = '" || cid_mensaje1 || "' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux || " ;";
		LET stmt ="UPDATE  " || vTablaNotif || " SET transaction_id = NULL, string6 = '" || pinfreceptor || "', string9 = '" || pno_autorizacion || "', string8 = '" || psecuencia_ext || "', string7 = '" || ccajero ||"' WHERE secuencial = '" || dSecuencia || "' AND fecha_hora_registro between '" || pfecha_aut_aux || " 00:00:00' AND '" || pfecha_aut_aux || " 23:59:59'  AND id_mensaje = '" || cid_mensaje1 || "' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux || " ;";
		EXECUTE IMMEDIATE stmt;
		/*
		UPDATE  bdimnsj:"informix".mnsjr_trx_online 
			SET transaction_id = NULL, string6 = pinfreceptor, string9 = pno_autorizacion, string8 = psecuencia_ext, string7 = ccajero
			WHERE secuencial = dSecuencia AND
			fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje1 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;
		*/
--SYNDEIN
	END IF;
		CLOSE C;
		FREE C;
		FREE p;
--SYNDEIN
        SELECT nombre_tabla
                INTO vTablaNotif
                FROM notif_cfg
                WHERE id_mensaje = cid_mensaje2 ; --cid_mensaje1
                --AND tipo_mensaje = 2
                --AND tipo_proceso = 1;

        IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN
                SELECT nombre_tabla
                INTO vTablaNotif
                FROM notif_cfg
                WHERE id_mensaje = 'DEFAULT'
                AND tipo_mensaje = 1
                AND tipo_proceso = 1; 
                --IF (pTipoproc = '1') THEN
                --        LET vTablaNotif = 'intercard:notif_online_default'; 
                --ELSE
                --        LET vTablaNotif = 'intercard:notif_batch_default'; 
                --END IF;
        END IF;

	--LET stmt = "SELECT MAX(secuencial) FROM " || vTablaNotif || " WHERE fecha_hora_registro::DATE = '" || pfecha_aut_aux || "'::DATE AND id_mensaje = '" || cid_mensaje2 ||"' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux ||" ;";
	LET stmt = "SELECT MAX(secuencial) FROM " || vTablaNotif || " WHERE fecha_hora_registro between '" || pfecha_aut_aux || " 00:00:00' AND '" || pfecha_aut_aux || " 23:59:59' AND id_mensaje = '" || cid_mensaje2 ||"' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux ||" ;";

	PREPARE p FROM stmt;
    DECLARE C CURSOR FOR p;
    OPEN C;

        FETCH C INTO dSecuencia;
        IF sqlcode != 0 THEN
			CLOSE C;
			FREE C;
			FREE p;
            return sqlcode;

        END IF;

	
	
	/*SELECT MAX(secuencial) INTO dSecuencia FROM bdimnsj:"informix".mnsjr_trx_online 
		WHERE fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje2 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;*/
--SYNDEIN
	IF (dSecuencia IS NULL) THEN
                LET dSecuencia = 0;
    END IF;
	IF dSecuencia > 0 AND NOT dSecuencia IS NULL THEN
		-- Valida si se trata de la transaccion Original o es un reverso
		IF pid_reverso = '1' THEN
			-- Por ahora no se informaron los reversos
			RETURN cCodRet;
		END IF;	
		
		
		-- ACTUALIZAR DATOS DE LA ALERTA GENERADA Y CAMBIAR EL ID A NULL
		--SYNDEIN
				--LET stmt ="UPDATE  " || vTablaNotif || " SET transaction_id = NULL, string6 = '" || pinfreceptor || "', string9 = '" || pno_autorizacion || "', string8 = '" || psecuencia_ext || "', string7 = '" || ccajero ||"' WHERE secuencial = '" || dSecuencia || "' AND fecha_hora_registro::DATE = '" || pfecha_aut_aux || "'::DATE AND id_mensaje = '" || cid_mensaje2 || "' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux || " ;";
				LET stmt ="UPDATE  " || vTablaNotif || " SET transaction_id = NULL, string6 = '" || pinfreceptor || "', string9 = '" || pno_autorizacion || "', string8 = '" || psecuencia_ext || "', string7 = '" || ccajero ||"' WHERE secuencial = '" || dSecuencia || "' AND fecha_hora_registro between '" || pfecha_aut_aux || " 00:00:00' AND '" || pfecha_aut_aux || " 23:59:59' AND id_mensaje = '" || cid_mensaje2 || "' AND tarjeta = '" || pno_tarjeta || "' AND transaction_id = 'PENDIENTE' AND estatus IS NULL AND importe2 = " || pimporte_aux || " ;";
		EXECUTE IMMEDIATE stmt;

		/*
		UPDATE  bdimnsj:"informix".mnsjr_trx_online 
			SET transaction_id = NULL, string6 = pinfreceptor, string9 = pno_autorizacion, string8 = psecuencia_ext, string7 = ccajero
			WHERE secuencial = dSecuencia AND
			fecha_hora_registro::DATE = pfecha_aut::DATE AND
			id_mensaje = cid_mensaje2 AND
			tarjeta = pno_tarjeta AND 
			transaction_id = 'PENDIENTE' AND
			estatus IS NULL AND
			importe2 = pimporte;*/
--SYNDEIN
	END IF;
		CLOSE C;
		FREE C;
		FREE p;
END;	
RETURN 	cCodRet;
END PROCEDURE;