CREATE PROCEDURE "informix".sp_valida_gerente(pempresa CHAR(3), cEmpleado CHAR(20))
   returning char(5);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNombramiento CHAR(25);

LET iSqlErr = 0;
LET cCodRet = "00000";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

    IF pempresa = '' OR pempresa IS NULL THEN
       LET cCodRet = "110";
       RETURN cCodRet;
    END IF;

    IF cEmpleado = '' OR cEmpleado IS NULL THEN
       LET cCodRet = "110";
       RETURN cCodRet;
    END IF;

    SELECT nombramiento
        INTO cNombramiento
      FROM si_ejecut
        WHERE ejecutivo=cEmpleado;

    --IF cNombramiento IS NULL or TRIM(UPPER(cNombramiento))<> "GERENTE TITULAR" THEN
	-- Se agrego la validacion para el nuevo perfil SUB-GERENTE
	IF TRIM(UPPER(cNombramiento)) in ('GERENTE TITULAR','JEFE OP. Y SERV') AND cNombramiento IS NOT NULL THEN
	ELSE
		LET cCodRet="119";
		RETURN cCodRet;
    END IF;


RETURN cCodRet;

END
END PROCEDURE;