CREATE PROCEDURE "informix".sp_consultanombreproducto(pProducto CHAR(4))
	RETURNING CHAR(5),CHAR(40);
	
	DEFINE CcodRet CHAR(5);
    DEFINE nombreProducto  CHAR(40);	
	DEFINE cVarDataErr      VARCHAR(64);
	DEFINE iSqlErr          INTEGER;
	DEFINE iSamErr          INTEGER;    
	
	LET iSqlErr=0;
	LET CcodRet='00000';		
	
BEGIN
	ON EXCEPTION
		SET iSqlErr	
		IF iSqlErr <> 0 THEN
			LET CcodRet = iSqlErr;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT nombre
    INTO nombreProducto
	FROM "informix".sc_producto WHERE producto = pProducto;

	IF nombreProducto IS NULL OR nombreProducto = '' THEN
		LET CcodRet='00001';
	END IF
		
	RETURN CcodRet, nombreProducto;
END;
END PROCEDURE;