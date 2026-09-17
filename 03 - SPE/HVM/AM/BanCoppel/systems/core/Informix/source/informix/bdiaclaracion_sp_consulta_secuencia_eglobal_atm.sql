CREATE PROCEDURE "informix".sp_consulta_secuencia_eglobal_atm()

    RETURNING CHAR(10) AS consecutivo;
    
    DEFINE iSqlErr      		INTEGER;
    DEFINE secuencia            CHAR(10);

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				RETURN  iSqlErr||''; --RETURNING
			END IF;
        END EXCEPTION;
        
        /*
        SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_consulta_secuencia_eglobal_atm"; --> TRACE DESDE APP
        TRACE ON;
        */
         

         LET secuencia = (SELECT "informix".secuencia_folio_eglobal_atm_seq.nextval FROM systables WHERE tabid=1);
                                
         RETURN secuencia;

    END

END PROCEDURE;