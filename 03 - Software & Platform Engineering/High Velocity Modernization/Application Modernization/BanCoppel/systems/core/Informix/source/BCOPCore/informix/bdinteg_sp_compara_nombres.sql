CREATE PROCEDURE "informix".sp_compara_nombres()
    RETURNING
    CHAR(5);

    --DEFINICION DE VARIABLES--
    DEFINE porcentaje, porcentaje2, dPorcentajeFinal  DECIMAL(6,1);
    DEFINE iSqlErr        	INTEGER;
    DEFINE cCodRet      CHAR(5);
	DEFINE vnumcte1, vapell_pat_1, vapell_mat_1, vnom1_1, vnom2_1, vrfc_1, vnumcte2, vapell_pat_2, vapell_mat_2, vnom1_2, vnom2_2, vrfc_2  CHAR(40);
	LET porcentaje = 0;
	LET porcentaje2 = 0;
	LET cCodRet = '00000';
	LET iSqlErr=0;
	LET dPorcentajeFinal = 0;
	
	--	SET DEBUG FILE TO "/tmp/sp_ValidaNomBenefBTS.out";
    --	TRACE ON;
	
		
BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT  numcte1, apell_pat_1, apell_mat_1, nom1_1, nom2_1, rfc_1, numcte2, apell_pat_2, apell_mat_2, nom1_2, nom2_2, rfc_2 
			INTO vnumcte1, vapell_pat_1, vapell_mat_1, vnom1_1, vnom2_1, vrfc_1, vnumcte2, vapell_pat_2, vapell_mat_2, vnom1_2, vnom2_2, vrfc_2
			FROM bdinteg:si_clientes_huellas_dupl 
			WHERE porce_simil IS NULL
			
			EXECUTE PROCEDURE  bdisac:"informix".sp_validanombenefbts(vnom1_1, vnom2_1, vapell_pat_1, vapell_mat_1,
                                       vnom1_2, vnom2_2, vapell_pat_2, vapell_mat_2)
			INTO cCodRet, porcentaje;
			
			EXECUTE PROCEDURE  bdisac:"informix".sp_validanombenefbts(vnom1_2, vnom2_2, vapell_pat_2, vapell_mat_2,
                                       vnom1_1, vnom2_1, vapell_pat_1, vapell_mat_1)
			INTO cCodRet, porcentaje2;			
			
			LET dPorcentajeFinal = (porcentaje+porcentaje2)/2;
			
			IF( dPorcentajeFinal > 100.00) THEN 
				LET dPorcentajeFinal = 100.00;
			END IF;	
			
			UPDATE si_clientes_huellas_dupl SET porce_simil = dPorcentajeFinal WHERE numcte1 = vnumcte1 AND numcte2 = vnumcte2; 
			
		END FOREACH;
		
    RETURN cCodRet;
END
END PROCEDURE;