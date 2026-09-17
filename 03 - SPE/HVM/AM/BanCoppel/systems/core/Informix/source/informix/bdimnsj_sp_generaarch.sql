CREATE PROCEDURE "informix".sp_generaarch(pNombrearch char(50))
RETURNING  CHAR(5) AS CodRetorno;



--DECLARACION DE VARIABLES
DEFINE viSqlError INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);
DEFINE vsRutaArchRep	  CHAR(150);


--INICIALIZACION DE VARIABLES
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET cSQL1 = ' ';
LET cSQL = ' ';
LET vsRutaArchRep = ' ';

--SET DEBUG FILE TO "/tmp/MNSJR/sp_generaarch.OUT";
--TRACE ON;
BEGIN

	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			RETURN vsCodRetorno;
		END IF;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF (pNombrearch is null) or (pNombrearch = '') THEN
		LET vsCodRetorno = '00042';
		RETURN vsCodRetorno;
	END IF;

	SELECT LIMIT 1 TRIM(VALOR)||'/'
	INTO vsRutaArchRep FROM bdimnsj:"informix".mnsj_param
	WHERE cod_param = '3';

	IF vsRutaArchRep <> ' ' THEN

		LET cSQL1 = 'echo "UNLOAD TO '||trim(vsRutaArchRep)||TRIM(pNombrearch)||' delimiter '' '' SELECT linea from bdimnsj:"informix".mnsj_susc_paso ORDER BY secuencial" >'||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
		SYSTEM cSQL1;

		LET cSQL='dbaccess bdimnsj '||trim(vsRutaArchRep)||'Ejecuta_archivo.sql';
		System cSQL;
		
			LET cSQL = '' ;
			LET cSQL = 'gzip -f '||trim(vsRutaArchRep)||TRIM(pNombrearch);
			SYSTEM cSQL ;

	ELSE
		LET vsCodRetorno = '00043';
		RETURN vsCodRetorno;
	END IF;

	IF vsCodRetorno = '00000' THEN
		TRUNCATE TABLE bdimnsj:"informix".mnsj_susc_paso;
		UPDATE statistics medium FOR TABLE bdimnsj:"informix".mnsj_susc_paso;
	END IF;

RETURN vsCodRetorno;

END;
END PROCEDURE;