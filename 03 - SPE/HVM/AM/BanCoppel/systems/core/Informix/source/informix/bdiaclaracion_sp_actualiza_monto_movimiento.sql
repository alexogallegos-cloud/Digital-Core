CREATE PROCEDURE "informix".sp_actualiza_monto_movimiento(pFolioSuac CHAR(10),pIdMov INTEGER,pMonto MONEY)
    RETURNING CHAR(3) as cCodRet;

    DEFINE cCodRet              CHAR(3);   
    DEFINE iSqlErr INTEGER;

    LET cCodRet      		= '000';

    -- SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_tipoTransaccion"||"_"||""||pFolioSuac||""||"_v1_"||".out";
    -- TRACE ON;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = '001';  
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;

		UPDATE bdiaclaracion:acl_movimiento
		SET montoprocedente = pMonto
		WHERE folio_csuac = pFolioSuac
        AND pky_movimiento = pIdMov;

    END;
    
    RETURN cCodRet;

END PROCEDURE;