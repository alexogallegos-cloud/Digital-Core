CREATE PROCEDURE "informix".req_inicial()



DEFINE v_cta                CHAR(20);
DEFINE v_tp                 CHAR(2);
DEFINE v_in                 INTEGER;
DEFINE v_ro                 SMALLINT;
DEFINE v_cp                 INTEGER;
DEFINE v_si		    INTEGER;
DEFINE c   		    INTEGER;
DEFINE d   		    INTEGER;
DEFINE v_ncheq		    SMALLINT;
DEFINE i      		    SMALLINT;
DEFINE v_suc                CHAR(3);
DEFINE v_hoy		    DATE;
DEFINE v_pedido		    INTEGER;
DEFINE v_usuario	    CHAR(8);

--SET DEBUG FILE TO "req_inicial.out";
--TRACE ON;

SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;
SELECT (num_pedido - 1) INTO v_pedido FROM sq_paramgen;
LET v_usuario = USER;

FOREACH SELECT sucursal, cuenta, chequera, ultimo_stock, reorden, chq_prov 
	  INTO v_suc, v_cta, v_tp, v_in, v_ro, v_cp
	  FROM sq_stockctes
--	 WHERE cuenta ="0010137718"



	 SELECT no_cheques INTO v_ncheq FROM sq_chequera
	  WHERE chequera = v_tp;

	
	 LET v_si = v_in / v_ncheq;
	 IF v_si < 0 THEN
		CONTINUE FOREACH;
	 END IF

	 IF v_si < v_ro THEN
	   LET v_si = v_ro - v_si;

	   FOR i = 1 TO v_si
                 LET c = v_cp + 1;
                 LET d = v_cp + v_ncheq;
                 INSERT INTO bdicntchq:sq_reqctes VALUES(v_suc, v_cta, c,
                                                         d, v_hoy, v_hoy, v_hoy,
                                                         "X", "001", v_pedido,
							 v_usuario);
		 LET v_cp =  d;
            END FOR
	END IF
END FOREACH
END PROCEDURE;