CREATE PROCEDURE "informix".sp_rollback_cfdi (pempresa char(3),pnumcte char(20)) 
    RETURNING CHAR(5) AS CodigoRetorno

    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);

	-- SET DEBUG FILE TO  "sp_rollback_cfdi.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '00000';

	-- ******************************************************************************************************************************************************
    -- Creado por:			L.I. Manuel Ramos Figueroa
    -- Fecha: 2014/03/06
    -- Objetivo:			Elimina el registro de alta de servicio de estados de cuenta CFDI del cliente
    -- ******************************************************************************************************************************************************

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF NOT EXISTS (SELECT numcte FROM bdiedoelec:"informix".edelec_alta_serv WHERE numcte = pnumcte ) THEN
			LET v_sCodRet = '00001'; --Cliente No se encuentra en el Alta del Servicio
		ELSE
			DELETE FROM bdiedoelec:"informix".edelec_alta_serv WHERE numcte = pnumcte;
		END IF;

		RETURN v_sCodRet;
    END
END PROCEDURE;