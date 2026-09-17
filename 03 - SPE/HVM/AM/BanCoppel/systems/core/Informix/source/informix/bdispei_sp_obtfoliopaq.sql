CREATE PROCEDURE "informix".sp_obtfoliopaq(pintCveCesif INTEGER, pchrTopologia CHAR(1), pchrPrioridad CHAR(1))
RETURNING CHAR(5), INTEGER, INTEGER;

DEFINE codret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE vintFolioPaquete INTEGER;
DEFINE VintPkPaqueteEnv	INTEGER;
DEFINE vdtFechaOp	DATE;
DEFINE v_Institucion 	CHAR(255);

LET CODRET = '000'; 
LET vintFolioPaquete = 0;
LET vintPkPaqueteEnv = 0;

--BEGIN WORK;

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET codret = sql_err;
	     --ROLLBACK WORK;
	     RETURN codret, vintFolioPaquete, vintPkPaqueteEnv;
	  END IF
	END EXCEPTION;
	
	SELECT vchrValor INTO v_Institucion
	FROM tblParametros
	WHERE vchrCveParametro = '@CVECESIFBCO';
   
        LET v_Institucion = trim(v_Institucion);

	SELECT to_date(vchrValor, '%d/%m/%Y') INTO vdtFechaOp
	FROM tblParametros
	WHERE vchrCveParametro = 'FECHA_OPERACION';
	
	--Obtiene el folio del paquete
	--EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_OPCAJERO') INTO codret, vintFolioPaquete;
	EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAQUETEENV') INTO codret, vintPkPaqueteEnv;
	
	INSERT INTO tblPaqueteEnv(intPkPaqueteEnv, intFolioPaquete, cvecesifbcoord, cvecesifbcodest, dtFechaOp, chrTopologia, chrPrioridad, chrEstatus)
	VALUES (vintPkPaqueteEnv, vintFolioPaquete, v_Institucion, pintCveCesif, vdtFechaOp, pchrTopologia, pchrPrioridad, 'N');
		
	--COMMIT WORK;		
	
	RETURN codret, vintFolioPaquete, vintPkPaqueteEnv;
	
END

END PROCEDURE;