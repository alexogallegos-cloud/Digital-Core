CREATE PROCEDURE "informix".sp_obtienevalorinstrucc(pEmpresa CHAR(3), pCodigo INTEGER)
RETURNING CHAR(5),CHAR(2), CHAR(2);

--Declaracion de variables		  
DEFINE iSqlErr              INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cCap					CHAR(2);
DEFINE cInte				CHAR(2);


--Crea el archivo de monitoreo del proceso
--SET DEBUG FILE TO "/tmp/sp_ObtieneValorInstrucc.out";
--TRACE ON;

--inicializacion de  variables
LET cCodRet= '00000';
LET cCap= '';
LET cInte='';


	BEGIN
		--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cCap, cInte ;
			END IF;
		END EXCEPTION;

	SELECT aplic_cap, aplic_int
	INTO cCap, cInte
	FROM bdinvers:sv_instruccvenci
	WHERE empresa = pEmpresa
	AND codigo = pCodigo;

	RETURN cCodRet,cCap, cInte ;

	
END
END PROCEDURE
