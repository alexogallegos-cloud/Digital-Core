CREATE PROCEDURE "informix".sp_obtener_cel_rep_act(pNumCte CHAR(20),
												   pNumCel CHAR(10)
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS totRegRep;
	

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_obtener_cel_rep_act"
Folio.........: 854 - Validacion de numeros de celular en 90 dias.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 27/04/2022
Solicita......: Bancoppel
BD............: bdinteg
*/


DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iValidaDiasTu    INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iValidaDiasTu    = 0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LIP/sp_obtener_cel_rep_act.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='F' AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
																																									   
		
	    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;