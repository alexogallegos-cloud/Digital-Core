CREATE PROCEDURE "informix".sp_extrae_llave_publica	(user_id INTEGER)
RETURNING 	VARCHAR(6) as Cod_ret,
			VARCHAR(80) as Men_ret,
			CHAR(30) as llavepublica;


-- Variables generales 

	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	
-- Variables de retorno
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	
	DEFINE  vllavepublica       CHAR (30);
	
	
--	SET DEBUG FILE TO "/informix/HomeInformix/rrm/sp_extrae_llave_publica.out";
--	TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET  = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
	  
      RETURN 	(P_COD_RET),
				(P_MENSAJE),
				(vllavepublica);
	  
   END EXCEPTION;

	
	LET  vllavepublica  = '';
		
	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'LLave publica obtenida con exito!!';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	select llave_publica into vllavepublica FROM "informix".provedor_maquila WHERE id = user_id ;

			
	if ((vllavepublica is null) or (vllavepublica = '')) then
			LET P_COD_RET = '66666';
			LET P_MENSAJE = 'Error al Obtener la llave publica';
	end if;
	
	RETURN	 	(P_COD_RET), (P_MENSAJE), trim(vllavepublica);
				

END;
END PROCEDURE;