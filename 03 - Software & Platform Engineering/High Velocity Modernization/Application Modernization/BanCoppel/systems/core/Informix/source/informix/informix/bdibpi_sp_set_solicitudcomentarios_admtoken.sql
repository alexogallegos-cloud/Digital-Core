CREATE PROCEDURE "informix".sp_set_solicitudcomentarios_admtoken(pNumSolicitud char(10), pNumCliente char(9), pComentarios char(200))
   returning char(5) ;

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Inserta comentarios de la solicitud del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 12/01/2010

---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    
   
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';
    

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

    IF EXISTS(SELECT numcte from bdibpi:bpi_tokensolicitud WHERE solicitud = pNumSolicitud AND numcte = pNumCliente) THEN
       
        UPDATE bdibpi:bpi_tokensolicitud SET comentarios = pComentarios WHERE solicitud = pNumSolicitud AND numcte = pNumCliente;

    ELSE
        
        LET cod_ret = '001';

    END IF;
        
    RETURN cod_ret;
   
END

END PROCEDURE;