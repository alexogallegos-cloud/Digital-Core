CREATE PROCEDURE "informix".sp_actualiza_catcalles2()

    --DATOS A REGRESAR---
RETURNING CHAR(5) AS CodRet;  -- Codigo de Retorno

	--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE sOrigen          	CHAR(10);
DEFINE sDestino             CHAR(10);


	--INICIALIZACION DE VARIABLES--
LET iSql_err 				= 0;
LET cCodRet 				= '00001';
LET sOrigen          		= '';
LET sDestino                = '';


--SET DEBUG FILE TO "/tmp/anj/sp_actualiza_catcalles.out";
--TRACE ON;
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet;
		END IF;
	END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


            FOREACH Cursor_Calle WITH HOLD FOR
            	SELECT trim(origen), trim(destino)
                INTO sOrigen, sDestino
                FROM si_temp_catcalles
                WHERE estatus='0' and bandera='0'


				UPDATE si_direcciones SET numerocalle = sDestino WHERE numerocalle = sOrigen;
                UPDATE si_direcciones_actual SET numerocalle = sDestino WHERE numerocalle = sOrigen;
                --UPDATE si_temp_catcalles SET estatus = '1' WHERE origen = sOrigen;

			END FOREACH;

		LET cCodRet = '00000';

	RETURN cCodRet;
END
END PROCEDURE;