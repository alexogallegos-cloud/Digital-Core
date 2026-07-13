CREATE PROCEDURE "informix".sp_set_solicitudcomentarios_admtoken_bei(pNumSolicitud char(10), pNumCliente char(9), pComentarios char(200))
   returning char(5) ;

--------------------------------------------------------------------------------------------
-- Realizó: Jose Ruben Lopez
-- Actividad: Inserta comentarios de la solicitud del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud:24/07/2013
---------------------------------------------------------------------------------------------

-- Define variables
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
-- Inicializa variables
    LET cod_ret  = '000';
    
	--SET DEBUG FILE TO '/tmp/sp_set_devolucion_comentarios_admtoken_bei.out';
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
	
    IF EXISTS(SELECT numcte from "informix".bei_solicitudtoken WHERE solicitud = pNumSolicitud AND numcte = pNumCliente) THEN
       
        UPDATE "informix".bei_solicitudtoken SET comentarios = pComentarios WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;

    ELSE
        LET cod_ret = '001';
    END IF;
    RETURN cod_ret;
END
END PROCEDURE;