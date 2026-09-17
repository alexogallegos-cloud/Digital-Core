CREATE PROCEDURE "informix".sp_borra_cteduplicados() 
       RETURNING char(8);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			  INTEGER;
DEFINE isam_err 		  INTEGER;
DEFINE error_info		  CHAR(150);
DEFINE cMensaje 		  CHAR(80);
DEFINE cCod_ret           CHAR(6);
DEFINE vNumcte            CHAR(20);
DEFINE vUsuarioInset      CHAR(8);
--SET DEBUG FILE TO '/tmp/sp_datos_admin_auronix.out';
--TRACE ON;
    LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET vNumcte       = '';
	  LET vUsuarioInset = '';
	BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            RETURN cCod_ret;
        END EXCEPTION;
		
		SELECT numcte, usuario_insert FROM bdicobranza:cb_cat_directorio_cte
			WHERE empresa = '001' AND tipo_cobranza = 'P'
			AND fecha_insert= '11-12-2013' AND usuario_insert = 'syscobra'
			AND status_cliente = 'AC'
		INTO temp cte_dup WITH NO LOG;
		
	FOREACH	WITH HOLD 
		SELECT numcte, usuario_insert 
		INTO vNumcte, vUsuarioInset
		FROM cte_dup WHERE usuario_insert = 'syscobra'

			BEGIN;
			DELETE FROM bdicobranza:cb_cat_directorio_cte WHERE empresa = '001' AND tipo_cobranza='P'
				AND numcte = vNumcte AND fecha_insert= '11-12-2013'
				AND usuario_insert = vUsuarioInset AND status_cliente='AC';
			COMMIT;
END FOREACH;
	
    RETURN cCod_ret;
    END;
END PROCEDURE;