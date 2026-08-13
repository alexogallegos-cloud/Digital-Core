CREATE PROCEDURE "informix".sp_buscar_detalle_tarjeta_adicional(p_skip INT, p_numeroTarjeta CHAR(16))
		
    RETURNING CHAR(1) AS titularTarjeta, CHAR(16) AS numeroTarjeta, 
              CHAR(3) AS estatusTarjeta, CHAR(104) AS nombreTarjeta, 
              CHAR(3) AS tipoProducto, CHAR(30) AS descProducto;

	--definicion de variables--	    
	DEFINE resultado_titularTarjeta 	CHAR(1);
    	DEFINE resultado_numeroTarjeta		CHAR(16);
	DEFINE resultado_estatusTarjeta		CHAR(3);
	DEFINE resultado_nombreTarjeta		CHAR(104);
    	DEFINE resultado_tipoProducto 		CHAR(3);
    	DEFINE resultado_descProducto           CHAR(30);
    	DEFINE cuenta_temp			CHAR(20);
   	DEFINE iSqlErr                      	INTEGER;
		
     -- InicializaciÃÂ³n de las variables.
	LET resultado_titularTarjeta = '';
	LET resultado_numeroTarjeta = '';
	LET resultado_estatusTarjeta = '';
	LET resultado_nombreTarjeta = '';
	LET resultado_tipoProducto = '';
    LET resultado_descProducto = '';
	
    SET ISOLATION TO dirty READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_titularTarjeta = '';
					LET resultado_numeroTarjeta = '';
					LET resultado_estatusTarjeta = '';
					LET resultado_nombreTarjeta = '';
					LET resultado_tipoProducto = '';
                    LET resultado_descProducto = '';    
                    RETURN resultado_titularTarjeta, resultado_numeroTarjeta,resultado_estatusTarjeta,resultado_nombreTarjeta,resultado_tipoProducto,resultado_descProducto;
                END IF;
        END EXCEPTION;
        
        SELECT numcuenta
        	INTO cuenta_temp
			FROM intercard:tarjetacuenta 
			WHERE intercard:tarjetacuenta.numtarjeta = p_numeroTarjeta;
        
		FOREACH       
	     	SELECT SKIP p_skip DISTINCT titular,numtarjeta,codstatustarjeta,nombre,intercard:tarjeta.codproductotarjeta,descproducto
	          INTO resultado_titularTarjeta, resultado_numeroTarjeta,resultado_estatusTarjeta,resultado_nombreTarjeta,resultado_tipoProducto,resultado_descProducto
	          FROM intercard:tarjeta
                LEFT JOIN intercard:productotarjeta ON (intercard:productotarjeta.codproductotarjeta = intercard:tarjeta.codproductotarjeta)
              WHERE numtarjeta in (select numtarjeta from intercard:tarjetacuenta where numcuenta = cuenta_temp)
	          RETURN resultado_titularTarjeta, resultado_numeroTarjeta,resultado_estatusTarjeta,resultado_nombreTarjeta,resultado_tipoProducto,resultado_descProducto WITH RESUME;
		END FOREACH;
	END
END PROCEDURE;