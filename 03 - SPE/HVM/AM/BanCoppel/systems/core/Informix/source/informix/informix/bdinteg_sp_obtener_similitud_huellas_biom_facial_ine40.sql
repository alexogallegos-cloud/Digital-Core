CREATE PROCEDURE "informix".sp_obtener_similitud_huellas_biom_facial_ine40( )

	RETURNING CHAR(5) AS CodRet, CHAR(5) AS Similitud;
	
	DEFINE iSqlErr 	    						INTEGER;
	DEFINE cCodRet 	    						CHAR(5);
	DEFINE v_Similitud							CHAR(5);
	DEFINE sql_err 								INTEGER;
	DEFINE isam_err         					INTEGER;
	DEFINE error_info       					VARCHAR(60);
	
	LET		iSqlErr = 0;
	LET 	cCodRet = '00000';
	LET 	v_Similitud = '00000';
	LET 	sql_err = 0;
	LET 	isam_err = 0;
	LET 	error_info = "";
	BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cCodRet = sql_err;
			RETURN cCodRet, v_Similitud;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		SELECT valor INTO v_Similitud FROM si_param WHERE cod_param='566';
		RETURN cCodRet, v_Similitud;
		
	END
END PROCEDURE;