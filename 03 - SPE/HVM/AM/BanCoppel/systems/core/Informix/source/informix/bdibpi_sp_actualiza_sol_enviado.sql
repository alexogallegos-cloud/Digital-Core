CREATE PROCEDURE "informix".sp_actualiza_sol_enviado (pNumSolicitud CHAR(10),pSerieToken CHAR(9),pNumCliente CHAR(9),pStatusNuevo CHAR(4),pUsrAtendio CHAR(9),pCanal CHAR(2))
   RETURNING CHAR(5);

--------------------------------------------------------------------------------------------
-- Realizó: José Rubén López
-- Actividad: Actualiza estatus de la solicitud y el token.
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 11-08-2014

    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
	DEFINE vEstatusSolicitudAnt CHAR(4);
	DEFINE vEstatusTokenAnt CHAR(4);
	
	LET cod_ret  = '00000';
	LET vEstatusSolicitudAnt='';
	LET vEstatusTokenAnt='';
	--SET DEBUG FILE TO "/home/sp_actualiza_sol_enviado.out";
	--TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT id_status 
	INTO vEstatusSolicitudAnt
	FROM bdibpi:"informix".bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte=pNumCliente;
	
    IF(NVL(vEstatusSolicitudAnt,'') <>'')THEN
		--SE ACTUALIZA LA SOLICITUD A 120
		EXECUTE PROCEDURE bdibpi:"informix".sp_set_solicitudstatus_admtoken(pNumSolicitud, pNumCliente, pUsrAtendio, vEstatusSolicitudAnt, pStatusNuevo) INTO cod_ret;
		IF cod_ret<>'000' THEN
			LET cod_ret='00001';
			RETURN cod_ret;
		END IF;
		
		--SE OBTIENE EL ESTATUS DEL TOKEN
		SELECT id_status 
		INTO vEstatusTokenAnt
		FROM bdibpi:"informix".tkn_nseries WHERE ns_token = pSerieToken;	
		--SE ACTUALIZA EL TOKEN A 120
		EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(pSerieToken, vEstatusTokenAnt, pStatusNuevo, pUsrAtendio,pCanal)
		INTO cod_ret;
		IF cod_ret<>'000' THEN
			LET cod_ret='00002';
			RETURN cod_ret;
		END IF;
		
		--SE ACTUALIZA EL ESTATUS DEL TOKEN
		UPDATE bdinteg:"informix".si_bpitoken SET id_status_token='120', f_status = current WHERE num_cliente=pNumCliente AND ns_token=pSerieToken;

	ELSE
        LET cod_ret = '00001';
    END IF;
        
    RETURN cod_ret;
   
END

END PROCEDURE;