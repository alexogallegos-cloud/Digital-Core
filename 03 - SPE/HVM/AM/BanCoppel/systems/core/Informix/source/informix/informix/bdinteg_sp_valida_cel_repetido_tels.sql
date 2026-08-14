CREATE PROCEDURE "informix".sp_valida_cel_repetido_tels(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;
DEFINE iValidaDiasTu    INTEGER;
DEFINE sTelefonoAct CHAR(13);
--TEls
DEFINE sNumcte 		CHAR(9);
--DEFINE sStatus_tel	CHAR(1);
DEFINE CodRet		CHAR(5);
DEFINE sTipoCte		CHAR(1);
DEFINE sSecuencia	CHAR(3);

LET sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;
LET iValidaDiasTu    = 0;
LET sTelefonoAct     = 0;
--TEls
LET sNumcte			= '';
--LET sStatus_tel		= '';
LET CodRet			= '00000';
LET sTipoCte		= '';
LET sSecuencia		= '';

BEGIN
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LMendoza/sp_valida_cel_repetido.out';
--SET DEBUG FILE TO '/pisa/pisabanco/sp_valida_cel_repetido_tels.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;  
    SET LOCK MODE TO WAIT 3;
	
	SELECT telefono INTO sTelefonoAct FROM bdinteg:"informix".si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel=2;
		IF (TRIM(sTelefonoAct) == TRIM(pNumCel)) THEN RETURN sCodRet, iCantRep;
			END IF;
	
	--Se cosulta el tipo de cliente que tiene el telefono celular
	SELECT first 1 numcte INTO sNumcte FROM bdinteg:"informix".si_telefonos 
		WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel = 'A' AND verificado='V';
	
	EXECUTE PROCEDURE bdinteg:cons_tipo_cte('001',sNumcte)
		   INTO CodRet, sTipoCte, sSecuencia;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';

/*	RQM 10 1768 Mantto tels
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel IN ('A','C') AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));

	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
	
*/
	--Se identifica si el cliente es titular, aplica la regla de los 30 dÃ­as, de lo contrario puede registrar el celular del prospecto
	IF sTipoCte = '1' THEN
		SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
		WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel = 'A' AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
		
		IF iCantRep>=1 THEN
			LET sCodRet='288';
		END IF;
	END IF;

	
RETURN sCodRet, iCantRep;

END
END PROCEDURE;