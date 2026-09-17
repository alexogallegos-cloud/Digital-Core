CREATE PROCEDURE "informix".sp_consulta_documentos_presentados(pBandera CHAR(2),pUsuario CHAR(8), pIdFuncion CHAR(10),pfechapre DATE,pRegistros INTEGER, pRecuperacion INTEGER)			
            RETURNING CHAR(5) AS codret ,
					  CHAR(100) AS banco,
					  CHAR(11) AS cuenta,
					  CHAR(7) AS numcheque,
            		  DECIMAL(16,2) AS monto,
					  CHAR(45) AS sucursal, 
					  CHAR(20) AS ctadeposito,
            		  CHAR(100) AS nombrecte,
					  CHAR(1) AS presentado,
					  INTEGER AS noregistro;
			
DEFINE v_codret      char(5);
DEFINE v_banco       char(100);
DEFINE v_cuenta      char(11);
DEFINE v_numcheque   char(7);
DEFINE v_monto       decimal(16,2);
DEFINE v_sucursal    char(45);
DEFINE v_ctadeposito char(20);
DEFINE v_nombrecte   char(100);
DEFINE v_presentado  char(1);
DEFINE v_noregistros INTEGER;

DEFINE sql_err		 integer;

LET v_codret = '00000';
LET v_banco = '';
LET v_cuenta = '';
LET v_numcheque = '';
LET v_monto = 0;
LET v_sucursal = '';
LET v_ctadeposito = '';
LET v_nombrecte	= '';
LET v_presentado = '';
LET v_noregistros = 0;

	BEGIN
		on exception set sql_err
			LET v_codret = sql_err;
			RETURN v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_sucursal,v_ctadeposito, v_nombrecte,v_presentado, v_noregistros;  
		end exception;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO v_codret;
		IF v_codret <> '00000' THEN
			RETURN v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_sucursal,v_ctadeposito, v_nombrecte,v_presentado, v_noregistros;  
		END IF;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_documentos_presentados.out';
		--TRACE ON;
		

		IF pBandera = '1' THEN
			FOREACH
			EXECUTE PROCEDURE bditef:"informix".sp_cons_presenta2('001', pfechapre)
			INTO v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_sucursal,v_ctadeposito, v_nombrecte,v_presentado
			
			IF v_codret = '000' THEN 
				LET v_codret = '00000';
			END IF;
			
			RETURN v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_sucursal,v_ctadeposito, v_nombrecte,v_presentado, v_noregistros WITH RESUME;

			END FOREACH
		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE bditef:"informix".sp_cons_presenta2_totales('001', pfechapre)
			INTO v_codret, v_noregistros;
			IF v_codret = '000' THEN 
				LET v_codret = '00000';
			END IF;
			RETURN v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_sucursal,v_ctadeposito, v_nombrecte,v_presentado, v_noregistros;
		END IF;
	END;
	
END PROCEDURE;