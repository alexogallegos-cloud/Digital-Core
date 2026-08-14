CREATE PROCEDURE "informix".sp_obtieneinstruccionespag(pEmpresa CHAR(3))
RETURNING CHAR(5),CHAR(50);

--Declaracion de variables		  
DEFINE iSqlErr              INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cInstruccion			CHAR(50);

--Crea el archivo de monitoreo del proceso
--SET DEBUG FILE TO "/tmp/sp_ObtieneInstruccionesPag.out";
--TRACE ON;

--inicializacion de  variables
LET cCodRet= '00000';
LET cInstruccion= "";

	BEGIN
		--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cInstruccion WITH RESUME;
			END IF;
		END EXCEPTION;

	FOREACH

		SELECT codigo || ' ' ||descripcion
		INTO cInstruccion
		FROM bdinvers:sv_instruccvenci
		WHERE empresa= pEmpresa
		order by codigo

		RETURN cCodRet,cInstruccion WITH RESUME;

	END FOREACH
END
END PROCEDURE
