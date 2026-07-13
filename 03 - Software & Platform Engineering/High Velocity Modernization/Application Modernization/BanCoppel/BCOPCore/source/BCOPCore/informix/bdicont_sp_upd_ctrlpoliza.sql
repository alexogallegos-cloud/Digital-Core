CREATE PROCEDURE "informix".sp_upd_ctrlpoliza(pre integer , post integer)
 RETURNING INTEGER;
 
	DEFINE v_numero INTEGER;
	
	IF pre < post THEN
		LET v_numero = post;
	ELSE
		LET v_numero = pre + 1;
	END IF
	
	RETURN v_numero;
	
END PROCEDURE;