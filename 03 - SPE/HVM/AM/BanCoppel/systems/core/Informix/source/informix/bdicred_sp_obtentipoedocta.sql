CREATE PROCEDURE "informix".sp_obtentipoedocta()

RETURNING CHAR(5) AS CodRet, --codigo de retorno
		  CHAR(3) AS id_estdocta, --id de estado de cuenta
		  VARCHAR(40) AS desc_estdocta; --descripcion de estado de cuenta

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr  INTEGER;
DEFINE cid_estdocta VARCHAR(3);
DEFINE cDesc_Estdocta VARCHAR(40);

LET cCodRet = '00000';
LET iSqlErr = 0;
LET cId_Estdocta = '';
LET cDesc_Estdocta = '';

	BEGIN
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cId_Estdocta,cDesc_Estdocta;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_obtentipoedocta.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT id_estdocta,desc_estdocta
			INTO cId_Estdocta,cDesc_Estdocta
			FROM "informix".sd_tipo_edocta

			RETURN cCodRet,TRIM(cId_Estdocta),TRIM(cDesc_Estdocta) WITH RESUME;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			RETURN cCodRet,TRIM(cId_Estdocta),TRIM(cDesc_Estdocta);
		END IF;
	END
END PROCEDURE;