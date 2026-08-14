CREATE PROCEDURE "informix".sp_recupera_cuentatelefono(pcel CHAR(10))
	RETURNING CHAR(5) AS codret, CHAR(160) AS estatus;
    
	DEFINE vsqlerr, vcant INTEGER;

    DEFINE vcodret 			CHAR(5);
	DEFINE vTermCta 		CHAR(5);

    LET vcodret    		= '00000';
	LET vTermCta   		= '';
    
    BEGIN

		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF LENGTH(pcel) <> 10 THEN
			LET vcodret = "00001";
			RETURN vcodret,'NUMERO TELEFONICO INVALIDO, VERIFIQUE.';
		END IF;

 		SELECT COUNT(*) INTO vcant FROM bdicheq:sc_cuenta_telefono WHERE telefono=pcel;

		IF vcant <> 1 THEN 
			RETURN vcodret,'SU TELEFONO CELULAR NO ESTA ASOCIADO A UNA CUENTA EFECTIVA.';
		END IF;
													
		LET vTermCta = SUBSTR(TRIM((select TRIM(cuenta) from bdicheq:sc_cuenta_telefono where telefono=pcel)),7,5);
		
		RETURN vcodret,'SU TELEFONO CELULAR ESTA ASOCIADO A LA CUENTA EFECTIVA CON TERMINACION ***' || vTermCta;
	END;
END PROCEDURE;