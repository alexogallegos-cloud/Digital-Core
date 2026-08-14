CREATE PROCEDURE "informix".sp_valida_cel_tarjper(pNumCte CHAR(9), pNumCel CHAR(10) )
RETURNING CHAR(5), INTEGER  ;

DEFINE sCodRet		CHAR(5);
DEFINE sCodRetV		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iVerificado  INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iVerificado =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            LET sCodRetV = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/scarlett/sp_valida_cel_tarjper.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Valida si el celular esta repetido
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A';
	IF iCantRep >= 1 THEN
		LET sCodRet='288';
	END IF;
   


RETURN NVL(sCodRet,'00000'), NVL(iCantRep,0);

END
END PROCEDURE;