CREATE PROCEDURE "informix".sp_set_solicitudstatus_admtoken_bei(pNumSolicitud char(10), pNumCliente char(9), pUsrAtiende char(8),  pStatusViejo char(3), pStatusNuevo char(3) )
   returning char(5);
   
--------------------------------------------------------------------------------------------
-- Realizó: Jose Ruben Lopez
-- Actividad: Actualiza el estatus de la solicitud del AdmToken personas morales
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 24-07-2013
---------------------------------------------------------------------------------------------
-- Define variables
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
	
-- Inicializa variables
    LET cod_ret  = '000';
	--SET DEBUG FILE TO '/tmp/sp_set_solicitudstatus_admtoken_bei.out';
	--TRACE ON;

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
    IF EXISTS(SELECT numcte FROM "informix".bei_solicitudtoken WHERE solicitud = pNumSolicitud AND numcte = pNumCliente) THEN
       
        UPDATE "informix".bei_solicitudtoken SET id_status = pStatusNuevo, f_atencion = CURRENT, usr_atiende = pUsrAtiende  WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;

        INSERT INTO "informix".bei_stasolicitud (solicitud,anterior,actual,f_registro) VALUES(pNumSolicitud,pStatusViejo,pStatusNuevo,CURRENT);
		
		--si tiene tokens asignados cambia el estatus en la tabla bei_tokensolicitud
		IF EXISTS(SELECT solicitud FROM "informix".bei_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente)THEN
			IF (pStatusNuevo =100) THEN
				DELETE FROM "informix".bei_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;
			ELSE
				UPDATE "informix".bei_tokensolicitud 
				SET id_status=pStatusNuevo 
				WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;
			END IF	
		END IF
		--si tiene registro de envio se cambia el estatus en la tabla bei_envio
		IF EXISTS(SELECT solicitud FROM "informix".bei_envios WHERE solicitud = pNumSolicitud AND numcte = pNumCliente AND id_status=pStatusViejo)THEN
			UPDATE "informix".bei_envios
			SET id_status=pStatusNuevo 
			WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;
		END IF
    ELSE
        LET cod_ret = '001';
    END IF;
    
    RETURN cod_ret;
   
END

END PROCEDURE ;