CREATE PROCEDURE "informix".sp_consultarcatestatus()
	RETURNING 	CHAR(6) AS retorno,
				CHAR(2) AS idestatus, 
				CHAR(20) AS descripcion;

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(6);
	DEFINE v_sIdEstatus 		CHAR(2);
	DEFINE v_sDescripcion		CHAR(20);
		
	--SET DEBUG FILE TO "/tmp/sp_consultarcatestatus.out"; 
	--TRACE ON;
	
	LET v_sValRetorno = '000001';
		
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','';
			END IF;
		END EXCEPTION;			
		
		FOREACH
		select idestatus, desestatus
		into v_sIdEstatus, v_sDescripcion
		from rec_catestatus where idestatus in (3,4,7)
		order by idestatus
			
			LET v_sValRetorno = '000000';
			
			RETURN v_sValRetorno, v_sIdEstatus, v_sDescripcion WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE;