CREATE PROCEDURE "informix".sp_generafoliorepide(pClave CHAR(2))
RETURNING CHAR(5) AS retorno,
          CHAR(8) AS valor;

    DEFINE iSqlErr		INTEGER;
    DEFINE cValRetorno	CHAR(5);
    DEFINE cValor		CHAR(8);

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET iSqlErr     = 0;
    LET cValRetorno = '00001';
    LET cValor      = '';

    --- SET DEBUG FILE TO "/tmp/sp_generafoliorepide.out"; 
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr,'';
        END IF;
    END EXCEPTION;		

    IF NVL(pClave,'') = '' THEN
        RETURN cValRetorno,'';
    END IF;

    Select valor
      INTO cValor
      From bdilide:"informix".sl_parametros 
     Where cve_param = pClave;

    LET cValor = cValor + 1;

    Update bdilide:"informix".sl_parametros 
       SET valor = TRIM (cValor) 
     Where cve_param = pClave;

    LET cValRetorno = '00000';
    
    RETURN cValRetorno,cValor WITH RESUME;					
    
    END
    
END PROCEDURE             
