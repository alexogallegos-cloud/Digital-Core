CREATE PROCEDURE "informix".sp_ce_consultafechas (v_tipo CHAR(1))

RETURNING CHAR(5), CHAR(1), DATE;
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para pago consulta de fechas
    -- Autor: SADCV
    -- Fecha: 23/04/2014
    ------------------------------------------------------------------------------>
    
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	
	-- DEFINE v_tipo       	CHAR(1);
	DEFINE v_fecha_hoy		DATE ;

    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	-- LET v_tipo			= v_tipo;
	LET v_fecha_hoy			= '';

   -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_consultafechas.out";
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
            RETURN cCodRet, v_tipo, v_fecha_hoy;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//

	--BEGIN WORK;
	
    SET ISOLATION DIRTY READ;

	IF (v_tipo = '1') THEN   --> Cheques
	
		SELECT fecha_hoy
		INTO v_fecha_hoy
		FROM bdicheq:sc_fechas; -- Realizar Cambio en la Base de datos en Producción.
		
	ELIF (v_tipo = '2') THEN --> Crédito
	
		SELECT fecha_hoy
		INTO v_fecha_hoy
		FROM bdicred:sd_fechas;
		
	ELIF (v_tipo = '3') THEN --> Integral
	
		SELECT fecha_hoy
		INTO v_fecha_hoy
		FROM bdinteg:si_fechas;
	
	ELIF (v_tipo = '4') THEN --> Contabilidad
	
		SELECT fecha_hoy
		INTO v_fecha_hoy
		FROM bdicont:co_fechas;
		
	END IF;
	
		LET v_tipo 		= v_tipo;
		LET v_fecha_hoy = v_fecha_hoy;
	
    RETURN cCodRet, v_tipo, v_fecha_hoy;
    
	END;
	
END PROCEDURE;