CREATE PROCEDURE "informix".sp_verifica_cel_tarjper(pNumCte CHAR(9), pNumCel CHAR(10) )
RETURNING CHAR(5), INTEGER  ;

DEFINE sCodRet		CHAR(5);
DEFINE iVerificado  INTEGER;
DEFINE iVerificado2  INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;

LEt sCodRet     =   '00000';
LET iVerificado =   0;
LET iVerificado2 =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iVerificado;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/scarlett/sp_valida_cel_tarjper.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
  
	-- Valida si el celular fue verificado hace mÃ¡s de 90 dÃ­as
	SELECT count(*) INTO iVerificado FROM bdinteg:si_bitsmstels 
	WHERE telefono = pNumCel AND numcte = pNumCte AND bandera = 't' AND date(fecha) < (TODAY - 90);
    
    IF iVerificado >= 1 THEN
        LET sCodRet='289';			-- Verificado hace mas de 90 dias

	END IF;

	-- Valida si el celular fue verificado en los Ãºltimos 90 dÃ­as
    SELECT count(*) INTO iVerificado2 FROM bdinteg:si_bitsmstels 
	WHERE telefono = pNumCel AND numcte = pNumCte AND bandera = 't' AND date(fecha) > (TODAY - 90);
    
    IF iVerificado2 = 0 THEN
        LET sCodRet='290';			-- No verificado
        LET iVerificado = iVerificado2;
	END IF;

    

RETURN NVL(sCodRet,'000'), NVL(iVerificado,0);

END
END PROCEDURE;