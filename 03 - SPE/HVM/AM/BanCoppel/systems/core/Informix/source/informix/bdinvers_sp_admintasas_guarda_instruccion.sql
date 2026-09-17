create procedure "informix".sp_admintasas_guarda_instruccion(pNumcte CHAR(20), pInstruccionCapital CHAR(2), pInstruccionIntereses CHAR(2))
-- ******************************************************************************************
-- Realizo   : Daniel Perez
-- Proyecto  : RQM Administrador de tasas - TEMCAP08 Addendum
-- Actividad : Guardar temporalmente la instruccion al vencimiento seleccionada en la apertura del pagare.
--                 
-- Fecha     : 04 de Julio de 2025
-- ******************************************************************************************                                    
RETURNING CHAR(5) AS codRet;

-- DefiniciÃ³n de Variables
DEFINE SQL_ERR          		INTEGER;
DEFINE vCodRet          		CHAR(5);

-- Valores iniciales
LET vCodRet	 					= '001';

BEGIN

	ON EXCEPTION SET SQL_ERR
        LET vCodRet = SQL_ERR;
        RETURN vCodRet;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/prueba_ofi_pagare/sp_admintasas_guarda_instruccion.out';
    --TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;


    DELETE FROM sv_admintasas_instruccion_vencimiento WHERE num_cte = pNumcte;

    INSERT INTO sv_admintasas_instruccion_vencimiento (num_cte, instruccion_capital, instruccion_intereses)
     VALUES (pNumcte, pInstruccionCapital, pInstruccionIntereses);


    LET vCodRet = '000';

    RETURN vCodRet;


END;
END PROCEDURE
