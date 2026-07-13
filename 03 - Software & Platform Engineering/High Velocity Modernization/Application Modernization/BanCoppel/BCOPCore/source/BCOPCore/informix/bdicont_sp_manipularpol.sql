CREATE PROCEDURE "informix".sp_manipularpol(p_inumero INTEGER, p_iaccion INTEGER)

    RETURNING CHAR(6), INTEGER;

	DEFINE		sql_err                 INTEGER;
	DEFINE		isam_err                INTEGER;
	DEFINE		error_info              CHAR(40);
    DEFINE      cod_ret                 CHAR(6);

	DEFINE		v_iexiste				INTEGER;
	DEFINE		v_inumero				INTEGER;

	BEGIN

		ON EXCEPTION SET sql_err, isam_err, error_info
			LET cod_ret = sql_err;
			RETURN cod_ret, isam_err;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		
		LET cod_ret = '000';
		LET v_iexiste = 0;
		LET v_inumero = 0;

		--CONSULTAR
        IF p_iaccion = 1 AND p_inumero = 0 THEN

            SELECT numero 
			INTO   v_inumero
            FROM   bdicont:co_ctrlpoliza;

		--GRABAR O MODIFICAR
		ELIF p_iaccion = 2 THEN

			UPDATE bdicont:co_ctrlpoliza SET numero = numero + 1;

			SELECT numero 
			INTO   v_inumero
			FROM   bdicont:co_ctrlpoliza;
				
        ELSE
            LET cod_ret = '001';
        END IF

		RETURN cod_ret, v_inumero;

	END
END PROCEDURE;