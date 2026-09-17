CREATE PROCEDURE "informix".sp_busca_producto_cred_cuenta_crd(p_sNumeroCuenta CHAR(20), p_skip INT, p_sNumeroEmpresa CHAR(3))

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta;

	--definicion de variables--
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto         CHAR(60);
	DEFINE resultado_numeroCuenta           CHAR(30);
	DEFINE resultado_numeroTarjeta          CHAR(30);
	DEFINE iSqlErr                          INTEGER;
	
     -- InicializaciÃÂ³n de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';

    SET ISOLATION TO dirty READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
            END IF;
        END EXCEPTION;

        	FOREACH
			SELECT SKIP p_skip bdicred:sd_definicion.num_producto,nombre_prod, num_credito, numtarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			FROM bdicred:sd_maecredcrd 
                	LEFT JOIN bdicred:sd_definicion 
                        ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa 
                            AND bdicred:sd_definicion.num_producto = bdicred:sd_maecredcrd.num_producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecredcrd.num_credito = intercard:tarjetacuenta.numcuenta)
            		WHERE num_credito = p_sNumeroCuenta
					AND bdicred:sd_maecredcrd.status_cred IN ('AA','BA','BT','E1','E2','E3') -- Solo tomar en cuenta crÃ©ditos con los estatus 					
            		ORDER BY num_credito asC

			--IFRS Se contemplan los nuevos estatus por Etapas				
             --AND bdicred:sd_maecredcrd.status_cred IN ('AA','BA','BT') -- Solo tomar en cuenta crÃ©ditos con los estatus 			
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta WITH RESUME;
        	END FOREACH;
	END
END PROCEDURE;