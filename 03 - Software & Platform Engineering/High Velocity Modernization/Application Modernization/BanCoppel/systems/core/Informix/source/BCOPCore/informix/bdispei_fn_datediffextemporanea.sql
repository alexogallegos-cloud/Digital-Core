CREATE FUNCTION "informix".fn_datediffextemporanea(pFecha1 DATETIME YEAR to SECOND, pFecha2 DATETIME YEAR to SECOND)
	RETURNING
            CHAR(10); -- Resp
	
	DEFINE vDias		INTEGER;
	DEFINE vDiasMin		INTEGER;
	DEFINE vHoras		INTEGER;
	DEFINE vHorasMin	INTEGER;
	DEFINE vMinutos 	INTEGER;
    DEFINE vResultado	INTEGER;
	DEFINE vDifftime	CHAR(20);

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER; 
    DEFINE vIsamErr         INTEGER;

	LET vDias			=0;
	LET vDiasMin		=0;
	LET vHoras			=0;
	LET vHorasMin		=0;
	LET vMinutos		=0;
    LET vResultado		=0;
	LET vDifftime		=0;

BEGIN
	LET vDifftime = EXTEND(pFecha1,YEAR TO SECOND)- EXTEND(pFecha2,YEAR TO SECOND);
    LET vDias     = SUBSTR(TRIM(vDifftime),1,INSTR(trim(vDifftime), ' ',1));
	LET vHoras	  = SUBSTR(TRIM(vDifftime),INSTR(trim(vDifftime), ' ',1),3);
    LET vMinutos  = SUBSTR(TRIM(vDifftime),(INSTR(trim(vDifftime),' ',1)+4),2);

    LET vDias 	  = ((vDias * 24) * 60);
	LET vHoras	  = vHoras * 60;
    LET vResultado= vDias + vHoras + vMinutos;

    RETURN  vResultado;

END;
END FUNCTION;