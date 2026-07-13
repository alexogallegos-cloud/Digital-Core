CREATE PROCEDURE "informix".sp_consulta_fechaoperacion
(pempresa CHAR(3), pcuenta CHAR(20), pfolio_suc CHAR(16))

RETURNING CHAR(5), CHAR (20), DATE;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cDescripcion			CHAR (20);
DEFINE iSqlErr				INTEGER;
DEFINE cempresa				CHAR (3);
DEFINE ccuenta				CHAR (20);
DEFINE cfolio_suc			CHAR (16);
DEFINE dFecha_operacion		DATE;
DEFINE ivalidamovto			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET cDescripcion			= 'CONSULTA EXITOSA.';
LET iSqlErr					= 0;
LET cempresa				= '001';
LET ccuenta					= pcuenta;
LET cfolio_suc				= pfolio_suc;
LET dFecha_operacion		= '01-01-1900';
LET ivalidamovto			= 0;

	--	SET DEBUG FILE TO  '/RESPALDOS/sp_consulta_fechaproceso.out';
	--	TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cDescripcion = 'CONSULTA NO EXITOSA.';
				RETURN cCodRet, cDescripcion, dFecha_operacion;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

			SELECT fech_oper 
				INTO dFecha_operacion
			from "informix".sc_movdia where empresa = cempresa and cuenta = ccuenta and folio_suc = cfolio_suc;
			
			IF dFecha_operacion IS NULL then
				LET cCodRet = '00001';
				LET cDescripcion = 'CONSULTA NO EXITOSA.';
				RETURN cCodRet, cDescripcion, dFecha_operacion;
			ELSE
			RETURN cCodRet, cDescripcion, dFecha_operacion;
			END IF;

	END;     

END PROCEDURE;