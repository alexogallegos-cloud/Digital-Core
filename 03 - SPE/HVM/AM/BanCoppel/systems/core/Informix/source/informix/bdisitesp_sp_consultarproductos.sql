CREATE PROCEDURE "informix".sp_consultarproductos(
												 pEmpresa CHAR(3)
												)

	RETURNING CHAR(6),	--codret
			  CHAR(4),	--numproducto
			  CHAR(40);	--nomproducto

	DEFINE vcCodRet CHAR(5);
	DEFINE viSqlErr INTEGER;

	DEFINE v_NumProducto	CHAR(4);
	DEFINE v_NomProducto	CHAR(40);

	LET vcCodRet = '000';
	LET viSqlErr = 0;

	LET v_NumProducto = '';
	LET v_NomProducto = '';

--*****************************************************
-- Creado por Abraham Ayala
--06/Mar/2009
--*****************************************************

	BEGIN
		ON EXCEPTION SET viSqlErr
			LET vcCodRet = viSqlErr;
			RETURN vcCodRet, v_NumProducto, v_NomProducto;
		END EXCEPTION;

		--SET DEBUG FILE TO "/respaldos/subedepaso/sp_consultarproductos.out";
		--TRACE ON;

		FOREACH
			SELECT {+INDEX (bdicred:sd_definicion idx_consultaprod)} num_producto, nombre_prod
			INTO v_NumProducto, v_NomProducto
			FROM bdicred:sd_definicion
			WHERE empresa = pEmpresa
			ORDER BY 1

			RETURN vcCodRet, v_NumProducto, v_NomProducto WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE;