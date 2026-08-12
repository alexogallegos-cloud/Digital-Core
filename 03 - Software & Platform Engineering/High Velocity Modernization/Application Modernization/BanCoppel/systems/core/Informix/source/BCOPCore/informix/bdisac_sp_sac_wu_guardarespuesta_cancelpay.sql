CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_cancelpay(pbandera_reversion char(1),pretcode char(5),pdescretcode char(30),pfecha_hora_cancelacion char(16),pfix_on_send char(1),phoja_impuestos char(300),pmonto_enviado_origen char(10),pmonto_pagar_destino char(10),pmonto_total_bruto_origen char(10), pmonto_cargo_extra_emisor char(10), pmonto_cargo_emisor char (10), pmonto_desc_promocion char(10), pmtcn char(16), pfecha_alta_remesa char(52), phora_alta_remesa char(16), pid_sistema_externo char(11), preferencia_sistema_externo char(16),pid_terminal_sistema_externo char(11), perror char(250),pparther_id char(10), pcadena_recibida char(534), pusuario_insert char(8))

   RETURNING char(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret           char(5);
   DEFINE sql_err           integer;
 
 	--SET DEBUG FILE TO '/home/sysifx/HMLG/sp_confpago_remesa.out';
	--TRACE ON;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "00000";
  
  		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
    END EXCEPTION;
	
	
	INSERT INTO bdisac:"informix".sac_wu_cancelpay (bandera_reversion, retcode, descretcode,  fecha_hora_cancelacion, fix_on_send, hoja_impuestos, monto_enviado_origen, monto_pagar_destino, monto_total_bruto_origen, monto_cargo_extra_emisor, monto_cargo_emisor, monto_desc_promocion, mtcn, fecha_alta_remesa, hora_alta_remesa, id_sistema_externo, referencia_sistema_externo, id_terminal_sistema_externo, error,
   parther_id, cadena_recibida, usuario_insert, fecha_insert) VALUES (pbandera_reversion, pretcode, pdescretcode, pfecha_hora_cancelacion, pfix_on_send, phoja_impuestos,pmonto_enviado_origen, pmonto_pagar_destino, pmonto_total_bruto_origen, pmonto_cargo_extra_emisor, pmonto_cargo_emisor, pmonto_desc_promocion, pmtcn, pfecha_alta_remesa, phora_alta_remesa, pid_sistema_externo, preferencia_sistema_externo, pid_terminal_sistema_externo, perror, pparther_id, pcadena_recibida, pusuario_insert, current);
	
	
	RETURN cod_ret;
END;
END PROCEDURE;