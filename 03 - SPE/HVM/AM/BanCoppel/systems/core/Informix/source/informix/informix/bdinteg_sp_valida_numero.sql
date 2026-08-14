create procedure "informix".sp_valida_numero(sCP  char(5))
 RETURNING CHAR(5) as codret, CHAR(1) as pos1, CHAR(1) as pos2, CHAR(1) as pos3, CHAR(1) as pos4, CHAR(1) as pos5;

DEFINE iSqlErr	INTEGER;
DEFINE sCodRet  CHAR(5);
DEFINE sPos1    CHAR(1);
DEFINE sPos2    CHAR(1);
DEFINE sPos3    CHAR(1);
DEFINE sPos4    CHAR(1);
DEFINE sPos5    CHAR(1);

LET iSqlErr	= 0;
LET sCodRet = '00000';
LET sPos1   ='';
LET sPos2   ='';
LET sPos3   ='';
LET sPos4   ='';
LET sPos5   ='';


BEGIN
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
	   RETURN iSqlErr, sPos1, sPos2, sPos3, sPos4, sPos5;
        END IF;
END EXCEPTION;


IF TRIM(sCP)="" OR LENGTH(sCP)<5  OR sCP="00000" THEN
    RETURN '00006', sPos1, sPos2, sPos3, sPos4, sPos5;
END IF;

--SEPARANDO EL CODIGO POSTAL EN POSICIONES
    SELECT sCP[1],sCP[2],sCP[3], sCP[4], sCP[5]
        INTO sPos1, sPos2, sPos3, sPos4, sPos5
    FROM si_fechas;

--VALIDANDO POSICION 1
    IF (sPos1<>"0" AND sPos1<>"1" AND sPos1<>"2" AND sPos1<>"3" AND sPos1<>"4" AND sPos1<>"5" AND sPos1<>"6" 
        AND sPos1<>"7" AND sPos1<>"8" AND sPos1<>"9" ) THEN
        RETURN '00001', sPos1, sPos2, sPos3, sPos4, sPos5;
    END IF; 

--VALIDANDO POSICION 2
    IF (sPos2<>"0" AND sPos2<>"1" AND sPos2<>"2" AND sPos2<>"3" AND sPos2<>"4" AND sPos2<>"5" AND sPos2<>"6" 
        AND sPos2<>"7" AND sPos2<>"8" AND sPos2<>"9" ) THEN
        RETURN '00002', sPos1, sPos2, sPos3, sPos4, sPos5;
    END IF; 

--VALIDANDO POSICION 3
    IF (sPos3<>"0" AND sPos3<>"1" AND sPos3<>"2" AND sPos3<>"3" AND sPos3<>"4" AND sPos3<>"5" AND sPos3<>"6" 
        AND sPos3<>"7" AND sPos3<>"8" AND sPos3<>"9" ) THEN
        RETURN '00003', sPos1, sPos2, sPos3, sPos4, sPos5;
    END IF; 

--VALIDANDO POSICION 4
    IF (sPos4<>"0" AND sPos4<>"1" AND sPos4<>"2" AND sPos4<>"3" AND sPos4<>"4" AND sPos4<>"5" AND sPos4<>"6" 
        AND sPos4<>"7" AND sPos4<>"8" AND sPos4<>"9" ) THEN
        RETURN '00004', sPos1, sPos2, sPos3, sPos4, sPos5;
    END IF; 

--VALIDANDO POSICION 5
    IF (sPos5<>"0" AND sPos5<>"1" AND sPos5<>"2" AND sPos5<>"3" AND sPos5<>"4" AND sPos5<>"5" AND sPos5<>"6" 
        AND sPos5<>"7" AND sPos5<>"8" AND sPos5<>"9" ) THEN
        RETURN '00005', sPos1, sPos2, sPos3, sPos4, sPos5;
    END IF; 


RETURN sCodRet, sPos1, sPos2, sPos3, sPos4, sPos5;
END
END PROCEDURE;