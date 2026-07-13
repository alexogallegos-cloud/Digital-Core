CREATE PROCEDURE "informix".sp_monitoreo_sms()
RETURNING CHAR(5) AS CodRetorno,
		  CHAR(200) AS Mensaje; 

/*DEFINICION DE VARIABLES */
DEFINE vsCodRetorno       CHAR (5);
DEFINE vsMensaje          CHAR(200);
DEFINE sql_err            SMALLINT;
DEFINE isam_err           SMALLINT;
DEFINE error_info         CHAR(40);

/*MANEJO DEL ERROR*/
       ON EXCEPTION
		SET sql_err, isam_err, error_info 
		 
           IF sql_err <> 0 THEN
            LET vsCodRetorno=sql_err;

            RETURN vsCodRetorno, vsMensaje;
           END IF;
       END EXCEPTION;

/* FIN DE DEFINICION DE VARIABLES*/
LET vsCodRetorno = '00000';
LET vsMensaje = '';
LET sql_err = 0;   
LET isam_err = 0;  
LET error_info = '';

BEGIN

	IF (vsCodRetorno='00000') THEN
	
		LET vsMensaje ='VAL_AURO';
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','1','','','','','','','','','','',
		'','6671850969',1,0,0,0,0,current,'') INTO vsCodRetorno;
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','1','','','','','','','','','','',
		'','6674311669',1,0,0,0,0,current,'') INTO vsCodRetorno; ---TELCEL
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','1','','','','','','','','','','',
		'','6673825707',1,0,0,0,0,current,'') INTO vsCodRetorno; ---MOVISTAR
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AURO','VAL_AURO','000000000','','','1','','','','','','','','','','',
		'','6674485735',1,0,0,0,0,current,'') INTO vsCodRetorno; ---AT&T
				
		LET vsMensaje ='VAL_AUTO';
			
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','1','','','','','','','','','','',
		'','6671850969',1,0,0,0,0,current,'') INTO vsCodRetorno;
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','1','','','','','','','','','','',
		'','6674311669',1,0,0,0,0,current,'') INTO vsCodRetorno; ---TELCEL
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','1','','','','','','','','','','',
		'','6673825707',1,0,0,0,0,current,'') INTO vsCodRetorno; ---MOVISTAR
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_AUTO','VAL_AUTO','000000000','','','1','','','','','','','','','','',
		'','6674485735',1,0,0,0,0,current,'') INTO vsCodRetorno; ---AT&T
		
		LET vsMensaje ='VAL_INNO';
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','1','','','','','','','','','','',
		'','6671850969',1,0,0,0,0,current,'') INTO vsCodRetorno;
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','1','','','','','','','','','','',
		'','6674311669',1,0,0,0,0,current,'') INTO vsCodRetorno; ---TELCEL
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','1','','','','','','','','','','',
		'','6673825707',1,0,0,0,0,current,'') INTO vsCodRetorno; ---MOVISTAR
		
		EXECUTE PROCEDURE "informix".sp_registra_evento('1','VAL_INNO','VAL_INNO','000000000','','','1','','','','','','','','','','',
		'','6674485735',1,0,0,0,0,current,'') INTO vsCodRetorno; ---AT&T
		
	END IF;
		
		LET vsCodRetorno = '00000';
		LET vsMensaje ='PROCESO EXITOSO..';
		
		
	RETURN vsCodRetorno, vsMensaje;

END;
END PROCEDURE;