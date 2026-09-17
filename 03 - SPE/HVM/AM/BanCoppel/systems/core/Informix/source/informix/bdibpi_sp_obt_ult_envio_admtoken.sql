CREATE PROCEDURE "informix".sp_obt_ult_envio_admtoken(pSolicitud char(10))
   returning char(5), char(10), char(20), char(30), char(200);

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Obtiene los datos de la consulta del último envio del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 07/01/2009
-- Modificó: Javier Calderón
-- Fecha de Modificación: 11/03/2010
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret      char(5);
	DEFINE sql_err      integer;
	DEFINE vNumEnvio    char(10);
    DEFINE vFecha       char(20) ;
	DEFINE vNumGuia     char(30);
	DEFINE vComentarios char(200) ;
    	
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret      = '000';
   LET vNumEnvio     = '';
   LET vFecha       = '01-01-1900';
   LET vNumGuia      = '';
   LET vComentarios  = '';
   

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNumEnvio, vFecha, vNumGuia, vComentarios;
      END IF ;
   END EXCEPTION ;
		
	IF EXISTS (SELECT num_envio FROM bdibpi:tkn_envios WHERE solicitud = pSolicitud ) THEN
            
            SELECT LIMIT 1 num_envio::char(10), f_envio::char(20), num_guia, comentarios
            INTO vNumEnvio, vFecha, vNumGuia, vComentarios
            FROM bdibpi:tkn_envios WHERE solicitud = pSolicitud
            AND num_envio = (SELECT MAX(num_envio) FROM bdibpi:tkn_envios WHERE solicitud = pSolicitud  );
            
        ELSE
            
            LET cod_ret = '001';
            
        END IF;
	
	 RETURN cod_ret, vNumEnvio, vFecha, vNumGuia, vComentarios;

END

END PROCEDURE ;