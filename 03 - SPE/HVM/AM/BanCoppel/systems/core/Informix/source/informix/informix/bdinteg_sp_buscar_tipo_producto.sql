CREATE PROCEDURE "informix".sp_buscar_tipo_producto(p_sNumeroCuenta CHAR(30), p_sTarjeta CHAR(30), p_sEmpresa CHAR(4))

     RETURNING	CHAR(3) AS tipoProducto;

	--definicion de variables--	    
	DEFINE resultado_tipoProducto   CHAR(3);
    	DEFINE cuenta_temp              CHAR(30);
    	DEFINE iSqlErr                  INTEGER;
     
     -- InicializaciÃ³n de las variables.
	LET resultado_tipoProducto = '';

    SET ISOLATION TO DIRTY READ;

	BEGIN

        /*ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_tipoProducto = '';
                    RETURN resultado_tipoProducto;
                END IF;
        END EXCEPTION;*/

		IF(p_sTarjeta IS NOT NULL AND p_sTarjeta <> '') THEN
			SELECT DISTINCT numcuenta
			INTO cuenta_temp
			FROM intercard:tarjetacuenta 
			WHERE numtarjeta = p_sTarjeta;

			SELECT DISTINCT cuenta
			INTO resultado_tipoProducto
			FROM bdicheq:sc_maechq
			WHERE empresa = p_sEmpresa
			AND cuenta = cuenta_temp;

			IF resultado_tipoProducto IS NOT NULL AND resultado_tipoProducto <> '' THEN
				RETURN 'CHQ';
			ELSE
				SELECT DISTINCT num_credito
				INTO resultado_tipoProducto
				FROM bdicred:sd_maecred
				WHERE empresa = p_sEmpresa
				AND num_credito = cuenta_temp;
				
				IF resultado_tipoProducto IS NOT NULL AND resultado_tipoProducto <> '' THEN
					RETURN 'CRE';
				ELSE
					Select mc.cuenta_tf--* 
					INTO cuenta_temp
					From bditransfer:tf_maecte mc
					Inner Join bdicheq:sc_tarjeta t ON ( t.cuenta = mc.cuenta_tf)
					where t.num_tarjeta = p_sTarjeta;
					
					Select cuenta_tf
					INTO resultado_tipoProducto
					from bditransfer:tf_maecte 
					where cuenta_tf = cuenta_temp;
					
					IF resultado_tipoProducto IS NOT NULL AND resultado_tipoProducto <> '' THEN
						RETURN 'CHQ'; --TRANSFER
					ELSE
						RETURN 'INV';
					END IF;
				END IF;
			END IF;                    
		ELSE 
			SELECT DISTINCT cuenta
			INTO resultado_tipoProducto
			FROM bdicheq:sc_maechq
			WHERE empresa = p_sEmpresa
			AND cuenta = p_sNumeroCuenta;

			IF resultado_tipoProducto IS NOT NULL AND resultado_tipoProducto <> '' THEN
				RETURN 'CHQ';
			ELSE
				SELECT DISTINCT num_credito
				INTO resultado_tipoProducto
				FROM bdicred:sd_maecred
				WHERE empresa = p_sEmpresa
				AND num_credito = p_sNumeroCuenta;
				
				IF resultado_tipoProducto IS NOT NULL AND resultado_tipoProducto <> '' THEN
					RETURN 'CRE';
				ELSE
					Select cuenta_tf
					INTO resultado_tipoProducto
					from bditransfer:tf_maecte 
					where cuenta_tf = p_sNumeroCuenta;
					
					IF resultado_tipoProducto IS NOT NULL AND resultado_tipoProducto <> '' THEN
						RETURN 'CHQ';
					ELSE
						RETURN 'INV';
					END IF;
				END IF;
			END IF;  
	   END IF;
	END 
END PROCEDURE;