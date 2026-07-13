CREATE PROCEDURE "informix".sp_valida_ctehuella_comp(pNumCte CHAR(20))
    --DATOS A REGRESAR---
    RETURNING CHAR(5),CHAR(942),CHAR(942);
    
    --DEFINICION DE VARIABLES--
    DEFINE iSql_err INTEGER;
    DEFINE cCodRet  CHAR(5);
    DEFINE cHuellaD CHAR(942);
    DEFINE cHuellaI CHAR(942);
   	DEFINE existe INTEGER;
    
    --SET DEBUG FILE TO "/informix/jfponce/gabriel/err/sp_generahuellalinea.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET iSql_err = 0;
    LET cCodRet  = '00000';
    LET cHuellaD = "";
    LET cHuellaI = "";
   	let existe = 0;

BEGIN
    ON EXCEPTION SET iSql_err
        IF iSql_err    <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet, cHuellaD,cHuellaI;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT 1, dmapa, imapa
    INTO existe, cHuellaD, cHuellaI
    FROM bdinteg:"informix".si_cte_huella
    WHERE numcte = pNumcte AND estado ="A";

    IF existe IS NULL THEN
        LET cCodRet="00001";
        RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
    END IF;
   
    RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
END;
END PROCEDURE;