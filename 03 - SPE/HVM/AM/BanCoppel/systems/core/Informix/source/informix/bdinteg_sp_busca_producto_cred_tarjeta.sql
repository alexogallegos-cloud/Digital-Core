CREATE PROCEDURE "informix".sp_busca_producto_cred_tarjeta(p_sNumeroTarjeta CHAR(20), p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto     CHAR(60);
	DEFINE resultado_numeroCuenta       CHAR(30);
	DEFINE resultado_numeroTarjeta      CHAR(30);
	DEFINE iSqlErr                      INTEGER;
	
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
			SELECT bdicred:sd_definicion.num_producto,nombre_prod, num_credito, numtarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			FROM bdicred:sd_maecred 
                	LEFT JOIN bdicred:sd_definicion 
                        ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa
                        AND bdicred:sd_definicion.num_producto = bdicred:sd_maecred.num_producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
                    WHERE bdicred:sd_maecred.empresa = p_sNumeroEmpresa
					AND status_cred IN ('AA','BA','BT','E1','E2','E3') 
            		AND numtarjeta = p_sNumeroTarjeta

					--IFRS Se contemplan los nuevos estatus por Etapas			
					--AND status_cred IN ('AA','BA','BT') 							
                    RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;        
			END FOREACH;

			
	END
END PROCEDURE;