CREATE PROCEDURE "informix".sp_movctes_huellasatrasadas(pLimite INTEGER)
   RETURNING char (5) AS cCodRet;
      
DEFINE sCont	SMALLINT;
DEFINE cCodRet	char(5);
DEFINE iSql_err integer;

---Datos de tabla
DEFINE vnumcte   CHAR(20);
DEFINE vfecha_consulta DATE;
DEFINE vsecuencia CHAR(2);
DEFINE vsucursal CHAR(4);
DEFINE vip CHAR(15);
DEFINE vstatus_huella CHAR(1);
DEFINE vticket CHAR(20);
DEFINE vstatus_consulta CHAR(1);
DEFINE vrespuesta_msj601 CHAR(1);
DEFINE vfecha_insert DATETIME YEAR to SECOND;
  
LET sCont	= 0;
LET cCodRet	='00000';

	BEGIN
	    ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		-- Se eliminan registros de la tabla de paso
		TRUNCATE TABLE "informix".tmp_si_huella_linea; 
		
		BEGIN WORK;
		
		FOREACH WITH HOLD
		
			SELECT LIMIT pLimite {+AVOID_FULL("informix".si_huella_linea)} numcte,fecha_consulta,secuencia,sucursal,ip,status_huella,ticket,status_consulta,respuesta_msj601,fecha_insert  
				INTO vnumcte,vfecha_consulta,vsecuencia,vsucursal,vip,vstatus_huella,vticket,vstatus_consulta,vrespuesta_msj601,vfecha_insert
			FROM "informix".si_huella_linea 
			WHERE status_consulta IN ('3','9','0')
			AND fecha_insert < CURRENT - 1 UNITS DAY 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
							
			INSERT INTO "informix".tmp_si_huella_linea 
				(numcte,fecha_consulta,secuencia,status_huella,ticket,status_consulta,respuesta_msj601,fecha_insert)
			VALUES 
             	(vnumcte,vfecha_consulta,vsecuencia,vstatus_huella,vticket,vstatus_consulta,vrespuesta_msj601,vfecha_insert);		

					
			LET sCont= sCont+1; 
			IF sCont=1000 THEN
				COMMIT WORK;
			   LET sCont=0;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		
		IF sCont >= 0 THEN
		  COMMIT WORK;
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE;