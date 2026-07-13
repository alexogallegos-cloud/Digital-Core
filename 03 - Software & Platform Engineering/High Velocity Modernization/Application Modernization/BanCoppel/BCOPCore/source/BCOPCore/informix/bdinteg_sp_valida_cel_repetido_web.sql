CREATE PROCEDURE "informix".sp_valida_cel_repetido_web(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))

	RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;
	
	DEFINE sCodRet		CHAR(5);
	DEFINE iCantRep     INTEGER;
	DEFINE iSqlErr		INTEGER;
	DEFINE iSamErr		INTEGER;
	DEFINE iDias        INTEGER;
	
	LEt sCodRet     =   '00000';
	LET iCantRep    =   0;
	LET iSqlErr		=   0;
	LET iSamErr     =   0;
	LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='V'	AND (DATE(CURRENT) - DATE(fecha_hora) < 90);
		
	IF iCantRep >= 1 THEN
		LET sCodRet = '00288';
	END IF;
	
	RETURN sCodRet, iCantRep;
END
END PROCEDURE;