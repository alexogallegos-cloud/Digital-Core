CREATE PROCEDURE "informix".sp_cargaarchivoestafeta_paso()
	RETURNING 	CHAR(5); --cod retorno

--*********************************************
--Definición:	Se crea a modo de semaforo para saber si el sp_cargaarchivoestafeta realizo todo correctamente en su ejecución previa.
--Autor: 		Walber Castro
--Fecha:		07 Febrero 2012
--*********************************************

DEFINE cCodret			CHAR(5);
DEFINE iSql_Err    		INTEGER;

LET cCodret 	=	'00000';

--SET debug FILE TO "/tmp/manuel/sp_cargaarchivoestafeta.out";
--Trace ON;

BEGIN

	ON EXCEPTION SET iSql_Err
		LET cCodRet = iSql_Err;		
		RETURN cCodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	IF EXISTS(SELECT dbsname FROM sysmaster:systabnames WHERE tabname = 'bpi_tempcargarchivoestafeta_paso') THEN
		SELECT LIMIT 1 TRIM(campo) INTO cCodRet FROM bdibpi:"informix".bpi_tempcargarchivoestafeta_paso;
		DELETE FROM bdibpi:"informix".bpi_tempcargarchivoestafeta_paso;
	ELSE
		LET cCodRet = '00001';
	END IF;
		
	RETURN NVL(cCodRet,'');

END;
END PROCEDURE;