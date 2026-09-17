CREATE PROCEDURE "informix".sp_tel_casa_valido(pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet;
        END IF;
    END EXCEPTION; 	
    
    IF EXISTS(SELECT * FROM si_sucvalidasms WHERE sucursal=pSucursal AND activo='1') THEN
        IF NOT EXISTS (SELECT * FROM si_telefonos WHERE numcte=pNumCte AND tipo_tel='1' AND status_tel='A' AND cofetel='V') THEN
           LET sCodRet='00001'; 
        END IF;
    END IF; 

RETURN NVL(sCodRet,'00000');

END
END PROCEDURE
;