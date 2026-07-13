CREATE PROCEDURE "informix".spconsultarparam (p_iIdSecuencia SMALLINT)
RETURNING CHAR(5) AS retorno, CHAR(60) AS descripcion, CHAR(20) AS valor;

	DEFINE v_sCveValor 		CHAR(20);
	DEFINE v_sDescripcion  	CHAR(60);
	DEFINE v_sCodRet 		CHAR(5);
	DEFINE sql_err 			INTEGER;

 --****************************************************************
 -- SET DEBUG FILE TO "/tmp/prisma/spconsultarparam.out";       --* 
 -- TRACE ON;                                            		--*
 --****************************************************************

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET v_sCodRet = sql_err;
				RETURN v_sCodRet,'','';
			END IF;
		END EXCEPTION;
		
		IF NVL(p_iIdSecuencia, '') = '' THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet, 'NO EXISTE EL PARAMETRO', '';
		END IF		
		
		SELECT descripcion, valor
		INTO v_sDescripcion, v_sCveValor
		FROM bdirech:rec_param
		WHERE secuencia = p_iIdSecuencia;
			
		LET v_sCodRet = '00000';
		
		RETURN v_sCodRet, v_sDescripcion, v_sCveValor;
		
	END
END PROCEDURE
