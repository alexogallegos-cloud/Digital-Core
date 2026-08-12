CREATE PROCEDURE "informix".sp_obtieneinstruccionespagocap(pUsuario char(8), pIdFuncion char(10))
	RETURNING CHAR(5) AS codret,
		CHAR(2) AS codigoInstruccion,
		CHAR(50) AS descripcionInstruccion;
		
	
	DEFINE cCodRet		CHAR(5);
	DEFINE cCodRetSp	CHAR(5);
	DEFINE iSqlErr		INTEGER;
	DEFINE cCodigoIns	CHAR(2);
	DEFINE cDescIns		CHAR(50);
	DEFINE iIdxBs		SMALLINT;
	DEFINE cEmpresa		CHAR(3);
	DEFINE i			SMALLINT;
	DEFINE iRegs		SMALLINT;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '00000';
	LET iSqlErr = 0;
	LET cCodigoIns = '';
	LET cDescIns = '';
	LET iIdxBs = 0;
	LET cEmpresa = '001';
	LET iRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigoIns, cDescIns;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtieneinstruccionespagocap.out';
		--TRACE ON;
		
		IF pUsuario = '' or pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigoIns, cDescIns;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigoIns, cDescIns;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdinvers:"informix".sp_obtieneinstruccionespag(cEmpresa)
			INTO cCodRetSp, cDescIns
			
			LET iIdxBs = 0;
			FOR i = 0 TO LENGTH(cDescIns)
				IF SUBSTR(cDescIns, i , 1) = ' ' THEN
					LET iIdxBs = i;
					EXIT FOR;
				END IF;
			END FOR;
			
			LET cCodigoIns = SUBSTR(cDescIns, 0, iIdxBs);
			LET cDescIns = SUBSTR(cDescIns, iIdxBs);
			LET iRegs = iRegs + 1;
			
			RETURN cCodRet, TRIM(cCodigoIns), TRIM(cDescIns) WITH RESUME;
			
		END FOREACH;
		
		IF iRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodigoIns, cDescIns;
		END IF;
		
	END;
	
END PROCEDURE;