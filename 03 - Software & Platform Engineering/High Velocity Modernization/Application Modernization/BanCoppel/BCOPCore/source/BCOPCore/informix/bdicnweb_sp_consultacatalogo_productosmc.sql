CREATE PROCEDURE "informix".sp_consultacatalogo_productosmc(pIdFuncionDummy CHAR(10))
	RETURNING CHAR(5) AS codret,
			CHAR(40) AS nombre_prod,
			CHAR(4) AS num_producto;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cNombreProducto CHAR(40);
	DEFINE cNumProducto CHAR(4);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cMensajeRetorno = '';
	LET cNombreProducto = '';
	LET cNumProducto = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreProducto, cNumProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogo_productosmc.out';
		--TRACE ON;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_consulta_productos()
			INTO cCodRetSp, cMensajeRetorno, cNombreProducto, cNumProducto
			
			IF cCodRetSp = '00001' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNombreProducto, cNumProducto;
			ELSE
				RETURN cCodRet, cNombreProducto, cNumProducto WITH RESUME;
			END IF;
			
		END FOREACH;
	
	END;
	
END PROCEDURE;