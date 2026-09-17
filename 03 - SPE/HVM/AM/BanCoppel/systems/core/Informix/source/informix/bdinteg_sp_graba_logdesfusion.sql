CREATE PROCEDURE "informix".sp_graba_logdesfusion(cProceso CHAR(50), cTabla CHAR(30),cClienteTit CHAR(20),cClienteTras CHAR(20),cDetalle_mov CHAR(200),cUsuario_insert CHAR(8))
RETURNING CHAR(6);

DEFINE iSql_err			INTEGER;
DEFINE cRetorno	CHAR(6);
LET cRetorno = '000000';
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cRetorno = iSql_err;
			RETURN cRetorno;
		END IF;
	END EXCEPTION;
	
	INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
	VALUES (cProceso,cTabla,cClienteTit,cClienteTras,cDetalle_mov,CURRENT HOUR TO FRACTION(4),cUsuario_insert,CURRENT::DATE);
	
	RETURN cRetorno;
END
END PROCEDURE;