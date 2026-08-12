CREATE FUNCTION "informix".fn_pld_chqc_valfolper(pperiodo char(020)) RETURNING INT;
	
	
	IF (select count(*) from tblpld_chqc_crg where periodo = pperiodo and folio_consec_oper <> "" ) > 0 THEN
	
		RETURN 1;
	
	ELSE
		
		RETURN 0;	
			
	END IF

END FUNCTION;