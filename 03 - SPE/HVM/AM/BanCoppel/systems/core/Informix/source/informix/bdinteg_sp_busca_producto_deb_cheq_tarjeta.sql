CREATE PROCEDURE "informix".sp_busca_producto_deb_cheq_tarjeta(p_sNumeroTarjeta CHAR(20))

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
	DEFINE iSqlErr                      	INTEGER;
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto ='';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
            END IF;
        END EXCEPTION;
		
		FOREACH
			SELECT DISTINCT bdicheq:sc_maechq.producto as numeroProducto,nombre AS nombreProducto, cuenta AS cuentaProducto, numtarjeta AS tarjetaProducto
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			FROM bdicheq:sc_maechq 
               		LEFT JOIN bdicheq:sc_producto ON (bdicheq:sc_maechq.producto = bdicheq:sc_producto.producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicheq:sc_maechq.cuenta = intercard:tarjetacuenta.numcuenta)
			WHERE intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
		END FOREACH;
		
	END
END PROCEDURE;