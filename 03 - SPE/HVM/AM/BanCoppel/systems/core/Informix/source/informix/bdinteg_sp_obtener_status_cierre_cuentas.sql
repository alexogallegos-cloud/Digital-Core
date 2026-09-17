CREATE PROCEDURE "informix".sp_obtener_status_cierre_cuentas(pNumEmpresa  CHAR(3),
															 pDescProceso VARCHAR(20),
															 pFechaCierre DATE)
RETURNING
    CHAR(5),
    CHAR(1);

--Creado por: Javier Calderon
--Actividad:  Obtener el Status del cierre de cuentas
--Solicito:   Mauricio Leon
--Fecha:      16/02/2010

DEFINE cCodRet          CHAR(5);
DEFINE vValorStatus     CHAR(1);
DEFINE iSqlErr			INTEGER;

LET cCodRet = '000';
LET vValorStatus = '';

--SET DEBUG FILE TO "sp_obtener_status_cierre_cuentas.out";
--TRACE ON;


BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodret = iSqlErr;
            RETURN cCodret, vValorStatus;
        END IF;
    END EXCEPTION;

    IF (month(pFechaCierre) = '12' and day(pFechaCierre)= '25') OR (month(pFechaCierre) = '01' and day(pFechaCierre)= '01') THEN
        LET pFechaCierre = pFechaCierre - 1;
    END IF;
    
	IF EXISTS (SELECT status_proc FROM sx_contproc WHERE empresa = pNumEmpresa AND proceso = pDescProceso AND fecha = pFechaCierre) THEN
		SELECT status_proc INTO vValorStatus FROM sx_contproc WHERE empresa = pNumEmpresa AND proceso = pDescProceso AND fecha = pFechaCierre;
	ELSE
		LET cCodRet = '001';
	END IF;
	RETURN cCodRet, vValorStatus;
END
END PROCEDURE
;