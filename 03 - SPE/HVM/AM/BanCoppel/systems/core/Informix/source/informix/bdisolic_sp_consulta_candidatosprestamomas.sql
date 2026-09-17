CREATE PROCEDURE "informix".sp_consulta_candidatosprestamomas(pNumcte CHAR (20))
RETURNING
    CHAR(5)     AS Retorno, -- Codigo de Retorno	
	CHAR(20)    AS ClienteCoppel; --Num de Cliente coppel
	
	-- DEFINICION DE VARIABLES
	DEFINE vlRetorno	CHAR(5);   -- Codigo de Retorno
	DEFINE vlCliente    CHAR(20); -- Codigo cliente encontrado en tabla
    DEFINE vlClienteCpl    CHAR(20);
    DEFINE cClienteCpl  INTEGER;
    DEFINE cClienteCpl2  INTEGER;

    -- EXCEPTION
    DEFINE iSqlErr  INTEGER;
	
	--INICIALIZACION DE VARIABLES
	LET vlRetorno = '00001';
    LET	vlCliente = '';
    LET vlClienteCpl = '';
    LET cClienteCpl = 0;
    LET cClienteCpl2 = 0;
    LET iSqlErr = 0;

BEGIN
    ON EXCEPTION SET iSqlErr
    IF iSqlErr != 0 THEN
        LET vlRetorno = iSqlErr;
        RETURN TRIM(vlRetorno), vlCliente;
    END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --	SET DEBUG FILE TO "/informix/OscarOjeda/PMB/ss_consulta_candidatosprestamomas.out";
    --	TRACE ON;
	
    IF NVL(pNumcte,'') = '' THEN
        RETURN  vlRetorno,vlCliente;
    ELSE	

        SELECT numcte_ref INTO vlCliente FROM bdinteg:si_cliente WHERE numcte = pNumcte AND tipo_cliente = '1';

        IF NVL(vlCliente,'') <> '' THEN

                SELECT COUNT(numcte_coppel) INTO cClienteCpl FROM bdisolic:candidatosprestamomas WHERE numcte_coppel = vlCliente AND numcte_banco = pNumcte;

                SELECT COUNT(numcte_coppel) INTO cClienteCpl2 FROM bdisolic:candidatosprestamomas WHERE numcte_coppel = vlCliente AND numcte_banco = '';
                
                IF  (cClienteCpl > 0) OR (cClienteCpl2 > 0) THEN
                    LET	vlRetorno	 = "00000";
                ELSE
                    LET	vlRetorno	 = "00002";
                END IF;

            -- END IF;

        END IF;

        RETURN  vlRetorno,vlCliente;

    END IF;
END
END PROCEDURE
