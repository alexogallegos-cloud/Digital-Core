CREATE PROCEDURE "informix".sp_ce_aplicareversion (v_FolioSUC CHAR(16), v_usuario CHAR(8))

RETURNING CHAR(5);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para reversion de cargo a cuenta de cheques por pago de crédito empresarial - Orión
    -- Autor: SADCV
    -- Fecha: 30/09/2013
    ------------------------------------------------------------------------------>
    
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	

	DEFINE cod_ret 		CHAR (5);
	
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	LET cod_ret 			= '';
	
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicareversion.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
    
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            -- ROLLBACK WORK;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//

    SET ISOLATION DIRTY READ;
	
	CALL bdicheq:reversion('001','9550', v_usuario, v_FolioSUC, '0') 
	RETURNING cod_ret;
	
	LET cCodRet = LPAD (TRIM(cod_ret), 5, '0');
	
    RETURN cCodRet;
    
	END;
	
END PROCEDURE;