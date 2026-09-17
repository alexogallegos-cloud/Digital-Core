CREATE PROCEDURE "informix".monthsdiff(nPFecha DATE, fechaAlta DATE)
	RETURNING INTEGER AS numero_meses;
	
	DEFINE num INTEGER;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET num = SUBSTRING(CAST(ROUND((nPFecha - fechaAlta) / (365.25/12),1) AS CHAR(12)) 
			  FROM 1 FOR 
			  CHARINDEX(".",CAST(ROUND((nPFecha - fechaAlta) / (365.25/12),1) AS CHAR(12)))-1);
	
	/*IF num < 0 THEN
		LET num = SUBSTRING(CAST(ROUND((today - fechaAlta) / (365.25/12),1) AS CHAR(12)) 
				  FROM 1 FOR 
		          CHARINDEX(".",CAST(ROUND((today - fechaAlta) / (365.25/12),1) AS CHAR(12)))-1);
	END IF;*/

	RETURN num;
END PROCEDURE
