CREATE PROCEDURE "informix".sp_consulta_carrier_adn ()

     RETURNING	CHAR(4) AS idCarrier, CHAR(40) AS nombreCarrier;

	--definicion de variables--	    
	DEFINE resultado_idCarrier	 	CHAR(4);
    DEFINE resultado_nombreCarrier	CHAR(40);
    DEFINE iSqlErr                  INTEGER;
		
     -- InicializaciÃ³n de las variables.
	LET resultado_idCarrier = '';
	LET resultado_nombreCarrier = '';

    SET ISOLATION TO DIRTY READ;
				
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                   		LET resultado_idCarrier = '';
						LET resultado_nombreCarrier = '';
                    RETURN resultado_idCarrier, resultado_nombreCarrier;
                END IF;
        END EXCEPTION;
      
		FOREACH
			SELECT cve_carrier, nombre_carrier
			INTO resultado_idCarrier, resultado_nombreCarrier
			FROM bdinteg:si_carriers car, bdicred:"informix".sd_param_campania par
			WHERE car.cve_carrier = par.valor_numerico
			AND par.tipo_campania  =66
			AND par.grupo_parametro ='ADN_MOVIL'			
			
			
            RETURN resultado_idCarrier, resultado_nombreCarrier WITH resume;
        END FOREACH;
	END
END PROCEDURE;