CREATE PROCEDURE "informix".sp_validar_num_cheques(pEmpresa char(3), pCuenta char(20), pNumParam integer)
        RETURNING char(5);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Validar el numero de cheques activos permitidos
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 19/03/2010

   DEFINE vCodret   char(5);
   DEFINE vValorMaxChqs  char(60);
   DEFINE vNumChqesActivos integer;
   DEFINE sql_err integer;
   DEFINE iChqSolic char(60);
   DEFINE iCheques_activos char(10);
   DEFINE alt_consumo char(5);  

	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO  "/informix/Aida/spvalidar_num_cheques.out";
	--TRACE ON;
	
		LET vCodret = '000';
	LET vValorMaxChqs = '';
	LET vNumChqesActivos = 0;
	LET alt_consumo = 1;
	
	BEGIN
		IF EXISTS(SELECT valor FROM sq_param WHERE cod_param = pNumParam) THEN

			SELECT valor 
			INTO vValorMaxChqs
			FROM sq_param 
			WHERE cod_param = pNumParam;

		ELSE
			LET vCodret = '001';
			RETURN vCodret;
		END IF;
		
		SELECT count(numero)
		INTO vNumChqesActivos
		FROM bdicheq:sc_contch
		WHERE cuenta = pCuenta
		AND empresa = pEmpresa
		AND estado = "A";
		
		SELECT chequeras_sol,cheques_activos
		INTO iChqSolic, iCheques_activos
		FROM bdicntchq:"informix".sq_ctealtconsumo
		WHERE cuenta = pcuenta	
		AND alt_consumo = '1';
	   
		IF NVL(iCheques_activos,0) <> 0 THEN  --si no entra significa que no es de alto consumo
			IF (vNumChqesActivos > iCheques_activos::integer) THEN
				LET vCodret = '002';
				RETURN vCodret;
			END IF;
		END IF;		
		
		IF (vNumChqesActivos > vValorMaxChqs::integer) THEN
			LET vCodret = '002';
			RETURN vCodret;
		END IF;

		RETURN vCodret;
	END;

END PROCEDURE;