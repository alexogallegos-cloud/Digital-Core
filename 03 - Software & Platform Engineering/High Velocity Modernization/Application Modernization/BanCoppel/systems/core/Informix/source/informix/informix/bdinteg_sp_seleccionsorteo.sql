CREATE PROCEDURE "informix".sp_seleccionsorteo( )

    RETURNING CHAR(5), CHAR(5), CHAR(50);

    -- DEFINICION DE VARIABLES --
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);
    DEFINE cCveSorteo CHAR(5);
    DEFINE cResultado CHAR(50);
	DEFINE v_param	  CHAR(5);
	

    -- INICIALIZACION DE VARIABLES --
    LET cCodRet = "00000";
    LET cCveSorteo = "00000";
    LET cResultado = "";

    --SET DEBUG FILE TO '/tmp/sp_seleccionsorteo.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cCveSorteo, cResultado;
        END IF;
    END EXCEPTION;

	 SELECT valor INTO v_param
	FROM bdinteg:si_param
	WHERE cod_param = 118;

    SELECT cve_sorteo, descripcion INTO cCveSorteo, cResultado
    FROM si_sorteo WHERE cve_sorteo = v_param;

    RETURN cCodRet, cCveSorteo, cResultado;    

    END;
END PROCEDURE;