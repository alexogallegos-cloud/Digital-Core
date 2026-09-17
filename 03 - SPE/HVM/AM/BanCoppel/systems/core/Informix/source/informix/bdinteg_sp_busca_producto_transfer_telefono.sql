CREATE PROCEDURE "informix".sp_busca_producto_transfer_telefono(p_sTelefonoCliente CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 	CHAR(60);
	DEFINE resultado_numeroCuenta		CHAR(30);
	DEFINE resultado_numeroTarjeta		CHAR(30);
    DEFINE resultado_telefonoTransfer	CHAR(30);
    DEFINE resultado_numclienteTransfer	CHAR(30);
	DEFINE iSqlErr                      	INTEGER;
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto = '';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
    LET resultado_telefonoTransfer = '';
    LET resultado_numClienteTransfer = '';

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                LET resultado_telefonoTransfer = '';
                LET resultado_numClienteTransfer = '';
            RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer;
            END IF;
        END EXCEPTION;

		FOREACH
	        SELECT SKIP p_skip DISTINCT bdicheq:sc_producto.producto as numeroProducto,bdicheq:sc_producto.nombre AS nombreProducto, 
                bditransfer:tf_maecte.cuenta_tf AS cuentaProducto,
                bdicheq:sc_tarjeta.num_tarjeta AS tarjetaProducto,
                bditransfer:tf_maecte.telefono AS telefonoTransfer,
                bditransfer:tf_maecte.numcte_tf AS numClienteTransfer
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer 
              FROM bditransfer:tf_maecte
              LEFT JOIN bdicheq:sc_producto ON ( bdicheq:sc_producto.producto = bditransfer:tf_maecte.producto)
			  LEFT JOIN bdicheq:sc_tarjeta ON ( bdicheq:sc_tarjeta.cuenta = bditransfer:tf_maecte.cuenta_tf)
              WHERE bditransfer:tf_maecte.telefono= p_sTelefonoCliente
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;