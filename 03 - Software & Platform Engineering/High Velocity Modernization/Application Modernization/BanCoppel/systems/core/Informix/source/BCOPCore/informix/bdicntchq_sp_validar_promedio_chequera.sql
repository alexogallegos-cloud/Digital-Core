CREATE PROCEDURE "informix".sp_validar_promedio_chequera(pCuenta char(20), pNumParam integer)
        RETURNING char(5), char(60);
    
    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener parametro saldo promedio minimo para obtener chequera y 
	--             validar si el saldo de la cuenta promedio es mayor
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 19/03/2010

    --Modificado
    --Fecha: 24/Agosto/2011
    --Por:   Berenice Noriega Guevara
    --Actividad: se modifico para que se tomen en cuenta los clientes 
    --que aun no cumplen con un mes de antiguedad y desean una nueva chequera.

   DEFINE v_hoy  date;
   DEFINE vdummy char(100);
   DEFINE vdummy1 char(100);
   DEFINE vfechames DATE;
   DEFINE vCodret   char(5);
   DEFINE vValorPromedio  char(60);
   DEFINE vSdoPromedio money;
   DEFINE vfecha_alta  DATE;
   DEFINE sql_err integer;


	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret, vValorPromedio;
	   END IF;
	END EXCEPTION;

	LET vCodret = '000';
	LET vValorPromedio = '';
	LET vSdoPromedio = 0;
    LET vdummy = " ";
    LET vdummy1 = " ";

	
	BEGIN

		--- Selecciona la fecha del dia.
            SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

        --- Obtener Valor
			SELECT valor 
			INTO vValorPromedio
			FROM sq_param 
			WHERE cod_param = pNumParam;

        --- valor vacio
            IF (vValorPromedio = '') THEN
            	LET vCodret = '001';
            	RETURN vCodret, vValorPromedio;
            END IF;
		
		--- Saldo Promedio
			SELECT sdo_prom_mesant, fecha_alta 
			INTO vSdoPromedio, vfecha_alta
			FROM bdicheq:sc_maenoc 
			WHERE cuenta = pCuenta;

       --- Saldo nulo
            IF (vSdoPromedio='') THEN
            	LET vCodret = '002';
            	RETURN vCodret, vValorPromedio;
            END IF;

      --//Si tiene saldo promedio mayor a 0, no es apertura reciente
          IF vSdoPromedio > 0 THEN
              IF (vSdoPromedio < vValorPromedio::money) THEN 
                  LET vCodret = '003';
                  RETURN vCodret, vValorPromedio;
             END IF
          ELSE --//Verifica que no sea cuenta reciente para saldo promedio = 0
             EXECUTE PROCEDURE bdicheq:sp_mes_siguiente(vfecha_alta,1,day(vfecha_alta))
                      INTO vdummy, vfechames, vdummy1;
            
             IF v_hoy > vfechames THEN
                IF (vSdoPromedio < vValorPromedio::money) THEN 
                      LET vCodret = '003';
                      RETURN vCodret, vValorPromedio;
                 END IF
             END IF
         END IF

		RETURN vCodret, vValorPromedio;
	END;

END PROCEDURE;