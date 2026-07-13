CREATE PROCEDURE "informix".sp_obtiene_productos_tf_web(pEmpresa CHAR(3))
RETURNING CHAR(5) as Cod_Retorno, CHAR(4) as Cod_Producto;
--Declaracion de variables

DEFINE sCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE sCodProd CHAR(4);

--SET DEBUG FILE TO "/respaldosbd/Leslie/sp_obtiene_productos_tf_web.out";
--TRACE ON;

--Asignacion de variables

LET sCodRet = '00000';
LET iSqlErr = 0;
LET sCodProd = '';

--Inicio del procedimiento
BEGIN

    ON EXCEPTION SET iSqlErr --Manejador de Errores
        IF iSqlErr <> 0 THEN
            LET sCodRet = iSqlErr;
            RETURN sCodRet, sCodProd;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pEmpresa,'')='' THEN
		LET sCodRet = '00001';
		RETURN sCodRet, sCodProd;
	ELSE
		FOREACH
			SELECT producto 
			INTO sCodProd
			FROM bdicheq:"informix".sc_producto 
			WHERE empresa = pEmpresa
			AND asociar_transfer='2'
		
			RETURN sCodRet, sCodProd WITH RESUME;
		END FOREACH
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET sCodRet = '00002';
			RETURN sCodRet, sCodProd;
		END IF
	END IF
END
END PROCEDURE
DOCUMENT
"Realiza bÃºsqueda de productos asociados a transfer que se pueden ofertar",
"Autor : Leslie RendÃ³n",
"FECHA : 10/04/2014",
"BD    : bditransfer";