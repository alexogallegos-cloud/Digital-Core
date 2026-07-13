CREATE PROCEDURE "informix".sp_busca_producto_deb_inver_cliente(p_sNumeroCliente CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS numeroCuentaInversion;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto     CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
    	DEFINE resultado_numeroCuentaInversion		CHAR(30);
    	DEFINE iSqlErr                      		INTEGER;
	
     -- InicializaciÃ³n de las variables.
     LET resultado_numeroProducto = '';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
    LET resultado_numeroCuentaInversion = '';

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            	IF iSqlErr <> 0 THEN
                    LET resultado_numeroProducto = '';
                	LET resultado_nombreProducto = '';
                	LET resultado_numeroCuenta = '';
               		LET resultado_numeroTarjeta = '';
                    LET resultado_numeroCuentaInversion = '';
                	RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_numeroCuentaInversion;
           	END IF;
        END EXCEPTION;

		FOREACH
			SELECT SKIP p_skip DISTINCT '3000' as numeroProducto,nombre AS nombreProducto, cuenta AS cuentaProducto, cta_cheques as cuentaInvCheques
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroCuentaInversion
			FROM bdinvers:sv_maeinv 
                LEFT JOIN bdinvers:sv_instrum ON (bdinvers:sv_maeinv.cod_instrum = bdinvers:sv_instrum.cod_instrum) 
            	WHERE bdinvers:sv_maeinv.num_cte = p_sNumeroCliente 
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_numeroCuentaInversion WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;