CREATE PROCEDURE "informix".sp_consultaingresos(pEmpresa CHAR(3), pNumeroCliente CHAR(20))
                  returning CHAR(5);

---23/02/2009
--Tortolero Varela Rodolfo
--consulta si el cliente  existe en la tabla si_ingresos

-- Fecha: 09/10/2009
-- Modifico: Paul Ivan Quintero Varela
-- Observaciones: Se modifica para que el query de consulta solo verifique si el cliente ya cuenta con un 
--                registro en la tabla si_ingresos independientemente si el tipo ingreso es "T" (Trabajo) o
--                "E" (Extra) y para validar que se reciban parámetros validos.

--define variables
DEFINE iSqlErr INTEGER;
DEFINE vcodret CHAR(5);
DEFINE vNumCte CHAR(20);

--asigna variables
LET vcodret = "000";
LET vNumCte = "";

IF NVL(pEmpresa,'') = ''  OR  NVL(pNumeroCliente,'') = '' THEN
    LET vcodret = "002"; -- Se realizo la ejecucion del procedimiento de forma incorrecta.
    RETURN vcodret;
END IF;

BEGIN
    ON EXCEPTION
        SET iSqlErr
          IF iSqlErr <> 0 THEN
             LET vCodRet = iSqlErr;
             RETURN vcodret;
          END IF;
    END EXCEPTION;
		
    --SET DEBUG FILE TO "/tmp/sp_consultaingresos.out";
    --TRACE ON;

        SELECT LIMIT 1 numcte 
          INTO vNumCte
          FROM bdinteg:si_ingresos
         WHERE empresa = pEmpresa 
           AND numcte = pNumeroCliente;
       
        IF vNumCte = pNumeroCliente THEN
			LET vcodret = "001"; -- ya existe el cliente en la tabla, por lo tanto se hara un cambio de los ingresos.
		ELSE
			LET vcodret = "000"; --no existe el cliente en la tabla, por lo tanto se hara una alta de los ingresos.
        END IF;

        RETURN vcodret;
END;
END PROCEDURE;