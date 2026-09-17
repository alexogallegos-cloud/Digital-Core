CREATE PROCEDURE "informix".sp_cancelartokensbloqueados(pNumCte CHAR(10),pNsToken CHAR(11),pStatus CHAR(3),pUsuario CHAR(10),pCanal CHAR(2))
   returning char(5);
   
    DEFINE vCod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vSolicitud CHAR(10);
	
	
    LET vCod_ret  = "00000";
    

	--****************************************************************************************************
	-- DESCRIPCION:  CANCELA LOS TOKEN CON ESTATUS 152 EN LA SI_BPITOKEN, ASI COMO ACTUALIZA TABLAS TKN_SERIES,Y BPI_TOKENSOLICITUD
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 06/09/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--***************************************************************************************************
	-- MODIFICACIÓN:  ACTUALIZA EL CAMPO TIPO = 5 EN LA TABLA bdibpi:"informix".bpi_tokensolicitud.
	-- AUTOR : José de Jesús Nevarez
	-- FECHA : 13/10/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--***************************************************************************************************
	-- MODIFICACIÓN:  ACTUALIZA EL CAMPO id_status_token = '199' EN LA TABLA bdinteg:"informix".si_bpitoken 
	-- AUTOR : José de Jesús Nevarez
	-- FECHA : 20/10/2011
	-- BD: bdinteg
	-- SOLICITO :Mauricio León
	--***************************************************************************************************

	
	--set debug file to "sp_cancelartokensbloqueados.out";
	--trace on;
   BEGIN
	

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCod_ret = sql_err;
            RETURN vCod_ret;
      END IF ;
   END EXCEPTION ;
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		LET vCod_ret  = "00001";
		
		UPDATE bdinteg:"informix".si_bpitoken SET id_status_token = pStatus, f_status=current WHERE num_cliente = pNumCte;
		
		INSERT INTO  bdinteg:"informix".si_bpitokenhis(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro)
			SELECT empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro
				FROM bdinteg:"informix".si_bpitoken 
				WHERE num_cliente = pNumCte AND ns_token=pNsToken;
		
		LET vCod_ret  = "00002";
		DELETE 	FROM  bdinteg:"informix".si_bpitoken WHERE num_cliente = pNumCte AND ns_token=pNsToken;
		
		LET vCod_ret  = "00003";
		UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = pStatus, f_atencion=CURRENT, tipo='5' WHERE numcte=pNumCte AND ns_token=pNsToken;
		
				
		LET vCod_ret  = "00004";
		SELECT solicitud  INTO vSolicitud  FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte=pNumCte AND ns_token=pNsToken;
		INSERT INTO bdibpi:"informix".tkn_stasolicitud (solicitud, anterior, actual, f_registro) VALUES (vSolicitud, '152', pStatus, CURRENT);

		UPDATE bdibpi:"informix".tkn_envios SET id_status = pStatus ,comentarios="El token ha sido cancelado por presentar 5 días hábiles bloqueado" WHERE solicitud=vSolicitud;
		
		LET vCod_ret  = "00005";
		UPDATE bdibpi:"informix".tkn_nseries SET id_status = pStatus ,f_status=CURRENT WHERE ns_token=pNsToken;
		
		LET vCod_ret  = "00006";
		INSERT INTO bdibpi:"informix".tkn_status_token (ns_token, actual, anterior, f_cambio_status, usr_cambio_status, canal) 
		VALUES (pNsToken, pStatus, '152',CURRENT, pUsuario, pCanal);
		
		LET vCod_ret  = "00007";
		
		RETURN vCod_ret;
	END;
END PROCEDURE
;