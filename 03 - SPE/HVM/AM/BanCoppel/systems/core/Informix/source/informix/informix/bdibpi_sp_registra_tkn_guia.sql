CREATE PROCEDURE "informix".sp_registra_tkn_guia(pNumSolicitud CHAR(10), pNumCliente CHAR(9), pNumGuia CHAR(30),pCodRastreo CHAR(10))
   returning CHAR(5) ;

--------------------------------------------------------------------------------------------
-- Realizó: José Rubén López
-- Actividad: Inserta guia y cod de rastreo en las tablas tkn_envios y tkn_guias
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 11-08-2014

    DEFINE sql_err INTEGER ;
    DEFINE cod_ret CHAR(5);
    DEFINE fEnvio DATETIME year to second;
	DEFINE nToken CHAR(10);
	DEFINE nSucursal CHAR(4);
	DEFINE nFactura VARCHAR(20);
	DEFINE nSolicitud CHAR(10);
	DEFINE nEnvio SMALLINT;
    
	LET cod_ret  = '00000';
	LET nToken='';
	LET nSucursal='';
	LET nFactura='';
    LET fEnvio=CURRENT::DATE + 1;
	LET nSolicitud='';
	LET nEnvio=0;
--SET DEBUG FILE TO "/home/sp_registra_tkn_guia.out";
--TRACE ON
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT ns_token,sucursal 
	INTO nToken,nSucursal
	FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte=pNumCliente AND solicitud=pNumSolicitud;
	
	LET nFactura=TRIM(nToken)||'-'||TRIM(nSucursal);
	
    IF EXISTS(SELECT cte_destino from bdibpi:"informix".tkn_guias WHERE cte_destino = pNumCliente AND factura=nFactura) THEN
        UPDATE bdibpi:"informix".tkn_guias SET num_guia = pNumGuia,cod_rastreo=pCodRastreo WHERE cte_destino = pNumCliente AND factura=nFactura;
		
		
		SELECT solicitud,num_envio 
		INTO nSolicitud,nEnvio
		FROM bdibpi:"informix".tkn_envios 
		WHERE solicitud=pNumSolicitud AND numcte=pNumCliente;
		
		IF NVL(nSolicitud, '')='' THEN
			INSERT INTO bdibpi:"informix".tkn_envios (solicitud,num_envio,id_status,comentarios,f_envio,f_registro,num_guia,numcte,cod_rastreo) 
			VALUES(pNumSolicitud,'1',120,'',fEnvio,CURRENT,pNumGuia,pNumCliente,pCodRastreo);
		ELSE
			UPDATE bdibpi:"informix".tkn_envios SET id_status=120, f_envio=fEnvio, num_guia=pNumGuia,cod_rastreo=pCodRastreo,num_envio=nEnvio+1 
			WHERE solicitud=pNumSolicitud AND numcte=pNumCliente;
		END IF;
    ELSE
        LET cod_ret = '00001';
    END IF;
        
    RETURN cod_ret;
   
END

END PROCEDURE;