CREATE PROCEDURE "informix".sp_random(p_snumero INTEGER, p_smaximo INTEGER)
	RETURNING INTEGER;

    DEFINE v_dsemilla 	DECIMAL(10) ;
    DEFINE v_ddecimal 	DECIMAL(20,0);
	DEFINE v_ivalor 	INTEGER;
	DEFINE v_ssegundo   INTEGER;
	DEFINE v_ireturn	INTEGER;

	--************************************************
	-- Creado por Javier Calderon 14/12/2008         *
	--************************************************

	SELECT LIMIT 1 SUBSTRING (CURRENT FROM 18 FOR 2) INTO v_ssegundo FROM bdinteg:si_bpiusuarios;

	LET p_snumero = p_snumero + v_ssegundo;
    LET v_ddecimal = (p_snumero * 1103515245) + 12345;  --1103517714
	
    LET v_dsemilla = (v_ddecimal - (p_smaximo * 12345678)) * TRUNC(v_ddecimal / (p_smaximo * 12345678));

	LET v_ivalor = MOD(TRUNC(v_dsemilla / 65536), 32768);

	LET v_ireturn = MOD(v_ivalor, p_smaximo);

	IF v_ireturn = 0 THEN
		LET v_ireturn = p_smaximo;
	END IF

    RETURN v_ireturn;
END PROCEDURE;