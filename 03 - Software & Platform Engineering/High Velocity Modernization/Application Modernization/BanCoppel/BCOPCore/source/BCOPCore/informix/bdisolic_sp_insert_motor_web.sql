CREATE PROCEDURE "informix".sp_insert_motor_web ( pEmpresa CHAR(3), pNumcte CHAR (20), pNumSol CHAR (20))
RETURNING
	CHAR(6) AS cCodRet;

    --DEFINICION DE VARIABLES DE ERROR
    DEFINE iSqlErr         INTEGER;
    DEFINE iIsamErr        INTEGER;
    DEFINE cCodRet         CHAR(6);

    --DECLARACION DE VARIABLES DE ERROR
    LET iSqlErr  = 0;
    LET iIsamErr = 0;
    LET cCodRet  ="000000";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet;
       END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --SET debug file to '/home/sysifx/VeraMariscal/sp_insert_motor_web.out';
    --TRACE ON; 

    IF NVL(pNumcte,"") = "" OR NVL(pNumSol,"") = "" OR NVL(pEmpresa,"") = "" THEN

		  LET cCodRet = "000001"; -- Parametros de entrada insuficiontes

    ELSE

      INSERT INTO  bdisolic:"informix".ss_enviossolicitudesmotor (empresa, num_solicitud, num_cte, status_consumo, fecha_insert, status_respuesta)
		  VALUES  (pEmpresa , pNumSol, pNumcte , 0, current, '');

    END IF;	

	RETURN cCodRet; 
END
END PROCEDURE
