CREATE PROCEDURE "informix".sp_ce_consultafecha_inhabil (v_fecha DATE)

RETURNING CHAR(5), CHAR(1);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para pago consulta de fechas laborales para el procesamiento de pólizas contables en días inhabiles 
    -- Autor: SADCV
    -- Fecha: 10/02/2016
    ------------------------------------------------------------------------------>
    
	------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	DEFINE v_tipo       	SMALLINT;
	--DEFINE v_fecha 			DATE ;
	DEFINE v_laborable  	CHAR (1);

    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	LET v_laborable  		= '';
	
   -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/sp_ce_consultafecha_inhabil_.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
   
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            --ROLLBACK WORK;
            RETURN cCodRet, v_tipo;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//
	--BEGIN WORK;
	
    SET ISOLATION DIRTY READ;

		SELECT laborable
		INTO v_laborable
		FROM bdinteg:si_feriado
		WHERE fecha = v_fecha;
		
		LET v_fecha = v_fecha;
		LET v_laborable = v_laborable;
		
		IF v_laborable = 'N' THEN
			LET v_tipo = '0';
		ELSE
			LET v_tipo = '1';
		END IF;
		
		RETURN cCodRet, v_tipo;
    
	END;
	
END PROCEDURE;