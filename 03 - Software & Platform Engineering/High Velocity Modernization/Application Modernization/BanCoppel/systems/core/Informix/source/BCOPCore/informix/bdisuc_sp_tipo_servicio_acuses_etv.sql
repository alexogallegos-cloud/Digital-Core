CREATE PROCEDURE "informix".sp_tipo_servicio_acuses_etv()

RETURNING CHAR(5),CHAR(15);


DEFINE SQL_ERR 			INTEGER;
DEFINE ISAM_ERR 		INTEGER;
DEFINE cod_ret 			CHAR(5);
DEFINE vtipo_servicio_acuses 	CHAR(15);


LET cod_ret = '00000';
LET vtipo_servicio_acuses = '';



BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR
        LET cod_ret = SQL_ERR; 
		
        RETURN cod_ret,vtipo_servicio_acuses;
		
		
    END EXCEPTION;

    set isolation to dirty read;
	
	--SET debug file to "/informix/1170/calizarraga/sp_tipo_servicio_etv.out";
	--trace on;

    FOREACH
        SELECT tipo_servicio
        INTO vtipo_servicio_acuses
        FROM bdisuc:"informix".ss_tipo_servicio_acuses_etv
        

        RETURN cod_ret,vtipo_servicio_acuses WITH resume;
    END FOREACH;
END;

END PROCEDURE;