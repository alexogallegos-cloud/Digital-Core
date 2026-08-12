CREATE PROCEDURE "informix".sp_ce_consultacodret  (v_ccodret CHAR(5), v_sistema CHAR (2))

RETURNING CHAR(5), CHAR(5), CHAR (50);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para consulta de códigos de retorno de error cheques por peticiones - Orión
    -- Autor: SADCV
    -- Fecha: 30/09/2013
    ------------------------------------------------------------------------------>
    
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
	DEFINE vCodRet			CHAR (5);
    DEFINE cCodRet  		CHAR (5);
	DEFINE cDescripcion	 	CHAR (50);

	DEFINE cod_ret 			CHAR (5);
	
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
	LET vCodRet				= '';
    LET cCodRet 			= v_ccodret;
	LET cDescripcion		= '';
	
	LET cod_ret 			= '';
	
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_consultacodret.out";
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
            RETURN vCodRet, cCodRet, cDescripcion;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//

    SET ISOLATION DIRTY READ;
	
	LET v_ccodret = SUBSTRING(v_ccodret FROM 3 FOR 3);
	
		SELECT descripcion
		INTO cDescripcion
		FROM bdinteg:si_codret 
		WHERE sistema = v_sistema -- '01' Cheques 
		AND codigo_retorno = v_ccodret;
		
		IF cDescripcion = '' OR cDescripcion IS NULL THEN 
		
			LET cDescripcion = 'No existe el código';
			LET cCodRet = '99999';
			LET vCodRet = '99999';
			
			ELSE 
			
			LET vCodRet = '00000'; --> Código exitos
		
		END IF;
	
    RETURN vCodRet, cCodRet, cDescripcion;
    
	END;
	
END PROCEDURE;