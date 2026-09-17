CREATE PROCEDURE "informix".sp_blqdesconcentractasinactivascap(pUsuario     char(8),
                                                               pIdFuncion   char(10),
                                                               pCuenta      CHAR(20))
        RETURNING CHAR(5) AS codret;

DEFINE cCodRet          CHAR(5);
DEFINE iSqlErr          INT;
DEFINE cEmpresa         CHAR(3);
DEFINE cCodMsg          CHAR(50);
DEFINE cCuenta          CHAR(20);
DEFINE iTransaccionPrev int;

LET cCodRet             = "00000";
LET iSqlErr             = 0;
LET cEmpresa            = "001";
LET cCodMsg             = "";
LET cCuenta             = "";
LET iTransaccionPrev = 0;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET iTransaccionPrev = 1;
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-255)
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
        
	--SET DEBUG FILE TO "/tmp/mfinis/sp_blqdesconcentractasinactivascap.out";
	--TRACE ON;

        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR pCuenta = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        --
        IF cCodRet <> '00000' THEN
                RETURN cCodRet;
        END IF;

        -- OBTIENE LOS DATOS Y VALIDA LA CUENTA DE CHEQUES
        LET cCuenta = "";
                
        SELECT mc.cuenta
        INTO cCuenta
        FROM bdicheq:"informix".sc_maechq mc
        WHERE mc.cuenta = pCuenta;
                
        IF NVL(cCuenta,"") = "" THEN
                -- "La Cuenta no existe"
                LET cCodRet = "00009";
                RETURN cCodRet;
        END IF;
                
        BEGIN;
        EXECUTE PROCEDURE bdicheq:"informix".sp_blqdesconcentractasinactivas(cEmpresa
                                                                             ,pCuenta)
                
                INTO cCodRet,
                     cCodMsg;
                
                
        IF cCodRet = '000' THEN
        --      proceso correcto
                LET cCodRet = "00000";
				COMMIT;
                RETURN cCodRet;
        END IF;
        IF cCodRet = '100' THEN
        --      cuenta no existe
                LET cCodRet = '00009';
				ROLLBACK;
                RETURN cCodRet;
        END IF;
        IF cCodRet = '202' THEN
        --      status de la cuenta diferente a 6
                LET cCodRet = '00137';
				ROLLBACK;
                RETURN cCodRet;
        END IF;
        IF cCodRet = '400' THEN
        --      fondos insuficientes
                LET cCodRet = '00136';
				ROLLBACK;
                RETURN cCodRet;
        END IF;

        IF iTransaccionPrev = 1 THEN
			BEGIN WORK;
		END IF;
                
        RETURN cCodRet;

END;

END PROCEDURE;