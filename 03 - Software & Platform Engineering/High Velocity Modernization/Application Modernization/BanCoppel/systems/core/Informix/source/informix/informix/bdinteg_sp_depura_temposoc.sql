CREATE PROCEDURE "informix".sp_depura_temposoc()
				RETURNING
				CHAR(5)     AS Cod_Retorno,
				CHAR(100)   AS Msj_Retorno;
				
DEFINE cCodRet		CHAR(5);
DEFINE cMsjRetorno	CHAR(100);
DEFINE iSql_err     INT; 


LET cCodRet = "00000";
LET cMsjRetorno = "PROCESO EXITOSO";
LET iSql_err = 0;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			LET cMsjRetorno = "ERROR DE BASE DE DATOS";
			RETURN cCodRet, cMsjRetorno;
		END IF;
	END EXCEPTION;
	 
	--SET DEBUG FILE TO "/informix/CHVN/sp_depura_temposoc.out";
	--TRACE ON;
	
	TRUNCATE TABLE "informix".si_tempoamortizaciones;
	TRUNCATE TABLE "informix".si_tempobloqctascred;
	TRUNCATE TABLE "informix".si_tempoconcheques;
	TRUNCATE TABLE "informix".si_tempoconmovfol;
	TRUNCATE TABLE "informix".si_tempoctas;
	TRUNCATE TABLE "informix".si_tempodescprog;
	TRUNCATE TABLE "informix".si_tempodisposiciones;
	TRUNCATE TABLE "informix".si_tempomovofi;
	TRUNCATE TABLE "informix".si_tempomovs;
	TRUNCATE TABLE "informix".si_tempomovtranele;
	TRUNCATE TABLE "informix".si_tempopagosrecibidos;
	TRUNCATE TABLE "informix".si_temporepmovtoside;
	TRUNCATE TABLE "informix".si_temposaldoshist;
	TRUNCATE TABLE "informix".si_temposbcretenido;
	TRUNCATE TABLE "informix".si_tempotarjetas;
	
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempoamortizaciones;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempobloqctascred;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempoconcheques;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempoconmovfol;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempoctas;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempodescprog;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempodisposiciones;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempomovofi;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempomovs;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempomovtranele;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempopagosrecibidos;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_temporepmovtoside;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_temposaldoshist;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_temposbcretenido;
	COMMIT;
	BEGIN;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".si_tempotarjetas;
	COMMIT;
	
	RETURN cCodRet,cMsjRetorno;
END
END PROCEDURE;