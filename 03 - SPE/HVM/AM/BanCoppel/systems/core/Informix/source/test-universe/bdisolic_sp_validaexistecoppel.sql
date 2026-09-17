CREATE PROCEDURE "informix".sp_validaexistecoppel(p_Empresa CHAR(3), p_NumCte VARCHAR (20))
RETURNING
     CHAR(5); ---cod_ret

    DEFINE v_cod_ret        CHAR(5);
    DEFINE iSqlErr          INTEGER;

    LET v_cod_ret = '00000';

    SET LOCK MODE TO WAIT 3;
  
BEGIN

        ON EXCEPTION SET iSqlerr
            IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                RETURN v_cod_ret;
            END IF;
        END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_ValidaExisteCoppel.out";
	--TRACE ON;

        IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte = p_NumCte AND secuencia = 1) THEN
            LET v_cod_ret = '00001';
       END IF;

  RETURN v_cod_ret;

END;

END PROCEDURE;