CREATE PROCEDURE "informix".sp_obtenernaccliente(
pCliente CHAR(20)
)		

RETURNING
CHAR(5)    AS cCodret

DEFINE sql_err      INTEGER;
DEFINE cCodret CHAR(5);
DEFINE cNacionalidad  CHAR(3);

LET cCodret = "00000";
LET cNacionalidad = "";

BEGIN
 
    ON EXCEPTION SET sql_err

		RETURN sql_err;

    END EXCEPTION;

	-- SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--VALIDAR DATOS VACIOS
	IF NVL(pCliente, '') = '' THEN
			LET cCodret = "00002"; --Datos vacios
		RETURN cCodret;
	ELSE 
		 select nacionalidad into cNacionalidad from si_ctepf where numcte = pCliente;
		IF cNacionalidad = 001 THEN
			LET cCodret = "00000";
		ELSE
			LET cCodret = "00001";
		END IF;
	END IF;
    RETURN cCodret;	
	
END;
END PROCEDURE;