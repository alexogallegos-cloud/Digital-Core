CREATE PROCEDURE "informix".sp_concilsdos_app_det(pempresa CHAR(3),pfecha DATE, psistema CHAR(2), ptipoconsulta CHAR(1))
RETURNING VARCHAR(5),   --retorno
		  CHAR(4),      --producto 
		  CHAR(20),     --cuenta
	      VARCHAR(25),   --concept_oper
		  DECIMAL(18,2), --capital_anterior
		  DECIMAL(18,2), --movs_cargo
		  DECIMAL(18,2), --movs_abono
		  DECIMAL(18,2), --capital_calculado
		  DECIMAL(18,2), --capital_actual
		  DECIMAL(18,2), --diferencia_capital
		  DECIMAL(18,2), --interes_anterior
		  DECIMAL(18,2), --movs_cargo_interes
		  DECIMAL(18,2), --movs_abono_interes
		  DECIMAL(18,2), --interes_calculado
		  DECIMAL(18,2), --interes_actual
		  DECIMAL(18,2)  --diferencia_interes

	DEFINE cVarDataErr  VARCHAR(64);
	DEFINE iSqlErr      INTEGER;
	DEFINE iSamErr      INTEGER;
	DEFINE vCodRet      CHAR(5);

	DEFINE vfecha_cont  DATE;

	DEFINE vproducto    CHAR(4);
    DEFINE vcuenta      CHAR(20);
    DEFINE vconcept_op  VARCHAR(25);

	DEFINE vcapital_anterior	DECIMAL(18,2);
	DEFINE vmovs_cargo	  		DECIMAL(18,2);
	DEFINE vmovs_abono	  		DECIMAL(18,2);
	DEFINE vcapital_calculado	DECIMAL(18,2);
	DEFINE vcapital_actual	  	DECIMAL(18,2);
	DEFINE vdiferencia_capital	DECIMAL(18,2);
	DEFINE vinteres_anterior	DECIMAL(18,2);
	DEFINE vmovs_cargo_interes	DECIMAL(18,2);
	DEFINE vmovs_abono_interes	DECIMAL(18,2);
	DEFINE vinteres_calculado	DECIMAL(18,2);
	DEFINE vinteres_actual	  	DECIMAL(18,2);
	DEFINE vdiferencia_interes	DECIMAL(18,2);
	DEFINE vmaxregistros        INTEGER;
           
	--Manejo del error
	    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
		   IF iSqlErr <> 0 THEN
	          LET vCodRet = iSqlErr;
			  RETURN vCodRet,vproducto,vcuenta,vconcept_op,
			         vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
			         vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes;
		   END IF;
		END EXCEPTION;

   --set debug file to "/tmp/sp_sel_sdohistorico.out";
    --trace on;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET vCodRet = "000";

	LET vproducto = "";
	LET vcuenta = ""; 
	LET vconcept_op = "";

	LET vcapital_anterior = 0.0;	
	LET vmovs_cargo	= 0.0;  		
	LET vmovs_abono	= 0.0;  		
	LET vcapital_calculado = 0.0;
	LET vcapital_actual	= 0.0;  
	LET vdiferencia_capital = 0.0;
	LET vinteres_anterior = 0.0;	
	LET vmovs_cargo_interes = 0.0;
	LET vmovs_abono_interes = 0.0;
	LET vinteres_calculado = 0.0;
	LET vinteres_actual	= 0.0;  
	LET vdiferencia_interes = 0.0;
	LET vmaxregistros = 0;

	SELECT fecha_hoy 
      INTO vfecha_cont
      FROM bdicont:co_fechas;

	IF psistema = "01" THEN -- Captacion
		IF ptipoconsulta = '1' THEN

			SELECT COUNT (fecha) INTO vmaxregistros FROM bdicheq:sc_concilsdo_difdet WHERE fecha = pfecha;

			IF vmaxregistros = 0 THEN

				LET vcodret = "102";
				LET cVarDataErr='No Existen Datos con la fecha solicitada';

				RETURN vCodRet, vproducto,vcuenta,vconcept_op,
					   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
					   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes;
			ELIF vmaxregistros >= 100000 THEN
				LET vcodret = "103";
				LET cVarDataErr='Los datos solicitados superan los 100,00 registros';

				RETURN vCodRet, vproducto,vcuenta,vconcept_op,
					   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
					   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes;
			END IF

			FOREACH
			SELECT producto,cuenta, CASE WHEN diferencia_capital <> 0 THEN 'CAPITAL' ELSE 'INTERES' END concept_oper,
				   capital_anterior,movs_cargo,movs_abono,capital_calculado,capital_actual,diferencia_capital,     
				   interes_anterior,movs_cargo_interes,movs_abono_interes,interes_calculado,interes_actual,diferencia_interes    
		      INTO vproducto,vcuenta,vconcept_op,
				   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
				   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes
			  FROM bdicheq:sc_concilsdo_difdet 
			 WHERE fecha = pfecha
			 ORDER BY 3,1,2 ASC

		    RETURN vCodRet, vproducto,vcuenta,vconcept_op,
				   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
				   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes WITH RESUME;

			END FOREACH; 
        ELIF ptipoconsulta = '2' THEN

			IF NOT EXISTS (SELECT DISTINCT fecha FROM bdicheq:sc_concilsdo_difacum WHERE fecha = pfecha) THEN

				LET vcodret = "102";
				LET cVarDataErr='No Existen Datos con la fecha solicitada';

				RETURN vCodRet, vproducto,vcuenta,vconcept_op,
					   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
					   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes;
	        END IF

			FOREACH
			SELECT producto, "" , CASE WHEN diferencia_capital <> 0 THEN 'CAPITAL' ELSE 'INTERES' END concept_oper,
				   capital_anterior,movs_cargo,movs_abono,capital_calculado,capital_actual,diferencia_capital,     
				   interes_anterior,movs_cargo_interes,movs_abono_interes,interes_calculado,interes_actual,diferencia_interes    
		      INTO vproducto,vcuenta,vconcept_op,
				   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
				   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes
			  FROM bdicheq:sc_concilsdo_difacum 
			 WHERE fecha = pfecha
			 ORDER BY 3,1 ASC

		    RETURN vCodRet,vproducto,vcuenta,vconcept_op,
				   vcapital_anterior,vmovs_cargo,vmovs_abono,vcapital_calculado,vcapital_actual,vdiferencia_capital,
				   vinteres_anterior,vmovs_cargo_interes,vmovs_abono_interes,vinteres_calculado,vinteres_actual,vdiferencia_interes WITH RESUME;

			END FOREACH; 
			
		END IF;
	END IF;
END PROCEDURE;