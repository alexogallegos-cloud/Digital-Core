CREATE PROCEDURE "informix".sp_valida_ctasfrec_bpi(NumCte CHAR(10), CtaDestino CHAR(20), CveEstado CHAR(2))
RETURNING
     CHAR(6), ---cod_ret
	 SMALLINT ---contador de programaciones

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_ContReg			SMALLINT;

	LET v_ContReg = 0;
	LET v_cod_ret = "";
	
	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, v_ContReg;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_consulta_ctasfrec_bpi.out";
	--TRACE ON;

	IF (NumCte <> "" AND NumCte IS NOT NULL) AND (CtaDestino <> "" AND CveEstado <> "")  THEN
		
		SELECT count(*) INTO v_ContReg FROM pp_pagoprog WHERE num_cte = NumCte AND cve_estado = CveEstado AND cuenta_destino = CtaDestino;
		
		IF v_ContReg > 0 THEN 
			LET v_cod_ret = "000000"; -- existe por lo menos una programación
		ELSE
			LET v_cod_ret = "97000"; --NO EXISTE PAGOS PROGRAMADOS
		END IF;
	ELSE
		LET v_cod_ret = "10000"; --DATOS INVALIDOS
		LET v_ContReg = 0;
	END IF;
	RETURN v_cod_ret, v_ContReg;
		
END;
--##############################################################################
--## Procedimiento   : Validar antes de Eliminar Cta Frecuente con Programaciones
--## Version         : 1.0
--## Creado por      : Ismael Hernández
--## Fecha creacion  : Diciembre de 2012
--##############################################################################
END PROCEDURE;